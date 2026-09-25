"""Tests for poet_coverage.py (python3 -m unittest)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from poet_coverage import (  # noqa: E402
    chapter_heads, chapter_pages, cited_pages, coverage, flush_runs,
    markdown, page_ranges, suggest,
)

HEAD = """\
                    ДАҚИҚӢ
    Абумансур Муҳаммад бинни Аҳмади Дақиқӣ дар Балх ба дунё омадааст ва
дар ҷавонӣ ба шеър рӯй овардааст. Шоир чунин мегӯяд:
          Шаби сиёҳ бад-он зулфакони ту монад,
          Сапедрӯз ба покии рухони ту монад.
          Бинафша тоза ба бӯйи сари ту монад,
          Ки сарвро қаду боло бад-они ту монад.
                                   65
"""
NEXT = """\
                    АБУЛҚОСИМИ ФИРДАВСӢ
               (940 – байни солҳои 1009-1020)
    Фирдавсӣ дар Тӯс таваллуд шудааст ва тамоми умри худро ба шеър
бахшидааст.
                                   66
"""
NAMES = {'дақиқӣ': 'daqiqi', 'абулқосими фирдавсӣ': 'firdawsi'}


class CitedPagesTest(unittest.TestCase):
    def test_ranges_and_single_pages_are_read_per_grade(self):
        poet = {'biographySource': '«Адабиёти тоҷик», синфи 8 (2026), с. 35, 77–80; '
                                   'синфи 5 (2017), с. 56.'}
        self.assertEqual(cited_pages(poet), {8: {35, 77, 78, 79, 80}, 5: {56}})

    def test_page_ranges_are_written_compactly(self):
        self.assertEqual(page_ranges([1, 2, 3, 7, 9, 10]), '1–3, 7, 9–10')


class ChapterTest(unittest.TestCase):
    def test_a_name_heading_starts_a_chapter_until_the_next_one(self):
        pages = ['', HEAD, NEXT]
        heads = chapter_heads(pages, NAMES)
        self.assertEqual(heads, [(1, 'daqiqi'), (2, 'firdawsi')])
        self.assertEqual(chapter_pages('daqiqi', heads, pages), {65})

    def test_speaker_labels_of_a_play_start_no_chapter(self):
        play = 'ДАҚИҚӢ\nСалом!\nСУРУШ\nАлейк.\nДАҚИҚӢ\nЧӣ гап?\n'
        self.assertEqual(chapter_heads(['', play], NAMES), [])


class FlushRunTest(unittest.TestCase):
    def test_short_punctuated_lines_set_flush_left_are_verse(self):
        page = ('Нури чашми Ватан, эй бачаи афғон, афсӯс,\n'
                'Дили ман доғ шуд аз дасти ту, эй ҷон, афсӯс.\n'
                'Чанд гӯям, ба ту фарзанди мусалмон, афсӯс,\n'
                'Ба ту эй унсури афсурдаи, баҷон афсӯс.\n')
        self.assertEqual(flush_runs(page), [('Нури чашми Ватан, эй бачаи афғон, афсӯс,',
                                             'Ба ту эй унсури афсурдаи, баҷон афсӯс.')])

    def test_prose_is_not_a_flush_run(self):
        page = ('Ин матни наср аст, ки сатрҳояш дароз ва бе қофия буда,\n'
                'дар як сафҳа пай дар пай меоянд ва шеър нестанд ва на-\n')
        self.assertEqual(flush_runs(page), [])


class CoverageTest(unittest.TestCase):
    def test_a_poet_gets_chapter_blocks_counts_and_a_verdict(self):
        poets = [{'id': 'daqiqi', 'canonicalName': 'Дақиқӣ',
                  'biographySource': 'синфи 8 (2026), с. 65'},
                 {'id': 'absent', 'canonicalName': 'Номаълум',
                  'biographySource': ''}]
        works = [{'id': 'n1', 'authorId': 'daqiqi', 'title': 'Ин сатр дар саҳифа нест, албатта',
                  'primarySource': {'sourceReference': 'docs/literature/pdfs/b 8.pdf',
                                    'pageStart': 65},
                  'verification': {'evidenceLevel': 'needsReview'}}]
        rows = coverage(poets, works, {'b 8': ['', HEAD, NEXT]},
                        {'absent': {'verdict': 'd', 'note': 'Not in these books.'}})
        daqiqi, absent = rows
        self.assertEqual(daqiqi['chapters'], {8: [65]})
        self.assertEqual((daqiqi['blocks'], daqiqi['unpublishedBlocks']), (1, 1))
        self.assertEqual(daqiqi['reasons'],
                         {'the title is not printed on or near the cited page': 1})
        self.assertEqual(daqiqi['verdict'], 'a?')
        self.assertEqual(absent['verdict'], 'd')
        table = markdown(rows)
        self.assertIn('| Дақиқӣ | 8: 65 | 1 (1) | 0 |', table)
        self.assertIn('**d** no chapter in these books. Not in these books.', table)

    def test_suggestions(self):
        self.assertEqual(suggest({}, [], [], 0), 'd')
        self.assertEqual(suggest({8: [1]}, [], [], 0), 'c')
        self.assertEqual(suggest({8: [1]}, [1], [], 0), 'b')
        self.assertEqual(suggest({8: [1]}, [1], [1], 0), 'a')


if __name__ == '__main__':
    unittest.main()
