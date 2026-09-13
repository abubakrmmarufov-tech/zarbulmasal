import json
import os
import glob
from collections import defaultdict
import uuid
import re

def normalize_text(text):
    if not text: return ""
    text = re.sub(r'\s+', ' ', text).strip().lower()
    return text

def normalize_name(name):
    if not name: return ""
    n = name.replace("Абӯабдуллоҳи ", "").replace("Устод ", "").replace("Хоҷа ", "").replace("Шайх ", "")
    return n.strip()

def merge_poets():
    poets_db = {}
    poems_db = {}
    
    files = glob.glob("docs/literature/extracted/*.json")
    for file in files:
        book_key = os.path.basename(file)
        print(f"Processing {file}")
        try:
            with open(file, 'r', encoding='utf-8') as f:
                data = json.load(f)
        except Exception as e:
            print(f"Error reading {file}: {e}")
            continue
            
        poets = []
        if isinstance(data, dict):
            if "poets" in data:
                poets = data["poets"]
            else:
                # Handle {"Фирдавсӣ": [{"title": "...", "lines": [...]}]}
                for poet_name, poet_poems in data.items():
                    poets.append({
                        "name": poet_name,
                        "poems": poet_poems
                    })
        elif isinstance(data, list):
            # Handle [{"poet": "...", "poems": ["..."]}] or [{"poets": [...]}]
            for item in data:
                if "poets" in item:
                    poets.extend(item["poets"])
                elif "poet" in item:
                    poets.append(item)
                elif "name" in item:
                    poets.append(item)

        for p in poets:
            # Handle {"poet": "..."} vs {"name": "..."}
            name = p.get("name", p.get("poet", "Unknown"))
            norm_name = normalize_name(name)
            
            # Find existing poet or create new
            poet_id = None
            for pid, existing_poet in poets_db.items():
                if normalize_name(existing_poet["nameTj"]) == norm_name:
                    poet_id = pid
                    break
            
            if not poet_id:
                poet_id = str(uuid.uuid4())
                poets_db[poet_id] = {
                    "id": poet_id,
                    "nameTj": name,
                    "biography": p.get("biography", ""),
                    "birthYear": p.get("birthYear", str(p.get("birth_year", ""))),
                    "deathYear": p.get("deathYear", str(p.get("death_year", ""))),
                    "sourceRefs": []
                }
            
            # Add sources
            pages = p.get("source_pages", [])
            for page in pages:
                poets_db[poet_id]["sourceRefs"].append({
                    "bookTitle": book_key,
                    "pdfPage": int(page) if str(page).isdigit() else 0
                })
                
            # Process poems
            poems_list = p.get("poems", [])
            for poem in poems_list:
                title = "Unknown"
                text = ""
                is_excerpt = False
                source_page = 0
                
                if isinstance(poem, dict):
                    title = poem.get("title", "Unknown")
                    if "text" in poem:
                        text = poem["text"]
                    elif "lines" in poem:
                        text = "\n".join(poem["lines"])
                    is_excerpt = poem.get("is_excerpt", poem.get("isExcerpt", False))
                    source_page = poem.get("source_page", 0)
                elif isinstance(poem, str):
                    text = poem
                    first_line = text.strip().split('\n')[0]
                    title = first_line[:30] + '...' if len(first_line) > 30 else first_line
                
                if not text: continue
                
                # Check for duplicates
                norm_text = normalize_text(text)
                is_duplicate = False
                for existing_poem in poems_db.values():
                    if existing_poem["poetId"] == poet_id and existing_poem["title"] == title:
                        if normalize_text(existing_poem["text"]) == norm_text:
                            # Exact duplicate
                            existing_poem["sourceRefs"].append({
                                "bookTitle": book_key,
                                "pdfPage": 0 # Extract if available
                            })
                            is_duplicate = True
                            break
                        else:
                            # Variant
                            pass # We'll just add it as a new poem or variant
                
                if not is_duplicate:
                    poem_id = str(uuid.uuid4())
                    poems_db[poem_id] = {
                        "id": poem_id,
                        "poetId": poet_id,
                        "title": title,
                        "text": text,
                        "isExcerpt": False,
                        "sourceRefs": [{
                            "bookTitle": book_key,
                            "pdfPage": 0
                        }]
                    }

    with open("lib/data/seed/poets.json", "w", encoding="utf-8") as f:
        json.dump(list(poets_db.values()), f, ensure_ascii=False, indent=2)
        
    with open("lib/data/seed/poems.json", "w", encoding="utf-8") as f:
        json.dump(list(poems_db.values()), f, ensure_ascii=False, indent=2)

    # Output to Dart
    with open("lib/data/seed/seed_poets.dart", "w", encoding="utf-8") as f:
        f.write("import '../models/poet.dart';\n")
        f.write("import '../models/source_ref.dart';\n\n")
        f.write("const List<Poet> seedPoets = [\n")
        for poet in poets_db.values():
            f.write(f"  const Poet(\n")
            f.write(f"    id: '{poet['id']}',\n")
            f.write(f"    nameTj: '''{poet['nameTj']}''',\n")
            if poet['biography']:
                f.write(f"    biography: '''{poet['biography'].replace('\'', '\\\'')}''',\n")
            else:
                f.write(f"    biography: '',\n")
            f.write(f"    birthYear: '{poet['birthYear']}',\n")
            f.write(f"    deathYear: '{poet['deathYear']}',\n")
            f.write(f"    sourceRefs: [\n")
            for ref in poet['sourceRefs']:
                f.write(f"      const SourceRef(bookTitle: '''{ref['bookTitle']}''', pdfPage: {ref['pdfPage']}),\n")
            f.write(f"    ],\n")
            f.write(f"  ),\n")
        f.write("];\n")

    with open("lib/data/seed/seed_poems.dart", "w", encoding="utf-8") as f:
        f.write("import '../models/poem.dart';\n")
        f.write("import '../models/source_ref.dart';\n\n")
        f.write("const List<Poem> seedPoems = [\n")
        for poem in poems_db.values():
            f.write(f"  const Poem(\n")
            f.write(f"    id: '{poem['id']}',\n")
            f.write(f"    poetId: '{poem['poetId']}',\n")
            f.write(f"    title: '''{poem['title']}''',\n")
            f.write(f"    text: '''{poem['text'].replace('\'', '\\\'')}''',\n")
            f.write(f"    isExcerpt: {'true' if poem['isExcerpt'] else 'false'},\n")
            f.write(f"    sourceRefs: [\n")
            for ref in poem['sourceRefs']:
                f.write(f"      const SourceRef(bookTitle: '''{ref['bookTitle']}''', pdfPage: {ref['pdfPage']}),\n")
            f.write(f"    ],\n")
            f.write(f"  ),\n")
        f.write("];\n")

    print(f"Generated {len(poets_db)} poets and {len(poems_db)} poems.")

if __name__ == '__main__':
    merge_poets()

