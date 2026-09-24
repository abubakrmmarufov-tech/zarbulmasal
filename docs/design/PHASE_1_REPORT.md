# Phase 1 — Roadmap NOW (N1–N8)

Date: 24 Sep 2026 · Screenshots: `docs/design/phase1/` (390 px and 1440 px, light and dark, Tajik and Persian)

## Checks

| Check | Baseline (before Phase 0) | After Phase 1 |
|---|---|---|
| `flutter analyze` | 4 errors, 10 infos | **No issues found** |
| `flutter test` | 547 passed, 14 failed | **598 passed, 8 failed**, 0 new failures |

**The 8 remaining failures were all failing before this work.** They are data/test mismatches in the uncommitted content work, and I did not touch the data:
- Ibn Sina rubai attribution/page; Qanoat distinct works; Qanoat title/page span; the quarantine reason for rejected candidates; page-backed works evidence and rights; Firdausi/Kamol second witnesses.
- Persian history section translations: the data now has two translated sections, but the test expects exactly one.
- Khirad provider label: `Хирад · khirad.tj` is not rendered.

## What changed

- **N1 · one verification vocabulary.** New `ProvenanceState` (`literature/domain/provenance_state.dart`). The seal state comes only from `verification.evidenceLevel`, `pageVerified`, the second witness, and the collation result, never from `textStatus`.
  - The reader header's green «Матн санҷида шудааст» chip is replaced by one status sentence («Бо нашри чопӣ ва нусхаи дуввум муқобала шудааст · санҷиши муҳаррир дар навбат.»).
  - The source sheet repeats the same sentence word for word.
  - List and count labels that said «тасдиқшуда» (approved) now say "checked against the printed source", or use neutral wording.
  - Today no work shows the "approved" sentence, because the data has 0 `editoriallyApproved` records.
- **N2 · no internal data on screen.**
  - The reader no longer renders `editorialNotes`: they were **English internal audit notes** (see flags below).
  - Collation codes (`exact`, `minor-variant`) are mapped to Tajik/Persian sentences.
  - An automated sweep test opens all 28 readable works and their source sheets in both languages. It asserts that no enum, path, policy text, or hash is visible.
- **N3 · bayt layout.** New `VerseLayout` plus `VerseView`:
  - Classical forms with an even line count show as bayts; recorded stanza breaks are kept.
  - Everything else stays line by line, so no couplets are guessed.
  - Wrapped lines get a 1.5 em hanging indent.
  - At wide measures, a bayt sits side by side when both hemistichs fit on one line (RTL order in Persian).
  - A test proves that every character of every readable work survives the layout.
- **N4 · reading script ≠ interface language.**
  - New `readingScriptProvider`: it is saved, and follows the interface language until you choose.
  - The proverb page's buttons that switched the **whole app** are removed, and the proverb text follows the reading script.
  - Settings → Reading gains «Хатти матнҳо» (script for texts) with "the app language will not change". The language row is renamed «Забони барнома» (app language). Parallel mode is marked "only for texts that have both scripts from the source".
  - The reader's script chips are a per-screen override and now appear in the Tajik interface too, whenever a second script exists.
- **N5 · generated Persian labelled.** While a `persianScriptSource: "generated"` text is shown, the label «Хатти форсӣ — табдили механикӣ, на матни аслӣ» sits above it.
- **N6 · correct resume.**
  - New `readingPositionProvider`. Only poems, proverbs, and history entries set it, so poet pages, lists, levels, search, and Back never do.
  - The poem reader stores the first visible bayt/line. Home shows «Шеър · Байти 4 аз 6» and reopens there (`?at=4`).
  - The onboarding no longer promises "continue reading" (or oral heritage).
  - "Clear history" also clears the position.
- **N7 · no counters.** The limit stays in all 6 search fields but the `0/256` counter is gone, which also fixes the clipped global-search field. A guard test fails if `maxLength:` comes back.
- **N8 · empty sections.**
  - Oral heritage is hidden in Explore and in the Literature hub while it is empty. The hub numbering is renumbered so there is no gap.
  - A direct link now lands on the Literature section.
- **Also fixed on the way:**
  - The hub's "bayt of the day" author row overflowed at 390 px.
  - `dailyProverbProvider` no longer auto-disposes; it left timers that failed 4 baseline tests.
  - All 6 baseline UI test failures are fixed: 3 by the provider fix above, 2 by correcting wrong test finders, and 1 by splitting a test that mounted the app twice.
  - The iCloud ` 2` duplicate files are removed and backed up outside the repo.

## Existing tests changed (and why)

| Test | Change | Reason |
|---|---|---|
| Reader "renders … QalamSourceBadge" (tj, fa) | expects the new status sentence and `ProvenanceStatusLine` | The badge is replaced (N1). The fixture really is `editoriallyApproved`, so its sentence still says "approved". |
| Hub "labels empty oral heritage as unavailable" | now asserts it is hidden and the numbering is gapless | Q3 decision (N8) |
| "Persian home hides stale Tajik recent-activity metadata" | now asserts a poet visit creates no Continue card | The old test encoded the F5 bug |
| Persian reader "withholds Tajik-only …" | matches the verse by its opening words | The hanging indent splits wrapped lines into two parts (N3) |
| Settings sections (tj, fa) | expects «ЗАБОНИ БАРНОМА» and the new «Хатти матнҳо» | N4 label change |
| Literature poet counts | «Осор барои хондан (n)» | «тасдиқшуда» overstated `primaryChecked` (N1) |
| "48px target" (proverb + daily) | split in two; no script button to measure | The script buttons are removed (N4); one app per test avoids a pending timer |
| RTL 320 px proverb; app text scale | scroll the page's Scrollable; measure the text, not its stretched box | Wrong finders (they were already failing) |

New tests: `provenance_state_test`, `verse_layout_test`, `reading_state_providers_test`, `phase1_now_test` (18 widget tests covering N1–N8, including the N2 sweep).

## Skipped or deferred (and why)

1. **Full «Сабт» record in the source sheet (rights, checks list).** Tests added this morning (`source_panel_test.dart`) deliberately restrict the sheet to title and pages, with no rights and no checks. That contradicts report §9.2. For now I only added the status sentence and the collation sentence. **Decision needed at the Phase 2 gate:** may the «Дар бора | Сабт» tabs show rights and checks?
2. **Scan tile:** none is shown. The 66 scans are not bundled; whether to bundle them is your decision.
3. **Generated-title labels outside the reader.** Persian titles in lists, search, and Home's Continue card are also `generated`, and only the reader states it. This is planned with the one collection index and search work (Phase 4).
4. **History resume at section level.** History entries resume at the top of the page. The section anchor comes with the history redesign (Phase 4).
5. **Debounced anchor writes** (review item, low severity): scroll-end events are infrequent.
6. The code review (flutter-reviewer) found **0 critical, 1 high, 3 medium, 1 low**. The high and all mediums are fixed; the low item is #5.

## CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED (new in Phase 1)

I have left all of these unchanged in the data.

1. **Internal notes contradict publication.** Several displayable works carry `editorialNotes` saying "full text remains withheld pending rights review", yet their full text is shown. Examples: `b95406e4-…`, `6e9c4717-…`, `f3088f90-…`, `d8035663-…`, `fd2474e2-…`, `b262d381-…`, `3772bd06-…`, `d232629e-…`. Other notes record corrections ("Replaced fabricated hemistichs …", `f4c025e3-…`). Which is true: publication or the notes? The notes no longer appear on screen.
2. **Classical texts typed `poem`.** Examples: Saadi «Банӣ Одам аъзои якдигаранд», «Яке Руму яке Юнон парастад». They show line by line, not as bayts. If the editors set their form, the bayt layout applies automatically.
3. The Phase 0 list (§6 of `PHASE_0_PLAN.md`) still stands.
