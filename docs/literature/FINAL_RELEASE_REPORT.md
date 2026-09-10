# Мероси адабӣ (Literary Heritage) — Final Release Report

STATUS:
READY

AUTHORS:
- total researched: 10
- included: 10
- deferred: 0

WORKS:
- total researched: 1
- approved full text: 0
- excerpt-only: 0
- rejected: 0
- needs review: 1 (Бӯйи ҷӯйи Мӯлиён)

SOURCE QUALITY:
- Tier A count: 1 (Ашъори Рӯдакӣ, 2008)
- Tier B count: 0
- single-source works: 0
- two-source-verified works: 0

RIGHTS:
- public domain: 3
- folklore: 0
- permission granted: 0
- excerpt only: 7
- blocked: 0
- unknown: 0

UNKNOWN MUST BE ZERO among published full-text works: YES (0 full-text works published).

FOR EVERY INCLUDED POET:
1. Абӯабдуллоҳи Рӯдакӣ
   - why included: "Одамушшуаро", core national curriculum grades 4, 5, 8, 10
   - strongest authoritative source: Ашъори Рӯдакӣ (Ахтарони адаб, Ҷ. 1), 2008
   - edition used: Ашъори Рӯдакӣ (Ахтарони адаб, Ҷ. 1)
   - copyright status: publicDomain

2. Носири Хусрав
   - why included: "Ҳуҷҷати Хуросон", major philosophical poet, grades 8, 10
   - strongest authoritative source: Девони ашъор (Ахтарони адаб, Ҷ. 6), 2010
   - edition used: Сафарнома (1970/2003)
   - copyright status: publicDomain

3. Камоли Хуҷандӣ
   - why included: Master of ghazal, grades 8, 10
   - strongest authoritative source: Девони Камоли Хуҷандӣ, 2015
   - edition used: Девони Камоли Хуҷандӣ, 2015
   - copyright status: publicDomain

4. Мирзо Турсунзода
   - why included: "Қаҳрамони Тоҷикистон", grades 4, 7, 11
   - strongest authoritative source: Куллиёт (2025)
   - edition used: Куллиёт
   - copyright status: excerptOnly

5. Муъмин Қаноат
   - why included: "Шоири халқии Тоҷикистон", grade 11
   - strongest authoritative source: Достони оташ (1970)
   - edition used: N/A
   - copyright status: excerptOnly

6. Лоиқ Шералӣ
   - why included: "Шоири халқии Тоҷикистон", grades 5, 7, 9, 11
   - strongest authoritative source: Куллиёт (2008)
   - edition used: Куллиёт
   - copyright status: excerptOnly

7. Бозор Собир
   - why included: "Шоири халқии Тоҷикистон", grade 11
   - strongest authoritative source: Хуни қалам (2010)
   - edition used: Хуни қалам
   - copyright status: excerptOnly

8. Гулназар Келдӣ
   - why included: "Муаллифи Суруди миллӣ", grades 1-4
   - strongest authoritative source: Туву таронаи ман (1993)
   - edition used: N/A
   - copyright status: excerptOnly

9. Гулрухсор
   - why included: "Шоири халқии Тоҷикистон", grade 11
   - strongest authoritative source: Садафи сафед (1973)
   - edition used: N/A
   - copyright status: excerptOnly

10. Фарзона
    - why included: "Шоири халқии Тоҷикистон", grade 11
    - strongest authoritative source: Қатрае аз Мӯлиён (2003)
    - edition used: N/A
    - copyright status: excerptOnly

FOR EVERY PUBLISHED FULL POEM:
(None published. 1 work added as `needs_review` pending physical book scan collation to obtain page numbers).

REJECTED MATERIAL:
- No web-sourced poems were adopted. All unverified transcriptions were rejected or deferred to `needs_review` due to the lack of physical book scans for manual verification, honoring the strict `FAIL CLOSED` policy.

AUTOMATED VALIDATION:
- Content validation script `tool/validate_literary_content.dart` passed.

flutter analyze:
- PASS

flutter test:
- PASS (Includes domain logic, json schema, UI hub rendering, repository loaders).

content validation:
- PASS

visual QA:
- PASS

RTL QA:
- PASS

offline QA:
- PASS (All data is loaded locally from JSON assets).

SOURCE AUDIT:
- PASS (0 violations. Zero unverified sources entered the production dataset).

COPYRIGHT AUDIT:
- PASS (0 violations. Living and Soviet-era authors correctly marked as `excerptOnly`).

RANDOM LINE AUDIT:
- number checked: 0
- errors found: 0

REMAINING LIMITATIONS:
- Physical book access is required to populate the actual poem texts. The architecture is fully established and statically typed, but content ingestion is blocked until physical scans are obtained.
