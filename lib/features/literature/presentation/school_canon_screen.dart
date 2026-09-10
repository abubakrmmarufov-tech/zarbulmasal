import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_author.dart';
import '../domain/school_canon_entry.dart';

/// A screen presenting the official Tajik school curriculum literary canon,
/// organized by grade level (grades 4–11) with approved textbook citations.
class SchoolCanonScreen extends ConsumerStatefulWidget {
  const SchoolCanonScreen({super.key});

  @override
  ConsumerState<SchoolCanonScreen> createState() => _SchoolCanonScreenState();
}

class _SchoolCanonScreenState extends ConsumerState<SchoolCanonScreen> {
  String? _selectedGrade;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final canonAsync = ref.watch(schoolCanonProvider);
    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final authorsMap = <String, LiteraryAuthor>{
      for (final a in (authorsAsync.valueOrNull ?? <LiteraryAuthor>[])) a.id: a,
    };

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top back button
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
            // Header
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: isPersian ? '۰۳ / برنامهٔ مکتبی' : '03 / БАРНОМАИ МАКТАБӢ',
                title: AppTranslations.get('lit_school', lang),
                subtitle: isPersian
                    ? 'آثار و شاعران مصوب برنامهٔ درسی وزارت معارف برای صنف‌های ۴ تا ۱۱'
                    : 'Осор ва шоирони барномаи таълимии Вазорати маориф ва илми ҶТ барои синфҳои 4–11',
              ),
            ),
            // Content
            canonAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: isPersian
                        ? 'خطا در بارگیری برنامهٔ درسی'
                        : 'Хато ҳангоми боргирии барнома',
                    subtitle: err.toString(),
                  ),
                ),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.school_outlined,
                        title: isPersian
                            ? 'برنامهٔ درسی خالی است'
                            : 'Барномаи таълимӣ ёфт нашуд',
                      ),
                    ),
                  );
                }

                // Extract all unique grades and sort them
                final grades = entries.map((e) => e.grade).toSet().toList()
                  ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

                final filteredEntries = _selectedGrade == null
                    ? entries
                    : entries.where((e) => e.grade == _selectedGrade).toList();

                // Group entries by grade
                final grouped = <String, List<SchoolCanonEntry>>{};
                for (final entry in filteredEntries) {
                  grouped.putIfAbsent(entry.grade, () => []).add(entry);
                }
                final sortedGrades = grouped.keys.toList()
                  ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

                return SliverMainAxisGroup(
                  slivers: [
                    // Grade filter chips
                    SliverToBoxAdapter(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: Text(isPersian ? 'همهٔ صنف‌ها' : 'Ҳамаи синфҳо'),
                              selected: _selectedGrade == null,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() => _selectedGrade = null);
                                }
                              },
                            ),
                            const SizedBox(width: 8),
                            for (final grade in grades) ...[
                              ChoiceChip(
                                label: Text(
                                  isPersian ? 'صنف $grade' : 'Синфи $grade',
                                ),
                                selected: _selectedGrade == grade,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedGrade = selected ? grade : null;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    // Grouped Sections
                    for (final grade in sortedGrades) ...[
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                          padding: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: colors.primary,
                                width: 1.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(
                                isPersian ? 'صنف $grade' : 'СИНФИ $grade',
                                style: QalamTypography.eyebrow(
                                  color: colors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${grouped[grade]!.length} ${isPersian ? "اثر/مؤلف" : "мавзӯъ"}',
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final entry = grouped[grade]![index];
                            final author = authorsMap[entry.authorId];
                            return _CanonEntryCard(
                              entry: entry,
                              author: author,
                              isPersian: isPersian,
                            );
                          },
                          childCount: grouped[grade]!.length,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),
          ],
        ),
      ),
    );
  }
}

class _CanonEntryCard extends StatelessWidget {
  final SchoolCanonEntry entry;
  final LiteraryAuthor? author;
  final bool isPersian;

  const _CanonEntryCard({
    required this.entry,
    required this.author,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final authorName = author != null
        ? ((isPersian && author!.canonicalNamePersian != null)
            ? author!.canonicalNamePersian!
            : author!.canonicalName)
        : entry.authorId;

    final isMandatory = entry.isMandatory;

    return InkWell(
      onTap: () {
        if (entry.workId.isNotEmpty) {
          context.push('/literature/work/${entry.workId}');
        } else if (entry.authorId.isNotEmpty) {
          context.push('/literature/poet/${entry.authorId}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject & Mandatory tag row
            Row(
              children: [
                Text(
                  entry.subject,
                  style: QalamTypography.meta(
                    color: colors.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isMandatory
                        ? QalamColors.forest.withOpacity(0.1)
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    isMandatory
                        ? (isPersian ? 'حتماً' : 'Ҳатмӣ')
                        : (isPersian ? 'توصیه‌شده' : 'Тавсияшаванда'),
                    style: QalamTypography.meta(
                      color: isMandatory ? QalamColors.forest : colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            // Author Name
            Text(
              authorName,
              style: QalamTypography.sectionTitle(
                color: colors.onSurface,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            // Textbook details
            Row(
              children: [
                Icon(
                  Icons.menu_book,
                  size: 14,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${entry.textbookTitle} (${entry.textbookYear}) — ${entry.textbookPublisher}',
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            if (entry.textbookAuthors.isNotEmpty) ...[
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '${isPersian ? "مؤلفان کتاب:" : "Муаллифони китоб:"} ${entry.textbookAuthors}',
                  style: QalamTypography.meta(
                    color: colors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
