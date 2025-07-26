// lib/providers/products_provider.dart - ДЛЯ РАБОТЫ С API
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ProductsProvider with ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  // Getters
  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Загружает все товары с сервера
  Future<void> loadProducts({
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getProducts(
        categoryId: categoryId,
        search: search,
        page: page,
        limit: limit,
      );

      if (result['success']) {
        _products = List<Map<String, dynamic>>.from(result['products']);
        print('ProductsProvider: Загружено ${_products.length} товаров');

        // Логируем первый товар для отладки
        if (_products.isNotEmpty) {
          print('ProductsProvider: Первый товар - ${_products.first}');
        }
      } else {
        _error = result['error'] ?? 'Ошибка загрузки товаров';
        print('ProductsProvider: Ошибка - $_error');
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      print('ProductsProvider: Exception - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Загружает категории с сервера
  Future<void> loadCategories() async {
    try {
      final result = await _apiService.getCategories();

      if (result['success']) {
        _categories = List<Map<String, dynamic>>.from(result['categories']);
        print('ProductsProvider: Загружено ${_categories.length} категорий');
      } else {
        print(
            'ProductsProvider: Ошибка загрузки категорий - ${result['error']}');
      }
    } catch (e) {
      print('ProductsProvider: Exception при загрузке категорий - $e');
    }

    notifyListeners();
  }

  /// Получает товар по ID
  Future<Map<String, dynamic>?> getProduct(int productId) async {
    try {
      final result = await _apiService.getProduct(productId);

      if (result['success']) {
        return result['product'];
      } else {
        _error = result['error'];
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Ошибка получения товара';
      notifyListeners();
      return null;
    }
  }

  /// Поиск товаров по запросу
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    await loadProducts(search: query);
  }

  /// Фильтрация товаров по категории
  Future<void> filterByCategory(int? categoryId) async {
    await loadProducts(categoryId: categoryId);
  }

  /// Получает товары по категории (локально из загруженных)
  List<Map<String, dynamic>> getProductsByCategory(int categoryId) {
    return _products.where((product) {
      final productCategory = product['category'];
      return productCategory != null && productCategory['id'] == categoryId;
    }).toList();
  }

  /// Получает товар по ID из загруженных
  Map<String, dynamic>? getProductById(int productId) {
    try {
      return _products.firstWhere((product) => product['id'] == productId);
    } catch (e) {
      return null;
    }
  }

  /// Очищает ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Обновляет данные (pull-to-refresh)
  Future<void> refresh() async {
    await Future.wait([
      loadProducts(),
      loadCategories(),
    ]);
  }

  /// Проверяет, есть ли товары
  bool get hasProducts => _products.isNotEmpty;

  /// Проверяет, есть ли категории
  bool get hasCategories => _categories.isNotEmpty;

  /// Получает количество товаров в категории
  int getProductCountByCategory(int categoryId) {
    return getProductsByCategory(categoryId).length;
  }

  /// Получает популярные товары (первые 10)
  List<Map<String, dynamic>> get popularProducts {
    return _products.take(10).toList();
  }

  /// Получает новые товары (последние добавленные)
  List<Map<String, dynamic>> get newProducts {
    final sortedProducts = List<Map<String, dynamic>>.from(_products);
    sortedProducts.sort((a, b) {
      final aDate = DateTime.parse(a['createdAt'] ?? '2020-01-01');
      final bDate = DateTime.parse(b['createdAt'] ?? '2020-01-01');
      return bDate.compareTo(aDate);
    });
    return sortedProducts.take(10).toList();
  }
}
