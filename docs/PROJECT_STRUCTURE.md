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
│   ├── orders.js              # Заказы (ИСПРАВЛЕН)
│   ├── payments.js            # Платежи (ИСПРАВЛЕН)
│   ├── batches.js             # Закупки
│   ├── addresses.js           # Адреса
│   ├── admin.js               # Админские функции
│   └── sms.js                 # SMS сервис
├── 📁 middleware/              # Промежуточное ПО
│   ├── auth.js                # Аутентификация
│   └── safety.js              # Безопасность
└── 📁 utils/                   # Утилиты
    └── batchCalculations.js    # Расчеты закупок
```

### 🗄️ Структура базы данных:
```
PostgreSQL Database:
├── 👥 users                   # Пользователи
├── 🏠 addresses               # Адреса доставки
├── 📦 categories              # Категории товаров
├── 🛍️ products                # Товары
├── 📊 batches                 # Закупки/партии
├── 📋 batch_items             # Товары в закупках
├── 🛒 orders                  # Заказы пользователей
└── 📝 order_items             # Позиции заказов
```

---

## 📱 МОБИЛЬНОЕ ПРИЛОЖЕНИЕ (severnaya_korzina)

### 📂 Структура Flutter:
```
severnaya_korzina/
├── 📄 pubspec.yaml             # Зависимости Flutter
├── 📁 lib/                     # Код приложения
│   ├── 🎯 main.dart           # Точка входа
│   ├── 📱 screens/            # Экраны
│   ├── 🔧 services/           # API сервисы
│   ├── 🎨 widgets/            # UI компоненты
│   ├── 📊 models/             # Модели данных
│   ├── 🔄 providers/          # Управление состоянием
│   └── 🎨 constants/          # Константы и стили
├── 🤖 android/                # Android конфиг
├── 🍎 ios/                    # iOS конфиг
└── 🌐 web/                    # Web конфиг
```

### 📱 lib/ - Основной код:
```
lib/
├── screens/                    # Экраны приложения
│   ├── auth/                  # Авторизация
│   │   ├── login_screen.dart  # Вход
│   │   └── register_screen.dart # Регистрация
│   ├── catalog/               # Каталог
│   │   ├── catalog_screen.dart # Список товаров
│   │   └── product_detail_screen.dart # Детали товара
│   ├── cart/                  # Корзина
│   ├── orders/                # Заказы
│   ├── profile/               # Профиль
│   └── splash/                # Загрузочный экран
├── services/                   # Сервисы
│   ├── api_service.dart       # HTTP клиент
│   ├── auth_service.dart      # Авторизация
│   └── storage_service.dart   # Локальное хранение
├── providers/                  # Провайдеры состояния
│   ├── auth_provider.dart     # Авторизация
│   ├── catalog_provider.dart  # Каталог
│   └── cart_provider.dart     # Корзина
└── constants/                  # Константы
    ├── api_constants.dart     # API endpoints
    ├── colors.dart           # Цвета
    └── order_status.dart     # Статусы заказов
```

---

## 🔧 АДМИН ПАНЕЛЬ (severnaya_korzina_admin)

### 📂 Структура админки:
```
severnaya_korzina_admin/
├── 📄 pubspec.yaml             # Зависимости
├── 📁 lib/                     # Код админки
│   ├── 🎯 main.dart           # Точка входа
│   ├── 📊 screens/            # Экраны админки
│   ├── 🔧 services/           # API сервисы
│   ├── 📈 widgets/            # UI компоненты
│   ├── 🔄 providers/          # Управление состоянием
│   └── 🎨 constants/          # Константы
└── 🌐 web/                    # Web конфиг
```

### 📊 lib/ - Админский код:
```
lib/
├── screens/                    # Экраны админки
│   ├── login_screen.dart      # Вход администратора
│   ├── dashboard_screen.dart  # Главная панель
│   └── admin/                 # Админские экраны
│       ├── orders_management_screen.dart # Управление заказами
│       ├── batches_screen.dart # Управление закупками
│       ├── users_screen.dart  # Управление пользователями
│       └── products_screen.dart # Управление товарами
├── services/                   # Сервисы
│   ├── admin_api_service.dart # API клиент для админки
│   └── auth_service.dart      # Авторизация админа
├── providers/                  # Провайдеры
│   ├── auth_provider.dart     # Авторизация
│   ├── orders_provider.dart   # Заказы
│   └── batches_provider.dart  # Закупки
└── constants/                  # Константы
    ├── api_constants.dart     # API endpoints
    └── order_status.dart      # Статусы заказов
```

---

## 🔑 Ключевые файлы и их назначение

### Backend (критически важные):
- **`src/server.js`** - главный файл сервера, настройка middleware
- **`src/routes/orders.js`** - 🔧 ИСПРАВЛЕН: создание заказов с автоадресами
- **`src/routes/payments.js`** - 🔧 ИСПРАВЛЕН: webhook ЮKassa, защита от NaN
- **`src/routes/admin.js`** - функции "Машина уехала/приехала"
- **`prisma/schema.prisma`** - схема базы данных
- **`.env`** - конфиденциальные настройки (БД, API ключи)

### Мобильное приложение:
- **`lib/main.dart`** - конфигурация приложения и роутинг
- **`lib/services/api_service.dart`** - HTTP клиент для API
- **`lib/constants/api_constants.dart`** - настройки подключения к серверу
- **`lib/constants/order_status.dart`** - единые статусы заказов

### Админ панель:  
- **`lib/main.dart`** - конфигурация админской панели
- **`lib/services/admin_api_service.dart`** - API для административных функций
- **`lib/screens/admin/orders_management_screen.dart`** - управление заказами

---

## 🌐 API Endpoints (финальные)

```http
# Авторизация
POST   /api/auth/login          # Вход по SMS
POST   /api/auth/register       # Регистрация
GET    /api/auth/profile        # Профиль пользователя

# Товары и каталог  
GET    /api/products            # Список товаров
GET    /api/products/:id        # Детали товара

# Заказы (ОБНОВЛЕНЫ)
POST   /api/orders              # Создать заказ ✅ ИСПРАВЛЕНО
GET    /api/orders              # Список заказов пользователя  
GET    /api/orders/:id          # Детали заказа
PUT    /api/orders/:id          # Обновить заказ

# Платежи (ОБНОВЛЕНЫ)
POST   /api/payments/create     # Создать платеж
POST   /api/payments/webhook    # Webhook ЮKassa ✅ ИСПРАВЛЕНО
GET    /api/payments/status/:id # Статус платежа

# Закупки
GET    /api/batches             # Список закупок
GET    /api/batches/active      # Активная закупка
GET    /api/batches/:id         # Детали закупки

# Админские функции
GET    /api/admin/stats         # Статистика для dashboard
GET    /api/admin/orders        # Все заказы (для админа)
PUT    /api/admin/orders/ship   # "Машина уехала" ✅
PUT    /api/admin/orders/deliver # "Машина приехала" ✅
GET    /api/admin/batches       # Управление закупками
```

---

## 🚀 Скрипты для разработки

### Backend:
```bash
npm start              # Запуск продакшн сервера
npm run dev            # Запуск dev сервера с nodemon
npm run db:migrate     # Применить миграции БД
npm run db:seed        # Загрузить тестовые данные
npm run db:studio      # Открыть Prisma Studio
```

### Flutter (Mobile/Admin):
```bash
flutter pub get       # Установить зависимости
flutter run           # Запуск на устройстве
flutter build apk     # Сборка Android APK
flutter build web     # Сборка для Web
flutter clean         # Очистка проекта
```

---

**💡 Примечание:** Все файлы с пометкой "ИСПРАВЛЕНО" содержат критические исправления, сделанные в последнем чате для обеспечения стабильной работы продакшн версии.