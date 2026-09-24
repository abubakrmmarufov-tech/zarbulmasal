import 'package:flutter/material.dart';

import 'qalam_colors.dart';
import 'qalam_spacing.dart';
import 'qalam_typography.dart';

/// A typographic stand-in for a portrait: the person's initial in Cyrillic
/// and, when the data has one, in Persian script — set like a seal
/// impression. Used whenever a portrait's rights are not cleared.
class QalamMonogramPlate extends StatelessWidget {
  const QalamMonogramPlate({
    super.key,
    required this.name,
    this.persianName,
    this.width = 64,
    this.height = 80,
  });

  final String name;
  final String? persianName;
  final double width;
  final double height;

  static String initialOf(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    return String.fromCharCode(trimmed.runes.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = dark ? QalamColors.vermilionNight : QalamColors.vermilion;
    final cyrillic = initialOf(name);
    final persian = initialOf(persianName);
    final base = height < width ? height : width;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: dark ? QalamColors.lapisRaised : QalamColors.paperRaised,
        border: Border.all(color: accent, width: 1),
        borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              cyrillic,
              textDirection: TextDirection.ltr,
              style: QalamTypography.monographTitle(
                color: accent,
                fontSize: base * 0.5,
                height: 1.0,
              ),
            ),
            if (persian.isNotEmpty)
              Text(
                persian,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontFamily: QalamTypography.persian,
                  color: accent,
                  fontSize: base * 0.24,
                  height: 1.3,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
