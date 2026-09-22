# Literary Heritage Text Verification Report (VERIFICATION_REPORT)

**Feature**: Мероси адабӣ (Literary Heritage)  
**Project**: Zarbulmasal (Зарбулмасал)  
**Status**: 28 SOURCE-ATTESTED WORKS READABLE; REMAINING RECORDS REVIEW ONLY
**Version**: 1.0.0  
**Effective Date**: 2026-09-22

---

## 1. Verification Process & Protocol

This document tracks the philological collation and verification status of every literary work (poem, ghazal, qasida, rubai, masnavi excerpt) intended for publication in the Zarbulmasal application.

In accordance with the current project publication rule:
1. **Zero Unverified Publication**: A literary work is displayed only after its exact text and printed page have been checked against one permitted source: an uploaded project PDF or `maorif.tj`.
2. **Current Baseline State**: The catalog contains 5,501 work records: 31 have primary-page evidence, 28 of those have recoverable verified Tajik text, 5,215 remain pending review, and 255 extraction/prose/duplicate candidates are rejected. The remaining three checked records contain no guessed text.
3. **Optional Second Witness**: A second witness and further editorial collation improve the record but are not publication requirements for the source-attested path. Source-attested is a provenance/policy status, not a general copyright or public-domain claim.
4. **Orthographic Rigor**:
   - Every Tajik Cyrillic diacritic (`ғ`, `ӣ`, `қ`, `ӯ`, `ҳ`, `ҷ`) is audited against the printed scan.
   - Persian Arabic script is proofread for correct consonantal dots (`پ`, `چ`, `ژ`, `گ`), medial forms, and standard Persian orthography.
   - Hemistich (*мисраъ*) integrity, line breaks, and classical metres (*авзон ва буҳури арӯз*) are strictly verified.

---

## 2. Global Verification Dashboard

| Catalog works | Pending review | Primary-page checked | Source-attested readable | Rejected | Editorially approved |
|:---:|:---:|:---:|:---:|:---:|:---:|
| 5,501 | 5,215 | 31 | 28 | 255 | 0 |

> [!NOTE]
> Of the 31 page-checked works, 28 have exact recoverable text and use the
> source-attested publication path. Three remain withheld because exact text
> was not recoverable. Current page evidence and occurrence records are in
> `POEM_PAGE_PROOF.md` and `assets/data/literature/works.json`.

---

## 3. Per-Work Verification Checklist Template

*(Editors must duplicate this checklist block for each work undergoing collation)*

```markdown
### Work Dossier: [WORK_ID] — [TITLE_CYRILLIC] / [TITLE_PERSIAN]

- **Author**: [Author Name]
- **Poetic Form**: [Ghazal / Rubai / Qasida / Masnavi / She'ri Nav]
- **Rights Status**: [PUBLIC_DOMAIN / EXCERPT_ONLY / FOLKLORE]
- **Curriculum Grade Level**: [e.g., Grade 5 / Grade 8 / Grade 10]
- **Current Text Status**: `needs_review`

#### Witness Documentation
- **Witness 1 (Base Witness - Tier A)**:
  - Title: [Book Title]
  - Editor / Compiler: [Name]
  - Publisher & City: [Publisher, City, Year]
  - Volume & Page Number(s): [Vol., pp. XX–YY]
  - Facsimile / Scan Reference: [Archive file ID or shelfmark]
- **Witness 2 (Corroborating Witness - Tier A / B)**:
  - Title: [Book Title]
  - Editor / Compiler: [Name]
  - Publisher & City: [Publisher, City, Year]
  - Volume & Page Number(s): [Vol., pp. XX–YY]
  - Facsimile / Scan Reference: [Archive file ID or shelfmark]

#### Verification Gate Checklist
- [ ] 1. Rights clearance verified under Tajik Law No. 726 (Public Domain or Fair Use Excerpt).
- [ ] 2. Line and bayt counts match identically across both witnesses.
- [ ] 3. Line-by-line manual collation completed against physical scan (no unverified OCR).
- [ ] 4. Tajik Cyrillic diacritics audited (`ғ`, `ӣ`, `қ`, `ӯ`, `ҳ`, `ҷ` confirmed correct).
- [ ] 5. Persian Arabic text matched, joined properly, and orthographically compliant.
- [ ] 6. Classical poetic metre (*вазн/арӯз*) and rhyming scheme (*қофия ва радиф*) verified.
- [ ] 7. Hemistich division verified (Misra 1 / Misra 2 clearly delimited in JSON).
- [ ] 8. Variant readings (if any) documented in the Variant Log below.

#### Variant Log (Collation Discrepancies)
| Line # | Base Witness Reading | Witness 2 Reading | Adopted Reading | Rationale & Authority |
|:---:|:---|:---|:---|:---|
| — | None | None | None | No variants observed |

#### Editorial Sign-Off
- **Collation Editor**: [Name / ID] — Date: [YYYY-MM-DD]
- **Senior Reviewer**: [Name / ID] — Date: [YYYY-MM-DD]
- **Final Determination**: [ `verified` | `rejected` | `needs_revision` ]
```

---

## 4. Random Line Audit Protocol & Log

To guarantee long-term quality assurance and prevent drift between printed sources and the application database, periodic random line audits are performed.

### Audit Protocol
1. **Sampling Rule**: A random sample of 10% of all published lines is selected using a deterministic seed.
2. **Double-Blind Review**: An independent reviewer compares the live JSON string directly to the physical book scan without viewing the previous verification report.
3. **Tolerance**: Zero-defect threshold for Cyrillic letters and Persian orthography. Any mismatch immediately triggers reversion to `needs_review` status.

### Random Line Audit Log

*(Empty — To be populated during subsequent post-verification audit cycles)*

| Audit ID | Work ID | Line # | Live Database Text | Physical Scan Source & Page | Audit Result | Auditor | Audit Date |
|:---:|:---:|:---:|:---|:---|:---:|:---:|:---:|
| — | — | — | *(No records verified yet)* | — | — | — | — |

---

## 5. Summary & Next Steps

1. Keep every unapproved work and all poem text withheld from public display.
2. Resolve second-witness gaps for the six primary-checked records and establish rights/editorial approval before any release.
3. Complete line/script audits and editorial review for the 5,215 pending records; retain exact printed-page and source evidence for every decision.

### Work Dossier: rudaki_buyi_juyi_muliyon_grade5_2017_p54 — Бӯйи Ҷӯйи Мулиён / بوی جوی مولیان

The Persian title is a generated script representation, not a Persian-source title or semantic translation.

- **Author**: Абӯабдуллоҳи Рӯдакӣ
- **Poetic Form**: Qasida
- **Rights Status**: `unknown` — textbook evidence does not establish redistribution rights.
- **Curriculum Grade Level**: Grade 5
- **Current Text Status**: `needs_review`

#### Witness Documentation
- **Witness 1 (Base Witness - Tier A)**:
  - Title: Адабиёт: Китоби дарсӣ барои синфи 5
  - Editor / Compiler: А. Абдураҳмонов, С. Солеҳов, Ш. Исломов
  - Publisher & City: Маориф, Душанбе, 2017
  - Volume & Page Number(s): Printed p. 54
  - Facsimile / Scan Reference: `assets/data/literature/page_images/rudaki_buyi_juyi_muliyon_grade5_2017_p54.png`
- **Witness 2 (Corroborating Witness - Tier A / B)**:
  - Title: Адабиёти тоҷик. Китоби дарсӣ барои синфи 5-уми муассисаҳои таҳсилоти умумӣ
  - Editor / Compiler: Т. Мирзод, Р. Ҳамидов, М. Пирзод, Ф. Мирзода
  - Publisher & City: Маориф, Душанбе, 2025; ISBN 978-99985-61-21-2
  - Volume & Page Number(s): Printed p. 56
  - Facsimile / Scan Reference: `assets/data/literature/page_images/rudaki_buyi_muliyon_maorif_2025_p56.png`; [official Ministry PDF](https://maorif.tj/storage/libraries/01K6HGRAG6CPT6S1XBVK6KBPJT.pdf)

#### Verification Gate Checklist
- [ ] 1. Rights clearance verified under Tajik Law No. 726 (not established).
- [x] 2. Both witnesses contain the same 12-line poem; a minor orthographic variant is recorded below.
- [x] 3. Line-by-line collation completed against inspected page images (not OCR alone).
- [ ] 4. Tajik Cyrillic diacritics audited (`ғ`, `ӣ`, `қ`, `ӯ`, `ҳ`, `ҷ` confirmed correct).
- [ ] 5. Persian Arabic text matched, joined properly, and orthographically compliant.
- [ ] 6. Classical poetic metre (*вазн/арӯз*) and rhyming scheme (*қофия ва радиф*) verified.
- [ ] 7. Hemistich division verified (Misra 1 / Misra 2 clearly delimited in JSON).
- [x] 8. Variant readings documented in the Variant Log below.

#### Variant Log (Collation Discrepancies)
| Line # | Base Witness Reading | Witness 2 Reading | Adopted Reading | Rationale & Authority |
|:---:|:---|:---|:---|:---|
| 3 | Minor orthographic variant; see inspected page | Minor orthographic variant; see inspected page | Not adjudicated for publication | `works.json` records a minor line-3 variant; the display form remains unresolved pending editorial approval. |

#### Editorial Sign-Off
- **Collation Editor**: [PENDING] — Date: [PENDING]
- **Senior Reviewer**: [PENDING] — Date: [PENDING]
- **Final Determination**: `needs_review`
