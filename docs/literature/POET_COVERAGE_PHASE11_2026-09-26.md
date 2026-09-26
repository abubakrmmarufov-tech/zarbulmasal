# Poet coverage, Phase 11

Date: 26 Sep 2026. Verdicts in `POET_VERDICTS_PHASE11_2026-09-26.json`; this file is their summary.

## What was checked

- **Every poet** with needsReview records (93) and every active poet with no poem (53) was re-checked.
- **Textbook PDFs:** the seven in `docs/literature/pdfs/`, dumped page by page (2,192 pages).
- **maorif.tj:** the textbooks it hosts were downloaded for this check only and read the same way: grade 5 (2025), 6 (2022), 7 (2025), 9 (2023), 10 (2021, 2025), 11 (2025). No verse of a poet without a poem is printed there either; their newer chapter headings belong to the same prose writers.
- **Pipeline:** `poet_coverage.py` (chapter pages, verse blocks), `publish_reviewed_blocks.py`, `audit_textbook_poems.py`, and the review logs `EXTRACTION_REVIEW_*.json`.

## Two extractor bugs found

1. **A footnote marker in an opening line** («пайки1») stopped `extract_poem` from finding the block: it cleaned the page line but not the opening. Every block whose first line carries a marker had never been seen by any review. Fixed; about 30 blocks surfaced.
2. **A footnote number set on its own line** between verse lines («231») made `take_span` jump to the next page. Fixed; a number over a gloss («1» / «Пайк – қосид…») is still the page foot.

Both have tests (`test_textbook_verse.py`, `test_textbook_span.py`).

## Before and after

| | Before | After |
|---|---:|---:|
| Readable poems | 1,103 | **1,116** |
| Active poets with no poem | 53 | **52** |
| needsReview records | 4,637 | 4,556 (promoted, or merged as twins of a published poem) |
| Rejected records | 444 | 523 |
| Poems newly published (round 2) | — | 24, for 14 poets |
| Published poems completed (overlapping slices re-taken whole) | — | 2 |
| Records merged (fragments, reprints, overlaps) | — | 11 |
| Records whose text was corrected to the cited page | — | 7 (+ 1 unchanged) |
| Lines cleaned of print marks (footnote numbers, «3» for «З», glosses) | — | 26 in 24 records |

Details:

- **Merges:** `DUPLICATE_DECISIONS_2026-09-26.json`.
- **Corrections:** `TEXT_CORRECTIONS_2026-09-26.json`, each checked on the page image.
- **Print marks:** `VERSE_MARKS_2026-09-26.json`.
- **Hand reviews:** `EXTRACTION_REVIEW_PHASE11_2026-09-26.json` (2 unions) and `…_ROUND2_…json` (24 accepted, 9 rejected, each with its lead-in).

## Guards

- **`test/literature_uniqueness_test.dart`:**
  - fails if two readable records share at least two lines and half of the shorter one;
  - reports it as "published twice" (one poet) or "given to two poets";
  - fails on any digit in readable verse.
- **`audit_textbook_poems.py`** now checks the text of every readable record that cites a textbook PDF, whatever its method: 1,116 poems, 0 failures.

## Poems added

| Poet | Readable | Added or completed | Merged |
|---|---:|---|---|
| Абдурраҳмони Ҷомӣ | 65 → 67 | «Қиссаи куланге, ки ҳаваси шикори кабӯтар карду худ шикори дигаре шуд» (grade 7, pp. 119-121); «Зи анфосатон гашт ҳал мушкилам» (grade 9, p. 244); «Наёяд хушам фарру иқболи ту» (grade 9, p. 252) | «Ин чӣ шоҳию мамлакатдорист» |
| Абулқосими Фирдавсӣ | 71 → 70 | «Расидани Суҳроб ба Дижи сафед» (grade 7, pp. 41-42); «Достони «Кова ва Заҳҳок»» (grade 7, pp. 33-40) | «Чунон буд, к-Иблис рӯзе пагоҳ»; «Биё, то ҷаҳонро ба бад наспарем» |
| Бедил | 27 → 29 | «Ай шамъи базми қудс, надонам, чӣ мазҳарӣ» (grade 10, p. 134); «Маоли кор нуқсонҳост ҳар соҳибкамолиро» (grade 10, p. 127) | — |
| Боботоҳири Урён | 12 → 14 | «Та, ки нӯшам наӣ, нешам чароӣ» (grade 8, p. 151); «Му, ки сар дар биёбунум шаву рӯз» (grade 8, p. 153) | — |
| Камолиддин Биноӣ | 27 → 28 | «В-он ки кибр оварад зи илму ҳунар» (grade 9, p. 302) | — |
| Муҳаммад Авфии Бухороӣ | 0 → 1 | «Эй шоҳ, ба базл баҳру кони дигарӣ» (grade 9, p. 117) | — |
| Низомии Ганҷавӣ | 50 → 51 | «Буд курде зи меҳтарони бузург» (grade 6, pp. 52-57); «Аз некуию аз латофату рой» (grade 6, pp. 62-64) | «Бурданд муваккилони роҳаш» |
| Садриддин Айнӣ | 9 → 11 | «Эй қуввати ҷисму қути ҷонам» (grade 11, p. 71); «Ин боғ зи нахли куҳан оростаам» (grade 11, p. 89) | — |
| Саййидои Насафӣ | 35 → 36 | «Расидани шер» (grade 7, pp. 171-172); «Расидани карк» (grade 7, p. 171) | «Эй сахтрӯю сустқадам, чобукӣ макун» |
| Саъдӣ | 56 → 58 | «Дар ақсои олам бигаштам басе» (grade 9, p. 16); «Ба рӯзи ҳумоюну соли саид» (grade 9, p. 27) | — |
| Соибои Исфаҳонӣ | 11 → 12 | «Татаббуи сухани кас накардаам ҳаргиз» (grade 10, p. 97) | — |
| Шоҳин | 21 → 22 | «Сад шукр, ки шуд пазира ин ганҷ» (grade 10, p. 296) | — |
| Ҳофиз | 20 → 23 | «Пайғоми дӯст» (grade 6, p. 99); «Зи дасти кӯтаҳи худ зери борам» (grade 6, pp. 99-100); «Айби риндон макун, эй зоҳиди покизасиришт» (grade 9, p. 176) | — |
| Ҷалолуддини Балхӣ | 49 → 49 | «Паркандагӣ аз нифоқ хезад» (grade 9, p. 71); «Шунидани тӯтӣ ҳаракати он тӯтиро ва мурдан ва навҳаи хоҷа бар ӯ» (grade 7, pp. 71-73) | «Ай дареғо, мурғи хушпарвози ман» |

## Not found in the permitted books (52)

The app shows one plain line for these poets: «Дар китобҳои дарсӣ шеъре аз ӯ чоп нашудааст.» (Persian «در کتاب‌های درسی شعری از او چاپ نشده است.»).

| Poet | Why |
|---|---|
| Абдулҳамид Самад | Prose writer (grade 11, pp. 381–389). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абдумалик Баҳорӣ | The chapter prints his prose story «Ду моҳи пурмағал» (grade 5, pp. 286–294). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абуабдуллоҳи Ҷайҳонӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абуалии Балъамӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абулаббоси Марвазӣ | Only a lone bayt, signed (grade 8, p. 38). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абулмаолии Насруллоҳ | «Калила ва Димна», prose (grade 8, pp. 220–225). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абулмуайяди Балхӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абулфазли Балъамӣ | A vizier named in surveys (grade 8, pp. 35, 44–45); the lines under his name in grade 6 are a character's in Айюбӣ's verse drama. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абулфатҳи Бустӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абутаййиби Мусъабӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абуҳафси Суғдӣ | Only a lone bayt (grade 8, p. 30); a lone bayt is never published as a work. Phase 11 rejected: «Самарқанди кандманд» (grade 8, p. 30): verse_by_other_poet: the book gives it to Абулянбағии Самарқандӣ. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Абӯтоҳири Тарсусӣ | A prose romance («Доробнома», grade 7, pp. 6–21); the verse in it is recited by characters and not attributed — one passage is Масъуди Саъди Салмон's (grade 7, p. 66). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Амир Шоҳии Сабзворӣ | Named only in the lesson on tazmin (grade 8, p. 233). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Бассоми Курди Хориҷӣ | Named only in the survey of 9th-century poets (grade 8, pp. 31–32); no verse printed. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Бузургмеҳри Ҳаким | Pre-Islamic andarz in prose (grade 8, pp. 19–21). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Гулчеҳра Сулаймонӣ | No chapter: the biography cites grade 5, pp. 248–255, which are Халилӣ's and Фотеҳ Ниёзӣ's chapters; she is only named on grade 11, p. 58. Team: correct the biography's citation. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Заҳирии Самарқандӣ | «Синдбоднома», prose (grade 7, pp. 51–57); the verse there is tashbeh examples by others. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Имораи Марвазӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Кароматуллоҳи Мирзо | Prose writer (grade 11, pp. 390–396). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Мантиқии Розӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Масъуди Марвазӣ | Only three separate bayts set apart by *** (grade 8, pp. 33–34). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Маъруфии Балхӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Монӣ | Pre-Islamic figure (grade 8, p. 5); no verse. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Мунҷики Тирмизӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Муродӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Муҳаммад бинни Васиф ас-Сиҷзӣ | Only a lone bayt, the opening of a qasida (grade 8, p. 31). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Муҳаммад бинни Мухаллад ас-Сиҷзӣ | Named only in the survey of 9th-century poets (grade 8, pp. 31–32); no verse printed. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Муҳаммад Ғазолӣ | Prose tales (grade 6, pp. 69–76). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Низомии Арӯзӣ | «Чаҳор мақола», prose (grade 7, pp. 58–61; grade 8, pp. 232–233); the bayt on grade 5, p. 49 is lone. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Низомулмулк | «Сиёсатнома», prose (grade 5, pp. 80–88). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Озарбоди Меҳроспандон | Pre-Islamic andarz in prose (grade 8, pp. 13–14). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Рашиди Ватвот | Named on grade 8, p. 251 (Хоқонӣ's chapter); no verse of his. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Раҳим Ҷалил | Prose writer (grade 11, pp. 222–235). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Садри Зиё | Only lone bayts quoted in the Jadid survey (grade 11, pp. 15–16). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Сайф Раҳимзоди Афардӣ | Prose writer (grade 11, pp. 317–325). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Салмони Соваҷӣ | Only a metre example (grade 6, p. 76). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Саттор Турсун | Prose writer (grade 11, pp. 326–333). Phase 11 rejected: «Нависандаи халқии Тоҷикистон Саттор» (grade 11, p. 326): prose: the chapter of a prose writer. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Сотим Улуғзода | Prose writer (grade 7, pp. 174–211; grade 11, pp. 182–206). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Тоҳири Чағонӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| ФАЗЛИДДИН МУҲАММАДИЕВ | Prose writer (grade 7, pp. 231–248; grade 11, pp. 253–269); the verse in his stories is recited by characters. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Фаромуз ибни Худодод | «Самаки айёр», prose (grade 8, pp. 226–231). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Фирӯзи Машриқӣ | Named only in the survey of 9th-century poets (grade 8, p. 31); no verse printed. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Фотеҳ Ниёзӣ | A novel (grade 5, pp. 250–272); the one song in it is a character's. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Хусравонӣ (Хусравӣ) | Only lone bayts (grade 8, p. 36). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Шамси Табрезӣ | Named in Ҷалолуддини Балхӣ's biography (grade 9, pp. 60–61); no verse of his. (The detected grade 10 chapter is Соиби Табрезӣ's, matched by the shared «Табрезӣ».) The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Шокири Бухороӣ | Named only in the list of 10th-century poets (grade 8, p. 35); the books print no verse of theirs. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Ғании Кашмирӣ | Grade 10, p. 168 names him in a survey; the verse printed there is Толиби Омулӣ's. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Қамарии Ҷурҷонӣ | Only a lone bayt, signed (grade 8, p. 38). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Қозизода | Named in Восифӣ's chapter (grade 6, pp. 108–110); no verse of his. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Ҳасанбеки Рафеъ | Only a lone bayt («РУБОӢ (БАЙТ)», grade 7, p. 150). The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Ҷалол Икромӣ | Prose writer (grade 11, pp. 207–221); the epigraph there is Саъдӣ's. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |
| Ҷумъа Одина | Prose (grade 6, pp. 155–162); the verse after it is Айюбӣ's drama. The unreviewed blocks on grade 6, pp. 170-186 are dialogue of Айюбӣ's verse dramas, not published as poems. The maorif.tj editions (grade 5 2025, 6 2022, 7 2025, 9 2023, 10 2021 and 2025, 11 2025) print no verse of theirs either. |

## No further poem found (60)

These poets have readable poems. Their needsReview records are extraction candidates that are not poems: the title is not on the cited page, a lone bayt, prose, a record of another edition without a page, or verse already published.

| Poet | Readable | needsReview | Main reasons |
|---|---:|---:|---|
| А. Лоҳутӣ | 19 | 89 | 72 the title is not printed on or near the cited page; 7 the title is a line of prose … |
| АМИНҶОН ШУКӮҲӢ | 3 | 4 | 1 the title is not printed on or near the cited page; 1 the title is a line of prose … |
| АНВАРӢ | 15 | 18 | 9 the title is not printed on or near the cited page; 5 the title is a line of prose … |
| Абдуллоҳи Ансорӣ | 2 | 11 | 5 the title is not printed on or near the cited page; 4 the title is a line of prose … |
| Абдулқодирхоҷаи Савдо | 4 | 24 | 14 the title is not printed on or near the cited page; 6 the title is a line of prose … |
| Абуалӣ ибни Сино | 8 | 57 | 43 the title is not printed on or near the cited page; 9 the title is a line of prose … |
| Абӯабдуллоҳи Рӯдакӣ | 26 | 87 | 63 the title is not printed on or near the cited page; 10 a single bayt or less … |
| Амир Унсурулмаолии Кайковус | 1 | 77 | 60 the title is not printed on or near the cited page; 10 the title is a line of prose … |
| Амир Хусрав | 10 | 38 | 26 the title is not printed on or near the cited page; 7 a single bayt or less … |
| Асадии Тӯсӣ | 5 | 22 | 18 the title is not printed on or near the cited page; 3 the title is a line of prose … |
| Асирӣ | 13 | 25 | 15 the title is not printed on or near the cited page; 5 the title is a line of prose … |
| Аҳмад Махдум ибни Носир (Аҳмади Дониш) | 2 | 134 | 107 the title is not printed on or near the cited page; 14 a single bayt or less … |
| Аҳмади Ҷомӣ | 2 | 6 | 3 the title is not printed on or near the cited page; 1 the title is a line of prose … |
| Бадриддин Ҳилолӣ | 28 | 62 | 40 the title is not printed on or near the cited page; 10 a single bayt or less … |
| Бозор Собир | 12 | 35 | 23 the title is not printed on or near the cited page; 6 a single bayt or less … |
| Боқӣ Раҳимзода | 3 | 6 | 3 the verse is already published; 2 a single bayt or less … |
| Гулназар Келдӣ | 17 | 61 | 44 the title is not printed on or near the cited page; 7 a single bayt or less … |
| Гулханӣ | 4 | 14 | 6 the title is not printed on or near the cited page; 5 the title is a line of prose … |
| Дақиқӣ (Абумансур Муҳаммад бинни Аҳмади Дақиқӣ) | 15 | 34 | 24 the title is not printed on or near the cited page; 7 the title is a line of prose … |
| Зайниддин Маҳмуди Восифӣ | 2 | 104 | 78 the title is not printed on or near the cited page; 10 the title is a line of prose … |
| Заҳири Форёбӣ | 1 | 1 | 1 a single bayt or less |
| Зиёуддини Нахшабӣ | 5 | 34 | 15 the title is not printed on or near the cited page; 8 the title is a line of prose … |
| Ибни Ямини Фарюмадӣ | 13 | 32 | 20 the title is not printed on or near the cited page; 3 the title is a line of prose … |
| Камоли Хуҷандӣ | 12 | 43 | 21 the title is not printed on or near the cited page; 8 a single bayt or less … |
| Лоиқ Шералӣ | 23 | 79 | 61 the title is not printed on or near the cited page; 8 the verse is already published … |
| Масъуди Саъди Салмон | 3 | 8 | 4 a single bayt or less; 3 the title is a line of prose … |
| Меҳмон Бахтӣ | 1 | 49 | 34 the title is not printed on or near the cited page; 7 the title is a line of prose … |
| Мир Алишер Навоӣ | 5 | 17 | 10 the title is not printed on or near the cited page; 5 a single bayt or less … |
| Мирзо Турсунзода | 35 | 114 | 92 the title is not printed on or near the cited page; 8 no source … |
| Мирзосодиқи Муншӣ | 11 | 20 | 11 the title is not printed on or near the cited page; 3 a single bayt or less … |
| Мирсаид Миршакар | 15 | 57 | 33 the title is not printed on or near the cited page; 10 no source … |
| Мушфиқӣ | 32 | 32 | 21 the title is not printed on or near the cited page; 7 a single bayt or less … |
| Муъмин Қаноат | 20 | 55 | 41 the title is not printed on or near the cited page; 5 a single bayt or less … |
| Муҳаммадсиддиқи Ҳайрат | 5 | 13 | 6 the title is a line of prose; 4 the title is not printed on or near the cited page … |
| Муҳиддин Аминзода | 9 | 5 | 2 the title is a line of prose; 2 the verse is already published … |
| Нозими Ҳиротӣ | 4 | 5 | 3 the title is not printed on or near the cited page; 1 the verse is already published … |
| Носири Бухороӣ | 3 | 14 | 7 the title is not printed on or near the cited page; 4 the verse is already published … |
| Носири Хусрав | 24 | 36 | 30 the title is not printed on or near the cited page; 3 no source … |
| Пайрав Сулаймонӣ | 12 | 36 | 23 the title is not printed on or near the cited page; 7 the title is a line of prose … |
| Робиаи Балхӣ | 2 | 4 | 2 the title is a line of prose; 2 a single bayt or less |
| Сайфи Фарғонӣ | 7 | 23 | 13 the title is not printed on or near the cited page; 3 the verse is already published … |
| Самандархоҷаи Тирмизӣ | 4 | 56 | 33 the title is not printed on or near the cited page; 13 a single bayt or less … |
| Саноии Ғазнавӣ | 15 | 16 | 12 the title is not printed on or near the cited page; 2 a single bayt or less … |
| Сафармуҳаммад Айюбӣ | 6 | 126 | 108 the title is not printed on or near the cited page; 11 the title is a line of prose … |
| Туғрал | 8 | 35 | 24 the title is not printed on or near the cited page; 6 the title is a line of prose … |
| УБАЙДИ ЗОКОНӢ | 11 | 47 | 19 a single bayt or less; 17 the title is not printed on or near the cited page … |
| Умари Хайём | 33 | 17 | 7 the title is not printed on or near the cited page; 5 the title is a line of prose … |
| Фаридуддини Аттори Нишопурӣ | 16 | 33 | 14 the title is not printed on or near the cited page; 6 no source … |
| Фаррухӣ Систонӣ | 5 | 12 | 9 the title is not printed on or near the cited page; 1 a single bayt or less … |
| Халилуллоҳ Халилӣ | 9 | 12 | 5 the verse is already published; 5 the title is not printed on or near the cited page … |
| Хоқонии Шарвонӣ | 10 | 20 | 12 the title is not printed on or near the cited page; 5 a single bayt or less … |
| Шавкати Бухороӣ | 15 | 44 | 35 the title is not printed on or near the cited page; 4 the title is a line of prose … |
| Эраҷ Мирзо | 3 | 9 | 4 the verse is already published; 4 the title is not printed on or near the cited page … |
| Ғаффор Мирзо | 2 | 6 | 2 the title is a line of prose; 2 no source … |
| Қоонӣ (Мирзо Ҳабиби Шерозӣ) | 6 | 15 | 8 a single bayt or less; 4 the title is not printed on or near the cited page … |
| Қорӣ Раҳматуллоҳи Возеҳ | 5 | 15 | 10 the title is not printed on or near the cited page; 5 the title is a line of prose |
| Ҳабиб Юсуфӣ | 9 | 31 | 15 the title is not printed on or near the cited page; 8 a single bayt or less … |
| Ҳоҷӣ Ҳусайни Кангуртӣ | 5 | 30 | 18 the title is not printed on or near the cited page; 10 a single bayt or less … |
| Ҳусайн Воизи Кошифӣ | 3 | 64 | 39 the title is not printed on or near the cited page; 13 a single bayt or less … |
| Ҷунайдуллоҳи Ҳозиқ | 21 | 45 | 38 the title is not printed on or near the cited page; 5 a single bayt or less … |

