// lib/screens/payment/payment_screen.dart - ПОЛНЫЙ ФАЙЛ

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import 'payment_service.dart';
import 'universal_payment_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _currentPaymentId;

  @override
  Widget build(BuildContext context) {
    final double amount = widget.orderData['totalAmount'] ?? 0.0;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Оплата заказа'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(amount),
                    SizedBox(height: 20),
                    _buildPaymentMethod(),
                    SizedBox(height: 20),
                    _buildSecurityInfo(),
                  ],
                ),
              ),
            ),
            _buildPaymentButton(amount, user),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double amount) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'К оплате',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Итого к оплате:'),
                Text(
                  '${amount.toStringAsFixed(0)} ₽',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '💡 Полная оплата заказа. Товары будут готовы к получению после доставки.',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.credit_card, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Способ оплаты',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
                color: Colors.green[50],
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Банковская карта (ЮKassa)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Принимаются карты: МИР, Visa, Mastercard',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.security, color: Colors.blue),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Безопасная оплата',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Платеж проходит через защищенную систему ЮKassa',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(double amount, User? user) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : () => _startPayment(user),
          icon: _isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(Icons.payment, size: 24),
          label: Text(
            _isProcessing
                ? 'Обработка...'
                : 'Оплатить ${amount.toStringAsFixed(0)} ₽',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _startPayment(User? user) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      // Извлекаем данные из orderData
      final items = widget.orderData['items'] as List<Map<String, dynamic>>?;
      final addressId = widget.orderData['addressId'] ?? 1;
      final notes = widget.orderData['notes'] as String?;
      final amount = widget.orderData['totalAmount'] ?? 0.0;

      // Получаем активную партию если есть
      int? batchId;
      try {
        final ordersProvider =
            Provider.of<OrdersProvider>(context, listen: false);
        // Здесь можно получить batchId из контекста или API если нужно
      } catch (e) {
        print('Не удалось получить batchId: $e');
      }

      // Генерируем фейковый orderId как сигнал для бэкенда создать заказ
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fakeOrderId = 'ORDER_$timestamp';

      // Создаем платеж с данными для заказа
      final result = await _paymentService.createPayment(
        amount: amount,
        orderId: fakeOrderId,
        customerPhone: user?.phone ?? '',
        customerName: user?.fullName ?? 'Клиент',
        token: token,
        orderItems: items,
        notes: notes,
        addressId: addressId,
        batchId: batchId,
      );

      if (result.success && result.confirmationUrl != null) {
        // Получаем реальный orderId если заказ был создан
        final realOrderId = result.realOrderId ?? fakeOrderId;

        if (!mounted) return;

        // Показываем диалог подтверждения
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.payment, color: Colors.green),
                SizedBox(width: 8),
                Text('Переход к оплате'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'Сейчас вы будете перенаправлены на защищенную страницу банка для оплаты картой.'),
                SizedBox(height: 16),
                Text(
                  '💳 Принимаются карты: МИР, Visa, Mastercard',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Отмена'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openPaymentWebView(
                    result.confirmationUrl!,
                    result.paymentId!,
                    realOrderId,
                    result.orderCreated,
                  );
                },
                child: Text('Продолжить'),
              ),
            ],
          ),
        );
      } else {
        _showError(result.message ?? 'Ошибка создания платежа');
      }
    } catch (e) {
      _showError('Ошибка: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _openPaymentWebView(String confirmationUrl, String paymentId,
      String orderId, bool orderCreated) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalPaymentScreen(
          paymentUrl: confirmationUrl,
          paymentId: paymentId,
          orderId: orderId,
          orderCreated: orderCreated,
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Ошибка оплаты'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ОК'),
          ),
        ],
      ),
    );
  }
}
