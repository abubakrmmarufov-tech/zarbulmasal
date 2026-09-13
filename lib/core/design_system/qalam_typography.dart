import 'package:flutter/material.dart';

/// Locally bundled, script-complete type families. No network font requests.
class QalamTypography {
  QalamTypography._();
  static const serif = 'NotoSerif';
  static const sans = 'NotoSans';
  static const persian = 'NotoNaskhArabic';
  static const fallback = [persian, sans];

  static TextStyle heroProverb({
    required Color color,
    double fontSize = 28, // Reduced from 32 for better mobile fit
    FontWeight fontWeight = FontWeight.w500,
    double height = 1.45,
  }) => TextStyle(
    fontFamily: serif,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: height,
    letterSpacing: -0.65,
  );

  static TextStyle sectionTitle({
    required Color color,
    double fontSize = 22, // Reduced from 24
    FontWeight fontWeight = FontWeight.w600,
  }) => TextStyle(
    fontFamily: sans,
    fontFamilyFallback: fallback,
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
    height: 1.3, // Increased from 1.2 to prevent clipping of descenders
    letterSpacing: -0.7,
  );

  static TextStyle pageTitle({
    required Color color,
    double fontSize = 32,
  }) => // Reduced from 40
  sectionTitle(
    color: color,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
  ).copyWith(letterSpacing: -1.2, height: 1.3); // Increased height from 1.08

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

  static TextStyle bodySecondary({
    required Color color,
    double fontSize = 14,
    double height = 1.6,
    FontWeight fontWeight = FontWeight.normal,
  }) => body(
    color: color,
    fontSize: fontSize,
    height: height,
    fontWeight: fontWeight,
  );

  static TextStyle label({
    required Color color,
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
  }) => body(
    color: color,
    fontSize: fontSize,
    height: 1.35,
    fontWeight: fontWeight,
  );

  static TextStyle eyebrow({
    required Color color,
    double fontSize = 12,
  }) => // Increased from 11
      label(color: color, fontSize: fontSize).copyWith(letterSpacing: 0.7);
  static TextStyle navLabel({
    required Color color,
    double fontSize = 12,
  }) => // Increased from 10
      label(color: color, fontSize: fontSize, fontWeight: FontWeight.w500);
  static TextStyle meta({required Color color, double fontSize = 12}) =>
      label(color: color, fontSize: fontSize, fontWeight: FontWeight.w400);
}
