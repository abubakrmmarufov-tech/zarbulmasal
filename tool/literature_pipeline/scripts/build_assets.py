#!/usr/bin/env python3
"""Merge extracted literature into the current JSON asset schema.

The command is deliberately dry-run by default. Extracted text is candidate
material, not publication evidence, so generated records remain needsReview,
have no invented page numbers, and cannot expose full text in the app.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import re
import uuid
from pathlib import Path
from typing import Any, Iterable


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_INPUT = ROOT / "docs/literature/extracted"
DEFAULT_POETS = ROOT / "assets/data/literature/poets.json"
DEFAULT_WORKS = ROOT / "assets/data/literature/works.json"


def normalized(value: Any) -> str:
    return re.sub(r"[^\w]+", "", str(value or "").casefold())


def stable_id(prefix: str, *parts: Any) -> str:
    key = "\x1f".join(normalized(part) for part in parts)
    digest = hashlib.sha1(f"{prefix}:{key}".encode("utf-8")).hexdigest()[:20]
    return f"{prefix}-{digest}"


def read_json(path: Path, fallback: Any) -> Any:
    if not path.exists():
        return fallback
    with path.open(encoding="utf-8") as handle:
        return json.load(handle)


def source_poets(payload: Any) -> Iterable[dict[str, Any]]:
    if isinstance(payload, dict) and isinstance(payload.get("poets"), list):
        yield from (item for item in payload["poets"] if isinstance(item, dict))
        return
    if isinstance(payload, dict):
        for name, poems in payload.items():
            if isinstance(poems, list):
                yield {"name": name, "poems": poems}
        return
    if isinstance(payload, list):
        for item in payload:
            if not isinstance(item, dict):
                continue
            if isinstance(item.get("poets"), list):
                yield from (poet for poet in item["poets"] if isinstance(poet, dict))
            elif item.get("poet") or item.get("name"):
                yield item


def load_extracted(input_dir: Path) -> list[dict[str, Any]]:
    records: list[dict[str, Any]] = []
    for path in sorted(input_dir.glob("*.json")):
        payload = read_json(path, None)
        for poet in source_poets(payload):
            record = dict(poet)
            record["_source"] = path.relative_to(ROOT).as_posix()
            records.append(record)
    return records


def split_lifespan(value: Any) -> tuple[str | None, str | None]:
    years = re.findall(r"(?:~|c\.\s*)?\d{3,4}", str(value or ""))
    return (years[0] if years else None, years[1] if len(years) > 1 else None)


def candidate_rights() -> dict[str, Any]:
    return {
        "status": "excerptOnly",
        "reasoning": "Extracted candidate; rights and edition provenance require per-record review.",
        "rightsSource": None,
        "fullTextAllowed": False,
        "excerptAllowed": True,
        "permissionReference": None,
    }


def candidate_verification() -> dict[str, Any]:
    return {
        "verifiedBy": None,
        "verifiedDate": None,
        "primarySourceChecked": False,
        "secondSourceChecked": False,
        "titleChecked": False,
        "authorshipChecked": False,
        "pageChecked": False,
        "textLineByLineChecked": False,
        "scriptChecked": False,
        "copyrightChecked": False,
        "finalStatus": "needsReview",
    }


def poem_text(poem: Any) -> str | None:
    if isinstance(poem, str):
        return poem.strip() or None
    if not isinstance(poem, dict):
        return None
    text = poem.get("text") or poem.get("content")
    if isinstance(text, str) and text.strip():
        return text.strip()
    lines = poem.get("lines")
    if isinstance(lines, list):
        joined = "\n".join(str(line).strip() for line in lines if str(line).strip())
        return joined or None
    return None


def poem_title(poem: Any, text: str | None) -> str:
    if isinstance(poem, dict) and str(poem.get("title") or "").strip():
        return str(poem["title"]).strip()
    if text:
        return text.splitlines()[0][:80].strip()
    return "Номи номаълум"


def source_edition(source: str) -> dict[str, Any]:
    return {
        "bookTitle": Path(source).stem,
        "authorAsPrinted": None,
        "editor": None,
        "volume": None,
        "edition": None,
        "publisher": "",
        "city": "",
        "year": "",
        "isbn": None,
        "pageStart": None,
        "pageEnd": None,
        "sourceInstitution": None,
        "sourceType": "official-textbook",
        "sourceReference": source,
        "accessDate": None,
        "sourceImageVerified": False,
    }


def build_candidates(
    extracted: list[dict[str, Any]],
    existing_poets: list[dict[str, Any]],
    existing_works: list[dict[str, Any]],
) -> tuple[list[dict[str, Any]], list[dict[str, Any]], int, int]:
    poets = list(existing_poets)
    works = list(existing_works)
    poet_ids = {normalized(item.get("canonicalName")): item["id"] for item in poets}
    work_keys = {
        (item.get("authorId"), normalized(item.get("title"))) for item in works
    }
    new_poets = 0
    new_works = 0

    for record in extracted:
        name = str(record.get("name") or record.get("poet") or "").strip()
        if not name:
            continue
        name_key = normalized(name)
        author_id = poet_ids.get(name_key)
        if author_id is None:
            author_id = stable_id("author", name)
            birth, death = split_lifespan(record.get("birth_death"))
            poets.append(
                {
                    "id": author_id,
                    "canonicalName": name,
                    "canonicalNamePersian": None,
                    "aliases": [],
                    "birthYear": birth,
                    "deathYear": death,
                    "birthPlace": None,
                    "literaryPeriod": "Extracted literature candidate; verify before publication",
                    "biographyTj": str(record.get("bio") or "").strip(),
                    "biographyFa": None,
                    "biographySource": record["_source"],
                    "majorWorkIds": [],
                    "officialTitles": [],
                    "educationGrades": [],
                    "rights": candidate_rights(),
                }
            )
            poet_ids[name_key] = author_id
            new_poets += 1

        poems = record.get("poems") or []
        if not isinstance(poems, list):
            continue
        for poem in poems:
            text = poem_text(poem)
            title = poem_title(poem, text)
            key = (author_id, normalized(title))
            if key in work_keys:
                continue
            works.append(
                {
                    "id": str(uuid.uuid5(uuid.NAMESPACE_URL, f"zarbulmasal:{author_id}:{normalized(title)}")),
                    "authorId": author_id,
                    "title": title,
                    "titlePersian": None,
                    "incipit": text.splitlines()[0].strip() if text else None,
                    "type": "poem",
                    "scriptSource": "tajikCyrillic",
                    "textTajik": text,
                    "textPersian": None,
                    "textStatus": "needsReview",
                    "editorial": "none",
                    "editorialNotes": str(poem.get("notes") or "").strip() if isinstance(poem, dict) else None,
                    "primarySource": source_edition(record["_source"]),
                    "secondarySource": None,
                    "textMatchResult": None,
                    "variantNotes": None,
                    "rights": candidate_rights(),
                    "verification": candidate_verification(),
                }
            )
            work_keys.add(key)
            new_works += 1

    return poets, works, new_poets, new_works


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input-dir", type=Path, default=DEFAULT_INPUT)
    parser.add_argument("--poets-output", type=Path, default=DEFAULT_POETS)
    parser.add_argument("--works-output", type=Path, default=DEFAULT_WORKS)
    parser.add_argument("--write", action="store_true", help="Write merged assets; default is dry-run")
    args = parser.parse_args()

    extracted = load_extracted(args.input_dir)
    poets, works, new_poets, new_works = build_candidates(
        extracted,
        read_json(args.poets_output, []),
        read_json(args.works_output, []),
    )
    print(f"Read {len(extracted)} extracted poet records.")
    print(f"Would preserve {len(poets) - new_poets} poets and add {new_poets} candidates.")
    print(f"Would preserve {len(works) - new_works} works and add {new_works} candidates.")
    if not args.write:
        print("Dry-run only. Pass --write after reviewing the generated candidate counts.")
        return

    for path, payload in ((args.poets_output, poets), (args.works_output, works)):
        path.parent.mkdir(parents=True, exist_ok=True)
        with path.open("w", encoding="utf-8") as handle:
            json.dump(payload, handle, ensure_ascii=False, indent=2)
            handle.write("\n")
    print("Wrote current literature JSON assets. Run both validators before committing.")


if __name__ == "__main__":
    main()
