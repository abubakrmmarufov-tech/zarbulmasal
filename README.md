<div align="center">
  <img src="assets/branding/zarbulmasal_icon.png" alt="Zarbulmasal app icon" width="112">
  <h1>Зарбулмасал</h1>
  <p><strong>Zarbulmasal · ضرب‌المثل</strong></p>
  <p>A calm, editorial home for Tajik proverbs, language, memory, and discovery.</p>
  <p>
    <a href="https://abubakrmmarufov-tech.github.io/zarbulmasal/">
      <img src="https://img.shields.io/badge/%F0%9F%9A%80_Open_Live_App-abubakrmmarufov--tech.github.io%2Fzarbulmasal%2F-2e7d32?style=for-the-badge&logoColor=white" alt="Open Live App">
    </a>
  </p>
  <p>
    <a href="CONTRIBUTING.md">Contribute</a>
    ·
    <a href="https://github.com/abubakrmmarufov-tech/zarbulmasal/issues">Report an issue</a>
  </p>
</div>

[![Quality](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/workflows/ci.yml/badge.svg)](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-A43D2F.svg)](LICENSE)

Zarbulmasal is an open-source Flutter application for reading, understanding,
remembering, and practising Tajik proverbs. The complete catalog ships with the
app, so the main reading and learning experience works without an account or a
network connection.

## Product identity

These names are intentional and should stay consistent across the app, stores,
documentation, and code:

| Context | Canonical name |
| --- | --- |
| Tajik Cyrillic product name | **Зарбулмасал** |
| Latin project name | **Zarbulmasal** |
| Persian-script interface name | **ضرب‌المثل** |
| Repository and Dart package | `zarbulmasal` |
| Android application ID | `com.zarbulmasal.zarbulmasal` |

## What is included

- **Proverbs Catalog**: 149 book-attested traditional proverbs across 20 categories and 6 data-derived levels
- **Literary Heritage (Мероси адабӣ)**: 159 catalogued author records (145 public, 6 rejected artifacts, 8 pending review) and 5,501 textbook candidates from Grades 5–11. Records without editorial, source, and rights approval remain visibly quarantined; only approved works can enter the bilingual Cyrillic/Persian poem reader.
- **History of the Tajik People (Таърихи халқи тоҷик)**: Chronological timeline covering 6 canonical epochs (Ancient & Aryan, Samanid Renaissance, Medieval Dynasties, Enlightenment, Soviet, and Independence), curriculum browsing by textbook grade (5–11), and topics
- **Cultural Knowledge Graph**: Relational cross-linking between historical eras, rulers, and literary figures ("Explore Their World")
- **Tajik Cyrillic & Persian Arabic Support**: Full bilingual reading modes, RTL text direction isolation, Persian numerals, and phonetic diacritic-tolerant search
- **Learning Hub**:
  - Proverb Quizzes with post-answer explanation review and Persian numeral scoring
  - Spaced-repetition Flashcards with persistent mastery states ("Again / Learning / Mastered")
- **Source Verification & Rights**: Rigorous academic provenance with verified print editions and clear publication quarantine gates
- **Design & Performance**: Qalam design system with light/dark ink themes, offline PWA support, and responsive layouts tested down to 320px ultra-compact viewports

## Design and architecture

The Qalam design system in `lib/core/design_system/` uses warm paper, deep ink,
vermilion accents, book-like margins, restrained rules, and a multilingual type
system built from Noto Sans, Noto Serif, and Noto Naskh Arabic. Font files and
their licenses are bundled locally.

GoRouter owns the application destinations. Riverpod manages filters, daily
selection, favorites, quizzes, flashcards, language, and theme. SharedPreferences
persists favorites, writing-system choice, and theme. The catalogs remain
local and available offline; quiz scores and flashcard sessions remain local to
the current session.

```text
lib/
├── core/       design system, theme, localization, constants
├── data/       proverb/literature models and the bundled catalog
├── features/   home, discovery, reading, literature, learning, saved items, settings
├── router/     route definitions and navigation behavior
└── shared/     providers and cross-feature widgets
```

## Run locally

Install Flutter 3.47.2, then run:

```sh
git clone https://github.com/abubakrmmarufov-tech/zarbulmasal.git
cd zarbulmasal
flutter pub get
flutter run
```

For the web app:

```sh
flutter run -d chrome
```

### Install on iPhone or iPad

1. Open the [live app](https://abubakrmmarufov-tech.github.io/zarbulmasal/) in Safari.
2. Tap Safari's **Share** button.
3. Choose **Add to Home Screen**.
4. Confirm with **Add**.
5. Launch Зарбулмасал from the new Home Screen icon.

Open the site online once before relying on the installed app offline so its
application shell, catalog, fonts, and other required resources can be cached.

## Quality checks

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
dart run tool/validate_literature_json.dart
dart run tool/validate_literary_content.dart
flutter build web --release --base-href /zarbulmasal/
flutter build appbundle --release  # requires production signing variables
python3 tool/verify_android_bundle_alignment.py build/app/outputs/bundle/release/app-release.aab
bash tool/verify_android_release_artifacts.sh build/app/outputs/bundle/release/app-release.aab
python3 tool/deep_browser_audit.py https://abubakrmmarufov-tech.github.io/zarbulmasal/
```

The regression suite currently covers 394 automated tests across all routes, 8 viewports (from 320px ultra-compact phones to tablet and desktop), both writing systems (Cyrillic and Persian Arabic RTL), large text, dark mode, filtering, parallel script reading, clipboard behavior, favorites, persisted preferences, quizzes, flashcards, and empty states. `tool/deep_browser_audit.py` validates viewport overflow, console errors, page exceptions, failed requests, and route diagnostics across all major destinations, and exits nonzero on a real browser failure.

## Android release (currently withheld)

See [`docs/RELEASE_RUNBOOK.md`](docs/RELEASE_RUNBOOK.md) for the protected
release, rollback, and incident-evidence procedure.

Direct-download APKs for Android devices (Android 7.0+) are staged by the
release workflow in the [Android Downloads Portal](https://abubakrmmarufov-tech.github.io/zarbulmasal/android/)
only after production signing secrets are configured and the current release
artifacts pass package, signature, ABI, alignment, and checksum checks.

Current status: the public Android portal and download links are intentionally
withheld. No APK listed in this repository should be treated as a current
installable release until a production-signed artifact has passed those checks
and the portal has been verified after publication.

The source release includes the [static privacy policy](web/privacy.html), and
the in-app privacy disclosure points to the verified live Pages URL. The current
web-only deployment returns HTTP 200 for both the app root and
`/zarbulmasal/privacy.html`; keep the post-deploy verification in CI before
using it as the Google Play privacy-policy URL.

The following is the post-publication installation flow; it is not currently
actionable while the portal is withheld:

- [Intended Android Portal & Direct APK Downloads](https://abubakrmmarufov-tech.github.io/zarbulmasal/android/)
  - **ARM64-v8a**, recommended for modern phones
  - **ARMv7a**, for compatible 32-bit devices
  - **Universal**, for all supported architectures

### Post-publication installation instructions:
1. Open the [Android Downloads Portal](https://abubakrmmarufov-tech.github.io/zarbulmasal/android/) in your mobile browser.
2. Select your device architecture (ARM64 recommended for modern devices).
3. Verify the published checksum and signing identity before opening the APK.
4. Open the verified `.apk` file and tap **Install** (or **Update**).

### Delivery and signing notes:
- **Direct download**: Release assets are standalone `.apk` binaries hosted directly on the web app distribution portal, requiring no GitHub login and no `.zip` archive extraction.
- **Signing identity**: Public releases must use a protected `EXPECTED_RELEASE_CERT_SHA256` value that matches the real production keystore. The historical v1.0.1 digest is not trusted as a production identity because device inspection identifies it as `CN=Android Debug`.
- **Release evidence**: The main workflow archives verified APKs in an APK-rooted public-download artifact and retains the AAB, R8 mapping, Flutter obfuscation symbols, and native debug symbols in a separate evidence artifact for crash diagnosis. Manual release verification also requires `EXPECTED_RELEASE_CERT_SHA256` to be exported alongside the production keystore variables.
- **Workflow artifacts (CI)**: CI workflow runs also upload test APKs to the [Quality & Pages action runs](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/workflows/ci.yml).

## Contributing

Bug fixes, interface improvements, translations, and well-sourced proverb
corrections are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a
pull request. Security reports should follow [SECURITY.md](SECURITY.md).

Zarbulmasal is available under the [MIT License](LICENSE). For general feedback,
contact [@imarufov](https://t.me/imarufov) on Telegram.
