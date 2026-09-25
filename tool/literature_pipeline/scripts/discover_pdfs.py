"""Writes docs/literature/SOURCE_INVENTORY.md from the textbook PDF manifest.

The textbook PDFs are kept outside the repository. Their identity is
committed in docs/literature/pdfs/MANIFEST.json (file, bytes, SHA-256, PDF
page count, whether a text layer exists). When copies are present locally
they must match the manifest byte for byte.

    python3 tool/literature_pipeline/scripts/discover_pdfs.py
    python3 tool/literature_pipeline/scripts/discover_pdfs.py --update-manifest

--update-manifest re-reads the local PDFs (needs PyMuPDF) and rewrites the
manifest; use it only when a textbook PDF is deliberately replaced.
"""

import hashlib
import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[3]
PDF_DIR = ROOT / "docs/literature/pdfs"
MANIFEST_PATH = PDF_DIR / "MANIFEST.json"
SOURCES_PATH = ROOT / "assets/data/literature/sources.json"
INVENTORY_PATH = ROOT / "docs/literature/SOURCE_INVENTORY.md"


def markdown_cell(value: object) -> str:
    return str(value or "—").replace("|", "\\|").replace("\n", " ")


sources = json.loads(SOURCES_PATH.read_text(encoding="utf-8"))
source_by_filename = {
    Path(source["sourceReference"]).name: source
    for source in sources
    if str(source.get("sourceReference", "")).startswith("docs/literature/pdfs/")
}



def pdf_sort_key(pdf: Path) -> tuple[int, str]:
    match = re.search(r"sinfi\s+(\d+)", pdf.name.lower())
    return (int(match.group(1)) if match else 999, pdf.name.lower())


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1 << 20), b""):
            digest.update(block)
    return digest.hexdigest()


def update_manifest() -> None:
    import fitz  # PyMuPDF; only needed when the PDFs themselves are re-read

    entries = []
    for pdf in sorted(PDF_DIR.glob("*.pdf"), key=pdf_sort_key):
        with fitz.open(pdf) as document:
            pages = len(document)
            sample = "".join(
                document[index].get_text() for index in range(min(3, pages))
            )
        entries.append(
            {
                "file": pdf.name,
                "bytes": pdf.stat().st_size,
                "sha256": sha256(pdf),
                "pdfPages": pages,
                "textLayer": len(sample.strip()) > 100,
            }
        )
    if not entries:
        raise SystemExit(f"No PDFs in {PDF_DIR} to build the manifest from.")
    MANIFEST_PATH.write_text(
        json.dumps({"pdfs": entries}, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(entries)} PDFs to {MANIFEST_PATH}.")


if "--update-manifest" in sys.argv[1:]:
    update_manifest()

manifest = {
    entry["file"]: entry
    for entry in json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))["pdfs"]
}
# Local copies, when present, must be the exact files the manifest names.
for pdf in PDF_DIR.glob("*.pdf"):
    entry = manifest.get(pdf.name)
    if entry is None:
        raise SystemExit(
            f"{pdf.name} is not in {MANIFEST_PATH.name}; "
            "run with --update-manifest if it is a new textbook."
        )
    if pdf.stat().st_size != entry["bytes"] or sha256(pdf) != entry["sha256"]:
        raise SystemExit(f"{pdf.name} does not match its manifest SHA-256.")

pdfs = sorted(manifest.values(), key=lambda entry: pdf_sort_key(Path(entry["file"])))
missing_sources = [
    entry["file"] for entry in pdfs if entry["file"] not in source_by_filename
]
if missing_sources:
    raise SystemExit(
        "No active source record for uploaded PDF(s): "
        + ", ".join(missing_sources)
    )

duplicate_sources = [
    filename
    for filename in source_by_filename
    if sum(
        Path(source.get("sourceReference", "")).name == filename
        for source in sources
    )
    != 1
]
if duplicate_sources:
    raise SystemExit(
        "Uploaded PDF(s) must map to exactly one active source record: "
        + ", ".join(sorted(duplicate_sources))
    )

inventory_lines = [
    "# Source Inventory",
    "",
    "| Filename | Book title | Author/editor as printed | Publisher | Year | Edition | ISBN | PDF pages | Text quality / evidence status |",
    "|---|---|---|---|---:|---|---|---:|---|",
]

for entry in pdfs:
    name = entry["file"]
    source = source_by_filename[name]
    grade_match = re.search(r"sinfi\s+(\d+)", name.lower())
    book_title = str(source.get("bookTitle") or "—")
    if grade_match and "синфи" not in book_title.lower():
        book_title = f"{book_title}, синфи {grade_match.group(1)}"
    num_pages = entry["pdfPages"]
    quality = (
        "Text extract available; held PDF"
        if entry["textLayer"]
        else "Requires OCR; held PDF"
    )
    inventory_lines.append(
        "| "
        + " | ".join(
            (
                f"`{name}`",
                f"*{markdown_cell(book_title)}*",
                markdown_cell(source.get("authorAsPrinted")),
                markdown_cell(
                    ", ".join(
                        value
                        for value in (
                            source.get("publisher"),
                            source.get("city"),
                        )
                        if value
                    )
                ),
                markdown_cell(source.get("year")),
                markdown_cell(source.get("edition")),
                markdown_cell(source.get("isbn")),
                str(num_pages),
                f"{quality}; source record `{source['id']}`",
            )
        )
        + " |"
    )

inventory_lines.extend(
    [
        "",
        "This inventory is generated from the active source records and the",
        "PDF manifest (`docs/literature/pdfs/MANIFEST.json`). The PDFs are held",
        "outside the repository; the manifest records each file's SHA-256. PDF",
        "page counts are not printed page citations.",
        "A held PDF does not by itself establish publication rights or make a",
        "literary work displayable.",
    ]
)
remote_sources = [
    source
    for source in sources
    if str(source.get("sourceReference", "")).startswith("https://maorif.tj/")
]
for source in remote_sources:
    inventory_lines.extend(
        [
            f"The {source.get('year', 'undated')} edition is a separate remote `maorif.tj`",
            f"witness (`{source['id']}`) and is not a local uploaded PDF.",
        ]
    )
inventory_lines.append("")
INVENTORY_PATH.write_text("\n".join(inventory_lines), encoding="utf-8")
print(f"Synchronized {len(pdfs)} uploaded PDFs into {INVENTORY_PATH}.")
