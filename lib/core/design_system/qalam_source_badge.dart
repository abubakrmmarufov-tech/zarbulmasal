import 'package:flutter/material.dart';
import 'qalam_colors.dart';
import 'qalam_typography.dart';
import 'qalam_spacing.dart';

/// Verification badge that displays editorial provenance status.
class QalamSourceBadge extends StatelessWidget {
  final bool isVerified;
  final String label;

  const QalamSourceBadge({
    super.key,
    required this.isVerified,
    this.label = 'Матн санҷида шудааст',
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? const Color(0xFF7CA98B) : QalamColors.forest;
    final bg = isDark
        ? QalamColors.forest.withValues(alpha: 0.20)
        : QalamColors.forest.withValues(alpha: 0.08);
    final border = isDark
        ? QalamColors.forest.withValues(alpha: 0.40)
        : QalamColors.forest.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border, width: 0.5),
        borderRadius: BorderRadius.circular(QalamSpacing.radiusXs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 13, color: fg),
          const SizedBox(width: 5),
          Text(
            label,
            style: QalamTypography.meta(
              color: fg,
              fontSize: 11,
            ).copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
