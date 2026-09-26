/// High-fidelity phonetic, orthographic, and diacritic normalization
/// for Tajik Cyrillic and Persian Arabic scripts.
class SearchNormalizer {
  SearchNormalizer._();

  static final RegExp _zwnjRegex = RegExp(r'[\u200C\u200D\u200E\u200F\uFEFF]');
  static final RegExp _arabicDiacritics = RegExp(
    r'[\u064B-\u065F\u0670\u06D6-\u06ED]',
  );
  static final RegExp _multiSpace = RegExp(r'\s+');

  /// Normalizes a query or text string for robust search matching across
  /// both Tajik Cyrillic and Persian Arabic scripts.
  static String normalize(String text) {
    if (text.isEmpty) return '';

    var s = text.trim().toLowerCase();

    // 1. Unicode ZWNJ, Arabic diacritics and tatweel removal
    s = s.replaceAll(_zwnjRegex, '');
    s = s.replaceAll(_arabicDiacritics, '');
    s = s.replaceAll('ـ', '');

    // 2. Persian / Arabic letter unification
    s = s
        .replaceAll('ي', 'ی') // Arabic Yeh to Persian Yeh
        .replaceAll('ك', 'ک') // Arabic Kaf to Persian Keheh
        .replaceAll('آ', 'ا') // Alef with madda
        .replaceAll('أ', 'ا') // Alef with hamza above
        .replaceAll('إ', 'ا') // Alef with hamza below
        .replaceAll('ٱ', 'ا') // Alef wasla
        .replaceAll('ى', 'ی') // Alef maksura (Arabic keyboard) to Yeh
        .replaceAll('ئ', 'ی') // Yeh with hamza
        .replaceAll('ؤ', 'و') // Waw with hamza
        .replaceAll('ھ', 'ه') // Heh doachashmee
        .replaceAll('ة', 'ه') // Teh marbuta to Heh
        .replaceAll('ۀ', 'ه'); // Heh with yeh

    // 3. Persian / Eastern digits to ASCII
    const faDigits = '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩';
    const enDigits = '01234567890123456789';
    for (var i = 0; i < faDigits.length; i++) {
      s = s.replaceAll(faDigits[i], enDigits[i]);
    }

    // 4. Tajik Cyrillic diacritic folding; a Russian keyboard writes ҷ as
    // «дж» and has э where Tajik has е.
    s = s
        .replaceAll('дж', 'ч')
        .replaceAll('э', 'е')
        .replaceAll('ӣ', 'и') // I with macron to plain I
        .replaceAll('ӯ', 'у') // U with macron to plain U
        .replaceAll('ҳ', 'х') // H with descender to Kh
        .replaceAll('ҷ', 'ч') // Che with descender to Che
        .replaceAll('қ', 'к') // Ka with descender to Ka
        .replaceAll('ғ', 'г') // Ghe with stroke to Ghe
        .replaceAll('ё', 'е'); // Yo to Ye

    // 5. Tajik hard sign (ъ / Ъ) and apostrophe unification
    s = s
        .replaceAll('ъ', '')
        .replaceAll('’', '')
        .replaceAll('‘', '')
        .replaceAll('ʻ', '')
        .replaceAll("'", '')
        .replaceAll('`', '');

    // 6. Clean extra spaces
    s = s.replaceAll(_multiSpace, ' ').trim();

    return s;
  }

  static final RegExp _hasLatin = RegExp(r'[a-zA-Z]');

  /// Transliterates Latin (English/Tajik Latin) text to phonetic Tajik Cyrillic.
  /// Handles common digraphs (sh, ch, gh, kh, zh, ts, yo, yu, ya, ye) and
  /// character correspondences so users on Latin keyboards can search effectively.
  static String latinToTajikCyrillic(String input) {
    if (input.isEmpty) return '';
    var s = input.toLowerCase();

    // 1. Multi-letter digraphs first
    s = s
        .replaceAll('shch', 'щ')
        .replaceAll('ch', 'ч')
        .replaceAll('sh', 'ш')
        .replaceAll('gh', 'г') // ғ folds to г
        .replaceAll('kh', 'х') // ҳ / х
        .replaceAll('zh', 'ж')
        .replaceAll('ts', 'ц')
        .replaceAll('ayyam', 'айем')
        .replaceAll('ayyom', 'айем')
        .replaceAll('yo', 'е') // ё folds to е
        .replaceAll('yu', 'ю')
        .replaceAll('ya', 'е')
        .replaceAll('ye', 'е')
        .replaceAll('ay', 'ай')
        .replaceAll('oy', 'ой')
        .replaceAll('ey', 'ей')
        .replaceAll('uy', 'уй')
        .replaceAll('ee', 'и')
        .replaceAll('oo', 'у')
        .replaceAll('ou', 'у');

    // 2. Single letters
    final sb = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      final char = s[i];
      switch (char) {
        case 'a':
          sb.write('а');
          break;
        case 'b':
          sb.write('б');
          break;
        case 'c':
          sb.write('к');
          break;
        case 'd':
          sb.write('д');
          break;
        case 'e':
          sb.write('е');
          break;
        case 'f':
          sb.write('ф');
          break;
        case 'g':
          sb.write('г');
          break;
        case 'h':
          sb.write('х');
          break;
        case 'i':
          sb.write('и');
          break;
        case 'j':
          sb.write('ч'); // ҷ folds to ч
          break;
        case 'k':
          sb.write('к');
          break;
        case 'l':
          sb.write('л');
          break;
        case 'm':
          sb.write('м');
          break;
        case 'n':
          sb.write('н');
          break;
        case 'o':
          sb.write('о');
          break;
        case 'p':
          sb.write('п');
          break;
        case 'q':
          sb.write('к'); // қ folds to к
          break;
        case 'r':
          sb.write('р');
          break;
        case 's':
          sb.write('с');
          break;
        case 't':
          sb.write('т');
          break;
        case 'u':
          sb.write('у');
          break;
        case 'v':
        case 'w':
          sb.write('в');
          break;
        case 'x':
          sb.write('х');
          break;
        case 'y':
          sb.write('и');
          break;
        case 'z':
          sb.write('з');
          break;
        default:
          sb.write(char);
      }
    }
    return sb.toString();
  }

  /// Exact-aware matching that tests:
  /// 1. Direct case-insensitive containment
  /// 2. Normalized diacritic & script-folded containment
  /// 3. Space-agnostic containment (for compound words like "می‌شود" vs "می شود" or "ضرب‌المثل" vs "ضرب المثل")
  /// 4. Latin-to-Tajik Cyrillic transliteration and vowel-flexible variants
  static bool matches(String target, String query) {
    if (query.isEmpty) return true;
    if (target.isEmpty) return false;
    return _strictlyMatches(target, query);
  }

  /// [matches], or failing that [looselyMatches]: for names and titles,
  /// where a reader types what they heard on whatever keyboard they have.
  static bool matchesOnAnyKeyboard(String target, String query) =>
      matches(target, query) ||
      (target.isNotEmpty && looselyMatches(target, query));

  /// Containment after folding, with or without spaces, and Latin queries
  /// read as Tajik Cyrillic.
  static bool _strictlyMatches(String target, String query) {
    // 1. Fast path: direct case-insensitive containment
    final lowerTarget = target.toLowerCase();
    final lowerQuery = query.toLowerCase().trim();
    if (lowerTarget.contains(lowerQuery)) return true;

    // 2. Normalized path: diacritic and script-folded containment
    final normTarget = normalize(target);
    final normQuery = normalize(query);
    if (normQuery.isNotEmpty && normTarget.contains(normQuery)) {
      return true;
    }

    // 3. Space-agnostic path for compound words
    final tightTarget = normTarget.replaceAll(' ', '');
    final tightQuery = normQuery.replaceAll(' ', '');
    if (tightQuery.isNotEmpty && tightTarget.contains(tightQuery)) {
      return true;
    }

    // 4. Latin transliteration path
    if (_hasLatin.hasMatch(query)) {
      final cyrQuery = normalize(latinToTajikCyrillic(query));
      if (cyrQuery.isNotEmpty) {
        if (normTarget.contains(cyrQuery)) return true;
        final tightCyr = cyrQuery.replaceAll(' ', '');
        if (tightCyr.isNotEmpty && tightTarget.contains(tightCyr)) {
          return true;
        }

        // Vowel-flexible matching for Persian 'ā' vs Tajik 'о' (e.g. Hafiz -> Ҳофиз, Jami -> Ҷомӣ)
        final aToO = cyrQuery.replaceAll('а', 'о');
        if (normTarget.contains(aToO)) return true;
        final tightAToO = aToO.replaceAll(' ', '');
        if (tightAToO.isNotEmpty && tightTarget.contains(tightAToO)) {
          return true;
        }

        final oToA = cyrQuery.replaceAll('о', 'а');
        if (normTarget.contains(oToA)) return true;
        final tightOToA = oToA.replaceAll(' ', '');
        if (tightOToA.isNotEmpty && tightTarget.contains(tightOToA)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Word by word, on any keyboard: every word of [query] is found in
  /// [target] — whole or in part, spelled in Tajik, Russian or Latin
  /// letters ([skeleton]), or in Persian or Arabic letters compared by
  /// consonants ([consonants]) — and a word of [typoMinLength] letters or
  /// more may be one typo away from a word of [target].
  static bool looselyMatches(String target, String query) =>
      _looseScore(target, query) > 0;

  /// 15 when every word is found, 10 when one needed a typo forgiven, 0.
  static int _looseScore(String target, String query) {
    final normQuery = normalize(query);
    if (normQuery.isEmpty) return 0;
    var best = _wordsFound(normQuery, normalize(target));
    if (best == _allExact) return 15;
    final latinQuery = skeleton(query);
    // A word the skeleton shrank to one letter («ққққ» → «k») would be
    // found everywhere.
    if (latinQuery.isNotEmpty && !latinQuery.split(' ').any(_isOneLetter)) {
      final found = _wordsFound(latinQuery, skeleton(target));
      if (found == _allExact) return 15;
      if (found > best) best = found;
    }
    if (_hasArabicScript.hasMatch(normQuery)) {
      final queryConsonants = consonants(normQuery);
      if (queryConsonants.replaceAll(' ', '').length >= _minConsonants &&
          _wordsFound(queryConsonants, consonants(target), typos: false) ==
              _allExact) {
        return 15;
      }
    }
    return best == _withTypos ? 10 : 0;
  }

  static bool _isOneLetter(String word) => word.length == 1;

  static final RegExp _hasArabicScript = RegExp(r'[\u0600-\u06FF]');
  static const int _minConsonants = 3;

  /// Words of at least this many letters may differ by one typo.
  static const int typoMinLength = 5;

  static const int _notFound = 0;
  static const int _withTypos = 1;
  static const int _allExact = 2;

  /// Whether each word of [query] is in [target] ([_allExact]), some only
  /// within one edit of a word of [target] when they have [typoMinLength]
  /// letters ([_withTypos]), or not ([_notFound]).
  static int _wordsFound(String query, String target, {bool typos = true}) {
    if (query.isEmpty || target.isEmpty) return _notFound;
    var result = _allExact;
    List<String>? targetWords;
    for (final word in query.split(' ')) {
      if (word.isEmpty || target.contains(word)) continue;
      if (!typos || word.length < typoMinLength) return _notFound;
      targetWords ??= target.split(' ');
      if (!targetWords.any((candidate) => _nearWord(word, candidate))) {
        return _notFound;
      }
      result = _withTypos;
    }
    return result;
  }

  /// [word] within one edit of [candidate] or of its start (a word typed in
  /// part, with a typo).
  static bool _nearWord(String word, String candidate) {
    if (candidate.length < typoMinLength - 1) return false;
    if (withinOneEdit(word, candidate)) return true;
    for (final length in [word.length, word.length + 1]) {
      if (candidate.length > length &&
          withinOneEdit(word, candidate.substring(0, length))) {
        return true;
      }
    }
    return false;
  }

  /// Whether [a] becomes [b] by at most one inserted, deleted or replaced
  /// letter, or two neighbouring letters swapped.
  static bool withinOneEdit(String a, String b) {
    if (a == b) return true;
    if ((a.length - b.length).abs() > 1) return false;
    var i = 0;
    while (i < a.length && i < b.length && a[i] == b[i]) {
      i++;
    }
    if (a.length == b.length) {
      if (a.substring(i + 1) == b.substring(i + 1)) return true;
      return i + 1 < a.length &&
          a[i] == b[i + 1] &&
          a[i + 1] == b[i] &&
          a.substring(i + 2) == b.substring(i + 2);
    }
    final (longer, shorter) = a.length > b.length ? (a, b) : (b, a);
    return longer.substring(i + 1) == shorter.substring(i);
  }

  static const Map<String, String> _cyrillicToLatin = {
    'а': 'a',
    'б': 'b',
    'в': 'v',
    'г': 'g',
    'ғ': 'g',
    'д': 'd',
    'е': 'e',
    'ё': 'yo',
    'ж': 'zh',
    'з': 'z',
    'и': 'i',
    'ӣ': 'i',
    'й': 'y',
    'к': 'k',
    'қ': 'k',
    'л': 'l',
    'м': 'm',
    'н': 'n',
    'о': 'o',
    'п': 'p',
    'р': 'r',
    'с': 's',
    'т': 't',
    'у': 'u',
    'ӯ': 'u',
    'ф': 'f',
    'х': 'kh',
    'ҳ': 'h',
    'ц': 's',
    'ч': 'ch',
    'ҷ': 'j',
    'ш': 'sh',
    'щ': 'sh',
    'ъ': '',
    'ы': 'i',
    'ь': '',
    'э': 'e',
    'ю': 'yu',
    'я': 'ya',
  };

  static const Map<String, String> _latinLetters = {
    'ā': 'a',
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'ē': 'e',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'ī': 'i',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ō': 'o',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ū': 'u',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ğ': 'gh',
    'ǧ': 'gh',
    'ḥ': 'h',
    'ḳ': 'q',
    'š': 'sh',
    'č': 'ch',
    'ž': 'zh',
    'ǰ': 'j',
    'ñ': 'n',
    'ç': 'ch',
    'ẓ': 'z',
    'ṣ': 's',
    'ṭ': 't',
  };

  /// Digraphs and vowels written in many ways, folded to one: Khayyam and
  /// Khayyom, Ferdowsi and Firdavsi, Jami and Jomi meet. Order matters.
  static const List<(String, String)> _latinFolds = [
    ('dzh', 'ç'),
    ('dj', 'ç'),
    ('zh', 'ž'),
    ('kh', 'h'),
    ('gh', 'g'),
    ('sh', 'ş'),
    ('ch', 'ç'),
    ('j', 'ç'),
    ('ph', 'f'),
    ('ts', 's'),
    ('c', 'k'),
    ('q', 'k'),
    ('x', 'h'),
    ('w', 'v'),
    ('ee', 'i'),
    ('oo', 'u'),
    ('ou', 'av'),
    ('ow', 'av'),
    ('au', 'av'),
    ('e', 'i'),
    ('o', 'a'),
    ('y', 'i'),
  ];

  static final RegExp _notSkeleton = RegExp(r'[^a-z0-9şçž ]');
  static final RegExp _repeated = RegExp(r'(.)\1+');

  /// A loose Latin spelling of Tajik Cyrillic or Latin text: «Рӯдакӣ»,
  /// "Rudakiy" and "Rūdakī" all become "rudaki". Empty for text in other
  /// scripts.
  static String skeleton(String text) {
    final cached = _skeletons[text];
    if (cached != null) return cached;
    final buffer = StringBuffer();
    for (final char in text.toLowerCase().split('')) {
      buffer.write(_cyrillicToLatin[char] ?? _latinLetters[char] ?? char);
    }
    var s = buffer.toString().replaceAll(RegExp(r"['’‘ʻʼ`´\-‐–]"), '');
    for (final (from, to) in _latinFolds) {
      s = s.replaceAll(from, to);
    }
    s = s
        .replaceAll(_notSkeleton, ' ')
        .replaceAllMapped(_repeated, (m) => m[1]!)
        .replaceAll(_multiSpace, ' ')
        .trim();
    if (!RegExp(r'[a-zşçž]').hasMatch(s)) s = '';
    return _remember(_skeletons, text, s);
  }

  /// Persian-Arabic and Tajik letters grouped by consonant, vowels and the
  /// letters that also write vowels (ا و ی ع, в й ъ) left out, so a Persian
  /// query «بوی جوی مولیان» meets «Бӯйи Ҷӯйи Мулиён».
  static const Map<String, String> _consonantClasses = {
    'ب': 'b',
    'б': 'b',
    'پ': 'p',
    'п': 'p',
    'ت': 't',
    'ط': 't',
    'т': 't',
    'ث': 's',
    'س': 's',
    'ص': 's',
    'с': 's',
    'ц': 's',
    'ج': 'j',
    'ҷ': 'j',
    'چ': 'j',
    'ч': 'j',
    'ح': 'h',
    'ه': 'h',
    'ҳ': 'h',
    'خ': 'x',
    'х': 'x',
    'د': 'd',
    'д': 'd',
    'ذ': 'z',
    'ز': 'z',
    'ض': 'z',
    'ظ': 'z',
    'з': 'z',
    'ر': 'r',
    'р': 'r',
    'ژ': 'ž',
    'ж': 'ž',
    'ش': 'š',
    'ш': 'š',
    'щ': 'š',
    'ف': 'f',
    'ф': 'f',
    'ق': 'q',
    'қ': 'q',
    'ک': 'k',
    'к': 'k',
    'گ': 'g',
    'г': 'g',
    'غ': 'ğ',
    'ғ': 'ğ',
    'ل': 'l',
    'л': 'l',
    'م': 'm',
    'м': 'm',
    'ن': 'n',
    'н': 'n',
  };

  /// [text]'s consonants by class, word by word (see [_consonantClasses]).
  /// A Persian word's final ه is a vowel (زاده, «зода») and is dropped.
  static String consonants(String text) {
    final cached = _consonantCache[text];
    if (cached != null) return cached;
    final words = <String>[];
    for (final word in text.toLowerCase().split(_multiSpace)) {
      final trimmed = word.endsWith('ه')
          ? word.substring(0, word.length - 1)
          : word;
      final buffer = StringBuffer();
      for (final char in trimmed.split('')) {
        final mapped = _consonantClasses[char];
        if (mapped != null) buffer.write(mapped);
      }
      if (buffer.isNotEmpty) words.add(buffer.toString());
    }
    return _remember(_consonantCache, text, words.join(' '));
  }

  static final Map<String, String> _skeletons = {};
  static final Map<String, String> _consonantCache = {};
  static const int _cacheLimit = 20000;

  static String _remember(Map<String, String> cache, String key, String value) {
    if (cache.length >= _cacheLimit) cache.clear();
    cache[key] = value;
    return value;
  }

  /// Returns true if any of the given targets match the query.
  static bool matchesAny(List<String> targets, String query) {
    if (query.trim().isEmpty) return true;
    for (final t in targets) {
      if (matches(t, query)) return true;
    }
    return false;
  }

  /// [matchesAny] with [matchesOnAnyKeyboard].
  static bool matchesAnyOnAnyKeyboard(List<String> targets, String query) {
    if (query.trim().isEmpty) return true;
    for (final t in targets) {
      if (matchesOnAnyKeyboard(t, query)) return true;
    }
    return false;
  }

  /// Computes a relevance score (0..100) for ranking search results:
  /// - Exact match (100)
  /// - Normalized exact match (90)
  /// - Prefix match (75)
  /// - Normalized prefix match (65)
  /// - Word boundary / prefix of a word (50)
  /// - Partial / substring match (35)
  /// - Space-agnostic / transliterated match (20)
  /// - Any keyboard, word by word (15), or with one typo (10)
  /// - No match (0)
  static int scoreMatch(String target, String query) {
    if (query.trim().isEmpty) return 100;
    if (target.trim().isEmpty) return 0;

    final lowerTarget = target.toLowerCase().trim();
    final lowerQuery = query.toLowerCase().trim();

    if (lowerTarget == lowerQuery) return 100;

    final normTarget = normalize(target);
    final normQuery = normalize(query);

    if (normQuery.isEmpty) return 0;
    if (normTarget == normQuery) return 90;
    if (lowerTarget.startsWith(lowerQuery)) return 75;
    if (normTarget.startsWith(normQuery)) return 65;

    // Word prefix matching
    final words = normTarget.split(' ');
    for (final w in words) {
      if (w.startsWith(normQuery)) return 50;
    }

    if (normTarget.contains(normQuery)) return 35;

    // Transliterated or folded containment, then the any-keyboard fallback.
    if (_strictlyMatches(target, query)) return 20;
    return _looseScore(target, query);
  }

  /// Returns the highest relevance score among all candidate targets.
  static int scoreMatchAny(List<String> targets, String query) {
    var maxScore = 0;
    for (final t in targets) {
      final score = scoreMatch(t, query);
      if (score > maxScore) maxScore = score;
    }
    return maxScore;
  }

  /// The span of [target] (in its own code units) that [query] matches, for
  /// highlighting; `null` when the match is not in [target] itself.
  ///
  /// Each character is folded as [normalize] folds it, keeping a map back to
  /// the original, so a folded match ("руда" in «Рӯдакӣ») highlights the
  /// original letters. Latin queries are also tried in Tajik Cyrillic.
  static ({int start, int end})? matchRange(String target, String query) {
    if (target.isEmpty) return null;
    final folded = StringBuffer();
    final origin = <int>[];
    for (var i = 0; i < target.length; i++) {
      final unit = _foldUnit(target[i]);
      for (var j = 0; j < unit.length; j++) {
        folded.write(unit[j]);
        origin.add(i);
      }
    }
    final haystack = folded.toString();
    final candidates = <String>[
      normalize(query),
      if (_hasLatin.hasMatch(query)) ...[
        normalize(latinToTajikCyrillic(query)),
        normalize(latinToTajikCyrillic(query)).replaceAll('а', 'о'),
        normalize(latinToTajikCyrillic(query)).replaceAll('о', 'а'),
      ],
    ];
    for (final needle in candidates) {
      if (needle.isEmpty) continue;
      final at = haystack.indexOf(needle);
      if (at < 0) continue;
      return (start: origin[at], end: origin[at + needle.length - 1] + 1);
    }
    return null;
  }

  /// [normalize] for a single code unit; whitespace stays one space (plain
  /// [normalize] would trim it away) so positions stay aligned.
  static String _foldUnit(String unit) =>
      _multiSpace.hasMatch(unit) ? ' ' : normalize(unit);
}
