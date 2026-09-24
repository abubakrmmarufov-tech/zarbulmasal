"""Tests for the textbook verse extractor (python3 -m unittest)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from textbook_verse import (  # noqa: E402
    clean_line, decode_legacy, extract_poem, reads_as_verse, sentence_case,
    split_heading, split_series,
)

PAGE = """\
    дигар ба ў ёрї дод. Ман бо
шунидани он ѓазал дар он суруд:

                  ХАНДАИ ЛОЛА
        Бихандад лола дар сањро
        Ба сони чењраи Лайло1.
        Бигиряд абр дар гардун
        Ба сони дидаи Маљнун2.

   Лайло – Лайлї.
                                                      52
"""


VERSE = (
    '        Бихандад лола дар саҳро\n'
    '        Ба сони чеҳраи Лайло.\n'
    '        Бигиряд абр дар гардун\n'
    '        Ба сони дидаи Маҷнун.\n'
)


class DecodeTest(unittest.TestCase):
    def test_maps_legacy_letters_one_to_one(self):
        self.assertEqual(decode_legacy('њ ќ љ ѓ ў ї Њ'), 'ҳ қ ҷ ғ ӯ ӣ Ҳ')
        self.assertEqual(decode_legacy('Бухоро'), 'Бухоро')


class ExtractTest(unittest.TestCase):
    def test_takes_the_verse_verbatim_with_its_heading(self):
        pages = ['', decode_legacy(PAGE)]
        title, lines, last, first = extract_poem(pages, 1, 'Бихандад лола дар саҳро')
        self.assertEqual(title, 'ХАНДАИ ЛОЛА')
        self.assertEqual(lines, [
            'Бихандад лола дар саҳро',
            'Ба сони чеҳраи Лайло.',      # footnote marker removed
            'Бигиряд абр дар гардун',
            'Ба сони дидаи Маҷнун.',
        ])
        self.assertEqual((first, last), (1, 1))

    def test_prose_is_not_verse(self):
        prose = ['Аз Абулқосим Лоҳутӣ мероси адабии зиёд',
                 'боқӣ мондааст. Маҷмӯаи шеърҳои шоир, аз',
                 'ҷумла, ба номҳои «Девон»',
                 'чоп шудааст']
        self.assertFalse(reads_as_verse(prose))

    def test_a_quoted_bayt_is_not_a_poem(self):
        self.assertFalse(reads_as_verse(['Ман аз бегонагон ҳаргиз нанолам,',
                                         'Ки бо ман ҳар чӣ кард, он ошно кард.']))

    def test_a_doubled_footnote_marker_is_removed(self):
        self.assertEqual(clean_line('Сояи тозиёнааш ба кафал158158.'),
                         'Сояи тозиёнааш ба кафал.')
        self.assertEqual(clean_line('Соли 1938.'), 'Соли 1938.')

    def test_the_date_under_a_poem_is_not_verse(self):
        page = VERSE + '        Соли 1938.\n'
        _, lines, _, _ = extract_poem(['', page], 1, 'Бихандад лола дар саҳро')
        self.assertEqual(lines[-1], 'Ба сони дидаи Маҷнун.')

    def test_a_part_label_is_skipped(self):
        page = '             ХАНДАИ ЛОЛА\n           (фасли нахуст)\n' + VERSE
        title, lines, _, _ = extract_poem(['', page], 1, 'Бихандад лола дар саҳро')
        self.assertEqual(title, 'ХАНДАИ ЛОЛА')
        self.assertEqual(lines[0], 'Бихандад лола дар саҳро')

    def test_prose_at_the_foot_of_the_previous_page_is_not_carried(self):
        previous = ('ҷиддан машғул шуда, худ ба шеърнависӣ мепардозад.\n'
                    '    Пайрав соли 1920 шоҳиди инқилоби Бухоро гардида, соли\n'
                    '1921 ҳамроҳи тағояш ба Афғонистон сафар намуд. Марсияи\n'
                    'устод Айнӣ дар вафоти Пайрав ҷонгудоз ва дардовар аст:\n'
                    '1 Ҳошим Шоиқ – шоир.\n\n                     132\n')
        _, lines, _, first = extract_poem(['', previous, VERSE], 2,
                                          'Бихандад лола дар саҳро')
        self.assertEqual(first, 2)
        self.assertEqual(lines[0], 'Бихандад лола дар саҳро')

    def test_verse_ending_a_page_above_a_footnote_is_carried(self):
        previous = ('        Бихандад лола дар саҳро\n'
                    '        Ба сони чеҳраи Лайло1.\n'
                    '1 Лайло – Лайлӣ.\n\n                     52\n')
        rest = ('        Бигиряд абр дар гардун\n'
                '        Ба сони дидаи Маҷнун.\n')
        _, lines, _, first = extract_poem(['', previous, rest], 2,
                                          'Бигиряд абр дар гардун')
        self.assertEqual(first, 1)
        self.assertEqual(len(lines), 4)


class SeriesAndHeadingTest(unittest.TestCase):
    def test_rubais_separated_by_stars_become_separate_poems(self):
        block = ['Як,', 'Ду,', 'Се,', 'Чор.', '***', 'Панҷ,', 'Шаш,', 'Ҳафт,', 'Ҳашт.']
        self.assertEqual(len(split_series(block)), 2)

    def test_genre_group_label_is_split_off(self):
        self.assertEqual(
            split_heading('АЗ ҚАСИДАҲО АНДАР ИН ДАВРОН МАҶӮ РОҲАТ'),
            ('qasida', 'АНДАР ИН ДАВРОН МАҶӮ РОҲАТ'),
        )
        self.assertEqual(split_heading('ҚИТЪА'), ('fragment', None))

    def test_sentence_case_keeps_names(self):
        names = {'исмоили сомонӣ', 'ҳирот'}
        self.assertEqual(sentence_case('БА ИСМОИЛИ СОМОНӢ', names),
                         'Ба Исмоили Сомонӣ')
        self.assertEqual(sentence_case('АЗ ДОСТОНИ «ЛАЙЛӢ ВА МАҶНУН»'),
                         'Аз достони «Лайлӣ ва Маҷнун»')
        self.assertEqual(sentence_case('Баҳори нав'), 'Баҳори нав')


class AttributionTest(unittest.TestCase):
    def test_a_verse_introduced_under_another_poets_name_is_not_attributed(self):
        from extract_textbook_poems import quoted_from_other_poet
        names = {'абуабдуллоҳи рӯдакӣ': 'rudaki', 'рӯдакӣ': 'rudaki',
                 'бузургмеҳр': 'buzurgmehr', 'айнӣ': 'ayni'}
        lead = 'манзум ё мансури худ ишора намояд.\nМонанди рубоии зери Абуабдуллоҳи Рӯдакӣ:\n\n     21\n'
        self.assertTrue(quoted_from_other_poet(lead, 'buzurgmehr', names))
        self.assertFalse(quoted_from_other_poet(lead, 'rudaki', names))
        self.assertFalse(quoted_from_other_poet('Рӯдакӣ мегӯяд.', 'buzurgmehr', names))
        self.assertTrue(quoted_from_other_poet(
            'Марсияи устод Айнӣ дар вафоти Пайрав ҷонгудоз ва дардовар аст:',
            'payrav', names))


if __name__ == '__main__':
    unittest.main()
