# Proverb source audit — 2026-09-26

Phase 9, step 1. Every one of the 150 production proverbs (IDs 21–170) was looked up in the permitted printed sources. This file records what each source prints, where, and what that means for our record. Nothing here has been applied to the app yet; the changes are made in the rounds described in `PROVERB_PLAN_2026-09-26.md`.

## Sources

The seven folklore books were downloaded from their zarowadk.com download pages into `docs/content/pdfs/` (git-ignored; `docs/content/pdfs/MANIFEST.json` records SHA-256, size and pages). Edition data below is from each book's title page. The textbook PDFs were checked with `discover_pdfs.py` against `docs/literature/pdfs/MANIFEST.json`.

| Key | Book (title page) | Compiler / author | Publisher, city, year | Text layer | How it was read |
|---|---|---|---|---|---|
| `asrori1956` | «Зарбулмасал ва мақолҳои тоҷикӣ» | В. Асрорӣ (ҷамъкунанда ва тартибдиҳанда) | Нашриёти давлатии Тоҷикистон, Сталинобод, 1956 | no | No text layer. All 72 proverb pages (printed pp. 23–99) typed up from page images; every line used below re-read at 220 dpi. |
| `fozilov1_1975` | «Фарҳанги зарбулмасал, мақол ва афоризмҳои тоҷикию форсӣ. Ҷилди I» | Муллоҷон Фозилов | Ирфон, Душанбе, 1975 | no | No text layer. Alphabetical; covers headwords А–Д only. Each candidate headword position was read from page images. |
| `fozilov1973` | «Зарбулмасалу мақолҳо дар тамсилу ҳикояҳо» | М. Фозилов | Дониш, Душанбе, 1973 | no | No text layer. Contents read; one story page read. |
| `bayoz2_1990` | «Баёзи фолклори тоҷик. Ҷилди 2: Зарбулмасал, мақол, чистонҳо» | Б. Тилавов, Қ. Ҳисомов, Ф. Муродов, Ф. Зеҳниева (мураттибон) | Адиб, Душанбе, 1990 | yes | Text layer without Tajik letters (ҳ→х, қ→к, ҷ→ч, ӯ→у, ӣ→й). Searched by text; every reading used below re-read from the page image. |
| `roghun2017` | «Фолклори Роғун» | Рӯзии Аҳмад, Салоҳиддин Фатҳуллоев (гирдоварӣ ва тадвин) | ЭР-граф, Душанбе, 2017 | yes | Text layer in the legacy font; decoded like the textbooks. |
| `tursunzoda2012` | «Фарҳанги мардуми диёри Турсунзода» | Рӯзии Аҳмад, Дилшод Раҳимов (гирдоварӣ ва тадвин) | —, Душанбе, 2012 | yes | Poor text layer (two-page spreads); hits re-read from the page image. |
| `folklori_tojik1954` | «Фолклори тоҷик» | М. Турсунзода, А. Н. Болдырев (тартибдиҳандагон) | Нашриёти давлатии Тоҷикистон, Сталинобод, 1954 | no | No text layer. Contents and a page sample (every 4–6 pages) read: songs, dastans and verse only; it has no proverb section. |

- Edition note, `asrori1956`: Website: «Нашрдавтоҷик»; title page: «Нашриёти давлатии Тоҷикистон» (the same publisher, full name).
- Edition note, `tursunzoda2012`: Title page names no publisher; the website gives «ҶДММ „Позитив сервис“».
- Textbooks: the seven «Адабиёти тоҷик» books of `docs/literature/SOURCE_INVENTORY.md` (grade 5, 2017; grade 7, 2018; grade 9, 2026; grade 10, 2026; grade 11, 2018 are cited below). Their PDF page equals the printed page.

Page numbers are always given as printed page and PDF page. Scans have unnumbered leaves, so the two differ (Асрорӣ: PDF + 3; Фозилов vol. I: PDF + 1 to + 3).

## Method

1. Our text was folded (case, punctuation, Tajik letters) and searched in every page text and every typed-up line: exact matches first, then word-level near matches (up to two words added, dropped or changed).
2. Фозилов vol. I is alphabetical, so each proverb beginning with А–Д was looked up at its headword position; a missing headword was confirmed by reading its neighbours.
3. Every hit was read on the page image before it was accepted.

**Verdicts.**
- **exact:** a source prints our words. Punctuation follows the book; dashes are set as «—».
- **variant:** a source prints the same saying in a different form: up to two words differ, or our text was one half of a printed two-line saying. Our text will become the printed form, and the change is logged.
- **not found:** no permitted source prints it. **related** lists printed sayings on the same theme that are not the same saying; they are for the team, not for automatic replacement.

## Summary

| Verdict | Records |
|---|---:|
| exact | 33 |
| variant (text will change) | 28 |
| not found (→ needsReview) | 89 |
| total | 150 |

- **Source corrections:** 39 records are printed in a different book from the one their `sourceNote` names: 26, 27, 30, 32, 37, 42, 43, 46, 47, 49, 54, 55, 62, 65, 66, 68, 69, 70, 75, 76, 77, 78, 81, 84, 88, 92, 94, 104, 110, 114, 115, 117, 121, 125, 130, 137, 138, 142, 164.
- **Not found, by the book the record claimed:** Асрорӣ 1956 39, Фозилов, ҷ. I, 1975 28, Баёз, ҷ. 2, 1990 15, Фолклори тоҷик, 1954 4, Диёри Турсунзода, 2012 2, Фолклори Роғун, 2017 1.
- **Фозилов vol. I covers А–Д only.** 29 records labelled Фозилов vol. I begin with a later letter, so that volume cannot contain them; vols. II–III are not among the permitted sources.
- **«Фолклори тоҷик» (1954), «Фолклори Роғун» and «Фарҳанги мардуми диёри Турсунзода».** None of their 7 labelled records is printed in its own book.
- **Meanings, explanations and examples:** all 150 are editorial. None is printed; earlier agents wrote them. All meanings and examples were read against the proverb; each example uses its proverb in the figurative sense, in natural Tajik. Where the text changes, the example's quotation of the proverb must follow it.
- **Persian script:** all 150 are transliterations (`PERSIAN_AUDIT_REGISTER.md`). None of the permitted books prints these proverbs in Persian script: Фозилов's «тоҷикию форсӣ» means Tajik-and-Persian sayings, printed in Cyrillic.

## The 19 page candidates from `PROVERB_AUDIT.md`

All 19 are confirmed on the page, with the same printed/PDF pages: Асрорӣ IDs 24, 34, 36, 39, 41, 67, 74, 80, 87, 100, 117, 118, 144, 147, 150 and 164; Баёз ID 45 (31/31); Фозилов IDs 98 (69/70) and 116 (101/102).
- ID 117: Асрорӣ prints the longer «Гул бе хор намешавад, гӯшт бе устухон».
- ID 116: Фозилов p. 101 is a cross-reference («Аз як гул баҳор намешавад. ниг. Бо як гул…»); the main entry is p. 242 (PDF 245).

## Per proverb

Columns: M = meaning, E = example, Ex = simple explanation, P = Persian. «ed» = editorial, «ed✓» = editorial and checked, «printed avail.» = the book prints a meaning or usage example for this saying, «translit» = generated Persian script.

| ID | Our text | Verdict | Printed form (primary source) | Other witnesses / related | Claimed source → correct | M / Ex / E / P |
|---|---|---|---|---|---|---|
| 21 | Мисли модар ёру мисли Ватан диёре нест. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 22 | Паррандаро бо парвозаш баҳо диҳанд, одамро ба кораш. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 23 | Офтоб гармӣ дораду модар меҳр. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 24 | Илм хоҳӣ, такрор кун; ҳосил хоҳӣ, шудгор кун. | exact | «Илм хоҳӣ, такрор кун, ҳосил хоҳӣ, шудгор кун.» — Асрорӣ 1956, p. 25 (PDF 24) | — — Punctuation follows the book (comma, not semicolon). | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 25 | Меҳнати имрӯз роҳати фардост. | not found | — | related: «Меҳнати тобистон — роҳати зимистон.» (Баёз, ҷ. 2, 1990, p. 47 (PDF 47)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 26 | Дасти одамизод — гул. | exact | «Дасти одамизод – гул.» — Адабиёт, синфи 5, p. 38 (PDF 38) (lesson «Зарбулмасалу мақолҳо», list of proverbs) | «Дасти одамизод гул.» (Баёз, ҷ. 2, 1990, p. 46 (PDF 46)); «Дасти одамизод гул аст.» (Асрорӣ 1956, p. 50 (PDF 47), variant); «ДАСТИ ОДАМИЗОД (ОДАМ) ГУЛ (АСТ).» (Фозилов, ҷ. I, 1975, p. 363 (PDF 366), main entry with printed meaning and examples); ««Дасти одамизод гул аст» – мегӯяд зарбулмасали тоҷик.» (Адабиёт, синфи 11, p. 234 (PDF 234), variant) | Асрорӣ 1956 → **Адабиёт, синфи 5** | printed avail. / ed✓ / ed✓ / translit |
| 27 | Ба як ҷавон чил ҳунар кам. | exact | «Ба як ҷавон чил ҳунар кам.» — Баёз, ҷ. 2, 1990, p. 45 (PDF 45) (section «Касбу ҳунар») | «Ба як ҷавонмард 40 ҳунар кам аст.» (Асрорӣ 1956, p. 40 (PDF 37), variant); «БА ЯК МАРД (ЙИГИТ, ҶАВОН) ЧИЛ ҲУНАР КАМ АСТ.» (Фозилов, ҷ. I, 1975, p. 192 (PDF 195), variant) | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit |
| 28 | Инсон бо забонаш не, бояд бо амалаш сухан гӯяд. | not found | — | — — Already needsReview (modernCustom). | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 29 | Сухан зар аст, сабр гавҳар. | not found | — | related: «АГАРЧИ СУХАН ЗАР АСТ, СУКУТ ГАВҲАР АСТ.» (Фозилов, ҷ. I, 1975, p. 51 (PDF 52)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 30 | Адаб беҳтарин ганҷ аст. | exact | «1. АДАБ БЕҲТАРИН ГАНҶ АСТ. 2. АДАБИ МАРД БЕҲТАР АЗ ЗАР(Р)И ӮСТ.» — Фозилов, ҷ. I, 1975, p. 54 (PDF 55) (main entry, printed meaning) | — | Асрорӣ 1956 → **Фозилов, ҷ. I, 1975** | printed avail. / ed✓ / ed✓ / translit |
| 31 | Меҳнат фаровон мекунад, танбалӣ вайрон мекунад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 32 | Меҳнати ҳалол — нони бемалол. | exact | «Меҳнати ҳалол — нони бемалол.» — Баёз, ҷ. 2, 1990, p. 47 (PDF 47) (section «Ҳаракату баракат») | — | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit |
| 33 | Бе ранҷ наояд ганҷ. | not found | — | related: «БЕ РАНҶ ГАНҶ НАХОҲӢ БУРД.» (Фозилов, ҷ. I, 1975, p. 209 (PDF 212)); related: «Нобурда ранҷ, ганҷ муяссар намешавад.» (Асрорӣ 1956, p. 64 (PDF 61)); related: «Наёбад касе ганҷ, нобурда ранҷ. (Фирдавсӣ)» (Асрорӣ 1956, p. 95 (PDF 91)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 34 | Аз бад — касофат, аз нек — шарофат. | exact | «Аз бад—касофат, аз нек—шарофат.» — Асрорӣ 1956, p. 32 (PDF 29) | «АЗ БАД КАСОФАТ, АЗ НЕК ШАРОФАТ.» (Фозилов, ҷ. I, 1975, p. 56 (PDF 57), cross-reference entry) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 35 | Салом аз хурд, калом аз калон. → «Салом аз хурду калом аз калон.» | **variant** | «Салом аз хурду калом аз калон.» — Асрорӣ 1956, p. 71 (PDF 68) | — | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 36 | Як китоби хуб беҳтар аз як хазинаи бузург. | exact | «Як китоби хуб беҳтар аз як хазинаи бузург.» — Асрорӣ 1956, p. 81 (PDF 78) | — | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 37 | Ҳунар аз мулку мероси падар беҳ. → «Ҳунар аз нуқраю тиллою зар беҳ, Ҳунар аз мулку мероси падар беҳ.» | **variant** | «Ҳунар аз нуқраю тиллою зар беҳ, / Ҳунар аз мулку мероси падар беҳ.» — Баёз, ҷ. 2, 1990, p. 45 (PDF 45) (our text was the second line only) | «Ҳунар аз нуқраву тиллову зар беҳ, / Ҳунар аз молу мероси падар беҳ.» (Фолклори Роғун, 2017, p. 296 (PDF 296), variant) — The book prints a two-line saying; our record held only its second line. | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed — check: now a two-line saying; meaning still fits / ed✓ / ed✓ / translit — regenerate |
| 38 | Дониш омӯхтан — бо сӯзан чоҳ кандан. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 39 | Тилло дар оташ, одам дар меҳнат маълум мешавад. | exact | «Тилло дар оташ, одам дар меҳнат маълум мешавад.» — Асрорӣ 1956, p. 74 (PDF 71) | — | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 40 | Кам гӯю дониста гӯй. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 41 | Нури ақл дониш аст. | exact | «Нури ақл—дониш аст.» — Асрорӣ 1956, p. 65 (PDF 62) | «Нури ақл дониш аст.» (Баёз, ҷ. 2, 1990, p. 44 (PDF 44), section «Ақл») | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 42 | Аввал андеша, баъд гуфтор. | exact | «Аввал андеша, баъд гуфтор.» — Асрорӣ 1956, p. 31 (PDF 28) | ««Аввал – андеша, баъд – гуфтор»» (Адабиёт, синфи 5, p. 38 (PDF 38), cited as a мақол); «Аввал андеша в-он гаҳ гуфтор.» (Баёз, ҷ. 2, 1990, p. 38 (PDF 38), variant); «АВВАЛ АНДЕША В-ОН ГАҲЕ (БАЪД) ГУФТОР.» (Фозилов, ҷ. I, 1975, p. 25 (PDF 26), variant, main entry) | Баёз, ҷ. 2, 1990 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit |
| 43 | Забони сурх сари сабзро медиҳад бар бод. → «Забони сурх сари сабз медиҳад барбод.» | **variant** | «Забони сурх сари сабз медиҳад барбод.» — Асрорӣ 1956, p. 54 (PDF 51) | «Забони сурх сари сабз медиҳад бар бод, / Киро забон на ба банд аст, пой дар банд аст. (Рӯдакӣ)» (Баёз, ҷ. 2, 1990, p. 51 (PDF 51), couplet signed Рӯдакӣ) | Баёз, ҷ. 2, 1990 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 44 | Забони сурх сари сабзро мехӯрад. | not found | — | — — Variant record of 43; no printed witness for «…мехӯрад». | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 45 | Сари хамро шамшер намебурад. | exact | «Сари хамро (каҷро) шамшер намебурад (набуридааст).» — Баёз, ҷ. 2, 1990, p. 31 (PDF 31) (our text is the base reading; the book gives alternatives in brackets) | — | Баёз, ҷ. 2, 1990 | ed✓ / ed✓ / ed✓ / translit |
| 46 | Даҳони пӯшида сад тилло. | exact | «Даҳони пӯшида сад тилло.» — Баёз, ҷ. 2, 1990, p. 35 (PDF 35) | «ДАҲОНИ ПӮШИДА ҲАЗОР ТИЛЛО» (Адабиёт, синфи 5, p. 121 (PDF 121), variant, heading of a «Гулистон» story) | Фозилов, ҷ. I, 1975 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit |
| 47 | Бо ҳалво гуфтан даҳон ширин намешавад. | exact | «БО ҲАЛВО ГУФТАН ДАҲОН ШИРИН НАМЕШАВАД.» — Фозилов, ҷ. I, 1975, p. 243 (PDF 246) (cross-reference to «Ба ҳалво гуфтан…» (vol. II)) | «Бо „ҳалво, ҳалво“ гуфтан даҳон ширин намешавад.» (Асрорӣ 1956, p. 43 (PDF 40), variant) | Асрорӣ 1956 → **Фозилов, ҷ. I, 1975** | ed✓ / ed✓ / ed✓ / translit |
| 48 | Нонро калон гиру, гапро калон не. | not found | — | related: «Гапро калон назан, нонро калон нагаз.» (Асрорӣ 1956, p. 45 (PDF 42)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 49 | Сухани хуб морро аз хонааш мебарорад. → «Гапи нағз морро аз хонааш мебарорад.» | **variant** | «ГАПИ НАҒЗ МОРРО АЗ ХОНААШ МЕБАРОРАД.» — Фозилов, ҷ. I, 1975, p. 269 (PDF 272) | «Бо сухани ширин мор аз хонааш мебарояд.» (Асрорӣ 1956, p. 42 (PDF 39), variant) | Асрорӣ 1956 → **Фозилов, ҷ. I, 1975** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 50 | Аз пашша фил масоз. | not found | — | related: «Бо гап ба чӯб либос пӯшонда, аз пашша фил месозад.» (Асрорӣ 1956, p. 41 (PDF 38)) — Not in Фозилов vol. I (checked pp. 89–90). | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 51 | Сарро деҳу сирро не. | not found | — | related: «Сар раваду сир наравад.» (Асрорӣ 1956, p. 71 (PDF 68)); related: «Сар раваду сир наравад.» (Баёз, ҷ. 2, 1990, p. 38 (PDF 38)) | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 52 | Дар ҳар сар сиррест. | not found | — | — — Not in Фозилов vol. I (checked p. 357). | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 53 | Дарро гуфтам, девор шунав. | not found | — | related: «БА ДАР МЕГӮЯМ, ДЕВОР БИШНАВ!» (Фозилов, ҷ. I, 1975, p. 141 (PDF 144)); related: «ДАР БА ТУ МЕГӮЯМ, ДЕВОР ГӮШ КУН!» (Фозилов, ҷ. I, 1975, p. 326 (PDF 329)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 54 | Гапи рост талх мешавад. | exact | «Гапи рост талх мешавад.» — Баёз, ҷ. 2, 1990, p. 26 (PDF 26) (section «Ростӣ») | «ГАПИ РОСТ ТАЛХ МЕШАВАД.» (Фозилов, ҷ. I, 1975, p. 269 (PDF 272)); «Сухани рост талх мешавад.» (Асрорӣ 1956, p. 73 (PDF 70), variant) | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit |
| 55 | Ростӣ — растӣ. | exact | «мук. Ростӣ — растӣ.» — Фозилов, ҷ. I, 1975, p. 90 (PDF 91) (cross-reference line) | «Ростӣ, растӣ.» (Баёз, ҷ. 2, 1990, p. 15 (PDF 15)) | Асрорӣ 1956 → **Фозилов, ҷ. I, 1975** | ed✓ / ed✓ / ed✓ / translit |
| 56 | Дурӯғ умри кӯтоҳ дорад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 57 | Ҳақиқат талх аст. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 58 | Ҳақиқатро пинҳон карда намешавад. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 59 | Илм — чароғи ақл. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 60 | Дониш аз хондан, ҳунар аз кор. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 61 | Одам аз одам меомӯзад. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 62 | Ҳунар беҳ аз симу зар. → «Ҳунар беҳ аз симу зар аст.» | **variant** | «Ҳунар беҳ аз симу зар аст.» — Адабиёт, синфи 5, p. 41 (PDF 41) (lesson «Зарбулмасалу мақолҳо») | — | Асрорӣ 1956 → **Адабиёт, синфи 5** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 63 | Ҳунарманд ҳар ҷо азиз аст. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 64 | Ҳунар дошта бошӣ, хор намешавӣ. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 65 | Ҳар кӣ ранҷ бурд, ганҷ бурд. → «Ранҷ бурдӣ, ганҷ бурдӣ.» | **variant** | «Ранҷ бурдӣ, ганҷ бурдӣ.» — Баёз, ҷ. 2, 1990, p. 47 (PDF 47) | «Ранҷ бурдӣ, / Ганҷ бурдӣ.» (Баёз, ҷ. 2, 1990, p. 15 (PDF 15)) | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 66 | То меҳнат накунӣ, роҳат набинӣ. | exact | ««То меҳнат накунӣ, роҳат набинӣ»» — Адабиёт, синфи 5, p. 38 (PDF 38) (cited as a мақол) | — | Баёз, ҷ. 2, 1990 → **Адабиёт, синфи 5** | ed✓ / ed✓ / ed✓ / translit |
| 67 | То меҳнат накунӣ, санги сиёҳ лаъл нагардад. | exact | «То меҳнат накунӣ, санги сиёҳ лаъл нагардад.» — Асрорӣ 1956, p. 74 (PDF 71) | «То меҳнат накунӣ, санги сиёҳ лаъл нагардад.» (Адабиёт, синфи 5, p. 41 (PDF 41)) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 68 | Бе меҳнат ганҷ муяссар намешавад. → «Бе меҳнат роҳат муяссар намешавад.» | **variant** | «Бе меҳнат роҳат муяссар намешавад.» — Асрорӣ 1956, p. 40 (PDF 37) | «Нобурда ранҷ ганҷ муяссар намешавад.» (Баёз, ҷ. 2, 1990, p. 47 (PDF 47), variant) — Not in Фозилов vol. I (checked p. 207). | Фозилов, ҷ. I, 1975 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 69 | Кор кунӣ, нон мехӯрӣ. | exact | «Кор кунӣ, нон мехӯрӣ.» — Асрорӣ 1956, p. 25 (PDF 24) | — | Баёз, ҷ. 2, 1990 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit |
| 70 | Кор кори кордон аст. → «Кор ба кордон осон аст.» | **variant** | ««Кор ба кордон осон аст»» — Адабиёт, синфи 5, p. 72 (PDF 72) (listed as зарбулмасалу мақол) | «Кор пеши кордон осон.» (Баёз, ҷ. 2, 1990, p. 46 (PDF 46), variant); «Ба кордон кор осон.» (Асрорӣ 1956, p. 38 (PDF 35), variant) | Фозилов, ҷ. I, 1975 → **Адабиёт, синфи 5** | ed — check: meaning describes «entrust work to the skilled»; the printed form says work is easy for the skilled / ed✓ / ed✓ / translit — regenerate |
| 71 | Ҳар чизе, ки коштӣ, ҳамонро медаравӣ. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 72 | Агар бод шинонӣ, тӯфон медаравӣ. | not found | — | — — Not in Фозилов vol. I (checked p. 33). | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 73 | Деҳқон бошад, ҷаҳон обод аст. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 74 | Заминро об вайрон мекунад, одамро гап. | exact | «Заминро об вайрон мекунад, одамро гап.» — Асрорӣ 1956, p. 54 (PDF 51) | «Заминро об вайрон мекунад, одамро – гап.» (Адабиёт, синфи 5, p. 41 (PDF 41)) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 75 | Об аз сар лой мешавад. → «Об аз сар лой.» | **variant** | «Об аз сар лой.» — Асрорӣ 1956, p. 65 (PDF 62) | «Об аз сар лой.» (Баёз, ҷ. 2, 1990, p. 76 (PDF 76)) | Фозилов, ҷ. I, 1975 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 76 | Қатра-қатра дарё шавад. → «Зарра-зарра мӯл шавад, Қатра-қатра кӯл шавад.» | **variant** | «Зарра-зарра мӯл шавад, / Қатра-қатра кӯл шавад.» — Баёз, ҷ. 2, 1990, p. 36 (PDF 36) (section «Сарфа») | «Қатра-қатра ҷамъ гардад, он гаҳе дарьё шавад.» (Асрорӣ 1956, p. 83 (PDF 80), variant) | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 77 | Сабр кунӣ, аз ғӯра ҳалво мешавад. → «Сабр кунӣ, ғӯра ҳалво мешавад.» | **variant** | «Сабр кунӣ, ғӯра ҳалво мешавад.» — Баёз, ҷ. 2, 1990, p. 32 (PDF 32) | «Гар сабр кунӣ, аз ғӯра ҳалво мепазад.» (Асрорӣ 1956, p. 45 (PDF 42), variant) | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 78 | Сабр талх аст, вале мевааш ширин. → «Сабр талх аст, вале оқибаташ ширин.» | **variant** | «Сабр талх аст, вале оқибаташ ширин.» — Асрорӣ 1956, p. 70 (PDF 67) | — | Фозилов, ҷ. I, 1975 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 79 | Шитоб кори шайтон аст. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 80 | Дер ояду шер ояд. | exact | «Дер ояду шер ояд.» — Асрорӣ 1956, p. 51 (PDF 48) | «Дер ояду шер ояд.» (Баёз, ҷ. 2, 1990, p. 33 (PDF 33)); ««Дер ояду шер ояд»» (Адабиёт, синфи 5, p. 42 (PDF 42), listed in an exercise) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 81 | Ҳар кор вақти худро дорад. → «Ҳар кор вақту соат дорад.» | **variant** | «Ҳар кор вақту соат дорад.» — Баёз, ҷ. 2, 1990, p. 105 (PDF 105) (section «Фурсат») | — | Фозилов, ҷ. I, 1975 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 82 | Имрӯзро ба фардо магузор. → «Кори имрӯзаро ба фардо магузор.» | **variant** | «Кори имрӯзаро ба фардо магузор.» — Асрорӣ 1956, p. 57 (PDF 54) | «Кори имрӯзаро ба фардо магузор.» (Баёз, ҷ. 2, 1990, p. 46 (PDF 46)); ««Кори имрӯзаро ба фардо нагузор»» (Адабиёт, синфи 9, p. 318 (PDF 318), cited as a зарбулмасал) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 83 | Вақт аз тилло қиматтар аст. | not found | — | — — Not in Фозилов vol. I (checked pp. 257–259). | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 84 | Модарашро бину, духтарашро гир. → «Роҳаша бину аспаша гир, Очаша бину духтараша гир.» | **variant** | «Роҳаша бину аспаша гир, / Очаша бину духтараша гир.» — Баёз, ҷ. 2, 1990, p. 92 (PDF 92) (section «Интихоби арӯс») | — — Our text was a standard-orthography paraphrase of the second line. | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed — check: the printed saying also covers choosing a horse; meaning covers the family half only / ed✓ / ed✓ / translit — regenerate |
| 85 | Модар чӣ гуна, духтар намуна. | not found | — | related: «Арӯс (духтар) чӣ гуна? Очаш намуна.» (Баёз, ҷ. 2, 1990, p. 92 (PDF 92)) | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 86 | Ҳуши оча ба бача, ҳуши бача ба кӯча. → «Дили оча ба бача, дили бача ба кӯча.» | **variant** | «Дили оча ба бача, дили бача ба кӯча.» — Асрорӣ 1956, p. 51 (PDF 48) | «Дили оча ба бача, / Дили бача ба кӯча.» (Баёз, ҷ. 2, 1990, p. 98 (PDF 98)) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 87 | Духтарам, ба ту мегӯям; келинам, ту шунав. | exact | «Духтарам, ба ту мегӯям, келинам ту шунав.» — Асрорӣ 1956, p. 53 (PDF 50) | «ДУХТАРАМ, БА ТУ МЕГӮЯМ, КЕЛИНАМ, ТУ ШУНАВ!» (Адабиёт, синфи 5, p. 40 (PDF 40), lesson entry with printed meaning and a signed example) | Асрорӣ 1956 | printed avail. / ed✓ / ed✓ / translit — regenerate |
| 88 | Ба ҷанги зану шавҳар остона хандидааст. → «Ба ҷанги зану шӯй остона механдад.» | **variant** | «Ба ҷанги зану шӯй остона механдад.» — Асрорӣ 1956, p. 40 (PDF 37) | «БА ҶАНГИ ЗАНУ ШӮ ОСТОНАИ ДАРИ ХОНА МЕХАНДАД.» (Фозилов, ҷ. I, 1975, p. 200 (PDF 203), variant) | Фозилов, ҷ. I, 1975 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 89 | Хонаи бехушдоман — майдони бе хошок. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 90 | Фарзанд азиз, одобаш азизтар. | not found | — | related: «Кӯдак азиз аст, адабаш – аз он азизтар.» (Адабиёт, синфи 5, p. 38 (PDF 38)) | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 91 | Ватан аз остона сар мешавад. | not found | — | — — «Фолклори тоҷик» (1954) has no proverb section; not in Фозилов vol. I. | Фолклори тоҷик, 1954 → none found | ed✓ / ed✓ / ed✓ / translit |
| 92 | Хоки Ватан аз тахти Сулаймон беҳ. → «Хоки ватан аз тахти Сулаймон хуштар, Хори ватан аз лолаву райҳон хуштар.» | **variant** | «Хоки ватан аз тахти Сулаймон хуштар, / Хори ватан аз лолаву райҳон хуштар.*» — Баёз, ҷ. 2, 1990, p. 20 (PDF 20) (section «Ватан»; footnote: the opening of a well-known folk rubai) | — | Фозилов, ҷ. I, 1975 → **Баёз, ҷ. 2, 1990** | ed — check: now a two-line saying; meaning still fits / ed✓ / ed✓ / translit — regenerate |
| 93 | Ҷон фидои Ватан. | not found | — | — — «Фолклори тоҷик» (1954) has no proverb section. | Фолклори тоҷик, 1954 → none found | ed✓ / ed✓ / ed✓ / translit |
| 94 | Бе Ватан одам булбули бе чаман аст. → «Шахси беватан — булбули бечаман.» | **variant** | «Шахси беватан—булбули бечаман.» — Асрорӣ 1956, p. 80 (PDF 77) | «Одами беватан — мурдаи бекафан (булбули бечаман).» (Баёз, ҷ. 2, 1990, p. 20 (PDF 20), variant) — Not in Фозилов vol. I (checked p. 204). | Фозилов, ҷ. I, 1975 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 95 | Дӯст дар сафар шинохта мешавад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 96 | Дӯстро дар рӯзи сахт шиносанд. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 97 | Дӯсти нодон аз душмани доно бадтар аст. → «Аз дӯсти нодон душмани доно беҳ.» | **variant** | «Аз дӯсти нодон душмани доно беҳ.» — Асрорӣ 1956, p. 33 (PDF 30) | «Аз дӯсти нодон душмани доно беҳ.» (Баёз, ҷ. 2, 1990, p. 23 (PDF 23)); «АЗ ДӮСТИ НОДОН ДУШМАНИ ДОНО БЕҲ!» (Фозилов, ҷ. I, 1975, p. 69 (PDF 70), main entry with an example by Ҷалол Икромӣ) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 98 | Душмани доно беҳ аз дӯсти нодон. | exact | «ниг. Душмани доно беҳ аз дӯсти нодон.» — Фозилов, ҷ. I, 1975, p. 69 (PDF 70) (cross-reference line under «Аз дӯсти нодон…») | «мук. Душмани доно беҳ аз дӯсти нодон!» (Фозилов, ҷ. I, 1975, p. 144 (PDF 147)); «Душмани доно беҳ аз нодони дӯст. (Саъдии Шерозӣ)» (Баёз, ҷ. 2, 1990, p. 23 (PDF 23), variant, signed) | Фозилов, ҷ. I, 1975 | ed✓ / ed✓ / ed✓ / translit |
| 99 | Дӯст оинаи дӯст аст. | not found | — | related: «Дӯстон оинаи якдигаранд.» (Асрорӣ 1956, p. 53 (PDF 50)) | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 100 | Бо моҳ шинӣ, моҳ шавӣ; бо дег шинӣ, сиёҳ шавӣ. | exact | «Бо моҳ шинӣ, моҳ шавӣ, бо дег шинӣ, сиёҳ шавӣ.» — Асрорӣ 1956, p. 42 (PDF 39) | «БО МОҲ ШИНӢ, МОҲ ШАВӢ, / БО ДЕГ ШИНӢ, СИЁҲ ШАВӢ.» (Фозилов, ҷ. I, 1975, p. 231 (PDF 234), main entry with printed meaning and examples); «Бо моҳ шинӣ, моҳ шавӣ, / Бо дег шинӣ, сиёҳ шавӣ.» (Баёз, ҷ. 2, 1990, p. 30 (PDF 30)); ««Бо моҳ шинӣ моҳ шавӣ, бо дег шинӣ сиёҳ шавӣ»» (Адабиёт, синфи 5, p. 116 (PDF 116), cited as a зарбулмасал) — Punctuation follows Асрорӣ (comma, not semicolon). | Асрорӣ 1956 | printed avail. / ed✓ / ed✓ / translit — regenerate |
| 101 | Ҳамнишинатро гӯй, то туро бишиносам. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 102 | Бо некон нишинӣ, нек шавӣ. | not found | — | related: «БО НЕК НИШИНӢ, НЕК ШАВӢ, БО ДЕГ НИШИНӢ, СИЁҲ.» (Фозилов, ҷ. I, 1975, p. 234 (PDF 237)) | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 103 | Бо бадон нишинӣ, бад шавӣ. | not found | — | related: «АЗ БАДОН БАД ШАВӢ, ЗИ НЕКОН НЕК.» (Фозилов, ҷ. I, 1975, p. 56 (PDF 57)) — Not in Фозилов vol. I (checked pp. 221–223). | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 104 | Некӣ куну ба дарё андоз. → «Некӣ куну ба об андоз!» | **variant** | «НЕКӢ КУНУ БА ОБ АНДОЗ!» — Фозилов 1973, p. 94 (PDF 95) (story title; the story prints the saying) | «Накӯӣ куну дар об андоз.» (Асрорӣ 1956, p. 63 (PDF 60), variant); «Некӣ мекуну дар Даҷла андоз, / Ки эзид дар биёбонат диҳад боз.» (Баёз, ҷ. 2, 1990, p. 30 (PDF 30), variant) | Асрорӣ 1956 → **Фозилов 1973** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 105 | Некӣ бо некӣ ҷавоб дорад. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 106 | Бадӣ кунӣ, бадӣ мебинӣ. | not found | — | related: «Ҳурмат кунӣ, ҳурмат мебинӣ.» (Асрорӣ 1956, p. 87 (PDF 84)) — Not in Фозилов vol. I (checked p. 145). | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 107 | Одами нек аз суханаш маълум. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 108 | Ҳеҷ кас айби худро намебинад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 109 | Ҳеҷ кас думи харашро каҷ намегӯяд. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 110 | Кал агар табиб будӣ, сари худ даво намудӣ. | exact | «мук. Кал агар табиб будӣ, сари худ даво намудӣ.» — Фозилов, ҷ. I, 1975, p. 272 (PDF 275) (cross-reference line under «Гар ба чора пизишк битвонад…») | — | Асрорӣ 1956 → **Фозилов, ҷ. I, 1975** | ed✓ / ed✓ / ed✓ / translit |
| 111 | Айби худ кӯр, айби мардум дурбин. | not found | — | — — Not in Фозилов vol. I (checked pp. 107–108). | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 112 | Чоҳи дигаронро макан, ки худ меафтӣ. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 113 | Дари касеро ба мушт назан, ки даратро бо лагад мезананд. | not found | — | — — Not in Фозилов vol. I (checked pp. 335–336). | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 114 | Як дари баста, сад дари кушода. | exact | «Як дари баста, сад дари кушода.» — Асрорӣ 1956, p. 81 (PDF 78) | «Як дари баста, сад дари кушода.» (Баёз, ҷ. 2, 1990, p. 27 (PDF 27)) | Фозилов, ҷ. I, 1975 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit |
| 115 | Як гулу сад харидор. | exact | «Як гулу сад харидор.» — Баёз, ҷ. 2, 1990, p. 49 (PDF 49) | «Як гулу сад харидор.» (Баёз, ҷ. 2, 1990, p. 10 (PDF 10), introduction) | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit |
| 116 | Як гул баҳор намешавад. → «Бо як гул баҳор намешавад.» | **variant** | «БО (БА) ЯК ГУЛ БАҲОР НАМЕШАВАД.» — Фозилов, ҷ. I, 1975, p. 242 (PDF 245) (main entry with printed meaning and an example by Садриддин Айнӣ) | «Бо як гул баҳор намешавад.» (Асрорӣ 1956, p. 43 (PDF 40)); ««ба як гул баҳор намешавад»» (Адабиёт, синфи 10, p. 257 (PDF 257), variant) | Фозилов, ҷ. I, 1975 | printed avail. / ed✓ / ed✓ / translit — regenerate |
| 117 | Гул бе хор намешавад. | exact | «ГУЛ БЕ ХОР НАМЕШАВАД, (ГӮШТ БЕ УСТУХОН).» — Фозилов, ҷ. I, 1975, p. 289 (PDF 292) (main entry; the second half is optional; printed meaning) | «Гул бе хор намешавад, гӯшт бе устухон.» (Асрорӣ 1956, p. 45 (PDF 42), longer form); «Гул бе хор намешавад, гӯшт бе устухон.» (Баёз, ҷ. 2, 1990, p. 9 (PDF 9), longer form) | Асрорӣ 1956 → **Фозилов, ҷ. I, 1975** | printed avail. / ed✓ / ed✓ / translit |
| 118 | Гул гулро дида мешукуфад. | exact | «Гул гулро дида мешукуфад.» — Асрорӣ 1956, p. 45 (PDF 42) | «ГУЛ ГУЛРО ДИДА МЕШУКУФАД.» (Фозилов, ҷ. I, 1975, p. 291 (PDF 294), cross-reference entry) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 119 | Дарахтро аз мевааш мешиносанд. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 120 | Дарахти пурбор сар хам мекунад. | not found | — | related: «Сари дарахти мевадор хам аст.» (Асрорӣ 1956, p. 71 (PDF 68)); related: «Шохи дарахти мевадор хам аст.» (Баёз, ҷ. 2, 1990, p. 31 (PDF 31)); related: «2. ДАРАХТ ҲАР ЧӢ ПУРБОРТАР АСТ, АФТОДАТАР АСТ.» (Фозилов, ҷ. I, 1975, p. 324 (PDF 327)) | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 121 | Бой аз фарбеҳӣ меноладу камбағал аз лоғарӣ. | exact | «Бой аз фарбеҳӣ меноладу камбағал – аз лоғарӣ.» — Адабиёт, синфи 5, p. 41 (PDF 41) (lesson «Зарбулмасалу мақолҳо») | «Бой аз фарбеҳӣ менолад, камбағал аз лоғарӣ.» (Асрорӣ 1956, p. 42 (PDF 39), variant) — Not in Фозилов vol. I (checked p. 229). | Асрорӣ 1956 → **Адабиёт, синфи 5** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 122 | Қарз гирӣ, ғам мехарӣ. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 123 | Қарздор — ғамдор. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 124 | Қаноат ганҷи бепоён аст. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 125 | Нафси бад балои ҷон аст. → «Нафси бад балои ҷон.» | **variant** | «Зарбулмасали «Нафси бад балои ҷон»» — Адабиёт, синфи 5, p. 294 (PDF 294) (named as a зарбулмасал) | «Нафси бад балои ҷон.» (Асрорӣ 1956, p. 63 (PDF 60)); «Феъли бад — коҳиши ҷон, / Нафси бад — балои ҷон.» (Баёз, ҷ. 2, 1990, p. 61 (PDF 61), variant) | Фозилов, ҷ. I, 1975 → **Адабиёт, синфи 5** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 126 | Ош бе пиёз намешавад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 127 | Нон бошад, ҷон бошад. | not found | — | — | Фолклори тоҷик, 1954 → none found | ed✓ / ed✓ / ed✓ / translit |
| 128 | Нонро хор макун. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 129 | Нони меҳнат ширин аст. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 130 | Меҳмон атои Худост. → «Меҳмон атои Худо, аспаш балои Худо.» | **variant** | «100. Меҳмон атои Худо, аспаш балои Худо.» — Фолклори Роғун, 2017, p. 153 (PDF 153) (section «Зарбулмасал, мақол ва чистонҳо») | «Меҳмон атои худо, / Аспаш балои худо.» (Баёз, ҷ. 2, 1990, p. 102 (PDF 102)); «Меҳмон атои худо, хараш балои худо.» (Асрорӣ 1956, p. 61 (PDF 58), variant) — Our text was the first half only. | Фозилов, ҷ. I, 1975 → **Фолклори Роғун, 2017** | ed — check: meaning covers only the first half; the printed second half («аспаш балои Худо») adds a twist / ed✓ / ed✓ / translit — regenerate |
| 131 | Меҳмон азиз, ҷойаш азизтар. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 132 | Хонаи меҳмондор обод аст. | not found | — | — | Фолклори Роғун, 2017 → none found | ed✓ / ed✓ / ed✓ / translit |
| 133 | Ҳар хона одати худро дорад. | not found | — | — | Диёри Турсунзода, 2012 → none found | ed✓ / ed✓ / ed✓ / translit |
| 134 | Ҳар диёр расми худро дорад. | not found | — | — | Диёри Турсунзода, 2012 → none found | ed✓ / ed✓ / ed✓ / translit |
| 135 | Ба шаҳр рафтӣ, расми шаҳрро гир. | not found | — | — — Not in Фозилов vol. I (checked p. 189). | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 136 | Қарға ба қарға чашм намеканад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 137 | Гургзода оқибат гург шавад. → «Оқибат гургзода гург шавад, Гарчи бо одамӣ бузург шавад.» | **variant** | «Оқибат гургзода гург шавад, / Гарчи бо одамӣ бузург шавад. (Саъдии Шерозӣ)» — Баёз, ҷ. 2, 1990, p. 30 (PDF 30) (signed Саъдӣ) | «12. Оқибат гургзода гург шавад, / Гарчӣ бо одамӣ бузург шавад.» (Диёри Турсунзода, 2012, p. 18 (PDF 11), footnote: a bayt of Саъдӣ that became a proverb); «Оқибат гургзода гург шавад, Гарчи бо одами бузург шавад. (Саъдӣ)» (Асрорӣ 1956, p. 99 (PDF 95), classics section) — A bayt of Саъдӣ used as a proverb; the books print the whole bayt. | Фозилов, ҷ. I, 1975 → **Баёз, ҷ. 2, 1990** | ed — check: now a bayt of Саъдӣ; meaning still fits / ed✓ / ed✓ / translit — regenerate |
| 138 | Саг аккос мезанад, корвон мегузарад. → «Саг меҷағад, корвон мегузарад.» | **variant** | «Саг меҷағад, корвон мегузарад.» — Асрорӣ 1956, p. 71 (PDF 68) | — | Фозилов, ҷ. I, 1975 → **Асрорӣ 1956** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 139 | Саги аккосак газанда нест. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 140 | Аз асп афтӣ, аз асл наафт. | not found | — | — — Not in Фозилов vol. I (checked p. 55). | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 141 | Харро бо зин асп намешавад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 142 | Қурбоққа шӯй дорад, обрӯ дорад. → «Қурбоққа шӯ дорад, обрӯ дорад.» | **variant** | «Қурбоққа шӯ дорад, обрӯ дорад.» — Баёз, ҷ. 2, 1990, p. 95 (PDF 95) (section «Шавҳар») | — | Асрорӣ 1956 → **Баёз, ҷ. 2, 1990** | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 143 | Моҳӣ аз сар бадбӯй мешавад. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 144 | Аз як даст садо намебарояд. | exact | «Аз як даст садо намебарояд.» — Асрорӣ 1956, p. 35 (PDF 32) | «Аз як даст садо намебарояд.» (Баёз, ҷ. 2, 1990, p. 23 (PDF 23)); «АЗ ЯК ДАСТ САДО БАРНАЁЯД (БАРНАМЕХЕЗАД).» (Фозилов, ҷ. I, 1975, p. 101 (PDF 102), variant, main entry) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 145 | Як даст гул намекунад. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 146 | Як тан танҳо ҷанг намекунад. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 147 | Оҳанро дар гармиаш мекӯбанд. | exact | «Оҳанро дар гармиаш мекӯбанд.» — Асрорӣ 1956, p. 68 (PDF 65) | «Оҳанро дар гармиаш мекӯбанд.» (Баёз, ҷ. 2, 1990, p. 7 (PDF 7), introduction) | Асрорӣ 1956 | ed✓ / ed✓ / ed✓ / translit |
| 148 | Кор аз кордон тарсад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 149 | Корро ба кордон супор. | not found | — | — — Variant record of 70. | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 150 | Бо як даст ду тарбуз бардошта намешавад. | exact | «Бо як даст ду тарбуз бардошта намешавад.» — Асрорӣ 1956, p. 43 (PDF 40) | «ниг. Бо як даст ду тарбуз бардошта намешавад.» (Фозилов, ҷ. I, 1975, p. 192 (PDF 195), cross-reference line); «БО (БА) ЯК ДАСТ ДУ ХАРБУЗА (ТАРБУЗ, ҲИНДУВОНА) БАРДОШТА НАМЕШАВАД.» (Фозилов, ҷ. I, 1975, p. 242 (PDF 245), main entry with printed meaning) | Асрорӣ 1956 | printed avail. / ed✓ / ed✓ / translit |
| 151 | Одат балои ҷон аст. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 152 | Одат табиати дуюм аст. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 153 | Дарахтро дар навниҳолӣ рост мекунанд. | not found | — | — — «Фолклори тоҷик» (1954) has no proverb section; not in Фозилов vol. I (checked pp. 323–325). | Фолклори тоҷик, 1954 → none found | ed✓ / ed✓ / ed✓ / translit |
| 154 | Пири корро хор мадор. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 155 | Калонро ҳурмат кун, хурдро иззат. | not found | — | — | Баёз, ҷ. 2, 1990 → none found | ed✓ / ed✓ / ed✓ / translit |
| 156 | Пандро аз душман ҳам шунав. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 157 | Илм ганҷи бебаҳост. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 158 | Илм бе амал — дарахти бе ҳосил. | not found | — | — | Фозилов, ҷ. I, 1975 → none found | ed✓ / ed✓ / ed✓ / translit |
| 159 | Нодонро панд гуфтан — об дар ҳован кӯфтан. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 160 | Ба доно як ишора бас. → «Ба доно як ишорат бас аст.» | **variant** | «БА ДОНО ЯК ИШОРАТ (ИМО) БАС АСТ.» — Фозилов, ҷ. I, 1975, p. 148 (PDF 151) (main entry with an example by Раҳим Ҷалил) | — | Фозилов, ҷ. I, 1975 | ed✓ / ed✓ / ed✓ / translit — regenerate |
| 161 | Кам гӯю бисёр шунав. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 162 | Ҳар сухан ҷое дорад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 163 | Дурӯғ пой надорад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 164 | Офтобро бо доман пӯшида намешавад. | exact | «1. Офтобро бо доман пӯшида намешавад.» — Адабиёт, синфи 5, p. 37 (PDF 37) (lesson «Зарбулмасалу мақолҳо»: printed meanings and examples) | «Офтобро бо доман пӯшида намешавад.» (Асрорӣ 1956, p. 67 (PDF 64)); «Офтобро бо доман пӯшида намешавад.» (Баёз, ҷ. 2, 1990, p. 37 (PDF 37)) | Асрорӣ 1956 → **Адабиёт, синфи 5** | printed avail. / ed✓ / ed✓ / translit |
| 165 | Аввал худро бин, баъд дигаронро. | not found | — | related: «АВВАЛ ГИРЕБОНИ ХУД БИБӮЙ, БАЪД АЙБИ ДИГАРОН БИҶӮЙ!» (Фозилов, ҷ. I, 1975, p. 27 (PDF 28)); related: «Аввал гиребонатро бӯй куну баъд гап зан.» (Баёз, ҷ. 2, 1990, p. 38 (PDF 38)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 166 | Дарахти пурмева сар хам мекунад. | not found | — | related: «Сари дарахти мевадор хам аст.» (Асрорӣ 1956, p. 71 (PDF 68)); related: ««Ниҳад шохи пурмева сар ба замин» (Саъдии Шерозӣ)» (Адабиёт, синфи 5, p. 42 (PDF 42)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 167 | Некӣ кун, некӣ бин. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 168 | Чоҳи касро макан, ки худ меафтӣ. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 169 | Ҳар чӣ киштӣ, ҳамон даравӣ. | not found | — | related: «Ин ҷаҳон киштзори охират аст, / Ҳар чӣ корӣ, бараш ҳамон даравӣ» (Адабиёт, синфи 7, p. 55 (PDF 55)) | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |
| 170 | Дӯст дар рӯзи сахт маълум мешавад. | not found | — | — | Асрорӣ 1956 → none found | ed✓ / ed✓ / ed✓ / translit |

## Textbook proverbs we do not have

The textbooks quote these as зарбулмасал or мақол, or print them in a proverb lesson or list. We have no record for them. Round 6 (see the plan) reads each lead-in and adds those that qualify. Where the book prints several forms, they are listed together.

**Grade 5 (2017), lesson «Зарбулмасалу мақолҳо», pp. 37–42.** The lesson prints meanings and signed usage examples.

| p. | Saying as printed | Printed with it |
|---:|---|---|
| 37 | Панҷ ангушт баробар нест. | explained in the lesson text |
| 37 | Офтобро кас ба доман натавонад пӯшид. / Офтобро пинҳон натавон кард. | numbered forms 2–3 of our ID 164; printed meanings; examples «Аз „Доробнома“», «Аз „Баҳруттаворих“» (p. 38) |
| 38 | Аз одами бекор Худо безор. | cited as a мақол |
| 38 | Намур, бузакам, баҳор мешавад. · Ҷӯянда – ёбанда. · Моҳ бе айб намешавад. · Кӯдак азиз аст, адабаш – аз он азизтар. · Забон донӣ, ҷаҳон донӣ. · Пурсидан айб нест. · Дӯст гӯяд табарвор, душман гӯяд шакарвор. · Аз дӯсти нодон душмани доно беҳтар. · Гап дар калла, на дар салла. | list «Зарбулмасалу мақолҳо» |
| 39 | Он чӣ дар дег аст, ба чумча (кафлез) меояд. | examples «Аз „Маҷмӯъуламсол“» ×2, Абдумалик Баҳорӣ |
| 39 | Дарди кампир – ғӯза. | in the Баҳорӣ example |
| 39–40 | Дили нохоҳам – узри бисёр. | heading, printed meaning, example «Аз „Наводири Зиёия“» |
| 40 | Ё тир мекафад ё ҷувоз. | heading, example Фазлиддин Муҳаммадиев |
| 40 | Моргазида аз ресмони ало метарсад. | heading, printed meaning, verse by Ғании Кашмирӣ, example «Аз „Шарқи сурх“» |
| 41 | Ростгӯйро ҳамеша роҳат дар пеш аст. | heading, example «Аз „Саргузашти Ҳотам“» |
| 41 | Меҳрубониҳои султон – бозии гурба бо мушон. · Хурӯс дар ҳама ҷо як хел ҷеғ мезанад. | list «Чанд намуна» |
| 42 | На сих сӯзад, на кабоб. | heading, printed meaning, Фаридуддини Аттор |
| 42 | Кори шаб – хандаи рӯз. | heading, printed meaning, example Ҷалол Икромӣ |
| 42 | Ниҳад шохи пурмева сар бар замин. | heading, printed meaning, verse by Саъдии Шерозӣ (a poet's line; the team decides) |
| 42 | Чӯҷаро дар тирамоҳ мешуморанд. · Забони мурғонро мурғон медонанд. · Хар ҳамону полонаш дигар. · Кам-кам хӯру доим хӯр. · Сукут аломати ризост. | exercise list |

**Elsewhere.**
- Grade 5:
  - p. 72, «Илоҷи воқеа пеш аз вуқӯъ» and «Гӯр сӯзаду дег ҷӯшад» (exercise «зарбулмасалу мақолҳои зайл»);
  - p. 152, «Намак хӯрда ба намакдон туф накунед» (зарбулмасал);
  - p. 294, «Эрка балои ҷон» (мақоли халқӣ).
- Grade 9:
  - p. 265, «Девона ба кори худ ҳушёр» (зарбулмасали халқӣ);
  - p. 318, «Ҷӯянда – ёбанда», «Дасти ману домони ту» and «То дам аст, ғам аст» (зарбулмасалу мақолҳо).
- Grade 11:
  - p. 157, «Дил дили Зайнаб» (зарбулмасали халқӣ);
  - p. 174, «Хурӯс дар ҳама ҷо як хел садо медиҳад» (зарбулмасал) and «Ба гузашта салавот» (мақол);
  - pp. 233–234, sayings the book says Раҳим Ҷалил used (e.g. «Тоқати меҳмон надошт, хона ба меҳмон гузошт», «Бе шамол шохи дарахт намеҷунбад», «Асои пир ба ҷойи пир», «Бачаи эрка – балои ҷон»);
  - p. 375, «Гандум корӣ, гандум бидравӣ, ҷав корӣ – ҷав».
- Grade 7, p. 107: sayings given as examples of a device («Думи сагат каҷ», «Дами табарро пахта гирифтааст», …). A device example is not a proverb entry; they are listed only for completeness.

## Limits of this audit

- **Unreadable Асрорӣ lines.** Two lines on p. 47 (PDF 44) could not be read, because of bleed-through. p. 34 (PDF 31) was read at low resolution and is used only for related witnesses.
- **Баёз, ҷ. 2** was searched through its text layer, then by word overlap. A saying garbled beyond both could have been missed; only what was found was re-read from the image.
- **Фозилов vol. I** was consulted only at headword positions. A saying printed only inside another entry's examples would not be found.
- **Not found means not found in these books.** It does not mean the saying is not a Tajik proverb.
