"""Reading sections for thin History entries, excerpted from the
«Таърихи халқи тоҷик» textbooks on maorif.tj (grades 6-11).

Usage:
    python3 tool/history/excerpt_textbooks.py <pages_dir> [--write]

<pages_dir>/<grade>/<n>.txt holds `pdftotext -layout` output of the grade's
textbook PDF (links in assets/data/history/books.json; the PDFs are not
kept in the repository). Printed page numbers equal PDF page numbers in
these books.

Each section is an excerpt as printed: the opening paragraphs of the
named lesson, or for a person the paragraphs of the lesson that mention
them. Only the legacy font map, line-break hyphens and footnote markers
are changed. Nothing is paraphrased; the section cites its book and pages.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'literature'))
from textbook_verse import decode_legacy  # noqa: E402

ENTRIES = 'assets/data/history/entries.json'
LIMIT = 1100          # characters per section, cut at a sentence end
UPPER = 'А-ЯЁӢӮҲҶҚҒ'

# entry id -> [(grade, first page, last page, heading, name or None)]
PLAN = {
    'empire-sasanid': [(6, 6, 8, 'Ташкили давлати Сосониён', None),
                       (6, 19, 23, 'Сохтори давлатӣ ва ҷомеаи Сосониён', None)],
    'empire-hephthalite': [(6, 44, 46, 'Хиёниён–Ҳайтолиён', None),
                           (6, 47, 49, 'Пайдоиши Хиёниён–Ҳайтолиён', None)],
    'empire-arab-caliphate': [(6, 124, 126, 'Ҳокимияти арабҳо', None),
                              (6, 127, 129, 'Ташкили хилофати Аббосиён', None)],
    'dynasty-tahirid': [(7, 25, 30, 'Давлати Тоҳириён', None)],
    'dynasty-saffarid': [(7, 31, 37, 'Давлати Саффориён', None)],
    'dynasty-samanid': [(7, 38, 44, 'Таъсиси давлати Сомониён', None),
                        (7, 45, 54, 'Ташкили дастгоҳи идорӣ ва лашкар', None),
                        (7, 83, 89, 'Сабабҳои таназзули давлати Сомониён', None)],
    'dynasty-qarakhanid': [(7, 124, 130, 'Халқи тоҷик дар замони Қарахониён', None)],
    'dynasty-ghaznavid': [(7, 131, 138, 'Халқи тоҷик дар замони Ғазнавиён', None)],
    'dynasty-seljuk': [(7, 139, 145, 'Давлати Салҷуқиён', None)],
    'dynasty-khwarazmshah': [(7, 151, 155, 'Давлати Хоразмшоҳиён', None)],
    'empire-mongol': [(7, 178, 181, 'Ҳуҷуми муғулҳо', None),
                      (7, 200, 201, 'Империяи Муғул баъди Чингизхон', None)],
    'dynasty-ghurid': [(7, 217, 225, 'Давлати Ғуриён', None)],
    'dynasty-kurt': [(7, 226, 228, 'Давлати Куртҳои Ҳирот', None)],
    'dynasty-sarbadar': [(7, 229, 233, 'Давлати Сарбадорон', None)],
    'dynasty-muzaffarid': [(7, 234, 237, 'Давлати Музаффариён', None)],
    'empire-bukhara': [(8, 219, 223, 'Оғози ҳукмронии сулолаи Манғитиён', None),
                       (8, 255, 259, 'Сохти маъмурии аморати Бухоро', None),
                       (9, 61, 64, 'Вазъи сиёсии аморати Бухоро', None)],
    'empire-kokand': [(8, 231, 234, 'Таъсиси хонии Хӯқанд', None),
                      (8, 239, 244, 'Хонҳои Хӯқанд', None)],
    'empire-russian': [(9, 9, 12, 'Сабабҳои ҷанги Русия бо давлатҳои Осиёи Марказӣ', None),
                       (9, 51, 54, 'Оқибатҳои забти Осиёи Марказӣ аз тарафи Русия', None)],
    'event-tajik-ussr': [(10, 91, 95, 'Таъсисёбии ҶМШС Тоҷикистон', None),
                         (10, 128, 131, 'Таъсисёбии ҶШС Тоҷикистон', None)],
    'event-civil-war': [(10, 31, 33, 'Сабабҳои ҷанги шаҳрвандии солҳои 1918–1923', None),
                        (10, 64, 68, 'Ба охир расидани ҷанги шаҳрвандӣ', None)],
    'event-world-war-two': [(10, 231, 233, 'Давраи аввали Ҷанги бузурги Ватанӣ', None),
                            (10, 258, 261, 'Ақибгоҳ дар хидмати ҷанг', None)],
    'event-independence': [(11, 97, 101, 'Шароити таърихии ташкилёбии Ҷумҳурии соҳибистиқлол', None),
                           (11, 102, 108, 'Эълон гардидани истиқлолияти давлатӣ', None)],
    'person-shapur-i': [(6, 6, 12, 'Шопури I', r'Шопур')],
    'person-akhshunvar': [(6, 44, 46, 'Ахшунвар', r'Ахшунвар|Ахушнавоз|Ахшунавоз')],
    'person-khosrow-parviz': [(6, 18, 19, 'Хусрави Парвиз', None)],
    'person-abdallah-tahir': [(7, 25, 30, 'Абдуллоҳи Тоҳир', r'Абдуллоҳ')],
    'person-yaqub-layth': [(7, 31, 37, 'Яъқуби Лайс', r'Яъқуб')],
    'person-nasr-ii': [(7, 45, 90, 'Насри II', r'Насри II')],
    'person-evsen': [(6, 42, 46, 'Евсенҳо', r'Евсен')],
    'person-ardashir': [(6, 6, 8, 'Ардашери Бобакон', r'Ардашер')],
    'person-anushirvan': [(6, 14, 18, 'Хусрави Анӯшервон', r'Анӯшервон|Хусрави I\b')],
    'person-devashtich': [(6, 176, 179, 'Шӯриш бо сарварии Деваштич', None),
                          (6, 180, 183, 'Бойгонии Деваштич', None)],
    'person-abu-muslim': [(7, 21, 24, 'Абӯмуслими Хуросонӣ', None)],
    'person-ismail-samani': [(7, 38, 44, 'Исмоили Сомонӣ', r'Исмоил')],
    'person-temurmalik': [(7, 187, 190, 'Темурмалик — сарвари мудофиа', None)],
    'person-jaloliddin': [(7, 191, 193, 'Шуҷоати Ҷалолуддини Хоразмшоҳ', None)],
    'person-ibrohim-bek': [(10, 55, 63, 'Иброҳимбек', r'Иброҳимбек')],
    'person-emomali-rahmon': [(11, 118, 122, 'Иҷлосияи таърихии тақдирсоз', None)],
    # Phase 7: the history books do discuss these two after all.
    'person-ayni': [(11, 215, 216, 'Қаҳрамони Тоҷикистон', r'Айнӣ'),
                    (9, 148, 149, 'Мактаби усули нави Мунзим ва Айнӣ', r'Айнӣ')],
    'poem-khurrami': [(6, 204, 206, 'Хуррамии Самарқандӣ ва шуубия',
                       r'Хуррами')],
}


def page_text(pages_dir, grade, page):
    path = os.path.join(pages_dir, str(grade), f'{page}.txt')
    return decode_legacy(open(path, encoding='utf-8').read())


LESSON_HEAD = re.compile(rf'^\s*(?:§\s*\d+|\d{{1,2}}\.\s+[{UPPER}][{UPPER}\s\-–,.«»()]+$)')
LESSON_END = re.compile(r'^\s*(?:Савол ва супориш|САВОЛ ВА СУПОРИШ|Саволҳо)\b')


def lesson_lines(pages_dir, grade, first, last, whole_pages=False):
    """[(page, line)] of the lesson that starts on `first`: from just after
    its heading to its questions («Савол ва супориш») or the next lesson.
    With whole_pages, every lesson on the pages (used to find a person)."""
    out = []
    started = whole_pages
    for page in range(first, last + 1):
        lines = page_text(pages_dir, grade, page).split('\n')
        i = 0
        while i < len(lines):
            line = lines[i]
            if LESSON_HEAD.match(line):
                if started and not whole_pages:
                    return out
                started = True
                # skip the rest of the capitalised heading
                i += 1
                while i < len(lines) and (not lines[i].strip() or re.fullmatch(
                        rf'[{UPPER}\s\-–,.«»()0-9]+', lines[i].strip())):
                    i += 1
                continue
            if LESSON_END.match(line):
                if started and not whole_pages:
                    return out
                started = False
            elif started:
                out.append((page, line))
            i += 1
    return out


def paragraphs(pages_dir, grade, first, last, whole_pages=False):
    """[(page, paragraph)] of running prose; headings, captions, page
    numbers and footnotes left out."""
    out = []
    current, start = [], None
    for page, line in lesson_lines(pages_dir, grade, first, last, whole_pages):
        stripped = line.strip()
        if not stripped or re.fullmatch(r'\d{1,3}', stripped) or \
                re.match(r'^(Расми|Расм\.|Харитаи)\s', stripped) or \
                re.fullmatch(rf'[{UPPER}\s\-–,.«»()0-9§IVXLC]+', stripped):
            continue
        indent = len(line) - len(line.lstrip())
        if indent >= 2 and current:
            out.append((start, ' '.join(current)))
            current = []
        if not current:
            start = page
        current.append(stripped)
    if current:
        out.append((start, ' '.join(current)))
    cleaned = []
    for page, text in out:
        text = re.sub(r'(\w)[-\xad]\s+(\w)', r'\1\2', text)
        text = text.replace('\xad', '')            # a soft hyphen
        text = re.sub(r'(?<=[^\W\d_])\d{1,2}(?=[\s,.;:])', '', text)
        text = re.sub(r'\s+', ' ', text).strip()
        if len(text) > 60 and not re.match(r'^\d{1,2}[.)]\s', text):
            cleaned.append((page, text))
    return cleaned


def excerpt(pages_dir, grade, first, last, name):
    paras = paragraphs(pages_dir, grade, first, last, whole_pages=bool(name))
    if name:
        paras = [p for p in paras if re.search(name, p[1])]
    taken, total = [], 0
    for page, text in paras:
        if total and total + len(text) > LIMIT:
            break
        taken.append((page, text))
        total += len(text)
        if total >= LIMIT * 0.6:
            break
    if not taken:
        return None
    # A paragraph carried over from the previous page opens mid-sentence;
    # the excerpt starts at its first whole sentence.
    page, text = taken[0]
    if text[:1].islower() and '. ' in text:
        taken[0] = (page, text[text.index('. ') + 2:])
    body = '\n\n'.join(text for _, text in taken)
    if len(body) > LIMIT * 1.4:
        cut = body[:int(LIMIT * 1.4)]
        body = cut[:cut.rfind('.') + 1] or cut
    return body, taken[0][0], taken[-1][0]


def build(pages_dir):
    sections = {}
    for entry_id, plan in PLAN.items():
        built = []
        for grade, first, last, heading, name in plan:
            result = excerpt(pages_dir, grade, first, last, name)
            if result is None:
                continue
            body, page_start, page_end = result
            section = {
                'heading': heading,
                'body': body,
                'sourceBookId': f'history-{grade}',
                'printedPage': page_start,
                'pdfPage': page_start,
            }
            if page_end != page_start:
                section['printedPageEnd'] = page_end
                section['pdfPageEnd'] = page_end
            built.append(section)
        sections[entry_id] = built
    return sections


def main(pages_dir, write):
    sections = build(pages_dir)
    entries = json.load(open(ENTRIES, encoding='utf-8'))
    filled = 0
    for entry in entries:
        new = sections.get(entry['id'])
        if new and not entry.get('sections'):
            entry['sections'] = new
            filled += 1
    print(f'entries given sections: {filled}; sections: '
          f'{sum(len(v) for v in sections.values())}')
    if write:
        with open(ENTRIES, 'w', encoding='utf-8') as f:
            json.dump(entries, f, ensure_ascii=False, indent=2)
            f.write('\n')
    return sections


if __name__ == '__main__':
    main(sys.argv[1], '--write' in sys.argv)
