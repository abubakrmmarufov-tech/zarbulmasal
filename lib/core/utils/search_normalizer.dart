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

  /// Exact-aware matching that tests:
  /// 1. Direct case-insensitive containment
  /// 2. Normalized diacritic & script-folded containment
  /// 3. Space-agnostic containment (for compound words like "می‌شود" vs "می شود" or "ضرب‌المثل" vs "ضرب المثل")
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
    if (normQuery.isEmpty) return false;
    if (normTarget.contains(normQuery)) return true;

    // 3. Space-agnostic path for compound words
    final tightTarget = normTarget.replaceAll(' ', '');
    final tightQuery = normQuery.replaceAll(' ', '');
    if (tightQuery.isNotEmpty && tightTarget.contains(tightQuery)) {
      return true;
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
}
