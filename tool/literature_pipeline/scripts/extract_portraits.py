#!/usr/bin/env python3
"""Extract explicitly mapped textbook portraits and hydrate poets.json.

This script never discovers or assigns identities. Every author/page mapping
must already exist in portrait_sources.json, and only a portrait-oriented
embedded image from that exact PDF page is accepted.
"""

from __future__ import annotations

import argparse
from io import BytesIO
import json
from pathlib import Path
from typing import Any


ROOT = Path(__file__).resolve().parents[3]
PDF_DIR = ROOT / "docs/literature/pdfs"
PORTRAIT_DIR = ROOT / "assets/data/literature/portraits"
MANIFEST = ROOT / "assets/data/literature/portrait_sources.json"
POETS = ROOT / "assets/data/literature/poets.json"


def load_manifest(path: Path = MANIFEST) -> list[dict[str, Any]]:
    entries = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(entries, list) or not entries:
        raise ValueError("portrait manifest must be a non-empty list")
    seen: set[str] = set()
    for entry in entries:
        author_id = entry.get("authorId")
        pdf_page = entry.get("pdfPage")
        pdf_name = entry.get("pdf")
        if not isinstance(author_id, str) or not author_id.strip():
            raise ValueError(f"invalid authorId: {entry!r}")
        if author_id in seen:
            raise ValueError(f"duplicate portrait authorId: {author_id}")
        if not isinstance(pdf_name, str) or Path(pdf_name).name != pdf_name:
            raise ValueError(f"PDF must be a basename: {entry!r}")
        if not isinstance(pdf_page, int) or pdf_page < 1:
            raise ValueError(f"PDF page must be positive: {entry!r}")
        seen.add(author_id)
    return entries


def _portrait_image(document: Any, page_number: int) -> tuple[bytes, str, int, int]:
    page = document.load_page(page_number - 1)
    candidates = []
    # Use image placement metadata, not only the PDF resource table. A PDF
    # page can retain an image object that is not actually painted on the
    # page; accepting that object would make a manifest entry look sourced
    # while extracting an unrelated portrait from the document.
    for image in page.get_image_info(xrefs=True):
        xref = int(image.get("xref", 0) or 0)
        bbox = image.get("bbox")
        if xref <= 0 or not isinstance(bbox, (tuple, list)) or len(bbox) != 4:
            continue
        x0, y0, x1, y1 = (float(value) for value in bbox)
        if x1 <= x0 or y1 <= y0:
            continue
        extracted = document.extract_image(xref)
        width = int(extracted.get("width", 0))
        height = int(extracted.get("height", 0))
        if height >= 150 and height >= width * 1.15:
            candidates.append((width * height, extracted))
    if not candidates:
        raise ValueError(f"no portrait-oriented embedded image on PDF page {page_number}")
    _, extracted = max(candidates, key=lambda item: item[0])
    return (
        extracted["image"],
        str(extracted.get("ext", "jpg")),
        int(extracted["width"]),
        int(extracted["height"]),
    )


def normalize_portrait(image: bytes, extension: str) -> bytes:
    """Normalize scan polarity without adding or removing identity features.

    A subset of the textbook scans stores monochrome portraits as negatives.
    Detecting a dark border with a lighter interior is conservative for these
    page crops; only those images are inverted. Other source pixels are kept.
    """
    try:
        from PIL import Image, ImageOps  # type: ignore
    except ImportError:  # pragma: no cover - environment setup error
        return image

    with Image.open(BytesIO(image)) as source:
        rgb = source.convert("RGB")
        width, height = rgb.size
        points = [
            rgb.getpixel((0, 0)),
            rgb.getpixel((width - 1, 0)),
            rgb.getpixel((0, height - 1)),
            rgb.getpixel((width - 1, height - 1)),
        ]
        corner_luma = sum(sum(pixel) / 3 for pixel in points) / len(points)
        center_luma = sum(rgb.getpixel((width // 2, height // 2))) / 3
        if corner_luma < 90 and center_luma > max(60, corner_luma + 15):
            rgb = ImageOps.invert(rgb)
        output = BytesIO()
        format_name = "PNG" if extension.lower() == "png" else "JPEG"
        save_args = {"format": format_name}
        if format_name == "JPEG":
            save_args.update(quality=92, optimize=True)
        rgb.save(output, **save_args)
        return output.getvalue()


def extract_assets(entries: list[dict[str, Any]], root: Path = ROOT) -> dict[str, str]:
    try:
        import fitz  # type: ignore
    except ImportError as exc:  # pragma: no cover - environment setup error
        raise RuntimeError("PyMuPDF is required to extract textbook portraits") from exc

    output: dict[str, str] = {}
    portrait_dir = root / "assets/data/literature/portraits"
    portrait_dir.mkdir(parents=True, exist_ok=True)
    for entry in entries:
        pdf_path = root / "docs/literature/pdfs" / entry["pdf"]
        if not pdf_path.is_file():
            raise FileNotFoundError(pdf_path)
        with fitz.open(pdf_path) as document:
            image, extension, width, height = _portrait_image(document, entry["pdfPage"])
        image = normalize_portrait(image, extension)
        target = portrait_dir / f"{entry['authorId']}.{extension}"
        target.write_bytes(image)
        output[entry["authorId"]] = f"assets/data/literature/portraits/{target.name}"
        print(f"{entry['authorId']}: {entry['pdf']} p.{entry['pdfPage']} -> {width}x{height} {target.name}")
    return output


def hydrate_poets(
    entries: list[dict[str, Any]],
    asset_paths: dict[str, str],
    poets_path: Path = POETS,
) -> None:
    poets = json.loads(poets_path.read_text(encoding="utf-8"))
    by_id = {poet.get("id"): poet for poet in poets}
    missing = [entry["authorId"] for entry in entries if entry["authorId"] not in by_id]
    if missing:
        raise ValueError(f"manifest author IDs missing from poets.json: {missing}")
    for entry in entries:
        by_id[entry["authorId"]]["portrait"] = {
            "assetPath": asset_paths[entry["authorId"]],
            "sourceType": "uploaded_book",
            "sourceReference": f"docs/literature/pdfs/{entry['pdf']}",
            "sourcePage": entry["pdfPage"],
            "sourceNote": "Portrait extracted from the author profile on the cited textbook page; scan polarity was normalized only where the source was a photographic negative; rights status remains unknown.",
            "rightsStatus": "unknown",
        }
    poets_path.write_text(
        json.dumps(poets, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--extract", action="store_true", help="extract image assets from the uploaded PDFs")
    parser.add_argument("--manifest", type=Path, default=MANIFEST)
    parser.add_argument("--poets", type=Path, default=POETS)
    args = parser.parse_args()
    entries = load_manifest(args.manifest)
    poets = json.loads(args.poets.read_text(encoding="utf-8"))
    poet_ids = {poet.get("id") for poet in poets}
    missing = sorted({entry["authorId"] for entry in entries} - poet_ids)
    if missing:
        raise SystemExit(f"manifest author IDs missing from poets.json: {missing}")
    if not args.extract:
        print(f"Validated {len(entries)} explicit portrait mappings.")
        return
    asset_paths = extract_assets(entries)
    hydrate_poets(entries, asset_paths, args.poets)
    print(f"Extracted and hydrated {len(asset_paths)} portraits.")


if __name__ == "__main__":
    main()
