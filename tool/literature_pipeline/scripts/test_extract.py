import re
import json
import sys

def is_capital_cyrillic(char):
    return char in 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯҒӢҚӮҲҶ'

def extract_poems(filepath):
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
            
        # skip headings, numbers, etc
        if line_clean.startswith('#') or re.match(r'^\d+$', line_clean) or re.match(r'^\d+\.', line_clean):
            if current_block:
                blocks.append(current_block)
                current_block = []
            continue
            
        current_block.append(line_clean)
        
    if current_block:
        blocks.append(current_block)
        
    poems = []
    for block in blocks:
        # A block is a poem if it has at least 2 lines and all lines start with a capital cyrillic letter (or a quote followed by it)
        # Also, check if it's not just a short list.
        is_poem = True
        if len(block) < 2:
            is_poem = False
        else:
            for line in block:
                # remove leading quotes or non-alphabetic
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
            poems.append("\n".join(block))
            
    print(f"Found {len(poems)} poems.")
    for i, p in enumerate(poems[:3]):
        print(f"--- Poem {i+1} ---")
        print(p)
        print("-------------")

extract_poems('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/chunk_book11_ae')
