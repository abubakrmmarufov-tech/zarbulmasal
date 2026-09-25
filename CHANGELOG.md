# Changelog

All notable changes to Zarbulmasal are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases use
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] — 2.0.0

A tester preview, `1.0.0-preview.1`, was shared as a debug-signed APK on
25 Sep 2026. It is not a release.

### Added

- 706 readable poems copied from the Tajik school literature textbooks
  (grades 5–11), each cited by book and page and checked line by line
  against its page.
- Poems by form (ghazal, rubai, masnavi, qit'a, qasida) in Explore and the
  poem list.
- Tap a word in a poem to see its Lexicon meaning; the Lexicon has 1,867
  words from the textbook glossaries.
- History reading sections from the maorif.tj history textbooks.
- Explore: a daily poem, proverb and word; poets by era; the history
  timeline.
- Golden images of the main screens and an accessibility test suite (tap
  targets, labels, contrast, headings, 200% text).

### Changed

- The «Муҳр» design: collection tiles with ikat bands, new typefaces and a
  calmer reading page, in light and dark, Tajik and Persian.
- Lighter APK: subset fonts, smaller images, R8 and resource shrinking.
- The textbook PDFs are no longer in the repository;
  `docs/literature/pdfs/MANIFEST.json` names each one by SHA-256.

### Removed

- One-off data scripts and superseded reports.

## [1.0.1] — 2026-09-09

Published as APKs on GitHub Releases: Tajik wording fixes (*Пешрафта*,
*Боргирӣ...*, *Ғайрифаъол*), minSdk 24 / targetSdk 36, and the Qalam
editorial design across Cyrillic and Persian script.

[Unreleased]: https://github.com/abubakrmmarufov-tech/zarbulmasal/compare/v1.0.1...main
[1.0.1]: https://github.com/abubakrmmarufov-tech/zarbulmasal/releases/tag/v1.0.1
