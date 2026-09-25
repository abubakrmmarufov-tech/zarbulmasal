"""Collect glossary entries ("Луғат" lists and footnote glosses) from the
textbook PDFs into the Lexicon.

Usage:
    python3 tool/vocabulary/extract_glossary.py <pages_dir> [--write]

<pages_dir>/<book>/<n>.txt holds `pdftotext -layout` output for
docs/literature/pdfs/<book>.pdf.

An entry is a line of the form

    Сафеҳ – нодон, нолоиқ, камақл.
    1 Мунъим – дӯст.

(a footnote number may lead). The term is one to four words starting with
a capital letter; the meaning starts in lower case, runs on to following
lower-case lines, and is taken as printed. A meaning longer than eight
words is kept only as a numbered footnote or inside a «Луғат» list: in
running prose a dash more often starts an explanation than a gloss. Lines holding two entries
(columns merged by the text layer), names with dates, and terms already
in the Lexicon are skipped. With --write, new entries are appended to
assets/data/vocabulary/words.json with their book and PDF page.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'literature'))
from textbook_verse import decode_legacy  # noqa: E402

WORDS = 'assets/data/vocabulary/words.json'
POETS = 'assets/data/literature/poets.json'
UPPER = 'А-ЯЁӢӮҲҶҚҒ'
LOWER = 'а-яёӣӯҳҷқғ'
ENTRY = re.compile(
    rf'^(?:\d{{1,3}}\s+)?([{UPPER}][{LOWER}{UPPER}\-()]*(?:\s[{LOWER}{UPPER}\-()]+){{0,3}})'
    rf'\s+[–—-]\s+((?:\d\.\s*)?[{LOWER}(«].+)$'
)
MAX_TERM = 40
GLOSSARY_LABEL = re.compile(r'^(?:луғат|луғатҳо|луғот|шарҳи луғатҳо|луғатнома)\b', re.IGNORECASE)
MAX_DEFINITION = 200


def norm(text):
    return re.sub(r'[^\w]+', '', text.lower())


def term_case(term):
    """All-capital glossary heads ("АРҶМАНД") in sentence case."""
    if term.upper() == term and len(term) > 1:
        return term[0] + term[1:].lower()
    return term


def entries_on_page(text):
    lines = [l.strip() for l in text.split('\n')]
    found = []
    in_glossary = False
    i = 0
    while i < len(lines):
        line = lines[i]
        if GLOSSARY_LABEL.match(line):
            in_glossary = True
        match = ENTRY.match(line)
        i += 1
        if not match:
            continue
        footnote = re.match(r'^\d{1,3}\s', line) is not None
        term, meaning = match.group(1).strip(), match.group(2).strip()
        if len(re.findall(r'\s[–—-]\s', meaning)) > 0:
            continue                    # two entries merged on one line
        while not re.search(r'[.!?]$', meaning) and i < len(lines) and \
                re.match(rf'^[{LOWER}(«]', lines[i]) and not ENTRY.match(lines[i]):
            meaning += ' ' + lines[i]
            i += 1
        meaning = re.sub(r'(\w)[-\xad]\s+(\w)', r'\1\2', meaning)
        if len(term) > MAX_TERM or len(meaning) > MAX_DEFINITION or \
                re.search(r'\d{3,4}', term + meaning):
            continue
        words = meaning.split()
        if meaning.endswith(',') or not (meaning.endswith('.') or len(words) <= 4):
            continue                    # a verse line with a dash, not a gloss
        if len(words) > 8 and not (footnote or in_glossary):
            continue                    # a prose sentence with a dash
        found.append((term_case(term), meaning))
    return found


def main(pages_dir, write):
    words = json.load(open(WORDS, encoding='utf-8'))
    known = {norm(w['term']) for w in words}
    poets = json.load(open(POETS, encoding='utf-8'))
    names = {norm(n) for p in poets
             for n in [p.get('canonicalName', '')] + list(p.get('aliases') or [])}
    added = []
    for book in sorted(os.listdir(pages_dir)):
        folder = os.path.join(pages_dir, book)
        if not os.path.isdir(folder):
            continue
        count = len([f for f in os.listdir(folder) if f.endswith('.txt')])
        for page in range(1, count + 1):
            text = decode_legacy(open(os.path.join(folder, f'{page}.txt'),
                                      encoding='utf-8').read())
            for term, meaning in entries_on_page(text):
                key = norm(term)
                if key in known or key in names:
                    continue
                known.add(key)
                added.append({'term': term, 'definition': meaning,
                              'sourceBook': f'{book}.pdf', 'pdfPage': page})
    print(f'new entries: {len(added)}')
    if write and added:
        with open(WORDS, 'w', encoding='utf-8') as f:
            json.dump(words + added, f, ensure_ascii=False, indent=2)
            f.write('\n')
    return added


if __name__ == '__main__':
    main(sys.argv[1], '--write' in sys.argv)
