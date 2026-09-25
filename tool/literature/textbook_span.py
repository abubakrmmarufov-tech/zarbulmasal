"""Verse the automatic extractor cannot delimit, taken between two lines a
reviewer names; and Latin look-alike letters set inside Cyrillic words.

`take_span` copies the printed lines from `opening` to `closing` inclusive,
across page breaks, with the same cleaning as textbook_verse.extract_poem
(legacy-font map already applied by load_pages, layout whitespace trimmed,
footnote markers removed). It exists for verse the indent rules miss:
  * verse set flush left, where the text layer gives it no indent;
  * a poem whose facing pages have different margins.
A «***» between stanzas is kept as a stanza break (an empty line), as a
blank line is; footnotes at the foot of a page («166 Шоҳҷон – …») are
skipped and the span goes on overleaf. It refuses a span that takes in anything but verse: a heading, a glossary
entry, a question, a footnote, a line too long for verse, a hyphenated
prose line, or a page's glossary label. Nothing is ever added or reworded.

`fix_lookalikes` maps Latin letters that look like Cyrillic ones (A, C, E,
H, K, M, O, P, T, X, a, c, e, o, p, u, x, y, B, k) to those Cyrillic letters in
a word that is Cyrillic: one with a Cyrillic letter in it, or a word of two
or more letters made only of look-alikes in a line that is otherwise
Cyrillic («cap» for «сар»). A lone letter («X» for a century, «A)» for an
exam option) is left alone, and so is a Roman numeral («ХIV»). The
page shows the Cyrillic letters; only the text layer is wrong. Every change
is returned so it can be logged.
"""
import re

from textbook_verse import (
    CYR, MAX_VERSE_CHARS, _date_line, _footnote_line, _gloss, _glossary,
    _label, _page_number, _question, _SECTION_LABELS, clean_line, is_heading,
    norm,
)

MAX_PAGES = 4       # a span never runs over more pages than this
_STARS = ('***', '* * *', '*')

_LOOKALIKE = str.maketrans({
    'A': 'А', 'B': 'В', 'C': 'С', 'E': 'Е', 'H': 'Н', 'K': 'К', 'M': 'М',
    'O': 'О', 'P': 'Р', 'T': 'Т', 'X': 'Х', 'a': 'а', 'c': 'с', 'e': 'е',
    'k': 'к', 'o': 'о', 'p': 'р', 'u': 'и', 'x': 'х', 'y': 'у',
})
_LATIN_LOOKALIKES = set('ABCEHKMOPTXacekopuxy')
_WORD = re.compile(r'[A-Za-z' + CYR + r']+')
_CYRILLIC = re.compile(f'[{CYR}]')
_LATIN = re.compile(r'[A-Za-z]')


def _fix_word(word, cyrillic_line):
    if not _LATIN.search(word):
        return word
    if _CYRILLIC.search(word) or (cyrillic_line and len(word) > 1 and
                                  set(word) <= _LATIN_LOOKALIKES):
        fixed = word.translate(_LOOKALIKE)
        # A Latin letter with no Cyrillic twin («I» in «ХIV»): leave it.
        return fixed if not _LATIN.search(fixed) else word
    return word


def fix_lookalikes(text):
    """(fixed text, [(before, after)]) for every word changed."""
    changes = []
    out_lines = []
    for line in text.split('\n'):
        letters = re.sub(r'[^A-Za-z' + CYR + ']', '', line)
        cyrillic = len(_CYRILLIC.findall(letters))
        cyrillic_line = cyrillic > 0 and cyrillic >= 0.8 * len(letters)

        def repl(match):
            word = match.group(0)
            fixed = _fix_word(word, cyrillic_line)
            if fixed != word:
                changes.append((word, fixed))
            return fixed
        out_lines.append(_WORD.sub(repl, line))
    return '\n'.join(out_lines), changes


def _not_verse(line, verse_indent=0):
    """Why `line` cannot be part of a poem, or None. A line with a dash
    («Додарам – қуввати рӯҳ…») reads as a glossary entry, and one ending in
    a hyphen («…дар бари худ-») as hyphenated prose, only when it is set
    left of indented verse, or the verse is flush left."""
    stripped = line.strip()
    indent = len(line) - len(line.lstrip(' '))
    glossary_like = verse_indent < 2 or indent < verse_indent - 1
    if stripped.lower().strip(' .:') in _SECTION_LABELS:
        return 'a glossary or exercise label'
    if is_heading(line):
        return 'a heading'
    if glossary_like and (_glossary.match(stripped) or _gloss.match(stripped)):
        return 'a glossary entry'
    if _question.match(stripped):
        return 'a numbered question'
    if _date_line.match(stripped) or _label.match(stripped):
        return 'a date or a label'
    if len(stripped) > MAX_VERSE_CHARS:
        return 'a line too long for verse'
    if stripped.endswith('-') and glossary_like:
        return 'a hyphenated prose line'
    return None


def _matches(line, wanted):
    key = norm(wanted).rstrip('.… ')
    return bool(key) and norm(clean_line(line)).startswith(key)


def take_span(pages, index, opening, closing):
    """((lines, first page, last page), None) or (None, reason)."""
    if len(norm(opening)) < 10 or len(norm(closing)) < 10:
        return None, 'opening and closing must quote a whole line'
    lines = pages[index].split('\n')
    start = next((i for i, line in enumerate(lines) if _matches(line, opening)),
                 None)
    if start is None:
        return None, 'the opening line is not on the page'
    block, blank = [], False
    page, row = index, start
    verse_indent = len(lines[start]) - len(lines[start].lstrip(' '))
    while page < len(pages) and page < index + MAX_PAGES:
        rows = pages[page].split('\n')
        if page != index:
            verse_indent = None     # facing pages have their own margins
        for line in rows[row:]:
            if block and _footnote_line.match(line.strip()):
                break                   # the page's footnotes: go on overleaf
            if not line.strip():
                blank = bool(block)
                continue
            if _page_number.match(line):
                blank = False           # a page break is not a stanza break
                continue
            if line.strip() in _STARS:
                blank = bool(block)     # «***» between stanzas: a stanza break
                continue
            if verse_indent is None:
                verse_indent = len(line) - len(line.lstrip(' '))
            why = _not_verse(line, verse_indent)
            if why:
                return None, f'the span takes in {why}: «{line.strip()}»'
            if blank:
                block.append('')
                blank = False
            block.append(clean_line(line))
            if _matches(line, closing):
                return (block, index, page), None
        page, row, blank = page + 1, 0, False
    return None, 'the closing line was not found after the opening'
