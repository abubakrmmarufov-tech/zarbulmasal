import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/l10n/source_citation.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/reading_position_provider.dart';
import '../../../shared/providers/recent_activity_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';
import 'history_end_of_text.dart';
import 'history_section_labels.dart';
import 'history_source_launcher.dart';

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

/// The textbook an entry comes from: title, grade and year, never the page.
String _historyBookCitation(HistoryBook book, DisplayLanguage language) =>
    formatBookCitation(
      _historyRequiredTitle(book.title, book.titlePersian, language),
      language,
      grade: book.grade,
      year: book.year,
    );

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
            subtitle: AppTranslations.get('hist_detail_error_sub', lang),
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
                subtitle: AppTranslations.get(
                  'hist_detail_not_found_sub',
                  lang,
                ),
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

          final title = _historyRequiredTitle(
            entry.title,
            entry.titlePersian,
            lang,
          );
          final summary = isPersian
              ? _historyOptionalText(entry.summaryPersian)
              : _historyOptionalText(entry.summary);
          final dates = isPersian
              ? _historyOptionalText(entry.datesPersian) ??
                    _historyOptionalText(entry.periodPersian) ??
                    ''
              : _historyOptionalText(entry.dates) ??
                    _historyOptionalText(entry.period) ??
                    '';
          final capital = isPersian
              ? _historyOptionalText(entry.capitalPersian)
              : _historyOptionalText(entry.capital);
          final territory = isPersian
              ? _historyOptionalText(entry.territoryPersian)
              : _historyOptionalText(entry.territory);
          final significance = isPersian
              ? _historyOptionalText(entry.significancePersian)
              : _historyOptionalText(entry.significance);
          final keyFigures =
              (isPersian ? entry.keyFiguresPersian : entry.keyFigures)
                  .map((figure) => figure.trim())
                  .where((figure) => figure.isNotEmpty)
                  .toList(growable: false);
          final section = isPersian
              ? null
              : _historyOptionalText(entry.sourceSection);

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(recentActivityProvider.notifier)
                .addActivity(
                  RecentActivity(
                    id: entry.id,
                    type: RecentActivityType.history,
                    title: title,
                    subtitle: AppTranslations.getForIsPersian(
                      isPersian,
                      'kind_history',
                    ),
                    titleTajik: entry.title,
                    titlePersian: entry.titlePersian,
                    subtitleTajik: 'Таърих',
                    subtitlePersian: 'تاریخ',
                    timestamp: DateTime.now(),
                    route: '/history/${entry.id}',
                  ),
                );
            ref
                .read(readingPositionProvider.notifier)
                .open(
                  ReadingPosition(
                    kind: ReadingKind.history,
                    id: entry.id,
                    route: '/history/${entry.id}',
                    titleTajik: entry.title,
                    titlePersian: entry.titlePersian,
                    timestamp: DateTime.now(),
                  ),
                );
          });

          return Directionality(
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                // Catalogue line: kind and grade as type, no badges.
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      _kindLabel(entry.kind, isPersian),
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                    Text(
                      AppTranslations.get('hist_filter_grade', lang, [
                        entry.grade,
                      ]),
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    style: QalamTypography.monographTitle(
                      color: colors.onSurface,
                      fontSize: 30,
                    ),
                  ),
                ),
                if (dates.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    dates,
                    style: QalamTypography.meta(
                      color: colors.primary,
                      fontSize: 15,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                // Capital, territory, key figures: a boxed fact card
                // (definition list), as on a museum label.
                if (capital != null ||
                    territory != null ||
                    keyFigures.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? colors.surfaceContainer
                          : colors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colors.onSurface.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (capital != null)
                          _DetailLine(
                            label: AppTranslations.get('hist_capital', lang),
                            value: capital,
                          ),
                        if (territory != null)
                          _DetailLine(
                            label: AppTranslations.get('hist_territory', lang),
                            value: territory,
                          ),
                        if (keyFigures.isNotEmpty)
                          _DetailLine(
                            label: AppTranslations.get(
                              'hist_key_figures_and_rulers',
                              lang,
                            ),
                            value: keyFigures.join(', '),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Historical Summary
                if (summary != null) ...[
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
                ],
                // Historical Significance
                if (significance != null) ...[
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
                // Long-form reading sections
                if (entry.sections.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    HistorySectionLabels.readingTitle(lang),
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 12),
                  ...entry.sections.map(
                    (section) => _ReadingSectionCard(
                      section: section,
                      isPersian: isPersian,
                      books: books,
                      entrySourceBookId: entry.sourceBookId,
                    ),
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
                              AppTranslations.get(
                                'hist_official_textbook',
                                lang,
                              ),
                              style: QalamTypography.eyebrow(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // The section heads the card; the grade is named
                      // once, in the book line below (or here when no book
                      // is recorded).
                      if (section != null || sourceBook == null) ...[
                        const SizedBox(height: 10),
                        Text(
                          section ??
                              AppTranslations.get('hist_filter_grade', lang, [
                                entry.grade,
                              ]),
                          style: QalamTypography.sectionTitle(
                            color: colors.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ],
                      if (sourceBook != null) ...[
                        SizedBox(height: section != null ? 4 : 10),
                        Text(
                          _historyBookCitation(sourceBook, lang),
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        if (sourceBook.externalSourceUri != null) ...[
                          const SizedBox(height: 14),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(48, 48),
                            ),
                            icon: const Icon(Icons.open_in_browser, size: 20),
                            label: Text(
                              (sourceBook.isUploadedBook ||
                                      sourceBook.localPath != null)
                                  ? AppTranslations.get(
                                      'hist_source_study_local',
                                      lang,
                                    )
                                  : AppTranslations.get(
                                      'hist_source_study',
                                      lang,
                                    ),
                            ),
                            onPressed: () async {
                              final uri = sourceBook.externalSourceUri!;
                              await openHistorySource(context, uri, lang);
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                HistoryEndOfText(entry: entry),
              ],
            ),
          );
        },
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

class _ReadingSectionCard extends StatelessWidget {
  final HistoryDetailSection section;
  final bool isPersian;
  final List<HistoryBook> books;
  final String entrySourceBookId;

  const _ReadingSectionCard({
    required this.section,
    required this.isPersian,
    required this.books,
    required this.entrySourceBookId,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik;

    final heading = isPersian
        ? _historyOptionalText(section.headingPersian) ?? section.heading
        : section.heading;
    final body = isPersian
        ? _historyOptionalText(section.bodyPersian) ?? section.body
        : section.body;
    // The editorial note applies whenever any Persian text on this section is
    // an editorial rendering of the Tajik source witness, not only when a full
    // Persian body translation exists.
    final showedPersianEditorial = isPersian && section.persianIsEditorial;
    // When the body has no Persian rendering it falls back to the Tajik source
    // paragraph (Cyrillic); label it and keep it LTR so it is not misread as
    // right-to-left Persian text.
    final showedTajikSourceFallback =
        isPersian && _historyOptionalText(section.bodyPersian) == null;
    // Cyrillic headings (Tajik mode, or a Persian-mode heading with no Persian
    // rendering) must stay LTR; only a real Persian heading is RTL.
    final headingDirection =
        (!isPersian || _historyOptionalText(section.headingPersian) == null)
        ? TextDirection.ltr
        : TextDirection.rtl;
    final paragraphs = body
        .split('\n\n')
        .map((paragraph) => paragraph.trim())
        .where((paragraph) => paragraph.isNotEmpty)
        .toList(growable: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(QalamSpacing.cardRadius),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (heading.isNotEmpty) ...[
            Directionality(
              textDirection: headingDirection,
              child: Text(
                heading,
                style: QalamTypography.sectionTitle(
                  color: colors.onSurface,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          ...paragraphs.map(
            (paragraph) => Padding(
              padding: EdgeInsets.only(
                bottom: paragraph == paragraphs.last ? 0 : 12,
              ),
              child: _sectionParagraph(
                context,
                paragraph,
                forceLtr: isPersian && showedTajikSourceFallback,
              ),
            ),
          ),
          if (_sectionBook != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.menu_book, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    HistorySectionLabels.sourceBookCaption(
                      lang,
                      _sectionBookTitle(),
                    ),
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showedTajikSourceFallback) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.translate, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    HistorySectionLabels.sourceLanguageNote(lang),
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (showedPersianEditorial) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.edit_note, size: 14, color: colors.onSurfaceVariant),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    HistorySectionLabels.editorialNote(lang),
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// A section paragraph. When the body is the Tajik source witness shown in
  /// Persian mode it is wrapped in an LTR [Directionality] so the Cyrillic
  /// text is not reshaped or aligned as right-to-left Persian.
  Widget _sectionParagraph(
    BuildContext context,
    String paragraph, {
    required bool forceLtr,
  }) {
    final text = Text(
      paragraph,
      style: QalamTypography.body(
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.65,
        fontSize: 15,
      ),
    );
    if (!forceLtr) return text;
    return Directionality(textDirection: TextDirection.ltr, child: text);
  }

  /// The book a section cites when it differs from the entry's own source book
  /// (e.g. a poem section drawn from a literature textbook).
  HistoryBook? get _sectionBook {
    final bookId = section.sourceBookId;
    if (bookId == null || bookId == entrySourceBookId) return null;
    for (final book in books) {
      if (book.id == bookId) return book;
    }
    return null;
  }

  /// "Таърихи халқи тоҷик, синфи 8": every grade's book has the same
  /// title, so the grade says which one.
  String _sectionBookTitle() {
    final book = _sectionBook!;
    final title = isPersian
        ? _historyOptionalText(book.titlePersian) ?? book.title
        : book.title;
    if (book.grade.trim().isEmpty) return title;
    final grade = AppTranslations.get(
      'hist_filter_grade',
      isPersian ? DisplayLanguage.persian : DisplayLanguage.tajik,
      [book.grade],
    ).toLowerCase();
    return '$title, $grade';
  }
}

class _DetailLine extends StatelessWidget {
  final String label;
  final String value;

  const _DetailLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.outlineVariant)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: QalamTypography.meta(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: QalamTypography.body(color: colors.onSurface, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
