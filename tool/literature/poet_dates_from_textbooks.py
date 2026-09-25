"""Align poets' life dates with the chapter headings of the textbooks.

Usage:
    python3 tool/literature/poet_dates_from_textbooks.py <pages_dir> [--write]

<pages_dir>/<book>/<n>.txt holds `pdftotext -layout` output for
docs/literature/pdfs/<book>.pdf (see extract_textbook_poems.py).

A poet chapter opens with the name in capitals and the dates in brackets:

    АҲМАДИ ҶОМӢ
    (1049-1141)

The dates are taken exactly as printed ("тахминан 980", "байни солҳои
1009-1020", "таваллуд 1946"). When a poet's record disagrees with the
heading, the record takes the printed dates and `lifeDatesSource` names
the page. If two textbooks print different dates, the one the poet's
biography cites wins, else the higher grade; the conflict is reported.
Day-precise dates in the record are kept only when their years match.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from textbook_verse import decode_legacy  # noqa: E402

POETS = 'assets/data/literature/poets.json'
UPPER = 'А-ЯЁӢӮҲҶҚҒ'
_DATES = re.compile(r'\(\s*([^()]{0,60}?\d{3,4}[^()]{0,60}?)\s*\)')
_APPROX = re.compile(r'^(?:тахминан|тақрибан)\s+', re.IGNORECASE)
_BORN_ONLY = re.compile(r'^(?:соли\s+)?таваллуд(?:аш)?\s+(\d{4})$', re.IGNORECASE)
COMMON = {'абдуллоҳ', 'муҳаммад', 'мирзо', 'шайх', 'амир', 'мир', 'хоҷа',
          'мавлоно', 'аҳмад', 'абулқосим', 'абӯабдуллоҳ'}


def words(text):
    """Name words without the izofa ending, so "Ҷомии" matches "Ҷомӣ"."""
    out = []
    for word in re.findall(r'[^\W\d_]+', text.lower()):
        if len(word) > 4 and word.endswith('и') and not word.endswith('ӣи'):
            word = word[:-1]
        out.append(word)
    return out


def grade_of(book):
    match = re.search(r'sinfi\s*(\d+)', book)
    return int(match.group(1)) if match else 0


def printed_page(page_text, index):
    for line in reversed(page_text.strip().split('\n')):
        if re.fullmatch(r'\s*\d{1,3}\s*', line):
            return int(line)
        if line.strip():
            break
    return index


def chapter_headings(pages):
    """(pdf index, heading, printed dates) for every dated name heading."""
    found = []
    for index, text in enumerate(pages):
        lines = text.split('\n')
        for i, line in enumerate(lines):
            stripped = line.strip()
            name = _DATES.sub('', stripped).strip(' -–')
            if len(re.sub(rf'[^{UPPER}]', '', name)) < 5 or \
                    not re.fullmatch(rf'[{UPPER}\s\-–]+', name):
                continue
            match = _DATES.search(stripped)
            if match is None:
                following = next((x.strip() for x in lines[i + 1:i + 3]
                                  if x.strip()), '')
                match = _DATES.fullmatch(following)
            if match is not None:
                found.append((index, name, match.group(1).strip()))
    return found


def match_poet(heading, poets):
    """The poet whose name the heading is: an exact word match first, then
    a unique poet sharing a distinctive word with a subset/superset name."""
    head = words(heading)
    exact, loose = [], []
    for poet in poets:
        for name in [poet.get('canonicalName', '')] + list(poet.get('aliases') or []):
            name_words = words(name)
            if not name_words:
                continue
            if name_words == head:
                exact.append(poet)
            shared = {w for w in set(head) & set(name_words)
                      if w not in COMMON and len(w) >= 4}
            if shared and (set(head) <= set(name_words) or set(name_words) <= set(head)):
                loose.append(poet)
    for group in (exact, loose):
        unique = {p['id']: p for p in group}
        if len(unique) == 1:
            return next(iter(unique.values()))
    return None


def parse_dates(printed):
    """(birthYear, deathYear, birthExact, deathExact) as printed, or None."""
    printed = ' '.join(printed.split())
    born = _BORN_ONLY.match(printed)
    if born:
        return born.group(1), None, None, None
    # "940 – байни солҳои 1009-1020": a spaced dash separates birth and
    # death; only without one does a bare dash ("1049-1141") do so.
    parts = re.split(r'\s[–-]\s', printed, maxsplit=1)
    if len(parts) != 2:
        parts = re.split(r'(?<=\d)[–-](?=\d)', printed, maxsplit=1)
    if len(parts) != 2:
        return None
    b_year, b_exact = _one(parts[0].strip())
    d_year, d_exact = _one(parts[1].strip())
    return b_year, d_year, b_exact, d_exact


def _one(part):
    part = part.replace('солҳои ', '')
    if _APPROX.match(part):
        value = _APPROX.sub('', part)
        return '~' + value, 'Тақрибан ' + value
    if re.fullmatch(r'\d{3,4}', part):
        return part, None
    return part, part


def years_in(value):
    return re.findall(r'\d{3,4}', value or '')


def main(pages_dir, write):
    poets = json.load(open(POETS, encoding='utf-8'))
    headings = {}
    for book in sorted(os.listdir(pages_dir)):
        folder = os.path.join(pages_dir, book)
        count = len([f for f in os.listdir(folder) if f.endswith('.txt')])
        pages = [''] + [decode_legacy(open(os.path.join(folder, f'{n}.txt'),
                                           encoding='utf-8').read())
                        for n in range(1, count + 1)]
        for index, name, printed in chapter_headings(pages):
            poet = match_poet(name, poets)
            parsed = parse_dates(printed)
            if poet is None or parsed is None:
                continue
            headings.setdefault(poet['id'], []).append({
                'book': book, 'grade': grade_of(book),
                'page': printed_page(pages[index], index),
                'printed': printed, 'parsed': parsed,
            })
    changes, conflicts = [], []
    for poet in poets:
        found = headings.get(poet['id'])
        if not found:
            continue
        cited = grade_of(poet.get('biographySource', '').replace('синфи', 'sinfi'))
        found.sort(key=lambda h: (h['grade'] != cited, -h['grade']))
        chosen = found[0]
        if len({h['parsed'][:2] for h in found}) > 1:
            conflicts.append((poet['canonicalName'],
                              [(h['grade'], h['page'], h['printed']) for h in found]))
        b_year, d_year, b_exact, d_exact = chosen['parsed']
        born_only = d_year is None
        same_birth = years_in(poet.get('birthYear')) == years_in(b_year)
        same_death = born_only or years_in(poet.get('deathYear')) == years_in(d_year)
        if same_birth and same_death:
            continue
        if born_only:
            # A book printed in the poet's lifetime gives the birth year
            # only; a death recorded since is not contradicted by it.
            d_year = poet.get('deathYear')
            d_exact = poet.get('deathDateExact')
        if years_in(poet.get('birthYear')) == years_in(b_year) and poet.get('birthDateExact'):
            b_exact = poet.get('birthDateExact')
        if years_in(poet.get('deathYear')) == years_in(d_year) and poet.get('deathDateExact'):
            d_exact = poet.get('deathDateExact')
        before = (poet.get('birthYear'), poet.get('deathYear'),
                  poet.get('birthDateExact'), poet.get('deathDateExact'))
        poet['birthYear'] = b_year
        poet['deathYear'] = d_year
        poet['birthDateExact'] = b_exact
        poet['deathDateExact'] = d_exact
        poet['lifeDatesSource'] = (f"«Адабиёти тоҷик», синфи {chosen['grade']}, "
                                   f"с. {chosen['page']}")
        changes.append((poet['canonicalName'], before,
                        (b_year, d_year, b_exact, d_exact), poet['lifeDatesSource']))
    for change in changes:
        print('CHANGE', *change)
    for conflict in conflicts:
        print('TEXTBOOKS DIFFER', *conflict)
    print(f'{len(changes)} poets updated; {len(conflicts)} conflicts')
    if write and changes:
        with open(POETS, 'w', encoding='utf-8') as f:
            json.dump(poets, f, ensure_ascii=False, indent=2)
            f.write('\n')
    return changes, conflicts


if __name__ == '__main__':
    main(sys.argv[1], '--write' in sys.argv)
