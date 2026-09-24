"""Verse-block extraction from the official literature textbooks.

The textbook PDFs (docs/literature/pdfs/*.pdf, from maorif.tj) use a legacy
Tajik font encoding: њ ќ љ ѓ ў ї stand for ҳ қ ҷ ғ ӯ ӣ. `decode_legacy`
maps them back one-to-one.

`extract_poem` takes page texts (pdftotext -layout) and the opening words of
a poem and returns the verse lines exactly as printed. The only changes are
the encoding map, trimming of layout whitespace, and removal of footnote
reference digits glued to a word ("Лайло1." -> "Лайло."), which are
superscript markers in print, not part of the verse.

Prose, headings, glossaries, question lists and page numbers end a block;
a block that does not read as verse is rejected.
"""
import re

LEGACY = str.maketrans({
    'њ': 'ҳ', 'Њ': 'Ҳ', 'ќ': 'қ', 'Ќ': 'Қ', 'љ': 'ҷ', 'Љ': 'Ҷ',
    'ѓ': 'ғ', 'Ѓ': 'Ғ', 'ў': 'ӯ', 'Ў': 'Ӯ', 'ї': 'ӣ', 'Ї': 'Ӣ',
})

CYR = 'А-Яа-яЁёӢӣӮӯҲҳҶҷҚқҒғ'
UPPER = 'А-ЯЁӢӮҲҶҚҒ'
MAX_VERSE_CHARS = 58     # longer printed lines are prose
MIN_INDENT = 2           # verse is set indented in these books
MIN_LINES = 4            # at least two bayts: a poem, not a quoted bayt

# The text layer sometimes doubles a marker ("кафал158158.").
_footnote = re.compile(rf'(?<=[{CYR}»"])(\d{{1,3}})\1?(?=[\s,.;:!?…»"]|$)')
_footnote_after_punct = re.compile(r'(?<=[.,;:!?»"])\d{1,3}$')
# A footnote gloss: one to three words, a dash, the meaning ("Лайло – Лайлӣ.").
_gloss = re.compile(rf'^[{CYR}\-()]+(?:\s[{CYR}\-()]+){{0,2}} – ')
_heading = re.compile(rf'^[{UPPER}A-Z«»"\-–—\s,.:!?()0-9]+$')
_glossary = re.compile(rf'^[{CYR}][{CYR},\-\s]{{0,40}} – [а-яӣӯҳҷқғё]')
_question = re.compile(r'^\d{1,2}\.\s')
_page_number = re.compile(r'^\s*\d{1,3}\s*$')
_footnote_line = re.compile(r'^\d{1,3}\s')      # "1 Ҳошим Шоиқ – ..."
_dates = re.compile(r'\(\s*\d{3,4}\s*[–-]')
# The date printed under a poem ("Соли 1938."), or a part label
# ("(фасли нахуст)"): not verse.
_date_line = re.compile(r'^(?:Соли\s+)?\d{4}(?:\s*с\.)?\.?$')
_label = re.compile(r'^\([^()]{2,30}\)$')
_ends_verse = re.compile(r'[,.!?;:…»"\-–—)]$')
_column_gap = re.compile(r'\S\s{3,}\S')
_latin = re.compile(r'[A-Za-z]')


def decode_legacy(text):
    return text.translate(LEGACY)


def norm(text):
    return re.sub(r'\s+', ' ', text).strip().lower()


def clean_line(line):
    return _footnote_after_punct.sub('', _footnote.sub('', line.strip()))


def _indent(line):
    return len(line) - len(line.lstrip(' '))


_GENRE_WORDS = {
    'байт', 'рубоӣ', 'ғазал', 'қитъа', 'маснавӣ', 'қасида', 'фард',
    'дубайтӣ', 'рубоиёт', 'ғазалҳо', 'ҳикоят', 'тамсил', 'ҳикмат',
}


def is_heading(line):
    stripped = line.strip()
    letters = re.sub(rf'[^{CYR}]', '', stripped)
    if len(letters) >= 3 and _heading.match(stripped) is not None:
        return True
    # A genre label in mixed case: "Байт (Рубоӣ)", "Ғазал".
    words = [w for w in re.split(r'[\s()«».:,]+', stripped.lower()) if w]
    return bool(words) and all(w in _GENRE_WORDS for w in words)


# Labels that open a glossary or exercises under a poem.
_SECTION_LABELS = {
    'луғат', 'луғатҳо', 'луғот', 'шарҳи луғатҳо', 'луғатнома',
    'савол ва супориш', 'саволҳо', 'супориш', 'саволу супориш',
}


def _stops(line):
    stripped = line.strip()
    return (
        stripped.lower().strip(' .:') in _SECTION_LABELS
        or _page_number.match(line) is not None
        or is_heading(line)
        or _glossary.match(stripped) is not None
        or _question.match(stripped) is not None
        or _dates.search(stripped) is not None
        or _date_line.match(stripped) is not None
        or _label.match(stripped) is not None
        or _indent(line) < MIN_INDENT
        or len(stripped) > MAX_VERSE_CHARS
        or stripped.endswith('-')
        or _column_gap.search(stripped) is not None
    )


def _next_text_line(lines, i):
    for line in lines[i + 1:]:
        if line.strip():
            return line
    return None


def _starts_paragraph(lines, i):
    """An indented line whose next text line is flush left: a prose
    paragraph opening, not verse."""
    nxt = _next_text_line(lines, i)
    return nxt is not None and _indent(nxt) < MIN_INDENT and \
        _page_number.match(nxt) is None and \
        _footnote_line.match(nxt) is None


def _collect(lines):
    """Verse lines from the top of `lines`; returns (block, reached_end)."""
    block = []
    blank_run = 0
    for i, line in enumerate(lines):
        if not line.strip():
            blank_run += 1
            if blank_run > 1 and block:
                return block, False
            continue
        if _stops(line) or _starts_paragraph(lines, i):
            return block, _page_number.match(line) is not None
        if blank_run == 1 and block and _gloss.match(line.strip()):
            return block, False          # the footnote glossary under a poem
        if blank_run == 1 and block:
            block.append('')
        blank_run = 0
        block.append(clean_line(line))
    return block, True


def _rewind(lines, start):
    """Move `start` up to the first line of the verse run it belongs to."""
    i = start
    while i > 0:
        prev = lines[i - 1]
        if not prev.strip() or _stops(prev) or _starts_paragraph(lines, i - 1):
            break
        # A one- or two-word prose lead-in ("Чунончи:", "Масалан:"); longer
        # lines ending in ':' are verse introducing speech.
        if prev.strip().endswith(':') and len(prev.split()) <= 2:
            break
        i -= 1
    return i


def trim_prose_tail(block):
    """Drop trailing lines without verse-final punctuation when the rest of
    the block is punctuated (a prose sentence caught after the poem)."""
    block = list(block)
    while block:
        verse = [l for l in block if l]
        punctuated = sum(1 for l in verse if _ends_verse.search(l))
        prose_lead_in = block[-1].endswith(':') and len(block) > 1 and \
            block[-2] == ''
        if prose_lead_in or (block[-1] and not _ends_verse.search(block[-1])
                             and punctuated >= 0.8 * len(verse)):
            block.pop()
            while block and block[-1] == '':
                block.pop()
            continue
        break
    return block


def reads_as_verse(block):
    verse = [l for l in block if l]
    if len(verse) < MIN_LINES:
        return False
    if any(_latin.search(l) for l in verse):
        return False                    # mixed-encoding text: not reliable
    if verse[0][:1].islower():
        return False                    # starts mid-sentence: prose
    if _gloss.match(verse[0]) and verse[0].endswith('.'):
        return False                    # starts with a footnote gloss
    if any(re.match(rf'^[{CYR}0-9]\)\s', l) or ' – (' in l for l in verse):
        return False                    # a list item or a glossary entry
    good = 0
    for i, line in enumerate(verse):
        nxt = verse[i + 1] if i + 1 < len(verse) else None
        if _ends_verse.search(line) or nxt is None or re.match(rf'[{UPPER}«"]', nxt):
            good += 1
    return good / len(verse) >= 0.85


def extract_poem(pages, index, opening):
    """Find `opening` on pages[index] and return (title, lines) or None.

    `pages` is a list of page texts (decoded); the poem may continue onto
    the following pages. `title` is the printed heading directly above the
    poem when there is one, else None.
    """
    lines = pages[index].split('\n')
    key = norm(opening).rstrip('.… ')[:24]
    if len(key) < 10:
        return None
    start = None
    for i, line in enumerate(lines):
        if norm(clean_line(line))[:len(key)] == key:
            start = i
            break
    if start is None:
        return None
    if _stops(lines[start]):
        return None
    start = _rewind(lines, start)
    first_page = index
    carried = []
    if not any(l.strip() for l in lines[:start]) and index > 1:
        # The poem may begin on the previous page: take the verse run that
        # ends that page (above its page number and footnote glossary).
        prev = pages[index - 1].split('\n')
        end = len(prev)
        while end > 0 and (not prev[end - 1].strip()
                           or _page_number.match(prev[end - 1])
                           or _glossary.match(prev[end - 1].strip())
                           or _gloss.match(prev[end - 1].strip())
                           or _indent(prev[end - 1]) < MIN_INDENT):
            end -= 1
        # Only verse carries over: an indented line followed by flush-left
        # text opens a prose paragraph.
        if end > 0 and not _stops(prev[end - 1]) and \
                not _starts_paragraph(prev, end - 1):
            begin = _rewind(prev, end - 1)
            run, _ = _collect(prev[begin:end])
            if run:
                carried = run
                first_page = index - 1
                lines_above = prev[:begin]
            else:
                lines_above = lines[:start]
        else:
            lines_above = lines[:start]
    else:
        lines_above = lines[:start]
    heading_lines = []
    for above in reversed(lines_above):
        if not above.strip():
            if heading_lines:
                break
            continue
        if _label.match(above.strip()):
            continue                    # "(фасли нахуст)" under the title
        if is_heading(above) and not _dates.search(above):
            heading_lines.insert(0, clean_line(above))
            continue
        break
    title = ' '.join(heading_lines) if heading_lines else None
    block, reached_end = _collect(lines[start:])
    block = carried + block
    page = index
    while reached_end and page + 1 < len(pages):
        page += 1
        more, reached_end = _collect(pages[page].split('\n'))
        if not more:
            break
        block.extend(more)
    while block and block[-1] == '':
        block.pop()
    return title, block, page, first_page


def split_series(block):
    """A series of short poems (rubais, qit'as) set apart by '***' becomes
    separate poems; each part must still read as verse."""
    parts, current = [], []
    for line in block:
        if line.strip() in ('***', '* * *', '*'):
            parts.append(current)
            current = []
        else:
            current.append(line)
    parts.append(current)
    poems = []
    for part in parts:
        while part and part[0] == '':
            part = part[1:]
        while part and part[-1] == '':
            part = part[:-1]
        part = trim_prose_tail(part)
        if reads_as_verse(part):
            poems.append(part)
    return poems


GENRE_HEADINGS = {
    'ғазал': 'ghazal', 'ғазалҳо': 'ghazal', 'рубоӣ': 'rubai',
    'рубоиёт': 'rubai', 'рубоиҳо': 'rubai', 'қитъа': 'fragment',
    'қасида': 'qasida', 'маснавӣ': 'epic', 'байт': 'fragment',
    'фард': 'fragment', 'ҳикоят': 'poem', 'ҳикмат': 'poem',
    'тамсил': 'poem', 'дубайтӣ': 'rubai', 'дубайтиҳо': 'rubai',
    'қасидаҳо': 'qasida', 'қитъаҳо': 'fragment', 'маснавиҳо': 'epic',
    'ҳикоятҳо': 'poem', 'байтҳо': 'fragment',
}

_SMALL = {'ва', 'аз', 'ба', 'дар', 'бо', 'то', 'и', 'ки', 'бар', 'зи'}


def _genre_key(text):
    key = norm(text).strip(' .:()«»')
    return key[3:] if key.startswith('аз ') else key


def heading_genre(heading):
    """The genre a heading names when it is only a genre label
    ("ҚИТЪА", "АЗ ҚАСИДАҲО")."""
    return GENRE_HEADINGS.get(_genre_key(heading))


def split_heading(heading):
    """(genre, title): a leading genre-group label ("АЗ ҚАСИДАҲО") is
    taken off a multi-part heading and returned as the genre."""
    words = heading.split()
    for cut in range(len(words) - 1, 0, -1):
        genre = heading_genre(' '.join(words[:cut]))
        if genre:
            return genre, ' '.join(words[cut:])
    return heading_genre(heading), (None if heading_genre(heading) else heading)


_WORD = re.compile(rf'[{CYR}]+(?:-[{CYR}]+)*')


def proper_nouns(page_texts):
    """Words the books print capitalised in mid-sentence and never in
    lower case: names of people, places and works («Сомонӣ», «Бухоро»)."""
    page_texts_cache = list(page_texts)
    capital_mid, lower = {}, set()
    for text in page_texts_cache:
        for line in text.split('\n'):
            words = _WORD.findall(line)
            for i, word in enumerate(words):
                key = word.lower()
                if word[0].islower():
                    lower.add(key)
                elif i > 0 and words[i - 1][0].islower() and \
                        not word.isupper():
                    capital_mid[key] = capital_mid.get(key, 0) + 1
    singles = {w for w, n in capital_mid.items() if n >= 2 and w not in lower}
    # Two-word names printed with both capitals ("Исмоили Сомонӣ").
    pairs = {}
    for text in page_texts_cache:
        for line in text.split('\n'):
            words = _WORD.findall(line)
            for i in range(1, len(words) - 1):
                a, b = words[i], words[i + 1]
                if words[i - 1][0].islower() and a[0].isupper() and \
                        b[0].isupper() and not a.isupper():
                    key = f'{a.lower()} {b.lower()}'
                    pairs[key] = pairs.get(key, 0) + 1
    return singles | {p for p, n in pairs.items() if n >= 2}


def sentence_case(heading, names=frozenset()):
    """A heading printed in capitals, set with only its first letter
    capital. Proper nouns (`names`, lower-case forms) keep their capital, as
    do significant words inside «…»."""
    text = heading.strip()
    if text.upper() != text:
        return text                     # already mixed case: as printed
    out = []
    in_quote = False
    for token in re.split(r'(\s+|«|»)', text.lower()):
        if token == '«':
            in_quote = True
        elif token == '»':
            in_quote = False
        elif (in_quote and token.strip() and token not in _SMALL) or \
                re.sub(r'[^\w-]', '', token) in names:
            token = _capitalize(token)
        out.append(token)
    result = _capitalize(''.join(out))
    for name in names:
        if ' ' in name and name in result.lower():
            start = result.lower().index(name)
            fixed = ' '.join(_capitalize(w) for w in name.split(' '))
            result = result[:start] + fixed + result[start + len(name):]
    return result


def _capitalize(text):
    """Upper-case the first Cyrillic letter of `text`."""
    match = re.search(rf'[{CYR}]', text)
    if not match:
        return text
    i = match.start()
    return text[:i] + text[i].upper() + text[i + 1:]
