import '../../data/models/source_ref.dart';
import '../../shared/providers/app_providers.dart';
import 'app_translations.dart';

/// The book a source is, as readers see it: the title, then the grade and the
/// year when they are known — «Адабиёти тоҷик, синфи 5 (2017)»,
/// «Зарбулмасал ва мақолҳои тоҷикӣ (1956)».
///
/// Nothing else is shown: no author, imprint or page. Page numbers stay in the
/// data as the team's evidence for the checks.
String formatBookCitation(
  String title,
  DisplayLanguage lang, {
  String? grade,
  String? year,
}) {
  final buffer = StringBuffer(title.trim());
  final gradeText = grade?.trim() ?? '';
  if (gradeText.isNotEmpty) {
    final separator = lang == DisplayLanguage.persian ? '، ' : ', ';
    buffer.write(
      '$separator${AppTranslations.get('lit_source_grade', lang, [gradeText])}',
    );
  }
  final yearText = year?.trim() ?? '';
  if (yearText.isNotEmpty) {
    buffer.write(' (${AppTranslations.formatDigits(yearText, lang)})');
  }
  return buffer.toString();
}

/// A proverb's source: the book and its year. Textbook titles already name
/// the grade («Адабиёти тоҷик, синфи 5»); in Persian a bundled textbook is
/// named in Persian ([textbookCitation]). The printed and PDF pages stay on
/// [SourceRef] for the checks.
String formatSourceCitation(SourceRef source, DisplayLanguage lang) {
  final year = source.year?.toString();
  final grade = RegExp(
    r'^Адабиёти тоҷик, синфи (\d+)$',
  ).firstMatch(source.bookTitle.trim())?.group(1);
  final persianTextbook = grade == null
      ? null
      : persianTextbookCitation(grade, year, lang);
  return persianTextbook ??
      formatBookCitation(source.bookTitle, lang, year: year);
}

/// The literature textbooks in `docs/literature/pdfs`, by grade: each
/// edition's title and year as `assets/data/literature/sources.json` records
/// them (a test keeps the two in step).
const Map<String, ({String title, String year})> uploadedTextbookEditions = {
  '5': (title: 'Адабиёти тоҷик', year: '2017'),
  '6': (title: 'Адабиёти тоҷик', year: '2014'),
  '7': (title: 'Адабиёти тоҷик', year: '2018'),
  '8': (title: 'Адабиёти тоҷик', year: '2026'),
  '9': (title: 'Адабиёти тоҷик', year: '2026'),
  '10': (title: 'Адабиёти тоҷик', year: '2026'),
  '11': (title: 'Адабиёти тоҷик (давраи нав)', year: '2018'),
};

/// The grade of a textbook PDF named «… sinfi N.pdf»; null for any other
/// reference.
String? textbookGrade(String? reference) =>
    RegExp(r'sinfi\s*(\d+)').firstMatch(reference ?? '')?.group(1);

/// «Адабиёти тоҷик, синфи 5 (2017)» for the textbook PDF of [grade]; null when
/// no such PDF is bundled. Persian names the book in Persian.
///
/// See [persianTextbookCitation] for a source that names its own year.
String? textbookCitation(String grade, DisplayLanguage lang) {
  final edition = uploadedTextbookEditions[grade];
  if (edition == null) return null;
  return AppTranslations.get('lit_textbook_citation', lang, [
    grade,
    edition.year,
    edition.title,
  ]);
}

/// In Persian, the Persian name of the bundled textbook of [grade] when
/// [year] is that edition's year («ادبیات تاجیک، صنف ۵ (۲۰۱۷)»); null in
/// Tajik, for another edition, or for a grade with no bundled PDF.
String? persianTextbookCitation(
  String grade,
  String? year,
  DisplayLanguage lang,
) {
  if (lang != DisplayLanguage.persian) return null;
  final edition = uploadedTextbookEditions[grade];
  if (edition == null || edition.year != year?.trim()) return null;
  return textbookCitation(grade, lang);
}
