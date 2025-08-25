// lib/screens/orders/orders_screen.dart - ПОЛНАЯ ИСПРАВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/orders_provider.dart';
import '../../models/order.dart';
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
        //
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
                Text(
                  ordersProvider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
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

        return RefreshIndicator(
          onRefresh: () => ordersProvider.refresh(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: inTransitOrders.length,
            itemBuilder: (context, index) {
              final order = inTransitOrders[index];
              return _buildOrderCard(order);
            },
          ),
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

        return RefreshIndicator(
          onRefresh: () => ordersProvider.refresh(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: readyOrders.length,
            itemBuilder: (context, index) {
              final order = readyOrders[index];
              return _buildOrderCard(order);
            },
          ),
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

        return RefreshIndicator(
          onRefresh: () => ordersProvider.refresh(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: allOrders.length,
            itemBuilder: (context, index) {
              final order = allOrders[index];
              return _buildOrderCard(order);
            },
          ),
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
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return GestureDetector(
      onTap: () {
        // Переход к деталям заказа
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(order: order),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.statusText,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Сумма: ${order.formattedAmount}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Дата: ${_formatDate(order.createdAt)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (order.address != null) ...[
                SizedBox(height: 4),
                Text(
                  'Адрес: ${order.address!['address']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
              if (order.notes != null && order.notes!.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  'Комментарий: ${order.notes}',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'paid':
        return Colors.green;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green.shade700;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
