"""Find poems in the textbook chapters that no candidate record points to.

Usage:
    python3 tool/literature/scan_textbook_chapters.py <pages_dir> <out.json>

<pages_dir>/<book>/<n>.txt holds `pdftotext -layout` output for
docs/literature/pdfs/<book>.pdf.

Attribution is deliberately narrow. A verse block is attributed to the poet
whose chapter covers its page -- the page ranges the poets' biographies
cite, used only where exactly one poet's chapter covers the page -- and
only when
  * it sits under a printed poem title, or
  * the sentence introducing it speaks of the poet's own words
    ("... шоир чунин мегӯяд:", "Худи Ҷомӣ ... менависад:");
and none of the guards fire: another poet named in the lead-in, folk
verse, an elegy or chronogram about the poet, a translation, an example
list, a theory lesson, an exam page. Everything else is left out.

The output has the same shape as extract_textbook_poems.py and is reviewed
by a person before publish_textbook_poems.py writes it.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import (  # noqa: E402
    SECTION_HEADINGS, first_line_title, lead_in_disqualifies, load_pages,
    poet_names, printed_page, quoted_from_other_poet, text_above,
)
from textbook_verse import (  # noqa: E402
    extract_poem, is_heading, norm, proper_nouns, sentence_case,
    split_heading, split_series,
)

UPPER = 'А-ЯЁӢӮҲҶҚҒ'
# Headings of lessons on theory and of non-chapter matter.
THEORY = re.compile(
    r'^(НАЗАРИЯ|ТАЛМЕҲ|ТАШБЕҲ|ИСТИОРА|ТАЗОД|МУБОЛИҒА|ТАШХИС|ИҒРОҚ|ТАРСЕЪ|'
    r'ТАҶНИС|САҶЪ|КИНОЯ|МАҶОЗ|ВАЗН|АРӮЗ|ҚОФИЯ|РАДИФ|ЖАНР|ФОЛКЛОР|'
    r'АДАБИЁТИ ШИФОҲӢ|ЭҶОДИЁТИ ШИФОҲӢ|САНЪАТҲОИ|САВОЛ|ТЕСТ|ХУЛОСА)'
)
OWN_VOICE = re.compile(
    r'(мегӯяд|гуфтааст|менависад|навиштааст|сурудааст|изҳор|ба қалам|'
    r'баён (?:доштааст|кардааст|намудааст)|овардааст|мефармояд|'
    r'чунин аст|чунин мегӯяд|ишорат|ишора карда)',
    re.IGNORECASE,
)
EXAM = re.compile(r'(\$[A-E]\)|^[АВСDЕ]\.\s|кист\?$)', re.MULTILINE)


def chapter_ranges(poets):
    """{grade: [(first page, last page, poet)]} from the page ranges the
    poets' biographies cite ("синфи 8 (2026), с. 179–200"). Single pages
    and two-page mentions are not chapters."""
    ranges = {}
    for poet in poets:
        for segment in (poet.get('biographySource') or '').split(';'):
            match = re.search(r'синфи\s*(\d+)[^,]*?,\s*с\.\s*([\d–\-,\s]+)', segment)
            if not match:
                continue
            for part in match.group(2).split(','):
                pages = [int(n) for n in re.findall(r'\d+', part)]
                if len(pages) == 2 and pages[1] - pages[0] >= 2:
                    ranges.setdefault(int(match.group(1)), []).append(
                        (pages[0], pages[1], poet))
    return ranges


def owner(ranges, grade, page):
    """The one poet whose chapter covers the printed page, else None."""
    covering = {p['id']: p for a, b, p in ranges.get(grade, []) if a <= page <= b}
    return next(iter(covering.values())) if len(covering) == 1 else None


def section_above(text, line_no):
    """The last capitalised heading above `line_no` on the page."""
    found = None
    for line in text.split('\n')[:line_no]:
        if is_heading(line) and len(line.strip()) > 3:
            found = line.strip()
    return found


def verse_starts(text):
    """Line numbers where an indented block begins after a non-verse line."""
    lines = text.split('\n')
    starts = []
    for i, line in enumerate(lines):
        if not line.strip() or len(line) - len(line.lstrip()) < 6:
            continue
        prev = next((lines[j] for j in range(i - 1, -1, -1) if lines[j].strip()), '')
        prev_indent = len(prev) - len(prev.lstrip())
        if not prev or prev_indent < 4 or is_heading(prev) or prev.rstrip().endswith(':'):
            starts.append(i)
    return starts


def scan_book(book, pages, poets, names, nouns, ranges):
    grade = int(re.search(r'sinfi\s*(\d+)', book).group(1))
    found = []
    for index in range(1, len(pages)):
        text = pages[index]
        if len(EXAM.findall(text)) >= 3:
            continue
        author = owner(ranges, grade, printed_page(text, index))
        if author is None:
            continue
        for line_no in verse_starts(text):
            section = section_above(text, line_no)
            if section and THEORY.match(section):
                continue
            opening = text.split('\n')[line_no].strip()
            result = extract_poem(pages, index, opening)
            if result is None:
                continue
            title, lines, last_index, first_index = result
            if first_index != index:
                continue            # counted where the block begins
            if not any(lines):
                continue
            if owner(ranges, grade, printed_page(pages[last_index], last_index)) is not author:
                continue            # runs into another poet's chapter
            tail = norm(lines[-1])
            if tail in names:
                if names[tail] != author['id']:
                    continue        # the book signs it with another name
                lines = lines[:-1]
                while lines and not lines[-1]:
                    lines.pop()
                if not any(lines):
                    continue
            lead = text_above(pages, first_index, lines)
            if quoted_from_other_poet(lead, author['id'], names) or \
                    lead_in_disqualifies(lead):
                continue
            genre, title = split_heading(title) if title else (None, None)
            if title and (norm(title) in names or re.search(r'[A-Za-z]', title)
                          or norm(title).startswith(SECTION_HEADINGS)
                          or THEORY.match(title.upper())):
                title = None
            lead_line = ' '.join(lead.split())
            if not title and not (lead_line.endswith(':') and
                                  OWN_VOICE.search(lead_line[-220:])):
                continue
            for part in split_series(lines):
                first_line = next(l for l in part if l)
                found.append({
                    'authorId': author['id'],
                    'author': author['canonicalName'],
                    'type': genre or 'poem',
                    'book': book,
                    'sourceReference': f'docs/literature/pdfs/{book}.pdf',
                    'pdfPageStart': first_index,
                    'pdfPageEnd': last_index,
                    'pageStart': printed_page(pages[first_index], first_index),
                    'pageEnd': printed_page(pages[last_index], last_index),
                    'heading': title,
                    'title': sentence_case(title, nouns) if title
                    else first_line_title(first_line),
                    'leadIn': lead_line[-220:],
                    'lines': part,
                })
    return found


def main(pages_dir, out_path):
    poets = [p for p in json.load(open('assets/data/literature/poets.json',
                                       encoding='utf-8'))
             if p.get('recordStatus') != 'review']
    names = poet_names(poets)
    works = json.load(open('assets/data/literature/works.json', encoding='utf-8'))
    known = set()
    bodies = []
    for work in works:
        text = work.get('textTajik') or ''
        if text:
            known.add(norm(text.split('\n')[0]))
            bodies.append('\n'.join(norm(l) for l in text.split('\n') if l))
        if work.get('incipit'):
            known.add(norm(work['incipit']))
    books = {b: load_pages(pages_dir, b) for b in sorted(os.listdir(pages_dir))
             if os.path.isdir(os.path.join(pages_dir, b))}
    nouns = proper_nouns(t for pages in books.values() for t in pages)
    ranges = chapter_ranges(poets)
    found = []
    for book, pages in books.items():
        found += scan_book(book, pages, poets, names, nouns, ranges)
    kept = []
    for poem in sorted(found, key=lambda p: -len(p['lines'])):
        first = norm(next(l for l in poem['lines'] if l))
        body = '\n'.join(norm(l) for l in poem['lines'] if l)
        if first in known or any(body in b for b in bodies) or \
                any(body in '\n'.join(norm(l) for l in k['lines'] if l) for k in kept):
            continue
        kept.append(poem)
    kept.sort(key=lambda p: (p['book'], p['pdfPageStart']))
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(kept, f, ensure_ascii=False, indent=1)
    print(f'blocks attributed: {len(found)}; new poems: {len(kept)}')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
