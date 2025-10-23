// lib/screens/payment/universal_payment_screen.dart
// ВЕРСИЯ С ОТКАТОМ НЕОПЛАЧЕННОГО ЗАКАЗА

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import 'package:web/web.dart' as web;
import '../home/home_screen.dart';

class UniversalPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String paymentId;
  final String? orderId;
  final bool orderCreated;
  final Map<String, dynamic>?
      orderData; // ✅ НОВОЕ: Данные для восстановления корзины

  const UniversalPaymentScreen({
    Key? key,
    required this.paymentUrl,
    required this.paymentId,
    this.orderId,
    this.orderCreated = false,
    this.orderData, // ✅ НОВОЕ
  }) : super(key: key);

  @override
  _UniversalPaymentScreenState createState() => _UniversalPaymentScreenState();
}

class _UniversalPaymentScreenState extends State<UniversalPaymentScreen>
    with WidgetsBindingObserver {
  final PaymentService _paymentService = PaymentService();
  Timer? _statusCheckTimer;
  Timer? _autoRollbackTimer; // ✅ НОВОЕ: Таймер автоотмены
  bool _isChecking = false;
  bool _paymentCompleted = false; // ✅ НОВОЕ: Флаг завершения оплаты
  bool _paymentCancelled = false; // ✅ НОВЫЙ флаг
  int _checkAttempts = 0;
  static const int _maxAttempts = 40;
  static const int _autoRollbackMinutes = 2; // ✅ Короче для Web

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handlePayment();
    _startAutoRollbackTimer(); // ✅ НОВОЕ: Запускаем таймер автоотмены
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _statusCheckTimer?.cancel();
    _autoRollbackTimer?.cancel(); // ✅ НОВОЕ
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 Приложение вернулось из фона, проверяем статус платежа');
      // ✅ НОВОЕ: Проверяем статус с небольшой задержкой
      Future.delayed(Duration(seconds: 1), () {
        if (mounted && !_paymentCompleted) {
          _checkPaymentStatusOnResume();
        }
      });
      if (_statusCheckTimer == null || !_statusCheckTimer!.isActive) {
        _startStatusChecking();
      }
    } else if (state == AppLifecycleState.paused) {
      print('⏸️ Приложение ушло в фон');
    }
  }

  Future<void> _handlePayment() async {
    if (!kIsWeb) {
      await _openPaymentInBrowser();
    }
    // ✅ Запускаем автопроверку для ВСЕХ платформ (включая Web)
    _startStatusChecking();
  }

  Future<void> _openPaymentManually() async {
    try {
      // Получаем размеры экрана
      final screenWidth = web.window.screen.width;
      final screenHeight = web.window.screen.height;

      // Адаптивный размер (70% x 80%)
      final popupWidth = (screenWidth * 0.7).round();
      final popupHeight = (screenHeight * 0.8).round();

      // Минимальные размеры
      const minWidth = 400;
      const minHeight = 600;

      final finalWidth = popupWidth < minWidth ? minWidth : popupWidth;
      final finalHeight = popupHeight < minHeight ? minHeight : popupHeight;

      // Центрирование
      final left = ((screenWidth - finalWidth) / 2).round();
      final top = ((screenHeight - finalHeight) / 2).round();

      // Открываем popup
      web.window.open(
        widget.paymentUrl,
        '_blank',
        'width=$finalWidth,height=$finalHeight,left=$left,top=$top,'
            'menubar=no,toolbar=no,location=yes,status=no,resizable=yes,scrollbars=yes',
      );

      print('✅ Popup открыт: ${finalWidth}x${finalHeight} по центру');

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

  // ✅ НОВОЕ: Автоматическая отмена через N минут без активности
  void _startAutoRollbackTimer() {
    // ✅ Для Web 5 минут (даём время webhook/cron), для Mobile 2 минуты
    final rollbackDuration =
        kIsWeb ? Duration(minutes: 5) : Duration(minutes: _autoRollbackMinutes);

    _autoRollbackTimer = Timer(
      rollbackDuration,
      () async {
        // ✅ ДОБАВЛЕН async
        if (!_paymentCompleted && mounted) {
          print(
              '⏰ Время ожидания оплаты истекло, выполняем финальную проверку...');
          await _finalCheckBeforeRollback();
        }
      },
    );
  }

  // ✅ ФИНАЛЬНАЯ ПРОВЕРКА перед откатом
  Future<void> _finalCheckBeforeRollback() async {
    print('🔍 ФИНАЛЬНАЯ ПРОВЕРКА перед откатом заказа...');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final status = await _paymentService.checkPaymentStatus(
        widget.paymentId,
        token: token,
      );

      if (status.isPaid) {
        print('✅ ПЛАТЁЖ ОПЛАЧЕН! Отменяем откат!');
        _paymentCompleted = true;
        _statusCheckTimer?.cancel();
        _autoRollbackTimer?.cancel();
        _handlePaymentSuccess();
        return;
      }

      if (status.isPending) {
        print('⏳ Статус всё ещё PENDING, продлеваем ожидание на 2 минуты...');
        // Продлеваем ожидание
        _autoRollbackTimer = Timer(Duration(minutes: 2), () async {
          if (!_paymentCompleted && mounted) {
            await _finalCheckBeforeRollback(); // Рекурсивная проверка
          }
        });
        return;
      }

      // Статус FAILED или CANCELED
      print('❌ Платёж не оплачен (статус: ${status.status}), откатываем заказ');
    } catch (e) {
      print('❌ Ошибка финальной проверки: $e');
    }

    // Откатываем заказ
    await _handlePaymentCancelled();
  }

  // ✅ СТАРЫЙ метод для совместимости (теперь просто вызывает новый)
  Future<void> _handleAutoRollback() async {
    await _finalCheckBeforeRollback();
  }

  Future<void> _checkPaymentStatus() async {
    if (_isChecking || _paymentCompleted) return;

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
        _paymentCompleted = true; // ✅ Помечаем как завершенный
        _statusCheckTimer?.cancel();
        // ✅ Показываем диалог успеха если пользователь вернулся на эту вкладку
        if (kIsWeb) {
          _showPaymentSuccessDialog();
        } else {
          _handlePaymentSuccess();
        }
      } else if (status.isCanceled) {
        _statusCheckTimer?.cancel();
        await _handlePaymentCancelled();
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

  // ✅ НОВОЕ: Диалог успеха для Web (когда статус обновился на вкладке A)
  void _showPaymentSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              'Оплата успешна!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Ваш заказ #${widget.orderId ?? "..."} оплачен\nи принят в обработку.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Закрыть диалог
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen(initialIndex: 2), // ✅ index 2 = Orders tab
                ),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('Перейти к заказам'),
          ),
        ],
      ),
    );
  }

  // ✅ НОВОЕ: Проверка статуса при возврате из фона с показом диалога
  Future<void> _checkPaymentStatusOnResume() async {
    if (_paymentCompleted) return;

    print('🔍 Проверяем статус после возврата из браузера...');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final status = await _paymentService.checkPaymentStatus(
        widget.paymentId,
        token: token,
      );

      if (!mounted) return;

      if (status.isPaid) {
        _paymentCompleted = true;
        _statusCheckTimer?.cancel();
        _autoRollbackTimer?.cancel(); // ✅ ДОБАВЛЕНО: отменяем таймер автоотмены
        _handlePaymentSuccess();
      } else if (status.isCanceled) {
        _statusCheckTimer?.cancel();
        _autoRollbackTimer?.cancel(); // ✅ ДОБАВЛЕНО
        await _handlePaymentCancelled();
      } else if (status.isPending) {
        // // ✅ ВАЖНО: Если платеж все еще pending, спрашиваем пользователя
        // _showPaymentStatusDialog();
        print(
            '⏳ Платеж в статусе PENDING, продолжаем автоматическую проверку...');
        print(
            '⏱️ Заказ будет автоматически отменён через 2 минуты если оплата не пройдёт');
        // Таймер автоотмены (_autoRollbackTimer) сам отменит заказ если статус не изменится
      }
    } catch (e) {
      print('❌ Ошибка проверки статуса при возврате: $e');
    }
  }

  // // ✅ НОВОЕ: Диалог для уточнения статуса оплаты
  // void _showPaymentStatusDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: Row(
  //         children: [
  //           Icon(Icons.help_outline, color: Colors.blue),
  //           SizedBox(width: 8),
  //           Text('Статус оплаты'),
  //         ],
  //       ),
  //       content: Text(
  //         'Вы завершили оплату?\n\nЕсли оплата прошла успешно, мы скоро получим подтверждение. Если вы закрыли окно оплаты, заказ будет отменен.',
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // Пользователь закрыл окно - отменяем
  //             _handlePaymentCancelled();
  //           },
  //           child: Text('Я не оплатил, отменить'),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(context);
  //             // Продолжаем проверку статуса
  //             print('⏳ Продолжаем ожидание подтверждения оплаты...');
  //           },
  //           child: Text('Я оплатил, ждать'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _handlePaymentSuccess() async {
    print('✅ Платеж успешно завершен!');

    // Останавливаем все таймеры
    _statusCheckTimer?.cancel();
    _autoRollbackTimer?.cancel();

    // ✅ Корзина уже очищена в checkout_screen, просто обновляем заказы
    // (Но можно оставить для надежности, clearCart() безопасен для пустой корзины)
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart();

    // Обновляем список заказов
    final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
    await ordersProvider.loadOrders();

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
                'Ваш заказ принят в обработку и будет доставлен в указанные сроки.',
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
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

  // ✅ НОВАЯ ЛОГИКА: Откат неоплаченного заказа
  Future<void> _handlePaymentCancelled() async {
    // ✅ ЗАЩИТА ОТ ПОВТОРНОГО ВЫЗОВА
    if (_paymentCancelled) {
      print('⚠️ Отмена уже выполняется, пропускаем');
      return;
    }

    _paymentCancelled = true; // ✅ Устанавливаем флаг
    print('❌ Платеж отменен или не завершен');

    // Останавливаем все таймеры
    _statusCheckTimer?.cancel();
    _autoRollbackTimer?.cancel(); // ✅ НОВОЕ

    // 1. Удаляем заказ с backend (если он был создан)
    if (widget.orderId != null && widget.orderCreated) {
      await _deleteUnpaidOrder(widget.orderId!);
    }

    // 2. Восстанавливаем товары в корзину
    if (widget.orderData != null) {
      await _restoreCartItems();
    }

    if (mounted) {
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0), // ← НОВОЕ
          actionsPadding: EdgeInsets.only(right: 16, bottom: 8), // ← НОВОЕ
          title: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 8),
              Flexible(
                // ← НОВОЕ: предотвращает переполнение
                child: Text('Оплата не завершена'),
              ),
            ],
          ),
          content: ConstrainedBox(
            // ← НОВОЕ: ограничиваем ширину
            constraints: BoxConstraints(maxWidth: 280),
            child: Text(
              'Заказ не был оплачен. Товары возвращены в корзину.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('ОК'),
            ),
          ],
        ),
      );
    }
  }

  // ✅ НОВОЕ: Удаление неоплаченного заказа через API
  Future<void> _deleteUnpaidOrder(String orderId) async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      print('🗑️ Удаляем неоплаченный заказ #$orderId');

      final response = await http.delete(
        Uri.parse('https://api.sevkorzina.ru/api/orders/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Заказ #$orderId успешно удален');
      } else {
        print('⚠️ Ошибка удаления заказа: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Ошибка при удалении заказа: $e');
    }
  }

  // ✅ НОВОЕ: Восстановление товаров в корзину
  Future<void> _restoreCartItems() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final items = widget.orderData!['items'] as List<Map<String, dynamic>>?;

      if (items != null && items.isNotEmpty) {
        print('🔄 Восстанавливаем ${items.length} товаров в корзину');

        for (var item in items) {
          final productId = item['productId'] as int;
          final quantity = item['quantity'] as int;

          // ✅ ИСПРАВЛЕНО: Безопасное преобразование price
          final priceValue = item['price'];
          final price = priceValue is double
              ? priceValue
              : (priceValue is int
                  ? priceValue.toDouble()
                  : double.parse(priceValue.toString()));

          final name = item['name'] as String? ?? 'Товар #$productId';
          final unit = item['unit'] as String? ?? 'шт';

          cartProvider.addItem(
            productId: productId,
            name: name,
            price: price,
            unit: unit,
            quantity: quantity,
          );
        }

        print('✅ Товары восстановлены в корзину (${items.length} позиций)');
      }
    } catch (e) {
      print('❌ Ошибка восстановления корзины: $e');
      print('❌ Детали ошибки: $e');
    }
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
            onPressed: () async {
              Navigator.pop(context);
              // При тайм-ауте тоже откатываем заказ
              await _handlePaymentCancelled();
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

  // ✅ НОВОЕ: Обработка кнопки "Назад"
  Future<bool> _onWillPop() async {
    // Если платеж завершен - разрешаем выход
    if (_paymentCompleted) {
      return true;
    }

    // Иначе показываем диалог подтверждения
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Отменить оплату?'),
        content: Text(
          'Вы уверены, что хотите отменить оплату? Заказ будет удален, а товары вернутся в корзину.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Продолжить оплату'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text('Отменить'),
          ),
        ],
      ),
    );

    if (shouldPop == true) {
      await _handlePaymentCancelled();
    }

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // ✅ Обработка кнопки "Назад"
      child: Scaffold(
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
                      ? 'Нажмите кнопку ниже.\nPopup окно откроется по центру экрана.'
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
                if (kIsWeb && !_isChecking) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _openPaymentManually,
                      icon: Icon(Icons.open_in_new, size: 24),
                      label: Text(
                        'Открыть форму оплаты',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
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

                  // // ===== ДОБАВИТЬ ЭТИ СТРОКИ =====
                  // SizedBox(height: 16),
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 56,
                  //   child: ElevatedButton.icon(
                  //     onPressed: () async {
                  //       setState(() {
                  //         _isChecking = true;
                  //       });

                  //       await Future.delayed(Duration(seconds: 1));
                  //       await _checkPaymentStatus();

                  //       if (mounted) {
                  //         setState(() {
                  //           _isChecking = false;
                  //         });
                  //       }
                  //     },
                  //     icon: Icon(Icons.check_circle_outline, size: 24),
                  //     label: Text(
                  //       'Я завершил оплату',
                  //       style: TextStyle(
                  //         fontSize: 18,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.blue,
                  //       foregroundColor: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // // ===== КОНЕЦ ДОБАВЛЕНИЯ =====

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
                        onPressed: () async {
                          _statusCheckTimer?.cancel();
                          await _handlePaymentCancelled();
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
      ),
    );
  }
}
