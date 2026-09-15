#!/usr/bin/env python3
"""Locate possible author mentions in held Tajik literature textbooks.

This utility creates an editorial *candidate* index only. It records PDF page
ordinals, matched author names, and non-content review hints, never poem text,
printed page numbers, or approval decisions. A human must inspect the page
image and enter a specific printed page citation before a work or biography
can become verified.
"""

from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
from datetime import date
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_SOURCES = ROOT / "assets/data/literature/sources.json"
DEFAULT_AUTHORS = ROOT / "assets/data/literature/poets.json"
DEFAULT_OUTPUT = ROOT / "docs/literature/TEXTBOOK_AUTHOR_PAGE_CANDIDATES.json"

_LEGACY_TAJIK = str.maketrans(
    {
        "њ": "ҳ",
        "Њ": "Ҳ",
        "ќ": "қ",
        "Ќ": "Қ",
        "љ": "ҷ",
        "Љ": "Ҷ",
        "ѓ": "ғ",
        "Ѓ": "Ғ",
        "ў": "ӯ",
        "Ў": "Ӯ",
        "ї": "ӣ",
        "Ї": "Ӣ",
    }
)


def normalize_tajik(value: str) -> str:
    """Normalise legacy PDF Cyrillic and whitespace for literal matching."""
    return re.sub(r"\s+", " ", value.translate(_LEGACY_TAJIK).casefold()).strip()


def find_author_page_candidates(
    *, author_id: str, names: Iterable[str], pages: Iterable[tuple[int, str]]
) -> list[dict[str, Any]]:
    """Return literal author-name hits, retaining only page references."""
    normalized_names = [
        (name, normalize_tajik(name))
        for name in names
        if normalize_tajik(name)
    ]
    candidates: list[dict[str, Any]] = []
    for pdf_page, page_text in pages:
        normalized_page = normalize_tajik(page_text)
        for name, normalized_name in normalized_names:
            if normalized_name in normalized_page:
                candidates.append(
                    {
                        "authorId": author_id,
                        "pdfPage": pdf_page,
                        "matchedName": name,
                        "pageSignals": page_signals(page_text),
                    }
                )
                break
    return candidates


def extract_pdf_pages(pdf_path: Path) -> list[tuple[int, str]]:
    """Extract each PDF page's text without persisting copyrighted content."""
    if shutil.which("pdftotext") is None:
        raise RuntimeError("pdftotext is required to index textbook PDF pages.")
    process = subprocess.run(
        ["pdftotext", "-layout", str(pdf_path), "-"],
        check=True,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    return [
        (page_number, text)
        for page_number, text in enumerate(process.stdout.split("\f"), start=1)
        if text.strip()
    ]


def load_list(path: Path) -> list[dict[str, Any]]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, list):
        raise ValueError(f"Expected a JSON array in {path}")
    return [dict(item) for item in payload if isinstance(item, dict)]


def author_names(author: dict[str, Any]) -> list[str]:
    """Return the canonical name only; aliases are too ambiguous for indexing."""
    canonical_name = str(author.get("canonicalName") or "").strip()
    return [canonical_name] if len(normalize_tajik(canonical_name)) >= 4 else []


def page_signals(page_text: str) -> list[str]:
    """Return review hints without retaining copyrighted page text."""
    normalized = normalize_tajik(page_text)
    signals: list[str] = []
    if re.search(r"(?m)^\s*\d+[.)]\s", page_text):
        signals.append("question_numbering")
    if re.search(r"\b(?:шеър|ашъор|байт|ғазал|рубоӣ|қасида)\b", normalized):
        signals.append("poetry_cue")
    if re.search(
        r"\b(?:биография|зиндагӣ|таваллуд|вафот|даргузашт|шоир)\b", normalized
    ):
        signals.append("biography_cue")
    return signals or ["name_hit_only"]


def build_candidate_index(
    sources: Iterable[dict[str, Any]], authors: Iterable[dict[str, Any]]
) -> dict[str, Any]:
    """Build a no-text review queue for every held official textbook."""
    textbook_sources = [
        source
        for source in sources
        if source.get("sourceType") == "official-textbook"
        and str(source.get("sourceReference") or "").endswith(".pdf")
    ]
    results: list[dict[str, Any]] = []
    for source in textbook_sources:
        reference = Path(str(source["sourceReference"]))
        pdf_path = reference if reference.is_absolute() else ROOT / reference
        if not pdf_path.is_file():
            results.append(
                {
                    "sourceId": source.get("id"),
                    "sourceReference": str(reference),
                    "reviewStatus": "sourceUnavailable",
                    "candidates": [],
                }
            )
            continue

        pages = extract_pdf_pages(pdf_path)
        candidates: list[dict[str, Any]] = []
        for author in authors:
            author_id = str(author.get("id") or "").strip()
            if not author_id:
                continue
            candidates.extend(
                find_author_page_candidates(
                    author_id=author_id,
                    names=author_names(author),
                    pages=pages,
                )
            )
        results.append(
            {
                "sourceId": source.get("id"),
                "sourceReference": str(reference),
                "pdfPageCount": len(pages),
                "reviewStatus": "candidateOnly",
                "candidates": candidates,
            }
        )

    return {
        "generatedOn": date.today().isoformat(),
        "purpose": (
            "Literal author-name hits for manual page review; not a citation, "
            "text witness, rights decision, or approval record. pageSignals "
            "are non-content hints only."
        ),
        "sources": results,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--sources", type=Path, default=DEFAULT_SOURCES)
    parser.add_argument("--authors", type=Path, default=DEFAULT_AUTHORS)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    args = parser.parse_args()

    index = build_candidate_index(load_list(args.sources), load_list(args.authors))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(
        json.dumps(index, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    source_count = len(index["sources"])
    candidate_count = sum(len(source["candidates"]) for source in index["sources"])
    print(f"Indexed {source_count} textbook PDFs; wrote {candidate_count} review candidates.")
    print(f"No poem or biography was approved: {args.output}")


if __name__ == "__main__":
    main()
