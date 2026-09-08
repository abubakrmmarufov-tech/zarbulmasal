import 'package:flutter/material.dart';
import '../design_system/qalam_colors.dart';

/// Legacy color surface — updated to use Qalam tokens.
///
/// Existing code that imports `app_colors.dart` should continue to work.
/// New code should prefer importing `qalam_colors.dart` directly.
class AppColors {
  AppColors._();

  // ─── Light theme — Qalam light palette ───────────────────────────────
  static const Color primaryLight = QalamColors.burgundy;
  static const Color secondary = QalamColors.forest;
  static const Color accentGold = QalamColors.antiqueGold;
  static const Color surfaceLight = QalamColors.cream;
  static const Color backgroundLight = QalamColors.paper;
  static const Color cardLight = QalamColors.paperHigh;
  static const Color textPrimaryLight = QalamColors.ink;
  static const Color textSecondaryLight = QalamColors.inkSoft;
  static const Color dividerLight = QalamColors.hairline;
  static const Color error = QalamColors.danger;

  // ─── Dark theme — Qalam dark palette ────────────────────────────────
  static const Color primaryDarkMode = QalamColors.burgundySoft;
  static const Color secondaryDarkMode = QalamColors.forestSoft;
  static const Color tertiaryGoldDark = QalamColors.antiqueGoldSoft;
  static const Color surfaceDark = QalamColors.inkCard;
  static const Color backgroundDark = QalamColors.inkBg;
  static const Color cardDark = QalamColors.inkCardHigh;
  static const Color surfaceDarkMode = QalamColors.inkCard;
  static const Color textPrimaryDark = QalamColors.paperText;
  static const Color textSecondaryDark = QalamColors.paperTextSoft;
  static const Color dividerDark = QalamColors.hairlineDark;
  static const Color errorDark = QalamColors.burgundySoft;

  // ─── Tajik cultural palette — legacy alias, prefer QalamColors directly ──
  static const Color tajikFlagRed = QalamColors.burgundy;
  static const Color tajikFlagGreen = QalamColors.forest;
  static const Color tajikGold = QalamColors.antiqueGold;
  static const Color atlasGold = QalamColors.antiqueGoldSoft;

  // ─── Category colors ──────────────────────────────────────────────────
  // Now uses the calm Qalam palette.
  static const List<Color> categoryColors = <Color>[
    QalamColors.burgundy,
    QalamColors.forest,
    QalamColors.antiqueGold,
    QalamColors.burgundySoft,
    QalamColors.forestSoft,
    QalamColors.antiqueGoldDeep,
    QalamColors.burgundyDeep,
    QalamColors.forestSoft,
  ];

  /// Legacy index-based lookup — prefer [QalamColors.tokenForId].
  static Color getCategoryColor(int index) =>
      QalamColors.legacyCategoryColor(index);
}
