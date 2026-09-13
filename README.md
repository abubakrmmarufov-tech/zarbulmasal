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
- **Literary Heritage (Мероси адабӣ)**: 178 Tajik poets and 1,466 poems extracted with full provenance from 7 school literature textbooks (Grades 5-11)
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

Public direct-download APK assets are available from the [Latest Release](https://github.com/abubakrmmarufov-tech/zarbulmasal/releases/latest) without requiring a GitHub account or archive extraction:

- **Universal compatibility APK (v2.0.0, ~56 MB)**:  
  [Download app-release.apk](https://github.com/abubakrmmarufov-tech/zarbulmasal/releases/download/v2.0.0/Zarbulmasal-v2.0.0.apk)

### Installation instructions:
1. Tap the download link above in your Android browser (Chrome, Samsung Internet, Firefox, etc.).
2. When prompted by Android ("File might be harmful"), tap **Download anyway**.
3. Open the downloaded `.apk` file. If prompted, enable **Install unknown apps** for your browser.
4. Tap **Install** (or **Update**).

### Delivery and signing notes:
- **Direct download**: Release assets are standalone `.apk` binaries hosted on GitHub Releases, requiring no GitHub login and no `.zip` archive extraction.
- **Signing identity**: Pre-release builds use development signing until repository release secrets (`KEYSTORE_BASE64`, etc.) are configured. Upgrading between builds signed with differing keys requires uninstalling the prior build first.
- **Workflow artifacts (CI)**: CI workflow runs also upload test APKs to the [Quality & Pages action runs](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/workflows/ci.yml), which require a GitHub login and extract from `.zip`.

## Contributing

Bug fixes, interface improvements, translations, and well-sourced proverb
corrections are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a
pull request. Security reports should follow [SECURITY.md](SECURITY.md).

Zarbulmasal is available under the [MIT License](LICENSE). For general feedback,
contact [@imarufov](https://t.me/imarufov) on Telegram.
