import json, re, pymupdf
from pathlib import Path

ROOT = Path("/Users/m.a/Desktop/work/zarbulmasal")

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items(): text = text.replace(k, v)
    return text

def clean_poetry_lines(raw_text):
    lines = raw_text.splitlines()
    cleaned = []
    for line in lines:
        line = fix_text(line).strip()
        if not line:
            if cleaned and cleaned[-1] != "":
                cleaned.append("")
            continue
        # Skip isolated numbers or footnotes
        if re.match(r"^\d{1,3}\.?$", line) or line in ["*", "**", "***", "•", "–", "—"]:
            continue
        # Strip trailing/inline footnote numbers attached to words
        line = re.sub(r"([а-яёғӣқӯҳҷ])\d{1,2}(?=[,.\s!?…»\"]|$)", r"\1", line, flags=re.IGNORECASE)
        line = re.sub(r"\s+", " ", line).strip()
        if line:
            cleaned.append(line)
    while cleaned and cleaned[0] == "": cleaned.pop(0)
    while cleaned and cleaned[-1] == "": cleaned.pop()
    return "\n".join(cleaned)

print("Build extractors helper initialized.")
