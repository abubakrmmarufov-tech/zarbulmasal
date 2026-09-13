import re
import json

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/book8_chunk_ae', 'r', encoding='utf-8') as f:
    lines = f.readlines()

poets = []
current_poet = "Unknown"
poets_dict = {current_poet: []}

def starts_with_capital(line):
    line = line.strip()
    if not line: return False
    # match optional punctuation then a capital letter (Tajik/Cyrillic)
    match = re.match(r'^[\W]*([А-ЯЁҒӢҚӮҲҶ])', line)
    return bool(match)

current_poem = []
in_poem = False

for i, line in enumerate(lines):
    line_stripped = line.strip()
    
    # Check for poet headings
    if line_stripped.startswith('## НОСИРИ ХУСРАВ'):
        current_poet = "Носири Хусрав"
        poets_dict[current_poet] = []
        in_poem = False
        current_poem = []
        continue
    elif line_stripped.startswith('## УМАРИ ХАЙЁМ'):
        current_poet = "Умари Хайём"
        poets_dict[current_poet] = []
        in_poem = False
        current_poem = []
        continue
    elif line_stripped.startswith('## САНОИИ ҒАЗНАВӢ'):
        current_poet = "Саноии Ғазнавӣ"
        poets_dict[current_poet] = []
        in_poem = False
        current_poem = []
        continue

    # Ignore page numbers and headings
    if re.match(r'^\d+$', line_stripped) or line_stripped.startswith('##'):
        continue

    if not line_stripped:
        if current_poem:
            if len(current_poem) >= 2:
                poets_dict[current_poet].append("\n".join(current_poem))
            current_poem = []
            in_poem = False
        continue

    # Is it a poem line?
    if starts_with_capital(line_stripped):
        # Additional check: poems usually don't have very long lines
        if len(line_stripped) < 70:
            current_poem.append(line_stripped)
        else:
            # too long, probably prose sentence starting with capital
            if current_poem:
                if len(current_poem) >= 2:
                    poets_dict[current_poet].append("\n".join(current_poem))
                current_poem = []
    else:
        # Not starting with capital -> prose
        if current_poem:
            # If the last line of the "poem" didn't end with punctuation, it might just be prose wrapping.
            # But we already enforce all lines in current_poem start with Capital.
            # Let's save if >= 2 lines.
            if len(current_poem) >= 2:
                poets_dict[current_poet].append("\n".join(current_poem))
            current_poem = []

if current_poem and len(current_poem) >= 2:
    poets_dict[current_poet].append("\n".join(current_poem))

# Filter out false positives:
# If a poem is just 2 lines but they are long and look like prose, we might drop them.
# Usually poem lines are roughly similar in length.
cleaned_dict = {}
for p, pms in poets_dict.items():
    if p == "Unknown": continue
    cleaned_pms = []
    for pm in pms:
        lines_pm = pm.split('\n')
        # Check if they are just prose sentences
        # A common prose false positive: 2 lines, both start with capital (new sentence).
        # But if they end with hyphens, it's definitely prose wrapped.
        if any(l.endswith('-') for l in lines_pm):
            continue
        cleaned_pms.append(pm)
    if cleaned_pms:
        cleaned_dict[p] = cleaned_pms

output_data = []
for p, pms in cleaned_dict.items():
    output_data.append({"poet": p, "poems": pms})

import os
os.makedirs('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted', exist_ok=True)
with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book8_chunk_ae.json', 'w', encoding='utf-8') as f:
    json.dump(output_data, f, ensure_ascii=False, indent=2)

for o in output_data:
    print(o['poet'], ":", len(o['poems']), "poems")
