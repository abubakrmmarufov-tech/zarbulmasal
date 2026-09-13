import re
import json
import sys

def is_capital_cyrillic(char):
    return char in 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯҒӢҚӮҲҶ'

def extract_poems_and_poets(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    blocks = []
    current_block = []
    
    for line in lines:
        line_clean = line.strip()
        if not line_clean:
            if current_block:
                blocks.append(current_block)
                current_block = []
            continue
            
        if line_clean.startswith('#'):
            if current_block:
                blocks.append(current_block)
                current_block = []
            continue
            
        current_block.append(line_clean)
        
    if current_block:
        blocks.append(current_block)
        
    results = []
    default_poet = "Мирзо Турсунзода"
    
    for block in blocks:
        if len(block) < 2:
            continue
            
        is_poem = True
        poet_for_this_block = default_poet
        
        last_line = block[-1]
        poet_match = re.match(r'^\((.*?)\)$', last_line)
        if poet_match:
            poet_for_this_block = poet_match.group(1)
            lines_to_check = block[:-1]
        else:
            lines_to_check = block
            
        if len(lines_to_check) < 2:
            is_poem = False
        else:
            for line in lines_to_check:
                if re.match(r'^[\d\-\*]', line):
                    is_poem = False
                    break
                
                match = re.search(r'[А-Яа-яЁёҒғӢӣҚқӮӯҲҳҶҷ]', line)
                if match:
                    first_letter = match.group(0)
                    if not is_capital_cyrillic(first_letter):
                        is_poem = False
                        break
                else:
                    is_poem = False
                    break
                    
        if is_poem:
            results.append({
                "poet": poet_for_this_block,
                "poem": "\n".join(lines_to_check)
            })
            
    poet_to_poems = {}
    for r in results:
        poet = r['poet']
        poem = r['poem']
        if poet not in poet_to_poems:
            poet_to_poems[poet] = []
        poet_to_poems[poet].append(poem)
        
    final_json = []
    for poet, poems in poet_to_poems.items():
        final_json.append({
            "poet": poet,
            "poems": poems
        })
        
    return final_json

filepath = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/chunk_book11_ae'
outpath = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/chunk_book11_ae.json'

import os
os.makedirs(os.path.dirname(outpath), exist_ok=True)
data = extract_poems_and_poets(filepath)
with open(outpath, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"Extraction complete. Found {len(data)} poets and total {sum(len(v['poems']) for v in data)} poems.")
for d in data:
    print(f"Poet: {d['poet']}")
    for p in d['poems'][:2]:
        print(p)
        print("---")
