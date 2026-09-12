import 'package:flutter/material.dart';
import 'qalam_typography.dart';
import 'qalam_spacing.dart';

/// Verification badge that displays "Матн санҷида шудааст ✓" only when
/// ALL required verification gates have passed for a literary work.
///
/// This badge must NEVER be shown based merely on finding text on multiple
/// websites. It requires:
/// - Primary source checked
/// - Title checked
/// - Authorship checked
/// - Page checked
/// - Text line-by-line checked
/// - Script checked
/// - Copyright checked
/// - Final status == approved
class QalamSourceBadge extends StatelessWidget {
  /// Whether the work has passed all verification gates.
  final bool isVerified;

  /// The label to display (defaults to Tajik verification text).
  final String label;

  const QalamSourceBadge({
    super.key,
    required this.isVerified,
    this.label = 'Матн санҷида шудааст',
  });

  @override
  Widget build(BuildContext context) {
    if (!isVerified) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: QalamSpacing.badgePadH,
        vertical: QalamSpacing.badgePadV,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outlineVariant, width: 0.5),
        borderRadius: BorderRadius.circular(QalamSpacing.badgeRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: colors.primary),
          const SizedBox(width: 6),
          Text(label, style: QalamTypography.meta(color: colors.primary)),
        ],
      ),
    );
  }
}
