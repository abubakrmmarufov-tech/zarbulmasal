# Literary Heritage Source Hierarchy & Text Verification Policy (SOURCE_POLICY)

**Feature**: Мероси адабӣ (Literary Heritage)  
**Project**: Zarbulmasal (Зарбулмасал)  
**Status**: Active Governance Document  
**Version**: 1.0.0  
**Effective Date**: 2026-09-10  

---

## 1. Editorial Vision & Core Philological Principles

The **Мероси адабӣ (Literary Heritage)** feature of the Zarbulmasal application brings classical and modern Tajik literature to users worldwide. Classical Persian-Tajik poetry represents an unbroken millennium of poetic excellence, while 20th- and 21st-century Tajik literature captures national identity, independence, and cultural rebirth.

Because Zarbulmasal serves as an educational and cultural reference, accuracy and philological integrity are paramount. Digital editions frequently suffer from transcription errors, misplaced hemistichs (misra'), invented rhymes, unauthorized modernizations, and conflated variants.

### Absolute Editorial Rules

1. **Zero Artificial Generation**: NEVER generate, hallucinate, invent, extrapolate, or computationally reconstruct literary verses or stanzas. If a hemistich or poem is incomplete in canonical records, it must remain incomplete or omitted.
2. **Empty Initial State**: All newly created poem records in data schemas must initialize with poem text fields as `null` or empty string `""`, accompanied by `"text_status": "needs_review"`, until dual-witness human verification is completed and logged.
3. **Mandatory Sourcing for Biographies**: Every biographical fact, date, birthplace, career milestone, and award must carry explicit Tier A or Tier B bibliographic citations.
4. **Jurisdictional Copyright Gate**: No text may be ingested or displayed without legal clearance under the copyright laws of the Republic of Tajikistan (see `RIGHTS_POLICY.md`).

---

## 2. Source Hierarchy

All textual material, biographical data, and bibliographic metadata must originate from verified sources categorized into the following four tiers.

```
┌────────────────────────────────────────────────────────┐
│  TIER A: Authoritative Canonical & Academic Editions   │
│  (State Academic Presses, Ministries, Academy, Textbooks)│
└───────────────────────────┬────────────────────────────┘
                            │ (Gold Standard)
┌───────────────────────────▼────────────────────────────┐
│  TIER B: Verified Academic Repositories & Scans        │
│  (Ravshanfikr, University Repositories, Journals)       │
└───────────────────────────┬────────────────────────────┘
                            │ (Bibliographic Metadata Only)
┌───────────────────────────▼────────────────────────────┐
│  TIER C: Discovery & Bibliographical Catalogues         │
│  (National Library OPAC, WorldCat, Google Books Meta)   │
└────────────────────────────────────────────────────────┘
                            ▲
                            │ [STRICTLY REJECTED]
┌───────────────────────────┴────────────────────────────┐
│  PROHIBITED SOURCES:                                   │
│  Social Media, Blogs, OCR Dumps, AI Output, Wikis      │
└────────────────────────────────────────────────────────┘
```

### Tier A — Authoritative Canonical & Academic Editions (Primary Source)
Tier A sources represent the highest level of scholarly and state authority in the Republic of Tajikistan. Only Tier A editions can serve as the primary witness for a published canonical text.

Eligible Tier A entities and imprints:
- **State Academic Publishing Houses**:
  - **Адиб (Adib)**: The official state literary publishing house, specifically editions in the 50-volume canonical series *«Ахтарони адаб» (Stars of Literature)*.
  - **Дониш (Donish)**: Publishing house of the National Academy of Sciences of Tajikistan.
  - **Ирфон (Irfon)**: State publisher of classical literature, philosophy, and scholarly monographs.
  - **Ношир (Noshir)**: Leading regional/jubilee publisher responsible for anniversary editions (e.g., Kamol Khujandi 700th jubilee).
  - **Маориф (Maorif)**: State educational publisher responsible for curriculum literature.
- **State Institutional Authorities**:
  - **Academy of Sciences of Tajikistan (Академияи миллии илмҳои Тоҷикистон)**:
    - Institute of Language and Literature named after Rudaki (Институти забон ва адабиёти ба номи А. Рӯдакӣ).
  - **National Library of Tajikistan (Китобхонаи миллии Тоҷикистон)**: Special collections, manuscript department critical editions, and official anthologies.
  - **Ministry of Education and Science of the Republic of Tajikistan (Вазорати маориф ва илми Ҷумҳурии Тоҷикистон)**: Approved national curriculum textbooks (*Хониши адабӣ*, *Адабиёти тоҷик* for Grades 4 through 11).
  - **Ministry of Culture of the Republic of Tajikistan (Вазорати фарҳанги Ҷумҳурии Тоҷикистон)**: Official cultural anthologies and state jubilees.

### Tier B — Scholarly Repositories & Verified Academic Scans (Secondary Witness)
Tier B sources provide supplementary witnesses, academic journal analyses, or digital scans of out-of-print books.

Eligible Tier B sources:
- **Ravshanfikr (Равшанфикр)**: Scholarly portal repository (`ravshanfikr.tj`) hosting curated scientific and literary materials.
- **University Digital Repositories**: Tajik National University (ДМТ), Khujand State University (ДДХ), and affiliated academic libraries.
- **Scholarly Literary Journals**:
  - *Садои Шарқ (Sadoi Sharq)* — organ of the Union of Writers of Tajikistan.
  - *Паёми Донишгоҳи миллӣ (Bulletin of the National University)*.
  - *Адаб (Adab)*.
- **High-Resolution Physical Library Scans**: Complete book scans provided by university or state library archives.

> [!IMPORTANT]
> **Mandatory Print Edition Traceability**: A Tier B scan or digital reprint is valid IF AND ONLY IF it explicitly documents the physical book's title, publishing house, city of publication, year of print, and page numbers. Digital files lacking complete bibliographic imprints are automatically downgraded to Prohibited.

### Tier C — Bibliographical Discovery Catalogues (Metadata Only)
Tier C sources are restricted strictly to verifying bibliographic metadata (e.g., confirming publisher names, publication years, ISBN, volume structure, editor credits).

Eligible Tier C sources:
- Electronic catalogues (OPAC) of the National Library of Tajikistan.
- Russian State Library (РГБ) and National Library of Russia (РНБ) oriental collections.
- WorldCat, Library of Congress, and Karlsruhe Virtual Catalog.
- Google Books metadata records.

> [!WARNING]
> **Strict Restriction**: Tier C sources MUST NEVER be used as the text witness for poetry lines or stanzas. They serve solely for bibliographic verification.

### Prohibited Sources (Strictly Banned)
Under no circumstances may the following sources be cited, consulted for text collation, or used in Zarbulmasal:
- **Social Media**: Instagram, TikTok, Facebook, Telegram channels/groups, Pinterest, YouTube descriptions or captions, VKontakte, X/Twitter.
- **Personal & Hobbyist Websites**: Unvetted blogs, personal Medium/Teletype posts, web forums, lyric websites, amateur poetry archives.
- **Unsourced PDFs & Documents**: Files found via generic web searches without title pages, colophons, or publishing house details.
- **Generative AI & LLMs**: Text completions, translations, or synthetic verses produced by ChatGPT, Claude, Gemini, or any computational language model.
- **Crowdsourced Wikis**: Wikipedia, Wikiquote, Wikibooks, or other user-edited wikis (may only be used for informal background leads, never cited or used for text extraction).
- **Unverified OCR Dumps**: Bulk machine-read outputs that lack side-by-side line verification against physical printed scans.

---

## 3. Text Verification & Collation Protocols

### The Two-Source Rule (Dual-Witness Standard)
To eliminate typographical errors and spurious editorial alterations:
1. Every full poem or multi-bayt excerpt admitted to the catalog must ideally be collated against **two independent book-based witnesses** (e.g., the *Ахтарони адаб* series edition plus the author's scholarly *Куллиёт* or a Ministry of Education textbook).
2. If only one Tier A witness exists (e.g., unique critical edition of a rare classical fragment), the entry must explicitly note `witness_count: 1` with full volume and page numbers, and undergo dual-peer sign-off.
3. When both witnesses match line-for-line, diacritic-for-diacritic, the text achieves `text_status: "verified"`.

### Optical Character Recognition (OCR) Policy
OCR technology frequently misinterprets Tajik Cyrillic diacritics (e.g., confusing `Ғ/Г`, `Ӯ/У`, `Ӣ/И`, `Ҳ/Х`, `Ҷ/Ч`) and Persian Arabic script (e.g., missing dots in `پ`, `چ`, `ژ`, `گ` or confusing `ی` and `ي`).
- **Initial Classification**: Raw OCR output is categorized as **UNVERIFIED SCRATCH DATA**.
- **Line-by-Line Proofreading**: An editor must compare every hemistich manually against the high-resolution scanned page image.
- **Diacritic Audit**: All six specific Tajik Cyrillic letters (`ғ, ӣ, қ, ӯ, ҳ, ҷ`) and Persian orthographic markers (tanwin, tashdid, silent vav, he-ye ezāfe) must be verified individually.

### Text Collation & Variant Policy
Classical Persian-Tajik literature has survived through diverse manuscript traditions, resulting in legitimate variants (*нусхабадалҳо*) across authoritative critical editions.
- **No Silent Merging**: Editors must NEVER arbitrarily merge, stitch together, or homogenize lines from different editions to create a synthetic composite text.
- **Base Witness Selection**: For each poet, a primary Base Witness edition is selected (e.g., *Девони Рӯдакӣ*, ed. Q. Rustam, Adib, 2015).
- **Variant Logging**: Where another Tier A edition (e.g., *Осори Рӯдакӣ*, ed. A. Mirzoev, 1958) presents a variant reading, the variant must be documented in a dedicated Variant Report with line number, base reading, variant reading, and edition citation.
- **Editorial Conservatism**: When in doubt, the reading from the most recent peer-reviewed academy edition (Дониш / Адиб) takes precedence.

---

## 4. Verification Workflow

```
[Candidate Poem / Excerpt Identified]
                  │
                  ▼
       [Check Rights Gate] ──(Protected / No Rights)──► [Log in REJECTED_MATERIAL.md]
                  │ (Public Domain / Permitted)
                  ▼
    [Locate Tier A / B Witness 1] ──(Unavailable)──► [Halt: Hold in Backlog]
                  │ (Print scan secured)
                  ▼
    [Locate Tier A / B Witness 2]
                  │
                  ▼
  [Line-by-Line Manual Collation]
  - Cyrillic diacritics (ғ, ӣ, қ, ӯ, ҳ, ҷ)
  - Persian Arabic orthography & metre
  - Punctuation & line numbering
                  │
                  ├───(Discrepancies found)──► [Draft Variant Note]
                  │
                  ▼
   [Populate Verification Checklist]
                  │
                  ▼
  [Update Status: "needs_review" -> "verified"]
```

---

## 5. Summary Table of Source Validity

| Source Type | Permitted For Poem Text | Permitted For Metadata | Permitted For Biography | Minimum Requirement |
|:---|:---:|:---:|:---:|:---|
| **Tier A (Adib, Donish, Irfon, Noshir, Maorif)** | **YES** | **YES** | **YES** | Full citation (Book, Year, Page) |
| **Tier B (Ravshanfikr, University, Journals)** | **YES** (as 2nd witness) | **YES** | **YES** | Provenance to printed book scan |
| **Tier C (National Library OPAC, WorldCat)** | **NO** | **YES** | **NO** | Bibliographic reference check |
| **OCR Output (Unedited)** | **NO** | **NO** | **NO** | Must undergo manual line audit |
| **Social Media / Telegram / Blogs** | **NO** | **NO** | **NO** | Automatically rejected |
| **Generative AI / LLM Output** | **NO** | **NO** | **NO** | Automatically rejected |

---

*This policy is strictly enforced across all data ingestion and code updates for the Zarbulmasal Literary Heritage module.*
