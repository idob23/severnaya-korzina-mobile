// // lib/screens/payment/payment_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// class PaymentService {
//   // Используем ваш бэкенд вместо прямых запросов к ЮKassa
//   static const String _baseUrl =
//       'http://84.201.149.245:3000'; // Замените на ваш API URL

//   // Старые константы ЮKassa оставляем для мобильных платформ (fallback)
//   static const String _yooKassaBaseUrl = 'https://api.yookassa.ru/v3';
//   static const String _shopId = '1148812';
//   static const String _secretKey =
//       'test_jSLEuLPMPW58_iRfez3W_ToHsrMv2XS_cgqIYpNMa5A';

//   /// Создание платежа (универсальный метод)
//   Future<PaymentResult> createPayment({
//     required double amount,
//     required String orderId,
//     required String customerPhone,
//     required String customerName,
//     String? token,
//   }) async {
//     if (kIsWeb) {
//       // Для веб-версии используем бэкенд
//       return _createPaymentViaBackend(
//         amount: amount,
//         orderId: orderId,
//         customerPhone: customerPhone,
//         customerName: customerName,

//       );
//     } else {
//       // Для мобильных платформ используем прямые запросы к ЮKassa
//       return _createPaymentDirectly(
//         amount: amount,
//         orderId: orderId,
//         customerPhone: customerPhone,
//         customerName: customerName,
//       );
//     }
//   }

//   /// Создание платежа через ваш бэкенд (для веб)
//   Future<PaymentResult> _createPaymentViaBackend({
//     required double amount,
//     required String orderId,
//     required String customerPhone,
//     required String customerName,
//   }) async {
//     try {
//       // Здесь нужно получить токен авторизации
//       // final token = await AuthService.getToken();

//       final response = await http.post(
//         Uri.parse('$_baseUrl/api/payments/create'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token', // Добавить когда будет авторизация
//         },
//         body: jsonEncode({
//           'amount': amount,
//           'orderId': orderId,
//           'customerPhone': customerPhone,
//           'customerName': customerName,
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           return PaymentResult(
//             success: true,
//             paymentId: data['paymentId'],
//             status: data['status'],
//             confirmationUrl: data['confirmationUrl'],
//             message: data['message'],
//           );
//         } else {
//           return PaymentResult(
//             success: false,
//             message: data['error'] ?? 'Ошибка создания платежа',
//           );
//         }
//       } else {
//         final errorData = jsonDecode(response.body);
//         return PaymentResult(
//           success: false,
//           message: errorData['error'] ?? 'Ошибка сервера',
//         );
//       }
//     } catch (e) {
//       return PaymentResult(
//         success: false,
//         message: 'Ошибка подключения к серверу: $e',
//       );
//     }
//   }

//   /// Создание платежа напрямую через ЮKassa (для мобильных)
//   Future<PaymentResult> _createPaymentDirectly({
//     required double amount,
//     required String orderId,
//     required String customerPhone,
//     required String customerName,
//   }) async {
//     try {
//       final basicAuth = base64Encode(utf8.encode('$_shopId:$_secretKey'));
//       final idempotenceKey =
//           'order_${orderId}_${DateTime.now().millisecondsSinceEpoch}';

//       final requestBody = {
//         'amount': {
//           'value': amount.toStringAsFixed(2),
//           'currency': 'RUB',
//         },
//         'confirmation': {
//           'type': 'redirect',
//           'return_url': 'https://sevkorzina.ru/payment-success?status=success',
//         },
//         'capture': true,
//         'description': 'Оплата заказа $orderId в Северной корзине',
//         'metadata': {
//           'order_id': orderId,
//           'customer_phone': customerPhone,
//           'customer_name': customerName,
//           'app_name': 'severnaya_korzina',
//         },
//         'payment_method_data': {'type': 'bank_card'},
//         'receipt': {
//           'customer': {'phone': customerPhone},
//           'items': [
//             {
//               'description': 'Оплата за товары (коллективная закупка)',
//               'quantity': '1.00',
//               'amount': {
//                 'value': amount.toStringAsFixed(2),
//                 'currency': 'RUB',
//               },
//               'vat_code': 1,
//             }
//           ],
//         },
//       };

//       final response = await http.post(
//         Uri.parse('$_yooKassaBaseUrl/payments'),
//         headers: {
//           'Authorization': 'Basic $basicAuth',
//           'Content-Type': 'application/json',
//           'Idempotence-Key': idempotenceKey,
//         },
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         return PaymentResult(
//           success: true,
//           paymentId: data['id'],
//           status: data['status'],
//           confirmationUrl: data['confirmation']['confirmation_url'],
//           message: 'Платеж создан успешно',
//         );
//       } else {
//         final errorData = jsonDecode(response.body);
//         return PaymentResult(
//           success: false,
//           message: errorData['description'] ?? 'Неизвестная ошибка',
//         );
//       }
//     } catch (e) {
//       return PaymentResult(
//         success: false,
//         message: 'Ошибка подключения к платежной системе',
//       );
//     }
//   }

//   /// Проверка статуса платежа (универсальный метод)
//   Future<PaymentStatus> checkPaymentStatus(String paymentId, {String? token}) async {
//     if (kIsWeb) {
//       return _checkPaymentStatusViaBackend(paymentId);
//     } else {
//       return _checkPaymentStatusDirectly(paymentId);
//     }
//   }

//   /// Проверка статуса через бэкенд (для веб)
//   Future<PaymentStatus> _checkPaymentStatusViaBackend(String paymentId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_baseUrl/api/payments/status/$paymentId'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer $token', // Добавить когда будет авторизация
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['success']) {
//           return PaymentStatus(
//             paymentId: data['paymentId'],
//             status: data['status'],
//             isPaid: data['isPaid'],
//             isCanceled: data['isCanceled'],
//             isPending: data['isPending'],
//             amount: data['amount'],
//             createdAt: DateTime.parse(data['createdAt']),
//             paidAt:
//                 data['paidAt'] != null ? DateTime.parse(data['paidAt']) : null,
//           );
//         }
//       }
//       throw Exception('Ошибка проверки статуса через бэкенд');
//     } catch (e) {
//       throw Exception('Ошибка подключения при проверке статуса');
//     }
//   }

//   /// Проверка статуса напрямую (для мобильных)
//   Future<PaymentStatus> _checkPaymentStatusDirectly(String paymentId) async {
//     try {
//       final basicAuth = base64Encode(utf8.encode('$_shopId:$_secretKey'));

//       final response = await http.get(
//         Uri.parse('$_yooKassaBaseUrl/payments/$paymentId'),
//         headers: {
//           'Authorization': 'Basic $basicAuth',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final status = data['status'];

//         return PaymentStatus(
//           paymentId: paymentId,
//           status: status,
//           isPaid: status == 'succeeded',
//           isCanceled: status == 'canceled',
//           isPending: status == 'pending',
//           amount: double.parse(data['amount']['value']),
//           createdAt: DateTime.parse(data['created_at']),
//           paidAt:
//               data['paid_at'] != null ? DateTime.parse(data['paid_at']) : null,
//         );
//       } else {
//         throw Exception('Ошибка проверки статуса: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Ошибка подключения при проверке статуса');
//     }
//   }

//   /// Открытие платежной формы в браузере
//   Future<bool> openPaymentForm(String confirmationUrl) async {
//     try {
//       final Uri url = Uri.parse(confirmationUrl);
//       if (await canLaunchUrl(url)) {
//         return await launchUrl(url, mode: LaunchMode.externalApplication);
//       }
//       return false;
//     } catch (e) {
//       return false;
//     }
//   }

//   /// Проверка тестового режима
//   static bool isTestMode() => _secretKey.startsWith('test_');
// }

// /// Результат создания платежа
// class PaymentResult {
//   final bool success;
//   final String? paymentId;
//   final String? status;
//   final String? confirmationUrl;
//   final String? message;

//   PaymentResult({
//     required this.success,
//     this.paymentId,
//     this.status,
//     this.confirmationUrl,
//     this.message,
//   });
// }

// /// Статус платежа
// class PaymentStatus {
//   final String paymentId;
//   final String status;
//   final bool isPaid;
//   final bool isCanceled;
//   final bool isPending;
//   final double amount;
//   final DateTime createdAt;
//   final DateTime? paidAt;

//   PaymentStatus({
//     required this.paymentId,
//     required this.status,
//     required this.isPaid,
//     required this.isCanceled,
//     required this.isPending,
//     required this.amount,
//     required this.createdAt,
//     this.paidAt,
//   });
// }

// lib/screens/payment/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class PaymentService {
  // Используем ваш бэкенд вместо прямых запросов к ЮKassa
  static const String _baseUrl =
      'http://84.201.149.245:3000'; // Замените на ваш API URL

  // Старые константы ЮKassa оставляем для мобильных платформ (fallback)
  static const String _yooKassaBaseUrl = 'https://api.yookassa.ru/v3';
  static const String _shopId = '1148812';
  static const String _secretKey =
      'test_jSLEuLPMPW58_iRfez3W_ToHsrMv2XS_cgqIYpNMa5A';

  /// Создание платежа (универсальный метод)
  Future<PaymentResult> createPayment({
    required double amount,
    required String orderId,
    required String customerPhone,
    required String customerName,
    String? token,
    List<Map<String, dynamic>>? orderItems, // ДОБАВИТЬ
    String? notes, // ДОБАВИТЬ
  }) async {
    if (kIsWeb) {
      // Для веб-версии используем бэкенд
      return _createPaymentViaBackend(
        amount: amount,
        orderId: orderId,
        customerPhone: customerPhone,
        customerName: customerName,
        token: token,
        orderItems: orderItems, // ДОБАВИТЬ
        notes: notes, // ДОБАВИТЬ
      );
    } else {
      // Для мобильных платформ используем прямые запросы к ЮKassa
      return _createPaymentDirectly(
        amount: amount,
        orderId: orderId,
        customerPhone: customerPhone,
        customerName: customerName,
      );
    }
  }

  /// Создание платежа через ваш бэкенд (для веб)
  Future<PaymentResult> _createPaymentViaBackend({
    required double amount,
    required String orderId,
    required String customerPhone,
    required String customerName,
    String? token,
    List<Map<String, dynamic>>? orderItems, // ДОБАВИТЬ
    String? notes, // ДОБАВИТЬ
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/payments/create'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'orderId': orderId,
          'customerPhone': customerPhone,
          'customerName': customerName,
          // ДОБАВИТЬ данные заказа:
          'addressId': 1,
          'items': orderItems ?? [], // ДОБАВИТЬ
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PaymentResult(
            success: true,
            paymentId: data['paymentId'],
            status: data['status'],
            confirmationUrl: data['confirmationUrl'],
            message: data['message'],
          );
        } else {
          return PaymentResult(
            success: false,
            message: data['error'] ?? 'Ошибка создания платежа',
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        return PaymentResult(
          success: false,
          message: errorData['error'] ?? 'Ошибка сервера',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Ошибка подключения к серверу: $e',
      );
    }
  }

  /// Создание платежа напрямую через ЮKassa (для мобильных)
  Future<PaymentResult> _createPaymentDirectly({
    required double amount,
    required String orderId,
    required String customerPhone,
    required String customerName,
  }) async {
    try {
      final basicAuth = base64Encode(utf8.encode('$_shopId:$_secretKey'));
      final idempotenceKey =
          'order_${orderId}_${DateTime.now().millisecondsSinceEpoch}';

      final requestBody = {
        'amount': {
          'value': amount.toStringAsFixed(2),
          'currency': 'RUB',
        },
        'confirmation': {
          'type': 'redirect',
          'return_url': 'https://sevkorzina.ru/payment-success?status=success',
        },
        'capture': true,
        'description': 'Оплата заказа $orderId в Северной корзине',
        'metadata': {
          'order_id': orderId,
          'customer_phone': customerPhone,
          'customer_name': customerName,
          'app_name': 'severnaya_korzina',
        },
        'payment_method_data': {'type': 'bank_card'},
        'receipt': {
          'customer': {'phone': customerPhone},
          'items': [
            {
              'description': 'Оплата за товары (коллективная закупка)',
              'quantity': '1.00',
              'amount': {
                'value': amount.toStringAsFixed(2),
                'currency': 'RUB',
              },
              'vat_code': 1,
            }
          ],
        },
      };

      final response = await http.post(
        Uri.parse('$_yooKassaBaseUrl/payments'),
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/json',
          'Idempotence-Key': idempotenceKey,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return PaymentResult(
          success: true,
          paymentId: data['id'],
          status: data['status'],
          confirmationUrl: data['confirmation']['confirmation_url'],
          message: 'Платеж создан успешно',
        );
      } else {
        final errorData = jsonDecode(response.body);
        return PaymentResult(
          success: false,
          message: errorData['description'] ?? 'Неизвестная ошибка',
        );
      }
    } catch (e) {
      return PaymentResult(
        success: false,
        message: 'Ошибка подключения к платежной системе',
      );
    }
  }

  /// Проверка статуса платежа (универсальный метод)
  Future<PaymentStatus> checkPaymentStatus(String paymentId,
      {String? token}) async {
    if (kIsWeb) {
      return _checkPaymentStatusViaBackend(paymentId, token: token);
    } else {
      return _checkPaymentStatusDirectly(paymentId);
    }
  }

  /// Проверка статуса через бэкенд (для веб)
  Future<PaymentStatus> _checkPaymentStatusViaBackend(String paymentId,
      {String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/api/payments/status/$paymentId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return PaymentStatus(
            paymentId: data['paymentId'],
            status: data['status'],
            isPaid: data['isPaid'],
            isCanceled: data['isCanceled'],
            isPending: data['isPending'],
            amount: data['amount'],
            createdAt: DateTime.parse(data['createdAt']),
            paidAt:
                data['paidAt'] != null ? DateTime.parse(data['paidAt']) : null,
          );
        }
      }
      throw Exception('Ошибка проверки статуса через бэкенд');
    } catch (e) {
      throw Exception('Ошибка подключения при проверке статуса');
    }
  }

  /// Проверка статуса напрямую (для мобильных)
  Future<PaymentStatus> _checkPaymentStatusDirectly(String paymentId) async {
    try {
      final basicAuth = base64Encode(utf8.encode('$_shopId:$_secretKey'));

      final response = await http.get(
        Uri.parse('$_yooKassaBaseUrl/payments/$paymentId'),
        headers: {
          'Authorization': 'Basic $basicAuth',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'];

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
      throw Exception('Ошибка подключения при проверке статуса');
    }
  }

  /// Открытие платежной формы в браузере
  Future<bool> openPaymentForm(String confirmationUrl) async {
    try {
      final Uri url = Uri.parse(confirmationUrl);
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Проверка тестового режима
  static bool isTestMode() => _secretKey.startsWith('test_');
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
}
