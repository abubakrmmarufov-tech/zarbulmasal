# Phase 5 — Owner feedback round

Date: 24–25 Sep 2026. Screenshots are from the owner's phone (Android, dark theme, debug build) and live in `docs/design/phase5/`.

## Checks

| Check | Result |
|---|---|
| `flutter analyze` | **No issues found** |
| `flutter test` | **652 passed, 0 failed** |
| `python3 -m unittest test_textbook_verse` (`tool/literature/`) | **13 passed** |
| Phone tour (APK installed with `adb install -r -d`) | Home, Literature, Poets, poet page, reader, Learn, Lexicon, Library, book page, Settings; Persian UI and back |

## What changed, by request

### "Remove Сабт, the source is enough, and the tick"
- The reader no longer has the «Матн / Сабт» tabs, the seal next to the title, or the status sentence.
- Under the poem there is one line: **«Манбаъ: Адабиёти тоҷик, синфи 5 (2017), с. 52»**. It shows the book, grade, year and page, and nothing else from the provenance record (`LiteraryWorkDisplayText.shortCitation`, `widgets/source_line.dart`).
- Proverb pages work the same way: the tabs are gone, the sections are shown, and one «Манбаъ: …» line follows them.
- Deleted: `qalam_seal.dart`, `qalam_record_tabs.dart`, `source_panel.dart`, `provenance_status_line.dart`, `provenance_display_text.dart` and the seal placeholder images.
- The provenance data itself is unchanged in the JSON; only the display changed.

### "When there is no space the word must go under it, to the right"
- A hemistich that does not fit now continues on the next line, **flush to the end edge**: right in Cyrillic, left in Persian script (`HangingIndentLine`, `textAlign: TextAlign.end`).
- It is used in the reader, the parallel (two-script) view and the bayt of the day. See `phone_poem1.png`: «…бад-ин гаҳ шавад / чавон,».

### "First letters of titles look bold" (sentence case)
- Titles printed in capitals in the textbooks ("ХАНДАИ ЛОЛА") are stored in sentence case («Хандаи лола»), with proper names kept («Ба Исмоили Сомонӣ»).
- The name list is mined from the textbooks themselves (`proper_nouns`, `sentence_case`).

### Lexicon (Луғатнома): redesign, search, dark mode
- Rewritten (`vocabulary_screen.dart`):
  - a search field (word or meaning);
  - a strip of Tajik letters (А Б В Г Ғ Д …);
  - letter headings;
  - each word in its own boxed card (serif word on top, meaning below).
- It follows the theme; before, it stayed white in dark mode.

### Learn: redesign
- A progress panel at the top: mastered / learning / to review, with a bar ("5 аз 150 аз худ шуд").
- A "continue" slip back to where you left off.
- Four practice folios: Levels, Quiz, Flashcards, School literature. See `phone_learn.png`.

### Poets' images from the textbooks
- Portraits that come from the textbook PDFs are shown, with a caption under them, e.g. «Сурат: Адабиёти тоҷик, синфи 5, с. 49».
- Rights stay recorded as they are ("unknown"). Only the display rule changed: a portrait is shown when it is sourced from the textbooks (`PortraitRecord.isDisplayable`).
- Any other portrait stays a monogram.

### "AI was too strict — if the PDF prints a poem under a poet, add it"
- **Published poems: 31 → 283.**
  - 255 of them were extracted from the textbook PDFs (grades 5–11): grade 5: 36, 6: 27, 7: 52, 8: 40, 9: 27, 10: 48, 11: 25.
  - They cover 65 poets.
- How the text is taken (`tool/literature/textbook_verse.py`, `extract_textbook_poems.py`, `publish_textbook_poems.py`):
  - The text layer of the cited page is copied verbatim.
  - The only changes are the legacy font map (њ→ҳ ќ→қ љ→ҷ ѓ→ғ ў→ӯ ї→ӣ), layout whitespace, and footnote markers glued to words («Лайло1.» → «Лайло.»).
  - A block must read as verse (≥ 4 lines, verse punctuation, no prose paragraph, no glossary).
  - The printed heading becomes the title. Without a heading, the poem is known by its first line.
- Each record carries `verificationMethod: textbookPdfTextExtraction`, the printed page numbers, and a generated Persian-script version that is labelled as generated.
- Full list: `docs/literature/TEXTBOOK_POEMS_EXTRACTED.json`.

**Audit after publishing (25 Sep).** Every one of the 255 poems was checked line by line against its PDF.
- **3 misattributions found and withdrawn.** The records went back to their earlier "needs review" state, and the extractor now refuses such quotes. See the flags below.
- **1 prose dialogue withdrawn:** «Ба ҷуворӣ дубора об додӣ?» (grade 5, p. 155).
- **12 poems had a prose line glued on top**, carried from the foot of the previous page. That line was removed and the title recomputed.
  - Cause: the page-carry step skipped flush-left prose.
  - Fixed in `extract_poem`, with a test.
- 2 doubled footnote markers were removed («кафал158158.» → «кафал.»), with a test.
- 1 dated line «Соли 1938.» was removed from the end of a poem (the date printed under it), with a test.
- 1 part label «(фасли нахуст)» was removed, with a test.
- 2 section headings used as titles were replaced by the first line: «Қасидаҳои Саъдӣ» and «Мундариҷаи идеявии ашъори … Навоӣ». The extractor now treats these, and literary-device lesson headings, as section headings.

### Boxes for every list
- The poet cards, the works list, the poet page's list of works and the collection links are all boxed slips.
- Lists show the first line of a poem **only when it is not already the title** (`LiteraryWorkDisplayText.distinctIncipit`). This applies to the works list, poet page, featured poems, search, Saved and "more by this poet".
- The works list has a search field: title, first line, poet name or alias.

### "Upload more books from kitobkhon.net"
- **Library: 28 → 710 books.** 682 new books plus one new edition (Қобуснома, 2016) come from the kitobkhon.net catalogue (1,103 books on 92 pages, crawled politely: cached, 4 workers, 1 s pause).
- Selection:
  - Tajik-language books with a PDF, in Literature (classical, modern), Poetry, Prose, History and Biography;
  - with the provider's own title, author, publisher, year, pages, city, categories, description and cover;
  - linked to a poet in the app only on an exact name match (147 books).
- One book was left out: its description says it was compiled from a WordPress blog, which the content policy excludes.
- Like the existing kitobkhon entries, every edition is `readableExternal` and `rightsUnclear`. The app links to the provider and hosts nothing.
- Tool: `tool/books/import_kitobkhon.py` (rerunning it adds nothing new).
- The only other verified source for books would be khirad.tj (already present). No other sites were used.

### Bugs fixed on the way
- Library rows read "PDF · 1978 · Саҳифаҳо" without the number; they now say "PDF · 1978 · 416 саҳифа" (new key `books_page_count`).
- Featured poems on the Literature page repeated the title as the first line.
- The poet page lost the composition date line during the slip rewrite; it is restored.
- Reader: removed a null-bang on the Persian-script text (review finding).

## Review (flutter-reviewer agent)

- **HIGH, not changed.** Every reader rebuild re-measures each line with `TextPainter`: the side-by-side check plus the hanging-indent split.
  - This costs about the same as laying the text out, and it runs only on rebuilds (font size, theme, script), not while scrolling.
  - Most of it predates this round; this round only changed the continuation's alignment.
  - If long masnavis ever feel slow on text-size changes, cache the fit decision per width.
- **MEDIUM, fixed.** `persianScriptRepresentation!` in the reader now falls back to an empty string.
- No leftover "verified" wording or icons, and no dead imports from the deletions.

## Tests changed

- **New:**
  - `test/features/phase5_feedback_test.dart` (9 tests): source line, Persian citation, end-aligned wrap, no seal or «Сабт» in either theme, textbook portraits, Learn layout, works-list search, `distinctIncipit`;
  - `tool/literature/test_textbook_verse.py` (13 tests).
- **Updated for the new design:**
  - `phase1_now_test`, `phase2_*`, `phase3_*`, `phase4_*`;
  - `literature_presentation_test`, `readability_regression_test`, `vocabulary_*`, `learn_screen_behavior`, `navigation_shell`, `widget_test`, `qalam_portrait_test`.
- **Seal test removed** from `pwa_assets_test` and `source_panel_test.dart`, because the seal and panel were deleted.
- **Content policy tests** (`provenance_integrity_test`, `literature_json_validation_test`) now accept `textbookPdfTextExtraction` as a verification method.
- **Books** (`books_repository_test`): the count is now 710; Қобуснома has 2 editions; a new test checks that every kitobkhon edition links to kitobkhon.net pages and PDFs; `books_presentation_test` checks the page count.

## Not done

- **DeepSeek / Gemini CLIs:** neither `gemini` nor `deepseek` is on this Mac's PATH, so the work was done here and by the built-in reviewer agent.
- **maorif.tj:** no new material was taken from the website this round; the textbook PDFs (from maorif.tj) were enough for poems and portraits.
- **Screenshots from you:** none arrived during this run.

## CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED

Nothing below was changed in content; each item needs a person to decide.

1. **Three quotations were attributed to the poet whose chapter they appear in.** All three were withdrawn to "needs review":
   - grade 11, pp. 132–133: «Пайрав, ки яке шоири шӯроии мо буд…» is **Айнӣ's elegy on Пайрав** («Марсияи устод Айнӣ дар вафоти Пайрав…»), filed under Пайрав;
   - grade 9, Ҷомӣ chapter (around p. 219): «Ҷомӣ, он офтоби нуронӣ…» is by **Камолиддини Биноӣ**, about Ҷомӣ, filed under Ҷомӣ;
   - grade 8, p. 22: «Юсуфрӯе, к-аз ӯ фиғон кард дилам…» is **Рӯдакӣ's** rubai, quoted as an example of *талмеҳ*, filed under Бузургмеҳр.
   - If these belong in the app, they need records under the right poets.
2. **«Қасидаи модар» (Лоиқ Шералӣ, record `49a09b23…`)** holds the text of Халилӣ's «Ҳадя ба модарон» (grade 5, pp. 243–245). Unchanged.
3. **The generated Persian script is rough** (mechanical transliteration). It is always labelled as generated, but a native reader should check it before it is relied on.
4. **Extracted poems are excerpts where the textbook prints excerpts.** For example, «Бурданд муваккилони роҳаш» (Низомӣ) starts mid-story, because that is how grade 6 prints it. The source line gives the page.
5. From earlier phases: hardcoded fallbacks and the «6 сатҳ» count in Learn.
