import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../shared/providers/app_providers.dart';
import '../l10n/app_translations.dart';
import 'design_system.dart';

/// A numbered entry in the collection's table of contents.
class QalamCategoryTile extends ConsumerWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const QalamCategoryTile({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  static String nameFor(Category category, DisplayLanguage language) {
    if (language == DisplayLanguage.tajik) return category.nameTj;
    const names = {
      'ilm': 'علم',
      'hikmat': 'حکمت',
      'sabr': 'صبر',
      'padaru_modar': 'پدر و مادر',
      'dusti': 'دوستی',
      'mehnat': 'کار و کوشش',
      'pul': 'پول',
      'rostqavli': 'راست‌گویی',
      'muhabbat': 'محبت',
      'zindagi': 'زندگی',
      'din': 'دین',
      'jasorat': 'شجاعت',
      'vaqt': 'وقت',
      'xomushhi': 'خاموشی',
      'odob': 'ادب',
      'tanbali': 'تنبلی',
      'oila': 'خانواده',
      'ehtirom': 'احترام',
      'omuzish': 'آموزش',
      'muvaffaqiyat': 'موفقیت',
    };
    return names[category.id] ?? category.nameTj;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final language = ref.watch(displayLanguageProvider);
    final count = ref
        .watch(proverbsProvider)
        .where((proverb) => proverb.categoryId == category.id)
        .length;
    final name = nameFor(category, language);
    final countLabel =
        '${AppTranslations.formatNumber(count, language)} ${AppTranslations.get('levels_proverbs', language)}';

    // «Атлас» cover: the collection's own ikat print, with the title on a
    // solid paper plate so it never sits on the pattern.
    return Semantics(
      selected: isSelected,
      button: true,
      label: '$name, $countLabel',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
              border: Border.all(
                color: isSelected ? colors.primary : colors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: 1.25,
                  child: AtlasCover(seed: category.id),
                ),
                Container(
                  color: colors.surfaceContainerLowest,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: QalamTypography.literaryTitle(
                                color: colors.onSurface,
                                fontSize: 19,
                                height: 1.15,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check, color: colors.primary, size: 18),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        countLabel,
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
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
