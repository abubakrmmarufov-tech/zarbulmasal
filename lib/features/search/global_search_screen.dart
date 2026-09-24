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
import '../../shared/widgets/recent_activity_display_text.dart';
import '../history/data/history_providers.dart';
import '../history/domain/history_domain.dart';
import '../literature/data/literature_providers.dart';
import '../literature/domain/domain.dart';
import '../literature/presentation/literary_author_display_text.dart';
import '../literature/presentation/literary_work_display_text.dart';
import '../books/data/books_providers.dart';
import '../books/domain/book_domain.dart';
import '../books/presentation/book_display_text.dart';
import '../../core/utils/search_field_limits.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  String _rawQuery = '';

  /// Result groups the reader has opened in full.
  final Set<String> _expanded = {};

  /// Rows shown per group before "show all".
  static const int _groupPreview = 5;

  /// Recently opened texts offered while the query is empty.
  static const int _maxRecent = 6;

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
          inputFormatters: searchQueryFormatters,
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
              _expanded.clear();
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
    final colors = Theme.of(context).colorScheme;
    final recent = ref
        .watch(recentActivityProvider)
        .take(_maxRecent)
        .toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      children: [
        Text(
          AppTranslations.get('search_empty_prompt_title', lang),
          style: QalamTypography.sectionTitle(color: colors.onSurface),
        ),
        const SizedBox(height: 8),
        Text(
          AppTranslations.get('search_empty_prompt_sub', lang),
          style: QalamTypography.bodySecondary(color: colors.onSurfaceVariant),
        ),
        if (recent.isNotEmpty) ...[
          const SizedBox(height: 32),
          Text(
            AppTranslations.get('recent_activity', lang).toUpperCase(),
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
          for (final activity in recent)
            QalamIndexRow(
              title: RecentActivityDisplayText.title(activity, lang),
              subtitle: RecentActivityDisplayText.subtitle(activity, lang),
              onTap: () => context.push(activity.route),
            ),
        ],
      ],
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
        child: SingleChildScrollView(
          child: EmptyState(
            icon: Icons.search_off,
            title: AppTranslations.get('lit_no_results', lang),
            subtitle:
                '${AppTranslations.translate('search_no_results_for', lang, [_rawQuery.trim().isNotEmpty ? _rawQuery.trim() : _query])}\n\n'
                '${AppTranslations.get('search_no_results_tip', lang)}',
            action: OutlinedButton(
              onPressed: () => context.go('/explore'),
              child: Text(AppTranslations.get('search_browse_index', lang)),
            ),
          ),
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;
    String count(String key, int value) => AppTranslations.translate(
      key,
      lang,
      [AppTranslations.formatDigits(value.toString(), lang)],
    );
    String? lifeLine(LiteraryAuthor author) {
      final lifespan = author.hasAuditableBiographySource
          ? LiteraryAuthorDisplayText.lifespan(author, lang)
          : '';
      final period = LiteraryAuthorDisplayText.period(author, lang);
      final line = lifespan.isNotEmpty ? lifespan : period;
      return line.isEmpty ? null : line;
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        ..._group(
          id: 'poets',
          header: count('search_poets_count', matchingAuthors.length),
          lang: lang,
          colors: colors,
          rows: [
            for (final author in matchingAuthors)
              _SearchRow(
                title: LiteraryAuthorDisplayText.name(author, lang),
                subtitle: lifeLine(author),
                query: _rawQuery,
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
        ),
        ..._group(
          id: 'works',
          header: count('search_works_count', matchingWorks.length),
          lang: lang,
          colors: colors,
          rows: [
            for (final work in matchingWorks)
              _SearchRow(
                title: LiteraryWorkDisplayText.title(work, lang),
                subtitle: isPersian && work.titlePersianSource == 'generated'
                    ? AppTranslations.get('lit_generated_script_label', lang)
                    : LiteraryWorkDisplayText.distinctIncipit(work, lang),
                query: _rawQuery,
                onTap: () {
                  ref
                      .read(recentActivityProvider.notifier)
                      .addActivity(
                        RecentActivity(
                          id: work.id,
                          type: RecentActivityType.work,
                          title: LiteraryWorkDisplayText.title(work, lang),
                          subtitle: AppTranslations.get(
                            'search_kind_poem',
                            lang,
                          ),
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
        ),
        ..._group(
          id: 'books',
          header: count('books_search_result', matchingBooks.length),
          lang: lang,
          colors: colors,
          rows: [
            for (final book in matchingBooks)
              _SearchRow(
                title: BookDisplayText.title(book, lang),
                subtitle:
                    BookDisplayText.author(book, lang) ??
                    AppTranslations.get('books_title', lang),
                query: _rawQuery,
                onTap: () => context.push('/books/${book.id}'),
              ),
          ],
        ),
        ..._group(
          id: 'proverbs',
          header: count('search_proverbs_count', matchingProverbs.length),
          lang: lang,
          colors: colors,
          rows: [
            for (final proverb in matchingProverbs)
              _SearchRow(
                title: isPersian
                    ? (proverb.persianText.isNotEmpty
                          ? proverb.persianText
                          : proverb.tajikCyrillic)
                    : proverb.tajikCyrillic,
                subtitle: isPersian
                    ? '${AppTranslations.get('reading_tajik_explanation', lang)}: ${proverb.meaningTj}'
                    : proverb.meaningTj,
                query: _rawQuery,
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
        ),
        ..._group(
          id: 'history',
          header: count('search_history_count', matchingHistory.length),
          lang: lang,
          colors: colors,
          rows: [
            for (final entry in matchingHistory)
              _SearchRow(
                title: historyTitle(entry),
                subtitle: historyDate(entry).isEmpty
                    ? null
                    : historyDate(entry),
                query: _rawQuery,
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
        ),
      ],
    );
  }

  /// One result group: a header with its count, the first [_groupPreview]
  /// rows, and "show all" when there are more.
  List<Widget> _group({
    required String id,
    required String header,
    required List<Widget> rows,
    required DisplayLanguage lang,
    required ColorScheme colors,
  }) {
    if (rows.isEmpty) return const [];
    final expanded = _expanded.contains(id) || rows.length <= _groupPreview;
    return [
      _buildSectionHeader(header, colors),
      ...(expanded ? rows : rows.take(_groupPreview)),
      if (!expanded)
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, bottom: 8),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: () => setState(() => _expanded.add(id)),
              child: Text(
                AppTranslations.get('search_show_all', lang, [
                  AppTranslations.formatDigits(rows.length.toString(), lang),
                ]),
              ),
            ),
          ),
        ),
    ];
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(title, style: QalamTypography.eyebrow(color: colors.primary)),
    );
  }
}

/// A search result as a typographic row: the title with the matched part
/// set bold, and one line of context.
class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.title,
    required this.query,
    required this.onTap,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final String query;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final style = QalamTypography.literaryTitle(
      color: colors.onSurface,
      fontSize: 18,
    );
    final range = SearchNormalizer.matchRange(title, query);
    final titleText = range == null
        ? Text(title, style: style)
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(text: title.substring(0, range.start)),
                TextSpan(
                  text: title.substring(range.start, range.end),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                  ),
                ),
                TextSpan(text: title.substring(range.end)),
              ],
            ),
            style: style,
          );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: QalamSlip(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleText,
            if (subtitle != null && subtitle!.isNotEmpty)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }
}
