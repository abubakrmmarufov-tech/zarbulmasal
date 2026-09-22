#!/usr/bin/env python3
"""
LOOP 2 — LITERATURE REPAIR

Make every literary record say what its Persian-script fields actually are.
The bundled literature PDFs are Tajik-Cyrillic textbooks.  A Persian-looking
field generated from those pages is therefore a script representation, not a
Persian source witness and not a semantic translation.

This loop is intentionally conservative:
* all current Persian poem fields are moved to an explicit generated field;
* unsupported rights claims are reset to ``unknown``;
* biography provenance is classified without expanding the corpus;
* unsupported template biographies are removed from active display.
"""

import json
import os
from pathlib import Path
import copy
import re

ROOT = Path(__file__).parent.parent
WORKS_PATH = ROOT / "assets/data/literature/works.json"
PAGE_IMAGES_DIR = ROOT / "assets/data/literature/page_images"


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_json(path, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"✅ Saved: {path}")


def get_existing_images():
    if PAGE_IMAGES_DIR.exists():
        return {f.name for f in PAGE_IMAGES_DIR.iterdir() if f.is_file()}
    return set()


def has_real_image(work, existing_images):
    src = work.get("primarySource") or {}
    path = src.get("sourceImagePath", "")
    if not path:
        return False
    fname = os.path.basename(path)
    return fname in existing_images


def main():
    works = load_json(WORKS_PATH)
    poets = load_json(ROOT / "assets/data/literature/poets.json")
    existing_images = get_existing_images()

    print(f"Total works: {len(works)}")
    print(f"Existing page images: {len(existing_images)}")

    repaired_script_source = 0
    repaired_persian_fields = 0
    repaired_rights = 0
    repaired_text_status = 0
    quarantined_full_text = 0
    quarantined_excerpts = 0
    removed_biographies = 0
    manual_bio_ids = {
        # These records were re-opened against the cited local textbook pages
        # during the manual sample audit (see docs/content/PROVENANCE_MANUAL_SAMPLE_AUDIT.md).
        "rudaki",
        "nasir_khusraw",
        "kamol_khujandi",
        "tursunzoda",
        "qanoat",
        "loiq_sherali",
        "bozor_sobir",
        "gulnazar_keldi",
        "gulrukhsor",
        "farzona",
        "47c1dc67-363a-4506-8a9c-bbbb38f98d20",
        "455f0420-3834-48f0-86b9-7da673a2a684",
        "d1abb54a-9804-4baf-b238-fd2203d7673e",
        "1a55efdd-6a1f-43b8-834f-94af060b4329",
        "be19709e-c3af-460d-80b9-4c67046e8be3",
        "d48ec80f-951d-4dfd-b65a-6e409561a712",
        "282f4c69-1d14-4be2-89d3-d21f867e4964",
        "1c82210c-343c-4499-9639-93f0a766b5f7",
        "8231eb1a-ac35-46d2-9e39-19d5603bfcec",
        "92753b88-1d31-4f79-aae4-5d36c83ab4a1",
    }

    repaired_works = []

    for w in works:
        w = copy.deepcopy(w)
        changed = False
        src = w.get("primarySource") or {}
        ver = w.get("verification") or {}

        # ── Fix 1: script and Persian fields ──────────────────────
        # Every bundled textbook witness is Tajik Cyrillic.  The existing
        # Persian strings are mechanical representations, including the 12
        # page-image-backed works.
        persian_text = w.get("textPersian")
        if persian_text and not w.get("persianScriptRepresentation"):
            w["persianScriptRepresentation"] = persian_text
            repaired_persian_fields += 1
            changed = True
        if w.get("persianScriptRepresentation"):
            if w.get("textPersian") is not None:
                w["textPersian"] = None
                changed = True
            if w.get("scriptSource") != "tajikOnly":
                w["scriptSource"] = "tajikOnly"
                repaired_script_source += 1
                changed = True
            if w.get("persianScriptSource") != "generated":
                w["persianScriptSource"] = "generated"
                changed = True
            if w.get("editorial") != "transliteration":
                w["editorial"] = "transliteration"
                changed = True
            note = (
                "Mechanical Tajik Cyrillic to Persian-script representation; "
                "not a Persian source witness or semantic translation."
            )
            if w.get("editorialNotes") != note:
                w["editorialNotes"] = note
                changed = True
        if w.get("titlePersian") and w.get("titlePersianSource") is None:
            w["titlePersianSource"] = "generated"
            changed = True

        # ── Fix 2: sourceImageVerified ───────────────────────────
        # Keep this flag only when the referenced local image actually exists.
        if src.get("sourceImageVerified") is True:
            if not has_real_image(w, existing_images):
                src["sourceImageVerified"] = False
                w["primarySource"] = src
                changed = True

        # ── Fix 3: textStatus contradiction ─────────────────────
        # textStatus='verified' + evidenceLevel='needsReview' is contradictory.
        # The evidenceLevel is the authoritative field here (set by the validator).
        # Downgrade textStatus to 'needsReview' where they contradict.
        ev = ver.get("evidenceLevel", "")
        if w.get("textStatus") == "verified" and ev in ("needsReview", "", None):
            w["textStatus"] = "needsReview"
            repaired_text_status += 1
            changed = True

        # ── Fix 4: rights ────────────────────────────────────────
        # Textbook inclusion and author age are not rights evidence.  No
        # permitted rights document is attached to these records, so remove
        # the unsupported public-domain/excerpt claims.
        rights = w.get("rights") or {}
        if rights.get("status") != "unknown":
            w["rights"] = {
                "status": "unknown",
                "reasoning": (
                    "Rights status is not established by the uploaded source "
                    "record or maorif.tj; previous claim removed."
                ),
                "fullTextAllowed": False,
                "excerptAllowed": False,
            }
            repaired_rights += 1
            changed = True

        # ── Fix 5: distribution quarantine ──────────────────────
        # A textbook scan is evidence of location, not permission to ship its
        # text.  Keep titles and source metadata, but remove full text and
        # excerpts until a separate rights record authorizes publication.
        if rights.get("fullTextAllowed") is not True:
            for field in (
                "textTajik",
                "textPersian",
                "persianScriptRepresentation",
            ):
                if w.get(field):
                    w[field] = None
                    quarantined_full_text += 1
                    changed = True
            if w.get("textStatus") != "needsReview":
                w["textStatus"] = "needsReview"
                repaired_text_status += 1
                changed = True
        if rights.get("excerptAllowed") is not True and w.get("incipit"):
            w["incipit"] = None
            quarantined_excerpts += 1
            changed = True

        repaired_works.append(w)

    print(f"\nREPAIRS MADE:")
    print(f"  scriptSource fixed: {repaired_script_source}")
    print(f"  Persian fields moved: {repaired_persian_fields}")
    print(f"  rights claims reset: {repaired_rights}")
    print(f"  textStatus corrected: {repaired_text_status}")
    print(f"  full-text fields quarantined: {quarantined_full_text}")
    print(f"  excerpts quarantined: {quarantined_excerpts}")

    repaired_poets = []
    template_source = "«Адабиёти тоҷик», нашрияи «Маориф», Душанбе"
    page_pattern = re.compile(r"(?:с\.|ص\.|page)\s*\d+", re.IGNORECASE)
    template_phrase = "аз чеҳраҳои шинохташудаи мероси адабӣ"
    for poet in poets:
        poet = copy.deepcopy(poet)
        source = poet.get("biographySource") or ""
        bio = poet.get("biographyTj", "") or ""
        is_template = source == template_source or template_phrase in bio
        has_page = bool(page_pattern.search(source))
        if is_template or not has_page or not bio.strip():
            poet["biographyTj"] = ""
            poet["biographyFa"] = None
            poet["biographyTjProvenance"] = "UNSUPPORTED_GENERATED"
            poet["biographyFaProvenance"] = "UNSUPPORTED_GENERATED"
            poet["biographyQuarantineNote"] = (
                "Removed from active display: unsupported/generated biography "
                "had no auditable permitted-source page."
            )
            removed_biographies += 1
        else:
            poet["biographyTjProvenance"] = (
                "SOURCE_BACKED" if poet.get("id") in manual_bio_ids
                else "EDITORIAL_SUMMARY_FROM_SOURCES"
            )
            poet["biographyFaProvenance"] = "EDITORIAL_TRANSLATION"

        # No attached rights evidence authorizes a public-domain assertion.
        rights = poet.get("rights") or {}
        if rights.get("status") != "unknown":
            poet["rights"] = {
                "status": "unknown",
                "reasoning": (
                    "Rights status is not established by the uploaded source "
                    "record or maorif.tj; previous claim removed."
                ),
                "fullTextAllowed": False,
                "excerptAllowed": False,
            }
        repaired_poets.append(poet)

    save_json(WORKS_PATH, repaired_works)
    save_json(ROOT / "assets/data/literature/poets.json", repaired_poets)
    return {
        "scriptSource_fixed": repaired_script_source,
        "persian_fields_moved": repaired_persian_fields,
        "rights_reset": repaired_rights,
        "textStatus_fixed": repaired_text_status,
        "full_text_quarantined": quarantined_full_text,
        "excerpts_quarantined": quarantined_excerpts,
        "unsupported_biographies_removed": removed_biographies,
    }


if __name__ == "__main__":
    main()
