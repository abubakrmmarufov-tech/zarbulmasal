/// Qalam spacing, radii, and layout tokens.
///
/// All layout and dimension decisions flow from these tokens.
class QalamSpacing {
  QalamSpacing._();

  // --- Page Margins & Section Gaps ---
  /// Standard horizontal page padding on mobile.
  static const double pageH = 24.0;

  /// Vertical section gap.
  static const double sectionV = 32.0;

  /// Tight vertical section gap.
  static const double sectionVTight = 20.0;

  // --- Card & Container Padding ---
  /// Card internal padding.
  static const double cardPad = 20.0;

  /// Compact card internal padding.
  static const double cardPadSm = 14.0;

  /// Card border radius (legacy token).
  static const double cardRadius = 8.0;

  /// Card gap in vertical lists.
  static const double cardGap = 14.0;

  // --- Inline Item Spacing ---
  /// Gap between icon and label in inline rows.
  static const double iconLabelGap = 8.0;

  /// Gap between label groups on a meta line.
  static const double metaGap = 12.0;

  /// Gap between a section title and its content.
  static const double titleContentGap = 12.0;

  // --- Chip & Badge Padding ---
  static const double badgePadH = 10.0;
  static const double badgePadV = 4.0;
  static const double badgeRadius = 4.0;

  // --- Navigation Bar ---
  static const double navHeight = 76.0;

  // --- Unified Radius Tokens ---
  static const double radiusNone = 0.0;
  static const double radiusXs = 2.0;
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusPill = 999.0;

  // --- Responsive Screen Breakpoints ---
  static const double mobileMax = 430;
  static const double tabletMin = 600;
  static const double desktopMin = 900;

  /// Responsive page horizontal padding.
  static double responsivePageH(double screenWidth) {
    if (screenWidth >= desktopMin) return 48.0;
    if (screenWidth >= tabletMin) return 32.0;
    return pageH;
  }
}
