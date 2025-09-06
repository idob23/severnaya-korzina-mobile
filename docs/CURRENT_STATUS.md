📝 ПОДРОБНЫЙ ОТЧЕТ О ВНЕДРЕНИИ ФИСКАЛИЗАЦИИ И НАСТРАИВАЕМЫХ ПАРАМЕТРОВ
🎯 Что было сделано:
1. База данных - Добавлена таблица настроек
Создана новая таблица system_settings:
sqlCREATE TABLE "system_settings" (
    "id" SERIAL PRIMARY KEY,
    "key" TEXT UNIQUE NOT NULL,
    "value" TEXT NOT NULL,
    "description" TEXT,
    "updatedAt" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP
);
Добавлены начальные настройки:

default_margin_percent = '20' (маржа по умолчанию)
vat_code = '6' (код НДС для УСН без НДС)
payment_mode = 'test' (режим платежей)
enable_test_cards = 'true' (разрешить тестовые карты)

В prisma/schema.prisma добавлена модель:
prismamodel SystemSettings {
  id          Int      @id @default(autoincrement())
  key         String   @unique
  value       String
  description String?
  updatedAt   DateTime @default(now()) @updatedAt
  @@map("system_settings")
}
2. Backend - Полностью переработан файл src/routes/payments.js
Ключевые изменения:

Добавлена функция получения настроек из БД getSystemSettings()
Реализовано разделение суммы на две позиции в чеке:

Товары (сумма без маржи)
Услуга организации закупки (маржа)


Маржа берется из партии или из настроек по умолчанию
НДС код берется из настроек (по умолчанию 6 - без НДС для УСН)
Динамическое переключение между тестовым и боевым режимом

Формула расчета:
javascriptconst totalWithMargin = 1000; // Итоговая сумма
const marginPercent = 20; // Маржа из партии или настроек
const goodsAmount = (totalWithMargin / (1 + marginPercent / 100)); // 833.33
const serviceAmount = (totalWithMargin - goodsAmount); // 166.67
Структура чека теперь:
javascriptreceipt: {
  customer: { phone: customerPhone },
  items: [
    {
      description: "Товары коллективной закупки (партия №1)",
      quantity: "1.00",
      amount: { value: "833.33", currency: "RUB" },
      vat_code: 6, // из настроек
      payment_subject: "commodity", // товар
      payment_mode: "full_payment"
    },
    {
      description: "Услуга организации коллективной закупки",
      quantity: "1.00", 
      amount: { value: "166.67", currency: "RUB" },
      vat_code: 6, // из настроек
      payment_subject: "service", // услуга
      payment_mode: "full_payment"
    }
  ]
}
3. Backend - Добавлены API endpoints в src/routes/admin.js
Новые маршруты:
javascript// Получение всех настроек
GET /api/admin/settings

// Обновление конкретной настройки
PUT /api/admin/settings/:key

// Обновление маржи партии (если добавлен)
PUT /api/admin/batches/:id/margin
Исправления в файле:

Добавлен импорт const { authenticateToken } = require('../middleware/auth');
Добавлена функция requireAdmin для проверки прав

4. Админ-панель - Создан экран настроек
Файл lib/screens/admin/system_settings_screen.dart:

Управление режимом платежей (тест/боевой)
Изменение кода НДС (6 вариантов)
Настройка маржи по умолчанию
Включение/отключение тестовых карт

Добавлены методы в lib/services/admin_api_service.dart:
dartgetSystemSettings() // Получение настроек
updateSystemSetting(String key, String value) // Обновление настройки
5. Текущее состояние и настройки
Проверенные значения:

Маржа в партии №1: 50% (нужно изменить на более адекватную)
НДС: код 6 (без НДС для УСН)
Режим: тестовый
Тестовые карты: разрешены

Успешно протестировано:

✅ Создание платежа с разделением на 2 позиции
✅ Расчет маржи (при 50% маржа: 1000₽ = 666.67₽ товары + 333.33₽ услуга)
✅ Оплата тестовой картой 5555 5555 5555 4444
✅ Платеж успешно проведен (ID: 304e4745-000f-5000-b000-1f8153cd3cd4)

6. Что нужно сделать для полного запуска
Обязательно:

Изменить маржу партии №1 с 50% на разумную (10-20%)
Получить боевые ключи ЮKassa:

Shop ID (не начинается с test_)
Secret Key (начинается с live_)


Добавить в .env:
envYOOKASSA_SHOP_ID_PROD=ваш_shop_id
YOOKASSA_SECRET_KEY_PROD=live_xxxxxxxxxx

Переключить в админке режим на "Боевой"

Рекомендуется:

Настроить webhook в ЮKassa на http://84.201.149.245:3000/api/payments/webhook
Протестировать с минимальной реальной суммой (10₽)
Проверить чек в личном кабинете ЮKassa
Отключить тестовые карты после проверки

7. Важные технические детали
Налоговые аспекты:

УСН Доходы-Расходы: налог платится только с маржи (услуги)
Код НДС 6: означает "без НДС" для УСН
Две позиции в чеке: обязательно для корректного учета

Формулы для разных марж:
При марже 20%: 1000₽ = 833.33₽ товары + 166.67₽ услуга
При марже 15%: 1000₽ = 869.57₽ товары + 130.43₽ услуга  
При марже 10%: 1000₽ = 909.09₽ товары + 90.91₽ услуга
При марже 50%: 1000₽ = 666.67₽ товары + 333.33₽ услуга
API для тестирования:
bash# Получить токен
curl -X POST http://84.201.149.245:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phone": "79142667582", "code": "1234"}'

# Создать платеж
TOKEN="полученный_токен"
curl -X POST http://84.201.149.245:3000/api/payments/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "amount": 1000,
    "orderId": "TEST-XXX",
    "customerPhone": "79142667582",
    "customerName": "Тест",
    "batchId": 1
  }'
8. Файлы, которые были изменены:

✅ prisma/schema.prisma - добавлена модель SystemSettings
✅ src/routes/payments.js - полностью переработан для фискализации
✅ src/routes/admin.js - добавлены endpoints для настроек
✅ lib/screens/admin/system_settings_screen.dart - создан новый экран
✅ lib/services/admin_api_service.dart - добавлены методы для настроек
✅ lib/screens/dashboard_screen.dart - добавлена навигация к настройкам

9. Текущие проблемы и решения:
Проблема: Чек не отображается в тестовом режиме ЮKassa
Решение: Это нормально для тестового режима. В боевом режиме чеки будут видны.
Проблема: Высокая маржа 50% в партии №1
Решение: Нужно обновить через админку или БД на адекватное значение (10-20%).
Проблема: Нет боевых ключей
Решение: Нужно зарегистрироваться в ЮKassa как ИП и получить реальные ключи.
10. Следующий разговор начать с:
"Система фискализации настроена. Чеки разделяются на товары и услугу. Маржа и НДС настраиваются через админку. Нужно:

Изменить маржу партии с 50% на нормальную
Получить боевые ключи ЮKassa
Протестировать в боевом режиме с реальным платежом"


СТАТУС: ✅ Система готова к переходу на боевой режим после получения реальных ключей ЮKassa и корректировки маржи.