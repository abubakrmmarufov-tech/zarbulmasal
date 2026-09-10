# Literary Heritage Rejected Material Log (REJECTED_MATERIAL)

**Feature**: Мероси адабӣ (Literary Heritage)  
**Project**: Zarbulmasal (Зарбулмасал)  
**Status**: Active Log — Initial Setup  
**Version**: 1.0.0  
**Effective Date**: 2026-09-10  

---

## 1. Rejection Criteria & Policy

The **Мероси адабӣ (Literary Heritage)** module maintains an exclusionary register of all web domains, scanned files, digital repositories, manuscripts, and third-party texts evaluated and rejected during research and editorial collation.

Any candidate material failing to meet the rigorous standards defined in `SOURCE_POLICY.md` and `RIGHTS_POLICY.md` is permanently banned from inclusion.

### Standard Rejection Categories

1. **`random_website`**: Unvetted blogs, personal pages, poetry hobbyist forums, lyrics repositories, and generic content mills lacking academic credentials or editorial oversight.
2. **`no_edition_identified`**: Digital texts, PDFs, or transcriptions lacking verifiable physical book imprints (publisher, publication year, city, editorial board).
3. **`no_page_numbers`**: Reprints or digital excerpts that omit specific volume and page references required for scholarly verification.
4. **`uncertain_authorship`**: Works whose attribution to a given poet is contested, apocryphal, pseudepigraphical, or contradicted by authoritative critical editions.
5. **`copyright_violation`**: Material under copyright protection (authors deceased less than 50 years ago or living authors) lacking written publisher/estate authorization and exceeding fair-use educational excerpt thresholds.
6. **`ocr_only`**: Raw optical character recognition outputs without side-by-side human collation against high-resolution physical page scans.
7. **`inaccessible_scan`**: Scans with obscured pages, illegible text, severed margins, missing hemistichs, or broken URLs that prevent line-by-line verification.
8. **`social_media_source`**: Any content originating from Instagram, Facebook, TikTok, Telegram channels/chats, Pinterest, Twitter/X, or YouTube descriptions.

---

## 2. Rejection Log Table

The following log permanently records rejected domains, files, and material to prevent duplicate research and re-introduction of substandard sources into the project.

| URL / Domain / Source Identifier | Type / Category | Specific Rejection Reason | Log Date | Evaluated By |
|:---|:---|:---|:---:|:---:|
| *(Template entry — do not use in production)* | `example_category` | *Detailed explanation of defect* | *YYYY-MM-DD* | *Editor* |

> [!NOTE]
> **Current Status**: **No items rejected yet (initial setup).**  
> All sources utilized in the initial foundation setup have been drawn strictly from approved Tier A and Tier B editions catalogued in `SOURCE_REGISTER.md`. As prospective digital texts and external scans are assessed in future phases, rejected items will be documented in this table.

---

## 3. Mandatory Protocol Upon Rejection

When an editor or researcher discovers or evaluates a proposed text that meets any rejection category:
1. Immediately halt collation of the candidate text.
2. Add a new row to the Rejection Log Table above documenting:
   - Full URL, domain, or digital document identifier.
   - Exact rejection category from the 8 standardized types.
   - Specific philological or legal rationale (e.g., "Missing title page; omits diacritics on letters Ғ and Ӯ; contradicts 2015 Adib critical edition").
   - Date of evaluation and editor's initials.
3. If an existing entry in the application database was derived from a newly rejected source, downgrade its database status immediately to `text_status: "needs_review"` or `rights_status: "BLOCKED"`.
