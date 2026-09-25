# Phase 2 — Visual system

> Screenshots for this phase were removed from the repository on 25 Sep 2026 to keep it small. They remain in git history: `git show dcd3805:docs/design/phase2/<file>`.

Date: 24 Sep 2026 · Screenshots: `docs/design/phase2/` (390 px and 1440 px, light and dark, Tajik and Persian; `*_390_detail.png` are close-ups)

## Checks

| Check | After Phase 1 | After Phase 2 |
|---|---|---|
| `flutter analyze` | No issues | **No issues found** |
| `flutter test` | 598 passed, 8 failed | **611 passed, 8 failed**, 0 new failures |

The 8 failures are the same pre-existing content/data mismatches listed in `PHASE_1_REPORT.md`.

## What changed

- **Tokens («Муҳр» day / «Шаб» night).** `QalamColors` has the new tokens: ivory paper, lamp-black ink, one cinnabar vermilion, and lapis-black with ivory text at night. All text pairs are AA or better, and tests check this in both themes.
  - The v2 names (burgundy, forest, gold…) are kept as aliases pointing at the new values, so every screen switched at once.
  - **Green and gold are retired as roles.** The remaining forest-coloured "verified-style" badges now read as neutral ink; their state is carried by icon and words.
  - The browser/PWA background and the area beside the column follow the theme, including at 1440 px.
- **Typography.** The approved fonts are bundled as subset static instances (`tool/design/build_fonts.py`, **+1.6 MB**, SIL OFL with licences):
  - EB Garamond for display: titles, exhibits.
  - PT Serif for reading: the poem text.
  - Golos Text for the interface.
  - Vazirmatn and Noto Naskh for Persian.
  - Noto Nastaliq Urdu is bundled for Phase 3 exhibits.

  Noto remains as the fallback. The test harness now loads every family, so tests measure real glyphs.
- **Seal component (`QalamSeal`), 3 states.**
  - pressed = editorially approved;
  - outline = page-checked, editorial review pending;
  - absent = under review, shown with a sentence only.

  **The artwork is a PLACEHOLDER** (`assets/design/seal_placeholder_*.png`, a dashed "МУҲР · PLACEHOLDER" mask tinted vermilion). Your seal drops in by replacing those two files (see `docs/design/SEAL_PLACEHOLDER.md`). Today every readable poem shows the **outline** seal, because none is editorially approved.
- **«Дар бора | Сабт» tabs** on the poem reader and the proverb page:
  - **Poem «Сабт» = full record** (your decision): the status sentence with the seal, both printed witnesses as citations (title, author as printed, place: publisher, year, pages, ISBN), the collation sentence, the variant note, the checks (done ✓ / pending "— дар навбат"), the page-check date, and one plain rights sentence.
  - Tapping the seal or «Манбаъ» opens «Сабт». The same record opens as a sheet for works under review.
  - **Proverb «Сабт»**: the status sentence exactly as recorded («Дар китоби зикршуда омадааст (саҳифа санҷида нашудааст)») plus the source.
- **Monogram plates (Q2).** Portraits show only when the rights are cleared, and all 67 records say `unknown`, so every poet now gets a monogram plate: the Cyrillic initial plus the Persian initial from the data. This also removed a screen-reader leak of a PDF file name.
- **No card soup:**
  - New `QalamIndexRow` (catalogue rows: serif title, one-line description, hairline, no box) on Explore and Learn. Decorative icons are removed; the "Continue" row keeps its icon.
  - The book detail's 5 boxed tiles are now one definition list.
  - The reader's boxed placeholders are unboxed.
- `DESIGN.md` is updated to v3 («Муҳр»). The dead `QalamSourceBadge` (hard-coded "verified" string) is deleted.

## Existing tests changed (and why)

| Test | Change | Reason |
|---|---|---|
| `source_panel_test` (3 tests written the morning of 24 Sep) | now assert the full record, no raw values, and that the only image is the seal | Your decision: «Сабт» shows the full record |
| Proverb "shows only the source title, not provenance caveats" | the caveat is absent from «Дар бора» and present in «Сабт» | Same decision; the sentence matches the data (`bookAttested`, no page) |
| Reader "Source button opens SourcePanel bottom sheet" | expects the «Сабт» tab instead of a sheet close button | The record is a tab now |
| Portrait tests | rights-unknown → monogram; the image path uses a rights-cleared fixture with a localized citation | Q2, plus removing the file-name leak |
| Lexicon paper colour, Learn flashcards entry | paper token; find the row by title | New tokens; rows without decorative icons |

New tests: `phase2_visual_system_test.dart` (contrast in both themes, type roles, seal states, seal → «Сабт» with pending checks, no cards in Explore/Learn), plus font/licence and seal-asset checks in `pwa_assets_test.dart`.

## Skipped or deferred (and why)

1. **Home, reader title card, «Шаб» exhibit, ikat covers, «Баёзи ман»** belong to Phase 3.
2. **Nastaliq is bundled but not yet used.** It goes into the Home exhibit and the proverb Persian line in Phase 3, and still needs a Persian reader's review.
3. **Card soup remains on** History entries, the Saved page, and the Oral heritage page. The History redesign is Phase 4 and Saved becomes «Баёзи ман» in Phase 3. Oral heritage **now has displayable content**, so it correctly appears again.
4. **Category colours** (`categoryTokens`, still green/gold) are replaced by the ikat covers in Phase 3.
5. **Quiz and flashcard "correct/mastered" green** stays: it's a learning semantic with icon and words. I can switch it to ink if you prefer.
6. The code review (flutter-reviewer) found **0 critical, 2 high, 2 medium, 2 low**:
   - Fixed: faux-bold EB Garamond (the title weight is now 600, which ships), the dead badge, and the raw citation fallback.
   - Kept on purpose: forest now resolving to ink (the report retires green), and the ISO page-check date (shown as recorded in the data).

## CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED

No new items this phase; the lists in `PHASE_0_PLAN.md` §6 and `PHASE_1_REPORT.md` still stand.
