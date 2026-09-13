# Changelog

All notable changes to Zarbulmasal are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and releases use
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Rebuilt the application around the editorial Qalam design system.
- Redesigned home, discovery, reading, quiz, flashcard, saved, category, level,
  daily, settings, loading, empty, and invalid states.
- Added responsive, multilingual, dark-theme, reduced-motion, and accessibility
  behavior across the interface.
- Made the web build self-contained and capable of reopening offline after the
  first successful load.
- Standardized the product identity across Tajik Cyrillic, Latin, and Persian
  script.

### Added

- Regression coverage for navigation, persistence, reading, learning flows,
  accessibility, and realistic phone widths.
- GitHub quality checks, Android test artifacts, and GitHub Pages deployment.
- Open-source contribution, conduct, security, and issue-reporting guidance.

## [1.1.0] - 2026-09-13

### Added

- Added the literature hub, ten verified poet profiles, school-canon browsing,
  literary search, and rights-aware poem and oral-heritage readers.
- Added a public Android install page with lightweight ARM64 and ARMv7 APKs
  plus a universal compatibility package.

### Fixed

- Preserved the v1.0.1 Android signing identity and raised all package version
  codes so existing users can install this release as an update.
- Enforced complete editorial verification, rights clearance, and non-empty
  text before any literary work or oral-heritage entry can be published.

### Changed

- Split Android packages by CPU architecture and separated debug symbols,
  reducing the recommended ARM64 download while retaining all content, fonts,
  behavior, and visual design.

[Unreleased]: https://github.com/abubakrmmarufov-tech/zarbulmasal/commits/main
[1.1.0]: https://github.com/abubakrmmarufov-tech/zarbulmasal/compare/v1.0.1...v1.1.0
