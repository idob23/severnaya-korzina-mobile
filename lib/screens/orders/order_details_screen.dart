import 'package:flutter/material.dart';

class OrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  OrderDetailsScreen({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Заказ ${order['id']}'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Поделиться заказом - в разработке')),
              );
            },
          ),
        ],
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
            SizedBox(height: 16),

            // Информация о доставке
            _buildDeliveryInfo(),
            SizedBox(height: 16),

            // Участники заказа (для активных заказов)
            if (order['status'] == 'Сбор заказов' ||
                order['status'] == 'Подтвержден')
              _buildParticipantsInfo(),

            // Дополнительная информация
            _buildAdditionalInfo(),
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
                  'Заказ ${order['id']}',
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
              'Дата создания: ${order['date']}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(
              order['description'],
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
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
        order['status'],
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
      {'name': 'Создан', 'completed': true},
      {'name': 'Сбор заказов', 'completed': _isStatusCompleted('Сбор заказов')},
      {'name': 'Подтвержден', 'completed': _isStatusCompleted('Подтвержден')},
      {'name': 'В пути', 'completed': _isStatusCompleted('В пути из Якутска')},
      {'name': 'Готов', 'completed': _isStatusCompleted('Готов к выдаче')},
      {'name': 'Получен', 'completed': _isStatusCompleted('Получен')},
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
    switch (order['status']) {
      case 'Сбор заказов':
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Идет сбор заказов',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
              SizedBox(height: 4),
              Text('Сбор до: ${order['deadline']}'),
              Text(
                  'Участников: ${order['participants']}/${order['minParticipants']}'),
              SizedBox(height: 8),
              LinearProgressIndicator(
                value: order['participants'] / order['minParticipants'],
                backgroundColor: Colors.orange[100],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
              ),
            ],
          ),
        );

      case 'В пути из Якутска':
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Груз в пути',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
              SizedBox(height: 4),
              Text('Ожидаемое прибытие: ${order['eta']}'),
              Text('Трек-номер: ${order['trackingNumber']}'),
            ],
          ),
        );

      case 'Готов к выдаче':
        return Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Заказ готов к получению',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 4),
              Text('Адрес: ${order['pickupAddress']}'),
              Text('Время работы: ${order['pickupTime']}'),
            ],
          ),
        );

      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildItemsList() {
    // Демонстрационные товары
    final items = _generateOrderItems();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Товары в заказе (${order['items']} шт.)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...items.map((item) => _buildOrderItem(item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory, color: Colors.grey[600]),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  item['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Text('${item['quantity']} шт.'),
                    SizedBox(width: 8),
                    Text('${item['pricePerUnit']} ₽/шт.'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['totalPrice']} ₽',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (item['discount'] > 0)
                Text(
                  '-${item['discount']}%',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
            ],
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
            _buildPaymentRow('Стоимость товаров:', '${order['total']} ₽'),
            _buildPaymentRow(
                'Скидка коллективной закупки:',
                '-${(order['total'] * 0.1).toStringAsFixed(0)} ₽',
                Colors.green),
            _buildPaymentRow('Доставка:', 'Бесплатно', Colors.green),
            Divider(),
            _buildPaymentRow(
                'Итого к оплате:', '${order['total']} ₽', null, true),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPaymentRow('Предоплата (90%):', '${order['prepaid']} ₽',
                      Colors.blue),
                  if (order['remaining'] > 0)
                    _buildPaymentRow('К доплате при получении:',
                        '${order['remaining']} ₽', Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, String amount,
      [Color? color, bool isBold = false]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Информация о доставке',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow(Icons.local_shipping, 'Способ доставки',
                'Автомобильный транспорт'),
            _buildInfoRow(Icons.location_on, 'Маршрут', 'Якутск → Усть-Нера'),
            _buildInfoRow(Icons.schedule, 'Время в пути', '≈ 10-14 дней'),
            if (order['pickupAddress'] != null)
              _buildInfoRow(
                  Icons.store, 'Пункт выдачи', order['pickupAddress']),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantsInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Участники заказа',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${order['participants']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text('Участников'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${order['minParticipants']}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text('Минимум'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: order['participants'] / order['minParticipants'],
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                order['participants'] >= order['minParticipants']
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
            SizedBox(height: 8),
            Text(
              order['participants'] >= order['minParticipants']
                  ? 'Минимум участников набран! ✅'
                  : 'Нужно еще ${order['minParticipants'] - order['participants']} участников',
              style: TextStyle(
                color: order['participants'] >= order['minParticipants']
                    ? Colors.green
                    : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительная информация',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoRow(
                Icons.support_agent, 'Поддержка', '+7 (xxx) xxx-xx-xx'),
            _buildInfoRow(Icons.email, 'Email', 'support@severnaya-korzina.ru'),
            _buildInfoRow(Icons.info, 'Номер заказа', order['id']),
            if (order['trackingNumber'] != null)
              _buildInfoRow(
                  Icons.track_changes, 'Трек-номер', order['trackingNumber']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (order['status']) {
      case 'Сбор заказов':
        return Colors.orange;
      case 'Подтвержден':
        return Colors.blue;
      case 'В пути из Якутска':
        return Colors.blue;
      case 'Готов к выдаче':
        return Colors.green;
      case 'Получен':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  bool _isStatusCompleted(String statusToCheck) {
    final statusOrder = [
      'Сбор заказов',
      'Подтвержден',
      'В пути из Якутска',
      'Готов к выдаче',
      'Получен'
    ];

    final currentIndex = statusOrder.indexOf(order['status']);
    final checkIndex = statusOrder.indexOf(statusToCheck);

    return currentIndex >= checkIndex;
  }

  List<Map<String, dynamic>> _generateOrderItems() {
    // Генерируем товары в зависимости от описания заказа
    if (order['description'].contains('Молочные продукты')) {
      return [
        {
          'name': 'Молоко 3.2%',
          'description': '1 литр, пастеризованное',
          'quantity': 3,
          'pricePerUnit': 65,
          'totalPrice': 195,
          'discount': 15,
        },
        {
          'name': 'Творог 9%',
          'description': '200г, натуральный',
          'quantity': 2,
          'pricePerUnit': 120,
          'totalPrice': 240,
          'discount': 20,
        },
        {
          'name': 'Хлеб белый',
          'description': 'Нарезной, 400г',
          'quantity': 2,
          'pricePerUnit': 45,
          'totalPrice': 90,
          'discount': 10,
        },
        {
          'name': 'Масло сливочное',
          'description': '180г, 82.5%',
          'quantity': 1,
          'pricePerUnit': 180,
          'totalPrice': 180,
          'discount': 25,
        },
        {
          'name': 'Сыр российский',
          'description': '300г, твердый',
          'quantity': 1,
          'pricePerUnit': 350,
          'totalPrice': 350,
          'discount': 30,
        },
      ];
    } else if (order['description'].contains('Мясные продукты')) {
      return [
        {
          'name': 'Говядина',
          'description': 'Лопатка, охлажденная, 1кг',
          'quantity': 2,
          'pricePerUnit': 420,
          'totalPrice': 840,
          'discount': 25,
        },
        {
          'name': 'Курица',
          'description': 'Тушка, охлажденная, 1.5кг',
          'quantity': 1,
          'pricePerUnit': 180,
          'totalPrice': 180,
          'discount': 20,
        },
        {
          'name': 'Колбаса варенная',
          'description': 'Докторская, 500г',
          'quantity': 1,
          'pricePerUnit': 280,
          'totalPrice': 280,
          'discount': 15,
        },
      ];
    } else {
      // Универсальный набор
      return [
        {
          'name': 'Продукт 1',
          'description': 'Описание товара',
          'quantity': 2,
          'pricePerUnit': 100,
          'totalPrice': 200,
          'discount': 15,
        },
        {
          'name': 'Продукт 2',
          'description': 'Описание товара',
          'quantity': 1,
          'pricePerUnit': 150,
          'totalPrice': 150,
          'discount': 20,
        },
      ];
    }
  }
}
