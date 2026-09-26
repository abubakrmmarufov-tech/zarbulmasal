# Book covers, 26 Sep 2026

Owner's authorisation (Phase 11, task 1): download the covers from kitobkhon.net
and khirad.tj at build time; the app stays offline.

- **Tool:** `tool/books/fetch_covers.py` (tests: `tool/books/test_fetch_covers.py`).
- **Per edition:** `BOOK_COVERS_2026-09-26.json` gives the page, the image URL,
  HTTP status, sha256, bytes, size and verdict.
- **Politeness:**
  - one request at a time, at most one a second;
  - User-Agent `ZarbulmasalCoverFetcher/1.0 (+https://github.com/abubakrmmarufov-tech/zarbulmasal; build-time cover download, 1 request/s)`;
  - every answer saved to `build/book_covers/state.json`, so a rerun resumes.
  - 997 requests in all.

## What counts as a cover

- **The book page decides.** The cover is the page's `og:image`.
  kitobkhon.net shows `/images/cover.png` for books it has no cover for; that
  means *no cover*.
- **A recorded `coverUrl` is not used when the page shows none.** Five records
  named one:
  - three pointed at the «Наводир-ул-вақоеъ» image, one of them Дониш's
    «Девони ашъор»;
  - Қобуснома keeps the cover bundled in an earlier phase (its own image,
    `kobusnoma.jpg`).
- **Kept only when** the server calls it an image, it decodes (Pillow), it is at
  least 100 × 140 px and not a single colour, and at most five editions share it.
  - Volumes of one work share their series' cover: «Маснавии маънавӣ» 1–6,
    «Куллиёт» 5–7, «Сарои санг» 1–3, «Таърихи адабиёти тоҷик» 1–2,
    «Наводир-ул-вақоеъ» 1–2.
  - Зоконӣ and Бухороӣ share one printed volume («Ахтарони адаб», 28).
- **In the data:**
  - each kept image is bundled as `assets/data/books/covers/<book>.webp` and set
    as the edition's `coverAssetPath`;
  - `coverUrl` keeps where it came from (set for the 10 khirad.tj books, which
    had none);
  - `rightsStatus` is unchanged (`rightsUnclear`).

## Results

| | Editions |
|---|---:|
| Cover downloaded and kept | 300 (7 already bundled; 293 new: 283 kitobkhon.net, 10 khirad.tj) |
| The book page shows no cover | 411 |
| Rejected (HTML, undecodable, tiny, blank, placeholder) | 0 |
| **Bundled covers in the app** | **301** of 711 editions |

- **Size:**
  - 293 downloads, 31.8 MB as served;
  - after `tool/design/compress_images.py` (≤ 232 × 340, WebP q80): 4.37 MB;
  - the covers folder is now 4.9 MB.
- **APK** (arm64, release, obfuscated): 22,956,803 → 27,399,113 bytes (**+4.44 MB**).

The other 410 editions get a typographic cover: the category's «Атлас» ikat
band over the title and author (Persian UI: the Persian title, else the
category's Persian name).

## Link rot

All 711 book pages answered **200**, and all 300 cover images kept answered
**200**. Four of the five recorded cover URLs that are no longer used were
fetched in a first pass and answered 200 too. **No dead links.** The PDF links
(`readUrl`) were not checked.
