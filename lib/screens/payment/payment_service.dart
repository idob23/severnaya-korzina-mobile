// lib/screens/payment/payment_service.dart - ОЧИЩЕННАЯ ВЕРСИЯ (только Точка Банк)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentService {
  // Backend API endpoint (Точка Банк)
  // static const String _baseUrl = 'http://84.201.149.245:3000';
  static const String _baseUrl = 'https://api.sevkorzina.ru';

  /// Создание платежа через backend (Точка Банк)
  Future<PaymentResult> createPayment({
    required double amount,
    required String orderId,
    required String customerPhone,
    required String customerName,
    String? token,
    List<Map<String, dynamic>>? orderItems,
    String? notes,
    int? addressId,
    int? batchId,
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
          'addressId': addressId ?? 1,
          'items': orderItems ?? [],
          'notes': notes,
          'batchId': batchId,
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
            realOrderId: data['realOrderId'],
            orderCreated: data['orderCreated'] ?? false,
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

  /// Проверка статуса платежа через backend
  Future<PaymentStatus> checkPaymentStatus(String paymentId,
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
            amount: data['amount'].toDouble(),
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
}

/// Результат создания платежа
class PaymentResult {
  final bool success;
  final String? paymentId;
  final String? status;
  final String? confirmationUrl;
  final String? message;
  final String? realOrderId;
  final bool orderCreated;

  PaymentResult({
    required this.success,
    this.paymentId,
    this.status,
    this.confirmationUrl,
    this.message,
    this.realOrderId,
    this.orderCreated = false,
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
