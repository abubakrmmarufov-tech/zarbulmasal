import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import correct_to_page as ctp  # noqa: E402

PAGE = [
    '',
    '        Фишонд аз савсану гул симу зар бод.\n'
    '        Зиҳӣ боде, ки раҳмат бод бар бод!\n'
    '    1. Гар бар сари нафси худ амирӣ, мардӣ,\n'
    '        Гар бар дигаре нукта нагирӣ, мардӣ.\n'
    '        Гуфт: Агар гардад лабат хушк аз дами сӯзони оҳ,\n'
    '        Боз месозаш чу шамъ аз гиря тар. Гуфтам ба чашм!\n'
    '                                                     60\n',
]


class CorrectTest(unittest.TestCase):
    def setUp(self):
        self.printed = ctp.printed_lines(PAGE, 1, 1)

    def test_punctuation_follows_the_page(self):
        text, changes = ctp.correct('Фишонд аз савсану гул симу зар бод,\n'
                                    'Зиҳӣ боде, ки раҳмат бод бар бод!',
                                    self.printed)
        self.assertEqual(text, 'Фишонд аз савсану гул симу зар бод.\n'
                               'Зиҳӣ боде, ки раҳмат бод бар бод!')
        self.assertEqual(changes, [{
            'before': 'Фишонд аз савсану гул симу зар бод,',
            'after': 'Фишонд аз савсану гул симу зар бод.',
        }])

    def test_words_follow_the_page(self):
        text, changes = ctp.correct(
            'Гуфт: «Агар гардад лабат хушк аз дами сӯзони мо,\n'
            'Боз месозаш чу шамъ аз дида тар!» Гуфтам: «Ба чашм!»',
            self.printed)
        self.assertEqual(text.split('\n'), [
            'Гуфт: Агар гардад лабат хушк аз дами сӯзони оҳ,',
            'Боз месозаш чу шамъ аз гиря тар. Гуфтам ба чашм!',
        ])
        self.assertEqual(len(changes), 2)

    def test_a_printed_list_number_is_not_text(self):
        text, changes = ctp.correct('Гар бар сари нафси худ амирӣ, мардӣ,',
                                    self.printed)
        self.assertEqual(text, 'Гар бар сари нафси худ амирӣ, мардӣ,')
        self.assertEqual(changes, [])

    def test_blank_lines_between_stanzas_stay(self):
        text, _ = ctp.correct('Фишонд аз савсану гул симу зар бод.\n\n'
                              'Зиҳӣ боде, ки раҳмат бод бар бод!',
                              self.printed)
        self.assertEqual(text.count('\n\n'), 1)

    def test_a_line_the_page_does_not_print_is_reported(self):
        with self.assertRaises(ctp.NotOnPage) as caught:
            ctp.correct('Ин мисраъ дар саҳифа нест.', self.printed)
        self.assertIn('Ин мисраъ', str(caught.exception))

    def test_first_line_titles_follow_the_first_line(self):
        self.assertTrue(ctp.is_first_line_title(
            'Фишонд аз савсану гул симу зар бод',
            'Фишонд аз савсану гул симу зар бод,'))
        self.assertFalse(ctp.is_first_line_title(
            'Гуфтам: «Ба чашм»', 'Ёр гуфт: Аз ғайри мо пӯшон назар.'))


if __name__ == '__main__':
    unittest.main()
