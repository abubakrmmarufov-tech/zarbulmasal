import json
import re

with open('docs/literature/dumps/chunk_book11_ag', 'r', encoding='utf-8') as f:
    lines = f.readlines()

results = []
current_poet = "Раҳим Ҷалил"
poems_for_poet = []

current_poem = []

def is_poem_line(line):
    line = line.strip()
    if not line: return False
    if len(line) > 70: return False
    # Starts with capital Cyrillic
    if not re.match(r'^[А-ЯЁҒӢҚӮҲҶ"«]', line):
        return False
    # Not a heading
    if line.startswith('#'): return False
    return True

for line in lines:
    orig_line = line.strip()
    
    # Check for poet change
    if "## МИРСАИД МИРШАКАР" in orig_line:
        if poems_for_poet:
            results.append({"poet": current_poet, "poems": poems_for_poet})
        current_poet = "Мирсаид Миршакар"
        poems_for_poet = []
    elif "## ФАЗЛИДДИН МУҲАММАДИЕВ" in orig_line:
        if poems_for_poet:
            results.append({"poet": current_poet, "poems": poems_for_poet})
        current_poet = "Фазлиддин Муҳаммадиев"
        poems_for_poet = []
    elif "Фирдавсӣ" in orig_line or "«Бежан ва" in orig_line:
        # Just in case we attribute properly
        pass
        
    if is_poem_line(line):
        current_poem.append(orig_line)
    else:
        if len(current_poem) >= 2:
            poems_for_poet.append("\n".join(current_poem))
        current_poem = []

if len(current_poem) >= 2:
    poems_for_poet.append("\n".join(current_poem))

if current_poet and poems_for_poet:
    results.append({"poet": current_poet, "poems": poems_for_poet})

with open('docs/literature/extracted/chunk_book11_ag.json', 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print("Done")
