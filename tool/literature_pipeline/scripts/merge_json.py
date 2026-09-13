import json
import glob
import os
from collections import defaultdict

input_dir = "/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book7_chunks_json"
output_file = "/Users/m.a/Desktop/work/zarbulmasal/docs/literature/extracted/book7.json"

poets_dict = defaultdict(list)
total_poems = 0

for file_path in glob.glob(os.path.join(input_dir, "*.json")):
    with open(file_path, "r", encoding="utf-8") as f:
        try:
            data = json.load(f)
            for item in data:
                poet = item.get("poet", "Unknown")
                poems = item.get("poems", [])
                poets_dict[poet].extend(poems)
                total_poems += len(poems)
        except Exception as e:
            print(f"Error parsing {file_path}: {e}")

result = []
for poet, poems in poets_dict.items():
    result.append({
        "poet": poet,
        "poems": poems
    })

os.makedirs(os.path.dirname(output_file), exist_ok=True)
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(result, f, ensure_ascii=False, indent=2)

print(f"Total poets: {len(poets_dict)}")
print(f"Total poems: {total_poems}")
print(f"Poets list: {list(poets_dict.keys())}")
