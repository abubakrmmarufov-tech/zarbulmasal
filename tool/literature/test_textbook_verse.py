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

    def test_footnote_markers_the_text_layer_glues_to_words_are_removed(self):
        # In the gap between two words the superscript takes the space.
        self.assertEqual(clean_line('Аз басити91марғзор афзун бувад.'),
                         'Аз басити марғзор афзун бувад.')
        self.assertEqual(clean_line('Бар афсонааш гашт наҳмор 27шод.'),
                         'Бар афсонааш гашт наҳмор шод.')
        self.assertEqual(clean_line('Мунъиме,6 к-ӯ дошт меҳмонро наку,'),
                         'Мунъиме, к-ӯ дошт меҳмонро наку,')
        self.assertEqual(clean_line('«Муъминам, «Янзур бинуриллаҳ» 112'),
                         '«Муъминам, «Янзур бинуриллаҳ»')
        self.assertEqual(clean_line('Нишаст аз бари бодпое 76 чу гард,'),
                         'Нишаст аз бари бодпое чу гард,')

    def test_a_digit_three_for_ze_is_read_as_ze(self):
        self.assertEqual(clean_line('3-он чӣ бояд, набуд чизе кам.'),
                         'З-он чӣ бояд, набуд чизе кам.')
        self.assertEqual(clean_line('Дар синфи 3-юм хондем.'),
                         'Дар синфи 3-юм хондем.')

    def test_an_opening_with_a_footnote_marker_is_found(self):
        page = ('                          ПАЙҒОМИ ДӮСТ\n'
                '    Марҳабо, эй пайки1 муштоқон, бидеҳ пайғоми дӯст,\n'
                '    То кунад ҷон аз сари рағбат фидои номи дӯст.\n'
                '    Волаву шайдост доим ҳамчу булбул дар қафас,\n'
                '    Тӯтии табъам зи ишқи шаккару бодоми дӯст.\n')
        result = extract_poem(['', page],
                              1, 'Марҳабо, эй пайки1 муштоқон, бидеҳ пайғоми дӯст,')
        self.assertIsNotNone(result)
        self.assertEqual(result[1][0],
                         'Марҳабо, эй пайки муштоқон, бидеҳ пайғоми дӯст,')

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


class ShallowLeadInTest(unittest.TestCase):
    """A one-line prose sentence ending in ':' is set with a shallower
    indent than the verse around it; it separates two quotations."""
    PAGE = (
        '             Ёрам ҳар гоҳ дар сухан меояд,\n'
        '             Бӯйи аҷабеш аз даҳан меояд.\n'
        '             Ин бӯйи қаранфул аст, ё накҳати гул,\n'
        '             Ё роиҳаи мушки Хутан меояд?\n'
        '\n'
        '      Бедил соли 1665 аз Биҳор ба шаҳри Деҳлӣ меояд:\n'
        '             Аз мулки Биҳор сӯйи Деҳлӣ,\n'
        '             Чун ашк равон шудем бекас.\n'
    )

    def test_the_block_ends_before_the_shallow_lead_in(self):
        _, lines, _, _ = extract_poem(['', self.PAGE], 1, 'Ёрам ҳар гоҳ дар сухан меояд')
        self.assertEqual(lines[-1], 'Ё роиҳаи мушки Хутан меояд?')

    def test_the_next_quotation_does_not_rewind_past_it(self):
        _, lines, _, _ = extract_poem(['', self.PAGE], 1, 'Аз мулки Биҳор сӯйи Деҳлӣ')
        self.assertEqual(lines[0], 'Аз мулки Биҳор сӯйи Деҳлӣ,')

    def test_verse_introducing_speech_at_the_same_indent_stays(self):
        page = ('        Бигуфт ӯ ба шоҳ ин сухан дар замон:\n'
                '        «Бихандад лола дар саҳро,\n'
                '        Ба сони чеҳраи Лайло.\n'
                '        Бигиряд абр дар гардун\n'
                '        Ба сони дидаи Маҷнун».\n')
        _, lines, _, _ = extract_poem(['', page], 1, '«Бихандад лола дар саҳро')
        self.assertEqual(lines[0], 'Бигуфт ӯ ба шоҳ ин сухан дар замон:')


class CenteredTitleTest(unittest.TestCase):
    PAGE = (
        '                   Духтарони Дарвоз\n'
        '           Мевазад боди тозаву форам,\n'
        '           Барги гулҳо ба ҷунбишанд аз он.\n'
        '           Мешавад паҳн дар фазо ҳар дам\n'
        '           Ин суруди қадими кӯҳистон:\n'
        '           «Рӯзу шаб рӯди Панҷи ноором\n'
        '           Мезанад доду мезанад фарёд.\n'
    )

    def test_a_centred_mixed_case_title_is_not_a_verse_line(self):
        _, lines, _, _ = extract_poem(['', self.PAGE], 1, 'Мевазад боди тозаву форам')
        self.assertEqual(lines[0], 'Мевазад боди тозаву форам,')
        self.assertIn('Ин суруди қадими кӯҳистон:', lines)   # verse, same indent


class FootnoteMarkerLineTest(unittest.TestCase):
    def test_a_numbered_footnote_line_does_not_cut_the_last_verse_line(self):
        page = ('            Раҳонам зи ғам ҳар ғамандешро,\n'
                '            Кунам марҳаме ҳар дили решро.\n'
                '            Чу шоҳ аз раийят бувад комхоҳ,\n'
                '            Гадо бошад андар ҳақиқат, на шоҳ!\n'
                '1.\n'
                '   воя – ҳоҷат, мурод\n')
        _, lines, _, _ = extract_poem(['', page], 1, 'Раҳонам зи ғам ҳар ғамандешро')
        self.assertEqual(lines[-1], 'Гадо бошад андар ҳақиқат, на шоҳ!')


class IndentedParagraphTest(unittest.TestCase):
    def test_an_indented_paragraph_opening_is_not_verse(self):
        page = ('        Дил ба ҷуз васли ту бо ҳеч тасалло нашавад,\n'
                '        Нест дар ҳаҷри ту орому қарорам, бинишин.\n'
                '        Дар ду олам набувад ғайри ту ёрам, бинишин.\n'
                '        Омадӣ, ҳарфи ниҳонӣ ба ту дорам, бинишин.\n'
                '    Яке аз ҷанбаҳои ҳунарии ғазалиёти Абдулқодирхоҷаи Савдо\n'
                '    дарёфту корбасти радиф аст ва ҳунари ӯ дар истифодаи радиф ба\n')
        _, lines, _, _ = extract_poem(['', page], 1, 'Дил ба ҷуз васли ту бо ҳеч тасалло')
        self.assertEqual(lines[-1], 'Омадӣ, ҳарфи ниҳонӣ ба ту дорам, бинишин.')


class ProseAtVerseIndentTest(unittest.TestCase):
    def test_prose_after_the_poem_at_the_same_indent_keeps_the_last_line(self):
        page = ('     Ҳазратам, аз гушнагӣ мурдам, ба ман нунам бидеҳ,\n'
                '     Кофирам, гӯям агар инам бидеҳ, унам бидеҳ.\n'
                '     Гулханиро ай қатори баччамардон кам мадон,\n'
                '     Фӯтаву шофам бидеҳ, аспам бидеҳ, тунам бидеҳ.\n'
                '     Хусусан, бори ғоявию мавзуӣ ва маънавию мундариҷавӣ бар дӯш\n'
                'доштани радиф дар ғазали боло аз он ҳам маълум мегардад, ки дар\n')
        _, lines, _, _ = extract_poem(['', page], 1, 'Ҳазратам, аз гушнагӣ мурдам')
        self.assertEqual(lines[-1], 'Фӯтаву шофам бидеҳ, аспам бидеҳ, тунам бидеҳ.')


class LeadInAtPageTopTest(unittest.TestCase):
    def test_a_lead_in_opening_the_next_page_ends_the_poem(self):
        page1 = ('               Чу мулки ҷаҳонат мусаллам шавад,\n'
                 '               Дар он поя пойи ту муҳкам шавад,\n'
                 '               Чӣ бошад ба пеши ту миқдори ман?\n'
                 '               Чӣ равнақ пазирад зи ту кори ман?\n'
                 '\n'
                 '                                253\n')
        page2 = ('   Искандар чунин ҷавоб медиҳад:\n'
                 '\n'
                 '          Бигуфто, ки бошад туро бартарӣ\n'
                 '          Бари ман ба миқдори фармонбарӣ...\n')
        _, lines, last, _ = extract_poem(['', page1, page2], 1, 'Чу мулки ҷаҳонат мусаллам шавад')
        self.assertEqual(lines[-1], 'Чӣ равнақ пазирад зи ту кори ман?')
        self.assertEqual(last, 1)


class MarginShiftTest(unittest.TestCase):
    def test_a_lead_in_on_a_page_with_a_wider_margin_ends_the_poem(self):
        page1 = ('         Ман чунон аз ишқи гул мустағрақам,\n'
                 '         К-аз вуҷуди хеш маҳви мутлақам.\n'
                 '\n'
                 '                                247\n')
        page2 = ('           Дар сарам аз ишқи гул савдо бас аст,\n'
                 '           З-он ки маъшуқам гули раъно бас аст.\n'
                 '      Ҳудҳуд ба ӯ ҷавоб медиҳад ва он ин аст:\n'
                 '           Ҳудҳудаш гуфт: «Ай ба сурат монда боз,\n')
        _, lines, last, _ = extract_poem(['', page1, page2], 1, 'Ман чунон аз ишқи гул мустағрақам')
        self.assertEqual(lines[-1], 'З-он ки маъшуқам гули раъно бас аст.')
        self.assertEqual(last, 2)


class PoetNamesTest(unittest.TestCase):
    POETS = [
        {'id': 'jomi', 'canonicalName': 'Абдурраҳмони Ҷомӣ', 'aliases': []},
        {'id': 'ahmad', 'canonicalName': 'Аҳмади Ҷомӣ', 'aliases': []},
        {'id': 'tursun', 'canonicalName': 'Мирзо Турсунзода', 'aliases': []},
        {'id': 'ghaffor', 'canonicalName': 'Ғаффор Мирзо', 'aliases': []},
        {'id': 'dar', 'canonicalName': 'Дар', 'aliases': [],
         'recordStatus': 'rejected'},
        {'id': 'rudaki', 'canonicalName': 'Абӯабдуллоҳи Рӯдакӣ', 'aliases': []},
    ]

    def names(self):
        from extract_textbook_poems import poet_names
        return poet_names(self.POETS)

    def test_rejected_records_give_no_names(self):
        self.assertNotIn('дар', self.names())

    def test_a_shared_last_word_names_no_one(self):
        names = self.names()
        self.assertNotIn('ҷомӣ', names)          # two poets: ambiguous
        self.assertNotIn('мирзо', names)         # a title in another name
        self.assertEqual(names['абдурраҳмони ҷомӣ'], 'jomi')
        self.assertEqual(names['аҳмади ҷомӣ'], 'ahmad')

    def test_a_unique_last_word_names_its_poet(self):
        self.assertEqual(self.names()['рӯдакӣ'], 'rudaki')

    def test_an_ordinary_word_does_not_flag_a_lead_in(self):
        from extract_textbook_poems import quoted_from_other_poet
        lead = 'Дар ин бора худи адиб чунин мегӯяд:'
        self.assertFalse(quoted_from_other_poet(lead, 'jomi', self.names()))


class LeadInTest(unittest.TestCase):
    def test_folk_songs_elegies_and_examples_are_not_the_poets_own(self):
        from extract_textbook_poems import lead_in_disqualifies
        self.assertTrue(lead_in_disqualifies(
            'Мардуми одии диёр ба ӯ меҳру муҳаббати беандоза доранд ва дар '
            'борааш нақлу ривоятҳои рангин, шеъру таронаҳои намакин эҷод '
            'кардаанд. Ҳоло муште аз он хирвор:'))
        self.assertTrue(lead_in_disqualifies(
            'Мавлоно Комӣ дар вафоти Ҷомӣ марсияе эҷод кард. Чанд байт аз он марсия:'))
        self.assertTrue(lead_in_disqualifies('Истиора низ як навъи маҷоз аст. Мисолҳо:'))
        self.assertTrue(lead_in_disqualifies('... Баюшки – баю... Тарҷума:'))
        self.assertFalse(lead_in_disqualifies(
            'Ба ин нукта худи Ҷомӣ ишорат карда мегӯяд:'))

    def test_a_connector_ends_the_quotation(self):
        page = VERSE + '        Ё худ:\n' + VERSE
        _, lines, _, _ = extract_poem(['', page], 1, 'Бихандад лола дар саҳро')
        self.assertEqual(len(lines), 4)


class ChapterRangeTest(unittest.TestCase):
    def test_a_page_belongs_to_the_one_poet_whose_chapter_covers_it(self):
        from scan_textbook_chapters import chapter_ranges, owner
        poets = [
            {'id': 'nosir', 'biographySource': '«Адабиёти тоҷик», синфи 8 (2026), с. 179–200.'},
            {'id': 'khayyom', 'biographySource': '«Адабиёти тоҷик», синфи 8 (2026), с. 201–211.'},
            {'id': 'mention', 'biographySource': '«Адабиёти тоҷик», синфи 8 (2026), с. 35, 190.'},
            {'id': 'wide', 'biographySource': '«Адабиёти тоҷик», синфи 9 (2026), с. 10–40; синфи 8 (2026), с. 205–207'},
        ]
        ranges = chapter_ranges(poets)
        self.assertEqual(owner(ranges, 8, 186)['id'], 'nosir')
        self.assertIsNone(owner(ranges, 8, 35))          # a mention, not a chapter
        self.assertIsNone(owner(ranges, 8, 206))         # two chapters claim it
        self.assertEqual(owner(ranges, 8, 210)['id'], 'khayyom')

    def test_an_elegy_written_on_the_poets_death_is_not_his(self):
        from extract_textbook_poems import lead_in_disqualifies
        self.assertTrue(lead_in_disqualifies(
            'Мир Ғуломалихони Озод дар вафоти Бедил қитъаи зеринро сурудааст:'))


if __name__ == '__main__':
    unittest.main()
