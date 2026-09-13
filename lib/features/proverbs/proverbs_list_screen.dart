import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';

class ProverbsListScreen extends ConsumerStatefulWidget {
  const ProverbsListScreen({super.key});
  @override
  ConsumerState<ProverbsListScreen> createState() => _ProverbsListScreenState();
}

class _ProverbsListScreenState extends ConsumerState<ProverbsListScreen> {
  late final TextEditingController _searchController;
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clear() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(selectedCategoryProvider.notifier).state = null;
    ref.read(selectedLevelProvider.notifier).state = null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final proverbs = ref.watch(filteredProverbsProvider);
    final availableLevels = ref.watch(availableLevelsProvider);
    final level = ref.watch(selectedLevelProvider);
    final category = ref.watch(selectedCategoryProvider);
    final query = ref.watch(searchQueryProvider);
    final lang = ref.watch(displayLanguageProvider);
    final categories = ref.watch(categoriesProvider);
    String tr(String key) => AppTranslations.get(key, lang);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: tr('home_edition'),
                title: tr('proverbs_title'),
                subtitle:
                    '${tr('proverbs_found')} / ${AppTranslations.formatNumber(proverbs.length, lang)}',
                showRule: false,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  textDirection: lang == DisplayLanguage.persian
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  textInputAction: TextInputAction.search,
                  onChanged: (value) =>
                      ref.read(searchQueryProvider.notifier).state = value,
                  decoration: InputDecoration(
                    hintText: tr('proverbs_search_hint'),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: tr('btn_clear_filters'),
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        tr('levels_title'),
                        style: QalamTypography.eyebrow(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/categories'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(tr('categories_title')),
                          const SizedBox(width: 8),
                          const Icon(Icons.tune, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _LevelTab(
                      key: const ValueKey('level-filter-all'),
                      label: tr('proverbs_all_levels'),
                      selected: level == null,
                      onTap: () =>
                          ref.read(selectedLevelProvider.notifier).state = null,
                    ),
                    for (final value in availableLevels)
                      _LevelTab(
                        key: ValueKey('level-filter-$value'),
                        label: AppTranslations.formatDigits(
                          '$value'.padLeft(2, '0'),
                          lang,
                        ),
                        selected: level == value,
                        onTap: () =>
                            ref.read(selectedLevelProvider.notifier).state =
                                level == value ? null : value,
                      ),
                  ],
                ),
              ),
            ),
            if (category != null || query.isNotEmpty || level != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Wrap(
                    spacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (category != null &&
                          categories.any((c) => c.id == category))
                        Text(
                          QalamCategoryTile.nameFor(
                            categories.firstWhere((c) => c.id == category),
                            lang,
                          ),
                          style: QalamTypography.label(color: colors.primary),
                        ),
                      TextButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.close, size: 16),
                        label: Text(tr('btn_clear_filters')),
                      ),
                    ],
                  ),
                ),
              ),
            if (proverbs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.search_off,
                  title: tr('proverbs_no_results'),
                  subtitle: tr('proverbs_change_filters'),
                  action: OutlinedButton(
                    onPressed: _clear,
                    child: Text(tr('btn_clear_filters')),
                  ),
                ),
              )
            else
              SliverList.builder(
                itemCount: proverbs.length,
                itemBuilder: (context, index) => QalamProverbCard(
                  key: ValueKey(proverbs[index].id),
                  proverb: proverbs[index],
                  onTap: () => context.push('/proverb/${proverbs[index].id}'),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}

class _LevelTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LevelTab({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      selected: selected,
      child: Material(
        color: selected ? colors.onSurface : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              label,
              style: QalamTypography.label(
                color: selected ? colors.surface : colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
