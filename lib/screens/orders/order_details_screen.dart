// lib/screens/orders/order_details_screen.dart
import 'package:flutter/material.dart';
import '../../models/order.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Order order;

  OrderDetailsScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ #${order.id}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основная информация о заказе
            _buildOrderHeader(),
            SizedBox(height: 16),

            // Статус и прогресс
            _buildStatusSection(),
            SizedBox(height: 16),

            // Список товаров
            _buildItemsList(),
            SizedBox(height: 16),

            // Финансовая информация
            _buildPaymentDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Card(
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'Дата создания: ${_formatDate(order.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (order.notes != null && order.notes!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                order.notes!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    Color color = _getStatusColor();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        order.statusText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статус заказа',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildProgressIndicator(),
            SizedBox(height: 16),
            _buildStatusSpecificInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final statuses = [
      {'name': 'Создан', 'status': 'pending', 'completed': true},
      {
        'name': 'Оплачен',
        'status': 'paid',
        'completed': _isStatusCompleted('paid')
      },
      {
        'name': 'Подтвержден',
        'status': 'confirmed',
        'completed': _isStatusCompleted('confirmed')
      },
      {
        'name': 'Отправлен',
        'status': 'shipped',
        'completed': _isStatusCompleted('shipped')
      },
      {
        'name': 'Доставлен',
        'status': 'delivered',
        'completed': _isStatusCompleted('delivered')
      },
    ];

    return Column(
      children: statuses
          .map((status) => _buildProgressStep(
                status['name'] as String,
                status['completed'] as bool,
                statuses.indexOf(status) == statuses.length - 1,
              ))
          .toList(),
    );
  }

  Widget _buildProgressStep(String title, bool completed, bool isLast) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: completed ? Colors.green : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: completed
              ? Icon(Icons.check, color: Colors.white, size: 14)
              : null,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: completed ? FontWeight.bold : FontWeight.normal,
                  color: completed ? Colors.black : Colors.grey[600],
                ),
              ),
              if (!isLast)
                Container(
                  margin: EdgeInsets.only(top: 8, bottom: 8),
                  height: 20,
                  width: 2,
                  color: Colors.grey[300],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSpecificInfo() {
    switch (order.status) {
      case 'pending':
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, color: Colors.orange[700]),
              SizedBox(width: 8),
              Text(
                'Ожидает обработки',
                style: TextStyle(
                    color: Colors.orange[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case 'paid':
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.payment, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                'Заказ оплачен, готовится к отправке',
                style: TextStyle(
                    color: Colors.green[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case 'shipped':
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.local_shipping, color: Colors.blue[700]),
              SizedBox(width: 8),
              Text(
                'Заказ в пути',
                style: TextStyle(
                    color: Colors.blue[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      case 'delivered':
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green[700]),
              SizedBox(width: 8),
              Text(
                'Заказ доставлен',
                style: TextStyle(
                    color: Colors.green[700], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildItemsList() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Товары в заказе',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (order.orderItems != null && order.orderItems!.isNotEmpty)
              ...order.orderItems!.map((item) => _buildOrderItem(item)).toList()
            else
              Text('Информация о товарах недоступна'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${item.quantity} ${item.unit} × ${item.price.toStringAsFixed(0)} ₽',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            '${item.totalPrice.toStringAsFixed(0)} ₽',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Детали оплаты',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Сумма заказа:'),
                Text(
                  order.formattedAmount,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (order.address != null) ...[
              SizedBox(height: 8),
              Text(
                'Адрес доставки:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 4),
              Text(
                '${order.address!['title']}: ${order.address!['address']}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
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

  bool _isStatusCompleted(String statusToCheck) {
    final statusOrder = [
      'pending',
      'paid',
      'confirmed',
      'shipped',
      'delivered'
    ];
    final currentIndex = statusOrder.indexOf(order.status);
    final checkIndex = statusOrder.indexOf(statusToCheck);
    return currentIndex >= checkIndex;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
