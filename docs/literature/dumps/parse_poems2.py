import re
import json

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/book8_chunk_ae', 'r', encoding='utf-8') as f:
    lines = f.readlines()

poets = []
current_poet = "Unknown"
poets_dict = {current_poet: []}

is_poem_block = False
current_poem = []

def is_prose(line):
    # If the line is long, it's prose
    if len(line) > 60: return True
    # If it ends with punctuation like ., :, ?, ! it might be prose, but poems also end with .
    # Let's check average word length or number of words
    words = line.split()
    if len(words) > 10: return True
    if len(words) < 3: return True
    return False

# Actually, the markdown might have blockquotes for poems? Let's check how the excerpt looked.
# In the chunk:
# 399: 
# 400: Эй фалаки зудгард, вой бар он,
# 401: К-ӯ ба ту, эй фитнаҷӯй, мафтун шуд.
# No blockquotes.

for i, line in enumerate(lines):
    line_stripped = line.strip()
    
    if line_stripped.startswith('## НОСИРИ ХУСРАВ'):
        current_poet = "Носири Хусрав"
        poets_dict[current_poet] = []
    elif line_stripped.startswith('## УМАРИ ХАЙЁМ'):
        current_poet = "Умари Хайём"
        poets_dict[current_poet] = []
    elif line_stripped.startswith('## САНОИИ ҒАЗНАВӢ'):
        current_poet = "Саноии Ғазнавӣ"
        poets_dict[current_poet] = []
        
    if not line_stripped:
        if current_poem:
            if len(current_poem) >= 2: # At least two lines for a poem
                poets_dict[current_poet].append("\n".join(current_poem))
            current_poem = []
        continue
        
    # Ignore page numbers
    if re.match(r'^\d+$', line_stripped) or line_stripped.startswith('##'):
        continue

    # Poem heuristic: lines usually between 15 and 55 chars, and part of a block of similar length lines.
    if 15 <= len(line_stripped) <= 60 and not re.search(r'\d', line_stripped):
        # check if adjacent lines also look like poem
        prev_is_poem = (i > 0 and 15 <= len(lines[i-1].strip()) <= 60 and not re.search(r'\d', lines[i-1].strip()) and lines[i-1].strip())
        next_is_poem = (i < len(lines)-1 and 15 <= len(lines[i+1].strip()) <= 60 and not re.search(r'\d', lines[i+1].strip()) and lines[i+1].strip())
        
        if prev_is_poem or next_is_poem or current_poem:
            current_poem.append(line_stripped)
        else:
            # isolate short prose line
            pass
    else:
        # It's prose
        if current_poem:
            if len(current_poem) >= 2:
                poets_dict[current_poet].append("\n".join(current_poem))
            current_poem = []

# Output to JSON
output_data = []
for p, pms in poets_dict.items():
    if p != "Unknown" and pms:
        output_data.append({"poet": p, "poems": pms})

import os
os.makedirs('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted', exist_ok=True)
with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book8_chunk_ae.json', 'w', encoding='utf-8') as f:
    json.dump(output_data, f, ensure_ascii=False, indent=2)

print("Extracted", len(output_data), "poets.")
for o in output_data:
    print(o['poet'], ":", len(o['poems']), "poems")
