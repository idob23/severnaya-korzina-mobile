# 🏗️ Структура проекта "Северная Корзина"

## 📁 Обзор репозиториев

```
🌐 GitHub: https://github.com/idob23/
├── 📱 severnaya_korzina/              # Мобильное и веб-приложение Flutter
├── 🔧 severnaya_korzina_admin/        # Админ панель Flutter Web  
└── 🗄️ severnaya-korzina-backend/     # Backend API Node.js
```

---

## 🗄️ BACKEND API (severnaya-korzina-backend)

### 📂 Полная структура проекта:
```
severnaya-korzina-backend/
├── 📄 package.json              # Версия 1.0.0
├── 📄 package-lock.json         # Фиксированные версии
├── 📄 .env                      # Переменные окружения (НЕ В GIT!)
├── 📄 .gitignore               # Исключения Git
├── 📄 docker-compose.yml       # Конфигурация Docker
├── 📄 Dockerfile               # Образ для контейнеризации
├── 📄 README.md                # Документация
│
├── 🗄️ prisma/                  # База данных
│   ├── schema.prisma           # Схема БД (9 таблиц)
│   ├── seed.js                 # Начальные данные
│   └── migrations/             # История миграций
│       ├── 20250726100336_init/
│       └── migration_lock.toml
│
├── 📁 src/                     # Исходный код
│   ├── 🌐 server.js            # Главный файл (~500 строк)
│   ├── 📁 routes/              # API маршруты
│   │   ├── auth.js             # Авторизация и регистрация
│   │   ├── users.js            # CRUD пользователей
│   │   ├── products.js         # Управление товарами
│   │   ├── orders.js           # Обработка заказов
│   │   ├── payments.js         # ЮKassa + фискализация
│   │   ├── batches.js          # Управление партиями
│   │   ├── addresses.js        # Адреса доставки
│   │   ├── admin.js            # Админские функции (700+ строк)
│   │   ├── sms.js              # SMS Aero интеграция
│   │   ├── settings.js         # Системные настройки
│   │   └── app.js              # API обновлений приложения
│   │
│   ├── 📁 middleware/          # Промежуточное ПО
│   │   ├── auth.js             # JWT аутентификация
│   │   └── safety.js           # Безопасность (Helmet, CORS)
│   │
│   └── 📁 utils/               # Утилиты
│       └── batchCalculations.js # Расчеты партий
│
├── 📁 public/                  # Статические файлы
│   ├── index.html              # Лендинг
│   ├── unsupported-browser.html
│   └── downloads/              # APK файлы
│       └── severnaya-korzina-1.2.0.apk
│
├── 📁 uploads/                 # Загруженные файлы
├── 📁 logs/                    # Логи приложения
└── 📁 web/                     # Flutter Web файлы
    └── index.html
```

### 🔧 API Endpoints:

#### Авторизация (`/api/auth/`)
```
POST   /login                 # Вход по SMS
POST   /register              # Регистрация с согласием
GET    /profile               # Профиль пользователя
POST   /admin-login           # Вход админа
GET    /admin-stats           # Статистика для админа
```

#### Пользователи (`/api/users/`)
```
GET    /                      # Список пользователей
GET    /:id                   # Информация о пользователе
PUT    /:id                   # Обновление профиля
DELETE /:id                   # Удаление (админ)
PUT    /:id/deactivate        # Деактивация (админ)
```

#### Товары (`/api/products/`)
```
GET    /                      # Каталог товаров
GET    /:id                   # Детали товара
POST   /                      # Создание (админ)
PUT    /:id                   # Обновление (админ)
DELETE /:id                   # Удаление (админ)
GET    /categories            # Список категорий
POST   /categories            # Создание категории
```

#### Заказы (`/api/orders/`)
```
GET    /                      # Заказы пользователя
POST   /                      # Создание заказа
GET    /:id                   # Детали заказа
PUT    /:id/status            # Обновление статуса
DELETE /:id                   # Отмена заказа
```

#### Партии (`/api/batches/`)
```
GET    /                      # Активные партии
GET    /:id                   # Детали партии с товарами
POST   /                      # Создание (админ)
PUT    /:id                   # Обновление (админ)
DELETE /:id                   # Удаление (админ)
GET    /:id/progress          # Прогресс партии
```

#### Админ функции (`/api/admin/`)
```
GET    /dashboard/stats              # Статистика dashboard
POST   /batches/:id/launch           # Запуск партии
POST   /batches/:id/ship             # Отправка товаров
POST   /batches/:id/deliver          # Доставка товаров
GET    /batches/:id/total-order      # Общий заказ партии
GET    /batches/:id/orders-by-users  # Заказы по пользователям
POST   /sms/send                     # SMS рассылка
GET    /settings                     # Системные настройки
PUT    /settings                     # Обновление настроек
POST   /maintenance/toggle           # Режим обслуживания
```

#### Платежи (`/api/payments/`)
```
POST   /create                # Создание платежа с фискализацией
GET    /status/:paymentId     # Статус платежа
POST   /webhook               # Webhook от ЮKassa
```

#### Приложение (`/api/app/`)
```
GET    /check-update          # Проверка обновлений
GET    /download/:version     # Скачивание APK
GET    /changelog/:version    # История изменений
GET    /status                # Статус и режим обслуживания
```

---

## 📱 МОБИЛЬНОЕ И ВЕБ-ПРИЛОЖЕНИЕ (severnaya_korzina)

### 📂 Структура Flutter приложения:
```
severnaya_korzina/
├── 📄 pubspec.yaml             # Версия 1.2.0+12
├── 📄 README.md                # Документация
│
├── 📁 lib/                     # Код приложения
│   ├── 🎯 main.dart           # Точка входа с UpdateService
│   │
│   ├── 📱 screens/            # Экраны приложения (15+ экранов)
│   │   ├── home/
│   │   │   └── home_screen.dart         # Главный с навигацией
│   │   ├── auth/
│   │   │   ├── auth_choice_screen.dart  # Выбор типа входа
│   │   │   ├── login_screen.dart        # SMS-авторизация
│   │   │   ├── register_screen.dart     # Регистрация
│   │   │   └── sms_verification_screen.dart
│   │   ├── catalog/
│   │   │   └── catalog_screen.dart      # Каталог с поиском
│   │   ├── cart/
│   │   │   └── cart_screen.dart         # Корзина
│   │   ├── checkout/
│   │   │   └── checkout_screen.dart     # Оформление заказа
│   │   ├── orders/
│   │   │   ├── orders_screen.dart       # История заказов
│   │   │   └── order_details_screen.dart # Детали заказа
│   │   ├── profile/
│   │   │   └── profile_screen.dart      # Профиль и настройки
│   │   └── payment/
│   │       ├── payment_screen.dart      # Платежная форма
│   │       ├── payment_success_screen.dart
│   │       └── universal_payment_screen.dart
│   │
│   ├── 🔧 services/           # API сервисы
│   │   ├── api_service.dart            # Основной API клиент
│   │   ├── update_service.dart         # OTA обновления
│   │   ├── auth_service.dart           # Авторизация
│   │   ├── sms_service.dart            # SMS верификация
│   │   ├── notification_service.dart   # Уведомления
│   │   └── payment_service.dart        # Платежи
│   │
│   ├── 📊 models/             # Модели данных
│   │   ├── user.dart                   # Пользователь
│   │   ├── product.dart                # Товар
│   │   ├── category.dart               # Категория
│   │   ├── order.dart                  # Заказ
│   │   ├── batch.dart                  # Партия
│   │   └── address.dart                # Адрес
│   │
│   ├── 🔄 providers/          # State Management
│   │   ├── auth_provider.dart          # Состояние авторизации
│   │   ├── cart_provider.dart          # Управление корзиной
│   │   ├── products_provider.dart      # Каталог товаров
│   │   └── orders_provider.dart        # Заказы пользователя
│   │
│   ├── 🎨 widgets/            # Переиспользуемые компоненты
│   │   ├── product_card.dart           # Карточка товара
│   │   ├── cart_item.dart              # Элемент корзины
│   │   ├── order_card.dart             # Карточка заказа
│   │   ├── loading_indicator.dart      # Индикатор загрузки
│   │   └── premium_loading.dart        # Премиум загрузка
│   │
│   ├── 🎨 design_system/      # Дизайн-система
│   │   ├── theme/
│   │   │   └── app_theme.dart          # Тема приложения
│   │   ├── colors/
│   │   │   ├── app_colors.dart         # Цветовая схема
│   │   │   └── gradients.dart          # Градиенты
│   │   └── spacing/
│   │       └── app_spacing.dart        # Отступы
│   │
│   └── 🎨 constants/          # Константы
│       ├── colors.dart                 # Цвета (legacy)
│       ├── text_styles.dart            # Стили текста
│       ├── api_constants.dart          # API endpoints
│       └── order_status.dart           # Статусы заказов
│
├── 🤖 android/                # Android конфигурация
│   ├── app/
│   │   ├── build.gradle               # Версия и подпись
│   │   └── src/main/
│   │       └── AndroidManifest.xml    # Разрешения
│   └── gradle.properties               # Настройки сборки
│
├── 🍎 ios/                    # iOS конфигурация
├── 🌐 web/                    # Web конфигурация
│   ├── index.html             # PWA настройки
│   └── manifest.json          # Web манифест
│
└── 📁 build/                  # Скомпилированные файлы
    └── app/outputs/flutter-apk/
        └── app-release.apk    # Готовый APK
```

---

## 🔧 АДМИН ПАНЕЛЬ (severnaya_korzina_admin)

### 📂 Структура админки:
```
severnaya_korzina_admin/
├── 📄 pubspec.yaml             # Версия 1.0.0+1
├── 📄 README.md                # Документация
│
├── 📁 lib/                     # Код админки
│   ├── 🎯 main.dart           # Точка входа
│   │
│   ├── 📊 screens/            # Экраны админки
│   │   ├── dashboard_screen.dart             # Главный со статистикой
│   │   ├── add_product_screen.dart           # Добавление товаров
│   │   ├── login_screen.dart                 # Вход для админа
│   │   └── admin/
│   │       ├── batch_details_screen.dart     # Детали партии
│   │       ├── orders_management_screen.dart # Управление заказами
│   │       ├── users_management_screen.dart  # Управление пользователями
│   │       ├── system_settings_screen.dart   # Системные настройки
│   │       └── maintenance_control_screen.dart # Режим обслуживания
│   │
│   ├── 🔧 services/           # API сервисы
│   │   └── admin_api_service.dart       # API админки (1500+ строк)
│   │
│   ├── 📈 widgets/            # UI компоненты
│   │   ├── stat_card.dart              # Карточка статистики
│   │   ├── order_details_card.dart     # Детали заказа
│   │   ├── user_orders_card.dart       # Заказы пользователя
│   │   └── batch_progress.dart         # Прогресс партии
│   │
│   ├── 🔄 providers/          # Управление состоянием
│   │   ├── auth_provider.dart          # Состояние админа
│   │   └── dashboard_provider.dart     # Данные dashboard
│   │
│   └── 🎨 constants/          # Константы
│       ├── api_endpoints.dart          # Endpoints админки
│       └── order_status.dart           # Статусы заказов
│
├── 🌐 web/                    # Web конфигурация
│   ├── index.html             # Точка входа
│   └── manifest.json          # PWA манифест
│
└── 🍎 macos/                  # macOS конфигурация
```

---

## 🗄️ База данных PostgreSQL

### Схема данных (Prisma):
```prisma
// 9 основных таблиц
model User {
  id              Int       @id @default(autoincrement())
  phone           String    @unique
  firstName       String
  lastName        String?
  email           String?
  isActive        Boolean   @default(true)
  acceptedTerms   Boolean   @default(false)
  acceptedTermsAt DateTime?
  createdAt       DateTime  @default(now())
  updatedAt       DateTime  @updatedAt
}

model SystemSettings {
  id          Int      @id @default(autoincrement())
  key         String   @unique
  value       String
  description String?
  updatedAt   DateTime @updatedAt
}

model Batch {
  marginPercent       Decimal  @default(20)
  collectionStartDate DateTime?
  progressPercent     Int      @default(0)
  // ... другие поля
}
```

---

## 🚀 Процессы деплоя

### 📱 Мобильное приложение:
```bash
# 1. Обновить версию в pubspec.yaml
version: 1.2.0+12

# 2. Сборка APK
flutter build apk --release

# 3. Загрузка на сервер
scp build/app/outputs/flutter-apk/app-release.apk ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/downloads/

# 4. Обновление конфигурации
nano src/routes/app.js  # Обновить CURRENT_APP_CONFIG
pm2 restart severnaya-backend
```

### 🌐 Веб-приложение:
```bash
# 1. Сборка web версии
flutter build web --release

# 2. Деплой
scp -r build/web/* ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/app/
```

### 🗄️ Backend:
```bash
# 1. Подключение к серверу
ssh ubuntu@84.201.149.245

# 2. Обновление кода
cd ~/severnaya-korzina
git pull origin main

# 3. Установка зависимостей
npm install

# 4. Миграции БД
npx prisma migrate deploy
npx prisma generate

# 5. Перезапуск
pm2 restart severnaya-backend
pm2 save
```

---

## 📊 Статистика проекта

### Размеры компонентов:
| Компонент | Размер | Файлов | Строк кода |
|-----------|--------|--------|------------|
| Backend | ~20 MB | ~60 | ~8,000 JS |
| Mobile/Web | ~35 MB | ~120 | ~25,000 Dart |
| Admin Panel | ~12 MB | ~90 | ~15,000 Dart |
| Database | ~100 MB | 9 таблиц | ~600 SQL |

### Производительность:
- **API Response Time**: <100ms
- **Build Time Mobile**: ~3 min
- **Build Time Web**: ~2 min
- **Database Queries**: <50ms
- **Uptime**: 99.9%

---

## 🔐 Безопасность и связи данных

### Каскадное удаление (CASCADE):
- `addresses` → `users` - адреса удаляются при удалении пользователя
- `batch_items` → `batches` - элементы партии при удалении партии  
- `order_items` → `orders` - позиции при удалении заказа

### Ограничение удаления (RESTRICT):
- `orders` → `users` - нельзя удалить пользователя с заказами
- `products` → `categories` - нельзя удалить категорию с товарами
- `order_items` → `products` - нельзя удалить товар в заказах

### SET NULL:
- `orders` → `batches` - при удалении партии заказы сохраняются

---

## 🔑 Переменные окружения (.env)

```env
# Database
DATABASE_URL="postgresql://user:password@localhost:5432/severnaya_korzina"

# JWT
JWT_SECRET="your-secret-key-here"

# Server
PORT=3000
NODE_ENV=production

# SMS Service
SMS_AERO_EMAIL="your-email@example.com"
SMS_AERO_API_KEY="your-api-key"

# YooKassa
YOOKASSA_SHOP_ID="1148812"
YOOKASSA_SECRET_KEY="test_xxxxxxxxxxxxx"

# Admin
ADMIN_PASSWORD="your-admin-password"
```

---

## 📝 Дополнительные файлы

### Лендинг (index.html)
- Информация о проекте
- Инструкции по установке
- Ссылки на приложения
- Контакты

### Документы
- agreement.html - Пользовательское соглашение
- privacy.html - Политика конфиденциальности
- offer.html - Договор-оферта

### Скрипты
- create_files.bat - Создание структуры
- deploy_with_cleanup.ps1 - Деплой скрипт

---

> 📌 **Примечание**: Структура актуальна на сентябрь 2025. При добавлении новых функций обновляйте этот документ!