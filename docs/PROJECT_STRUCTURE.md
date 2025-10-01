# 🏗️ Структура проекта "Северная Корзина"

> **Статус**: Pre-Production (в разработке)  
> **Дата обновления**: 01.10.2025  
> **Версия документа**: 2.0

---

## 📁 Обзор репозиториев

```
🌐 GitHub Organization: https://github.com/idob23/

├── 📱 severnaya_korzina/              # Mobile & Web приложение
│   └── Flutter (Android, iOS, Web)
│
├── 🔧 severnaya_korzina_admin/        # Admin панель
│   └── Flutter Web
│
└── 🗄️ severnaya-korzina-backend/      # Backend API
    └── Node.js + Express + Prisma
```

---

## 🗄️ BACKEND API

### 📂 Полная структура

```
severnaya-korzina-backend/
├── 📄 package.json              # Версия 1.0.0
├── 📄 package-lock.json         # Зафиксированные версии
├── 📄 .env                      # Переменные окружения (НЕ в Git!)
├── 📄 .gitignore               # Правила исключения
├── 📄 README.md                # Основная документация
│
├── 🗄️ prisma/                  # База данных
│   ├── schema.prisma           # Схема БД (10 таблиц) ✨
│   ├── seed.js                 # Начальные данные
│   └── migrations/             # История миграций
│       ├── 20250726100336_init/        # Начальная миграция
│       ├── migration_add_payments/     # Таблица payments ✨
│       └── migration_lock.toml
│
├── 📁 src/                     # Исходный код
│   ├── 🌐 server.js            # Главный файл сервера (~600 строк)
│   │
│   ├── 📁 routes/              # API маршруты
│   │   ├── auth.js             # Авторизация (SMS, JWT)
│   │   ├── users.js            # Управление пользователями
│   │   ├── products.js         # CRUD товаров
│   │   ├── orders.js           # Управление заказами
│   │   ├── payments.js         # ✨ Точка Банк API
│   │   ├── batches.js          # Управление партиями
│   │   ├── addresses.js        # Адреса доставки
│   │   ├── admin.js            # Админские функции (~700 строк)
│   │   ├── sms.js              # SMS Aero интеграция
│   │   ├── settings.js         # Системные настройки
│   │   └── app.js              # API обновлений приложения
│   │
│   ├── 📁 services/            # Бизнес-логика
│   │   └── tochkaPaymentService.js  # ✨ Сервис оплаты Точка Банк
│   │
│   ├── 📁 middleware/          # Промежуточное ПО
│   │   ├── auth.js             # JWT верификация
│   │   └── safety.js           # Безопасность (Helmet, CORS)
│   │
│   ├── 📁 utils/               # Утилиты
│   │   └── batchCalculations.js    # Расчёты партий
│   │
│   └── 📁 jobs/                # 🔄 Cron задачи (в разработке)
│       ├── check-payments-cron.js      # Проверка платежей
│       ├── cancel-expired-orders-cron.js # Отмена заказов
│       └── scheduler.js                # Планировщик
│
├── 📁 public/                  # Статические файлы
│   ├── index.html              # Лендинг страница
│   ├── agreement.html          # Пользовательское соглашение
│   ├── privacy.html            # Политика конфиденциальности
│   ├── offer.html              # Договор-оферта
│   ├── app/                    # Flutter Web PWA
│   └── downloads/              # APK файлы
│       └── severnaya-korzina-1.2.0.apk
│
├── 📁 test/                    # ✨ Тестовые скрипты
│   ├── test-tochka.js          # Тест API Точка Банк ✅
│   ├── test-migration.js       # Тест миграции payments ✅
│   ├── setup-tochka-webhook.js # Настройка webhook ✅
│   └── generate-test-token.js  # Генерация JWT ✅
│
├── 📁 docs/                    # ✨ Документация проекта
│   ├── PROJECT_OVERVIEW.md     # Обзор проекта
│   ├── CURRENT_STATUS.md       # Текущий статус
│   ├── PROJECT_STRUCTURE.md    # Этот файл
│   ├── INTEGRATION_TOCHKA_COMPLETE.md # Интеграция Точка Банк
│   └── SUPPLIER_PORTAL.md      # План портала поставщиков
│
├── 📁 uploads/                 # Загруженные файлы
├── 📁 logs/                    # Логи приложения
└── 📁 node_modules/            # Зависимости (НЕ в Git)
```

---

## 🔌 API Endpoints

### 🔐 Авторизация (`/api/auth/`)

```
POST   /register              # Регистрация (SMS + соглашение)
POST   /login                 # Вход (SMS код)
GET    /profile               # Профиль пользователя
POST   /admin-login           # Вход для админа
GET    /admin-stats           # Статистика (админ)
```

### 👥 Пользователи (`/api/users/`)

```
GET    /                      # Список всех пользователей (админ)
GET    /:id                   # Информация о пользователе
PUT    /:id                   # Обновление профиля
DELETE /:id                   # Удаление (админ)
PUT    /:id/deactivate        # Деактивация (админ)
```

### 🛍️ Товары (`/api/products/`)

```
GET    /                      # Каталог товаров
GET    /:id                   # Детали товара
POST   /                      # Создание (админ)
PUT    /:id                   # Обновление (админ)
DELETE /:id                   # Удаление (админ)
GET    /categories            # Список категорий
POST   /categories            # Создание категории (админ)
```

### 📦 Заказы (`/api/orders/`)

```
GET    /                      # Заказы пользователя
POST   /                      # Создание заказа
GET    /:id                   # Детали заказа
PUT    /:id/status            # Обновление статуса (админ)
DELETE /:id                   # Отмена заказа
```

### 💳 Платежи (`/api/payments/`) ✨ НОВОЕ

```
POST   /create                # Создание платежа Точка Банк
GET    /status/:paymentId     # Проверка статуса платежа
POST   /webhook               # Webhook от Точка Банк
POST   /refund/:paymentId     # 🔄 Возврат средств (в разработке)
GET    /history               # 🔄 История платежей (в разработке)
```

### 🎒 Партии (`/api/batches/`)

```
GET    /                      # Список активных партий
GET    /:id                   # Детали партии
POST   /                      # Создание (админ)
PUT    /:id                   # Обновление (админ)
DELETE /:id                   # Удаление (админ)
GET    /:id/progress          # Прогресс партии
```

### 🏠 Адреса (`/api/addresses/`)

```
GET    /                      # Адреса пользователя
POST   /                      # Добавление адреса
PUT    /:id                   # Обновление адреса
DELETE /:id                   # Удаление адреса
```

### 👑 Админ функции (`/api/admin/`)

```
GET    /dashboard/stats              # Статистика dashboard
POST   /batches/:id/launch           # Запуск партии
POST   /batches/:id/ship             # Отправка товаров
POST   /batches/:id/deliver          # Доставка
GET    /batches/:id/total-order      # Общий заказ партии
GET    /batches/:id/orders-by-users  # Заказы по пользователям
POST   /sms/send                     # SMS рассылка
GET    /settings                     # Системные настройки
PUT    /settings                     # Обновление настроек
POST   /maintenance/toggle           # Режим обслуживания
```

### 📱 Приложение (`/api/app/`)

```
GET    /version                      # Проверка версии приложения
GET    /config                       # Конфигурация приложения
```

---

## 📱 МОБИЛЬНОЕ/ВЕБ ПРИЛОЖЕНИЕ

### 📂 Структура Flutter проекта

```
severnaya_korzina/
├── 📄 pubspec.yaml             # Версия 1.2.0+12
├── 📄 README.md                # Документация
│
├── 📁 lib/                     # Исходный код
│   ├── 🎯 main.dart           # Точка входа
│   │
│   ├── 📊 screens/            # Экраны приложения
│   │   ├── home_screen.dart            # Главная страница
│   │   ├── catalog_screen.dart         # Каталог товаров
│   │   ├── cart_screen.dart            # Корзина
│   │   ├── checkout_screen.dart        # Оформление заказа
│   │   ├── payment_webview_screen.dart # ✨ WebView для оплаты
│   │   ├── orders/
│   │   │   ├── order_history_screen.dart    # История заказов
│   │   │   └── order_details_screen.dart    # Детали заказа
│   │   ├── profile_screen.dart         # Профиль
│   │   ├── login_screen.dart           # Авторизация
│   │   └── terms_screen.dart           # Соглашение
│   │
│   ├── 🔧 services/           # API сервисы
│   │   ├── api_service.dart            # REST API клиент
│   │   ├── payment_service.dart        # ✨ Сервис оплаты
│   │   └── update_service.dart         # Сервис обновлений
│   │
│   ├── 📦 models/             # Модели данных
│   │   ├── user.dart                   # Пользователь
│   │   ├── product.dart                # Товар
│   │   ├── category.dart               # Категория
│   │   ├── order.dart                  # Заказ
│   │   ├── payment.dart                # ✨ Платёж
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
│       ├── colors.dart                 # Цвета
│       ├── text_styles.dart            # Стили текста
│       ├── api_constants.dart          # API endpoints
│       └── order_status.dart           # Статусы заказов
│
├── 🤖 android/                # Android конфигурация
│   ├── app/
│   │   ├── build.gradle               # Версия и подпись
│   │   └── src/main/
│   │       └── AndroidManifest.xml    # Разрешения и настройки
│   └── gradle.properties               # Настройки сборки
│
├── 🍎 ios/                    # iOS конфигурация
│   └── Runner/
│       ├── Info.plist                  # Настройки iOS
│       └── AppDelegate.swift           # Делегат приложения
│
├── 🌐 web/                    # Web конфигурация
│   ├── index.html             # PWA точка входа
│   ├── manifest.json          # Web манифест
│   └── icons/                 # Иконки PWA
│
└── 📁 build/                  # Скомпилированные файлы
    ├── app/outputs/flutter-apk/
    │   └── app-release.apk    # ✅ Android APK (35 MB)
    └── web/                   # ✅ Web PWA файлы
```

---

## 🔧 АДМИН ПАНЕЛЬ

### 📂 Структура админки

```
severnaya_korzina_admin/
├── 📄 pubspec.yaml             # Версия 1.0.0+1
├── 📄 README.md                # Документация
│
├── 📁 lib/                     # Код админки
│   ├── 🎯 main.dart           # Точка входа
│   │
│   ├── 📊 screens/            # Экраны админки
│   │   ├── dashboard_screen.dart             # Главный dashboard
│   │   ├── add_product_screen.dart           # Добавление товаров
│   │   ├── login_screen.dart                 # Вход админа
│   │   └── admin/
│   │       ├── batch_details_screen.dart     # Детали партии
│   │       ├── orders_management_screen.dart # Управление заказами
│   │       ├── users_management_screen.dart  # Управление пользователями
│   │       ├── system_settings_screen.dart   # Системные настройки
│   │       ├── maintenance_control_screen.dart # Режим обслуживания
│   │       └── payments_management_screen.dart # 🔄 Платежи (в разработке)
│   │
│   ├── 🔧 services/           # API сервисы
│   │   └── admin_api_service.dart       # API админки (~1500 строк)
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
└── 🍎 macos/                  # macOS конфигурация (опционально)
```

---

## 🗄️ База данных PostgreSQL

### Схема Prisma (10 таблиц)

```prisma
// === ПОЛЬЗОВАТЕЛИ ===

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
  
  orders          Order[]
  addresses       Address[]
}

model Address {
  id        Int      @id @default(autoincrement())
  userId    Int
  city      String
  street    String
  building  String
  apartment String?
  entrance  String?
  floor     String?
  isDefault Boolean  @default(false)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  orders    Order[]
  
  @@index([userId])
}

// === ТОВАРЫ ===

model Category {
  id          Int       @id @default(autoincrement())
  name        String    @unique
  description String?
  isActive    Boolean   @default(true)
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  products    Product[]
}

model Product {
  id          Int        @id @default(autoincrement())
  categoryId  Int
  name        String
  description String?
  price       Decimal    @db.Decimal(10,2)
  unit        String     @default("шт")
  imageUrl    String?
  isActive    Boolean    @default(true)
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt
  
  category    Category   @relation(fields: [categoryId], references: [id], onDelete: Restrict)
  orderItems  OrderItem[]
  batchItems  BatchItem[]
  
  @@index([categoryId])
}

// === ПАРТИИ ===

model Batch {
  id                  Int        @id @default(autoincrement())
  title               String
  description         String?
  status              String     @default("active")
  targetAmount        Decimal    @db.Decimal(12,2)
  currentAmount       Decimal    @db.Decimal(12,2) @default(0)
  participantsCount   Int        @default(0)
  progressPercent     Int        @default(0)
  marginPercent       Decimal    @db.Decimal(5,2) @default(20)
  autoLaunch          Boolean    @default(false)
  collectionStartDate DateTime?
  launchDate          DateTime?
  shippedDate         DateTime?
  deliveredDate       DateTime?
  lastCalculated      DateTime?
  createdAt           DateTime   @default(now())
  updatedAt           DateTime   @updatedAt
  
  orders              Order[]
  items               BatchItem[]
}

model BatchItem {
  id         Int      @id @default(autoincrement())
  batchId    Int
  productId  Int
  quantity   Int
  price      Decimal  @db.Decimal(10,2)
  createdAt  DateTime @default(now())
  
  batch      Batch    @relation(fields: [batchId], references: [id], onDelete: Cascade)
  product    Product  @relation(fields: [productId], references: [id], onDelete: Restrict)
  
  @@index([batchId])
  @@index([productId])
}

// === ЗАКАЗЫ ===

model Order {
  id          Int         @id @default(autoincrement())
  userId      Int
  batchId     Int?
  addressId   Int
  status      String      @default("pending")
  totalAmount Decimal     @db.Decimal(10,2)
  notes       String?
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  
  user        User        @relation(fields: [userId], references: [id], onDelete: Restrict)
  batch       Batch?      @relation(fields: [batchId], references: [id], onDelete: SetNull)
  address     Address     @relation(fields: [addressId], references: [id], onDelete: Restrict)
  items       OrderItem[]
  payments    Payment[]   // ✨ НОВОЕ
  
  @@index([userId])
  @@index([batchId])
  @@index([status])
  @@index([createdAt])
}

model OrderItem {
  id        Int      @id @default(autoincrement())
  orderId   Int
  productId Int
  quantity  Int
  price     Decimal  @db.Decimal(10,2)
  createdAt DateTime @default(now())
  
  order     Order    @relation(fields: [orderId], references: [id], onDelete: Cascade)
  product   Product  @relation(fields: [productId], references: [id], onDelete: Restrict)
  
  @@index([orderId])
  @@index([status])
  @@index([createdAt])
}

// === СИСТЕМНЫЕ НАСТРОЙКИ ===

model SystemSettings {
  id          Int      @id @default(autoincrement())
  key         String   @unique
  value       String
  description String?
  updatedAt   DateTime @updatedAt
  
  @@index([key])
}
```

---

## 🔄 Связи и каскадное удаление

### Каскадное удаление (CASCADE)
```
addresses    → users     # Адреса удаляются при удалении пользователя
batch_items  → batches   # Элементы партии при удалении партии
order_items  → orders    # Позиции при удалении заказа
payments     → orders    # ✨ Платежи при удалении заказа
```

### Ограничение удаления (RESTRICT)
```
orders       → users     # Нельзя удалить пользователя с заказами
products     → categories # Нельзя удалить категорию с товарами
order_items  → products  # Нельзя удалить товар в заказах
```

### Установка NULL (SET NULL)
```
orders       → batches   # При удалении партии заказы сохраняются
```

---

## 🚀 Процессы деплоя

### 📱 Мобильное приложение

```bash
# 1. Обновить версию в pubspec.yaml
# version: 1.2.0+12

# 2. Сборка Android APK
cd severnaya_korzina
flutter clean
flutter pub get
flutter build apk --release

# 3. Загрузка на сервер
scp build/app/outputs/flutter-apk/app-release.apk \
  ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/downloads/severnaya-korzina-1.2.0.apk

# 4. Обновление конфигурации на сервере
ssh ubuntu@84.201.149.245
nano ~/severnaya-korzina/src/routes/app.js
# Обновить CURRENT_APP_CONFIG
pm2 restart severnaya-backend
```

### 🌐 Веб-приложение (PWA)

```bash
# 1. Сборка Flutter Web
cd severnaya_korzina
flutter clean
flutter pub get
flutter build web --release

# 2. Деплой на сервер
scp -r build/web/* \
  ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/app/

# 3. Очистка кэша (если нужно)
ssh ubuntu@84.201.149.245
sudo systemctl reload nginx
```

### 🗄️ Backend API

```bash
# 1. Подключение к серверу
ssh ubuntu@84.201.149.245

# 2. Переход в директорию
cd ~/severnaya-korzina

# 3. Обновление кода из Git
git pull origin main

# 4. Установка новых зависимостей
npm install

# 5. ✨ ВАЖНО: Применение миграций БД
npx prisma migrate deploy
npx prisma generate

# 6. Перезапуск приложения
pm2 restart severnaya-backend
pm2 save

# 7. Проверка статуса
pm2 status
pm2 logs severnaya-backend --lines 50
```

### 💾 Резервное копирование БД

```bash
# Создание бэкапа
pg_dump "postgresql://superadmin:PASSWORD@HOST:6432/severnaya_korzina?sslmode=require" \
  > backup_$(date +%Y%m%d_%H%M%S).sql

# Восстановление из бэкапа
psql "postgresql://superadmin:PASSWORD@HOST:6432/severnaya_korzina?sslmode=require" \
  < backup_20251001_120000.sql

# Автоматический бэкап (cron)
# Добавить в crontab -e:
0 2 * * * pg_dump "postgresql://..." > ~/backups/severnaya_$(date +\%Y\%m\%d).sql
```

---

## 📊 Статистика проекта

### Размеры компонентов

| Компонент | Размер | Файлов | Строк кода | Статус |
|-----------|--------|--------|------------|--------|
| Backend | ~25 MB | ~70 | ~10,000 JS | 🟢 95% |
| Mobile/Web | ~40 MB | ~130 | ~28,000 Dart | 🟢 90% |
| Admin Panel | ~15 MB | ~100 | ~18,000 Dart | 🟡 85% |
| Database | ~110 MB | 10 таблиц | ~800 SQL | 🟢 100% |
| Документация | ~2 MB | ~15 файлов | ~5,000 MD | 🟡 75% |

### Производительность

```
API Response Time:    <100ms    ✅
Database Query Time:  <50ms     ✅
Build Time Mobile:    ~3 min    ✅
Build Time Web:       ~2 min    ✅
Build Time Admin:     ~2.5 min  ✅
```

---

## 🔑 Переменные окружения

### Backend (.env)

```env
# === DATABASE ===
DATABASE_URL="postgresql://superadmin:PASSWORD@HOST:6432/severnaya_korzina?sslmode=require"

# === JWT ===
JWT_SECRET="your-secret-key-here"
JWT_EXPIRES_IN="24h"

# === SERVER ===
PORT=3000
NODE_ENV=production

# === SMS SERVICE ===
SMS_AERO_EMAIL="your-email@example.com"
SMS_AERO_API_KEY="your-api-key"

# === ТОЧКА БАНК ✨ ===
TOCHKA_API_URL="https://enter.tochka.com/uapi"
TOCHKA_CUSTOMER_CODE="305236529"
TOCHKA_MERCHANT_ID="200000000026552"
TOCHKA_TERMINAL_ID="20025552"
TOCHKA_JWT_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# === ADMIN ===
ADMIN_PASSWORD="your-secure-admin-password"

# === CRON НАСТРОЙКИ 🔄 (в разработке) ===
ENABLE_CRON="true"
PAYMENT_CHECK_INTERVAL="2"           # минуты
ORDER_TIMEOUT_MINUTES="30"           # минуты
```

---

## 📝 Дополнительные файлы

### Конфигурационные файлы

```
.env                        # Переменные окружения (НЕ в Git!)
.gitignore                  # Правила исключения
package.json                # Зависимости Node.js
package-lock.json           # Фиксированные версии
prisma/schema.prisma        # Схема базы данных
```

### Документы для пользователей

```
public/agreement.html       # Пользовательское соглашение ✅
public/privacy.html         # Политика конфиденциальности ✅
public/offer.html           # Договор-оферта ✅
```

### Тестовые скрипты ✨

```
test/test-tochka.js                 # Тест Точка Банк API ✅
test/test-migration.js              # Тест миграции payments ✅
test/setup-tochka-webhook.js        # Настройка webhook ✅
test/generate-test-token.js         # Генерация JWT ✅
```

### Техническая документация

```
docs/PROJECT_OVERVIEW.md            # Обзор проекта ✅
docs/CURRENT_STATUS.md              # Текущий статус ✅
docs/PROJECT_STRUCTURE.md           # Структура (этот файл) ✅
docs/INTEGRATION_TOCHKA_COMPLETE.md # Интеграция Точка Банк ✅
docs/SUPPLIER_PORTAL.md             # План портала поставщиков ✅
```

---

## 🔄 История миграций БД

### Применённые миграции

```
1. 20250726100336_init
   ├─ Создано: 26.07.2025
   ├─ Таблиц: 9
   ├─ Описание: Начальная схема БД
   └─ Статус: ✅ Применена

2. migration_add_payments
   ├─ Создано: 30.09.2025
   ├─ Таблиц: +1 (payments)
   ├─ Описание: Интеграция Точка Банк
   └─ Статус: ✅ Применена
```

### Команды миграций

```bash
# Создать новую миграцию
npx prisma migrate dev --name описание_изменения

# Применить миграции на продакшене
npx prisma migrate deploy

# Обновить Prisma Client
npx prisma generate

# Просмотр статуса миграций
npx prisma migrate status

# Откат последней миграции (осторожно!)
npx prisma migrate resolve --rolled-back migration_name
```

---

## 🧪 Тестирование системы

### Backend тесты

```bash
# Health check
curl http://84.201.149.245:3000/health

# API info
curl http://84.201.149.245:3000/api

# Тест интеграции Точка Банк
cd ~/severnaya-korzina
node test/test-tochka.js

# Тест миграции payments
node test/test-migration.js

# Настройка вебхука
node test/setup-tochka-webhook.js

# Генерация JWT для тестов
node test/generate-test-token.js
```

### SQL запросы для проверки

```sql
-- Просмотр последних платежей
SELECT "paymentId", "orderId", status, amount, "createdAt"
FROM payments 
ORDER BY "createdAt" DESC 
LIMIT 10;

-- Проверка зависших платежей
SELECT "paymentId", status, "createdAt"
FROM payments 
WHERE status IN ('CREATED', 'PENDING')
AND "createdAt" < NOW() - INTERVAL '2 minutes';

-- Просроченные заказы
SELECT id, status, "totalAmount", "createdAt"
FROM orders 
WHERE status = 'pending'
AND "createdAt" < NOW() - INTERVAL '30 minutes';

-- Статистика по партиям
SELECT 
  id, 
  title, 
  status, 
  "progressPercent",
  "participantsCount",
  "currentAmount",
  "targetAmount"
FROM batches 
WHERE status IN ('active', 'collecting', 'ready')
ORDER BY "createdAt" DESC;
```

### Проверка логов

```bash
# Логи backend через PM2
pm2 logs severnaya-backend

# Последние 100 строк
pm2 logs severnaya-backend --lines 100

# Логи через systemd (если используется)
sudo journalctl -u severnaya-korzina -f

# Логи Nginx
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## 📌 Важные URL

### Production

```
Backend API:     http://84.201.149.245:3000/api
Web App:         http://app.sevkorzina.ru
Health Check:    http://84.201.149.245:3000/health
Webhook:         https://app.sevkorzina.ru/api/payments/webhook
Admin Panel:     http://84.201.149.245:3000/admin
```

### GitHub

```
Backend:         https://github.com/idob23/severnaya-korzina-backend
Mobile:          https://github.com/idob23/severnaya_korzina
Admin:           https://github.com/idob23/severnaya_korzina_admin
```

### Внешние сервисы

```
Точка Банк API:  https://enter.tochka.com/uapi
Точка Банк Docs: https://enter.tochka.com/doc/
SMS Aero:        https://smsaero.ru/
Yandex Cloud:    https://console.cloud.yandex.ru/
```

---

## 🛠️ Инструменты разработки

### Backend

```
Node.js          v18.x
npm              v9.x
Prisma CLI       v5.x
PM2              v5.x
```

### Frontend

```
Flutter SDK      v3.8.1
Dart             v3.8.1
Android Studio   2024.x
Xcode            15.x (для macOS)
```

### Database

```
PostgreSQL       v15
pgAdmin          v4 (опционально)
```

### DevOps

```
Git              v2.x
SSH              OpenSSH
Nginx            v1.18+
Ubuntu           22.04 LTS
```

---

## 🔄 Планируемые изменения

### В разработке 🟡

```
src/jobs/
├── check-payments-cron.js       # Проверка зависших платежей (каждые 2 мин)
├── cancel-expired-orders-cron.js # Отмена старых заказов (каждые 5 мин)
└── scheduler.js                  # Управление всеми cron задачами
```

### Новые endpoints (планируется) 🔄

```
POST   /api/payments/refund/:paymentId  # Возврат средств
GET    /api/payments/history            # История платежей пользователя
GET    /api/analytics/dashboard         # Расширенная аналитика
POST   /api/notifications/push          # Push уведомления
```

### Админ-панель (в разработке) 🔄

```
lib/screens/admin/
└── payments_management_screen.dart     # Управление платежами
```

---

## 📞 Поддержка и контакты

### Техническая поддержка

```
Email:           sevkorzina@gmail.com
Телефон:         +7 (914) 266-75-82
GitHub:          https://github.com/idob23/
```

### Документация

```
Проект:          /docs/PROJECT_OVERVIEW.md
Статус:          /docs/CURRENT_STATUS.md
Структура:       /docs/PROJECT_STRUCTURE.md (этот файл)
Интеграции:      /docs/INTEGRATION_TOCHKA_COMPLETE.md
```

---

## 📊 Статус готовности компонентов

```
Backend API              ████████████████████░ 95%  ✅ Почти готов
Mobile App (Android)     ██████████████████░░░ 90%  ✅ Готов к тестам
Web App (PWA)            ██████████████████░░░ 90%  ✅ Готов к тестам
Admin Panel              █████████████████░░░░ 85%  🟡 Финальная доработка
Database                 █████████████████████ 100% ✅ Готова
Infrastructure           █████████████████████ 100% ✅ Готова
Security                 ███████████████████░░ 95%  ✅ Готово
Documentation            ███████████████░░░░░░ 75%  🟡 В процессе
Testing                  ██████████████░░░░░░░ 70%  🟡 Активное тестирование

ОБЩАЯ ГОТОВНОСТЬ:       █████████████████░░░░ 85%  🟡 Pre-Production
```

---

> 📌 **Документ обновлён**: 01.10.2025  
> 📌 **Версия документа**: 2.0  
> 📌 **Статус проекта**: В РАЗРАБОТКЕ (Pre-Production)  
> 📌 **Прогноз запуска**: 15-20 октября 2025

---

## 🎯 Следующие шаги

1. ✅ Завершить интеграцию Точка Банк (DONE)
2. 🔄 Реализовать Cron задачи (в процессе)
3. 🔄 Провести полное E2E тестирование
4. 🔄 Финализировать документацию
5. 🔄 Запустить бета-тестирование
6. 🚀 Публичный запускd])
  @@index([productId])
}

// === ПЛАТЕЖИ ✨ НОВАЯ ТАБЛИЦА (30.09.2025) ===

model Payment {
  id        Int       @id @default(autoincrement())
  paymentId String    @unique           // ID от Точка Банк
  orderId   Int                         // Связь с заказом
  provider  String    @default("tochka") // Провайдер оплаты
  status    String                      // CREATED/PENDING/APPROVED/FAILED/REFUNDED
  amount    Decimal   @db.Decimal(10,2) // Сумма платежа
  metadata  String?                     // JSON с доп. данными
  createdAt DateTime  @default(now())   // Дата создания
  paidAt    DateTime?                   // Дата оплаты
  
  order     Order     @relation(fields: [orderId], references: [id], onDelete: Cascade)
  
  @@index([orderI