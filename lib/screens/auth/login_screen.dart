// // lib/screens/auth/login_screen.dart - ПОЛНОСТЬЮ ОБНОВЛЕННАЯ ВЕРСИЯ
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
// import '../../providers/auth_provider.dart';
// import '../home/home_screen.dart';
// import 'sms_verification_screen.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:shared_preferences/shared_preferences.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _phoneController = TextEditingController();
//   bool _rememberMe = true;

//   // Маска для номера телефона
//   final _phoneMask = MaskTextInputFormatter(
//     mask: '+7 (###) ###-##-##',
//     filter: {'#': RegExp(r'[0-9]')},
//     type: MaskAutoCompletionType.lazy,
//   );

//   @override
//   void initState() {
//     super.initState();
//     _checkAutoLogin();
//   }

//   // Проверяем возможность автологина
//   void _checkAutoLogin() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);

//     // Небольшая задержка для красивой анимации
//     await Future.delayed(Duration(milliseconds: 500));

//     if (authProvider.isAuthenticated) {
//       // Пользователь уже авторизован, переходим на главный экран
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => HomeScreen()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Вход'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(24.0),
//             child: Container(
//               constraints: BoxConstraints(maxWidth: 400),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     // Логотип
//                     Container(
//                       alignment: Alignment.center,
//                       margin: EdgeInsets.only(bottom: 24),
//                       child: Container(
//                         width: 100,
//                         height: 100,
//                         decoration: BoxDecoration(
//                           color: Colors.blue.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.shopping_basket,
//                           size: 50,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),

//                     Text(
//                       'Добро пожаловать!',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.blue,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),

//                     SizedBox(height: 8),

//                     Text(
//                       'Введите номер телефона для входа\nв Северную корзину',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey[600],
//                       ),
//                     ),

//                     SizedBox(height: 40),

//                     // Поле ввода телефона
//                     TextFormField(
//                       controller: _phoneController,
//                       keyboardType: TextInputType.phone,
//                       inputFormatters: [_phoneMask],
//                       decoration: InputDecoration(
//                         labelText: 'Номер телефона',
//                         prefixIcon: Icon(Icons.phone, color: Colors.blue),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: Colors.blue, width: 2),
//                         ),
//                         hintText: '+7 (999) 123-45-67',
//                         filled: true,
//                         fillColor: Colors.grey[50],
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Введите номер телефона';
//                         }

//                         // Убираем все символы кроме цифр
//                         final cleanPhone =
//                             value.replaceAll(RegExp(r'[^\d]'), '');

//                         if (cleanPhone.length != 11) {
//                           return 'Номер должен содержать 11 цифр';
//                         }

//                         if (!cleanPhone.startsWith('7')) {
//                           return 'Номер должен начинаться с +7';
//                         }

//                         return null;
//                       },
//                     ),

//                     SizedBox(height: 20),

//                     // Кнопка входа
//                     Consumer<AuthProvider>(
//                       builder: (context, authProvider, child) {
//                         return Column(
//                           children: [
//                             SizedBox(
//                               width: double.infinity,
//                               height: 52,
//                               child: ElevatedButton(
//                                 onPressed:
//                                     authProvider.isLoading ? null : _sendSMS,
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.blue,
//                                   foregroundColor: Colors.white,
//                                   elevation: 2,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                                 child: authProvider.isLoading
//                                     ? Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(
//                                             width: 20,
//                                             height: 20,
//                                             child: CircularProgressIndicator(
//                                               color: Colors.white,
//                                               strokeWidth: 2,
//                                             ),
//                                           ),
//                                           SizedBox(width: 12),
//                                           Text('Отправляем SMS...'),
//                                         ],
//                                       )
//                                     : Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           Icon(Icons.sms, size: 20),
//                                           SizedBox(width: 8),
//                                           Text(
//                                             'Получить SMS код',
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                               ),
//                             ),

//                             // Отображение ошибок
//                             if (authProvider.lastError != null) ...[
//                               SizedBox(height: 16),
//                               Container(
//                                 padding: EdgeInsets.all(12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red[50],
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(color: Colors.red[200]!),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     Icon(Icons.error_outline,
//                                         color: Colors.red, size: 20),
//                                     SizedBox(width: 8),
//                                     Expanded(
//                                       child: Text(
//                                         authProvider.lastError!,
//                                         style: TextStyle(
//                                           color: Colors.red[800],
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ],
//                         );
//                       },
//                     ),

//                     SizedBox(height: 24),

//                     // Кнопка "Назад"
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                       },
//                       child: Text(
//                         'Назад к выбору',
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),

//                     SizedBox(height: 40),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _sendSMS() async {
//     if (!_formKey.currentState!.validate()) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     authProvider.clearError();

//     // Получаем чистый номер телефона
//     final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
//     final formattedPhone = '+$cleanPhone';

//     // Для веб-версии добавляем проверку mounted
//     if (!mounted) return;

//     try {
//       final success = await authProvider.sendSMSCode(formattedPhone);

//       if (!mounted) return;

//       if (success) {
//         // SMS отправлено, переходим к экрану подтверждения
//         // Добавляем небольшую задержку для веб
//         if (kIsWeb) {
//           await Future.delayed(Duration(milliseconds: 200));
//         }

//         if (!mounted) return;

//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => SMSVerificationScreen(
//               phone: formattedPhone,
//               rememberMe: _rememberMe,
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error sending SMS: $e');
//     }
//   }

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }
// }

// lib/screens/auth/login_screen.dart - УЛУЧШЕННАЯ ВЕРСИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'sms_verification_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
// Добавляем импорты дизайн-системы
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _rememberMe = true;

  // Добавляем анимацию
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Маска для номера телефона
  final _phoneMask = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: {'#': RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();

    // Инициализируем анимацию
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();

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
  void dispose() {
    _phoneController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _sendSMS() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact(); // Добавляем haptic feedback

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Получаем чистый номер телефона
    final cleanPhone = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    final formattedPhone = '+$cleanPhone';

    // Для веб-версии добавляем проверку mounted
    if (!mounted) return;

    try {
      final success = await authProvider.sendSMSCode(formattedPhone);

      if (!mounted) return;

      if (success) {
        // SMS отправлено, переходим к экрану подтверждения
        // Добавляем небольшую задержку для веб
        if (kIsWeb) {
          await Future.delayed(Duration(milliseconds: 200));
        }

        if (!mounted) return;

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
    } catch (e) {
      print('Error sending SMS: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Убираем стандартный AppBar и делаем градиентный фон
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryLight.withOpacity(0.7),
              AppColors.aurora3.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Кнопка назад
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    SizedBox(height: 20),

                    // Иконка телефона с анимацией
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppGradients.aurora,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.aurora2.withOpacity(0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.phone_android,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 32),

                    // Заголовок
                    Text(
                      'Вход',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8),

                    Text(
                      'Введите номер телефона для входа',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: 40),

                    // Форма
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Поле ввода телефона с улучшенным дизайном
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryLight.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [_phoneMask],
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryDark,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Номер телефона',
                                hintText: '+7 (___) ___-__-__',
                                labelStyle: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                                hintStyle: TextStyle(
                                  color:
                                      AppColors.textSecondary.withOpacity(0.5),
                                ),
                                prefixIcon: Container(
                                  margin: EdgeInsets.all(8),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.button,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.phone,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Введите номер телефона';
                                }
                                if (value
                                        .replaceAll(RegExp(r'[^\d]'), '')
                                        .length !=
                                    11) {
                                  return 'Введите корректный номер';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _sendSMS(),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Чекбокс "Запомнить меня" с улучшенным дизайном
                          AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(_rememberMe ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _rememberMe = !_rememberMe;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      gradient: _rememberMe
                                          ? AppGradients.success
                                          : null,
                                      color: _rememberMe
                                          ? null
                                          : Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: _rememberMe
                                        ? Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Запомнить меня',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 32),

                    // Кнопка "Получить код" с градиентом
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return Container(
                          width: double.infinity,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: authProvider.isLoading
                                ? null
                                : AppGradients.button,
                            color: authProvider.isLoading ? Colors.grey : null,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: authProvider.isLoading
                                ? []
                                : [
                                    BoxShadow(
                                      color: AppColors.primaryLight
                                          .withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: authProvider.isLoading ? null : _sendSMS,
                              borderRadius: BorderRadius.circular(12),
                              child: Center(
                                child: authProvider.isLoading
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'Получить код',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Убираем отображение ошибок, так как поля error нет в AuthProvider

                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
