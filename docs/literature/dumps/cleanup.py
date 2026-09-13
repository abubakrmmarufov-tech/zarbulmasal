import json

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book8_chunk_ac.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

for item in data:
    clean_poems = []
    for p in item['poems']:
        # clean up standalone hyphens and empty lines
        lines = [l for l in p.split('\n') if l.strip() and l.strip() != '-']
        
        # skip fake poems that are mostly prose but accidentally wrapped
        if len(lines) >= 2:
            avg_len = sum(len(l) for l in lines) / len(lines)
            if 15 < avg_len < 45:
                clean_poems.append('\n'.join(lines))
    
    # merge consecutive poems if they look like they belong together
    # actually let's just save the cleaned poems
    item['poems'] = clean_poems

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book8_chunk_ac.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=4)
