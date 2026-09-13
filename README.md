<div align="center">
  <img src="assets/branding/zarbulmasal_icon.png" alt="Zarbulmasal app icon" width="112">
  <h1>Зарбулмасал</h1>
  <p><strong>Zarbulmasal · ضرب‌المثل</strong></p>
  <p>A calm, editorial home for Tajik proverbs, language, memory, and discovery.</p>
  <p>
    <a href="https://abubakrmmarufov-tech.github.io/zarbulmasal/">Open the web app</a>
    ·
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

- **Proverbs Catalog**: 149 book-attested traditional proverbs plus 1 clearly labeled needs-review
  modern learning text, across 20 categories and 6 data-derived levels
- **Literary Heritage (Мероси адабӣ)**: 171 Tajik poets and 1,466 quarantined poems currently under manual review from 7 school literature textbooks (Grades 5-11)
- Tajik Cyrillic and Persian-script reading modes with correct text direction
- Search, category filters, level filters, saved items, and daily reading
- Meaning, explanation, example, source, and verification metadata
- Quizzes, answer feedback, scoring, and replay
- Swipeable flashcards with reveal and session progress
- Dedicated poem reader and poet biography profiles
- Light and dark themes, large-text support, and reduced-motion behavior
- Android and installable web builds with offline reopening after first load

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
flutter build apk --release
flutter build web --release --base-href /zarbulmasal/ --no-web-resources-cdn --no-wasm-dry-run
bash tool/prepare_web_release.sh
```

The regression suite covers routes at 360, 390, and 430 logical pixels, both
writing systems, large text, dark mode, filtering, reading, clipboard behavior,
favorites, persisted preferences, quizzes, flashcards, and empty or invalid
states. GitHub Actions runs the same checks and deploys the web build from `main`.

## Install on Android

Direct-download APKs for Android devices (Android 7.0+) are available from the [Android Downloads Portal](https://abubakrmmarufov-tech.github.io/zarbulmasal/android/):

- [Android Portal & Direct APK Downloads](https://abubakrmmarufov-tech.github.io/zarbulmasal/android/)
  - **ARM64-v8a** (~20 MB, recommended for modern phones)
  - **ARMv7a** (~18 MB, for 32-bit devices)
  - **Universal** (~56 MB, all architectures)

### Installation instructions:
1. Open the [Android Downloads Portal](https://abubakrmmarufov-tech.github.io/zarbulmasal/android/) in your mobile browser.
2. Select your device architecture (ARM64 recommended for modern devices).
3. Tap **Download anyway** when prompted by Android.
4. Open the downloaded `.apk` file and tap **Install** (or **Update**).

### Delivery and signing notes:
- **Direct download**: Release assets are standalone `.apk` binaries hosted directly on the web app distribution portal, requiring no GitHub login and no `.zip` archive extraction.
- **Signing identity**: Public releases maintain continuity with the v1.0.1 signing certificate (SHA-256 `93287a41a80796ceab4f049fced1685abb02851a9f4cebd9bd28b1f27857f91e`), allowing in-place upgrades.
- **Workflow artifacts (CI)**: CI workflow runs also upload test APKs to the [Quality & Pages action runs](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/workflows/ci.yml).

## Contributing

Bug fixes, interface improvements, translations, and well-sourced proverb
corrections are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a
pull request. Security reports should follow [SECURITY.md](SECURITY.md).

Zarbulmasal is available under the [MIT License](LICENSE). For general feedback,
contact [@imarufov](https://t.me/imarufov) on Telegram.
