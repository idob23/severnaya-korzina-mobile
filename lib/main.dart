import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/cart_provider.dart';
import 'package:severnaya_korzina/providers/auth_provider.dart';
import 'package:severnaya_korzina/providers/products_provider.dart'; // НОВЫЙ
import 'package:severnaya_korzina/providers/orders_provider.dart'; // НОВЫЙ
import 'screens/catalog/catalog_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'package:severnaya_korzina/screens/auth/auth_choice_screen.dart';
import 'screens/home/home_screen.dart';

void main() {
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
            create: (context) => OrdersProvider()),
        
        // Корзина
        ChangeNotifierProvider<CartProvider>(
            create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Северная корзина',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: AuthChoiceScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    CatalogScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Каталог',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
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