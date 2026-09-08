import 'package:flutter/material.dart';
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
          onPrimary: dark ? QalamColors.ink : QalamColors.paperHigh,
          secondary: dark ? const Color(0xFFACC7A9) : QalamColors.forest,
          surface: paper,
          onSurface: ink,
          onSurfaceVariant: muted,
          surfaceContainerHighest: dark
              ? QalamColors.inkCardHigh
              : QalamColors.paperLow,
          outline: rule,
          outlineVariant: rule,
          error: dark ? const Color(0xFFF3AA9D) : QalamColors.danger,
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(3),
    );
    return base.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: QalamPageTransitions(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
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
        displayLarge: QalamTypography.pageTitle(color: ink, fontSize: 56),
        displayMedium: QalamTypography.pageTitle(color: ink, fontSize: 48),
        displaySmall: QalamTypography.pageTitle(color: ink),
        headlineLarge: QalamTypography.sectionTitle(color: ink, fontSize: 32),
        headlineMedium: QalamTypography.sectionTitle(color: ink, fontSize: 28),
        headlineSmall: QalamTypography.sectionTitle(color: ink),
        titleLarge: QalamTypography.sectionTitle(color: ink, fontSize: 22),
        titleMedium: QalamTypography.label(color: ink, fontSize: 17),
        titleSmall: QalamTypography.label(color: ink, fontSize: 15),
        bodyLarge: QalamTypography.body(color: ink, fontSize: 18),
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
        titleTextStyle: QalamTypography.label(color: ink, fontSize: 15),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          minimumSize: const Size(48, 52),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          textStyle: QalamTypography.label(
            color: scheme.onPrimary,
            fontSize: 14,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: shape,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 52),
          shape: shape,
          side: BorderSide(color: ink),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(48, 48),
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
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink)),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      ),
      dividerTheme: DividerThemeData(color: rule, space: 1, thickness: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: rule,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        shape: shape,
        elevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: QalamTypography.body(color: paper, fontSize: 14),
        behavior: SnackBarBehavior.floating,
      ),
      cardTheme: CardThemeData(color: paper, elevation: 0, shape: shape),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: paper,
        shape: shape,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
