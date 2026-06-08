import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/seed/seed_categories.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/proverb_card.dart';

class ProverbsListScreen extends ConsumerWidget {
  const ProverbsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final proverbs = ref.watch(filteredProverbsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedLevel = ref.watch(selectedLevelProvider);
    final categories = seedCategories;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мақолҳо'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
              ref.read(selectedLevelProvider.notifier).state = null;
              ref.read(searchQueryProvider.notifier).state = '';
            },
            icon: const Icon(Icons.filter_list_off),
            tooltip: 'Пок кардан',
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
              decoration: const InputDecoration(
                hintText: 'Ҷустуҷӯи мақол...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          // Level filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: const Text('Ҳама', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                      label: Text('Сатҳ $level', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
          // Category filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: categories.map((cat) {
                final isSelected = selectedCategory == cat.id;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat.nameTj, style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    )),
                    selected: isSelected,
                    backgroundColor: colorScheme.surface,
                    selectedColor: colorScheme.primary,
                    checkmarkColor: colorScheme.onPrimary,
                    onSelected: (_) {
                      ref.read(selectedCategoryProvider.notifier).state =
                          isSelected ? null : cat.id;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: proverbs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Мақол ёфт нашуд',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Филтрҳоро тағир диҳед',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
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
