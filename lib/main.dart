// lib/main.dart - ПОЛНОСТЬЮ ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/cart_provider.dart';
import 'package:severnaya_korzina/providers/auth_provider.dart';
import 'package:severnaya_korzina/providers/products_provider.dart';
import 'package:severnaya_korzina/providers/orders_provider.dart';
import 'screens/catalog/catalog_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:severnaya_korzina/screens/auth/auth_choice_screen.dart';
import 'screens/payment/payment_success_screen.dart';
import 'package:severnaya_korzina/services/update_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация сервиса обновлений
  try {
    await UpdateService().init();
  } catch (e) {
    print('Ошибка инициализации UpdateService: $e');
    // Продолжаем работу даже при ошибке
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Авторизация
        ChangeNotifierProvider<AuthProvider>(
            create: (context) => AuthProvider()..init()),

        // Товары и каталог
        ChangeNotifierProvider<ProductsProvider>(
            create: (context) => ProductsProvider()),

        // Заказы
        ChangeNotifierProvider<OrdersProvider>(
            create: (context) => OrdersProvider()..init()),

        // Корзина - БЕЗ автоматической загрузки, чтобы избежать двойного вызова
        ChangeNotifierProvider<CartProvider>(
            create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Северная корзина',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AppInitializer(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/auth': (context) => AuthChoiceScreen(),
          '/home': (context) => HomeScreen(),
          '/catalog': (context) => CatalogScreen(),
          '/cart': (context) => CartScreen(),
          '/orders': (context) => OrdersScreen(),
          '/profile': (context) => ProfileScreen(),
          '/payment-success': (context) => PaymentSuccessScreen(),
        },
      ),
    );
  }
}

/// Виджет для инициализации приложения
class AppInitializer extends StatefulWidget {
  @override
  _AppInitializerState createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isInitialized = false;
  bool _updateChecked = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Для веб-версии добавляем больше времени на инициализацию
      if (kIsWeb) {
        // Ждем инициализации LocalStorage
        await Future.delayed(Duration(milliseconds: 500));
      }

      // ВАЖНО: Загружаем сохраненную корзину
      await cartProvider.loadCart();
      print(
          '✅ Корзина загружена при запуске: ${cartProvider.totalItems} товаров');

      // Проверяем статус авторизации
      await authProvider.checkAuthStatus();

      // Если пользователь авторизован, инициализируем OrdersProvider
      if (authProvider.isAuthenticated) {
        final ordersProvider =
            Provider.of<OrdersProvider>(context, listen: false);
        await ordersProvider.init();
        print('✅ OrdersProvider инициализирован');
      }

      setState(() {
        _isInitialized = true;
      });

      // Проверка обновлений только для мобильных
      if (!kIsWeb) {
        _checkForMobileUpdates();
      }
    } catch (e) {
      print('❌ Ошибка инициализации приложения: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _checkForMobileUpdates() async {
    if (_updateChecked) return;
    _updateChecked = true;

    // Ждем немного для полной загрузки UI
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    try {
      final updateService = UpdateService();
      final updateInfo = await updateService.checkForUpdate(silent: true);

      if (updateInfo != null && mounted) {
        if (await updateService.shouldShowUpdateDialog()) {
          updateService.showUpdateDialog(context, updateInfo);
        }
      }
    } catch (e) {
      print('Ошибка проверки обновлений: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип или иконка приложения
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 16),
              Text(
                'Загрузка...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return HomeScreen();
        } else {
          return AuthChoiceScreen();
        }
      },
    );
  }
}
