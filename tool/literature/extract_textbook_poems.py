"""Fill in poem text for textbook candidates, from the textbook pages.

Usage:
    python3 tool/literature/extract_textbook_poems.py <pages_dir> <out.json>

<pages_dir>/<book>/<n>.txt must hold `pdftotext -layout -f n -l n` output
for docs/literature/pdfs/<book>.pdf.

For every `needsReview` work in assets/data/literature/works.json that cites
a textbook page, the candidate's opening words are looked for on that page
and the next few pages (the recorded page is approximate). When a verse
block starts there it is taken verbatim (see textbook_verse.py).

Attribution: the candidate's poet, unless the block ends with a line that is
only a poet's name (the book's own attribution of a quotation), in which
case that poet is used — or the poem is skipped if the name is unknown.

Output: one record per poem with the candidate id, poet, book, printed
page(s), title (the printed heading, if any) and lines. Poems already
published, duplicates and fragments contained in a longer extracted poem
are dropped.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from textbook_verse import (  # noqa: E402
    decode_legacy, extract_poem, norm, proper_nouns, sentence_case,
    split_heading, split_series,
)

PAGE_OFFSETS = (0, 1, 2, 3, -1, 4, 5, -2)

# Headings that name a section of the book, not the poem under them.
SECTION_HEADINGS = (
    'куллиёт', 'мероси адабӣ', 'мероси адабии', 'намунаҳо', 'девон',
    '(маснавӣ)', '(рубоӣ)', '(ғазал)', '(қитъа)', 'мундариҷа',
    'қасидаҳои', 'ғазалҳои', 'рубоиёти',
    # Literary-device lessons: the verse under them is an example, often
    # by another poet.
    'талмеҳ', 'ташбеҳ', 'истиора', 'тазод', 'муболиға', 'ташхис',
    'иғроқ', 'тарсеъ', 'таҷнис', 'саҷъ',
)


# Lead-ins that introduce verse the chapter's poet did not write: folk
# songs about him, elegies and chronograms by others, translations, and
# example lists in theory lessons.
_NOT_THE_POETS_OWN = re.compile(
    r'(халқ|мардум)\S*\b.{0,80}(суруд|таронаҳо|шеъру)\S*.{0,60}эҷод'
    r'|аз халқ:|марсия|қитъаи таърихӣ|дар борааш|дар бораи ӯ'
    r'|тарҷума:|мисолҳо:|мисол:|ҳаҷв карда буд|дар вафоти|дар ҳаққи',
    re.IGNORECASE,
)


def lead_in_disqualifies(lead):
    """True when the sentence right before a verse block says the verse is
    someone else's (folk, an elegy about the poet, a translation, an
    example list)."""
    lead = ' '.join(lead.split())
    lead = re.sub(r'(\s\d{1,3})+$', '', lead)
    if not lead.endswith(':'):
        return False
    tail = lead[-260:]
    return _NOT_THE_POETS_OWN.search(tail) is not None


def quoted_from_other_poet(lead, author, names):
    """True when the sentence introducing the verse ("... Рӯдакӣ:") names
    a known poet other than `author`: the book is quoting someone else."""
    lead = ' '.join(lead.split())
    lead = re.sub(r'(\s\d{1,3})+$', '', lead)
    if not lead.endswith(':'):
        return False
    sentence = re.split(r'[.!?»]\s', lead)[-1].lower()
    words = re.findall(r'\w+', sentence)
    spans = {' '.join(words[i:i + n]) for n in (1, 2, 3)
             for i in range(len(words) - n + 1)}
    named = {names[s] for s in spans if s in names}
    return bool(named) and author not in named


def load_pages(pages_dir, book):
    folder = os.path.join(pages_dir, book)
    count = len([f for f in os.listdir(folder) if f.endswith('.txt')])
    pages = [''] * (count + 1)          # 1-based
    for n in range(1, count + 1):
        with open(os.path.join(folder, f'{n}.txt'), encoding='utf-8') as f:
            pages[n] = decode_legacy(f.read())
    return pages


def printed_page(page_text, pdf_index):
    """The page number printed at the foot of the page (or the PDF index)."""
    for line in reversed(page_text.strip().split('\n')):
        if re.fullmatch(r'\s*\d{1,3}\s*', line):
            return int(line)
        if line.strip():
            break
    return pdf_index


def first_line_title(line):
    """A poem known by its first line: the line without closing
    punctuation and without an unmatched opening quote."""
    title = line.strip().rstrip(' ,.;:!?…-–—')
    if title.count('«') > title.count('»'):
        title = title.replace('«', '', 1)
    if title.count('»') > title.count('«'):
        title = title[::-1].replace('»', '', 1)[::-1]
    return title.strip()


def text_above(pages, index, lines, width=400):
    """The printed text just above the block's first line (running back
    onto the previous page when the block opens a page)."""
    first = next(line for line in lines if line)
    page = pages[index]
    for raw in page.split('\n'):
        if raw.strip().startswith(first[:12]):
            above = page[:page.index(raw)]
            if not above.strip() and index > 1:
                above = pages[index - 1]
            return above[-width:]
    return ''


def poet_names(poets):
    """{lower-case name: poet id} for recognising poets in lead-ins and
    signatures. Rejected records give no names. The last word of a name
    ("Ҳофиз", "Рӯдакӣ") counts only when no other poet's name contains it:
    a shared nisba ("Ҷомӣ", "Балхӣ") or a title ("Мирзо") names no one."""
    poets = [p for p in poets if p.get('recordStatus') != 'rejected']
    names = {}
    owners = {}
    for poet in poets:
        for name in [poet.get('canonicalName', '')] + list(poet.get('aliases') or []):
            key = norm(name)
            if key:
                names[key] = poet['id']
                for word in key.split(' '):
                    owners.setdefault(word, set()).add(poet['id'])
    for poet in poets:
        parts = norm(poet.get('canonicalName', '')).split(' ')
        last = parts[-1] if parts else ''
        if len(last) > 3 and owners.get(last) == {poet['id']}:
            names.setdefault(last, poet['id'])
    return names


def main(pages_dir, out_path):
    works = json.load(open('assets/data/literature/works.json', encoding='utf-8'))
    poets = json.load(open('assets/data/literature/poets.json', encoding='utf-8'))
    names = poet_names(poets)
    # Poets held for review (translations of foreign poets, unresolved
    # names) get no published works.
    review_poets = {p['id'] for p in poets if p.get('recordStatus') == 'review'}
    # (poet, title, first line) of every record already kept, so a poem that
    # is already catalogued is not published twice.
    def canonical(author, title, incipit):
        clean = lambda v: re.sub(r'[^\w]+', '', (v or '').lower())
        return (author, clean(title), clean(incipit))
    existing = {
        canonical(w['authorId'], w.get('title'), w.get('incipit'))
        for w in works
        if w.get('verification', {}).get('evidenceLevel') != 'rejected'
    }
    published = {
        norm((w.get('textTajik') or '').split('\n')[0])
        for w in works if w.get('textTajik')
    }
    books = {}
    for name in os.listdir(pages_dir):
        if os.path.isdir(os.path.join(pages_dir, name)):
            books[name] = load_pages(pages_dir, name)
    nouns = proper_nouns(text for pages in books.values() for text in pages)
    found = []
    for work in works:
        if work.get('verification', {}).get('evidenceLevel') != 'needsReview':
            continue
        if work.get('secondarySource') or work.get('textMatchResult'):
            continue        # a curated record with its own review decision
        source = work.get('primarySource') or {}
        ref = source.get('sourceReference') or ''
        if not ref.endswith('.pdf') or source.get('pageStart') is None:
            continue
        book = os.path.basename(ref)[:-4]
        if book not in books:
            books[book] = load_pages(pages_dir, book)
        pages = books[book]
        opening = work['title'].rstrip('.…').strip()
        for offset in PAGE_OFFSETS:
            index = source['pageStart'] + offset
            if not 1 <= index < len(pages):
                continue
            result = extract_poem(pages, index, opening)
            if result is None:
                continue
            title, lines, last_index, first_index = result
            if not [line for line in lines if line]:
                continue
            author = work['authorId']
            tail = norm(lines[-1]) if lines else ''
            if tail in names:
                author = names[tail]
                lines = lines[:-1]
                while lines and lines[-1] == '':
                    lines.pop()
            elif len(tail) <= 20 and len(tail.split(' ')) <= 2 and not re.search(r'[,.!?]$', lines[-1]):
                break                     # an unknown name line: skip
            if author in review_poets:
                break
            lead = text_above(pages, first_index, lines)
            if quoted_from_other_poet(lead, author, names) or \
                    lead_in_disqualifies(lead):
                break
            genre, title = split_heading(title) if title else (None, None)
            if title and (norm(title) in names
                          or norm(title).startswith(SECTION_HEADINGS)
                          or re.search(r'[A-Za-z]', title)):
                title = None      # a name, a section heading, or unreliable
            parts = split_series(lines)
            for n, part in enumerate(parts):
                first_line = next(l for l in part if l)
                printed_title = title if len(parts) == 1 else None
                found.append({
                    'candidateId': work['id'],
                    'candidateTitle': work.get('title'),
                    'authorId': author,
                    'type': genre or work.get('type'),
                    'book': book,
                    'sourceReference': ref,
                    'source': source,
                    'pdfPageStart': first_index,
                    'pdfPageEnd': last_index,
                    'pageStart': printed_page(pages[first_index], first_index),
                    'pageEnd': printed_page(pages[last_index], last_index),
                    # A heading names the whole series, not each part;
                    # otherwise the poem is known by its first line.
                    'heading': printed_title,
                    'title': sentence_case(printed_title, nouns)
                    if printed_title else first_line_title(first_line),
                    'lines': part,
                })
            break

    # Drop poems already published, then duplicates and contained fragments.
    kept = []
    for poem in sorted(found, key=lambda p: -len(p['lines'])):
        first = norm(next(l for l in poem['lines'] if l))
        if first in published:
            continue
        key = canonical(poem['authorId'], poem['title'], first)
        if key in existing and poem['title'] != poem.get('candidateTitle'):
            continue
        body = '\n'.join(norm(l) for l in poem['lines'] if l)
        if any(body in '\n'.join(norm(l) for l in k['lines'] if l) for k in kept):
            continue
        kept.append(poem)
    kept.sort(key=lambda p: (p['book'], p['pdfPageStart']))
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(kept, f, ensure_ascii=False, indent=1)
    print(f'candidates matched: {len(found)}; poems kept: {len(kept)}')


if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])
