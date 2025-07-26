import 'package:flutter/foundation.dart';
import 'package:severnaya_korzina/models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.approximatePrice * quantity;
}

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get prepaymentAmount => totalAmount * 0.9; // 90%

  void addItem(Product product, {int quantity = 1}) {
    print('🔄 addItem вызван для: ${product.name}');

    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      print('📈 Увеличиваем количество существующего товара');
      _items[existingIndex].quantity += quantity;
    } else {
      print('🆕 Добавляем новый товар');
      _items.add(CartItem(product: product, quantity: quantity));
    }

    print('📦 Всего товаров в корзине: ${_items.length}');
    print('🔔 Вызываем notifyListeners()');
    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(int productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
