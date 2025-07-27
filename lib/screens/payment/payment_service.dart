// lib/screens/payment/payment_service.dart - ПРОДАКШЕН ВЕРСИЯ
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  // ЮKassa API настройки
  static const String _baseUrl = 'https://api.yookassa.ru/v3';

  // ВАЖНО: Замените на ваши реальные данные из личного кабинета ЮKassa
  // Получите их здесь: https://yookassa.ru/my/
  static const String _shopId = 'ваш_shop_id_здесь'; // Например: '123456'
  static const String _secretKey =
      'ваш_secret_key_здесь'; // Например: 'test_ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789'

  // Для начала используйте тестовые ключи, затем замените на боевые

  /// Создание платежа через ЮKassa для карт МИР
  Future<PaymentResult> createMirPayment({
    required double amount,
    required String orderId,
    required String customerPhone,
    required String customerName,
  }) async {
    try {
      print('💳 Создаем платеж на сумму: $amount руб.');
      print('📞 Телефон клиента: $customerPhone');

      final String basicAuth =
          base64Encode(utf8.encode('$_shopId:$_secretKey'));
      final String idempotenceKey =
          'order_${orderId}_${DateTime.now().millisecondsSinceEpoch}';

      final requestBody = {
        'amount': {
          'value': amount.toStringAsFixed(2),
          'currency': 'RUB',
        },
        'confirmation': {
          'type': 'redirect',
          'return_url':
              'https://your-app.com/payment-success', // Замените на ваш URL
        },
        'capture': true,
        'description': 'Предоплата заказа $orderId в Северной корзине',
        'metadata': {
          'order_id': orderId,
          'customer_phone': customerPhone,
          'customer_name': customerName,
          'app_name': 'severnaya_korzina',
        },
        'payment_method_data': {
          'type': 'bank_card',
        },
        'receipt': {
          'customer': {
            'phone': customerPhone,
          },
          'items': [
            {
              'description': 'Предоплата за товары (коллективная закупка)',
              'quantity': '1.00',
              'amount': {
                'value': amount.toStringAsFixed(2),
                'currency': 'RUB',
              },
              'vat_code': 1, // НДС 20%
            }
          ],
        },
      };

      print('📤 Отправляем запрос в ЮKassa...');

      final response = await http.post(
        Uri.parse('$_baseUrl/payments'),
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/json',
          'Idempotence-Key': idempotenceKey,
        },
        body: jsonEncode(requestBody),
      );

      print('📥 Ответ ЮKassa: ${response.statusCode}');
      print('📥 Тело ответа: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Платеж создан успешно: ${data['id']}');

        return PaymentResult(
          success: true,
          paymentId: data['id'],
          status: data['status'],
          confirmationUrl: data['confirmation']['confirmation_url'],
          message: 'Платеж создан успешно',
        );
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ Ошибка создания платежа: ${errorData['description']}');

        return PaymentResult(
          success: false,
          message: errorData['description'] ?? 'Неизвестная ошибка',
        );
      }
    } catch (e) {
      print('💥 Исключение при создании платежа: $e');
      return PaymentResult(
        success: false,
        message: 'Ошибка подключения к платежной системе: $e',
      );
    }
  }

  /// Проверка статуса платежа
  Future<PaymentStatus> checkPaymentStatus(String paymentId) async {
    try {
      print('🔍 Проверяем статус платежа: $paymentId');

      final String basicAuth =
          base64Encode(utf8.encode('$_shopId:$_secretKey'));

      final response = await http.get(
        Uri.parse('$_baseUrl/payments/$paymentId'),
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

        print('📊 Статус платежа: $status');

        return PaymentStatus(
          paymentId: paymentId,
          status: status,
          isPaid: status == 'succeeded',
          isCanceled: status == 'canceled',
          isPending: status == 'pending',
          amount: double.parse(data['amount']['value']),
          createdAt: DateTime.parse(data['created_at']),
          paidAt:
              data['paid_at'] != null ? DateTime.parse(data['paid_at']) : null,
        );
      } else {
        throw Exception('Ошибка проверки статуса: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Ошибка проверки статуса: $e');
      throw Exception('Ошибка подключения при проверке статуса: $e');
    }
  }

  /// Открытие платежной формы в браузере
  Future<bool> openPaymentForm(String confirmationUrl) async {
    try {
      print('🌐 Открываем платежную форму: $confirmationUrl');

      final Uri url = Uri.parse(confirmationUrl);

      if (await canLaunchUrl(url)) {
        final result = await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        print('🚀 Платежная форма открыта: $result');
        return result;
      } else {
        print('❌ Не удается открыть URL: $confirmationUrl');
        return false;
      }
    } catch (e) {
      print('💥 Ошибка открытия платежной формы: $e');
      return false;
    }
  }

  /// Отмена платежа
  Future<bool> cancelPayment(String paymentId) async {
    try {
      print('❌ Отменяем платеж: $paymentId');

      final String basicAuth =
          base64Encode(utf8.encode('$_shopId:$_secretKey'));
      final String idempotenceKey =
          'cancel_${paymentId}_${DateTime.now().millisecondsSinceEpoch}';

      final response = await http.post(
        Uri.parse('$_baseUrl/payments/$paymentId/cancel'),
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/json',
          'Idempotence-Key': idempotenceKey,
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('💥 Ошибка отмены платежа: $e');
      return false;
    }
  }

  /// Возврат платежа
  Future<bool> refundPayment(String paymentId, double amount) async {
    try {
      print('💰 Возврат платежа: $paymentId, сумма: $amount');

      final String basicAuth =
          base64Encode(utf8.encode('$_shopId:$_secretKey'));
      final String idempotenceKey =
          'refund_${paymentId}_${DateTime.now().millisecondsSinceEpoch}';

      final requestBody = {
        'amount': {
          'value': amount.toStringAsFixed(2),
          'currency': 'RUB',
        },
        'payment_id': paymentId,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/refunds'),
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/json',
          'Idempotence-Key': idempotenceKey,
        },
        body: jsonEncode(requestBody),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('💥 Ошибка возврата платежа: $e');
      return false;
    }
  }

  /// Получение тестовых данных карт для песочницы
  static Map<String, String> getTestCards() {
    return {
      'Успешная оплата': '5555555555554444',
      'Недостаточно средств': '5555555555554477',
      'Отклонена банком': '5555555555554485',
      'Карта заблокирована': '5555555555554493',
      'Карта МИР (тест)': '2200000000000004',
    };
  }

  /// Проверка, работаем ли в тестовом режиме
  static bool isTestMode() {
    return _secretKey.startsWith('test_');
  }

  /// Получение информации о магазине
  static Map<String, String> getShopInfo() {
    return {
      'shop_id': _shopId,
      'is_test': isTestMode().toString(),
      'api_url': _baseUrl,
    };
  }
}

/// Результат создания платежа
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? status;
  final String? confirmationUrl;
  final String? message;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.status,
    this.confirmationUrl,
    this.message,
  });

  @override
  String toString() {
    return 'PaymentResult(success: $success, paymentId: $paymentId, status: $status)';
  }
}

/// Статус платежа
class PaymentStatus {
  final String paymentId;
  final String status;
  final bool isPaid;
  final bool isCanceled;
  final bool isPending;
  final double amount;
  final DateTime createdAt;
  final DateTime? paidAt;

  PaymentStatus({
    required this.paymentId,
    required this.status,
    required this.isPaid,
    required this.isCanceled,
    required this.isPending,
    required this.amount,
    required this.createdAt,
    this.paidAt,
  });

  @override
  String toString() {
    return 'PaymentStatus(paymentId: $paymentId, status: $status, amount: $amount)';
  }
}
