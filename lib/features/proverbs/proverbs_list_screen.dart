import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/proverb_card.dart';
import '../../shared/widgets/pamir_silhouette.dart';
import '../../shared/widgets/tajik_pattern_divider.dart';

class ProverbsListScreen extends ConsumerWidget {
  const ProverbsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final proverbs = ref.watch(filteredProverbsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedLevel = ref.watch(selectedLevelProvider);
    final displayLang = ref.watch(displayLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.get('proverbs_title', displayLang)),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
              ref.read(selectedLevelProvider.notifier).state = null;
              ref.read(searchQueryProvider.notifier).state = '';
            },
            icon: const Icon(Icons.filter_list_off),
            tooltip: AppTranslations.get('btn_clear_filters', displayLang),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              decoration: InputDecoration(
                hintText: AppTranslations.get('proverbs_search_hint', displayLang),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TajikPatternDivider(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(
                      AppTranslations.get('proverbs_all_levels', displayLang),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    selected: selectedLevel == null && selectedCategory == null,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state = null;
                      ref.read(selectedLevelProvider.notifier).state = null;
                    },
                  ),
                ),
                ...List.generate(10, (i) {
                  final level = i + 1;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(
                        AppTranslations.get('badges_level', displayLang, [level.toString()]),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      selected: selectedLevel == level,
                      onSelected: (_) {
                        ref.read(selectedLevelProvider.notifier).state =
                            selectedLevel == level ? null : level;
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: proverbs.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      PamirSilhouette(
                        height: 48,
                        darkMode: Theme.of(context).brightness == Brightness.dark,
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppTranslations.get('empty_no_proverbs_found', displayLang),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppTranslations.get('empty_change_filters', displayLang),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: proverbs.length,
                    itemBuilder: (context, index) {
                      final proverb = proverbs[index];
                      return ProverbCard(
                        proverb: proverb,
                        onTap: () => context.push('/proverb/${proverb.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
