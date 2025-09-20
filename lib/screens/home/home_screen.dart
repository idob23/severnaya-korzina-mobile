// lib/screens/home/home_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ С БЕЙДЖЕМ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';
import '../catalog/catalog_screen.dart';
import '../maintenance_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  Timer? _maintenanceCheckTimer;
  final ApiService _apiService = ApiService();

  final List<Widget> _screens = [
    CatalogScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startMaintenanceCheck();
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
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            // ИСПРАВЛЕНО: Добавлен Consumer для отображения количества товаров
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  children: [
                    Icon(Icons.shopping_cart),
                    // Показываем бейдж только если есть товары
                    if (cart.totalItems > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '${cart.totalItems}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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
            icon: Icon(Icons.list_alt),
            label: 'Заказы',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
        ],
      ),
    );
  }
}
