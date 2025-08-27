// lib/screens/payment/payment_success_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../orders/orders_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Map<String, dynamic>? orderData; // ДОБАВИТЬ

  const PaymentSuccessScreen({Key? key, this.orderData}) : super(key: key);

  @override
  _PaymentSuccessScreenState createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  bool _isCreatingOrder = true;
  String _status = 'Создание заказа...';

  @override
  void initState() {
    super.initState();
    _handlePaymentSuccess();
  }

  Future<void> _handlePaymentSuccess() async {
    try {
      // Очищаем корзину
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();

      // Откладываем создание заказа до завершения build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _createOrderInSystem();
      });
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            _status = 'Ошибка создания заказа: $e';
            _isCreatingOrder = false;
          });
        });
      }
    }
  }

  Future<void> _createOrderInSystem() async {
    print('🔔 PaymentSuccessScreen: Начинаем создание заказа');
    print('🔔 OrderData: ${widget.orderData}');

    if (widget.orderData == null) {
      setState(() {
        _status = 'Заказ создан автоматически';
        _isCreatingOrder = false;
      });
      return;
    }

    setState(() => _status = 'Создание заказа...');

    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);

    print('🔔 Вызываем ordersProvider.createOrder');

    // Минимальные данные для создания заказа
    final orderItems =
        widget.orderData!['items'] as List<Map<String, dynamic>>? ?? [];
    final notes = widget.orderData!['notes'] as String?;

    final success = await ordersProvider.createOrder(
      addressId: 1, // пока захардкодим
      items: orderItems,
      notes: notes ?? 'Заказ оплачен и создан автоматически',
    );

    print('🔔 Результат createOrder: $success');

    setState(() {
      if (success) {
        _status = 'Заказ успешно создан!';
      } else {
        _status = 'Ошибка создания заказа';
      }
      _isCreatingOrder = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Оплата завершена'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 80,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 32),
              Text(
                'Платеж успешно выполнен!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Ваш заказ принят в обработку.\nВы получите уведомление о готовности товаров к получению.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                    (route) => false,
                  ),
                  icon: Icon(Icons.home, size: 24),
                  label: Text(
                    'Вернуться в каталог',
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
              SizedBox(height: 16),
              // TextButton(
              //   onPressed: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => OrdersScreen(),
              //       ),
              //     );
              //   },
              //   child: Text(
              //     'Посмотреть мои заказы',
              //     style: TextStyle(
              //       fontSize: 16,
              //       color: Colors.green[700],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
