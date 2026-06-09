import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/proverb.dart';
import '../../data/models/category.dart';
import '../../data/seed/seed_categories.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

class ProverbCard extends ConsumerWidget {
  final Proverb proverb;
  final VoidCallback? onTap;

  const ProverbCard({
    super.key,
    required this.proverb,
    this.onTap,
  });

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

  Category _getCategory(String categoryId) {
    return seedCategories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => const Category(id: '', nameTj: 'Номаълум', iconName: 'book'),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(proverb.id);
    final category = _getCategory(proverb.categoryId);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTraditional = proverb.type == ProverbType.traditional;
    final accentColor = const Color(0xFFD97706);
    final displayLang = ref.watch(displayLanguageProvider);
    final isPersian = displayLang == DisplayLanguage.persian;
    final primaryText = isPersian ? proverb.persianText : proverb.tajikCyrillic;
    final secondaryText = isPersian ? proverb.tajikCyrillic : proverb.persianText;
    final primaryDir = isPersian ? TextDirection.rtl : TextDirection.ltr;
    final levelName = isPersian
        ? AppTranslations.get('badges_level', displayLang, [proverb.level.toString()])
        : 'Сатҳ ${proverb.level}';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: accentColor.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              primaryText,
                              style: TextStyle(
                                fontFamily: 'NotoSerif',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.6,
                                color: colorScheme.onSurface,
                              ),
                              textDirection: primaryDir,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isFavorite
                                  ? Colors.red.withValues(alpha: 0.1)
                                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                ref.read(favoritesProvider.notifier).toggle(proverb.id);
                              },
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        secondaryText,
                        style: TextStyle(
                          fontFamily: 'NotoSans',
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textDirection: isPersian ? TextDirection.ltr : TextDirection.rtl,
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getIconData(category.iconName), size: 14, color: colorScheme.onPrimaryContainer),
                                const SizedBox(width: 5),
                                Text(
                                  category.nameTj,
                                  style: TextStyle(
                                    fontFamily: 'NotoSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              levelName,
                              style: TextStyle(
                                fontFamily: 'NotoSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isTraditional
                                  ? accentColor.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              AppTranslations.get(
                                isTraditional ? 'badges_traditional' : 'badges_modern',
                                displayLang,
                              ),
                              style: TextStyle(
                                fontFamily: 'NotoSans',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isTraditional ? accentColor : Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
