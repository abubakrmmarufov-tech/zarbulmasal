"""Tests for apply_attribution_decisions.py (python3 -m unittest)."""
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from apply_attribution_decisions import apply  # noqa: E402

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
        self.assertEqual(len(decisions), 17)
        for d in decisions:
            self.assertIn(d['action'], ('drop', 'refile', 'titleOnly'))
            self.assertTrue(d['evidence'])
            self.assertIsInstance(d['page'], int)
            if d['action'] == 'drop':
                self.assertTrue(d['reason'])
            if d['action'] == 'refile':
                self.assertTrue(d['authorId'])


if __name__ == '__main__':
    unittest.main()
