// lib/screens/payment/payment_success_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String orderId;
  final double amount;
  final String paymentMethod;
  final Map<String, dynamic> orderData;

  const PaymentSuccessScreen({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.paymentMethod,
    required this.orderData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text('Оплата завершена'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 40),

            // Иконка успеха
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                size: 80,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 24),

            // Заголовок
            Text(
              'Оплата прошла успешно!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 8),

            Text(
              'Ваш заказ принят к обработке',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            // Информация о платеже
            _buildPaymentInfo(),

            SizedBox(height: 20),

            // Информация о заказе
            _buildOrderInfo(),

            SizedBox(height: 20),

            // Что дальше
            _buildNextSteps(),

            SizedBox(height: 32),

            // Кнопки действий
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Детали платежа',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoRow('Номер платежа:', orderId),
            _buildInfoRow('Сумма:', '${amount.toStringAsFixed(0)} ₽'),
            _buildInfoRow('Способ оплаты:', paymentMethod),
            _buildInfoRow('Дата:', _formatDateTime(DateTime.now())),
            _buildInfoRow('Статус:', 'Оплачено', isSuccess: true),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    final totalAmount = orderData['totalAmount'] as double;
    final remainingAmount = totalAmount - amount;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Информация о заказе',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            _buildInfoRow('Адрес получения:', orderData['address']),
            _buildInfoRow('Время получения:', orderData['deliveryTime']),
            _buildInfoRow(
                'Общая сумма заказа:', '${totalAmount.toStringAsFixed(0)} ₽'),
            _buildInfoRow('Предоплачено:', '${amount.toStringAsFixed(0)} ₽'),
            _buildInfoRow('К доплате при получении:',
                '${remainingAmount.toStringAsFixed(0)} ₽',
                isHighlighted: true),
          ],
        ),
      ),
    );
  }

  Widget _buildNextSteps() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Что дальше?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildStepItem(
                '1', 'Мы обработаем ваш заказ в течение 1-2 рабочих дней'),
            _buildStepItem(
                '2', 'Отправим SMS, когда товары будут готовы к выдаче'),
            _buildStepItem('3', 'Приходите в пункт выдачи в удобное время'),
            _buildStepItem(
                '4', 'Доплачиваете оставшуюся сумму и получаете товары'),
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '📍 Пункт выдачи',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('ул. Ленина, 15, магазин "Северянка"'),
                  Text('📞 +7 (914) 123-45-67'),
                  Text('🕐 Пн-Пт: 9:00-19:00, Сб: 10:00-16:00'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool isSuccess = false, bool isHighlighted = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                if (isSuccess) ...[
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontWeight:
                          isHighlighted ? FontWeight.bold : FontWeight.normal,
                      color: isHighlighted ? Colors.orange[700] : null,
                    ),
                  ),
                ),
                if (label.contains('Номер платежа')) ...[
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      // Показать уведомление о копировании
                    },
                    child: Icon(Icons.copy, size: 16, color: Colors.blue),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () {
              // Возвращаемся к главному экрану
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: Icon(Icons.home),
            label: Text('На главную'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Переход к заказам
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // TODO: Переключиться на вкладку заказов
                },
                icon: Icon(Icons.list_alt),
                label: Text('Мои заказы'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Продолжить покупки
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // TODO: Переключиться на вкладку каталога
                },
                icon: Icon(Icons.shopping_bag),
                label: Text('Продолжить'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
