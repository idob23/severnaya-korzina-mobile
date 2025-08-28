# Деплой с автоматической очисткой старых версий
Write-Host "Deploying with automatic cleanup..." -ForegroundColor Green

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
                File = $file
                Version = $version
                Path = Join-Path $path $file
            }
        }
    }
    
    $totalDeleted = 0
    
    foreach ($type in $groupedFiles.Keys) {
        $files = $groupedFiles[$type] | Sort-Object Version -Descending
        
        # Оставляем 3 последние версии
        if ($files.Count -gt 3) {
            $toDelete = $files[3..($files.Count-1)]
            
            Write-Host "  Deleting $($toDelete.Count) old $type files" -ForegroundColor Yellow
            foreach ($file in $toDelete) {
                try {
                    Remove-Item $file.Path -Force
                    Write-Host "    Deleted: $($file.File)" -ForegroundColor Gray
                    $totalDeleted++
                } catch {
                    Write-Host "    Failed to delete: $($file.File)" -ForegroundColor Red
                }
            }
        }
    }
    
    if ($totalDeleted -gt 0) {
        Write-Host "  Cleaned up $totalDeleted old files" -ForegroundColor Green
    }
}

# Обычный процесс сборки
if (Test-Path "build") { 
    Cleanup-OldVersions "build\web"
    Remove-Item -Recurse -Force "build" 
}

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
  const dismissBtn = document.getElementById('dismiss-btn');
  
  if (updateBtn) {
    updateBtn.addEventListener('click', updateApp);
  }
  
  if (dismissBtn) {
    dismissBtn.addEventListener('click', hideUpdateNotification);
  }
  
  setTimeout(() => document.body.classList.add('loaded'), 1500);
});
"@

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
  
  <title>Severnaya Korzina v$NEW_VERSION</title>
  <link rel="manifest" href="manifest.json">
  <link rel="icon" type="image/png" href="favicon.png">
  
  <style>
    #loading {
      position: fixed; top: 0; left: 0; width: 100%; height: 100%;
      background: linear-gradient(135deg, #DC2626, #EF4444);
      display: flex; flex-direction: column; justify-content: center; align-items: center;
      z-index: 9999; transition: opacity 0.5s ease;
    }
    body.loaded #loading { opacity: 0; pointer-events: none; }
    
    .loading-text { color: white; font-size: 24px; margin-bottom: 10px; font-weight: bold; }
    .loading-version { color: rgba(255,255,255,0.8); font-size: 14px; margin-bottom: 30px; }
    .loading-spinner {
      width: 40px; height: 40px; border: 4px solid rgba(255,255,255,0.3);
      border-top: 4px solid white; border-radius: 50%;
      animation: spin 1s linear infinite;
    }
    
    #update-notification {
      position: fixed; top: 20px; left: 50%; transform: translateX(-50%);
      background: #DC2626; color: white; padding: 20px; border-radius: 12px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.4); z-index: 10000; 
      display: none; text-align: center; min-width: 320px;
    }
    
    .notification-title { font-size: 18px; font-weight: bold; margin-bottom: 8px; }
    .notification-text { margin: 10px 0 20px 0; font-size: 14px; opacity: 0.9; }
    .button-group { display: flex; gap: 10px; justify-content: center; }
    
    #update-notification button {
      background: white; color: #DC2626; border: none;
      padding: 12px 24px; border-radius: 8px; cursor: pointer; 
      font-weight: bold; min-width: 120px;
    }
    
    #dismiss-btn {
      background: transparent !important; border: 2px solid white !important;
      color: white !important;
    }
    
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <div id="loading">
    <div class="loading-text">Severnaya Korzina</div>
    <div class="loading-version">v$NEW_VERSION</div>
    <div class="loading-spinner"></div>
  </div>
  
  <div id="update-notification">
    <div class="notification-title">New version available!</div>
    <div class="notification-text">Click to reload with latest version</div>
    <div class="button-group">
      <button id="update-btn">Update Now</button>
      <button id="dismiss-btn">Later</button>
    </div>
  </div>
  
  <div id="app"></div>
  
  <script src="app-$NEW_VERSION.js"></script>
  <script src="main-$NEW_VERSION.js" async></script>
  <script src="flutter-$NEW_VERSION.js" async></script>
</body>
</html>
"@

Write-Host "Creating files..." -ForegroundColor Cyan
$utf8 = New-Object System.Text.UTF8Encoding $False
[System.IO.File]::WriteAllText("web\index.html", $indexHtml, $utf8)
[System.IO.File]::WriteAllText("web\app-updater.js", $appUpdaterJs, $utf8)

Write-Host "Flutter build..." -ForegroundColor Cyan
flutter clean
flutter pub get
flutter build web --release

Write-Host "Renaming files..." -ForegroundColor Yellow

# Переименование файлов
if (Test-Path "build\web\main.dart.js") {
    Move-Item "build\web\main.dart.js" "build\web\main-$NEW_VERSION.js"
    Write-Host "  main.dart.js -> main-$NEW_VERSION.js" -ForegroundColor Green
}

if (Test-Path "build\web\flutter.js") {
    Move-Item "build\web\flutter.js" "build\web\flutter-$NEW_VERSION.js"
    Write-Host "  flutter.js -> flutter-$NEW_VERSION.js" -ForegroundColor Green
}

Copy-Item "web\app-updater.js" "build\web\app-$NEW_VERSION.js"
Write-Host "  created app-$NEW_VERSION.js" -ForegroundColor Green

# Service Worker
$swContent = @"
const CACHE_VERSION = '$NEW_VERSION';
const CACHE_NAME = 'sevkorzina-' + CACHE_VERSION;

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.addAll([
          '/', '/main-$NEW_VERSION.js', '/flutter-$NEW_VERSION.js', '/app-$NEW_VERSION.js'
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

[System.IO.File]::WriteAllText("build\web\sw-$NEW_VERSION.js", $swContent, $utf8)
Write-Host "  created sw-$NEW_VERSION.js" -ForegroundColor Green

# Обновление index.html с правильными именами файлов
[System.IO.File]::WriteAllText("build\web\index.html", $indexHtml, $utf8)

# Финальная очистка
Write-Host "`nFinal cleanup..." -ForegroundColor Cyan
Cleanup-OldVersions "build\web"

Write-Host "`nDEPLOY WITH CLEANUP COMPLETED!" -ForegroundColor Green -BackgroundColor Black
Write-Host "Version: $NEW_VERSION" -ForegroundColor Yellow
Write-Host "Old versions automatically cleaned (keeping 3 latest)" -ForegroundColor Cyan

pause