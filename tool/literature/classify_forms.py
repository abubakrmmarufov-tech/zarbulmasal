"""Classify published textbook poems by form: ghazal, rubai, masnavi, qit'a.

Usage:
    python3 tool/literature/classify_forms.py <pages_dir> [<report.json>]

A form is set only when two kinds of evidence agree:
  * the book names it: a printed genre heading (already the work's `type`),
    or the sentence introducing the verse ("дар ин ғазал", "рубоии зер",
    "дар маснавии …", "қитъаи зерин");
  * the rhyme fits it: ghazal and qasida are monorhymes (the second line of
    every bayt rhymes; a two-bayt excerpt may also show the aaba of an
    opening), a qit'a is a monorhyme without a rhyming opening, a rubai is
    a quatrain rhyming aaba or aaaa, a masnavi rhymes bayt by bayt (aa bb cc).
The one form the rhyme alone settles is the masnavi: three or more bayts in
rhyming couplets. A quatrain is not called a rubai on its rhyme alone (a
ghazal opens aaba too), nor a monorhyme a ghazal (it may be a qasida or a
qit'a). Everything else keeps its type ("poem").

`masnavi` is stored as the existing type `epic`, qit'a as `fragment`.
Prints a summary; the report lists each change with its evidence.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import load_pages, text_above  # noqa: E402
from textbook_verse import norm  # noqa: E402

WORKS = 'assets/data/literature/works.json'
KEEP = ('ghazal', 'rubai', 'qasida', 'fragment', 'epic', 'folk', 'anthem')
# The form named as a noun ("дар ин ғазал", "рубоии зер"), not a writer
# of it ("қасидасаро", "ғазалсаро", "достонсаро").
_NOT_WRITER = r'(?!\w*сар[оо])'
HINTS = (
    ('ghazal', re.compile(r'\bғазал' + _NOT_WRITER)),
    ('rubai', re.compile(r'\b(?:рубо[ӣи]|дубайт)' + _NOT_WRITER)),
    ('fragment', re.compile(r'\bқитъа' + _NOT_WRITER)),
    ('epic', re.compile(r'\b(?:маснав|достон)' + _NOT_WRITER)),
    ('qasida', re.compile(r'\bқасида' + _NOT_WRITER)),
)
FITS = {
    'ghazal': ('monorhyme', 'quatrain'),
    'qasida': ('monorhyme', 'quatrain'),
    'fragment': ('monorhyme',),
    'rubai': ('quatrain',),
    'epic': ('couplets',),
}
MIN_MASNAVI_BAYTS = 3


def _words(line):
    return re.findall(r'[^\W\d_]+(?:-[^\W\d_]+)*', norm(line))


def _common_suffix(words):
    suffix = ''
    for chars in zip(*(w[::-1] for w in words)):
        if len(set(chars)) != 1:
            break
        suffix += chars[0]
    return suffix


def rhymes(lines):
    """True when the lines end in one rhyme: a shared radif (whole words)
    after a rhyme of at least one letter, or two letters without radif."""
    tails = [_words(line) for line in lines]
    if len(tails) < 2 or any(not t for t in tails):
        return False
    radif = 0
    while all(len(t) > radif + 1 for t in tails) and \
            len({t[-1 - radif] for t in tails}) == 1:
        radif += 1
    last = [t[-1 - radif] for t in tails]
    if len(set(last)) == 1:
        return True                     # the same word: a rhyme too
    return len(_common_suffix(last)) >= (1 if radif else 2)


def rhyme_scheme(lines):
    """'quatrain' (aaba, aaaa), 'monorhyme' (xa xa …), 'couplets'
    (aa bb …), or None."""
    verse = [line for line in lines if line.strip()]
    if len(verse) < 4 or len(verse) % 2:
        return None
    bayts = [verse[i:i + 2] for i in range(0, len(verse), 2)]
    if len(verse) == 4 and rhymes([verse[0], verse[1], verse[3]]):
        return 'quatrain'
    if rhymes([b[1] for b in bayts]):
        return 'monorhyme'
    if all(rhymes(b) for b in bayts):
        return 'couplets'
    return None


def last_sentence(text):
    text = ' '.join(text.split())
    text = re.sub(r'(\s\d{1,3})+$', '', text)
    return re.split(r'(?<=[.!?])»?\s', text)[-1]


def form_hint(lead):
    """The one form the sentence introducing the verse names, if any."""
    sentence = last_sentence(lead).lower()
    named = {form for form, pattern in HINTS if pattern.search(sentence)}
    return named.pop() if len(named) == 1 else None


def classify(lines, current, lead):
    """(type, evidence): evidence is 'lead-in', 'rhyme' or None."""
    if current in KEEP:
        return current, None            # a printed genre heading
    scheme = rhyme_scheme(lines)
    hint = form_hint(lead)
    if hint and scheme in FITS[hint]:
        return hint, 'lead-in'
    verse = [line for line in lines if line.strip()]
    if hint is None and scheme == 'couplets' and \
            len(verse) // 2 >= MIN_MASNAVI_BAYTS:
        return 'epic', 'rhyme'
    return current, None


def main(pages_dir, report_path=None):
    with open(WORKS, encoding='utf-8') as f:
        works = json.load(f)
    from audit_textbook_poems import printed_index
    books, indexes, changes = {}, {}, []
    for work in works:
        if work['verification'].get('verificationMethod') != \
                'textbookPdfTextExtraction':
            continue
        source = work['primarySource']
        book = os.path.basename(source['sourceReference'])[:-4]
        if book not in books:
            books[book] = load_pages(pages_dir, book)
            indexes[book] = printed_index(books[book])
        pages = books[book]
        lines = [l for l in work['textTajik'].split('\n') if l.strip()]
        index = indexes[book].get(source['pageStart'], source['pageStart'])
        lead = text_above(pages, index, lines)
        form, evidence = classify(lines, work.get('type'), lead)
        if form != work.get('type'):
            changes.append({'id': work['id'], 'title': work['title'],
                            'from': work.get('type'), 'to': form,
                            'evidence': evidence,
                            'leadIn': last_sentence(lead)[-160:]})
            work['type'] = form
    with open(WORKS, 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
        f.write('\n')
    if report_path:
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(changes, f, ensure_ascii=False, indent=1)
            f.write('\n')
    by = {}
    for change in changes:
        key = (change['to'], change['evidence'])
        by[key] = by.get(key, 0) + 1
    for (form, evidence), n in sorted(by.items()):
        print(f'{form} ({evidence}): {n}')
    print(f'{len(changes)} forms set')


if __name__ == '__main__':
    main(*sys.argv[1:3])
