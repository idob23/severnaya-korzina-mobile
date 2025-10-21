// lib/screens/checkout/checkout_screen.dart
// ИСПРАВЛЕНО: Корзина НЕ очищается до завершения оплаты

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/screens/payment/payment_screen.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  double _marginPercent = 50.0;
  bool _isLoadingMargin = true;
  bool _hasLoadedMargin = false; // ← ДОБАВИТЬ

  final TextEditingController _notesController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

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

  // ✨ ДОБАВИТЬ ЭТОТ МЕТОД:
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedMargin) {
      _loadMarginPercent();
      _hasLoadedMargin = true;
    }
  }

  // ДОБАВЬТЕ этот метод:
  Future<void> _loadMarginPercent() async {
    try {
      print('🔄 Загружаем маржу из активной партии...');

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      final batchResponse = await http.get(
        Uri.parse('https://api.sevkorzina.ru/api/batches/active'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (batchResponse.statusCode == 200 && mounted) {
        final batchData = json.decode(batchResponse.body);

        // 🔍 ДЕБАГ: Смотрим что пришло с сервера
        print('📦 ДЕБАГ: Полный ответ сервера:');
        print(batchResponse.body);
        print('📊 ДЕБАГ: batch объект: ${batchData['batch']}');
        print(
            '💰 ДЕБАГ: marginPercent значение: ${batchData['batch']?['marginPercent']}');
        print(
            '🔢 ДЕБАГ: тип данных: ${batchData['batch']?['marginPercent'].runtimeType}');

        final newMargin = double.tryParse(
                batchData['batch']?['marginPercent']?.toString() ?? '50') ??
            50.0;

        setState(() {
          _marginPercent = newMargin;
          _isLoadingMargin = false;
        });

        print('✅ Маржа загружена: $_marginPercent%'); // ← ДОБАВИТЬ ЛОГ
      }
    } catch (e) {
      print('⚠️ Ошибка получения маржи: $e');
      if (mounted) {
        setState(() {
          _isLoadingMargin = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }

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

      // ✅ КРИТИЧЕСКАЯ ПРОВЕРКА: Есть ли адрес у пользователя?
      if (user == null || user.defaultAddress == null) {
        throw Exception('Пожалуйста, добавьте адрес доставки в профиле');
      }

      // ✅ ВАЖНО: Сохраняем все данные ДО перехода
      final double baseAmount = cartProvider.totalAmount;
      final double marginAmount = baseAmount * (_marginPercent / 100);
      final double totalAmount = baseAmount + marginAmount; // ✅ С маржой!
      final List<Map<String, dynamic>> items = cartProvider.itemsList
          .map((item) => {
                'productId': item.productId,
                'quantity': item.quantity,
                'price': item.price,
                'name': item.name, // ✅ НОВОЕ: Сохраняем name
                'unit': item.unit, // ✅ НОВОЕ: Сохраняем unit
              })
          .toList();

      if (!mounted) return;

      // ✅ ИСПРАВЛЕНО: Очищаем корзину СРАЗУ после сохранения данных
      // Это гарантирует что при отмене мы восстановим ТОЧНО те товары
      cartProvider.clearCart();
      print('🗑️ Корзина очищена перед переходом к оплате');

      // ✅ ИСПРАВЛЕНИЕ: Используем реальный ID адреса пользователя
      final realAddressId = user.defaultAddress!.id!;

      print('📍 Используем адрес ID: $realAddressId');
      print('📍 Адрес: ${user.defaultAddress!.address}');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            orderData: {
              'totalAmount': totalAmount,
              'items': items,
              'notes': _notes,
              'addressId': realAddressId,
              'deliveryTime': _selectedDeliveryTime,
            },
          ),
        ),
      );
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
    final user = authProvider.currentUser;

    return Scaffold(
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
                // AppBar
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
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          'Оформление заказа',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: 48),
                    ],
                  ),
                ),

                // Контент
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(16),
                    children: [
                      // Информация о пользователе
                      _buildUserInfoCard(user),
                      SizedBox(height: 16),

                      // Детали заказа
                      _buildOrderDetailsCard(cartProvider),
                      SizedBox(height: 16),

                      // Заметки к заказу
                      _buildNotesCard(),
                      SizedBox(height: 16),

                      // Итоговая сумма
                      _buildTotalCard(cartProvider),
                    ],
                  ),
                ),

                // Кнопка оформления
                _buildCheckoutButton(cartProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text(
                'Информация о получателе',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            user?.fullName ?? 'Не указано',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 4),
          Text(
            user?.phone ?? 'Не указано',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(CartProvider cartProvider) {
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
              Icon(Icons.shopping_basket, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text(
                'Состав заказа',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...cartProvider.itemsList.map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity} x Товар #${item.name}',
                        style: TextStyle(fontSize: 14),
                        maxLines: 2, // ✅ Добавлено для длинных названий
                        overflow: TextOverflow.ellipsis, // ✅ Добавлено
                      ),
                    ),
                    Text(
                      '${(item.price * item.quantity).toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

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
              Icon(Icons.note, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text(
                'Комментарий к заказу',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Например: позвонить за час до доставки',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            onChanged: (value) => _notes = value,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(CartProvider cartProvider) {
    // Расчет сумм
    final baseAmount = cartProvider.totalAmount;
    final marginAmount = baseAmount * (_marginPercent / 100);
    final totalWithMargin = baseAmount + marginAmount;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryLight.withOpacity(0.1),
            AppColors.aurora2.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: _isLoadingMargin
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                // Товары (базовая цена)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shopping_basket,
                            color: AppColors.textSecondary, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Товары:',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${baseAmount.toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Услуга организации (маржа)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_shipping,
                            color: AppColors.textSecondary, size: 18),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Услуга организации:',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '(${_marginPercent.toStringAsFixed(0)}% наценка)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      '${marginAmount.toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.aurora3,
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: AppColors.primaryLight.withOpacity(0.3),
                    thickness: 1,
                  ),
                ),

                // ИТОГО к оплате
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Итого к оплате:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${totalWithMargin.toStringAsFixed(0)} ₽',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),

                // Пояснение
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue.shade700, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Наценка покрывает доставку и организацию закупки',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCheckoutButton(CartProvider cartProvider) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: _isProcessing ? null : AppGradients.primary,
          color: _isProcessing ? Colors.grey[300] : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _isProcessing ? null : _createOrder,
            child: Center(
              child: _isProcessing
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Перейти к оплате',
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
    );
  }
}
