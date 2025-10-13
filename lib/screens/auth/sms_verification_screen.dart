// lib/screens/auth/sms_verification_screen.dart - УЛУЧШЕННАЯ ВЕРСИЯ С СЕВЕРНОЙ ТЕМОЙ
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Добавляем импорты дизайн-системы
import '../../design_system/colors/app_colors.dart';
import '../../design_system/colors/gradients.dart';
import 'package:sms_autofill/sms_autofill.dart';

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

class _SMSVerificationScreenState extends State<SMSVerificationScreen>
    with TickerProviderStateMixin, CodeAutoFill {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  Timer? _timer;
  int _resendCountdown = 60;
  bool _canResend = false;
  String _enteredCode = '';

  // Добавляем анимации
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late List<AnimationController> _codeAnimationControllers;

  @override
  void initState() {
    super.initState();
    _startResendTimer();

    // Инициализация анимаций
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

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    // Анимации для полей кода
    _codeAnimationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _animationController.forward();

    // Автофокус на первое поле
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes[0].requestFocus();
    });
    _initSMSListener();
  }

  Future<void> _initSMSListener() async {
    try {
      final signature = await SmsAutoFill().getAppSignature;
      print('📱 App Signature: $signature');
      await SmsAutoFill().listenForCode();
    } catch (e) {
      print('❌ Ошибка SMS: $e');
    }
  }

  @override
  void codeUpdated() {
    if (code != null && code!.length >= 4) {
      final smsCode = code!.substring(0, 4);
      for (int i = 0; i < 4; i++) {
        _controllers[i].text = smsCode[i];
        _codeAnimationControllers[i].forward();
      }
      _updateEnteredCode();
      _focusNodes[3].unfocus();
      Future.delayed(Duration(milliseconds: 500), _verifyCode);
    }
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
      // Градиентный фон
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primaryLight,
              AppColors.aurora1,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar фиксированный
              Container(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                    ),
                    Expanded(
                      child: Text(
                        'Подтверждение',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Балансировка
                  ],
                ),
              ),

              // Scrollable контент
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Column(
                        children: [
                          SizedBox(height: 40),

                          // Анимированная иконка
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.aurora1.withOpacity(0.3),
                                      AppColors.aurora2.withOpacity(0.1),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.aurora1.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.sms_outlined,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 32),

                          // Заголовок
                          Text(
                            'Введите код из SMS',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 16),

                          // Описание
                          Column(
                            children: [
                              Text(
                                'Код отправлен на номер',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                widget.phone,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 40),

                          // Поля ввода кода - исправленные стили
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(4, (index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                width: 65,
                                height: 65,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _controllers[index].text.isNotEmpty
                                        ? AppColors.success
                                        : AppColors.border,
                                    width: _controllers[index].text.isNotEmpty
                                        ? 2
                                        : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _controllers[index].text.isNotEmpty
                                          ? AppColors.success.withOpacity(0.3)
                                          : Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLength: 1,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        _codeAnimationControllers[index]
                                            .forward();
                                        if (index < 3) {
                                          _focusNodes[index + 1].requestFocus();
                                        } else {
                                          _focusNodes[index].unfocus();
                                        }
                                      } else {
                                        _codeAnimationControllers[index]
                                            .reverse();
                                        if (index > 0) {
                                          _focusNodes[index - 1].requestFocus();
                                        }
                                      }

                                      _updateEnteredCode();

                                      if (_enteredCode.length == 4) {
                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          _verifyCode();
                                        });
                                      }
                                    },
                                    onTap: () {
                                      _controllers[index].clear();
                                      _updateEnteredCode();
                                    },
                                  ),
                                ),
                              );
                            }),
                          ),

                          SizedBox(height: 32),

                          // Кнопка подтверждения
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: _enteredCode.length == 4
                                  ? AppGradients.aurora
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey.withOpacity(0.5),
                                        Colors.grey.withOpacity(0.3),
                                      ],
                                    ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: _enteredCode.length == 4
                                  ? [
                                      BoxShadow(
                                        color:
                                            AppColors.aurora1.withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: Offset(0, 10),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: ElevatedButton(
                              onPressed: (_enteredCode.length == 4 &&
                                      !authProvider.isLoading)
                                  ? _verifyCode
                                  : null,
                              child: Text(
                                authProvider.isLoading
                                    ? 'Проверяем код...'
                                    : 'Подтвердить',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _enteredCode.length == 4
                                      ? Colors.white
                                      : Colors.grey[600],
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                            ),
                          ),

                          // Отображение ошибок - оставляем как есть
                          if (authProvider.lastError != null) ...[
                            SizedBox(height: 16),
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.error.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: AppColors.error, size: 20),
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

                          SizedBox(height: 32),

                          // Ссылка для изменения номера
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Изменить номер телефона',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Таймер и кнопка повторной отправки
                          _resendCountdown > 0
                              ? Text(
                                  'Повторная отправка через $_resendCountdown сек',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 14,
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: _canResend ? _resendSMS : null,
                                  icon:
                                      Icon(Icons.refresh, color: Colors.white),
                                  label: Text(
                                    'Отправить код повторно',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    backgroundColor:
                                        Colors.white.withOpacity(0.1),
                                  ),
                                ),

                          SizedBox(height: 20), // Отступ внизу
                        ],
                      );
                    },
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

  // ВСЕ МЕТОДЫ ОСТАЮТСЯ БЕЗ ИЗМЕНЕНИЙ
  Future<void> _verifyCode() async {
    if (_enteredCode.length != 4) {
      _showErrorSnackBar('Введите 4-значный код');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    try {
      final success = await authProvider.verifySMSAndLogin(
        widget.phone,
        _enteredCode,
        rememberMe: widget.rememberMe,
      );

      if (!mounted) return;

      if (success) {
        HapticFeedback.heavyImpact();
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

        if (kIsWeb) {
          await Future.delayed(Duration(milliseconds: 500));
        }

        if (!mounted) return;

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
      for (var controller in _controllers) {
        controller.clear();
      }
      _updateEnteredCode();

      _focusNodes[0].requestFocus();

      _startResendTimer();

      _showSuccessSnackBar('SMS код отправлен повторно');
    }
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
    SmsAutoFill().unregisterListener();
    _animationController.dispose();
    for (var controller in _codeAnimationControllers) {
      controller.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
