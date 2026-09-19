#!/usr/bin/env python3
"""Strict provenance linter for the bundled Zarbulmasal content.

This tool checks consistency and evidence labels.  It deliberately does not
require a target content count, non-empty translations, or a source URL as a
substitute for verification.

Exit status is non-zero when a record violates an integrity rule.  Use it in
CI and after every content import:

    python3 tool/provenance_linter.py
"""

from __future__ import annotations

import collections
import json
import re
import sys
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "assets/data"
WORKS_PATH = DATA / "literature/works.json"
POETS_PATH = DATA / "literature/poets.json"
HISTORY_PATH = DATA / "history/entries.json"
BOOKS_PATH = DATA / "history/books.json"
IMAGES = DATA / "literature/page_images"

HISTORY_STATUSES = {
    "VERIFIED_UPLOADED_BOOK_PAGE",
    "VERIFIED_MAORIF_PAGE",
    "VERIFIED_DOCUMENT",
    "SOURCE_LOCATED",
    "GENERATED_TRANSFORMATION",
    "EDITORIAL_TRANSLATION",
    "PARTIAL",
    "NEEDS_REVIEW",
    "UNSUPPORTED",
}
VERIFICATION_LEVELS = {
    "extracted",
    "sourceLocated",
    "primaryChecked",
    "secondWitnessLocated",
    "collated",
    "editoriallyApproved",
    "rejected",
    "needsReview",
}
BIO_TJ_PROVENANCE = {
    "SOURCE_BACKED",
    "EDITORIAL_SUMMARY_FROM_SOURCES",
    "UNSUPPORTED_GENERATED",
}
BIO_FA_PROVENANCE = {
    "SOURCE_PERSIAN",
    "SOURCE_TRANSLATION",
    "EDITORIAL_TRANSLATION",
    "UNSUPPORTED_GENERATED",
}


def load(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def text(value: Any) -> str:
    return value.strip() if isinstance(value, str) else ""


def main() -> int:
    works = load(WORKS_PATH)
    poets = load(POETS_PATH)
    history = load(HISTORY_PATH)
    books = load(BOOKS_PATH)
    errors: list[str] = []

    def fail(rule: str, record: str, detail: str) -> None:
        errors.append(f"{rule}: {record}: {detail}")

    def unique_ids(records: list[dict[str, Any]], label: str) -> set[str]:
        ids: list[str] = []
        for record in records:
            record_id = record.get("id")
            if not text(record_id):
                fail("ID_REQUIRED", label, "missing id")
            ids.append(str(record_id))
        for record_id, count in collections.Counter(ids).items():
            if count > 1:
                fail("ID_UNIQUE", label, f"duplicate id {record_id!r} ({count})")
        return set(ids)

    poet_ids = unique_ids(poets, "poets.json")
    work_ids = unique_ids(works, "works.json")
    book_ids = unique_ids(books, "books.json")
    unique_ids(history, "entries.json")

    # Literature works -------------------------------------------------
    image_names = {path.name for path in IMAGES.iterdir()} if IMAGES.exists() else set()
    for work in works:
        record = f"work:{work.get('id', '?')}"
        if work.get("authorId") not in poet_ids:
            fail("REFERENCE", record, f"unknown authorId {work.get('authorId')!r}")

        verification = work.get("verification") or {}
        level = verification.get("evidenceLevel")
        if level not in VERIFICATION_LEVELS:
            fail("VERIFICATION_ENUM", record, f"invalid evidenceLevel {level!r}")

        source = work.get("primarySource") or {}
        page_start = source.get("pageStart")
        page_end = source.get("pageEnd")
        if page_start is not None and (not isinstance(page_start, int) or page_start < 1):
            fail("PAGE_VALID", record, f"invalid pageStart {page_start!r}")
        if page_end is not None and (not isinstance(page_end, int) or page_end < 1):
            fail("PAGE_VALID", record, f"invalid pageEnd {page_end!r}")
        if page_start is not None and page_end is not None and page_start > page_end:
            fail("PAGE_RANGE", record, "pageStart is after pageEnd")

        image_verified = source.get("sourceImageVerified") is True
        image_path = source.get("sourceImagePath")
        if image_verified and (not image_path or Path(str(image_path)).name not in image_names):
            fail("IMAGE_EVIDENCE", record, "sourceImageVerified has no existing local image")
        if level in {"primaryChecked", "editoriallyApproved"}:
            if page_start is None or verification.get("pageVerified") is not True:
                fail("PAGE_EVIDENCE", record, f"{level} requires pageVerified and pageStart")
        if work.get("textStatus") == "verified" and level not in {"primaryChecked", "editoriallyApproved", "collated"}:
            fail("TEXT_STATUS", record, "verified text requires checked evidence")

        script_source = work.get("scriptSource")
        representation = text(work.get("persianScriptRepresentation"))
        representation_source = work.get("persianScriptSource")
        text_persian = text(work.get("textPersian"))
        if representation_source == "generated":
            if script_source == "both":
                fail("GENERATED_NOT_SOURCE", record, "generated representation is labeled both")
            if not representation:
                fail("GENERATED_CONTENT", record, "generated source is empty")
            if text_persian:
                fail("GENERATED_FIELD_SEPARATION", record, "generated text is still in textPersian")
        if script_source == "both":
            witnesses = work.get("scriptWitnesses") or []
            if not isinstance(witnesses, list) or not {str(w).lower() for w in witnesses} >= {"tajik", "persian"}:
                fail("DUAL_SCRIPT_EVIDENCE", record, "scriptSource=both lacks two source witnesses")
        if script_source not in {"tajikOnly", "tajikCyrillic", "persianArabic", "both"}:
            fail("SCRIPT_ENUM", record, f"invalid scriptSource {script_source!r}")

        rights = work.get("rights") or {}
        if rights.get("status") == "publicDomain" and not rights.get("supportingEvidence"):
            fail("RIGHTS_EVIDENCE", record, "publicDomain lacks supportingEvidence")
        if rights.get("status") == "unknown" and (rights.get("fullTextAllowed") or rights.get("excerptAllowed")):
            fail("RIGHTS_CONSISTENCY", record, "unknown rights cannot allow text")

        title_source = work.get("titlePersianSource")
        if work.get("titlePersian") and title_source not in {"generated", "source", "translation"}:
            fail("TITLE_PROVENANCE", record, f"invalid titlePersianSource {title_source!r}")

    # Poet biographies and rights -------------------------------------
    for poet in poets:
        record = f"poet:{poet.get('id', '?')}"
        tj_provenance = poet.get("biographyTjProvenance")
        fa_provenance = poet.get("biographyFaProvenance")
        if tj_provenance not in BIO_TJ_PROVENANCE:
            fail("BIOGRAPHY_ENUM", record, f"invalid Tajik provenance {tj_provenance!r}")
        if fa_provenance not in BIO_FA_PROVENANCE:
            fail("BIOGRAPHY_ENUM", record, f"invalid Persian provenance {fa_provenance!r}")
        if tj_provenance == "UNSUPPORTED_GENERATED" and text(poet.get("biographyTj")):
            fail("BIOGRAPHY_QUARANTINE", record, "unsupported Tajik biography remains active")
        if tj_provenance != "UNSUPPORTED_GENERATED" and not text(poet.get("biographyTj")):
            fail("BIOGRAPHY_REQUIRED", record, "sourced Tajik biography is empty")
        if fa_provenance == "UNSUPPORTED_GENERATED" and text(poet.get("biographyFa")):
            fail("BIOGRAPHY_QUARANTINE", record, "unsupported Persian biography remains active")
        if fa_provenance != "UNSUPPORTED_GENERATED" and not text(poet.get("biographyFa")):
            fail("BIOGRAPHY_REQUIRED", record, "sourced Persian biography is empty")
        rights = poet.get("rights") or {}
        if rights.get("status") == "publicDomain" and not rights.get("supportingEvidence"):
            fail("RIGHTS_EVIDENCE", record, "publicDomain lacks supportingEvidence")
        if rights.get("status") == "unknown" and (rights.get("fullTextAllowed") or rights.get("excerptAllowed")):
            fail("RIGHTS_CONSISTENCY", record, "unknown rights cannot allow text")

    # History claims ---------------------------------------------------
    books_by_id = {book.get("id"): book for book in books}
    page_occurrences: collections.Counter[tuple[str, int]] = collections.Counter()
    for entry in history:
        record = f"history:{entry.get('id', '?')}"
        if entry.get("sourceBookId") not in book_ids:
            fail("REFERENCE", record, f"unknown sourceBookId {entry.get('sourceBookId')!r}")
        for claim in entry.get("claimProvenance") or []:
            claim_record = f"{record}/claim"
            status = claim.get("status")
            if status not in HISTORY_STATUSES:
                fail("VERIFICATION_ENUM", claim_record, f"invalid status {status!r}")
            if not text(claim.get("claim")):
                fail("CLAIM_REQUIRED", claim_record, "empty claim")
            source_book_id = claim.get("sourceBookId")
            if source_book_id not in book_ids:
                fail("REFERENCE", claim_record, f"unknown claim sourceBookId {source_book_id!r}")
            printed = claim.get("printedPage")
            pdf = claim.get("pdfPage")
            for label, page in (("printedPage", printed), ("pdfPage", pdf)):
                if page is not None and (not isinstance(page, int) or page < 1):
                    fail("PAGE_VALID", claim_record, f"invalid {label} {page!r}")
            if status in {"VERIFIED_UPLOADED_BOOK_PAGE", "VERIFIED_MAORIF_PAGE"} and printed is None and pdf is None:
                fail("PAGE_EVIDENCE", claim_record, f"{status} requires a page")
            total_pages = (books_by_id.get(source_book_id) or {}).get("totalPages")
            if total_pages:
                for label, page in (("printedPage", printed), ("pdfPage", pdf)):
                    if page is not None and page > total_pages:
                        fail("PAGE_RANGE", claim_record, f"{label} {page} exceeds {total_pages}")
            for page in (printed, pdf):
                if page is not None:
                    page_occurrences[(str(source_book_id), page)] += 1

    for (book_id, page), count in page_occurrences.items():
        if page == 1 and count > 1:
            fail("REPEATED_DEFAULT_PAGE", f"book:{book_id}", f"page 1 appears {count} times")

    # A URL is a locator only; it is never accepted as proof on its own.
    for book in books:
        url = text(book.get("sourceUrl"))
        if url and not url.startswith("https://maorif.tj/"):
            fail("SOURCE_POLICY", f"book:{book.get('id', '?')}", f"unapproved source URL {url}")

    # Fake verifier/institution fields are forbidden even if a future importer
    # adds them.  Real evidence is represented by source/page/hash metadata.
    generic_verifier = re.compile(r"(?:ai|system|editorial board|institute|academy|board|verifier)", re.I)
    for collection_name, records in (("works", works), ("entries", history)):
        seen: collections.Counter[str] = collections.Counter()
        for item in records:
            values = (item.get("verification") or {}).get("verifiedBy", [])
            if isinstance(values, list):
                for value in values:
                    if isinstance(value, str) and generic_verifier.search(value):
                        seen[value] += 1
        for value, count in seen.items():
            fail("FAKE_VERIFIER", collection_name, f"generic verifier {value!r} appears {count} times")

    metrics = {
        "poets": len(poets),
        "works": len(works),
        "history_entries": len(history),
        "history_claims": sum(len(e.get("claimProvenance") or []) for e in history),
        "generated_script_representations": sum(
            1 for w in works if w.get("persianScriptSource") == "generated"
        ),
        "source_persian_works": sum(
            1 for w in works if w.get("persianScriptSource") == "source"
        ),
        "semantic_translations": sum(
            1 for w in works if w.get("persianScriptSource") == "translation"
        ),
        "unsupported_biographies": sum(
            1 for p in poets if p.get("biographyTjProvenance") == "UNSUPPORTED_GENERATED"
        ),
    }
    print(json.dumps({"metrics": metrics, "errors": len(errors)}, ensure_ascii=False, indent=2))
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print("PROVENANCE_LINTER: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
