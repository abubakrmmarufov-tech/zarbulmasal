"""Set Latin look-alike letters in Cyrillic words as the Cyrillic letters the
page shows, in every record kept in the catalogue.

Usage:
    python3 tool/literature/fix_lookalike_letters.py <log.json>
    dart run tool/build_runtime_literature.dart

The PDF text layer sometimes sets a Latin letter that looks like a Cyrillic
one inside a Cyrillic word («КИШТИНИШACTАГОНЕМ», «Xалоси», «cap» for «сар»).
The printed page shows the Cyrillic letter; search for the word fails with
the Latin one. textbook_span.fix_lookalikes decides which words change.

Only title, incipit and textTajik are touched. When one changes, its
generated Persian-script form is generated again (it is labelled
«generated»). Every change is written to <log.json> with the record id,
field, the word before and after. Rejected records are left as they are.
"""
import json
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from transliterate_tajik import transliterate_text  # noqa: E402

sys.path.insert(0, os.path.dirname(__file__))
from textbook_span import fix_lookalikes  # noqa: E402

WORKS = 'assets/data/literature/works.json'
FIELDS = ('title', 'incipit', 'textTajik')
GENERATED = {
    'title': ('titlePersian', 'titlePersianSource'),
    'textTajik': ('persianScriptRepresentation', 'persianScriptSource'),
}


def fix_record(record):
    """[(field, before, after)] for the words changed in `record`."""
    changes = []
    for field in FIELDS:
        value = record.get(field)
        if not isinstance(value, str):
            continue
        fixed, words = fix_lookalikes(value)
        if not words:
            continue
        record[field] = fixed
        changes += [(field, before, after) for before, after in words]
        persian = GENERATED.get(field)
        if persian and record.get(persian[1]) == 'generated' and \
                record.get(persian[0]):
            record[persian[0]] = transliterate_text(fixed)
    return changes


def fix_all(works):
    log = []
    for record in works:
        if (record.get('verification') or {}).get('evidenceLevel') == 'rejected':
            continue
        for field, before, after in fix_record(record):
            log.append({'id': record['id'], 'field': field,
                        'before': before, 'after': after})
    return log


def main(log_path):
    with open(WORKS, encoding='utf-8') as f:
        works = json.load(f)
    log = fix_all(works)
    with open(WORKS, 'w', encoding='utf-8') as f:
        json.dump(works, f, ensure_ascii=False, indent=2)
        f.write('\n')
    with open(log_path, 'w', encoding='utf-8') as f:
        json.dump({'about': 'Latin look-alike letters set as the Cyrillic letters '
                            'the page shows (tool/literature/fix_lookalike_letters.py).',
                   'changes': log}, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(f'{len(log)} words changed in {len({c["id"] for c in log})} records')


if __name__ == '__main__':
    main(sys.argv[1])
