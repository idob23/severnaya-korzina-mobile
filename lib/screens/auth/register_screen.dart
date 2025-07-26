// lib/screens/auth/register_screen.dart - ПОЛНОСТЬЮ ОБНОВЛЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
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

  // Маска для номера телефона
  final _phoneMask = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

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
                  inputFormatters: [_phoneMask],
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
                    hintText: '+7 (999) 123-45-67',
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
                      return 'Номер должен начинаться с +7';
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.blue, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Безопасная регистрация',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ваши данные сохраняются локально на устройстве и защищены шифрованием. Доступ подтверждается через SMS.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),

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
                          MaterialPageRoute(builder: (_) => LoginScreen()),
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

                SizedBox(height: 16),

                // Информация о проекте
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
                          Icon(Icons.info_outline,
                              color: Colors.green, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Северная корзина',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.green[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Коллективные закупки для жителей Усть-Неры. Объединяем заказы и получаем скидки до 70%. Предоплата 90%, остальное при получении.',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),
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

    // Получаем данные из формы
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = '+$cleanPhone';
    final email = _emailController.text.trim();

    // Регистрируем пользователя
    final success = await authProvider.register(
      formattedPhone,
      firstName,
      '', // Пустой пароль для SMS авторизации
      lastName: lastName.isEmpty ? null : lastName,
    );

    if (success) {
      // Сохраняем email если был введен
      if (email.isNotEmpty && authProvider.currentUser != null) {
        await authProvider.updateUserProfile(email: email);
      }

      // Показываем сообщение об успехе
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Регистрация успешна! Теперь войдите в систему'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Переходим к экрану входа
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
    // Ошибки отображаются через Consumer выше
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
