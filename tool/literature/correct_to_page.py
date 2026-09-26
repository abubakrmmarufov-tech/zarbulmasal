"""Set a published poem's lines to what its cited page prints.

Usage:
    python3 tool/literature/correct_to_page.py <pages_dir> <decisions.json> [--apply]
    dart run tool/build_runtime_literature.dart

<decisions.json> (e.g. docs/literature/TEXT_CORRECTIONS_2026-09-26.json)
lists the records a person compared with the page images, each with the
reason and, when the poem is known by a printed heading, its `title`.

For each record, a line of textTajik that its cited pages do not print
verbatim is replaced by the printed line it most resembles; a printed list
number («1. Гар бар сари…») is a label, not text. Nothing else in the text
changes; a line with no close printed line stops the run (NotOnPage). The
title follows the first line when the poem is known by it, and the incipit
likewise; the generated Persian script is generated again. Without --apply
the changes are only printed. With --apply they are written to works.json
and, with their before and after, to the decisions file (`changes`).
"""
import difflib
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from extract_textbook_poems import first_line_title, load_pages  # noqa: E402
from textbook_verse import clean_line, norm  # noqa: E402

WORKS = 'assets/data/literature/works.json'
MIN_RATIO = 0.75
_list_number = re.compile(r'^\d{1,2}\.\s+')


class NotOnPage(Exception):
    pass


def printed_lines(pages, first, last):
    """The printed lines of pages first..last (PDF indices), cleaned."""
    out = []
    for index in range(max(first, 1), min(last, len(pages) - 1) + 1):
        for line in pages[index].split('\n'):
            line = _list_number.sub('', clean_line(line))
            if line.strip() and not re.fullmatch(r'\d{1,3}', line.strip()):
                out.append(line.strip())
    return out


def correct(text, printed):
    """(text, changes): [text] with every line set as [printed] prints it."""
    exact = {norm(line): line for line in printed}
    out, changes = [], []
    for line in text.split('\n'):
        if not line.strip() or norm(line) in exact:
            out.append(line)
            continue
        best = max(printed, key=lambda candidate: difflib.SequenceMatcher(
            None, norm(line), norm(candidate)).ratio())
        ratio = difflib.SequenceMatcher(None, norm(line), norm(best)).ratio()
        if ratio < MIN_RATIO:
            raise NotOnPage(f'not printed on the cited pages: «{line}»')
        out.append(best)
        changes.append({'before': line, 'after': best})
    return '\n'.join(out), changes


def is_first_line_title(title, first_line):
    return norm(first_line_title(title)) == norm(first_line_title(first_line))


def _pdf_index(pages, printed_page):
    from audit_textbook_poems import printed_index
    return printed_index(pages).get(printed_page, printed_page)


def apply_decision(work, decision, pages):
    from transliterate_tajik import transliterate_text
    source = work['primarySource']
    first = _pdf_index(pages, source['pageStart'])
    last = _pdf_index(pages, source['pageEnd'] or source['pageStart'])
    old_first = next(l for l in work['textTajik'].split('\n') if l.strip())
    text, changes = correct(work['textTajik'], printed_lines(pages, first, last))
    new_first = next(l for l in text.split('\n') if l.strip())
    title = decision.get('title')
    if title is None and is_first_line_title(work['title'], old_first):
        title = first_line_title(new_first)
    if title and title != work['title']:
        changes.append({'field': 'title', 'before': work['title'], 'after': title})
        work['title'] = title
        if work.get('titlePersianSource') == 'generated':
            work['titlePersian'] = transliterate_text(title)
    if work.get('incipit') and norm(work['incipit']) == norm(old_first):
        work['incipit'] = new_first
    work['textTajik'] = text
    if work.get('persianScriptSource') == 'generated':
        work['persianScriptRepresentation'] = transliterate_text(text)
    return changes


def main(pages_dir, decisions_path, apply=False):
    with open(WORKS, encoding='utf-8') as handle:
        works = json.load(handle)
    with open(decisions_path, encoding='utf-8') as handle:
        decisions = json.load(handle)
    by_id = {work['id']: work for work in works}
    books = {}
    for decision in decisions['records']:
        work = by_id[decision['id']]
        book = os.path.basename(work['primarySource']['sourceReference'])[:-4]
        pages = books.setdefault(book, load_pages(pages_dir, book))
        changes = apply_decision(work, decision, pages)
        decision['changes'] = changes
        print(f"{decision['id']}: {len(changes)} change(s)")
        for change in changes:
            print(f"  - {change['before']}\n  + {change['after']}")
    if apply:
        with open(WORKS, 'w', encoding='utf-8') as handle:
            handle.write(json.dumps(works, ensure_ascii=False, indent=2) + '\n')
        with open(decisions_path, 'w', encoding='utf-8') as handle:
            handle.write(json.dumps(decisions, ensure_ascii=False, indent=2) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1], sys.argv[2], '--apply' in sys.argv[3:]))
