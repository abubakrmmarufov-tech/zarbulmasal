#!/usr/bin/env python3
"""Comprehensive Curriculum Poem Extractor for Zarbulmasal (Grades 5-11).

Strictly grounded in the textbook dumps and PDFs:
- Removes non-poem questions, vocabulary lists, and lesson exercises
- Ensures correct Tajik Cyrillic orthography (ғ, ӣ, қ, ӯ, ҳ, ҷ)
- Correctly classifies completeness: complete poem, excerpt, or fragment
- Determines true author and links to canonical authorId
- Resolves exact start/end pages and sourceId
- Outputs clean JSON to docs/literature/EXTRACTED_POEMS.json
"""

from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

import pymupdf

ROOT = Path("/Users/m.a/Desktop/work/zarbulmasal")
DUMPS_DIR = ROOT / "docs/literature/dumps"
PDFS_DIR = ROOT / "docs/literature/pdfs"
POETS_PATH = ROOT / "assets/data/literature/poets.json"
OUTPUT_PATH = ROOT / "docs/literature/EXTRACTED_POEMS.json"

LEGACY_MAP = {
    'њ': 'ҳ', 'Њ': 'Ҳ',
    'ќ': 'қ', 'Ќ': 'Қ',
    'љ': 'ҷ', 'Љ': 'Ҷ',
    'ѓ': 'ғ', 'Ѓ': 'Ғ',
    'ў': 'ӯ', 'Ў': 'Ӯ',
    'ї': 'ӣ', 'Ї': 'Ӣ'
}

def fix_tajik(text: str) -> str:
    """Normalize legacy Tajik Cyrillic characters."""
    for k, v in LEGACY_MAP.items():
        text = text.replace(k, v)
    return text

def clean_lines(raw: str) -> str:
    """Clean poetry text by removing footnote numbers and trailing artifacts."""
    lines = raw.splitlines()
    cleaned = []
    for line in lines:
        line = fix_tajik(line).strip()
        if not line:
            if cleaned and cleaned[-1] != "":
                cleaned.append("")
            continue
        # Skip isolated footnote digits or bullets
        if re.match(r"^\d{1,3}\.?$", line) or line in ["*", "**", "***", "•", "–", "—", "..."]:
            continue
        # Strip trailing/inline footnote numbers attached to words
        line = re.sub(r"([а-яёғӣқӯҳҷ])\d{1,2}(?=[,.\s!?…»\"]|$)", r"\1", line, flags=re.IGNORECASE)
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            cleaned.append(line)
            
    while cleaned and cleaned[0] == "": cleaned.pop(0)
    while cleaned and cleaned[-1] == "": cleaned.pop()
    return "\n".join(cleaned)

def extract_pdf_slice(doc: pymupdf.Document, p_start: int, p_end: int, start_needle: str, end_needle: str) -> Tuple[str, int, int]:
    """Extract poetry lines between needles and find exact page range."""
    full_text = ""
    page_offsets = []
    
    for p_idx in range(p_start - 1, min(p_end, len(doc))):
        start_char = len(full_text)
        page_text = fix_tajik(doc[p_idx].get_text()) + "\n"
        full_text += page_text
        end_char = len(full_text)
        page_offsets.append((p_idx + 1, start_char, end_char))
        
    s_idx = full_text.find(start_needle)
    if s_idx == -1:
        # try without punctuation
        s_clean = re.sub(r"[,\.?!;:\-\"\«\»]", "", start_needle).strip()
        s_idx = full_text.find(s_clean[:20])
        if s_idx == -1:
            raise ValueError(f"Start needle not found: {start_needle}")
            
    sub = full_text[s_idx:]
    e_idx = sub.find(end_needle)
    if e_idx == -1:
        e_clean = re.sub(r"[,\.?!;:\-\"\«\»]", "", end_needle).strip()
        e_idx = sub.find(e_clean[:20])
        if e_idx == -1:
            raise ValueError(f"End needle not found: {end_needle}")
            
    raw_slice = sub[:e_idx + len(end_needle)]
    cleaned = clean_lines(raw_slice)
    
    # Calculate exact start and end page
    abs_start = s_idx
    abs_end = s_idx + e_idx + len(end_needle)
    
    actual_start_page = p_start
    actual_end_page = p_end
    
    for p_num, p_start_char, p_end_char in page_offsets:
        if p_start_char <= abs_start < p_end_char:
            actual_start_page = p_num
        if p_start_char <= abs_end <= p_end_char:
            actual_end_page = p_num
            break
            
    if actual_end_page < actual_start_page:
        actual_end_page = actual_start_page
        
    return cleaned, actual_start_page, actual_end_page

print("Base helper ready.")
