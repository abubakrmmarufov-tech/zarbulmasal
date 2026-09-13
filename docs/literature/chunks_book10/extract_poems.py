import json
import re

def is_poem_line(line):
    line = line.strip()
    if not line: return False
    # Poem lines in this document usually start with an uppercase Cyrillic letter
    # and are not too long (usually < 60 chars)
    if len(line) > 65: return False
    # Ignore page markers and headers
    if line.startswith('##') or line.isdigit() or line.startswith('«') or line.startswith('В-'):
        pass
    # Basic check: doesn't look like a prose line
    return True

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/chunks_book10/chunk_aa', 'r') as f:
    lines = f.readlines()

poets = {}
current_poet = "Номаълум"
current_poem = []

poet_keywords = {
    'Рӯдакӣ': 'Рӯдакӣ',
    'Манучеҳрӣ': 'Манучеҳрӣ',
    'Манучеҳрии Домғонӣ': 'Манучеҳрӣ',
    'Хоқонӣ': 'Хоқонӣ',
    'Хоқонии Шарвонӣ': 'Хоқонӣ',
    'Саъдӣ': 'Саъдӣ',
    'Ҳилолӣ': 'Ҳилолӣ',
    'Бадриддини Ҳилолӣ': 'Ҳилолӣ',
    'Мушфиқӣ': 'Мушфиқӣ',
    'Абдурраҳмони Мушфиқӣ': 'Мушфиқӣ'
}

for i, line in enumerate(lines):
    line_clean = line.strip()
    
    # Check for poet mentions in prose (roughly)
    if len(line_clean) > 0 and not is_poem_line(line_clean) and not line_clean.startswith('##'):
        for k, v in poet_keywords.items():
            if k in line_clean:
                current_poet = v
    elif line_clean.startswith('## АБДУРРАҲМОНИ'):
        current_poet = 'Мушфиқӣ'
    
    # Very simple poem extraction:
    # We look for blocks of lines where lengths are similar and < 60
    if len(line_clean) > 0 and len(line_clean) <= 65 and not line_clean.startswith('##') and not line_clean.isdigit():
        # exclude prose short lines (like ends of paragraphs)
        # Check if next line is also a short line, or previous was
        prev_is_short = i > 0 and 0 < len(lines[i-1].strip()) <= 65 and not lines[i-1].strip().startswith('##') and not lines[i-1].strip().isdigit()
        next_is_short = i < len(lines)-1 and 0 < len(lines[i+1].strip()) <= 65 and not lines[i+1].strip().startswith('##') and not lines[i+1].strip().isdigit()
        
        if prev_is_short or next_is_short:
             # Likely part of a poem
             # Ignore lines that are just one word or non-alphabetic
             if len(line_clean.split()) > 2:
                 current_poem.append(line_clean)
        else:
            if current_poem:
                if len(current_poem) >= 2:
                    if current_poet not in poets:
                        poets[current_poet] = []
                    poets[current_poet].append({
                        "title": "Шеър",
                        "text": "\n".join(current_poem)
                    })
                current_poem = []
    else:
        if current_poem:
            if len(current_poem) >= 2:
                if current_poet not in poets:
                    poets[current_poet] = []
                poets[current_poet].append({
                    "title": "Шеър",
                    "text": "\n".join(current_poem)
                })
            current_poem = []

# Output parsing results
out = []
for p, pms in poets.items():
    out.append({
        "poet": p,
        "poems": pms
    })

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/chunks_book10/chunk_aa.json', 'w', encoding='utf-8') as f:
    json.dump(out, f, ensure_ascii=False, indent=2)

print(f"Extracted {len(out)} poets and {sum(len(x['poems']) for x in out)} poems.")
