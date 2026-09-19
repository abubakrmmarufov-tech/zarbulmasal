import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/learning_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';

class LearnScreen extends ConsumerWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final stats = ref.watch(masteryStatsProvider);
    String tr(String key) => AppTranslations.get(key, lang);

    // Find last level activity
    final recentActivity = ref.watch(recentActivityProvider);
    final lastLevelActivity = recentActivity
        .where((r) => r.type == RecentActivityType.level)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('learn_title'),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          // Mastery Stats Hero
          if (stats.masteredCount > 0 || stats.learningCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.emoji_events, color: colors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('learn_your_progress'),
                          style: QalamTypography.body(color: colors.primary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppTranslations.get('home_mastery_stat', lang, [
                            AppTranslations.formatDigits(
                              '${stats.masteredCount}',
                              lang,
                            ),
                            AppTranslations.formatDigits(
                              '${stats.totalProverbs}',
                              lang,
                            ),
                          ]),
                          style: QalamTypography.meta(color: colors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],

          if (lastLevelActivity != null) ...[
            Text(
              tr('learn_continue'),
              style: QalamTypography.sectionTitle(color: colors.onSurface),
            ),
            const SizedBox(height: 12),
            _buildLearnCard(
              context,
              icon: Icons.play_arrow_rounded,
              title: lastLevelActivity.title,
              subtitle:
                  lastLevelActivity.subtitle ??
                  tr('learn_continue_hint'),
              onTap: () => context.push(lastLevelActivity.route),
              primary: true,
            ),
            const SizedBox(height: 32),
          ],

          // Learning Paths
          Text(
            tr('learn_tracks'),
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          _buildLearnCard(
            context,
            icon: Icons.stairs_outlined,
            title: tr('levels_title'),
            subtitle: tr('learn_levels_step_by_step'),
            onTap: () => context.push('/levels'),
          ),
          _buildLearnCard(
            context,
            icon: Icons.school_outlined,
            title: tr('learn_school_title'),
            subtitle: tr('learn_school_desc'),
            onTap: () => context.push('/literature/school'),
          ),

          const SizedBox(height: 32),

          // Practice
          Text(
            tr('learn_practice'),
            style: QalamTypography.sectionTitle(color: colors.onSurface),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLearnCard(
                  context,
                  icon: Icons.quiz_outlined,
                  title: tr('quiz_title'),
                  subtitle: tr('learn_quiz_desc'),
                  onTap: () => context.push('/quiz'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLearnCard(
                  context,
                  icon: Icons.style_outlined,
                  title: tr('flashcards_title'),
                  subtitle: tr('learn_flashcards_desc'),
                  onTap: () => context.push('/flashcards'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLearnCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool primary = false,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: primary ? colors.primaryContainer : colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: primary
              ? colors.primary.withValues(alpha: 0.5)
              : colors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: primary ? colors.onPrimaryContainer : colors.primary,
                size: 32,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: QalamTypography.body(
                  color: primary ? colors.onPrimaryContainer : colors.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: QalamTypography.meta(
                    color: primary
                        ? colors.onPrimaryContainer.withValues(alpha: 0.8)
                        : colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
