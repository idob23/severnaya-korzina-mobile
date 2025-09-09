import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart'; // ДОБАВИТЬ импорт
import '../auth/auth_choice_screen.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  // ИЗМЕНЕНО на StatefulWidget
  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ApiService _apiService = ApiService();
  bool _checkoutEnabled = true;
  bool _isLoadingStatus = false;

  @override
  void initState() {
    super.initState();
    _checkCheckoutStatus();
  }

  Future<void> _checkCheckoutStatus() async {
    if (!mounted) return;

    setState(() {
      _isLoadingStatus = true;
    });

    try {
      final response = await _apiService.getCheckoutEnabled();
      if (mounted) {
        setState(() {
          _checkoutEnabled = response['checkoutEnabled'] ?? true;
          _isLoadingStatus = false;
        });
      }
    } catch (e) {
      print('Ошибка проверки статуса checkout: $e');
      if (mounted) {
        setState(() {
          _checkoutEnabled = true; // По умолчанию разрешаем
          _isLoadingStatus = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Корзина'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
          if (cartProvider.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              // Информация о заказе
              _buildOrderSummary(cartProvider),

              // Список товаров в корзине
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: cartProvider.itemsList.length,
                  itemBuilder: (context, index) {
                    final item = cartProvider.itemsList[index];
                    return _buildCartItem(context, item, cartProvider);
                  },
                ),
              ),

              // Кнопка оформления заказа с проверкой статуса
              _buildCheckoutButton(context, cartProvider, authProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Корзина пуста',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Добавьте товары из каталога',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Товаров в корзине:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${cartProvider.totalItems} шт.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Общая сумма:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                cartProvider.formattedTotalAmount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(
      BuildContext context, CartItem item, CartProvider cartProvider) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Изображение товара (заглушка)
            // Container(
            //   width: 60,
            //   height: 60,
            //   decoration: BoxDecoration(
            //     color: Colors.grey[200],
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Icon(Icons.shopping_bag, color: Colors.grey[400]),
            // ),

            // SizedBox(width: 12),

            // Информация о товаре
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item.formattedPrice} за ${item.unit}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Сумма: ${item.formattedTotalPrice}',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Управление количеством
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (item.quantity > 1) {
                          cartProvider.updateQuantity(
                              item.productId, item.quantity - 1);
                        } else {
                          cartProvider.removeItem(item
                              .productId); // ИСПРАВЛЕНО: removeItem вместо removeProduct
                        }
                      },
                      icon: Icon(
                        item.quantity > 1 ? Icons.remove : Icons.delete,
                        color: item.quantity > 1 ? Colors.blue : Colors.red,
                      ),
                      constraints:
                          BoxConstraints.tightFor(width: 36, height: 36),
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        cartProvider.updateQuantity(
                            item.productId, item.quantity + 1);
                      },
                      icon: Icon(Icons.add, color: Colors.blue),
                      constraints:
                          BoxConstraints.tightFor(width: 36, height: 36),
                    ),
                  ],
                ),
                Text(
                  item.unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД с проверкой статуса
  Widget _buildCheckoutButton(BuildContext context, CartProvider cartProvider,
      AuthProvider authProvider) {
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
          // Показываем предупреждение если оформление выключено
          if (!_checkoutEnabled && !_isLoadingStatus)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Оформление заказов временно недоступно',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Информация о предоплате (показываем только если оформление включено)
          if (_checkoutEnabled && !_isLoadingStatus)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.green[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Требуется 100% предоплата картой МИР',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.green[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 12),

          // Кнопка оформления заказа
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: (_checkoutEnabled && !_isLoadingStatus)
                  ? () =>
                      _proceedToCheckout(context, cartProvider, authProvider)
                  : null,
              icon: _isLoadingStatus
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.payment, size: 24),
              label: Text(
                _isLoadingStatus ? 'Проверка...' : 'Оформить заказ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _checkoutEnabled ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          SizedBox(height: 8),

          // Дополнительная информация
          if (_checkoutEnabled && !_isLoadingStatus)
            Text(
              'Безопасная оплата картой МИР через ЮKassa',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, CartProvider cartProvider,
      AuthProvider authProvider) {
    // Проверяем авторизацию
    if (!authProvider.isAuthenticated) {
      _showAuthRequiredDialog(context);
      return;
    }

    // Проверяем, что корзина не пуста
    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Корзина пуста'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Переходим к оформлению заказа
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(),
      ),
    );
  }

  void _showAuthRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Необходима авторизация'),
        content: Text(
          'Для оформления заказа необходимо войти в аккаунт или зарегистрироваться.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthChoiceScreen(),
                ),
              );
            },
            child: Text('Войти'),
          ),
        ],
      ),
    );
  }
}
