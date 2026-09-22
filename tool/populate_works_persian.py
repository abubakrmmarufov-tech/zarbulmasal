# -*- coding: utf-8 -*-
"""
Populates titlePersian and textPersian for all 1472 works in works.json,
sets scriptSource = 'both', and ensures zero Cyrillic characters.
"""
import json
import re

cyrillic_pattern = re.compile(r'[\u0400-\u04FF]')

# Load transliteration engine
from transliterate_tajik import transliterate_text, LEXICON

# Add special known canonical titles and poetry phrases to LEXICON
SPECIAL_TITLES = {
    "Биёед, эй рафиқон, дарс хонем": "بیایید، ای رفیقان، درس خوانیم",
    "Аз қаъри гили сиёҳ то авҷи Зуҳал": "از قعر گل سیاه تا اوج زحل",
    "Ман бода хурам, валек мастӣ накунам": "من باده خورم، ولیک مستی نکنم",
    "Банӣ Одам аъзои якдигаранд": "بنی‌آدم اعضای یکدیگرند",
    "Гар бар сари нафси худ амирӣ, мардӣ": "گر بر سر نفس خود امیری، مردی",
    "Фишонд аз савсану гул симу зар бод": "فشاند از سوسن و گل سیم و زر باد",
    "Агар он турки шерозӣ ба даст орад дили моро": "اگر آن ترک شیرازی به دست آرد دل ما را",
    "Қасидаи модар": "قصیده مادر",
    "Зан агар оташ намешуд...": "زن اگر آتش نمی‌شد...",
    "Забони модарӣ": "زبان مادری",
    "Бӯйи Ҷӯйи Мулиён": "بوی جوی مولیان",
    "Гуфтам: «Ба чашм»": "گفتم: «به چشم»"
}

with open('assets/data/literature/works.json', 'r', encoding='utf-8') as f:
    works = json.load(f)

print(f"Loaded {len(works)} works.")

for i, w in enumerate(works):
    title = w.get('title', '')
    text_tj = w.get('textTajik', '')
    
    # Title Persian
    if title in SPECIAL_TITLES:
        w['titlePersian'] = SPECIAL_TITLES[title]
    else:
        w['titlePersian'] = transliterate_text(title)
        
    # Text Persian
    w['textPersian'] = transliterate_text(text_tj)
    
    # Script source
    w['scriptSource'] = 'both'

# Check for any remaining Cyrillic
leaks_title = []
leaks_text = []
for w in works:
    t_fa = w.get('titlePersian', '')
    txt_fa = w.get('textPersian', '')
    if cyrillic_pattern.search(t_fa):
        leaks_title.append((w['id'], t_fa))
    if cyrillic_pattern.search(txt_fa):
        leaks_text.append((w['id'], txt_fa[:50]))

print(f"Title leaks: {len(leaks_title)}")
print(f"Text leaks: {len(leaks_text)}")

if leaks_title or leaks_text:
    print("Sample title leaks:", leaks_title[:5])
    print("Sample text leaks:", leaks_text[:5])
else:
    with open('assets/data/literature/works.json', 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
    print("Successfully updated assets/data/literature/works.json with 0 leaks!")
