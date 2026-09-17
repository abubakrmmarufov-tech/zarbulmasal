import pymupdf, re

def fix_text(text):
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items(): text = text.replace(k, v)
    return text

def test_poem(pdf_name, p_start, p_end, start_needle, end_needle):
    doc = pymupdf.open("docs/literature/pdfs/" + pdf_name)
    full = ""
    for p in range(p_start - 1, min(p_end, len(doc))):
        full += fix_text(doc[p].get_text()) + "\n"
    has_start = start_needle in full
    has_end = end_needle in full
    print(f"[{pdf_name}] {p_start}-{p_end}: start={has_start}, end={has_end}")
    if not has_start:
        print(f"  FAILED START: {start_needle}")
    if not has_end:
        print(f"  FAILED END: {end_needle}")

# Test a few samples in Grade 8, 9, 10, 11
test_poem("adabiyet sinfi 8.pdf", 48, 55, "Шуд он замона, ки шеъраш ҳама ҷаҳон бинвишт", "Кунун ба хона нишинам, асиру ранҷурам")
test_poem("adabiyet sinfi 8.pdf", 56, 57, "Модари майро бибояд кушт", "То ҷаҳон бошад ту бошӣ эй амир")
test_poem("adabiyet sinfi 9.pdf", 18, 22, "Эй сорбон, оҳиста рон", "Чун мурда гардам бехабар")
test_poem("adabiet sinfi 10.pdf", 31, 35, "Дар аҳди ҳусни ӯ санами гулъизори мо", "Мушфиқӣ")
test_poem("adabiyet sinfi 11.pdf", 26, 30, "Моҳи ман имшаб зи рӯ гар мушакпар бардорад", "Туғрал")
