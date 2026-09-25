# Phase 0 — Plan: «Муҳр» redesign

> Screenshots for this phase were removed from the repository on 25 Sep 2026 to keep it small. They remain in git history: `git show dcd3805:docs/design/phase0/<file>`.

Date: 24 Sep 2026 · Branch: `provenance-repair-2026-09-19` · Source of truth: `ZARBULMASAL_UX_RESEARCH_REPORT.md` (v2)

Visuals for this phase are in `docs/design/phase0/`:

| File | What it shows |
|---|---|
| `font_proof_390_light.png`, `font_proof_390_dark.png` | Font proof sheet at 390 px (cut into 4 panels), «Муҳр» day and «Шаб» night, with token swatches |
| `font_proof_1440_light.png`, `font_proof_1440_dark.png` | The same proof at 1440 px |
| `baseline_home.png`, `baseline_reader.png`, `baseline_proverb.png` | The app as it is now (current working tree): 390 and 1440 px, light and dark, Tajik and Persian interface |

The proof is rendered by Flutter's own text engine (`tool/design/font_proof_test.dart`), not by a browser. It uses no fallback fonts, so any missing glyph shows as a blank box. Every sample text is read word for word from the bundled assets.

---

## 0. Pre-flight findings (please read first)

1. **The repo is on iCloud Drive (Desktop sync).** `.git/index` had been evicted to the cloud ("dataless") and git could not read it. I rebuilt the index from HEAD. The evicted file is kept as `.git/index.icloud-evicted.bak`. Writes into `.git` also time out now and then. **Recommendation:** move the repo out of `~/Desktop` (or turn off "Optimize Mac Storage") before the next phases. Otherwise builds and git may fail at random.
2. **There is a lot of uncommitted work that is not in HEAD `259d17f`.** That is 85 modified tracked files and 39 untracked files (not counting the design report I copied in), including `runtime_works.json`, the vocabulary feature, `verse_structure.dart`, and new tests. The old index probably had them staged. No file content was lost. I backed up a full patch and a tarball of the untracked files outside the repo. My changes will sit on top of this work, so please commit or confirm it before Phase 1. That keeps the design diff reviewable.
3. **iCloud conflict duplicates** `lib/router/app_router 2.dart`, `lib/shared/providers/app_providers 2.dart`, `lib/features/settings/settings_screen 2.dart`, `lib/core/design_system/qalam_reading_page 2.dart`, `pubspec 2.yaml`, `README 2.md`, `web/favicon 2.png`. **These cause all 4 current `flutter analyze` errors.** They are stale copies. I have not deleted them. Please confirm and I will remove them in Phase 1.
4. **The source code is newer than the build the report audited.** `build/web` is from 00:01 today. The reader, poet dossier, and source panel were edited between 09:52 and 11:10 today, possibly by another agent (there is an `.orchestra/` state DB). I re-captured the current tree (the `baseline_*` images). F1 still holds: the header still says «Матн санҷида шудааст». **If another agent is still editing this branch, we will collide.** Please pause it.
5. **The baseline is not green.** `flutter analyze` reports 4 errors, all from the duplicates in item 3, and 10 infos. `flutter test` gives **547 passed, 14 failed** before any change of mine. The failing tests are:
   - Content and data: the Ibn Sina rubai attribution/page; Qanoat distinct works; Qanoat title/page span; the quarantine reason for rejected candidates; page-backed works evidence and rights; Firdausi/Kamol second witnesses; Khirad provider labels; Persian history section translations.
   - UI: app text scale; Home/Explore search button names; 320 px RTL proverb page; `/` and `/daily` on a small phone; 48 px reading-action targets.

   I will not "fix" the content tests by editing data. That would break the hard rule. The UI ones overlap Phase 1 and 2 work, and I will make them pass. The rule "keep all existing tests passing" will be measured against this list: no new failures, and the UI failures fixed.

---

## 1. Open questions: your answers were template placeholders

The brief kept the placeholders (`<show with label "…" / hide>` and so on), so no option was chosen. These are the defaults I propose. **Phase 1 needs Q1 and Q3 decided.**

| # | Question | Proposed default | Why |
|---|---|---|---|
| Q1 | Persian-script renderings of poems (all 5,494 have `persianScriptSource: "generated"`) | **Show, with a fixed label** tied to the data field: «Хатти форсӣ — табдили механикӣ, на матни аслӣ» / «خط فارسی — برگردان ماشینی، نه متن اصلی». The label wording is up to you or the editors. | Honest and reversible. Hiding also removes a script-learning aid. |
| Q2 | Portraits (rights "unknown" for all 67) | **Seal-monogram plates by default.** Portraits appear only where a record says rights are cleared (none today). | There's no rights risk, and it fits the «Муҳр» direction. |
| Q3 | Oral heritage (0 items) | **Hide until content exists.** The route redirects to the Literature section, and no entry point shows it. | N8's success signal is "no path leads to an empty collection". |
| Q4 | Home leads with | **The daily ritual** (proverb + bayt exhibit), with the grade lens second. | This is the report's signature "exhibit" moment. The grade lens is still one tap away. |

---

## 2. What the data actually supports (drives N1 and the seal)

Measured from `runtime_works.json` (5,501 records):

| Field | Values |
|---|---|
| `textStatus` | `verified` 28 · `needsReview` 5,473 |
| `verification.evidenceLevel` | `primaryChecked` 28 · `needsReview` 5,218 · `rejected` 255 · **`editoriallyApproved` 0** |
| The 28 "verified" works | all are `primaryChecked`. 22 have a collated second witness (`exact` 15, `minor-variant` 7). 6 are primary only. |
| Rights | all 28 are `sourceAttested`. `rightsSource` is a repo file path. `reasoning` is an English policy sentence. |
| Page scans | 66 PNGs exist in `assets/data/literature/page_images/`, but **they are not in `pubspec.yaml`**. That is why the scan tile opens "not available". |

**The contradiction (F1):** the header badge reads `textStatus` ("verified"), while the checklist reads `verification.evidenceLevel` (`primaryChecked`, not editorially approved). Under the hard rule, **no work may show "verified" today.**

Proposed seal states. The labels are proposals for editor approval, and each state comes only from data fields:

| Seal | Condition (all must hold) | Status sentence (proposal) | Works today |
|---|---|---|---|
| **Pressed** | `evidenceLevel == editoriallyApproved` | «Матн аз ҷониби муҳаррир тасдиқ шудааст.» | 0 |
| **Outline** | `evidenceLevel ∈ {primaryChecked, secondWitnessLocated, collated}` and `pageVerified` | With a second witness: «Бо нашри чопӣ ва нусхаи дуввум муқобала шудааст · санҷиши муҳаррир дар навбат.» Primary only: «Бо нашри чопӣ муқобала шудааст · санҷиши муҳаррир дар навбат.» | 22 / 6 |
| **Absent** | anything else (these works are not shown publicly today) | «Матн дар баррасӣ.» | 0 visible |

- The header status line, the seal, and the Record tab all read **one derived getter** (`LiteraryWork.provenanceState`). Tests assert that no path shows "verified" unless `editoriallyApproved` holds.
- **Scan tile:** render it only when the image is actually bundled. Whether to bundle the 66 scans (≈ size and scan rights) is **your decision**. Until you decide, the tile shows one plain line: «Скани саҳифа ҳанӯз илова нашудааст».
- **N2 leak map:** `Tier A` → «Сарчашмаи асосӣ»; `exact` / `minor-variant` → «мувофиқ» / «фарқи ночиз» (wording proposal); `rightsSource` path → hidden (the Record tab names the edition instead); `reasoning` (English) → hidden, replaced by a fixed Tajik/Persian rights sentence per `rights.status`; `evidenceHash` → never shown (an editor name or role only, once the data has one).

---

## 3. Token proposal («Муҳр» day / «Шаб» night)

All contrast ratios are computed against the ground colour (WCAG 2.x). Everything used for text passes AA (4.5:1).

**Day, «Муҳр» (ivory, lamp-black, one cinnabar)**

| Token | Value | Contrast | Use |
|---|---|---|---|
| `paper` | `#F3ECDD` | — | ground (a warmer, slightly deeper ivory than today's `#F4EFE6`) |
| `paperRaised` | `#FAF6EC` | — | sheets, menus (the only raised surface) |
| `paperSunk` | `#E8DFCB` | — | wells, the proverb folio in day mode |
| `ink` | `#1A1714` | 15.2:1 | text |
| `inkSoft` | `#4F473E` | 7.8:1 | secondary text |
| `inkMute` | `#6B6256` | 5.1:1 (4.5 on sunk) | meta, pending states |
| `vermilion` | `#B02E1C` | 5.5:1 | **the seal, links, active states only** (no large fills) |
| `rule` | ink at 15% | — | hairlines |

**Night, «Шаб» (lapis-black)**

| Token | Value | Contrast |
|---|---|---|
| `lapis` | `#0B1222` | — |
| `lapisRaised` | `#131C33` | — |
| `lapisSunk` | `#070C18` | — |
| `ivory` | `#EFE7D6` | 15.2:1 |
| `ivorySoft` | `#BDB5A4` | 9.2:1 |
| `ivoryMute` | `#948D7E` | 5.7:1 |
| `vermilion` | `#EC6A52` | 6.0:1 (the seal stays vermilion at night) |

- **Removed as colour roles:** forest green (it read as "verified"), antique gold, and burgundy blocks. Status never relies on colour alone: seal shape plus words.
- **Ikat «Атлас»:** only on collection covers, share cards, and the splash, and never behind reading text. It is procedural and seeded from the collection ID. The motif grammar is a placeholder until a textile specialist reviews it.
- **Spacing:** 4-pt base; sections 32 (mobile) / 48 (desktop); bayt gap = 1.2 × line height; list rows 16 px padding with hairlines.
- **Motion:** 250–320 ms fades; the seal "press" is 240 ms, once per session; everything is static under reduced motion.

## 4. Typography proposal (from the proof)

| Role | Proposal | Alternative | Proof result |
|---|---|---|---|
| Exhibit serif (Cyrillic, 40–120 px) | **EB Garamond** | Cormorant Garamond | Both PASS. Cormorant draws **л/д in an archaic lambda form** («Мисʌи»), which is a readability risk for school readers. EB Garamond keeps the conventional Cyrillic forms. |
| Reading serif (verse, body) | **PT Serif** | Brygada 1918, EB Garamond | PASS. Cyrillic by ParaType, sturdy at 17–20 px. |
| UI grotesque | **Golos Text** | Onest | PASS, and covers every character in the corpus. Onest lacks U+00AD, which the corpus uses. |
| Persian exhibit (Nastaliq) | **Noto Nastaliq Urdu**, pending a native Persian reader's review | Gulzar | Shapes well. It is **Urdu-tuned** (digit forms ۴۵۶۷, final ی) and needs line-height ≥ 2.0. Gulzar lacks tatweel (U+0640), which the corpus uses. |
| Persian reading | **Noto Naskh Arabic** (keep) | — | PASS |
| Persian UI | **Vazirmatn** | — | PASS |
| **Rejected** | **Literata** (report §12) | — | FAIL: no Ҳ Ҷ Ӣ Ӯ glyphs (tofu in the proof) |
| **Rejected** | **Manrope** (report §12) | — | FAIL: none of the 6 Tajik letters |
| **Rejected** | **Markazi Text** (report §12) | — | FAIL: no ZWNJ (U+200C), which Persian needs |

- **Size scale:** exhibit 44–64 (mobile) / up to 120 (desktop); title 28–34; verse 19–20 at height 1.7; body 16–17; meta 12–13. **It never shrinks on desktop.**
- **Offline bundle:** the fonts stay bundled (no runtime fetching). I will ship **static instances subset to Cyrillic + Latin + punctuation** (Persian fonts subset to Arabic + Persian) with fontTools. That avoids variable-font weight quirks in Flutter and should keep the added download to roughly ≤ 1 MB. The current Noto files stay as fallbacks. All candidates are SIL OFL 1.1, so each ships with its OFL text.
- **Download source (please confirm):** the TTFs come from `github.com/google/fonts` (the `ofl/` directory). Nothing is added to the project until you approve the choices.

---

## 5. Files to change, by phase

**Phase 1 — NOW (N1–N8)**

| Item | Files |
|---|---|
| N1 status and seal state | `literature/domain/literary_work.dart` (the derived `provenanceState`), `domain/verification_record.dart`, `presentation/poem_reader_screen.dart` (header chips → one status line), `presentation/source_panel.dart`, `core/design_system/qalam_source_badge.dart`, `presentation/school_canon_screen.dart` and `poet_detail_screen.dart` (the same vocabulary), `core/l10n/app_translations.dart` |
| N2 leaks | `source_panel.dart`, `domain/source_edition.dart`, `domain/rights_record.dart`, `app_translations.dart` (`lit_source_tier_a`) |
| N3 bayt layout | a new `presentation/widgets/bayt_verse.dart`, `domain/verse_structure.dart` (a pairing helper; it never alters text), `poem_reader_screen.dart` |
| N4 script vs language | `shared/providers/app_providers.dart` (a new `readingScriptProvider`), `core/design_system/qalam_controls.dart:62` (today it calls `setLanguage`, which is the F3 bug), `qalam_reading_page.dart`, `literature/data/reader_preferences_provider.dart`, `settings/settings_screen.dart` (Interface vs Reading groups) |
| N5 generated-script label | `poem_reader_screen.dart`, `qalam_reading_page.dart`, `app_translations.dart` (it reads `persianScriptSource`) |
| N6 resume | `shared/providers/recent_activity_provider.dart` (`isContent` flag + anchor), `poet_detail_screen.dart`, `levels_screen.dart`, `global_search_screen.dart` (they stop setting the resume target), `home/home_screen.dart`, `shared/widgets/onboarding_overlay.dart` (drop the "continue" promise) |
| N7 counters | `maxLength: 256` in 6 files → `inputFormatters` (the limit stays, the counter goes): `global_search_screen`, `poets_list_screen`, `proverbs_list_screen`, `books_screen`, `history_screen`, `literature_search_screen` |
| N8 empty sections | `explore/explore_screen.dart`, `literature_hub_screen.dart`, `router/app_router.dart` (a `/literature/oral` redirect when empty) |
| Tests | new tests for each item under `test/features/...`; the 5 failing UI tests go green |

**Phase 2 — visual system:** `qalam_colors.dart`, `qalam_typography.dart`, `qalam_spacing.dart`, `qalam_motion.dart`, `core/theme/app_theme.dart`, `app_colors.dart`, `pubspec.yaml` + `assets/fonts/*`, a new `qalam_seal.dart` (3 states, taking an **asset path**, where `assets/design/seal_placeholder.png` is visibly marked PLACEHOLDER), a new `qalam_record_tabs.dart` («Дар бора | Сабт»), `DESIGN.md`, and list screens de-carded (Explore, Learn, History, Library, Saved).

**Phase 3 — signature screens:** `home_screen.dart` + `qalam_daily_hero.dart` (exhibit), `poem_reader_screen.dart` (the day reader and the lapis night title card), a new `core/design_system/atlas_cover.dart` (a procedural ikat painter, seeded), `categories_screen.dart`, and `saved_screen.dart` → «Баёзи ман» with named anthologies (a new local-only provider in SharedPreferences, with no accounts or sync).

**Phase 4 — NEXT:** `router/app_router.dart` + `shared/widgets/app_scaffold.dart` (a left rail at ≥ 1200 px, with navigation kept on pushed screens), Explore + Literature hub merged into one index, end-of-text navigation (poems, proverbs, history), the desktop reading room (context pane), `history_screen.dart` / `history_detail_screen.dart` (content first, era navigator, prev/next), and `global_search_screen.dart` (one-line subtitles, highlights, counts, a better no-results state).

---

## 6. CONTENT/PROVENANCE — TEAM VERIFICATION REQUIRED

I have left all of these unchanged.

1. **Generated Persian-script text shows transliteration artefacts.** Rudaki `rudaki_buyi_juyi_muliyon_grade5_2017_p54` has «می‌هربان» (for «меҳрбон») and «نـزدت» with a stray tatweel (U+0640) in `persianScriptRepresentation`. The data itself says "Mechanical … not a Persian source". (Report §3.4 #1.)
2. **The Persian forms of proverbs (`seedProverbs[].persianText`) carry no provenance field.** It is unknown whether they are sourced, translated, or generated. Example: #24 has «شیار کن» for «шудгор кун».
3. **Status data disagrees:** 28 works have `textStatus: "verified"` but `evidenceLevel: "primaryChecked"`. Which one is the editorial truth? Until you answer, the UI will follow the stricter field.
4. **Page scans:** 66 scan PNGs are referenced by `sourceImagePaths` but not bundled. Should they be shipped (rights of the textbook scans)?
5. **Stray soft hyphens (U+00AD)** appear in several work titles, for example «Қиссаи «Одамони куҳна» ба мавзӯи муҳим­». All of those records are `needsReview`, so none of them is public.
6. The report's items §3.4 #2–#4 still stand: 150 vs 149 proverbs; proverb sources without pages; 145/159 poet counts.

---

## 7. Decisions I need from you before Phase 1

1. Answers to Q1–Q4 (the defaults in §1 are fine if you agree).
2. Font choices: EB Garamond vs Cormorant (exhibit), PT Serif (reading), Golos Text (UI), Noto Nastaliq Urdu (pending Persian review), Vazirmatn + Noto Naskh.
3. Seal-state wording in §2, or tell me who writes it.
4. Commit or confirm the existing uncommitted work, allow removal of the ` 2` duplicate files, and ideally move the repo off iCloud.

---

## 8. Decisions (approved 24 Sep 2026)

- Q1: show the generated Persian-script text, always with the label. Q2: seal-monogram plates. Q3: hide until content exists. Q4: daily ritual first.
- Fonts: EB Garamond (display), PT Serif (reading), Golos Text (UI), Noto Nastaliq Urdu (Persian exhibit, pending a Persian reader), Vazirmatn + Noto Naskh Arabic.
- The seal wording in §2 is approved as a **draft**; editors may still replace it.
- The iCloud ` 2` duplicate files may be deleted.
