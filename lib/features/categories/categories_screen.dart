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
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.getForIsPersian(isPersian, 'btn_back'),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          AppTranslations.get('categories_title', language),
          style: QalamTypography.sectionTitle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: AppTranslations.get('home_edition', language),
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
                        AppTranslations.getForIsPersian(
                          isPersian,
                          'categories_clear_topic_filter',
                        ),
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
              // A rack of «Атлас» covers: two across on phones, more on wider
              // screens. Each cover sizes to its title, so enlarged text grows
              // the plate instead of overflowing it.
              sliver: SliverToBoxAdapter(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const spacing = 16.0;
                    final columns = (constraints.maxWidth / 220).floor().clamp(
                      2,
                      4,
                    );
                    final width =
                        (constraints.maxWidth - spacing * (columns - 1)) /
                        columns;
                    return Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: [
                        for (final category in categories)
                          SizedBox(
                            width: width,
                            child: QalamCategoryTile(
                              category: category,
                              isSelected: selected == category.id,
                              onTap: () {
                                // Entering a subject starts a new browsing
                                // scope. The list still supports combining
                                // filters deliberately afterward.
                                ref.read(selectedLevelProvider.notifier).state =
                                    null;
                                ref.read(searchQueryProvider.notifier).state =
                                    '';
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = selected == category.id
                                    ? null
                                    : category.id;
                                context.go('/proverbs');
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
