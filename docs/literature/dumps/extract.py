import re
import json

file_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/book8_chunk_aa'
out_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book8_chunk_aa.json'

poet_poems = {}

with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

def add_poem(poet, poem):
    poet = poet.strip('() \n\r:.,')
    poem = poem.strip()
    if not poem: return
    if poet not in poet_poems:
        poet_poems[poet] = []
    poet_poems[poet].append(poem)

# Strategy 1: Look for (Poet Name)
# Strategy 2: Look for keywords like "Рӯдакӣ гуфтааст:"
current_poem_lines = []
i = 0
while i < len(lines):
    line = lines[i].strip()
    if not line:
        i += 1
        continue
    
    # Check if this line is an author attribution in parentheses
    if line.startswith('(') and line.endswith(')'):
        # The preceding non-empty lines are likely the poem
        # We need to backtrack to get the poem
        j = i - 1
        poem_lines = []
        while j >= 0:
            if lines[j].strip() == '' or lines[j].strip() == '***' or re.match(r'^[0-9]+$', lines[j].strip()):
                if len(poem_lines) > 0:
                    # we hit a break
                    break
            else:
                poem_lines.insert(0, lines[j].strip())
            j -= 1
        
        # If the extracted lines look like poetry (more than 1 line), add it
        if poem_lines:
            poet = line
            add_poem(poet, '\n'.join(poem_lines))
    
    # Check if this line introduces a poem
    # e.g., "Абушакури Балхӣ дар замина чунин мегӯяд:"
    # e.g., "Фирдавсӣ ... мегӯяд:"
    match = re.search(r'([А-ЯҶҲҒҚШЧ][а-яҷҳғқшч]+(?:\s+[А-ЯҶҲҒҚШЧ][а-яҷҳғқшч]+)*)\s+.*(?:мегӯяд|гуфтааст|дорад)[\s:]*$', line)
    if match and not line.startswith('#'):
        poet = match.group(1)
        # Often it introduces a poem block next.
        j = i + 1
        poem_lines = []
        empty_count = 0
        while j < len(lines):
            l = lines[j].strip()
            if not l:
                empty_count += 1
                if empty_count > 1 and len(poem_lines) > 0:
                    break
            elif l == '***' or re.match(r'^[0-9]+$', l):
                break
            else:
                poem_lines.append(l)
                empty_count = 0
            j += 1
        if len(poem_lines) > 0:
            add_poem(poet, '\n'.join(poem_lines))
            i = j - 1
            
    i += 1

# Special cases:
# Let's also do a pass for explicit mentions that regex might have missed
for key in poet_poems:
    print(key, len(poet_poems[key]))

result = [{"poet": k, "poems": v} for k, v in poet_poems.items()]

import os
os.makedirs(os.path.dirname(out_path), exist_ok=True)
with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(result, f, ensure_ascii=False, indent=2)

print(f"Saved to {out_path}")
