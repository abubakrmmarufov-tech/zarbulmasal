"""Publish poems extracted from the textbooks into works.json.

Usage:
    python3 tool/literature/publish_textbook_poems.py <extracted.json>
    dart run tool/build_runtime_literature.dart

Input: the output of extract_textbook_poems.py. Each poem fills in the
candidate record it was found from (same id); further poems from the same
candidate (a split series) get a stable id derived from book, page and first
line. Records get:
  * textTajik: the printed lines, verbatim;
  * primarySource.pageStart/pageEnd: the printed page numbers;
  * verification.evidenceLevel = primaryChecked, pageVerified = true,
    method = textbookPdfTextExtraction (text layer of the cited page);
  * rights.status = sourceAttested (the project's one-source policy: the
    text as printed in the official textbook, attributed there);
  * a generated Persian-script representation, always labelled as such.
"""
import json
import os
import sys
import uuid

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from transliterate_tajik import transliterate_text  # noqa: E402

WORKS = 'assets/data/literature/works.json'
NAMESPACE = uuid.UUID('6f0c6c1e-5b8e-4a55-9d0c-7a1d2f3b4c5d')
TODAY = '2026-09-24'


def stable_id(poem):
    first = next(l for l in poem['lines'] if l)
    key = f"{poem['book']}|{poem['pdfPageStart']}|{first}"
    return str(uuid.uuid5(NAMESPACE, key))


def fill(record, poem):
    text = '\n'.join(poem['lines'])
    source = dict(record.get('primarySource') or poem['source'])
    source['pageStart'] = poem['pageStart']
    source['pageEnd'] = poem['pageEnd']
    source['sourceReference'] = poem['sourceReference']
    record.update({
        'authorId': poem['authorId'],
        'title': poem['title'],
        'titlePersian': transliterate_text(poem['title']),
        'titlePersianSource': 'generated',
        'incipit': next(l for l in poem['lines'] if l),
        'type': poem['type'] or record.get('type') or 'poem',
        'scriptSource': 'tajikOnly',
        'textTajik': text,
        'textPersian': None,
        'persianScriptRepresentation': transliterate_text(text),
        'persianScriptSource': 'generated',
        'textStatus': 'verified',
        'editorial': 'asPrinted',
        'editorialNotes': 'Text layer of the cited textbook page; legacy '
                          'Tajik font encoding mapped to Unicode and footnote '
                          'markers removed; no other change.',
        'primarySource': source,
        'rights': {
            'status': 'sourceAttested',
            'reasoning': 'Zarbulmasal source-attested publication policy: '
                         'text as printed in the official textbook, '
                         f"attributed there, page {poem['pageStart']}.",
            'rightsSource': poem['sourceReference'],
            'fullTextAllowed': True,
            'excerptAllowed': True,
            'permissionReference': None,
        },
        'verification': {
            'evidenceLevel': 'primaryChecked',
            'pageVerified': True,
            'verificationMethod': 'textbookPdfTextExtraction',
            'verifiedAt': TODAY,
        },
    })
    return record


def main(extracted_path):
    works = json.load(open(WORKS, encoding='utf-8'))
    poems = json.load(open(extracted_path, encoding='utf-8'))
    by_id = {w['id']: w for w in works}
    used = set()
    added = updated = 0
    for poem in poems:
        cid = poem['candidateId']
        if cid in by_id and cid not in used:
            fill(by_id[cid], poem)
            used.add(cid)
            updated += 1
            continue
        new_id = stable_id(poem)
        if new_id in by_id:
            fill(by_id[new_id], poem)
            updated += 1
            continue
        template = json.loads(json.dumps(by_id[cid])) if cid in by_id else {}
        template['id'] = new_id
        record = fill(template, poem)
        works.append(record)
        by_id[new_id] = record
        added += 1
    with open(WORKS, 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f'filled {updated} candidate records, added {added} new records')


if __name__ == '__main__':
    main(sys.argv[1])
