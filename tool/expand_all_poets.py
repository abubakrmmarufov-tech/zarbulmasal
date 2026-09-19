# -*- coding: utf-8 -*-
import fitz
import json
import re

tajik_map = {
    'Љ': 'Ҷ', 'љ': 'ҷ',
    'Њ': 'Ҳ', 'њ': 'ҳ',
    'Ї': 'Ӣ', 'ї': 'ӣ',
    'Ќ': 'Қ', 'ќ': 'қ',
    'Ў': 'Ӯ', 'ў': 'ӯ',
    'Ѓ': 'Ғ', 'ѓ': 'ғ'
}

def clean_tajik(text):
    for k, v in tajik_map.items():
        text = text.replace(k, v)
    text = re.sub(r'(\w+)-\s*\n\s*(\w+)', r'\1\2', text)
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    return ' '.join(lines)

def extract_pages(pdf_path, start_page, end_page, max_chars=1400):
    doc = fitz.open(pdf_path)
    combined = []
    s = max(0, start_page - 1)
    e = min(len(doc), end_page)
    for p in range(s, e):
        txt = clean_tajik(doc[p].get_text())
        txt = re.sub(r'^\d+\s*', '', txt)
        combined.append(txt)
        if sum(len(x) for x in combined) >= max_chars:
            break
    full = ' '.join(combined)
    # clean multiple spaces
    full = re.sub(r'\s+', ' ', full).strip()
    return full[:max_chars].strip()

print("Helper functions ready.")
