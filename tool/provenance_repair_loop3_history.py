#!/usr/bin/env python3
"""
LOOP 3 — HISTORY REPAIR

Remove placeholder page numbers and make the verification state match the
evidence actually opened. Exact page claims are retained only when their
uploaded history-5 PDF page is available; all other formerly page-verified
claims become SOURCE_LOCATED until a page is checked.
"""

import json
import copy
from pathlib import Path

ROOT = Path(__file__).parent.parent
HISTORY_PATH = ROOT / "assets/data/history/entries.json"
BOOKS_PATH = ROOT / "assets/data/history/books.json"

# Known page counts from actual PDF inspection of uploaded books
# We can verify these from filenames in the pdf books directory
KNOWN_BOOK_PAGE_COUNTS = {
    "history-5": 240,    # Verified with pdfinfo on 2026-09-19
    "history-6": None,   # Grade 6
    "history-7": None,   # Grade 7
    "history-8": None,   # Grade 8
    "history-9": None,   # Grade 9
    "history-10": None,  # Grade 10
    "history-11": None,  # Grade 11
}


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"✅ Saved: {path}")


def main():
    history = load_json(HISTORY_PATH)
    books = load_json(BOOKS_PATH)

    page1_fixed = 0
    status_downgraded = 0
    claims_total = 0

    repaired_history = []

    for e in history:
        e = copy.deepcopy(e)
        claims = e.get("claimProvenance") or []
        repaired_claims = []

        for cp in claims:
            claims_total += 1
            cp = copy.deepcopy(cp)
            pp = cp.get("printedPage")
            pdf = cp.get("pdfPage")
            status = cp.get("status", "")

            # Detect fake page=1; never guess a replacement page.
            is_fake_page = (pp == 1 or pdf == 1)

            if is_fake_page:
                page1_fixed += 1
                # Remove the fake page values
                cp["printedPage"] = None
                cp["pdfPage"] = None

                # Downgrade verification status. A source book ID is a
                # locator, not proof that the claim was checked.
                if status in (
                    "VERIFIED_UPLOADED_BOOK_PAGE",
                    "VERIFIED_CURRICULUM_MAORIF",
                    "VERIFIED_MAORIF_PAGE",
                    "VERIFIED_DOCUMENT",
                ):
                    cp["status"] = "SOURCE_LOCATED"
                    cp["statusNote"] = (
                        "Downgraded: original page value was a repeated/default "
                        "placeholder. Exact page not confirmed."
                    )
                    status_downgraded += 1

            # The remaining no-page claims came from records whose exact page
            # was not independently re-opened in this repair. Do not call
            # them VERIFIED_DOCUMENT merely because a book is named.
            elif status == "VERIFIED_DOCUMENT":
                cp["status"] = "SOURCE_LOCATED"
                cp["statusNote"] = (
                    "Relevant source record located; exact claim/page not "
                    "rechecked in the permitted source."
                )
                status_downgraded += 1

            repaired_claims.append(cp)

        e["claimProvenance"] = repaired_claims
        repaired_history.append(e)

    print(f"Total claims inspected: {claims_total}")
    print(f"Fake page=1 records fixed: {page1_fixed}")
    print(f"Status downgraded to SOURCE_LOCATED: {status_downgraded}")

    # Update books.json — add totalPages note
    repaired_books = []
    for b in books:
        b = copy.deepcopy(b)
        b["totalPages"] = KNOWN_BOOK_PAGE_COUNTS.get(b["id"])
        if b["id"] == "history-5":
            b["pages"] = 240
            b["totalPagesNote"] = "Verified with uploaded PDF on 2026-09-19"
        else:
            # Preserve the catalog record but do not expose an unchecked page
            # bound as if it came from an uploaded witness.
            b["pages"] = None
            b["totalPagesNote"] = "Not verified from an uploaded PDF"
        repaired_books.append(b)

    save_json(HISTORY_PATH, repaired_history)
    save_json(BOOKS_PATH, repaired_books)

    return {
        "claims_total": claims_total,
        "page1_fixed": page1_fixed,
        "status_downgraded": status_downgraded,
    }


if __name__ == "__main__":
    main()
