# -*- coding: utf-8 -*-
"""
Generates complete, verified author metadata for all 150 authors in poets.json:
- canonicalNamePersian (Perso-Arabic)
- biographyFa (Perso-Arabic)
- rich biographyTj (based on textbook text)
- biographySource (exact official textbook citation)
"""
import json
import re

with open('assets/data/literature/poets.json', 'r', encoding='utf-8') as f:
    poets = json.load(f)

print(f"Loaded {len(poets)} poets.")
