// lib/screens/payment/payment_checking_web_screen.dart
// Экран для Web после успешной оплаты (открывается в popup/новой вкладке)

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class PaymentCheckingWebScreen extends StatefulWidget {
  @override
  _PaymentCheckingWebScreenState createState() =>
      _PaymentCheckingWebScreenState();
}

class _PaymentCheckingWebScreenState extends State<PaymentCheckingWebScreen> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
          _closeOrNavigate();
        }
      });
    });
  }

  void _closeOrNavigate() {
    if (kIsWeb) {
      try {
        // Пытаемся закрыть окно (работает если открыто через window.open)
        html.window.close();

        // Если не получилось закрыть, переходим на страницу заказов
        Future.delayed(Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/orders',
              (route) => false,
            );
          }
        });
      } catch (e) {
        print('Ошибка закрытия окна: $e');
        // Если не получилось, просто переходим на заказы
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/orders',
          (route) => false,
        );
      }
    } else {
      // На мобильных просто переходим на заказы
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/orders',
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade400, Colors.green.shade700],
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимированная галочка
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 600),
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 120,
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),

                // Заголовок
                Text(
                  'Оплата успешна!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),

                // Подзаголовок
                Text(
                  'Ваш заказ принят в обработку.',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Вы получите уведомление когда товары будут готовы к получению.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),

                // Обратный отсчёт
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        _countdown > 0
                            ? 'Автоматический переход через $_countdown...'
                            : 'Перенаправление...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

                // Кнопка ручного перехода
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _timer?.cancel();
                      _closeOrNavigate();
                    },
                    icon: Icon(Icons.list_alt, size: 24),
                    label: Text(
                      'Посмотреть мои заказы',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
