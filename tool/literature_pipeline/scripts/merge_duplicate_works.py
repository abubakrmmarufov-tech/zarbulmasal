#!/usr/bin/env python3
"""Collapse exact same-author extraction duplicates into canonical works.

The merge is intentionally conservative: it only groups records with the same
normalized author/title/incipit, and only when every member is still
needsReview with no full text. Source records are retained as occurrences.
"""

from __future__ import annotations

import argparse
import json
import re
from collections import defaultdict
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[3]
WORKS_PATH = ROOT / "assets/data/literature/works.json"


def normalize(value: Any) -> str:
    return re.sub(r"[^\w\u0400-\u04ff\u0600-\u06ff]+", "", str(value or "").lower())


def duplicate_groups(works: list[dict[str, Any]]) -> list[list[dict[str, Any]]]:
    groups: dict[tuple[str, str, str], list[dict[str, Any]]] = defaultdict(list)
    for work in works:
        key = (str(work.get("authorId", "")), normalize(work.get("title")), normalize(work.get("incipit")))
        if key[1]:
            groups[key].append(work)
    return [group for group in groups.values() if len(group) > 1]


def _source_key(source: dict[str, Any]) -> str:
    return json.dumps(source, ensure_ascii=False, sort_keys=True)


def merge(works: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], int]:
    groups = duplicate_groups(works)
    by_id = {work["id"]: work for work in works}
    remove: set[str] = set()
    merged = 0
    for group in groups:
        if any(
            work.get("verification", {}).get("evidenceLevel") != "needsReview"
            or any(str(work.get(field) or "").strip() for field in ("textTajik", "textPersian"))
            for work in group
        ):
            continue
        canonical = group[0]
        occurrences: list[dict[str, Any]] = []
        seen: set[str] = set()
        for work in group:
            for field in ("primarySource", "secondarySource"):
                source = work.get(field)
                if isinstance(source, dict):
                    key = _source_key(source)
                    if key not in seen:
                        seen.add(key)
                        occurrences.append(source)
            if work["id"] != canonical["id"]:
                remove.add(work["id"])
        if occurrences:
            canonical["sourceOccurrences"] = occurrences
        else:
            canonical["sourceOccurrences"] = []
        prior_note = str(canonical.get("editorialNotes") or "").strip()
        merge_note = "Same-author extraction duplicates merged; source occurrences retained for review."
        canonical["editorialNotes"] = f"{prior_note} {merge_note}".strip()
        merged += len(group) - 1
    return [work for work in works if work["id"] not in remove], merged


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--apply", action="store_true")
    parser.add_argument("--works", type=Path, default=WORKS_PATH)
    args = parser.parse_args()
    works = json.loads(args.works.read_text(encoding="utf-8"))
    groups = duplicate_groups(works)
    safe = [
        group
        for group in groups
        if all(
            work.get("verification", {}).get("evidenceLevel") == "needsReview"
            and not any(str(work.get(field) or "").strip() for field in ("textTajik", "textPersian"))
            for work in group
        )
    ]
    print(f"duplicate groups: {len(groups)}; safe merge groups: {len(safe)}")
    if not args.apply:
        return
    merged, count = merge(works)
    args.works.write_text(json.dumps(merged, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"merged duplicate records: {count}; works remaining: {len(merged)}")


if __name__ == "__main__":
    main()
