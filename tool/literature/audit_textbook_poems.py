"""Audit every published textbook poem against its printed pages.

Usage:
    python3 tool/literature/audit_textbook_poems.py <pages_dir> [<report.json>]

For each work published with verificationMethod textbookPdfTextExtraction
(and, for the text check only, every other readable record citing a
textbook PDF):
  * text: every line of textTajik must be printed, verbatim after the
    legacy-font map and footnote-marker removal, on the cited pages
    (pageStart..pageEnd, printed numbers);
  * pages: pageStart..pageEnd must be the pages the lines are printed on;
  * form: no line may be prose printed among the verse -- a line that opens
    a prose paragraph, or a lead-in ending in ':' set left of the verse;
  * attribution: the lead-in above the first line must not name another
    poet or introduce folk verse, an elegy, a translation or examples
    (the guards of extract_textbook_poems.py); and the line right under
    the last line must not sign the verse with another poet's name
    («(Шаҳиди Балхӣ)»).

A lead-in that a person read and confirmed is not flagged again: those
listed, with the reason, in docs/literature/ATTRIBUTION_GUARD_EXCEPTIONS.json,
and the blocks accepted in the hand-review logs
docs/literature/EXTRACTION_REVIEW_*.json.

Verse the text layer sets flush left (no indent) is judged against its own
margin: a line counts as prose there only when it is too long for verse.

Exits 1 when any poem fails, listing each failure.
"""
import glob
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import (  # noqa: E402
    lead_in_disqualifies, load_pages, poet_names, printed_page,
    quoted_from_other_poet, text_above,
)
from textbook_verse import (  # noqa: E402
    MAX_VERSE_CHARS, MIN_INDENT, SHALLOW, _indent, _indented_paragraph,
    _starts_paragraph, clean_line, is_heading, norm,
)

WORKS = 'assets/data/literature/works.json'
POETS = 'assets/data/literature/poets.json'
EXCEPTIONS = 'docs/literature/ATTRIBUTION_GUARD_EXCEPTIONS.json'
REVIEWS = 'docs/literature/EXTRACTION_REVIEW_*.json'
NEAR = 3        # lines of a poem are printed at most this far apart


def reviewed_ids(blocks):
    """Record ids of the blocks a person accepted in a hand review: those
    the publisher recorded (`recordIds`), else the stable id of the block."""
    from publish_reviewed_blocks import stable_id
    ids = set()
    for b in blocks:
        if b.get('decision') == 'accept':
            ids |= set(b.get('recordIds') or
                       [stable_id(b['book'], b['pdfPage'], b['opening'])])
    return ids


def printed_index(pages):
    """{printed page number: pdf index}."""
    index = {}
    for i in range(1, len(pages)):
        index.setdefault(printed_page(pages[i], i), i)
    return index


_list_number = re.compile(r'^\s*\d{1,2}\.\s+')


def page_lines(pages, first, last):
    lines = set()
    for i in range(max(first, 1), min(last, len(pages) - 1) + 1):
        for line in pages[i].split('\n'):
            if line.strip():
                lines.add(norm(clean_line(line)))
                # A numbered rubai («1. Гар бар сари…»): the number is a label.
                lines.add(norm(clean_line(_list_number.sub('', line))))
    return lines


def _readable_from_textbook(work):
    """A readable record whose source is one of the textbook PDFs."""
    source = work.get('primarySource') or {}
    return (work['verification'].get('evidenceLevel') == 'primaryChecked' and
            bool(work.get('textTajik')) and source.get('pageStart') is not None and
            (source.get('sourceReference') or '').startswith('docs/literature/pdfs/'))


def missing_lines(work, pages, index):
    """Lines of the work not printed on its cited pages."""
    source = work['primarySource']
    first = index.get(source['pageStart'], source['pageStart'])
    last = index.get(source['pageEnd'], source['pageEnd'])
    printed = page_lines(pages, first, last)
    return [line for line in work['textTajik'].split('\n')
            if line.strip() and norm(line) not in printed]


def _find(pages, line, start, last):
    """(page, line number) of `line` at or after `start`, else None."""
    first_page, first_line = start
    for i in range(first_page, min(last, len(pages) - 1) + 1):
        lines = pages[i].split('\n')
        begin = first_line if i == first_page else 0
        for j in range(begin, len(lines)):
            if norm(clean_line(lines[j])) == norm(line):
                return i, j
    return None


def _gap(pages, at, found):
    """Printed text lines between position `at` and `found` (across a page
    break: those left on the first page, bar its number, and those above
    `found` on the next)."""
    def text(lines):
        return sum(1 for l in lines if l.strip() and not re.fullmatch(r'\s*\d{1,3}\s*', l))
    if found[0] == at[0]:
        return found[1] - at[1]
    rest = pages[at[0]].split('\n')[at[1]:]
    above = pages[found[0]].split('\n')[:found[1]]
    return text(rest) + text(above)


def _anchor(pages, verse, first, last):
    """Where the poem starts: the copy of its first line followed by the
    most of its other lines, in order (a page may quote a line twice)."""
    best, best_score = (first, 0), -1
    start = (first, 0)
    while True:
        found = _find(pages, verse[0], start, last)
        if found is None:
            return best
        score, at = 0, (found[0], found[1] + 1)
        for line in verse[1:]:
            nxt = _find(pages, line, at, last)
            if nxt is None or _gap(pages, at, nxt) > NEAR:
                break                 # the next line must follow closely,
                                      # or open the next page
            score, at = score + 1, (nxt[0], nxt[1] + 1)
        if score > best_score:
            best, best_score = found, score
        start = (found[0], found[1] + 1)


def locate(work, pages, index):
    """[(line, pdf page, line number)]: where each line of the work is
    printed within its cited pages, matched in order."""
    source = work['primarySource']
    first = max(index.get(source['pageStart'], source['pageStart']), 1)
    last = index.get(source['pageEnd'], source['pageEnd'])
    verse = [line for line in work['textTajik'].split('\n') if line.strip()]
    located = []
    at = _anchor(pages, verse, first, last)
    for line in verse:
        found = _find(pages, line, at, last) or _find(pages, line, (first, 0), last)
        if found:
            located.append((line, found[0], found[1]))
            at = (found[0], found[1] + 1)
    return located


def printed_pages(work, pages, index):
    """(first, last) printed page numbers on which the work's lines are
    printed, or None when they are not found."""
    located = locate(work, pages, index)
    if not located:
        return None
    number = {pdf: printed for printed, pdf in index.items()}
    return (number[min(i for _, i, _ in located)],
            number[max(i for _, i, _ in located)])


def _opens_paragraph(lines, j):
    """textbook_verse._starts_paragraph, except that a heading set flush
    left under the last line of a poem is not a prose paragraph."""
    if not _starts_paragraph(lines, j):
        return False
    nxt = next((l for l in lines[j + 1:] if l.strip()), '')
    return not is_heading(nxt)


def prose_lines(work, pages, index):
    """Lines of the work printed as prose: a paragraph opening, or a
    lead-in ending in ':' set left of the verse. Each page is judged by
    the verse's margin on that page (facing pages differ, and the text
    layer sets some pages' verse flush left)."""
    located = locate(work, pages, index)
    prose = []
    for page in sorted({i for _, i, _ in located}):
        lines = pages[page].split('\n')
        rows = [(line, j) for line, i, j in located if i == page]
        indents = sorted(_indent(lines[j]) for _, j in rows)
        verse_indent = indents[len(indents) // 2]
        if verse_indent < MIN_INDENT:
            # Flush-left verse: the indent rules cannot tell verse from prose.
            prose += [line for line, j in rows
                      if len(lines[j].strip()) > MAX_VERSE_CHARS]
            continue
        prose += [line for line, j in rows
                  if _opens_paragraph(lines, j) or
                  _indented_paragraph(lines, j, verse_indent) or
                  (line.strip().endswith(':') and
                   _indent(lines[j]) <= verse_indent - SHALLOW)]
    return prose


_SIGNATURE = re.compile(r'^\(?\s*([^()\d]{3,40}?)\s*\)?$')


def signed_by(work, pages, index, names):
    """The poet id the book signs the verse with, in a name line right
    under its last line, or None."""
    located = locate(work, pages, index)
    if not located:
        return None
    _, page, row = located[-1]
    below = pages[page].split('\n')[row + 1:]
    line = next((l.strip() for l in below if l.strip()), '')
    match = _SIGNATURE.match(line)
    if not match or line.startswith('***'):
        return None
    return names.get(norm(match.group(1)))


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


def signature_problem(work, pages, index, names):
    signer = signed_by(work, pages, index, names)
    if signer and signer != work['authorId']:
        return f'the book signs the verse with another poet ({signer})'
    return None


def audit(works, books, names, confirmed=frozenset()):
    failures = []
    checked = 0
    indexes = {book: printed_index(pages) for book, pages in books.items()}
    for work in works:
        extracted = work['verification'].get('verificationMethod') == \
            'textbookPdfTextExtraction'
        if not (extracted or _readable_from_textbook(work)):
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
        if not extracted:
            continue      # older methods: the text check only
        prose = prose_lines(work, pages, index)
        if prose:
            failures.append((work['id'], 'prose lines inside the poem', prose))
        source = work['primarySource']
        where = printed_pages(work, pages, index)
        if where and not missing and \
                where != (source['pageStart'], source['pageEnd']):
            failures.append((work['id'], 'cited pages differ from the printed pages',
                             {'cited': [source['pageStart'], source['pageEnd']],
                              'printed': list(where)}))
        problem = None if work['id'] in confirmed else \
            lead_problem(work, pages, index, names)
        if problem:
            failures.append((work['id'], problem, work['title']))
        problem = signature_problem(work, pages, index, names)
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
    for path in sorted(glob.glob(REVIEWS)):
        with open(path, encoding='utf-8') as f:
            confirmed |= reviewed_ids(json.load(f)['blocks'])
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
