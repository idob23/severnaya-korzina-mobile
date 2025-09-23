// // lib/screens/auth/auth_choice_screen.dart - ИСПРАВЛЕННАЯ ВЕРСТКА
// import 'package:flutter/material.dart';
// import 'login_screen.dart';
// import 'register_screen.dart';
// import 'package:provider/provider.dart';
// import '../../providers/auth_provider.dart';
// import '../../services/api_service.dart';
// import '../maintenance_screen.dart';
// import '../home/home_screen.dart';

// class AuthChoiceScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 // Логотип и заголовок
//                 Icon(
//                   Icons.shopping_cart,
//                   size: 80,
//                   color: Colors.blue,
//                 ),

//                 SizedBox(height: 24),

//                 Text(
//                   'Северная корзина',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),

//                 SizedBox(height: 12),

//                 Text(
//                   'Коллективные закупки в Усть-Нере',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.grey[600],
//                   ),
//                 ),

//                 SizedBox(height: 32),

//                 // Информационные карточки
//                 Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.green[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: Colors.green,
//                         size: 24,
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: Text(
//                           'Экономьте до 50% на продуктах благодаря совместным закупкам',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[700],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 SizedBox(height: 40),

//                 // Кнопка "Войти"
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => LoginScreen()),
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                       elevation: 2,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       'Войти',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 16),

//                 // Кнопка "Зарегистрироваться"
//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: OutlinedButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => RegisterScreen()),
//                       );
//                     },
//                     style: OutlinedButton.styleFrom(
//                       foregroundColor: Colors.blue,
//                       side: BorderSide(color: Colors.blue, width: 2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       'Зарегистрироваться',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: 40),

//                 // Ссылка "Узнать больше о проекте"
//                 TextButton(
//                   onPressed: () {
//                     showDialog(
//                       context: context,
//                       builder: (context) => AlertDialog(
//                         title: Text('О проекте'),
//                         content: Text(
//                           'Северная корзина - платформа для организации коллективных закупок продуктов питания.\n\n'
//                           'Мы объединяем заказы жителей Усть-Неры, чтобы получить оптовые цены и сэкономить на доставке.',
//                         ),
//                         actions: [
//                           TextButton(
//                             onPressed: () => Navigator.pop(context),
//                             child: Text('Понятно'),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                   child: Text(
//                     'Узнать больше о проекте',
//                     style: TextStyle(color: Colors.grey[600], fontSize: 14),
//                   ),
//                 ),

//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/screens/auth/auth_choice_screen.dart - ШАГ 1: ГРАДИЕНТНЫЙ ФОН И АНИМАЦИЯ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Добавляем для HapticFeedback
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../maintenance_screen.dart';
import '../home/home_screen.dart';
// Добавляем импорты дизайн-системы
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';

class AuthChoiceScreen extends StatefulWidget {
  @override
  _AuthChoiceScreenState createState() => _AuthChoiceScreenState();
}

class _AuthChoiceScreenState extends State<AuthChoiceScreen>
    with SingleTickerProviderStateMixin {
  // Добавляем контроллер анимации
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Инициализируем анимацию
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    // Запускаем анимацию
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Добавляем градиентный фон
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryLight.withOpacity(0.8),
              AppColors.aurora3.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Логотип с анимацией масштаба
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: 600),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.aurora1.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.shopping_cart,
                              size: 60,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 24),

                    // Заголовок с белым цветом для контраста
                    Text(
                      'Северная корзина',
                      style: TextStyle(
                        fontSize: 28,
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

                    SizedBox(height: 12),

                    Text(
                      'Коллективные закупки в Усть-Нере',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),

                    SizedBox(height: 32),

                    // Информационная карточка с улучшенным дизайном
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.aurora2.withOpacity(0.2),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: AppGradients.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Экономьте до 50% на продуктах благодаря совместным закупкам',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    // Кнопка "Войти" с градиентом
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.button,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryLight.withOpacity(0.4),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => LoginScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                'Войти',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 14),

                    // Кнопка "Зарегистрироваться" с обводкой
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => RegisterScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: Text(
                                'Зарегистрироваться',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 24),

                    // Кнопка "Войти как гость"
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        // Просто переходим на главный экран без авторизации
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                        );
                      },
                      child: Text(
                        'Войти как гость',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
}
