#!/usr/bin/env python3
"""Comprehensive Curriculum Poem Extractor for Zarbulmasal (Grades 5-11).

Builds docs/literature/EXTRACTED_POEMS.json with authentic, clean, verified
curriculum poems directly grounded in the official Tajik literature textbook dumps.
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
    for k, v in LEGACY_MAP.items():
        text = text.replace(k, v)
    return text

def clean_lines(raw: str) -> str:
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

def extract_poem_from_doc(doc: pymupdf.Document, p_hint_start: int, p_hint_end: int, start_needle: str, end_needle: str) -> Tuple[str, int, int]:
    full_text = ""
    page_offsets = []
    
    p_min = max(0, p_hint_start - 3)
    p_max = min(len(doc), p_hint_end + 3)
    
    for p_idx in range(p_min, p_max):
        s_offset = len(full_text)
        page_text = fix_tajik(doc[p_idx].get_text()) + "\n"
        full_text += page_text
        e_offset = len(full_text)
        page_offsets.append((p_idx + 1, s_offset, e_offset))
        
    s_idx = full_text.find(start_needle)
    if s_idx == -1:
        s_first_word = start_needle.strip().split()[0]
        s_idx = full_text.find(s_first_word)
        if s_idx == -1:
            raise ValueError(f"Could not locate start needle: {start_needle}")
            
    sub = full_text[s_idx:]
    e_idx = sub.find(end_needle)
    if e_idx == -1:
        end_last_word = end_needle.strip().split()[-1]
        e_idx = sub.find(end_last_word)
        if e_idx == -1:
            raise ValueError(f"Could not locate end needle: {end_needle}")
            
    raw = sub[:e_idx + len(end_needle)]
    cleaned = clean_lines(raw)
    
    abs_start = s_idx
    abs_end = s_idx + e_idx + len(end_needle)
    
    start_page = p_hint_start
    end_page = p_hint_end
    
    for p_num, s_off, e_off in page_offsets:
        if s_off <= abs_start < e_off:
            start_page = p_num
        if s_off <= abs_end <= e_off:
            end_page = p_num
            break
            
    if end_page < start_page:
        end_page = start_page
        
    return cleaned, start_page, end_page

print("Base extractor configured.")
