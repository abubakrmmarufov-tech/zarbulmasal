import 'package:flutter/material.dart';

/// Locally bundled, script-complete type families for Zarbulmasal («Муҳр»).
///
/// Roles: a high-contrast display serif for exhibits and titles, a calm
/// reading serif for verse, a precise grotesque for the interface, Naskh for
/// Persian reading, Vazirmatn for Persian interface text, and Nastaliq for
/// exhibited Persian verse. Every family passed the Tajik/Persian glyph proof
/// (`tool/design/font_proof_test.dart`). Persian-script text in a Cyrillic
/// family falls back to the Persian faces, never to a missing glyph.
class QalamTypography {
  QalamTypography._();

  /// Display serif (exhibits, titles).
  static const display = 'EBGaramond';

  /// Reading serif (verse and long reading).
  static const serif = 'PTSerif';

  /// Interface grotesque.
  static const sans = 'GolosText';

  /// Persian reading (Naskh).
  static const persian = 'NotoNaskhArabic';

  /// Persian interface sans.
  static const persianUi = 'Vazirmatn';

  /// Exhibited Persian verse. Urdu-tuned; pending review by a Persian reader.
  static const nastaliq = 'NotoNastaliqUrdu';

  static const fallback = [persianUi, persian, 'NotoSans'];
  static const serifFallback = [persian, 'NotoSerif', sans];

  /// Exhibited Persian verse (Nastaliq needs generous line height).
  static TextStyle nastaliqVerse({
    required Color color,
    double fontSize = 28,
    double height = 2.1,
  }) => TextStyle(
    fontFamily: nastaliq,
    fontFamilyFallback: const [persian],
    color: color,
    fontSize: fontSize,
    height: height,
  );

  /// Hero Proverb: commanding, elegant serif representation for daily & spotlight folios.
  static TextStyle heroProverb({
    required Color color,
    double fontSize = 25,
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.48,
  }) => TextStyle(
    fontFamily: display,
    fontFamilyFallback: serifFallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: -0.4,
  );

  /// Monograph Title: Author names and major literary figures.
  static TextStyle monographTitle({
    required Color color,
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w600,
    double height = 1.25,
  }) => TextStyle(
    fontFamily: display,
    fontFamilyFallback: serifFallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: -0.6,
  );

  /// Literary Title: Ghazal titles, poem headings, book titles.
  static TextStyle literaryTitle({
    required Color color,
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w600,
    double height = 1.35,
  }) => TextStyle(
    fontFamily: display,
    fontFamilyFallback: serifFallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: -0.3,
  );

  /// Verse Body: Flagship poem reading text lines with optimal leading.
  static TextStyle verseText({
    required Color color,
    double fontSize = 19,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.85,
  }) => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: -0.1,
  );

  /// Hemistich: Half-verse lines in parallel or paired verse view.
  static TextStyle hemistich({
    required Color color,
    double fontSize = 17,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.75,
  }) => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: serifFallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
  );

  /// Page Title: Primary screen header.
  static TextStyle pageTitle({
    required Color color,
    double fontSize = 30,
    FontWeight fontWeight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: 1.25,
    letterSpacing: -0.9,
  );

  /// Section Title: Section groupings, cards, and modal dialogs.
  static TextStyle sectionTitle({
    required Color color,
    double fontSize = 21,
    FontWeight fontWeight = FontWeight.w600,
    double height = 1.30,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: -0.5,
  );

  /// Body: Main explanatory content, biographies, historical descriptions.
  static TextStyle body({
    required Color color,
    double fontSize = 16,
    double height = 1.65,
    FontWeight fontWeight = FontWeight.normal,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    height: height,
    fontWeight: fontWeight,
  );

  /// Secondary Body: Captions, subtitles, secondary information.
  static TextStyle bodySecondary({
    required Color color,
    double fontSize = 14,
    double height = 1.60,
    FontWeight fontWeight = FontWeight.normal,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    height: height,
    fontWeight: fontWeight,
  );

  /// Label: Button text, form labels, emphasized short text.
  static TextStyle label({
    required Color color,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    double height = 1.35,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    height: height,
    fontWeight: fontWeight,
  );

  /// Eyebrow: Section numbers and uppercase category folios.
  static TextStyle eyebrow({
    required Color color,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w700,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    letterSpacing: 1.2,
    height: 1.2,
  );

  /// Nav Label: Bottom navigation bar labels.
  static TextStyle navLabel({
    required Color color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: 1.2,
  );

  /// Meta: Dates, counts, page citations, small badges.
  static TextStyle meta({
    required Color color,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.35,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
  );
}
