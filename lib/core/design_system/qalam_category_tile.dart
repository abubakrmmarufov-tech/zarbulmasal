import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../data/seed/seed_categories.dart';
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
    final index = seedCategories.indexWhere((item) => item.id == category.id);
    return Semantics(
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: 100),
            padding: const EdgeInsets.symmetric(vertical: 22),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 6, end: 20),
                  child: Text(
                    '${index + 1}'.padLeft(2, '0'),
                    style: QalamTypography.meta(
                      color: colors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nameFor(category, language),
                        style: QalamTypography.sectionTitle(
                          color: isSelected ? colors.primary : colors.onSurface,
                          fontSize: 23,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '$count ${AppTranslations.get('levels_proverbs', language)}',
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 12, top: 6),
                  child: Icon(
                    isSelected ? Icons.check : Icons.arrow_forward,
                    color: isSelected ? colors.primary : colors.onSurface,
                    size: 20,
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
