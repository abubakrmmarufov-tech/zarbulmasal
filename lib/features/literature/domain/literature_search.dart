import '../../../core/utils/search_normalizer.dart';
import 'literary_author.dart';
import 'literary_work.dart';

/// What a reader can find poets and poems by, the same in global search,
/// literature search and the poet list's filter.
abstract final class LiteratureSearch {
  /// A poet's names in both scripts, other names, period and birthplace.
  static List<String> authorFields(LiteraryAuthor author) => [
    author.canonicalName,
    author.canonicalNamePersian ?? '',
    ...author.aliases,
    author.literaryPeriod,
    author.birthPlace ?? '',
  ];

  /// A poem's titles and first lines in both scripts.
  static List<String> workFields(LiteraryWork work) => [
    work.title,
    work.titlePersian ?? '',
    work.incipit ?? '',
    _firstLine(work.textTajik),
    _firstLine(work.textPersian),
  ];

  static bool matchesAuthor(LiteraryAuthor author, String query) =>
      SearchNormalizer.matchesAnyOnAnyKeyboard(authorFields(author), query);

  static bool matchesWork(LiteraryWork work, String query) =>
      SearchNormalizer.matchesAnyOnAnyKeyboard(workFields(work), query);

  static String _firstLine(String? text) {
    if (text == null) return '';
    for (final line in text.split('\n')) {
      if (line.trim().isNotEmpty) return line.trim();
    }
    return '';
  }
}
