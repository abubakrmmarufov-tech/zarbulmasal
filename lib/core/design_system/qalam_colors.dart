import 'package:flutter/material.dart';

/// Qalam — the central design system for Zarbulmasal.
///
/// The palette and typography are tuned to feel like a refined literary
/// publication rooted in Tajik culture: paper, ink, burgundy, forest green, antique gold.
class QalamColors {
  QalamColors._();

  // --- Primary Heritage Tones ---
  static const Color burgundy = Color(0xFF9E3424);
  static const Color burgundyDeep = Color(0xFF782417);
  static const Color burgundySoft = Color(0xFFBD5343);

  static const Color forest = Color(0xFF2E523A);
  static const Color forestSoft = Color(0xFF4E735B);
  static const Color forestDeep = Color(0xFF1E3B27);

  static const Color antiqueGold = Color(0xFFC49A45);
  static const Color antiqueGoldSoft = Color(0xFFE0BD70);
  static const Color antiqueGoldDeep = Color(0xFF8F6B21);

  static const Color terracotta = Color(0xFFB85C38);

  // --- Light Surfaces & Ink ---
  static const Color paper = Color(0xFFF4EFE6);
  static const Color paperHigh = Color(0xFFFAF8F2);
  static const Color paperLow = Color(0xFFEAE4D7);
  static const Color paperWarm = Color(0xFFFBF9F4);
  static const Color cream = Color(0xFFEBE8DD);

  static const Color ink = Color(0xFF1B221E);
  static const Color inkSoft = Color(0xFF4A554E);
  static const Color inkMute = Color(0xFF6C7870);

  static const Color hairline = Color(0x1F1B221E);
  static const Color hairlineSoft = Color(0x121B221E);
  static const Color hairlineGold = Color(0x47C49A45);

  // --- Dark Surfaces & Paper Text ---
  static const Color inkBg = Color(0xFF121614);
  static const Color inkCard = Color(0xFF1B221E);
  static const Color inkCardHigh = Color(0xFF252E28);
  static const Color inkWell = Color(0xFF0B0E0C);

  static const Color paperText = Color(0xFFF2EFE9);
  static const Color paperTextSoft = Color(0xFFC2C9C3);
  static const Color paperTextMute = Color(0xFF8F9A91);

  static const Color hairlineDark = Color(0x24F2EFE9);
  static const Color hairlineGoldDark = Color(0x4DE0BD70);

  // --- Semantic States ---
  static const Color success = Color(0xFF2E523A);
  static const Color danger = Color(0xFF9E3424);
  static const Color warning = Color(0xFFC49A45);

  /// Stable tokens — deterministic mapping from category name to brand color.
  static const List<CategoryToken> categoryTokens = [
    CategoryToken(name: 'ilm', token: Color(0xFF2E523A)),
    CategoryToken(name: 'hikmat', token: Color(0xFF9E3424)),
    CategoryToken(name: 'sabr', token: Color(0xFF8F6B21)),
    CategoryToken(name: 'padaru_modar', token: Color(0xFF782417)),
    CategoryToken(name: 'dusti', token: Color(0xFF4E735B)),
    CategoryToken(name: 'mehnat', token: Color(0xFFB85C38)),
    CategoryToken(name: 'pul', token: Color(0xFFC49A45)),
    CategoryToken(name: 'rostqavli', token: Color(0xFF2E523A)),
    CategoryToken(name: 'muhabbat', token: Color(0xFFBD5343)),
    CategoryToken(name: 'zindagi', token: Color(0xFF782417)),
    CategoryToken(name: 'din', token: Color(0xFF8F6B21)),
    CategoryToken(name: 'jasorat', token: Color(0xFF9E3424)),
    CategoryToken(name: 'vaqt', token: Color(0xFFC49A45)),
    CategoryToken(name: 'xomushhi', token: Color(0xFF4E735B)),
    CategoryToken(name: 'odob', token: Color(0xFF2E523A)),
    CategoryToken(name: 'tanbali', token: Color(0xFFBD5343)),
    CategoryToken(name: 'oila', token: Color(0xFF2E523A)),
    CategoryToken(name: 'ehtirom', token: Color(0xFF782417)),
    CategoryToken(name: 'omuzish', token: Color(0xFF4E735B)),
    CategoryToken(name: 'muvaffaqiyat', token: Color(0xFF9E3424)),
  ];

  /// Legacy lookup — keeps old `getCategoryColor(index)` calls working.
  static Color legacyCategoryColor(int index) {
    const legacy = <Color>[
      Color(0xFF9E3424),
      Color(0xFF2E523A),
      Color(0xFFC49A45),
      Color(0xFFBD5343),
      Color(0xFF782417),
      Color(0xFF4E735B),
      Color(0xFF8F6B21),
      Color(0xFFB85C38),
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
