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
  final String? exactDates;
  final String? poemCountBadge;
  final VoidCallback? onTap;

  const QalamPoetCard({
    super.key,
    required this.name,
    required this.dates,
    required this.period,
    this.isPublicDomain = false,
    this.exactDates,
    this.poemCountBadge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final displayDates = (exactDates != null && exactDates!.isNotEmpty)
        ? exactDates!
        : dates;

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
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          displayDates,
                          style: QalamTypography.meta(color: colors.primary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          period,
                          style: QalamTypography.bodySecondary(
                            color: colors.onSurfaceVariant,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (poemCountBadge != null &&
                          poemCountBadge!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.25),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            poemCountBadge!,
                            style: QalamTypography.meta(
                              color: colors.primary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ],
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
