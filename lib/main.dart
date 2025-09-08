// lib/main.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ БЕЗ ОШИБОК ИНТЕРПОЛЯЦИИ
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
          fontFamily: 'MarckScript',

          // 🔴 ЗНАЧИТЕЛЬНО УВЕЛИЧЕННЫЕ РАЗМЕРЫ ШРИФТОВ
          textTheme: TextTheme(
            // Очень крупные заголовки
            displayLarge: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 42,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            displayMedium: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 38,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            displaySmall: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 34,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),

            // Заголовки экранов и разделов
            headlineLarge: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 32,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            headlineMedium: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 30,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            headlineSmall: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 28,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),

            // Заголовки в списках и карточках
            titleLarge: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 26,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            titleMedium: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),
            titleSmall: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.3,
            ),

            // Основной текст - ЗНАЧИТЕЛЬНО УВЕЛИЧЕН
            bodyLarge: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            bodyMedium: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            bodySmall: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),

            // Кнопки и метки - УВЕЛИЧЕНЫ
            labelLarge: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 22,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
            labelMedium: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
            labelSmall: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),

          // 🔴 AppBar - увеличенный заголовок и высота
          appBarTheme: AppBarTheme(
            titleTextStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 30,
              fontWeight: FontWeight.w400,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
            toolbarHeight: 70,
            iconTheme: IconThemeData(
              size: 28,
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: TextStyle(
                fontFamily: 'MarckScript',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ),

          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              textStyle: TextStyle(
                fontFamily: 'MarckScript',
                fontSize: 22,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // 🔴 Поля ввода - увеличенный текст
          inputDecorationTheme: InputDecorationTheme(
            labelStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 22,
            ),
            hintStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 21,
              color: Colors.grey,
            ),
            helperStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 18,
            ),
            errorStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 18,
              color: Colors.red,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),

          // 🔴 ListTile - увеличенные размеры для списков
          listTileTheme: ListTileThemeData(
            titleTextStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 24,
              color: Colors.black87,
            ),
            subtitleTextStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 20,
              color: Colors.black54,
              height: 1.3,
            ),
            minVerticalPadding: 14,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),

          // 🔴 Карточки - увеличенные отступы
          cardTheme: CardThemeData(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // 🔴 Чипы (теги категорий)
          chipTheme: ChipThemeData(
            labelStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 20,
            ),
            labelPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            padding: EdgeInsets.all(8),
          ),

          // 🔴 Табы
          tabBarTheme: const TabBarThemeData(
            labelStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 21,
              fontWeight: FontWeight.w400,
            ),
            indicatorSize: TabBarIndicatorSize.label,
          ),

          // 🔴 BottomNavigationBar - увеличенные иконки и текст
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedLabelStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 18,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 17,
            ),
            selectedIconTheme: IconThemeData(size: 32),
            unselectedIconTheme: IconThemeData(size: 30),
            type: BottomNavigationBarType.fixed,
          ),

          // 🔴 Диалоги
          dialogTheme: const DialogThemeData(
            titleTextStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 26,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
            contentTextStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 22,
              color: Colors.black87,
              height: 1.4,
            ),
          ),

          // 🔴 SnackBar
          snackBarTheme: SnackBarThemeData(
            contentTextStyle: TextStyle(
              fontFamily: 'MarckScript',
              fontSize: 20,
              color: Colors.white,
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
