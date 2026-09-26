import '../../../core/l10n/app_translations.dart';
import '../../../core/l10n/source_citation.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/literary_work.dart';
import '../domain/source_edition.dart';

/// Language-safe display values for literary works.
abstract final class LiteraryWorkDisplayText {
  static String title(LiteraryWork work, DisplayLanguage language) {
    if (language != DisplayLanguage.persian) return work.title;
    final translated = work.titlePersian?.trim() ?? '';
    return translated.isNotEmpty
        ? translated
        : AppTranslations.get('lit_work_title_persian_pending', language);
  }

  /// The corpus stores only the source-language incipit; do not leak it into
  /// Persian UI until a reviewed Persian field is available.
  static String? incipit(LiteraryWork work, DisplayLanguage language) {
    if (language == DisplayLanguage.persian) return null;
    final value = work.incipit?.trim() ?? '';
    return value.isEmpty ? null : value;
  }

  /// The first line, unless the poem is known by it (its title is the
  /// first line): lists show it only when it adds something.
  static String? distinctIncipit(LiteraryWork work, DisplayLanguage language) {
    final value = incipit(work, language);
    if (value == null) return null;
    final shown = title(work, language).toLowerCase();
    return value.toLowerCase().startsWith(shown) ? null : value;
  }

  /// One short citation for readers: the book, its grade (for a textbook file
  /// named "… sinfi N") and year — «Адабиёти тоҷик, синфи 5 (2017)». No page
  /// and nothing else from the provenance record is shown. `null` when the
  /// work has no source title.
  static String? shortCitation(LiteraryWork work, DisplayLanguage language) =>
      sourceCitation(work.primarySource, language);

  /// [shortCitation] for any source edition; `null` when no title is
  /// recorded.
  static String? sourceCitation(
    SourceEdition? source,
    DisplayLanguage language,
  ) {
    if (source == null) return null;
    final title = source.bookTitle.trim();
    if (title.isEmpty) return null;
    return formatBookCitation(
      title,
      language,
      grade: textbookGrade(source.sourceReference),
      year: source.year,
    );
  }

  /// The forms a reader can browse by, in the order they are offered.
  static const browsableForms = [
    WorkType.ghazal,
    WorkType.rubai,
    WorkType.epic,
    WorkType.fragment,
    WorkType.qasida,
  ];

  /// The name of a work's form («Ғазал», «Рубоӣ», «Маснавӣ», «Қитъа» …).
  static String form(WorkType type, DisplayLanguage language) {
    final key = switch (type) {
      WorkType.ghazal => 'lit_genre_ghazal',
      WorkType.rubai => 'lit_genre_rubai',
      WorkType.qasida => 'lit_genre_qasida',
      WorkType.poem => 'lit_genre_poem',
      WorkType.fragment => 'lit_genre_qita',
      WorkType.folk => 'lit_genre_folk',
      WorkType.anthem => 'lit_genre_song',
      WorkType.epic => 'lit_genre_masnavi',
      WorkType.other => 'lit_genre_other',
    };
    return AppTranslations.get(key, language);
  }
}
