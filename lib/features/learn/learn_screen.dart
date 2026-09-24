import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/learning_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/recent_activity_display_text.dart';

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

    final levels = ref.watch(availableLevelsProvider).length;

    void openFlashcards() {
      // This is the general entry point, so always open the full deck. A
      // stale filter (e.g. "again" left by the quiz's "practice missed"
      // handoff) must not leak in here.
      ref.read(flashcardsFilterProvider.notifier).state = MasteryFilter.all;
      context.push('/flashcards');
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('learn_title'),
          style: QalamTypography.monographTitle(
            color: colors.onSurface,
            fontSize: 24,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 48),
        children: [
          _ProgressPanel(stats: stats, lang: lang),
          if (lastLevelActivity != null) ...[
            const SizedBox(height: 28),
            _Eyebrow(tr('learn_continue')),
            QalamIndexRow(
              leading: Icons.play_arrow_rounded,
              title: RecentActivityDisplayText.title(lastLevelActivity, lang),
              subtitle:
                  RecentActivityDisplayText.subtitle(lastLevelActivity, lang) ??
                  tr('learn_continue_hint'),
              onTap: () {
                // The level filter is in-memory only, so after a restart it
                // is null while the activity (and its level) is persisted.
                // Restore the level from the record so Continue resumes the
                // actual level instead of the unfiltered proverb list. When
                // the record is malformed or its level is no longer in the
                // catalog, fall back to null (the unfiltered list) so a stale
                // in-memory selection does not leak into /proverbs.
                final level = _levelFromActivityId(lastLevelActivity.id);
                final validLevel =
                    level != null &&
                    ref.read(availableLevelsProvider).contains(level);
                ref.read(selectedLevelProvider.notifier).state = validLevel
                    ? level
                    : null;
                context.push(lastLevelActivity.route);
              },
            ),
          ],
          const SizedBox(height: 28),
          _Eyebrow(tr('learn_tracks')),
          const SizedBox(height: 4),
          QalamTileGrid(
            maxColumns: 2,
            children: [
              QalamFolioTile(
                seed: 'levels',
                icon: Icons.stairs_outlined,
                title: tr('levels_title'),
                subtitle: AppTranslations.get('learn_levels_count', lang, [
                  AppTranslations.formatNumber(levels, lang),
                ]),
                onTap: () => context.push('/levels'),
              ),
              QalamFolioTile(
                seed: 'quiz',
                icon: Icons.quiz_outlined,
                title: tr('quiz_title'),
                subtitle: tr('learn_quiz_desc'),
                onTap: () => context.push('/quiz'),
              ),
              QalamFolioTile(
                seed: 'flashcards',
                icon: Icons.style_outlined,
                title: tr('flashcards_title'),
                subtitle: tr('learn_flashcards_desc'),
                onTap: openFlashcards,
              ),
              QalamFolioTile(
                seed: 'school',
                icon: Icons.school_outlined,
                title: tr('explore_school_title'),
                subtitle: tr('learn_school_desc'),
                onTap: () => context.push('/literature/school'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Parses the numeric level from a persisted level-activity id like
  /// `level-3`. Returns null for malformed ids (missing or non-numeric
  /// suffix) so a corrupt record can never pin the /proverbs list to an
  /// invalid filter; the caller additionally checks the level is present
  /// in the catalog before restoring it.
  static int? _levelFromActivityId(String id) {
    const prefix = 'level-';
    if (!id.startsWith(prefix)) return null;
    return int.tryParse(id.substring(prefix.length));
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: QalamTypography.eyebrow(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

/// Progress as a boxed panel: three counts (mastered, learning, to review)
/// and a bar for the share mastered. Shown from the first day (zeros are
/// honest), so the page always has the same shape.
class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.stats, required this.lang});

  final MasteryStats stats;
  final DisplayLanguage lang;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    String tr(String key) => AppTranslations.get(key, lang);
    String n(int value) => AppTranslations.formatNumber(value, lang);
    final share = stats.totalProverbs == 0
        ? 0.0
        : stats.masteredCount / stats.totalProverbs;

    Widget figure(int value, String label, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n(value),
            style: QalamTypography.monographTitle(color: color, fontSize: 30),
          ),
          Text(
            label,
            style: QalamTypography.meta(
              color: colors.onSurfaceVariant,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainer
            : colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            tr('learn_your_progress'),
            style: QalamTypography.literaryTitle(
              color: colors.onSurface,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              figure(
                stats.masteredCount,
                tr('flashcards_filter_mastered'),
                colors.primary,
              ),
              figure(
                stats.learningCount,
                tr('flashcards_filter_learning'),
                colors.onSurface,
              ),
              figure(
                stats.againCount,
                tr('flashcards_filter_again'),
                colors.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: share,
              minHeight: 6,
              backgroundColor: colors.outlineVariant,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppTranslations.get('home_mastery_stat', lang, [
              n(stats.masteredCount),
              n(stats.totalProverbs),
            ]),
            style: QalamTypography.meta(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
