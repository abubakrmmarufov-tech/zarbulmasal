# Phase 6: accuracy, content, Explore, ikat, performance

Date: 25 Sep 2026. Screenshots are in `docs/design/phase6/`, rendered with the app's real fonts by `tool/design/screens_test.dart`, because the phone was unplugged.

## Checks

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `flutter test` | **664 passed**, 0 failed |
| `tool/provenance_linter.py` | **PASS** (it failed before this phase) |
| `tool/provenance_repair_loop5_adversarial.py` | PASS |
| Python tool tests (CI set, plus `tool/literature`) | 31 + 18 passed |
| Dart data validators, runtime catalogue in sync | PASS |

## Your decision applied: PDF text is enough, images for final approval

`provenance_linter.py` now treats text copied from an uploaded textbook PDF page (`verificationMethod: textbookPdfTextExtraction`, source under `docs/literature/pdfs/`) as page evidence at `primaryChecked`. `editoriallyApproved` still requires a verified page image. Three new linter tests pin these limits.

## Bugs from your screenshots

- **Poet page, "RIGHT OVERFLOWED BY 0.316 PIXELS".** The birth/death chip repeated the calendar line above it. I removed it.
- **Books by this author, "BOTTOM OVERFLOWED BY 16 PIXELS".** The placeholder cover's title now shrinks to fit. A test covers text sizes up to 200%.
- **The same screenshot showed a data error.** Аҳмади Ҷомӣ carried Абдурраҳмони Ҷомӣ's dates (7 Nov 1414 – 9 Nov 1492) and birthplace (Харҷерд). Fixed from the PDF: 1049–1141, Ҷом (grade 5, p. 89).

## Poems: every attribution checked

I read the sentence introducing every published textbook poem and checked each poem against its chapter.

**Withdrawn to "needs review" (16).** Each case is logged in `docs/literature/ATTRIBUTION_AUDIT_2026-09-25.json`:
- **Folk verse:**
  - songs about Аҳмади Ҷомӣ;
  - a quatrain printed as «Аз халқ:» beside Ҳофиз;
  - a weavers' song in the Саййидо chapter.
- **Verse by other people:**
  - Мавлоно Комӣ's elegy on Ҷомӣ;
  - Хумулии Моғиёнӣ's chronogram on Содиқ;
  - Фазлӣ's verse on Ҳозиқ;
  - Наҳвии Ҳиротӣ's satire quoted by Восифӣ;
  - Заҳири Форёбӣ's bayt in the Саъдӣ chapter;
  - Боқӣ's line filed under Фирдавсӣ.
- **Prose (3):**
  - a lesson on киноя;
  - a dialogue in Ҳилолӣ's biography;
  - an analysis of a story (Саттор Турсун).
- **Other (4):**
  - an unattributed metre example;
  - a translation (Юсуфӣ from Lermontov);
  - two bayts by two different poets glued into one record;
  - three separate Ҳофиз bayts joined by «ё».

**Repaired (7):**
- 5 prose lead-in lines removed from the start of poems;
- a stray «.» removed;
- one record split in two where the book joins two excerpts with «Ё худ:».

**New poems: +79.** `tool/literature/scan_textbook_chapters.py` attributes verse only when all of these hold:
- the page lies inside the chapter range the poet's bio cites;
- the verse sits under a printed title or follows an own-voice lead-in («шоир мегӯяд:»);
- no guard fires: another poet named, folk verse, elegy, translation, examples, theory lesson, exam page.

I read all 92 candidates and rejected 13. Examples of what was rejected:
- quotes by Озод, Фазлӣ and Муштарӣ;
- a verse play's speaker labels;
- «Мавҷи одам», which is in Қаноат's pages but was attributed to Айнӣ.

**Result: 347 readable poems** (283 before, less the withdrawn 16). All 319 textbook-extracted poems pass a line-by-line check against their PDF. The extractor has new tests for every failure type found (18 tests in total).

## Poet dates, birthplaces and bios checked against the PDFs

- **Dates:** `tool/literature/poet_dates_from_textbooks.py` sets **23 poets'** dates as their chapter heading prints them, and records the page in `lifeDatesSource`.
  - 12 poets had no years before.
  - Fixed disagreements include Фотеҳ Ниёзӣ (died 1997, not 1991), Саттор Турсун (born 1946) and Кайковус (1020–1099).
  - Where the textbook predates a death (Гулназар Келдӣ), the recorded death date is kept.
- **Bios that were someone else's text (3):**
  - Мушфиқӣ's bio was a section on 18th–19th-century literary centres.
  - Амир Хусрав's bio was text from Муҳаммад Авфӣ's chapter.
  - Рашидӣ's bio was a passage from Рӯдакӣ's chapter.
  - Each now carries its own chapter's opening, verbatim, with page.
- **Birthplaces:** checked against each chapter. Ҳилолӣ's Астаробод is confirmed (grade 9, p. 308).

## Lexicon: 284 → 1,867 words

`tool/vocabulary/extract_glossary.py` adds the «Луғат» lists and footnote glosses of grades 6–11, as printed, each with its book and page:
- all-caps glossary headwords are put in sentence case;
- verse lines containing a dash are rejected;
- meanings over 8 words are accepted only from footnotes or glossary lists.

The Lexicon sorts its list once per load, not on every keystroke.

## History: 38 thin entries now have reading sections

41 entries (the Сосониён, Сомониён, Ғазнавиён, Муғул, Бухоро, Хӯқанд pages and more) had one line of text.
- The source is the «Таърихи халқи тоҷик» textbooks for grades 6–11 on maorif.tj; the PDF links are now recorded in `books.json`.
- `tool/history/excerpt_textbooks.py` gives each entry the opening paragraphs of its lesson, verbatim, cited by book and page; a person gets the paragraphs that name them.
- **53 sections** now cover 38 entries, including every empire and dynasty.
- Section captions name the grade, since all six books share one title.
- Not covered, because the books don't discuss them (only lists or citations):
  - «Пули Вахш»;
  - Садриддин Айнӣ in the history book (he has a full Literature page);
  - Хуррамӣ.

## Explore redesigned (`phase6/explore.png`, `explore_dark.png`)

From top to bottom:
1. **Discover today:** a poem, a proverb and a word, with a reroll button.
2. **Poets by era:** IX–XV (36), XVI–XIX (16), XX–XXI, each opening the poets list filtered. The poets list itself gained era chips.
3. **By grade:** 5–11.
4. **History timeline:** empires and dynasties in textbook order.
5. **The collection index,** below.

## Atlas bands (`phase6/atlas_before.png` vs `atlas_after.png`)

Redrawn after real адрас/атлас ikat:
- nested lozenge "eyes" with an ink outline and hooked tips;
- zigzag combs between them;
- the feathered *abr* edge: thread-wide slices shifted by a smooth random walk;
- faint warp threads;
- one row of whole eyes on thin bands.

Each collection keeps its own palette. The motif layer is rasterised once per seed and size, so the effect costs a few image blits.

**To go back to the old bands:**

```
git checkout ca66914~1 -- lib/core/design_system/atlas_cover.dart
```

## APK: lighter and smoother

- **Portraits:** 4.5 MB → 2.3 MB. Re-encoded as JPEG at 640 px tall; the 8 PNG photos became JPEGs.
- **Fallback fonts** (Noto Sans/Serif): 1.4 MB → 350 KB, as static regular instances subset to the ranges they serve. Recorded in `tool/design/build_fonts.py`.
- **Launcher PNGs:** recompressed losslessly (−10%).
- **Speed:**
  - books.json (1.7 MB), history and Lexicon JSON now decode on a background isolate;
  - portraits and covers decode at their displayed size;
  - atlas bands are cached.
- **Size:**
  - A clean arm64 **profile** APK is 36.9 MB.
  - The signed **release** build also minifies the Java code and drops the profiler. The last release arm64 APK (26.5 MB) was built before these savings, so expect about 23–24 MB per ABI.
  - CI already builds per-ABI APKs with `--obfuscate`.
- Note: the Android packager updates APKs in place and leaves holes, so measure with a clean build.

## How production-ready is it?

**About 80% for a public v1.0 on Android.**

**Ready:**
- Offline-first, no accounts, stable navigation.
- 664 widget and unit tests plus all data gates green; analyze clean.
- A release pipeline with signing checks, per-ABI APKs, an AAB, obfuscation and R8.
- Content traceable to textbook pages; attributions audited by hand.
- Dark mode, Persian UI, and large-text layouts are tested.

**Still to do before a public release:**
1. **A native Tajik/Persian editor should review** the 347 poems, the dates and the generated Persian-script text. Nothing is `editoriallyApproved` yet (0 works).
2. **Persian bios** come from outside the textbooks and sometimes disagree with them; for example, Аҳмади Ҷомӣ «۱۰۴۸, نامق ترشیز» vs the PDF's 1049, Ҷом. They need a translator.
3. **Portrait and ikat artwork rights:** portraits are shown from the textbooks with rights "unknown", and the ikat design needs a textile specialist's review.
4. **Device QA on a low-end Android phone** of the release build: startup time, scrolling the 710-book library and the 1,867-word Lexicon.
5. **Store listing, privacy policy** (the app collects no data; say so), crash reporting decision (currently none; offline-first).

## CONTENT/PROVENANCE: team verification required

- The 16 withdrawn records: the right poets should get their own records if the team wants them (log above).
- «Қасидаи модар» (Лоиқ, `49a09b23…`) contains Халилӣ's «Ҳадя ба модарон». Unchanged.
- The PDFs disagree with each other:
  - Ҳилолӣ's birth year: 1470 in grade 5, 1475 in grade 9;
  - Аттор: 1119–1221 in grade 5, "about 1148/51 – 1219/21" in grade 8.
  - The app follows the book the bio cites.
- Миршакар's and Баҳорӣ's birthplaces are not in the PDFs; they stay as recorded.
- The generated Persian-script poems are rough transliterations, labelled as generated.
