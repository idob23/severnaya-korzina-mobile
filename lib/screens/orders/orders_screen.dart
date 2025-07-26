import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/auth_provider.dart';
import '../auth/auth_choice_screen.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мои заказы'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: [
            Tab(text: 'Активные'),
            Tab(text: 'В пути'),
            Tab(text: 'Готовые'),
            Tab(text: 'История'),
          ],
        ),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return _buildUnauthenticatedView();
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildActiveOrders(),
              _buildInTransitOrders(),
              _buildReadyOrders(),
              _buildHistoryOrders(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'Войдите для просмотра заказов',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Авторизуйтесь чтобы видеть свои заказы и отслеживать их статус',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => AuthChoiceScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    // Демонстрационные данные
    final activeOrders = [
      {
        'id': '#2025001',
        'date': '12 июля 2025',
        'status': 'Сбор заказов',
        'items': 5,
        'total': 4500.0,
        'prepaid': 4050.0,
        'remaining': 450.0,
        'description': 'Молочные продукты, хлебобулочные изделия',
        'deadline': '20 июля 2025',
        'participants': 15,
        'minParticipants': 20,
      },
      {
        'id': '#2025002',
        'date': '10 июля 2025',
        'status': 'Подтвержден',
        'items': 3,
        'total': 2800.0,
        'prepaid': 2520.0,
        'remaining': 280.0,
        'description': 'Мясные продукты',
        'deadline': 'Закрыт',
        'participants': 25,
        'minParticipants': 20,
      },
    ];

    return _buildOrdersList(activeOrders, OrderStatus.active);
  }

  Widget _buildInTransitOrders() {
    final inTransitOrders = [
      {
        'id': '#2025003',
        'date': '5 июля 2025',
        'status': 'В пути из Якутска',
        'items': 7,
        'total': 6200.0,
        'prepaid': 5580.0,
        'remaining': 620.0,
        'description': 'Бытовая химия, косметика',
        'eta': '16 июля 2025',
        'trackingNumber': 'YAK12345678',
      },
    ];

    return _buildOrdersList(inTransitOrders, OrderStatus.inTransit);
  }

  Widget _buildReadyOrders() {
    final readyOrders = [
      {
        'id': '#2025004',
        'date': '1 июля 2025',
        'status': 'Готов к выдаче',
        'items': 4,
        'total': 3800.0,
        'prepaid': 3420.0,
        'remaining': 380.0,
        'description': 'Крупы, консервы',
        'pickupAddress': 'ул. Ленина, 15 (склад)',
        'pickupTime': 'Пн-Пт: 9:00-18:00',
      },
    ];

    return _buildOrdersList(readyOrders, OrderStatus.ready);
  }

  Widget _buildHistoryOrders() {
    final historyOrders = [
      {
        'id': '#2025005',
        'date': '25 июня 2025',
        'status': 'Получен',
        'items': 6,
        'total': 5100.0,
        'prepaid': 4590.0,
        'remaining': 0.0,
        'description': 'Овощи, фрукты',
        'completedDate': '28 июня 2025',
        'rating': 5,
      },
      {
        'id': '#2025006',
        'date': '20 июня 2025',
        'status': 'Получен',
        'items': 2,
        'total': 1800.0,
        'prepaid': 1620.0,
        'remaining': 0.0,
        'description': 'Замороженные продукты',
        'completedDate': '25 июня 2025',
        'rating': 4,
      },
    ];

    return _buildOrdersList(historyOrders, OrderStatus.completed);
  }

  Widget _buildOrdersList(
      List<Map<String, dynamic>> orders, OrderStatus status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyIcon(status),
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              _getEmptyMessage(status),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Имитация обновления данных
        await Future.delayed(Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order, status);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, OrderStatus status) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок заказа
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Заказ ${order['id']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(order['status'], status),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Дата заказа: ${order['date']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Text(
              order['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 12),

            // Информация в зависимости от статуса
            _buildStatusSpecificInfo(order, status),

            SizedBox(height: 12),

            // Финансовая информация
            _buildFinancialInfo(order),

            SizedBox(height: 16),

            // Кнопки действий
            _buildActionButtons(order, status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, OrderStatus orderStatus) {
    Color color;
    switch (orderStatus) {
      case OrderStatus.active:
        color = Colors.orange;
        break;
      case OrderStatus.inTransit:
        color = Colors.blue;
        break;
      case OrderStatus.ready:
        color = Colors.green;
        break;
      case OrderStatus.completed:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusSpecificInfo(
      Map<String, dynamic> order, OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return Column(
          children: [
            if (order['deadline'] != 'Закрыт')
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.orange),
                  SizedBox(width: 4),
                  Text(
                    'Сбор до: ${order['deadline']}',
                    style: TextStyle(color: Colors.orange[700]),
                  ),
                ],
              ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text(
                    '${order['participants']}/${order['minParticipants']} участников'),
              ],
            ),
          ],
        );

      case OrderStatus.inTransit:
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping, size: 16, color: Colors.blue),
                SizedBox(width: 4),
                Text('Ожидаемое прибытие: ${order['eta']}'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.track_changes, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Трек-номер: ${order['trackingNumber']}'),
              ],
            ),
          ],
        );

      case OrderStatus.ready:
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Expanded(child: Text('Адрес: ${order['pickupAddress']}')),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text('Время работы: ${order['pickupTime']}'),
              ],
            ),
          ],
        );

      case OrderStatus.completed:
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                SizedBox(width: 4),
                Text('Получен: ${order['completedDate']}'),
              ],
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                SizedBox(width: 4),
                Text('Оценка: ${order['rating']}/5'),
                SizedBox(width: 8),
                ...List.generate(
                    5,
                    (index) => Icon(
                          index < order['rating']
                              ? Icons.star
                              : Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        )),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildFinancialInfo(Map<String, dynamic> order) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Товаров: ${order['items']} шт.'),
              Text('${order['total'].toStringAsFixed(0)} ₽'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Предоплата (90%):'),
              Text('${order['prepaid'].toStringAsFixed(0)} ₽',
                  style: TextStyle(color: Colors.green)),
            ],
          ),
          if (order['remaining'] > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('К доплате:'),
                Text('${order['remaining'].toStringAsFixed(0)} ₽',
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> order, OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showOrderDetails(order);
                },
                child: Text('Подробнее'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: order['status'] == 'Сбор заказов'
                    ? () {
                        _showCancelOrderDialog(order);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: Text('Отменить'),
              ),
            ),
          ],
        );

      case OrderStatus.inTransit:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showTrackingInfo(order);
            },
            icon: Icon(Icons.track_changes),
            label: Text('Отследить груз'),
          ),
        );

      case OrderStatus.ready:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _showPickupInfo(order);
            },
            icon: Icon(Icons.location_on),
            label: Text('Информация о получении'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        );

      case OrderStatus.completed:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _showOrderDetails(order);
                },
                child: Text('Подробнее'),
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _showReorderDialog(order);
                },
                child: Text('Повторить заказ'),
              ),
            ),
          ],
        );
    }
  }

  IconData _getEmptyIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return Icons.shopping_cart_outlined;
      case OrderStatus.inTransit:
        return Icons.local_shipping_outlined;
      case OrderStatus.ready:
        return Icons.inventory_outlined;
      case OrderStatus.completed:
        return Icons.history;
    }
  }

  String _getEmptyMessage(OrderStatus status) {
    switch (status) {
      case OrderStatus.active:
        return 'Нет активных заказов';
      case OrderStatus.inTransit:
        return 'Нет заказов в пути';
      case OrderStatus.ready:
        return 'Нет готовых заказов';
      case OrderStatus.completed:
        return 'История заказов пуста';
    }
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(order: order),
      ),
    );
  }

  void _showCancelOrderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Отмена заказа'),
        content: Text('Вы действительно хотите отменить заказ ${order['id']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Нет'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Заказ отменен')),
              );
            },
            child: Text('Да', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showTrackingInfo(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Отслеживание груза'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Заказ: ${order['id']}'),
            Text('Трек-номер: ${order['trackingNumber']}'),
            SizedBox(height: 16),
            Text('Статус: ${order['status']}'),
            Text('Ожидаемое прибытие: ${order['eta']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showPickupInfo(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Информация о получении'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Заказ: ${order['id']}'),
            SizedBox(height: 8),
            Text('Адрес получения:'),
            Text(order['pickupAddress'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Время работы:'),
            Text(order['pickupTime'],
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('К доплате: ${order['remaining'].toStringAsFixed(0)} ₽',
                style: TextStyle(
                    color: Colors.orange, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  void _showReorderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Повторить заказ'),
        content: Text('Добавить товары из заказа ${order['id']} в корзину?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Товары добавлены в корзину')),
              );
            },
            child: Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

enum OrderStatus { active, inTransit, ready, completed }
