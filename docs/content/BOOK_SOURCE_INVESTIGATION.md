# Books source investigation

Date: 2026-09-19

The two user-provided share links were opened in a browser and both resolved
to the same destination: [kitobkhon.net](https://kitobkhon.net/). They are not
two independent catalogues.

## Destination

| User link | Final destination | Role in Zarbulmasal |
|---|---|---|
| `https://share.google/LDg5VQX7eWm3wnOCp` | `https://kitobkhon.net/category/adabiyoti-klassiki` | Book availability and metadata only |
| `https://share.google/TFMnbBTHC13zhM0AZ` | `https://kitobkhon.net/` | Book availability and metadata only |

The site presents itself as a Tajik electronic library. Its visible catalogue
reports 1,092 books, 725 authors, and 30 categories. The language index
reports 1,047 Tajik, 30 Russian, 12 Persian-script, 7 English, 5 Uzbek, and 1
German-language records at the time of investigation.

The site exposes:

- catalogue search at `/books?q=...`;
- category pages such as `/category/nazm`, `/category/tarikh`, and school-grade
  categories;
- author pages at `/author/<slug>`;
- stable book detail pages at `/book/<slug>`;
- cover images where available;
- publication metadata including author, publisher, year, pages, language,
  city, categories, and tags;
- direct PDF links under `/storage/books/`.

## Reading behavior

The inspected book [Баъди борон](https://kitobkhon.net/book/badi-boron) exposes
a direct 8.8 MB PDF URL. The response is `application/pdf` with byte-range
support. The provider does not expose a site-native HTML/EPUB reader on the
inspected page; opening the PDF is delegated to the browser/PDF viewer.

Zarbulmasal therefore models these records as `readableExternal` PDF
availability and opens the provider's real PDF URL. It does not copy PDFs into
the app, claim an internal reader, or fabricate reading progress.

Eight provider cover URLs resolved successfully during link QA. Their exact
JPEG responses are now bundled under `assets/data/books/covers/` for reliable
web and offline rendering. Each edition retains the original `coverUrl` as
source/provenance metadata and the checked-in `coverAssetPath` only as a
rendering copy; Zarbulmasal does not proxy or rehost the provider URLs. The
other ten canonical books retain the truthful no-cover placeholder because
their provider pages exposed no dedicated matching cover.

## Rights and source separation

The provider describes books as freely downloadable, but the inspected pages
do not establish a reusable licence or public-domain status for each edition.
All imported editions therefore retain `rightsUnclear`. The app offers the
provider reading action and source page, while avoiding an in-app download
button and avoiding redistribution of the files.

Provider data is tagged with `bookAvailability` purpose. It is not used as
factual provenance for biographies, poetry attribution, interpretation,
historical claims, or dynasty data. Those claims remain governed by the
existing uploaded-PDF / `maorif.tj` policy.

## Imported catalogue scope

The app contains a curated first slice of 18 canonical books with one observed
Kitobkhon edition each. It spans poetry, classical literature, modern
literature, history, textbooks, and records whose provider metadata mentions
Persian script. This is intentionally metadata-only integration, not a blind
mirror of all 1,092 files.

No duplicate editions were turned into duplicate canonical books. Exact author
relationships are linked only when the provider name matches an existing
literary-author ID; no biography or history claim is inferred from a book
listing.

## Author and Literature relationships

The 18 canonical records were re-audited on 2026-09-21. All existing
`authorId` and `relatedPoetIds` values resolve to the current Literature
catalogue, and no dangling relationship IDs were found. Seven records retain
their provider-supplied `authorNameTj` without a Literature ID:

- `osori-muntakhab-tirmizi` — Адиб Собири Тирмизӣ;
- `sukhandoru` and `tojik-maqolaho` — Муҳтарам Ҳотам;
- `zaboni-tojiki-11` — Баҳриддин Камолиддинов;
- `panjakenti-qadim` — Абдуллоҷон Исҳоқов;
- `tarikhi-darvoz` — Ҳайдаршо Пирумшоев;
- `menejment` — no author supplied by the provider.

These names are displayed as source-catalogue metadata, not as clickable
Literature profiles. No author profile, biography, portrait, poem, or work
relationship is inferred from the provider listing alone. A future profile can
be linked only after independent source evidence is admitted under the
Literature provenance policy.
