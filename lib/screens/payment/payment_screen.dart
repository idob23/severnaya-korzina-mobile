// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:severnaya_korzina/providers/cart_provider.dart';
// import 'package:severnaya_korzina/providers/auth_provider.dart';
// import 'payment_service.dart';
// import 'payment_success_screen.dart';

// class PaymentScreen extends StatefulWidget {
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   final PaymentService _paymentService = PaymentService();
//   bool _isProcessing = false;
//   String? _currentPaymentId;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Оплата заказа'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//       ),
//       body: Consumer2<CartProvider, AuthProvider>(
//         builder: (context, cartProvider, authProvider, child) {
//           final user = authProvider.currentUser;
//           final total = cartProvider.totalAmount;
//           final prepayment = total * 0.9;
//           final remaining = total * 0.1;

//           return Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Информация о заказе
//                       _buildOrderSummary(
//                           cartProvider, total, prepayment, remaining),
//                       SizedBox(height: 16),

//                       // Информация о пользователе
//                       _buildUserInfo(user),
//                       SizedBox(height: 16),

//                       // Информация о способе оплаты
//                       _buildPaymentMethodInfo(),
//                       SizedBox(height: 16),

//                       // Тестовые карты (если в тестовом режиме)
//                       if (PaymentService.isTestMode()) _buildTestCardsInfo(),
//                     ],
//                   ),
//                 ),
//               ),

//               // Кнопка оплаты
//               _buildPaymentButton(prepayment, user),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildOrderSummary(CartProvider cartProvider, double total,
//       double prepayment, double remaining) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Ваш заказ',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 12),
//             ...cartProvider.items
//                 .map((cartItem) => Padding(
//                       padding: EdgeInsets.symmetric(vertical: 4),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Expanded(
//                               child: Text(
//                                   '${cartItem.product.name} × ${cartItem.quantity}')),
//                           Text('${cartItem.totalPrice.toStringAsFixed(0)} ₽'),
//                         ],
//                       ),
//                     ))
//                 .toList(),
//             Divider(height: 24),
//             _buildSummaryRow(
//                 'Стоимость товаров:', '${total.toStringAsFixed(0)} ₽'),
//             _buildSummaryRow('Скидка коллективной закупки:',
//                 '-${(total * 0.1).toStringAsFixed(0)} ₽', Colors.green),
//             _buildSummaryRow('Доставка:', 'Бесплатно', Colors.green),
//             Divider(height: 16),
//             _buildSummaryRow(
//                 'Итого к оплате:', '${total.toStringAsFixed(0)} ₽', null, true),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.blue[200]!),
//               ),
//               child: Column(
//                 children: [
//                   _buildSummaryRow('Предоплата (90%):',
//                       '${prepayment.toStringAsFixed(0)} ₽', Colors.blue, true),
//                   _buildSummaryRow('К доплате при получении:',
//                       '${remaining.toStringAsFixed(0)} ₽', Colors.orange),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryRow(String label, String amount,
//       [Color? color, bool isBold = false]) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: TextStyle(
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
//           Text(amount,
//               style: TextStyle(
//                   fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//                   color: color)),
//         ],
//       ),
//     );
//   }

//   Widget _buildUserInfo(user) {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Контактная информация',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 12),
//             _buildInfoRow(Icons.person, user?.name ?? 'Не указано'),
//             _buildInfoRow(Icons.phone, user?.phone ?? 'Не указан'),
//             _buildInfoRow(Icons.location_on, 'Усть-Нера (пункт выдачи)'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(IconData icon, String text) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Icon(icon, color: Colors.grey[600], size: 20),
//           SizedBox(width: 8),
//           Text(text),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaymentMethodInfo() {
//     return Card(
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Способ оплаты',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 12),
//             Container(
//               padding: EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.blue, width: 2),
//                 borderRadius: BorderRadius.circular(8),
//                 color: Colors.blue[50],
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.credit_card, color: Colors.blue, size: 28),
//                   SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Карта МИР',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 16)),
//                         Text('Национальная платежная система',
//                             style: TextStyle(color: Colors.grey[600])),
//                       ],
//                     ),
//                   ),
//                   Icon(Icons.check_circle, color: Colors.green, size: 20),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTestCardsInfo() {
//     final testCards = PaymentService.getTestCards();

//     return Card(
//       color: Colors.orange[50],
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.science, color: Colors.orange),
//                 SizedBox(width: 8),
//                 Text('Тестовый режим',
//                     style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.orange[800])),
//               ],
//             ),
//             SizedBox(height: 12),
//             Text('Для тестирования используйте эти номера карт:',
//                 style: TextStyle(color: Colors.orange[700])),
//             SizedBox(height: 8),
//             ...testCards.entries
//                 .map((entry) => Padding(
//                       padding: EdgeInsets.symmetric(vertical: 2),
//                       child: Text('${entry.key}: ${entry.value}',
//                           style:
//                               TextStyle(fontFamily: 'monospace', fontSize: 12)),
//                     ))
//                 .toList(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPaymentButton(double prepayment, user) {
//     return Container(
//       padding: EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.3),
//               spreadRadius: 1,
//               blurRadius: 5,
//               offset: Offset(0, -2))
//         ],
//       ),
//       child: SizedBox(
//         width: double.infinity,
//         height: 56,
//         child: ElevatedButton(
//           onPressed: !_isProcessing
//               ? () => _processMirPayment(prepayment, user)
//               : null,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.blue,
//             foregroundColor: Colors.white,
//             shape:
//                 RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           child: _isProcessing
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(color: Colors.white)),
//                     SizedBox(width: 12),
//                     Text('Создание платежа...'),
//                   ],
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.credit_card),
//                     SizedBox(width: 8),
//                     Text(
//                         'Оплатить ${prepayment.toStringAsFixed(0)} ₽ картой МИР',
//                         style: TextStyle(
//                             fontSize: 16, fontWeight: FontWeight.bold)),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   Future<void> _processMirPayment(double amount, user) async {
//     setState(() => _isProcessing = true);

//     try {
//       final orderId =
//           DateTime.now().millisecondsSinceEpoch.toString().substring(8);

//       print('🚀 Начинаем процесс оплаты...');

//       final result = await _paymentService.createMirPayment(
//         amount: amount,
//         orderId: orderId,
//         customerPhone: user?.phone ?? '',
//         customerName: user?.name ?? '',
//       );

//       if (result.success && result.confirmationUrl != null) {
//         _currentPaymentId = result.paymentId;

//         // Открываем платежную форму
//         final opened =
//             await _paymentService.openPaymentForm(result.confirmationUrl!);

//         if (opened) {
//           // Показываем диалог ожидания
//           _showPaymentPendingDialog(result.paymentId!);
//         } else {
//           _showError('Не удается открыть платежную форму');
//         }
//       } else {
//         _showError(result.message);
//       }
//     } catch (e) {
//       _showError('Ошибка создания платежа: $e');
//     } finally {
//       setState(() => _isProcessing = false);
//     }
//   }

//   void _showPaymentPendingDialog(String paymentId) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => AlertDialog(
//         title: Text('Ожидание оплаты'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             CircularProgressIndicator(),
//             SizedBox(height: 16),
//             Text(
//                 'Завершите оплату в открывшемся окне браузера и нажмите "Проверить оплату"'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Отмена'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _checkPaymentStatus(paymentId);
//             },
//             child: Text('Проверить оплату'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _checkPaymentStatus(String paymentId) async {
//     try {
//       print('🔍 Проверяем статус платежа...');

//       final status = await _paymentService.checkPaymentStatus(paymentId);

//       if (status.isPaid) {
//         print('✅ Платеж успешно завершен!');
//         _showPaymentSuccess(paymentId, status.amount);
//       } else if (status.isCanceled) {
//         _showError('Платеж был отменен');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content:
//                   Text('Платеж еще обрабатывается. Статус: ${status.status}')),
//         );
//       }
//     } catch (e) {
//       _showError('Ошибка проверки статуса: $e');
//     }
//   }

//   void _showPaymentSuccess(String paymentId, double amount) {
//     final cartProvider = Provider.of<CartProvider>(context, listen: false);

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PaymentSuccessScreen(
//           orderId: paymentId,
//           amount: amount,
//           paymentMethod: 'Карта МИР',
//         ),
//       ),
//     );

//     cartProvider.clear();
//   }

//   void _showError(String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Ошибка оплаты'),
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
