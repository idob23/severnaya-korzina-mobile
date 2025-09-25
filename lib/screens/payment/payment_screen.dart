// // lib/screens/payment/payment_screen.dart - ПОЛНЫЙ ФАЙЛ

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../models/user.dart';
// import '../../providers/cart_provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/orders_provider.dart';
// import 'payment_service.dart';
// import 'universal_payment_screen.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PaymentScreen extends StatefulWidget {
//   final Map<String, dynamic> orderData;

//   const PaymentScreen({Key? key, required this.orderData}) : super(key: key);

//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   final PaymentService _paymentService = PaymentService();
//   bool _isProcessing = false;
//   String? _currentPaymentId;

//   @override
//   Widget build(BuildContext context) {
//     final double amount = widget.orderData['totalAmount'] ?? 0.0;
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Оплата заказа'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildOrderSummary(amount),
//                     SizedBox(height: 20),
//                     _buildPaymentMethod(),
//                     SizedBox(height: 20),
//                     _buildSecurityInfo(),
//                   ],
//                 ),
//               ),
//             ),
//             _buildPaymentButton(amount, user),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildOrderSummary(double amount) {
//     return Card(
//       color: Colors.green[50],
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'К оплате',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Итого к оплате:'),
//                 Text(
//                   '${amount.toStringAsFixed(0)} ₽',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.green[700],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.green[100],
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: Text(
//                 '💡 Полная оплата заказа. Товары будут готовы к получению после доставки.',
//                 style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentMethod() {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.credit_card, color: Colors.blue),
//                 SizedBox(width: 8),
//                 Text(
//                   'Способ оплаты',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.green),
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.green[50],
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.check_circle, color: Colors.green, size: 20),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Банковская карта (ЮKassa)',
//                       style: TextStyle(fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 8),
//             Text(
//               'Принимаются карты: МИР, Visa, Mastercard',
//               style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSecurityInfo() {
//     return Card(
//       color: Colors.blue[50],
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Row(
//           children: [
//             Icon(Icons.security, color: Colors.blue),
//             SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Безопасная оплата',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     'Платеж проходит через защищенную систему ЮKassa',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentButton(double amount, User? user) {
//     return Container(
//       padding: EdgeInsets.symmetric(vertical: 16),
//       child: SizedBox(
//         width: double.infinity,
//         height: 56,
//         child: ElevatedButton.icon(
//           onPressed: _isProcessing ? null : () => _startPayment(user),
//           icon: _isProcessing
//               ? SizedBox(
//                   width: 20,
//                   height: 20,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Colors.white,
//                   ),
//                 )
//               : Icon(Icons.payment, size: 24),
//           label: Text(
//             _isProcessing
//                 ? 'Обработка...'
//                 : 'Оплатить ${amount.toStringAsFixed(0)} ₽',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.green,
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _startPayment(User? user) async {
//     if (_isProcessing) return;

//     setState(() {
//       _isProcessing = true;
//     });

//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;

//       // Извлекаем данные из orderData
//       final items = widget.orderData['items'] as List<Map<String, dynamic>>?;
//       final addressId = widget.orderData['addressId'] ?? 1;
//       final notes = widget.orderData['notes'] as String?;
//       final amount = widget.orderData['totalAmount'] ?? 0.0;

//       // Получаем активную партию из API
//       int? batchId;
//       try {
//         // Сначала ищем активную партию
//         final activeResponse = await http.get(
//           Uri.parse('http://84.201.149.245:3000/api/batches?status=active'),
//           headers: {
//             'Content-Type': 'application/json',
//             if (token != null) 'Authorization': 'Bearer $token',
//           },
//         );

//         if (activeResponse.statusCode == 200) {
//           final activeData = jsonDecode(activeResponse.body);
//           if (activeData['success'] == true &&
//               activeData['batches'] != null &&
//               (activeData['batches'] as List).isNotEmpty) {
//             final activeBatch = activeData['batches'][0];
//             batchId = activeBatch['id'];
//             print('✅ Найдена активная партия #$batchId');
//           }
//         }

//         // Если не нашли активную, ищем партию в сборе
//         if (batchId == null) {
//           final collectingResponse = await http.get(
//             Uri.parse(
//                 'http://84.201.149.245:3000/api/batches?status=collecting'),
//             headers: {
//               'Content-Type': 'application/json',
//               if (token != null) 'Authorization': 'Bearer $token',
//             },
//           );

//           if (collectingResponse.statusCode == 200) {
//             final collectingData = jsonDecode(collectingResponse.body);
//             if (collectingData['success'] == true &&
//                 collectingData['batches'] != null &&
//                 (collectingData['batches'] as List).isNotEmpty) {
//               final collectingBatch = collectingData['batches'][0];
//               batchId = collectingBatch['id'];
//               print('✅ Найдена партия в сборе #$batchId');
//             }
//           }
//         }
//       } catch (e) {
//         print('❌ Ошибка получения партии: $e');
//         // Продолжаем без batchId - заказ создастся без привязки к партии
//       }

//       print('📦 Создаем платеж с batchId: ${batchId ?? "без партии"}');

//       // Генерируем фейковый orderId как сигнал для бэкенда создать заказ
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fakeOrderId = 'ORDER_$timestamp';

//       // Создаем платеж с данными для заказа
//       final result = await _paymentService.createPayment(
//         amount: amount,
//         orderId: fakeOrderId,
//         customerPhone: user?.phone ?? '',
//         customerName: user?.fullName ?? 'Клиент',
//         token: token,
//         orderItems: items,
//         notes: notes,
//         addressId: addressId,
//         batchId: batchId, // Передаем найденный batchId или null
//       );

//       if (result.success && result.confirmationUrl != null) {
//         // Получаем реальный orderId если заказ был создан
//         final realOrderId = result.realOrderId ?? fakeOrderId;

//         if (!mounted) return;

//         // Показываем диалог подтверждения
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => AlertDialog(
//             title: Row(
//               children: [
//                 Icon(Icons.payment, color: Colors.green),
//                 SizedBox(width: 8),
//                 Text('Переход к оплате'),
//               ],
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                     'Сейчас вы будете перенаправлены на защищенную страницу банка для оплаты картой.'),
//                 SizedBox(height: 16),
//                 if (batchId != null) ...[
//                   Text(
//                     '📦 Заказ будет добавлен в партию #$batchId',
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                   ),
//                   SizedBox(height: 8),
//                 ],
//                 Text(
//                   '💳 Принимаются карты: МИР',
//                   style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('Отмена'),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   _openPaymentWebView(
//                     result.confirmationUrl!,
//                     result.paymentId!,
//                     realOrderId,
//                     result.orderCreated,
//                   );
//                 },
//                 child: Text('Продолжить'),
//               ),
//             ],
//           ),
//         );
//       } else {
//         _showError(result.message ?? 'Ошибка создания платежа');
//       }
//     } catch (e) {
//       _showError('Ошибка: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessing = false;
//         });
//       }
//     }
//   }

//   void _openPaymentWebView(String confirmationUrl, String paymentId,
//       String orderId, bool orderCreated) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => UniversalPaymentScreen(
//           paymentUrl: confirmationUrl,
//           paymentId: paymentId,
//           orderId: orderId,
//           orderCreated: orderCreated,
//         ),
//       ),
//     );
//   }

//   void _showError(String message) {
//     if (!mounted) return;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             Icon(Icons.error, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Ошибка оплаты'),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('ОК'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/screens/payment/payment_screen.dart - УЛУЧШЕННАЯ ВЕРСИЯ с визуальными эффектами

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Добавлено для HapticFeedback
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import 'payment_service.dart';
import 'universal_payment_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// Добавляем импорты дизайн-системы
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

  // Добавляем анимации
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Инициализация анимаций
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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      // Градиентный фон
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.ice,
              AppColors.aurora3.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Премиум AppBar с градиентом
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Оплата заказа',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Баланс для центровки
                  ],
                ),
              ),

              // Контент с анимацией
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 16),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummary(double amount) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1000),
      tween: Tween(begin: 0, end: amount),
      builder: (context, value, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.success.withOpacity(0.1),
                AppColors.aurora2.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.success.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.aurora2.withOpacity(0.05),
                blurRadius: 30,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Card(
            color: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppGradients.success,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'К оплате',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Итого к оплате:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      // Анимированная сумма с градиентом
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppGradients.success.createShader(bounds),
                        child: Text(
                          '${value.toStringAsFixed(0)} ₽',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Полная оплата заказа. Товары будут готовы к получению после доставки.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethod() {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: AppColors.aurora1.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: AppGradients.button,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Способ оплаты',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.1),
                      AppColors.aurora2.withOpacity(0.05),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.success,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Банковская карта (ЮKassa)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'МИР, Visa, Mastercard',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.info.withOpacity(0.1),
            AppColors.aurora1.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppGradients.button,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryLight.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.security_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Безопасная оплата',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Платеж проходит через защищенную систему ЮKassa',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton(double amount, User? user) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        height: 60,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            gradient: _isProcessing ? null : AppGradients.success,
            color: _isProcessing ? Colors.grey[400] : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isProcessing
                ? []
                : [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                    BoxShadow(
                      color: AppColors.aurora2.withOpacity(0.3),
                      blurRadius: 30,
                      offset: Offset(0, 5),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
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
        ),
      ),
    );
  }

  // ВСЕ ОСТАЛЬНЫЕ МЕТОДЫ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ
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
          Uri.parse('http://84.201.149.245:3000/api/batches/active'),
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
        print('Ошибка получения активной партии: $e');
      }

      // Создаем заказ на бэкенде
      final orderResponse = await http.post(
        Uri.parse('http://84.201.149.245:3000/api/orders'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'items': items,
          'addressId': addressId,
          'notes': notes,
        }),
      );

      if (orderResponse.statusCode != 201) {
        throw Exception('Не удалось создать заказ');
      }

      final orderData = json.decode(orderResponse.body);
      final orderId = orderData['order']?['id'];

      if (orderId == null) {
        throw Exception('Не получен ID заказа');
      }

      // Создаем платеж
      final paymentResult = await _paymentService.createPayment(
        amount: amount,
        orderId: orderId.toString(),
        customerPhone: user?.phone ?? '',
        customerName: user?.fullName ?? 'Клиент',
        batchId: activeBatchId,
        token: token,
      );

      if (paymentResult.success && paymentResult.paymentId != null) {
        _currentPaymentId = paymentResult.paymentId;

        if (paymentResult.confirmationUrl != null) {
          _openPaymentWebView(
            paymentResult.confirmationUrl!,
            paymentResult.paymentId!,
            orderId.toString(),
            true,
          );
        } else {
          _showError('Не получена ссылка для оплаты');
        }
      } else {
        _showError(paymentResult.message ?? 'Ошибка создания платежа');
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
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Понятно',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
