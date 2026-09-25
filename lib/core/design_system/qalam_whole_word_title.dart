import 'package:flutter/material.dart';

/// A large title that never breaks inside a word.
///
/// Titles wrap between words; when a single word is wider than the line
/// (a long name such as «Абӯабдуллоҳи» beside a portrait), the whole title
/// is set smaller until that word fits, down to [minScale] of [style]'s
/// size. Below that the word may still break rather than overflow.
///
/// It measures its width with a [LayoutBuilder], so it cannot sit inside
/// [IntrinsicHeight] or [IntrinsicWidth]; use it for page titles.
class QalamWholeWordTitle extends StatelessWidget {
  const QalamWholeWordTitle(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
    this.textDirection,
    this.minScale = 0.6,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final double minScale;

  @override
  Widget build(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final direction = textDirection ?? Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final fitted = style.copyWith(
          fontSize: fittedFontSize(
            text,
            style,
            constraints.maxWidth,
            scaler,
            direction,
            minScale,
          ),
        );
        return Text(
          text,
          style: fitted,
          textAlign: textAlign,
          textDirection: textDirection,
        );
      },
    );
  }

  /// The largest size, at most [style]'s, at which every word of [text]
  /// fits in [maxWidth].
  static double fittedFontSize(
    String text,
    TextStyle style,
    double maxWidth,
    TextScaler scaler,
    TextDirection direction,
    double minScale,
  ) {
    final base = style.fontSize ?? 14;
    if (!maxWidth.isFinite) return base;
    var widest = 0.0;
    for (final word in text.split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: word, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    if (widest <= maxWidth) return base;
    return (base * maxWidth / widest).clamp(base * minScale, base);
  }
}
