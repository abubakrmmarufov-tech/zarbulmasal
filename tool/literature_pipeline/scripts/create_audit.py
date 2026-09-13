import json
import glob
import os

poets_db = {}
poems_db = {}

files = glob.glob("docs/literature/extracted/*.json")
for file in files:
    book_key = os.path.basename(file)
    try:
        with open(file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception:
        continue
        
    poets = []
    if isinstance(data, dict):
        if "poets" in data:
            poets = data["poets"]
        else:
            for poet_name, poet_poems in data.items():
                poets.append({"name": poet_name, "poems": poet_poems})
    elif isinstance(data, list):
        for item in data:
            if "poets" in item:
                poets.extend(item["poets"])
            elif "poet" in item:
                poets.append(item)
            elif "name" in item:
                poets.append(item)

    for p in poets:
        name = p.get("name", p.get("poet", "Unknown"))
        if name not in poets_db:
            poets_db[name] = {"sources": set(), "poems_count": 0}
        
        pages = p.get("source_pages", [])
        for page in pages:
            poets_db[name]["sources"].add(f"{book_key} (pg {page})")
            
        poems_list = p.get("poems", [])
        for poem in poems_list:
            title = "Unknown"
            if isinstance(poem, dict):
                title = poem.get("title", "Unknown")
            elif isinstance(poem, str):
                first_line = poem.strip().split('\n')[0]
                title = first_line[:30] + '...' if len(first_line) > 30 else first_line
            
            poets_db[name]["poems_count"] += 1
            poem_key = f"{name} - {title}"
            if poem_key not in poems_db:
                poems_db[poem_key] = {"poet": name, "title": title, "sources": set()}
            for page in pages:
                poems_db[poem_key]["sources"].add(f"{book_key} (pg {page})")

with open("docs/literature/POET_AUDIT.md", "w", encoding="utf-8") as f:
    f.write("# Poet Audit Register\n\n")
    f.write("| Poet Name | Poem Count | Sources |\n")
    f.write("|-----------|------------|---------|\n")
    for name, info in sorted(poets_db.items()):
        sources = ", ".join(info["sources"]) if info["sources"] else "General/Missing page"
        f.write(f"| {name} | {info['poems_count']} | {sources} |\n")

with open("docs/literature/POEM_AUDIT.md", "w", encoding="utf-8") as f:
    f.write("# Poem Audit Register\n\n")
    f.write("| Poet | Poem Title | Sources |\n")
    f.write("|------|------------|---------|\n")
    for key, info in sorted(poems_db.items()):
        sources = ", ".join(info["sources"]) if info["sources"] else "General/Missing page"
        title = info["title"].replace("\n", " ").replace("|", "\\|")
        f.write(f"| {info['poet']} | {title} | {sources} |\n")

print("Audit files created.")
