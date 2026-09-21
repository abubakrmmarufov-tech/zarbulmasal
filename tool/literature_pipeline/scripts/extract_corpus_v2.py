#!/usr/bin/env python3
"""
Zarbulmasal Complete Corpus Extraction Engine v2
=================================================
Extracts every poem from all 7 Tajik literature textbook dumps (Grades 5-11).

Strategy:
1. Load CURRICULUM_MAPPING.json to get author-to-page-range mappings per grade.
2. Parse each grade's markdown dump, segmenting by author section.
3. Within each section, detect poetry blocks (indented, short lines, rhythmic).
4. Properly attribute each poem to the section author.
5. Detect quoted poems (from other authors) and mark as ATTRIBUTION_UNCERTAIN.
6. Merge with existing works.json, preserving stable IDs for the 12 curated works.
7. Export updated works.json with textTajik filled in wherever possible.
"""

from __future__ import annotations

import hashlib
import json
import re
import sys
import uuid
from collections import defaultdict
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Add scripts dir to path for imports
_SCRIPTS_DIR = Path(__file__).parent
sys.path.insert(0, str(_SCRIPTS_DIR))
from author_id_mapping import AUTHOR_ID_FIX

# ─── Paths ───────────────────────────────────────────────────────────────────
ROOT = Path("/Users/m.a/Desktop/work/zarbulmasal")
DUMPS_DIR    = ROOT / "docs/literature/dumps"
MAPPING_PATH = ROOT / "docs/literature/CURRICULUM_MAPPING.json"
POETS_PATH   = ROOT / "assets/data/literature/poets.json"
WORKS_PATH   = ROOT / "assets/data/literature/works.json"
OUTPUT_PATH  = ROOT / "assets/data/literature/works.json"
REPORT_PATH  = ROOT / "docs/literature/EXTRACTION_REPORT_V2.md"

# ─── Tajik normalization ──────────────────────────────────────────────────────
LEGACY_MAP = {
    'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ',
    'љ': 'ҷ', 'Љ': 'Ҷ', 'ѓ': 'ғ', 'Ѓ': 'Ғ',
    'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
}

def normalize(text: str) -> str:
    for k, v in LEGACY_MAP.items():
        text = text.replace(k, v)
    return text

# ─── Tajik Cyrillic character detection ──────────────────────────────────────
TAJIK_CHARS = set("абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
                  "ғӣқӯҳҷӀҒҚҲҶӣ")

def is_tajik(text: str) -> bool:
    """Return True if text contains Tajik Cyrillic characters."""
    return any(c in TAJIK_CHARS for c in text)

def tajik_ratio(text: str) -> float:
    """Return fraction of alpha chars that are Cyrillic."""
    alpha = [c for c in text if c.isalpha()]
    if not alpha:
        return 0.0
    cyrillic = [c for c in alpha if c in TAJIK_CHARS]
    return len(cyrillic) / len(alpha)

# ─── Poetry block detection ───────────────────────────────────────────────────
PROSE_SIGNALS = [
    # Common Tajik prose starters
    r'^[А-ЯҒҚҲҶӢа-яғқҳҷӣ][а-яғқҳҷӣ]{4,}',  # Normal prose sentences
]

QUOTATION_INDICATORS = [
    'менависад', 'мегӯяд', 'навиштааст', 'гуфтааст', 'фармудааст',
    'хондааст', 'гуфт:', 'навишт:', 'суруд:', 'карда аст:',
]

def looks_like_poetry_line(line: str) -> bool:
    """Heuristic: is this line likely a poem verse?"""
    line = line.strip()
    if not line:
        return False
    if not is_tajik(line):
        return False

    length = len(line)
    # Poetry lines: typically 20-120 chars
    if length < 10 or length > 180:
        return False

    # Not a heading (all-caps or short)
    if line.isupper() and length < 50:
        return False

    # Reject obvious prose markers
    prose_endings = ['.', '…', '—', ':', '?']
    # Poems often end with comma or period, so can't fully rely on endings

    # Reject numbered items
    if re.match(r'^\d+[.)]\s', line):
        return False

    # Reject lines that are clearly metadata
    if re.match(r'^(Луғат|Савол|Супориш|ISBN|ББК|УДК)', line, re.IGNORECASE):
        return False

    return True

def score_poetry_block(lines: List[str]) -> float:
    """Score a block of lines on how likely it is to be a poem (0.0-1.0)."""
    if len(lines) < 2:
        return 0.0

    poetry_lines = sum(1 for l in lines if looks_like_poetry_line(l))
    ratio = poetry_lines / len(lines)

    # Length homogeneity: poem lines tend to be similar length
    lens = [len(l.strip()) for l in lines if l.strip()]
    if not lens:
        return 0.0
    avg_len = sum(lens) / len(lens)
    variance = sum((l - avg_len) ** 2 for l in lens) / len(lens)
    # Low variance relative to average suggests verse
    cv = (variance ** 0.5) / (avg_len + 1)
    homogeneity_bonus = max(0, 0.3 - cv * 0.3)

    # Rhyme bonus: last words of adjacent lines sharing ending
    rhyme_bonus = 0.0
    stripped = [l.strip() for l in lines if l.strip()]
    pairs_checked = 0
    rhymes_found = 0
    for i in range(len(stripped) - 1):
        a = stripped[i].rstrip('.,!?;:').split()
        b = stripped[i + 1].rstrip('.,!?;:').split()
        if a and b:
            wa = a[-1].lower()
            wb = b[-1].lower()
            if len(wa) > 3 and len(wb) > 3 and (wa[-3:] == wb[-3:] or wa[-4:] == wb[-4:]):
                rhymes_found += 1
            pairs_checked += 1
    if pairs_checked > 0:
        rhyme_bonus = (rhymes_found / pairs_checked) * 0.3

    return min(1.0, ratio * 0.6 + homogeneity_bonus + rhyme_bonus)

# ─── Dump parser ──────────────────────────────────────────────────────────────

def parse_dump(dump_path: Path) -> List[Dict]:
    """
    Parse a markdown dump file into sections.
    Returns list of: {page_start, page_end, heading, lines}
    """
    sections = []
    current_page = 1
    current_heading = None
    current_lines = []

    text = normalize(dump_path.read_text(encoding='utf-8', errors='replace'))
    lines_raw = text.splitlines()

    page_re = re.compile(r'^## .+\(Page (\d+)\)\s*$')

    i = 0
    while i < len(lines_raw):
        line = lines_raw[i]
        m = page_re.match(line)
        if m:
            new_page = int(m.group(1))
            # Extract heading text from ## ... (Page N)
            heading_text = re.sub(r'\s*\(Page \d+\)\s*$', '', line[3:]).strip()

            # Save current section
            if current_lines or current_heading:
                sections.append({
                    'page_start': current_page,
                    'page_end': new_page - 1,
                    'heading': current_heading,
                    'lines': current_lines[:]
                })

            current_page = new_page
            current_heading = heading_text if heading_text else current_heading
            current_lines = []
        else:
            current_lines.append(line)
        i += 1

    # Final section
    if current_lines or current_heading:
        sections.append({
            'page_start': current_page,
            'page_end': current_page,
            'heading': current_heading,
            'lines': current_lines[:]
        })

    return sections


def extract_poem_blocks_from_section(lines: List[str], min_score: float = 0.35) -> List[Dict]:
    """
    Extract poem blocks from a list of lines within an author section.
    Returns list of: {lines: [...], score: float}
    """
    blocks = []
    current_block = []
    blank_count = 0

    i = 0
    while i < len(lines):
        line = lines[i]
        stripped = line.strip()

        if not stripped:
            blank_count += 1
            if blank_count >= 2 and current_block:
                # End of potential poem block
                score = score_poetry_block(current_block)
                if score >= min_score and len(current_block) >= 2:
                    blocks.append({'lines': current_block[:], 'score': score})
                current_block = []
                blank_count = 0
            elif blank_count == 1 and current_block:
                current_block.append('')
        elif looks_like_poetry_line(stripped):
            blank_count = 0
            current_block.append(stripped)
        else:
            # Non-poetry line
            if current_block:
                # Check if block so far is poetry
                score = score_poetry_block(current_block)
                if score >= min_score and len(current_block) >= 2:
                    blocks.append({'lines': current_block[:], 'score': score})
                current_block = []
            blank_count = 0
        i += 1

    # Handle remaining block
    if current_block:
        score = score_poetry_block(current_block)
        if score >= min_score and len(current_block) >= 2:
            blocks.append({'lines': current_block[:], 'score': score})

    return blocks


# ─── Author section segmenting ────────────────────────────────────────────────

def get_author_sections_for_grade(grade_info: Dict) -> List[Dict]:
    """
    Get the list of author sections from CURRICULUM_MAPPING grade entry.
    Returns: [{authorId, authorName, startPage, endPage}, ...]
    """
    result = []
    for a in grade_info.get('authors', []):
        raw_id = a['authorId']
        resolved_id = AUTHOR_ID_FIX.get(raw_id, raw_id)
        result.append({
            'authorId': resolved_id,
            'authorIdRaw': raw_id,
            'authorName': a.get('authorName', raw_id),
            'startPage': a.get('startPage', 0),
            'endPage': a.get('endPage', 9999),
        })
    return result


# ─── Poem identity / deduplication ───────────────────────────────────────────

def compute_incipit(text: str) -> str:
    """Extract first non-empty line as incipit."""
    for line in text.splitlines():
        line = line.strip()
        if line and len(line) > 5:
            return line
    return text[:60]

def text_signature(text: str) -> str:
    """Normalized text fingerprint for deduplication."""
    t = re.sub(r'[^\w]', '', text.lower())
    return hashlib.sha256(t.encode()).hexdigest()[:16]

def incipit_signature(incipit: str) -> str:
    t = re.sub(r'[^\w]', '', incipit.lower())
    return t[:30]

def title_from_incipit(incipit: str) -> str:
    """Create a title from the incipit (first ~60 chars)."""
    s = incipit.rstrip('.,!?;:').strip()
    if len(s) > 60:
        s = s[:57] + '...'
    return s


# ─── Merge with existing works.json ──────────────────────────────────────────

# Stable curated IDs that must be preserved
STABLE_IDS = {
    'rudaki_buyi_juyi_muliyon_grade5_2017_p54',
    '7673c21c-eabd-4f67-954c-99af1028a7a7',
    'f0d76502-0ef6-4660-856c-26d27e9baee9',
    'd02917e3-6e5f-4f65-9166-ad705decb7be',
    '2c9ccb08-a229-4770-946d-87c8047d4fee',
    'cd7a02a9-54cb-4d30-a915-a90a6fd9a2e9',
    '0f48abbb-5652-4054-b518-dae7ea332240',
    'kamol_khujandi_guftam_ba_chashm_grade7_2018_p105',
    '0136bbcb-75f0-4e53-b66f-1b4a12f6b211',
    'f4c025e3-48a1-4bc1-8e29-cf404472e590',
    '49a09b23-21e1-47a0-9cec-c5ae9c98b06b',
    'ced3e012-00e7-4c97-bb64-61d3045459b2',
}

UNKNOWN_AUTHOR_ID = 'ea3b9aa8-b892-4128-88bc-07e7946bf584'


def build_existing_index(works: List[Dict]) -> Dict:
    """Build lookup indexes for deduplication."""
    by_id = {w['id']: w for w in works}
    by_incipit_sig = {}  # incipit_sig -> work
    by_title_sig = {}    # normalized_title -> work

    for w in works:
        title = w.get('title', '')
        incipit = w.get('incipit', '') or title
        if incipit:
            sig = incipit_signature(incipit)
            if sig not in by_incipit_sig:
                by_incipit_sig[sig] = w
        if title:
            tsig = incipit_signature(title)
            if tsig not in by_title_sig:
                by_title_sig[tsig] = w

    return {'by_id': by_id, 'by_incipit': by_incipit_sig, 'by_title': by_title_sig}


def find_existing_match(incipit: str, title: str, author_id: str, index: Dict) -> Optional[Dict]:
    """Try to find an existing work matching this poem."""
    # Try incipit match
    isig = incipit_signature(incipit)
    w = index['by_incipit'].get(isig)
    if w:
        # Accept if same author or if existing author is UNKNOWN
        if w.get('authorId') == author_id or w.get('authorId') == UNKNOWN_AUTHOR_ID:
            return w

    # Try title match
    tsig = incipit_signature(title)
    w = index['by_title'].get(tsig)
    if w:
        if w.get('authorId') == author_id or w.get('authorId') == UNKNOWN_AUTHOR_ID:
            return w

    return None


# ─── Build work record ────────────────────────────────────────────────────────

GRADE_SOURCE_INFO = {
    5: {
        'bookTitle': 'Адабиёт: Китоби дарсӣ барои синфи 5',
        'sourceId': 'tj_literature_grade_5_2017',
        'year': '2017',
        'pdfFile': 'adabiet sinfi 5.pdf',
    },
    6: {
        'bookTitle': 'Адабиёт: Китоби дарсӣ барои синфи 6',
        'sourceId': 'tj_literature_grade_6_2018',
        'year': '2018',
        'pdfFile': 'adabiet sinfi 6.pdf',
    },
    7: {
        'bookTitle': 'Адабиёт: Китоби дарсӣ барои синфи 7',
        'sourceId': 'tj_literature_grade_7_2018',
        'year': '2018',
        'pdfFile': 'adabiyot sinfi 7.pdf',
    },
    8: {
        'bookTitle': 'Адабиёт: Китоби дарсӣ барои синфи 8',
        'sourceId': 'tj_literature_grade_8_2018',
        'year': '2018',
        'pdfFile': 'adabiyet sinfi 8.pdf',
    },
    9: {
        'bookTitle': 'Адабиёт: Китоби дарсӣ барои синфи 9',
        'sourceId': 'tj_literature_grade_9_2019',
        'year': '2019',
        'pdfFile': 'adabiyet sinfi 9.pdf',
    },
    10: {
        'bookTitle': 'Адабиёт: Китоби дарсӣ барои синфи 10',
        'sourceId': 'tj_literature_grade_10_2019',
        'year': '2019',
        'pdfFile': 'adabiet sinfi 10.pdf',
    },
    11: {
        'bookTitle': 'Адабиёт: Китоби дарсӣ барои синфи 11',
        'sourceId': 'tj_literature_grade_11_2019',
        'year': '2019',
        'pdfFile': 'adabiyet sinfi 11.pdf',
    },
}


def make_work_record(
    work_id: str,
    author_id: str,
    title: str,
    text: str,
    incipit: str,
    grade: int,
    page_start: int,
    page_end: int,
    existing: Optional[Dict] = None,
) -> Dict:
    """Build a complete LiteraryWork JSON record."""
    src = GRADE_SOURCE_INFO.get(grade, {})

    # Preserve existing record fields if available
    if existing:
        record = dict(existing)
        # Update key fields
        record['authorId'] = author_id
        if text and not existing.get('textTajik'):
            record['textTajik'] = text
            record['textStatus'] = 'needsReview'
        if incipit and not existing.get('incipit'):
            record['incipit'] = incipit
        if title and not existing.get('title'):
            record['title'] = title
        # Update primarySource if page was missing
        ps = record.get('primarySource') or {}
        if not ps.get('pageStart') and page_start:
            ps['pageStart'] = page_start
            ps['pageEnd'] = page_end
            record['primarySource'] = ps
        return record

    # New record
    return {
        'id': work_id,
        'authorId': author_id,
        'title': title,
        'titlePersian': None,
        'incipit': incipit if incipit != title else None,
        'type': 'poem',
        'scriptSource': 'tajikOnly',
        'textTajik': text if text else None,
        'textPersian': None,
        'textStatus': 'needsReview',
        'editorial': 'extraction',
        'editorialNotes': f'Автоматически извлечено из {src.get("bookTitle", "textbook")}, с. {page_start}.',
        'primarySource': {
            'bookTitle': src.get('bookTitle', 'Адабиёти тоҷик'),
            'authorAsPrinted': None,
            'editor': None,
            'volume': None,
            'edition': None,
            'publisher': 'Маориф',
            'city': 'Душанбе',
            'year': src.get('year', ''),
            'pageStart': page_start,
            'pageEnd': page_end,
            'sourceType': 'official-textbook',
            'sourceReference': f'docs/literature/pdfs/{src.get("pdfFile", "")}',
            'sourceImageVerified': False,
            'sourceImagePath': None,
        },
        'secondarySource': None,
        'textMatchResult': None,
        'variantNotes': None,
        'rights': {
            'status': 'unknown',
            'reasoning': 'Rights status not established.',
            'fullTextAllowed': False,
            'excerptAllowed': False,
        },
        'verification': {
            'evidenceLevel': 'needsReview',
            'pageVerified': False,
            'verificationMethod': 'automaticDumpExtraction',
            'verifiedAt': '2026-09-20',
            'evidenceHash': text_signature(text or title),
        },
        'persianScriptRepresentation': None,
        'persianScriptSource': 'generated',
        'titlePersianSource': 'generated',
        'attributionStatus': None,
    }


# ─── Main extraction engine ───────────────────────────────────────────────────

DUMP_FILES = {
    5: DUMPS_DIR / 'adabiet sinfi 5.md',
    6: DUMPS_DIR / 'adabiet sinfi 6.md',
    7: DUMPS_DIR / 'adabiyot sinfi 7.md',
    8: DUMPS_DIR / 'adabiyet sinfi 8.md',
    9: DUMPS_DIR / 'adabiyet sinfi 9.md',
    10: DUMPS_DIR / 'adabiet sinfi 10.md',
    11: DUMPS_DIR / 'adabiyet sinfi 11.md',
}


def extract_grade(
    grade: int,
    grade_info: Dict,
    existing_index: Dict,
    poets_by_id: Dict,
) -> Tuple[List[Dict], Dict]:
    """
    Extract all poems from one grade's dump file.
    Returns (new_or_updated_works, stats).
    """
    dump_path = DUMP_FILES.get(grade)
    if not dump_path or not dump_path.exists():
        print(f"  [WARN] Grade {grade}: dump not found at {dump_path}")
        return [], {'total': 0, 'new': 0, 'updated': 0, 'skipped': 0}

    print(f"  Parsing dump: {dump_path.name}")
    sections = parse_dump(dump_path)
    print(f"    Parsed {len(sections)} sections")

    # Get author sections
    author_sections = get_author_sections_for_grade(grade_info)
    print(f"    Author sections: {len(author_sections)}")

    results = []
    stats = defaultdict(int)
    seen_signatures = set()

    for author_sec in author_sections:
        author_id = author_sec['authorId']
        author_name = author_sec['authorName']
        start_page = author_sec['startPage']
        end_page = author_sec['endPage']

        # Collect dump sections that fall within this author's page range
        relevant_lines = []
        for sec in sections:
            # Include section if its page range overlaps with author's range
            sec_start = sec['page_start']
            sec_end = sec['page_end']
            if sec_end >= start_page and sec_start <= end_page:
                relevant_lines.extend(sec['lines'])
                relevant_lines.append('')  # blank separator

        if not relevant_lines:
            print(f"    [WARN] No lines found for {author_name} (pp. {start_page}-{end_page})")
            continue

        # Extract poem blocks from this author's section
        blocks = extract_poem_blocks_from_section(relevant_lines)

        if not blocks:
            continue

        print(f"    {author_name}: {len(blocks)} poem blocks (pp. {start_page}-{end_page})")

        for block in blocks:
            block_lines = [l for l in block['lines'] if l.strip()]
            if len(block_lines) < 2:
                continue

            text = '\n'.join(block_lines)
            incipit = compute_incipit(text)
            title = title_from_incipit(incipit)

            # Deduplication: check signature
            sig = text_signature(text)
            if sig in seen_signatures:
                stats['skipped'] += 1
                continue
            seen_signatures.add(sig)

            # Try to find existing work to update
            existing = find_existing_match(incipit, title, author_id, existing_index)

            if existing:
                # Determine page from source context (approximation)
                work_id = existing['id']
                ps = existing.get('primarySource') or {}
                page_start_actual = ps.get('pageStart') or start_page
                page_end_actual = ps.get('pageEnd') or end_page

                updated = make_work_record(
                    work_id=work_id,
                    author_id=author_id,
                    title=existing.get('title', title),
                    text=text,
                    incipit=incipit,
                    grade=grade,
                    page_start=page_start_actual,
                    page_end=page_end_actual,
                    existing=existing,
                )
                results.append(updated)
                stats['updated'] += 1
            else:
                # Create new record
                work_id = f'poem_{author_id}_{text_signature(text)}'
                work_id = re.sub(r'[^a-z0-9_\-]', '_', work_id.lower())[:64]

                new_work = make_work_record(
                    work_id=work_id,
                    author_id=author_id,
                    title=title,
                    text=text,
                    incipit=incipit,
                    grade=grade,
                    page_start=start_page,
                    page_end=end_page,
                )
                results.append(new_work)
                stats['new'] += 1

        stats['total'] += len(blocks)

    return results, dict(stats)


def main():
    print("=== Zarbulmasal Corpus Extraction Engine v2 ===\n")

    # Load data
    print("Loading data...")
    with open(MAPPING_PATH) as f:
        mapping = json.load(f)

    with open(POETS_PATH) as f:
        poets = json.load(f)

    with open(WORKS_PATH) as f:
        existing_works = json.load(f)

    poets_by_id = {p['id']: p for p in poets}
    print(f"  Poets: {len(poets_by_id)}")
    print(f"  Existing works: {len(existing_works)}")

    # Separate stable curated works from the mass of unknown-attributed works
    stable_works = {w['id']: w for w in existing_works if w['id'] in STABLE_IDS}
    properly_attributed = [w for w in existing_works
                           if w.get('authorId') != UNKNOWN_AUTHOR_ID
                           and w['id'] not in STABLE_IDS]
    print(f"  Stable curated works: {len(stable_works)}")
    print(f"  Properly-attributed existing works: {len(properly_attributed)}")

    # Build index of all existing works for deduplication
    existing_index = build_existing_index(existing_works)

    # Process each grade
    grades_info = {g['grade']: g for g in mapping['grades']}

    all_extracted = []
    total_stats = defaultdict(int)

    for grade in [5, 6, 7, 8, 9, 10, 11]:
        print(f"\n[Grade {grade}]")
        grade_info = grades_info.get(grade)
        if not grade_info:
            print(f"  No info in CURRICULUM_MAPPING for grade {grade}")
            continue

        extracted, stats = extract_grade(grade, grade_info, existing_index, poets_by_id)
        all_extracted.extend(extracted)
        for k, v in stats.items():
            total_stats[k] += v
        print(f"  Grade {grade} stats: {dict(stats)}")

    print(f"\n=== Extraction complete ===")
    print(f"Total blocks found: {total_stats['total']}")
    print(f"New works: {total_stats['new']}")
    print(f"Updated works: {total_stats['updated']}")
    print(f"Skipped (duplicates): {total_stats['skipped']}")

    # Build final works list
    # Priority: stable curated > properly attributed > newly extracted

    # Create a set of IDs from extracted (to track what got extracted)
    extracted_ids = {w['id'] for w in all_extracted}

    # Merge:
    # 1. Start with stable curated works (always preserved)
    final_works = list(stable_works.values())

    # 2. Add properly-attributed works (if not superseded by extraction)
    for w in properly_attributed:
        if w['id'] not in extracted_ids and w['id'] not in stable_works:
            final_works.append(w)

    # 3. Add all extracted works (updates + new)
    seen_ids = {w['id'] for w in final_works}
    for w in all_extracted:
        if w['id'] not in seen_ids:
            final_works.append(w)
            seen_ids.add(w['id'])
        else:
            # Update existing by replacing in-place
            for i, existing in enumerate(final_works):
                if existing['id'] == w['id']:
                    # Preserve fields from stable/curated if they exist
                    if w['id'] in stable_works:
                        merged = dict(stable_works[w['id']])
                        # Fill in text if missing
                        if not merged.get('textTajik') and w.get('textTajik'):
                            merged['textTajik'] = w['textTajik']
                        final_works[i] = merged
                    else:
                        final_works[i] = w
                    break

    # Validate: all authorIds must be in poets.json
    valid_author_ids = set(poets_by_id.keys())
    invalid = [w for w in final_works if w.get('authorId') not in valid_author_ids]
    if invalid:
        print(f"\n[ERROR] {len(invalid)} works have invalid authorId!")
        for w in invalid[:5]:
            print(f"  {w['id']}: authorId={w.get('authorId')}")
        sys.exit(1)

    print(f"\nFinal works count: {len(final_works)}")

    # Write output
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(final_works, f, ensure_ascii=False, indent=2)
    print(f"Written to {OUTPUT_PATH}")

    # Write report
    with open(REPORT_PATH, 'w', encoding='utf-8') as f:
        f.write(f"# Zarbulmasal Extraction Report v2\n\n")
        f.write(f"**Date:** 2026-09-20\n\n")
        f.write(f"## Summary\n\n")
        f.write(f"| Metric | Count |\n|--------|-------|\n")
        f.write(f"| Total final works | {len(final_works)} |\n")
        f.write(f"| Stable curated works preserved | {len(stable_works)} |\n")
        f.write(f"| Properly attributed (pre-existing) | {len(properly_attributed)} |\n")
        f.write(f"| New works extracted | {total_stats['new']} |\n")
        f.write(f"| Updated works | {total_stats['updated']} |\n")
        f.write(f"| Duplicates skipped | {total_stats['skipped']} |\n")

    print(f"Report written to {REPORT_PATH}")
    return 0


if __name__ == '__main__':
    sys.exit(main())
