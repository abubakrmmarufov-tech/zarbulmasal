import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

/// The collection's table of contents, with live counts for every subject.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(displayLanguageProvider);
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(selectedCategoryProvider);
    final isPersian = language == DisplayLanguage.persian;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: isPersian ? '۰۲ / فهرست' : '02 / ФЕҲРИСТ',
                title: AppTranslations.get('categories_title', language),
                subtitle: AppTranslations.get('categories_subtitle', language),
              ),
            ),
            if (selected != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: QalamSpacing.pageH,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () =>
                          ref.read(selectedCategoryProvider.notifier).state =
                              null,
                      icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                      label: Text(
                        isPersian
                            ? 'پاک کردن فیلتر موضوع'
                            : 'Тоза кардани мавзӯъ',
                      ),
                    ),
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                QalamSpacing.pageH,
                8,
                QalamSpacing.pageH,
                48,
              ),
              sliver: SliverList.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return QalamCategoryTile(
                    category: category,
                    isSelected: selected == category.id,
                    onTap: () {
                      // Entering a subject starts a new browsing scope. The list
                      // still supports combining filters deliberately afterward.
                      ref.read(selectedLevelProvider.notifier).state = null;
                      ref.read(searchQueryProvider.notifier).state = '';
                      ref.read(selectedCategoryProvider.notifier).state =
                          selected == category.id ? null : category.id;
                      context.go('/proverbs');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
