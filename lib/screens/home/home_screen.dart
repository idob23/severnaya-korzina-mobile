// lib/screens/home/home_screen.dart - УЛУЧШЕННАЯ ВЕРСИЯ С ПРЕМИУМ НАВИГАЦИЕЙ (ИСПРАВЛЕНО)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Для HapticFeedback
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/products_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../catalog/catalog_screen.dart';
import '../maintenance_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import 'dart:async';
import '../../services/onboarding_service.dart';
// Импортируем design_system
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';
import '../../design_system/spacing/app_spacing.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex; // ✅ ДОБАВИТЬ

  const HomeScreen({Key? key, this.initialIndex = 0})
      : super(key: key); // ✅ ДОБАВИТЬ

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late int _currentIndex; // ✅ ИЗМЕНИТЬ на late
  Timer? _maintenanceCheckTimer;
  final ApiService _apiService = ApiService();
  final GlobalKey<CartScreenState> _cartKey = GlobalKey<CartScreenState>();

  // final List<Widget> _screens = [
  //   CatalogScreen(),
  //   CartScreen(),
  //   OrdersScreen(),
  //   ProfileScreen(),
  // ];
  late final List<Widget> _screens;

  @override
  void initState() {
    _screens = [
      CatalogScreen(),
      CartScreen(key: _cartKey),
      OrdersScreen(),
      ProfileScreen(),
    ];
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addObserver(this);
    _startMaintenanceCheck();
    // Показываем приветственный диалог при первом входе
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showWelcomeDialogIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _maintenanceCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Когда приложение возвращается из фона, проверяем статус
      print('📱 Приложение вернулось из фона, проверяем режим обслуживания');
      _checkMaintenanceStatus();
      // Обновляем статус оформления заказов
      _cartKey.currentState?.refreshCheckoutStatus();
      // Обновляем каталог и категории
      Provider.of<ProductsProvider>(context, listen: false).refresh();
    }
  }

  void _startMaintenanceCheck() {
    // Первая проверка сразу
    _checkMaintenanceStatus();

    // Затем каждые 30 секунд
    _maintenanceCheckTimer = Timer.periodic(
      Duration(seconds: 30),
      (_) => _checkMaintenanceStatus(),
    );
  }

  Future<void> _showWelcomeDialogIfNeeded() async {
    if (!mounted) return;

    final onboarding = OnboardingService.instance;
    if (!onboarding.shouldShowWelcomeDialog) return;

    await onboarding.markWelcomeDialogShown();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(maxWidth: 340),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.waving_hand, color: Colors.white, size: 36),
              ),
              SizedBox(height: 20),
              Text(
                'Добро пожаловать!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'Рекомендуем ознакомиться с разделом "О приложении" в Профиле, чтобы узнать как работает сервис.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Позже'),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Переключаемся на вкладку Профиль
                        setState(() {
                          _currentIndex = 3;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Перейти'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkMaintenanceStatus() async {
    try {
      print('🔍 Проверка режима обслуживания...');

      final statusResponse = await _apiService.checkAppStatus();

      print('📡 Ответ сервера: maintenance=${statusResponse['maintenance']}');

      // Если режим обслуживания включен
      if (statusResponse['maintenance'] == true) {
        final maintenanceDetails = statusResponse['maintenance_details'];

        print(
            '⚠️ Режим обслуживания активен! Переключаем на экран обслуживания');

        // Отменяем таймер
        _maintenanceCheckTimer?.cancel();

        // Переходим на экран обслуживания
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MaintenanceScreen(
                message: maintenanceDetails?['message'] ??
                    'Проводятся технические работы. Приложение временно недоступно.',
                endTime: maintenanceDetails?['end_time'],
              ),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      print('❌ Ошибка проверки режима обслуживания: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        // Улучшенная нижняя навигация с градиентом
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryDark,
                AppColors.primaryLight,
                AppColors.aurora1.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.6, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
              BoxShadow(
                color: AppColors.aurora1.withOpacity(0.2),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor:
                    Colors.transparent, // Делаем фон прозрачным для градиента
              ),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _currentIndex,
                onTap: (index) {
                  HapticFeedback.lightImpact();
                  setState(() => _currentIndex = index);
                  // Обновляем статус оформления при открытии корзины
                  if (index == 1) {
                    _cartKey.currentState?.refreshCheckoutStatus();
                  }
                },
                backgroundColor: Colors.transparent, // Прозрачный фон
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withOpacity(0.6),
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                elevation: 0, // Убираем стандартную тень
                items: [
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.store, 0),
                    label: 'Каталог',
                  ),
                  BottomNavigationBarItem(
                    // Корзина с улучшенным badge
                    icon: Consumer<CartProvider>(
                      builder: (context, cart, child) {
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _buildNavIcon(Icons.shopping_cart, 1),
                            // Показываем badge только если есть товары
                            if (cart.totalItems > 0)
                              Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.error.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  constraints: BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  child: Text(
                                    cart.totalItems > 99
                                        ? '99+'
                                        : '${cart.totalItems}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    label: 'Корзина',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.list_alt, 2),
                    label: 'Заказы',
                  ),
                  BottomNavigationBarItem(
                    icon: _buildNavIcon(Icons.person, 3),
                    label: 'Профиль',
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  // Иконка с анимацией размера
  Widget _buildNavIcon(IconData icon, int index) {
    final bool isSelected = _currentIndex == index;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(isSelected ? 8 : 4),
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            )
          : null,
      child: Icon(
        icon,
        size: isSelected ? 26 : 24,
      ),
    );
  }
}
