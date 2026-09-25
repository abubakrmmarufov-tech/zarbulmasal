# Phase 8 plan: give poets their poems

Date: 26 Sep 2026. Starting point: 705 readable poems; 85 of 159 poets without a poem (71 active records, 14 held by design); see `POET_COVERAGE_2026-09-26.md`.

## Rules (unchanged from Phase 7, and hard)

- Sources: the seven textbook PDFs (checked against `MANIFEST.json`) and maorif.tj. Text is copied from the page's text layer, never typed, completed or «fixed»; the one correction is Latin look-alike letters inside Cyrillic words, set as the Cyrillic letters the page shows, each one logged.
- A block is attributed only when its lead-in makes the chapter's poet the speaker (or names the poet as the speaker), the book signs it with the poet's name, or it sits under the poet's printed title. Folk verse, other poets' verse, elegies and chronograms by others, translations, metre/device examples, exam items and drama dialogue are rejected, with the reason logged.
- A lone bayt is never published as a work. Nothing is marked editoriallyApproved.
- Every accepted block is logged, with its lead-in and reason, in `EXTRACTION_REVIEW_PHASE8_2026-09-26.json`; rejected blocks too.

## Tool changes

| Tool | Change | Why |
|---|---|---|
| `textbook_span.py` (new) | `take_span`: copy the printed lines between a named opening and closing line, across page breaks; refuses headings, glossaries, questions, labels and prose-length lines; skips page-foot footnotes; keeps «***» and blank lines as stanza breaks. `fix_lookalikes`: Latin look-alikes → Cyrillic in Cyrillic words. | Verse set flush left, and poems whose facing pages have different margins, which `extract_poem` cannot delimit. |
| `extract_textbook_poems.load_pages` | Applies `fix_lookalikes` to every page. | Every tool and the audit see the letters the page shows. |
| `publish_reviewed_blocks.py` | `closing` (span), `split: quatrains`, `heading`, `replaces` (repair a record that held part of a poem), `merges` (a shorter excerpt reprinted in another book); promotes a matching needsReview record instead of creating one and merges its duplicates (`duplicate_of:<id>`); writes `recordIds` back to the review log; takes its date from the log. | «Prefer promoting an existing needsReview record … and merge duplicates.» |
| `audit_textbook_poems.py` | Reads every `EXTRACTION_REVIEW_*.json`; judges prose per page (flush-left verse by line length); new check: **the line under the verse must not sign it with another poet's name**. | The signature check found the one Phase 7 misattribution (Шаҳиди Балхӣ's quatrain under Абушакур). |
| `poet_coverage.py` (new) | Per-poet chapter pages, verse blocks, readable and needsReview counts with reasons, verdicts. | The analysis above, repeatable. |
| `fix_lookalike_letters.py` (new) | Applies the look-alike fix to title, incipit and text of kept records, regenerates the generated Persian script, logs each word. | The 8 records Phase 7 left (13 records, 14 words in all). |
| `apply_attribution_decisions.py` | Takes its date from the decisions file. | Phase 8 decisions are dated 26 Sep. |

Each change has unit tests (`test_textbook_span.py`, `test_poet_coverage.py`, `test_fix_lookalike_letters.py`, and new cases in the publisher and audit tests).

## Rounds

Each round: extract the candidate blocks; read every block with its lead-in; log the decision; publish; classify forms (`classify_forms.py`, report `FORM_CLASSIFICATION_2026-09-26.json`); regenerate the runtime catalogue; audit (0 failures) and all checks; one commit.

1. **Groundwork** — the tools above; the Шаҳиди Балхӣ refile (`ATTRIBUTION_DECISIONS_2026-09-26.json`); the look-alike fixes (`LOOKALIKE_FIXES_2026-09-26.json`); this plan and the coverage report.
2. **Round 1: poets with 0–2 poems, and repairs.** Pages: grade 8, pp. 3–176 (survey of the 9th–11th centuries, Рӯдакӣ, Дақиқӣ, the Ghaznavid survey, Асадӣ, Кайковус); grade 5, pp. 48–300 (Ансорӣ, Аттор, Биноӣ, Ҳилолӣ, Эраҷ Мирзо, Халилӣ, Ғаффор Мирзо, the verse on Рӯдакӣ, pp. 55–56); grade 6 (Фаррухӣ, Нозим); grade 7 (Масъуди Саъди Салмон, Абӯсаид); grade 9 (Амир Хусрав, Сайфи Фарғонӣ, Носири Бухороӣ, Восифӣ); grade 10 (Қоонӣ); grade 11 (the Jadid survey, pp. 14–16; Яҳёхоҷа, p. 96; the independence-era survey, pp. 342–345). Expected: about **+100 poems**, poets without a poem 85 → about 67.
3. **Round 2: chapters that print more verse than we publish.** Фирдавсӣ, Низомӣ, Мушфиқӣ, Ҷалолуддини Балхӣ, Ҳозиқ, Ҷомӣ, Саййидо, Шавкат, Носири Хусрав, Анварӣ, Хоқонӣ, Саноӣ, Хайём, Сино, Боботоҳир, Ибни Ямин, Ҳилолӣ, Биноӣ, Бозор Собир, Турсунзода, Миршакар, Гулназар Келдӣ, Аминзода, Шукӯҳӣ, Лоҳутӣ, Айнӣ and others. Expected: about **+250 poems**.

## App health (after the rounds)

- Profile APK on an Android 7 (API 24) emulator with 2 GB RAM, and on the owner's phone if connected: cold start, poem list, a long poem, the Lexicon, search; no frame over 700 ms, no ANR, no crash.
- Open 100 poems and 30 poet pages in a row; compare `dumpsys meminfo` before and after.
- Check a cap on every stored list (recent activity is capped at 20; favorites, bayoz, learning progress) and that no cache grows without limit; add tests for any cap added.
- Report the APK size against 25.0 MB (arm64, preview.1) and the size of `runtime_works.json`.

## Risks

- **Attribution in survey chapters.** Accepting a poet named in a lead-in, rather than the chapter owner, is new. Mitigation: accept only an explicit name or signature; the audit's new signature check; every such block listed for the team.
- **Spans take more than verse.** Mitigation: `take_span` refuses anything that is not verse, the audit checks every line is on its cited pages and not prose, and every span was read on the page.
- **Excerpts of one long poem** (a qasida quoted in parts, «Шоҳнома» passages) become separate records. They are what the book prints; titles are their first lines.
- **Duplicates across books.** The publisher's duplicate check (contained text, half the lines shared, or the same poet, title and first line) skips reprints; a fuller text absorbs a shorter excerpt only when a person names it (`merges`).
- **Catalogue size.** More full records grow `runtime_works.json` and memory; measured in the app-health pass.
