import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart'; // ДОБАВИТЬ импорт
import '../auth/auth_choice_screen.dart';
import '../checkout/checkout_screen.dart';

import '/widgets/premium_loading.dart';

import 'package:flutter/services.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

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
          // Анимированная иконка корзины
          TweenAnimationBuilder(
            duration: Duration(seconds: 2),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.background,
                        AppColors.ice,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withOpacity(0.1),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: AppColors.primaryLight.withOpacity(0.6),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            'Корзина пуста',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Добавьте товары из каталога',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.aurora.scale(0.1), // Легкий градиент
        border: Border(
          bottom: BorderSide(
            color: AppColors.primaryLight.withOpacity(0.2),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.shopping_bag,
                      color: AppColors.primaryDark, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Товаров в корзине:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cartProvider.totalItems} шт.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Общая сумма:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppGradients.success,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  cartProvider.formattedTotalAmount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
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
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Dismissible(
          key: Key(item.productId.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error.withOpacity(0.8),
                  AppColors.error,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Icon(
              Icons.delete_sweep,
              color: Colors.white,
              size: 28,
            ),
          ),
          onDismissed: (direction) {
            HapticFeedback.mediumImpact();
            cartProvider.updateQuantity(item.productId, 0);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} удален из корзины'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                action: SnackBarAction(
                  label: 'Отменить',
                  textColor: Colors.white,
                  onPressed: () {
                    // TODO: Реализовать отмену удаления
                  },
                ),
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Информация о товаре
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.aurora1.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.formattedPrice} / ${item.unit}',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Элементы управления количеством
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              if (item.quantity > 1) {
                                cartProvider.updateQuantity(
                                    item.productId, item.quantity - 1);
                              } else {
                                cartProvider.updateQuantity(item.productId, 0);
                              }
                            },
                            icon: AnimatedSwitcher(
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                item.quantity > 1 ? Icons.remove : Icons.delete,
                                key: ValueKey(item.quantity > 1),
                                color: item.quantity > 1
                                    ? AppColors.primaryDark
                                    : AppColors.error,
                                size: 20,
                              ),
                            ),
                            constraints:
                                BoxConstraints.tightFor(width: 36, height: 36),
                          ),
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 40,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: item.quantity > 0
                                  ? AppGradients.primary.scale(0.8)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: item.quantity > 0
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              cartProvider.updateQuantity(
                                  item.productId, item.quantity + 1);
                            },
                            icon: Icon(
                              Icons.add,
                              color: AppColors.success,
                              size: 20,
                            ),
                            constraints:
                                BoxConstraints.tightFor(width: 36, height: 36),
                          ),
                        ],
                      ),
                      Text(
                        item.unit,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ОБНОВЛЕННЫЙ МЕТОД с проверкой статуса
  Widget _buildCheckoutButton(BuildContext context, CartProvider cartProvider,
      AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
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
              padding: EdgeInsets.all(14),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withOpacity(0.1),
                    AppColors.warning.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: AppColors.warning,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Оформление заказов временно приостановлено',
                      style: TextStyle(
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Основная кнопка с анимацией
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: (!_checkoutEnabled || _isLoadingStatus)
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      if (authProvider.isAuthenticated) {
                        // Анимированный переход
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    CheckoutScreen(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              const begin = Offset(1.0, 0.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutCubic;

                              var tween = Tween(begin: begin, end: end)
                                  .chain(CurveTween(curve: curve));

                              return SlideTransition(
                                position: animation.drive(tween),
                                child: child,
                              );
                            },
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthChoiceScreen(),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _checkoutEnabled ? null : Colors.grey[400],
                foregroundColor: Colors.white,
                elevation: _checkoutEnabled ? 4 : 0,
                shadowColor: AppColors.primaryLight.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: _checkoutEnabled
                      ? AppGradients.button
                      : LinearGradient(
                          colors: [Colors.grey[400]!, Colors.grey[400]!],
                        ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoadingStatus)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      else
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: Icon(
                            authProvider.isAuthenticated
                                ? Icons.shopping_cart_checkout
                                : Icons.login,
                            key: ValueKey(authProvider.isAuthenticated),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      SizedBox(width: 12),
                      Text(
                        _isLoadingStatus
                            ? 'Проверка...'
                            : authProvider.isAuthenticated
                                ? 'Оформить заказ'
                                : 'Войти для оформления',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
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

          // Дополнительная информация под кнопкой
          if (authProvider.isAuthenticated && _checkoutEnabled) ...[
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: 6),
                Text(
                  'Безопасная оплата картой или СБП',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
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
