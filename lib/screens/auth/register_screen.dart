// ========================================
// 2. lib/screens/auth/register_screen.dart
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Регистрация'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20),

                // Логотип и заголовок
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Icon(
                    Icons.person_add,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 24),

                Text(
                  'Создать аккаунт',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(height: 8),

                Text(
                  'Присоединяйтесь к коллективным закупкам\nи экономьте до 70%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 32),

                // Поле "Имя"
                TextFormField(
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Имя *',
                    prefixIcon: Icon(Icons.person, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите ваше имя';
                    }
                    if (value.trim().length < 2) {
                      return 'Имя должно содержать минимум 2 символа';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Поле "Фамилия" (необязательное)
                TextFormField(
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Фамилия',
                    prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    helperText: 'Необязательное поле',
                  ),
                  validator: (value) {
                    if (value != null &&
                        value.trim().isNotEmpty &&
                        value.trim().length < 2) {
                      return 'Фамилия должна содержать минимум 2 символа';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Поле "Номер телефона"
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Номер телефона *',
                    prefixIcon: Icon(Icons.phone, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    hintText: '79141234567',
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    helperText: 'Для подтверждения будет отправлен SMS',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Введите номер телефона';
                    }

                    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

                    if (cleanPhone.length != 11) {
                      return 'Номер должен содержать 11 цифр';
                    }

                    if (!cleanPhone.startsWith('7')) {
                      return 'Номер должен начинаться с 7';
                    }

                    return null;
                  },
                ),
                SizedBox(height: 16),

                // Поле "Email" (необязательное)
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.blue, width: 2),
                    ),
                    hintText: 'example@mail.ru',
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    helperText: 'Необязательное поле',
                  ),
                  validator: (value) {
                    if (value != null && value.trim().isNotEmpty) {
                      final emailRegex =
                          RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Введите корректный email адрес';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),

                // Информационное сообщение
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'На указанный номер будет отправлен SMS с кодом подтверждения',
                          style: TextStyle(
                            color: Colors.blue[800],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Кнопка регистрации
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed:
                                authProvider.isLoading ? null : _register,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                      Text('Регистрируем...'),
                                    ],
                                  )
                                : Text(
                                    'Зарегистрироваться',
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

                // Ссылка на вход
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Уже есть аккаунт? ',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Войти',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    // Получаем данные из полей
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    // Форматируем номер телефона
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = '+$cleanPhone';

    print('📝 Попытка регистрации:');
    print('Имя: $firstName');
    print('Фамилия: $lastName');
    print('Телефон: $formattedPhone');
    print('Email: $email');

    // Пробуем зарегистрировать через API
    final success = await authProvider.register(
      formattedPhone,
      firstName,
      'password', // Пароль не используется в нашей системе
      lastName: lastName.isNotEmpty ? lastName : null,
    );

    if (success) {
      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Регистрация прошла успешно!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Переходим на главный экран (авторизация уже произошла)
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/main',
        (route) => false,
      );
    } else {
      // Ошибка уже отображается через Consumer<AuthProvider>
      print('❌ Ошибка регистрации: ${authProvider.lastError}');
    }
  }
}
