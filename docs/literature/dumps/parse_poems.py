import re
import json

with open('/Users/m.a/Desktop/work/zarbulmasal/docs/literature/dumps/book8_chunk_ae', 'r', encoding='utf-8') as f:
    lines = f.readlines()

poets = []
current_poet = None
current_poem = []

for line in lines:
    line = line.strip()
    if not line:
        if current_poem:
            if current_poet:
                poets[-1]['poems'].append("\n".join(current_poem))
            current_poem = []
        continue

    # Detect poet headings
    if line.startswith('## НОСИРИ ХУСРАВ') or line.startswith('## УМАРИ ХАЙЁМ') or line.startswith('## САНОИИ ҒАЗНАВӢ'):
        poet_name = line.replace('## ', '').split(' (Page')[0].strip()
        poets.append({'poet': poet_name, 'poems': []})
        current_poet = poet_name
        continue
    
    # Check if line might be part of a poem
    # Simple heuristic: poetry lines in these texts often end with certain punctuation, or are shorter, or we can look for hemistich spacing.
    # Actually, in the text provided:
    # Эй фалаки зудгард, вой бар он,
    # К-ӯ ба ту, эй фитнаҷӯй, мафтун шуд.
    # They are consecutive non-empty lines, often separated by empty lines from prose.
    # Also, we might have page numbers like '179'
    if re.match(r'^\d+$', line) or line.startswith('##') or len(line.split()) > 15:
        # likely prose or page number or other heading
        pass
    else:
        # Might be poem or prose, let's just collect all and we will filter later
        pass

