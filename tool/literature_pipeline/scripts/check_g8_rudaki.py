import pymupdf

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items(): text = text.replace(k, v)
    return text

doc = pymupdf.open("docs/literature/pdfs/adabiyet sinfi 8.pdf")
for p in range(47, 57):
    print(f"=== Page {p+1} ===")
    txt = fix_text(doc[p].get_text())
    for l in txt.splitlines():
        if len(l.strip()) > 3:
            print("  ", l.strip())
