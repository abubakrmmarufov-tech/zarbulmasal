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

    // 1. Unicode ZWNJ & Arabic diacritics removal
    s = s.replaceAll(_zwnjRegex, '');
    s = s.replaceAll(_arabicDiacritics, '');

    // 2. Persian / Arabic letter unification
    s = s
        .replaceAll('ي', 'ی') // Arabic Yeh to Persian Yeh
        .replaceAll('ك', 'ک') // Arabic Kaf to Persian Keheh
        .replaceAll('آ', 'ا') // Alef with madda
        .replaceAll('أ', 'ا') // Alef with hamza above
        .replaceAll('إ', 'ا') // Alef with hamza below
        .replaceAll('ٱ', 'ا') // Alef wasla
        .replaceAll('ة', 'ه') // Teh marbuta to Heh
        .replaceAll('ۀ', 'ه'); // Heh with yeh

    // 3. Persian / Eastern digits to ASCII
    const faDigits = '۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩';
    const enDigits = '01234567890123456789';
    for (var i = 0; i < faDigits.length; i++) {
      s = s.replaceAll(faDigits[i], enDigits[i]);
    }

    // 4. Tajik Cyrillic diacritic folding
    s = s
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

  /// Returns true if any of the given targets match the query.
  static bool matchesAny(List<String> targets, String query) {
    if (query.trim().isEmpty) return true;
    for (final t in targets) {
      if (matches(t, query)) return true;
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

    if (matches(target, query)) return 20;

    return 0;
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
}
