"""Tests for correct_cited_pages.py (python3 -m unittest)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from correct_cited_pages import correct  # noqa: E402

PAGE52 = """\
    Дар ин бора худи шоир чунин
мегӯяд:
           Бихандад лола дар саҳро
           Ба сони чеҳраи Лайло.
                                   52
"""
PAGE53 = """\
           Бигиряд абр дар гардун
           Ба сони дидаи Маҷнун.
                                   53
"""
POEM = ('Бихандад лола дар саҳро\nБа сони чеҳраи Лайло.\n'
        'Бигиряд абр дар гардун\nБа сони дидаи Маҷнун.')


def work(start, end, text=POEM):
    return {'id': 'w', 'textTajik': text,
            'primarySource': {'sourceReference': 'docs/literature/pdfs/b.pdf',
                              'pageStart': start, 'pageEnd': end},
            'rights': {'reasoning': 'Zarbulmasal source-attested publication '
                                    'policy: … attributed there, page %d.' % start},
            'verification': {'verificationMethod': 'textbookPdfTextExtraction'}}


class CorrectTest(unittest.TestCase):
    def test_a_wrong_range_is_set_to_the_printed_pages(self):
        w = work(51, 54)
        changes = correct([w], {'b': ['', '  51\n', PAGE52, PAGE53]})
        self.assertEqual((w['primarySource']['pageStart'],
                          w['primarySource']['pageEnd']), (52, 53))
        self.assertTrue(w['rights']['reasoning'].endswith('page 52.'))
        self.assertEqual(changes, [('w', (51, 54), (52, 53))])

    def test_a_right_range_is_left_alone(self):
        w = work(52, 53)
        self.assertEqual(correct([w], {'b': ['', '  51\n', PAGE52, PAGE53]}), [])

    def test_a_poem_not_found_on_its_pages_is_left_alone(self):
        w = work(52, 53, text='Сатре, ки дар китоб нест.')
        self.assertEqual(correct([w], {'b': ['', '  51\n', PAGE52, PAGE53]}), [])


if __name__ == '__main__':
    unittest.main()
