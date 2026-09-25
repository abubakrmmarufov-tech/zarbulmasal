<div align="center">
  <img src="assets/branding/zarbulmasal_icon.png" alt="Zarbulmasal app icon" width="112">
  <h1>Зарбулмасал</h1>
  <p><strong>Zarbulmasal · ضرب‌المثل</strong></p>
  <p>Tajik literature, proverbs and history from the school textbooks: offline, free, in Tajik and Persian.</p>
  <p><a href="https://abubakrmmarufov-tech.github.io/zarbulmasal/"><strong>Open the web app</strong></a></p>

[![Quality](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/workflows/ci.yml/badge.svg)](https://github.com/abubakrmmarufov-tech/zarbulmasal/actions/workflows/ci.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-A43D2F.svg)](LICENSE)

</div>

## What's inside

- **706 poems** from the Tajik literature textbooks for grades 5–11. Each poem is cited by book and page and checked line by line against its page. You can browse by poet, grade or form (ghazal, rubai, masnavi, qit'a, qasida).
- **145 poets** with biographies and dates taken from their textbook chapters.
- **Tap a word** in a poem to see its meaning from the **1,867-word Lexicon** (the textbook glossaries).
- **History of the Tajik people:** 85 topics with reading sections from the maorif.tj history textbooks.
- **150 proverbs** in 20 themes, with a quiz and flashcards.
- Tajik (Cyrillic) and Persian interface, light and dark mode, and large text.
- **Offline:** no account, no ads, no analytics.

## Sources

Content comes only from the school textbooks and [maorif.tj](https://maorif.tj), and every record carries its book and page.

- **The textbook PDFs are kept outside this repository.** [`docs/literature/pdfs/MANIFEST.json`](docs/literature/pdfs/MANIFEST.json) identifies each one by SHA-256, and [`SOURCE_INVENTORY.md`](docs/literature/SOURCE_INVENTORY.md) lists them.
- **No work is editorially approved yet.** See the team verification list in [`PHASE_7_REPORT.md`](docs/design/PHASE_7_REPORT.md).

## Run it

```sh
flutter pub get
flutter run            # Android device or emulator
flutter run -d chrome  # web
```

Requires Flutter 3.47.2.

## Checks

CI ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs all of these on every pull request:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage                  # 80% minimum
dart run tool/validate_literature_json.dart
dart run tool/validate_literary_content.dart
python3 tool/provenance_linter.py
```

With the textbook PDFs present locally, `tool/literature/audit_textbook_poems.py` re-checks every poem against its page.

## Layout

```text
lib/      app code: core (design system «Муҳр», theme, strings), features, router
assets/   bundled data (poems, poets, history, Lexicon, books) and fonts
test/     widget, golden and accessibility tests
tool/     validators, provenance linter, extraction and audit tools
docs/     design reports, literature evidence, release notes
```

## Releases

- **Android:** a debug-signed tester preview (`1.0.0-preview.1`) exists; there is no store release yet. [`PLAY_STORE_READINESS.md`](docs/design/PLAY_STORE_READINESS.md) lists what Google Play needs, and [`RELEASE_RUNBOOK.md`](docs/RELEASE_RUNBOOK.md) covers signing and rollback.
- **Web:** published to GitHub Pages from `main`, with a [privacy policy](web/privacy.html).

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md). Report security issues as described in [SECURITY.md](SECURITY.md). MIT licensed. Contact: [@imarufov](https://t.me/imarufov) on Telegram.
