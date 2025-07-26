// lib/screens/cart/cart_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../auth/auth_choice_screen.dart';

class CartScreen extends StatelessWidget {
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
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Переходим на первую вкладку (каталог)
                      DefaultTabController.of(context)?.animateTo(0);
                    },
                    child: Text('Перейти в каталог'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Информация о заказе
              Container(
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Общая стоимость:',
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
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: Colors.green[700], size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Коллективная закупка - экономия до 70%!',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

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

              // Кнопка оформления заказа
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Итоговая сумма
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'К оплате:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          cartProvider.formattedTotalAmount,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Кнопка оформления
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (authProvider.isAuthenticated) {
                            _proceedToCheckout(context, cartProvider);
                          } else {
                            _showAuthRequiredDialog(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart_checkout),
                            SizedBox(width: 8),
                            Text(
                              authProvider.isAuthenticated
                                  ? 'Оформить заказ'
                                  : 'Войти и оформить заказ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
            // Изображение товара (placeholder)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.shopping_bag,
                color: Colors.blue[300],
                size: 30,
              ),
            ),

            SizedBox(width: 16),

            // Информация о товаре
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${item.formattedPrice} за ${item.unit}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Итого: ${item.formattedTotalPrice}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 16),

            // Контролы количества
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        cartProvider.decrementItem(item.productId);
                      },
                      icon: Icon(Icons.remove_circle_outline),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.red[600],
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        cartProvider.incrementItem(item.productId);
                      },
                      icon: Icon(Icons.add_circle_outline),
                      style: IconButton.styleFrom(
                        foregroundColor: Colors.green[600],
                      ),
                    ),
                  ],
                ),

                // Кнопка удаления
                TextButton.icon(
                  onPressed: () {
                    cartProvider.removeItem(item.productId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.name} удален из корзины'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: Icon(Icons.delete_outline, size: 16),
                  label: Text('Удалить'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _proceedToCheckout(BuildContext context, CartProvider cartProvider) {
    // TODO: Переход к оформлению заказа
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Оформление заказа - в разработке'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showAuthRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Требуется авторизация'),
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
                MaterialPageRoute(builder: (_) => AuthChoiceScreen()),
              );
            },
            child: Text('Войти'),
          ),
        ],
      ),
    );
  }
}
