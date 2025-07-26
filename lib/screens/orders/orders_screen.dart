// lib/screens/orders/orders_screen.dart - ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../auth/auth_choice_screen.dart';

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

    // Загружаем заказы при инициализации, если пользователь авторизован
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        final ordersProvider =
            Provider.of<OrdersProvider>(context, listen: false);
        ordersProvider.init();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              'Авторизуйтесь, чтобы видеть свои заказы и отслеживать их статус',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AuthChoiceScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: Text('Войти'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        if (ordersProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Загружаем заказы...'),
              ],
            ),
          );
        }

        if (ordersProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Ошибка загрузки заказов',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(ordersProvider.error!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ordersProvider.refresh(),
                  child: Text('Повторить'),
                ),
              ],
            ),
          );
        }

        final activeOrders = ordersProvider.activeOrders;

        if (activeOrders.isEmpty) {
          return _buildEmptyState(
            'Нет активных заказов',
            'Ваши новые заказы будут отображаться здесь',
            Icons.shopping_cart_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => ordersProvider.refresh(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: activeOrders.length,
            itemBuilder: (context, index) {
              final order = activeOrders[index];
              return _buildOrderCard(order);
            },
          ),
        );
      },
    );
  }

  Widget _buildInTransitOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        final inTransitOrders = ordersProvider.getOrdersByStatus('shipped');

        if (inTransitOrders.isEmpty) {
          return _buildEmptyState(
            'Нет заказов в пути',
            'Отправленные заказы будут отображаться здесь',
            Icons.local_shipping_outlined,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: inTransitOrders.length,
          itemBuilder: (context, index) {
            final order = inTransitOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildReadyOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        final readyOrders = ordersProvider.completedOrders;

        if (readyOrders.isEmpty) {
          return _buildEmptyState(
            'Нет готовых заказов',
            'Готовые к получению заказы будут отображаться здесь',
            Icons.inventory_2_outlined,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: readyOrders.length,
          itemBuilder: (context, index) {
            final order = readyOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildHistoryOrders() {
    return Consumer<OrdersProvider>(
      builder: (context, ordersProvider, child) {
        final allOrders = ordersProvider.orders;

        if (allOrders.isEmpty) {
          return _buildEmptyState(
            'История заказов пуста',
            'Все ваши заказы будут отображаться здесь',
            Icons.history,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: allOrders.length,
          itemBuilder: (context, index) {
            final order = allOrders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
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
                  'Заказ #${order.id}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),

            SizedBox(height: 12),

            // Информация о заказе
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Сумма: ${order.formattedAmount}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Товаров: ${order.totalItems} шт.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(order.createdAt),
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatTime(order.createdAt),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),

            if (order.notes != null && order.notes!.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 12),

            // Кнопки действий
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showOrderDetails(order);
                    },
                    child: Text('Подробнее'),
                  ),
                ),
                if (order.status == 'pending') ...[
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        _cancelOrder(order);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Отменить'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'confirmed':
        color = Colors.blue;
        break;
      case 'paid':
        color = Colors.green;
        break;
      case 'shipped':
        color = Colors.purple;
        break;
      case 'delivered':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showOrderDetails(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Заказ #${order.id}'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Статус: ${_getStatusText(order.status)}'),
            SizedBox(height: 8),
            Text('Сумма: ${order.formattedAmount}'),
            SizedBox(height: 8),
            Text(
                'Дата: ${_formatDate(order.createdAt)} ${_formatTime(order.createdAt)}'),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              SizedBox(height: 8),
              Text('Примечания: ${order.notes}'),
            ],
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

  void _cancelOrder(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Отменить заказ'),
        content: Text('Вы уверены, что хотите отменить заказ #${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Нет'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Реализовать отмену заказа через API
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Отмена заказа - в разработке'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Да, отменить'),
          ),
        ],
      ),
    );
  }
}
