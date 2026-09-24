import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../data/models/proverb.dart';
import '../../../shared/providers/app_providers.dart';

/// «Экспозиция»: the proverb of the day exhibited like a single object on a
/// wall — catalogue line, monumental text in the reading script, the other
/// script beneath (Nastaliq for Persian), and a quiet link to read more.
///
/// Proverbs have no page-checked record, so no seal is pressed here.
class HomeExhibit extends StatelessWidget {
  const HomeExhibit({
    super.key,
    required this.proverb,
    required this.categoryName,
    required this.date,
    required this.heroPersian,
    required this.lang,
    required this.onOpen,
  });

  final Proverb proverb;
  final String categoryName;
  final DateTime date;
  final bool heroPersian;
  final DisplayLanguage lang;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    String tr(String key) => AppTranslations.get(key, lang);
    final number = AppTranslations.formatDigits(
      proverb.id.replaceAll(RegExp(r'[^0-9]'), '').padLeft(3, '0'),
      lang,
    );
    final dateLabel = AppTranslations.formatDigits(
      '${date.day} ${AppTranslations.getMonthName(date.month, lang)} ${date.year}',
      lang,
    );
    final hasPersian = proverb.persianText.trim().isNotEmpty;
    final showPersianHero = heroPersian && hasPersian;
    final eyebrow = QalamTypography.eyebrow(color: colors.primary);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Monumental, but bounded: scale with the column and cap how far the
        // system text size may enlarge an already very large line.
        final heroSize = (constraints.maxWidth * 0.11).clamp(34.0, 60.0);
        final scaler = MediaQuery.textScalerOf(
          context,
        ).clamp(maxScaleFactor: 1.3);

        final hero = showPersianHero
            ? Text(
                proverb.persianText,
                textDirection: TextDirection.rtl,
                textScaler: scaler,
                style: QalamTypography.nastaliqVerse(
                  color: colors.onSurface,
                  fontSize: heroSize * 0.8,
                  height: 2.2,
                ),
              )
            : Text(
                proverb.tajikCyrillic,
                textDirection: TextDirection.ltr,
                textScaler: scaler,
                style: QalamTypography.heroProverb(
                  color: colors.onSurface,
                  fontSize: heroSize,
                  height: 1.12,
                ),
              );
        final secondary = showPersianHero
            ? Text(
                proverb.tajikCyrillic,
                textDirection: TextDirection.ltr,
                style: QalamTypography.heroProverb(
                  color: colors.onSurfaceVariant,
                  fontSize: 22,
                  height: 1.35,
                ),
              )
            : hasPersian
            ? Text(
                proverb.persianText,
                textDirection: TextDirection.rtl,
                style: QalamTypography.nastaliqVerse(
                  color: colors.onSurfaceVariant,
                  fontSize: 22,
                ),
              )
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${tr('home_daily_proverb').toUpperCase()} · $dateLabel',
              style: eyebrow,
            ),
            const SizedBox(height: 6),
            Text(
              '№ $number · ${categoryName.toUpperCase()}',
              style: QalamTypography.eyebrow(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            Semantics(header: true, child: hero),
            const SizedBox(height: 20),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Container(width: 32, height: 2, color: colors.primary),
            ),
            if (secondary != null) ...[const SizedBox(height: 16), secondary],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    tr(
                      proverb.type == ProverbType.traditional
                          ? 'badges_traditional'
                          : 'badges_modern',
                    ),
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onOpen,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tr('home_read'),
                        style: TextStyle(
                          fontFamily: QalamTypography.display,
                          fontFamilyFallback: QalamTypography.serifFallback,
                          fontStyle: FontStyle.italic,
                          fontSize: 18,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_back
                            : Icons.arrow_forward,
                        size: 18,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
