# Деплой с автоматической очисткой старых версий и поддержкой шрифта MarckScript
Write-Host "Deploying with automatic cleanup and MarckScript font..." -ForegroundColor Green

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
  Remove-Item -Recurse -Force "build" 
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
    updateBtn.textContent = 'Перезагрузка...';
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
  
  setTimeout(() => document.body.classList.add('loaded'), 1500);
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
    /* ПОДКЛЮЧЕНИЕ ШРИФТА MarckScript */
    @font-face {
      font-family: 'MarckScript';
      src: url('assets/fonts/MarckScript-Regular.ttf') format('truetype');
      font-weight: 400;
      font-style: normal;
      font-display: swap;
    }

    /* ОСНОВНЫЕ СТИЛИ */
    * {
      font-family: 'MarckScript', cursive, sans-serif !important;
    }

    body {
      margin: 0;
      padding: 0;
      font-family: 'MarckScript', cursive, sans-serif;
      font-size: 16px;
    }

    /* Загрузочный экран */
    #loading {
      position: fixed; 
      top: 0; 
      left: 0; 
      width: 100%; 
      height: 100%;
      background: linear-gradient(135deg, #DC2626, #EF4444);
      display: flex; 
      flex-direction: column; 
      justify-content: center; 
      align-items: center;
      z-index: 9999; 
      transition: opacity 0.5s ease;
    }
    
    body.loaded #loading { 
      opacity: 0; 
      pointer-events: none; 
    }
    
    .loading-text { 
      color: white; 
      font-size: 28px;
      margin-bottom: 10px; 
      font-weight: bold;
      font-family: 'MarckScript', cursive, sans-serif;
    }
    
    .loading-version { 
      color: rgba(255,255,255,0.8); 
      font-size: 16px;
      margin-bottom: 20px;
      font-family: 'MarckScript', cursive, sans-serif;
    }
    
    .loading-message {
      color: rgba(255,255,255,0.9);
      font-size: 14px;
      margin-bottom: 30px;
      font-family: 'MarckScript', cursive, sans-serif;
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
    
    /* Прогресс загрузки */
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
    
    /* Кнопка перезагрузки (скрыта по умолчанию) */
    .reload-button {
      display: none;
      margin-top: 20px;
      padding: 12px 24px;
      background: white;
      color: #DC2626;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      font-family: 'MarckScript', cursive, sans-serif;
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
  
  <div id="app"></div>
  
  <script>
    // Таймер для отображения кнопки перезагрузки
    let loadingTimeout;
    let loadingStartTime = Date.now();
    
    // Показываем кнопку перезагрузки через 15 секунд
    loadingTimeout = setTimeout(function() {
      const reloadBtn = document.getElementById('reloadBtn');
      const loadingMessage = document.querySelector('.loading-message');
      
      if (reloadBtn && !document.body.classList.contains('loaded')) {
        reloadBtn.classList.add('show');
        if (loadingMessage) {
          loadingMessage.textContent = 'Loading takes longer than usual. Try reloading the page.';
        }
      }
    }, 15000);
    
    // Функция для скрытия загрузочного экрана
    function hideLoading() {
      clearTimeout(loadingTimeout);
      document.body.classList.add('loaded');
      console.log('Loading completed in', Date.now() - loadingStartTime, 'ms');
    }
    
    // Слушаем событие загрузки Flutter
    window.addEventListener('flutter-initialized', hideLoading);
    
    // Запасной вариант - скрываем через 20 секунд в любом случае
    setTimeout(function() {
      if (!document.body.classList.contains('loaded')) {
        hideLoading();
      }
    }, 20000);
    
    // Обработка ошибок загрузки
    window.addEventListener('error', function(e) {
      console.error('Loading error:', e);
      const loadingMessage = document.querySelector('.loading-message');
      if (loadingMessage && !document.body.classList.contains('loaded')) {
        loadingMessage.textContent = 'An error occurred while loading. Please refresh the page.';
        const reloadBtn = document.getElementById('reloadBtn');
        if (reloadBtn) {
          reloadBtn.classList.add('show');
        }
      }
    });
  </script>
  
  <script src="flutter-$NEW_VERSION.js" defer></script>
  <script>
    window.addEventListener('load', function(ev) {
      setTimeout(function() {
        document.body.classList.add('loaded');
      }, 100);
    });
  </script>
  <script src="app-$NEW_VERSION.js"></script>
  <script src="main-$NEW_VERSION.js" defer></script>
</body>
</html>
"@

# Перезаписываем index.html ПОСЛЕ сборки
[System.IO.File]::WriteAllText("build\web\index.html", $indexHtml, $utf8NoBOM)
Write-Host "  index.html updated with version $NEW_VERSION" -ForegroundColor Green

# Копирование шрифта в сборку
Write-Host "Copying MarckScript font..." -ForegroundColor Cyan
if (Test-Path "assets\fonts\MarckScript-Regular.ttf") {
    # Создаем папку для шрифтов если её нет
    if (-not (Test-Path "build\web\assets\fonts")) {
        New-Item -ItemType Directory -Force -Path "build\web\assets\fonts"
    }
    
    # Копируем шрифт
    Copy-Item "assets\fonts\MarckScript-Regular.ttf" "build\web\assets\fonts\MarckScript-Regular.ttf" -Force
    Write-Host "  Font copied successfully" -ForegroundColor Green
} else {
    Write-Host "  WARNING: Font file not found at assets\fonts\MarckScript-Regular.ttf" -ForegroundColor Red
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
          '/assets/fonts/MarckScript-Regular.ttf'
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
Write-Host "MarckScript font included in build" -ForegroundColor Magenta
Write-Host "`nIMPORTANT: index.html has been updated with correct version numbers!" -ForegroundColor Yellow

pause