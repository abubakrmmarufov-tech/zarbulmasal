import 'package:flutter/material.dart';

import 'qalam_folio.dart';
import 'qalam_typography.dart';

/// A catalogue slip: serif title, one-line description and a chevron in a
/// hairline box (see [QalamSlip]).
///
/// [leading] is for icons that carry meaning (e.g. "continue"); decorative
/// icons stay out of lists.
class QalamIndexRow extends StatelessWidget {
  const QalamIndexRow({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.leadingWidget,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget? leadingWidget;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return QalamSlip(
      onTap: onTap,
      child: Row(
        children: [
          if (leadingWidget != null) ...[
            leadingWidget!,
            const SizedBox(width: 12),
          ] else if (leading != null) ...[
            Icon(leading, color: colors.primary, size: 22),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: QalamTypography.literaryTitle(
                    color: colors.onSurface,
                    fontSize: 19,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
