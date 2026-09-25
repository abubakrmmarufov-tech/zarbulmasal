"""Per-poet coverage of the textbooks: what the chapters print, what is
published, and why the rest is not.

Usage:
    python3 tool/literature/poet_coverage.py <pages_dir> <out.md> [<out.json>] [<works.json>]

<works.json> defaults to the catalogue; pass an older copy to report on it.

<pages_dir> holds `pdftotext -layout` page dumps, as for
extract_textbook_poems.py. For every poet (rejected name records and
translated foreign poets held for review are listed apart) the report gives
  * chapter pages: the pages the biography cites, and the chapter the book
    heads with the poet's name and dates, up to the next such heading;
  * verse blocks on those pages (four or more lines that read as verse,
    indented or set flush left), and how many are published;
  * readable poems (primaryChecked with text);
  * needsReview records, grouped by why they are not readable
    (`review_reason`);
  * a verdict, from docs/literature/POET_COVERAGE_VERDICTS_2026-09-26.json
    when a person has decided one (with a note, and chapter pages that
    correct the biography's), else a suggestion marked «?»:
      a  verse exists and can be published;
      b  verse exists but is not the poet's (folk verse, other poets,
         translations, examples);
      c  the chapter prints no verse (a prose writer);
      d  no chapter in these books.
"""
import json
import os
import re
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import (  # noqa: E402
    PAGE_OFFSETS, lead_in_disqualifies, load_pages, poet_names,
    printed_page, quoted_from_other_poet, text_above,
)
from scan_textbook_chapters import verse_starts  # noqa: E402
from textbook_verse import (  # noqa: E402
    MAX_VERSE_CHARS, _ends_verse, _glossary, _indent, _page_number,
    _question, extract_poem, is_heading, norm, split_series,
)

WORKS = 'assets/data/literature/works.json'
POETS = 'assets/data/literature/poets.json'
VERDICTS = 'docs/literature/POET_COVERAGE_VERDICTS_2026-09-26.json'
MAX_CHAPTER = 40        # pages; a longer run means a heading was missed
_DATES = re.compile(r'^\s*\(\s*\d{3,4}\s*[-–—]')
VERDICT_NAMES = {
    'a': 'verse can be published',
    'b': 'verse is not the poet\'s',
    'c': 'the chapter prints no verse',
    'd': 'no chapter in these books',
}


def grade_of(book):
    return int(re.search(r'(\d+)\s*$', book).group(1))


def cited_pages(poet):
    """{grade: set of printed pages} the biography cites."""
    out = {}
    for segment in (poet.get('biographySource') or '').split(';'):
        match = re.search(r'синфи\s*(\d+)[^,]*?,\s*с\.\s*([\d–\-,\s]+)', segment)
        if not match:
            continue
        pages = out.setdefault(int(match.group(1)), set())
        for part in match.group(2).split(','):
            numbers = [int(n) for n in re.findall(r'\d+', part)]
            if len(numbers) == 1:
                pages.add(numbers[0])
            elif len(numbers) == 2 and numbers[0] <= numbers[1]:
                pages.update(range(numbers[0], numbers[1] + 1))
    return out


def _loose(text):
    """A name key that ignores ӯ/у, ӣ/и and the izofat «-и» at word ends
    («АБУАБДУЛЛОҲИ» = «Абӯабдуллоҳ», «ҲОФИЗИ ШЕРОЗӢ» = «Ҳофиз Шерозӣ»)."""
    words = norm(text).replace('ӯ', 'у').replace('ӣ', 'и').split(' ')
    return ' '.join(w[:-1] if len(w) > 4 and w.endswith('и') else w
                    for w in words)


def _heading_owner(group, loose):
    """The poet a chapter heading names: the whole heading, else the
    longest poet name (six letters or more) it contains as whole words,
    when only one poet has it."""
    text = _loose(' '.join(group))
    if text in loose:
        return loose[text]
    hits = sorted((k for k in loose if len(k) >= 6 and
                   f' {k} ' in f' {text} '), key=len, reverse=True)
    owners = {loose[k] for k in hits if len(k) == len(hits[0])} if hits else set()
    if not owners and ' ' in text:
        # The heading is part of a longer name («ҲОФИЗИ ШЕРОЗӢ»).
        owners = {v for k, v in loose.items() if f' {text} ' in f' {k} '}
    return owners.pop() if len(owners) == 1 else None


def chapter_heads(pages, names):
    """[(pdf page, poet id or None)]: where chapters begin, in book order.
    A chapter begins at a heading in capitals (one or two lines) that is a
    poet's name near the top of a page, or any heading right above a line
    of dates «(1913 - 1988)»; a survey heading «АДАБИЁТИ …» begins a
    chapter of no one. Pages with several name headings (a play's speaker
    labels) start no chapter."""
    loose = {_loose(k): v for k, v in names.items()}
    heads = []
    for index in range(1, len(pages)):
        lines = [l for l in pages[index].split('\n') if l.strip()]
        short = [l for l in lines if is_heading(l) and len(l.strip()) <= 30]
        if len(short) >= 3:
            continue                    # a play's speaker labels
        found = []
        j = 0
        while j < len(lines):
            if not is_heading(lines[j]) or _page_number.match(lines[j]):
                j += 1
                continue
            group = [lines[j].strip()]
            if j + 1 < len(lines) and is_heading(lines[j + 1]) and \
                    not _DATES.match(lines[j + 1]) and \
                    len(lines[j + 1].strip()) <= 30:
                group.append(lines[j + 1].strip())
            text = norm(' '.join(group))
            owner = _heading_owner(group, loose)
            after = lines[j + len(group)] if j + len(group) < len(lines) else ''
            dated = _DATES.match(after) is not None and len(after.strip()) <= 40
            if dated or (owner and j < 6):
                found.append((index, owner))
            elif text.startswith('адабиёти ') and j < 6:
                found.append((index, None))
            j += len(group)
        if len([f for f in found if f[1]]) <= 1:
            heads += found[:1] if found else []
    return heads


def chapter_pages(poet_id, heads, pages):
    """Printed pages of the chapters headed with the poet's name."""
    found = set()
    for n, (index, owner) in enumerate(heads):
        if owner != poet_id:
            continue
        end = heads[n + 1][0] - 1 if n + 1 < len(heads) else len(pages) - 1
        end = min(end, index + MAX_CHAPTER)
        found.update(printed_page(pages[i], i) for i in range(index, end + 1))
    return found


def _versey(line):
    stripped = line.strip()
    return (10 <= len(stripped) <= MAX_VERSE_CHARS and
            not _glossary.match(stripped) and not _question.match(stripped)
            and not is_heading(line) and not _page_number.match(line)
            and not stripped.endswith('-') and ' – ' not in stripped)


def flush_runs(text):
    """[(first line, closing line)] of verse set flush left: four or more
    short lines, most ending as verse lines do."""
    runs, run = [], []

    def close():
        if len(run) >= 4 and run[0][:1].isupper() and \
                sum(1 for l in run if _ends_verse.search(l)) >= 0.75 * len(run):
            runs.append((run[0], run[-1]))
    for line in text.split('\n'):
        if not line.strip():
            continue
        if _indent(line) < 2 and _versey(line):
            run.append(line.strip())
            continue
        close()
        run = []
    close()
    return runs


_SEPARATOR = re.compile(r'^\s*(?:\*\s*){1,3}$|^\s*\([^()]{3,40}\)\s*$')


def block_starts(text):
    """Line numbers where a verse block may begin: after a non-verse line
    (scan_textbook_chapters.verse_starts), under a printed title, and after
    a «***» separator or a signature «(Шаҳиди Балхӣ)» between two
    quotations."""
    lines = text.split('\n')
    starts = set(verse_starts(text))
    for i, line in enumerate(lines):
        if is_heading(line) and not _page_number.match(line):
            # Verse under a printed title, at any indent.
            nxt = next((j for j in range(i + 1, len(lines)) if lines[j].strip()), None)
            if nxt is not None and _indent(lines[nxt]) >= 2 and \
                    not is_heading(lines[nxt]):
                starts.add(nxt)
        if _SEPARATOR.match(line):
            nxt = next((j for j in range(i + 1, len(lines)) if lines[j].strip()), None)
            if nxt is not None and not _SEPARATOR.match(lines[nxt]):
                starts.add(nxt)
    return sorted(starts)


def verse_blocks(pages, indices):
    """[(pdf page, opening, lines)] of the verse blocks that begin on the
    given pages, indented or flush left."""
    blocks, seen = [], set()
    for index in sorted(indices):
        text = pages[index]
        for line_no in block_starts(text):
            result = extract_poem(pages, index, text.split('\n')[line_no].strip())
            if result is None or result[3] != index:
                continue
            for part in split_series(result[1]):
                opening = next(l for l in part if l)
                if (index, norm(opening)) not in seen:
                    seen.add((index, norm(opening)))
                    blocks.append((index, opening, part))
        for opening, closing in flush_runs(text):
            if (index, norm(opening)) not in seen:
                seen.add((index, norm(opening)))
                blocks.append((index, opening, [opening, closing]))
    return blocks


def review_reason(work, books, names, published):
    """Why a needsReview record is not readable (one short phrase)."""
    verification = work.get('verification') or {}
    if work.get('secondarySource') or work.get('textMatchResult'):
        return 'curated record awaiting its own review'
    if verification.get('verificationMethod') == 'manualAttributionReview':
        return 'withdrawn or title only after attribution review'
    source = work.get('primarySource') or {}
    ref = source.get('sourceReference') or ''
    if not ref:
        return 'no source'
    if source.get('pageStart') is None:
        return 'no page'
    book = os.path.basename(ref)[:-4]
    pages = books.get(book)
    if pages is None:
        return 'not a textbook PDF'
    opening = (work.get('title') or '').rstrip('.…').strip()
    if len(norm(opening)) < 10:
        return 'title too short to find on the page'
    for offset in PAGE_OFFSETS:
        index = source['pageStart'] + offset
        if not 1 <= index < len(pages):
            continue
        if not any(norm(line).startswith(norm(opening)[:24])
                   for line in pages[index].split('\n')):
            continue
        result = extract_poem(pages, index, opening)
        if result is None:
            return 'the title is a line of prose'
        lines = [l for l in result[1] if l]
        if len(lines) < 4:
            return 'a single bayt or less'
        if not split_series(result[1]):
            return 'the block does not read as verse'
        lead = text_above(pages, result[3], result[1])
        if quoted_from_other_poet(lead, work['authorId'], names):
            return 'the lead-in names another poet'
        if lead_in_disqualifies(lead):
            return 'the lead-in introduces folk verse, an elegy, a translation or an example'
        if norm(lines[0]) in published:
            return 'the verse is already published'
        return 'verse found; not yet reviewed'
    return 'the title is not printed on or near the cited page'


def coverage(poets, works, books, verdicts):
    names = poet_names(poets)
    published = {norm(l) for w in works if w.get('textTajik') and
                 w['verification'].get('evidenceLevel') == 'primaryChecked'
                 for l in w['textTajik'].split('\n') if l.strip()}
    readable = Counter(w['authorId'] for w in works
                       if w['verification'].get('evidenceLevel') == 'primaryChecked'
                       and w.get('textTajik'))
    reasons = {}
    for work in works:
        if work['verification'].get('evidenceLevel') == 'needsReview':
            reasons.setdefault(work['authorId'], Counter())[
                review_reason(work, books, names, published)] += 1
    heads = {book: chapter_heads(pages, names) for book, pages in books.items()}
    indexes = {book: {printed_page(p, i): i for i, p in enumerate(pages) if i}
               for book, pages in books.items()}
    rows = []
    for poet in poets:
        cited = cited_pages(poet)
        decided = verdicts.get(poet['id']) or {}
        # A person's reading of the book corrects the biography's pages.
        for grade, pages_text in (decided.get('chapters') or {}).items():
            cited.setdefault(int(grade), set()).update(
                cited_pages({'biographySource': f'синфи {grade}, с. {pages_text}'})
                .get(int(grade), set()))
        chapters, blocks = {}, []
        for book, pages in books.items():
            grade = grade_of(book)
            printed = set(cited.get(grade, ())) | \
                chapter_pages(poet['id'], heads[book], pages)
            if not printed:
                continue
            chapters[grade] = sorted(printed)
            found = verse_blocks(pages, {indexes[book][n] for n in printed
                                         if n in indexes[book]})
            blocks += [(grade, index, opening, lines)
                       for index, opening, lines in found]
        unpublished = [b for b in blocks
                       if not any(norm(l) in published for l in b[3] if l)]
        rows.append({
            'id': poet['id'],
            'name': poet['canonicalName'],
            'status': poet.get('recordStatus') or 'active',
            'chapters': chapters,
            'blocks': len(blocks),
            'unpublishedBlocks': len(unpublished),
            'readable': readable[poet['id']],
            'needsReview': sum((reasons.get(poet['id']) or Counter()).values()),
            'reasons': dict((reasons.get(poet['id']) or Counter()).most_common()),
            # A published poem settles (a); otherwise an undecided verdict
            # is a suggestion, marked «?».
            'verdict': decided.get('verdict') or ('a' if readable[poet['id']] else
                                                  suggest(chapters, blocks, unpublished, 0) + '?'),
            'note': decided.get('note', ''),
        })
    return rows


def suggest(chapters, blocks, unpublished, readable):
    if not chapters:
        return 'd'
    if unpublished:
        return 'a'
    if readable or blocks:
        return 'a' if readable else 'b'
    return 'c'


def page_ranges(pages):
    """[1, 2, 3, 7] -> '1–3, 7'."""
    out, start = [], None
    for n, page in enumerate(pages):
        if start is None:
            start = page
        if n + 1 == len(pages) or pages[n + 1] != page + 1:
            out.append(str(start) if start == page else f'{start}–{page}')
            start = None
    return ', '.join(out)


def markdown(rows):
    lines = [
        '| Poet | Chapter pages | Verse blocks (unpublished) | Readable | '
        'needsReview: why not readable | Verdict |',
        '|---|---|---|---|---|---|',
    ]
    for row in sorted(rows, key=lambda r: (r['readable'], r['name'])):
        chapters = '; '.join(f'{g}: {page_ranges(p)}'
                             for g, p in sorted(row['chapters'].items())) or '—'
        why = '; '.join(f'{n} {r}' for r, n in row['reasons'].items()) or '—'
        verdict = row['verdict']
        name = VERDICT_NAMES.get(verdict.rstrip('?'), '')
        note = f" {row['note']}" if row['note'] else ''
        lines.append(
            f"| {row['name']} | {chapters} | {row['blocks']} "
            f"({row['unpublishedBlocks']}) | {row['readable']} | "
            f"{row['needsReview']}: {why} | **{verdict}** {name}.{note} |")
    return '\n'.join(lines) + '\n'


def main(pages_dir, out_md, out_json=None, works_path=WORKS):
    with open(POETS, encoding='utf-8') as f:
        poets = json.load(f)
    with open(works_path, encoding='utf-8') as f:
        works = json.load(f)
    verdicts = {}
    if os.path.exists(VERDICTS):
        with open(VERDICTS, encoding='utf-8') as f:
            verdicts = json.load(f)['poets']
    books = {b: load_pages(pages_dir, b) for b in sorted(os.listdir(pages_dir))
             if os.path.isdir(os.path.join(pages_dir, b))}
    rows = coverage(poets, works, books, verdicts)
    with open(out_md, 'w', encoding='utf-8') as f:
        f.write(markdown([r for r in rows if r['status'] not in ('rejected', 'review')]))
    if out_json:
        with open(out_json, 'w', encoding='utf-8') as f:
            json.dump(rows, f, ensure_ascii=False, indent=1)
    buckets = Counter('0' if r['readable'] == 0 else '1–2' if r['readable'] <= 2
                      else '3+' for r in rows)
    print(f"poets {len(rows)}; readable poems {sum(r['readable'] for r in rows)}; "
          f"poets with 0: {buckets['0']}, 1–2: {buckets['1–2']}, 3+: {buckets['3+']}")


if __name__ == '__main__':
    main(*sys.argv[1:5])
