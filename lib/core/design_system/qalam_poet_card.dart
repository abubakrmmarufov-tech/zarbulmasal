import 'package:flutter/material.dart';
import 'qalam_colors.dart';
import 'qalam_typography.dart';
import 'qalam_spacing.dart';

/// A list item for displaying a poet in the Шоирон (Poets) list.
///
/// Shows the poet's name, dates, literary period, and an optional
/// indicator for copyright-protected vs public-domain status.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayDates = (exactDates != null && exactDates!.isNotEmpty)
        ? exactDates!
        : dates;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: QalamSpacing.pageH,
            vertical: 18,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: QalamTypography.literaryTitle(
                        color: colors.onSurface,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            displayDates,
                            style: QalamTypography.meta(
                              color: colors.primary,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                QalamSpacing.radiusXs,
                              ),
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
              const SizedBox(width: 14),
              if (isPublicDomain)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? QalamColors.forest.withValues(alpha: 0.2)
                        : QalamColors.forest.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.public,
                    size: 15,
                    color: QalamColors.forest,
                  ),
                ),
              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
