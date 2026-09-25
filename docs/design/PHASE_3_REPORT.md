# Phase 3 — Signature screens

> Screenshots for this phase were removed from the repository on 25 Sep 2026 to keep it small. They remain in git history: `git show dcd3805:docs/design/phase3/<file>`.

Date: 24 Sep 2026 · Screenshots: `docs/design/phase3/` (390 px and 1440 px, light and dark, Tajik and Persian; `*_390_detail.png` are close-ups)

## Checks

| Check | After Phase 2 | After Phase 3 |
|---|---|---|
| `flutter analyze` | No issues | **No issues found** |
| `flutter test` | 611 passed, 8 failed | **625 passed, 8 failed**, 0 new failures |

The 8 failures are the same pre-existing content/data mismatches (see `PHASE_1_REPORT.md`).

## What changed

- **Home «Экспозиция» (Q4: the daily ritual first):**
  - A quiet search line.
  - Then the **proverb of the day exhibited**: date, catalogue line «№ 079 · САБР» (id and category from the data), and the proverb set monumental in EB Garamond. The size scales with the column (34–60 px), and its text scaling is capped so it never overflows.
  - Below it, the other script: **Persian in Nastaliq**. If the reading script is Persian, the Nastaliq line becomes the hero.
  - The italic «*Бихонед* →» link.
  - **No seal**, because proverbs are not page-checked.
  - Then the **bayt of the day** (the first bayt of the day's poem, in the reading script; a generated Persian bayt carries its label) and **Continue reading** as a quiet row («Шеър · Байти 4 аз 6»; the old burgundy block is gone).
  - Then **«Ганҷина»**: Literature, Proverbs, History, Lexicon and Library with real counts, each shown only once its catalogue has loaded.
  - Last, the **grade lens** «Синфи шумо». Its chips are the grades that actually appear in the school canon, and each opens the canon on that grade.
- **Poem reader:**
  - **Day:** a larger serif title with the **seal pressed beside it**. It is the outline seal today, and tapping it opens «Сабт».
  - **«Шаб» (night):** the poem opens as a **centred title card**: the title in capitals, a pedigree line «АБӮАБДУЛЛОҲИ РӮДАКӢ · 858 – 941 · ҚАСИДА» built only from the data, a dossier link, the seal, and the status sentence.
  - Text size moved into an **«Aa» sheet**, which keeps the toolbar on one row at 390 px.
- **«Атлас» collection covers.** The proverb themes are now a rack of **procedurally generated ikat covers**:
  - Each pattern is seeded from the collection ID (stable, unique, no image rights).
  - The title always sits on a solid paper plate, never on the pattern, so contrast holds.
  - Covers size to their text, so 2× text still fits at 320 px.
  - **The motif grammar is a placeholder** until a textile specialist designs it.
- **«Баёзи ман» (Saved):**
  - Named personal anthologies shown as typeset covers with counts; a "new Баёз" cover creates one.
  - «Ба баёз» on the poem toolbar and the proverb page opens a checklist of your Баёз.
  - The Баёз page shows its texts in the reading script, with remove, rename, and delete (with confirmation). Texts no longer published show as "no longer available" and can be removed.
  - Below the covers: all saved texts and the reading history, as typographic rows (the card soup is gone).
  - It is stored **only on this device** (no account, no sync), and stored data is validated when it loads.
  - The tab is renamed «Баёз» / «بیاض».
- `QalamDailyHero` is removed; it was replaced by the exhibit.

## Existing tests changed (and why)

| Test | Change | Reason |
|---|---|---|
| Navigation shell (tj, fa); compact nav labels | «Баёз» / «بیاض»; the Home check uses the search entry | Saved renamed; the old «Кашфи фарҳанги тоҷик» tiles were replaced by the exhibit |
| N6 Continue reading (3 tests) | scroll to the uppercase «ИДОМАИ ХОНДАН» eyebrow | Continue now sits below the exhibit |
| N2 sweep | opens the record by the «Манбаъ» label | The button lost its decorative icon |
| Reader text size (2 tests) | open the «Aa» sheet first | Size moved into the sheet |

New tests: `phase3_signature_screens_test.dart`. It covers:
- the exhibit (display face, the Nastaliq line, no seal) and the Persian-script hero;
- the grade lens → the canon on that grade;
- the «Шаб» title card;
- unique «Атлас» seeds;
- creating a Баёз, collecting a poem from the reader, and unavailable items;
- the generated-title label on Home.

Also new: `bayoz_provider_test.dart` (create, fill, rename, delete, limits, persistence, malformed data, unique IDs within one clock tick).

## Skipped or deferred (and why)

1. **Earlier days** (an archive of past proverbs and bayts) is a LATER item (L4).
2. **The seal "press" animation** (240 ms, once per session) is deferred, because nothing on Home carries a seal: proverbs are not page-checked. It is worth doing once your real seal artwork arrives.
3. **Bayt-level collecting** (long-press a bayt) is a LATER item (L1). Today a Баёз holds whole poems and proverbs.
4. **Ikat on history eras and grades, and on share cards/splash**: eras come with the History redesign (Phase 4). Share cards and the splash are not in scope yet.
5. **Desktop**: Home and the reader are still inside the 760 px column. The desktop reading room is Phase 4.
6. The code review (flutter-reviewer) found **1 critical, 2 high, 1 medium, 1 low**, all fixed:
   - The design-system layer imported a feature widget. The Баёз dialogs moved to `shared/widgets`.
   - Generated Persian titles were unlabelled in Home's Continue row and in Баёз rows. They now carry the label.
   - Баёз IDs could collide on web's millisecond clock. IDs now have a sequence and a random suffix.
   - Items for texts no longer published were counted but hidden. They now show as unavailable, with a remove button.

## CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED (new in Phase 3)

1. **Bayt of the day without a Persian form.** In the Persian interface, the bayt of the day can be a poem whose data has no Persian-script text. Example: «Дар шеър се тан паямбаронанд», Саъдӣ. It then shows in Cyrillic, as recorded, without any claim. Should the daily selection prefer poems that have a Persian form for Persian readers? Changing the daily selection rule is your call.
