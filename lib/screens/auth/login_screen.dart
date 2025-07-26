// lib/screens/auth/login_screen.dart - ПОЛНОСТЬЮ ОБНОВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'sms_verification_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _rememberMe = false;

  // Маска для номера телефона
  final _phoneMask = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  // Проверяем возможность автологина
  void _checkAutoLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Небольшая задержка для красивой анимации
    await Future.delayed(Duration(milliseconds: 500));

    if (authProvider.isAuthenticated) {
      // Пользователь уже авторизован, переходим на главный экран
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Вход'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom -
                  AppBar().preferredSize.height -
                  48,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 40),

                  // Логотип
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.shopping_basket,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Добро пожаловать!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Введите номер телефона для входа\nв Северную корзину',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40),

                  // Поле ввода телефона
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [_phoneMask],
                    decoration: InputDecoration(
                      labelText: 'Номер телефона',
                      prefixIcon: Icon(Icons.phone, color: Colors.blue),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                      hintText: '+7 (999) 123-45-67',
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите номер телефона';
                      }

                      // Убираем все символы кроме цифр
                      final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

                      if (cleanPhone.length != 11) {
                        return 'Номер должен содержать 11 цифр';
                      }

                      if (!cleanPhone.startsWith('7')) {
                        return 'Номер должен начинаться с +7';
                      }

                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Чекбокс "Запомнить меня"
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (value) {
                                setState(() {
                                  _rememberMe = value ?? false;
                                });
                              },
                              activeColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Оставаться в системе',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue[800],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_rememberMe) ...[
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue[600], size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Вы останетесь в системе на 30 дней. SMS не будет запрашиваться при следующих входах.',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 32),

                  // Кнопка входа
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  authProvider.isLoading ? null : _sendSMS,
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
                                        Text('Отправляем SMS...'),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.sms, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Получить SMS код',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
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

                  // Кнопка "Назад"
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Назад к выбору',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendSMS() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    // Получаем чистый номер телефона
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = '+$cleanPhone';

    // Проверяем автологин для этого номера
    final canAutoLogin = await authProvider.canAutoLogin(formattedPhone);
    if (canAutoLogin && _rememberMe) {
      // Пользователь может войти автоматически
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Выполняется автоматический вход...'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(Duration(seconds: 1));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
      return;
    }

    // Отправляем SMS
    final success = await authProvider.sendSMSCode(formattedPhone);

    if (success) {
      // SMS отправлено, переходим к экрану подтверждения
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SMSVerificationScreen(
            phone: formattedPhone,
            rememberMe: _rememberMe,
          ),
        ),
      );
    }
    // Ошибки отображаются через Consumer выше
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
