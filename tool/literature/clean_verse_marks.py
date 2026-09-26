"""Remove print marks that are not verse from published poems.

Usage:
    python3 tool/literature/clean_verse_marks.py <decisions.json> [--apply]
    dart run tool/build_runtime_literature.dart

The textbooks set footnote numbers as superscripts; the text layer glues
them to the verse («наҳмор 27шод», «басити91марғзор»). A few pages also
print a footnote gloss («Муқтазӣ – сабаб, боис.») among the verse lines, and
the text layer gives a digit 3 for the letter З in «З-он», «З-ин».

clean_line removes a marker (between two words, where the superscript
takes the word gap, it leaves the space the print implies) and sets З for 3.
is_gloss finds gloss candidates; only the glosses a person confirmed on the
page, listed in <decisions.json>, are removed. Without --apply the changes
are only printed; with it works.json is written and every change (record,
before, after) is logged in <decisions.json> under `changes`. The generated
Persian script is generated again for changed records.
"""
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

WORKS = 'assets/data/literature/works.json'
CYR = 'А-Яа-яЁёӢӣӮӯҲҳҶҷҚқҒғ'
_gloss = re.compile(rf'^([{CYR}]+(?: [{CYR}]+)?) [-–] ([{CYR}].*\.)$')


def clean_line(line):
    """textbook_verse.clean_line, which the extractor and the audit use."""
    from textbook_verse import clean_line as clean
    return clean(line)


def is_gloss(line):
    """A footnote gloss: a word or two, a dash, and its meaning ending with a
    full stop («Муқтазӣ – сабаб, боис.»); not a doubled word («Андак –
    андак …»)."""
    match = _gloss.match(line.strip())
    if not match:
        return False
    term, meaning = match.groups()
    return not meaning.lower().startswith(term.split()[0].lower())


def clean_text(text, glosses=frozenset()):
    out, changes = [], []
    for line in text.split('\n'):
        if line.strip() in glosses:
            changes.append({'before': line, 'after': None})
            continue
        cleaned = clean_line(line)
        if cleaned != line:
            changes.append({'before': line, 'after': cleaned})
        out.append(cleaned)
    return '\n'.join(out), changes


def merge_logs(earlier, later):
    """Changes logged by earlier runs, then those of this run that are new
    (a rerun finds nothing to change in text it already cleaned)."""
    merged = [dict(entry, changes=list(entry['changes'])) for entry in earlier]
    by_id = {entry['id']: entry for entry in merged}
    for entry in later:
        if entry['id'] not in by_id:
            by_id[entry['id']] = dict(entry, changes=[])
            merged.append(by_id[entry['id']])
        known = by_id[entry['id']]['changes']
        for change in entry['changes']:
            if change not in known:
                known.append(change)
    return merged


def main(decisions_path, apply=False):
    from transliterate_tajik import transliterate_text
    with open(WORKS, encoding='utf-8') as handle:
        works = json.load(handle)
    with open(decisions_path, encoding='utf-8') as handle:
        decisions = json.load(handle)
    glosses = {g['line'] for g in decisions.get('glosses', [])}
    log = []
    for work in works:
        if (work.get('verification') or {}).get('evidenceLevel') != 'primaryChecked':
            continue
        if not work.get('textTajik'):
            continue
        text, changes = clean_text(work['textTajik'], glosses)
        if not changes:
            continue
        work['textTajik'] = text
        if work.get('persianScriptSource') == 'generated':
            work['persianScriptRepresentation'] = transliterate_text(text)
        log.append({'id': work['id'], 'changes': changes})
        for change in changes:
            print(f"{work['id'][:48]}: {change['before']!r} -> {change['after']!r}")
    decisions['changes'] = merge_logs(decisions.get('changes', []), log)
    if apply:
        with open(WORKS, 'w', encoding='utf-8') as handle:
            handle.write(json.dumps(works, ensure_ascii=False, indent=2) + '\n')
        with open(decisions_path, 'w', encoding='utf-8') as handle:
            handle.write(json.dumps(decisions, ensure_ascii=False, indent=2) + '\n')
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1], '--apply' in sys.argv[2:]))
