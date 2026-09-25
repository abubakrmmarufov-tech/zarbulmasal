import 'word_entry.dart';

/// The Lexicon keyed for looking up a word as it appears in a poem.
///
/// A word is found under its headword as printed in the textbook glossaries
/// («Гул»), ignoring case, and — when the exact form is not a headword —
/// under the stem left after common Tajik endings: the izofat («гули»),
/// the plural («гулҳо»), the object marker («гулро») and the possessive
/// endings («ёрам»). Only stems of two letters or more are tried, and only
/// headwords that exist are returned, so a lookup never invents a meaning.
class LexiconIndex {
  LexiconIndex(Iterable<WordEntry> words) {
    for (final word in words) {
      (_byKey[_key(word.term)] ??= []).add(word);
    }
  }

  final Map<String, List<WordEntry>> _byKey = {};

  static const _minStem = 2;

  /// Endings tried, longest first, at most two in a row («гулҳоро»).
  static const _endings = [
    'ҳоямон', 'ҳоятон', 'ҳояшон', 'ҳоям', 'ҳоят', 'ҳояш', 'ҳоро', //
    'амон', 'атон', 'ашон', 'ҳо', 'он', 'ро', 'ам', 'ат', 'аш', //
    'и', 'ӣ', 'е', 'ю', 'йи',
  ];

  static final _letter = RegExp(r'[А-Яа-яЁёӢӣӮӯҲҳҶҷҚқҒғ]');

  static String _key(String text) => text.trim().toLowerCase();

  /// Entries for [word], exact headword first, else its stem's.
  List<WordEntry> lookup(String word) {
    final key = _key(word);
    if (key.isEmpty) return const [];
    for (final candidate in _candidates(key)) {
      final found = _byKey[candidate];
      if (found != null) return List.unmodifiable(found);
    }
    return const [];
  }

  static Iterable<String> _candidates(String word) sync* {
    yield word;
    final once = <String>[];
    for (final ending in _endings) {
      if (word.endsWith(ending) && word.length - ending.length >= _minStem) {
        final stem = word.substring(0, word.length - ending.length);
        once.add(stem);
        yield stem;
      }
    }
    for (final stem in once) {
      for (final ending in _endings) {
        if (stem.endsWith(ending) && stem.length - ending.length >= _minStem) {
          yield stem.substring(0, stem.length - ending.length);
        }
      }
    }
  }

  /// The word (letters, and hyphens between letters, as in «к-аз») at
  /// character [offset] of [text], or null on a space or mark.
  static String? wordAt(String text, int offset) {
    bool inWord(int i) {
      if (i < 0 || i >= text.length) return false;
      final char = text[i];
      if (_letter.hasMatch(char)) return true;
      return char == '-' &&
          i > 0 &&
          i + 1 < text.length &&
          _letter.hasMatch(text[i - 1]) &&
          _letter.hasMatch(text[i + 1]);
    }

    if (!inWord(offset)) return null;
    var start = offset;
    var end = offset + 1;
    while (inWord(start - 1)) {
      start--;
    }
    while (inWord(end)) {
      end++;
    }
    return text.substring(start, end);
  }

  /// The school grade of the book an entry comes from («5»), if named.
  static String? gradeOf(WordEntry entry) =>
      RegExp(r'sinfi\s*(\d+)').firstMatch(entry.sourceBook)?.group(1);
}
