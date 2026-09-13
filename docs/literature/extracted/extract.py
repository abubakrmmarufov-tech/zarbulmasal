import json
import re
import os

file_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/chunk_book11_aa'
out_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/chunk_book11_aa.json'

os.makedirs(os.path.dirname(out_path), exist_ok=True)

with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# Remove page markers
text = re.sub(r'## .*?\(Page \d+\)', '', text)
lines = text.split('\n')

results = {}
current_poet = "Unknown"

# Function to extract poet from paragraph
def find_poet(paragraph):
    # Regex to find capitalized words in Cyrillic (Tajik)
    # Including specific letters: Ҷ, Ҳ, Ғ, Қ, Ӯ, Ӣ
    matches = re.findall(r'[А-ЯҶҲҒҚӮ][а-яҷҳғқӯӣ]+(?:[-\s][А-ЯҶҲҒҚӮ][а-яҷҳғқӯӣ]+)*', paragraph)
    # Filter out common non-poet capitalized words if necessary, or just take the most likely one (e.g., last one before the colon)
    # Often the poet's name is near the end, e.g. "... Ҷавҳарӣ мебошад:"
    # Or in the subject: "Асирӣ дар ҳаққи..."
    # We'll just grab all capitalized words. Some might be places or book titles, but it's a good heuristic.
    # Actually, we can check a predefined list of known poets if we want, or just pick the first capitalized word sequence that isn't at the very start of a sentence unless it's the only one.
    
    # A simple list of known poets from the text
    known_poets = ["Асирӣ", "Ҷавҳарӣ", "Аҳмадҷони Ҳамдӣ", "Аҷзии Самарқандӣ", "Аҷзӣ", "Туғрал", "Садри Зиё", "Гулшанӣ", "Фитрат", "Мунзим", "Таҷаллии Кашмирӣ", "Сайидаҳмади Васлӣ", "Беҳбудӣ", "Айнӣ", "Садриддин Айнӣ", "Тошхоҷаи Асирӣ"]
    
    for kp in known_poets:
        if kp in paragraph:
            return kp
            
    if matches:
        # Return the last capitalized phrase that's not a common word
        return matches[-1]
    return "Unknown"

# Parse lines
i = 0
extracted = []
while i < len(lines):
    line = lines[i].strip()
    if line.endswith(':'):
        # This might be an introduction to a poem
        paragraph = line
        # look back a bit to get the whole paragraph if it was wrapped
        j = i - 1
        while j >= 0 and lines[j].strip() and not lines[j].strip().endswith('.') and not lines[j].strip().endswith(':'):
            paragraph = lines[j].strip() + " " + paragraph
            j -= 1
        
        poet = find_poet(paragraph)
        
        # Now collect the poem
        poem_lines = []
        i += 1
        # Skip blank lines
        while i < len(lines) and not lines[i].strip():
            i += 1
            
        # Read poem lines
        while i < len(lines):
            p_line = lines[i].strip()
            if not p_line:
                # empty line might mean end of poem, or just stanza break. 
                # Let's check the next line. If it's also empty, or if it's a prose line, end.
                if i + 1 < len(lines) and not lines[i+1].strip():
                    break
                # just a stanza break
                poem_lines.append("")
                i += 1
                continue
                
            # If line is too long, it's probably prose
            if len(p_line) > 65:
                break
                
            # Ignore numbers or single words unless they look like poetry
            if p_line.isdigit() or len(p_line.split()) < 2:
                # check if it's a marker like `1` or `2`
                if not re.match(r'^\d+$', p_line):
                    poem_lines.append(p_line)
            else:
                poem_lines.append(p_line)
                
            i += 1
            
        if poem_lines:
            # clean up trailing empty lines
            while poem_lines and poem_lines[-1] == "":
                poem_lines.pop()
            
            # Add to results
            if poet not in results:
                results[poet] = []
            
            poem_text = "\n".join(poem_lines)
            if poem_text:
                results[poet].append(poem_text)
                
        continue
        
    i += 1

# Format as JSON list
output_list = []
for p, poems in results.items():
    output_list.append({
        "poet": p,
        "poems": poems
    })

with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(output_list, f, ensure_ascii=False, indent=4)

print(f"Extracted {len(output_list)} poets.")
