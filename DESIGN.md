---
design_system:
  name: "Qalam Design System for Zarbulmasal"
  version: "2.0.0"
  character: "Premium Literary Journal + Cultural Museum Archive + Quiet Educational Product"
  heritage: "Tajik & Persian Classical Literary Heritage"
  
tokens:
  colors:
    light:
      paper: "#F4EFE6"
      paperHigh: "#FAF8F2"
      paperLow: "#EAE4D7"
      paperWarm: "#FBF9F4"
      ink: "#1B221E"
      inkSoft: "#4A554E"
      inkMute: "#6C7870"
      hairline: "rgba(27, 34, 30, 0.12)"
      hairlineGold: "rgba(196, 154, 69, 0.28)"
      burgundy: "#9E3424"
      burgundyDeep: "#782417"
      burgundySoft: "#BD5343"
      forest: "#2E523A"
      forestSoft: "#4E735B"
      forestDeep: "#1E3B27"
      antiqueGold: "#C49A45"
      antiqueGoldSoft: "#E0BD70"
      antiqueGoldDeep: "#8F6B21"
      terracotta: "#B85C38"
      success: "#2E523A"
      danger: "#9E3424"
      warning: "#C49A45"
    dark:
      inkBg: "#121614"
      inkCard: "#1B221E"
      inkCardHigh: "#252E28"
      inkWell: "#0B0E0C"
      paperText: "#F2EFE9"
      paperTextSoft: "#C2C9C3"
      paperTextMute: "#8F9A91"
      hairlineDark: "rgba(242, 239, 233, 0.12)"
      hairlineGoldDark: "rgba(224, 189, 112, 0.28)"
      accentGoldDark: "#D8B264"
      accentBurgundyDark: "#DE7A6A"
      accentForestDark: "#7CA98B"
      
  typography:
    families:
      serif: "NotoSerif"
      sans: "NotoSans"
      persian: "NotoNaskhArabic"
      fallback: ["NotoNaskhArabic", "NotoSans"]
    scale:
      heroProverb: { size: 28, height: 1.48, weight: 500, family: "NotoSerif" }
      monographTitle: { size: 34, height: 1.25, weight: 700, family: "NotoSerif" }
      pageTitle: { size: 30, height: 1.25, weight: 700, family: "NotoSans" }
      literaryTitle: { size: 22, height: 1.35, weight: 600, family: "NotoSerif" }
      sectionTitle: { size: 20, height: 1.30, weight: 600, family: "NotoSans" }
      verseText: { size: 20, height: 1.85, weight: 400, family: "NotoSerif" }
      body: { size: 16, height: 1.65, weight: 400, family: "NotoSans" }
      bodySecondary: { size: 14, height: 1.60, weight: 400, family: "NotoSans" }
      label: { size: 13, height: 1.35, weight: 600, family: "NotoSans" }
      eyebrow: { size: 11, height: 1.20, weight: 700, letterSpacing: 1.2, family: "NotoSans" }
      meta: { size: 12, height: 1.35, weight: 400, family: "NotoSans" }
      navLabel: { size: 12, height: 1.20, weight: 500, family: "NotoSans" }
      
  spacing:
    pageH: 24.0
    sectionV: 32.0
    sectionVTight: 20.0
    cardPad: 20.0
    cardPadSm: 14.0
    inlineGap: 12.0
    itemGap: 14.0
    
  radii:
    none: 0.0
    xs: 2.0
    sm: 4.0
    md: 8.0
    lg: 12.0
    xl: 16.0
    pill: 999.0
---

# Qalam Design System — Zarbulmasal

## 1. Product Character & Philosophy
Zarbulmasal is an authoritative digital home for Tajik proverbs, classical poetry, folklore, and national history. The visual language balances:
- **Literary Journal**: Restrained typography, dignified proportion, generous whitespace, confident serif headers, and clear editorial rhythm.
- **Museum Archive**: Scholarly provenance, transparent verification badges, manuscript-informed color accents, and timeline-driven discovery.
- **Modern Educational Tool**: Fast, touch-friendly, mobile-first thumb zone, calm layout without hyperactive gamification.

## 2. Core Visual Principles
1. **Content First**: Literature, poetry, proverbs, and history are the heroes. UI chrome never competes with text.
2. **Typography as Architecture**: Clear hierarchical differentiation across titles, incipits, verses, historical periods, and academic citations.
3. **No Card Soup**: Avoid nested rounded containers. Use hairlines, surface tone shifts, and whitespace for visual structure.
4. **Cultural Dignity, Not Superficial Cliché**: No pseudo-historical faux parchment, excessive gold gradients, or decorative noise.
5. **Bilingual Script Parity**: Tajik Cyrillic and Persian Arabic script (RTL) both receive first-class layout, metrics, and typographic care.
6. **Scholarly Transparency**: Verification levels (`Editorially Approved`, `Needs Review`, `Book Attested`, `Unverified`) are always explicit.

## 3. Surface & Elevation System
- **Paper High (`#FAF8F2`)**: Primary reading fields, elevated cards, and hero panels.
- **Paper Base (`#F4EFE6`)**: Main application background for light mode.
- **Paper Low (`#EAE4D7`)**: Secondary sections, footers, and contrasting content blocks.
- **Hairline Dividers**: 0.5px to 1px rules with soft ink tint (`0x1F1B221E`) rather than drop shadows.
- **Dark Mode Surfaces**: `inkBg` (`#121614`), `inkCard` (`#1B221E`), `inkCardHigh` (`#252E28`).

## 4. Typography Matrix
| Role | Family | Size | Height | Weight | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Hero Proverb** | NotoSerif | 28px | 1.48 | 500 | Daily proverb hero, flagship proverb display |
| **Monograph Title** | NotoSerif | 34px | 1.25 | 700 | Poet monograph name, major literary author |
| **Page Title** | NotoSans | 30px | 1.25 | 700 | Main screen titles, major headers |
| **Literary Title** | NotoSerif | 22px | 1.35 | 600 | Poem titles, book titles, ghazal headings |
| **Section Title** | NotoSans | 20px | 1.30 | 600 | Hub section titles, chapter labels |
| **Verse Line** | NotoSerif | 18–24px | 1.85 | 400 | Poem reader body lines, hemistich pairs |
| **Body** | NotoSans | 16px | 1.65 | 400 | Biographies, explanations, historical summaries |
| **Body Secondary** | NotoSans | 14px | 1.60 | 400 | Subtitles, translations, secondary descriptions |
| **Eyebrow** | NotoSans | 11px | 1.20 | 700 | Section numbering, folio category labels |
| **Meta** | NotoSans | 12px | 1.35 | 400 | Dates, page numbers, authors, counts |
| **Nav Label** | NotoSans | 12px | 1.20 | 500 | Bottom navigation items |

## 5. Color Roles & Palette
- **Burgundy (`#9E3424`)**: Primary brand identity, focal accents, key calls-to-action.
- **Forest (`#2E523A`)**: Verified state, secondary literature sections, nature/ethics categories.
- **Antique Gold (`#C49A45`)**: Folio highlights, verse dates, illuminated badges, active tabs.
- **Ink (`#1B221E`)**: Primary text, dark hero containers, authoritative headers.
- **Parchment Cream (`#F4EFE6`)**: Natural background for reading comfort and low eye fatigue.

## 6. Signature Surfaces
- **Literature Hub**: Curated library entry with daily verse, canonical poem carousel, and five cultural gateways.
- **Poet Monograph Dossier**: Hero dossier with name in Cyrillic & Persian, historical era link, auditable biography, and verified catalog.
- **Poem Reader**: Distraction-free reader with Cyrillic / Persian / Parallel switcher, variable font size, and collation source panel.
- **Historical Timeline**: Chronological era strip, textbook canon integration, and categorized entry dossiers.
- **Proverb Folio**: Bold proverb lockup with progressive disclosure of wisdom, examples, dialect variants, and book citations.

## 7. Accessibility & Mobile Standards
- Minimum touch target: 48x48 dp.
- 200% font scaling resilience without text clipping or horizontal overflow.
- WCAG AA contrast ratio (> 4.5:1 for body text, > 3.0:1 for large display titles).
- Full RTL mirror support including icons, directional padding, text alignment, and numbers.
