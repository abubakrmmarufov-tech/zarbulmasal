import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/recent_activity_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../literature/data/literature_providers.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';

/// Full-screen detail view for a specific historical entry (dynasty, person, event, or site).
class HistoryDetailScreen extends ConsumerWidget {
  final String entryId;

  const HistoryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final entryAsync = ref.watch(historyEntryByIdProvider(entryId));
    final booksAsync = ref.watch(historyBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTranslations.get('hist_detail_title', lang),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: AppTranslations.get('back', lang),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/history');
            }
          },
        ),
      ),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: AppTranslations.get('hist_detail_error_title', lang),
            subtitle: err.toString(),
            action: OutlinedButton(
              onPressed: () =>
                  ref.invalidate(historyEntryByIdProvider(entryId)),
              child: Text(AppTranslations.get('btn_retry', lang)),
            ),
          ),
        ),
        data: (entry) {
          if (entry == null) {
            return Center(
              child: EmptyState(
                icon: Icons.search_off,
                title: AppTranslations.get('hist_detail_not_found_title', lang),
                subtitle: AppTranslations.get('hist_detail_not_found_sub', lang),
                action: OutlinedButton(
                  onPressed: () => context.go('/history'),
                  child: Text(
                    AppTranslations.get('hist_back_to_history', lang),
                  ),
                ),
              ),
            );
          }

          final books = booksAsync.valueOrNull ?? [];
          final sourceBook = books
              .where((b) => b.id == entry.sourceBookId)
              .firstOrNull;

          final title = isPersian && entry.titlePersian != null
              ? entry.titlePersian!
              : entry.title;
          final summary = isPersian && entry.summaryPersian != null
              ? entry.summaryPersian!
              : entry.summary;
          final dates = isPersian && entry.datesPersian != null
              ? entry.datesPersian!
              : (entry.dates ?? entry.period);
          final capital = isPersian && entry.capitalPersian != null
              ? entry.capitalPersian
              : entry.capital;
          final territory = isPersian && entry.territoryPersian != null
              ? entry.territoryPersian
              : entry.territory;
          final significance = isPersian && entry.significancePersian != null
              ? entry.significancePersian
              : entry.significance;
          final keyFigures = isPersian && entry.keyFiguresPersian.isNotEmpty
              ? entry.keyFiguresPersian
              : entry.keyFigures;
          final section = entry.sourceSection;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(recentActivityProvider.notifier)
                .addActivity(
                  RecentActivity(
                    id: entry.id,
                    type: RecentActivityType.history,
                    title: isPersian && entry.titlePersian != null
                        ? entry.titlePersian!
                        : entry.title,
                    subtitle: isPersian ? 'تاریخ' : 'Таърих',
                    timestamp: DateTime.now(),
                    route: '/history/${entry.id}',
                  ),
                );
          });

          return Directionality(
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                // Kind badge & Grade Chip
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconForKind(entry.kind),
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _kindLabel(entry.kind, isPersian),
                            style: QalamTypography.eyebrow(
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        AppTranslations.get('hist_filter_grade', lang, [entry.grade]),
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: QalamTypography.pageTitle(
                    color: colors.onSurface,
                    fontSize: 26,
                  ),
                ),
                if (dates.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dates,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                // Capital, Territory, Key Figures
                if ((capital != null && capital.isNotEmpty) ||
                    (territory != null && territory.isNotEmpty) ||
                    keyFigures.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(
                        QalamSpacing.cardRadius,
                      ),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (capital != null && capital.isNotEmpty) ...[
                          _DetailLine(
                            icon: Icons.location_city,
                            label: AppTranslations.get('hist_capital', lang),
                            value: capital,
                          ),
                        ],
                        if (territory != null && territory.isNotEmpty) ...[
                          if (capital != null && capital.isNotEmpty)
                            const Divider(height: 20),
                          _DetailLine(
                            icon: Icons.public,
                            label: AppTranslations.get('hist_territory', lang),
                            value: territory,
                          ),
                        ],
                        if (keyFigures.isNotEmpty) ...[
                          if ((capital != null && capital.isNotEmpty) ||
                              (territory != null && territory.isNotEmpty))
                            const Divider(height: 20),
                          _DetailLine(
                            icon: Icons.people_outline,
                            label: AppTranslations.get('hist_key_figures_and_rulers', lang),
                            value: keyFigures.join(', '),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Historical Summary
                Text(
                  AppTranslations.get('hist_summary', lang),
                  style: QalamTypography.eyebrow(color: colors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  style: QalamTypography.body(
                    color: colors.onSurface,
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
                // Historical Significance
                if (significance != null && significance.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppTranslations.get('hist_significance', lang),
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    significance,
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ],
                // Related Poets
                if (entry.relatedAuthorIds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppTranslations.get('hist_related_authors', lang),
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.relatedAuthorIds.map((authorId) {
                          final authorAsync = ref.watch(
                            authorByIdProvider(authorId),
                          );
                          final author = authorAsync.valueOrNull;
                          final authorName = author != null
                              ? ((isPersian &&
                                        author.canonicalNamePersian != null)
                                    ? author.canonicalNamePersian!
                                    : author.canonicalName)
                              : (authorId == 'rudaki'
                                    ? (isPersian
                                          ? 'ابوعبدالله رودکی'
                                          : 'Абӯабдуллоҳи Рӯдакӣ')
                                    : authorId);
                          return ActionChip(
                            avatar: const Icon(Icons.auto_stories, size: 16),
                            label: Text(authorName),
                            onPressed: () {
                              context.push('/literature/poet/$authorId');
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
                // Related Works
                if (entry.relatedWorkIds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    AppTranslations.get('hist_related_works', lang),
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      final approvedWorks =
                          ref.watch(approvedWorksProvider).valueOrNull ?? [];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.relatedWorkIds.map((workId) {
                          final matched = approvedWorks
                              .where((w) => w.id == workId)
                              .firstOrNull;
                          final workTitle = matched != null
                              ? (isPersian && matched.titlePersian != null
                                    ? matched.titlePersian!
                                    : matched.title)
                              : (workId == 'poem-shahnameh'
                                    ? (isPersian ? 'شاهنامه' : 'Шоҳнома')
                                    : workId);
                          return ActionChip(
                            avatar: const Icon(Icons.menu_book, size: 16),
                            label: Text(workTitle),
                            onPressed: () {
                              if (matched != null) {
                                context.push('/literature/work/${matched.id}');
                              } else {
                                context.push('/literature/works');
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 28),
                // Official Source Card with Website Launcher
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      QalamSpacing.cardRadius,
                    ),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              AppTranslations.get('hist_official_textbook', lang),
                              style: QalamTypography.eyebrow(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${AppTranslations.get('hist_filter_grade', lang, [entry.grade])} · $section',
                        style: QalamTypography.sectionTitle(
                          color: colors.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      if (sourceBook != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          isPersian && sourceBook.titlePersian != null
                              ? '${sourceBook.titlePersian!} (${sourceBook.authorPersian ?? sourceBook.author})'
                              : '${sourceBook.title} (${sourceBook.author})',
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        if (sourceBook.sourceUrl.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                            ),
                            icon: const Icon(Icons.open_in_browser, size: 20),
                            label: Text(
                              (sourceBook.isUploadedBook || sourceBook.localPath != null)
                                  ? AppTranslations.get('hist_source_study_local', lang)
                                  : AppTranslations.get('hist_source_study', lang),
                            ),
                            onPressed: () async {
                              final uri = Uri.parse(sourceBook.sourceUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static IconData _iconForKind(HistoryEntryKind kind) => switch (kind) {
    HistoryEntryKind.empire => Icons.account_balance,
    HistoryEntryKind.dynasty => Icons.account_balance,
    HistoryEntryKind.ruler => Icons.shield,
    HistoryEntryKind.person => Icons.person,
    HistoryEntryKind.event => Icons.event,
    HistoryEntryKind.battle => Icons.sports_kabaddi,
    HistoryEntryKind.place => Icons.location_on,
    HistoryEntryKind.cultural => Icons.palette,
    HistoryEntryKind.poem => Icons.auto_stories,
    HistoryEntryKind.oral => Icons.record_voice_over,
  };

  static String _kindLabel(
    HistoryEntryKind kind,
    bool isPersian,
  ) {
    final key = switch (kind) {
      HistoryEntryKind.empire => 'hist_kind_empire',
      HistoryEntryKind.dynasty => 'hist_kind_dynasty',
      HistoryEntryKind.ruler => 'hist_kind_ruler',
      HistoryEntryKind.person => 'hist_kind_person',
      HistoryEntryKind.event => 'hist_kind_event',
      HistoryEntryKind.battle => 'hist_kind_battle',
      HistoryEntryKind.place => 'hist_kind_place',
      HistoryEntryKind.cultural => 'hist_kind_cultural',
      HistoryEntryKind.poem => 'hist_kind_poem',
      HistoryEntryKind.oral => 'hist_kind_oral',
    };
    return AppTranslations.getForLang(isPersian ? 'fa' : 'tj', key);
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: QalamTypography.meta(color: colors.primary, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: QalamTypography.body(color: colors.onSurface, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
