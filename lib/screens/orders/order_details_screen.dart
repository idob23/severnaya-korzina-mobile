// lib/screens/orders/order_details_screen.dart - ОБНОВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import '../../models/order.dart';
import '../../constants/order_status.dart';

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
    // ИСПРАВЛЕННЫЙ порядок статусов согласно константам
    final statuses = [
      {'name': 'Ожидает оплаты', 'status': 'pending'},
      {'name': 'Оплачен', 'status': 'paid'},
      {'name': 'Отправлен', 'status': 'shipped'},
      {'name': 'Доставлен', 'status': 'delivered'},
    ];

    return Column(
      children: statuses
          .map((status) => _buildProgressStep(
                status['name'] as String,
                OrderStatusUtils.isStatusCompleted(
                    order.status, status['status'] as String),
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
    // Отмененные заказы показываем отдельно
    if (order.status == 'cancelled') {
      return Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red[700]),
            SizedBox(width: 8),
            Text(
              'Заказ отменен',
              style: TextStyle(
                  color: Colors.red[700], fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Для остальных статусов
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
                'Ожидает оплаты',
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
                maxLines: 2, // ← Разрешить перенос на 2 строки
                overflow: TextOverflow.ellipsis, // ← Обрезка если не влезает
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
    if (order.orderItems == null || order.orderItems!.isEmpty) {
      return Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Товары не найдены'),
        ),
      );
    }

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
            ...order.orderItems!.map((item) => _buildOrderItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  '${item.quantity} ${item.unit} × ${item.price.toStringAsFixed(0)} ₽',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            item.formattedTotalPrice,
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
    // ИСПОЛЬЗУЕТ КОНСТАНТЫ
    switch (order.statusColor) {
      case 'orange':
        return Colors.orange;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // ТАКЖЕ ЗАМЕНИТЬ метод _isStatusCompleted():
  bool _isStatusCompleted(String statusToCheck) {
    final statusOrder = [
      'pending',
      'paid', // УБРАЛИ 'confirmed'
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
