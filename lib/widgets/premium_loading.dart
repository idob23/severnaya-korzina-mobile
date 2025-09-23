// Создайте новый файл: lib/widgets/premium_loading.dart

import 'package:flutter/material.dart';
import '../design_system/colors/app_colors.dart';
import '../design_system/colors/gradients.dart';

/// Премиум индикатор загрузки с градиентом
class PremiumLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;

  const PremiumLoadingIndicator({
    Key? key,
    this.message,
    this.size = 50,
  }) : super(key: key);

  @override
  _PremiumLoadingIndicatorState createState() =>
      _PremiumLoadingIndicatorState();
}

class _PremiumLoadingIndicatorState extends State<PremiumLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Анимация вращения
    _rotationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Анимация пульсации
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_rotationController, _pulseAnimation]),
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        AppColors.aurora1.withOpacity(0.8),
                        AppColors.aurora2.withOpacity(0.6),
                        AppColors.aurora3.withOpacity(0.8),
                        AppColors.primaryLight,
                        AppColors.aurora1.withOpacity(0.8),
                      ],
                      transform:
                          GradientRotation(_rotationController.value * 6.28),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.aurora1.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: AppColors.aurora2.withOpacity(0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryLight.withOpacity(0.3),
                                AppColors.aurora3.withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (widget.message != null) ...[
            SizedBox(height: 20),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              child: Text(widget.message!),
            ),
          ],
        ],
      ),
    );
  }
}

/// Использование в других экранах:
/// 
/// Замените:
/// CircularProgressIndicator()
/// 
/// На:
/// PremiumLoadingIndicator(
///   message: 'Загружаем заказы...',
/// )
/// 
/// Или без сообщения:
/// PremiumLoadingIndicator()
/// 
/// С кастомным размером:
/// PremiumLoadingIndicator(
///   size: 30,
/// )