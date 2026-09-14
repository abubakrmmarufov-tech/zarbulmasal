import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _grade;
  HistoryEntryKind? _kind;

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
                child: _BookStrip(books: books, isPersian: isPersian),
              ),
            ),
            SliverToBoxAdapter(
              child: _FilterBar(
                selectedGrade: _grade,
                selectedKind: _kind,
                isPersian: isPersian,
                onGradeChanged: (value) => setState(() => _grade = value),
                onKindChanged: (value) => setState(() => _kind = value),
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
                final filtered = ref
                    .read(historyRepositoryProvider)
                    .search(entries, _query, grade: _grade, kind: _kind);
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
                  itemBuilder: (context, index) => _HistoryCard(
                    entry: filtered[index],
                    sourceBook: booksById[filtered[index].sourceBookId],
                    isPersian: isPersian,
                  ),
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

  const _BookStrip({required this.books, required this.isPersian});

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
              onTap: () =>
                  _openHistorySource(context, book.sourceUrl, isPersian),
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
                                ? 'صنف ${book.grade}'
                                : 'Синфи ${book.grade}',
                            style: QalamTypography.eyebrow(
                              color: colors.primary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: isPersian ? 'مشاهدهٔ منبع' : 'Дидани манбаъ',
                          icon: const Icon(Icons.open_in_new, size: 18),
                          onPressed: () => _openHistorySource(
                            context,
                            book.sourceUrl,
                            isPersian,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          book.title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: QalamTypography.sectionTitle(
                            color: colors.onSurface,
                            fontSize: 16,
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
  final String? selectedGrade;
  final HistoryEntryKind? selectedKind;
  final bool isPersian;
  final ValueChanged<String?> onGradeChanged;
  final ValueChanged<HistoryEntryKind?> onKindChanged;

  const _FilterBar({
    required this.selectedGrade,
    required this.selectedKind,
    required this.isPersian,
    required this.onGradeChanged,
    required this.onKindChanged,
  });

  @override
  Widget build(BuildContext context) {
    final grades = ['5', '6', '7', '8', '9', '10', '11'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      child: Row(
        children: [
          ChoiceChip(
            label: Text(isPersian ? 'همه' : 'Ҳама'),
            selected: selectedGrade == null && selectedKind == null,
            onSelected: (_) {
              onGradeChanged(null);
              onKindChanged(null);
            },
          ),
          const SizedBox(width: 8),
          ...grades.map(
            (grade) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                label: Text(isPersian ? 'صنف $grade' : 'Синфи $grade'),
                selected: selectedGrade == grade,
                onSelected: (selected) =>
                    onGradeChanged(selected ? grade : null),
              ),
            ),
          ),
          ChoiceChip(
            label: Text(isPersian ? 'شاعران' : 'Шоирон'),
            selected: selectedKind == HistoryEntryKind.poem,
            onSelected: (selected) =>
                onKindChanged(selected ? HistoryEntryKind.poem : null),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryEntry entry;
  final HistoryBook? sourceBook;
  final bool isPersian;

  const _HistoryCard({
    required this.entry,
    required this.sourceBook,
    required this.isPersian,
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
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
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
              Text(
                isPersian ? 'صنف ${entry.grade}' : 'Синфи ${entry.grade}',
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: isPersian && entry.titlePersian != null
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Text(
              title,
              style: QalamTypography.sectionTitle(
                color: colors.onSurface,
                fontSize: 19,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Directionality(
            textDirection: isPersian && entry.summaryPersian != null
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Text(
              summary,
              style: QalamTypography.bodySecondary(
                color: colors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${entry.period} · ${entry.sourceSection}',
              style: QalamTypography.meta(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.menu_book_outlined, size: 14, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  isPersian
                      ? 'سند: کتاب تاریخ صنف ${entry.grade}'
                      : 'Сарчашма: китоби таърихи синфи ${entry.grade}',
                  style: QalamTypography.meta(color: colors.onSurfaceVariant),
                ),
              ),
            ],
          ),
          if (sourceBook?.sourceUrl.isNotEmpty ?? false) ...[
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _openHistorySource(
                  context,
                  sourceBook!.sourceUrl,
                  isPersian,
                ),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(
                  isPersian ? 'مشاهدهٔ منبع اصلی' : 'Дидани манбаи аслӣ',
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(48, 44),
                ),
              ),
            ),
          ],
        ],
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
        HistoryEntryKind.person => 'شخصیت',
        HistoryEntryKind.event => 'رویداد',
        HistoryEntryKind.place => 'جایگاه',
        HistoryEntryKind.poem => 'شاعر و شعر',
        HistoryEntryKind.oral => 'روایت شفاهی',
      };
    }
    return switch (kind) {
      HistoryEntryKind.empire => 'ДАВЛАТ ВА ИМПЕРИЯ',
      HistoryEntryKind.person => 'ШАХСИЯТ',
      HistoryEntryKind.event => 'ВОҚЕА',
      HistoryEntryKind.place => 'ҶОЙ',
      HistoryEntryKind.poem => 'ШОИР ВА ШЕЪР',
      HistoryEntryKind.oral => 'РИВОЯТИ ШИФОҲӢ',
    };
  }
}

Future<void> _openHistorySource(
  BuildContext context,
  String sourceUrl,
  bool isPersian,
) async {
  final uri = Uri.tryParse(sourceUrl);
  if (uri == null || uri.scheme != 'https' || uri.host != 'marifat.tj') {
    _showHistorySourceError(context, isPersian);
    return;
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _showHistorySourceError(context, isPersian);
  }
}

void _showHistorySourceError(BuildContext context, bool isPersian) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        isPersian ? 'منبع در حال حاضر باز نشد.' : 'Манбаъ ҳоло кушода нашуд.',
      ),
    ),
  );
}
