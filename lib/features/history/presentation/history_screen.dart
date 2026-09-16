import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

enum HistoryViewMode { timeline, canon, topics }

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
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
    final booksById = {
      for (final book in booksAsync.valueOrNull ?? const <HistoryBook>[])
        book.id: book,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
                    icon: const BackButtonIcon(),
                    onPressed: () => qalamBack(context),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: isPersian
                    ? '۰۴ / تاریخ‌نامهٔ مکتبی'
                    : '04 / ТАЪРИХНОМАИ МАКТАБӢ',
                title: isPersian ? 'تاریخ مردم تاجیک' : 'Таърихи халқи тоҷик',
                subtitle: isPersian
                    ? 'پژوهشی کوتاه و منبع‌محور از کتاب‌های صنف‌های ۵ تا ۱۱'
                    : 'Тадқиқоти кӯтоҳи сарчашмабунёд аз китобҳои синфҳои 5–11',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    labelText: isPersian
                        ? 'جست‌وجو در نام‌ها و رویدادها'
                        : 'Ҷустуҷӯ дар номҳо ва воқеаҳо',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: isPersian ? 'پاک کردن' : 'Пок кардан',
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
            if (isPersian)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'متن‌های منبع فعلاً به خط سیریلیک تاجیکی نمایش داده می‌شوند.',
                          style: QalamTypography.meta(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
                          minimumSize: const Size(48, 40),
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
                    final sourceBook = booksById[item.sourceBookId];
                    return _HistoryCard(
                      entry: item,
                      sourceBook: sourceBook,
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
    return SizedBox(
      height: 188,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: books.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final book = books[index];
          final radius = BorderRadius.circular(12);
          return Material(
            color: colors.surfaceContainerHighest,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: () => onBookSelected(book),
              child: Container(
                width: 190,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  borderRadius: radius,
                  border: Border.all(color: colors.outlineVariant),
                ),
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
                        textDirection: TextDirection.ltr,
                        child: Text(
                          book.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: QalamTypography.sectionTitle(
                            color: colors.onSurface,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        book.year.isEmpty
                            ? book.author
                            : '${book.author} · ${book.year}',
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
                  label: isPersian ? 'گاه‌شمار' : 'Хатти замон',
                  isSelected: viewMode == HistoryViewMode.timeline,
                  onTap: () => onViewModeChanged(HistoryViewMode.timeline),
                ),
                const SizedBox(width: 8),
                _ModeChip(
                  icon: Icons.school_outlined,
                  label: isPersian ? 'کتاب‌های درسی' : 'Китобҳои дарсӣ',
                  isSelected: viewMode == HistoryViewMode.canon,
                  onTap: () => onViewModeChanged(HistoryViewMode.canon),
                ),
                const SizedBox(width: 8),
                _ModeChip(
                  icon: Icons.category_outlined,
                  label: isPersian ? 'موضوعات' : 'Мавзӯъҳо',
                  isSelected: viewMode == HistoryViewMode.topics,
                  onTap: () => onViewModeChanged(HistoryViewMode.topics),
                ),
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
          child: Row(
            children: switch (viewMode) {
              HistoryViewMode.timeline => [
                ChoiceChip(
                  label: Text(isPersian ? 'همه' : 'Ҳама'),
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
                      label: Text(
                        isPersian ? epoch.labelPersian : epoch.labelTajik,
                      ),
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
                        isPersian
                            ? 'صنف ${AppTranslations.formatDigits(grade, DisplayLanguage.persian)}'
                            : 'Синфи $grade',
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
                  avatar: const Icon(Icons.account_balance_outlined, size: 16),
                  label: Text(isPersian ? 'دولت‌ها' : 'Давлатҳо'),
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
                  label: Text(isPersian ? 'شخصیت‌ها' : 'Шахсиятҳо'),
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
                  label: Text(isPersian ? 'میراث ادبی' : 'Мероси адабӣ'),
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
                  label: Text(isPersian ? 'رویدادها' : 'Рӯйдодҳо'),
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
                  label: Text(isPersian ? 'روایت‌ها' : 'Ривоятҳо'),
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
                  label: Text(isPersian ? 'همه' : 'Ҳама'),
                  selected: selectedGrade == null,
                  onSelected: (_) => onGradeChanged(null),
                ),
                ...grades.map(
                  (grade) => Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: ChoiceChip(
                      label: Text(
                        isPersian
                            ? 'صنف ${AppTranslations.formatDigits(grade, DisplayLanguage.persian)}'
                            : 'Синфи $grade',
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
                  label: Text(isPersian ? 'همه' : 'Ҳама'),
                  selected: selectedKind == null,
                  onSelected: (_) => onKindChanged(null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.account_balance_outlined, size: 16),
                  label: Text(isPersian ? 'دولت‌ها' : 'Давлатҳо'),
                  selected: selectedKind == HistoryEntryKind.empire,
                  onSelected: (selected) {
                    onKindChanged(selected ? HistoryEntryKind.empire : null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.person_outline, size: 16),
                  label: Text(isPersian ? 'شخصیت‌ها' : 'Шахсиятҳо'),
                  selected: selectedKind == HistoryEntryKind.person,
                  onSelected: (selected) {
                    onKindChanged(selected ? HistoryEntryKind.person : null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.auto_stories_outlined, size: 16),
                  label: Text(isPersian ? 'میراث ادبی' : 'Мероси адабӣ'),
                  selected: selectedKind == HistoryEntryKind.poem,
                  onSelected: (selected) {
                    onKindChanged(selected ? HistoryEntryKind.poem : null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.timeline_outlined, size: 16),
                  label: Text(isPersian ? 'رویدادها' : 'Рӯйдодҳо'),
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
                  label: Text(isPersian ? 'روایت‌ها' : 'Ривоятҳо'),
                  selected: selectedKind == HistoryEntryKind.oral,
                  onSelected: (selected) {
                    onKindChanged(selected ? HistoryEntryKind.oral : null);
                  },
                ),
              ],
            },
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

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final HistoryBook? sourceBook;
  final bool isPersian;
  final VoidCallback onTap;

  const _HistoryCard({
    required this.entry,
    required this.sourceBook,
    required this.isPersian,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
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

    return Card(
      elevation: 0,
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_iconFor(entry.kind), size: 18, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _kindLabel(entry.kind, isPersian),
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isPersian
                          ? 'صنف ${AppTranslations.formatDigits(entry.grade, DisplayLanguage.persian)}'
                          : 'Синфи ${entry.grade}',
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: isPersian && entry.titlePersian != null
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Text(
                  title,
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 18,
                  ),
                ),
              ),
              if (dates.isNotEmpty) ...[
                const SizedBox(height: 4),
                Directionality(
                  textDirection: isPersian
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  child: Text(
                    dates,
                    style: QalamTypography.meta(color: colors.primary),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Directionality(
                textDirection: isPersian && entry.summaryPersian != null
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                child: Text(
                  summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              if (capital != null && capital.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_city_outlined,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isPersian ? 'پایتخت: $capital' : 'Пойтахт: $capital',
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 14,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            isPersian
                                ? 'کتاب تاریخ صنف ${AppTranslations.formatDigits(entry.grade, DisplayLanguage.persian)}'
                                : 'Китоби таърихи синфи ${entry.grade}',
                            style: QalamTypography.meta(
                              color: colors.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isPersian ? 'جزئیات ←' : 'Тафсилот →',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(HistoryEntryKind kind) => switch (kind) {
    HistoryEntryKind.empire => Icons.account_balance_outlined,
    HistoryEntryKind.person => Icons.person_outline,
    HistoryEntryKind.event => Icons.timeline_outlined,
    HistoryEntryKind.place => Icons.place_outlined,
    HistoryEntryKind.poem => Icons.auto_stories_outlined,
    HistoryEntryKind.oral => Icons.record_voice_over_outlined,
  };

  static String _kindLabel(HistoryEntryKind kind, bool isPersian) {
    if (isPersian) {
      return switch (kind) {
        HistoryEntryKind.empire => 'دولت و امپراتوری',
        HistoryEntryKind.person => 'شخصیت تاریخی',
        HistoryEntryKind.event => 'رویداد تاریخی',
        HistoryEntryKind.place => 'جایگاه تاریخی',
        HistoryEntryKind.poem => 'شاعر و شعر',
        HistoryEntryKind.oral => 'روایت شفاهی',
      };
    }
    return switch (kind) {
      HistoryEntryKind.empire => 'ДАВЛАТ ВА ИМПЕРИЯ',
      HistoryEntryKind.person => 'ШАХСИЯТИ ТАЪРИХӢ',
      HistoryEntryKind.event => 'ВОҚЕАИ ТАЪРИХӢ',
      HistoryEntryKind.place => 'ҶОЙИ ТАЪРИХӢ',
      HistoryEntryKind.poem => 'ШОИР ВА ШЕЪР',
      HistoryEntryKind.oral => 'РИВОЯТИ ШИФОҲӢ',
    };
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
                        isPersian
                            ? 'کتاب درسی صنف ${AppTranslations.formatDigits(book.grade, DisplayLanguage.persian)}'
                            : 'Китоби дарсии синфи ${book.grade}',
                        style: QalamTypography.eyebrow(color: colors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    book.title,
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.year.isEmpty
                        ? book.author
                        : '${book.author} · ${book.year}',
                    style: QalamTypography.meta(color: colors.onSurfaceVariant),
                  ),
                  if (book.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      book.description,
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.filter_list),
                      label: Text(
                        isPersian
                            ? 'مشاهدهٔ موضوع‌های صنف ${AppTranslations.formatDigits(book.grade, DisplayLanguage.persian)}'
                            : 'Дидани мавзӯъҳои синфи ${book.grade}',
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
