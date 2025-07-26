// lib/main.dart - ОБНОВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/orders_provider.dart';
import 'package:severnaya_korzina/providers/products_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'services/local_storage_service.dart';
import 'screens/auth/auth_choice_screen.dart';
import 'screens/home/home_screen.dart';

void main() async {
  // Инициализация Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Настройка ориентации экрана (только портретная)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Настройка статус бара
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Инициализация локального хранилища
  try {
    await LocalStorageService.instance.init();
    print('✅ Local Storage инициализирован');
  } catch (e) {
    print('❌ Ошибка инициализации Local Storage: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Провайдер авторизации
        ChangeNotifierProvider(
          create: (context) => AuthProvider()..init(),
        ),

        // Провайдер корзины
        ChangeNotifierProvider(
          create: (context) => CartProvider(),
        ),
        ChangeNotifierProvider(create: (context) => ProductsProvider()),
        ChangeNotifierProvider(create: (context) => OrdersProvider()),
        // Здесь можно добавить другие провайдеры
      ],
      child: MaterialApp(
        title: 'Северная корзина',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          fontFamily: 'Roboto',

          // Общие настройки темы
          visualDensity: VisualDensity.adaptivePlatformDensity,

          // Настройки AppBar
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),

          // Настройки кнопок
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),

          // Настройки текстовых полей
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),

          // Настройки карточек
          cardTheme: const CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),

          // Настройки Snackbar
          snackBarTheme: SnackBarThemeData(
            backgroundColor: Colors.grey[800],
            contentTextStyle: TextStyle(color: Colors.white),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),

        // Стартовый экран
        home: AppStartupScreen(),

        // Настройка роутинга
        routes: {
          '/auth': (context) => AuthChoiceScreen(),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

/// Экран загрузки приложения с проверкой авторизации
class AppStartupScreen extends StatefulWidget {
  @override
  _AppStartupScreenState createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Настройка анимаций
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Запуск анимации
    _animationController.forward();

    // Проверка авторизации
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Минимальное время показа splash screen
    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Ждем завершения проверки авторизации
    while (authProvider.isLoading) {
      await Future.delayed(Duration(milliseconds: 100));
      if (!mounted) return;
    }

    // Навигация в зависимости от статуса авторизации
    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AuthChoiceScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[400]!,
              Colors.blue[600]!,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Логотип
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.shopping_basket,
                          size: 60,
                          color: Colors.blue[600],
                        ),
                      ),
                      SizedBox(height: 32),

                      // Название приложения
                      Text(
                        'Северная корзина',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 8),

                      // Подзаголовок
                      Text(
                        'Коллективные закупки',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 60),

                      // Индикатор загрузки
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),
                      ),
                      SizedBox(height: 16),

                      Text(
                        'Загрузка...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

/// Обработчик ошибок приложения
class AppErrorHandler {
  static void init() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Логирование ошибок
      print('Flutter Error: ${details.exception}');
      print('Stack trace: ${details.stack}');

      // В продакшене здесь можно отправлять ошибки в Crashlytics
    };
  }

  static void handleError(dynamic error, StackTrace? stackTrace) {
    print('App Error: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }

    // Здесь можно добавить отправку ошибок на сервер
  }
}
