"""Tests for audit_textbook_poems.py (python3 -m unittest)."""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from audit_textbook_poems import audit  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')

PAGE = """\
    Дар ин бора худи шоир чунин
мегӯяд:
           Бихандад лола дар саҳро
           Ба сони чеҳраи Лайло1.
           Бигиряд абр дар гардун
           Ба сони дидаи Маҷнун.
                                   52
"""
OTHER = PAGE.replace('худи шоир чунин', 'Рӯдакӣ чунин')
NAMES = {'рӯдакӣ': 'rudaki'}


def work(text, author='poet', wid='w'):
    return {'id': wid, 'authorId': author, 'title': 't', 'textTajik': text,
            'primarySource': {'sourceReference': 'docs/literature/pdfs/b.pdf',
                              'pageStart': 52, 'pageEnd': 52},
            'verification': {'verificationMethod': 'textbookPdfTextExtraction'}}


POEM = ('Бихандад лола дар саҳро\nБа сони чеҳраи Лайло.\n'
        'Бигиряд абр дар гардун\nБа сони дидаи Маҷнун.')


class AuditTest(unittest.TestCase):
    def test_a_poem_printed_on_its_page_passes(self):
        checked, failures = audit([work(POEM)], {'b': ['', PAGE]}, NAMES)
        self.assertEqual((checked, failures), (1, []))

    def test_a_line_not_on_the_page_fails(self):
        _, failures = audit([work(POEM + '\nСатри иловагӣ.')], {'b': ['', PAGE]}, NAMES)
        self.assertEqual(failures[0][1], 'lines not on the cited pages')
        self.assertEqual(failures[0][2], ['Сатри иловагӣ.'])

    def test_a_lead_in_naming_another_poet_fails_unless_confirmed(self):
        _, failures = audit([work(POEM)], {'b': ['', OTHER]}, NAMES)
        self.assertEqual(failures[0][1], 'the lead-in names another poet')
        _, failures = audit([work(POEM)], {'b': ['', OTHER]}, NAMES, {'w'})
        self.assertEqual(failures, [])

    def test_other_methods_are_not_audited(self):
        w = work(POEM)
        w['verification']['verificationMethod'] = 'manualReview'
        self.assertEqual(audit([w], {'b': ['', PAGE]}, NAMES), (0, []))


class ExceptionsFileTest(unittest.TestCase):
    def test_every_exception_quotes_its_lead_in_and_says_why(self):
        path = os.path.join(ROOT, 'docs', 'literature',
                            'ATTRIBUTION_GUARD_EXCEPTIONS.json')
        with open(path, encoding='utf-8') as f:
            exceptions = json.load(f)['exceptions']
        for e in exceptions:
            self.assertTrue(e['id'] and e['leadIn'] and e['note'])


if __name__ == '__main__':
    unittest.main()
