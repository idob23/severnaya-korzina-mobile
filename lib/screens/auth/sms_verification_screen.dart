// lib/screens/auth/sms_verification_screen.dart - ПОЛНОСТЬЮ ОБНОВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SMSVerificationScreen extends StatefulWidget {
  final String phone;
  final bool rememberMe;

  const SMSVerificationScreen({
    Key? key,
    required this.phone,
    this.rememberMe = false,
  }) : super(key: key);

  @override
  _SMSVerificationScreenState createState() => _SMSVerificationScreenState();
}

class _SMSVerificationScreenState extends State<SMSVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;
  String _enteredCode = '';

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Автофокус на первое поле
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
  }

  void _startResendTimer() {
    _canResend = false;
    _resendCountdown = 60;

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Подтверждение'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Иконка SMS
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Icon(
                        Icons.sms,
                        size: 40,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 24),

                    Text(
                      'Введите код из SMS',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    SizedBox(height: 8),

                    Text(
                      'Код отправлен на номер',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4),

                    Text(
                      widget.phone,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 40),

                    // Поля ввода кода
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          width: 60,
                          height: 60,
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.blue, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                // Переход к следующему полю
                                if (index < 3) {
                                  _focusNodes[index + 1].requestFocus();
                                } else {
                                  // Все поля заполнены, убираем фокус
                                  _focusNodes[index].unfocus();
                                }
                              } else {
                                // Переход к предыдущему полю при удалении
                                if (index > 0) {
                                  _focusNodes[index - 1].requestFocus();
                                }
                              }

                              // Обновляем введенный код
                              _updateEnteredCode();

                              // Автоматическая проверка когда введены все 4 цифры
                              if (_enteredCode.length == 4) {
                                Future.delayed(Duration(milliseconds: 500), () {
                                  _verifyCode();
                                });
                              }
                            },
                            onTap: () {
                              // Очищаем поле при нажатии
                              _controllers[index].clear();
                              _updateEnteredCode();
                            },
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 32),

                    // Кнопка подтверждения
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: (_enteredCode.length == 4 &&
                                        !authProvider.isLoading)
                                    ? _verifyCode
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text('Проверяем код...'),
                                        ],
                                      )
                                    : Text(
                                        'Подтвердить',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            // Отображение ошибок
                            if (authProvider.lastError != null) ...[
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        authProvider.lastError!,
                                        style: TextStyle(
                                          color: Colors.red[800],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 24),

                    // Кнопка повторной отправки
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Column(
                          children: [
                            if (!_canResend) ...[
                              Text(
                                'Повторная отправка через $_resendCountdown сек',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ] else ...[
                              TextButton(
                                onPressed:
                                    authProvider.isLoading ? null : _resendSMS,
                                child: Text(
                                  'Отправить код повторно',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),

                    SizedBox(height: 16),

                    // Информация о автоподключении
                    if (widget.rememberMe) ...[
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Автоподключение активно',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green[800],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'После подтверждения вы останетесь в системе на 30 дней',
                              style: TextStyle(
                                color: Colors.green[700],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],

                    Text(
                      'Мы отправили код подтверждения на номер ${widget.phone}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Кнопка "Назад"
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Изменить номер телефона',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateEnteredCode() {
    _enteredCode = _controllers.map((controller) => controller.text).join();
    setState(() {});
  }

  Future<void> _verifyCode() async {
    if (_enteredCode.length != 4) {
      _showErrorSnackBar('Введите 4-значный код');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    try {
      // Верификация через SMS сервис
      final success = await authProvider.verifySMSAndLogin(
        widget.phone,
        _enteredCode,
        rememberMe: widget.rememberMe,
      );

      if (!mounted) return;

      if (success) {
        // Показываем сообщение об успехе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Добро пожаловать!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Добавляем задержку для веб
        if (kIsWeb) {
          await Future.delayed(Duration(milliseconds: 500));
        }

        if (!mounted) return;

        // Переходим на главный экран
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      print('Verification error: $e');
    }
  }

  Future<void> _resendSMS() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final success = await authProvider.sendSMSCode(widget.phone);

    if (success) {
      // Очищаем поля ввода
      for (var controller in _controllers) {
        controller.clear();
      }
      _updateEnteredCode();

      // Устанавливаем фокус на первое поле
      _focusNodes[0].requestFocus();

      // Перезапускаем таймер
      _startResendTimer();

      _showSuccessSnackBar('SMS код отправлен повторно');
    }
    // Ошибки отображаются через Consumer выше
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
