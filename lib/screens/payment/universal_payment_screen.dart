// lib/screens/payment/universal_payment_screen.dart - ПОЛНЫЙ ФАЙЛ

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'payment_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';

class UniversalPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentId;
  final String? orderId;
  final bool orderCreated;

  const UniversalPaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.paymentId,
    this.orderId,
    this.orderCreated = false,
  }) : super(key: key);

  @override
  _UniversalPaymentScreenState createState() => _UniversalPaymentScreenState();
}

class _UniversalPaymentScreenState extends State<UniversalPaymentScreen>
    with WidgetsBindingObserver {
  final PaymentService _paymentService = PaymentService();
  Timer? _statusCheckTimer;
  bool _isChecking = false;
  int _checkAttempts = 0;
  static const int _maxAttempts = 40; // 2 минуты проверки (каждые 3 секунды)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handlePayment();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  // Обработка возврата из фона (для iOS)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 Приложение вернулось из фона, проверяем статус платежа');
      // Сразу проверяем статус при возврате
      _checkPaymentStatus();
      // Перезапускаем таймер если он был остановлен
      if (_statusCheckTimer == null || !_statusCheckTimer!.isActive) {
        _startStatusChecking();
      }
    } else if (state == AppLifecycleState.paused) {
      print('⏸️ Приложение ушло в фон');
    }
  }

  Future<void> _handlePayment() async {
    if (!kIsWeb) {
      // Для мобильных платформ открываем во внешнем браузере
      await _openPaymentInBrowser();
      // Начинаем проверку статуса
      _startStatusChecking();
    }
    // Для веб-версии показываем кнопку в UI
  }

  Future<void> _openPaymentManually() async {
    try {
      await launchUrl(
        Uri.parse(widget.paymentUrl),
        mode: LaunchMode.externalApplication,
      );
      _startStatusChecking();
    } catch (e) {
      print('❌ Ошибка открытия платежа: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть форму оплаты'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Попробовать снова',
              textColor: Colors.white,
              onPressed: _openPaymentManually,
            ),
          ),
        );
      }
    }
  }

  Future<void> _openPaymentInBrowser() async {
    if (await canLaunchUrl(Uri.parse(widget.paymentUrl))) {
      await launchUrl(
        Uri.parse(widget.paymentUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _startStatusChecking() {
    _statusCheckTimer?.cancel();
    _checkAttempts = 0;

    _statusCheckTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_checkAttempts >= _maxAttempts) {
        timer.cancel();
        _showTimeoutDialog();
        return;
      }

      _checkPaymentStatus();
      _checkAttempts++;
    });
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final status = await _paymentService.checkPaymentStatus(
        widget.paymentId,
        token: token,
      );

      if (!mounted) return;

      if (status.isPaid) {
        _statusCheckTimer?.cancel();
        _handlePaymentSuccess();
      } else if (status.isCanceled) {
        _statusCheckTimer?.cancel();
        _handlePaymentCancelled();
      }
    } catch (e) {
      print('Ошибка проверки статуса: $e');
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _handlePaymentSuccess() async {
    // Очищаем корзину
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart();
    print('✅ Корзина очищена после успешной оплаты');

    // Обновляем список заказов
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    await ordersProvider.loadOrders();
    print('✅ Список заказов обновлен');

    // Показываем диалог успеха и возвращаемся в каталог
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Оплата успешна!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.orderId != null)
                Text('Заказ #${widget.orderId} успешно оплачен'),
              SizedBox(height: 8),
              Text(
                  'Ваш заказ принят в обработку и будет доставлен в указанные сроки.'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Возвращаемся на главный экран
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: Text('В каталог'),
            ),
          ],
        ),
      );
    }
  }

  void _handlePaymentCancelled() {
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.orange),
            SizedBox(width: 8),
            Text('Платеж отменен'),
          ],
        ),
        content: Text('Платеж был отменен пользователем.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('ОК'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Проверка статуса'),
        content: Text(
          'Не удалось автоматически определить статус платежа.\n\nПроверьте SMS от банка или свяжитесь с поддержкой.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Вернуться'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _checkAttempts = 0;
              _startStatusChecking();
            },
            child: Text('Проверить еще раз'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Оплата заказа'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.payment,
                size: 80,
                color: Colors.green,
              ),
              SizedBox(height: 32),
              Text(
                kIsWeb ? 'Готово к оплате' : 'Ожидание оплаты',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                kIsWeb
                    ? 'Нажмите кнопку ниже для открытия формы оплаты.\nПосле оплаты вернитесь в приложение.'
                    : 'Завершите оплату в браузере.\nМы автоматически отследим результат.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              if (widget.orderId != null) ...[
                SizedBox(height: 8),
                Text(
                  'Заказ #${widget.orderId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
              SizedBox(height: 32),

              // Кнопка открытия оплаты - только для веб
              if (kIsWeb && !_isChecking) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _openPaymentManually,
                    icon: Icon(Icons.open_in_new, size: 24),
                    label: Text(
                      'Открыть форму оплаты',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                SizedBox(height: 24),
              ],

              if (_isChecking) ...[
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 16),
                Text(
                  'Проверяем статус платежа...',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 16),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _statusCheckTimer?.cancel();
                        Navigator.pop(context);
                      },
                      child: Text('Отменить'),
                    ),
                  ),
                  if (!kIsWeb && !_isChecking) ...[
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _checkPaymentStatus,
                        child: Text('Проверить статус'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
