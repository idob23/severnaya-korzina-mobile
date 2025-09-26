# Деплой с автоматической очисткой старых версий и поддержкой шрифта Inter 
Write-Host "Deploying with automatic cleanup and Inter font..." -ForegroundColor Green

$timestamp = [DateTimeOffset]::Now.ToString("MMddHHmm")
$NEW_VERSION = "6.$timestamp"
Write-Host "New version: $NEW_VERSION" -ForegroundColor Yellow

# Функция очистки старых файлов
function Cleanup-OldVersions {
  param($path)
    
  Write-Host "Cleaning old versions from: $path" -ForegroundColor Cyan
    
  if (-not (Test-Path $path)) {
    return
  }
    
  $versionedFiles = Get-ChildItem $path -Name | Where-Object { 
    $_ -match "(main|flutter|app|sw)-\d+\.\d+\.js$" 
  }
    
  if ($versionedFiles.Count -eq 0) {
    Write-Host "  No old versions to clean" -ForegroundColor Gray
    return
  }
    
  # Группируем по типу файла
  $groupedFiles = @{}
  foreach ($file in $versionedFiles) {
    if ($file -match "^(main|flutter|app|sw)-(\d+\.\d+)\.js$") {
      $type = $matches[1]
      $version = [double]$matches[2]
            
      if (-not $groupedFiles.ContainsKey($type)) {
        $groupedFiles[$type] = @()
      }
            
      $groupedFiles[$type] += @{
        File    = $file
        Version = $version
        Path    = Join-Path $path $file
      }
    }
  }
    
  $totalDeleted = 0
    
  foreach ($type in $groupedFiles.Keys) {
    $files = $groupedFiles[$type] | Sort-Object Version -Descending
        
    # Оставляем 3 последние версии
    if ($files.Count -gt 3) {
      $toDelete = $files[3..($files.Count - 1)]
            
      Write-Host "  Deleting $($toDelete.Count) old $type files" -ForegroundColor Yellow
      foreach ($file in $toDelete) {
        try {
          Remove-Item $file.Path -Force
          Write-Host "    Deleted: $($file.File)" -ForegroundColor Gray
          $totalDeleted++
        }
        catch {
          Write-Host "    Failed to delete: $($file.File)" -ForegroundColor Red
        }
      }
    }
  }
    
  if ($totalDeleted -gt 0) {
    Write-Host "  Cleaned up $totalDeleted old files" -ForegroundColor Green
  }
}

# Очистка старой сборки
if (Test-Path "build") { 
  Cleanup-OldVersions "build\web"

  Write-Host "Preparing for deployment..." -ForegroundColor Cyan
  
  # 1. Завершаем Java процессы
  Write-Host "Stopping background processes..." -ForegroundColor Yellow
  Get-Process java, dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
  Start-Sleep -Seconds 2
  
  # 2. Пытаемся удалить папку build с повторными попытками
  $maxAttempts = 3
  $attempt = 0
  $buildDeleted = $false
  
  while ($attempt -lt $maxAttempts -and -not $buildDeleted) {
    try {
      Remove-Item -Recurse -Force "build" -ErrorAction Stop
      Write-Host "Build folder cleaned successfully" -ForegroundColor Green
      $buildDeleted = $true
    }
    catch {
      $attempt++
      if ($attempt -eq $maxAttempts) {
        Write-Host "Warning: Could not fully clean build folder. Some files may be locked." -ForegroundColor Yellow
        Write-Host "Trying alternative cleanup..." -ForegroundColor Yellow
        
        # Альтернативный метод - удаляем только web папку
        if (Test-Path "build/web") {
          Remove-Item -Recurse -Force "build/web" -ErrorAction SilentlyContinue
          Write-Host "Web folder cleaned" -ForegroundColor Yellow
        }
      }
      else {
        Write-Host "Attempt $attempt failed. Waiting..." -ForegroundColor Yellow
        # Ждем и пробуем завершить Java процессы еще раз
        Get-Process java, dart -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
      }
    }
  }
}

# СНАЧАЛА делаем Flutter build (он создаст стандартный index.html)
Write-Host "Flutter build..." -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build web --release

Write-Host "Renaming files..." -ForegroundColor Yellow

# Переименование файлов
if (Test-Path "build\web\main.dart.js") {
  Move-Item "build\web\main.dart.js" "build\web\main-$NEW_VERSION.js" -Force
  Write-Host "  main.dart.js -> main-$NEW_VERSION.js" -ForegroundColor Green
}

if (Test-Path "build\web\flutter.js") {
  Move-Item "build\web\flutter.js" "build\web\flutter-$NEW_VERSION.js" -Force
  Write-Host "  flutter.js -> flutter-$NEW_VERSION.js" -ForegroundColor Green
}

if (Test-Path "build\web\flutter_service_worker.js") {
  Move-Item "build\web\flutter_service_worker.js" "build\web\flutter_service_worker-$NEW_VERSION.js" -Force
  Write-Host "  flutter_service_worker.js -> flutter_service_worker-$NEW_VERSION.js" -ForegroundColor Green
}

# Устанавливаем правильную кодировку для PowerShell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Создаем app-updater.js
$appUpdaterJs = @"
let swRegistration = null;
const APP_VERSION = '$NEW_VERSION';
console.log('APP VERSION: ' + APP_VERSION);

async function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    try {
      console.log('Registering Service Worker...');
      swRegistration = await navigator.serviceWorker.register('/sw-$NEW_VERSION.js', {
        updateViaCache: 'none'
      });
      console.log('Service Worker registered');

      swRegistration.addEventListener('updatefound', function() {
        console.log('Update found');
        const newWorker = swRegistration.installing;
        newWorker.addEventListener('statechange', function() {
          if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
            showUpdateNotification();
          }
        });
      });
      
    } catch (error) {
      console.error('Service Worker error:', error);
    }
  }
}

function showUpdateNotification() {
  const notification = document.getElementById('update-notification');
  if (notification) {
    notification.style.display = 'block';
  }
}

function hideUpdateNotification() {
  const notification = document.getElementById('update-notification');
  if (notification) {
    notification.style.display = 'none';
  }
}

function updateApp() {
  const updateBtn = document.getElementById('update-btn');
  if (updateBtn) {
    updateBtn.textContent = 'Reloading...';
    updateBtn.disabled = true;
  }
  
  sessionStorage.setItem('force_version_check', APP_VERSION);
  window.location.href = window.location.href.split('?')[0] + '?nocache=' + Date.now();
}

function checkAppVersion() {
  const savedVersion = localStorage.getItem('app_version');
  const forceCheck = sessionStorage.getItem('force_version_check');
  
  console.log('Version check - Saved:', savedVersion, 'Current:', APP_VERSION);
  
  if (forceCheck) {
    localStorage.setItem('app_version', APP_VERSION);
    sessionStorage.removeItem('force_version_check');
    return;
  }
  
  if (savedVersion && savedVersion !== APP_VERSION) {
    console.log('NEW VERSION DETECTED');
    setTimeout(() => showUpdateNotification(), 2000);
  } else if (!savedVersion) {
    localStorage.setItem('app_version', APP_VERSION);
  }
}

window.addEventListener('load', function() {
  setTimeout(() => {
    checkAppVersion();
    registerServiceWorker();
  }, 500);
  
  const updateBtn = document.getElementById('update-btn');
  if (updateBtn) {
    updateBtn.addEventListener('click', updateApp);
  }
  
  // УБРАНА строка которая конфликтовала: setTimeout(() => document.body.classList.add('loaded'), 1500);
});
"@

$utf8NoBOM = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("build\web\app-$NEW_VERSION.js", $appUpdaterJs, $utf8NoBOM)
Write-Host "  created app-$NEW_VERSION.js" -ForegroundColor Green

# ТЕПЕРЬ создаем правильный index.html (ПОСЛЕ сборки Flutter)
$indexHtml = @"
<!DOCTYPE html>
<html lang="ru">
<head>
  <base href="/">
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="#DC2626">
  
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="-1">
  
  <title>Severnaya Korzina</title>
  <link rel="manifest" href="manifest.json">
  <link rel="icon" type="image/png" href="favicon.png">
  
  <style>
    /* ПОДКЛЮЧЕНИЕ ШРИФТА Inter */
    @font-face {
      font-family: 'Inter';
      src: url('assets/fonts/Inter-Regular.ttf') format('truetype');
      font-weight: 400;
      font-style: normal;
      font-display: swap;
    }

    @font-face {
      font-family: 'Inter';
      src: url('assets/fonts/Inter-Medium.ttf') format('truetype');
      font-weight: 500;
      font-style: normal;
      font-display: swap;
    }

    @font-face {
      font-family: 'Inter';
      src: url('assets/fonts/Inter-SemiBold.ttf') format('truetype');
      font-weight: 600;
      font-style: normal;
      font-display: swap;
    }

    @font-face {
      font-family: 'Inter';
      src: url('assets/fonts/Inter-Bold.ttf') format('truetype');
      font-weight: 700;
      font-style: normal;
      font-display: swap;
    }

    /* ОСНОВНЫЕ СТИЛИ */
    * {
      font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif !important;
    }

    html, body {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      font-family: 'Inter', sans-serif;
      font-size: 14px;
      background: #DC2626 !important;
      overflow: hidden;
    }

    /* КРИТИЧНО: Скрываем ВСЕ Flutter элементы до полной загрузки */
    flt-glass-pane {
      display: none !important;
      opacity: 0 !important;
      visibility: hidden !important;
    }

    /* Показываем Flutter только после загрузки */
    body.flutter-ready flt-glass-pane {
      display: block !important;
      opacity: 1 !important;
      visibility: visible !important;
      animation: fadeIn 0.3s ease-in-out;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    /* После полной загрузки */
    body.flutter-ready {
      background: white !important;
      overflow: auto !important;
    }

    /* Загрузочный экран */
    #loading {
      position: fixed !important;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(135deg, #DC2626, #EF4444);
      display: flex;
      flex-direction: column;
      justify-content: center;
      align-items: center;
      z-index: 999999 !important;
      transition: opacity 0.5s ease;
      pointer-events: all;
    }

    body.flutter-ready #loading {
      opacity: 0 !important;
      pointer-events: none !important;
    }

    body.flutter-ready.loading-hidden #loading {
      display: none !important;
    }
    
    .loading-text { 
      color: white; 
      font-size: 28px;
      margin-bottom: 10px; 
      font-weight: bold;
      font-family: 'Inter', sans-serif;
    }
    
    .loading-version { 
      color: rgba(255,255,255,0.8); 
      font-size: 16px;
      margin-bottom: 20px;
      font-family: 'Inter', sans-serif;
    }
    
    .loading-message {
      color: rgba(255,255,255,0.9);
      font-size: 14px;
      margin-bottom: 30px;
      font-family: 'Inter', sans-serif;
      text-align: center;
      max-width: 300px;
      animation: fadeInOut 2s ease-in-out infinite;
    }
    
    @keyframes fadeInOut {
      0%, 100% { opacity: 0.6; }
      50% { opacity: 1; }
    }
    
    .loading-spinner {
      width: 40px; 
      height: 40px; 
      border: 4px solid rgba(255,255,255,0.3);
      border-top: 4px solid white; 
      border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    
    .loading-progress {
      width: 200px;
      height: 4px;
      background: rgba(255,255,255,0.2);
      border-radius: 2px;
      margin-top: 20px;
      overflow: hidden;
    }
    
    .loading-progress-bar {
      height: 100%;
      background: white;
      border-radius: 2px;
      animation: progress 3s ease-in-out infinite;
    }
    
    @keyframes progress {
      0% { width: 0%; }
      50% { width: 70%; }
      100% { width: 100%; }
    }
    
    .reload-button {
      display: none;
      margin-top: 20px;
      padding: 12px 24px;
      background: white;
      color: #DC2626;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-family: 'Inter', sans-serif;
      cursor: pointer;
      font-weight: bold;
      transition: transform 0.2s;
    }
    
    .reload-button:hover {
      transform: scale(1.05);
    }
    
    .reload-button.show {
      display: block;
    }
    
    @keyframes spin { 
      0% { transform: rotate(0deg); } 
      100% { transform: rotate(360deg); } 
    }

    @keyframes pulse {
      0%, 100% { opacity: 0.7; transform: scale(1); }
      50% { opacity: 1; transform: scale(1.05); }
    }

    /* УВЕДОМЛЕНИЕ ОБ ОБНОВЛЕНИИ */
    #update-notification {
      position: fixed;
      top: 20px;
      left: 50%;
      transform: translateX(-50%);
      background: #DC2626;
      color: white;
      padding: 20px;
      border-radius: 12px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.4);
      z-index: 1000000;
      display: none;
      text-align: center;
      min-width: 320px;
      font-family: 'Inter', sans-serif;
    }
    
    .notification-title {
      font-size: 18px;
      font-weight: bold;
      margin-bottom: 8px;
    }
    
    .notification-text {
      margin: 10px 0 20px 0;
      opacity: 0.9;
    }
    
    #update-btn {
      background: white;
      color: #DC2626;
      border: none;
      padding: 12px 24px;
      border-radius: 8px;
      cursor: pointer;
      font-weight: bold;
      min-width: 120px;
      font-family: 'Inter', sans-serif;
      transition: transform 0.2s;
    }
    
    #update-btn:hover {
      transform: scale(1.05);
    }
    
    #update-btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
  </style>
</head>
<body>
  <div id="loading">
    <div class="loading-text">Severnaya Korzina</div>
    <div class="loading-version">v$NEW_VERSION</div>
    <div class="loading-message">Loading...</div>
    <div class="loading-spinner"></div>
    <div class="loading-progress">
      <div class="loading-progress-bar"></div>
    </div>
    <button class="reload-button" id="reloadBtn" onclick="window.location.reload()">
      Reload
    </button>
  </div>
  
  <!-- Update notification -->
  <div id="update-notification">
    <div class="notification-title">New version available!</div>
    <div class="notification-text">Click to update</div>
    <button id="update-btn">Update</button>
  </div>
  
  <script>
    // Timer and state variables
    let loadingTimeout;
    let loadingStartTime = Date.now();
    let flutterInitialized = false;
    let flutterReady = false;
    
    // Progressive loading messages
    setTimeout(function() {
      if (!flutterReady) {
        const loadingMessage = document.querySelector('.loading-message');
        if (loadingMessage) {
          loadingMessage.textContent = 'Initializing app...';
        }
      }
    }, 2000);
    
    setTimeout(function() {
      if (!flutterReady) {
        const loadingMessage = document.querySelector('.loading-message');
        if (loadingMessage) {
          loadingMessage.textContent = 'Loading components...';
        }
      }
    }, 4000);
    
    setTimeout(function() {
      if (!flutterReady) {
        const loadingMessage = document.querySelector('.loading-message');
        if (loadingMessage) {
          loadingMessage.textContent = 'Almost ready...';
        }
      }
    }, 6000);
    
    // Show reload button after 15 seconds
    loadingTimeout = setTimeout(function() {
      const reloadBtn = document.getElementById('reloadBtn');
      const loadingMessage = document.querySelector('.loading-message');
      
      if (reloadBtn && !flutterReady) {
        reloadBtn.classList.add('show');
        if (loadingMessage) {
          loadingMessage.textContent = 'Loading takes longer than usual. Try reloading.';
        }
      }
    }, 15000);
    
    // Function to hide loading screen PROPERLY
    function hideLoading() {
      console.log('Hiding loader...');
      flutterReady = true;
      clearTimeout(loadingTimeout);
      
      // Добавляем класс для показа Flutter
      document.body.classList.add('flutter-ready');
      
      // Убираем загрузчик через 500ms после показа Flutter
      setTimeout(function() {
        document.body.classList.add('loading-hidden');
        console.log('Loading completed in', Date.now() - loadingStartTime, 'ms');
      }, 500);
    }
    
    // Ждем инициализации Flutter Engine
    window.addEventListener('flutter-first-frame', function() {
      console.log('Flutter first frame detected!');
      if (!flutterReady) {
        hideLoading();
      }
    });
    
    // Альтернативный способ детекции Flutter
    let flutterCheckCount = 0;
    let checkFlutterInterval = setInterval(function() {
      flutterCheckCount++;
      
      // Проверяем наличие Flutter элементов и их содержимого
      const flutterView = document.querySelector('flt-glass-pane');
      const flutterScene = document.querySelector('flt-scene');
      const flutterCanvas = document.querySelector('canvas');
      
      // Проверяем что Flutter действительно отрендерил контент
      if (flutterView && (flutterScene || flutterCanvas)) {
        // Дополнительная проверка - есть ли дочерние элементы
        const hasChildren = flutterView.children.length > 0 || 
                          (flutterScene && flutterScene.children.length > 0);
        
        if (hasChildren) {
          console.log('Flutter content fully rendered!');
          clearInterval(checkFlutterInterval);
          
          // Даем Flutter еще немного времени для финальной отрисовки
          setTimeout(function() {
            if (!flutterReady) {
              hideLoading();
            }
          }, 300);
        }
      }
      
      // Останавливаем проверку после 300 попыток (30 секунд)
      if (flutterCheckCount > 300) {
        clearInterval(checkFlutterInterval);
        console.log('Flutter check timeout, force showing content');
        if (!flutterReady) {
          hideLoading();
        }
      }
    }, 100);
    
    // Используем Flutter loader API если доступен
    if (window._flutter) {
      window._flutter.loader.loadEntrypoint({
        onEntrypointLoaded: async function(engineInitializer) {
          console.log('Flutter entrypoint loaded');
          flutterInitialized = true;
          const appRunner = await engineInitializer.initializeEngine();
          
          // Ждем запуска приложения
          appRunner.runApp().then(function() {
            console.log('Flutter app running');
            // Даем время на первый рендер
            setTimeout(function() {
              if (!flutterReady) {
                hideLoading();
              }
            }, 500);
          });
        }
      });
    }
    
    // Запасной вариант - принудительно скрываем через 30 секунд
    setTimeout(function() {
      if (!flutterReady) {
        console.log('Force hiding loader after 30 seconds');
        hideLoading();
      }
    }, 30000);
    
    // Обработка ошибок загрузки
    window.addEventListener('error', function(e) {
      console.error('Loading error:', e);
      const loadingMessage = document.querySelector('.loading-message');
      if (loadingMessage && !flutterReady) {
        loadingMessage.textContent = 'An error occurred. Please reload the page.';
        const reloadBtn = document.getElementById('reloadBtn');
        if (reloadBtn) {
          reloadBtn.classList.add('show');
        }
      }
    });
  </script>
  
  <script src="flutter-$NEW_VERSION.js" defer></script>
  <script src="app-$NEW_VERSION.js"></script>
  <script src="main-$NEW_VERSION.js" defer></script>
</body>
</html>
"@

# Перезаписываем index.html ПОСЛЕ сборки с правильной кодировкой
$utf8WithBOM = New-Object System.Text.UTF8Encoding $True
[System.IO.File]::WriteAllText("build\web\index.html", $indexHtml, $utf8WithBOM)
Write-Host "  index.html updated with version $NEW_VERSION" -ForegroundColor Green

# Копирование шрифтов Inter в сборку
Write-Host "Copying Inter fonts..." -ForegroundColor Cyan

# Создаем папку для шрифтов если её нет
if (-not (Test-Path "build\web\assets\fonts")) {
  New-Item -ItemType Directory -Force -Path "build\web\assets\fonts"
}

# Копируем все веса шрифта Inter
$fontFiles = @(
  "Inter-Regular.ttf",
  "Inter-Medium.ttf", 
  "Inter-SemiBold.ttf",
  "Inter-Bold.ttf"
)

foreach ($font in $fontFiles) {
  if (Test-Path "assets\fonts\$font") {
    Copy-Item "assets\fonts\$font" "build\web\assets\fonts\$font" -Force
    Write-Host "  $font copied successfully" -ForegroundColor Green
  }
  else {
    Write-Host "  WARNING: Font file not found at assets\fonts\$font" -ForegroundColor Red
  }
}

# Service Worker
$swContent = @"
const CACHE_VERSION = '$NEW_VERSION';
const CACHE_NAME = 'sevkorzina-' + CACHE_VERSION;

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.addAll([
          '/', 
          '/main-$NEW_VERSION.js', 
          '/flutter-$NEW_VERSION.js', 
          '/app-$NEW_VERSION.js',
          '/assets/fonts/Inter-Regular.ttf',
          '/assets/fonts/Inter-Medium.ttf',
          '/assets/fonts/Inter-SemiBold.ttf',
          '/assets/fonts/Inter-Bold.ttf'
        ]);
      })
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(names => {
      return Promise.all(
        names.map(name => {
          if (name !== CACHE_NAME) return caches.delete(name);
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  if (event.request.method === 'GET' && event.request.url.startsWith(self.location.origin)) {
    event.respondWith(
      fetch(event.request)
        .then(response => {
          if (response.ok) {
            const responseClone = response.clone();
            caches.open(CACHE_NAME).then(cache => cache.put(event.request, responseClone));
          }
          return response;
        })
        .catch(() => caches.match(event.request))
    );
  }
});
"@

[System.IO.File]::WriteAllText("build\web\sw-$NEW_VERSION.js", $swContent, $utf8NoBOM)
Write-Host "  created sw-$NEW_VERSION.js" -ForegroundColor Green

# Финальная очистка
Write-Host "`nFinal cleanup..." -ForegroundColor Cyan
Cleanup-OldVersions "build\web"

Write-Host "`nDEPLOY WITH CLEANUP COMPLETED!" -ForegroundColor Green -BackgroundColor Black
Write-Host "Version: $NEW_VERSION" -ForegroundColor Yellow
Write-Host "Old versions automatically cleaned (keeping 3 latest)" -ForegroundColor Cyan
Write-Host "Inter font included in build" -ForegroundColor Magenta
Write-Host "`nIMPORTANT: index.html has been updated with correct version numbers!" -ForegroundColor Yellow

pause