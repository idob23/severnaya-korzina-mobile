// lib/screens/payment/payment_screen.dart
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
                style: TextStyle(fontSize: 12, color: Colors.green[800]),
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
            Text(
              'Способ оплаты',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        'МИР',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Банковская карта МИР',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Безопасная оплата через ЮKassa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.security, color: Colors.green),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.security, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Оплата защищена SSL-шифрованием. Данные карты не сохраняются.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentButton(double amount, User? user) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : () => _startPayment(amount, user),
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
              ? 'Подготовка платежа...'
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
    );
  }

  Future<void> _startPayment(double amount, User? user) async {
    setState(() => _isProcessing = true);

    try {
      // ПОЛУЧАЕМ ТОКЕН ИЗ AuthProvider:
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';
      final result = await _paymentService.createPayment(
        amount: amount,
        orderId: orderId,
        customerPhone: user?.phone ?? '',
        customerName: user?.name ?? '',
        token: token, // ПЕРЕДАЕМ ТОКЕН
        orderItems: widget.orderData['items'], // ДОБАВИТЬ
        notes: widget.orderData['notes'], // ДОБАВИТЬ
      );

      if (!mounted) return;

      if (result.success && result.confirmationUrl != null) {
        _currentPaymentId = result.paymentId;
        _showPaymentDialog(result.confirmationUrl!, result.paymentId!);
      } else {
        _showError(result.message ?? 'Ошибка создания платежа');
      }
    } catch (e) {
      _showError('Ошибка подключения к платежной системе');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showPaymentDialog(String confirmationUrl, String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Переход к оплате'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.payment, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Сейчас откроется форма оплаты.\n\nВведите данные карты для завершения покупки.',
              textAlign: TextAlign.center,
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
              _openPaymentWebView(confirmationUrl, paymentId);
            },
            child: Text('Продолжить'),
          ),
        ],
      ),
    );
  }

  void _openPaymentWebView(String confirmationUrl, String paymentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UniversalPaymentScreen(
          paymentUrl: confirmationUrl,
          paymentId: paymentId,
          orderData: widget.orderData, // ДОБАВИТЬ
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
