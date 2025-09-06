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

### 📂 Полная структура проекта:
```
severnaya-korzina-backend/
├── 📄 package.json              # Зависимости Node.js
├── 📄 package-lock.json         # Фиксированные версии
├── 📄 .env                      # Переменные окружения (НЕ В GIT!)
├── 📄 .gitignore               # Исключения Git
├── 📄 docker-compose.yml       # Конфигурация Docker
├── 📄 Dockerfile               # Образ для контейнеризации
├── 📄 README.md                # Документация
│
├── 🗄️ prisma/                  # База данных
│   ├── schema.prisma           # Схема БД (8 таблиц)
│   ├── seed.js                 # Начальные данные
│   └── migrations/             # История миграций
│       ├── 20250726100336_init/
│       └── migration_lock.toml
│
├── 📁 src/                     # Исходный код
│   ├── 🌐 server.js            # Главный файл (400+ строк)
│   ├── 📁 routes/              # API маршруты
│   │   ├── auth.js             # Авторизация и админ-endpoints
│   │   ├── users.js            # CRUD пользователей
│   │   ├── products.js         # Управление товарами
│   │   ├── orders.js           # Обработка заказов
│   │   ├── payments.js         # ЮKassa интеграция
│   │   ├── batches.js          # Управление партиями
│   │   ├── addresses.js        # Адреса доставки
│   │   ├── admin.js            # Админские функции (600+ строк)
│   │   ├── sms.js              # SMS Aero интеграция
│   │   ├── settings.js         # Настройки системы
│   │   └── app.js              # API обновлений приложения
│   │
│   ├── 📁 middleware/          # Промежуточное ПО
│   │   ├── auth.js             # JWT аутентификация
│   │   └── safety.js           # Безопасность (Helmet, CORS)
│   │
│   └── 📁 utils/               # Утилиты
│       └── batchCalculations.js # Расчеты партий
│
└── 📁 public/                  # Статические файлы
    ├── index.html              # Лендинг
    └── downloads/              # APK файлы
        └── severnaya-korzina-1.2.0.apk
```

### 🔧 API Endpoints (основные):

#### Авторизация (`/api/auth/`)
```
POST   /login                 # Вход по SMS
POST   /register              # Регистрация
GET    /profile               # Профиль пользователя
POST   /admin-login           # Вход админа
GET    /admin-stats           # Статистика для админа
GET    /admin-orders          # Все заказы (админ)
GET    /admin-products        # Все товары (админ)
GET    /admin-batches         # Все партии (админ)
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
```

#### Заказы (`/api/orders/`)
```
GET    /                      # Заказы пользователя
POST   /                      # Создание заказа
GET    /:id                   # Детали заказа
PUT    /:id                   # Обновление статуса
```

#### Партии (`/api/batches/`)
```
GET    /                      # Активные партии
GET    /:id                   # Детали партии
POST   /                      # Создание (админ)
PUT    /:id                   # Обновление (админ)
DELETE /:id                   # Удаление (админ)
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
```

#### Платежи (`/api/payments/`)
```
POST   /create                # Создание платежа
GET    /status/:paymentId     # Статус платежа
POST   /webhook               # Webhook от ЮKassa
```

---

## 📱 МОБИЛЬНОЕ ПРИЛОЖЕНИЕ (severnaya_korzina)

### 📂 Структура Flutter приложения:
```
severnaya_korzina/
├── 📄 pubspec.yaml             # Версия 1.2.0+12
├── 📄 README.md                # Документация
│
├── 📁 lib/                     # Код приложения
│   ├── 🎯 main.dart           # Точка входа с UpdateService
│   │
│   ├── 📱 screens/            # Экраны приложения
│   │   ├── home/
│   │   │   └── home_screen.dart         # Главный экран с навигацией
│   │   ├── auth/
│   │   │   ├── auth_choice_screen.dart  # Выбор типа входа
│   │   │   └── login_screen.dart        # SMS-авторизация
│   │   ├── catalog/
│   │   │   └── catalog_screen.dart      # Каталог с поиском
│   │   ├── cart/
│   │   │   └── cart_screen.dart         # Корзина
│   │   ├── checkout/
│   │   │   └── checkout_screen.dart     # Оформление заказа
│   │   ├── orders/
│   │   │   └── orders_screen.dart       # История заказов
│   │   ├── profile/
│   │   │   └── profile_screen.dart      # Профиль и настройки
│   │   └── payment/
│   │       ├── payment_screen.dart      # Платежная форма
│   │       ├── payment_service.dart     # Сервис ЮKassa
│   │       ├── payment_success_screen.dart
│   │       └── universal_payment_screen.dart
│   │
│   ├── 🔧 services/           # API сервисы
│   │   ├── api_service.dart            # Основной API клиент
│   │   ├── update_service.dart         # OTA обновления
│   │   └── auth_service.dart           # Авторизация
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
│   │   └── loading_indicator.dart      # Индикатор загрузки
│   │
│   └── 🎨 constants/          # Константы
│       ├── colors.dart                 # Цветовая схема
│       ├── text_styles.dart            # Стили текста
│       └── api_constants.dart          # API endpoints
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
│   └── index.html             # PWA настройки
│
├── 📁 test/                   # Тесты
│   └── test_update.dart       # Тест UpdateService
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
├── 📄 pubspec.yaml             # Версия 1.1.0
├── 📄 README.md                # Документация
│
├── 📁 lib/                     # Код админки
│   ├── 🎯 main.dart           # Точка входа
│   │
│   ├── 📊 screens/            # Экраны админки
│   │   ├── dashboard_screen.dart        # Главный экран со статистикой
│   │   ├── add_product_screen.dart      # Добавление товаров
│   │   ├── admin/
│   │   │   ├── batch_details_screen.dart     # Детали партии
│   │   │   ├── orders_management_screen.dart # Управление заказами
│   │   │   └── users_management_screen.dart  # Управление пользователями
│   │   └── login_screen.dart            # Вход для админа
│   │
│   ├── 🔧 services/           # API сервисы
│   │   └── admin_api_service.dart       # API админки (1000+ строк)
│   │
│   ├── 📈 widgets/            # UI компоненты
│   │   ├── stat_card.dart              # Карточка статистики
│   │   ├── order_details_card.dart     # Детали заказа
│   │   ├── user_orders_card.dart       # Заказы пользователя
│   │   └── batch_progress.dart         # Прогресс партии
│   │
│   ├── 🔄 providers/          # Управление состоянием
│   │   ├── admin_provider.dart         # Состояние админа
│   │   └── dashboard_provider.dart     # Данные dashboard
│   │
│   └── 🎨 constants/          # Константы
│       └── api_endpoints.dart          # Endpoints админки
│
├── 🌐 web/                    # Web конфигурация
│   ├── index.html             # Точка входа
│   └── manifest.json          # PWA манифест
│
└── 🍎 macos/                  # macOS конфигурация
    └── Runner.xcodeproj/      # Xcode проект
```

---

## 🗄️ База данных PostgreSQL

### Схема данных (Prisma):
```prisma
// 8 основных таблиц
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
  addresses       Address[]
  orders          Order[]
}

model Address {
  id        Int      @id @default(autoincrement())
  userId    Int
  title     String
  address   String
  isDefault Boolean  @default(false)
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  orders    Order[]
}

model Category {
  id          Int       @id @default(autoincrement())
  name        String
  description String?
  imageUrl    String?
  isActive    Boolean   @default(true)
  products    Product[]
}

model Product {
  id          Int         @id @default(autoincrement())
  categoryId  Int
  name        String
  description String?
  imageUrl    String?
  price       Decimal     @db.Decimal(10, 2)
  unit        String
  minQuantity Int         @default(1)
  maxQuantity Int?        // Остатки на складе
  isActive    Boolean     @default(true)
  category    Category    @relation(fields: [categoryId], references: [id])
  batchItems  BatchItem[]
  orderItems  OrderItem[]
}

model Batch {
  id                  Int         @id @default(autoincrement())
  title               String
  description         String?
  startDate           DateTime
  endDate             DateTime
  deliveryDate        DateTime?
  minParticipants     Int         @default(5)
  maxParticipants     Int?
  status              String      @default("active")
  pickupAddress       String?
  targetAmount        Decimal     @default(3000000)
  currentAmount       Decimal     @default(0)
  participantsCount   Int         @default(0)
  progressPercent     Int         @default(0)
  lastCalculated      DateTime    @default(now())
  autoLaunch          Boolean     @default(true)
  marginPercent       Decimal     @default(20)
  collectionStartDate DateTime?
  batchItems          BatchItem[]
  orders              Order[]
}

model BatchItem {
  id        Int     @id @default(autoincrement())
  batchId   Int
  productId Int
  price     Decimal @db.Decimal(10, 2)
  discount  Decimal @default(0)
  isActive  Boolean @default(true)
  batch     Batch   @relation(fields: [batchId], references: [id], onDelete: Cascade)
  product   Product @relation(fields: [productId], references: [id])
}

model Order {
  id          Int         @id @default(autoincrement())
  userId      Int
  batchId     Int?
  addressId   Int
  status      String      @default("pending") // pending, paid, shipped, delivered, cancelled
  totalAmount Decimal     @db.Decimal(10, 2)
  notes       String?
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  orderItems  OrderItem[]
  address     Address     @relation(fields: [addressId], references: [id])
  batch       Batch?      @relation(fields: [batchId], references: [id])
  user        User        @relation(fields: [userId], references: [id])
}

model OrderItem {
  id        Int     @id @default(autoincrement())
  orderId   Int
  productId Int
  quantity  Int
  price     Decimal @db.Decimal(10, 2)
  order     Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  product   Product @relation(fields: [productId], references: [id])
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

# 3. Переименование файла
mv build/app/outputs/flutter-apk/app-release.apk severnaya-korzina-1.2.0.apk

# 4. Загрузка на сервер
scp severnaya-korzina-1.2.0.apk ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/downloads/

# 5. Обновление конфигурации версий
nano src/routes/app.js  # Обновить CURRENT_APP_CONFIG

# 6. Перезапуск сервера
pm2 restart severnaya-backend
```

### 🌐 Веб-приложение:
```bash
# 1. Сборка web версии
flutter build web --release

# 2. Деплой через PowerShell скрипт
.\deploy_with_cleanup.ps1

# 3. Загрузка на сервер
scp -r build/web/* ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/app/
```

### 🗄️ Backend:
```bash
# 1. Подключение к серверу
ssh ubuntu@84.201.149.245

# 2. Переход в директорию
cd ~/severnaya-korzina

# 3. Обновление кода
git pull origin main

# 4. Установка зависимостей
npm install

# 5. Миграции БД
npx prisma migrate deploy
npx prisma generate

# 6. Перезапуск
pm2 restart severnaya-backend
pm2 save
```

---

## 📊 Статистика проекта

### Размеры компонентов:
| Компонент | Размер | Файлов | Строк кода |
|-----------|--------|--------|------------|
| Backend | ~20 MB | ~60 | ~7,000 JS |
| Mobile APK | ~35 MB | ~100 | ~20,000 Dart |
| Web App | ~10 MB | - | - |
| Admin Panel | ~12 MB | ~90 | ~15,000 Dart |
| Database | ~100 MB | - | ~500 SQL |

### Производительность:
- **API Response Time**: <100ms
- **Build Time Mobile**: ~3 min
- **Build Time Web**: ~1 min
- **Database Queries**: <50ms

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
YOOKASSA_SECRET_KEY="test_jSLEuLPMPW58_iRfez3W_ToHsrMv2XS_cgqIYpNMa5A"

# Admin
ADMIN_PASSWORD="your-admin-password"
```

---

> 📌 **Примечание**: Структура актуальна на январь 2025. При добавлении новых функций обновляйте этот документ!