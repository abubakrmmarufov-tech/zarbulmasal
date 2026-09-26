"""Resolve readable poems published twice, as a person decided them.

Usage:
    python3 tool/literature/resolve_duplicates.py <decisions.json> [--apply]
    dart run tool/build_runtime_literature.dart

<decisions.json> (docs/literature/DUPLICATE_DECISIONS_2026-09-26.json) lists
  * {"retire": id, "into": id, "note": …}: a fragment cut at a page break,
    or an excerpt another book reprints, retired into the record that prints
    the whole poem, in the catalogue's terms
    (rejected as `duplicate_canonical_work:<into>`, without text); every
    line it held must be in the fuller record, or, with "variants": true,
    differ from one only in spelling (noted);
  * {"trim": id, "stanzas": n, "note": …}: a record that lumped several
    poems keeps its first n stanzas (the others are published on their own).
Without --apply nothing is written.
"""
import datetime
import difflib
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

WORKS = 'assets/data/literature/works.json'
TODAY = datetime.date.today().isoformat()


def _norm(line):
    return re.sub(r'[^\w]+', '', line.lower().replace('ё', 'е'))


def _lines(text):
    return [_norm(line) for line in (text or '').split('\n') if _norm(line)]


def retire(by_id, decision):
    record, into = by_id[decision['retire']], by_id[decision['into']]
    fuller = set(_lines(into['textTajik']))
    missing = [line for line in (record['textTajik'] or '').split('\n')
               if _norm(line) and _norm(line) not in fuller]
    variants = []
    for line in missing:
        close = difflib.get_close_matches(_norm(line), fuller, n=1, cutoff=0.9)
        if not (decision.get('variants') and close):
            raise ValueError(f"{record['id']} holds a line {into['id']} does "
                             f'not print: «{line}»')
        variants.append(line)
    record['verification'] = {
        'evidenceLevel': 'rejected',
        'rejectionReason': f"duplicate_canonical_work:{into['id']}",
        'verificationMethod': 'manualCanonicalDuplicateReview',
        'verifiedAt': TODAY,
    }
    record.update({
        'incipit': None, 'textTajik': None, 'textPersian': None,
        'persianScriptRepresentation': None, 'textStatus': 'needsReview',
        'rights': {'status': 'unknown', 'reasoning': f"Merged into {into['id']}.",
                   'fullTextAllowed': False, 'excerptAllowed': False},
    })
    note = decision['note']
    if variants:
        note += ('; its spelling differs in ' +
                 ', '.join(f'«{line.strip()}»' for line in variants))
    record['editorialNotes'] = (f"Merged {TODAY} into {into['id']} "
                                f"(«{into['title']}»): {note}.")


def trim(by_id, decision):
    from transliterate_tajik import transliterate_text
    record = by_id[decision['trim']]
    stanzas = re.split(r'\n\s*\n', record['textTajik'].strip())
    kept = '\n\n'.join(stanzas[:decision['stanzas']])
    removed = len(_lines(record['textTajik'])) - len(_lines(kept))
    if removed == 0:
        return {'removedLines': 0}       # already trimmed: a rerun changes nothing
    record['textTajik'] = kept
    if record.get('persianScriptSource') == 'generated':
        record['persianScriptRepresentation'] = transliterate_text(kept)
    note = f"Trimmed {TODAY}: {decision['note']}."
    record['editorialNotes'] = ' '.join(
        part for part in (record.get('editorialNotes'), note) if part)
    return {'removedLines': removed}


def main(decisions_path, apply=False):
    with open(WORKS, encoding='utf-8') as handle:
        works = json.load(handle)
    with open(decisions_path, encoding='utf-8') as handle:
        decisions = json.load(handle)
    by_id = {work['id']: work for work in works}
    for decision in decisions['decisions']:
        if 'retire' in decision:
            retire(by_id, decision)
            print(f"retired {decision['retire']} into {decision['into']}")
        else:
            result = trim(by_id, decision)
            print(f"trimmed {decision['trim']}: -{result['removedLines']} lines")
    if apply:
        with open(WORKS, 'w', encoding='utf-8') as handle:
            handle.write(json.dumps(works, ensure_ascii=False, indent=2) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1], '--apply' in sys.argv[2:]))
