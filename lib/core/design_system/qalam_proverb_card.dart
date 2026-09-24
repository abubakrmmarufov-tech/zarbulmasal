import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system.dart';
import '../l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';

/// An editorial reading-list entry, separated by hairlines rather than nested cards.
class QalamProverbCard extends ConsumerWidget {
  final Proverb proverb;
  final VoidCallback? onTap;

  const QalamProverbCard({super.key, required this.proverb, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final persian = lang == DisplayLanguage.persian;
    final categories = ref.watch(categoriesProvider);
    final matches = categories.where((c) => c.id == proverb.categoryId);
    final category = matches.isEmpty
        ? ''
        : QalamCategoryTile.nameFor(matches.first, lang);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QalamSpacing.pageH),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.isEmpty
                            ? AppTranslations.get('badges_level', lang, [
                                AppTranslations.formatDigits(
                                  '${proverb.level}',
                                  lang,
                                ),
                              ])
                            : '$category  ·  ${AppTranslations.get('badges_level', lang, [AppTranslations.formatDigits('${proverb.level}', lang)])}',
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    QalamBookmark(proverbId: proverb.id),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  persian ? proverb.persianText : proverb.tajikCyrillic,
                  textDirection: persian
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: QalamTypography.heroProverb(
                    color: colors.onSurface,
                    fontSize: 20,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  persian ? proverb.tajikCyrillic : proverb.persianText,
                  textDirection: persian
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
