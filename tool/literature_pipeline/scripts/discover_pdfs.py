import json
import re
from pathlib import Path

import fitz  # PyMuPDF


ROOT = Path(__file__).resolve().parents[3]
PDF_DIR = ROOT / "docs/literature/pdfs"
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


pdfs = sorted(PDF_DIR.glob("*.pdf"), key=pdf_sort_key)
missing_sources = [
    pdf.name for pdf in pdfs if pdf.name not in source_by_filename
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

for pdf in pdfs:
    source = source_by_filename[pdf.name]
    grade_match = re.search(r"sinfi\s+(\d+)", pdf.name.lower())
    book_title = str(source.get("bookTitle") or "—")
    if grade_match and "синфи" not in book_title.lower():
        book_title = f"{book_title}, синфи {grade_match.group(1)}"
    with fitz.open(pdf) as document:
        num_pages = len(document)
        sample = "".join(
            document[index].get_text()
            for index in range(min(3, num_pages))
        )

    quality = (
        "Text extract available; held PDF"
        if len(sample.strip()) > 100
        else "Requires OCR; held PDF"
    )
    inventory_lines.append(
        "| "
        + " | ".join(
            (
                f"`{pdf.name}`",
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
        "checked-in PDF files. PDF page counts are not printed page citations.",
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
