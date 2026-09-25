"""Audit every published textbook poem against its printed pages.

Usage:
    python3 tool/literature/audit_textbook_poems.py <pages_dir> [<report.json>]

For each work published with verificationMethod textbookPdfTextExtraction:
  * text: every line of textTajik must be printed, verbatim after the
    legacy-font map and footnote-marker removal, on the cited pages
    (pageStart..pageEnd, printed numbers);
  * attribution: the lead-in above the first line must not name another
    poet or introduce folk verse, an elegy, a translation or examples
    (the guards of extract_textbook_poems.py).

A lead-in that a person read and confirmed is listed, with the reason, in
docs/literature/ATTRIBUTION_GUARD_EXCEPTIONS.json and is not flagged again.

Exits 1 when any poem fails, listing each failure.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import (  # noqa: E402
    lead_in_disqualifies, load_pages, poet_names, printed_page,
    quoted_from_other_poet, text_above,
)
from textbook_verse import clean_line, norm  # noqa: E402

WORKS = 'assets/data/literature/works.json'
POETS = 'assets/data/literature/poets.json'
EXCEPTIONS = 'docs/literature/ATTRIBUTION_GUARD_EXCEPTIONS.json'


def printed_index(pages):
    """{printed page number: pdf index}."""
    index = {}
    for i in range(1, len(pages)):
        index.setdefault(printed_page(pages[i], i), i)
    return index


def page_lines(pages, first, last):
    lines = set()
    for i in range(max(first, 1), min(last, len(pages) - 1) + 1):
        for line in pages[i].split('\n'):
            if line.strip():
                lines.add(norm(clean_line(line)))
    return lines


def missing_lines(work, pages, index):
    """Lines of the work not printed on its cited pages."""
    source = work['primarySource']
    first = index.get(source['pageStart'], source['pageStart'])
    last = index.get(source['pageEnd'], source['pageEnd'])
    printed = page_lines(pages, first, last)
    return [line for line in work['textTajik'].split('\n')
            if line.strip() and norm(line) not in printed]


def lead_problem(work, pages, index, names):
    source = work['primarySource']
    first = index.get(source['pageStart'], source['pageStart'])
    lines = [l for l in work['textTajik'].split('\n') if l]
    lead = text_above(pages, first, lines)
    if quoted_from_other_poet(lead, work['authorId'], names):
        return 'the lead-in names another poet'
    if lead_in_disqualifies(lead):
        return 'the lead-in introduces verse that is not the poet\'s own'
    return None


def audit(works, books, names, confirmed=frozenset()):
    failures = []
    checked = 0
    indexes = {book: printed_index(pages) for book, pages in books.items()}
    for work in works:
        if work['verification'].get('verificationMethod') != \
                'textbookPdfTextExtraction':
            continue
        book = os.path.basename(work['primarySource']['sourceReference'])[:-4]
        if book not in books:
            failures.append((work['id'], 'book not found', book))
            continue
        checked += 1
        pages, index = books[book], indexes[book]
        missing = missing_lines(work, pages, index)
        if missing:
            failures.append((work['id'], 'lines not on the cited pages', missing))
        problem = None if work['id'] in confirmed else \
            lead_problem(work, pages, index, names)
        if problem:
            failures.append((work['id'], problem, work['title']))
    return checked, failures


def main(pages_dir, report_path=None):
    with open(WORKS, encoding='utf-8') as f:
        works = json.load(f)
    with open(POETS, encoding='utf-8') as f:
        poets = json.load(f)
    names = poet_names(poets)
    with open(EXCEPTIONS, encoding='utf-8') as f:
        confirmed = {e['id'] for e in json.load(f)['exceptions']}
    books = {b: load_pages(pages_dir, b) for b in sorted(os.listdir(pages_dir))
             if os.path.isdir(os.path.join(pages_dir, b))}
    checked, failures = audit(works, books, names, confirmed)
    for work_id, problem, detail in failures:
        print(f'FAIL {work_id}: {problem}: {detail}')
    print(f'checked {checked} textbook poems; {len(failures)} failures')
    if report_path:
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump({'checked': checked, 'failures': failures}, f,
                      ensure_ascii=False, indent=1)
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main(*sys.argv[1:3]))
