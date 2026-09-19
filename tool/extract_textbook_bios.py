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
    # clean extra hyphens at line ends
    text = re.sub(r'(\w+)-\s*\n\s*(\w+)', r'\1\2', text)
    # normalize spaces and newlines
    lines = [l.strip() for l in text.split('\n') if l.strip()]
    return ' '.join(lines)

def extract_pages(pdf_path, start_page, end_page, max_chars=1200):
    doc = fitz.open(pdf_path)
    combined = []
    # fitz is 0-indexed, start_page is 1-indexed
    s = max(0, start_page - 1)
    e = min(len(doc), end_page)
    for p in range(s, e):
        txt = clean_tajik(doc[p].get_text())
        # filter out standalone page numbers or headers
        txt = re.sub(r'^\d+\s*', '', txt)
        combined.append(txt)
        if sum(len(x) for x in combined) >= max_chars:
            break
    full = ' '.join(combined)
    return full[:max_chars].strip()

# Test with a few authors
print("Sanai Grade 8 (p.212):")
print(extract_pages('pdf books/adabiyet sinfi 8.pdf', 212, 215, 600))

print("\nAnvari Grade 8 (p.234):")
print(extract_pages('pdf books/adabiyet sinfi 8.pdf', 234, 237, 600))

print("\nHiloli Grade 9 (p.306):")
print(extract_pages('pdf books/adabiyet sinfi 9.pdf', 306, 309, 600))
