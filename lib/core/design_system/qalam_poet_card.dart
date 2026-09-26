import 'package:flutter/material.dart';
import 'qalam_typography.dart';
import 'qalam_spacing.dart';
import 'qalam_controls.dart';
import 'qalam_portrait.dart';
import '../../features/literature/domain/portrait_record.dart';

/// A list item for displaying a poet in the Шоирон (Poets) list.
///
/// Shows the poet's name, dates, literary period, and an optional
/// indicator for copyright-protected vs public-domain status.
class QalamPoetCard extends StatelessWidget {
  final String name;

  /// Cyrillic and Persian-script names for the monogram plate.
  final String? monogramName;
  final String? persianName;
  final String dates;
  final String period;
  final bool isPublicDomain;
  final String? exactDates;
  final String? poemCountBadge;
  final VoidCallback? onTap;
  final PortraitRecord? portrait;
  final String? portraitUnavailableLabel;
  final String? portraitCitationLabel;

  /// Verified birthplace shown under the dates, omitted entirely when unknown.
  final String? place;

  const QalamPoetCard({
    super.key,
    required this.name,
    this.monogramName,
    this.persianName,
    required this.dates,
    required this.period,
    this.isPublicDomain = false,
    this.exactDates,
    this.poemCountBadge,
    this.onTap,
    this.portrait,
    this.portraitUnavailableLabel,
    this.portraitCitationLabel,
    this.place,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayDates = (exactDates != null && exactDates!.isNotEmpty)
        ? exactDates!
        : dates;

    // A boxed catalogue slip, like every list item in the app.
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        QalamSpacing.pageH,
        0,
        QalamSpacing.pageH,
        8,
      ),
      child: Material(
        color: isDark ? colors.surfaceContainer : colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QalamPortrait(
                  portrait: portrait,
                  label: name,
                  monogramName: monogramName,
                  persianName: persianName,
                  unavailableLabel: portraitUnavailableLabel,
                  citationLabel: portraitCitationLabel,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: QalamTypography.literaryTitle(
                          color: colors.onSurface,
                          fontSize: 17,
                        ),
                      ),
                      // No dates line when none are checked yet.
                      if (displayDates.isNotEmpty) ...[
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
                      ],
                      if (place != null && place!.trim().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        // The birthplace sits on its own line and wraps in full,
                        // so a long birthplace (e.g. Rudaki, Khusrav) stays
                        // readable on narrow phones instead of being clipped.
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.place_outlined,
                              size: 13,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                place!,
                                style: QalamTypography.bodySecondary(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (period.trim().isNotEmpty)
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
                const SizedBox(width: 8),
                const QalamChevron(size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
