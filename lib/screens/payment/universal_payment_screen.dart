// lib/screens/payment/universal_payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'payment_service.dart';
import 'payment_success_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:web/web.dart' as web;

class UniversalPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentId;
  final Map<String, dynamic>? orderData; // ДОБАВИТЬ

  const UniversalPaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.paymentId,
    this.orderData, // ДОБАВИТЬ
  }) : super(key: key);

  @override
  _UniversalPaymentScreenState createState() => _UniversalPaymentScreenState();
}

class _UniversalPaymentScreenState extends State<UniversalPaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  Timer? _statusCheckTimer;
  bool _isChecking = false;
  int _checkAttempts = 0;
  static const int _maxAttempts = 24; // 2 минуты проверки (каждые 5 секунд)

  @override
  void initState() {
    super.initState();
    _handlePayment();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _handlePayment() async {
    if (!kIsWeb) {
      // Для мобильных платформ открываем во внешнем браузере
      await _openPaymentInBrowser();
      // Начинаем проверку статуса
      _startStatusChecking();
    }
    // Для веб-версии НЕ открываем автоматически - покажем кнопку в UI
  }
  // ДОБАВИТЬ НОВЫЙ МЕТОД:

  Future<void> _openPaymentManually() async {
    try {
      if (kIsWeb) {
        // Для веб - используем url_launcher без попытки popup
        await launchUrl(
          Uri.parse(widget.paymentUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        await launchUrl(
          Uri.parse(widget.paymentUrl),
          mode: LaunchMode.externalApplication,
        );
      }

      // Начинаем проверку статуса только после клика пользователя
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

  Future<void> _openPaymentInCurrentWindow() async {
    try {
      if (kIsWeb) {
        // Для веб-версии используем современный package:web
        web.window.open(widget.paymentUrl, '_blank');
        print('✅ Ссылка на оплату открыта через web.window.open');
      } else {
        // Для других платформ используем стандартный подход
        if (await canLaunchUrl(Uri.parse(widget.paymentUrl))) {
          await launchUrl(
            Uri.parse(widget.paymentUrl),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    } catch (e) {
      print('❌ Ошибка открытия платежа: $e');

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Проблема с оплатой'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Не удалось автоматически открыть форму оплаты.'),
                SizedBox(height: 12),
                Text('Способы решения:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('• Разрешите всплывающие окна для этого сайта'),
                Text('• Или нажмите кнопку ниже для ручного открытия'),
                SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Попробовать открыть через url_launcher как fallback
                    launchUrl(
                      Uri.parse(widget.paymentUrl),
                      mode: LaunchMode.platformDefault,
                    );
                  },
                  child: Text('Открыть оплату'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Закрыть диалог
                  Navigator.pop(context); // Вернуться назад
                },
                child: Text('Отмена'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _openPaymentInBrowser() async {
    // Для мобильных устройств открываем внешний браузер
    if (await canLaunchUrl(Uri.parse(widget.paymentUrl))) {
      await launchUrl(
        Uri.parse(widget.paymentUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _startStatusChecking() {
    _statusCheckTimer = Timer.periodic(Duration(seconds: 5), (timer) {
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
      // ПОЛУЧАЕМ ТОКЕН ИЗ AuthProvider:
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final status = await _paymentService.checkPaymentStatus(
        widget.paymentId,
        token: token, // ПЕРЕДАЕМ ТОКЕН
      );

      if (!mounted) return;

      if (status.isPaid) {
        _statusCheckTimer?.cancel();
        _handlePaymentSuccess();
      } else if (status.isCanceled) {
        _statusCheckTimer?.cancel();
        _handlePaymentCancelled();
      }
      // Если pending - продолжаем проверку
    } catch (e) {
      // Ошибки игнорируем и продолжаем проверку
      print('Ошибка проверки статуса: $e');
    }

    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _handlePaymentSuccess() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentSuccessScreen(
          orderData: widget.orderData, // ПЕРЕДАТЬ orderData
        ),
      ),
    );
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
              Navigator.pop(context); // Закрыть диалог
              Navigator.pop(context); // Вернуться назад
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
              SizedBox(height: 32),

              // КНОПКА ОТКРЫТИЯ ОПЛАТЫ - ТОЛЬКО ДЛЯ ВЕБ
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
                  if (_isChecking) ...[
                    SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _checkPaymentStatus,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Проверить статус'),
                      ),
                    ),
                  ],
                ],
              ),

              if (!kIsWeb) ...[
                SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    await launchUrl(
                      Uri.parse(widget.paymentUrl),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Text(
                    'Открыть оплату заново',
                    style: TextStyle(color: Colors.green[700]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
