# Literary Heritage Intellectual Property & Rights Policy (RIGHTS_POLICY)

**Feature**: Мероси адабӣ (Literary Heritage)  
**Project**: Zarbulmasal (Зарбулмасал)  
**Status**: Active Governance Document  
**Version**: 1.0.0  
**Effective Date**: 2026-09-10  

---

## 1. Statutory Framework

All content published within the **Мероси адабӣ (Literary Heritage)** module of Zarbulmasal is governed strictly by the intellectual property laws of the Republic of Tajikistan and relevant international treaties (including the Berne Convention for the Protection of Literary and Artistic Works).

### Key Legislative Provisions (Law of the Republic of Tajikistan No. 726 "On Copyright and Related Rights")

1. **Article 17 — Term of Copyright Protection (50 Years Post Mortem Auctoris)**:
   - Economic copyright remains in force for the lifetime of the author and **50 years** following their death (*post mortem auctoris* / p.m.a.).
   - The term begins on **January 1 of the year following the year of the author's death** and runs until December 31 of the 50th year.
   - Upon expiry of this term, the work enters the Public Domain (*моликияти ҷамъиятӣ*).

2. **Article 8 — Works Not Subject to Copyright**:
   - Official state symbols and signs (national anthem, national flag, coat of arms, currency notes, heraldry).
   - Official state documents (laws, court rulings, decrees) and their official translations.
   - Works of folklore (*эҷодиёти даҳонакии халқ*) without an identifiable author.

3. **Article 18 — Free Use of Works with Attribution (Educational Excerpts / Fair Use)**:
   - Permitted without the consent of the author and without remuneration, but with mandatory attribution of the author's name and the source used:
     - Quotation in the original language and in translation for scientific, research, polemical, critical, and educational purposes to the extent justified by the intended purpose.
     - Use of short literary excerpts as illustrations in educational publications and educational software.

---

## 2. Fundamental Copyright Rules & Myths

> [!CAUTION]
> **The "Downloadable PDF" Fallacy**: The fact that a digitized book, PDF, or document is freely accessible or downloadable on a public website, telegram channel, or university server does **NOT** constitute a grant of republication, redistribution, or app-embedding rights. Scanning or uploading an in-copyright book without explicit license does not place it in the public domain.

> [!IMPORTANT]
> **Protection of Moral Rights**: Even when a work is in the Public Domain under Article 17, the author's moral rights (*ҳуқуқҳои шахсии ғайримолумулкӣ*) — including the right of attribution (*ҳуқуқи муаллифӣ*) and the right to integrity of the work (*ҳуқуқ ба дахлнопазирии асар*) — are perpetual. Texts must never be corrupted, altered, or misattributed.

---

## 3. Standard Rights Statuses

Every literary entry in the catalog must be tagged with exactly one of the six standardized rights statuses.

| Status Enum | Full Text Eligible | Excerpt Permitted | Description & Application |
|:---|:---:|:---:|:---|
| `PUBLIC_DOMAIN` | **YES** | **YES** | Authors deceased 50+ calendar years ago (prior to Jan 1 of the 51st year) or unauthored folklore. Full poems, ghazals, and masnavis may be published once text-verified. |
| `PERMISSION_GRANTED` | **YES** | **YES** | Protected works for which explicit, documented written permission or licensing has been obtained from the copyright holder or estate. |
| `EXCERPT_ONLY` | **NO** | **YES** | In-copyright authors (living or deceased < 50 years). Only brief educational quotations (1–2 bayts, maximum 4 lines) with source attribution are allowed under Art. 18. |
| `FOLKLORE` | **YES** | **YES** | Anonymous traditional folklore, proverbs, rubaiyat-e khalqi, and oral tales without individual authorship under Article 8. |
| `BLOCKED` | **NO** | **NO** | Content legally contested, subject to takedown notice, questionable attribution, or active dispute. Strictly excluded from the app. |
| `UNKNOWN` | **NO** | **NO** | Works whose author, year of death, or copyright status has not yet been conclusively verified. Never publishable. |

> [!CRITICAL]
> Under no circumstances may an entry with status `UNKNOWN` or `BLOCKED` be displayed to end users. The database query filters must enforce:
> `WHERE rights_status IN ('PUBLIC_DOMAIN', 'PERMISSION_GRANTED', 'EXCERPT_ONLY', 'FOLKLORE')` and exclude unverified full texts.

---

## 4. Protected Authors: The "Metadata-First" Enclosure Rule

For modern, contemporary, or protected authors whose works carry `EXCERPT_ONLY` status:
- **What MAY be published in Zarbulmasal**:
  1. Full biographical profile and critical synthesis (written in original words with Tier A/B citations).
  2. Complete bibliography and list of published collections.
  3. Titles of major works, poem titles, and dates of publication.
  4. Photographic cover images of published books (for bibliographical representation under educational reporting).
  5. Short educational excerpts (strictly limited to 1–2 bayts or up to 4 lines) illustrating their poetic style, with precise book title, publisher, and page attribution.
  6. External links and library catalogue references directing users to official editions and physical libraries.
- **What MUST NEVER be published**:
  - Full-length poems, ghazals, qasidas, dāstāns, or complete poem stanzas exceeding educational excerpt thresholds without explicit written licensing.

---

## 5. Author Clearance Registry (Current Target Authors)

The following table provides the exact copyright determination for the 10 selected poets in the Zarbulmasal collection:

| Poet | Lifespan | Protection Expiry Date | Rights Status | Full Text Allowed? |
|:---|:---|:---|:---:|:---:|
| **Абӯабдуллоҳи Рӯдакӣ** | c. 858 – c. 940/941 | Expired (~1,000+ years ago) | `PUBLIC_DOMAIN` | **YES** |
| **Носири Хусрав** | 1004 – c. 1077–1088 | Expired (~930+ years ago) | `PUBLIC_DOMAIN` | **YES** |
| **Камоли Хуҷандӣ** | c. 1320 – c. 1400 | Expired (~620+ years ago) | `PUBLIC_DOMAIN` | **YES** |
| **Мирзо Турсунзода** | 1911 – Sept 24, 1977 | **December 31, 2027** | `EXCERPT_ONLY` | **NO** (Excerpts only until Jan 1, 2028) |
| **Муъмин Қаноат** | 1932 – May 18, 2018 | **December 31, 2068** | `EXCERPT_ONLY` | **NO** (Excerpts only) |
| **Лоиқ Шералӣ** | 1941 – June 30, 2000 | **December 31, 2050** | `EXCERPT_ONLY` | **NO** (Excerpts only) |
| **Бозор Собир** | 1939 – May 1, 2018 | **December 31, 2068** | `EXCERPT_ONLY` | **NO** (Excerpts only) |
| **Гулназар Келдӣ** *(Anthem)* | 1945 – Aug 13, 2020 | Exempted under Art. 8 | `PUBLIC_DOMAIN` | **YES** (Anthem lyrics only) |
| **Гулназар Келдӣ** *(Other)* | 1945 – Aug 13, 2020 | **December 31, 2070** | `EXCERPT_ONLY` | **NO** (Excerpts only) |
| **Гулрухсор (Сафиева)** | Born 1947 (Living) | Lifetime + 50 years | `EXCERPT_ONLY` | **NO** (Profile & excerpts only) |
| **Фарзона (Фарзонаи Хуҷандӣ)**| Born 1964 (Living) | Lifetime + 50 years | `EXCERPT_ONLY` | **NO** (Profile & excerpts only) |

---

## 6. Calculation Guidelines for 50-Year Post Mortem Auctoris

To determine the exact expiry date under Tajik Law No. 726:
$$\text{Protection End Date} = \text{December 31 of } (\text{Death Year} + 50)$$

### Concrete Calculation Examples:
- **Mirzo Tursunzoda**:
  - Date of death: September 24, 1977.
  - Calculation: $1977 + 50 = 2027$.
  - End of copyright: **December 31, 2027**.
  - Enters Public Domain: **January 1, 2028**.
- **Loiq Sherali**:
  - Date of death: June 30, 2000.
  - Calculation: $2000 + 50 = 2050$.
  - End of copyright: **December 31, 2050**.
  - Enters Public Domain: **January 1, 2051**.
- **Mumin Qanoat & Bozor Sobir**:
  - Date of death: May 2018.
  - Calculation: $2018 + 50 = 2068$.
  - End of copyright: **December 31, 2068**.
  - Enters Public Domain: **January 1, 2069**.

---

## 7. Compliance Checklist Before Ingestion

Before any verse, excerpt, or work is committed to the application repository:
1. [ ] Identify author's date of death (or confirm living status).
2. [ ] Calculate 50-year p.m.a. threshold against current calendar date.
3. [ ] If within protection period, verify that full poem text is **NOT** included.
4. [ ] If excerpted, ensure text does not exceed 4 lines and serves an illustrative/educational purpose.
5. [ ] Ensure full bibliographic attribution (Author, Work, Edition, Year, Page) accompanies the excerpt.
6. [ ] Assign valid `rights_status` enum in JSON data payload.
