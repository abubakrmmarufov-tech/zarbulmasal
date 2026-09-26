import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';
import 'history_source_launcher.dart';
import '../../../core/utils/search_field_limits.dart';

part 'history_screen_widgets.dart';

String? _historyOptionalText(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

String _historyRequiredTitle(
  String sourceTitle,
  String? persianTitle,
  DisplayLanguage language,
) {
  if (language != DisplayLanguage.persian) return sourceTitle;
  return _historyOptionalText(persianTitle) ??
      AppTranslations.get('hist_translation_pending', language);
}

String _historyBookDetails(HistoryBook book, DisplayLanguage language) {
  final author = _historyOptionalText(
    language == DisplayLanguage.persian ? book.authorPersian : book.author,
  );
  final year = book.year.trim();
  return [
    ?author,
    if (year.isNotEmpty) AppTranslations.formatDigits(year, language),
  ].join(' · ');
}

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

enum HistoryViewMode { timeline, canon, topics }

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _searchOpen = false;
  HistoryViewMode _viewMode = HistoryViewMode.timeline;
  String? _grade;
  HistoryEntryKind? _kind;
  HistoryEpoch? _epoch;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final booksAsync = ref.watch(historyBooksProvider);
    final entriesAsync = ref.watch(historyEntriesProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: AppTranslations.get('back', lang),
                      icon: const BackButtonIcon(),
                      onPressed: () => qalamBack(context),
                    ),
                    const Spacer(),
                    // Search is folded behind an icon so the entries come
                    // first; an active query keeps the field open.
                    IconButton(
                      tooltip: AppTranslations.get('hist_search_hint', lang),
                      isSelected: _searchOpen,
                      icon: const Icon(Icons.search),
                      onPressed: () => setState(() {
                        _searchOpen = !_searchOpen || _query.isNotEmpty;
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: AppTranslations.get('hist_header_eyebrow', lang),
                title: AppTranslations.get('hist_title_main', lang),
                subtitle: AppTranslations.get('hist_header_subtitle', lang),
              ),
            ),
            if (_searchOpen || _query.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: TextField(
                    autofocus: _query.isEmpty,
                    controller: _searchController,
                    inputFormatters: searchQueryFormatters,
                    onChanged: (value) => setState(() => _query = value),
                    decoration: InputDecoration(
                      labelText: AppTranslations.get('hist_search_hint', lang),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: AppTranslations.get('btn_clear', lang),
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            ),
                    ),
                  ),
                ),
              ),
            // The textbook shelf belongs to the «By textbook» view.
            if (_viewMode == HistoryViewMode.canon)
              booksAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: LinearProgressIndicator(minHeight: 2),
                ),
                error: (_, _) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppTranslations.getForIsPersian(
                            isPersian,
                            'hist_books_unavailable',
                          ),
                          style: QalamTypography.meta(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => ref.invalidate(historyBooksProvider),
                          icon: const Icon(Icons.refresh, size: 17),
                          label: Text(
                            AppTranslations.getForIsPersian(
                              isPersian,
                              'btn_retry',
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: QalamSpacing.iconLabelGap,
                            ),
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                data: (books) => SliverToBoxAdapter(
                  child: _BookStrip(
                    books: books,
                    isPersian: isPersian,
                    onBookSelected: (book) => _showHistoryBookDetails(
                      context,
                      book,
                      isPersian,
                      onGradeSelected: (grade) => setState(() {
                        _viewMode = HistoryViewMode.canon;
                        _grade = grade;
                        _epoch = null;
                        _kind = null;
                      }),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: _FilterBar(
                viewMode: _viewMode,
                selectedGrade: _grade,
                selectedKind: _kind,
                selectedEpoch: _epoch,
                isPersian: isPersian,
                onViewModeChanged: (mode) => setState(() {
                  _viewMode = mode;
                  if (mode == HistoryViewMode.timeline) {
                    _grade = null;
                    _kind = null;
                  } else if (mode == HistoryViewMode.canon) {
                    _epoch = null;
                    _kind = null;
                  } else if (mode == HistoryViewMode.topics) {
                    _epoch = null;
                    _grade = null;
                  }
                }),
                onGradeChanged: (value) => setState(() => _grade = value),
                onKindChanged: (value) => setState(() => _kind = value),
                onEpochChanged: (value) => setState(() => _epoch = value),
              ),
            ),
            entriesAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: AppTranslations.getForIsPersian(
                    isPersian,
                    'hist_load_error_title',
                  ),
                  subtitle: AppTranslations.getForIsPersian(
                    isPersian,
                    'hist_load_error_body',
                  ),
                  action: OutlinedButton(
                    onPressed: () => ref.invalidate(historyEntriesProvider),
                    child: Text(
                      AppTranslations.getForIsPersian(isPersian, 'btn_retry'),
                    ),
                  ),
                ),
              ),
              data: (entries) {
                final selectedGradeHasNoCatalog =
                    _grade != null &&
                    entries.every((entry) => entry.grade != _grade);
                if (selectedGradeHasNoCatalog) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.info_outline,
                      title: AppTranslations.getForIsPersian(
                        isPersian,
                        'hist_grade_no_catalog_title',
                        [_grade ?? '8'],
                      ),
                      subtitle: AppTranslations.getForIsPersian(
                        isPersian,
                        'hist_grade_no_catalog_body',
                      ),
                    ),
                  );
                }
                final filtered = ref
                    .read(historyRepositoryProvider)
                    .search(
                      entries,
                      _query,
                      grade: _grade,
                      kind: _kind,
                      epoch: _epoch,
                    );
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: AppTranslations.getForIsPersian(
                        isPersian,
                        'hist_no_results_title',
                      ),
                      subtitle: AppTranslations.getForIsPersian(
                        isPersian,
                        'hist_no_results_body',
                      ),
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _HistoryRow(
                      entry: item,
                      isPersian: isPersian,
                      onTap: () => context.push('/history/${item.id}'),
                    );
                  },
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 48)),
          ],
        ),
      ),
    );
  }
}

class _BookStrip extends StatelessWidget {
  final List<HistoryBook> books;
  final bool isPersian;
  final ValueChanged<HistoryBook> onBookSelected;

  const _BookStrip({
    required this.books,
    required this.isPersian,
    required this.onBookSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;
    return SizedBox(
      height: 188,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final book = books[index];
          final author = _historyOptionalText(
            isPersian ? book.authorPersian : book.author,
          );
          final year = book.year.trim();
          final details = [
            ?author,
            if (year.isNotEmpty) AppTranslations.formatDigits(year, lang),
          ].join(' · ');
          final radius = BorderRadius.circular(QalamSpacing.cardRadius);
          return Material(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.6),
                width: 0.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onBookSelected(book),
              child: Container(
                width: 190,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppTranslations.getForIsPersian(
                              isPersian,
                              'hist_filter_grade',
                              [book.grade],
                            ),
                            style: QalamTypography.eyebrow(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: colors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Directionality(
                        textDirection: isPersian
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          _historyRequiredTitle(
                            book.title,
                            book.titlePersian,
                            lang,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: QalamTypography.sectionTitle(
                            color: colors.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    if (details.isNotEmpty)
                      Directionality(
                        textDirection: isPersian
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        child: Text(
                          details,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
