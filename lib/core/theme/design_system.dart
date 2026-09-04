import 'package:flutter/material.dart';

class DesignSystem {
  DesignSystem._();

  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 16.0;
  static const double radiusL = 24.0;
  static const double radiusXl = 32.0;

  static List<BoxShadow> softShadow(bool isDark) {
    if (isDark) return [];
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];
  }

  static BoxDecoration atlasAccentDecoration(bool isDark) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: isDark
            ? [
                const Color(0xFFD4A843).withValues(alpha: 0.1),
                Colors.transparent,
              ]
            : [
                const Color(0xFFD97706).withValues(alpha: 0.08),
                Colors.transparent,
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }
}
