import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import '../design_system/design_system.dart';

class AppTheme {
  AppTheme._();
  static ThemeData get lightTheme => _build(false);
  static ThemeData get darkTheme => _build(true);

  static ThemeData _build(bool dark) {
    final ink = dark ? QalamColors.paperText : QalamColors.ink;
    final muted = dark ? QalamColors.paperTextSoft : QalamColors.inkSoft;
    final paper = dark ? QalamColors.inkBg : QalamColors.paper;
    final rule = dark ? QalamColors.hairlineDark : QalamColors.hairline;
    final accent = dark ? QalamColors.antiqueGoldSoft : QalamColors.burgundy;
    final base = ThemeData(
      brightness: dark ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      fontFamily: QalamTypography.sans,
      fontFamilyFallback: QalamTypography.fallback,
    );
    final scheme =
        ColorScheme.fromSeed(
          seedColor: QalamColors.burgundy,
          brightness: base.brightness,
        ).copyWith(
          primary: accent,
          onPrimary: dark ? QalamColors.inkWell : QalamColors.paperHigh,
          secondary: dark ? const Color(0xFF7CA98B) : QalamColors.forest,
          surface: paper,
          onSurface: ink,
          onSurfaceVariant: muted,
          surfaceContainerLowest: dark
              ? QalamColors.inkWell
              : QalamColors.paperHigh,
          surfaceContainerLow: dark
              ? const Color(0xFF161C18)
              : QalamColors.paperWarm,
          surfaceContainer: dark ? QalamColors.inkCard : QalamColors.cream,
          surfaceContainerHigh: dark
              ? const Color(0xFF222B24)
              : QalamColors.paperLow,
          surfaceContainerHighest: dark
              ? QalamColors.inkCardHigh
              : const Color(0xFFE5DFC9),
          outline: rule,
          outlineVariant: rule,
          error: dark ? const Color(0xFFF3AA9D) : QalamColors.danger,
        );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(QalamSpacing.radiusMd),
      side: BorderSide(color: rule, width: 0.5),
    );

    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: QalamPageTransitions(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: QalamPageTransitions(),
          TargetPlatform.windows: QalamPageTransitions(),
          TargetPlatform.linux: QalamPageTransitions(),
        },
      ),
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      dividerColor: rule,
      splashFactory: InkRipple.splashFactory,
      textTheme: base.textTheme.copyWith(
        displayLarge: QalamTypography.pageTitle(color: ink, fontSize: 40),
        displayMedium: QalamTypography.pageTitle(color: ink, fontSize: 36),
        displaySmall: QalamTypography.pageTitle(color: ink),
        headlineLarge: QalamTypography.sectionTitle(color: ink, fontSize: 28),
        headlineMedium: QalamTypography.sectionTitle(color: ink, fontSize: 24),
        headlineSmall: QalamTypography.sectionTitle(color: ink),
        titleLarge: QalamTypography.sectionTitle(color: ink, fontSize: 20),
        titleMedium: QalamTypography.label(color: ink, fontSize: 16),
        titleSmall: QalamTypography.label(color: ink, fontSize: 14),
        bodyLarge: QalamTypography.body(color: ink, fontSize: 16),
        bodyMedium: QalamTypography.body(color: ink),
        bodySmall: QalamTypography.bodySecondary(color: muted),
        labelLarge: QalamTypography.label(color: ink, fontSize: 14),
        labelMedium: QalamTypography.label(color: ink),
        labelSmall: QalamTypography.meta(color: muted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: QalamTypography.sectionTitle(color: ink, fontSize: 17),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(48, 48),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: QalamTypography.label(
            color: scheme.onPrimary,
            fontSize: 14,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 48),
          shape: shape,
          side: BorderSide(color: rule),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(48, 44),
          shape: shape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        hintStyle: QalamTypography.body(color: muted),
        border: UnderlineInputBorder(borderSide: BorderSide(color: rule)),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: rule),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? QalamColors.inkCard : QalamColors.paperHigh,
        selectedColor: dark
            ? QalamColors.antiqueGoldDeep
            : QalamColors.paperLow,
        disabledColor: dark ? QalamColors.inkWell : QalamColors.paperLow,
        labelStyle: QalamTypography.meta(color: ink),
        secondaryLabelStyle: QalamTypography.meta(color: accent),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
          side: BorderSide(color: rule, width: 0.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: rule, space: 1, thickness: 0.5),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: rule,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        shape: cardShape,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: QalamTypography.body(
          color: dark ? QalamColors.inkBg : QalamColors.paperHigh,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
        ),
      ),
      cardTheme: CardThemeData(
        color: dark ? QalamColors.inkCard : QalamColors.paperHigh,
        elevation: 0,
        shape: cardShape,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: paper,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(QalamSpacing.radiusLg),
          ),
        ),
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
