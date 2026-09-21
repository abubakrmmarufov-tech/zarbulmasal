# Zarbulmasal Reliability and UX Plan

Audit baseline: `e87d1f6` (`main`), inspected 2026-09-13.

## Scope

Verify and improve the complete offline application experience across Tajik Cyrillic and Persian/Arabic script, while preserving the Qalam visual system and refusing to publish unverified literary text.

## Execution order

1. Establish reproducible quality gates: format, analyze, tests, content validation, web build, Android package validation.
2. Correct remaining data/validation truthfulness issues and ensure UI counts derive from approved records.
3. Exercise every route and important interaction in both languages, themes, and representative phone widths.
4. Fix actionable logic, accessibility, localization, and release defects with regression tests.
5. Repeat independent review passes and update the issue register with command/runtime evidence.

## Completion gates

- No unmitigated local P0/P1 defects remain in the verified scope; the issue
  register still tracks external release gates for provenance/editorial
  approval, production signing, live deployment, security coverage, and
  physical-device verification.
- Full automated checks pass without weakened assertions.
- Every route and major control has observed runtime evidence.
- Pending literary material remains visibly pending and has no fabricated citation or verification claim.
- Android and web artifacts correspond to the audited source revision.
