#!/usr/bin/env python3
"""Align work citations with one verified source-catalog record.

The command is dry-run by default and only copies bibliographic metadata from
the selected active source record. It never changes page evidence, poem text,
author links, rights, or editorial/verification status. Run once per source ID
after visually checking the source's bibliographic page.
"""

from __future__ import annotations

import argparse
import json
import os
import stat
import tempfile
from copy import deepcopy
from dataclasses import dataclass
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_WORKS = ROOT / "assets/data/literature/works.json"
DEFAULT_SOURCES = ROOT / "assets/data/literature/sources.json"
SOURCE_FIELDS = (
    "bookTitle",
    "authorAsPrinted",
    "editor",
    "edition",
    "publisher",
    "city",
    "year",
    "isbn",
    "sourceType",
    "sourceInstitution",
)
SOURCE_SLOTS = ("primarySource", "secondarySource")


@dataclass(frozen=True)
class SyncPlan:
    works: list[dict[str, Any]]
    matched_citations: int
    changed_citations: int
    changed_fields: int


def _validate_source_reference(source_reference: Any) -> str:
    if not isinstance(source_reference, str) or not source_reference.strip():
        raise ValueError("selected source record must have a sourceReference")

    reference = source_reference.strip()
    if reference.startswith("https://maorif.tj/"):
        return reference

    if not reference.startswith("docs/literature/pdfs/"):
        raise ValueError(
            "sourceReference must point to an uploaded PDF or maorif.tj"
        )

    relative_path = Path(reference)
    if relative_path.is_absolute():
        raise ValueError("uploaded PDF sourceReference must be repository-relative")

    pdf_root = (ROOT / "docs/literature/pdfs").resolve()
    pdf_path = (ROOT / relative_path).resolve()
    try:
        pdf_path.relative_to(pdf_root)
    except ValueError as error:
        raise ValueError("uploaded PDF sourceReference escapes the PDF directory") from error
    if pdf_path.suffix.lower() != ".pdf" or not pdf_path.is_file():
        raise ValueError(f"uploaded source PDF does not exist: {reference}")
    return reference


def normalize_citations(
    works: list[dict[str, Any]],
    sources: list[dict[str, Any]],
    source_id: str,
) -> SyncPlan:
    """Return a copy with matching citations aligned to one catalog record."""
    if not isinstance(sources, list) or any(
        not isinstance(source, dict) for source in sources
    ):
        raise ValueError("source records must be objects")

    selected_sources = [source for source in sources if source.get("id") == source_id]
    if len(selected_sources) != 1:
        raise ValueError("sourceId must resolve to exactly one source record")

    source = selected_sources[0]
    source_reference = _validate_source_reference(source.get("sourceReference"))
    duplicate_references = [
        item
        for item in sources
        if isinstance(item.get("sourceReference"), str)
        and item["sourceReference"].strip() == source_reference
    ]
    if len(duplicate_references) != 1:
        raise ValueError("sourceReference must resolve to exactly one source record")

    canonical_fields: dict[str, str] = {}
    for field in SOURCE_FIELDS:
        value = source.get(field)
        if value in (None, ""):
            continue
        if not isinstance(value, str):
            raise ValueError(f"bibliographic field {field} must be a string")
        canonical_fields[field] = value
    if not canonical_fields:
        raise ValueError("selected source record has no bibliographic metadata")

    updated_works = deepcopy(works)
    matched_citations = 0
    changed_citations = 0
    changed_fields = 0

    for work in updated_works:
        if not isinstance(work, dict):
            raise ValueError("works.json must contain only object records")
        citations = [(slot, work.get(slot)) for slot in SOURCE_SLOTS]
        occurrences = work.get("sourceOccurrences")
        if occurrences is not None:
            if not isinstance(occurrences, list):
                raise ValueError("sourceOccurrences must be a list when present")
            if any(not isinstance(citation, dict) for citation in occurrences):
                raise ValueError("sourceOccurrences must contain objects")
            citations.extend(
                (f"sourceOccurrences[{index}]", citation)
                for index, citation in enumerate(occurrences)
            )

        for _slot, citation in citations:
            if not isinstance(citation, dict):
                continue
            citation_reference = citation.get("sourceReference")
            if (
                not isinstance(citation_reference, str)
                or citation_reference.strip() != source_reference
            ):
                continue

            matched_citations += 1
            changed_in_citation = 0
            for field, canonical_value in canonical_fields.items():
                if citation.get(field) != canonical_value:
                    citation[field] = canonical_value
                    changed_fields += 1
                    changed_in_citation += 1
            if changed_in_citation:
                changed_citations += 1

    return SyncPlan(
        works=updated_works,
        matched_citations=matched_citations,
        changed_citations=changed_citations,
        changed_fields=changed_fields,
    )


def _load_json(path: Path) -> Any:
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def _write_json_atomically(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    existing_mode = stat.S_IMODE(path.stat().st_mode) if path.exists() else 0o644
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            dir=path.parent,
            prefix=f".{path.name}.",
            suffix=".tmp",
            delete=False,
        ) as handle:
            temporary_path = Path(handle.name)
            json.dump(value, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary_path, existing_mode)
        os.replace(temporary_path, path)
    finally:
        if temporary_path is not None and temporary_path.exists():
            temporary_path.unlink()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-id", required=True)
    parser.add_argument("--works", type=Path, default=DEFAULT_WORKS)
    parser.add_argument("--sources", type=Path, default=DEFAULT_SOURCES)
    parser.add_argument(
        "--write",
        action="store_true",
        help="write the normalized works.json (default is dry-run)",
    )
    args = parser.parse_args()

    try:
        works = _load_json(args.works)
        sources = _load_json(args.sources)
        if not isinstance(works, list) or not isinstance(sources, list):
            raise ValueError("works and sources files must each contain a JSON list")
        plan = normalize_citations(works, sources, args.source_id)
    except (OSError, json.JSONDecodeError, ValueError) as error:
        parser.error(str(error))

    mode = "Wrote" if args.write else "Dry run"
    print(
        f"{mode}: source={args.source_id}; matched citations="
        f"{plan.matched_citations}; changed citations={plan.changed_citations}; "
        f"changed fields={plan.changed_fields}"
    )
    if args.write and plan.changed_fields:
        _write_json_atomically(args.works, plan.works)
        print(f"Updated {args.works}")
    elif not args.write:
        print("No files changed. Pass --write only after reviewing this source's metadata.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
