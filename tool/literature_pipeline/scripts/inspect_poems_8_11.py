import pymupdf, re

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items(): text = text.replace(k, v)
    return text

def inspect_book(pdf_name, checks):
    doc = pymupdf.open("docs/literature/pdfs/" + pdf_name)
    print(f"==================== {pdf_name} ====================")
    for p_num, label in checks:
        if p_num - 1 < len(doc):
            txt = fix_text(doc[p_num - 1].get_text())
            lines = [l.strip() for l in txt.splitlines() if l.strip()]
            print(f"--- Page {p_num}: {label} ---")
            for l in lines[:10]:
                print("  ", l)

inspect_book("adabiyet sinfi 8.pdf", [
    (48, "Рӯдакӣ Шикоят аз пирӣ"),
    (56, "Рӯдакӣ Модари май"),
    (67, "Дақиқӣ ғазал"),
    (81, "Фирдавсӣ Оғози Шоҳнома"),
    (85, "Фирдавсӣ Достони Суҳроб"),
    (112, "Фирдавсӣ Разми Исфандёр"),
    (138, "Сино ашъор"),
    (151, "Боботоҳир дубайтӣ"),
    (160, "Асадӣ Мунозира"),
    (187, "Носири Хусрав қасида"),
    (203, "Хайём рубоиёт"),
    (214, "Саноӣ ашъор"),
    (236, "Анварӣ ғазал"),
    (245, "Аттор Мантиқ-ут-тайр"),
    (254, "Хоқонӣ Айвони Мадоин"),
    (265, "Низоми Махзан-ул-асрор"),
    (267, "Низоми Хусрав ва Ширин"),
    (277, "Низоми Лайлӣ ва Маҷнун")
])

