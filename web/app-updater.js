let swRegistration = null;
const APP_VERSION = '6.08311645';
console.log('APP VERSION: ' + APP_VERSION);

async function registerServiceWorker() {
  if ('serviceWorker' in navigator) {
    try {
      console.log('Registering Service Worker...');
      swRegistration = await navigator.serviceWorker.register('/sw-6.08311645.js', {
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