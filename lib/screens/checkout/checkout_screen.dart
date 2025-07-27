// lib/screens/checkout/checkout_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart'; // ДОБАВЛЕНО: импорт User
import '../payment/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedAddress = 'Пункт выдачи: ул. Ленина, 15';
  String _selectedDeliveryTime = 'В любое время';
  String _notes = '';
  bool _isProcessing = false;

  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Оформление заказа'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
          if (cartProvider.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 100, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Корзина пуста', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Вернуться в каталог'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Информация о пользователе - ИСПРАВЛЕНО
                      _buildUserInfo(authProvider.currentUser),

                      SizedBox(height: 20),

                      // Адрес доставки
                      _buildDeliverySection(),

                      SizedBox(height: 20),

                      // Время получения
                      _buildTimeSection(),

                      SizedBox(height: 20),

                      // Товары в заказе
                      _buildOrderItems(cartProvider.itemsList),

                      SizedBox(height: 20),

                      // Комментарий к заказу
                      _buildNotesSection(),

                      SizedBox(height: 20),

                      // Итоговая сумма
                      _buildOrderSummary(cartProvider),
                    ],
                  ),
                ),
              ),

              // Кнопка оформления заказа
              _buildCheckoutButton(cartProvider, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(User? user) {
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
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(user?.name ?? 'Пользователь'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(user?.phone ?? 'Не указан'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Адрес получения',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                color: Colors.blue[50],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedAddress,
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Режим работы: Пн-Пт 9:00-19:00, Сб 10:00-16:00',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Телефон: +7 (914) 123-45-67',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Время получения',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedDeliveryTime,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.schedule),
              ),
              items: [
                'В любое время',
                '9:00 - 12:00',
                '12:00 - 15:00',
                '15:00 - 18:00',
                '18:00 - 19:00',
              ]
                  .map((time) => DropdownMenuItem(
                        value: time,
                        child: Text(time),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDeliveryTime = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(List<CartItem> items) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Товары в заказе',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            ...items
                .map((item) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '${item.formattedPrice} за ${item.unit}',
                                  style: TextStyle(
                                      color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${item.quantity} ${item.unit}',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          SizedBox(width: 16),
                          Text(
                            item.formattedTotalPrice,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Комментарий к заказу',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Укажите дополнительные пожелания...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _notes = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    final totalAmount = cartProvider.totalAmount;
    final prepaymentAmount = totalAmount * 0.9; // 90% предоплата
    final remainingAmount = totalAmount - prepaymentAmount;

    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Итого к оплате',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildSummaryRow('Товаров:', '${cartProvider.totalItems} шт.'),
            _buildSummaryRow(
                'Общая сумма:', '${totalAmount.toStringAsFixed(0)} ₽'),
            Divider(),
            _buildSummaryRow(
              'Предоплата (90%):',
              '${prepaymentAmount.toStringAsFixed(0)} ₽',
              isHighlighted: true,
            ),
            _buildSummaryRow(
              'Доплата при получении:',
              '${remainingAmount.toStringAsFixed(0)} ₽',
            ),
            SizedBox(height: 8),
            Text(
              '💡 Вы доплачиваете только 10% при получении товара',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              fontSize: isHighlighted ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isHighlighted ? 18 : 14,
              color: isHighlighted ? Colors.green[700] : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(
      CartProvider cartProvider, AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isProcessing
                  ? null
                  : () => _proceedToPayment(cartProvider, authProvider),
              icon: _isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(Icons.payment),
              label: Text(
                _isProcessing
                    ? 'Обработка...'
                    : 'Оплатить ${(cartProvider.totalAmount * 0.9).toStringAsFixed(0)} ₽',
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
          SizedBox(height: 8),
          Text(
            '🔒 Безопасная оплата картой МИР через ЮKassa',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _proceedToPayment(
      CartProvider cartProvider, AuthProvider authProvider) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Подготавливаем данные заказа
      final orderData = {
        'items': cartProvider.getOrderItems(),
        'address': _selectedAddress,
        'deliveryTime': _selectedDeliveryTime,
        'notes': _notes.isNotEmpty ? _notes : null,
        'totalAmount': cartProvider.totalAmount,
        'prepaymentAmount': cartProvider.totalAmount * 0.9,
      };

      // Переходим к оплате
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(orderData: orderData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }
}
