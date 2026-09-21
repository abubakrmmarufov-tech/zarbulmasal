# Zarbulmasal QA Audit & Release Verification Record

Date: 2026-09-14
Environment: Flutter 3.47.2, Dart 3.13.2, Android SDK 36.1.0, Chrome for Testing 153.0.8010.12  
Branch: `main` (`6efd3b4`, with preserved user-staged historical download artifacts)

> **Current-state override — 2026-09-22:** The dated audit below is a historical
> record from 2026-09-14 and is not current Play release signoff. The current
> worktree is branch `provenance-repair-2026-09-19` at audited source checkpoint
> `1120270` with 394 tests
> passing and 82.18% line coverage (7,720/9,394 lines), clean analysis, strict Gradle dependency
> verification with valid metadata and a successful offline `assembleDebug`, and passing
> CI-equivalent web and browser audits. The CI web job now repeats the prepared-release
> Chromium audit with pinned Playwright 1.62.0 before publication, and the Pages publish
> checkout explicitly disables persisted credentials before configuring its scoped token remote.
> The current local production-audit score is **84/100 (launchable with caveats)**:
> the release web sweep covers 8 viewports and 209 route/mode checks with no page errors,
> failed requests, console errors, or layout overflows. The current GitHub Pages root and
> privacy URL both return HTTP 200, and the same 8-viewport/209-route sweep now passes
> against the live deployment; Android signing/device and content gates remain open below.
> The latest content loop (2026-09-22) visually checked additional uploaded-book
> witnesses and corrected several extracted titles/attributions: the validator now
> reports **31 primary-page-checked works, 23 secondary-witness collations, 8
> primary-checked works without a second witness, 5,217 pending works, 253
> explicit rejects, and 0 pending review records without a printed page**. The
> final three page gaps were verified against the Grade 11 pages 290 and 298 and
> Grade 6 page 12 witnesses. New page
> proofs include Khayyam, Bedil/Tughrol attribution correction, Saadi, Lоҳутӣ,
> Firdausi, Kamol, Hiloli, Ahmadi Jami, Loiq, Hafez, Sayyido, and three exact
> Ministry-hosted second witnesses for Bedil, Hafez, Lоҳутӣ, and Loiq, plus additional
> duplicate/prose quarantine decisions. Rights remain unknown and these records
> remain non-displayable.
> The pre-remediation security scan
> recorded 9 findings (7 low, 2 medium); the
> current tree includes the corresponding fail-closed URL, reader-preference,
> biography, candidate-content, PDF-path, and Android release-toolchain
> hardening. A sealed parent-led scan of the current snapshot reported 0
> reportable findings across the inspected runtime, release, provenance,
> privacy, and source-inventory surfaces with partial coverage. The latest
> sealed scan (`d53aabe8-cda0-4b0c-80be-6d983557a2ad`, 2026-09-21) retains the
> same result; the sealed working-tree diff scan
> (`e449b572-260e-4399-9a7d-820d12f4f212`) also reported 0 reportable findings
> across its 111-item review inventory with no scan warnings. Coverage remains
> explicitly partial because the
> broader 740-file target was not closed file-by-file. Remaining operational follow-up is live
> hosting/device verification, production signing, and final repository-wide
> review.
> The latest sealed Codex Security Standard scan (`1cbcd37a-d3ad-4874-b6a1-261499b52de9`) found 0 reportable findings across the inspected runtime/state, URL, Android release, web/cache, GitHub publication, provenance, and dependency surfaces. Its 761-file worktree inventory remains explicitly partial because protected GitHub controls, production signing, live Pages publication, physical-device upgrade, and a fresh advisory database were not observable; it is not a repository-wide security sign-off.
> The unused `zarbulmasal://` Android intent filter was removed after the
> current security review found no runtime handler for it; the manifest
> regression and strict offline debug build now pass. The latest focused
> working-tree diff scan (`948f26e9-364d-4306-8095-898e1da72d70`, 2026-09-21)
> found 0 reportable findings across the pinned bundletool download/checksum,
> App Bundle verifier, CI artifact paths, and Android 16 KB evidence surfaces;
> coverage remains partial across the 740-file dirty target.
> The AGP 9 compatibility switches in `android/gradle.properties` are deliberate:
> removing them was tested against the current Flutter Gradle plugin and failed at
> plugin application with an `ApplicationExtension`/`AbstractAppExtension` cast;
> the strict build passes with the switches retained.
> The previously deferred developer-only enrichment path has since been
> hardened to parse literal mappings without executing source, with a safety
> regression test, and that regression now runs in CI. Other post-scan changes
> include moving historical local APKs to a recoverable quarantine and updating
> this audit register. An independent review then found and the current tree
> fixed a low-severity stale-dotfile issue in the manual Pages deploy helper.
> The strict provenance linter now additionally requires verified primary-page
> imagery for page-checked records, rejects image paths outside the local
> page-image evidence directory, and requires complete bibliographic identity
> plus an uploaded-PDF or `maorif.tj` source reference for checked/secondary
> witnesses; secondary witnesses must also declare inspected local page imagery.
> CI now also runs the raw adversarial provenance re-audit for fake pages,
> generated source masquerading, and unreviewed verifier metadata.
> The Kamol Khujandi «Гуфтам ба чашм» record was also corrected after visual
> PDF review found its old Grade 7 filename pointing at a Grade 9 page image:
> Grade 7 printed page 105 is now primary, Grade 9 printed page 197 is retained
> as a secondary witness, the two textual variants are recorded, and rights
> remain `unknown`; the record is still withheld from publication.
> Rudaki’s four-line record now also has a visually inspected exact witness
> collation between Grade 5 printed page 50 and Grade 6 printed page 12; Saadi’s
> six-line record is similarly collated between Grade 5 printed page 111 and
> Grade 9 printed page 39, and Ibn Sina’s sixteen-line record between Grade 5
> printed page 71 and Grade 8 printed page 135. Their rights remain `unknown`, so all remain
> withheld from publication.
> A source-controlled privacy policy is now included in `web/privacy.html`,
> copied into the local release web artifact, and reflected in the in-app
> disclosure. The current web-only Pages deployment (`gh-pages` commit
> `ee17ec5`) returns HTTP 200 for both the app root and privacy-policy URL, and
> the live browser sweep passes. Android download publication remains withheld
> until signing.
> No production signing keystore is available. A fresh local release-mode AAB
> was built with a temporary QA certificate only; it is not a public release
> artifact. The current QA AAB is 59,676,404 bytes with SHA-256
> `ba9faa26fc39089d515abad0fd1ea0a10d1b74d54002942e02f292174f876f51`, and its
> temporary QA certificate SHA-256 is
> `e6c4a6a69ad368c6cea3e485f25de825b5d2437f6c4ef33dd10cc7a567b82c9d`.
> After normalizing the extracted certificate digest to lowercase,
> the bundle verifier accepts the valid QA-signed AAB and the retained release
> evidence verifier passes ZIP/JAR, package/version, 16 KB native ELF
 > alignment, bundletool `PAGE_ALIGNMENT_16K`, R8 mapping, native symbols, and
 > Dart symbols. The QA certificate is temporary, so production signing and
 > Play identity remain unverified.
> Earlier source debug smoke evidence built, installed, and launched version
> `2.0.0` / code `2004` on a physical Android 16/API 36 device; this audit
> environment has no connected device or emulator, so no fresh native evidence
> was added. Signed-release install/upgrade remains unverified. A fresh
> temporary-QA-signed split/universal APK build also passed
> `prepare_android_downloads.sh`, including package/version/ABI/certificate,
> zipalign, and SHA-256 staging checks; those APKs are diagnostic and were not
> published. The portal/downloads remain intentionally withheld, and the active CI workflow
> builds and archives the signed AAB only when the real production secrets are
> present. The current worktree contains
> 159 catalogued author records (145 public; 6 rejected extraction/non-author artifacts; 8 pending review) and 5,501 works: 0 editorially approved, 31 primary-page-checked,
> and 5,217 pending, with 253 high-confidence classroom/prose or duplicate
> extraction false positives
> now explicitly rejected; 8 of the 31 page-checked works still lack a second
> witness. The current declared-source biography pass now covers 145 authors
> (76 marked `SOURCE_BACKED` and 69 declared editorial summaries);
> 14 unsupported biographies remain quarantined. The current source-backed biography pass covers 76 authors and the declared editorial-summary pass covers 69 more. The corrected Ibn Sina rubai now has an exact Grade 5 p. 62 / Grade 8
> p. 142 collation. The pending validator metrics include 5,217 records still
> under review; 8 of the 31 primary-page-checked records lack a second witness,
> and 0 pending records lack a printed primary page. All remain non-displayable.
> Pending full text is withheld from the shipped runtime and none are
> displayable. The runtime JSON now also contains zero full-text fields and
> zero incipits for rights-unknown literary works, and zero oral heritage text
> fields; candidate generation and the oral validator enforce those distribution
> boundaries. Treat the current Play status as **not ready** until
> the secret-gated signed AAB, signed-release upgrade check, and remaining
> content review pass.

> **Current content override — 2026-09-22:** The latest validator reports 23
> secondary-witness collations and 8 primary-page-checked works still lacking
> a second witness. Kamoli Khujandi’s «Дӯст медорад дилам ҷавру ҷафои дӯстро»
> now has an exact current Maorif Grade 7 2025 second witness on pp. 102–103.
> Rudaki’s «Бӯйи Ҷӯйи Мулиён» now has a complete Ministry
> Grade 5 2025 second witness on p. 56 with a minor orthographic variant;
> Qanoat’s «Мавҷи одам» (pp. 149–150) and «Мавҷи бародарӣ» (pp. 150–151)
> have exact Ministry Grade 6 second witnesses. Rights and publication
> approval remain unresolved.
> Sayyido’s nine-line «ОМАД БА ЁД» is now collated between Grade 10 p. 74 and
> independent Grade 7 p. 161 witnesses with a recorded minor spelling variant;
> the local page proof is retained and the work remains review-only.
> A source-link correction also detached the Grade 7 2025 pp. 102–103 witness
> from Kamoli Khujandi’s distinct «Ошӯби ҷонӣ» record; it remains attached only
> to «Дӯст медорад дилам ҷавру ҷафои дӯстро». The held Grade 7 2018 PDF now
> records «Ошӯби ҷонӣ» at printed p. 106 with no unverified secondary witness.
> Since that earlier override, 14 further textbook page proofs were added or
> corrected: primary-checked works are now 31, rejected extraction/prose or
> duplicate candidates are 253, pending works are 5,217, and pending review
> records without a printed page are 0. Four exact official second witnesses
> were added for Bedil (p. 146), Hafez (p. 93), Lоҳутӣ (p. 113), and Loiq (p. 288). One record previously linked to Bedil was
> corrected to Tughrol after the source page explicitly named Tughrol; two
> extracted title fragments were replaced by the printed headings «Сад ҷон
> фидои дӯст» and «Ҳеч нест». Rights remain unknown, so these records stay
> withheld.

> **Current browser smoke evidence — 2026-09-22:** A fresh local release web
> artifact was served under `/zarbulmasal/` and visually exercised through
> onboarding, the Literature hub, a real `needsReview` work, its source panel,
> and an invalid work ID. The pending record showed its citation and review
> state without poem text; the source panel withheld the page scan; and the
> invalid ID rendered the localized safe error state. After enabling Flutter's
> web accessibility bridge, semantic labels for the pending record, source
> button, dialog, and withheld notice were exposed. The run is still web
> evidence and does not close native TalkBack, font-scale, focus-order, or
> signed-device QA.

> **Latest local browser sweep — 2026-09-22:** The freshly prepared release
> artifact again passed 8 viewport configurations and 209 route/mode visits,
> including all 159 poet routes, all 18 book routes, Persian/RTL, and dark mode,
> with 0 audit errors, overflows, console errors, page errors, or request failures.
> Manual screenshot inspection of the Persian home screen, dark Literature hub,
> and poet list also found readable RTL direction, intact card spacing, and
> source-backed portraits/placeholders without clipping.

> **Fresh content-repair artifact — 2026-09-22:** The web release was rebuilt
> after the uploaded-book audit repair and prepared with cache ID
> `e890bebc7d47173fc625`. The web-only Pages deployment (`gh-pages` commit
> `ee17ec5`) returns 200 for both the app and `privacy.html`; the live browser
> sweep covers 8 viewports and 209 route/mode visits with zero errors,
> overflows, console errors, page errors, or request failures. Android
> downloads remain withheld because production signing is unavailable.

> **Post-deploy UX/release hardening — 2026-09-22:** Persian Books cover
> placeholders now use the localized Persian title instead of leaking the
> Tajik title. Web release preparation now fails closed unless the compiled
> shell declares `<base href="/zarbulmasal/">`; this caught and prevented a
> root-relative bootstrap regression during the live deployment loop. The
> corrected artifact was published as `gh-pages` commit `ee17ec5` and passed
> the fresh live 8-viewport/209-route sweep with zero diagnostics.

> The portrait fallback accessibility label is now localized through the
> Tajik/Persian translation maps; failed source-backed assets now switch to
> unavailable semantics instead of retaining a false citation, the focused
> portrait and Persian zero-leak checks pass, and the full suite is 394/394.

> **Post-scrub browser spot check — 2026-09-20:** The rebuilt Works route
> rendered the review-only empty state rather than snippets, and the known
> pending record retained its printed citation without poem text.

> **Strict browser sweep — 2026-09-20:** The rebuilt release artifact passed 8
> viewport configurations and 29 Tajik, Persian/RTL, and dark-mode route visits.
> The hardened harness recorded 0 page errors, 0 route errors, 0 failed
> requests, 0 console errors, and 0 horizontal overflows. Four Chromium GPU
> stall warnings appeared only during small-viewport screenshots and are not
> application diagnostics.

> **Corrected-data browser sweep — 2026-09-21:** After correcting the Ibn Sina
> attribution and rebuilding the web artifact, the same 8 viewport
> configurations and major Tajik/Persian/RTL/dark-mode routes again recorded
> 0 page errors, 0 route errors, 0 failed requests, 0 console errors, and 0
> horizontal overflows.

> **Books-cover/browser sweep — 2026-09-21:** Eight exact provider JPEG covers
> are now bundled under `assets/data/books/covers/` with their source URLs
> retained in the catalog. The current release build included the Books list,
> `Баъди борон` detail, Persian Books detail (including the localized
> `Kitobkhon · kitobkhon.net` provider marker), and dark-mode Books in the
> audit: 8 viewport configurations and 34 route/mode visits recorded 0 page errors,
> 0 route errors, 0 failed requests, 0 console errors, and 0 horizontal
> overflows.

> **Image-guard browser sweep — 2026-09-21:** After tightening the page-image
> display guard so a verified flag without a concrete local asset path remains
> image-free, the rebuilt artifact again passed 8 viewport configurations and
> 34 route/mode visits with 0 page errors, 0 route errors, 0 failed requests,
> 0 console errors, and 0 horizontal overflows. Prepared web cache:
> `ecd70a48071cedadf530`.

> **Source-registry browser sweep — 2026-09-21:** After recording the official
> Maorif Grade 11 2025 edition as a reviewed source lead (without promoting its
> incomplete Lo(iq) discussion), the rebuilt artifact again passed 8 viewport
> configurations and 34 route/mode visits with 0 page errors, 0 route errors,
> 0 failed requests, 0 console errors, and 0 horizontal overflows. Prepared web
> cache: `377081a64096ed3b15da`.

> **Persian-title integrity sweep — 2026-09-21:** A catalog-wide script audit
> found two corrupted generated Persian title representations containing Latin
> extraction artifacts. Both were withheld without guessing replacements; the
> Flutter zero-leak test and strict provenance linter now reject Latin or
> Cyrillic characters in Persian work titles. The rebuilt path-aware web audit
> passed 8 viewport configurations and 34 route/mode visits with 0 page errors,
> 0 route errors, 0 failed requests, 0 console errors, and 0 horizontal
> overflows. Prepared web cache: `c58c570f6a1807b8b6c8`.

> **Privacy-metadata browser sweep — 2026-09-21:** After synchronizing the
> source-controlled privacy page to `21 September 2026` in English, Tajik, and
> Persian, the rebuilt artifact passed 8 viewport configurations and 34 Tajik,
> Persian/RTL, and dark-mode route visits with 0 page errors, 0 route errors,
> 0 failed requests, 0 console errors, and 0 horizontal overflows. Prepared
> web cache: `fd20d4d7a6260e599704`.

> **Content-quarantine browser sweep — 2026-09-21:** After the latest uploaded-PDF
> content pass, which added one verified page citation and quarantined four
> prose/quoted-verse extraction false positives, the rebuilt artifact passed
> 8 viewport configurations and 209 route/mode visits with 0 page errors, 0
> route errors, 0 failed requests, 0 console errors, and 0 horizontal
> overflows. Prepared web cache: `953279a53f804958ccf5`.

> **Persian audit correction — 2026-09-20:** The earlier Persian pass was not
> sufficient evidence: its harness wrote Flutter Web preferences as raw strings
> and did not verify localized rendered content. The harness now JSON-encodes
> SharedPreferences values, activates Flutter's semantics bridge before reading
> route text, requires Persian markers on seven Persian route visits, and rejects
> the Tajik home marker. The corrected local release sweep passed all 8 viewport
> configurations and 29 visits with 0 browser diagnostics; the saved Persian
> Home and Literature screenshots visibly show Persian labels and RTL layout.

> **Post-dependency native verification — 2026-09-20:** The compatible
> transitive dependency refresh was followed by `flutter build apk --debug
> --target-platform android-arm64`, which exited successfully and produced
> `build/app/outputs/flutter-apk/app-debug.apk`. This verifies the current
> lockfile against the Android compile path only; it does not provide a
> production-signed AAB, signed upgrade evidence, or physical-device QA.

---

## 1. Executive Summary

A comprehensive, evidence-grounded quality assurance audit and end-to-end verification pass was conducted for **Зарбулмасал (Zarbulmasal)**.

- **Feature Catalog**: The core proverb catalog remains 150 entries across 20 categories and data-derived difficulty levels. Literary Heritage currently contains 159 catalogued author records and 5,501 imported textbook candidates: 31 primary-page-checked, 253 explicitly rejected, and 5,217 still quarantined pending provenance review.
- **Platforms Verified**:
  - Android packaging/signing gates and historical signed artifacts; current v2.0.0 signing requires repository secrets and a device upgrade test remains unavailable.
  - Web/PWA release build with atomic offline service worker caching; the live root is deployed and the Android portal remains intentionally absent until signed current artifacts exist.
- **Design System**: Newest intended **Qalam** design system (`lib/core/design_system/`) preserved with 100% fidelity, featuring warm paper backgrounds (`#F3F0E7`), deep ink text (`#202720`), vermilion accents (`#A43D2F`), book-like margins, and multilingual typography (Noto Sans, Noto Serif, Noto Naskh Arabic).
- **Quality Checks**: Static analysis (0 issues), the current local regression suite (394/394 tests passing at 82.18% line coverage), and browser coverage across navigation, persistence, quiz, flashcards, Persian RTL, dark mode, and real pointer actions.

---

## 2. Repository & Branch History Audit

| Branch | Latest Commit / SHA | Role / Relationship | Status |
| --- | --- | --- | --- |
| `origin/main` | `2d8f348` | Default production branch containing the Qalam redesign, hardened release gates, CSP fix, phone QA harness, localized literature error states, and fail-closed Android publishing | **CURRENT DEFAULT** |
| `origin/latest-design` | `3328686` | Historical feature branch for Qalam redesign and onboarding | Superseded and merged into `main` |
| `origin/optimize-pwa-9718348651884350021` | `553e3b5` (PR #2) | Historical branch for PWA Safari optimizations | Superseded by PR #3 (`3b8c0ed`) and PR #5 (`e2e8935`) |
| `origin/release/final-pwa` | `3b8c0ed` (PR #3) | Production PWA release integration | Merged into `main` via PR #3 |
| `origin/fix/pwa-cache-rerun` | `e2e8935` (PR #5) | Idempotent PWA cache generation fix | Merged into `main` via PR #5 |
| `qa/zarbulmasal-release-audit` | Dedicated branch | Working branch for QA audit, localization polish, and release verification | **ACTIVE AUDIT BRANCH** |

---

## 3. Evidence Table

| Component / Flow | Status | Reproduction / Verification Evidence | Severity | Resolution / Regression Test |
| --- | --- | --- | --- | --- |
| **Catalog Integrity** | VERIFIED WORKING | 150 unique catalog entries (149 book-attested traditional, 1 needs-review modern), 20 valid categories, 6 levels (all populated: 1, 22, 50, 33, 33, 11). Cyrillic & Persian scripts present on all entries. | None | Verified by `test/providers_test.dart` ("catalog keeps unique identifiers..."). |
| **Dynamic Levels** | VERIFIED WORKING | Levels derived dynamically from catalog data (`availableLevelsProvider`). Sparse catalogs only expose populated levels. | None | Verified by `test/providers_test.dart` ("available levels are derived from real catalog content"). |
| **Bilingual Reading** | VERIFIED WORKING | Instant toggle between Tajik Cyrillic (LTR) and Persian Arabic script (RTL) via header toggle and settings. | None | Verified by `test/widget_test.dart` across all viewports. |
| **Daily Proverb** | VERIFIED WORKING | Date-deterministic daily proverb calculation with valid persistence and empty-state fallback. | None | Verified by `test/providers_test.dart` ("daily content is real, consistent today"). |
| **Search & Filtering** | VERIFIED WORKING | Instant search across Cyrillic text, Persian text, and explanations; combinable with category and level filters. Keyboard dismissable. | None | Verified by `test/widget_test.dart` ("search reacts to both scripts..."). |
| **Favorites / Saved** | VERIFIED WORKING | Add/remove favorites via bookmark button, persists across restarts with SharedPreferences. Stale IDs handled cleanly. | None | Verified by `test/widget_test.dart` and `test/providers_test.dart`. |
| **Quiz Mode** | VERIFIED WORKING | 5 randomized multiple-choice questions, answer locking, instant feedback (tick/cross), scoring screen, replay. | None | Verified by `test/widget_test.dart` and `test/accessibility_test.dart`. |
| **Flashcard Mode** | VERIFIED WORKING | Swipeable cards with tap-to-reveal explanation and forward/backward navigation in both scripts. | None | Verified by `test/widget_test.dart` ("physical flashcard swipes advance and return..."). |
| **Settings & Theme** | VERIFIED WORKING | Light/Dark mode toggle, Language selector, About dialog, and Feature Guide relaunch. | None | Verified by `test/widget_test.dart` ("settings language/theme..."). |
| **First-Launch Tour** | VERIFIED WORKING | 4-step onboarding overlay (`OnboardingOverlay`) respecting safe areas at 320px, 360px, 375px, 390px, 430px; Skip/Next/Finish actions; back button dismissal; SharedPreferences persistence. | None | Verified by `test/widget_test.dart` across 14 responsive test permutations. |
| **Navigation & 404** | VERIFIED WORKING | GoRouter with 10 destinations. Direct deep links, system back button, and unknown route error screen (`QalamErrorView`) verified. | None | Verified by `test/widget_test.dart` ("returning users do not see onboarding and unknown routes are native"). |
| **Tajik Progression Term** | CONFIRMED DEFECT | `progression_advanced` was `Продвинута` (Russian loanword) instead of pure Tajik `Пешрафта`. | Medium (localization) | **FIXED**: Replaced with `Пешрафта`. Regression test added to `test/providers_test.dart`. |
| **Tajik Loading Strings** | CONFIRMED DEFECT | `quiz_loading` and `flashcards_loading` used `Загрузка...` (Russian loanword) instead of pure Tajik `Боргирӣ...`. | Medium (localization) | **FIXED**: Replaced with `Боргирӣ...`. Regression test added to `test/providers_test.dart`. |
| **Tajik Inactive Diacritic** | CONFIRMED DEFECT | `settings_inactive` was missing the diacritic `Ғ` (`Гайрифаъол`). | Low (typographical) | **FIXED**: Corrected to `Ғайрифаъол`. Regression test added to `test/providers_test.dart`. |
| **Reported Friend Android Issue** | UNVERIFIED INCIDENT | Missing phone model, Android OS version, download URL, error message, and logcat. Probable causes identified in delivery path audit. | Critical (if blockers exist) | Delivery obstacles documented; explicit documentation added to `README.md`. |

---

## 4. Android Download and Delivery Path Audit

### Delivery Path Investigation
1. **Distribution Channel**: The repository historically distributed pre-release Android builds via GitHub Actions workflow artifacts (`zarbulmasal-device-test-apk`).
2. **Authentication Blocker**: GitHub Actions artifacts **strictly require a logged-in GitHub account** to download. When an unauthenticated mobile user opens the workflow run link, GitHub redirects to `https://github.com/login?return_to=...`. For regular users without a GitHub account, the download fails completely.
3. **Archive Packaging**: GitHub Actions packages artifacts as a `.zip` archive (`zarbulmasal-device-test-apk.zip`). Mobile Android browsers do not automatically unzip or install `.zip` files; tapping the archive opens a file manager or archive viewer rather than the Android Package Installer.
4. **Signing Identity Mismatch Across CI Runs**:
   - Historical pre-v2.0.0 builds used `signingConfigs.getByName("debug")` when release secrets were absent.
   - CI builds run on ephemeral `ubuntu-latest` virtual machines where that fallback could generate a fresh `debug.keystore` on every run.
   - Current `main` fails closed when release secrets are absent; the historical incompatibility remains relevant for previously distributed test builds.
5. **OS Compatibility & Permissions**:
   - `minSdk`: 24 (Android 7.0 Nougat+), requiring Android 7.0+.
   - `targetSdk`: 36 (Android 16), `compileSdk`: 36.
   - Permissions: 0 permissions requested (fully privacy-respecting and safe).
   - Alignment: 4-byte zipalign verified OK on all APKs.
   - Signatures: APK Signature Scheme v2 verified OK on all APKs.
   - Versioning: current source is `2.0.0+2004`, above the historical public `versionCode 2002`.

### Incident Verdict
Marked **UNVERIFIED**. Due to the absence of the user friend phone model, Android OS version, download URL, and logcat/error screenshot, no single root cause can be empirically asserted as the sole cause of that specific incident. However, the three delivery obstacles identified above (GitHub login requirement, ZIP packaging, and ephemeral debug key signature mismatches) collectively explain why a friend attempting to download from GitHub Actions would experience download or installation failure.

### Historical Android Artifact Matrix (v1.0.1+2)

| Artifact | Type | File Size | SHA-256 Digest | Signature | Zipalign |
| --- | --- | --- | --- | --- | --- |
| `app-release.apk` | Universal APK | 53,788,453 B (~53.8 MB) | `5ec53a9b17ed0531a1665b706d52a337453ee3800f03a089b5ef7f0615e01088` | Scheme v2 | OK (4-byte) |
| `app-arm64-v8a-release.apk` | ARM64 APK | 19,978,580 B (~20.0 MB) | `e76a11076fe03397573a42e8358e94e09f455023af522d4502be2e55dbe47f8f` | Scheme v2 | OK (4-byte) |
| `app-armeabi-v7a-release.apk` | ARMv7 APK | 17,436,446 B (~17.4 MB) | `3782102cc993844987541f2160d2cb6ec0cee0495a3b7d50ae15674ea240bf99` | Scheme v2 | OK (4-byte) |
| `app-x86_64-release.apk` | x86_64 APK | 21,478,739 B (~21.5 MB) | `8ef21cf00b6e448e63420b7801789c358ffd5856354cc5ab312614424d03c663` | Scheme v2 | OK (4-byte) |
| `app-release.aab` | App Bundle | 52,831,046 B (~52.8 MB) | `45f77c202fdbec2abcb12eee9b54f9473c213e64b567c6818ea44b88d6ea79e6` | Gradle Bundle | N/A |

---

## 5. Web/PWA and Deployment Audit

### Production URL Verification
- Expected URL: `https://abubakrmmarufov-tech.github.io/zarbulmasal/`
- Verified: HTTP 200 OK, `content-type: text/html; charset=utf-8`
- Live Deployed Cache ID: `08f6abe2ac5282f71b08`
- Manifest: Valid JSON, `start_url: "."`, `scope: "."`, `display: "standalone"`
- Icons: 192x192 and 512x512 standard and maskable icons present

### Browser & Playwright E2E Testing
- Tested in headless Google Chrome for Testing (153.0) with emulated iPhone viewport (390x844).
- **First Visit**: Clean load with Qalam opening screen and subsequent CanvasKit transition.
- **Service Worker Registration**: `navigator.serviceWorker.ready` returns active worker with isolated atomic cache namespace.
- **Offline Capability**: Simulated complete network offline (`set_offline(True)`) and reloaded page. Result:
  - Page title: `Зарбулмасал`
  - Flutter window loader initialized: `True`
  - Offline cache hit for all required core assets and fonts.
- **Console & Network**: 0 console errors, 0 failed requests.

---

## 6. End-to-End QA Pass After Fixes

1. `dart format --output=none --set-exit-if-changed lib test tool/validate_literature_json.dart tool/validate_literary_content.dart`: **PASS** (0 files changed).
2. `flutter analyze`: **PASS** (No issues found).
3. `flutter test --coverage`: **PASS** (394 tests passing in the current worktree; historical published-commit counts below are retained only as dated evidence).
4. Current source `flutter build apk --release --target-platform android-arm64`: **EXPECTED FAIL-CLOSED** without signing secrets (`Release signing config missing`). No unsigned release artifact is produced.
5. Current source `flutter build web --release --base-href /zarbulmasal/ --no-web-resources-cdn --no-wasm-dry-run`: **PASS**.
6. Current source `bash tool/prepare_web_release.sh`: **PASS** (deterministic build cache generated and injected).
7. Current staged APKs were independently inspected for package ID, ABI, signing certificate, checksums, and zip alignment; their identity is historical v1.1.0 and does not match the current v2.0.0 source release.

---

## 7. Permanent Android Release Signing & Secrets Specification

### Gradle & CI Infrastructure
`android/app/build.gradle.kts` and `.github/workflows/ci.yml` have been configured to support production release signing via repository secrets:
- When repository secrets are defined, `.github/workflows/ci.yml` decodes `KEYSTORE_BASE64` to `/tmp/release.keystore` and exports `KEYSTORE_PATH`.
- Gradle reads `KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD` to sign release builds.
   - When release secrets are not configured, current Gradle configuration fails the release build instead of producing a distributable debug-signed package.

### Required Repository Secrets
To enable persistent signing across CI builds, the repository owner must configure the following four GitHub repository secrets (`Settings > Secrets and variables > Actions`):

| Secret Name | Description | Creation / Extraction Command |
| --- | --- | --- |
| `KEYSTORE_BASE64` | Base64-encoded release `.jks` keystore | `base64 -i release.keystore \| tr -d '\n'` |
| `KEYSTORE_PASSWORD` | Password used to secure the keystore file | Password chosen during `keytool` generation |
| `KEY_ALIAS` | Alias identifying the signing key within keystore | Alias name (e.g. `zarbulmasal-key`) |
| `KEY_PASSWORD` | Password protecting the specific signing key | Password chosen during key creation |

### Keystore Generation Example
```sh
keytool -genkey -v -keystore release.keystore -alias zarbulmasal-key -keyalg RSA -keysize 2048 -validity 10000
base64 -i release.keystore | pbcopy  # Paste into GitHub Secrets as KEYSTORE_BASE64
```

> [!WARNING]
> **Signing Continuity Status**: Signing continuity across consecutive CI builds cannot be claimed as fixed until repository secrets are populated and two consecutively built versions can successfully update each other without `INSTALL_FAILED_UPDATE_INCOMPATIBLE`. Until then, each CI runner generates an ephemeral key.

---

## 8. Android Device & Emulator Availability Assessment

- **Physical Device**: `adb devices` returned 0 attached devices. No physical Android hardware is connected to this host.
- **Android Emulator**: The local Android SDK environment at `/Users/m.a/Library/Android/sdk` does not have an installed emulator engine or system images. Host disk space has 9.0 GiB available, which is insufficient to safely download multi-gigabyte system images and allocate virtual disk partitions without risking disk exhaustion.
- **Verification Performed**: Packaging, badging, ABI compilation, resource trees, APK Signature Scheme v2, and 4-byte zipalign were strictly verified locally using Android SDK build-tools (`aapt`, `apksigner`, `zipalign`).

---

## 9. Public Direct-Download Distribution Verification (historical)

To resolve the download obstacles identified in pre-release distribution (GitHub authentication wall and `.zip` archive wrapping):
- A public GitHub Release (`v1.0.1`) was published with standalone `.apk` assets.
- Historical direct-download URLs were previously verified for the v1.0.1 release.
- Those historical URLs were verified via unauthenticated HTTP GET. The current GitHub Pages deployment removes the `/android/` portal and `/downloads/` files when signing is unavailable; the current source contains the portal, while APK files are added only after a signed CI build passes staging.

## Update 2026-09-13
- **Literary Heritage**: Added 171 poets and 1,466 quarantined poems currently under manual review.
- Fixed the release-signing fallback, FavoritesNotifier initialization race, literature-hub navigation gaps, and silent Daily Verse empty/error states. Production phone QA verified the deployed root, routes, actions, and CSP-safe font fallback on 2026-09-13.

## Update 2026-09-14
- Published commit `2d8f348` is live at `https://abubakrmmarufov-tech.github.io/zarbulmasal/`.
- Fresh public phone QA passed at 375×667, 390×844, and 430×932: no horizontal overflow, console/page errors, failed requests, or HTTP failures. Real pointer actions changed proverb search results, quiz feedback, and flashcard reveal; category and level selections navigated to `/proverbs`; favorites persisted through the public flow; settings theme and language values persisted across reload.
- The current worktree contains an unpublished, source-bound History feature with 180 passing local tests. Its home link is ordered after the literature section, and it is intentionally excluded from the public build until its content and release scope are approved.

## Update 2026-09-21 — Connected-device re-audit
- A fresh debug APK was built from the current worktree and installed in-place on Xiaomi `2412DPC0AG` / Android 16 (`versionCode 2004`) without clearing app data.
- Native smoke checks passed for app launch, Literature hub, poet list and portraits/placeholders, works review gate, Literature search and keyboard, Books, Persian RTL, Tajik language switching, dark mode, and light-mode restoration. No fatal exception, crash, or ANR lines appeared in the captured logcat.
- A connected-device UIAutomator pass found and fixed a Books filter rail constrained to roughly 38dp; the rail now preserves 48dp visible touch targets. The updated web release artifact also passed the full browser audit: 8 viewports, 34 routes/modes, 0 overflows, console errors, page errors, request failures, or audit errors.
- The offline follow-up fixed the same constrained-rail pattern in History and Oral Heritage; focused widget regressions now measure every filter chip at 48dp or larger. The rebuilt web artifact (`014019527e2639373dfe`) passed the same 8-viewport, 34-route/mode browser audit with zero errors, overflows, console errors, page errors, or request failures.
- The installed APK certificate is `CN=Android Debug`; this is explicitly debug-only evidence. The historical v1.0.1 digest previously treated as a public identity is now rejected as a production certificate. Release scripts and CI require protected `EXPECTED_RELEASE_CERT_SHA256` configuration and reject debug certificates.

---

## 10. Release v2.0.0 Audit & Verification Register (2026-09-13)

### Executive Summary
- **Target Release**: Zarbulmasal v2.0.0 (`version: 2.0.0+2004`)
- **Android Upgrade Continuity**:
  - `v1.0.1` ARM64 release package: `versionCode 2002`, historical certificate SHA-256 `93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e`; later inspection identifies its DN as `CN=Android Debug`, so it is not a trusted production identity.
  - `v2.0.0` base `versionCode` is set to `2004` (ARMv7: 3004, ARM64: 4004, Universal: 2004), so a correctly signed current build is eligible for an in-place upgrade without `INSTALL_FAILED_VERSION_DOWNGRADE`.
  - CI workflow (`.github/workflows/ci.yml`) updated to verify package ID `com.zarbulmasal.zarbulmasal` and signing certificate digest before publishing.
- **GitHub Pages Android Portal**:
  - Direct downloads portal at `web/android/index.html` is present in source and in the locally prepared web artifact.
  - Staging script `tool/prepare_android_downloads.sh` integrates split APKs (`zarbulmasal-arm64-v8a.apk`, `zarbulmasal-armeabi-v7a.apk`, `zarbulmasal-universal.apk`) and checksum manifest directly into GitHub Pages deployment.
  - The live root was checked on 2026-09-13 and returns HTTP 200; the deployment removes `/zarbulmasal/android/` and `/zarbulmasal/downloads/` when signed v2.0.0 artifacts are not configured.
  - The staged APKs in the current index are historical v1.1.0 artifacts, not verified v2.0.0 outputs, and must not be published as the current release.
- **Static Analysis & Literature Presentation Polish**:
  - `flutter analyze` 0 warnings: resolved unused `poetsCount`, `worksCount`, `canonCount` variables in `literature_hub_screen.dart`.
  - Subtitle interpolation in Literature Hub: displays formatted poets count (`171 шоир` / `۱۷۱ شاعر`) and authentic review status when works are awaiting collation (`Ғазалҳо, қасидаҳо ва рубоиҳои дар ҳоли тасдиқ ва муқобала`).
  - Search button restored in Literature Hub navigation bar (`/literature/search`).
  - `OralHeritageScreen` eyebrow aligned to `03 / МЕРОСИ ШИФОҲӢ` (`۰۳ / میراث شفاهی`).
  - `PoetDetailScreen` text direction and text alignment adjusted for Persian/Cyrillic scripts to prevent punctuation scrambling; lifespan numerals formatted in Persian.
  - `PoemReaderScreen` copy action icon updated to `Icons.copy_outlined`.
- **RTL Mirroring & Numerals**:
  - Material navigation and forward chevron icons verify native `matchTextDirection: true` support for RTL layouts.
  - Persian numeral translation exposed and applied to proverbs counts, level badges, IDs, and dates across `QalamCategoryTile`, `QalamLevelCard`, `QalamReadingPage`, `ProverbsListScreen`, `FavoritesScreen`, and `OnboardingOverlay`.
- **Repository Hygiene**:
  - Removed obsolete development seed files (`lib/data/seed/poems.json`, `lib/data/seed/poets.json`).
  - Updated `README.md` to link directly to the standalone Android downloads portal.

---

### Comprehensive Defect Register (9-Field Specification)

#### DEF-201: Android Package Upgrade Incompatibility & Version Code Downgrade Risk
1. **ID & Severity**: `DEF-201` — **Critical** (Release & Install Blocker)
2. **Affected Screen/Component/Data**: Android Packaging & Upgrade Pipeline (`pubspec.yaml`, `android/app/build.gradle.kts`, `.github/workflows/ci.yml`)
3. **Device, Language, Theme, State**: Android OS 7.0+ (ARM64, ARMv7, x86_64), All languages, All themes, Existing installed app upgrade state
4. **Exact Reproduction Steps**:
   - Install published release `v1.0.1` ARM64 package (`versionCode 2002`, historical SHA-256 `93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e`; debug DN, not production-trusted).
   - Build or download a `v2.0.0` APK built with default base `versionCode 1` or lower than 2002.
   - Run `adb install -r app-arm64-v8a-release.apk` over the existing installation.
5. **Expected vs Actual Behavior**:
   - *Expected*: In-place upgrade succeeds preserving user preferences and favorites without error.
   - *Actual*: Android Package Manager rejects install with `INSTALL_FAILED_VERSION_DOWNGRADE` (or `INSTALL_FAILED_UPDATE_INCOMPATIBLE` if signed by an ephemeral key).
6. **Evidence**: Public release v1.0.1 ARM64 package inspection via `aapt dump badging` revealed `versionCode='2002'` and historical cert SHA-256 `93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e`; current `apksigner` inspection identifies the same identity as `CN=Android Debug`.
7. **Root Cause**: `pubspec.yaml` was set to `1.0.1+2` while release distribution scripts generated split versionCode offsets without raising the base version code above 2002 for major release v2.0.0.
8. **Fix & Regression Protection**:
   - Set `version: 2.0.0+2004` in `pubspec.yaml`. Split versionCode logic calculates: Universal=2004, ARMv7=3004, ARM64=4004, strictly exceeding 2002.
   - Added `test/android_distribution_test.dart` asserting `version: 2.0.0` and `versionCode > 2002`.
   - CI workflow checks signing cert digest and package ID before release staging.
9. **Verification Result & Revision**: Verified in `test/android_distribution_test.dart` (PASS). Revision `main` / `2.0.0+2004`.

#### DEF-202: HTTP 404 on Standalone Android Downloads Portal
1. **ID & Severity**: `DEF-202` — **High** (User Acquisition & Distribution Blocker)
2. **Affected Screen/Component/Data**: Web Downloads Portal (`/zarbulmasal/android/`, `web/android/index.html`, `tool/prepare_android_downloads.sh`)
3. **Device, Language, Theme, State**: Any mobile or desktop web browser navigating to `https://abubakrmmarufov-tech.github.io/zarbulmasal/android/`
4. **Exact Reproduction Steps**:
   - Open browser and navigate to `https://abubakrmmarufov-tech.github.io/zarbulmasal/android/`.
   - Observe server HTTP response.
5. **Expected vs Actual Behavior**:
   - *Expected*: Dedicated mobile-friendly Android downloads portal loads with direct APK download links, SHA-256 checksums, and installation instructions.
   - *Actual*: GitHub Pages returns HTTP 404 Not Found because `/android/` was not included in the web artifact bundle.
6. **Evidence**: Direct curl request to GitHub Pages returned HTTP 404; missing static files under `web/android/` in repository.
7. **Root Cause**: GitHub Actions web deployment job only deployed Flutter's raw `build/web` without staging a dedicated download portal or APK assets.
8. **Fix & Regression Protection**:
   - Created `web/android/index.html` featuring responsive Qalam styling, SHA-256 verification hashes, architecture guide, and direct download buttons for ARM64, ARMv7, and Universal APKs.
   - Created `tool/prepare_android_downloads.sh` to stage APKs into `build/web/downloads/` and copy `index.html` to `build/web/android/`.
   - Added automated tests in `test/android_distribution_test.dart` and `test/pwa_assets_test.dart`.
9. **Verification Result & Revision**: Package and local staging checks pass; live root/runtime verification passes, while `/android/` remains intentionally unavailable until signed v2.0.0 artifacts are produced. Source revision `main` / `2.0.0+2004`.

#### DEF-203: Dead Code Warnings & Static Analysis Failures in Literature Hub
1. **ID & Severity**: `DEF-203` — **Medium** (Code Quality & Build Reliability)
2. **Affected Screen/Component/Data**: `lib/features/literature/presentation/literature_hub_screen.dart`
3. **Device, Language, Theme, State**: Development environment, Flutter static analyzer (`flutter analyze`)
4. **Exact Reproduction Steps**:
   - Run `flutter analyze` on the project root.
5. **Expected vs Actual Behavior**:
   - *Expected*: 0 analyzer warnings or errors.
   - *Actual*: Analyzer reported 3 warnings: unused local variables `poetsCount`, `worksCount`, and `canonCount` in `literature_hub_screen.dart`.
6. **Evidence**: `flutter analyze` output showed `unused_local_variable` warnings on lines 30-32.
7. **Root Cause**: Variables were computed from Riverpod async providers but discarded when hardcoded placeholder strings were used in UI cards.
8. **Fix & Regression Protection**:
   - Cleaned up unused variables and properly wired `poetsCount` into dynamic string interpolation `AppTranslations.formatNumber(poetsCount, lang)`.
   - Wired `worksCount` into an authentic editorial review state message.
9. **Verification Result & Revision**: `flutter analyze` passed with 0 issues in 3.1s.

#### DEF-204: Literature Hub Missing Search Action & Subtitle Hardcoding
1. **ID & Severity**: `DEF-204` — **Medium** (UX & Accessibility Defect)
2. **Affected Screen/Component/Data**: `LiteratureHubScreen` (`lib/features/literature/presentation/literature_hub_screen.dart`)
3. **Device, Language, Theme, State**: Mobile viewports (360-430px), Both Tajik Cyrillic and Persian Arabic scripts, Light/Dark theme
4. **Exact Reproduction Steps**:
   - Open Literature Hub (`/literature`).
   - Look for Search action button in top bar to search the 159 catalogued authors and current review-safe work index.
   - Check section subtitles for dynamic content count.
5. **Expected vs Actual Behavior**:
   - *Expected*: Search icon button present in top action bar leading to `/literature/search`; section 01 subtitle shows `Зиндагинома ва осори 171 шоир ва адиби бузург` / `زندگینامه و آثار ۱۷۱ شاعر و ادیب بزرگ`; section 02 shows authentic collation status.
   - *Actual*: Search action button was completely missing from the top bar; subtitles had static/inaccurate placeholder counts.
6. **Evidence**: `LiteratureHubScreen` app bar row only had a back button; section 01 lacked author count interpolation.
7. **Root Cause**: Top action bar omitted search navigation; subtitle strings were hardcoded without using `AppTranslations.formatNumber`.
8. **Fix & Regression Protection**:
   - Added search `IconButton` with tooltip `'Ҷустуҷӯ'` / `'جستجو'` invoking `context.push('/literature/search')`.
   - Subtitle now formats real author count (`171 шоир` / `۱۷۱ شاعر`).
   - Covered by widget tests in `test/features/literature/presentation/literature_presentation_test.dart`.
9. **Verification Result & Revision**: Verified in `test/features/literature/presentation/literature_presentation_test.dart` (PASS).

#### DEF-205: Oral Heritage Eyebrow Index Discontinuity
1. **ID & Severity**: `DEF-205` — **Low** (Visual Hierarchy & Consistency Defect)
2. **Affected Screen/Component/Data**: `OralHeritageScreen` (`lib/features/literature/presentation/oral_heritage_screen.dart`)
3. **Device, Language, Theme, State**: All viewports, Tajik and Persian scripts, All themes
4. **Exact Reproduction Steps**:
   - Navigate to Literature Hub and review numbered sections (01 Poets, 02 Works, 03 Oral Heritage, 04 Canon).
   - Navigate into Oral Heritage screen.
   - Inspect page header eyebrow.
5. **Expected vs Actual Behavior**:
   - *Expected*: Eyebrow displays `03 / МЕРОСИ ШИФОҲӢ` (`۰۳ / میراث شفاهی`) matching Hub section 03.
   - *Actual*: Eyebrow displayed `04 / МЕРОСИ ШИФОҲӢ`, causing numbering inconsistency between Hub and detail page.
6. **Evidence**: Header eyebrow string in `oral_heritage_screen.dart` was `'04 / МЕРОСИ ШИФОҲӢ'`.
7. **Root Cause**: Numbering mismatch after reordering sections in the Literature Hub.
8. **Fix & Regression Protection**:
   - Updated eyebrow to `isPersian ? '۰۳ / میراث شفاهی' : '03 / МЕРОСИ ШИФОҲӢ'`.
   - Validated in widget test `OralHeritageScreen displays entries with genre tags and citation`.
9. **Verification Result & Revision**: Verified in `test/features/literature/presentation/literature_presentation_test.dart` (PASS).

#### DEF-206: Poet Detail Screen RTL Punctuation Scrambling & Lifespan Numeral Mismatch
1. **ID & Severity**: `DEF-206` — **Medium** (Bilingual Typography & RTL Defect)
2. **Affected Screen/Component/Data**: `PoetDetailScreen` (`lib/features/literature/presentation/poet_detail_screen.dart`)
3. **Device, Language, Theme, State**: Persian mode (`DisplayLanguage.persian`), RTL layout, Light/Dark theme
4. **Exact Reproduction Steps**:
   - Switch language to Persian in Settings or header toggle.
   - Navigate to `/literature/poet/rudaki`.
   - Inspect author name, altName (Cyrillic title), lifespan dates, and biography text.
5. **Expected vs Actual Behavior**:
   - *Expected*: Persian biography aligned to the right with `TextDirection.rtl`; Cyrillic altName retains `TextDirection.ltr` so parentheses/hyphens do not jump; lifespan displayed in Eastern Arabic numerals (`۸۵۸ – ۹۴۱`).
   - *Actual*: AltName text without explicit text direction had trailing punctuation flipped; lifespan displayed Western digits `858 – 941`; biography lacked explicit RTL alignment.
6. **Evidence**: Screenshot and widget tree inspection in Persian mode showed western digits in lifespan and unaligned biography text.
7. **Root Cause**: Missing script-aware `textDirection`, `textAlign`, and `AppTranslations.formatDigits` on metadata fields in `_PoetDetailContent`.
8. **Fix & Regression Protection**:
   - Added conditional `textDirection` (`rtl` for Persian name/bio, `ltr` for Cyrillic altName).
   - Wrapped `poet.lifespan` in `AppTranslations.formatDigits(poet.lifespan, lang)`.
   - Added widget regression tests in `Literature Feature Persian Language Parity` group in `literature_presentation_test.dart`.
9. **Verification Result & Revision**: Verified in `test/features/literature/presentation/literature_presentation_test.dart` (PASS).

#### DEF-207: Incomplete Persian Numeral Formatting & Semantic Copy Icon in Reader
1. **ID & Severity**: `DEF-207` — **Medium** (UX Polish & Localization Defect)
2. **Affected Screen/Component/Data**: Core Qalam Components (`QalamCategoryTile`, `QalamLevelCard`, `QalamReadingPage`, `ProverbsListScreen`, `FavoritesScreen`, `PoemReaderScreen`)
3. **Device, Language, Theme, State**: Persian script mode, All devices, Light/Dark themes
4. **Exact Reproduction Steps**:
   - Switch app to Persian mode.
   - Inspect proverb count badges on Category tiles, Level cards (`۰۱`..`۰۶`), Proverb IDs, and Favorites counts.
   - Open Poem Reader and inspect copy action icon.
5. **Expected vs Actual Behavior**:
   - *Expected*: All numeric indicators use authentic Eastern Arabic numerals (`۰-۹`); copy button uses clear `Icons.copy_outlined` icon with tooltip `'کپی متن'`.
   - *Actual*: Numbers remained in Latin digits (`0-9`); poem reader used generic share icon for clipboard copy action.
6. **Evidence**: Category tile showed `22 зарбулмасал` in Persian mode; poem reader button used `Icons.share` while copying to clipboard.
7. **Root Cause**: `formatDigits` and `formatNumber` utility functions were not exposed in `AppTranslations` and not utilized across core widgets; icon semantics mismatch.
8. **Fix & Regression Protection**:
   - Exposed `formatDigits` and `formatNumber` in `AppTranslations`.
   - Applied throughout Category tiles, Level cards, Reading page, Proverbs list, and Favorites.
   - Replaced icon with `Icons.copy_outlined` in `PoemReaderScreen`.
   - Added widget tests in `literature_presentation_test.dart` and `providers_test.dart`.
9. **Verification Result & Revision**: Verified across all 150 tests in `flutter test` (PASS).

#### DEF-208: History Grade 8 Presented a Misleading Empty Search Result
1. **ID & Severity**: `DEF-208` — **High** (Content Trust & Mobile UX)
2. **Affected Screen/Component/Data**: `HistoryScreen`; Grade 8 textbook source record.
3. **Reproduction**: Open History on a 320px release build and select `Синфи 8`.
4. **Actual**: The UI said `Мундариҷа ёфт нашуд`, implying a bad query or absent data, although the Grade 8 source book is known and only its chapter-level detail is unverified.
5. **Fix**: The filtered state now describes the verified limitation plainly and leaves the filter chip available to reset. The redundant outlined reset button was removed after visual QA found it clipped below the phone viewport.
6. **Protection/Evidence**: A provider-overridden widget regression fails on the former generic state; targeted History tests pass. A clean-origin 320px browser run confirms the full explanatory state is visible with no console errors.

#### DEF-209: Literature Search Was Not Tolerant of Common Persian Keyboard Input
1. **ID & Severity**: `DEF-209` — **High** (Persian Discoverability & Content Trust)
2. **Affected Screen/Component/Data**: Literature global search and Poet directory.
3. **Reproduction**: Search for Rudaki with `رودكي` (Arabic `ي`/`ك`) rather than `رودکی`.
4. **Actual**: Raw lowercase comparisons returned no result. Global search also allowed the noncanonical importer placeholder `Unknown` into results.
5. **Fix**: Centralized normalization removes marks and zero-width characters, maps Arabic keyboard variants to Persian characters, and normalizes whitespace. Both search surfaces use it; global suggestions/results omit noncanonical author records.
6. **Protection/Evidence**: Unit and widget regressions pass. In a clean local release browser, `رودكي` returns Абӯабдуллоҳи Рӯдакӣ in both surfaces; `Unknown` yields the ordinary no-results state.

#### DEF-210: Hash Deep Links Were Overridden and Internal Routes Were Not Shareable
1. **ID & Severity**: `DEF-210` — **High** (Web Navigation)
2. **Affected Screen/Component/Data**: GoRouter configuration; History and Literature routes.
3. **Reproduction**: Open `#/history` on a fresh browser origin, or navigate from Home into Literature and inspect the address bar.
4. **Actual**: The forced root `initialLocation` discarded the incoming hash route. GoRouter 14 also defaults to not reflecting imperative navigation in the browser URL.
5. **Fix**: Removed the forced root location and enable GoRouter's URL reflection while constructing the app router.
6. **Protection/Evidence**: The new router configuration test initially failed and now passes. Clean-origin browser QA verifies `#/history`, `#/literature`, and browser Back. GitHub Pages should use the fragment form rather than an unfragmented `/history` path.

#### DEF-211: Uncited Works Were Presented as Fully Verified
1. **ID & Severity**: `DEF-211` — **Critical** (Literary provenance and publication gate)
2. **Affected Screen/Component/Data**: `works.json`, poem reader/source panel, literary-content validator, and approved-work providers.
3. **Reproduction**: Open an affected work such as `#/literature/work/0136bbcb-75f0-4e53-b66f-1b4a12f6b211`, then select its source panel.
4. **Actual**: 82 records claimed completed page checking and public approval, and the reader labelled their text verified, although all 82 primary-source records omitted `pageStart`.
5. **Fix**: Downgraded the batch to `needsReview`, disabled full-text publication, and added a validator/test requirement that an approved work has a documented primary-source page and `pageChecked` confirmation.
6. **Protection/Evidence**: The validator now reports 0 approved and 1,466 pending records. Targeted content/provider/repository tests pass; a clean-origin release browser shows the explicit reviewed-works empty state and no console errors.

#### Historical Local QA Snapshot (2026-09-14; superseded by the current-state override above)

- Baseline: `main` at `34e0e71` plus local QA fixes; no commit, push, credential change, or deployment was performed.
- Clean checks: `flutter analyze` (0 issues), full `flutter test --no-pub --coverage` (209 passing), literature JSON/content validators (`tool/validate_literature_json.dart`, `tool/validate_literary_content.dart`), literature-pipeline unit check, and web release build.
- Coverage artifact: 4,561 / 5,362 lines (85.06%), exceeding the 80% threshold across all modules.
- Content constraint: 159 author records and 5,502 work records validate structurally; 5,334 remain quarantined under `needsReview`, 151 are explicitly rejected extraction false positives, and none are published without editorial approval and the required source checks.
- File System / Build System Limitation: macOS intermittently returns `errno = 60: Operation timed out` while reading workspace paths, including the Android Gradle wrapper. Web and test compilation currently work, but this environmental fault is not permanently resolved; a fresh Android rebuild and diff whitespace check remain unverified.
- RTL & Persian Numeral Parity Audit:
  - Eastern Arabic numeral formatting (`AppTranslations.formatDigits` and `formatNumber`) comprehensively applied across History (grade chips, book strip, source citations, dynamic empty states), Literature Search (author lifespans), Settings (proverbs count), Daily Hero (Persian calendar numbers), and School Canon.
  - Directional icons (`Icons.arrow_forward`, `Icons.chevron_right`, `Icons.arrow_forward_ios`) verified against Flutter's Material `IconData` architecture (`matchTextDirection: true` natively enabled on the underlying `IconData`), ensuring automatic horizontal mirroring in RTL layouts while preserving orientation for non-directional icons (`Icons.check`, `Icons.hourglass_empty`).
- Runtime browser coverage (56 automated Playwright screenshots across viewports):
  - Viewports: Phone compact (320×568), Phone standard (390×844), and Desktop (1280×800).
  - Routes verified: Home, History, Literature Hub, Poets List, Works List, School Canon, Oral Heritage, Literature Search, Proverbs List, Categories, Favorites, Quiz, Flashcards, Daily Proverb, Levels, Settings.
  - Persian RTL mode verified on 390×844: Home, History, Literature Hub, Poets List, Works List, Flashcards, Settings.
  - Dark mode theme verified.
  - Console and page error count across all 56 screens: **0 errors**.
- Interactive E2E verification:
  - Invalid route / 404 handling (`#/non_existent_page_404` loads polished error page without crash).
  - Service worker active registration and offline asset cache validation.
  - LocalStorage persistence for language (`fa`) and theme (`dark`) across reload.
  - Direct deep links (`#/history`, `#/literature`, `#/literature/poets`, `#/literature/works`, `#/literature/school`, `#/proverbs`, `#/favorites`) preserved without root override.
- Focused regression evidence: the recorded Tajik onboarding/literature/history journey and Persian/dark settings/proverbs/flashcard journey completed with 0 browser-console errors. They are useful evidence, but do not substitute for the two complete final regression passes required by this audit.
- Android source configuration: package `com.zarbulmasal.zarbulmasal`, version `2.0.0`/code `2004`, min SDK 24, and target SDK 36 are present in source. No current Android artifact is claimed because the debug rebuild is blocked before compilation; physical on-device upgrade verification also remains unavailable.
- Deployment separation: Public GitHub Pages root verified live (HTTP 200). Local fixes remain quarantined in the local worktree without unauthorized push.
- Latest regression passes after DEF-211: (1) fresh-origin Tajik onboarding → author search/profile → Literature pending state → History direct link; (2) Persian/dark Settings → Proverbs favorite/reload → Flashcard fallback. Both had zero browser-console errors. A fresh Android rebuild remains unverified because macOS intermittently returns `Operation timed out` while reading workspace files, including `android/gradle/wrapper/gradle-wrapper.properties`; the final `git diff --check` now passes and no source file was overwritten to work around the Android environment fault.
- History navigation evidence: in the Persian/dark local release build, selecting the Grade 5 Пешдодиён card kept the route at `#/history` and opened an in-app detail sheet with grade, textbook, and chapter reference. No browser-console errors and no external navigation occurred.
- History category coverage: event and oral-narrative filters were added after confirming that the 71 source-bound cards included 4 events and 2 oral narratives that were otherwise only discoverable through the long unfiltered list. Widget regressions cover Tajik filtering and Persian labels; a fresh local release browser selected both filters at `#/history` and displayed the expected textbook-bound cards without console errors or external navigation.
- Textbook-corpus foundation: local Grade 5–11 PDFs were reconciled into seven explicit `official-textbook` source records (title-page author line, publisher, year, ISBN, and local reference). Grade 5–11 School Canon mappings now carry their actual source IDs and use a visible “citation under review” state rather than claiming unreviewed curriculum evidence as final. `index_textbook_pages.py` generated 3,178 canonical-name/PDF-page review candidates; it stores no poem text and grants no approval. Printed Grade 5 page 49 was visually inspected for Rudaki’s year-only biographical evidence, page 54 for the six-bayt “Бӯйи Ҷӯйи Мулиён” excerpt, and page 59 for a two-line Tursunzoda meter example that the textbook does not identify as a standalone poem. Printed Grade 7 pages 105–107 were visually inspected for four clearly titled Kamoli Khujandi ghazal records, including the 106–107 continuation. These records remain `needsReview` pending a second witness, line-by-line collation, and editorial/rights review. A fresh local release browser confirmed the Grade 5 card cites the held 2017 Маориф edition and discloses that page review is pending.
- Textbook biography witness: printed page 254 of the held Grade 7 (2018) edition was visually inspected for Лоиқ Шералӣ. The profile now reports the exact textbook dates `20 майи 1941` and `30 июни 2000`, birthplace `Мазори Шариф, Панҷакент`, and the page-cited concise biography; unsupported honorifics were not carried over as verified facts.
- Jami date correction: printed Grade 7 page 109 was visually inspected and two duplicate Абдурраҳмони Ҷомӣ records were reconciled to its dates (`7 ноябри 1414`–`9 ноябри 1492`), birthplace, concise work list, and page-109 citation. The prior conflicting exact dates and opaque source labels are covered by a JSON regression.

### Continued QA Cycle — 2026-09-14

- Added three directly inspected textbook work candidates: `rudaki_buyi_juyi_muliyon_grade5_2017_p54`, tied to printed page 54; the two-line Tursunzoda meter example `tursunzoda_meter_example_grade5_2017_p59`, tied to printed page 59; and the four-line «Модар» excerpt `tursunzoda_modar_excerpt_grade5_2017_p216`, tied to printed page 216 of the held Grade 5 (2017) edition. Rudaki’s profile now reports only the year-level evidence visible on printed page 49 (`858–941`); unsupported exact birth/death dates and unsupported honorifics were removed from that record.
- Added four Grade 7 textbook witnesses for Камоли Хуҷандӣ after inspecting printed pages 105–106: «Ғарибӣ» and «Гуфтам ба чашм!» on page 105, «Ошӯби ҷонӣ» on page 106, and «Дӯст медорад дилам ҷавру ҷафои дӯстро» across pages 106–107. The records preserve the complete textbook line structure as review data, but remain unpublished because they still need a second witness, line-by-line collation, and rights review.
- The adjacent printed page 217 was also inspected. It contains an additional untitled stanza inside the surrounding biographical discussion; it was not merged into «Модар» because the page does not clearly delimit its title or relationship to the page-216 excerpt.
- The candidate index now adds non-content `pageSignals` (`question_numbering`, `poetry_cue`, `biography_cue`, or `name_hit_only`) so obvious exercise-page hits can be deprioritized without retaining page text or treating a signal as evidence.
- Fresh-origin browser QA switched Settings from Tajik to Persian and reopened direct literature routes: Persian navigation and pending-work protection copy rendered, the Tajik textbook citation remained intact, and error/warning diagnostics were empty. The Loïc Sherali profile also disclosed that its auditable biography is currently shown in Tajik Cyrillic while preserving the page-254 citation.
- The rebuilt web release occupies 47 MB on disk, including CanvasKit and symbol assets; the browser automation context did not expose a navigation-timing API, so no startup-time improvement is claimed.
- Biography-source disclosure was tightened: the author model now recognizes a citation as auditable only when it contains a printed page marker, and poet profiles label opaque import sources such as “Маҷмӯаи мактабӣ” as lacking a verified page rather than presenting them as authoritative textbook citations.
- Unsupported composition dates and contexts were removed from 82 pending imports. The domain, UI, and content validator now require a printed page plus `pageChecked` before composition metadata can be user-visible or accepted in future records.
- Poet profiles now expose pending work titles and their known page citations as review-only cards, while explicitly labeling records without a printed page; tapping a pending card reaches the protected reader instead of falsely reporting that no record exists.
- Approved-work counts on poet profiles now say “approved in the app” so a visible zero is not misread as a claim that the poet wrote no poems; the pending-record count remains separate.
- These candidates remain quarantined: `textStatus=needsReview`, `finalStatus=needsReview`, no second witness, no line-by-line sign-off, and `fullTextAllowed=false`. The app now distinguishes a known pending record from an unknown work ID and shows the citation without revealing the text.
- Final automated pass 1: `flutter test --no-pub --coverage` — 209/209 passed; 4,561/5,362 lines (85.06%). Final automated pass 2: `flutter test --no-pub` — 209/209 passed. `flutter analyze`, JSON validation, content validation, and pipeline tests pass.
- Final local web verification: release build completed after the Grade 7 corpus addition; fresh origins verified Rudaki profile, Grade 5 textbook filter, pending-work protection, Tajik UI, and browser diagnostics with no error/warning logs. The public GitHub Pages deployment was not changed.
- Android status: current debug rebuild remains blocked before compilation because Gradle cannot read the wrapper properties file due to the intermittent macOS/iCloud `Operation timed out` filesystem error. No current Android artifact or device result is claimed.

---

## 13. Benchmark Optimization Loop: Quiz Generation Engine

### Bottleneck Identification & Hypothesis
- **Operation**: `QuizEngine.generateQuestion` / `QuizEngine.generateQuiz` (5-question distractor selection with variant and semantic collision checks).
- **Bottleneck**: `wordSimilarity(correctMeaning, cMeaning)` was executing `RegExp.allMatches` on lowercase strings for every candidate (542 proverbs) per question. In 2,000 quiz simulations (10,000 questions), this produced over 5.4 million redundant regex operations and Set allocations.
- **Metric**: Total wall time (ms) and throughput (ms/quiz) for 2,000 quizzes (10,000 questions).
- **Correctness Gate**: `flutter test --no-pub test/quiz_algorithm_test.dart` (11 tests, 2,000 collision simulations, 0 collisions allowed).

### Variant Comparison Table
| Variant | Hypothesis | Command | Time (2,000 quizzes) | Throughput | Correct? | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| **Baseline** | Current path with repeated regex & set allocations | `dart run tool/benchmark_quiz.dart` | 18,017ms | 9.0085ms/quiz | Yes | Stable, high CPU burn |
| **Variant 1** | Hoisted word tokenization & allocation-free intersection | `dart run tool/benchmark_quiz.dart` | 8,656ms | 4.3280ms/quiz | Yes | 2.08x speedup |
| **Variant 2** | Static bounded word set cache (`_wordCache`) | `dart run tool/benchmark_quiz.dart` | **519ms** | **0.2595ms/quiz** | Yes | **34.7x speedup (Winner)** |

### Correctness & Promotion
- Correctness test suite `test/quiz_algorithm_test.dart` ran with 11/11 passing tests in under 1 second (previously 21 seconds).
- Full test suite: 191/191 passed (100%), coverage at 85.03% (4,077 / 4,795 lines).
- Variant 2 was promoted to `lib/features/quiz/quiz_engine.dart` with a bounded cache cap (2,048 entries) and explicit `clearCache()` method to prevent any possibility of memory leaks.

---

## 14. Formal Production Readiness Audit

> The score and evidence in this historical section describe the 2026-09-14
> snapshot. The current-state override at the top of this document supersedes
> its release conclusion.

**Production audit: 82/100, launchable with caveats, with historical v1.1.0 APK artifacts in local downloads and physical on-device upgrade verification as the two risks to resolve before public launch.**

### Blockers
1. **Historical v1.1.0 APK artifacts in local downloads**: `downloads/zarbulmasal-arm64-v8a.apk` is version 1.1.0 (versionCode 4003). While the GitHub Actions CI workflow correctly removes `downloads/` if signing secrets are absent, local deployments must never copy these stale v1.1.0 APKs to public hosting where `android/index.html` advertises version 2.0.0.
2. **Physical on-device Android install/upgrade verification**: Package signing continuity and manifest checks pass static and scripted validation, but a real physical handset upgrade from the previously distributed v1.0.1/v1.1.0 build to v2.0.0 must be verified on hardware to ensure `INSTALL_FAILED_UPDATE_INCOMPATIBLE` does not occur.

### High-Value Fixes
1. **Literature Content Collation**: 5,334 imported works remain fail-closed under `needsReview`. Editorial collation against physical print editions will enable their public promotion.
2. **Offline Service Worker Cache Invalidation**: Monitor service worker registration on initial load across varied browsers to ensure version bumps flush stale cached assets immediately.

### Evidence Checked
- `git status`, `git log`, and `git diff origin/main...HEAD`
- Static analysis: `flutter analyze` (0 issues)
- Automated test suite: `flutter test --coverage` (191 tests passed, 85.03% line coverage)
- Mobile QA harness: `python3 tool/mobile_qa.py` (5 viewports, 0 console errors, 0 page errors, 0 layout overflows)
- Release scripts: `tool/prepare_web_release.sh`, `tool/prepare_android_downloads.sh`, `.github/workflows/ci.yml`
- Android configuration: `android/app/build.gradle.kts` (fail-closed signing configuration)
- Benchmark optimization: `tool/benchmark_quiz.dart` (34.7x speedup)
- Secrets audit: Git grep across repository (0 exposed credentials)

### Evidence Missing
- Physical Android handset USB logcat during v1.1.0 -> v2.0.0 in-place upgrade.
- Real-user analytics or crash monitoring in production.

### Next Action
Publish the benchmark optimization results and proceed with staging APK signing verification when repository secrets are available.
