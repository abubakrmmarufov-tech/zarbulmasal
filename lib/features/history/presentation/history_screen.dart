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
                          isPersian
                              ? 'منابع کتاب‌ها فعلاً در دسترس نیستند.'
                              : 'Манбаъҳои китобҳо ҳоло дастрас нестанд.',
                          style: QalamTypography.meta(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => ref.invalidate(historyBooksProvider),
                          icon: const Icon(Icons.refresh, size: 17),
                          label: Text(
                            isPersian ? 'تلاش دوباره' : 'Дубора кӯшиш кардан',
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  title: isPersian
                      ? 'خطا در بارگیری تاریخ'
                      : 'Хато ҳангоми боргирии таърих',
                  subtitle: isPersian
                      ? 'فهرست محلی بارگیری نشد. بعداً دوباره تلاش کنید.'
                      : 'Феҳристи маҳаллӣ бор нашуд. Баъдтар дубора кӯшиш кунед.',
                  action: OutlinedButton(
                    onPressed: () => ref.invalidate(historyEntriesProvider),
                    child: Text(
                      isPersian ? 'تلاش دوباره' : 'Дубора кӯшиш кардан',
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
                      title: isPersian
                          ? 'فهرست تفصیلی صنف ${AppTranslations.formatDigits(_grade ?? '8', DisplayLanguage.persian)} فعلاً در دسترس نیست'
                          : 'Барои синфи ${_grade ?? '8'} феҳристи муфассал ҳоло дастрас нест',
                      subtitle: isPersian
                          ? 'کتاب منبع نگه‌داری شده است، اما جزئیات فصل‌ها برای ساختن کارت‌های قابل اعتماد کافی نیست.'
                          : 'Китоби манбаъ нигоҳ дошта шудааст, аммо тафсилоти фаслҳо барои сохтани кортҳои боэътимод кофӣ нест.',
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
                      title: isPersian
                          ? 'چیزی پیدا نشد'
                          : 'Мундариҷа ёфт нашуд',
                      subtitle: isPersian
                          ? 'فیلتر یا عبارت جست‌وجو را تغییر دهید.'
                          : 'Филтр ё ибораи ҷустуҷӯро тағйир диҳед.',
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
                            isPersian
                                ? 'صنف ${AppTranslations.formatDigits(book.grade, DisplayLanguage.persian)}'
                                : 'Синфи ${book.grade}',
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

class _FilterBar extends StatelessWidget {
  final HistoryViewMode viewMode;
  final String? selectedGrade;
  final HistoryEntryKind? selectedKind;
  final HistoryEpoch? selectedEpoch;
  final bool isPersian;
  final ValueChanged<HistoryViewMode> onViewModeChanged;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<HistoryEntryKind?> onKindChanged;
  final ValueChanged<HistoryEpoch?> onEpochChanged;

  const _FilterBar({
    required this.viewMode,
    required this.selectedGrade,
    required this.selectedKind,
    required this.selectedEpoch,
    required this.isPersian,
    required this.onViewModeChanged,
    required this.onGradeChanged,
    required this.onKindChanged,
    required this.onEpochChanged,
  });

  @override
  Widget build(BuildContext context) {
    final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;
    final grades = ['5', '6', '7', '8', '9', '10', '11'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _ModeChip(
                  icon: Icons.timeline_outlined,
                  label: AppTranslations.get('hist_view_timeline', lang),
                  isSelected: viewMode == HistoryViewMode.timeline,
                  onTap: () => onViewModeChanged(HistoryViewMode.timeline),
                ),
                const SizedBox(width: 8),
                _ModeChip(
                  icon: Icons.school_outlined,
                  label: AppTranslations.get('hist_view_textbooks', lang),
                  isSelected: viewMode == HistoryViewMode.canon,
                  onTap: () => onViewModeChanged(HistoryViewMode.canon),
                ),
                const SizedBox(width: 8),
                _ModeChip(
                  icon: Icons.category_outlined,
                  label: AppTranslations.get('hist_view_topics_label', lang),
                  isSelected: viewMode == HistoryViewMode.topics,
                  onTap: () => onViewModeChanged(HistoryViewMode.topics),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 72,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
            child: Row(
              children: switch (viewMode) {
                HistoryViewMode.timeline => [
                  ChoiceChip(
                    label: Text(AppTranslations.get('hist_filter_all', lang)),
                    selected:
                        selectedEpoch == null &&
                        selectedGrade == null &&
                        selectedKind == null,
                    onSelected: (_) {
                      onEpochChanged(null);
                      onGradeChanged(null);
                      onKindChanged(null);
                    },
                  ),
                  ...HistoryEpoch.values.map(
                    (epoch) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: ChoiceChip(
                        label: Text(epoch.label(lang)),
                        selected: selectedEpoch == epoch,
                        onSelected: (selected) {
                          onEpochChanged(selected ? epoch : null);
                          if (selected) {
                            onGradeChanged(null);
                            onKindChanged(null);
                          }
                        },
                      ),
                    ),
                  ),
                  ...grades.map(
                    (grade) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: ChoiceChip(
                        label: Text(
                          AppTranslations.get('hist_filter_grade', lang, [
                            grade,
                          ]),
                        ),
                        selected: selectedGrade == grade,
                        onSelected: (selected) {
                          onGradeChanged(selected ? grade : null);
                          if (selected) {
                            onEpochChanged(null);
                            onKindChanged(null);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_states', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.empire,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.empire : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_figures', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.person,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.person : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.auto_stories_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_heritage', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.poem,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.poem : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.timeline_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_events', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.event,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.event : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.record_voice_over_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_narratives', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.oral,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.oral : null);
                      if (selected) {
                        onEpochChanged(null);
                        onGradeChanged(null);
                      }
                    },
                  ),
                ],
                HistoryViewMode.canon => [
                  ChoiceChip(
                    label: Text(AppTranslations.get('hist_filter_all', lang)),
                    selected: selectedGrade == null,
                    onSelected: (_) => onGradeChanged(null),
                  ),
                  ...grades.map(
                    (grade) => Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: ChoiceChip(
                        label: Text(
                          AppTranslations.get('hist_filter_grade', lang, [
                            grade,
                          ]),
                        ),
                        selected: selectedGrade == grade,
                        onSelected: (selected) =>
                            onGradeChanged(selected ? grade : null),
                      ),
                    ),
                  ),
                ],
                HistoryViewMode.topics => [
                  ChoiceChip(
                    label: Text(AppTranslations.get('hist_filter_all', lang)),
                    selected: selectedKind == null,
                    onSelected: (_) => onKindChanged(null),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.account_balance_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_states', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.empire,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.empire : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.person_outline, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_figures', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.person,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.person : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.auto_stories_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_heritage', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.poem,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.poem : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(Icons.timeline_outlined, size: 16),
                    label: Text(
                      AppTranslations.get('hist_filter_events', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.event,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.event : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    avatar: const Icon(
                      Icons.record_voice_over_outlined,
                      size: 16,
                    ),
                    label: Text(
                      AppTranslations.get('hist_filter_narratives', lang),
                    ),
                    selected: selectedKind == HistoryEntryKind.oral,
                    onSelected: (selected) {
                      onKindChanged(selected ? HistoryEntryKind.oral : null);
                    },
                  ),
                ],
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: isSelected ? colors.primary : colors.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? colors.onPrimary : colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? colors.onPrimary : colors.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A history entry as a typographic row: kind and grade, the title, its
/// dates and a one-line summary. Opens the entry page directly.
class _HistoryRow extends StatelessWidget {
  final HistoryEntry entry;
  final bool isPersian;
  final VoidCallback onTap;

  const _HistoryRow({
    required this.entry,
    required this.isPersian,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;
    final title = _historyRequiredTitle(entry.title, entry.titlePersian, lang);
    final summary = isPersian
        ? _historyOptionalText(entry.summaryPersian)
        : _historyOptionalText(entry.summary);
    final dates = isPersian
        ? _historyOptionalText(entry.datesPersian) ??
              _historyOptionalText(entry.periodPersian)
        : _historyOptionalText(entry.dates) ??
              _historyOptionalText(entry.period);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: QalamSpacing.pageH),
      child: QalamSlip(
        onTap: onTap,
        child: Directionality(
          textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_kindLabel(entry.kind, isPersian)} · '
                '${AppTranslations.get('hist_filter_grade', lang, [entry.grade])}',
                style: QalamTypography.meta(
                  color: colors.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: QalamTypography.literaryTitle(
                  color: colors.onSurface,
                  fontSize: 20,
                ),
              ),
              if (dates != null) ...[
                const SizedBox(height: 2),
                Text(
                  dates,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.meta(color: colors.primary),
                ),
              ],
              if (summary != null) ...[
                const SizedBox(height: 6),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _kindLabel(HistoryEntryKind kind, bool isPersian) {
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

void _showHistoryBookDetails(
  BuildContext context,
  HistoryBook book,
  bool isPersian, {
  required ValueChanged<String?> onGradeSelected,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final colors = Theme.of(context).colorScheme;
      final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;
      final details = _historyBookDetails(book, lang);
      final description = isPersian
          ? _historyOptionalText(book.descriptionPersian)
          : _historyOptionalText(book.description);
      return SafeArea(
        child: SingleChildScrollView(
          child: Directionality(
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book, size: 22, color: colors.primary),
                      const SizedBox(width: 8),
                      Text(
                        AppTranslations.get('hist_textbook_grade', lang, [
                          book.grade,
                        ]),
                        style: QalamTypography.eyebrow(color: colors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _historyRequiredTitle(book.title, book.titlePersian, lang),
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      details,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (description != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  if (book.externalSourceUri != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.open_in_browser),
                        label: Text(
                          (book.isUploadedBook || book.localPath != null)
                              ? AppTranslations.get(
                                  'hist_source_study_local',
                                  lang,
                                )
                              : AppTranslations.get('hist_source_study', lang),
                        ),
                        onPressed: () async {
                          final uri = book.externalSourceUri!;
                          await openHistorySource(context, uri, lang);
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: Text(
                        AppTranslations.get('hist_view_grade_topics', lang, [
                          book.grade,
                        ]),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onGradeSelected(book.grade);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
