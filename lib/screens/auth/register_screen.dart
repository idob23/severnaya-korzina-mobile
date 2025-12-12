// lib/screens/auth/register_screen.dart - УЛУЧШЕННАЯ ВЕРСИЯ С СЕВЕРНОЙ ТЕМОЙ

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'login_screen.dart';
import 'sms_verification_screen.dart';
import 'package:flutter/foundation.dart';
import '../home/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Добавляем импорты дизайн-системы
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _acceptedTerms = false;
  bool _formSubmitted = false;

  // Добавляем анимации
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Градиентный фон
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.ice,
              AppColors.aurora3.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Кастомный AppBar с градиентом
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text(
                        'Регистрация',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Балансировка для центровки
                  ],
                ),
              ),

              // Форма с анимацией
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Анимированная иконка
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 1000),
                              builder: (context, double value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    margin: EdgeInsets.only(bottom: 24),
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.aurora,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.aurora2
                                              .withOpacity(0.4),
                                          blurRadius: 20,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.person_add,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Поле "Имя" с улучшенным дизайном
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _firstNameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: 'Имя *',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.primary,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.person,
                                        color: Colors.white, size: 20),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Введите имя';
                                  }
                                  if (value.trim().length < 2) {
                                    return 'Имя должно содержать минимум 2 символа';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 16),

                            // Поле "Фамилия" с улучшенным дизайном
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _lastNameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: InputDecoration(
                                  labelText: 'Фамилия',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.success,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.badge,
                                        color: Colors.white, size: 20),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
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
                            ),
                            SizedBox(height: 16),

                            // Поле "Номер телефона" с премиум дизайном
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                      10), // Изменено на 10 цифр
                                ],
                                decoration: InputDecoration(
                                  labelText: 'Номер телефона *',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: AppGradients.aurora,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.phone_android,
                                        color: Colors.white, size: 20),
                                  ),
                                  prefixText: '+7 ', // Добавлен префикс
                                  prefixStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  hintText: '914 123 45 67', // Изменен пример
                                  helperText:
                                      'Для подтверждения будет отправлен SMS',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Введите номер телефона';
                                  }
                                  if (value.length != 10) {
                                    // Проверка на 10 цифр
                                    return 'Номер должен содержать 10 цифр после +7';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 16),

                            // Поле "Email" с премиум дизайном
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.shadowLight,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue, Colors.lightBlue],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.email,
                                        color: Colors.white, size: 20),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 16),
                                  helperText: 'Необязательное поле',
                                ),
                                validator: (value) {
                                  if (value != null &&
                                      value.trim().isNotEmpty) {
                                    final emailRegex =
                                        RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Введите корректный email';
                                    }
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(height: 16),

                            // Информационная карточка с градиентом
                            Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.info.withOpacity(0.1),
                                    AppColors.info.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.info.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.info_outline,
                                        color: AppColors.info, size: 20),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'На указанный номер будет отправлен SMS с кодом подтверждения',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 24),

                            // Чекбокс согласия с анимацией
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                gradient: _acceptedTerms
                                    ? LinearGradient(
                                        colors: [
                                          AppColors.success.withOpacity(0.1),
                                          AppColors.success.withOpacity(0.05),
                                        ],
                                      )
                                    : null,
                                color: _acceptedTerms ? null : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _acceptedTerms
                                      ? AppColors.success
                                      : (_formSubmitted && !_acceptedTerms
                                          ? AppColors.error
                                          : AppColors.border),
                                  width: _acceptedTerms ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _acceptedTerms
                                        ? AppColors.success.withOpacity(0.2)
                                        : AppColors.shadowLight,
                                    blurRadius: 10,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: CheckboxListTile(
                                value: _acceptedTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptedTerms = value ?? false;
                                  });
                                  if (value == true) {
                                    HapticFeedback.lightImpact();
                                  }
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                activeColor: AppColors.success,
                                checkColor: Colors.white,
                                title: Wrap(
                                  children: [
                                    Text('Я принимаю условия ',
                                        style: TextStyle(fontSize: 14)),
                                    GestureDetector(
                                      onTap: () => _openDocument('terms'),
                                      child: Text(
                                        'Пользовательского соглашения',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryLight,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(', ', style: TextStyle(fontSize: 14)),
                                    GestureDetector(
                                      onTap: () => _openDocument('privacy'),
                                      child: Text(
                                        'Политики конфиденциальности',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryLight,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Text(' и ', style: TextStyle(fontSize: 14)),
                                    GestureDetector(
                                      onTap: () => _openDocument('offer'),
                                      child: Text(
                                        'Публичной оферты',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primaryLight,
                                          decoration: TextDecoration.underline,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Кнопка "Зарегистрироваться" с градиентом
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, _) {
                                return Column(
                                  children: [
                                    Container(
                                      height: 56,
                                      decoration: BoxDecoration(
                                        gradient: AppGradients.button,
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryLight
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: authProvider.isLoading
                                            ? null
                                            : _register,
                                        icon: authProvider.isLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                          Color>(Colors.white),
                                                ),
                                              )
                                            : Icon(Icons.app_registration,
                                                color: Colors.white),
                                        label: Text(
                                          authProvider.isLoading
                                              ? 'Регистрация...'
                                              : 'Зарегистрироваться',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(28),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Показываем ошибку с анимацией
                                    if (authProvider.lastError != null) ...[
                                      SizedBox(height: 16),
                                      AnimatedContainer(
                                        duration: Duration(milliseconds: 300),
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color:
                                              AppColors.error.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.error
                                                .withOpacity(0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: AppColors.error,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                authProvider.lastError!,
                                                style: TextStyle(
                                                  color: AppColors.error,
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

                            // Ссылка на вход с анимацией
                            TweenAnimationBuilder(
                              tween: Tween<double>(begin: 0, end: 1),
                              duration: Duration(milliseconds: 1200),
                              builder: (context, double value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Уже есть аккаунт? ',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 16,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  LoginScreen(),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          'Войти',
                                          style: TextStyle(
                                            color: AppColors.primaryLight,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ВСЕ МЕТОДЫ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ
  Future<void> _register() async {
    setState(() {
      _formSubmitted = true;
    });

    if (!_acceptedTerms) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Необходимо принять условия использования'),
              ),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = '+7$cleanPhone'; // Добавляем +7 к введенному номеру

    print('📝 Попытка регистрации:');
    print('Имя: $firstName');
    print('Фамилия: $lastName');
    print('Телефон: $formattedPhone');
    print('Email: $email');
    print('Согласие принято: $_acceptedTerms');

    try {
      final success = await authProvider.register(
        formattedPhone,
        firstName,
        'password',
        lastName: lastName.isNotEmpty ? lastName : null,
        email: email.isNotEmpty ? email : null,
        acceptedTerms: _acceptedTerms,
      );

      if (!mounted) return;

      if (success) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Регистрация успешна! Отправляем SMS...'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(Duration(seconds: 1));

        if (!mounted) return;

        final smsSuccess = await authProvider.sendSMSCode(formattedPhone);

        if (!mounted) return;

        if (smsSuccess) {
          if (kIsWeb) {
            await Future.delayed(Duration(milliseconds: 300));
          }

          if (!mounted) return;

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SMSVerificationScreen(
                phone: formattedPhone,
                rememberMe: true,
              ),
            ),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child:
                          Text('Не удалось отправить SMS. Попробуйте войти.'),
                    )
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );

            await Future.delayed(Duration(seconds: 2));

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            }
          }
        }
      } else {
        if (authProvider.lastError != null && mounted) {
          print('❌ Ошибка регистрации: ${authProvider.lastError}');
        }
      }
    } catch (e) {
      print('❌ Исключение при регистрации: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Ошибка регистрации. Попробуйте позже.'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openDocument(String type) {
    String url = '';
    String title = '';

    switch (type) {
      case 'terms':
        url = 'https://sevkorzina.ru//agreement.html';
        title = 'Пользовательское соглашение';
        break;
      case 'privacy':
        url = 'https://sevkorzina.ru//privacy.html';
        title = 'Политика конфиденциальности';
        break;
      case 'offer':
        url = 'https://sevkorzina.ru//offer.html';
        title = 'Публичная оферта';
        break;
    }

    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}
