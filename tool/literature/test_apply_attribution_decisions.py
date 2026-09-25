"""Tests for apply_attribution_decisions.py (python3 -m unittest)."""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from apply_attribution_decisions import ACTIONS, apply  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')

PAGE = """\
    Восифӣ мегӯяд: Мавлоно Наҳвии Ҳиротӣ ҳаҷв карда буд ва
баъзе абёти он қасидаи ҳаҷвия ин аст:
       Саргаштатар зи ахтарам1 аз гардиши фалак,
       Толеъ намекунад мададу бахт-ҳеч як.
       Афтодаам ба хиттаи2 вайронае, ки ҳаст,
       Бодаш самуми3 оташеву хоки ӯ намак.

1
  Ахтар – ситора.
                                108
"""


VERSE_4 = ('Бихандад лола дар саҳро,\nБа сони чеҳраи Лайло.\n'
           'Бигиряд абр дар гардун,\nБа сони дидаи Маҷнун.')


def record(rid, author='vosifi', text=None):
    return {
        'id': rid, 'authorId': author, 'title': 'Қозии Сиистонро писаре буд',
        'type': 'poem', 'incipit': None, 'textTajik': text, 'textPersian': None,
        'persianScriptRepresentation': None, 'textStatus': 'needsReview',
        'editorialNotes': '',
        'primarySource': {'bookTitle': 'Адабиёти тоҷик', 'year': '2017',
                          'pageStart': 107, 'pageEnd': 107,
                          'sourceReference': 'docs/literature/pdfs/b.pdf',
                          'sourceImageVerified': True,
                          'sourceImagePath': 'x.png'},
        'rights': {'status': 'unknown'},
        'verification': {'evidenceLevel': 'needsReview'},
    }


def decision(action, **extra):
    base = {'id': 'w1', 'action': action, 'book': 'b', 'page': 108,
            'evidence': 'lead-in quoted'}
    base.update(extra)
    return base


class DropTest(unittest.TestCase):
    def test_drop_rejects_with_the_reason_and_the_page(self):
        works = [record('w1')]
        apply(works, [decision('drop', reason='folk_verse')])
        v = works[0]['verification']
        self.assertEqual(v['evidenceLevel'], 'rejected')
        self.assertEqual(v['rejectionReason'], 'extraction_false_positive:folk_verse')
        self.assertIn('p. 108', works[0]['editorialNotes'])
        self.assertIn('lead-in quoted', works[0]['editorialNotes'])


class RefileTest(unittest.TestCase):
    def test_refile_moves_the_record_and_keeps_it_unpublished(self):
        works = [record('w1')]
        apply(works, [decision('refile', authorId='rashidi')])
        self.assertEqual(works[0]['authorId'], 'rashidi')
        self.assertEqual(works[0]['verification']['evidenceLevel'], 'needsReview')
        self.assertIsNone(works[0]['textTajik'])

    def test_refile_with_publish_copies_the_verse_verbatim(self):
        works = [record('w1')]
        pages = {'b': ['', PAGE]}
        apply(works, [decision('refile', authorId='nahvi', publish={
            'pdfPage': 1, 'opening': 'Саргаштатар зи ахтарам аз гардиши фалак',
            'type': 'qasida'})], pages)
        w = works[0]
        self.assertEqual(w['authorId'], 'nahvi')
        self.assertEqual(w['type'], 'qasida')
        self.assertEqual(w['title'], 'Саргаштатар зи ахтарам аз гардиши фалак')
        self.assertEqual(w['textTajik'].split('\n'), [
            'Саргаштатар зи ахтарам аз гардиши фалак,',
            'Толеъ намекунад мададу бахт-ҳеч як.',
            'Афтодаам ба хиттаи вайронае, ки ҳаст,',
            'Бодаш самуми оташеву хоки ӯ намак.',
        ])
        self.assertEqual(w['primarySource']['pageStart'], 108)
        self.assertEqual(w['verification']['evidenceLevel'], 'primaryChecked')
        self.assertEqual(w['verification']['verificationMethod'],
                         'textbookPdfTextExtraction')

    def test_publishing_without_pages_fails_loudly(self):
        works = [record('w1')]
        with self.assertRaises(ValueError):
            apply(works, [decision('refile', authorId='nahvi', publish={
                'pdfPage': 1, 'opening': 'Саргаштатар зи ахтарам'})])

    def test_a_lone_bayt_is_never_published(self):
        page = PAGE.split('       Афтодаам')[0] + '\n                                108\n'
        works = [record('w1')]
        with self.assertRaises(ValueError):
            apply(works, [decision('refile', authorId='nahvi', publish={
                'pdfPage': 1, 'opening': 'Саргаштатар зи ахтарам аз гардиши фалак'})],
                {'b': ['', page]})


class RepairTest(unittest.TestCase):
    PAGE = """\
             Шер рам мекунад аз шӯриши девонаи ишқ,
             Дидаи дев бувад шамъи парихонаи ишқ.
             Куфру ислом дар ин роҳ ду нақши қадам аст,
             Каъба сангест зи девори санамхонаи ишқ.
      Ё худ дар ғазали дигар:
             Дар он саҳро, ки ваҳшат раҳравонро роҳбар бошад,
             Саводи манзил аз чашми ғизолон шӯхтар бошад.
                                53
"""

    def test_repair_retakes_the_text_from_the_page_for_the_same_poet(self):
        works = [record('w1', author='shavkat', text='glued\ntext')]
        works[0]['title'] = 'Шер рам мекунад аз шӯриши девонаи ишқ'
        apply(works, [decision('repair', publish={
            'pdfPage': 1, 'opening': 'Шер рам мекунад аз шӯриши девонаи ишқ'})],
            {'b': ['', self.PAGE]})
        w = works[0]
        self.assertEqual(w['authorId'], 'shavkat')
        self.assertEqual(w['textTajik'].split('\n')[-1],
                         'Каъба сангест зи девори санамхонаи ишқ.')
        self.assertEqual(len(w['textTajik'].split('\n')), 4)

    def test_repair_keeps_a_printed_title(self):
        works = [record('w1', author='shavkat', text='x')]
        apply(works, [decision('repair', publish={
            'pdfPage': 1, 'opening': 'Шер рам мекунад аз шӯриши девонаи ишқ',
            'title': 'Ишқ'})], {'b': ['', self.PAGE]})
        self.assertEqual(works[0]['title'], 'Ишқ')


class TruncateTest(unittest.TestCase):
    def test_truncate_cuts_at_the_prose_line_and_keeps_the_verse_above(self):
        works = [record('w1', author='rudaki', text=(
            'Басе нишастам ман бо акобиру аъён,\nБиёзмудамашон ошкору пинҳонӣ.\n'
            'Нахостам зи таманно, магар ки дастурӣ,\nНаёфтам зи атоҳо, магар пушаймонӣ.\n'
            'Марги Рӯдакии шоир барои аҳли адаби замонааш ва асрҳои\n'
            'Рӯдакӣ рафту монд ҳикмати ӯй,'))]
        works[0]['persianScriptRepresentation'] = 'x'
        apply(works, [decision('truncate',
                               at='Марги Рӯдакии шоир барои аҳли адаби замонааш ва асрҳои')])
        w = works[0]
        self.assertEqual(w['textTajik'].split('\n')[-1],
                         'Наёфтам зи атоҳо, магар пушаймонӣ.')
        self.assertEqual(len(w['textTajik'].split('\n')), 4)
        self.assertNotEqual(w['persianScriptRepresentation'], 'x')   # regenerated
        self.assertIn('p. 108', w['editorialNotes'])

    def test_truncate_moves_the_end_page_to_the_last_kept_line(self):
        works = [record('w1', text=VERSE_4 + '\nСатри дигар')]
        works[0]['primarySource'].update(pageStart=52, pageEnd=53)
        page52 = ''.join('        %s\n' % l for l in VERSE_4.split('\n')) + '                  52\n'
        page53 = '        Сатри дигар\n                  53\n'
        apply(works, [decision('truncate', at='Сатри дигар')], {'b': ['', page52, page53]})
        self.assertEqual(works[0]['primarySource']['pageEnd'], 52)

    def test_truncate_withdraws_a_record_left_with_a_single_bayt(self):
        works = [record('w1', text='Ту худ донӣ, ки вақти сарфарозӣ\nНахоҳам кард бо ту ишқбозӣ.\n'
                                   'Ширин савганд мехӯрад:\nСатри дигар')]
        works[0]['verification'] = {'evidenceLevel': 'primaryChecked'}
        works[0]['rights'] = {'status': 'sourceAttested', 'fullTextAllowed': True}
        apply(works, [decision('truncate', at='Ширин савганд мехӯрад:')])
        w = works[0]
        self.assertIsNone(w['textTajik'])
        self.assertEqual(w['verification']['evidenceLevel'], 'needsReview')
        self.assertEqual(w['textStatus'], 'needsReview')
        self.assertFalse(w['rights']['fullTextAllowed'])
        self.assertIn('single bayt', w['editorialNotes'])

    def test_truncate_needs_the_exact_line(self):
        works = [record('w1', text='А\nБ')]
        with self.assertRaises(ValueError):
            apply(works, [decision('truncate', at='В')])


class TitleOnlyTest(unittest.TestCase):
    def test_title_only_removes_the_borrowed_text_and_cites_the_title_page(self):
        works = [record('w1', author='loiq', text='Гуфт: «Аз як қатра ашки модарам,'),
                 record('src')]
        works[0]['persianScriptRepresentation'] = 'گفت'
        apply(works, [decision('titleOnly', page=296, sourceFrom='src')])
        w = works[0]
        self.assertEqual(w['authorId'], 'loiq')
        self.assertIsNone(w['textTajik'])
        self.assertIsNone(w['persianScriptRepresentation'])
        self.assertEqual(w['textStatus'], 'needsReview')
        self.assertEqual(w['primarySource']['pageStart'], 296)
        self.assertIsNone(w['primarySource']['sourceImagePath'])
        self.assertFalse(w['rights'].get('fullTextAllowed'))
        self.assertEqual(w['verification']['evidenceLevel'], 'needsReview')


class GuardTest(unittest.TestCase):
    def test_unknown_action_and_unknown_record_fail(self):
        with self.assertRaises(ValueError):
            apply([record('w1')], [decision('approve')])
        with self.assertRaises(KeyError):
            apply([record('w2')], [decision('drop', reason='x')])


class ShippedDecisionsTest(unittest.TestCase):
    """The decisions file in docs/literature is well formed."""

    def test_every_decision_names_its_page_and_evidence(self):
        path = os.path.join(ROOT, 'docs', 'literature',
                            'ATTRIBUTION_DECISIONS_2026-09-25.json')
        with open(path, encoding='utf-8') as f:
            decisions = json.load(f)['decisions']
        self.assertGreaterEqual(len(decisions), 17)
        for d in decisions:
            self.assertIn(d['action'], ACTIONS)
            self.assertTrue(d['evidence'])
            self.assertIsInstance(d['page'], int)
            if d['action'] == 'drop':
                self.assertTrue(d['reason'])
            if d['action'] == 'refile':
                self.assertTrue(d['authorId'])


if __name__ == '__main__':
    unittest.main()
