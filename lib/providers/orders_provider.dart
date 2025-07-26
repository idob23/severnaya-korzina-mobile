// lib/providers/orders_provider.dart - ДЛЯ РАБОТЫ С API
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class OrdersProvider with ChangeNotifier {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = false;
  String? _error;

  final ApiService _apiService = ApiService();

  // Getters
  List<Map<String, dynamic>> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Загружает заказы пользователя с сервера
  Future<void> loadOrders({
    int? userId,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _apiService.getOrders(
        userId: userId,
        status: status,
        page: page,
        limit: limit,
      );

      if (result['success']) {
        _orders = List<Map<String, dynamic>>.from(result['orders']);
        print('OrdersProvider: Загружено ${_orders.length} заказов');

        // Логируем первый заказ для отладки
        if (_orders.isNotEmpty) {
          print('OrdersProvider: Первый заказ - ${_orders.first}');
        }
      } else {
        _error = result['error'] ?? 'Ошибка загрузки заказов';
        print('OrdersProvider: Ошибка - $_error');
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      print('OrdersProvider: Exception - $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Создает новый заказ
  Future<bool> createOrder({
    required int userId,
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
        userId: userId,
        addressId: addressId,
        batchId: batchId,
        items: items,
        notes: notes,
      );

      if (result['success']) {
        print('OrdersProvider: Заказ создан успешно');

        // Добавляем новый заказ в начало списка
        final newOrder = result['order'];
        _orders.insert(0, newOrder);

        notifyListeners();
        return true;
      } else {
        _error = result['error'] ?? 'Ошибка создания заказа';
        print('OrdersProvider: Ошибка создания - $_error');
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      print('OrdersProvider: Exception при создании - $e');
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Получает заказ по ID
  Map<String, dynamic>? getOrderById(int orderId) {
    try {
      return _orders.firstWhere((order) => order['id'] == orderId);
    } catch (e) {
      return null;
    }
  }

  /// Получает заказы по статусу
  List<Map<String, dynamic>> getOrdersByStatus(String status) {
    return _orders.where((order) => order['status'] == status).toList();
  }

  /// Получает активные заказы
  List<Map<String, dynamic>> get activeOrders {
    return _orders.where((order) {
      final status = order['status'];
      return status == 'pending' || status == 'confirmed' || status == 'paid';
    }).toList();
  }

  /// Получает завершенные заказы
  List<Map<String, dynamic>> get completedOrders {
    return getOrdersByStatus('delivered');
  }

  /// Получает отмененные заказы
  List<Map<String, dynamic>> get cancelledOrders {
    return getOrdersByStatus('cancelled');
  }

  /// Подсчитывает общую сумму заказов
  double get totalOrdersAmount {
    return _orders.fold(0.0, (sum, order) {
      final amount = order['totalAmount'];
      if (amount is String) {
        return sum + (double.tryParse(amount) ?? 0.0);
      } else if (amount is num) {
        return sum + amount.toDouble();
      }
      return sum;
    });
  }

  /// Получает количество заказов по статусам
  Map<String, int> get orderCountByStatus {
    final counts = <String, int>{};
    for (final order in _orders) {
      final status = order['status'] ?? 'unknown';
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  /// Получает последний заказ
  Map<String, dynamic>? get lastOrder {
    if (_orders.isEmpty) return null;
    return _orders.first;
  }

  /// Проверяет, есть ли заказы
  bool get hasOrders => _orders.isNotEmpty;

  /// Получает заказы за последнюю неделю
  List<Map<String, dynamic>> get recentOrders {
    final weekAgo = DateTime.now().subtract(Duration(days: 7));
    return _orders.where((order) {
      final createdAt = DateTime.tryParse(order['createdAt'] ?? '');
      return createdAt != null && createdAt.isAfter(weekAgo);
    }).toList();
  }

  /// Обновляет данные (pull-to-refresh)
  Future<void> refresh({int? userId}) async {
    await loadOrders(userId: userId);
  }

  /// Очищает ошибку
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Очищает все заказы (при выходе из аккаунта)
  void clear() {
    _orders.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Форматирует сумму заказа
  String formatOrderAmount(Map<String, dynamic> order) {
    final amount = order['totalAmount'];
    double value = 0.0;

    if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else if (amount is num) {
      value = amount.toDouble();
    }

    return '${value.toStringAsFixed(0)} ₽';
  }

  /// Получает статус заказа на русском языке
  String getOrderStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Ожидает подтверждения';
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
        return 'Неизвестный статус';
    }
  }

  /// Получает цвет статуса заказа
  int getOrderStatusColor(String status) {
    switch (status) {
      case 'pending':
        return 0xFFFF9800; // Orange
      case 'confirmed':
        return 0xFF2196F3; // Blue
      case 'paid':
        return 0xFF4CAF50; // Green
      case 'shipped':
        return 0xFF9C27B0; // Purple
      case 'delivered':
        return 0xFF4CAF50; // Green
      case 'cancelled':
        return 0xFFF44336; // Red
      default:
        return 0xFF757575; // Grey
    }
  }
}
