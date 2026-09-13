import json
import re

file_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/book8_chunk_ab'
out_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book8_chunk_ab.json'

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

poets = [
    ("АБУАБДУЛЛОҲИ РӮДАКӢ", r"## АБУАБДУЛЛОҲИ РӮДАКӢ"),
    ("ДАҚИҚӢ", r"## ДАҚИҚӢ"),
    ("АБУЛҚОСИМИ ФИРДАВСӢ", r"## АБУЛҚОСИМИ ФИРДАВСӢ")
]

blocks = content.split('\n\n')

results = []
current_poet = None
current_poems = []

for block in blocks:
    lines = [line.strip() for line in block.split('\n') if line.strip()]
    if not lines:
        continue
    
    # Check if this block sets the current poet
    for poet_name, poet_regex in poets:
        if any(re.search(poet_regex, line) for line in lines):
            if current_poet and current_poems:
                results.append({"poet": current_poet, "poems": current_poems})
            current_poet = poet_name
            current_poems = []
            break
            
    if not current_poet:
        continue
        
    # Heuristics for a poem block:
    # 1. At least 2 lines
    # 2. No line starts with ##
    # 3. No line ends with -
    # 4. Max line length < 90
    # 5. Last line does not end with :
    # 6. Does not look like a list (e.g. starts with "а)", "б)", "1.", "2.")
    if len(lines) >= 2:
        if any(line.startswith('##') for line in lines):
            continue
        if any(line.endswith('-') for line in lines):
            continue
        if any(len(line) > 90 for line in lines):
            continue
        if lines[-1].endswith(':'):
            continue
        if any(re.match(r'^(\d+\.|[а-яА-Я]\))', line) for line in lines):
            continue
            
        # It's likely a poem
        poem_text = '\n'.join(lines)
        current_poems.append(poem_text)

if current_poet and current_poems:
    results.append({"poet": current_poet, "poems": current_poems})

with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(results, f, ensure_ascii=False, indent=2)

print(f"Extracted {len(results)} poets.")
for r in results:
    print(f"Poet {r['poet']} - {len(r['poems'])} poems")
