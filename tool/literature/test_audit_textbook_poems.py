"""Tests for audit_textbook_poems.py (python3 -m unittest)."""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from audit_textbook_poems import audit, reviewed_ids  # noqa: E402

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


SIGNED = PAGE.replace('           Ба сони дидаи Маҷнун.\n',
                      '           Ба сони дидаи Маҷнун.\n'
                      '                             (Рӯдакӣ)\n')
FLUSH = """\
    Дар ин бора худи шоир чунин
мегӯяд:
Бихандад лола дар саҳро
Ба сони чеҳраи Лайло.
Бигиряд абр дар гардун
Ба сони дидаи Маҷнун.
                                   52
"""


class Phase8AuditTest(unittest.TestCase):
    def test_verse_the_book_signs_with_another_poet_fails(self):
        _, failures = audit([work(POEM)], {'b': ['', SIGNED]}, NAMES)
        self.assertEqual(failures[0][1], 'the book signs the verse with another poet (rudaki)')

    def test_verse_signed_with_its_own_poet_passes(self):
        _, failures = audit([work(POEM, author='rudaki')], {'b': ['', SIGNED]}, NAMES)
        self.assertEqual(failures, [])

    def test_flush_left_verse_is_not_read_as_prose(self):
        checked, failures = audit([work(POEM)], {'b': ['', FLUSH]}, NAMES)
        self.assertEqual((checked, failures), (1, []))

    def test_a_long_prose_line_in_flush_left_verse_fails(self):
        page = FLUSH.replace('Ба сони дидаи Маҷнун.',
                             'Ба сони дидаи Маҷнун, ки ин сатр аз панҷоҳу ҳашт ҳарф дарозтар аст.')
        text = POEM.replace('Ба сони дидаи Маҷнун.',
                            'Ба сони дидаи Маҷнун, ки ин сатр аз панҷоҳу ҳашт ҳарф дарозтар аст.')
        _, failures = audit([work(text)], {'b': ['', page]}, NAMES)
        self.assertEqual(failures[0][1], 'prose lines inside the poem')

    def test_reviewed_ids_prefer_the_ids_the_publisher_recorded(self):
        blocks = [{'decision': 'accept', 'book': 'b', 'pdfPage': 1,
                   'opening': 'x', 'recordIds': ['r1', 'r2']},
                  {'decision': 'reject', 'book': 'b', 'pdfPage': 1,
                   'opening': 'y', 'recordIds': ['r3']}]
        self.assertEqual(reviewed_ids(blocks), {'r1', 'r2'})


class ProseLineTest(unittest.TestCase):
    PAGE = """\
         Биёзмудамашон ошкору пинҳонӣ.
         Нахостам зи таманно, магар ки дастурӣ,
         Наёфтам зи атоҳо, магар пушаймонӣ.
    Марги Рӯдакии шоир барои аҳли адаби замонааш ва асрҳои
баъдӣ андуҳи бузурге буд. Онҳо хеле хуб фаҳмида буданд, ки
         Рӯдакӣ рафту монд ҳикмати ӯй,
         Май бирезад, нарезад аз вай бӯй.
                                   52
"""

    def test_a_prose_paragraph_opening_inside_a_poem_fails(self):
        text = ('Биёзмудамашон ошкору пинҳонӣ.\nНахостам зи таманно, магар ки дастурӣ,\n'
                'Наёфтам зи атоҳо, магар пушаймонӣ.\n'
                'Марги Рӯдакии шоир барои аҳли адаби замонааш ва асрҳои\n'
                'Рӯдакӣ рафту монд ҳикмати ӯй,\nМай бирезад, нарезад аз вай бӯй.')
        _, failures = audit([work(text)], {'b': ['', self.PAGE]}, NAMES)
        self.assertEqual(failures[0][1], 'prose lines inside the poem')
        self.assertEqual(failures[0][2],
                         ['Марги Рӯдакии шоир барои аҳли адаби замонааш ва асрҳои'])

    def test_a_shallow_lead_in_inside_a_poem_fails(self):
        page = PAGE.replace('                                   52\n', (
            '      Ё худ дар ғазали дигар:\n'
            '           Дар он саҳро, ки ваҳшат раҳравонро роҳбар бошад,\n'
            '                                   52\n'))
        text = POEM + '\nЁ худ дар ғазали дигар:\nДар он саҳро, ки ваҳшат раҳравонро роҳбар бошад,'
        _, failures = audit([work(text)], {'b': ['', page]}, NAMES)
        self.assertEqual(failures[0][2], ['Ё худ дар ғазали дигар:'])


class RepeatedLineTest(unittest.TestCase):
    def test_lines_are_matched_in_order_not_at_an_earlier_copy(self):
        page = ('Бихандад лола дар саҳро\n'
                'Ба сони чеҳраи Лайло.\n'
                'Касе дигар ҳам ин сатрро хондааст ва медонад\n'
                + PAGE)
        _, failures = audit([work(POEM)], {'b': ['', page]}, NAMES)
        self.assertEqual(failures, [])


class ReviewConfirmationTest(unittest.TestCase):
    def test_accepted_review_blocks_are_confirmed_by_their_stable_id(self):
        from audit_textbook_poems import reviewed_ids
        from publish_reviewed_blocks import stable_id
        blocks = [
            {'book': 'b', 'pdfPage': 3, 'opening': 'Сатри аввал,', 'decision': 'accept'},
            {'book': 'b', 'pdfPage': 4, 'opening': 'Сатри дигар,', 'decision': 'reject'},
        ]
        self.assertEqual(reviewed_ids(blocks), {stable_id('b', 3, 'Сатри аввал,')})


class CitedPagesTest(unittest.TestCase):
    def test_a_range_wider_than_the_printed_text_fails(self):
        page53 = '        Сатри дигари китоб\n                  53\n'
        w = work(POEM)
        w['primarySource']['pageEnd'] = 53
        _, failures = audit([w], {'b': ['', PAGE, page53]}, NAMES)
        self.assertEqual(failures[0][1], 'cited pages differ from the printed pages')
        self.assertEqual(failures[0][2], {'cited': [52, 53], 'printed': [52, 52]})

    def test_printed_pages_are_found_across_a_page_break(self):
        from audit_textbook_poems import printed_pages, printed_index
        page53 = '        Бигиряд абр дар гардун\n        Ба сони дидаи Маҷнун.\n                  53\n'
        page52 = PAGE.split('           Бигиряд')[0] + '                                   52\n'
        w = work(POEM)
        w['primarySource']['pageEnd'] = 53
        pages = ['', page52, page53]
        self.assertEqual(printed_pages(w, pages, printed_index(pages)), (52, 53))


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
