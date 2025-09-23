import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // ===== ОТСТУПЫ =====
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // ===== PADDING для контейнеров =====
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Горизонтальные отступы
  static const EdgeInsets paddingHorizontalSM =
      EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD =
      EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL =
      EdgeInsets.symmetric(horizontal: xl);

  // Вертикальные отступы
  static const EdgeInsets paddingVerticalSM =
      EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD =
      EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG =
      EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL =
      EdgeInsets.symmetric(vertical: xl);

  // Стандартные отступы для экранов
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // ===== РАДИУСЫ =====
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusRound = 100.0;

  // BorderRadius
  static const BorderRadius borderRadiusXS =
      BorderRadius.all(Radius.circular(radiusXS));
  static const BorderRadius borderRadiusSM =
      BorderRadius.all(Radius.circular(radiusSM));
  static const BorderRadius borderRadiusMD =
      BorderRadius.all(Radius.circular(radiusMD));
  static const BorderRadius borderRadiusLG =
      BorderRadius.all(Radius.circular(radiusLG));
  static const BorderRadius borderRadiusXL =
      BorderRadius.all(Radius.circular(radiusXL));
  static const BorderRadius borderRadiusXXL =
      BorderRadius.all(Radius.circular(radiusXXL));
  static const BorderRadius borderRadiusRound =
      BorderRadius.all(Radius.circular(radiusRound));

  // Специальные радиусы
  static const BorderRadius borderRadiusTop =
      BorderRadius.vertical(top: Radius.circular(radiusXL));
  static const BorderRadius borderRadiusBottom =
      BorderRadius.vertical(bottom: Radius.circular(radiusXL));

  // ===== РАЗМЕРЫ ИКОНОК =====
  static const double iconSizeXS = 16.0;
  static const double iconSizeSM = 20.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 28.0;
  static const double iconSizeXL = 32.0;
  static const double iconSizeXXL = 40.0;

  // ===== ВЫСОТА ЭЛЕМЕНТОВ =====
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;

  static const double inputHeightSM = 40.0;
  static const double inputHeightMD = 48.0;
  static const double inputHeightLG = 56.0;

  static const double cardHeight = 120.0;
  static const double listItemHeight = 72.0;

  // ===== ШИРИНА =====
  static const double maxWidthPhone = 480.0;
  static const double maxWidthTablet = 768.0;
  static const double maxWidthDesktop = 1200.0;

  // ===== АНИМАЦИИ =====
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ===== ТЕНИ =====
  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> shadowXL = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  // Цветные тени
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: Color(0xFF3B82F6).withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> shadowSuccess = [
    BoxShadow(
      color: Color(0xFF10B981).withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static List<BoxShadow> shadowError = [
    BoxShadow(
      color: Color(0xFFEF4444).withOpacity(0.3),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];
}

// Методы-помощники для адаптивных отступов
extension ResponsiveSpacing on BuildContext {
  double get horizontalPadding {
    final width = MediaQuery.of(this).size.width;
    if (width < AppSpacing.maxWidthPhone) return AppSpacing.lg;
    if (width < AppSpacing.maxWidthTablet) return AppSpacing.xl;
    return AppSpacing.xxl;
  }

  EdgeInsets get screenPadding {
    return EdgeInsets.all(horizontalPadding);
  }
}
