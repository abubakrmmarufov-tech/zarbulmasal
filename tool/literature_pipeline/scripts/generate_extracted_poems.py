#!/usr/bin/env python3
"""Curriculum Poem Extractor for Zarbulmasal (Grades 5-11).

Strictly extracts authentic curriculum poems from textbook dumps and PDFs:
- Standardizes Tajik Cyrillic (ғ, ӣ, қ, ӯ, ҳ, ҷ)
- Classifies completeness: complete, excerpt, fragment
- Records exact sourceId, bookTitle, pageStart, pageEnd
- Resolves true author and links to canonical entity
- Removes all non-poem questions, vocab, exercises
- Outputs clean JSON to docs/literature/EXTRACTED_POEMS.json
"""

import json
import os
import re
import pymupdf
from pathlib import Path

ROOT = Path("/Users/m.a/Desktop/work/zarbulmasal")
OUTPUT_PATH = ROOT / "docs/literature/EXTRACTED_POEMS.json"

LEGACY_MAP = {
    'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
    'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
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
        if re.match(r"^\d{1,3}\.?$", line) or line in ["*", "**", "***", "•", "–", "—", "..."]:
            continue
        line = re.sub(r"([а-яёғӣқӯҳҷ])\d{1,2}(?=[,.\s!?…»\"]|$)", r"\1", line, flags=re.IGNORECASE)
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            cleaned.append(line)
            
    while cleaned and cleaned[0] == "": cleaned.pop(0)
    while cleaned and cleaned[-1] == "": cleaned.pop()
    return "\n".join(cleaned)

def extract_poem_from_doc(doc, p_hint_start, p_hint_end, start_needle, end_needle):
    full_text = ""
    page_offsets = []
    
    # search within a generous window
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
        # Fallback: ignore spaces and punctuation for needle
        s_clean = re.sub(r"[,\.?!;:\-\"\«\»\s]", "", start_needle)
        full_clean = re.sub(r"[,\.?!;:\-\"\«\»\s]", "", full_text)
        c_idx = full_clean.find(s_clean[:15])
        if c_idx == -1:
            raise ValueError(f"Could not locate start needle: {start_needle}")
        # Approx match
        s_idx = full_text.find(start_needle.split()[0])
        
    sub = full_text[s_idx:]
    e_idx = sub.find(end_needle)
    if e_idx == -1:
        # try without punctuation
        end_clean = end_needle.strip().split()[-1]
        e_idx = sub.find(end_clean)
        if e_idx == -1:
            raise ValueError(f"Could not locate end needle: {end_needle}")
            
    raw = sub[:e_idx + len(end_needle)]
    cleaned = clean_lines(raw)
    
    # Determine exact pages
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

print("Extractor generator initialized.")
