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
│   ├── orders.js              # Заказы (ИСПРАВЛЕН)
│   ├── payments.js            # Платежи (ИСПРАВЛЕН)
│   ├── batches.js             # Закупки
│   ├── addresses.js           # Адреса
│   ├── admin.js               # Админские функции
│   ├── sms.js                 # SMS сервис
│   └── app.js                 # 🆕 API обновлений приложения
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
│   ├── profile/               # Профиль (с проверкой обновлений)
│   └── splash/                # Загрузочный экран
├── services/                   # Сервисы
│   ├── api_service.dart       # HTTP клиент
│   ├── auth_service.dart      # Авторизация
│   ├── storage_service.dart   # Локальное хранение
│   ├── sms_service.dart       # SMS сервис
│   ├── notification_service.dart # Уведомления
│   └── update_service.dart    # 🆕 Сервис обновлений
├── providers/                  # Провайдеры состояния
│   ├── auth_provider.dart     # Авторизация
│   ├── catalog_provider.dart  # Каталог
│   ├── cart_provider.dart     # Корзина
│   └── orders_provider.dart   # Заказы
└── constants/                  # Константы
    ├── api_constants.dart     # API endpoints
    ├── colors.dart           # Цвета
    └── order_status.dart     # Статусы заказов
```

### 📦 Зависимости приложения:
```yaml
dependencies:
  # Основные
  flutter: sdk
  http: ^1.2.0
  provider: ^6.1.1
  shared_preferences: ^2.3.0
  
  # Для обновлений
  package_info_plus: ^8.3.1
  dio: ^5.4.0
  open_file: ^3.5.10
  permission_handler: ^12.0.1
  path_provider: ^2.1.5
  
  # UI и утилиты
  intl: ^0.20.0
  mask_text_input_formatter: ^2.9.0
  qr_flutter: ^4.1.0
  url_launcher: ^6.2.0
  webview_flutter: ^4.5.0
  flutter_secure_storage: ^9.2.1
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
│   ├── 🔧 services/           # API сервисы
│   ├── 📈 widgets/            # UI компоненты
│   ├── 🔄 providers/          # Управление состоянием
│   └── 🎨 constants/          # Константы
└── 🌐 web/                    # Web конфиг с автообновлениями
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
- **Backend**: ~15 MB (без node_modules)
- **Mobile APK**: ~35 MB
- **Web App**: ~10 MB
- **Admin Panel**: ~8 MB
- **Database**: ~50 MB

### Количество файлов:
- **Backend**: ~50 файлов
- **Mobile**: ~100 файлов
- **Admin**: ~80 файлов

### Строки кода:
- **JavaScript (Backend)**: ~5,000
- **Dart (Flutter)**: ~15,000
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
- `lib/main.dart` - точка входа mobile
- `lib/services/api_service.dart` - API клиент
- `lib/services/update_service.dart` - обновления

### Документация:
- `docs/PROJECT_OVERVIEW.md` - обзор
- `docs/CURRENT_STATUS.md` - статус
- `docs/PROJECT_STRUCTURE.md` - структура
- `README.md` - быстрый старт

---

> 📌 **Примечание**: Структура актуальна на 31.12.2024. При добавлении новых функций обновляйте этот документ!