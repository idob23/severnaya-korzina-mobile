// lib/providers/orders_provider.dart - ЧИСТАЯ ВЕРСИЯ БЕЗ ДУБЛИРОВАНИЯ
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/order.dart';
import '../services/notification_service.dart';

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

  /// Инициализация провайдера
  Future<void> init() async {
    if (kDebugMode) {
      print('🔄 OrdersProvider: Инициализация...');
    }

    // ВАЖНО: Сначала инициализируем токен!
    await _initializeApiToken();

    // Затем загружаем заказы
    await loadOrders();
  }

  /// Инициализирует токен в ApiService
  Future<void> _initializeApiToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        _apiService.setAuthToken(token);
        if (kDebugMode) {
          print('✅ Токен установлен в ApiService для OrdersProvider');
        }
      } else {
        if (kDebugMode) {
          print('❌ Токен не найден в SharedPreferences для OrdersProvider');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка инициализации токена в OrdersProvider: $e');
      }
    }
  }

  /// Загружает заказы с сервера
  Future<void> loadOrders({
    String? status,
    int page = 1,
    int limit = 20,
    bool silent = false,
  }) async {
    print('ТЕСТ: Создаем NotificationService');
    final testService = NotificationService();
    testService.showLocalNotification(
      title: 'ТЕСТ loadOrders',
      body: 'Проверка уведомлений',
    );

    print(
        '🔔 TEST: loadOrders вызван, silent=$silent, текущих заказов=${_orders.length}');

    if (!silent) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      if (kDebugMode) {
        print('🔄 OrdersProvider: Загружаем заказы...');
      }

      final result = await _apiService.getOrders(
        status: status,
        page: page,
        limit: limit,
      );

      if (kDebugMode) {
        print('📡 OrdersProvider: Ответ от API: ${result['success']}');
        if (result['error'] != null) {
          print('❌ OrdersProvider: Ошибка API: ${result['error']}');
        }
      }

      if (result['success'] == true) {
        final ordersList = result['orders'] as List? ?? [];
        final newOrders =
            ordersList.map((json) => Order.fromJson(json)).toList();
        print(
            '🔔 TEST: Проверяем изменения - старых заказов: ${_orders.length}, новых: ${newOrders.length}');

        if (!silent && _orders.isNotEmpty) {
          print('🔔 TEST: Вызываем _checkForStatusChanges');
          _checkForStatusChanges(newOrders);
        } else {
          print(
              '🔔 TEST: НЕ вызываем _checkForStatusChanges - silent=$silent, orders.isEmpty=${_orders.isEmpty}');
        }

        _orders = newOrders;

        if (kDebugMode) {
          print('✅ OrdersProvider: Загружено ${_orders.length} заказов');
        }
      } else {
        _error = result['error'] ?? 'Ошибка загрузки заказов';
        if (kDebugMode) {
          print('❌ OrdersProvider: Ошибка - $_error');
        }
      }
    } catch (e) {
      _error = 'Ошибка подключения к серверу';
      if (kDebugMode) {
        print('❌ OrdersProvider: Exception - $e');
      }
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void _checkForStatusChanges(List<Order> newOrders) {
    print(
        '🔔 TEST: _checkForStatusChanges вызван, сравниваем ${newOrders.length} новых заказов с ${_orders.length} старыми');

    final notificationService = NotificationService();

    // Сравниваем со старым списком заказов
    for (final newOrder in newOrders) {
      final oldOrder = _orders.where((o) => o.id == newOrder.id).firstOrNull;

      print(
          '🔔 TEST: Заказ #${newOrder.id} - oldOrder: ${oldOrder != null ? "найден" : "НЕ найден"}, статус: ${newOrder.status}');

      // Если заказ новый или статус изменился
      if (oldOrder == null) {
        print('🔔 TEST: Новый заказ #${newOrder.id}!');
        // Новый заказ - показываем уведомление
        notificationService.showLocalNotification(
          title: '🎯 Новый заказ #${newOrder.id}',
          body: 'Заказ создан на сумму ${newOrder.formattedAmount}',
        );
      } else if (oldOrder.status != newOrder.status) {
        print(
            '🔔 TEST: Статус заказа #${newOrder.id} изменился: ${oldOrder.status} → ${newOrder.status}');
        // Статус изменился - показываем уведомление
        notificationService.showOrderStatusNotification(
          orderId: newOrder.id,
          oldStatus: oldOrder.status,
          newStatus: newOrder.status,
        );
      } else {
        print('🔔 TEST: Заказ #${newOrder.id} без изменений');
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

        // ПРОСТЕЙШИЙ ТЕСТ
        print(
            '🔔 ТЕСТ: Пытаемся показать уведомление для заказа ${newOrder.id}');
        final notificationService = NotificationService();
        print('🔔 ТЕСТ: NotificationService создан');

        notificationService.showLocalNotification(
          title: 'Новый заказ #${newOrder.id}',
          body: 'Заказ создан на сумму ${newOrder.formattedAmount}',
        );

        print('🔔 ТЕСТ: showLocalNotification вызван');
        // // ТЕСТ: показываем уведомление напрямую
        // final notificationService = NotificationService();
        // notificationService.showLocalNotification(
        //   title: 'Новый заказ #${newOrder.id}',
        //   body: 'Заказ создан на сумму ${newOrder.formattedAmount}',
        // );

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
