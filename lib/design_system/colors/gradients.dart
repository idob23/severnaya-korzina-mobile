import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  // Основной градиент приложения
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primaryDark,
      AppColors.primaryLight,
    ],
  );

  // Северное сияние
  static const LinearGradient aurora = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.aurora1,
      AppColors.aurora2,
      AppColors.aurora3,
    ],
  );

  // Градиент для кнопок
  static const LinearGradient button = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF1E40AF),
    ],
  );

  // Градиент успеха
  static const LinearGradient success = LinearGradient(
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );

  // Градиент для карточек
  static const LinearGradient card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.white,
      Color(0xFFF9FAFB),
    ],
  );
}
