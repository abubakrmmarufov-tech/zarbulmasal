"""Apply hand-made attribution decisions to works.json.

Usage:
    python3 tool/literature/apply_attribution_decisions.py <decisions.json> [<pages_dir>]

<decisions.json> (e.g. docs/literature/ATTRIBUTION_DECISIONS_2026-09-25.json)
lists one decision per record, each taken by reading the printed page:

  * drop      -- the verse is not the poet's own (folk verse, an elegy or
                 chronogram by someone else, a translation, an example, or
                 prose). The record becomes `rejected` with the reason.
  * refile    -- the book names another poet. The record moves to that poet
                 and stays `needsReview`, unless `publish` is given: then the
                 verse is copied from the page (<pages_dir>, as for
                 extract_textbook_poems.py) and published like any other
                 textbook poem. A lone bayt is never published.
  * titleOnly -- the title is attested but the text belonged to someone else.
                 The text goes; the record cites the page naming the title.
  * repair    -- the published text joined two quotations, or carried a
                 non-verse line; it is taken again from the page (`publish`,
                 as for refile) for the same poet.
  * truncate  -- the published text runs on past a prose line printed
                 between two quotations; it is cut before that line (`at`,
                 quoted exactly). Nothing above it changes.

Nothing is ever marked editoriallyApproved. Rerunning is harmless.
"""
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from transliterate_tajik import transliterate_text  # noqa: E402

sys.path.insert(0, os.path.dirname(__file__))
from extract_textbook_poems import first_line_title, load_pages, printed_page  # noqa: E402
from publish_textbook_poems import fill  # noqa: E402
from textbook_verse import extract_poem, reads_as_verse  # noqa: E402

WORKS = 'assets/data/literature/works.json'
TODAY = '2026-09-25'
ACTIONS = ('drop', 'refile', 'titleOnly', 'repair', 'truncate')


def _note(decision):
    return (f"Attribution review {TODAY} ({decision['book']}, p. "
            f"{decision['page']}): {decision['evidence']}")


def drop(record, decision):
    record['verification'] = {
        'evidenceLevel': 'rejected',
        'rejectionReason': f"extraction_false_positive:{decision['reason']}",
        'verificationMethod': 'manualAttributionReview',
        'verifiedAt': TODAY,
    }
    record['editorialNotes'] = _note(decision)
    return record


def refile(record, decision, pages=None):
    record['authorId'] = decision['authorId']
    publish = decision.get('publish')
    if not publish:
        record['editorialNotes'] = _note(decision)
        return record
    if pages is None:
        raise ValueError(f"{record['id']}: publishing needs the page texts")
    result = extract_poem(pages, publish['pdfPage'], publish['opening'])
    if result is None:
        raise ValueError(f"{record['id']}: verse not found on the page")
    _, lines, last, first = result
    if not reads_as_verse(lines):
        raise ValueError(f"{record['id']}: the block does not read as verse")
    book = decision['book']
    fill(record, {
        'authorId': decision['authorId'],
        'title': publish.get('title') or
        first_line_title(next(line for line in lines if line)),
        'type': publish.get('type'),
        'lines': lines,
        'pageStart': printed_page(pages[first], first),
        'pageEnd': printed_page(pages[last], last),
        'sourceReference': f'docs/literature/pdfs/{book}.pdf',
    })
    record['verification']['verifiedAt'] = TODAY
    record['editorialNotes'] += ' ' + _note(decision)
    return record


def _last_page(record, pages, last_line):
    """The printed page on which `last_line` of the record appears."""
    from audit_textbook_poems import printed_index
    from textbook_verse import clean_line, norm
    source = record['primarySource']
    index = printed_index(pages)
    for printed in range(source['pageStart'], source['pageEnd'] + 1):
        i = index.get(printed)
        if i and any(norm(clean_line(raw)) == norm(last_line)
                     for raw in pages[i].split('\n')):
            return printed
    return source['pageEnd']


def _withdraw(record, decision, why):
    record.update({
        'incipit': None, 'textTajik': None, 'textPersian': None,
        'persianScriptRepresentation': None, 'textStatus': 'needsReview',
        'editorial': 'extraction',
        'rights': {'status': 'unknown',
                   'reasoning': 'Withdrawn from publication; see the note.',
                   'fullTextAllowed': False, 'excerptAllowed': False},
        'verification': {'evidenceLevel': 'needsReview', 'pageVerified': False,
                         'verificationMethod': 'manualAttributionReview',
                         'verifiedAt': TODAY},
    })
    record['editorialNotes'] = _note(decision) + f' Withdrawn: {why}.'
    return record


def truncate(record, decision, pages=None):
    lines = record['textTajik'].split('\n')
    if decision['at'] not in lines:
        raise ValueError(f"{record['id']}: {decision['at']!r} is not a line")
    kept = lines[:lines.index(decision['at'])]
    while kept and not kept[-1].strip():
        kept.pop()
    if not reads_as_verse(kept):
        return _withdraw(record, decision, 'what precedes it is a single bayt '
                         'or less, which is not published as a work')
    text = '\n'.join(kept)
    if pages is not None:
        source = dict(record['primarySource'])
        source['pageEnd'] = _last_page(record, pages, kept[-1])
        record['primarySource'] = source
    record['textTajik'] = text
    record['persianScriptRepresentation'] = transliterate_text(text)
    record['editorialNotes'] = (record.get('editorialNotes') or '') + \
        ' ' + _note(decision)
    return record


def title_only(record, decision, by_id):
    source = dict(by_id[decision['sourceFrom']]['primarySource'])
    source.update({
        'pageStart': decision['page'],
        'pageEnd': decision['page'],
        'sourceImageVerified': False,
        'sourceImagePath': None,
    })
    record.update({
        'incipit': None,
        'textTajik': None,
        'textPersian': None,
        'persianScriptRepresentation': None,
        'textStatus': 'needsReview',
        'editorial': 'extraction',
        'editorialNotes': _note(decision),
        'primarySource': source,
        'rights': {
            'status': 'unknown',
            'reasoning': 'Title attested in the textbook; its text is not printed there.',
            'fullTextAllowed': False,
            'excerptAllowed': False,
        },
        'verification': {
            'evidenceLevel': 'needsReview',
            'pageVerified': False,
            'verificationMethod': 'manualAttributionReview',
            'verifiedAt': TODAY,
        },
    })
    return record


def apply(works, decisions, pages_by_book=None):
    """Apply `decisions` to `works` in place; returns {action: count}."""
    by_id = {w['id']: w for w in works}
    counts = {}
    for decision in decisions:
        action = decision['action']
        if action not in ACTIONS:
            raise ValueError(f"unknown action {action!r}")
        record = by_id.get(decision['id'])
        if record is None:
            raise KeyError(decision['id'])
        if action == 'drop':
            drop(record, decision)
        elif action in ('refile', 'repair'):
            if action == 'repair':
                decision = dict(decision, authorId=record['authorId'])
            pages = (pages_by_book or {}).get(decision['book'])
            refile(record, decision, pages)
        elif action == 'truncate':
            truncate(record, decision, (pages_by_book or {}).get(decision['book']))
        else:
            title_only(record, decision, by_id)
        counts[action] = counts.get(action, 0) + 1
    return counts


def main(decisions_path, pages_dir=None):
    works = json.load(open(WORKS, encoding='utf-8'))
    decisions = json.load(open(decisions_path, encoding='utf-8'))['decisions']
    books = {d['book'] for d in decisions
             if d.get('publish') or d['action'] == 'truncate'}
    pages = {b: load_pages(pages_dir, b) for b in books} if pages_dir else {}
    counts = apply(works, decisions, pages)
    with open(WORKS, 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(', '.join(f'{k}: {v}' for k, v in sorted(counts.items())))


if __name__ == '__main__':
    main(*sys.argv[1:3])
