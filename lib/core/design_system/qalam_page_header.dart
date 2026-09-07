import 'package:flutter/material.dart';
import 'design_system.dart';

/// A publication heading: small folio, large title, a single ink rule.
class QalamPageHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool showRule;
  final EdgeInsets padding;
  const QalamPageHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showRule = true,
    this.padding = const EdgeInsets.fromLTRB(24, 28, 24, 24),
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!,
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
            const SizedBox(height: 20),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: QalamTypography.pageTitle(color: colors.onSurface),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing!],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 14),
            Text(
              subtitle!,
              style: QalamTypography.bodySecondary(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (showRule) ...[const SizedBox(height: 28), const Divider()],
        ],
      ),
    );
  }
}
