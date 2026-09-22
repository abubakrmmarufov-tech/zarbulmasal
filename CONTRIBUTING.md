# Contributing to Zarbulmasal

Thank you for helping improve Zarbulmasal. Contributions can address Flutter
code, accessibility, translations, documentation, and the proverb catalog.

## Before opening an issue

- Search the existing issues for the same problem or suggestion.
- Use the content-correction template for spelling, translation, attribution,
  or source changes in the proverb catalog.
- Include the affected proverb ID when it is available.
- Support cultural or language corrections with a credible published source.

## Local setup

```sh
git clone https://github.com/abubakrmmarufov-tech/zarbulmasal.git
cd zarbulmasal
flutter pub get --enforce-lockfile
flutter run
```

Create a focused branch, keep changes scoped to one concern, and use a clear
commit message such as `fix: correct Persian product name`.

## Project conventions

- Preserve existing routes, provider behavior, persistence keys, and catalog IDs
  unless the change explicitly requires a migration.
- Use the shared Qalam tokens and components before creating feature-only styles.
- Verify both Tajik Cyrillic and Persian-script layouts. Persian content must use
  right-to-left direction and a font with the required glyphs.
- Keep touch targets accessible and avoid conveying state through color alone.
- Do not add network dependencies for content already bundled with the app.
- Never commit credentials, signing keys, generated build output, or local tool
  state.

## Validate a change

Run the checks that match your change. Before opening a pull request, the full
set should pass:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test --coverage
python3 tool/check_coverage.py coverage/lcov.info --minimum 80
flutter build apk --debug --target-platform android-arm64
flutter build web --release --base-href /zarbulmasal/ --no-web-resources-cdn --no-wasm-dry-run
```

The release APK and Play App Bundle builds intentionally fail closed unless
`KEYSTORE_PATH`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, and `KEY_PASSWORD` point to
the production signing material. Do not substitute a debug or throwaway key
for a public release; use the secret-gated CI workflow for signed artifacts.

Add a meaningful regression test when behavior changes. For interface work,
inspect representative phone widths around 360, 390, and 430 logical pixels and
check large text where practical.

## Pull requests

Explain the user-visible problem and resulting behavior. Include validation
results and screenshots when a visual change benefits from them. Keep generated
files and unrelated formatting out of the diff.

By contributing, you agree that your contribution is licensed under the
repository's [MIT License](LICENSE).
