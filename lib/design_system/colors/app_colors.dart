import 'package:flutter/material.dart';

class AppColors {
  // Запретить создание экземпляров
  AppColors._();

  // ===== ОСНОВНЫЕ ЦВЕТА =====
  static const Color primaryDark =
      Color(0xFF0A2540); // Темно-синий (ночное небо)
  static const Color primaryLight = Color(0xFF3B82F6); // Светло-синий
  static const Color secondary = Color(0xFF10B981); // Зеленый (успех/корзина)

  // ===== СЕВЕРНАЯ ПАЛИТРА =====
  static const Color aurora1 = Color(0xFF00D9FF); // Голубое сияние
  static const Color aurora2 = Color(0xFF00FF88); // Зеленое сияние
  static const Color aurora3 = Color(0xFF7B61FF); // Фиолетовое сияние
  static const Color ice = Color(0xFFE6F4FF); // Ледяной
  static const Color snow = Color(0xFFFAFBFC); // Снежный белый
  static const Color frost = Color(0xFFB4D4F1); // Морозный

  // ===== ФУНКЦИОНАЛЬНЫЕ ЦВЕТА =====
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ===== НЕЙТРАЛЬНЫЕ =====
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Colors.white;

  // ===== ТЕНИ =====
  static Color shadowLight = Colors.black.withOpacity(0.05);
  static Color shadowMedium = Colors.black.withOpacity(0.08);
  static Color shadowDark = Colors.black.withOpacity(0.12);
}
