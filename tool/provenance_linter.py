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
from urllib.parse import urlparse
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "assets/data"
WORKS_PATH = DATA / "literature/works.json"
ORAL_PATH = DATA / "literature/oral_heritage.json"
POETS_PATH = DATA / "literature/poets.json"
HISTORY_PATH = DATA / "history/entries.json"
BOOKS_PATH = DATA / "history/books.json"
APP_BOOKS_PATH = DATA / "books/books.json"
PROVIDERS_PATH = DATA / "books/providers.json"
IMAGES = DATA / "literature/page_images"
PORTRAITS = DATA / "literature/portraits"
BOOK_COVERS = DATA / "books/covers"

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
SECONDARY_COLLATION_RESULTS = {"exact", "minor-variant"}
REQUIRED_BIBLIOGRAPHIC_FIELDS = (
    "bookTitle",
    "publisher",
    "city",
    "year",
    "sourceType",
)
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
    oral = load(ORAL_PATH)
    poets = load(POETS_PATH)
    history = load(HISTORY_PATH)
    books = load(BOOKS_PATH)
    app_books = load(APP_BOOKS_PATH)
    providers = load(PROVIDERS_PATH)
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
    unique_ids(oral, "oral_heritage.json")
    book_ids = unique_ids(books, "books.json")
    unique_ids(history, "entries.json")

    # Books catalogue -------------------------------------------------
    provider_ids = {provider.get("id") for provider in providers}
    unique_ids(app_books, "books/books.json")
    app_edition_ids: set[str] = set()
    canonical_books: dict[tuple[str, str], str] = {}
    for book in app_books:
        record = f"book:{book.get('id', '?')}"
        if not text(book.get("canonicalTitle")) or not text(book.get("titleTj")):
            fail("BOOK_TITLE_REQUIRED", record, "canonicalTitle and titleTj are required")
        author_id = book.get("authorId")
        if author_id is not None and author_id not in poet_ids:
            fail("REFERENCE", record, f"unknown authorId {author_id!r}")
        for related_poet_id in book.get("relatedPoetIds") or []:
            if related_poet_id not in poet_ids:
                fail("REFERENCE", record, f"unknown relatedPoetId {related_poet_id!r}")
        for related_work_id in book.get("relatedWorkIds") or []:
            if related_work_id not in work_ids:
                fail("REFERENCE", record, f"unknown relatedWorkId {related_work_id!r}")
        canonical_key = (
            re.sub(r"\W+", "", text(book.get("canonicalTitle")).lower()),
            re.sub(r"\W+", "", text(book.get("authorNameTj")).lower()),
        )
        if canonical_key in canonical_books:
            fail(
                "BOOK_CANONICAL_DUPLICATE",
                record,
                f"duplicates {canonical_books[canonical_key]} by canonical title/author",
            )
        else:
            canonical_books[canonical_key] = str(book.get("id"))
        editions = book.get("editions") or []
        if not editions:
            fail("BOOK_EDITION_REQUIRED", record, "book must have at least one edition")
        for edition in editions:
            edition_record = f"{record}/edition:{edition.get('id', '?')}"
            edition_id = edition.get("id")
            if not text(edition_id) or edition_id in app_edition_ids:
                fail("BOOK_EDITION_ID", edition_record, "edition id is empty or duplicated")
            app_edition_ids.add(str(edition_id))
            if edition.get("bookId") != book.get("id"):
                fail("BOOK_EDITION_RELATIONSHIP", edition_record, "edition bookId does not match parent book")
            if edition.get("providerId") not in provider_ids:
                fail("REFERENCE", edition_record, f"unknown providerId {edition.get('providerId')!r}")
            for url_field in ("sourceUrl", "readUrl", "downloadUrl", "coverUrl"):
                url_value = edition.get(url_field)
                if url_value is None or not text(url_value):
                    continue
                parsed = urlparse(str(url_value))
                if parsed.scheme != "https" or not parsed.netloc:
                    fail("BOOK_URL_POLICY", edition_record, f"{url_field} must be an HTTPS URL")
            cover_asset = text(edition.get("coverAssetPath"))
            if cover_asset:
                cover_path = Path(cover_asset)
                if (
                    not cover_asset.startswith("assets/data/books/covers/")
                    or "\\" in cover_asset
                    or ".." in cover_path.parts
                    or cover_path.suffix.lower() not in {".jpg", ".jpeg", ".png", ".webp"}
                ):
                    fail(
                        "BOOK_COVER_ASSET_PATH",
                        edition_record,
                        "coverAssetPath must stay inside assets/data/books/covers",
                    )
                else:
                    resolved_cover = (ROOT / cover_asset).resolve()
                    try:
                        resolved_cover.relative_to(BOOK_COVERS.resolve())
                    except ValueError:
                        fail(
                            "BOOK_COVER_ASSET_PATH",
                            edition_record,
                            "coverAssetPath resolves outside the approved cover directory",
                        )
                    else:
                        if not resolved_cover.is_file():
                            fail(
                                "BOOK_COVER_ASSET_MISSING",
                                edition_record,
                                f"cover asset does not exist: {cover_asset!r}",
                            )
                if not text(edition.get("coverUrl")):
                    fail(
                        "BOOK_COVER_PROVENANCE",
                        edition_record,
                        "a bundled cover must retain its source coverUrl",
                    )
            if edition.get("availability") == "readableExternal" and not text(edition.get("readUrl")):
                fail("BOOK_READ_LINK_REQUIRED", edition_record, "readable edition must have readUrl")
            page_count = edition.get("pageCount")
            if page_count is not None and (not isinstance(page_count, int) or page_count < 1):
                fail("BOOK_PAGE_COUNT", edition_record, "pageCount must be a positive integer")

    # Literature works -------------------------------------------------
    image_root = IMAGES.resolve()
    pdf_root = (ROOT / "docs/literature/pdfs").resolve()
    canonical_work_keys: dict[tuple[str, str, str], str] = {}

    def validate_source(
        source: Any,
        record: str,
        label: str,
        *,
        require_page: bool = False,
        require_bibliography: bool = False,
        require_image: bool = False,
    ) -> None:
        source_record = record if label == "primarySource" else f"{record}/{label}"
        if not isinstance(source, dict):
            fail("SOURCE_FORMAT", source_record, "source record must be an object")
            return

        page_start = source.get("pageStart")
        page_end = source.get("pageEnd")
        if page_start is not None and (not isinstance(page_start, int) or page_start < 1):
            fail("PAGE_VALID", source_record, f"invalid pageStart {page_start!r}")
        if page_end is not None and (not isinstance(page_end, int) or page_end < 1):
            fail("PAGE_VALID", source_record, f"invalid pageEnd {page_end!r}")
        if page_start is not None and page_end is not None and page_start > page_end:
            fail("PAGE_RANGE", source_record, "pageStart is after pageEnd")
        if require_page and page_start is None:
            fail("SECONDARY_PAGE_EVIDENCE", source_record, "secondary source requires pageStart")

        if require_bibliography:
            for field in REQUIRED_BIBLIOGRAPHIC_FIELDS:
                if not text(source.get(field)):
                    fail(
                        "SOURCE_BIBLIOGRAPHY",
                        source_record,
                        f"checked source requires non-empty {field}",
                    )
            source_reference = text(source.get("sourceReference"))
            if not source_reference:
                fail(
                    "SOURCE_BIBLIOGRAPHY",
                    source_record,
                    "checked source requires sourceReference",
                )
            elif source_reference.startswith("docs/literature/pdfs/"):
                reference_path = (ROOT / source_reference).resolve()
                try:
                    reference_path.relative_to(pdf_root)
                except ValueError:
                    fail(
                        "SOURCE_REFERENCE",
                        source_record,
                        f"local source is outside the approved PDF corpus: {source_reference!r}",
                    )
                else:
                    if reference_path.suffix.lower() != ".pdf" or not reference_path.is_file():
                        fail(
                            "SOURCE_REFERENCE",
                            source_record,
                            f"local source PDF does not exist: {source_reference!r}",
                        )
            elif not source_reference.startswith("https://maorif.tj/"):
                fail(
                    "SOURCE_REFERENCE",
                    source_record,
                    "checked sourceReference must point to an uploaded PDF or maorif.tj",
                )

        image_verified = source.get("sourceImageVerified") is True
        legacy_image_path = source.get("sourceImagePath")
        raw_image_paths = source.get("sourceImagePaths")
        image_paths: list[str] = []
        if raw_image_paths is not None:
            if not isinstance(raw_image_paths, list):
                fail("IMAGE_EVIDENCE_FORMAT", source_record, "sourceImagePaths must be a list")
            else:
                for image_path in raw_image_paths:
                    if not isinstance(image_path, str) or not text(image_path):
                        fail("IMAGE_EVIDENCE_FORMAT", source_record, "sourceImagePaths contains an empty/non-string path")
                    else:
                        image_paths.append(image_path.strip())
        if legacy_image_path is not None:
            if not isinstance(legacy_image_path, str) or not text(legacy_image_path):
                fail("IMAGE_EVIDENCE_FORMAT", source_record, "sourceImagePath must be a non-empty string when present")
            elif not image_paths:
                image_paths.append(legacy_image_path.strip())
            elif image_paths[0] != legacy_image_path.strip():
                fail("IMAGE_EVIDENCE_ORDER", source_record, "legacy sourceImagePath must match the first sourceImagePaths entry")
        if require_image and not image_verified:
            fail(
                "PAGE_IMAGE_EVIDENCE",
                source_record,
                "checked source requires sourceImageVerified=true",
            )
        if image_verified:
            if not image_paths:
                fail(
                    "IMAGE_EVIDENCE",
                    source_record,
                    "sourceImageVerified has missing local image evidence",
                )
            for image_path in image_paths:
                candidate = (ROOT / image_path).resolve()
                try:
                    candidate.relative_to(image_root)
                except ValueError:
                    fail(
                        "IMAGE_EVIDENCE",
                        source_record,
                        f"source image is outside the local page-image directory: {image_path!r}",
                    )
                    continue
                if not candidate.is_file():
                    fail(
                        "IMAGE_EVIDENCE",
                        source_record,
                        f"source image does not exist locally: {image_path!r}",
                    )

    for work in works:
        record = f"work:{work.get('id', '?')}"
        if work.get("authorId") not in poet_ids:
            fail("REFERENCE", record, f"unknown authorId {work.get('authorId')!r}")
        work_key = (
            str(work.get("authorId", "")),
            re.sub(r"\W+", "", text(work.get("title")).lower()),
            re.sub(r"\W+", "", text(work.get("incipit")).lower()),
        )
        if work_key[1] and work_key in canonical_work_keys:
            fail(
                "WORK_CANONICAL_DUPLICATE",
                record,
                f"duplicates {canonical_work_keys[work_key]} for the same author/title/incipit",
            )
        elif work_key[1]:
            canonical_work_keys[work_key] = str(work.get("id"))

        verification = work.get("verification") or {}
        level = verification.get("evidenceLevel")
        if level not in VERIFICATION_LEVELS:
            fail("VERIFICATION_ENUM", record, f"invalid evidenceLevel {level!r}")

        source = work.get("primarySource") or {}
        validate_source(
            source,
            record,
            "primarySource",
            require_bibliography=level in {"primaryChecked", "editoriallyApproved"},
            require_image=level in {"primaryChecked", "editoriallyApproved"},
        )
        page_start = source.get("pageStart")
        page_end = source.get("pageEnd")
        secondary = work.get("secondarySource")
        if secondary is not None:
            validate_source(
                secondary,
                record,
                "secondarySource",
                require_page=True,
                require_bibliography=True,
                require_image=True,
            )
            match_result = work.get("textMatchResult")
            if match_result not in SECONDARY_COLLATION_RESULTS:
                fail(
                    "SECONDARY_COLLATION",
                    record,
                    "secondary source requires an explicit exact or minor-variant textMatchResult",
                )
                if not text(work.get("variantNotes")):
                    fail(
                        "SECONDARY_COLLATION",
                        record,
                        "secondary source requires variantNotes describing the line collation",
                    )
        occurrences = work.get("sourceOccurrences")
        if occurrences is not None:
            if not isinstance(occurrences, list):
                fail("SOURCE_OCCURRENCES_FORMAT", record, "sourceOccurrences must be a list")
            else:
                for index, occurrence in enumerate(occurrences):
                    validate_source(
                        occurrence,
                        record,
                        f"sourceOccurrences[{index}]",
                    )
        if level in {"primaryChecked", "editoriallyApproved"}:
            if page_start is None or verification.get("pageVerified") is not True:
                fail("PAGE_EVIDENCE", record, f"{level} requires pageVerified and pageStart")
            if source.get("sourceImageVerified") is not True:
                fail(
                    "PAGE_IMAGE_EVIDENCE",
                    record,
                    f"{level} requires sourceImageVerified on the primary witness",
                )
        if work.get("textStatus") == "verified" and level not in {"primaryChecked", "editoriallyApproved", "collated"}:
            fail("TEXT_STATUS", record, "verified text requires checked evidence")

        script_source = work.get("scriptSource")
        representation = text(work.get("persianScriptRepresentation"))
        representation_source = work.get("persianScriptSource")
        text_persian = text(work.get("textPersian"))
        if representation_source == "generated":
            if script_source == "both":
                fail("GENERATED_NOT_SOURCE", record, "generated representation is labeled both")
            if not representation and work.get("textStatus") != "needsReview":
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
        if not rights.get("fullTextAllowed"):
            if any(text(work.get(field)) for field in ("textTajik", "textPersian", "persianScriptRepresentation")):
                fail("FULLTEXT_DISTRIBUTION", record, "full-text fields require explicit rights clearance")
        if not rights.get("excerptAllowed") and text(work.get("incipit")):
            fail("EXCERPT_DISTRIBUTION", record, "incipit requires explicit excerpt rights")

        title_source = work.get("titlePersianSource")
        if work.get("titlePersian") and title_source not in {"generated", "source", "translation"}:
            fail("TITLE_PROVENANCE", record, f"invalid titlePersianSource {title_source!r}")
        title_persian = text(work.get("titlePersian"))
        if title_persian and re.search(r"[A-Za-z\u0400-\u04FF]", title_persian):
            fail(
                "TITLE_SCRIPT_LEAK",
                record,
                "Persian title contains Latin or Cyrillic extraction characters",
            )

    # Poet biographies and rights -------------------------------------
    for poet in poets:
        record = f"poet:{poet.get('id', '?')}"
        portrait = poet.get("portrait")
        if portrait is not None:
            if not isinstance(portrait, dict):
                fail("PORTRAIT_FORMAT", record, "portrait must be an object")
            else:
                portrait_asset = text(portrait.get("assetPath"))
                portrait_source = text(portrait.get("sourceReference"))
                portrait_type = text(portrait.get("sourceType"))
                portrait_page = portrait.get("sourcePage")
                if portrait_type not in {"uploaded_book", "user_provided_photo", "maorif_tj"}:
                    fail("PORTRAIT_SOURCE_TYPE", record, f"invalid sourceType {portrait_type!r}")
                if not portrait_asset.startswith("assets/data/literature/portraits/"):
                    fail("PORTRAIT_ASSET_PATH", record, "portrait asset must stay in the local portraits directory")
                else:
                    asset_path = (ROOT / portrait_asset).resolve()
                    try:
                        asset_path.relative_to(PORTRAITS.resolve())
                    except ValueError:
                        fail("PORTRAIT_ASSET_PATH", record, "portrait asset escapes the local portraits directory")
                    else:
                        if not asset_path.is_file():
                            fail("PORTRAIT_ASSET_MISSING", record, f"portrait asset does not exist: {portrait_asset!r}")
                if not isinstance(portrait_page, int) or portrait_page < 1:
                    fail("PORTRAIT_PAGE", record, "portrait sourcePage must be a positive integer")
                if portrait_type == "uploaded_book":
                    if not portrait_source.startswith("docs/literature/pdfs/"):
                        fail("PORTRAIT_SOURCE_REFERENCE", record, "uploaded_book portrait must cite the approved PDF corpus")
                    else:
                        source_path = (ROOT / portrait_source).resolve()
                        try:
                            source_path.relative_to((ROOT / "docs/literature/pdfs").resolve())
                        except ValueError:
                            fail("PORTRAIT_SOURCE_REFERENCE", record, "portrait source escapes the approved PDF corpus")
                        else:
                            if source_path.suffix.lower() != ".pdf" or not source_path.is_file():
                                fail("PORTRAIT_SOURCE_REFERENCE", record, f"portrait source PDF does not exist: {portrait_source!r}")
                elif portrait_type == "maorif_tj" and not portrait_source.startswith("https://maorif.tj/"):
                    fail("PORTRAIT_SOURCE_REFERENCE", record, "maorif_tj portrait must cite maorif.tj")
                if text(portrait.get("rightsStatus")) not in {"unknown", "permission_granted", "public_domain"}:
                    fail("PORTRAIT_RIGHTS_STATUS", record, "portrait rightsStatus must be explicit")
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
        if (
            tj_provenance == "UNSUPPORTED_GENERATED"
            or fa_provenance == "UNSUPPORTED_GENERATED"
        ) and not text(poet.get("biographyQuarantineNote")):
            fail("BIOGRAPHY_QUARANTINE_NOTE", record, "unsupported biography lacks a quarantine explanation")
        rights = poet.get("rights") or {}
        if rights.get("status") == "publicDomain" and not rights.get("supportingEvidence"):
            fail("RIGHTS_EVIDENCE", record, "publicDomain lacks supportingEvidence")
        if rights.get("status") == "unknown" and (rights.get("fullTextAllowed") or rights.get("excerptAllowed")):
            fail("RIGHTS_CONSISTENCY", record, "unknown rights cannot allow text")

    # Oral heritage content and rights --------------------------------
    for entry in oral:
        record = f"oral:{entry.get('id', '?')}"
        rights = entry.get("rights") or {}
        has_text = bool(text(entry.get("text")) or text(entry.get("textPersian")))
        if rights.get("status") == "unknown" and (
            rights.get("fullTextAllowed") or rights.get("excerptAllowed")
        ):
            fail("RIGHTS_CONSISTENCY", record, "unknown rights cannot allow text")
        if not rights.get("fullTextAllowed") and has_text:
            fail(
                "ORAL_FULLTEXT_DISTRIBUTION",
                record,
                "oral text requires explicit full-text rights",
            )
        if rights.get("fullTextAllowed") and not text(entry.get("text")):
            fail("ORAL_TEXT_REQUIRED", record, "cleared oral entry has no Tajik text")

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
        "oral_heritage_entries": len(oral),
        "oral_full_text_records": sum(
            1
            for entry in oral
            if text(entry.get("text")) or text(entry.get("textPersian"))
        ),
        "history_entries": len(history),
        "history_claims": sum(len(e.get("claimProvenance") or []) for e in history),
        "generated_script_representations": sum(
            1
            for w in works
            if w.get("persianScriptSource") == "generated"
            and text(w.get("persianScriptRepresentation"))
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
        "catalog_books": len(app_books),
        "catalog_book_editions": len(app_edition_ids),
        "catalog_books_with_covers": sum(
            1
            for b in app_books
            if any(text(e.get("coverUrl")) for e in b.get("editions") or [])
        ),
        "catalog_books_with_bundled_covers": sum(
            1
            for b in app_books
            if any(text(e.get("coverAssetPath")) for e in b.get("editions") or [])
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
