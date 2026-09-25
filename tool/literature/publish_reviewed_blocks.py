"""Publish the verse blocks a person accepted in a hand review.

Usage:
    python3 tool/literature/publish_reviewed_blocks.py <review.json> <pages_dir>
    dart run tool/build_runtime_literature.dart

<review.json> (e.g. docs/literature/EXTRACTION_REVIEW_2026-09-25.json) lists
each block by book, PDF page and opening line, with the reviewer's decision
and the poet the lead-in names. Only `accept` blocks are used. Each is taken
again from the page, so the published text is the printed text, not a copy
kept in the review file:
  * by default with textbook_verse.extract_poem;
  * with textbook_span.take_span when the block names its `closing` line
    (verse set flush left, or across pages with different margins).

Optional fields of an accepted block:
  * split: "quatrains" -- a run of rubais or dubaitis printed without
    separators; each four lines become a poem;
  * heading: true -- the poem is known by the printed title above it
    (sentence case), not by its first line;
  * type -- the form the book names (ghazal, rubai, qasida, fragment, epic);
  * replaces -- the id of a published record this block repairs (the record
    held part of the poem); the record keeps its id and gets the full text;
  * merges -- ids of published records that print a shorter excerpt of the
    same poem (another book reprints its opening); they are merged into
    this record (rejected as `duplicate_of:<id>`, their page named in its
    note).

A needsReview record of the same poem -- a citation that fits the block
(`_near`) and a title that opens one of its lines -- is promoted (it keeps its id and gets the text) rather than a new record
created; further such records are merged into it (rejected as
`duplicate_of:<id>`).

A block is skipped, and reported, when
  * it is no longer found on the page, or does not read as verse;
  * it is already published: contained in a published text, sharing half
    its lines with one (the books reprint passages), or with the same poet,
    title and first line as a record kept in the catalogue. Punctuation is
    ignored, since reprints differ in it.
New records get a stable id from book, page and first line, and the same
provenance as publish_textbook_poems.py. The ids of the records each block
produced are written back to the review file as `recordIds`, for the audit.
"""
import json
import os
import re
import sys
import uuid

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import first_line_title, load_pages, printed_page  # noqa: E402
from publish_textbook_poems import fill  # noqa: E402
from textbook_span import take_span  # noqa: E402
from textbook_verse import (  # noqa: E402
    extract_poem, norm, proper_nouns, reads_as_verse, sentence_case,
    split_series,
)

WORKS = 'assets/data/literature/works.json'
NAMESPACE = uuid.UUID('6f0c6c1e-5b8e-4a55-9d0c-7a1d2f3b4c5d')
TODAY = '2026-09-25'
OVERLAP = 0.5
PAGE_SLACK = 2      # a candidate's own page may be this far from the verse
CHAPTER = 30        # a chapter's first page is at most this far before a poem
MIN_TITLE = 10      # letters a candidate title needs to identify a line


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
    """(lines, first page, last page) of `block`, or None with a reason."""
    if block.get('closing'):
        taken, why = take_span(pages, block['pdfPage'], block['opening'],
                               block['closing'])
        if taken is None:
            return None, why
        lines, first, last = taken
        return (lines, first, last), None
    result = extract_poem(pages, block['pdfPage'], block['opening'])
    if result is None:
        return None, 'not found on the page'
    _, lines, last, first = result
    if first != block['pdfPage']:
        return None, 'the block starts on another page'
    for part in split_series(lines):
        if norm(next(l for l in part if l)) == norm(block['opening']):
            return (part, first, last), None
    return None, 'the opening line starts no verse part'


def quatrains(lines):
    """Four-line poems from a run of quatrains; None if it is not one."""
    verse = [line for line in lines if line]
    if len(verse) < 8 or len(verse) % 4:
        return None
    return [verse[i:i + 4] for i in range(0, len(verse), 4)]


def printed_heading(pages, index, opening):
    """The heading printed directly above `opening` (sentence case), or
    None. Taken from extract_poem, which finds it for indented verse."""
    result = extract_poem(pages, index, opening)
    if result and result[0]:
        return result[0]
    lines = pages[index].split('\n')
    key = norm(opening)[:24]
    from textbook_verse import clean_line, is_heading
    for i, line in enumerate(lines):
        if norm(clean_line(line)).startswith(key):
            above = [l for l in lines[:i] if l.strip()]
            heading = []
            for raw in reversed(above):
                if not is_heading(raw):
                    break
                heading.insert(0, raw.strip())
            return ' '.join(heading) or None
    return None


class Catalogue:
    """Published texts, for the duplicate check."""

    def __init__(self, works):
        self.texts = {w['id']: verse_lines(w['textTajik']) for w in works
                      if w.get('textTajik') and
                      w['verification'].get('evidenceLevel') == 'primaryChecked'}
        self.keys = {work_key(w['authorId'], w.get('title'), w.get('incipit')): w['id']
                     for w in works
                     if w['verification'].get('evidenceLevel') != 'rejected'}

    def duplicate(self, lines, author=None, ignore=()):
        first = next(line for line in lines if line)
        owner = self.keys.get(work_key(author, first_line_title(first), first))
        if owner is not None and owner not in ignore:
            return True
        body = verse_lines('\n'.join(lines))
        joined = '\n'.join(body)
        wanted = set(body)
        for record_id, text in self.texts.items():
            if record_id in ignore:
                continue
            if joined in '\n'.join(text):
                return True
            if len(wanted & set(text)) >= OVERLAP * len(wanted):
                return True
        return False

    def add(self, record_id, lines, author=None):
        self.texts[record_id] = verse_lines('\n'.join(lines))
        first = next(line for line in lines if line)
        self.keys[work_key(author, first_line_title(first), first)] = record_id


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


def _near(work, ref, author, first_page, last_page):
    """Whether a needsReview record's citation fits a block on
    first_page..last_page: its own page within PAGE_SLACK; or, for the
    same poet, the chapter page it cites (dump candidates cite the page a
    chapter opens on, up to CHAPTER pages before the poem); or, for
    title-only records without a source, the page range they cite."""
    source = work.get('primarySource') or {}
    page = source.get('pageStart')
    if page is None:
        return False
    if source.get('sourceReference') == ref:
        if first_page - PAGE_SLACK <= page <= last_page + PAGE_SLACK:
            return True
        return work.get('authorId') == author and \
            first_page - CHAPTER <= page <= last_page
    if not source.get('sourceReference') and work.get('authorId') == author:
        end = source.get('pageEnd') or page
        return page - PAGE_SLACK <= first_page and last_page <= end + PAGE_SLACK
    return False


def candidates(works, ref, first_page, last_page, lines, author=None):
    """needsReview records of this poem: a citation that fits the block
    (`_near`) and a title that opens one of its lines."""
    wanted = [bare(line) for line in lines if line]
    found = []
    for work in works:
        if work['verification'].get('evidenceLevel') != 'needsReview' or \
                work.get('textTajik') or \
                not _near(work, ref, author, first_page, last_page):
            continue
        title = bare(work.get('title'))
        if len(title.replace(' ', '')) >= MIN_TITLE and \
                any(line.startswith(title) for line in wanted):
            found.append(work)
    return found


def merge_duplicate(record, into, note):
    record['verification'] = {
        'evidenceLevel': 'rejected',
        'rejectionReason': f"duplicate_of:{into['id']}",
        'verificationMethod': 'manualAttributionReview',
        'verifiedAt': TODAY,
    }
    record['editorialNotes'] = (
        f"Merged {TODAY} into {into['id']} («{into['title']}»), the "
        f"published text of the same poem: {note}.")


def pages_of(pages, first, last, lines):
    """(first, last) PDF pages on which `lines` are printed, searched
    within first..last: the page of the first line, and of the last line
    after it."""
    from textbook_verse import clean_line
    verse = [line for line in lines if line]

    def find(line, begin):
        for i in range(begin, last + 1):
            if any(norm(clean_line(raw)) == norm(line)
                   for raw in pages[i].split('\n')):
                return i
        return None
    start = find(verse[0], first)
    if start is None:
        return first, last
    end = find(verse[-1], start)
    return start, end if end is not None else last


def _poems(block, lines):
    if block.get('split') == 'quatrains':
        return quatrains(lines)
    return [lines]


def publish(works, blocks, pages_by_book, nouns=frozenset()):
    """Add the accepted blocks to `works`; returns (added, skipped). Each
    accepted block gets `recordIds`: the records it produced."""
    catalogue = Catalogue(works)
    templates = source_templates(works)
    by_id = {w['id']: w for w in works}
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
        poems = _poems(block, lines)
        if not poems or not all(reads_as_verse(p) for p in poems):
            skipped.append((block, 'does not read as verse'))
            continue
        ref = f"docs/literature/pdfs/{block['book']}.pdf"
        heading = printed_heading(pages, block['pdfPage'], block['opening']) \
            if block.get('heading') else None
        ids = []
        for poem in poems:
            record = _publish_poem(works, by_id, catalogue, templates, block,
                                   poem, pages, first, last, ref,
                                   sentence_case(heading, nouns) if heading
                                   and len(poems) == 1 else None)
            if isinstance(record, str):
                skipped.append((block, record))
                continue
            ids.append(record['id'])
            added.append(record)
        if ids:
            block['recordIds'] = ids
    return added, skipped


def _publish_poem(works, by_id, catalogue, templates, block, lines, pages,
                  first, last, ref, title):
    """The published record, or the reason it was skipped."""
    replaces = block.get('replaces')
    merges = block.get('merges') or []
    for known in [replaces] * bool(replaces) + merges:
        if known not in by_id:
            return f'unknown record {known}'
    ignore = tuple([replaces] * bool(replaces) + merges)
    if catalogue.duplicate(lines, block['authorId'], ignore):
        return 'already published'
    found = candidates(works, ref, printed_page(pages[first], first),
                       printed_page(pages[last], last), lines, block['authorId'])
    if replaces:
        record = by_id[replaces]
    elif found:
        record = found.pop(0)
        # Its citation is replaced by the PDF's: a title-only record may
        # cite another edition.
        record['primarySource'] = dict(templates[ref])
    else:
        record_id = stable_id(block['book'], block['pdfPage'], lines[0])
        if record_id in by_id:
            return 'already published'
        record = blank_record(record_id, templates[ref])
        works.append(record)
        by_id[record_id] = record
    was = record.get('title')
    start, end = pages_of(pages, first, last, lines)
    fill(record, {
        'authorId': block['authorId'],
        'title': title or first_line_title(lines[0]),
        'type': block.get('type'),
        'lines': lines,
        'pageStart': printed_page(pages[start], start),
        'pageEnd': printed_page(pages[end], end),
        'sourceReference': ref,
    })
    record['verification']['verifiedAt'] = TODAY
    record['editorialNotes'] += (
        f" Attribution from the lead-in, reviewed by hand {TODAY}: "
        f"{block['reason']}.")
    if replaces:
        record['editorialNotes'] += f' Text re-taken from the page {TODAY}: ' \
            'the record held only part of the poem.'
    elif record['id'] != stable_id(block['book'], block['pdfPage'], lines[0]):
        record['editorialNotes'] += (
            f' Promoted {TODAY} from the needsReview candidate «{was}», '
            'matched to its page.')
    for duplicate in found:
        merge_duplicate(duplicate, record, f"its title «{duplicate['title']}» "
                        'opens a line of that poem on the same page')
    for excerpt_id in merges:
        excerpt = by_id[excerpt_id]
        source = excerpt['primarySource']
        where = (f"{os.path.basename(source['sourceReference'])[:-4]}, "
                 f"p. {source['pageStart']}")
        merge_duplicate(excerpt, record, f'{where} prints the opening '
                        'of the same poem')
        catalogue.texts.pop(excerpt_id, None)
        record['editorialNotes'] += f' Its opening is also printed in {where}.'
    catalogue.add(record['id'], lines, block['authorId'])
    return record


def main(review_path, pages_dir):
    with open(WORKS, encoding='utf-8') as f:
        works = json.load(f)
    with open(review_path, encoding='utf-8') as f:
        review = json.load(f)
    global TODAY
    TODAY = review.get('reviewedAt', TODAY)
    blocks = review['blocks']
    books = {b['book'] for b in blocks if b.get('decision') == 'accept'}
    pages = {book: load_pages(pages_dir, book) for book in books}
    nouns = proper_nouns(t for book in pages.values() for t in book)
    added, skipped = publish(works, blocks, pages, nouns)
    with open(WORKS, 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
        f.write('\n')
    with open(review_path, 'w', encoding='utf-8') as f:
        json.dump(review, f, ensure_ascii=False, indent=1)
        f.write('\n')
    for block, why in skipped:
        print(f"skipped {block['book']} p{block['page']} "
              f"«{block['opening']}»: {why}")
    print(f'published {len(added)}, skipped {len(skipped)}')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
