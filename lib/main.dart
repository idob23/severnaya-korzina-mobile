// lib/main.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ БЕЗ ОШИБОК ИНТЕРПОЛЯЦИИ
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
import 'package:severnaya_korzina/services/update_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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

// ДОБАВИТЬ эту функцию:
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
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter', // или ваш текущий шрифт
        ),
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

        // 🔴 ГЛОБАЛЬНОЕ УВЕЛИЧЕНИЕ ВСЕХ ШРИФТОВ НА 40%
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor:
                  1.2, // Увеличивает ВСЕ тексты в приложении на 40%
            ),
            child: child!,
          );
        },

        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Inter',

          // 🔴 ЗНАЧИТЕЛЬНО УВЕЛИЧЕННЫЕ РАЗМЕРЫ ШРИФТОВ
          textTheme: TextTheme(
            // Очень крупные заголовки
            displayLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 32, // Уменьшено с 42
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            displayMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 28, // Уменьшено с 38
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            displaySmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24, // Уменьшено с 34
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),

            // Заголовки экранов и разделов
            headlineLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22, // Уменьшено с 32
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20, // Уменьшено с 30
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18, // Уменьшено с 28
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),

            // Заголовки в списках и карточках
            titleLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18, // Уменьшено с 26
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
            titleMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16, // Уменьшено с 24
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            titleSmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14, // Уменьшено с 22
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),

            // Основной текст - ОПТИМАЛЬНЫЕ РАЗМЕРЫ
            bodyLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16, // Уменьшено с 24 (идеально для чтения)
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.15,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14, // Уменьшено с 22 (стандарт для мобильных)
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.15,
            ),
            bodySmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12, // Уменьшено с 20
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0.15,
            ),

            // Кнопки и метки - УВЕЛИЧЕНЫ
            labelLarge: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16, // Уменьшено с 22
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            labelMedium: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14, // Уменьшено с 20
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            labelSmall: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12, // Уменьшено с 18
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
          ),

          // 🎯 AppBar - нормальный размер
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20, // Уменьшено с 30
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            toolbarHeight: 56, // Стандартная высота (было 70)
            iconTheme: IconThemeData(
              size: 24, // Стандартный размер (было 28)
              color: Colors.white,
            ),
          ),

          // 🔴 Кнопки - увеличенный текст и отступы
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: Size(100, 50),
              textStyle: TextStyle(
                fontFamily: 'MarckScript',
                fontSize: 24,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ),

          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              textStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16, // Уменьшено с 24
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              textStyle: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16, // Уменьшено с 24
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
          ),

          // 📝 Поля ввода
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
            errorStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),

          // 📦 Карточки
          cardTheme: CardThemeData(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // 🏷️ Чипы
          chipTheme: ChipThemeData(
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14, // Уменьшено с 20
              fontWeight: FontWeight.w500,
            ),
            labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            padding: EdgeInsets.all(6),
          ),

          // 📑 Табы
          tabBarTheme: TabBarThemeData(
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16, // Уменьшено с 22
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 15, // Уменьшено с 21
              fontWeight: FontWeight.w400,
            ),
            indicatorSize: TabBarIndicatorSize.label,
          ),

          // 🧭 BottomNavigationBar
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12, // Уменьшено с 18
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11, // Уменьшено с 17
              fontWeight: FontWeight.w400,
            ),
            selectedIconTheme: IconThemeData(size: 28), // Было 32
            unselectedIconTheme: IconThemeData(size: 26), // Было 30
            type: BottomNavigationBarType.fixed,
          ),

          // 💬 Диалоги
          dialogTheme: DialogThemeData(
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20, // Уменьшено с 26
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            contentTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16, // Уменьшено с 22
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
          // 🍞 SnackBar
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14, // Уменьшено с 20
              fontWeight: FontWeight.w400,
            ),
          ),

          // 🎯 ListTile
          listTileTheme: ListTileThemeData(
            titleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            subtitleTextStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey[700],
            ),
          ),

          // Иконки - увеличенный размер по умолчанию
          iconTheme: IconThemeData(
            size: 26,
          ),
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
                  fontFamily: 'MarckScript',
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
