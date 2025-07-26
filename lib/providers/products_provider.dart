// lib/providers/products_provider.dart - ПОЛНЫЙ ФАЙЛ
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

/// Модель товара
class Product {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final String unit;
  final int minQuantity;
  final int? maxQuantity;
  final bool isActive;
  final DateTime createdAt;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    required this.price,
    required this.unit,
    this.minQuantity = 1,
    this.maxQuantity,
    this.isActive = true,
    required this.createdAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      price: (json['price'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'шт',
      minQuantity: json['minQuantity'] ?? 1,
      maxQuantity: json['maxQuantity'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'price': price,
      'unit': unit,
      'minQuantity': minQuantity,
      'maxQuantity': maxQuantity,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Форматированная цена
  String get formattedPrice {
    return '${price.toStringAsFixed(0)} ₽';
  }

  /// Полное описание с единицей измерения
  String get fullDescription {
    final desc = description ?? '';
    return desc.isNotEmpty ? '$desc ($unit)' : unit;
  }

  /// Проверяет, есть ли изображение
  bool get hasImage {
    return imageUrl != null && imageUrl!.isNotEmpty;
  }

  /// Получает URL изображения или плейсхолдер
  String get displayImageUrl {
    if (hasImage) return imageUrl!;
    return 'https://via.placeholder.com/300x200/E3F2FD/1565C0?text=${Uri.encodeComponent(name)}';
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $formattedPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Модель категории
class Category {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isActive;
  final int? productsCount;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.isActive = true,
    this.productsCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['imageUrl'],
      isActive: json['isActive'] ?? true,
      productsCount: json['_count']?['products'] ?? json['productsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isActive': isActive,
    };
  }

  /// Проверяет, есть ли изображение
  bool get hasImage {
    return imageUrl != null && imageUrl!.isNotEmpty;
  }

  /// Получает URL изображения или плейсхолдер
  String get displayImageUrl {
    if (hasImage) return imageUrl!;
    return 'https://via.placeholder.com/150x150/E8F5E8/4CAF50?text=${Uri.encodeComponent(name)}';
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, productsCount: $productsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Провайдер для управления товарами и категориями
class ProductsProvider with ChangeNotifier {
  // Приватные поля
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  bool _isLoadingCategories = false;
  String? _error;
  int? _selectedCategoryId;
  String _searchQuery = '';

  final ApiService _apiService = ApiService();

  // Геттеры
  List<Product> get products => _products;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;

  /// Получает отфильтрованные товары
  List<Product> get filteredProducts {
    var filtered = _products;

    // Фильтр по категории
    if (_selectedCategoryId != null) {
      filtered = filtered
          .where((product) => product.category?.id == _selectedCategoryId)
          .toList();
    }

    // Поиск по названию
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((product) =>
              product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (product.description
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false))
          .toList();
    }

    return filtered;
  }

  /// Получает количество товаров в категории
  int getProductsCountInCategory(int categoryId) {
    return _products
        .where((product) => product.category?.id == categoryId)
        .length;
  }

  /// Проверяет, есть ли товары в категории
  bool hasCategoryProducts(int categoryId) {
    return getProductsCountInCategory(categoryId) > 0;
  }

  /// Загружает все товары с сервера
  Future<void> loadProducts({
    int? categoryId,
    String? search,
    int page = 1,
    int limit = 50,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final result = await _apiService.getProducts(
        categoryId: categoryId,
        search: search,
        page: page,
        limit: limit,
      );

      if (result['success']) {
        final productsList = result['products'] as List;
        _products = productsList.map((json) => Product.fromJson(json)).toList();

        if (kDebugMode) {
          print('ProductsProvider: Загружено ${_products.length} товаров');
        }
      } else {
        _error = result['error'] ?? 'Ошибка загрузки товаров';
        if (kDebugMode) {
          print('ProductsProvider: Ошибка - $_error');
        }
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      if (kDebugMode) {
        print('ProductsProvider: Exception - $e');
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Загружает категории с сервера
  Future<void> loadCategories({bool silent = false}) async {
    if (!silent) {
      _isLoadingCategories = true;
      notifyListeners();
    }

    try {
      final result = await _apiService.getCategories();

      if (result['success']) {
        final categoriesList = result['categories'] as List;
        _categories =
            categoriesList.map((json) => Category.fromJson(json)).toList();

        if (kDebugMode) {
          print('ProductsProvider: Загружено ${_categories.length} категорий');
        }
      } else {
        if (kDebugMode) {
          print(
              'ProductsProvider: Ошибка загрузки категорий - ${result['error']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ProductsProvider: Exception при загрузке категорий - $e');
      }
    } finally {
      if (!silent) {
        _isLoadingCategories = false;
        notifyListeners();
      }
    }
  }

  /// Получает товар по ID
  Future<Product?> getProduct(int productId) async {
    try {
      // Сначала ищем в загруженных товарах
      final existingProducts = _products.where((p) => p.id == productId);
      if (existingProducts.isNotEmpty) {
        return existingProducts.first;
      }

      // Если не найден, загружаем с сервера
      final result = await _apiService.getProduct(productId);

      if (result['success']) {
        final product = Product.fromJson(result['product']);

        // Добавляем в список, если его там нет
        if (!_products.any((p) => p.id == product.id)) {
          _products.add(product);
          notifyListeners();
        }

        return product;
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
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      await loadProducts();
    } else {
      await loadProducts(search: _searchQuery);
    }
  }

  /// Фильтрация товаров по категории
  Future<void> filterByCategory(int? categoryId) async {
    _selectedCategoryId = categoryId;
    await loadProducts(
        categoryId: categoryId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null);
  }

  /// Сброс фильтров
  Future<void> clearFilters() async {
    _selectedCategoryId = null;
    _searchQuery = '';
    await loadProducts();
  }

  /// Очищает поисковый запрос
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Устанавливает поисковый запрос без загрузки
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Обновляет все данные
  Future<void> refresh() async {
    await Future.wait([
      loadCategories(silent: true),
      loadProducts(
        silent: true,
        categoryId: _selectedCategoryId,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      ),
    ]);
    notifyListeners();
  }

  /// Инициализация провайдера
  Future<void> init() async {
    await loadCategories();
    await loadProducts();
  }

  /// Получает категорию по ID
  Category? getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((cat) => cat.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  /// Получает товары определенной категории
  List<Product> getProductsByCategory(int categoryId) {
    return _products
        .where((product) => product.category?.id == categoryId)
        .toList();
  }

  /// Получает популярные товары (первые N)
  List<Product> getPopularProducts({int limit = 10}) {
    return _products.take(limit).toList();
  }

  /// Получает товары со скидкой (placeholder для будущей реализации)
  List<Product> getDiscountedProducts() {
    return _products;
  }

  /// Проверяет доступность товара для заказа
  bool isProductAvailable(Product product, int quantity) {
    if (!product.isActive) return false;
    if (quantity < product.minQuantity) return false;
    if (product.maxQuantity != null && quantity > product.maxQuantity!)
      return false;
    return true;
  }

  /// Получает рекомендованное количество для товара
  int getRecommendedQuantity(Product product) {
    return product.minQuantity;
  }

  /// Получает максимально допустимое количество
  int getMaxAllowedQuantity(Product product) {
    return product.maxQuantity ?? 999;
  }

  /// Проверяет, можно ли увеличить количество
  bool canIncreaseQuantity(Product product, int currentQuantity) {
    if (product.maxQuantity == null) return true;
    return currentQuantity < product.maxQuantity!;
  }

  /// Проверяет, можно ли уменьшить количество
  bool canDecreaseQuantity(Product product, int currentQuantity) {
    return currentQuantity > product.minQuantity;
  }

  /// Получает сообщение об ошибке количества
  String? getQuantityErrorMessage(Product product, int quantity) {
    if (quantity < product.minQuantity) {
      return 'Минимальное количество: ${product.minQuantity} ${product.unit}';
    }

    if (product.maxQuantity != null && quantity > product.maxQuantity!) {
      return 'Максимальное количество: ${product.maxQuantity} ${product.unit}';
    }

    return null;
  }

  /// Получает статистику товаров
  Map<String, int> getProductsStats() {
    return {
      'total': _products.length,
      'active': _products.where((p) => p.isActive).length,
      'categories': _categories.length,
      'filtered': filteredProducts.length,
    };
  }

  /// Проверяет, загружены ли данные
  bool get hasData => _products.isNotEmpty || _categories.isNotEmpty;

  /// Проверяет, есть ли выбранная категория
  bool get hasSelectedCategory => _selectedCategoryId != null;

  /// Проверяет, есть ли поисковый запрос
  bool get hasSearchQuery => _searchQuery.isNotEmpty;

  /// Проверяет, применены ли фильтры
  bool get hasActiveFilters => hasSelectedCategory || hasSearchQuery;

  /// Получает название выбранной категории
  String? get selectedCategoryName {
    if (_selectedCategoryId == null) return null;
    final category = getCategoryById(_selectedCategoryId!);
    return category?.name;
  }

  /// Очищает ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Принудительное обновление без сброса данных
  void forceUpdate() {
    notifyListeners();
  }
}
