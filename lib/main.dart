// // lib/main.dart - ПОЛНАЯ ИСПРАВЛЕННАЯ ВЕРСИЯ
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:severnaya_korzina/providers/cart_provider.dart';
// import 'package:severnaya_korzina/providers/auth_provider.dart';
// import 'package:severnaya_korzina/providers/products_provider.dart';
// import 'package:severnaya_korzina/providers/orders_provider.dart';
// import 'screens/catalog/catalog_screen.dart';
// import 'screens/cart/cart_screen.dart';
// import 'screens/orders/orders_screen.dart';
// import 'screens/profile/profile_screen.dart';
// import 'package:severnaya_korzina/screens/auth/auth_choice_screen.dart';
// import 'screens/payment/payment_success_screen.dart';
// import 'package:severnaya_korzina/services/update_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Инициализация сервиса обновлений
//   await UpdateService().init();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Авторизация
//         ChangeNotifierProvider<AuthProvider>(
//             create: (context) => AuthProvider()..init()),

//         // Товары и каталог
//         ChangeNotifierProvider<ProductsProvider>(
//             create: (context) => ProductsProvider()),

//         // Заказы - ИСПРАВЛЕНО: инициализируем сразу при создании
//         ChangeNotifierProvider<OrdersProvider>(
//             create: (context) => OrdersProvider()..init()),

//         // Корзина
//         ChangeNotifierProvider<CartProvider>(
//             create: (context) => CartProvider()),
//       ],
//       child: MaterialApp(
//         title: 'Северная корзина',
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: AppInitializer(),
//         debugShowCheckedModeBanner: false,
//         // // ДОБАВЬТЕ ЭТО:
//         // routes: {
//         //   '/payment-success': (context) => PaymentSuccessScreen(),
//         // },
//       ),
//     );
//   }
// }

// /// Виджет для инициализации приложения
// class AppInitializer extends StatefulWidget {
//   @override
//   _AppInitializerState createState() => _AppInitializerState();
// }

// class _AppInitializerState extends State<AppInitializer> {
//   bool _isInitialized = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeApp();
//   }

//   Future<void> _initializeApp() async {
//     try {
//       // Ждем инициализации AuthProvider
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       await authProvider.checkAuthStatus();

//       // Если пользователь авторизован, инициализируем OrdersProvider
//       if (authProvider.isAuthenticated) {
//         final ordersProvider =
//             Provider.of<OrdersProvider>(context, listen: false);
//         await ordersProvider.init();
//       }

//       setState(() {
//         _isInitialized = true;
//       });

//       // НОВОЕ: Проверяем обновления после инициализации
//       _checkForUpdates();
//     } catch (e) {
//       print('Ошибка инициализации приложения: $e');
//       setState(() {
//         _isInitialized = true;
//       });
//     }
//   }

//   // НОВЫЙ МЕТОД: Проверка обновлений
//   Future<void> _checkForUpdates() async {
//     // Ждем 2 секунды, чтобы UI полностью загрузился
//     await Future.delayed(Duration(seconds: 2));

//     if (!mounted) return;

//     final updateService = UpdateService(); // Создаем локально
//     final updateInfo = await updateService.checkForUpdate(silent: true);

//     if (updateInfo != null && mounted) {
//       if (await updateService.shouldShowUpdateDialog()) {
//         updateService.showUpdateDialog(context, updateInfo);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               SizedBox(height: 16),
//               Text('Инициализация приложения...'),
//             ],
//           ),
//         ),
//       );
//     }

//     return Consumer<AuthProvider>(
//       builder: (context, authProvider, child) {
//         if (authProvider.isAuthenticated) {
//           return HomeScreen();
//         } else {
//           return AuthChoiceScreen();
//         }
//       },
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;

//   final List<Widget> _screens = [
//     CatalogScreen(),
//     CartScreen(),
//     OrdersScreen(),
//     ProfileScreen(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         currentIndex: _currentIndex,
//         onTap: (index) => setState(() => _currentIndex = index),
//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.store),
//             label: 'Каталог',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.shopping_cart),
//             label: 'Корзина',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.list_alt),
//             label: 'Заказы',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Профиль',
//           ),
//         ],
//       ),
//     );
//   }

//   // НОВЫЙ МЕТОД: AppBar для каталога с кнопкой обновлений
//   PreferredSizeWidget _buildCatalogAppBar() {
//     return AppBar(
//       title: Text('Северная Корзина'),
//       backgroundColor: Colors.blue,
//       foregroundColor: Colors.white,
//       actions: [
//         PopupMenuButton<String>(
//           onSelected: (value) async {
//             if (value == 'check_updates') {
//               await _manualCheckForUpdates();
//             }
//           },
//           itemBuilder: (BuildContext context) => [
//             PopupMenuItem<String>(
//               value: 'check_updates',
//               child: Row(
//                 children: [
//                   Icon(Icons.system_update, color: Colors.black54),
//                   SizedBox(width: 8),
//                   Text('Проверить обновления'),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   // НОВЫЙ МЕТОД: Ручная проверка обновлений
//   Future<void> _manualCheckForUpdates() async {
//     final updateService = UpdateService(); // Создаем локально

//     // Показываем индикатор загрузки
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Center(
//         child: CircularProgressIndicator(),
//       ),
//     );

//     // Проверяем обновления
//     final updateInfo = await updateService.checkForUpdate();

//     // Закрываем индикатор
//     if (mounted) Navigator.of(context).pop();

//     if (updateInfo != null && mounted) {
//       // Показываем диалог обновления
//       updateService.showUpdateDialog(context, updateInfo);
//     } else if (mounted) {
//       // Показываем сообщение, что обновлений нет
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('У вас установлена последняя версия приложения'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
// }

// lib/main.dart - ПОЛНАЯ ВЕРСИЯ С ИСПРАВЛЕННЫМИ ОБНОВЛЕНИЯМИ
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
import 'package:severnaya_korzina/screens/auth/auth_choice_screen.dart';
import 'screens/payment/payment_success_screen.dart';
import 'package:severnaya_korzina/services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация сервиса обновлений
  await UpdateService().init();

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

        // Корзина
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
      // Инициализация провайдеров
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productsProvider =
          Provider.of<ProductsProvider>(context, listen: false);
      final ordersProvider =
          Provider.of<OrdersProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Параллельная инициализация основных провайдеров
      await Future.wait([
        authProvider.init(),
        productsProvider.init(),
        if (authProvider.isAuthenticated) ordersProvider.loadOrders(),
      ]);

      // Загружаем корзину ОТДЕЛЬНО после основной инициализации
      await cartProvider.loadCart();

      setState(() {
        _isInitialized = true;
      });

      // Проверка обновлений после инициализации
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Ждем немного для плавного появления UI
        await Future.delayed(Duration(milliseconds: 500));

        if (!mounted) return;

        _checkForUpdates();
      });
    } catch (e) {
      print('Ошибка инициализации: $e');
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _checkForUpdates() async {
    // Защита от повторных проверок
    if (_updateChecked) return;
    _updateChecked = true;

    try {
      print('🔄 Автоматическая проверка обновлений...');

      final updateService = UpdateService();
      final updateInfo = await updateService.checkForUpdate(silent: false);

      if (updateInfo != null && mounted) {
        print('📱 Обновление доступно: v${updateInfo.latestVersion}');
        print('📱 Текущая версия: v${updateInfo.currentVersion}');

        // Всегда показываем диалог для обязательных обновлений
        print('📢 Показываем обязательный диалог обновления');
        await updateService.showUpdateDialog(context, updateInfo);
      } else {
        print('✅ Приложение актуально или сервер недоступен');
      }
    } catch (e) {
      print('❌ Ошибка при проверке обновлений: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              SizedBox(height: 16),
              Text(
                'Загрузка...',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return MainScreen();
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    CatalogScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Stack(
                  children: [
                    Icon(Icons.shopping_cart),
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
            icon: Icon(Icons.receipt_long),
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
