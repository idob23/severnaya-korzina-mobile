// lib/providers/cart_provider.dart - ВЕРСИЯ С ПЕРСИСТЕНТНОСТЬЮ
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// Импортируем Product из products_provider
import 'products_provider.dart';

/// Модель элемента корзины
class CartItem {
  final int productId;
  final String name;
  final double price;
  final String unit;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.unit,
    required this.quantity,
  });

  /// Создает копию с изменениями
  CartItem copyWith({
    int? productId,
    String? name,
    double? price,
    String? unit,
    int? quantity,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Общая стоимость позиции
  double get totalPrice => price * quantity;

  /// Форматированная общая стоимость
  String get formattedTotalPrice => '${totalPrice.toStringAsFixed(0)} ₽';

  /// Форматированная цена за единицу
  String get formattedPrice => '${price.toStringAsFixed(0)} ₽';

  /// Преобразование в JSON для сохранения
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'unit': unit,
      'quantity': quantity,
    };
  }

  /// Создание из JSON при загрузке
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      price: json['price'].toDouble(),
      unit: json['unit'],
      quantity: json['quantity'],
    );
  }

  @override
  String toString() {
    return 'CartItem(productId: $productId, name: $name, quantity: $quantity)';
  }
}

/// Провайдер для управления корзиной с персистентностью
class CartProvider with ChangeNotifier {
  Map<int, CartItem> _items = {};
  static const String _cartStorageKey = 'cart_items';

  /// Инициализация провайдера с загрузкой сохраненной корзины
  CartProvider() {
    loadCart();
  }

  /// Получает все элементы корзины
  Map<int, CartItem> get items => _items;

  /// Получает список элементов корзины
  List<CartItem> get itemsList => _items.values.toList();

  /// Проверяет, пуста ли корзина
  bool get isEmpty => _items.isEmpty;

  /// Проверяет, есть ли товары в корзине
  bool get isNotEmpty => _items.isNotEmpty;

  /// Получает общее количество товаров в корзине
  int get totalItems {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Получает общую стоимость корзины
  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  /// Получает форматированную общую стоимость
  String get formattedTotalAmount {
    return '${totalAmount.toStringAsFixed(0)} ₽';
  }

  /// Добавляет товар в корзину
  void addItem({
    required int productId,
    required String name,
    required double price,
    required String unit,
    int quantity = 1,
  }) {
    if (_items.containsKey(productId)) {
      // Если товар уже есть в корзине, увеличиваем количество
      _items[productId]!.quantity += quantity;
    } else {
      // Если товара нет, добавляем новый
      _items[productId] = CartItem(
        productId: productId,
        name: name,
        price: price,
        unit: unit,
        quantity: quantity,
      );
    }

    saveCart(); // Сохраняем после изменения
    notifyListeners();

    if (kDebugMode) {
      print('CartProvider: Добавлен товар $name (количество: $quantity)');
    }
  }

  /// НОВЫЙ МЕТОД: Добавляет товар по объекту Product (нужен для CatalogScreen)
  void addProduct(Product product, int quantity) {
    addItem(
      productId: product.id,
      name: product.name,
      price: product.price,
      unit: product.unit,
      quantity: quantity,
    );
  }

  /// Удаляет товар из корзины
  void removeItem(int productId) {
    if (_items.containsKey(productId)) {
      final removedItem = _items.remove(productId);
      saveCart(); // Сохраняем после изменения
      notifyListeners();

      if (kDebugMode) {
        print('CartProvider: Удален товар ${removedItem?.name}');
      }
    }
  }

  /// Обновляет количество товара
  void updateQuantity(int productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        _items[productId]!.quantity = quantity;
        saveCart(); // Сохраняем после изменения
        notifyListeners();

        if (kDebugMode) {
          print(
              'CartProvider: Обновлено количество для ${_items[productId]!.name}: $quantity');
        }
      }
    }
  }

  /// НОВЫЙ МЕТОД: Обновляет количество товара (альтернативное название для CatalogScreen)
  void updateProductQuantity(int productId, int quantity) {
    updateQuantity(productId, quantity);
  }

  /// Увеличивает количество товара на 1
  void incrementItem(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      saveCart(); // Сохраняем после изменения
      notifyListeners();
    }
  }

  /// Уменьшает количество товара на 1
  void decrementItem(int productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]!.quantity > 1) {
        _items[productId]!.quantity--;
        saveCart(); // Сохраняем после изменения
        notifyListeners();
      } else {
        removeItem(productId);
      }
    }
  }

  /// Проверяет, есть ли товар в корзине
  bool containsProduct(int productId) {
    return _items.containsKey(productId);
  }

  /// Получает количество конкретного товара в корзине
  int getProductQuantity(int productId) {
    return _items[productId]?.quantity ?? 0;
  }

  /// Получает элемент корзины по ID товара
  CartItem? getCartItem(int productId) {
    return _items[productId];
  }

  /// Очищает корзину
  void clearCart() {
    _items.clear();
    saveCart(); // Сохраняем пустую корзину
    notifyListeners();

    if (kDebugMode) {
      print('CartProvider: Корзина очищена');
    }
  }

  /// Получает данные для создания заказа
  List<Map<String, dynamic>> getOrderItems() {
    return _items.values
        .map((item) => {
              'productId': item.productId,
              'quantity': item.quantity,
              'price': item.price,
              'name': item.name, // для удобства отображения
            })
        .toList();
  }

  /// Получает краткую сводку корзины
  Map<String, dynamic> getCartSummary() {
    return {
      'totalItems': totalItems,
      'totalAmount': totalAmount,
      'itemsCount': _items.length,
      'isEmpty': isEmpty,
    };
  }

  /// Сохраняет корзину в локальное хранилище
  Future<void> saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_items.isEmpty) {
        // Если корзина пуста, удаляем данные
        await prefs.remove(_cartStorageKey);
        if (kDebugMode) {
          print('CartProvider: Корзина пуста, удалены сохраненные данные');
        }
      } else {
        // Преобразуем корзину в JSON
        final cartData = _items
            .map((key, value) => MapEntry(key.toString(), value.toJson()));
        final jsonString = jsonEncode(cartData);

        // Сохраняем в SharedPreferences
        await prefs.setString(_cartStorageKey, jsonString);

        if (kDebugMode) {
          print('CartProvider: Корзина сохранена (${_items.length} товаров)');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('CartProvider: Ошибка сохранения корзины: $e');
      }
    }
  }

  /// Загружает корзину из локального хранилища
  Future<void> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_cartStorageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> cartData = jsonDecode(jsonString);

        _items.clear();
        cartData.forEach((key, value) {
          final productId = int.parse(key);
          _items[productId] = CartItem.fromJson(value);
        });

        notifyListeners();

        if (kDebugMode) {
          print('CartProvider: Корзина загружена (${_items.length} товаров)');
        }
      } else {
        if (kDebugMode) {
          print('CartProvider: Нет сохраненной корзины');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('CartProvider: Ошибка загрузки корзины: $e');
      }
      // В случае ошибки очищаем корзину
      _items.clear();
    }
  }

  /// Принудительное обновление
  void forceUpdate() {
    notifyListeners();
  }
}
