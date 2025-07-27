// lib/screens/payment/payment_screen.dart - ФИНАЛЬНАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/models/user.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import 'payment_service.dart';
import 'payment_success_screen.dart';

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
    final prepaymentAmount = widget.orderData['prepaymentAmount'] as double;
    final totalAmount = widget.orderData['totalAmount'] as double;
    final remainingAmount = totalAmount - prepaymentAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Оплата заказа'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user =
              authProvider.currentUser; // ИСПРАВЛЕНО: currentUser вместо user

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Информация о заказе
                _buildOrderInfo(),

                SizedBox(height: 20),

                // Информация о покупателе
                _buildCustomerInfo(user),

                SizedBox(height: 20),

                // Способ оплаты
                _buildPaymentMethod(),

                SizedBox(height: 20),

                // Сумма к оплате
                _buildPaymentSummary(prepaymentAmount, remainingAmount),

                SizedBox(height: 20),

                // Тестовые карты (только в debug режиме)
                if (PaymentService.isTestMode()) _buildTestCards(),

                SizedBox(height: 30),

                // Кнопка оплаты
                _buildPaymentButton(prepaymentAmount, user),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInfo() {
    final items = widget.orderData['items'] as List;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Детали заказа',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Text('📍 ${widget.orderData['address']}'),
            SizedBox(height: 4),
            Text('🕐 ${widget.orderData['deliveryTime']}'),
            SizedBox(height: 4),
            Text('📦 Товаров: ${items.length} наименований'),
            if (widget.orderData['notes'] != null) ...[
              SizedBox(height: 4),
              Text('💬 ${widget.orderData['notes']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfo(User? user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Покупатель',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.person, user?.name ?? 'Не указано'),
            _buildInfoRow(Icons.phone, user?.phone ?? 'Не указан'),
            if (user?.email != null) _buildInfoRow(Icons.email, user!.email!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(text),
        ],
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue[50],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/mir_logo.png',
                    width: 40,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
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
                      );
                    },
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

  Widget _buildPaymentSummary(double prepaymentAmount, double remainingAmount) {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'К оплате сейчас',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Предоплата (90%):'),
                Text(
                  '${prepaymentAmount.toStringAsFixed(0)} ₽',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Доплата при получении:',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '${remainingAmount.toStringAsFixed(0)} ₽',
                  style: TextStyle(color: Colors.grey[600]),
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
                '💡 Это предоплата. Остальную сумму доплачиваете при получении товара в пункте выдачи.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[800],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestCards() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Тестовый режим',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Используйте тестовые карты:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 8),
            ...PaymentService.getTestCards().entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('• ${entry.key}: '),
                    SelectableText(
                      entry.value,
                      style: TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 8),
            Text(
              'CVV: любой трёхзначный код\nСрок: любая будущая дата',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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
                    strokeWidth: 2, color: Colors.white),
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
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      print('💳 Начинаем процесс оплаты...');
      print('Сумма к оплате: ${amount.toStringAsFixed(2)} ₽');

      // Генерируем уникальный ID заказа
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      // Создаем платеж через ЮKassa
      final result = await _paymentService.createMirPayment(
        amount: amount,
        orderId: orderId,
        customerPhone: user?.phone ?? '',
        customerName: user?.name ?? '',
      );

      if (!mounted) return;

      if (result.success && result.confirmationUrl != null) {
        _currentPaymentId = result.paymentId;

        // Показываем диалог с информацией
        _showPaymentDialog(result.confirmationUrl!, result.paymentId!);
      } else {
        _showError(result.message ?? 'Ошибка создания платежа');
      }
    } catch (e) {
      print('❌ Ошибка платежа: $e');
      _showError('Ошибка подключения к платежной системе');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
              'Сейчас откроется страница оплаты ЮKassa.\n\nПосле успешной оплаты вернитесь в приложение.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Возвращаемся к корзине
            },
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Открываем платежную форму
              final opened =
                  await _paymentService.openPaymentForm(confirmationUrl);

              if (opened) {
                // Показываем диалог ожидания результата
                _showPaymentPendingDialog(paymentId);
              } else {
                _showError('Не удалось открыть страницу оплаты');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: Text('Перейти к оплате'),
          ),
        ],
      ),
    );
  }

  void _showPaymentPendingDialog(String paymentId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Ожидание оплаты'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Ожидаем подтверждение оплаты...\n\nЭто может занять несколько минут.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _checkPaymentStatus(paymentId),
            child: Text('Проверить статус'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // Возвращаемся к корзине
            },
            child: Text('Отмена'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus(String paymentId) async {
    try {
      print('🔍 Проверяем статус платежа: $paymentId');

      final status = await _paymentService.checkPaymentStatus(paymentId);

      if (!mounted) return;

      Navigator.pop(context); // Закрываем диалог ожидания

      if (status.isPaid) {
        print('✅ Платеж успешно завершен');
        _showPaymentSuccess(paymentId, status.amount);
      } else if (status.isCanceled) {
        _showError('Платеж был отменен');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Платеж еще обрабатывается. Статус: ${status.status}'),
            action: SnackBarAction(
              label: 'Проверить снова',
              onPressed: () => _checkPaymentStatus(paymentId),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Ошибка проверки статуса: $e');
      _showError('Ошибка проверки статуса: $e');
    }
  }

  void _showPaymentSuccess(String paymentId, double amount) {
    if (!mounted) return;

    try {
      // Создаем заказ в системе
      _createOrderInSystem(paymentId);

      // Переходим к экрану успеха
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            orderId: paymentId,
            amount: amount,
            paymentMethod: 'Карта МИР',
            orderData: widget.orderData,
          ),
        ),
      );

      // Очищаем корзину
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();
    } catch (e) {
      print('❌ Ошибка при переходе к экрану успеха: $e');
    }
  }

  Future<void> _createOrderInSystem(String paymentId) async {
    try {
      final ordersProvider =
          Provider.of<OrdersProvider>(context, listen: false);

      // Создаем заказ в нашей системе
      await ordersProvider.createOrder(
        addressId: 1, // ID адреса пункта выдачи
        items: widget.orderData['items'] as List<Map<String, dynamic>>,
        notes:
            'Платеж ID: $paymentId\nВремя получения: ${widget.orderData['deliveryTime']}\n${widget.orderData['notes'] ?? ''}',
      );

      print('✅ Заказ создан в системе');
    } catch (e) {
      print('❌ Ошибка создания заказа в системе: $e');
      // Не показываем ошибку пользователю, так как платеж прошел успешно
    }
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
