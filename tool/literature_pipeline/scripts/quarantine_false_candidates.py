#!/usr/bin/env python3
"""Quarantine high-confidence textbook prose accidentally extracted as poems.

The corpus extractor intentionally produces review candidates, but a small
number of exercise prompts and biographical paragraphs were given poem-shaped
records.  This pass is deliberately conservative: it only changes
``needsReview`` records whose title contains an unmistakable classroom
instruction/question or starts with a strong prose lead.  Page-checked records
and records with an inspected source image are never changed.

The command is dry-run by default.  Use ``--write`` after reviewing the report.
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[3]
DEFAULT_WORKS = ROOT / "assets/data/literature/works.json"

# These phrases are classroom instructions or questions in the held textbooks,
# not titles or poetic incipits.  Keep word boundaries around short tokens so
# ``Худоё`` is not mistaken for the question word ``оё``.
QUESTION_PATTERN = re.compile(
    r"(?:"
    r"шарҳ диҳед|ифоданок хонед|гӯед(?:,| ки)|фаҳмонед|нависед|"
    r"матнро хонед|мазмунашро|ба андешаи шумо|кадом мавзӯъ|чӣ тавр|"
    r"пурсиданд|ҷавоб дод|пурсиш|дар дафтаратон|маънидод кунед|"
    r"(?<!\w)кӣ\s+буд\?|кай\s+навишта\s+шудааст|"
    r"ба\s+ёд\s+оред|ҷудо\s+намоед|"
    r"диққат\s+диҳед|ишорат\s+кун(?:ед|ед)|аз\s+матн\s+.*ёфта|"
    r"(?<!\w)оё\b|аз ёд намоед|аз ёд карда|(?<!\w)бигӯед\b|"
    r"муайян кунед|хонед ва|"
    r"(?<!\w)кадом(?:е|ин)?\s+(?:аз\s+ин|ади|достон|асар|амир|калима|ҷумла)|"
    r"(?<!\w)мазмун(?:и|у)?\s+(?:ва\s+)?(?:мундариҷа|муҳтаво|мухтасар|шеър|ғазал|маснавӣ)|"
    r"(?<!\w)хулоса(?:атон|\s+ва\s+натиҷа)|"
    r"(?<!\w)соли\s+қатли|"
    r"(?<!\w)усто\s+\S+\s+чӣ\s+хел\s+одам"
    r"|ҳангоми\s+иҷрои\s+супориш|"
    r"ҷумла\s+.*\s+кадом\b|"
    r"аз\s+«?фарҳанги\s+забони\s+тоҷикӣ|"
    r"маънии\s+онҳоро\s+(?:ёбед|ёбе)|"
    r"(?<!\w)меҳмон\s+кист\b|"
    r"ташбеҳ\s+маънои|тавсиф\s+маънои|"
    r"бо\s+наср\s+иншо\s+шудаанд\s+ё\s+бо\s+назм"
    r")",
    re.IGNORECASE,
)

PROSE_LEAD_PATTERN = re.compile(
    r"^(?:"
    r"Соли\s+\d{3,4}|"
    r"Дар яке аз шабҳои\s|"
    r"Чунин овардаанд(?:,|\s)|"
    r"Рӯзе\s+[^,]{2,60}\s+(?:гуфт|шуд|омад|рафт|нишаст|имтиҳон)|"
    r"(?:Амир|Амири|Султон|Подшоҳ|Вазир|Беморонро|Бозаргон|Донишманди)\s+[^.!?]{2,80}\s+(?:гуфт|омад|рафт|шуд|буд|кард)|"
    r"(?:Абдуллоҳи|Аҳмад ибни|Муслиҳиддин)\s+[^.!?]{2,60}\s+соли\s+\d{3,4}|"
    r"Дар эҷодиёти\s|"
    r"Ҳамчунин,|"
    r"Хулоса,|"
    r"Аввалин маҷмӯаи\s|"
    r"Маҷмӯаи\s|"
    r"Маҷмӯаҳои\s|"
    r"Фаъолияти\s|"
    r"Ниёгони мо\s|"
    r"Лоиқ дар синни\s|"
    r"Ҳангоме ки\s|"
    r"Сабаби\s+ин\s|"
    r"Оид ба\s|"
    r"Инъикоси\s|"
    r"Маънои\s+(?:назм|байт|калима)|"
    r"Вазни\s+(?:ҳиҷо|арӯз)|"
    r"Аз мисолҳои китобатон\s|"
    r"Маънояш:\s|"
    r"маънояш:\s|"
    r"Шоири халқии\s|"
    r"Дар асари\s|"
    r"Дар роман\s|"
    r"Хулоса(?:\s+ва\s+натиҷа)|"
    r"Мазмун(?:и|у)?\s"
    r")",
    re.IGNORECASE,
)

# These are sentence-level openings or biography markers that are not poem
# titles.  The specific constructions are intentionally narrower than a
# generic "starts with Дaр/Бa" rule, because genuine verse can use those words.
NARRATIVE_FRAGMENT_PATTERN = re.compile(
    r"^(?:"
    r"Ду\s+(?:амирзода|дарвеш)\b|"
    r"Дарвеше\b|Бозоргоне\b|Араби\s+саҳроиеро\b|"
    r"Гӯянд(?:,|\s)|Овардаанд(?:,|\s)|"
    r"Аз\s+Нӯшервон\s+касе\s+пурсид\b|"
    r"Рӯзе(?:,|\s).*\b(?:имтиҳон|гуфт|пурсид|омад|рафт|шуд|буд)\b|"
    r"Тамоми\s+шаб\s+.*\.|Ҳамин\s+тавр\s+рӯз\s+.*\.|"
    r"Боди\s+хазон\s+.*\.|"
    r"Пас\s+ба\s+гӯшаи\s+саҳро\s+.*\b(?:рафтам|рафт)\b"
    r")",
    re.IGNORECASE,
)

BIOGRAPHY_FRAGMENT_PATTERN = re.compile(
    r"(?:"
    r"\bсоли\s+\d{3,4}\b.*\b(?:ба\s+дунё\s+омад|таваллуд|вафот|дар\s+шаҳри)\b|"
    r"\b(?:ба\s+дунё\s+омада|таваллуд\s+шуда|вафот\s+карда)\b|"
    r"\bумри\s+пурбаракат\s+дида\b"
    r")",
    re.IGNORECASE,
)

NUMBERED_EXERCISE_PATTERN = re.compile(r"^\s*\d+\s*[.)]")


def rejection_reason(work: dict[str, Any]) -> str | None:
    """Return a stable reason for an obvious false positive, if present."""

    verification = work.get("verification")
    if not isinstance(verification, dict):
        return None
    if verification.get("evidenceLevel") != "needsReview":
        return None
    primary = work.get("primarySource")
    if isinstance(primary, dict) and primary.get("sourceImageVerified") is True:
        return None

    title = str(work.get("title") or "").strip()
    if not title:
        return None

    if QUESTION_PATTERN.search(title):
        if NUMBERED_EXERCISE_PATTERN.search(title):
            return "extraction_false_positive:numbered textbook exercise or question"
        return "extraction_false_positive:textbook question or classroom instruction"
    if PROSE_LEAD_PATTERN.search(title):
        return "extraction_false_positive:biographical or explanatory prose fragment"
    if BIOGRAPHY_FRAGMENT_PATTERN.search(title):
        return "extraction_false_positive:biographical sentence fragment"
    if NARRATIVE_FRAGMENT_PATTERN.search(title):
        return "extraction_false_positive:narrative or dialogue sentence fragment"
    return None


def classify(works: list[dict[str, Any]]) -> list[tuple[dict[str, Any], str]]:
    """Return records that are safe to quarantine under the conservative rules."""

    return [
        (work, reason)
        for work in works
        if (reason := rejection_reason(work)) is not None
    ]


def apply(works: list[dict[str, Any]]) -> int:
    """Apply quarantine metadata and return the number changed."""

    changed = 0
    for work, reason in classify(works):
        verification = dict(work["verification"])
        verification["evidenceLevel"] = "rejected"
        verification["rejectionReason"] = reason
        verification["verificationMethod"] = "conservativeFalseCandidateQuarantine"
        work["verification"] = verification
        changed += 1
    return changed


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--works", type=Path, default=DEFAULT_WORKS)
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()

    with args.works.open(encoding="utf-8") as handle:
        works = json.load(handle)
    if not isinstance(works, list):
        raise SystemExit("works.json must contain a list")

    candidates = classify(works)
    print(f"High-confidence false candidates: {len(candidates)}")
    for work, reason in candidates:
        print(f"- {work['id']} | {reason} | {work.get('title', '')}")

    if not args.write:
        print("Dry-run only. Pass --write after reviewing the candidate list.")
        return

    changed = apply(works)
    with args.works.open("w", encoding="utf-8") as handle:
        json.dump(works, handle, ensure_ascii=False, indent=2)
        handle.write("\n")
    print(f"Quarantined {changed} records as rejected.")


if __name__ == "__main__":
    main()
