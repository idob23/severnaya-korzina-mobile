// lib/screens/payment/payment_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
// УБРАНО ДВОЙНОЕ СОЗДАНИЕ ЗАКАЗА

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import 'payment_service.dart';
// import 'universal_payment_screen.dart';
import 'universal_payment_export.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentScreen({Key? key, required this.orderData}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _currentPaymentId;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double amount = widget.orderData['totalAmount'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Оплата заказа'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryLight.withOpacity(0.05),
                  Colors.white,
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: AppGradients.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryLight.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.payment_rounded,
                        size: 70,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 40),
                    Text(
                      'Сумма к оплате',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      '${amount.toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = AppGradients.primary.createShader(
                            Rect.fromLTWH(0, 0, 200, 70),
                          ),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Оплата через Точка Банк',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPaymentBadge('СБП'),
                        SizedBox(width: 12),
                        _buildPaymentBadge('Банковская карта'),
                      ],
                    ),
                    SizedBox(height: 48),
                    _buildPaymentButton(amount),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.primaryLight,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentButton(double amount) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;

        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: _isProcessing ? null : AppGradients.primary,
            color: _isProcessing ? Colors.grey[300] : null,
            boxShadow: _isProcessing
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _isProcessing
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      _startPayment(user);
                    },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isProcessing)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    else ...[
                      Icon(
                        Icons.payment_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12),
                    ],
                    Text(
                      _isProcessing
                          ? 'Обработка...'
                          : 'Оплатить ${amount.toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ ИСПРАВЛЕННАЯ ЛОГИКА: НЕ СОЗДАЕМ ЗАКАЗ ПОВТОРНО!
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

      // Получаем активную партию из API
      int? activeBatchId;
      try {
        final response = await http.get(
          // Uri.parse('http://84.201.149.245:3000/api/batches/active'),
          Uri.parse('https://api.sevkorzina.ru/api/batches/active'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          activeBatchId = data['batch']?['id'];
        }
      } catch (e) {
        print('⚠️ Ошибка получения активной партии: $e');
      }

      // ✅ ГЛАВНОЕ ИСПРАВЛЕНИЕ:
      // Передаем orderId с префиксом ORDER_ + данные для создания заказа
      // Backend сам создаст заказ ОДИН РАЗ в payments.js
      final orderId = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      print('📦 Создаем платеж с orderId: $orderId');
      print('📦 Items для создания заказа: ${items?.length ?? 0}');

      // Создаем платеж, передавая ВСЕ данные для создания заказа
      final paymentResult = await _paymentService.createPayment(
        amount: amount,
        orderId: orderId, // ✅ ORDER_ префикс - backend создаст заказ
        customerPhone: user?.phone ?? '',
        customerName: user?.fullName ?? 'Клиент',
        batchId: activeBatchId,
        addressId: addressId,
        orderItems: items, // ✅ Используем orderItems вместо items
        notes: notes,
        token: token,
      );

      if (paymentResult.success && paymentResult.paymentId != null) {
        _currentPaymentId = paymentResult.paymentId;

        print('✅ Платеж создан: ${paymentResult.paymentId}');
        print('✅ Реальный ID заказа: ${paymentResult.realOrderId}');

        if (paymentResult.confirmationUrl != null) {
          _openPaymentWebView(
            paymentResult.confirmationUrl!,
            paymentResult.paymentId!,
            paymentResult.realOrderId ?? orderId, // ✅ Используем realOrderId
            paymentResult.orderCreated,
          );
        } else {
          _showError('Не получена ссылка для оплаты');
        }
      } else {
        _showError(paymentResult.message ?? 'Ошибка создания платежа');
      }
    } catch (e) {
      print('❌ Ошибка в _startPayment: $e');
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
          orderData:
              widget.orderData, // ✅ Передаем orderData для восстановления
        ),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;

    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white,
                AppColors.error.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Ошибка оплаты',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.error,
                      AppColors.error.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    child: Center(
                      child: Text(
                        'Понятно',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
