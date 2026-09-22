import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../core/utils/search_normalizer.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../history/data/history_providers.dart';
import '../history/domain/history_domain.dart';
import '../literature/data/literature_providers.dart';
import '../literature/domain/domain.dart';
import '../literature/presentation/literary_author_display_text.dart';
import '../literature/presentation/literary_work_display_text.dart';
import '../books/data/books_providers.dart';
import '../books/domain/book_domain.dart';
import '../books/presentation/book_display_text.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String _rawQuery = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);

    final proverbs = ref.watch(proverbsProvider);
    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final worksAsync = ref.watch(approvedWorksProvider);
    final historyAsync = ref.watch(historyEntriesProvider);
    final booksAsync = ref.watch(booksProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: TextField(
          controller: _controller,
          maxLength: 256,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppTranslations.get('search_hint_global', lang),
            border: InputBorder.none,
            hintStyle: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
            ),
          ),
          style: QalamTypography.body(color: colors.onSurface),
          onChanged: (val) {
            setState(() {
              _rawQuery = val;
              _query = SearchNormalizer.normalize(val);
            });
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: AppTranslations.get('lit_search_clear_tooltip', lang),
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {
                  _rawQuery = '';
                  _query = '';
                });
              },
            ),
        ],
      ),
      body:
          (authorsAsync.isLoading ||
              worksAsync.isLoading ||
              historyAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : (authorsAsync.hasError ||
                worksAsync.hasError ||
                historyAsync.hasError)
          ? Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: AppTranslations.get('search_error_title', lang),
                subtitle: AppTranslations.get('search_error_sub', lang),
                action: OutlinedButton(
                  onPressed: () {
                    ref.invalidate(literaryAuthorsProvider);
                    ref.invalidate(approvedWorksProvider);
                    ref.invalidate(historyEntriesProvider);
                  },
                  child: Text(AppTranslations.get('btn_retry', lang)),
                ),
              ),
            )
          : _query.isEmpty
          ? _buildEmptyState(context, lang)
          : _buildSearchResults(
              context,
              proverbs,
              authorsAsync.valueOrNull ?? const [],
              worksAsync.valueOrNull ?? const [],
              historyAsync.valueOrNull ?? const [],
              booksAsync.valueOrNull ?? const [],
              lang,
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, DisplayLanguage lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppTranslations.get('search_empty_prompt_title', lang),
              style: QalamTypography.sectionTitle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppTranslations.get('search_empty_prompt_sub', lang),
              textAlign: TextAlign.center,
              style: QalamTypography.bodySecondary(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Proverb> proverbs,
    List<LiteraryAuthor> authors,
    List<LiteraryWork> works,
    List<HistoryEntry> history,
    List<Book> books,
    DisplayLanguage lang,
  ) {
    final isPersian = lang == DisplayLanguage.persian;
    String historyTitle(HistoryEntry entry) {
      if (!isPersian) return entry.title;
      final translated = entry.titlePersian?.trim() ?? '';
      return translated.isNotEmpty
          ? translated
          : AppTranslations.get('hist_translation_pending', lang);
    }

    String historyDate(HistoryEntry entry) {
      final candidates = isPersian
          ? [entry.datesPersian, entry.periodPersian]
          : [entry.dates, entry.period];
      for (final candidate in candidates) {
        final value = candidate?.trim() ?? '';
        if (value.isNotEmpty) return value;
      }
      return '';
    }

    final matchingAuthors =
        authors.where((a) {
          if (!a.hasCanonicalName) return false;
          return SearchNormalizer.matchesAny([
            a.canonicalName,
            a.canonicalNamePersian ?? '',
            a.literaryPeriod,
            a.birthPlace ?? '',
            ...a.aliases,
          ], _query);
        }).toList()..sort((a, b) {
          final scoreA = SearchNormalizer.scoreMatchAny([
            a.canonicalName,
            a.canonicalNamePersian ?? '',
            ...a.aliases,
            a.literaryPeriod,
          ], _query);
          final scoreB = SearchNormalizer.scoreMatchAny([
            b.canonicalName,
            b.canonicalNamePersian ?? '',
            ...b.aliases,
            b.literaryPeriod,
          ], _query);
          return scoreB.compareTo(scoreA);
        });

    final matchingWorks =
        works.where((w) {
          return SearchNormalizer.matchesAny([
            w.title,
            w.titlePersian ?? '',
            w.incipit ?? '',
          ], _query);
        }).toList()..sort((a, b) {
          final scoreA = SearchNormalizer.scoreMatchAny([
            a.title,
            a.titlePersian ?? '',
          ], _query);
          final scoreB = SearchNormalizer.scoreMatchAny([
            b.title,
            b.titlePersian ?? '',
          ], _query);
          return scoreB.compareTo(scoreA);
        });

    final matchingProverbs =
        proverbs.where((p) {
          return SearchNormalizer.matchesAny([
            p.tajikCyrillic,
            p.persianText,
            p.meaningTj,
            p.simpleExplanationTj,
          ], _query);
        }).toList()..sort((a, b) {
          final scoreA = SearchNormalizer.scoreMatchAny([
            a.tajikCyrillic,
            a.persianText,
          ], _query);
          final scoreB = SearchNormalizer.scoreMatchAny([
            b.tajikCyrillic,
            b.persianText,
          ], _query);
          return scoreB.compareTo(scoreA);
        });

    final matchingHistory =
        history.where((h) {
          return SearchNormalizer.matchesAny([
            h.title,
            h.titlePersian ?? '',
            h.summary,
            h.summaryPersian ?? '',
            ...h.keywords,
            ...h.keyFigures,
            ...h.keyFiguresPersian,
          ], _query);
        }).toList()..sort((a, b) {
          final scoreA = SearchNormalizer.scoreMatchAny([
            a.title,
            a.titlePersian ?? '',
          ], _query);
          final scoreB = SearchNormalizer.scoreMatchAny([
            b.title,
            b.titlePersian ?? '',
          ], _query);
          return scoreB.compareTo(scoreA);
        });

    final matchingBooks = books.where((book) => book.matches(_query)).toList()
      ..sort((a, b) {
        final scoreA = SearchNormalizer.scoreMatchAny([
          a.titleTj,
          a.titleFa ?? '',
          a.canonicalTitle,
        ], _query);
        final scoreB = SearchNormalizer.scoreMatchAny([
          b.titleTj,
          b.titleFa ?? '',
          b.canonicalTitle,
        ], _query);
        return scoreB.compareTo(scoreA);
      });

    if (matchingAuthors.isEmpty &&
        matchingWorks.isEmpty &&
        matchingProverbs.isEmpty &&
        matchingHistory.isEmpty &&
        matchingBooks.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off,
          title: AppTranslations.get('lit_no_results', lang),
          subtitle: AppTranslations.translate('search_no_results_for', lang, [
            _rawQuery.trim().isNotEmpty ? _rawQuery.trim() : _query,
          ]),
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (matchingAuthors.isNotEmpty) ...[
          _buildSectionHeader(
            AppTranslations.translate('search_poets_count', lang, [
              AppTranslations.formatDigits(
                matchingAuthors.length.toString(),
                lang,
              ),
            ]),
            colors,
          ),
          for (final author in matchingAuthors)
            ListTile(
              leading: Icon(Icons.person_outline, color: colors.primary),
              title: Text(
                LiteraryAuthorDisplayText.name(author, lang),
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: LiteraryAuthorDisplayText.period(author, lang).isEmpty
                  ? null
                  : Text(
                      LiteraryAuthorDisplayText.period(author, lang),
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
              trailing: const QalamChevron(size: 20),
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: author.id,
                        type: RecentActivityType.poet,
                        title: LiteraryAuthorDisplayText.name(author, lang),
                        subtitle: LiteraryAuthorDisplayText.period(
                          author,
                          lang,
                        ),
                        titleTajik: author.canonicalName,
                        titlePersian: author.canonicalNamePersian,
                        subtitleTajik: author.literaryPeriod,
                        subtitlePersian: author.literaryPeriodPersian,
                        timestamp: DateTime.now(),
                        route: '/literature/poet/${author.id}',
                      ),
                    );
                context.push('/literature/poet/${author.id}');
              },
            ),
        ],
        if (matchingWorks.isNotEmpty) ...[
          _buildSectionHeader(
            AppTranslations.translate('search_works_count', lang, [
              AppTranslations.formatDigits(
                matchingWorks.length.toString(),
                lang,
              ),
            ]),
            colors,
          ),
          for (final work in matchingWorks)
            ListTile(
              leading: Icon(Icons.auto_stories_outlined, color: colors.primary),
              title: Text(
                LiteraryWorkDisplayText.title(work, lang),
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: LiteraryWorkDisplayText.incipit(work, lang) != null
                  ? Text(
                      LiteraryWorkDisplayText.incipit(work, lang)!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  : null,
              trailing: const QalamChevron(size: 20),
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: work.id,
                        type: RecentActivityType.work,
                        title: LiteraryWorkDisplayText.title(work, lang),
                        subtitle: AppTranslations.get('search_kind_poem', lang),
                        titleTajik: work.title,
                        titlePersian: work.titlePersian,
                        subtitleTajik: AppTranslations.get(
                          'search_kind_poem',
                          DisplayLanguage.tajik,
                        ),
                        subtitlePersian: AppTranslations.get(
                          'search_kind_poem',
                          DisplayLanguage.persian,
                        ),
                        timestamp: DateTime.now(),
                        route: '/literature/work/${work.id}',
                      ),
                    );
                context.push('/literature/work/${work.id}');
              },
            ),
        ],
        if (matchingBooks.isNotEmpty) ...[
          _buildSectionHeader(
            AppTranslations.translate('books_search_result', lang, [
              AppTranslations.formatDigits(
                matchingBooks.length.toString(),
                lang,
              ),
            ]),
            colors,
          ),
          for (final book in matchingBooks)
            ListTile(
              leading: Icon(
                Icons.local_library_outlined,
                color: colors.primary,
              ),
              title: Text(
                BookDisplayText.title(book, lang),
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: Text(
                BookDisplayText.author(book, lang) ??
                    AppTranslations.get('books_title', lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
              trailing: const QalamChevron(size: 20),
              onTap: () => context.push('/books/${book.id}'),
            ),
        ],
        if (matchingProverbs.isNotEmpty) ...[
          _buildSectionHeader(
            AppTranslations.translate('search_proverbs_count', lang, [
              AppTranslations.formatDigits(
                matchingProverbs.length.toString(),
                lang,
              ),
            ]),
            colors,
          ),
          for (final proverb in matchingProverbs)
            ListTile(
              leading: Icon(Icons.menu_book_outlined, color: colors.primary),
              title: Text(
                isPersian
                    ? (proverb.persianText.isNotEmpty
                          ? proverb.persianText
                          : proverb.tajikCyrillic)
                    : proverb.tajikCyrillic,
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: Text(
                isPersian
                    ? '${AppTranslations.get('reading_tajik_explanation', lang)}: ${proverb.meaningTj}'
                    : proverb.meaningTj,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
              trailing: const QalamChevron(size: 20),
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: proverb.id,
                        type: RecentActivityType.proverb,
                        title: isPersian
                            ? (proverb.persianText.isNotEmpty
                                  ? proverb.persianText
                                  : proverb.tajikCyrillic)
                            : proverb.tajikCyrillic,
                        subtitle: AppTranslations.get(
                          'search_kind_proverb',
                          lang,
                        ),
                        titleTajik: proverb.tajikCyrillic,
                        titlePersian: proverb.persianText.isNotEmpty
                            ? proverb.persianText
                            : null,
                        subtitleTajik: AppTranslations.get(
                          'search_kind_proverb',
                          DisplayLanguage.tajik,
                        ),
                        subtitlePersian: AppTranslations.get(
                          'search_kind_proverb',
                          DisplayLanguage.persian,
                        ),
                        timestamp: DateTime.now(),
                        route: '/proverb/${proverb.id}',
                      ),
                    );
                context.push('/proverb/${proverb.id}');
              },
            ),
        ],
        if (matchingHistory.isNotEmpty) ...[
          _buildSectionHeader(
            AppTranslations.translate('search_history_count', lang, [
              AppTranslations.formatDigits(
                matchingHistory.length.toString(),
                lang,
              ),
            ]),
            colors,
          ),
          for (final entry in matchingHistory)
            ListTile(
              leading: Icon(Icons.timeline, color: colors.primary),
              title: Text(
                historyTitle(entry),
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: historyDate(entry).isEmpty
                  ? null
                  : Text(
                      historyDate(entry),
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
              trailing: const QalamChevron(size: 20),
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: entry.id,
                        type: RecentActivityType.history,
                        title: historyTitle(entry),
                        subtitle: AppTranslations.get(
                          'search_kind_history',
                          lang,
                        ),
                        titleTajik: entry.title,
                        titlePersian: entry.titlePersian,
                        subtitleTajik: AppTranslations.get(
                          'search_kind_history',
                          DisplayLanguage.tajik,
                        ),
                        subtitlePersian: AppTranslations.get(
                          'search_kind_history',
                          DisplayLanguage.persian,
                        ),
                        timestamp: DateTime.now(),
                        route: '/history/${entry.id}',
                      ),
                    );
                context.push('/history/${entry.id}');
              },
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(title, style: QalamTypography.eyebrow(color: colors.primary)),
    );
  }
}
