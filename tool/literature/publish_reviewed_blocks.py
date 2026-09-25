"""Publish the verse blocks a person accepted in a hand review.

Usage:
    python3 tool/literature/publish_reviewed_blocks.py <review.json> <pages_dir>
    dart run tool/build_runtime_literature.dart

<review.json> (e.g. docs/literature/EXTRACTION_REVIEW_2026-09-25.json) lists
each block by book, PDF page and opening line, with the reviewer's decision
and the poet the lead-in names. Only `accept` blocks are used. Each is taken
again from the page with textbook_verse.extract_poem, so the published text
is the printed text, not a copy kept in the review file.

A block is skipped, and reported, when
  * it is no longer found on the page, or does not read as verse;
  * it is already published: contained in a published text, sharing half
    its lines with one (the books reprint passages), or with the same poet,
    title and first line as a record kept in the catalogue. Punctuation is
    ignored, since reprints differ in it.
Published records get a stable id from book, page and first line, and the
same provenance as publish_textbook_poems.py.
"""
import json
import os
import re
import sys
import uuid

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import first_line_title, load_pages, printed_page  # noqa: E402
from publish_textbook_poems import fill  # noqa: E402
from textbook_verse import extract_poem, norm, reads_as_verse, split_series  # noqa: E402

WORKS = 'assets/data/literature/works.json'
NAMESPACE = uuid.UUID('6f0c6c1e-5b8e-4a55-9d0c-7a1d2f3b4c5d')
TODAY = '2026-09-25'
OVERLAP = 0.5


def stable_id(book, pdf_page, first_line):
    return str(uuid.uuid5(NAMESPACE, f'{book}|{pdf_page}|{first_line}'))


def bare(text):
    """Lower case, letters and spaces only."""
    return ' '.join(re.sub(r'[^\w\s]', ' ', norm(text or '')).split())


def verse_lines(text):
    return [bare(line) for line in text.split('\n') if bare(line)]


def work_key(author, title, incipit):
    """The linter's identity of a work: poet, title and first line."""
    return (author, bare(title).replace(' ', ''), bare(incipit).replace(' ', ''))


def take_block(pages, block):
    """The printed lines of `block`, or None with a reason."""
    result = extract_poem(pages, block['pdfPage'], block['opening'])
    if result is None:
        return None, 'not found on the page'
    _, lines, last, first = result
    if first != block['pdfPage']:
        return None, 'the block starts on another page'
    for part in split_series(lines):
        if norm(next(l for l in part if l)) == norm(block['opening']):
            if not reads_as_verse(part):
                return None, 'does not read as verse'
            return (part, first, last), None
    return None, 'the opening line starts no verse part'


class Catalogue:
    """Published texts, for the duplicate check."""

    def __init__(self, works):
        self.texts = [verse_lines(w['textTajik']) for w in works
                      if w.get('textTajik') and
                      w['verification'].get('evidenceLevel') == 'primaryChecked']
        self.keys = {work_key(w['authorId'], w.get('title'), w.get('incipit'))
                     for w in works
                     if w['verification'].get('evidenceLevel') != 'rejected'}

    def duplicate(self, lines, author=None):
        first = next(line for line in lines if line)
        if work_key(author, first_line_title(first), first) in self.keys:
            return True
        body = verse_lines('\n'.join(lines))
        joined = '\n'.join(body)
        wanted = set(body)
        for text in self.texts:
            if joined in '\n'.join(text):
                return True
            if len(wanted & set(text)) >= OVERLAP * len(wanted):
                return True
        return False

    def add(self, lines, author=None):
        self.texts.append(verse_lines('\n'.join(lines)))
        first = next(line for line in lines if line)
        self.keys.add(work_key(author, first_line_title(first), first))


def source_templates(works):
    """{sourceReference: primarySource} from records already published from
    each textbook."""
    templates = {}
    for work in works:
        source = work.get('primarySource') or {}
        ref = source.get('sourceReference') or ''
        if work['verification'].get('verificationMethod') == \
                'textbookPdfTextExtraction' and ref not in templates:
            templates[ref] = source
    return templates


def blank_record(record_id, source):
    return {
        'id': record_id, 'authorId': None, 'title': None, 'titlePersian': None,
        'incipit': None, 'type': 'poem', 'scriptSource': 'tajikOnly',
        'textTajik': None, 'textPersian': None, 'textStatus': 'needsReview',
        'editorial': 'extraction', 'editorialNotes': '',
        'primarySource': dict(source), 'secondarySource': None,
        'textMatchResult': None, 'variantNotes': None, 'rights': {},
        'verification': {}, 'persianScriptRepresentation': None,
        'persianScriptSource': 'generated', 'titlePersianSource': 'generated',
        'attributionStatus': None,
    }


def publish(works, blocks, pages_by_book):
    """Add the accepted blocks to `works`; returns (added, skipped)."""
    catalogue = Catalogue(works)
    templates = source_templates(works)
    known = {w['id'] for w in works}
    added, skipped = [], []
    for block in blocks:
        if block.get('decision') != 'accept':
            continue
        pages = pages_by_book[block['book']]
        taken, why = take_block(pages, block)
        if taken is None:
            skipped.append((block, why))
            continue
        lines, first, last = taken
        if catalogue.duplicate(lines, block['authorId']):
            skipped.append((block, 'already published'))
            continue
        ref = f"docs/literature/pdfs/{block['book']}.pdf"
        record_id = stable_id(block['book'], block['pdfPage'], lines[0])
        if record_id in known:
            skipped.append((block, 'already published'))
            continue
        record = fill(blank_record(record_id, templates[ref]), {
            'authorId': block['authorId'],
            'title': first_line_title(lines[0]),
            'type': block.get('type'),
            'lines': lines,
            'pageStart': printed_page(pages[first], first),
            'pageEnd': printed_page(pages[last], last),
            'sourceReference': ref,
        })
        record['verification']['verifiedAt'] = TODAY
        record['editorialNotes'] += (
            f" Attribution from the lead-in, reviewed by hand {TODAY}: "
            f"{block['reason']}.")
        works.append(record)
        known.add(record_id)
        catalogue.add(lines, block['authorId'])
        added.append(record)
    return added, skipped


def main(review_path, pages_dir):
    with open(WORKS, encoding='utf-8') as f:
        works = json.load(f)
    with open(review_path, encoding='utf-8') as f:
        blocks = json.load(f)['blocks']
    books = {b['book'] for b in blocks if b.get('decision') == 'accept'}
    pages = {book: load_pages(pages_dir, book) for book in books}
    added, skipped = publish(works, blocks, pages)
    with open(WORKS, 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
        f.write('\n')
    for block, why in skipped:
        print(f"skipped {block['book']} p{block['page']} "
              f"«{block['opening']}»: {why}")
    print(f'published {len(added)}, skipped {len(skipped)}')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
