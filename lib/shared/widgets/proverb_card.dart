import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/proverb.dart';
import '../../data/models/category.dart';
import '../../data/seed/seed_categories.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';
import '../../core/theme/design_system.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    
    final displayLang = ref.watch(displayLanguageProvider);
    final isPersian = displayLang == DisplayLanguage.persian;
    
    final primaryText = isPersian ? proverb.persianText : proverb.tajikCyrillic;
    final secondaryText = isPersian ? proverb.tajikCyrillic : proverb.persianText;
    final primaryDir = isPersian ? TextDirection.rtl : TextDirection.ltr;
    final levelName = isPersian
        ? AppTranslations.get('badges_level', displayLang, [proverb.level.toString()])
        : 'Сатҳ ${proverb.level}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        boxShadow: DesignSystem.softShadow(isDark),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      primaryText,
                      style: GoogleFonts.notoSerif(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      textDirection: primaryDir,
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => ref.read(favoritesProvider.notifier).toggle(proverb.id),
                    child: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorite ? colorScheme.primary : colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                secondaryText,
                style: GoogleFonts.notoSans(
                  fontSize: 15,
                  height: 1.5,
                  color: colorScheme.onSurfaceVariant,
                ),
                textDirection: isPersian ? TextDirection.ltr : TextDirection.rtl,
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(
                    icon: _getIconData(category.iconName),
                    label: category.nameTj,
                    color: colorScheme.primary,
                  ),
                  _Badge(
                    icon: Icons.stairs,
                    label: levelName,
                    color: colorScheme.tertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.notoSans(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
