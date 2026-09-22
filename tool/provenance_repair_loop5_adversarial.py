#!/usr/bin/env python3
"""LOOP 5 — adversarial re-audit.

Treat the repaired dataset as an untrusted submission and try the failure
modes that caused the original integrity incident.  This script is read-only;
it delegates structural checks to the provenance linter and performs a second
raw-text sweep for fake pages, fake verification, fixed quotas, and generated
text masquerading as a source witness.
"""

from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
JSON_FILES = [
    ROOT / "assets/data/literature/poets.json",
    ROOT / "assets/data/literature/works.json",
    ROOT / "assets/data/history/entries.json",
    ROOT / "assets/data/history/books.json",
]


def main() -> int:
    failures: list[str] = []
    works = json.loads(JSON_FILES[1].read_text(encoding="utf-8"))
    history = json.loads(JSON_FILES[2].read_text(encoding="utf-8"))

    if any(
        work.get("persianScriptSource") == "generated"
        and work.get("scriptSource") == "both"
        for work in works
    ):
        failures.append("generated Persian representation is labeled scriptSource=both")
    if any(
        work.get("persianScriptSource") == "generated"
        and str(work.get("textPersian") or "").strip()
        for work in works
    ):
        failures.append("generated Persian representation remains in textPersian")
    if any(
        claim.get("status") in {"VERIFIED_UPLOADED_BOOK_PAGE", "VERIFIED_MAORIF_PAGE"}
        and claim.get("printedPage") is None
        and claim.get("pdfPage") is None
        for entry in history
        for claim in entry.get("claimProvenance", [])
    ):
        failures.append("page-verified history claim has no page")

    for path in JSON_FILES:
        raw = path.read_text(encoding="utf-8")
        if re.search(r'"(?:pdfPage|printedPage)"\s*:\s*1\b', raw):
            failures.append(f"placeholder page 1 remains in {path.relative_to(ROOT)}")
        if re.search(r'"(?:verifiedBy|approvedBy|editorialBoard)"\s*:', raw):
            failures.append(f"unreviewed verifier metadata remains in {path.relative_to(ROOT)}")

    linter = subprocess.run(
        [sys.executable, str(ROOT / "tool/provenance_linter.py")],
        cwd=ROOT,
        capture_output=True,
        text=True,
    )
    if linter.returncode != 0:
        failures.append("provenance_linter.py failed")
        sys.stderr.write(linter.stderr)

    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print("LOOP 5 ADVERSARIAL RE-AUDIT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
