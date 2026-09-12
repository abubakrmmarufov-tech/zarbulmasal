import 'package:flutter/material.dart';
import 'qalam_typography.dart';
import 'qalam_spacing.dart';

/// A list item for displaying a poet in the Шоирон (Poets) list.
///
/// Shows the poet's name, dates, literary period, and an optional
/// icon indicator for copyright-protected vs public-domain status.
class QalamPoetCard extends StatelessWidget {
  final String name;
  final String dates;
  final String period;
  final bool isPublicDomain;
  final VoidCallback? onTap;

  const QalamPoetCard({
    super.key,
    required this.name,
    required this.dates,
    required this.period,
    this.isPublicDomain = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: QalamSpacing.pageH,
          vertical: QalamSpacing.cardGap,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dates,
                    style: QalamTypography.meta(color: colors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    period,
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (isPublicDomain)
              Icon(Icons.public, size: 16, color: colors.onSurfaceVariant),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 20, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
