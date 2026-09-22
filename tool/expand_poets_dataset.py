import json
import re
import fitz

tajik_map = {
    'Љ': 'Ҷ', 'љ': 'ҷ',
    'Њ': 'Ҳ', 'њ': 'ҳ',
    'Ї': 'Ӣ', 'ї': 'ӣ',
    'Ќ': 'Қ', 'ќ': 'қ',
    'Ў': 'Ӯ', 'ў': 'ӯ',
    'Ѓ': 'Ғ', 'ѓ': 'ғ'
}

def clean_tajik(text):
    for k, v in tajik_map.items():
        text = text.replace(k, v)
    return text

print("Script tool/expand_poets_dataset.py ready to develop.")
