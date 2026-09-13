import json
import re

file_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/chunk_book11_aa'
out_path = '/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/chunk_book11_aa.json'

with open(file_path, 'r', encoding='utf-8') as f:
    text = f.read()

# Remove page markers
text = re.sub(r'## .*?\(Page \d+\)', '', text)
lines = text.split('\n')

results = {}
current_poet = "Unknown"

known_poets = ["Асирӣ", "Ҷавҳарӣ", "Аҳмадҷони Ҳамдӣ", "Аҷзии Самарқандӣ", "Аҷзӣ", "Туғрал", "Садри Зиё", "Гулшанӣ", "Фитрат", "Мунзим", "Таҷаллии Кашмирӣ", "Сайидаҳмади Васлӣ", "Беҳбудӣ", "Айнӣ", "Садриддин Айнӣ", "Тошхоҷаи Асирӣ", "Саъдӣ", "Бедил", "Камоли Хуҷандӣ", "Нозими Ҳиротӣ", "Камол", "Файёзи Хуҷандӣ", "Шоҳин", "Шамсиддин Шоҳин"]

def find_poet(paragraph):
    for kp in known_poets:
        if kp in paragraph:
            if kp == "Аҷзӣ" and "Аҷзии Самарқандӣ" in paragraph:
                return "Аҷзии Самарқандӣ"
            if kp == "Камол" and "Камоли Хуҷандӣ" in paragraph:
                return "Камоли Хуҷандӣ"
            return kp
    
    matches = re.findall(r'[А-ЯҶҲҒҚӮ][а-яҷҳғқӯӣ]+(?:[-\s][А-ЯҶҲҒҚӮ][а-яҷҳғқӯӣ]+)*', paragraph)
    if matches:
        return matches[-1]
    return "Unknown"

# Parse lines
i = 0
while i < len(lines):
    line = lines[i].strip()
    if line.endswith(':'):
        paragraph = line
        j = i - 1
        while j >= 0 and lines[j].strip() and not lines[j].strip().endswith('.') and not lines[j].strip().endswith(':'):
            paragraph = lines[j].strip() + " " + paragraph
            j -= 1
        
        poet = find_poet(paragraph)
        
        poem_lines = []
        i += 1
        while i < len(lines) and not lines[i].strip():
            i += 1
            
        while i < len(lines):
            p_line = lines[i].strip()
            if not p_line:
                if i + 1 < len(lines) and not lines[i+1].strip():
                    break
                # Only keep single empty line as stanza break if we already have lines
                if poem_lines:
                    poem_lines.append("")
                i += 1
                continue
                
            # If the line is very long, it's definitely prose
            if len(p_line) > 55:
                break
                
            # Exclude lines that are just numbers or short non-poem strings
            if re.match(r'^\d+.*', p_line) or (len(p_line.split()) < 3 and not p_line.endswith(',')):
                if not poem_lines:
                    # Skip it, not a poem start
                    i += 1
                    continue
                else:
                    break
            
            poem_lines.append(p_line)
            i += 1
            
        # Analyze poem_lines to ensure it's a poem
        # 1. More than 1 line (not counting empty lines)
        actual_lines = [l for l in poem_lines if l]
        if len(actual_lines) > 1:
            # 2. Average line length should be < 50
            avg_len = sum(len(l) for l in actual_lines) / len(actual_lines)
            if avg_len < 55:
                if poet not in results:
                    results[poet] = []
                # Clean up empty lines at the end
                while poem_lines and not poem_lines[-1]:
                    poem_lines.pop()
                results[poet].append("\n".join(poem_lines))
        continue
        
    i += 1

output_list = [{"poet": p, "poems": poems} for p, poems in results.items() if p not in ["Мувофиқи", "Ин", "Unknown", "Мавзӯъҳои", "Адабиёти"]]

with open(out_path, 'w', encoding='utf-8') as f:
    json.dump(output_list, f, ensure_ascii=False, indent=4)

print(f"Extracted {len(output_list)} poets.")
