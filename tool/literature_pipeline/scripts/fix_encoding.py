import pymupdf
import sys

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ',
        'ќ': 'қ', 'Ќ': 'Қ',
        'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ',
        'ў': 'ӯ', 'Ў': 'Ӯ',
        'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items():
        text = text.replace(k, v)
    return text

doc = pymupdf.open("docs/literature/pdfs/adabiet sinfi 5.pdf")
text = ""
for i in range(4, 7):
    text += doc[i].get_text()
    
print(fix_text(text)[:1000])
