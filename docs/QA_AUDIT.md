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
