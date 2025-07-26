// lib/providers/orders_provider.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

/// Модель заказа
class Order {
  final int id;
  final int userId;
  final int addressId;
  final int? batchId;
  final String status;
  final double totalAmount;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Связанные данные
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? batch;
  final List<OrderItem>? orderItems;

  Order({
    required this.id,
    required this.userId,
    required this.addressId,
    this.batchId,
    required this.status,
    required this.totalAmount,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.user,
    this.address,
    this.batch,
    this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      addressId: json['addressId'] ?? 0,
      batchId: json['batchId'],
      status: json['status'] ?? 'pending',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      notes: json['notes'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      user: json['user'],
      address: json['address'],
      batch: json['batch'],
      orderItems: json['orderItems'] != null
          ? (json['orderItems'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'addressId': addressId,
      'batchId': batchId,
      'status': status,
      'totalAmount': totalAmount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Форматированная сумма
  String get formattedAmount {
    return '${totalAmount.toStringAsFixed(0)} ₽';
  }

  /// Количество товаров в заказе
  int get itemsCount {
    return orderItems?.length ?? 0;
  }

  /// Общее количество единиц товара
  int get totalItems {
    if (orderItems == null) return 0;
    return orderItems!.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Статус на русском
  String get statusText {
    switch (status) {
      case 'pending':
        return 'Ожидает';
      case 'confirmed':
        return 'Подтвержден';
      case 'paid':
        return 'Оплачен';
      case 'shipped':
        return 'Отправлен';
      case 'delivered':
        return 'Доставлен';
      case 'cancelled':
        return 'Отменен';
      default:
        return status;
    }
  }

  /// Цвет статуса
  String get statusColor {
    switch (status) {
      case 'pending':
        return 'orange';
      case 'confirmed':
        return 'blue';
      case 'paid':
        return 'green';
      case 'shipped':
        return 'purple';
      case 'delivered':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $status, amount: $formattedAmount)';
  }
}

/// Модель позиции заказа
class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final Map<String, dynamic>? product;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
    this.product,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      orderId: json['orderId'] ?? 0,
      productId: json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      product: json['product'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  /// Общая стоимость позиции
  double get totalPrice {
    return price * quantity;
  }

  /// Форматированная общая стоимость
  String get formattedTotalPrice {
    return '${totalPrice.toStringAsFixed(0)} ₽';
  }

  /// Название товара
  String get productName {
    return product?['name'] ?? 'Товар #$productId';
  }

  /// Единица измерения
  String get unit {
    return product?['unit'] ?? 'шт';
  }
}

/// Провайдер для управления заказами
class OrdersProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  String _selectedStatus = 'all';

  final ApiService _apiService = ApiService();

  // Геттеры
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedStatus => _selectedStatus;

  /// Получает отфильтрованные заказы
  List<Order> get filteredOrders {
    if (_selectedStatus == 'all') {
      return _orders;
    }
    return _orders.where((order) => order.status == _selectedStatus).toList();
  }

  /// Загружает заказы с сервера
  Future<void> loadOrders({
    String? status,
    int page = 1,
    int limit = 20,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final result = await _apiService.getOrders(
        status: status,
        page: page,
        limit: limit,
      );

      if (result['success']) {
        final ordersList = result['orders'] as List;
        _orders = ordersList.map((json) => Order.fromJson(json)).toList();

        if (kDebugMode) {
          print('OrdersProvider: Загружено ${_orders.length} заказов');
        }
      } else {
        _error = result['error'] ?? 'Ошибка загрузки заказов';
        if (kDebugMode) {
          print('OrdersProvider: Ошибка - $_error');
        }
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      if (kDebugMode) {
        print('OrdersProvider: Exception - $e');
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// Создает новый заказ
  Future<bool> createOrder({
    required int addressId,
    int? batchId,
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.createOrder(
        addressId: addressId,
        batchId: batchId,
        items: items,
        notes: notes,
      );

      if (result['success']) {
        // Добавляем новый заказ в список
        final newOrder = Order.fromJson(result['order']);
        _orders.insert(0, newOrder);

        if (kDebugMode) {
          print('OrdersProvider: Заказ создан - ${newOrder.id}');
        }

        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Ошибка создания заказа';
        return false;
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      if (kDebugMode) {
        print('OrdersProvider: Exception при создании заказа - $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Получает заказ по ID
  Future<Order?> getOrder(int orderId) async {
    try {
      // Сначала ищем в загруженных заказах
      final existingOrders = _orders.where((o) => o.id == orderId);
      if (existingOrders.isNotEmpty) {
        return existingOrders.first;
      }

      // Если не найден, загружаем с сервера (когда API будет поддерживать)
      // final result = await _apiService.getOrder(orderId);
      // ...

      return null;
    } catch (e) {
      _error = 'Ошибка получения заказа';
      notifyListeners();
      return null;
    }
  }

  /// Фильтрует заказы по статусу
  void filterByStatus(String status) {
    _selectedStatus = status;
    notifyListeners();
  }

  /// Получает заказы по статусу
  List<Order> getOrdersByStatus(String status) {
    return _orders.where((order) => order.status == status).toList();
  }

  /// Получает активные заказы
  List<Order> get activeOrders {
    return _orders
        .where((order) =>
            ['pending', 'confirmed', 'paid', 'shipped'].contains(order.status))
        .toList();
  }

  /// Получает завершенные заказы
  List<Order> get completedOrders {
    return _orders.where((order) => order.status == 'delivered').toList();
  }

  /// Получает отмененные заказы
  List<Order> get cancelledOrders {
    return _orders.where((order) => order.status == 'cancelled').toList();
  }

  /// Получает статистику заказов
  Map<String, dynamic> getOrdersStats() {
    final total = _orders.length;
    final pending = _orders.where((o) => o.status == 'pending').length;
    final confirmed = _orders.where((o) => o.status == 'confirmed').length;
    final delivered = _orders.where((o) => o.status == 'delivered').length;
    final cancelled = _orders.where((o) => o.status == 'cancelled').length;

    final totalRevenue = _orders
        .where((o) => ['delivered', 'paid'].contains(o.status))
        .fold(0.0, (sum, order) => sum + order.totalAmount);

    final today = DateTime.now();
    final todayOrders = _orders
        .where((order) =>
            order.createdAt.day == today.day &&
            order.createdAt.month == today.month &&
            order.createdAt.year == today.year)
        .length;

    return {
      'total': total,
      'pending': pending,
      'confirmed': confirmed,
      'delivered': delivered,
      'cancelled': cancelled,
      'total_revenue': totalRevenue,
      'today': todayOrders,
    };
  }

  /// Обновляет данные
  Future<void> refresh() async {
    await loadOrders(status: _selectedStatus == 'all' ? null : _selectedStatus);
  }

  /// Инициализация провайдера
  Future<void> init() async {
    await loadOrders();
  }

  /// Проверяет, есть ли заказы
  bool get hasOrders => _orders.isNotEmpty;

  /// Проверяет, есть ли отфильтрованные заказы
  bool get hasFilteredOrders => filteredOrders.isNotEmpty;

  /// Очищает ошибки
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Принудительное обновление
  void forceUpdate() {
    notifyListeners();
  }
}
