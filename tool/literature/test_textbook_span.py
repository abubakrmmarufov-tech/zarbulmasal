"""Tests for textbook_span.py (python3 -m unittest)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from textbook_span import fix_lookalikes, take_span  # noqa: E402

PAGE_A = """\
    Шоир чунин мегӯяд:
Нури чашми Ватан, эй бачаи афғон, афсӯс,
Дили ман доғ шуд аз дасти ту, эй ҷон, афсӯс.
Чанд гӯям, ба ту фарзанди мусалмон, афсӯс,
                                                  245
"""
PAGE_B = """\
      Мамлакатро ба ту сад гуна ниёз аст, ҳанӯз,
      Ай писар, кор накардан ба ту ор аст, биё!

                     Луғат
Оваҳ – задае, ки аз дарду алам ба забон меояд.
"""


class TakeSpanTest(unittest.TestCase):
    def test_a_flush_left_poem_is_taken_across_the_page_break(self):
        taken, why = take_span(['', PAGE_A, PAGE_B], 1,
                               'Нури чашми Ватан, эй бачаи афғон, афсӯс,',
                               'Ай писар, кор накардан ба ту ор аст, биё!')
        self.assertIsNone(why)
        lines, first, last = taken
        self.assertEqual((first, last), (1, 2))
        self.assertEqual(len(lines), 5)
        self.assertEqual(lines[3], 'Мамлакатро ба ту сад гуна ниёз аст, ҳанӯз,')
        self.assertNotIn('', lines)        # a page break is not a stanza break

    def test_footnotes_at_the_foot_of_a_page_are_skipped(self):
        page = PAGE_A.replace('                                                  245',
                              '1 Бача – писар.\n                                                  245')
        taken, why = take_span(['', page, PAGE_B], 1,
                               'Нури чашми Ватан, эй бачаи афғон, афсӯс,',
                               'Ай писар, кор накардан ба ту ор аст, биё!')
        self.assertIsNone(why)
        self.assertNotIn('1 Бача – писар.', taken[0])
        self.assertEqual(len(taken[0]), 5)

    def test_stars_between_stanzas_become_a_stanza_break(self):
        page = PAGE_A.replace('Дили ман', '                ***\nДили ман')
        taken, _ = take_span(['', page], 1,
                             'Нури чашми Ватан, эй бачаи афғон, афсӯс,',
                             'Чанд гӯям, ба ту фарзанди мусалмон, афсӯс,')
        self.assertEqual(taken[0][1], '')
        self.assertNotIn('***', taken[0])

    def test_a_verse_line_with_a_dash_is_verse_when_indented_like_the_poem(self):
        page = ('          Дӯстон! Фоҷиаи сахт биомад ба сарам,\n'
                '          Хабар ин аст, ки бо теғи ситам кушта шудаст,\n'
                '          Додарам – қуввати рӯҳу дилу қути ҷигарам.\n'
                'Додар – бародари хурд.\n')
        taken, why = take_span(['', page], 1, 'Дӯстон! Фоҷиаи сахт биомад ба сарам,',
                               'Додарам – қуввати рӯҳу дилу қути ҷигарам.')
        self.assertIsNone(why)
        self.assertEqual(len(taken[0]), 3)
        taken, why = take_span(['', page], 1, 'Дӯстон! Фоҷиаи сахт биомад ба сарам,',
                               'Додар – бародари хурд.')
        self.assertIn('glossary', why)

    def test_a_span_that_takes_in_a_glossary_is_refused(self):
        taken, why = take_span(['', PAGE_A, PAGE_B], 1,
                               'Нури чашми Ватан, эй бачаи афғон, афсӯс,',
                               'Оваҳ – задае, ки аз дарду алам ба забон меояд.')
        self.assertIsNone(taken)
        self.assertIn('label', why)

    def test_a_missing_opening_is_reported(self):
        taken, why = take_span(['', PAGE_A], 1, 'Ин сатр дар саҳифа нест, албатта',
                               'Дили ман доғ шуд аз дасти ту, эй ҷон, афсӯс.')
        self.assertIsNone(taken)
        self.assertEqual(why, 'the opening line is not on the page')

    def test_a_missing_closing_is_reported(self):
        taken, why = take_span(['', PAGE_A], 1,
                               'Нури чашми Ватан, эй бачаи афғон, афсӯс,',
                               'Ин сатр дар саҳифа нест, албатта')
        self.assertIsNone(taken)
        self.assertIn('closing', why)

    def test_a_long_prose_line_inside_is_refused(self):
        page = PAGE_A.replace(
            'Дили ман', 'Ин сатри наср аст, ки аз панҷоҳу ҳашт ҳарф дарозтар аст ва шеър нест.\nДили ман')
        taken, why = take_span(['', page], 1,
                               'Нури чашми Ватан, эй бачаи афғон, афсӯс,',
                               'Чанд гӯям, ба ту фарзанди мусалмон, афсӯс,')
        self.assertIsNone(taken)
        self.assertIn('too long', why)


class LookalikeTest(unittest.TestCase):
    def test_latin_letters_inside_a_cyrillic_word_become_cyrillic(self):
        fixed, changes = fix_lookalikes('КИШТИНИШACTАГОНЕМ ва Xалоси')
        self.assertEqual(fixed, 'КИШТИНИШАСТАГОНЕМ ва Халоси')
        self.assertEqual(changes, [('КИШТИНИШACTАГОНЕМ', 'КИШТИНИШАСТАГОНЕМ'),
                                   ('Xалоси', 'Халоси')])

    def test_a_word_of_look_alikes_in_a_cyrillic_line_becomes_cyrillic(self):
        fixed, _ = fix_lookalikes('Чашма гap cap шавад, чӣ суд аз пеш')
        self.assertEqual(fixed, 'Чашма гар сар шавад, чӣ суд аз пеш')
        fixed, _ = fix_lookalikes('Зи capҳou азизон уфтода.')
        self.assertEqual(fixed, 'Зи сарҳои азизон уфтода.')

    def test_lone_letters_roman_numerals_and_latin_text_are_left_alone(self):
        for text in ('асри X, саҳ. 5', 'дар асри ХIV', 'maorif.tj ISBN',
                     '$A) Рӯдакӣ $B) Фирдавсӣ'):
            fixed, changes = fix_lookalikes(text)
            self.assertEqual((fixed, changes), (text, []), text)


if __name__ == '__main__':
    unittest.main()
