import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/category.dart';
import '../../data/models/proverb.dart';
import '../../data/seed/seed_categories.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/cultural_header.dart';
import '../../shared/widgets/section_card.dart';
import '../../shared/widgets/tajik_badge.dart';
import '../../shared/widgets/pamir_silhouette.dart';
import '../../shared/widgets/textile_divider.dart';
import '../../core/theme/app_colors.dart';

class ProverbDetailScreen extends ConsumerWidget {
  final String proverbId;

  const ProverbDetailScreen({
    super.key,
    required this.proverbId,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final proverbs = ref.watch(proverbsProvider);
    final favorites = ref.watch(favoritesProvider);
    final displayLang = ref.watch(displayLanguageProvider);
    final isPersian = displayLang == DisplayLanguage.persian;

    if (proverbs.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            CulturalHeader(
              title: AppTranslations.get('proverbs_title', displayLang),
              subtitle: AppTranslations.get('detail_loading', displayLang),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppTranslations.get('detail_no_proverbs', displayLang),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final proverb = proverbs.firstWhere(
      (p) => p.id == proverbId,
      orElse: () => proverbs.first,
    );
    final isFavorite = favorites.contains(proverb.id);
    final category = _getCategory(proverb.categoryId);
    final isTraditional = proverb.type == ProverbType.traditional;
    final isVerified = proverb.sourceStatus == SourceStatus.verified;
    final categoryColor = AppColors.getCategoryColor(
      seedCategories.indexWhere((c) => c.id == proverb.categoryId),
    );

    final primaryText = isPersian ? proverb.persianText : proverb.tajikCyrillic;
    final secondaryText = isPersian ? proverb.tajikCyrillic : proverb.persianText;
    final subtitle = isPersian ? proverb.tajikCyrillic : proverb.persianText;
    final levelBadge = isPersian
        ? AppTranslations.get('badges_level', displayLang, [proverb.level.toString()])
        : 'Сатҳ ${proverb.level}';

    return Scaffold(
      body: Column(
        children: [
          CulturalHeader(
            title: AppTranslations.get('proverbs_title', displayLang),
            subtitle: subtitle,
            trailing: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggle(proverb.id);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red.shade300 : Colors.white,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          PamirSilhouette(
            height: 28,
            darkMode: Theme.of(context).brightness == Brightness.dark,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary.withValues(alpha: 0.08),
                          colorScheme.primary.withValues(alpha: 0.03),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 48,
                          color: AppColors.accentGold.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          primaryText,
                          style: TextStyle(
                            fontFamily: 'NotoSerif',
                            fontSize: 22,
                            height: 1.7,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          secondaryText,
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 17,
                            fontStyle: FontStyle.italic,
                            height: 1.6,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                          textDirection: isPersian ? TextDirection.ltr : TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TajikBadge.category(
                        text: category.nameTj,
                        icon: _getIconData(category.iconName),
                        accentColor: categoryColor,
                      ),
                      TajikBadge.level(
                        text: levelBadge,
                        accentColor: AppColors.accentGold,
                      ),
                      TajikBadge.type(
                        isTraditional: isTraditional,
                        primaryColor: AppColors.accentGold,
                        displayLanguage: displayLang,
                      ),
                      TajikBadge.verified(
                        isVerified: isVerified,
                        displayLanguage: displayLang,
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: TextileDivider(height: 20),
                  ),

                  const SizedBox(height: 24),
                  SectionCard(
                    title: AppTranslations.get('detail_simple_explanation', displayLang),
                    icon: Icons.menu_book,
                    accentColor: AppColors.accentGold,
                    child: Text(
                      proverb.simpleExplanationTj,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 16,
                        height: 1.7,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SectionCard(
                    title: AppTranslations.get('detail_meaning', displayLang),
                    icon: Icons.lightbulb_outline,
                    accentColor: const Color(0xFF166534),
                    child: Text(
                      proverb.meaningTj,
                      style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 16,
                        height: 1.7,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  SectionCard(
                    title: AppTranslations.get('detail_example', displayLang),
                    icon: Icons.format_quote,
                    accentColor: const Color(0xFFC2410C),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, size: 20, color: Color(0xFFC2410C)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            proverb.exampleSentenceTj,
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 16,
                              height: 1.7,
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (proverb.sourceNote.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              proverb.sourceNote,
                              style: TextStyle(
                                fontFamily: 'NotoSans',
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
