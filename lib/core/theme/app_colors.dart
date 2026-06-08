import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light theme colors — Tajik cultural palette
  static const Color primaryLight = Color(0xFFB91C1C);    // deep red (Tajik flag)
  static const Color secondary = Color(0xFF166534);          // dark green (Tajik flag)
  static const Color accentGold = Color(0xFFD97706);        // warm gold (atlas/adras)
  static const Color surfaceLight = Color(0xFFFFF8F0);      // warm cream
  static const Color backgroundLight = Color(0xFFFAF5EE);   // soft beige
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1C1917);
  static const Color textSecondaryLight = Color(0xFF57534E);
  static const Color dividerLight = Color(0xFFE7E5E0);
  static const Color error = Color(0xFFDC2626);

  // Dark theme colors — warm deep tones
  static const Color primaryDarkMode = Color(0xFFF87171);    // soft red
  static const Color secondaryDarkMode = Color(0xFF86EFAC);   // soft green
  static const Color surfaceDark = Color(0xFF1C1008);        // warm dark — like a traditional Tajik home at night
  static const Color backgroundDark = Color(0xFF150D04);      // deeper warm black
  static const Color cardDark = Color(0xFF261A0C);           // warm dark card
  static const Color surfaceDarkMode = Color(0xFF2D1F0E);    // elevated dark surface
  static const Color textPrimaryDark = Color(0xFFF5EFE0);   // warm cream text
  static const Color textSecondaryDark = Color(0xFFB8A882);  // warm muted text
  static const Color dividerDark = Color(0xFF4A3820);
  static const Color errorDark = Color(0xFFF87171);
  static const Color tertiaryGoldDark = Color(0xFFD4A843);    // warm gold for dark mode tertiary

  // Tajik cultural category colors
  static const Color categoryRed = Color(0xFFB91C1C);
  static const Color categoryGreen = Color(0xFF166534);
  static const Color categoryGold = Color(0xFFD97706);
  static const Color categoryTerracotta = Color(0xFFC2410C);
  static const Color categoryBurgundy = Color(0xFF7C2D12);
  static const Color categoryOlive = Color(0xFF4D7C0F);
  static const Color categoryTeal = Color(0xFF0F766E);
  static const Color categoryBrown = Color(0xFF92400E);

  static const List<Color> categoryColors = [
    categoryRed,
    categoryGreen,
    categoryGold,
    categoryTerracotta,
    Color(0xFFBE185D),       // plum
    categoryOlive,
    Color(0xFF1D4ED8),       // royal blue
    categoryTeal,
    categoryBrown,
    Color(0xFF6D28D9),       // violet
    Color(0xFF047857),       // emerald
    Color(0xFF9333EA),       // purple
    Color(0xFF0284C7),       // sky blue
    Color(0xFFCA8A04),       // amber
    Color(0xFF7C3AED),       // indigo
    Color(0xFF059669),       // jade
    Color(0xFFDC2626),       // bright red
    Color(0xFF0891B2),       // cyan
    Color(0xFF65A30D),       // lime
    Color(0xFF0D9488),       // teal dark
  ];

  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }
}
