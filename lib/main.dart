// lib/main.dart - ВЕРСИЯ С НОВОЙ ТЕМОЙ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/cart_provider.dart';
import 'package:severnaya_korzina/providers/auth_provider.dart';
import 'package:severnaya_korzina/providers/products_provider.dart';
import 'package:severnaya_korzina/providers/orders_provider.dart';
import 'package:severnaya_korzina/screens/maintenance_screen.dart';
import 'package:severnaya_korzina/services/api_service.dart';
import 'screens/catalog/catalog_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/home/home_screen.dart';
import 'package:severnaya_korzina/screens/auth/auth_choice_screen.dart';
import 'screens/payment/payment_success_screen.dart';
import 'screens/payment/payment_checking_web_screen.dart';
import 'package:severnaya_korzina/services/update_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
// Импортируем новую тему вместо старых цветов
import 'design_system/theme/app_theme.dart';
import 'screens/auth/sms_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Проверяем режим обслуживания
  final shouldContinue = await _checkMaintenanceStatus();

  if (!shouldContinue) {
    return; // Если режим обслуживания, не продолжаем
  }

  // Инициализация сервиса обновлений
  try {
    await UpdateService().init();
  } catch (e) {
    print('Ошибка инициализации UpdateService: $e');
    // Продолжаем работу даже при ошибке
  }

  runApp(MyApp());
}

Future<bool> _checkMaintenanceStatus() async {
  try {
    final apiService = ApiService();
    final statusResponse = await apiService.checkAppStatus();

    // Проверяем только режим обслуживания
    if (statusResponse['maintenance'] == true) {
      final maintenanceDetails = statusResponse['maintenance_details'];

      // Запускаем приложение с экраном обслуживания
      runApp(MaterialApp(
        title: 'Северная Корзина',
        theme: AppTheme.lightTheme, // Используем новую тему
        home: MaintenanceScreen(
          message: maintenanceDetails?['message'] ??
              'Проводятся технические работы. Приложение временно недоступно.',
          endTime: maintenanceDetails?['end_time'],
        ),
        debugShowCheckedModeBanner: false,
      ));

      return false; // Не продолжаем загрузку
    }

    return true; // Продолжаем нормальную загрузку
  } catch (e) {
    print('Ошибка проверки статуса: $e');
    // При ошибке продолжаем работу
    return true;
  }
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
        title: 'Северная Корзина',

        // 🔴 СОХРАНЯЕМ ГЛОБАЛЬНОЕ УВЕЛИЧЕНИЕ ВСЕХ ШРИФТОВ НА 20%
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor:
                  1.2, // Увеличивает ВСЕ тексты в приложении на 20%
            ),
            child: child!,
          );
        },

        // Используем новую тему из AppTheme
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        home: AppInitializer(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/auth': (context) => AuthChoiceScreen(),
          '/home': (context) => HomeScreen(),
          '/catalog': (context) => CatalogScreen(),
          '/payment-checking': (context) => PaymentCheckingWebScreen(),
          '/cart': (context) => CartScreen(),
          '/orders': (context) => OrdersScreen(),
          '/profile': (context) => ProfileScreen(),
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

class _AppInitializerState extends State<AppInitializer>
    with WidgetsBindingObserver {
  bool _isInitialized = false;
  bool _updateChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeApp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('🔄 Приложение возобновлено, проверяем pending update');
      _checkPendingUpdateOnResume();
    }
  }

  Future<void> _checkPendingUpdateOnResume() async {
    if (!mounted || kIsWeb) return;

    try {
      final updateService = UpdateService();
      await updateService.checkPendingUpdate(context);
    } catch (e) {
      print('Ошибка проверки pending update: $e');
    }
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

      // Проверяем незавершённую верификацию SMS
      final pendingSmsPhone = await authProvider.getPendingSmsPhone();

      if (pendingSmsPhone != null) {
        if (kDebugMode) {
          print('📱 Найдена незавершённая верификация для: $pendingSmsPhone');
        }

        setState(() {
          _isInitialized = true;
        });

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SMSVerificationScreen(
                phone: pendingSmsPhone,
                rememberMe: true,
              ),
            ),
          );
        }
        return; // ✅ ВАЖНО: выходим из метода
      }

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

      // НОВОЕ: Сначала проверяем незавершенные обновления
      await updateService.checkPendingUpdate(context);

      final updateInfo = await updateService.checkForUpdate();

      if (updateInfo != null && mounted) {
        updateService.showUpdateDialog(context, updateInfo);
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
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shopping_cart,
                  size: 50,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              SizedBox(height: 20),
              Text(
                'Загрузка...',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontFamily: 'Inter',
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
