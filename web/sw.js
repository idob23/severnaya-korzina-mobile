// sw.js - Service Worker для Северной Корзины PWA
const CACHE_NAME = 'sevkorzina-v1.0.0';
const urlsToCache = [
  '/',
  '/main.dart.js',
  '/flutter.js',
  '/flutter_bootstrap.js',
  '/manifest.json',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/icons/Icon-maskable-192.png',
  '/icons/Icon-maskable-512.png',
  // Добавьте другие критичные файлы
];

// Установка Service Worker
self.addEventListener('install', event => {
  console.log('🔧 Service Worker устанавливается...');
  
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('💾 Кэшируем основные файлы');
        return cache.addAll(urlsToCache);
      })
      .catch(error => {
        console.error('❌ Ошибка кэширования:', error);
      })
  );
  
  // Принудительная активация нового SW
  self.skipWaiting();
});

// Активация Service Worker
self.addEventListener('activate', event => {
  console.log('✅ Service Worker активируется...');
  
  event.waitUntil(
    Promise.all([
      // Очищаем старые кэши
      caches.keys().then(cacheNames => {
        return Promise.all(
          cacheNames.map(cacheName => {
            if (cacheName !== CACHE_NAME) {
              console.log('🗑️ Удаляем старый кэш:', cacheName);
              return caches.delete(cacheName);
            }
          })
        );
      }),
      // Берем контроль над всеми клиентами
      self.clients.claim()
    ])
  );
});

// Перехват сетевых запросов
self.addEventListener('fetch', event => {
  // Только для GET запросов
  if (event.request.method !== 'GET') {
    return;
  }
  
  event.respondWith(
    caches.match(event.request)
      .then(cachedResponse => {
        // Если есть в кэше - возвращаем
        if (cachedResponse) {
          // Для основных файлов делаем фоновое обновление
          if (shouldUpdateInBackground(event.request.url)) {
            fetchAndCache(event.request);
          }
          return cachedResponse;
        }
        
        // Если нет в кэше - загружаем из сети
        return fetchAndCache(event.request);
      })
      .catch(() => {
        // Офлайн страница для навигационных запросов
        if (event.request.mode === 'navigate') {
          return caches.match('/');
        }
      })
  );
});

// Функция для загрузки и кэширования
function fetchAndCache(request) {
  return fetch(request)
    .then(response => {
      // Проверяем валидность ответа
      if (!response || response.status !== 200 || response.type !== 'basic') {
        return response;
      }
      
      // Клонируем ответ для кэша
      const responseToCache = response.clone();
      
      // Кэшируем только определенные типы файлов
      if (shouldCache(request.url)) {
        caches.open(CACHE_NAME)
          .then(cache => {
            cache.put(request, responseToCache);
          })
          .catch(error => {
            console.error('❌ Ошибка записи в кэш:', error);
          });
      }
      
      return response;
    })
    .catch(error => {
      console.error('❌ Ошибка сети:', error);
      throw error;
    });
}

// Определяем, нужно ли кэшировать файл
function shouldCache(url) {
  return url.includes('.js') || 
         url.includes('.css') || 
         url.includes('.png') || 
         url.includes('.jpg') || 
         url.includes('.jpeg') || 
         url.includes('.svg') || 
         url.includes('.ico') ||
         url.includes('manifest.json');
}

// Определяем, нужно ли обновлять в фоне
function shouldUpdateInBackground(url) {
  return url.includes('main.dart.js') || 
         url.includes('manifest.json');
}

// Push уведомления (для будущего использования)
self.addEventListener('push', event => {
  console.log('📢 Получено push уведомление');
  
  let notificationData = {};
  
  if (event.data) {
    try {
      notificationData = event.data.json();
    } catch (e) {
      notificationData = {
        title: 'Северная Корзина',
        body: event.data.text() || 'Новое уведомление',
      };
    }
  }
  
  const options = {
    body: notificationData.body || 'Новое уведомление от Северной Корзины',
    icon: '/icons/Icon-192.png',
    badge: '/icons/badge-72x72.png',
    image: notificationData.image,
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: notificationData.id || 1,
      url: notificationData.url || '/'
    },
    actions: [
      {
        action: 'open',
        title: 'Открыть',
        icon: '/icons/action-open.png'
      },
      {
        action: 'close',
        title: 'Закрыть',
        icon: '/icons/action-close.png'
      }
    ],
    requireInteraction: notificationData.important || false,
    silent: false,
    tag: 'sevkorzina-notification'
  };
  
  event.waitUntil(
    self.registration.showNotification(
      notificationData.title || 'Северная Корзина',
      options
    )
  );
});

// Клик по уведомлению
self.addEventListener('notificationclick', event => {
  console.log('🔔 Клик по уведомлению');
  
  event.notification.close();
  
  const urlToOpen = event.notification.data?.url || '/';
  
  if (event.action === 'open' || !event.action) {
    // Открываем приложение
    event.waitUntil(
      clients.matchAll({ type: 'window', includeUncontrolled: true })
        .then(clientList => {
          // Если приложение уже открыто - фокусируемся на нем
          for (const client of clientList) {
            if (client.url.includes(urlToOpen) && 'focus' in client) {
              return client.focus();
            }
          }
          
          // Если не открыто - открываем новое окно
          if (clients.openWindow) {
            return clients.openWindow(urlToOpen);
          }
        })
    );
  }
});

// Синхронизация в фоне (для будущего использования)
self.addEventListener('sync', event => {
  console.log('🔄 Фоновая синхронизация');
  
  if (event.tag === 'background-sync') {
    event.waitUntil(
      // Здесь можно добавить логику синхронизации данных
      console.log('Синхронизация данных...')
    );
  }
});

// Обработка ошибок
self.addEventListener('error', event => {
  console.error('❌ Ошибка Service Worker:', event.error);
});

// Логирование версии
console.log(`🚀 Service Worker Северной Корзины запущен. Версия кэша: ${CACHE_NAME}`);