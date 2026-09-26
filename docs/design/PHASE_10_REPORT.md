# Phase 10: books not pages, offline, spacing, images, phone and Play build

Date: 26 Sep 2026. Branch `main`, commits `34867f1` to `6c14608`, plus this report. Not pushed.

## Checks

Run before every commit; the last run was on `6c14608`.

| Check | Result |
|---|---|
| `flutter analyze` | No issues |
| `flutter test` (goldens included) | **804 passed**, 0 failed (765 at the start of the phase) |
| Coverage (minimum 80%) | **89.7%** |
| `provenance_linter.py`, adversarial re-audit | PASS |
| `audit_textbook_poems.py` on fresh page dumps | 1,076 poems, **0 failures** |
| `unittest` `tool/literature` / `tool/history` / `tool/design` | 130 / 2 / 5 passed |
| `unittest tool.test_deep_browser_audit` | 19 passed |
| Every other step of the quality job in `ci.yml` | PASS |

Goldens were regenerated once, for the poet page only. The diff was checked first; two intended changes caused it:
- the recompressed portrait;
- the caption, which now reads «…, синфи 5 (2017)».

## Commits

| Task | Commit | What |
|---|---|---|
| 0 | `34867f1` | `PHASE_9_REPORT.md` |
| 1 | `d11b1d2` | Sources show book, grade and year, never a page |
| 2 | `5c2bbb6` | Book covers are never fetched; offline and ad-free guard test |
| 3 | `997ac92` | Persian script shown with no transliteration note |
| 4 | `bc86a5e` | Books show only «Манбаъ: kitobkhon.net», linked |
| 5 | `c0cd50a` | Spacing pass |
| 6 | `a5e1fd5` | Portraits and covers as small WebP; cache warm-up |
| 9 | `6c14608` | Version `2.0.0+2007` for the Play bundle |

## 1. No page numbers on screen

`formatBookCitation()` gives «Адабиёти тоҷик, синфи 5 (2017)» or «Зарбулмасал ва мақолҳои тоҷикӣ (1956)». No author, imprint or page is shown. It is used for:
- **Proverbs:** the sources section, the source line (`sourceNote`, now «title (year)» in the seed) and the printed-meaning and printed-example labels;
- **Poems:** the source line;
- **Poets:** biography sources and portrait captions;
- **Other screens:** history entries (the per-section page footer is gone), the lexicon sheet, the school canon, oral heritage and literature search.

Pages stay in the data for the checks: `SourceRef`, `SourceEdition`, `poets.json`, history sections and `words.json`. `test/no_page_numbers_test.dart` sweeps every proverb, poem, portrait, biography and lexicon citation for page numbers. One biography (Аҳмадҷони Ҳамдӣ) said «дар с. 16» in its editorial text; that clause was removed.

## 2. Offline and no ads: what I found

- **pubspec:**
  - app dependencies are riverpod, go_router, shared_preferences, url_launcher and cupertino_icons;
  - there is no ad, analytics, crash-reporting or HTTP package;
  - flutter_driver, which pulls `sync_http` and `webdriver`, is a dev dependency and is not in the app.
- **Gradle:** adds no SDK. `analytics-library` in `verification-metadata.xml` is the Android build tools' own.
- **Manifest:**
  - the main manifest has **no INTERNET permission**; only the debug and profile manifests have it, for Flutter tooling;
  - the shipped APKs request nothing but AndroidX's internal `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`;
  - I checked with `aapt2` on the installed preview and on all three release APKs.
- **Network use in code:**
  - the only path was `BookCover`, which fell back to `Image.network` for the 702 of 710 books with no bundled cover;
  - in release that request always failed, because the permission is absent;
  - covers are now drawn only from bundled assets, and the others show the typographic placeholder;
  - external links («Хондан дар Китобхон», «Манбаъ: kitobkhon.net», maorif.tj) open in the browser.
- **Guard:** `test/offline_guard_test.dart` fails on any network API in `lib/`, an ad, analytics or HTTP package in `pubspec.yaml`, or a network or advertising permission in the manifest.

## 3. Persian script without a note

The note «Хатти форсӣ — табдили механикӣ…» is removed everywhere it appeared:
- the poem reader and the bayt of the day;
- Continue reading and the bayoz;
- end-of-text links, search results and history links.

The proverb badge «Хатти форсӣ: транслитератсия» is gone too. The data keeps `persianScriptSource` and `persianOrigin`.

## 4. Books

The book page shows one link, «Манбаъ: kitobkhon.net» (khirad.tj for its 10 books). It opens the book's page in the browser. The following are gone:
- the red rights notice;
- the provider section with its metadata note;
- the separate «Саҳифаи манбаъ» button.

## 5. Spacing

**Method.** `tool/design/spacing_audit_test.dart` renders 29 screens with the real fonts at:
- 320 and 390 px;
- Tajik and Persian;
- text scale 1.0 and 1.3.

That is 232 screenshots before and 232 after. For each it measures the real glyph boxes and flags:
- text touching an icon or other text (< 4 px);
- lines colliding;
- text within 4 px of its box's edge.

I also read contact sheets of every screen at 320 px and 1.3.

**Found and fixed** (before/after images in `phase10/`):

| Screen | Problem | Fix |
|---|---|---|
| Literature hub, 320 px, 1.3 | «Шеърҳои баргузида» row overflowed by 46 px | eyebrow wraps; `metaGap` before the link |
| Poem reader | poet link 3 px from its chevron | `iconLabelGap / 2` |
| School canon | «Ҳатмӣ» tag padding 6×2 | `badgePadH` × `badgePadV` |
| History | retry button side padding 4 px | `iconLabelGap` |
| Lexicon, Explore word card (Persian UI) | Tajik text laid out RTL, full stop first | `scriptDirection()` from the text's script |

**After.** 0 render errors and 0 findings across all 232 variants. The tour card on the onboarding screen overlays the dimmed page, which the tool cannot tell from a collision, so onboarding was checked by eye.

**Evidence** in `phase10/`:
- `spacing_*_before_after.webp`;
- `spacing_after_all_screens_*.webp` (every screen, four combinations).

## 6. Images

Portraits and covers were already bundled (`isSourceBacked` refuses remote portraits), so nothing is fetched now.

| | Files | Before (JPEG) | After (WebP q80) |
|---|---:|---:|---:|
| Poet portraits (≤ 224×288, 2× the 112×144 poet page) | 67 | 2,247,426 B | 556,938 B |
| Book covers (≤ 232×340, 2× the 116×170 book page) | 8 | 469,810 B | 113,114 B |
| **Total** | 75 | **2.72 MB** | **0.67 MB (−75%)** |

- **Tool:** `tool/design/compress_images.py`, with tests. It scales each image to just cover the 2× box, never upscales, and rewrites the JSON paths.
- **Decoding:** portraits and covers decode at the size shown (`cacheHeight` / `cacheWidth`).
- **Warm-up:** `PortraitWarmUp` on Home precaches the poet list's first screenful after the first frame. It uses the same `ResizeImage` provider as the list, so the list reads from the cache.
- **Tests:**
  - `test/bundled_images_test.dart` checks every image is WebP, within the box and named by a record;
  - `portrait_warm_up_test.dart` checks the warm-up.

## 8. Phone check

Xiaomi 2412DPC0AG (MIUI, Android 16), serial 7H6XHE7LSOQKYH69.

- **Install:**
  - built with versionCode 4006 (`1.0.0-preview.2`), signed with the same local debug key as the installed 4005;
  - `adb install -r` printed **Success**;
  - the first-install time is unchanged, so the update kept the app's data.
- **Airplane mode:** switched on by the owner; the active network was none.
- **Cold start** (`am start -W`): 1,097 ms on the first launch after install, then 558 ms and 538 ms.
- **Walked, all offline:**
  - Home, Literature, the poet list, Рӯдакӣ, a poem in Tajik and in Persian script;
  - the proverb categories, «Дасти одамизод — гул.» with its sources;
  - Books and «Баъди борон» (bundled cover, source link);
  - search («Ayni» finds Садриддин Айнӣ);
  - then in Persian: settings, Home, Explore, the Lexicon, a Hafiz poem and a proverb.
- **What the screens showed:**
  - every source line shows book, grade and year only;
  - there is no Persian-script note and no rights notice;
  - Tajik text in the Persian UI keeps its full stop at the end.
- **Log:** no crash or Flutter error; memory PSS 232 MB after the tour.
- **Restored:** the app language was set back to Tajik.
- **Screenshots:** `phase10/phone_*.webp`.

## 9. Play build

- **Signing:**
  - no release signing existed, so an upload keystore was created outside the repository;
  - the owner has the path, and the key was never committed;
  - certificate SHA-256: `22eb6e8e5d2c5c3b180d0688c73eab77a8fd6612324df93f8f2eead4dc59222d`.
- **Build options:** R8 and resource shrinking, `--obfuscate`, `--split-debug-info` outside git.
- **Checks:** `verify_android_signing_material.sh` and `verify_android_bundle.sh` passed.
- The bundletool 16 KB check needs a download and stays in CI.

| Artifact | versionCode | Size |
|---|---:|---:|
| AAB | 2007 | 56.2 MB |
| arm64-v8a APK | 4007 | **22.96 MB** (last arm64: 25.2 MB, −2.2 MB) |
| armeabi-v7a APK | 3007 | 20.40 MB |
| x86_64 APK | 6007 | 24.52 MB |

Copied, with a README and the debug symbols, to `~/Desktop/Zarbulmasal-release/`.

## Suggestions (task 7, not implemented)

### Decisions for the owner
- **Covers:** 702 of 710 books have no bundled cover. Bundling them means downloading them from kitobkhon.net (rights recorded as unclear); at the new size that is about 8 MB more.
- **Upload key:** if a Play listing already exists under another upload key, use that key instead.

### Content
- **Generated Persian script:** with the note gone, the mechanical transliteration shows. For example, Рӯдакӣ's «Ин ҷаҳонро нигар бо чашми хирад» appears as «این جهانرا نیگر با چشمی خیرد». A Persian reader should review the most-read poems first.
- **Сафармуҳаммад Айюбӣ:** his `biographyTj` also holds the opening of the drama «Амир Исмоил» (cast list), pasted after the biography.
- **Team verification:** the list in `PHASE_9_REPORT.md`; also the textbook sayings not yet added.
- **Nested quotes:** a proverb's printed form that already starts with «» is quoted again, so it shows as ««…» …».

### Size and speed
- **Data files:** `runtime_works.json` (6.4 MB) and `books.json` (1.8 MB) are the biggest assets. Shipping them gzip-compressed and inflating on the loading isolate would save about 5 MB of download.
- **Launcher icons:** the foreground PNGs (265, 156 and 75 KB) could be WebP, about 0.4 MB less.
- **Fonts:** subsetting Noto Nastaliq Urdu (690 KB) and Noto Naskh Arabic (308 KB) to the Persian range, as `build_fonts.py` does for the others, would save about 0.6 MB.

### Accessibility
- **Screen reader:** check TalkBack on poem lines and mixed Tajik/Persian rows.
- **Icon rows:** give chevron-only rows a label.
- **Spacing audit in CI:** run it as a non-blocking report. Its Python sibling, `compress_images.py`'s tests, needs Pillow, which the CI image lacks.

### Store listing
- **Data safety:** no data collected or shared, no network, no ads. This matches the build.
- **Rating and category:** content rating Everyone; category Books & Reference.
- **Screenshots:** the 390 px audit screens in Tajik and Persian are a base; Play wants 1080×1920 or larger.
- **Short descriptions** in Tajik and Persian are yours to approve.
