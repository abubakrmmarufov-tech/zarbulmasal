# Proverb plan — 2026-09-26

Phase 9, step 2. It acts on `PROVERB_SOURCE_AUDIT_2026-09-26.md`.

## Data model

- **`SourceRef` (lib/data/models/source_ref.dart), extended.** Today it has `bookTitle`, `authorEditor`, `year`, `pdfPage` and `printedPage`. New fields:
  - `publisher` and `city`;
  - `printedText`: the saying exactly as that page prints it;
  - `note`.
- **`Proverb` gains:**
  - `sources`: a list of `SourceRef`, primary first. Empty means no printed source was found.
  - `meaningSource` and `exampleSource` (`SourceRef?`): set only when the meaning or example is copied from a book. `null` means editorial.
  - `exampleAttribution` (`String?`): the example's printed signature, e.g. «Сотим Улуғзода» or «Аз „Доробнома“».
  - `persianOrigin` (`transliteration` | `printed`), default `transliteration`.
- **Status rules:**
  - `pageVerified`: the record has at least one source with a page.
  - `needsReview`: no printed source; `sources` is empty.
  - `bookAttested` is no longer used by any record.
  - `sourceNote` becomes the primary citation line. It is empty for `needsReview`.
- **Stored user data:** IDs never change. Favorites, bayoz and learning progress store only IDs, so they keep loading. A test covers this.

## Interface

- **Source line.** The reading page cites the primary source: book, year, printed page. It lists other printed forms («Шаклҳои чопӣ»).
- **Unverified records** say that no printed source was found, instead of naming a book.
- **Printed or editorial.** The meaning, explanation and example sections each carry a label. A printed example shows its signature and citation.
- **Persian script** is labelled as a transliteration when it is one.
- **Quiz** questions and distractors use only `pageVerified` records.

## Rounds

Each round runs every check and ends in one commit.

| Round | Work |
|---|---|
| 1 | Model, interface, quiz and tests. No content change. |
| 2 | IDs 21–60: apply verdicts (text, sources, status, `sourceNote`), regenerate Persian for changed texts, update examples that quote a changed text, copy printed meanings and examples where the book prints them. |
| 3 | IDs 61–100, the same. |
| 4 | IDs 101–140, the same. |
| 5 | IDs 141–170, the same. |
| 6 | Add the textbook proverbs we lack (grade 5 lesson first), with printed meanings and printed examples. New IDs start at 171. Existing categories only. |
| 7 | `docs/design/PHASE_9_REPORT.md`. |

Every change is logged with before, after and page in `docs/content/PROVERB_DECISIONS_2026-09-26.json`.

## Rules applied

- **Variants.** When a book prints a different form, our text becomes the book's form.
  - A second printed form of the same saying is shown as a printed form, not merged.
  - Existing variant pairs (`canonicalId`/`variants`) stay as they are.
- **Not found → needsReview.** The record stays visible but leaves the quiz. The places searched are in the audit.
- **Editorial text stays, labelled.**
  - Where the text changes, the example's quotation of the proverb follows it.
  - Meanings flagged in the audit (IDs 70, 84, 130) are listed for the team, not rewritten.
- **Persian script** for a changed text is regenerated as a transliteration, in the same style as `PERSIAN_AUDIT_REGISTER.md`.
