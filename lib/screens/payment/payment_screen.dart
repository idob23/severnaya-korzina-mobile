// lib/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import 'payment_service.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _currentPaymentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Оплата заказа'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
          final user = authProvider.currentUser;
          final total = cartProvider.totalAmount;
          final prepayment = total * 0.9;
          final remaining = total * 0.1;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Информация о заказе
                      _buildOrderSummary(
                          cartProvider, total, prepayment, remaining),
                      SizedBox(height: 16),

                      // Информация о пользователе
                      _buildUserInfo(user),
                      SizedBox(height: 16),

                      // Выбор способа оплаты
                      _buildPaymentMethods(),
                    ],
                  ),
                ),
              ),

              // Кнопка оплаты
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed:
                      _isProcessing ? null : () => _startPayment(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Обработка...'),
                          ],
                        )
                      : Text(
                          'Оплатить ${prepayment.toStringAsFixed(0)} ₽',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider, double total,
      double prepayment, double remaining) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Детали заказа',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            // Список товаров - ИСПРАВЛЕНО
            ...cartProvider.itemsList.map((item) => Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text('${item.name} x${item.quantity}'),
                      ),
                      Text(
                          '${(item.price * item.quantity).toStringAsFixed(0)} ₽'),
                    ],
                  ),
                )),

            Divider(),

            // Общая стоимость
            Row(
              children: [
                Expanded(child: Text('Общая стоимость:')),
                Text(
                  '${total.toStringAsFixed(0)} ₽',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 8),

            // Предоплата
            Row(
              children: [
                Expanded(child: Text('Предоплата (90%):')),
                Text(
                  '${prepayment.toStringAsFixed(0)} ₽',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Доплата при получении
            Row(
              children: [
                Expanded(child: Text('Доплата при получении:')),
                Text(
                  '${remaining.toStringAsFixed(0)} ₽',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(user) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Контактная информация',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            _buildInfoRow(Icons.person, user?.fullName ?? 'Не указано'),
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

  Widget _buildPaymentMethods() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Способ оплаты',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.blue),
              title: Text('Банковская карта МИР'),
              subtitle: Text('Безопасная оплата через ЮKassa'),
              trailing: Radio<String>(
                value: 'card',
                groupValue: 'card',
                onChanged: (value) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startPayment(BuildContext context) async {
    if (!mounted) return;

    setState(() => _isProcessing = true);

    try {
      // Безопасное получение провайдеров
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final user = authProvider.currentUser;
      final total = cartProvider.totalAmount;
      final prepayment = total * 0.9;

      print('💳 Начинаем процесс оплаты...');
      print('Сумма к оплате: ${prepayment.toStringAsFixed(2)} ₽');

      // Создаем платеж через ЮKassa - ИСПРАВЛЕНО
      final result = await _paymentService.createMirPayment(
        amount: prepayment,
        orderId: 'ORDER_${DateTime.now().millisecondsSinceEpoch}',
        customerPhone: user?.phone ?? '',
        customerName: user?.fullName ?? '',
      );

      if (!mounted) return;

      if (result.success && result.confirmationUrl != null) {
        _currentPaymentId = result.paymentId;

        // Открываем платежную форму
        final opened =
            await _paymentService.openPaymentForm(result.confirmationUrl!);

        if (opened) {
          // Показываем диалог ожидания
          if (result.paymentId != null) {
            _showPaymentPendingDialog(result.paymentId!);
          }
        } else {
          _showError('Не удается открыть платежную форму');
        }
      } else {
        _showError(result.message);
      }
    } catch (e) {
      print('❌ Ошибка создания платежа: $e');
      _showError('Ошибка создания платежа: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showPaymentPendingDialog(String paymentId) {
    if (!mounted) return;

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
                'Завершите оплату в открывшемся окне браузера и нажмите "Проверить оплату"'),
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
              _checkPaymentStatus(paymentId);
            },
            child: Text('Проверить оплату'),
          ),
        ],
      ),
    );
  }

  Future<void> _checkPaymentStatus(String paymentId) async {
    if (!mounted) return;

    try {
      print('🔍 Проверяем статус платежа...');

      final status = await _paymentService.checkPaymentStatus(paymentId);

      if (!mounted) return;

      if (status.isPaid) {
        print('✅ Платеж успешно завершен!');
        _showPaymentSuccess(paymentId, status.amount);
      } else if (status.isCanceled) {
        _showError('Платеж был отменен');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Платеж еще обрабатывается. Статус: ${status.status}'),
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
      // Безопасное получение провайдера
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            orderId: paymentId,
            amount: amount,
            paymentMethod: 'Карта МИР',
          ),
        ),
      );

      // Очищаем корзину - ИСПРАВЛЕНО
      cartProvider.clearCart();
    } catch (e) {
      print('❌ Ошибка при переходе к экрану успеха: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ошибка оплаты'),
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
