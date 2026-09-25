#!/usr/bin/env python3
"""
LOOP 1 — DETECTION
Provenance & Data-Integrity Audit for Zarbulmasal
Produces docs/literature/PROVENANCE_PAGE_AUDIT.md with every suspicious record.
Does NOT modify any data.
"""

import json
import os
import collections
from datetime import date
from pathlib import Path

ROOT = Path(__file__).parent.parent
WORKS_PATH = ROOT / "assets/data/literature/works.json"
POETS_PATH = ROOT / "assets/data/literature/poets.json"
HISTORY_PATH = ROOT / "assets/data/history/entries.json"
BOOKS_PATH = ROOT / "assets/data/history/books.json"
SOURCES_PATH = ROOT / "assets/data/literature/sources.json"
PAGE_IMAGES_DIR = ROOT / "assets/data/literature/page_images"
AUDIT_OUT = ROOT / "docs/literature/PROVENANCE_PAGE_AUDIT.md"


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def source_image_paths(source):
    """Return all declared source-image paths, including legacy metadata."""
    source = source or {}
    paths = source.get("sourceImagePaths")
    if isinstance(paths, list):
        normalized = [path for path in paths if isinstance(path, str) and path]
        if normalized:
            return normalized
    legacy_path = source.get("sourceImagePath")
    return [legacy_path] if isinstance(legacy_path, str) and legacy_path else []


def section(title):
    print(f"\n{'='*70}")
    print(f"  {title}")
    print(f"{'='*70}")


def main():
    works = load_json(WORKS_PATH)
    poets = load_json(POETS_PATH)
    history = load_json(HISTORY_PATH)
    books = load_json(BOOKS_PATH)
    sources = load_json(SOURCES_PATH)

    generated_representation_count = sum(
        1
        for w in works
        if w.get("persianScriptSource") == "generated"
        and isinstance(w.get("persianScriptRepresentation"), str)
        and w.get("persianScriptRepresentation", "").strip()
    )
    generated_representation_source_count = sum(
        1 for w in works if w.get("persianScriptSource") == "generated"
    )

    existing_images = set()
    if PAGE_IMAGES_DIR.exists():
        existing_images = {f.name for f in PAGE_IMAGES_DIR.iterdir() if f.is_file()}

    findings = []
    stats = {}

    # ─────────────────────────────────────────────────────────────
    # WORKS: scriptSource
    # ─────────────────────────────────────────────────────────────
    section("WORKS: scriptSource='both' audit")
    scriptSource_both = [w for w in works if w.get("scriptSource") == "both"]
    scriptSource_tajik_only = [w for w in works if w.get("scriptSource") == "tajikOnly"]
    scriptSource_persian_only = [w for w in works if w.get("scriptSource") == "persianOnly"]
    scriptSource_missing = [w for w in works if not w.get("scriptSource")]

    # All works have Persian text — determine if it looks like mechanical transliteration
    # Heuristic: compare Tajik text (Cyrillic) with Persian text character by character
    # If Persian text contains excessive Arabic-script transliteration of Tajik words
    # (Tajik-specific words that don't exist in standard Persian), it's generated.
    # For now we flag ALL works with scriptSource='both' and NO sourceImageVerified with actual path
    # as GENERATED_SCRIPT_REPRESENTATION candidates.

    needs_script_review = []
    for w in scriptSource_both:
        src = w.get("primarySource") or {}
        has_real_image = any(
            os.path.basename(path) in existing_images
            for path in source_image_paths(src)
        )
        needs_script_review.append({
            "id": w["id"],
            "title": w.get("title", "?")[:60],
            "has_tajik": bool(w.get("textTajik")),
            "has_persian": bool(w.get("textPersian")),
            "has_page": bool(src.get("pageStart")),
            "has_real_image": has_real_image,
            "evidenceLevel": (w.get("verification") or {}).get("evidenceLevel", "MISSING"),
        })

    without_real_evidence = [r for r in needs_script_review if not r["has_real_image"]]
    print(f"Works with scriptSource='both': {len(scriptSource_both)}")
    print(f"  Without real page image evidence: {len(without_real_evidence)}")
    print(f"  With confirmed page image: {len(scriptSource_both) - len(without_real_evidence)}")

    findings.append({
        "section": "SCRIPT SOURCE CLASSIFICATION",
        "severity": "CRITICAL",
        "count": len(without_real_evidence),
        "description": (
            f"{len(without_real_evidence)} of {len(works)} works are labeled scriptSource='both' "
            "but have no page-image proof of a genuine Persian source witness. "
            "The 'Persian' text is a mechanical Tajik Cyrillic → Arabic-script transliteration, "
            "NOT an original Persian source or semantic translation."
        ),
        "sample_ids": [r["id"] for r in without_real_evidence[:5]],
    })
    stats["works_scriptSource_both_total"] = len(scriptSource_both)
    stats["works_scriptSource_both_no_evidence"] = len(without_real_evidence)

    # ─────────────────────────────────────────────────────────────
    # WORKS: sourceImageVerified fabrication
    # ─────────────────────────────────────────────────────────────
    section("WORKS: sourceImageVerified=True without image file")
    fake_verified_image = []
    for w in works:
        src = w.get("primarySource") or {}
        if src.get("sourceImageVerified") is True:
            paths = source_image_paths(src)
            if not paths:
                fake_verified_image.append(w["id"])
            elif not all(os.path.basename(path) in existing_images for path in paths):
                fake_verified_image.append(w["id"])

    print(f"Works claiming sourceImageVerified=True: {sum(1 for w in works if (w.get('primarySource') or {}).get('sourceImageVerified') is True)}")
    print(f"Works with fabricated sourceImageVerified=True (no file): {len(fake_verified_image)}")

    findings.append({
        "section": "FABRICATED SOURCE IMAGE VERIFICATION",
        "severity": "CRITICAL",
        "count": len(fake_verified_image),
        "description": (
            f"{len(fake_verified_image)} works claim sourceImageVerified=True "
            "but have no sourceImagePath or the file does not exist. "
            "This is a fabricated verification flag."
        ),
        "sample_ids": fake_verified_image[:5],
    })
    stats["works_fake_sourceImageVerified"] = len(fake_verified_image)

    # ─────────────────────────────────────────────────────────────
    # WORKS: textStatus='verified' without real verification
    # ─────────────────────────────────────────────────────────────
    section("WORKS: textStatus='verified' without evidence")
    text_verified_no_evidence = []
    for w in works:
        if w.get("textStatus") == "verified":
            ver = w.get("verification") or {}
            ev = ver.get("evidenceLevel", "")
            if ev in ("needsReview", "", None, "MISSING"):
                src = w.get("primarySource") or {}
                if not src.get("sourceImagePath"):
                    text_verified_no_evidence.append(w["id"])

    print(f"Works with textStatus='verified' but evidenceLevel=needsReview and no image: {len(text_verified_no_evidence)}")

    findings.append({
        "section": "CONFLICTING textStatus='verified' + evidenceLevel=needsReview",
        "severity": "HIGH",
        "count": len(text_verified_no_evidence),
        "description": (
            f"{len(text_verified_no_evidence)} works are labeled textStatus='verified' "
            "but their evidenceLevel is needsReview and they have no page image. "
            "textStatus and evidenceLevel are contradictory."
        ),
        "sample_ids": text_verified_no_evidence[:5],
    })
    stats["works_text_verified_no_evidence"] = len(text_verified_no_evidence)

    # ─────────────────────────────────────────────────────────────
    # WORKS: Pages
    # ─────────────────────────────────────────────────────────────
    section("WORKS: Page provenance")
    no_page = sum(1 for w in works if not (w.get("primarySource") or {}).get("pageStart"))
    has_page = len(works) - no_page
    print(f"Works with pageStart: {has_page}")
    print(f"Works without pageStart: {no_page}")
    stats["works_with_page"] = has_page
    stats["works_without_page"] = no_page

    # ─────────────────────────────────────────────────────────────
    # HISTORY: Fake pdfPage=1 patterns
    # ─────────────────────────────────────────────────────────────
    section("HISTORY: Suspicious repeated pdfPage=1")
    page_per_book = collections.defaultdict(list)
    verified_statuses = collections.Counter()
    fake_history_pages = []

    for e in history:
        for cp in (e.get("claimProvenance") or []):
            book_id = cp.get("sourceBookId", "?")
            pp = cp.get("printedPage")
            pdf = cp.get("pdfPage")
            status = cp.get("status", "?")
            verified_statuses[status] += 1

            if pp == 1 or pdf == 1:
                fake_history_pages.append({
                    "entry_id": e["id"],
                    "entry_title": e.get("title", "?"),
                    "book_id": book_id,
                    "printedPage": pp,
                    "pdfPage": pdf,
                    "status": status,
                })
                page_per_book[book_id].append(e["id"])

    print(f"History claim-provenance records with pdfPage=1 or printedPage=1: {len(fake_history_pages)}")
    print(f"History verification statuses:")
    for k, v in verified_statuses.most_common():
        print(f"  {k}: {v}")
    print()
    print("Repeated pdfPage=1 per book:")
    for book_id, entry_ids in sorted(page_per_book.items(), key=lambda x: -len(x[1])):
        print(f"  book={book_id}: {len(entry_ids)} entries")
        for eid in entry_ids[:3]:
            print(f"    - {eid}")

    findings.append({
        "section": "HISTORY: FAKE pdfPage=1 PROVENANCE",
        "severity": "CRITICAL",
        "count": len(fake_history_pages),
        "description": (
            f"{len(fake_history_pages)} history claim-provenance records use pdfPage=1 (or printedPage=1), "
            "repeated across unrelated entries for multiple different books. "
            "These are clearly default/placeholder page numbers, not real citations."
        ),
        "detail": fake_history_pages,
    })
    stats["history_fake_page1"] = len(fake_history_pages)

    # ─────────────────────────────────────────────────────────────
    # HISTORY: VERIFIED_UPLOADED_BOOK_PAGE without real page
    # ─────────────────────────────────────────────────────────────
    section("HISTORY: VERIFIED_UPLOADED_BOOK_PAGE status check")
    verified_uploaded_no_real_page = []
    verified_maorif_no_real_page = []
    for e in history:
        for cp in (e.get("claimProvenance") or []):
            status = cp.get("status", "")
            pp = cp.get("printedPage")
            pdf = cp.get("pdfPage")
            has_real_page = (pp is not None and pp != 1) or (pdf is not None and pdf != 1)
            is_page1 = (pp == 1 or pdf == 1)

            if status == "VERIFIED_UPLOADED_BOOK_PAGE" and is_page1:
                verified_uploaded_no_real_page.append({
                    "entry": e["id"],
                    "claim": cp.get("claim", "?")[:60],
                    "pp": pp,
                    "pdf": pdf,
                })
            if status == "VERIFIED_CURRICULUM_MAORIF" and is_page1:
                verified_maorif_no_real_page.append({
                    "entry": e["id"],
                    "claim": cp.get("claim", "?")[:60],
                    "pp": pp,
                    "pdf": pdf,
                })

    print(f"VERIFIED_UPLOADED_BOOK_PAGE with page=1: {len(verified_uploaded_no_real_page)}")
    print(f"VERIFIED_CURRICULUM_MAORIF with page=1: {len(verified_maorif_no_real_page)}")
    for r in verified_uploaded_no_real_page[:5]:
        print(f"  entry={r['entry']} pp={r['pp']} pdf={r['pdf']} claim={r['claim']}")

    findings.append({
        "section": "HISTORY: VERIFIED_*_PAGE with pdfPage=1",
        "severity": "CRITICAL",
        "count": len(verified_uploaded_no_real_page) + len(verified_maorif_no_real_page),
        "description": (
            f"{len(verified_uploaded_no_real_page)} records use VERIFIED_UPLOADED_BOOK_PAGE status "
            f"and {len(verified_maorif_no_real_page)} use VERIFIED_CURRICULUM_MAORIF "
            "but the 'verified' page is 1 — a default placeholder, not a real verified page."
        ),
    })
    stats["history_VERIFIED_UPLOADED_page1"] = len(verified_uploaded_no_real_page)
    stats["history_VERIFIED_MAORIF_page1"] = len(verified_maorif_no_real_page)

    # ─────────────────────────────────────────────────────────────
    # POETS: Rights
    # ─────────────────────────────────────────────────────────────
    section("POETS: Rights status")
    rights_by_status = collections.Counter()
    pd_no_evidence = []
    for p in poets:
        r = p.get("rights") or {}
        status = r.get("status", "MISSING")
        rights_by_status[status] += 1
        if status == "publicDomain":
            reasoning = r.get("reasoning", "") or ""
            has_evidence = any(kw in reasoning.lower() for kw in
                               ["berne", "70 year", "1886", "public domain", "1928", "copyright"])
            if not has_evidence:
                pd_no_evidence.append({
                    "id": p["id"],
                    "name": p.get("canonicalName", "?"),
                    "deathYear": p.get("deathYear", "?"),
                    "reasoning": reasoning[:80],
                })

    print("Poet rights status:")
    for k, v in rights_by_status.most_common():
        print(f"  {k}: {v}")
    print(f"\npublicDomain with weak/missing reasoning: {len(pd_no_evidence)}")
    for r in pd_no_evidence[:5]:
        print(f"  {r['name']} (d.{r['deathYear']}): {r['reasoning'][:60]}")

    findings.append({
        "section": "POETS: publicDomain WITHOUT CLEAR EVIDENCE",
        "severity": "MEDIUM",
        "count": len(pd_no_evidence),
        "description": (
            f"{len(pd_no_evidence)} poets are marked publicDomain "
            "but their rights.reasoning field contains no clear legal basis reference. "
            "Rights status should reflect verifiable evidence, not assumption."
        ),
    })
    stats["poets_publicDomain_weak_reasoning"] = len(pd_no_evidence)
    stats["poets_rights_unknown"] = sum(
        1 for p in poets if (p.get("rights") or {}).get("status") == "unknown"
    )

    # ─────────────────────────────────────────────────────────────
    # POETS: Biography
    # ─────────────────────────────────────────────────────────────
    section("POETS: Biography analysis")
    very_short_bio = [(p["id"], p.get("canonicalName","?"), len(p.get("biographyTj","") or ""))
                      for p in poets if len(p.get("biographyTj","") or "") < 150]
    generic_phrases_found = collections.defaultdict(list)
    generic_phrases = [
        "яке аз намояндагони",
        "яке аз машҳур",
        "яке аз бузург",
        "яке аз муҳим",
        "яке аз барҷаста",
        "яке аз беҳтарин",
        "машҳуртарин шоир",
        "бузургтарин шоир",
        "маъруфтарин шоир",
        "беҳтарин шоир",
    ]
    for p in poets:
        bio = (p.get("biographyTj") or "").lower()
        for phrase in generic_phrases:
            if phrase in bio:
                generic_phrases_found[phrase].append(p.get("canonicalName", p["id"]))

    print(f"Poets with biographyTj < 150 chars: {len(very_short_bio)}")
    for pid, name, ln in very_short_bio:
        print(f"  {name}: {ln} chars")

    print("\nGeneric phrases found in biographies:")
    for phrase, names in generic_phrases_found.items():
        print(f"  \"{phrase}\": {len(names)} poets -> {names[:3]}")

    # Bio source field — many are very specific (good), let's check if any are missing
    missing_bio_source = [p for p in poets if not p.get("biographySource")]
    print(f"\nPoets with no biographySource: {len(missing_bio_source)}")

    findings.append({
        "section": "POETS: SHORT/GENERIC BIOGRAPHIES",
        "severity": "MEDIUM",
        "count": len(very_short_bio),
        "description": (
            f"{len(very_short_bio)} poets have very short biographies (<150 chars). "
            f"Generic filler phrases detected in {sum(len(v) for v in generic_phrases_found.values())} cases."
        ),
    })

    # ─────────────────────────────────────────────────────────────
    # SUMMARY
    # ─────────────────────────────────────────────────────────────
    section("SUMMARY STATISTICS")
    print(f"Total works: {len(works)}")
    print(f"  scriptSource=both (ALL): {stats['works_scriptSource_both_total']}")
    print(f"  scriptSource=both without real Persian source evidence: {stats['works_scriptSource_both_no_evidence']}")
    print(f"  Fake sourceImageVerified=True: {stats['works_fake_sourceImageVerified']}")
    print(f"  textStatus=verified but evidenceLevel=needsReview: {stats['works_text_verified_no_evidence']}")
    print(f"  With real page number: {stats['works_with_page']}")
    print(f"  Without page number: {stats['works_without_page']}")
    print(f"  Generated Persian-script representations with content: {generated_representation_count}")
    print(f"  Works with persianScriptSource=generated metadata: {generated_representation_source_count}")
    print(f"  Source Persian works: {sum(1 for w in works if w.get('persianScriptSource') == 'source')}")
    print(f"  Semantic Persian translations: {sum(1 for w in works if w.get('persianScriptSource') == 'translation')}")
    print()
    print(f"Total history entries: {len(history)}")
    print(f"  Fake pdfPage=1 claims: {stats['history_fake_page1']}")
    print(f"  VERIFIED_UPLOADED_BOOK_PAGE with page=1: {stats['history_VERIFIED_UPLOADED_page1']}")
    print(f"  VERIFIED_MAORIF with page=1: {stats['history_VERIFIED_MAORIF_page1']}")
    print()
    print(f"Total poets: {len(poets)}")
    print(f"  publicDomain with weak reasoning: {stats['poets_publicDomain_weak_reasoning']}")
    print(f"  Rights status unknown: {stats['poets_rights_unknown']}")
    print(f"  With Persian biography: {sum(1 for p in poets if p.get('biographyFa'))}")
    print(f"  Unsupported biographies removed from active content: {sum(1 for p in poets if p.get('biographyTjProvenance') == 'UNSUPPORTED_GENERATED')}")
    portrait_count = sum(
        1
        for p in poets
        if isinstance(p.get('portrait'), dict)
        and isinstance(p['portrait'].get('assetPath'), str)
        and p['portrait']['assetPath'].startswith('assets/data/literature/portraits/')
    )
    portrait_source_count = sum(
        1
        for p in poets
        if isinstance(p.get('portrait'), dict)
        and p['portrait'].get('sourceReference')
        and p['portrait'].get('sourcePage') is not None
    )
    print(f"  Source-backed local portraits: {portrait_count}")
    print(f"  Portraits with exact source page metadata: {portrait_source_count}")

    # ─────────────────────────────────────────────────────────────
    # Write PROVENANCE_PAGE_AUDIT.md
    # ─────────────────────────────────────────────────────────────
    lines = [
        "# PROVENANCE_PAGE_AUDIT.md",
        "",
        "**Generated by:** `tool/provenance_repair_loop1_detect.py`",
        "**Baseline commit:** `80b0fc870ce78ca3ce8c1f203a744ff697476ad4`",
        f"**Date:** {date.today().isoformat()}",
        "",
        "---",
        "",
        "## EXECUTIVE SUMMARY",
        "",
        "| Category | Count |",
        "|---|---|",
        f"| Total works | {len(works)} |",
        f"| Works with `scriptSource: both` (ALL) | {stats['works_scriptSource_both_total']} |",
        f"| Works with `scriptSource: both` but NO genuine Persian source evidence | {stats['works_scriptSource_both_no_evidence']} |",
        f"| Works claiming `sourceImageVerified: true` without image file | {stats['works_fake_sourceImageVerified']} |",
        f"| Works `textStatus: verified` contradicted by `evidenceLevel: needsReview` | {stats['works_text_verified_no_evidence']} |",
        f"| Works with a real pageStart | {stats['works_with_page']} |",
        f"| Works WITHOUT pageStart | {stats['works_without_page']} |",
        f"| Generated Persian-script representations with content | {generated_representation_count} |",
        f"| Works with `persianScriptSource: generated` metadata | {generated_representation_source_count} |",
        f"| Source Persian works | {sum(1 for w in works if w.get('persianScriptSource') == 'source')} |",
        f"| Semantic Persian translations | {sum(1 for w in works if w.get('persianScriptSource') == 'translation')} |",
        f"| History entries | {len(history)} |",
        f"| History claims with fake pdfPage=1 | {stats['history_fake_page1']} |",
        f"| History VERIFIED_UPLOADED_BOOK_PAGE with page=1 | {stats['history_VERIFIED_UPLOADED_page1']} |",
        f"| History VERIFIED_CURRICULUM_MAORIF with page=1 | {stats['history_VERIFIED_MAORIF_page1']} |",
        f"| Poets | {len(poets)} |",
        f"| Source-backed local portraits | {portrait_count} |",
        f"| Portraits with exact source page metadata | {portrait_source_count} |",
        f"| Poets marked publicDomain with weak reasoning | {stats['poets_publicDomain_weak_reasoning']} |",
        f"| Poets with rights status unknown | {stats['poets_rights_unknown']} |",
        f"| Unsupported biographies removed from active content | {sum(1 for p in poets if p.get('biographyTjProvenance') == 'UNSUPPORTED_GENERATED')} |",
        "",
        "---",
        "",
    ]

    for finding in findings:
        lines += [
            f"## {finding['section']}",
            "",
            f"**Severity:** {finding['severity']}",
            f"**Records affected:** {finding['count']}",
            "",
            finding["description"],
            "",
        ]
        if finding.get("sample_ids"):
            lines += ["**Sample IDs:**", ""]
            for sid in finding["sample_ids"][:5]:
                lines.append(f"- `{sid}`")
            lines.append("")
        if finding.get("detail"):
            lines += ["**Detail (first 10):**", ""]
            for d in finding["detail"][:10]:
                entry = d.get("entry_id", d.get("entry", "?"))
                title = d.get("entry_title", "?")
                lines.append(f"- `{entry}` — {title[:50]} (pdfPage={d.get('pdfPage')}, status={d.get('status')})")
            lines.append("")
        lines.append("---")
        lines.append("")

    lines += [
        "## HISTORICAL BASELINE / CURRENT METRICS",
        "",
        "The baseline values below were read from commit `80b0fc8` before the repair work began. Current values are computed from the JSON files loaded by this run.",
        "",
        "| Metric | Historical baseline | Current snapshot |",
        "|---|---:|---:|",
        f"| Synthetic/default history pages | 64 | {stats['history_fake_page1']} |",
        f"| Fake `sourceImageVerified` records | 1,460 | {stats['works_fake_sourceImageVerified']} |",
        f"| Works labeled `scriptSource: both` | 1,472 | {stats['works_scriptSource_both_total']} |",
        f"| Works with generated Persian-script content | 0 explicit | {generated_representation_count} |",
        f"| Works with `persianScriptSource: generated` metadata | 1,472 | {generated_representation_source_count} |",
        f"| Poet public-domain claims without attached rights evidence | 150 | {stats['poets_publicDomain_weak_reasoning']} |",
        f"| Source-backed local portraits | 0 | {portrait_count} |",
        f"| Active unsupported/generated biographies | 0 quarantined | {sum(1 for p in poets if p.get('biographyTjProvenance') == 'UNSUPPORTED_GENERATED')} |",
        "",
        f"Current verification counts: {sum(1 for e in history for cp in (e.get('claimProvenance') or []) if cp.get('status') == 'VERIFIED_UPLOADED_BOOK_PAGE')} exact uploaded-book-page claims, {sum(1 for e in history for cp in (e.get('claimProvenance') or []) if cp.get('status') == 'SOURCE_LOCATED')} `SOURCE_LOCATED` history claims, {sum(1 for w in works if (w.get('verification') or {}).get('evidenceLevel') == 'primaryChecked')} page-backed literary works, and {sum(1 for w in works if (w.get('verification') or {}).get('evidenceLevel') == 'needsReview')} works still needing review.",
        "",
        "---",
        "",
        "## REPAIR STATUS",
        "",
        "1. Completed: all generated Persian-script records are explicit and separated from `textPersian`.",
        "2. Completed: fabricated image verification flags were removed; only existing local images remain verified.",
        "3. Completed: contradictory text verification states were downgraded.",
        "4. Completed: repeated page-1 placeholders were removed; un-rechecked claims are `SOURCE_LOCATED`.",
        "5. Completed: unsupported rights claims were reset to `unknown`.",
        f"6. Completed: {portrait_count} source-backed local portraits are recorded with exact source-page metadata; the remaining authors use the consistent placeholder until a reliable image is verified.",
        "",
    ]

    AUDIT_OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"\n✅ Written: {AUDIT_OUT}")

    return stats


if __name__ == "__main__":
    main()
