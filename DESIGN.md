---
design_system:
  name: "Qalam Design System for Zarbulmasal — «Муҳр»"
  version: "3.0.0"
  character: "A private gallery of the Tajik word: ivory paper, monumental type, one vermilion seal"
  heritage: "Tajik & Persian Classical Literary Heritage"
  source_of_truth: "docs/design/ZARBULMASAL_UX_RESEARCH_REPORT.md (v2)"

tokens:
  colors:
    day_muhr:
      paper: "#F3ECDD"
      paperRaised: "#FAF6EC"
      paperSunk: "#E8DFCB"
      ink: "#1A1714"        # 15.2:1 on paper
      inkSoft: "#4F473E"    # 7.8:1
      inkMute: "#6B6256"    # 5.1:1
      vermilion: "#B02E1C"  # 5.5:1 — seal, links, active states only
      hairline: "rgba(26, 23, 20, 0.15)"
    night_shab:
      lapis: "#0B1222"
      lapisRaised: "#131C33"
      lapisSunk: "#070C18"
      ivory: "#EFE7D6"          # 15.2:1 on lapis
      ivorySoft: "#BDB5A4"      # 9.2:1
      ivoryMute: "#948D7E"      # 5.7:1
      vermilionNight: "#EC6A52" # 6.0:1
    retired_roles: ["forest green (verified)", "antique gold", "burgundy blocks"]

  typography:
    families:
      display: "EBGaramond"        # exhibits, titles (500/600, italic 400)
      reading: "PTSerif"           # verse, long reading (400/700, italic)
      ui: "GolosText"              # interface (400–700)
      persianReading: "NotoNaskhArabic"
      persianUi: "Vazirmatn"
      persianExhibit: "NotoNastaliqUrdu"  # pending review by a Persian reader
      fallbacks: ["NotoSans", "NotoSerif"]
    proof: "tool/design/font_proof_test.dart (Tajik Ҷ Ҳ Қ Ғ Ӣ Ӯ + Persian Nastaliq/Naskh)"
    build: "tool/design/build_fonts.py (subset static instances)"
---

# Qalam Design System — Zarbulmasal («Муҳр»)

> **v3 («Муҳр»)** supersedes the colour and type values below where they
> differ. «Муҳр» by day, lapis-black «Шаб» by night; the ikat «Атлас» appears
> only on collection covers, share cards and the splash, never behind reading
> text. The v2 names in `QalamColors` (burgundy, forest, antiqueGold…) remain
> as aliases of the new tokens until call sites migrate.
>
> **Components (v3):** `QalamSeal` (pressed = editorially approved, outline =
> page-checked with review pending, absent = under review — sentence only;
> artwork is a replaceable PLACEHOLDER asset), `QalamRecordTabs`
> («Дар бора | Сабт»), `QalamIndexRow` (catalogue rows, no boxes),
> `QalamMonogramPlate` (replaces portraits whose rights are not cleared).
> Verification wording comes only from `ProvenanceState`.

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
- **Paper Raised (`#FAF6EC`)**: Primary reading fields, elevated cards, and hero panels.
- **Paper (`#F3ECDD`)**: Main application background for light mode («Муҳр»).
- **Paper Sunk (`#E8DFCB`)**: Secondary sections, footers, and contrasting content blocks.
- **Hairline Dividers**: 0.5px to 1px rules with a soft ink tint (`#261A1714`, ≈15% ink) rather than drop shadows; `hairlineSoft` (`#141A1714`) for lighter rules.
- **Dark Mode Surfaces («Шаб`)**: `lapis` (`#0B1222`), `lapisRaised` (`#131C33`), `lapisHigh` (`#1B2540`), `lapisSunk` (`#070C18`).

## 4. Typography Matrix
| Role | Family | Size | Height | Weight | Usage |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Hero Proverb** | EBGaramond | 25px | 1.48 | 500 | Daily proverb hero, flagship proverb display |
| **Monograph Title** | EBGaramond | 32px | 1.25 | 600 | Poet monograph name, major literary author |
| **Page Title** | GolosText | 30px | 1.25 | 700 | Main screen titles, major headers |
| **Literary Title** | EBGaramond | 20px | 1.35 | 600 | Poem titles, book titles, ghazal headings |
| **Section Title** | GolosText | 21px | 1.30 | 600 | Hub section titles, chapter labels |
| **Verse Line** | PTSerif | 19px | 1.85 | 400 | Poem reader body lines (see Hemistich below) |
| **Hemistich** | PTSerif | 17px | 1.75 | 400 | Half-verse lines in paired verse view |
| **Body** | GolosText | 16px | 1.65 | 400 | Biographies, explanations, historical summaries |
| **Body Secondary** | GolosText | 14px | 1.60 | 400 | Subtitles, translations, secondary descriptions |
| **Label** | GolosText | 13px | 1.35 | 600 | Button text, form labels, emphasized short text |
| **Eyebrow** | GolosText | 11px | 1.20 | 700 | Section numbering, folio category labels |
| **Meta** | GolosText | 12px | 1.35 | 400 | Dates, page numbers, authors, counts |
| **Nav Label** | GolosText | 12px | 1.20 | 500 | Bottom navigation items |

Persian-script text in a Cyrillic family falls back to the Persian faces, never
to a missing glyph: `NotoNaskhArabic` (Persian reading), `Vazirmatn` (Persian
interface), and `NotoNastaliqUrdu` (exhibited Persian verse, pending review by a
Persian reader).

## 5. Color Roles & Palette
Live `QalamColors` (v3) tokens; the v2 roles **Burgundy, Forest, Antique Gold** are retired as roles — their old hex values (`#9E3424`, `#2E523A`, `#C49A45`) no longer describe the palette and now resolve to the tokens below.
- **Paper (`#F3ECDD`)**: Main «Муҳр» background; `paperRaised` (`#FAF6EC`) elevated cards, `paperSunk` (`#E8DFCB`) secondary sections.
- **Ink (`#1A1714`)**: Primary text and dark authoritative headers; `inkSoft` (`#4F473E`) secondary, `inkMute` (`#6B6256`) muted.
- **Vermilion (`#B02E1C`)**: The one colour that speaks — the seal, links, and active states only; `vermilionDeep` (`#8C2414`) for pressed/focus.
- **«Шаб» night**: `lapis` (`#0B1222`) ground, `lapisRaised` (`#131C33`), `lapisHigh` (`#1B2540`), `lapisSunk` (`#070C18`); ivory text `ivory` (`#EFE7D6`), `ivorySoft` (`#BDB5A4`), `ivoryMute` (`#948D7E`), and `vermilionNight` (`#EC6A52`) seal.
- **Stable category tokens**: deterministic brand colours per category (`categoryTokens`), e.g. `ilm`/`odob` (`#2E523A`), `hikmat` (`#9E3424`), `pul`/`vaqt` (`#C49A45`). These per-category values remain accurate; they are not the palette roles above.

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
