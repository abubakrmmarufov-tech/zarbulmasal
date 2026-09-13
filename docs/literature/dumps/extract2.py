import json
import re

def extract_poems(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    poems = []
    current_poem = []
    
    for line in lines:
        stripped = line.strip()
        if not stripped:
            if current_poem:
                if len(current_poem) >= 2:
                    poems.append('\n'.join(current_poem))
                current_poem = []
            continue
            
        # condition for poem:
        # 1. line length <= 50
        # 2. Doesn't end with a hyphen (prose wrapping often ends with hyphen)
        # 3. Not just a number
        # 4. Doesn't start with '#' or number
        if len(stripped) <= 50 and not stripped.endswith('-') and not stripped.isdigit() and not re.match(r'^[\#\d]', stripped):
            current_poem.append(stripped)
        else:
            if current_poem:
                if len(current_poem) >= 2:
                    poems.append('\n'.join(current_poem))
                current_poem = []
                
    if current_poem and len(current_poem) >= 2:
        poems.append('\n'.join(current_poem))
        
    # filter out anything that looks like a heading or prose 
    valid_poems = []
    for p in poems:
        p_lines = p.split('\n')
        if len(p_lines) >= 2:
            # check average length
            avg_len = sum(len(l) for l in p_lines) / len(p_lines)
            if avg_len > 15 and avg_len < 45:
                valid_poems.append(p)
            
    output = {
        "poet": "Абулқосим Фирдавсӣ",
        "poems": valid_poems
    }
    
    with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book8_chunk_ac.json', 'w', encoding='utf-8') as f:
        json.dump([output], f, ensure_ascii=False, indent=4)

extract_poems('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/book8_chunk_ac')
