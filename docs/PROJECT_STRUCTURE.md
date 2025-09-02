# 🏗️ Структура проекта "Северная Корзина"

## 📁 Обзор репозиториев

```
🌐 GitHub: https://github.com/idob23/
├── 📱 severnaya_korzina/              # Мобильное приложение Flutter
├── 🔧 severnaya_korzina_admin/        # Админ панель Flutter Web  
└── 🗄️ severnaya-korzina-backend/     # Backend API Node.js
```

---

## 🗄️ BACKEND API (severnaya-korzina-backend)

### 📂 Корневая структура:
```
severnaya-korzina-backend/
├── 📄 package.json              # Зависимости и скрипты
├── 📄 .env                      # Переменные окружения
├── 📄 .gitignore               # Исключения Git
├── 🗄️ prisma/                  # База данных
│   ├── schema.prisma           # Схема БД
│   ├── migrations/             # Миграции
│   └── seed.js                 # Тестовые данные
├── 📁 src/                     # Исходный код
├── 📁 public/                  # Статические файлы
│   └── downloads/              # APK файлы для обновлений
└── 📄 Dockerfile               # Контейнеризация
```

### 🔧 src/ - Основной код:
```
src/
├── 🌐 server.js                # Главный файл сервера
├── 📁 routes/                  # API маршруты
│   ├── auth.js                 # Авторизация
│   ├── users.js               # Пользователи
│   ├── products.js            # Товары
│   ├── orders.js              # Заказы
│   ├── payments.js            # Платежи
│   ├── batches.js             # Закупки
│   ├── addresses.js           # Адреса
│   ├── admin.js               # Админские функции (РАСШИРЕН)
│   ├── sms.js                 # SMS сервис
│   └── app.js                 # API обновлений приложения
├── 📁 middleware/              # Промежуточное ПО
│   ├── auth.js                # Аутентификация
│   └── safety.js              # Безопасность
└── 📁 utils/                   # Утилиты
    └── batchCalculations.js    # Расчеты закупок
```

### 🆕 Новые API endpoints (admin.js):
```javascript
// Управление пользователями
DELETE /api/admin/users/:id         // Удаление пользователя
PUT /api/admin/users/:id/deactivate // Деактивация пользователя

// Управление товарами  
DELETE /api/admin/products/:id      // Удаление товара

// Управление партиями
DELETE /api/admin/batches/:id       // Удаление партии
GET /api/admin/batches/:id/total-order     // Общий заказ партии
GET /api/admin/batches/:id/orders-by-users // Заказы по пользователям
```

### 🗄️ Структура базы данных:
```
PostgreSQL Database:
├── 👥 users                   # Пользователи
├── 🏠 addresses               # Адреса доставки (CASCADE при удалении user)
├── 📦 categories              # Категории товаров
├── 🛍️ products                # Товары (RESTRICT при удалении если есть заказы)
├── 📊 batches                 # Закупки/партии
├── 📋 batch_items             # Товары в закупках (CASCADE при удалении batch)
├── 🛒 orders                  # Заказы (RESTRICT при удалении user)
└── 📝 order_items             # Позиции заказов (CASCADE при удалении order)
```

---

## 📱 МОБИЛЬНОЕ ПРИЛОЖЕНИЕ (severnaya_korzina)

### 📂 Структура Flutter:
```
severnaya_korzina/
├── 📄 pubspec.yaml             # Зависимости Flutter (версия 1.2.0+12)
├── 📁 lib/                     # Код приложения
│   ├── 🎯 main.dart           # Точка входа с UpdateService
│   ├── 📱 screens/            # Экраны
│   ├── 🔧 services/           # API сервисы
│   ├── 🎨 widgets/            # UI компоненты
│   ├── 📊 models/             # Модели данных
│   ├── 🔄 providers/          # Управление состоянием
│   └── 🎨 constants/          # Константы и стили
├── 🤖 android/                # Android конфиг
├── 🍎 ios/                    # iOS конфиг
├── 🌐 web/                    # Web конфиг
├── 📁 docs/                   # Документация проекта
│   ├── PROJECT_OVERVIEW.md   # Обзор проекта
│   ├── CURRENT_STATUS.md     # Текущий статус
│   └── PROJECT_STRUCTURE.md  # Этот файл
└── 📁 build/                  # Скомпилированные файлы
    └── app/outputs/flutter-apk/
        └── app-release.apk    # Готовый APK
```

---

## 🔧 АДМИН ПАНЕЛЬ (severnaya_korzina_admin)

### 📂 Структура админки:
```
severnaya_korzina_admin/
├── 📄 pubspec.yaml             # Зависимости
├── 📁 lib/                     # Код админки
│   ├── 🎯 main.dart           # Точка входа
│   ├── 📊 screens/            # Экраны
│   │   ├── dashboard_screen.dart        # Главный экран (ОБНОВЛЕН)
│   │   ├── add_product_screen.dart      # Добавление товаров
│   │   └── admin/
│   │       ├── batch_details_screen.dart # Детали партии (НОВЫЙ)
│   │       └── orders_management_screen.dart # Управление заказами
│   ├── 🔧 services/           # API сервисы
│   │   └── admin_api_service.dart       # API админки (РАСШИРЕН)
│   ├── 📈 widgets/            # UI компоненты
│   ├── 🔄 providers/          # Управление состоянием
│   └── 🎨 constants/          # Константы
└── 🌐 web/                    # Web конфиг с автообновлениями
```

### 🆕 Новые методы AdminApiService:
```dart
// Управление данными
deleteUser(int userId)           // Удаление пользователя
deactivateUser(int userId)       // Деактивация пользователя
deleteProduct(int productId)     // Удаление товара  
deleteBatch(int batchId)        // Удаление партии

// Аналитика
getTotalOrder(int batchId)      // Общий заказ партии
getOrdersByUsers(int batchId)   // Заказы по пользователям
```

---

## 🚀 Процессы деплоя

### 📱 Мобильное приложение:
1. Обновить версию в `pubspec.yaml`
2. `flutter build apk --release`
3. Переименовать в `severnaya-korzina-X.Y.Z.apk`
4. Загрузить в `/public/downloads/`
5. Обновить `src/routes/app.js`
6. `pm2 restart all`

### 🌐 Веб-приложение:
1. `flutter build web --release`
2. `.\deploy_with_cleanup.ps1`
3. Загрузить на сервер в `/app/`

### 🗄️ Backend:
1. `git pull`
2. `npm install`
3. `npx prisma migrate deploy`
4. `pm2 restart severnaya-backend`

---

## 📊 Статистика проекта

### Размеры:
- **Backend**: ~20 MB (без node_modules)
- **Mobile APK**: ~35 MB
- **Web App**: ~10 MB
- **Admin Panel**: ~12 MB
- **Database**: ~100 MB

### Количество файлов:
- **Backend**: ~60 файлов
- **Mobile**: ~100 файлов
- **Admin**: ~90 файлов

### Строки кода (примерно):
- **JavaScript (Backend)**: ~7,000
- **Dart (Flutter)**: ~20,000
- **SQL (Prisma)**: ~500

---

## 🔑 Важные файлы

### Конфигурация:
- `.env` - переменные окружения (не в Git!)
- `pubspec.yaml` - версия и зависимости Flutter
- `package.json` - зависимости Node.js
- `prisma/schema.prisma` - схема БД

### Критические для работы:
- `src/server.js` - точка входа backend
- `src/routes/admin.js` - админские endpoints
- `lib/main.dart` - точка входа mobile
- `lib/services/api_service.dart` - API клиент
- `lib/services/admin_api_service.dart` - API админки
- `lib/services/update_service.dart` - обновления
- `lib/screens/admin/batch_details_screen.dart` - детали партий

### Документация:
- `docs/PROJECT_OVERVIEW.md` - обзор
- `docs/CURRENT_STATUS.md` - статус
- `docs/PROJECT_STRUCTURE.md` - структура
- `README.md` - быстрый старт

---

## 🔐 Безопасность и связи данных

### Каскадное удаление (CASCADE):
- `addresses` → `users` - адреса удаляются при удалении пользователя
- `batch_items` → `batches` - элементы партии удаляются при удалении партии
- `order_items` → `orders` - позиции заказа удаляются при удалении заказа

### Ограничение удаления (RESTRICT):
- `orders` → `users` - нельзя удалить пользователя с заказами
- `products` → `categories` - нельзя удалить категорию с товарами
- `order_items` → `products` - нельзя удалить товар если он в заказах

### SET NULL:
- `orders` → `batches` - при удалении партии заказы сохраняются

---

> 📌 **Примечание**: Структура актуальна на 03.01.2025. При добавлении новых функций обновляйте этот документ!