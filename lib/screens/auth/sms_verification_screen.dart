import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:severnaya_korzina/providers/auth_provider.dart';
import '../home/home_screen.dart';

class SMSVerificationScreen extends StatefulWidget {
  final String phone;
  final bool rememberMe;

  SMSVerificationScreen({
    required this.phone,
    this.rememberMe = false,
  });

  @override
  _SMSVerificationScreenState createState() => _SMSVerificationScreenState();
}

class _SMSVerificationScreenState extends State<SMSVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  int _seconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _seconds > 0) {
        setState(() {
          _seconds--;
        });
        _startTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Подтверждение'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sms,
                size: 80,
                color: Colors.blue,
              ),
              SizedBox(height: 24),
              Text(
                'Введите код из SMS',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Мы отправили код на номер',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 8),
              Text(
                widget.phone,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(height: 32),

              // Поле для ввода кода
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  labelText: 'Код из SMS',
                  hintText: '1234',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                maxLength: 4,
                onChanged: (value) {
                  if (value.length == 4) {
                    _verifyCode();
                  }
                },
              ),
              SizedBox(height: 24),

              // Кнопка подтверждения
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Подтвердить',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
              SizedBox(height: 24),

              // Таймер и повторная отправка
              if (!_canResend)
                Text(
                  'Повторно отправить код через $_seconds сек',
                  style: TextStyle(color: Colors.grey[600]),
                )
              else
                TextButton(
                  onPressed: _resendCode,
                  child: Text(
                    'Отправить код повторно',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              SizedBox(height: 16),

              // Информация о временном коде
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange),
                    SizedBox(height: 8),
                    Text(
                      'Для демонстрации',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                    Text(
                      'Используйте код: 1234',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Введите 4-значный код'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Имитация проверки кода (для демо используем код 1234)
    await Future.delayed(Duration(seconds: 2));

    if (_codeController.text == '1234') {
      // Код правильный - авторизуем пользователя
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Авторизуем пользователя
      await authProvider.login(
          widget.phone, ''); // Пустой пароль для SMS авторизации

      // Если включено автоподключение, сохраняем это
      if (widget.rememberMe) {
        // TODO: В будущем здесь будет сохранение настройки автоподключения
        print('Автоподключение включено на 30 дней для ${widget.phone}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Автоподключение активировано на 30 дней'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Добро пожаловать!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Небольшая задержка чтобы пользователь увидел сообщение
      await Future.delayed(Duration(milliseconds: 500));

      // Переходим в основное приложение
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false, // Удаляем все предыдущие экраны
      );
    } else {
      // Неправильный код
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Неправильный код. Попробуйте еще раз.'),
          backgroundColor: Colors.red,
        ),
      );
      _codeController.clear();
    }

    setState(() => _isLoading = false);
  }

  void _resendCode() {
    setState(() {
      _seconds = 60;
      _canResend = false;
    });
    _startTimer();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Код отправлен повторно'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }
}
