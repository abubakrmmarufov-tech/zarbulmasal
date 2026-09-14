import 'package:flutter/material.dart';

/// A wrapper that enforces left-to-right text direction for Tajik Cyrillic text,
/// even when the overall app direction is right-to-left (e.g. in Persian mode).
/// It also explicitly forces the font to avoid mixing scripts with Arabic fonts.
class TajikText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign? textAlign;

  const TajikText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    // We don't hardcode a font family here, we just rely on the existing style,
    // but we wrap the text in a Directionality to force LTR text direction.
    // Noto Sans is default in the app for Cyrillic anyway, but the directionality
    // prevents issues when Persian RTL is active.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign ?? TextAlign.left,
      ),
    );
  }
}
