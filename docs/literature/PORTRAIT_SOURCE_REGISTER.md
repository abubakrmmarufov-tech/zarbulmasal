# Portrait Source Register

Current source-backed portrait pass: 2026-09-21.

The uploaded textbook corpus contains seven PDFs. A page-by-page image audit
found 94 portrait-shaped candidates. Only 67 were admitted here: each has an
explicit author ID, an exact PDF page, a local asset, and a page heading/profile
that identifies the person. Decorative, mythological, group, or ambiguous
illustrations were excluded.

The authoritative machine-readable mapping is
[`assets/data/literature/portrait_sources.json`](../../assets/data/literature/portrait_sources.json).
The deterministic extractor is
[`tool/literature_pipeline/scripts/extract_portraits.py`](../../tool/literature_pipeline/scripts/extract_portraits.py).

Processing is limited to scan-polarity normalization for textbook negatives;
no face is generated, reconstructed, or altered. Source rights remain
`unknown` because locating a portrait in an uploaded book is not permission to
redistribute it. Authors without an admitted reliable portrait render the
same accessible placeholder in light/dark and Tajik/Persian layouts.

The register deliberately does not claim that a textbook illustration is a
photograph or that its identity is historically exact; it records only the
source identity presented on the cited page.

## Follow-up candidate audit — 2026-09-21

A second inventory of the 27 portrait-shaped image resources not present in
the manifest found no additional admissible author portrait. Most were
duplicate images for authors already covered by a clearer profile page; the
remaining resources were scene illustrations, group images, or page-level
image resources whose visible placement did not provide an author profile.
They remain excluded. The admitted total therefore remains 67, and no new
face was inferred from a contextual page illustration.

The bundle audit also found two unreferenced portrait files with no author or
source mapping. They were moved to a recoverable quarantine outside the
checkout rather than assigned by inference; a regression guard now requires
every bundled portrait file to be referenced by `poets.json`.

An additional read-only review of the official [Maorif Grade 11, 2025
edition](https://maorif.tj/storage/libraries/01KH8MQHJJBRM70Q8FXHNNCGV5.pdf)
found portrait-shaped profile images for several modern authors. The
identifiable active-author profiles duplicate authors already covered by the
higher-priority uploaded textbook PDFs; the remaining profiles are outside the
active poet catalog or do not change the existing source decision. Lo(iq
Sherali’s p. 288 portrait is therefore not added a second time. The admitted
total remains 67, and the 2025 edition contributes no new portrait asset.

## Explicit polarity override — 2026-09-23

A caption/photo cross-check against the independent Grade 11 (2018) p. 152
portrait proved the Grade 5 (2017) p. 216 crop of **Мирзо Турсунзода**
(`tursunzoda`) was printed/scanned as a photographic negative: cross-correlation
with the Grade 11 positive was −0.67 as-is and +0.67 after inversion, and the
dHash distance dropped from 56/64 to 8/64. The conservative polarity heuristic
in `extract_portraits.normalize_portrait()` did not fire because the negative’s
centre pixel was too dark (luma 54 < 60).

The shipped `tursunzoda.jpeg` asset was corrected by inverting the existing
Grade 5 crop (503×668 RGB, JPEG quality 92), keeping `sourcePage: 216` and the
existing `sourceReference`. To keep future regeneration deterministic, the
manifest entry carries an explicit `"polarity": "invert"` override, which the
extractor honors ahead of the heuristic; no other author is affected and the
admitted total remains 67.
