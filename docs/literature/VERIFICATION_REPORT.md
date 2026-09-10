# Literary Heritage Text Verification Report (VERIFICATION_REPORT)

**Feature**: Мероси адабӣ (Literary Heritage)  
**Project**: Zarbulmasal (Зарбулмасал)  
**Status**: INITIAL — No works have completed verification yet  
**Version**: 1.0.0  
**Effective Date**: 2026-09-10  

---

## 1. Verification Process & Protocol

This document tracks the philological collation and verification status of every literary work (poem, ghazal, qasida, rubai, masnavi excerpt) intended for publication in the Zarbulmasal application.

In accordance with `SOURCE_POLICY.md` and `RIGHTS_POLICY.md`:
1. **Zero Unverified Publication**: No literary work may be displayed with `text_status: "verified"` until it passes full dual-witness manual collation and receives dual-editor sign-off.
2. **Current Baseline State**: As of the current baseline, **STATUS IS INITIAL**. All poem text fields in the catalog remain `null` or empty strings `""` with status `"text_status": "needs_review"`.
3. **Dual-Witness Standard**: Every published verse must be collated against two independent Tier A or Tier B printed book witnesses.
4. **Orthographic Rigor**:
   - Every Tajik Cyrillic diacritic (`ғ`, `ӣ`, `қ`, `ӯ`, `ҳ`, `ҷ`) is audited against the printed scan.
   - Persian Arabic script is proofread for correct consonantal dots (`پ`, `چ`, `ژ`, `گ`), medial forms, and standard Persian orthography.
   - Hemistich (*мисраъ*) integrity, line breaks, and classical metres (*авзон ва буҳури арӯз*) are strictly verified.

---

## 2. Global Verification Dashboard

| Total Planned Works | Needs Review (`needs_review`) | Verified (`verified`) | In Progress | Blocked (`blocked`) |
|:---:|:---:|:---:|:---:|:---:|
| 1 | 1 | 0 | 0 | 0 |

> [!NOTE]
> Detailed per-work records will be appended below as individual works are introduced to the editorial pipeline.

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

1. Foundation documentation establishes zero-defect standards prior to textual ingestion.
2. Data schemas in `assets/data/literature/` must reflect `text_status: "needs_review"` for all initial entries.
3. Human-verified texts with physical page scans will be sequentially logged in this document upon completion of the verification checklist.

### Work Dossier: rudaki_buyi_juyi_muliyon — Бӯйи ҷӯйи Мӯлиён ояд ҳаме / بوی جوی مولیان آید همی

- **Author**: Абӯабдуллоҳи Рӯдакӣ
- **Poetic Form**: Qasida
- **Rights Status**: PUBLIC_DOMAIN
- **Curriculum Grade Level**: Grade 8, Grade 10
- **Current Text Status**: `needs_review`

#### Witness Documentation
- **Witness 1 (Base Witness - Tier A)**:
  - Title: Ашъори Рӯдакӣ (Ахтарони адаб, Ҷ. 1)
  - Editor / Compiler: А. Абдуллоев, С. Саъдиев
  - Publisher & City: Адиб, Душанбе, 2008
  - Volume & Page Number(s): [PENDING]
  - Facsimile / Scan Reference: [PENDING]
- **Witness 2 (Corroborating Witness - Tier A / B)**:
  - Title: [PENDING]
  - Editor / Compiler: [PENDING]
  - Publisher & City: [PENDING]
  - Volume & Page Number(s): [PENDING]
  - Facsimile / Scan Reference: [PENDING]

#### Verification Gate Checklist
- [x] 1. Rights clearance verified under Tajik Law No. 726 (Public Domain or Fair Use Excerpt).
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
- **Collation Editor**: [PENDING] — Date: [PENDING]
- **Senior Reviewer**: [PENDING] — Date: [PENDING]
- **Final Determination**: `needs_review`
