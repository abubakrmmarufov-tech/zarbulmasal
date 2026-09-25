"""Tests for publish_reviewed_blocks.py (python3 -m unittest)."""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from publish_reviewed_blocks import publish  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')

PAGE = """\
    Шоир дар ғазали зерин аз рӯзгори худ шикоят
менамояд:
           Дар баҳор аз фоқа ранги заъфарон бошад маро,
           Пораҳо бар дӯш аз барги хазон бошад маро.
           Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон,
           Рӯзу шаб шармандагӣ аз обу нон бошад маро.
    Дар ҳамин маврид чунон ки
гуфтаанд:
           Пеши он кас, ки ихтиёраш ҳаст,
           Халқ беихтиёр меоянд.
           Гар набошад ба ӯ умеди касе,
           Бар дараш бо чӣ кор меоянд?
                                   68
"""

REF = 'docs/literature/pdfs/b.pdf'


def published(text):
    return {
        'id': 'old', 'authorId': 'x', 'textTajik': text,
        'primarySource': {'bookTitle': 'Адабиёти тоҷик', 'year': '2017',
                          'sourceReference': REF, 'pageStart': 1, 'pageEnd': 1},
        'verification': {'evidenceLevel': 'primaryChecked',
                         'verificationMethod': 'textbookPdfTextExtraction'},
    }


def block(opening, decision='accept', **extra):
    base = {'book': 'b', 'pdfPage': 1, 'page': 68, 'opening': opening,
            'decision': decision, 'authorId': 'sayyido',
            'reason': 'the lead-in names the poet'}
    base.update(extra)
    return base


class PublishTest(unittest.TestCase):
    def test_an_accepted_block_is_published_verbatim_from_the_page(self):
        works = [published('Бихандад лола дар саҳро')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(skipped, [])
        [record] = added
        self.assertEqual(record['authorId'], 'sayyido')
        self.assertEqual(record['textTajik'].split('\n')[0],
                         'Дар баҳор аз фоқа ранги заъфарон бошад маро,')
        self.assertEqual(len(record['textTajik'].split('\n')), 4)
        self.assertEqual(record['primarySource']['pageStart'], 68)
        self.assertEqual(record['primarySource']['bookTitle'], 'Адабиёти тоҷик')
        self.assertEqual(record['verification']['evidenceLevel'], 'primaryChecked')
        self.assertIn('reviewed by hand', record['editorialNotes'])
        self.assertIn(record, works)

    def test_rejected_blocks_are_ignored(self):
        works = [published('x')]
        added, _ = publish(works, [block('Пеши он кас, ки ихтиёраш ҳаст,',
                                         decision='reject')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(len(works), 1)

    def test_a_block_already_published_is_skipped(self):
        works = [published('Дар баҳор аз фоқа ранги заъфарон бошад маро,\n'
                           'Пораҳо бар дӯш аз барги хазон бошад маро.\n'
                           'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон,\n'
                           'Рӯзу шаб шармандагӣ аз обу нон бошад маро.\n'
                           'Байти дигар.')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'already published')

    def test_a_reprint_with_other_punctuation_is_a_duplicate(self):
        works = [published('Дар баҳор аз фоқа, ранги заъфарон бошад маро\n'
                           'Пораҳо бар дӯш аз барги хазон бошад маро!\n'
                           'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон\n'
                           'Рӯзу шаб шармандагӣ аз обу нон бошад маро...')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'already published')

    def test_the_same_poet_title_and_first_line_is_a_duplicate(self):
        old = published('Дар баҳор аз фоқа ранги заъфарон бошад маро...\nБайти дигар.')
        old.update(authorId='sayyido',
                   title='Дар баҳор аз фоқа ранги заъфарон бошад маро',
                   incipit='Дар баҳор аз фоқа ранги заъфарон бошад маро...')
        added, skipped = publish([old], [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'already published')

    def test_the_same_block_twice_is_published_once(self):
        works = [published('x')]
        b = block('Дар баҳор аз фоқа ранги заъфарон бошад маро,')
        added, skipped = publish(works, [b, dict(b)], {'b': ['', PAGE]})
        self.assertEqual(len(added), 1)
        self.assertEqual(len(skipped), 1)

    def test_a_block_that_does_not_start_at_the_opening_is_refused(self):
        page = PAGE.replace('шикоят\nменамояд:', 'шикоят менамояд:')
        works = [published('x')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', page]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'the opening line starts no verse part')

    def test_a_missing_opening_is_reported(self):
        works = [published('x')]
        added, skipped = publish(works, [block('Ин сатр дар саҳифа нест, албатта')],
                                 {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'not found on the page')


class ShippedReviewTest(unittest.TestCase):
    def test_every_block_has_a_decision_and_a_reason(self):
        path = os.path.join(ROOT, 'docs', 'literature',
                            'EXTRACTION_REVIEW_2026-09-25.json')
        with open(path, encoding='utf-8') as f:
            blocks = json.load(f)['blocks']
        self.assertGreater(len(blocks), 200)
        for b in blocks:
            self.assertIn(b['decision'], ('accept', 'reject'))
            self.assertTrue(b['reason'])
            self.assertTrue(b['leadIn'])
            if b['decision'] == 'accept':
                self.assertTrue(b['authorId'])


if __name__ == '__main__':
    unittest.main()
