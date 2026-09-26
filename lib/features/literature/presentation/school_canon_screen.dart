import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/l10n/source_citation.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_author.dart';
import '../domain/school_canon_entry.dart';
import 'literary_author_display_text.dart';

/// A screen presenting the official Tajik school curriculum literary canon,
/// organized by grade level (grades 4–11) with approved textbook citations.
class SchoolCanonScreen extends ConsumerStatefulWidget {
  /// Grade to open on (the Home grade lens links here with `?grade=`).
  final String? initialGrade;

  const SchoolCanonScreen({super.key, this.initialGrade});

  @override
  ConsumerState<SchoolCanonScreen> createState() => _SchoolCanonScreenState();
}

class _SchoolCanonScreenState extends ConsumerState<SchoolCanonScreen> {
  late String? _selectedGrade = widget.initialGrade;

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
                    tooltip: AppTranslations.get('back', lang),
                    icon: const BackButtonIcon(),
                    onPressed: () => qalamBack(context),
                  ),
                ),
              ),
            ),
            // Header
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: AppTranslations.get('lit_canon_eyebrow', lang),
                title: AppTranslations.get('lit_school', lang),
                subtitle: AppTranslations.get('lit_canon_subtitle', lang),
              ),
            ),
            // Content
            canonAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: AppTranslations.get('lit_canon_error_title', lang),
                    subtitle: AppTranslations.get('lit_canon_error_sub', lang),
                    action: OutlinedButton(
                      onPressed: () => ref.invalidate(schoolCanonProvider),
                      child: Text(AppTranslations.get('btn_retry', lang)),
                    ),
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
                        title: AppTranslations.get(
                          'lit_canon_empty_title',
                          lang,
                        ),
                      ),
                    ),
                  );
                }

                // Extract all unique grades and sort them
                final grades = entries.map((e) => e.grade).toSet().toList()
                  ..sort(
                    (a, b) =>
                        (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
                  );

                // An unknown grade from a link falls back to all grades.
                final activeGrade = grades.contains(_selectedGrade)
                    ? _selectedGrade
                    : null;
                final filteredEntries = activeGrade == null
                    ? entries
                    : entries.where((e) => e.grade == activeGrade).toList();

                // Group entries by grade
                final grouped = <String, List<SchoolCanonEntry>>{};
                for (final entry in filteredEntries) {
                  grouped.putIfAbsent(entry.grade, () => []).add(entry);
                }
                final sortedGrades = grouped.keys.toList()
                  ..sort(
                    (a, b) =>
                        (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0),
                  );

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
                              label: Text(
                                AppTranslations.get(
                                  'lit_filter_all_grades',
                                  lang,
                                ),
                              ),
                              selected: activeGrade == null,
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
                                  AppTranslations.get('lit_grade', lang, [
                                    grade,
                                  ]),
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
                                AppTranslations.get('lit_grade', lang, [
                                  grade,
                                ]).toUpperCase(),
                                style: QalamTypography.eyebrow(
                                  color: colors.primary,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${AppTranslations.formatNumber(grouped[grade]!.length, lang)} ${AppTranslations.get('lit_works_unit', lang)}',
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final entry = grouped[grade]![index];
                          final author = authorsMap[entry.authorId];
                          return _CanonEntryCard(
                            entry: entry,
                            author: author,
                            lang: lang,
                            isPersian: isPersian,
                          );
                        }, childCount: grouped[grade]!.length),
                      ),
                    ],
                  ],
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

class _CanonEntryCard extends StatelessWidget {
  final SchoolCanonEntry entry;
  final LiteraryAuthor? author;
  final DisplayLanguage lang;
  final bool isPersian;

  const _CanonEntryCard({
    required this.entry,
    required this.author,
    required this.lang,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final authorName = LiteraryAuthorDisplayText.nameOrFallback(
      author,
      lang,
      entry.authorId,
    );

    final isMandatory = entry.isMandatory;
    final isCitationVerified = entry.isCitationVerified;

    return InkWell(
      onTap: () {
        if (entry.workId.isNotEmpty) {
          context.push('/literature/work/${entry.workId}');
        } else if (entry.authorId.isNotEmpty) {
          context.push('/literature/poet/${entry.authorId}');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                  entry.subject == 'Адабиёти тоҷик'
                      ? AppTranslations.get('lit_subject_tajik', lang)
                      : AppTranslations.get('lit_subject_reading', lang),
                  style: QalamTypography.meta(
                    color: colors.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isMandatory
                        ? QalamColors.forest.withValues(alpha: 0.1)
                        : colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    isCitationVerified
                        ? (isMandatory
                              ? AppTranslations.get('lit_mandatory', lang)
                              : AppTranslations.get('lit_recommended', lang))
                        : AppTranslations.get('lit_source_pending', lang),
                    style: QalamTypography.meta(
                      color: isCitationVerified && isMandatory
                          ? QalamColors.forest
                          : colors.onSurfaceVariant,
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                const QalamChevron(size: 18),
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
                Icon(Icons.menu_book, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    formatBookCitation(
                      entry.textbookTitle,
                      lang,
                      grade: entry.grade,
                      year: entry.textbookYear,
                    ),
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
