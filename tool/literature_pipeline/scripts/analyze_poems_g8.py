import re, pymupdf

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items(): text = text.replace(k, v)
    return text

doc = pymupdf.open("docs/literature/pdfs/adabiyet sinfi 8.pdf")
print("Grade 8 total pages:", len(doc))

# Check poems in Rudaki, Daqiqi, Firdawsi, Sino, Bobotohir, Asadi, Nasir Khusraw, Khayyam, Sanoi, Anvari, Attor, Khoqoni, Nizomi
def sample_pages(start, end, label):
    print(f"=== {label} (p.{start}-{end}) ===")
    for p in range(start-1, min(end, len(doc))):
        txt = fix_text(doc[p].get_text())
        for l in txt.splitlines():
            l = l.strip()
            if l.isupper() and len(l) > 4 and not any(k in l for k in ["САВОЛ", "ПУРСИШ", "ТЕСТ", "АДАБИЁТ"]):
                print(f"  p.{p+1}: {l}")

sample_pages(43, 64, "Рӯдакӣ")
sample_pages(65, 76, "Дақиқӣ")
sample_pages(77, 126, "Фирдавсӣ")
sample_pages(127, 143, "Сино")
sample_pages(150, 154, "Боботоҳир")
sample_pages(159, 167, "Асадии Тӯсӣ")
sample_pages(179, 200, "Носири Хусрав")
sample_pages(201, 211, "Хайём")
sample_pages(212, 219, "Саноӣ")
sample_pages(234, 243, "Анварӣ")
sample_pages(244, 250, "Аттор")
sample_pages(251, 261, "Хоқонӣ")
sample_pages(262, 296, "Низомии Ганҷавӣ")
