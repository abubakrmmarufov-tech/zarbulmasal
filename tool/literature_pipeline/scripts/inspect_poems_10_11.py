import pymupdf, re

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items(): text = text.replace(k, v)
    return text

doc10 = pymupdf.open("docs/literature/pdfs/adabiet sinfi 10.pdf")
print("Grade 10 total pages:", len(doc10))
checks10 = [
    (31, "Мушфиқӣ ғазал"),
    (39, "Мушфиқӣ Гулзори Ирам"),
    (53, "Шавкат ғазал"),
    (71, "Саййидо ғазал"),
    (79, "Саййидо мусаммат"),
    (83, "Саййидо Шаҳрошӯб"),
    (87, "Саййидо Баҳориёт"),
    (99, "Соиб ғазал"),
    (125, "Бедил ғазал"),
    (135, "Бедил Комде ва Мадан"),
    (175, "Муншӣ ғазал"),
    (179, "Муншӣ Дахмаи шоҳон"),
    (189, "Ҳозиқ ғазал"),
    (192, "Ҳозиқ Юсуфу Зулайхо"),
    (212, "Гулханӣ Зарбулмасал"),
    (218, "Қоонӣ қасида"),
    (271, "Савдо ашъор"),
    (287, "Шоҳин ғазал"),
    (305, "Шоҳин Туҳфаи дӯстон"),
    (313, "Ҳайрат ғазал")
]

for p_num, label in checks10:
    if p_num - 1 < len(doc10):
        txt = fix_text(doc10[p_num - 1].get_text())
        lines = [l.strip() for l in txt.splitlines() if l.strip()]
        print(f"--- G10 Page {p_num}: {label} ---")
        for l in lines[:6]:
            print("  ", l)

doc11 = pymupdf.open("docs/literature/pdfs/adabiyet sinfi 11.pdf")
print("Grade 11 total pages:", len(doc11))
checks11 = [
    (26, "Туғрал ғазал"),
    (36, "Асирӣ Ҷӯйи Бекобод"),
    (40, "Кангуртӣ ғазал"),
    (69, "Айнӣ шоир"),
    (111, "Лоҳутӣ 1907-1922"),
    (123, "Лоҳутӣ Тоҷикистон"),
    (136, "Пайрав ашъор"),
    (147, "Юсуфӣ ашъор"),
    (156, "Турсунзода лирика"),
    (165, "Турсунзода достонҳо"),
    (240, "Миршакар достонҳо"),
    (273, "Қаноат ашъор"),
    (283, "Қаноат Сурӯши Сталинград"),
    (292, "Лоиқ ашъор"),
    (296, "Лоиқ Модарнома"),
    (312, "Бозор Собир"),
    (366, "Гулназар Келдӣ")
]

for p_num, label in checks11:
    if p_num - 1 < len(doc11):
        txt = fix_text(doc11[p_num - 1].get_text())
        lines = [l.strip() for l in txt.splitlines() if l.strip()]
        print(f"--- G11 Page {p_num}: {label} ---")
        for l in lines[:6]:
            print("  ", l)
