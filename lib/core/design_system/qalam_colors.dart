import 'package:flutter/material.dart';

/// Qalam — the central design system for Zarbulmasal.
///
/// The palette and typography are tuned to feel like a refined literary
/// publication rooted in Tajik culture: paper, ink, burgundy, forest green, antique gold.
class QalamColors {
  QalamColors._();

  // ── «Муҳр» — day: ivory paper, lamp-black ink, one cinnabar vermilion ──
  // Contrast against `paper` (WCAG 2.x): ink 15.2, inkSoft 7.8, inkMute 5.1,
  // vermilion 5.5.
  static const Color paper = Color(0xFFF3ECDD);
  static const Color paperRaised = Color(0xFFFAF6EC);
  static const Color paperSunk = Color(0xFFE8DFCB);
  static const Color ink = Color(0xFF1A1714);
  static const Color inkSoft = Color(0xFF4F473E);
  static const Color inkMute = Color(0xFF6B6256);

  /// The one colour that speaks: the seal, links, and active states only.
  static const Color vermilion = Color(0xFFB02E1C);
  static const Color vermilionDeep = Color(0xFF8C2414);

  static const Color hairline = Color(0x261A1714);
  static const Color hairlineSoft = Color(0x141A1714);

  // ── «Шаб» — night: lapis-black ground, ivory text, the same seal ──
  // Contrast against `lapis`: ivory 15.2, ivorySoft 9.2, ivoryMute 5.7,
  // vermilionNight 6.0.
  static const Color lapis = Color(0xFF0B1222);
  static const Color lapisRaised = Color(0xFF131C33);
  static const Color lapisHigh = Color(0xFF1B2540);
  static const Color lapisSunk = Color(0xFF070C18);
  static const Color ivory = Color(0xFFEFE7D6);
  static const Color ivorySoft = Color(0xFFBDB5A4);
  static const Color ivoryMute = Color(0xFF948D7E);
  static const Color vermilionNight = Color(0xFFEC6A52);
  static const Color hairlineDark = Color(0x33EFE7D6);

  // ── Legacy aliases ─────────────────────────────────────────────────────
  // The Qalam v2 names now resolve to «Муҳр»/«Шаб» values so every screen
  // adopts the new palette; green, gold and burgundy are retired as roles.
  // Migrate call sites to the tokens above as screens are redesigned.
  static const Color burgundy = vermilion;
  static const Color burgundyDeep = vermilionDeep;
  static const Color burgundySoft = Color(0xFFC8513F);
  static const Color forest = inkSoft;
  static const Color forestSoft = inkMute;
  static const Color forestDeep = ink;
  static const Color antiqueGold = vermilion;
  static const Color antiqueGoldSoft = vermilionNight;
  static const Color antiqueGoldDeep = vermilionDeep;
  static const Color terracotta = vermilion;
  static const Color paperHigh = paperRaised;
  static const Color paperLow = paperSunk;
  static const Color paperWarm = Color(0xFFF7F1E4);
  static const Color cream = Color(0xFFEDE5D4);
  static const Color hairlineGold = Color(0x33B02E1C);
  static const Color inkBg = lapis;
  static const Color inkCard = lapisRaised;
  static const Color inkCardHigh = lapisHigh;
  static const Color inkWell = lapisSunk;
  static const Color paperText = ivory;
  static const Color paperTextSoft = ivorySoft;
  static const Color paperTextMute = ivoryMute;
  static const Color hairlineGoldDark = Color(0x4DEC6A52);

  // --- Semantic States ---
  static const Color success = inkSoft;
  static const Color danger = vermilion;
  static const Color warning = vermilionDeep;

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
