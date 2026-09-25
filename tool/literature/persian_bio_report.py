"""Report Persian biographies that contradict the textbooks (report only).

Usage:
    python3 tool/literature/persian_bio_report.py <pages_dir> <report.md>

The Persian biographies (`biographyFa`) were written from outside sources;
the Tajik records follow the textbook PDFs. For each poet this compares:
  * life dates: the Gregorian span in the Persian text ("(۱۰۴۸–۱۱۴۱ م)",
    or an unmarked span in brackets; Hijri and Shamsi spans are skipped)
    with the dates the textbook chapter heading prints (see
    poet_dates_from_textbooks.py). Approximate textbook years allow one
    year either way;
  * birthplace: where the Persian text speaks of a birth ("متولد", "زاده")
    but does not name the place the textbook gives (compared on consonant
    skeletons, since Persian script omits short vowels), the two are listed
    for a reader to compare.
Nothing is changed; the report is for a translator.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from poet_dates_from_textbooks import (  # noqa: E402
    chapter_headings, grade_of, match_poet, parse_dates, printed_page, years_in,
)
from textbook_verse import decode_legacy  # noqa: E402

POETS = 'assets/data/literature/poets.json'
_DIGITS = str.maketrans('۰۱۲۳۴۵۶۷۸۹٠١٢٣٤٥٦٧٨٩', '01234567890123456789')
_SPAN = re.compile(r'(\d{3,4})\s*[–\-]\s*(\d{3,4})')
_BIRTH = re.compile(r'متولد|زاده|به دنیا|تولد')

# Consonant classes shared by the two scripts; vowels and the letters that
# write them in Persian (ا و ی ه at a word's end) are dropped.
_TAJIK = dict(zip('бптсҷчхҳдзржшғфқкглмн', 'bptsjcxhdzrZSgfqkGlmn'))
_PERSIAN = {
    'ب': 'b', 'پ': 'p', 'ت': 't', 'ط': 't', 'ث': 's', 'س': 's', 'ص': 's',
    'ج': 'j', 'چ': 'c', 'خ': 'x', 'ح': 'h', 'ه': 'h', 'د': 'd', 'ذ': 'z',
    'ز': 'z', 'ض': 'z', 'ظ': 'z', 'ر': 'r', 'ژ': 'Z', 'ش': 'S', 'غ': 'g',
    'ف': 'f', 'ق': 'q', 'ک': 'k', 'ك': 'k', 'گ': 'G', 'ل': 'l', 'م': 'm',
    'ن': 'n',
}


def gregorian_span(bio):
    """(birth, death) years of the first Gregorian span in `bio`, or None."""
    text = (bio or '').translate(_DIGITS)
    for match in _SPAN.finditer(text):
        after = text[match.end():].lstrip(' ‌‍')
        before = text[:match.start()].rstrip()
        if after.startswith('م'):
            return match.group(1), match.group(2)
        if after[:1] in ('ه', 'ق', 'ش'):
            continue
        if before.endswith('(') and after.startswith(')'):
            return match.group(1), match.group(2)
    return None


def compare_dates(textbook, persian):
    """A note on how the Persian years differ from the textbook's, or None."""
    notes = []
    for label, printed, given in (('birth', textbook[0], persian[0]),
                                  ('death', textbook[1], persian[1])):
        if not printed or not given:
            continue
        years = [int(y) for y in years_in(printed)]
        if not years:
            continue
        slack = 1 if not re.fullmatch(r'\d{3,4}', printed.strip()) else 0
        if not any(abs(int(given) - y) <= slack for y in years):
            notes.append(f'{label} {given} vs the textbook {printed.lstrip("~")}')
    return '; '.join(notes) or None


def _skeleton(word, table):
    word = word.lower()
    if table is _PERSIAN and word.endswith('ه'):
        word = word[:-1]
    return ''.join(table.get(char, '') for char in word)


# Words that describe a place rather than name it ("деҳаи", "шаҳри" …).
_GENERIC = {
    'деҳа', 'деҳаи', 'шаҳр', 'шаҳри', 'ноҳия', 'ноҳияи', 'вилоят', 'вилояти',
    'маҳалла', 'маҳаллаи', 'тумани', 'водии', 'аморати', 'музофоти', 'дар',
    'аз', 'ва', 'воқеъ', 'кунунии', 'ҳоло', 'қадими', 'хушбодуҳавои',
}


def place_named(place, bio):
    """Whether the Persian text names the place the Tajik record gives:
    the record's first proper name, its descriptive words and bracketed
    notes aside."""
    persian = [_skeleton(w, _PERSIAN)
               for w in re.findall(r'[؀-ۿ]+', bio or '')]
    name = re.sub(r'\([^)]*\)', ' ', place or '')
    words = [w for w in re.findall(r'[^\W\d_]+', name)
             if w.lower() not in _GENERIC]
    if not words:
        return True
    want = _skeleton(words[0], _TAJIK)
    # A name in izofat ("Курговади") keeps a final vowel the skeleton drops.
    return len(want) < 2 or any(p.startswith(want) for p in persian)


def textbook_dates(pages_dir, poets):
    """{poet id: (heading dates, 'синфи N, с. P')}, preferring the book the
    biography cites, else the highest grade."""
    found = {}
    for book in sorted(os.listdir(pages_dir)):
        folder = os.path.join(pages_dir, book)
        if not os.path.isdir(folder):
            continue
        count = len([f for f in os.listdir(folder) if f.endswith('.txt')])
        pages = [''] + [decode_legacy(open(os.path.join(folder, f'{n}.txt'),
                                           encoding='utf-8').read())
                        for n in range(1, count + 1)]
        for index, name, printed in chapter_headings(pages):
            poet = match_poet(name, poets)
            parsed = parse_dates(printed)
            if poet and parsed:
                found.setdefault(poet['id'], []).append(
                    (grade_of(book), printed_page(pages[index], index), parsed))
    chosen = {}
    for poet in poets:
        options = found.get(poet['id'])
        if not options:
            continue
        cited = grade_of((poet.get('biographySource') or '').replace('синфи', 'sinfi'))
        options.sort(key=lambda o: (o[0] != cited, -o[0]))
        grade, page, parsed = options[0]
        chosen[poet['id']] = (parsed[:2], f'синфи {grade}, с. {page}')
    return chosen


def main(pages_dir, report_path):
    with open(POETS, encoding='utf-8') as f:
        poets = json.load(f)
    dates = textbook_dates(pages_dir, poets)
    date_rows, place_rows = [], []
    for poet in poets:
        bio = poet.get('biographyFa') or ''
        if not bio or poet.get('recordStatus') in ('review', 'rejected'):
            continue
        first = re.split(r'(?<=[.!؟])\s', bio)[0][:160]
        span = gregorian_span(bio)
        if poet['id'] in dates and span:
            (printed, where) = dates[poet['id']]
            note = compare_dates(printed, span)
            if note:
                shown = '–'.join(p for p in printed if p)
                date_rows.append((poet['canonicalName'], f'{shown} ({where})',
                                  f'{span[0]}–{span[1]}', note, first))
        place = poet.get('birthPlace')
        if place and _BIRTH.search(bio) and not place_named(place, bio):
            place_rows.append((poet['canonicalName'], place,
                               poet.get('biographySource') or '', first))
    lines = [
        '# Persian biographies that contradict the textbooks',
        '',
        'Report only: nothing was changed. Generated by '
        '`tool/literature/persian_bio_report.py`. The Persian biographies '
        '(`biographyFa`) come from outside sources; the Tajik records follow '
        'the textbook PDFs. A translator should correct the Persian text to '
        'the textbook, or record why it differs.',
        '',
        f'## Life dates ({len(date_rows)})',
        '',
        'The chapter heading\'s dates against the Gregorian span in the '
        'Persian text.',
        '',
        '| Poet | Textbook | Persian bio | Difference | Persian bio opens |',
        '|---|---|---|---|---|',
    ]
    lines += [f'| {a} | {b} | {c} | {d} | {e} |' for a, b, c, d, e in date_rows]
    lines += [
        '',
        f'## Birthplace to check ({len(place_rows)})',
        '',
        'The Persian text speaks of the poet\'s birth but does not name the '
        'place the Tajik record gives (compared on consonants, so a spelling '
        'difference can show up here too).',
        '',
        '| Poet | Birthplace (Tajik record) | Tajik record\'s source | Persian bio opens |',
        '|---|---|---|---|',
    ]
    lines += [f'| {a} | {b} | {c} | {d} |' for a, b, c, d in place_rows]
    with open(report_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    print(f'{len(date_rows)} date contradictions, {len(place_rows)} birthplaces to check')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
