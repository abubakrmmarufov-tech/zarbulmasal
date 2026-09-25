"""Set each textbook poem's cited pages to the pages its lines are printed on.

Usage:
    python3 tool/literature/correct_cited_pages.py <pages_dir>

For works published with verificationMethod textbookPdfTextExtraction,
pageStart/pageEnd become the first and last printed page on which the
work's lines appear (found in order within the cited range; see
audit_textbook_poems.locate). A range that was one page too wide at either
end -- the extractor used to count a following page that gave no verse --
is narrowed. Works whose lines are not all found are left alone. The page
named in the rights note follows pageStart. Prints each change.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from audit_textbook_poems import missing_lines, printed_index, printed_pages  # noqa: E402
from extract_textbook_poems import load_pages  # noqa: E402

WORKS = 'assets/data/literature/works.json'


def correct(works, books):
    """Correct `works` in place; returns [(id, old range, new range)]."""
    changes = []
    indexes = {book: printed_index(pages) for book, pages in books.items()}
    for work in works:
        if work['verification'].get('verificationMethod') != \
                'textbookPdfTextExtraction':
            continue
        source = work['primarySource']
        book = os.path.basename(source['sourceReference'])[:-4]
        if book not in books:
            continue
        pages, index = books[book], indexes[book]
        if missing_lines(work, pages, index):
            continue
        where = printed_pages(work, pages, index)
        old = (source['pageStart'], source['pageEnd'])
        if where is None or where == old:
            continue
        work['primarySource'] = dict(source, pageStart=where[0], pageEnd=where[1])
        rights = work.get('rights') or {}
        if rights.get('reasoning'):
            rights['reasoning'] = re.sub(r'page \d+\.$', f'page {where[0]}.',
                                         rights['reasoning'])
        changes.append((work['id'], old, where))
    return changes


def main(pages_dir):
    with open(WORKS, encoding='utf-8') as f:
        works = json.load(f)
    books = {b: load_pages(pages_dir, b) for b in sorted(os.listdir(pages_dir))
             if os.path.isdir(os.path.join(pages_dir, b))}
    changes = correct(works, books)
    with open(WORKS, 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
        f.write('\n')
    for work_id, old, new in changes:
        print(f'{work_id}: pp. {old[0]}-{old[1]} -> {new[0]}-{new[1]}')
    print(f'{len(changes)} cited ranges corrected')


if __name__ == '__main__':
    main(sys.argv[1])
