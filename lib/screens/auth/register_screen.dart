// // ========================================
// // 2. lib/screens/auth/register_screen.dart
// // ========================================

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import 'login_screen.dart';
// import 'sms_verification_screen.dart';
// import 'package:flutter/foundation.dart';
// import '../home/home_screen.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _emailController = TextEditingController();
//   bool _acceptedTerms = false;
//   bool _formSubmitted = false;

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _phoneController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Регистрация'),
//         backgroundColor: Colors.blue,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 SizedBox(height: 20),

//                 // Логотип и заголовок
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.blue.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(40),
//                   ),
//                   child: Icon(
//                     Icons.person_add,
//                     size: 40,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 SizedBox(height: 24),

//                 Text(
//                   'Создать аккаунт',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//                 SizedBox(height: 8),

//                 Text(
//                   'Присоединяйтесь к коллективным закупкам\nи экономьте до 70%',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 SizedBox(height: 32),

//                 // Поле "Имя"
//                 TextFormField(
//                   controller: _firstNameController,
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                     labelText: 'Имя *',
//                     prefixIcon: Icon(Icons.person, color: Colors.blue),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.blue, width: 2),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.trim().isEmpty) {
//                       return 'Введите ваше имя';
//                     }
//                     if (value.trim().length < 2) {
//                       return 'Имя должно содержать минимум 2 символа';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),

//                 // Поле "Фамилия" (необязательное)
//                 TextFormField(
//                   controller: _lastNameController,
//                   textCapitalization: TextCapitalization.words,
//                   decoration: InputDecoration(
//                     labelText: 'Фамилия',
//                     prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.blue, width: 2),
//                     ),
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     helperText: 'Необязательное поле',
//                   ),
//                   validator: (value) {
//                     if (value != null &&
//                         value.trim().isNotEmpty &&
//                         value.trim().length < 2) {
//                       return 'Фамилия должна содержать минимум 2 символа';
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),

//                 // Поле "Номер телефона"
//                 TextFormField(
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     LengthLimitingTextInputFormatter(11),
//                   ],
//                   decoration: InputDecoration(
//                     labelText: 'Номер телефона *',
//                     prefixIcon: Icon(Icons.phone, color: Colors.blue),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.blue, width: 2),
//                     ),
//                     hintText: '79141234567',
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     helperText: 'Для подтверждения будет отправлен SMS',
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Введите номер телефона';
//                     }

//                     final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');

//                     if (cleanPhone.length != 11) {
//                       return 'Номер должен содержать 11 цифр';
//                     }

//                     if (!cleanPhone.startsWith('7')) {
//                       return 'Номер должен начинаться с 7';
//                     }

//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 16),

//                 // Поле "Email" (необязательное)
//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     labelText: 'Email',
//                     prefixIcon: Icon(Icons.email, color: Colors.blue),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.blue, width: 2),
//                     ),
//                     hintText: 'example@mail.ru',
//                     filled: true,
//                     fillColor: Colors.grey[50],
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                     helperText: 'Необязательное поле',
//                   ),
//                   validator: (value) {
//                     if (value != null && value.trim().isNotEmpty) {
//                       final emailRegex =
//                           RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
//                       if (!emailRegex.hasMatch(value.trim())) {
//                         return 'Введите корректный email адрес';
//                       }
//                     }
//                     return null;
//                   },
//                 ),
//                 SizedBox(height: 24),

//                 // Информационное сообщение
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.blue[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.blue[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info_outline, color: Colors.blue),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'На указанный номер будет отправлен SMS с кодом подтверждения',
//                           style: TextStyle(
//                             color: Colors.blue[800],
//                             fontSize: 14,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 24),

//                 // НОВЫЙ БЛОК: Чекбокс согласия с условиями
//                 Container(
//                   decoration: BoxDecoration(
//                     color: _acceptedTerms ? Colors.green[50] : Colors.grey[50],
//                     border: Border.all(
//                       color: _acceptedTerms
//                           ? Colors.green
//                           : (_formSubmitted && !_acceptedTerms
//                               ? Colors.red
//                               : Colors.grey[300]!),
//                       width: 1,
//                     ),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: CheckboxListTile(
//                     value: _acceptedTerms,
//                     onChanged: (value) {
//                       setState(() {
//                         _acceptedTerms = value ?? false;
//                       });
//                     },
//                     controlAffinity: ListTileControlAffinity.leading,
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     title: Wrap(
//                       children: [
//                         Text('Я принимаю условия ',
//                             style: TextStyle(fontSize: 14)),
//                         GestureDetector(
//                           onTap: () => _openDocument('terms'),
//                           child: Text(
//                             'Пользовательского соглашения',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Text(', ', style: TextStyle(fontSize: 14)),
//                         GestureDetector(
//                           onTap: () => _openDocument('privacy'),
//                           child: Text(
//                             'Политики конфиденциальности',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Text(' и ', style: TextStyle(fontSize: 14)),
//                         GestureDetector(
//                           onTap: () => _openDocument('offer'),
//                           child: Text(
//                             'Публичной оферты',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                         Text(' *',
//                             style: TextStyle(fontSize: 14, color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Сообщение об ошибке если не принято согласие
//                 if (_formSubmitted && !_acceptedTerms)
//                   Padding(
//                     padding: EdgeInsets.only(top: 8, left: 12),
//                     child: Text(
//                       '⚠️ Необходимо принять условия для продолжения',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 12,
//                       ),
//                     ),
//                   ),

//                 SizedBox(height: 24),

//                 // Кнопка регистрации
//                 Consumer<AuthProvider>(
//                   builder: (context, authProvider, child) {
//                     return Column(
//                       children: [
//                         SizedBox(
//                           width: double.infinity,
//                           height: 52,
//                           child: ElevatedButton(
//                             onPressed:
//                                 authProvider.isLoading ? null : _register,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue,
//                               foregroundColor: Colors.white,
//                               elevation: 2,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: authProvider.isLoading
//                                 ? Row(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       ),
//                                       SizedBox(width: 12),
//                                       Text('Регистрируем...'),
//                                     ],
//                                   )
//                                 : Text(
//                                     'Зарегистрироваться',
//                                     style: TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                           ),
//                         ),

//                         // Отображение ошибок
//                         if (authProvider.lastError != null) ...[
//                           SizedBox(height: 16),
//                           Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: Colors.red[50],
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(color: Colors.red[200]!),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(Icons.error_outline,
//                                     color: Colors.red, size: 20),
//                                 SizedBox(width: 8),
//                                 Expanded(
//                                   child: Text(
//                                     authProvider.lastError!,
//                                     style: TextStyle(
//                                       color: Colors.red[800],
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ],
//                     );
//                   },
//                 ),

//                 SizedBox(height: 24),

//                 // Ссылка на вход
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Уже есть аккаунт? ',
//                       style: TextStyle(
//                         color: Colors.grey[600],
//                         fontSize: 16,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => LoginScreen(),
//                           ),
//                         );
//                       },
//                       child: Text(
//                         'Войти',
//                         style: TextStyle(
//                           color: Colors.blue,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // ОБНОВЛЕННЫЙ метод регистрации для register_screen.dart
//   Future<void> _register() async {
//     setState(() {
//       _formSubmitted = true;
//     });

//     // Проверяем согласие с условиями
//     if (!_acceptedTerms) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Row(
//             children: [
//               Icon(Icons.warning, color: Colors.white),
//               SizedBox(width: 8),
//               Text('Необходимо принять условия использования'),
//             ],
//           ),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     authProvider.clearError();

//     // Получаем данные из полей
//     final firstName = _firstNameController.text.trim();
//     final lastName = _lastNameController.text.trim();
//     final phone = _phoneController.text.trim();
//     final email = _emailController.text.trim();

//     // Форматируем номер телефона
//     final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
//     final formattedPhone = '+$cleanPhone';

//     print('📝 Попытка регистрации:');
//     print('Имя: $firstName');
//     print('Фамилия: $lastName');
//     print('Телефон: $formattedPhone');
//     print('Email: $email');
//     print('Согласие принято: $_acceptedTerms');

//     // Пробуем зарегистрировать через API с передачей согласия
//     try {
//       final success = await authProvider.register(
//         formattedPhone,
//         firstName,
//         'password', // Пароль не используется в нашей системе
//         lastName: lastName.isNotEmpty ? lastName : null,
//         email: email.isNotEmpty ? email : null,
//         acceptedTerms: _acceptedTerms,
//       );

//       // Проверяем, что виджет все еще смонтирован
//       if (!mounted) return;

//       if (success) {
//         // Показываем сообщение об успехе
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.check_circle, color: Colors.white),
//                 SizedBox(width: 8),
//                 Text('Регистрация успешна! Отправляем SMS...'),
//               ],
//             ),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 2),
//           ),
//         );

//         // Небольшая задержка для отображения сообщения
//         await Future.delayed(Duration(seconds: 1));

//         // Проверяем mounted после задержки
//         if (!mounted) return;

//         // Отправляем SMS код на телефон
//         final smsSuccess = await authProvider.sendSMSCode(formattedPhone);

//         // Снова проверяем mounted
//         if (!mounted) return;

//         if (smsSuccess) {
//           // Добавляем задержку для веб-версии
//           if (kIsWeb) {
//             await Future.delayed(Duration(milliseconds: 300));
//           }

//           // Финальная проверка mounted перед навигацией
//           if (!mounted) return;

//           // Переходим на экран верификации SMS
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (context) => SMSVerificationScreen(
//                 phone: formattedPhone,
//                 rememberMe: true,
//               ),
//             ),
//           );
//         } else {
//           // Если SMS не отправилось, показываем ошибку
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Row(
//                   children: [
//                     Icon(Icons.error, color: Colors.white),
//                     SizedBox(width: 8),
//                     Text('Не удалось отправить SMS. Попробуйте войти.'),
//                   ],
//                 ),
//                 backgroundColor: Colors.red,
//                 duration: Duration(seconds: 3),
//               ),
//             );

//             // Задержка перед переходом
//             await Future.delayed(Duration(seconds: 2));

//             if (mounted) {
//               // Переходим на экран входа
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(
//                   builder: (context) => LoginScreen(),
//                 ),
//               );
//             }
//           }
//         }
//       } else {
//         // Регистрация не удалась
//         // Ошибка уже отображается через Consumer в UI
//         if (authProvider.lastError != null && mounted) {
//           print('❌ Ошибка регистрации: ${authProvider.lastError}');
//         }
//       }
//     } catch (e) {
//       print('❌ Исключение при регистрации: $e');

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Row(
//               children: [
//                 Icon(Icons.error, color: Colors.white),
//                 SizedBox(width: 8),
//                 Expanded(
//                   child: Text('Ошибка регистрации. Попробуйте позже.'),
//                 ),
//               ],
//             ),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   // НОВЫЙ метод для открытия документов
//   void _openDocument(String type) {
//     String url = '';
//     String title = '';

//     switch (type) {
//       case 'terms':
//         url = 'https://sevkorzina.ru//agreement.html';
//         title = 'Пользовательское соглашение';
//         break;
//       case 'privacy':
//         url = 'https://sevkorzina.ru//privacy.html';
//         title = 'Политика конфиденциальности';
//         break;
//       case 'offer':
//         url = 'https://sevkorzina.ru//offer.html';
//         title = 'Публичная оферта';
//         break;
//     }

//     // Открываем в браузере
//     launchUrl(
//       Uri.parse(url),
//       mode: LaunchMode.externalApplication,
//     );
//   }
// }

// ========================================
// 2. lib/screens/auth/register_screen.dart
// ========================================

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
  bool _acceptedTerms = false;
  bool _formSubmitted = false;

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
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.0),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Логотип и заголовок
                    Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 24),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ),

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
                        prefixIcon:
                            Icon(Icons.person_outline, color: Colors.blue),
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

                        final cleanPhone =
                            value.replaceAll(RegExp(r'[^\d]'), '');

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

                    // Чекбокс согласия с условиями
                    Container(
                      decoration: BoxDecoration(
                        color:
                            _acceptedTerms ? Colors.green[50] : Colors.grey[50],
                        border: Border.all(
                          color: _acceptedTerms
                              ? Colors.green
                              : (_formSubmitted && !_acceptedTerms
                                  ? Colors.red
                                  : Colors.grey[300]!),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CheckboxListTile(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
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
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
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
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(' *',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),

                    // Сообщение об ошибке если не принято согласие
                    if (_formSubmitted && !_acceptedTerms)
                      Padding(
                        padding: EdgeInsets.only(top: 8, left: 12),
                        child: Text(
                          '⚠️ Необходимо принять условия для продолжения',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
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
        ),
      ),
    );
  }

  // ОБНОВЛЕННЫЙ метод регистрации для register_screen.dart
  Future<void> _register() async {
    setState(() {
      _formSubmitted = true;
    });

    // Проверяем согласие с условиями
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Необходимо принять условия использования'),
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
    print('Согласие принято: $_acceptedTerms');

    // Пробуем зарегистрировать через API с передачей согласия
    try {
      final success = await authProvider.register(
        formattedPhone,
        firstName,
        'password', // Пароль не используется в нашей системе
        lastName: lastName.isNotEmpty ? lastName : null,
        email: email.isNotEmpty ? email : null,
        acceptedTerms: _acceptedTerms,
      );

      // Проверяем, что виджет все еще смонтирован
      if (!mounted) return;

      if (success) {
        // Показываем сообщение об успехе
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Регистрация успешна! Отправляем SMS...'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Небольшая задержка для отображения сообщения
        await Future.delayed(Duration(seconds: 1));

        // Проверяем mounted после задержки
        if (!mounted) return;

        // Отправляем SMS код на телефон
        final smsSuccess = await authProvider.sendSMSCode(formattedPhone);

        // Снова проверяем mounted
        if (!mounted) return;

        if (smsSuccess) {
          // Добавляем задержку для веб-версии
          if (kIsWeb) {
            await Future.delayed(Duration(milliseconds: 300));
          }

          // Финальная проверка mounted перед навигацией
          if (!mounted) return;

          // Переходим на экран верификации SMS
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SMSVerificationScreen(
                phone: formattedPhone,
                rememberMe: true,
              ),
            ),
          );
        } else {
          // Если SMS не отправилось, показываем ошибку
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Не удалось отправить SMS. Попробуйте войти.'),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );

            // Задержка перед переходом
            await Future.delayed(Duration(seconds: 2));

            if (mounted) {
              // Переходим на экран входа
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            }
          }
        }
      } else {
        // Регистрация не удалась
        // Ошибка уже отображается через Consumer в UI
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

  // НОВЫЙ метод для открытия документов
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

    // Открываем в браузере
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }
}
