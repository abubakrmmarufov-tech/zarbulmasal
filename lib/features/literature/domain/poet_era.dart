import 'literary_author.dart';

/// The three broad periods poets are browsed by: the classical centuries
/// (IX–XV), the later classics (XVI–XIX) and the modern era (XX–XXI).
enum PoetEra {
  classical,
  later,
  modern;

  /// The era from the birth year as recorded ("~980", "1414",
  /// "охири асри ХI"), or from the death year when no birth year is known.
  /// `null` when neither holds a year.
  static PoetEra? of(LiteraryAuthor poet) {
    final born = _firstYear(poet.birthYear);
    if (born != null) return _fromYear(born);
    final died = _firstYear(poet.deathYear);
    return died == null ? null : _fromYear(died - 40);
  }

  static PoetEra? fromName(String? name) {
    for (final era in PoetEra.values) {
      if (era.name == name) return era;
    }
    return null;
  }

  static PoetEra _fromYear(int year) {
    if (year < 1500) return PoetEra.classical;
    if (year < 1880) return PoetEra.later;
    return PoetEra.modern;
  }

  static int? _firstYear(String? value) {
    final match = RegExp(r'\d{3,4}').firstMatch(value ?? '');
    return match == null ? null : int.parse(match.group(0)!);
  }

  /// Translation key of the era's label.
  String get labelKey => 'lit_era_$name';
}
