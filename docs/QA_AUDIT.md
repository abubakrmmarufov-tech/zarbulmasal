# Zarbulmasal QA Audit & Release Verification Record

Date: 2026-09-09  
Environment: Flutter 3.47.2, Dart 3.13.2, Android SDK 36.1.0, Chrome for Testing 153.0.8010.12  
Branch: `qa/zarbulmasal-release-audit` (tracking `origin/main` at `3746466`)

---

## 1. Executive Summary

A comprehensive, evidence-grounded quality assurance audit and end-to-end verification pass was conducted for **Зарбулмасал (Zarbulmasal)**.

- **Feature Catalog**: 149 book-attested traditional proverbs plus 1 needs-review modern entry (IDs 21–170) across 20 categories and 6 data-derived difficulty levels; 20 earlier unknown-source entries remain quarantined.
- **Platforms Verified**:
  - Android (Universal APK, split-per-ABI APKs, release Android App Bundle).
  - Web/PWA (Production build with atomic offline service worker caching, Safari iOS Home Screen compatibility).
- **Design System**: Newest intended **Qalam** design system (`lib/core/design_system/`) preserved with 100% fidelity, featuring warm paper backgrounds (`#F3F0E7`), deep ink text (`#202720`), vermilion accents (`#A43D2F`), book-like margins, and multilingual typography (Noto Sans, Noto Serif, Noto Naskh Arabic).
- **Quality Checks**: Static analysis (0 issues), unit & widget test suite (74 tests passing), Playwright E2E tests (online/offline, 0 console errors, 0 failed requests).

---

## 2. Repository & Branch History Audit

| Branch | Latest Commit / SHA | Role / Relationship | Status |
| --- | --- | --- | --- |
| `origin/main` | `3746466` (PR #5) | Default production branch containing Qalam redesign, onboarding tour, font optimizations, and prepared PWA release | **CURRENT DEFAULT** |
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
   - `android/app/build.gradle.kts` uses `signingConfigs.getByName("debug")` when release secrets are absent.
   - CI builds run on ephemeral `ubuntu-latest` virtual machines where Gradle generates a fresh `debug.keystore` on every run.
   - If a user previously installed an APK from Run A, installing an APK from Run B causes Android OS to reject the installation with `INSTALL_FAILED_UPDATE_INCOMPATIBLE` ("App not installed: The package conflicts with an existing package by the same name").
5. **OS Compatibility & Permissions**:
   - `minSdk`: 24 (Android 7.0 Nougat+), requiring Android 7.0+.
   - `targetSdk`: 36 (Android 16), `compileSdk`: 36.
   - Permissions: 0 permissions requested (fully privacy-respecting and safe).
   - Alignment: 4-byte zipalign verified OK on all APKs.
   - Signatures: APK Signature Scheme v2 verified OK on all APKs.
   - Versioning: `versionCode` bumped to 2 (`1.0.1+2`) to support in-place package upgrades.

### Incident Verdict
Marked **UNVERIFIED**. Due to the absence of the user friend phone model, Android OS version, download URL, and logcat/error screenshot, no single root cause can be empirically asserted as the sole cause of that specific incident. However, the three delivery obstacles identified above (GitHub login requirement, ZIP packaging, and ephemeral debug key signature mismatches) collectively explain why a friend attempting to download from GitHub Actions would experience download or installation failure.

### Verified Android Artifact Matrix (v1.0.1+2)

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

1. `dart format --output=none --set-exit-if-changed lib test`: **PASS** (0 files changed).
2. `flutter analyze`: **PASS** (No issues found).
3. `flutter test --coverage`: **PASS** (All 59 unit, provider, widget, accessibility, and PWA tests passing).
4. `flutter build apk --release`: **PASS** (Universal APK: 53.8 MB, versionCode 2, versionName 1.0.1).
5. `flutter build apk --release --split-per-abi`: **PASS** (ARM64: 20.0 MB, ARMv7: 17.4 MB, x86_64: 21.5 MB).
6. `flutter build appbundle --release`: **PASS** (AAB: 52.8 MB).
7. `flutter build web --release --base-href /zarbulmasal/ --no-web-resources-cdn --no-wasm-dry-run`: **PASS**.
8. `bash tool/prepare_web_release.sh`: **PASS** (Deterministic build cache generated and injected).

---

## 7. Permanent Android Release Signing & Secrets Specification

### Gradle & CI Infrastructure
`android/app/build.gradle.kts` and `.github/workflows/ci.yml` have been configured to support production release signing via repository secrets:
- When repository secrets are defined, `.github/workflows/ci.yml` decodes `KEYSTORE_BASE64` to `/tmp/release.keystore` and exports `KEYSTORE_PATH`.
- Gradle reads `KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD` to sign release builds.
- When release secrets are not configured, Gradle safely falls back to local development debug signing so builds never fail.

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

## 9. Public Direct-Download Distribution Verification

To resolve the download obstacles identified in pre-release distribution (GitHub authentication wall and `.zip` archive wrapping):
- A public GitHub Release (`v1.0.1`) is published with standalone `.apk` assets.
- Both the ARM64 split APK (`app-arm64-v8a-release.apk`) and the universal APK (`app-release.apk`) are directly downloadable by unauthenticated mobile users.
- URLs verified via unauthenticated HTTP GET (returning HTTP 302 redirect to GitHub release asset storage with `content-type: application/vnd.android.package-archive`).

## Update 2026-09-13
- **Literary Heritage**: Added 171 poets and 1,466 quarantined poems currently under manual review.
- Fixed CSP, signing config, and FavoritesNotifier race conditions.

---

## 10. Release v2.0.0 Audit & Verification Register (2026-09-13)

### Executive Summary
- **Target Release**: Zarbulmasal v2.0.0 (`version: 2.0.0+2004`)
- **Android Upgrade Continuity**:
  - `v1.0.1` ARM64 release package: `versionCode 2002`, signing certificate SHA-256 `93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e`.
  - `v2.0.0` base `versionCode` set to `2004` (ARMv7: 3004, ARM64: 4004, Universal: 2004), guaranteeing clean in-place upgrade without `INSTALL_FAILED_VERSION_DOWNGRADE`.
  - CI workflow (`.github/workflows/ci.yml`) updated to verify package ID `com.zarbulmasal.zarbulmasal` and signing certificate digest before publishing.
- **GitHub Pages Android Portal**:
  - Direct downloads portal at `web/android/index.html` restored.
  - Staging script `tool/prepare_android_downloads.sh` integrates split APKs (`zarbulmasal-arm64-v8a.apk`, `zarbulmasal-armeabi-v7a.apk`, `zarbulmasal-universal.apk`) and checksum manifest directly into GitHub Pages deployment.
  - Resolves the 404 error on `/zarbulmasal/android/`.
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
   - Install published release `v1.0.1` ARM64 package (`versionCode 2002`, signing SHA-256 `93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e`).
   - Build or download a `v2.0.0` APK built with default base `versionCode 1` or lower than 2002.
   - Run `adb install -r app-arm64-v8a-release.apk` over the existing installation.
5. **Expected vs Actual Behavior**:
   - *Expected*: In-place upgrade succeeds preserving user preferences and favorites without error.
   - *Actual*: Android Package Manager rejects install with `INSTALL_FAILED_VERSION_DOWNGRADE` (or `INSTALL_FAILED_UPDATE_INCOMPATIBLE` if signed by an ephemeral key).
6. **Evidence**: Public release v1.0.1 ARM64 package inspection via `aapt dump badging` revealed `versionCode='2002'` and cert SHA-256 `93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e`.
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
9. **Verification Result & Revision**: Verified via `test/android_distribution_test.dart` and `bash tool/prepare_web_release.sh` generating `build/web/android/index.html` (PASS).

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
   - Look for Search action button in top bar to search the 171 authors and 1,466 works.
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

