import 'package:flutter/material.dart';

/// Qalam — the central design system for Zarbulmasal.
///
/// The palette and typography are tuned to feel like a refined literary
/// publication rooted in Tajik culture: paper, burgundy, dark green, antique gold.
class QalamColors {
  QalamColors._();

  static const Color burgundy = Color(0xFFA43D2F);
  static const Color burgundyDeep = Color(0xFF7D2E25);
  static const Color burgundySoft = Color(0xFFBE5946);
  static const Color forest = Color(0xFF365442);
  static const Color forestSoft = Color(0xFF56765E);
  static const Color antiqueGold = Color(0xFFA43D2F);
  static const Color antiqueGoldSoft = Color(0xFFE5A794);
  static const Color antiqueGoldDeep = Color(0xFF815548);

  static const Color paper = Color(0xFFF3F0E7);
  static const Color cream = Color(0xFFEBE8DD);
  static const Color paperHigh = Color(0xFFFAF8F1);
  static const Color paperLow = Color(0xFFE2DED1);
  static const Color ink = Color(0xFF202720);
  static const Color inkSoft = Color(0xFF596056);
  static const Color inkMute = Color(0xFF6B7168);
  static const Color hairline = Color(0x1A202720);
  static const Color hairlineGold = Color(0x33A43D2F);

  static const Color inkBg = Color(0xFF181E1B);
  static const Color inkCard = Color(0xFF242C26);
  static const Color inkCardHigh = Color(0xFF2D362F);
  static const Color inkWell = Color(0xFF121713);
  static const Color paperText = Color(0xFFF3F0E7);
  static const Color paperTextSoft = Color(0xFFC8C9BE);
  static const Color paperTextMute = Color(0xFFA0A99C);
  static const Color hairlineDark = Color(0x22F3F0E7);
  static const Color hairlineGoldDark = Color(0x44D9B36A);

  static const Color success = Color(0xFF365442);
  static const Color danger = Color(0xFF9A3528);

  /// Stable tokens — deterministic mapping from category name to brand color.
  static const List<CategoryToken> categoryTokens = [
    CategoryToken(name: 'ilm', token: Color(0xFF365442)),
    CategoryToken(name: 'hikmat', token: Color(0xFFA43D2F)),
    CategoryToken(name: 'sabr', token: Color(0xFF6B5B3E)),
    CategoryToken(name: 'padaru_modar', token: Color(0xFF815548)),
    CategoryToken(name: 'dusti', token: Color(0xFF56765E)),
    CategoryToken(name: 'mehnat', token: Color(0xFF7D2E25)),
    CategoryToken(name: 'pul', token: Color(0xFFA43D2F)),
    CategoryToken(name: 'rostqavli', token: Color(0xFF365442)),
    CategoryToken(name: 'muhabbat', token: Color(0xFFBE5946)),
    CategoryToken(name: 'zindagi', token: Color(0xFF815548)),
    CategoryToken(name: 'din', token: Color(0xFF6B5B3E)),
    CategoryToken(name: 'jasorat', token: Color(0xFFA43D2F)),
    CategoryToken(name: 'vaqt', token: Color(0xFFA43D2F)),
    CategoryToken(name: 'xomushhi', token: Color(0xFF56765E)),
    CategoryToken(name: 'odob', token: Color(0xFF7D2E25)),
    CategoryToken(name: 'tanbali', token: Color(0xFFBE5946)),
    CategoryToken(name: 'oila', token: Color(0xFF365442)),
    CategoryToken(name: 'ehtirom', token: Color(0xFF815548)),
    CategoryToken(name: 'omuzish', token: Color(0xFF56765E)),
    CategoryToken(name: 'muvaffaqiyat', token: Color(0xFFA43D2F)),
  ];

  /// Legacy lookup — keeps old `getCategoryColor(index)` calls working.
  static Color legacyCategoryColor(int index) {
    const legacy = <Color>[
      Color(0xFFA43D2F),
      Color(0xFF365442),
      Color(0xFFA43D2F),
      Color(0xFFBE5946),
      Color(0xFF815548),
      Color(0xFF56765E),
      Color(0xFF6B5B3E),
      Color(0xFF7D2E25),
    ];
    return legacy[index % legacy.length];
  }

  /// New stable lookup by category ID string.
  static Color tokenForId(String categoryId) {
    final idx = categoryTokens.indexWhere((c) => c.name == categoryId);
    if (idx >= 0) return categoryTokens[idx].token;
    final h = categoryId.codeUnits.fold<int>(0, (a, b) => (a + b) & 0x7fffffff);
    return categoryTokens[h % categoryTokens.length].token;
  }
}

class CategoryToken {
  final String name;
  final Color token;
  const CategoryToken({required this.name, required this.token});
}
