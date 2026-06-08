import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/seed/seed_categories.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/cultural_header.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'school': return Icons.school;
      case 'lightbulb': return Icons.lightbulb;
      case 'hourglass_bottom': return Icons.hourglass_bottom;
      case 'family_restroom': return Icons.family_restroom;
      case 'favorite': return Icons.favorite;
      case 'work': return Icons.work;
      case 'attach_money': return Icons.attach_money;
      case 'verified': return Icons.verified;
      case 'favorite_border': return Icons.favorite_border;
      case 'auto_stories': return Icons.auto_stories;
      case 'mosque': return Icons.mosque;
      case 'shield': return Icons.shield;
      case 'schedule': return Icons.schedule;
      case 'volume_off': return Icons.volume_off;
      case 'emoji_people': return Icons.emoji_people;
      case 'weekend': return Icons.weekend;
      case 'home': return Icons.home;
      case 'thumb_up': return Icons.thumb_up;
      case 'psychology': return Icons.psychology;
      case 'emoji_events': return Icons.emoji_events;
      default: return Icons.book;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categories = seedCategories;
    final proverbs = ref.watch(proverbsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: Column(
        children: [
          CulturalHeader(
            title: 'Гурӯҳҳо',
            subtitle: '${categories.length} гурӯҳи мақолҳо',
            trailing: selectedCategory != null
                ? Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        ref.read(selectedCategoryProvider.notifier).state = null;
                      },
                      icon: const Icon(Icons.clear, color: Colors.white, size: 18),
                      padding: EdgeInsets.zero,
                    ),
                  )
                : null,
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final proverbCount = proverbs.where((p) => p.categoryId == category.id).length;
                final isSelected = selectedCategory == category.id;
                final color = AppColors.getCategoryColor(index);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: isSelected
                          ? BorderSide(color: color, width: 2.5)
                          : BorderSide.none,
                    ),
                    elevation: isSelected ? 4 : 2,
                    child: InkWell(
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            isSelected ? null : category.id;
                        context.go('/proverbs');
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isSelected
                              ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    color.withValues(alpha: 0.15),
                                    color.withValues(alpha: 0.05),
                                  ],
                                )
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: isSelected
                                    ? Border.all(color: color, width: 2)
                                    : null,
                              ),
                              child: Icon(
                                _getIconData(category.iconName),
                                size: 32,
                                color: color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              category.nameTj,
                              style: TextStyle(
                                fontFamily: 'NotoSerif',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$proverbCount мақол',
                                style: TextStyle(
                                  fontFamily: 'NotoSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color.withValues(alpha: 0.8),
                                ),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: 8),
                              Icon(Icons.check_circle, size: 18, color: color),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
