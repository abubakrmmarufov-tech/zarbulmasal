import re
import json

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/chunks_book_5_v2/chunk_book5_aa', 'r', encoding='utf-8') as f:
    text = f.read()

# Try to find something that looks like poets and poems. 
# Usually in these textbooks, poems are centered or have a specific structure.
# But actually, let's just see if there's any mention of a poet.
print("Poets found in text:", set(re.findall(r'([А-ЗЯӢҶҒҚҲ][а-зяиӣҷғқҳ]+\s+[А-ЗЯӢҶҒҚҲ][а-зяиӣҷғқҳ]+)\s+гуфтааст|([А-ЗЯӢҶҒҚҲ][а-зяиӣҷғқҳ]+)\s+навиштааст', text)))
