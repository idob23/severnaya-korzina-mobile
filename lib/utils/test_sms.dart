// lib/utils/test_sms.dart
// Создайте этот файл для тестирования SMS сервиса

import 'package:flutter/material.dart';
import '../services/sms_service.dart';

class TestSMSScreen extends StatefulWidget {
  @override
  _TestSMSScreenState createState() => _TestSMSScreenState();
}

class _TestSMSScreenState extends State<TestSMSScreen> {
  final SMSService _smsService = SMSService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  String _status = 'Готов к тестированию';
  String _balance = 'Не проверен';
  bool _isLoading = false;
  String? _lastSentCode;

  @override
  void initState() {
    super.initState();
    _checkBalance();
  }

  Future<void> _checkBalance() async {
    setState(() {
      _status = 'Проверяем баланс...';
    });

    final result = await _smsService.checkBalance();

    setState(() {
      if (result['success'] == true) {
        _balance = '${result['balance']} руб';
        _status = 'Баланс получен';
      } else {
        _balance = 'Ошибка проверки';
        _status = 'Не удалось проверить баланс';
      }
    });
  }

  Future<void> _sendTestSMS() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() {
        _status = 'Введите номер телефона';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Отправляем SMS...';
    });

    try {
      final success = await _smsService.sendVerificationCode(phone);

      // Получаем код для отладки
      _lastSentCode = _smsService.getLastCodeForPhone(phone);

      setState(() {
        _isLoading = false;
        if (success) {
          _status = 'SMS отправлено успешно!\nКод для отладки: $_lastSentCode';
        } else {
          _status = 'Ошибка отправки SMS';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Ошибка: $e';
      });
    }
  }

  Future<void> _verifyCode() async {
    final phone = _phoneController.text.trim();
    final code = _codeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      setState(() {
        _status = 'Введите номер и код';
      });
      return;
    }

    final isValid = _smsService.verifyCode(phone, code);

    setState(() {
      if (isValid) {
        _status = '✅ Код верный!';
      } else {
        _status = '❌ Неверный код';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тест SMS сервиса'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Информация о балансе
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Баланс SMS Aero',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _balance,
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _checkBalance,
                      icon: Icon(Icons.refresh),
                      label: Text('Обновить баланс'),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Поле для номера телефона
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Номер телефона',
                hintText: '+7 (914) 266-75-82',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),

            SizedBox(height: 16),

            // Кнопка отправки SMS
            ElevatedButton(
              onPressed: _isLoading ? null : _sendTestSMS,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.green,
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Отправить тестовое SMS',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),

            SizedBox(height: 20),

            // Поле для кода
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Код из SMS',
                hintText: '1234',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
            ),

            // Кнопка проверки кода
            ElevatedButton(
              onPressed: _verifyCode,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.blue,
              ),
              child: Text(
                'Проверить код',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

            SizedBox(height: 20),

            // Статус
            Card(
              color: _status.contains('успешно')
                  ? Colors.green[50]
                  : _status.contains('Ошибка')
                      ? Colors.red[50]
                      : Colors.grey[100],
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      'Статус:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    if (_lastSentCode != null) ...[
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.yellow[100],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          '⚠️ Код для отладки: $_lastSentCode',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
