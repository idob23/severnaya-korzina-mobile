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
│   ├── schema.prisma           # Схема БД (10 таблиц) ✨ ОБНОВЛЕНО
│   ├── seed.js                 # Начальные данные
│   └── migrations/             # История миграций
│       ├── 20250726100336_init/
│       ├── migration_add_payments/ ✨ НОВОЕ (30.09.2025)
│       └── migration_lock.toml
│
├── 📁 src/                     # Исходный код
│   ├── 🌐 server.js            # Главный файл (~500 строк)
│   │
│   ├── 📁 routes/              # API маршруты
│   │   ├── auth.js             # Авторизация и регистрация
│   │   ├── users.js            # CRUD пользователей
│   │   ├── products.js         # Управление товарами
│   │   ├── orders.js           # Обработка заказов
│   │   ├── payments.js         # ✨ ОБНОВЛЕНО - Точка Банк + вебхуки
│   │   ├── batches.js          # Управление партиями
│   │   ├── addresses.js        # Адреса доставки
│   │   ├── admin.js            # Админские функции (700+ строк)
│   │   ├── sms.js              # SMS Aero интеграция
│   │   ├── settings.js         # Системные настройки
│   │   └── app.js              # API обновлений приложения
│   │
│   ├── 📁 services/            # Сервисы
│   │   └── tochkaPaymentService.js  # ✨ НОВОЕ - API Точка Банк
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
├── 📁 test/                    # ✨ НОВОЕ - Тестовые скрипты
│   ├── test-tochka.js          # Тест API Точка Банк
│   ├── test-migration.js       # Тест миграции payments
│   ├── setup-tochka-webhook.js # Настройка вебхука
│   └── generate-test-token.js  # Генерация JWT для тестов
│
├── 📁 docs/                    # ✨ НОВОЕ - Документация
│   ├── INTEGRATION_TOCHKA_COMPLETE.md  # Статус интеграции
│   ├── PROJECT_OVERVIEW.md     # Обзор проекта
│   ├── CURRENT_STATUS.md       # Текущий статус
│   ├── PROJECT_STRUCTURE.md    # Этот файл
│   └── SUPPLIER_PORTAL.md      # План портала поставщиков
│
├── 📁 uploads/                 # Загруженные файлы
├── 📁 logs/                    # Логи приложения
└── 📁 web/                     # Flutter Web файлы
    └── index.html
```

---

## 🔧 API Endpoints

### Авторизация (`/api/auth/`)
```
POST   /login                 # Вход по SMS
POST   /register              # Регистрация с согласием
GET    /profile               # Профиль пользователя
POST   /admin-login           # Вход админа
GET    /admin-stats           # Статистика для админа
```

### Пользователи (`/api/users/`)
```
GET    /                      # Список пользователей
GET    /:id                   # Информация о пользователе
PUT    /:id                   # Обновление профиля
DELETE /:id                   # Удаление (админ)
PUT    /:id/deactivate        # Деактивация (админ)
```

### Товары (`/api/products/`)
```
GET    /                      # Каталог товаров
GET    /:id                   # Детали товара
POST   /                      # Создание (админ)
PUT    /:id                   # Обновление (админ)
DELETE /:id                   # Удаление (админ)
GET    /categories            # Список категорий
POST   /categories            # Создание категории
```

### Заказы (`/api/orders/`)
```
GET    /                      # Заказы пользователя
POST   /                      # Создание заказа
GET    /:id                   # Детали заказа
PUT    /:id/status            # Обновление статуса
DELETE /:id                   # Отмена заказа
```

### Платежи (`/api/payments/`) ✨ ОБНОВЛЕНО
```
POST   /create                # Создание платежа Точка Банк
GET    /status/:paymentId     # Проверка статуса платежа
POST   /webhook               # Webhook от Точка Банк
POST   /refund/:paymentId     # 🔄 Возврат средств (в разработке)
GET    /history               # 🔄 История платежей (в разработке)
```

### Партии (`/api/batches/`)
```
GET    /                      # Активные партии
GET    /:id                   # Детали партии с товарами
POST   /                      # Создание (админ)
PUT    /:id                   # Обновление (админ)
DELETE /:id                   # Удаление (админ)
GET    /:id/progress          # Прогресс партии
```

### Админ функции (`/api/admin/`)
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

---

## 📦 МОБИЛЬНОЕ/ВЕБ ПРИЛОЖЕНИЕ (severnaya_korzina)

### 📂 Структура Flutter приложения:
```
severnaya_korzina/
├── 📄 pubspec.yaml             # Версия 1.2.0+12
├── 📄 README.md                # Документация
│
├── 📁 lib/                     # Исходный код
│   ├── 🎯 main.dart           # Точка входа
│   │
│   ├── 📊 screens/            # Экраны приложения
│   │   ├── home_screen.dart            # Главная
│   │   ├── catalog_screen.dart         # Каталог
│   │   ├── cart_screen.dart            # Корзина
│   │   ├── checkout_screen.dart        # Оформление заказа
│   │   ├── order_history_screen.dart   # История заказов
│   │   ├── profile_screen.dart         # Профиль
│   │   ├── login_screen.dart           # Авторизация
│   │   └── terms_screen.dart           # Соглашение
│   │
│   ├── 🔧 services/           # API сервисы
│   │   └── api_service.dart            # REST API клиент
│   │
│   ├── 📦 models/             # Модели данных
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
│   │       ├── maintenance_control_screen.dart # Режим обслуживания
│   │       └── payments_management_screen.dart # 🔄 Управление платежами (планируется)
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
// 10 основных таблиц ✨ ОБНОВЛЕНО

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

model Order {
  id          Int         @id @default(autoincrement())
  userId      Int
  batchId     Int?
  addressId   Int
  status      String      @default("pending")
  totalAmount Decimal
  notes       String?
  createdAt   DateTime    @default(now())
  updatedAt   DateTime    @updatedAt
  user        User        @relation(fields: [userId], references: [id])
  batch       Batch?      @relation(fields: [batchId], references: [id])
  address     Address     @relation(fields: [addressId], references: [id])
  items       OrderItem[]
  payments    Payment[]   // ✨ НОВОЕ
}

model Payment {  // ✨ НОВАЯ ТАБЛИЦА (30.09.2025)
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
  
  @@index([orderId])
  @@index([status])
  @@index([createdAt])
}

model Batch {
  marginPercent       Decimal  @default(20)
  collectionStartDate DateTime?
  progressPercent     Int      @default(0)
  // ... другие поля
}

model SystemSettings {
  id          Int      @id @default(autoincrement())
  key         String   @unique
  value       String
  description String?
  updatedAt   DateTime @updatedAt
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
scp build/app/outputs/flutter-apk/app-release.apk \
  ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/downloads/

# 4. Обновление конфигурации
nano src/routes/app.js  # Обновить CURRENT_APP_CONFIG
pm2 restart severnaya-backend
```

### 🌐 Веб-приложение:
```bash
# 1. Сборка web версии
flutter build web --release

# 2. Деплой
scp -r build/web/* \
  ubuntu@84.201.149.245:/home/ubuntu/severnaya-korzina/public/app/
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

# 4. Миграции БД ✨ ВАЖНО после обновления
npx prisma migrate deploy
npx prisma generate

# 5. Перезапуск
pm2 restart severnaya-backend
pm2 save
```

### 💾 Резервное копирование БД:
```bash
# Создание бэкапа
pg_dump "postgresql://superadmin:PASSWORD@HOST:6432/severnaya_korzina?sslmode=require" \
  > backup_$(date +%Y%m%d_%H%M%S).sql

# Восстановление
psql "postgresql://superadmin:PASSWORD@HOST:6432/severnaya_korzina?sslmode=require" \
  < backup_20250930_120304.sql
```

---

## 📊 Статистика проекта

### Размеры компонентов:
| Компонент | Размер | Файлов | Строк кода |
|-----------|--------|--------|------------|
| Backend | ~22 MB | ~65 | ~9,000 JS |
| Mobile/Web | ~35 MB | ~120 | ~25,000 Dart |
| Admin Panel | ~12 MB | ~95 | ~16,000 Dart |
| Database | ~110 MB | 10 таблиц | ~700 SQL |

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
- `payments` → `orders` - платежи при удалении заказа ✨ НОВОЕ

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
DATABASE_URL="postgresql://superadmin:PASSWORD@HOST:6432/severnaya_korzina?sslmode=require"

# JWT
JWT_SECRET="your-secret-key-here"

# Server
PORT=3000
NODE_ENV=production

# SMS Service
SMS_AERO_EMAIL="your-email@example.com"
SMS_AERO_API_KEY="your-api-key"

# Точка Банк ✨ НОВОЕ
TOCHKA_API_URL="https://enter.tochka.com/uapi"
TOCHKA_CUSTOMER_CODE="305236529"
TOCHKA_MERCHANT_ID="200000000026552"
TOCHKA_TERMINAL_ID="20025552"
TOCHKA_JWT_TOKEN="eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."

# Admin
ADMIN_PASSWORD="your-admin-password"

# Cron настройки (планируется) 🔄
ENABLE_CRON="true"
PAYMENT_CHECK_INTERVAL="2"
ORDER_TIMEOUT_MINUTES="30"
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

### Скрипты ✨ ОБНОВЛЕНО
- create_files.bat - Создание структуры
- deploy_with_cleanup.ps1 - Деплой скрипт
- test-tochka.js - Тест интеграции Точка Банк
- test-migration.js - Тест миграции payments
- setup-tochka-webhook.js - Настройка вебхука
- generate-test-token.js - Генерация JWT для тестов

### Документация (docs/)
- INTEGRATION_TOCHKA_COMPLETE.md - Полный статус интеграции Точка Банк
- PROJECT_OVERVIEW.md - Обзор проекта
- CURRENT_STATUS.md - Текущий статус
- PROJECT_STRUCTURE.md - Структура проекта (этот файл)
- SUPPLIER_PORTAL.md - План портала поставщиков

---

## 🔄 Планируемые изменения

### Cron задачи (в разработке)
```
src/jobs/
├── check-payments-cron.js       # Проверка зависших платежей (каждые 2 мин)
├── cancel-expired-orders-cron.js # Отмена старых заказов (каждые 5 мин)
└── scheduler.js                  # Управление всеми cron задачами
```

### Новые endpoints (в разработке)
```
POST   /api/payments/refund/:paymentId  # Возврат средств
GET    /api/payments/history            # История платежей пользователя
```

### Админ-панель (в разработке)
```
lib/screens/admin/
└── payments_management_screen.dart     # Управление платежами
```

---

## 📊 Миграции БД

### История миграций:
1. **20250726100336_init** - Начальная схема (9 таблиц)
2. **migration_add_payments** - Таблица payments (30.09.2025) ✨ НОВОЕ

### Команды миграции:
```bash
# Создать миграцию
npx prisma migrate dev --name описание_изменения

# Применить на продакшене
npx prisma migrate deploy

# Обновить Prisma Client
npx prisma generate

# Просмотр статуса
npx prisma migrate status
```

---

## 🧪 Тестирование

### Backend тесты:
```bash
# Тест интеграции Точка Банк
node test-tochka.js

# Тест миграции payments
node test-migration.js

# Настройка вебхука
node setup-tochka-webhook.js

# Генерация JWT для тестов
node generate-test-token.js
```

### Проверка здоровья системы:
```bash
# Health check
curl http://84.201.149.245:3000/health

# Проверка API
curl http://84.201.149.245:3000/api

# Логи backend
sudo journalctl -u severnaya-korzina -f

# Статус PM2
pm2 status
pm2 logs severnaya-backend
```

### SQL запросы для проверки:
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
```

---

## 📌 Важные URL

### Production:
- **Backend API**: http://84.201.149.245:3000/api
- **Web App**: http://app.sevkorzina.ru
- **Admin Panel**: http://84.201.149.245:3000/admin
- **Webhook**: https://app.sevkorzina.ru/api/payments/webhook

### GitHub:
- **Backend**: https://github.com/idob23/severnaya-korzina-backend
- **Mobile**: https://github.com/idob23/severnaya_korzina
- **Admin**: https://github.com/idob23/severnaya_korzina_admin

### Точка Банк:
- **API**: https://enter.tochka.com/uapi
- **Документация**: https://enter.tochka.com/doc/

---

> 📌 **Примечание**: Структура актуальна на **30 сентября 2025**. Документ обновлён с учётом интеграции Точка Банк. При добавлении новых функций обновляйте этот документ!