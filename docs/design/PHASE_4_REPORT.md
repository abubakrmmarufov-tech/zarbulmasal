# Phase 4 — Roadmap NEXT + «Folio» boxes

> Screenshots for this phase were removed from the repository on 25 Sep 2026 to keep it small. They remain in git history: `git show dcd3805:docs/design/phase4/<file>`.

Date: 24 Sep 2026 · Screenshots: `docs/design/phase4/` (390 px and 1440 px, light and dark, Tajik and Persian). Contact sheets: `home.png`, `explore.png`, `history.png`, `reader.png`, `search.png`, `learn.png`, `saved.png`. Close-up: `home_390_detail.png`.

## Checks

| Check | After Phase 3 | After Phase 4 |
|---|---|---|
| `flutter analyze` | No issues | **No issues found** |
| `flutter test` | 625 passed, 8 failed | **647 passed, 0 failed** before the outside seal edit (below); after it, 638 passed and `phase2_visual_system_test.dart` does not compile |

**Outside edit to the seal (22:17, not made in this session).** `lib/core/design_system/qalam_seal.dart` was rewritten to draw Material's `Icons.verified` / `Icons.verified_outlined` checkmark badges instead of the placeholder seal asset. Two consequences:
- It **conflicts with the hard rule "never show verified when checks are pending"**: today every readable work is in the *outline* state (checked against print, editor approval pending), and it now shows a "verified" badge.
- The Phase 2 seal tests reference `QalamSeal.pressedAsset` / `outlineAsset`, so that test file no longer compiles.

**Resolved at the phase gate:** you chose to restore the placeholder seal. `qalam_seal.dart` is back to the asset-based placeholder, and the checkmark version is kept at `scratchpad/qalam_seal.outside_edit_2217.dart` for reference. After the restore, the full suite passes again (see the last line of this report).

About the 8 old failures: 7 were content/data tests, plus the Khirad label test. **I did not fix them.** Between 20:45 and 21:14 on 24 Sep, someone else edited those test files, and the edits were not made in this session:
- `test/literature_content_test.dart`, `test/literature_json_validation_test.dart`, `test/provenance_integrity_test.dart`, `test/features/books/books_presentation_test.dart`;
- plus `lib/features/literature/presentation/poet_detail_screen.dart` and `lib/core/design_system/qalam_index_row.dart`.

I left those edits as they were. In `books_presentation_test.dart` I changed one line: the format badge is now part of one meta line, see below.

## Your feedback mid-phase: "bring the boxes back, but make them ours"

The pre-redesign Home was easy to navigate because every part of the app was a box one tap away. Phase 4 keeps that idea and gives it a signature.

- **Folio tile (`QalamFolioTile`):**
  - a raised paper rectangle with an ink hairline and small corners;
  - crowned by a band of the collection's own **«Атлас» ikat**, seeded from its ID, so every collection has a stable, unique pattern you can recognise from a screenshot;
  - the icon, the serif title and one line of real counts sit on the paper, never on the pattern;
  - in «Шаб» the paper is lifted lapis;
  - the band is cached (`RepaintBoundary`) and clipped.
- **Home:** the six folios come first, directly under search: Literature, Proverbs, History, Lexicon, Library, Learn. That's 2 columns on a phone and 3 on wide screens. The proverb of the day follows. **This reverses the Phase 0 Q4 decision** (the daily ritual first); navigation now comes first, as you asked.
- **Catalogue slip (`QalamSlip`):** every list item is now a boxed slip with a hairline, raised paper and gaps between slips. That covers Explore parts, Learn, History entries, search results, Saved, Library books and "more by the poet". Individual items get **no** ikat, so the pattern stays a sign of a collection.
- **Explore:** each domain is a large folio, with its parts as slips below it.
- **History entry:** the facts (capital, territory, rulers) sit in one boxed fact card.
- **Previous / Next** at the end of a text are two boxes.

## Roadmap NEXT — what changed

- **X1 · one collection index:**
  - Explore is the index: each domain once, with its parts.
  - The Literature hub lists only literature.
  - Learn keeps Levels, Continue, Quiz and Flashcards. «Адабиёти мактабӣ» and «Луғатнома» are removed there, because they live in Explore.
  - Running numbers ("01 /") are gone from eyebrows.
- **X2 · end-of-text navigation ("Боз хонед"):**
  - **Poem:** previous/next in the works collection (the same order as the works list), up to 3 more by the same poet plus the poet's page, and "the same period in History". The period comes only from the poet's own `relatedHistoryEntryIds`; nothing is inferred.
  - **Proverb:** previous/next within its theme, a few more from the theme, and "all in theme «…»".
  - **History entry:** previous/next within the same family (states: empires and dynasties; otherwise the same kind), in the catalogue's order. Also poets of the period, from `relatedAuthorIds` plus poets whose `relatedHistoryEntryIds` name the entry, and related works.
  - Records that can't be resolved are left out instead of shown as raw IDs.
  - Generated Persian-script titles carry the label everywhere they appear.
- **X4 · desktop reading room:**
  - From 1200 px a **left rail** (right in Persian) replaces the bottom bar and **stays on every screen**, pushed ones included. It holds the wordmark, Home, Explore, Learn, Баёз, Search and Settings.
  - Poem pages widen to 1160 px. From 1000 px of page width the **record («Сабт») and the connections sit in a right context pane**, so there are no tabs there.
  - Text sizes never shrink on desktop.
  - The layout keeps its tree shape across the breakpoint, so resizing keeps navigation state.
- **X5 · History:**
  - Entries come first. The textbook shelf moved under «Китобҳои дарсӣ», and search sits behind an icon.
  - Entries are slips: kind · grade, title, dates, one-line summary.
  - A tap opens the **entry page directly**; the intermediate sheet is gone.
  - The page ends with previous/next and connections.
- **X6 · search:**
  - Results are grouped with counts; the **matched part of each title is set bold**, including folded matches («руда», «rudaki» → **Рӯда**кӣ).
  - Each result has one line of context: the poet's lifespan, or else their period.
  - Groups show 5 results and then "Ҳамаи N →".
  - While the query is empty, it shows what you read recently.
  - No results: a tip about spelling, plus a button to the index.
- **X7 · Library:**
  - The provider box is now plain lines. Catalogue figures show only when all three are recorded, so there is no "— китоб · — муаллиф".
  - Format, year and pages are one meta line («HTML · 2013 · 480 саҳ.»).

## Existing tests changed (and why)

| Test | Change | Reason |
|---|---|---|
| History cards/book cards; in-app navigation (2 tests) | open «Китобҳои дарсӣ» first; tapping an entry opens `HistoryDetailScreen`; router-based pump | The shelf moved; the sheet was removed |
| Persian history book/entry (2) | the same, plus a check that the entry page opens | The same |
| Epoch view switch | tap the grade **chip** | The shelf also names grades |
| History detail | `missing-author` / `missing-work` are now **not** shown | No raw IDs on screen |
| N7 "no counter" on /history | open the search icon first | Search is folded |
| Search "Persian never falls back" | also checks Text.rich results | Highlighted titles are rich text |
| Variant IDs (2) | scroll to the variant section | The variant is also the "next" proverb in its theme |
| Khirad list badge | matches the «HTML · …» meta line | The pills became one line |

New tests: `test/features/phase4_next_test.dart` (13 tests). They cover:
- Learn without the duplicate rows;
- poem next/previous and navigation;
- a proverb stepping through its theme;
- the history family neighbour rule;
- the rail at 1440 px and its absence at 390 px, including on pushed screens, with the context pane replacing the tabs;
- route mapping;
- `matchRange` (Cyrillic folding, Latin, Persian);
- highlighted results and "show all";
- recent items on an empty query;
- the no-results tip leading to the index.

Also: `history_presentation_test` now covers "search is folded behind an icon". The test helper has `readingRoom: true` to render the app frame.

## Code review (flutter-reviewer)

0 critical, 1 high, 2 medium, 2 low. Fixed:
- **HIGH:** previous/next replaced the current page, so Back skipped the texts just read. They now push, and Back steps through the trail.
- **MEDIUM:** with the desktop pane, tapping the seal or «Манбаъ» set the hidden tab, so a later narrow resize jumped to «Сабт». On desktop these no longer change the tab; the record is already in the pane.
- **MEDIUM:** `QalamTileGrid` now documents that it measures rows with `IntrinsicHeight` and is meant for a handful of tiles.
- **LOW:** removed two `!` operators on Persian titles.

Kept:
- **LOW:** a result that matches only a non-title field (an alias, a proverb's meaning) shows no bold highlight. That's correct: there is nothing to highlight in the title.

## Skipped or deferred (and why)

1. **Sticky era navigator and a desktop era sub-rail for History:** epochs remain the chip row. Deferred until you confirm the new History list.
2. **History context pane on desktop:** only the poem reader has a pane. History and proverb pages use the normal column with the rail.
3. **Carousel arrows:** the only carousel, the textbook shelf, is now behind the «Китобҳои дарсӣ» view.
4. **Onboarding on desktop:** the four onboarding spotlights point at the bottom bar. With the rail, they fall back to centred cards. Worth revisiting with the rail as the target.
5. **Saved "recent searches":** the empty search state shows recently read texts from the existing local history. No new search log is stored.

## CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED (new in Phase 4)

1. **Hard-coded fallbacks in History detail (removed from view, data untouched).** The old chips printed «Абӯабдуллоҳи Рӯдакӣ» for `rudaki` and «Шоҳнома» for `poem-shahnameh` when those records were not in the catalogue. Those labels were typed into the code, not taken from the data. Unresolved records are now simply not shown. Should `poem-shahnameh` exist as a work?
2. **"6 сатҳ" in `learn_levels_step_by_step`.** A count written into a UI string; please confirm it matches the levels data.
3. **History prev/next order** follows `entries.json` order within a family. It looks chronological for states, but that is an assumption about the file order, not a date sort. Please confirm the file is kept in chronological order.

---

Final state after the phase gate: `flutter analyze` finds no issues; `flutter test` passes all **647** tests.
