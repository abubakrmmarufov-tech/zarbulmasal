import json, re, pymupdf
from pathlib import Path

ROOT = Path("/Users/m.a/Desktop/work/zarbulmasal")
doc5 = pymupdf.open("docs/literature/pdfs/adabiet sinfi 5.pdf")

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items(): text = text.replace(k, v)
    return text

def extract_from_pages(doc, start_p, end_p, start_needle, end_needle):
    full = ""
    for p in range(start_p - 1, end_p):
        full += fix_text(doc[p].get_text()) + "\n"
    
    # find start_needle
    p1 = full.find(start_needle)
    if p1 == -1:
        return f"START NOT FOUND: {start_needle}"
    sub = full[p1:]
    p2 = sub.find(end_needle)
    if p2 == -1:
        return f"END NOT FOUND: {end_needle}"
    raw = sub[:p2 + len(end_needle)]
    
    # Clean lines
    lines = raw.splitlines()
    cleaned = []
    for l in lines:
        l = l.strip()
        if not l or re.match(r"^\d{1,3}\.?$", l) or l in ["*", "**", "***", "•", "–", "—"]:
            continue
        l = re.sub(r"([а-яёғӣқӯҳҷ])\d{1,2}(?=[,.\s!?…»\"]|$)", r"\1", l, flags=re.IGNORECASE)
        l = re.sub(r"\s+", " ", l).strip()
        if l: cleaned.append(l)
    return "\n".join(cleaned)

res = extract_from_pages(doc5, 52, 53, "Омад баҳори хуррам", "Сор аз дарахти сарв мар-ӯро шуда муҷиб...")
print("EXTRACTED BAHORI KHURRAM:")
print(res)
