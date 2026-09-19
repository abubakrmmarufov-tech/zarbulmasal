import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('explore_title', lang),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Search Hero
          GestureDetector(
            onTap: () => context.push('/search'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppTranslations.get('explore_search_placeholder', lang),
                      style: QalamTypography.body(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Literature Section
          Text(
            AppTranslations.get('explore_literature_title', lang),
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildExploreCard(
            context,
            icon: Icons.people_outline,
            title: AppTranslations.get('explore_poets_title', lang),
            subtitle: AppTranslations.get('explore_poets_sub', lang),
            onTap: () => context.push('/literature/poets'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.auto_stories_outlined,
            title: AppTranslations.get('explore_works_title', lang),
            subtitle: AppTranslations.get('explore_works_sub', lang),
            onTap: () => context.push('/literature/works'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.school_outlined,
            title: AppTranslations.get('explore_school_title', lang),
            subtitle: AppTranslations.get('explore_school_sub', lang),
            onTap: () => context.push('/literature/school'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.record_voice_over_outlined,
            title: AppTranslations.get('explore_oral_title', lang),
            subtitle: AppTranslations.get('explore_oral_sub', lang),
            onTap: () => context.push('/literature/oral'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.hub_outlined,
            title: AppTranslations.get('explore_hub_title', lang),
            subtitle: AppTranslations.get('explore_hub_sub', lang),
            onTap: () => context.push('/literature'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.local_library_outlined,
            title: AppTranslations.get('explore_books_title', lang),
            subtitle: AppTranslations.get('explore_books_sub', lang),
            onTap: () => context.push('/books'),
          ),
          const SizedBox(height: 32),

          // History Section
          Text(
            AppTranslations.get('explore_history_title', lang),
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildExploreCard(
            context,
            icon: Icons.timeline,
            title: AppTranslations.get('explore_history_card_title', lang),
            subtitle: AppTranslations.get('explore_history_card_sub', lang),
            onTap: () => context.push('/history'),
          ),
          const SizedBox(height: 32),

          // Proverbs Section
          Text(
            AppTranslations.get('explore_proverbs_title', lang),
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildExploreCard(
            context,
            icon: Icons.format_list_bulleted,
            title: AppTranslations.get('explore_topics_title', lang),
            subtitle: AppTranslations.get('explore_topics_sub', lang),
            onTap: () => context.push('/categories'),
          ),
          _buildExploreCard(
            context,
            icon: Icons.menu_book_outlined,
            title: AppTranslations.get('explore_all_title', lang),
            subtitle: AppTranslations.get('explore_all_sub', lang),
            onTap: () => context.push('/proverbs'),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: QalamTypography.body(color: colors.onSurface),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const QalamChevron(size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
