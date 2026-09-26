import '../../../core/l10n/app_translations.dart';
import '../../../core/l10n/source_citation.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/literary_author.dart';
import '../domain/portrait_record.dart';

/// Language-safe display values for author metadata.
///
/// Source-language fields stay available to search and provenance logic, but
/// Persian UI only renders values with an explicitly reviewed Persian form.
abstract final class LiteraryAuthorDisplayText {
  static String name(LiteraryAuthor author, DisplayLanguage language) {
    if (language != DisplayLanguage.persian) {
      return _normalizeDisplayCase(author.canonicalName);
    }
    final persianName = author.canonicalNamePersian?.trim() ?? '';
    return persianName.isNotEmpty
        ? persianName
        : AppTranslations.get('lit_author_name_persian_pending', language);
  }

  static String nameOrFallback(
    LiteraryAuthor? author,
    DisplayLanguage language,
    String fallback,
  ) {
    if (author != null) return name(author, language);
    return language == DisplayLanguage.persian
        ? AppTranslations.get('lit_author_name_persian_pending', language)
        : fallback;
  }

  static String period(LiteraryAuthor author, DisplayLanguage language) {
    if (language == DisplayLanguage.persian) {
      return author.literaryPeriodPersian?.trim() ?? '';
    }
    return author.literaryPeriod.trim();
  }

  static String? birthPlace(LiteraryAuthor author, DisplayLanguage language) {
    final value = language == DisplayLanguage.persian
        ? author.birthPlacePersian
        : author.birthPlace;
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<String> officialTitles(
    LiteraryAuthor author,
    DisplayLanguage language,
  ) {
    return language == DisplayLanguage.persian
        ? author.officialTitlesPersian
        : author.officialTitles;
  }

  /// Where a portrait is printed: the book, grade and year — never the page.
  static String portraitCitation(
    PortraitRecord? portrait,
    DisplayLanguage language,
  ) {
    if (portrait == null) return '';
    final grade = textbookGrade(portrait.sourceReference);
    final textbook = grade == null ? null : textbookCitation(grade, language);
    return switch (portrait.sourceType) {
      PortraitSourceType.uploadedBook when textbook != null =>
        AppTranslations.get('lit_portrait_source_textbook', language, [
          textbook,
        ]),
      PortraitSourceType.uploadedBook => AppTranslations.get(
        'lit_portrait_source_book',
        language,
      ),
      PortraitSourceType.maorifTj => AppTranslations.get(
        'lit_portrait_source_maorif',
        language,
      ),
      PortraitSourceType.userProvidedPhoto => AppTranslations.get(
        'lit_portrait_source_user_photo',
        language,
      ),
    };
  }

  /// The books a biography cites, without their pages:
  /// «Адабиёти тоҷик», синфи 8 (2026), с. 43–64; синфи 5 (2017), с. 49–56.
  /// becomes «Адабиёти тоҷик, синфи 8 (2026); синфи 5 (2017)». A citation
  /// that names no grade is just its title. The full citation stays in the
  /// data for the checks.
  static String biographySourceBooks(String citation) {
    final raw = citation.trim();
    if (raw.isEmpty) return '';
    final quoted = RegExp(r'«([^»]+)»').firstMatch(raw)?.group(1);
    final title = (quoted ?? raw.split(',').first).trim();
    final grades = RegExp(
      r'синфи\s*(\d+)(?:\s*\((\d{4})\))?',
    ).allMatches(raw).toList(growable: false);
    if (grades.isEmpty) return title;
    // Pages never reach four digits, so a lone four-digit number is the year
    // of a single-grade citation written without parentheses.
    final years = RegExp(r'(?<!\d)\d{4}(?!\d)').allMatches(raw).toList();
    final loneYear = grades.length == 1 && years.length == 1
        ? years.single.group(0)
        : null;
    final editions = grades.map((match) {
      final year = match.group(2) ?? loneYear;
      final grade = 'синфи ${match.group(1)}';
      return year == null ? grade : '$grade ($year)';
    });
    return '$title, ${editions.join('; ')}';
  }

  /// Persian receives localized year-only dates; Tajik keeps its source form.
  /// Missing death dates stay unknown instead of being presented as "alive".
  static String lifespan(LiteraryAuthor author, DisplayLanguage language) {
    if (language != DisplayLanguage.persian) return author.lifespan;

    final birth = _persianYear(author.birthYear, author.birthDateExact);
    final death = _persianYear(author.deathYear, author.deathDateExact);
    if (birth == null && death == null) return '';

    return AppTranslations.translate('lit_author_dates', language, [
      birth ?? AppTranslations.get('lit_author_unknown_year', language),
      death ?? AppTranslations.get('lit_author_unknown_year', language),
    ]);
  }

  static String? _persianYear(String? year, String? exactDate) {
    final catalogYear = _parseYear(year);
    final exactFieldYear = _parseYear(exactDate);
    if (catalogYear == null) return _formatYear(exactFieldYear);
    if (exactFieldYear == null) return _formatYear(catalogYear);
    if (catalogYear.digits == exactFieldYear.digits) {
      return _formatYear((
        digits: catalogYear.digits,
        approximate: catalogYear.approximate || exactFieldYear.approximate,
      ));
    }

    return '${_formatYear(catalogYear)} (${AppTranslations.get('lit_author_alternate_date', DisplayLanguage.persian)} ${_formatYear(exactFieldYear)})';
  }

  static ({String digits, bool approximate})? _parseYear(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;

    final approximate = RegExp(
      r'^(?:тақрибан|тахминан|c\.?|ca\.?)\s*',
      caseSensitive: false,
    ).hasMatch(raw);
    final digits = RegExp(r'\d{3,4}').firstMatch(raw)?.group(0);
    return digits == null ? null : (digits: digits, approximate: approximate);
  }

  static String? _formatYear(({String digits, bool approximate})? year) {
    if (year == null) return null;
    final localized = AppTranslations.formatDigits(
      year.digits,
      DisplayLanguage.persian,
    );
    return year.approximate ? 'حدود $localized' : localized;
  }

  /// Rewrites all-caps display names into a readable title case without
  /// touching Persian/Tajik Arabic script.
  ///
  /// Only values dominated by uppercase Cyrillic/Latin letters are rewritten
  /// (e.g. `"АНВАРӢ"` -> `"Анварӣ"`). Persian script has no upper/lower case
  /// and mixed-case names are left exactly as authored, so this never corrupts
  /// Arabic-script text or legitimate capitalization.
  static String _normalizeDisplayCase(String value) {
    if (value.isEmpty) return value;
    final hasCasedLetters = RegExp(r'[A-Za-zЀ-ӿ]').hasMatch(value);
    if (!hasCasedLetters || value != value.toUpperCase()) return value;

    return value
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          final first = word.substring(0, 1);
          final rest = word.substring(1);
          return first.toUpperCase() + rest.toLowerCase();
        })
        .join(' ');
  }
}
