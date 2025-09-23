// lib/screens/checkout/checkout_screen.dart - УЛУЧШЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для HapticFeedback
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/screens/payment/payment_screen.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
// Добавляем импорты дизайн-системы
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  String _selectedDeliveryTime = 'В любое время';
  String _notes = '';
  bool _isProcessing = false;

  final TextEditingController _notesController = TextEditingController();

  // Добавляем анимации
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Инициализация анимаций
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Существующий метод createOrder остается без изменений
  Future<void> _createOrder() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    HapticFeedback.mediumImpact();

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;

      if (user?.id == null) {
        throw Exception('Пользователь не авторизован');
      }

      final orderData = {
        'userId': user!.id,
        'items': cartProvider.itemsList
            .map((item) => {
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'price': item.price,
                })
            .toList(),
        'total': cartProvider.totalAmount,
        'deliveryTime': _selectedDeliveryTime,
        'notes': _notes,
        'addressId': 1, // Добавляем обязательный параметр addressId
      };

      // Вызываем createOrder с именованными параметрами
      final response = await _apiService.createOrder(
        addressId: 1, // используем дефолтный адрес
        items: cartProvider.itemsList
            .map((item) => {
                  'productId': item.productId,
                  'quantity': item.quantity,
                  'price': item.price,
                })
            .toList(),
        notes: _notes,
      );

      if (response['success']) {
        // Используем clearCart вместо clear или removeAll
        cartProvider.clearCart();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              orderData: {
                'orderId': response['order']['id'],
                'totalAmount': cartProvider.totalAmount,
              },
            ),
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Ошибка создания заказа');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    // Используем currentUser вместо user
    final user = authProvider.currentUser;

    return Scaffold(
      // Добавляем градиентный фон
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.ice,
              AppColors.aurora3.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Премиум AppBar с градиентом
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryDark.withOpacity(0.9),
                        AppColors.primaryLight.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Оформление заказа',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                // Контент
                Expanded(
                  child: cartProvider.itemsList.isEmpty
                      ? _buildEmptyCart()
                      : SingleChildScrollView(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Информация о пользователе с улучшенным дизайном
                              _buildUserInfoCard(user),
                              SizedBox(height: 20),

                              // Товары в заказе
                              _buildOrderItemsCard(cartProvider),
                              SizedBox(height: 20),

                              // Время доставки
                              _buildDeliveryTimeCard(),
                              SizedBox(height: 20),

                              // Комментарий
                              _buildNotesCard(),
                              SizedBox(height: 20),

                              // Итоговая сумма
                              _buildOrderSummaryCard(cartProvider),
                              SizedBox(height: 80), // Место для кнопки
                            ],
                          ),
                        ),
                ),

                // Кнопка оформления (если корзина не пуста)
                if (cartProvider.itemsList.isNotEmpty)
                  _buildCheckoutButton(cartProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Пустая корзина
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppGradients.aurora,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.aurora2.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24),
          Text(
            'Корзина пуста',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              gradient: AppGradients.button,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    'Вернуться в каталог',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Карточка пользователя
  Widget _buildUserInfoCard(User? user) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: AppGradients.aurora,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Пользователь',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  user?.phone ?? 'Телефон не указан',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Карточка товаров
  Widget _buildOrderItemsCard(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.button,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.shopping_bag, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Товары в заказе',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...cartProvider.itemsList
              .map((item) => Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          '${item.quantity} × ${item.price.toStringAsFixed(0)}₽',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // Карточка времени доставки
  Widget _buildDeliveryTimeCard() {
    final times = ['В любое время', 'Утром', 'Днем', 'Вечером'];

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.aurora,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.access_time, color: Colors.white, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Время получения',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...times
              .map((time) => GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedDeliveryTime = time;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(vertical: 4),
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _selectedDeliveryTime == time
                            ? AppColors.primaryLight.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedDeliveryTime == time
                              ? AppColors.primaryLight
                              : AppColors.border,
                          width: _selectedDeliveryTime == time ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              gradient: _selectedDeliveryTime == time
                                  ? AppGradients.button
                                  : null,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedDeliveryTime == time
                                    ? Colors.transparent
                                    : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: _selectedDeliveryTime == time
                                ? Icon(Icons.check,
                                    size: 12, color: Colors.white)
                                : null,
                          ),
                          SizedBox(width: 12),
                          Text(
                            time,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: _selectedDeliveryTime == time
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  // Карточка комментария
  Widget _buildNotesCard() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    Icon(Icons.edit_note, color: AppColors.warning, size: 20),
              ),
              SizedBox(width: 12),
              Text(
                'Комментарий к заказу',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextField(
            controller: _notesController,
            onChanged: (value) => _notes = value,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Укажите пожелания к заказу (необязательно)',
              hintStyle: TextStyle(color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Карточка итоговой суммы
  Widget _buildOrderSummaryCard(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.aurora1.withOpacity(0.1),
            AppColors.aurora2.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.aurora1.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Итого к оплате:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: cartProvider.totalAmount),
            duration: Duration(milliseconds: 500),
            builder: (context, value, child) {
              return ShaderMask(
                shaderCallback: (bounds) =>
                    AppGradients.aurora.createShader(bounds),
                child: Text(
                  '${value.toStringAsFixed(0)}₽',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Кнопка оформления
  Widget _buildCheckoutButton(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: _isProcessing ? null : AppGradients.button,
            color: _isProcessing ? Colors.grey : null,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.3),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isProcessing ? null : _createOrder,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: _isProcessing
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Оформить заказ',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
}
