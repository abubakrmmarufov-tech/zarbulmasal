import json
import re

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/book8_chunk_ab', 'r') as f:
    lines = f.readlines()

poets = ["АБУАБДУЛЛОҲИ РӮДАКӢ", "ДАҚИҚӢ", "АБУЛҚОСИМИ ФИРДАВСӢ"]
data = []
current_poet = None
current_poem = []

for line in lines:
    line_clean = line.strip()
    
    # Check for poet headers
    is_poet = False
    for p in poets:
        if p in line_clean and line_clean.startswith('##'):
            current_poet = p
            is_poet = True
            break
    
    if is_poet:
        continue
        
    # Heuristic for poem line: usually no digits at start, short, has comma in middle or rhyme, but we can just use length and formatting
    # Let's just look at line length and if there's no markdown headers or numbers.
    # Actually, in the snippet earlier:
    # Рӯдакӣ устоди шоирони ҷаҳон буд,
    # Садяк аз ӯ туӣ, Кисоӣ, яргист!
    
    # It might be easier to use an LLM for extraction, but since I have to do it in python, let me do some regex for poem blocks:
    pass

