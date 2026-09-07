import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system.dart';
import '../l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';

/// A reading-list entry, separated by rules rather than nested surfaces.
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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outline)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$category  /  ${AppTranslations.get('badges_level', lang, [proverb.level])}',
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    QalamBookmark(proverbId: proverb.id),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  persian ? proverb.persianText : proverb.tajikCyrillic,
                  textDirection: persian
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: QalamTypography.heroProverb(
                    color: colors.onSurface,
                    fontSize: 23,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  persian ? proverb.tajikCyrillic : proverb.persianText,
                  textDirection: persian
                      ? TextDirection.ltr
                      : TextDirection.rtl,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 16,
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
