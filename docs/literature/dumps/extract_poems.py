import re
import json

def extract_poems_from_md(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        text = f.read()

    # In Tajik literature books, poets' names are often headings or bold text before poems
    # Poems are often indented or have multiple lines separated by / or just regular poetry stanzas.
    
    # We will try a different approach. We can ask an LLM or use simple heuristics, but since I am an LLM, I can write a script to look for poem patterns (e.g., short lines followed by short lines).
    pass
