# Phase 7: more poems, forms, word lookup, goldens, accessibility

Date: 25 Sep 2026. Branch `phase7-2026-09-25`, commits `d8826d0` to the end of the branch.

## Checks

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `flutter test` | **738 passed**, 0 failed (683 at the start of task 8) |
| Coverage (`tool/check_coverage.py`, minimum 80%) | **88.9%** |
| `tool/provenance_linter.py` | PASS, 0 errors |
| `tool/provenance_repair_loop5_adversarial.py` | PASS |
| `audit_textbook_poems.py` on fresh page dumps | **678 poems checked, 0 failures** |
| `unittest discover -s tool/literature` / `tool/history` | 90 + 2 passed |
| `unittest tool.test_deep_browser_audit` | 19 passed (these failed before this phase) |
| Every other step of `.github/workflows/ci.yml` | PASS: format, JSON and content validators, runtime catalogue in sync, source inventory, asset pipeline, duplicate/portrait/enrichment/legacy/provenance guards, shell syntax, bundle alignment, coverage gate |
| Works marked `editoriallyApproved` | **0** |

## 1. The 16 withdrawn poems (Phase 6 list)

- **12 dropped:** folk verse, an elegy, a chronogram, a translation, metre examples, prose.
- **4 re-filed** under the poet the book names. Мавлоно Наҳвӣ's satire (grade 6, p. 108) is now published under him.
- **«Қасидаи модар» (Лоиқ)** held lines of Халилӣ's «Ҳадя ба модарон». It now cites grade 11, p. 296, where only the title is printed, and keeps only its title.
- Every decision, with the lead-in, is in `docs/literature/ATTRIBUTION_DECISIONS_2026-09-25.json`.

## 2. More textbook poems: 347 → 706 readable

- **Four review rounds.** Every verse block in the poets' chapters was read by hand with the sentence that introduces it. 451 blocks were logged and 385 accepted. The rejected ones were verse by others, sayings, folk verse, translations and examples. Log: `docs/literature/EXTRACTION_REVIEW_2026-09-25.json`.
- **Accepted blocks** are re-read from the page and published. Reprints already in the catalogue are skipped.
- **Name guard fixed:** `poet_names` no longer turns a shared nisba or title («Ҷомӣ», «Балхӣ», «Мирзо») or the word «Дар» into a poet's name. «дар» had made the other-poet guard fire on most lead-ins.

## 3. Every textbook poem checked against its page

`tool/literature/audit_textbook_poems.py` checks each poem's lines against its cited pages and re-runs the lead-in guards.

- **The extractor stops where the book's verse ends.** It stops at a prose lead-in set left of the verse, and at a paragraph indented as a whole. It no longer drops the line above a «1.» footnote marker, and no longer reads a centred title as verse.
- **Repairs:**
  - 4 texts re-taken from the page;
  - 7 cut before a prose line;
  - **43 cited page ranges corrected;**
  - one record (Ширин, see the team list) withdrawn because it was left as a single bayt.
- **Result:** 678 textbook poems pass with 0 failures. 6 confirmed exceptions are listed with reasons.

## 4. Poems by form

`tool/literature/classify_forms.py` sets a form only when the book names it (in a heading or the sentence before the verse) and the rhyme fits. Three or more bayts in rhyming couplets count as a masnavi on rhyme alone.

- **191 poems classified:** 112 masnavi, 53 ghazal, 13 rubai, 7 qasida and 6 qit'a. The evidence for each is in `docs/literature/FORM_CLASSIFICATION_2026-09-25.json`.
- **Explore** has a «Poems by form» strip with counts. Each card opens the poem list filtered to that form, and the list has form chips. Today it shows 62 ghazals, 20 rubais, 112 masnavis, 21 qit'as and 11 qasidas.
- **Form names:** one helper names forms everywhere. The hub no longer calls a qit'a «Асари адабӣ».

## 5. Tap a word to see its meaning

- **Lookup:** in Cyrillic, every verse line is tappable. The word under the finger is looked up in the 1,867-word Lexicon as a headword. If that fails, it is looked up under the stem left after izofat, plural, object and possessive endings.
- **The sheet** shows each meaning as the glossary prints it, with book and page. If the word is missing, it says so and offers to open the Lexicon.
- **Long-press selection** still works.
- **The word of the day** in Explore now opens that word in the Lexicon.

## 6. Persian biographies vs the textbooks (report only)

`docs/literature/PERSIAN_BIO_CONTRADICTIONS_2026-09-25.md` compares the Persian bios with the textbooks. Nothing was changed.

- **12 give other life dates.** For example, Халилӣ is 1907–1987 in the Persian bio and 1913–1988 in the textbook; Восифӣ's death is 1566 vs 1556.
- **12 name another birthplace,** or none.

## 7. History: Айнӣ and Хуррамӣ filled

- **Садриддин Айнӣ** has two verbatim sections:
  - grade 11, p. 215: the Hero of Tajikistan title;
  - grade 9, p. 148: the new-method school he opened with Мунзим.
- **Хуррамии Самарқандӣ** has one (grade 6, p. 205).
- **«Пули Вахш»** is only listed by title (grade 10, p. 203) and stays as it was.

## 8. Code health, golden images, accessibility

- **No source file is over 800 lines.** Translations, seed proverbs, the poet page, the history screen and the large tests were split. There are no behaviour changes.
- **Deep browser audit:** its route discovery moved to `tool/browser_audit_routes.py`. Its tests were failing on `/saved/bayoz/:id` before this phase; they pass now.
- **Golden images** (`test/golden/`): 8 images, Home, Explore, Рӯдакӣ's «Бӯйи Ҷӯйи Мулиён» and Рӯдакӣ's page, each in light and dark.
  - The date is frozen through `nowProvider`. Explore's daily picks now follow the shared Tajikistan day, not the device clock.
  - The images use the default test font, and a comparator that tolerates 0.5% of pixels, so macOS and CI's ubuntu-latest agree.
  - To regenerate after a deliberate visual change, run `flutter test --update-goldens test/golden`.
- **Accessibility pass** on Home, Explore, the poem list and its form chips, the reader and its Lexicon sheet, the poet page, History and the Lexicon. Fixed:
  - **TalkBack could not open five kinds of buttons.** The collection tiles, category tiles, previous/next links, bayoz covers and the reading-room rail spoke their label but lost their tap action. A double tap now works.
  - **Headings:** page titles, poem titles, poet names and history titles are now announced as headings.
  - **Contrast:** selected chips in dark mode were 2.8:1. The label is ivory now, above 4.5:1.
  - **200% text:** the reader's author link overflowed; it wraps now.
  - **Reading order:** TalkBack no longer stops on the «·» between the reader's details. Poem lines are read whole, in order.
  - **Lexicon letters** are set at 16 px.
- **What the accessibility tests check** (`test/accessibility_phase7_test.dart`, 45 tests): 48 px tap targets, labelled buttons, text contrast, headings, and 200% text in Tajik and Persian, on every screen above in light and dark.
- **Two contrast warnings were false alarms:** a single «Б» chip and a small heading low on a long page. Each measured above 4.5:1 when checked by its colours.
- **Known limit:** looking up a word needs a finger tap on the word. TalkBack users reach the same meanings through the Lexicon screen and search.

## CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED

- **Ширин record withdrawn** (`e8be81cf-c4a4-58a2-959c-4bf33dea3d3f`, Низомии Ганҷавӣ, grade 8, p. 270). It was cut before the lead-in «Ширин савганд мехӯрад…» and was left as a single bayt, which is not publishable as a work.
- **Айнӣ's elegy is not published** (grade 11, p. 64, «Дӯстон! Фоҷиаи сахт биомад ба сарам,»). The extractor stops at the verse line «Додарам – …» because it reads it as a glossary entry. Someone should copy the band by hand from the page.
- **Ҳофиз bayts, grade 6, p. 97.** The book quotes three separate bayts joined by «Ё ин ки:» and «ё». The record keeps only its title bayt, under Ҳофиз, because the lead-in does not say «Ҳофиз мегӯяд».
- **Низомии Арӯзӣ's bayt** (the epigraph of the Рӯдакӣ chapter, grade 5, p. 49) has no record.
- **Комӣ, Хумулӣ and Фазлӣ have no poet records,** so their verse quoted in the textbooks cannot be filed under them.
- **Mukhammases** include the lines of the poet being answered, marked with «». The team should confirm this presentation.
- **Modern couplet poems** are labelled «Маснавӣ» on rhyme alone, when the book does not name the form.
- **Persian bios:** 12 date conflicts and 12 birthplaces to check (report above). They need a translator.
- **History, grade 11, p. 215:** the page's two-column layout garbles the text extraction. The Айнӣ section taken from it should be read against the printed page.
- **«Пули Вахш»** is only listed by title in the history books (grade 10, p. 203), so it has no reading section.
- **Pre-existing `deep_browser_audit` failures were fixed** (route discovery and `/saved/bayoz/:id`).
- **Latin look-alike letters:** 8 poem records carry Latin letters inside Cyrillic words, from the PDF text layer. Examples are «КИШТИНИШACTАГОНЕМ», «Xалоси», «Cаёҳатро» and «гap», and Roman numerals such as «ХIV» typed with a Cyrillic Х. They look right, but search for those words fails. They were left as extracted, pending a decision.
