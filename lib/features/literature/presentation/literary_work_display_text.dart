import '../../../core/l10n/app_translations.dart';
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

  /// One short citation for readers: book, grade (for a textbook file named
  /// "… sinfi N"), year and page — «Адабиёти тоҷик, синфи 5 (2017), с. 153».
  /// Nothing else from the provenance record is shown. `null` when the work
  /// has no source title.
  static String? shortCitation(LiteraryWork work, DisplayLanguage language) {
    final source = work.primarySource;
    if (source == null) return null;
    final title = source.bookTitle.trim();
    if (title.isEmpty) return null;
    final grade = RegExp(
      r'sinfi\s*(\d+)',
    ).firstMatch(source.sourceReference ?? '')?.group(1);
    final year = source.year.trim();
    final buffer = StringBuffer(title);
    if (grade != null) {
      buffer.write(
        ', ${AppTranslations.get('lit_source_grade', language, [grade])}',
      );
    }
    if (year.isNotEmpty) buffer.write(' ($year)');
    final start = source.pageStart;
    if (start != null) {
      final end = source.pageEnd;
      final pages = end == null || end == start ? '$start' : '$start–$end';
      buffer.write(
        ', ${AppTranslations.get('lit_source_pages', language, [pages])}',
      );
    }
    return AppTranslations.formatDigits(buffer.toString(), language);
  }

  /// Compact source label for ordinary reading UI: book title plus known page
  /// numbers only.
  ///
  /// Nothing is printed about missing pages, and full bibliographic/provenance
  /// strings stay in the explicit source panel rather than leaking into the
  /// reader. Returns `null` when no title is recorded.
  static String? sourceLabel(SourceEdition? source) {
    if (source == null) return null;
    final title = source.bookTitle.trim();
    if (title.isEmpty) return null;
    final pages = source.formattedPages;
    return pages == null ? title : '$title — $pages';
  }
}
