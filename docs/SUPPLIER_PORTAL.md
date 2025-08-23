План разработки Supplier Portal
Техническая архитектура
Stack

Backend: Node.js + Express + PostgreSQL
Frontend: React (простая админка)
Файлы: Multer для загрузки, хранение на сервере
Аутентификация: Простые логин/пароль (без SMS)

Структура проекта
supplier-portal/
├── backend/
│   ├── src/
│   │   ├── routes/
│   │   ├── models/
│   │   └── uploads/
│   └── prisma/
└── frontend/
    ├── src/
    └── public/
База данных
Таблицы
sqlsuppliers - ID, name, login, password, created_at
price_files - ID, supplier_id, filename, original_name, uploaded_at, status
chat_messages - ID, supplier_id, sender_type, message, created_at
Этапы разработки
Этап 1: Базовый backend (2-3 часа)

Настройка проекта

Инициализация Node.js проекта
Подключение PostgreSQL
Настройка Prisma


Модель данных

Создание схемы базы данных
Миграции


API для поставщиков

POST /api/auth/login - вход поставщика
POST /api/files/upload - загрузка прайса
GET /api/files - список файлов поставщика
DELETE /api/files/:id - удаление файла



Этап 2: API чата (1-2 часа)

Чат функционал

GET /api/chat/:supplierId - история сообщений
POST /api/chat/:supplierId - отправка сообщения
Разделение на отправителя (вы/поставщик)



Этап 3: Админская часть для вас (2-3 часа)

API для админа

GET /api/admin/suppliers - список поставщиков
GET /api/admin/files - все загруженные файлы
GET /api/admin/files/download/:id - скачивание файла
POST /api/admin/suppliers - создание поставщика


Простая админка (React)

Список поставщиков
Просмотр файлов по поставщикам
Скачивание/удаление файлов



Этап 4: Интерфейс для поставщиков (3-4 часа)

Веб-интерфейс поставщика

Страница входа
Загрузка файлов (drag&drop)
Просмотр загруженных файлов
Чат с вами



Этап 5: Интеграция с основной системой (1-2 часа)

API для экспорта

GET /api/export/files/:supplierId - данные для импорта в основную систему
Простой формат JSON для переноса в вашу БД



Детальная техническая спецификация
Backend Routes
Аутентификация поставщиков
javascriptPOST /api/auth/login
Body: { login, password }
Response: { success, token, supplier: { id, name } }
Управление файлами
javascriptPOST /api/files/upload
Headers: Authorization Bearer token
Body: FormData с файлом
Response: { success, file: { id, filename, uploaded_at } }

GET /api/files
Headers: Authorization
Response: { files: [{ id, filename, uploaded_at, status }] }
Чат
javascriptGET /api/chat
Headers: Authorization  
Response: { messages: [{ id, sender_type, message, created_at }] }

POST /api/chat
Headers: Authorization
Body: { message }
Response: { success, message_id }
Frontend компоненты
Для поставщиков

LoginPage - форма входа
Dashboard - главная страница после входа
FileUpload - загрузка прайсов
FileList - список загруженных файлов
Chat - чат с вами

Для админа (вас)

AdminDashboard - обзор всех поставщиков
SupplierFiles - файлы конкретного поставщика
ChatWithSupplier - переписка с поставщиком
SupplierManagement - создание новых поставщиков

Временная оценка
Общее время разработки: 8-12 часов

Backend: 4-6 часов
Frontend: 4-6 часов
Тестирование и отладка: 2-3 часа

MVP функционал
Для поставщика:

Вход в систему (логин/пароль)
Загрузка CSV/Excel файлов
Просмотр загруженных файлов
Удаление файлов
Чат с вами

Для вас (админ):

Создание аккаунтов поставщиков
Просмотр всех файлов по поставщикам
Скачивание файлов для ручной обработки
Чат с каждым поставщиком
Удаление файлов/поставщиков

Следующие итерации (TODO)

Автопарсинг файлов - унификация форматов
Уведомления - email/SMS о новых файлах
Статистика - частота обновлений прайсов
API интеграция - автоматический экспорт в основную систему
Версионность файлов - история изменений прайсов

Этот план создает минимально жизнеспособный продукт, который сразу решит проблему централизации прайсов и коммуникации, а потом можно наращивать функционал по мере необходимости.