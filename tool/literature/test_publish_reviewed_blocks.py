"""Tests for publish_reviewed_blocks.py (python3 -m unittest)."""
import glob
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from publish_reviewed_blocks import publish  # noqa: E402

ROOT = os.path.join(os.path.dirname(__file__), '..', '..')

PAGE = """\
    Шоир дар ғазали зерин аз рӯзгори худ шикоят
менамояд:
           Дар баҳор аз фоқа ранги заъфарон бошад маро,
           Пораҳо бар дӯш аз барги хазон бошад маро.
           Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон,
           Рӯзу шаб шармандагӣ аз обу нон бошад маро.
    Дар ҳамин маврид чунон ки
гуфтаанд:
           Пеши он кас, ки ихтиёраш ҳаст,
           Халқ беихтиёр меоянд.
           Гар набошад ба ӯ умеди касе,
           Бар дараш бо чӣ кор меоянд?
                                   68
"""

REF = 'docs/literature/pdfs/b.pdf'


def published(text):
    return {
        'id': 'old', 'authorId': 'x', 'textTajik': text,
        'primarySource': {'bookTitle': 'Адабиёти тоҷик', 'year': '2017',
                          'sourceReference': REF, 'pageStart': 1, 'pageEnd': 1},
        'verification': {'evidenceLevel': 'primaryChecked',
                         'verificationMethod': 'textbookPdfTextExtraction'},
    }


def block(opening, decision='accept', **extra):
    base = {'book': 'b', 'pdfPage': 1, 'page': 68, 'opening': opening,
            'decision': decision, 'authorId': 'sayyido',
            'reason': 'the lead-in names the poet'}
    base.update(extra)
    return base


class PublishTest(unittest.TestCase):
    def test_an_accepted_block_is_published_verbatim_from_the_page(self):
        works = [published('Бихандад лола дар саҳро')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(skipped, [])
        [record] = added
        self.assertEqual(record['authorId'], 'sayyido')
        self.assertEqual(record['textTajik'].split('\n')[0],
                         'Дар баҳор аз фоқа ранги заъфарон бошад маро,')
        self.assertEqual(len(record['textTajik'].split('\n')), 4)
        self.assertEqual(record['primarySource']['pageStart'], 68)
        self.assertEqual(record['primarySource']['bookTitle'], 'Адабиёти тоҷик')
        self.assertEqual(record['verification']['evidenceLevel'], 'primaryChecked')
        self.assertIn('reviewed by hand', record['editorialNotes'])
        self.assertIn(record, works)

    def test_a_block_is_cut_before_a_prose_lead_in_inside_it(self):
        page = PAGE.replace('    Дар ҳамин маврид чунон ки\nгуфтаанд:\n',
                            '           Рӯзу шаб шармандагӣ, аз обу нон,\n'
                            '           Ин ҳама бечорагӣ аз обу нон.\n'
                            '    Шоир чунин ҷавоб медиҳад:\n')
        works = [published('x')]
        added, _ = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', page]})
        text = added[0]['textTajik']
        self.assertNotIn('Шоир чунин ҷавоб медиҳад:', text)
        self.assertEqual(text.split('\n')[-1], 'Ин ҳама бечорагӣ аз обу нон.')

    def test_rejected_blocks_are_ignored(self):
        works = [published('x')]
        added, _ = publish(works, [block('Пеши он кас, ки ихтиёраш ҳаст,',
                                         decision='reject')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(len(works), 1)

    def test_a_block_already_published_is_skipped(self):
        works = [published('Дар баҳор аз фоқа ранги заъфарон бошад маро,\n'
                           'Пораҳо бар дӯш аз барги хазон бошад маро.\n'
                           'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон,\n'
                           'Рӯзу шаб шармандагӣ аз обу нон бошад маро.\n'
                           'Байти дигар.')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'already published')

    def test_a_reprint_with_other_punctuation_is_a_duplicate(self):
        works = [published('Дар баҳор аз фоқа, ранги заъфарон бошад маро\n'
                           'Пораҳо бар дӯш аз барги хазон бошад маро!\n'
                           'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон\n'
                           'Рӯзу шаб шармандагӣ аз обу нон бошад маро...')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'already published')

    def test_the_same_poet_title_and_first_line_is_a_duplicate(self):
        old = published('Дар баҳор аз фоқа ранги заъфарон бошад маро...\nБайти дигар.')
        old.update(authorId='sayyido',
                   title='Дар баҳор аз фоқа ранги заъфарон бошад маро',
                   incipit='Дар баҳор аз фоқа ранги заъфарон бошад маро...')
        added, skipped = publish([old], [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'already published')

    def test_the_same_block_twice_is_published_once(self):
        works = [published('x')]
        b = block('Дар баҳор аз фоқа ранги заъфарон бошад маро,')
        added, skipped = publish(works, [b, dict(b)], {'b': ['', PAGE]})
        self.assertEqual(len(added), 1)
        self.assertEqual(len(skipped), 1)

    def test_a_block_that_does_not_start_at_the_opening_is_refused(self):
        # The lead-in set at the verse's indent reads as part of the verse.
        page = PAGE.replace('    Шоир дар ғазали зерин аз рӯзгори худ шикоят\nменамояд:',
                            '           Шоир аз рӯзгор чунин мегӯяд:')
        works = [published('x')]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', page]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'the opening line starts no verse part')

    def test_a_missing_opening_is_reported(self):
        works = [published('x')]
        added, skipped = publish(works, [block('Ин сатр дар саҳифа нест, албатта')],
                                 {'b': ['', PAGE]})
        self.assertEqual(added, [])
        self.assertEqual(skipped[0][1], 'not found on the page')


FLUSH = """\
    Шоир дар ин бора мегӯяд:
Ҳар кӣ меҳмонро гиромӣ мекунад,
Кӯшише дар некномӣ мекунад.
Ҳар кӣ меҳмонат шавад, ар хосу ом,
Пеши ӯ мебояд овардан таом.
                                    97
"""

QUATRAINS = """\
              ДУБАЙТИЮ РУБОИЁТ
      Мусулмонон! Зи дур ояд садое,
      Садои ҷонгудозе, ғамфизое.
      Надонам, куҷо шабехун зада гург,
      Вале донам, ки нолад ошное.
      Ятиме, дардманде, бенавое,
      Баровард аз дили саҳро садое:
      «Манеҳ зинҳор аз каф шамъи умед,
      Агар хоҳӣ расӣ рӯзе ба ҷое».
                                    248
"""


def candidate(record_id, title, page=68):
    return {
        'id': record_id, 'authorId': 'x', 'title': title, 'textTajik': None,
        'primarySource': {'sourceReference': REF, 'pageStart': page},
        'verification': {'evidenceLevel': 'needsReview',
                         'verificationMethod': 'automaticDumpExtraction'},
    }


class Phase8OptionsTest(unittest.TestCase):
    def test_a_block_with_a_closing_line_is_taken_as_a_span(self):
        works = [published('x')]
        b = block('Ҳар кӣ меҳмонро гиромӣ мекунад,',
                  closing='Пеши ӯ мебояд овардан таом.')
        added, skipped = publish(works, [b], {'b': ['', FLUSH]})
        self.assertEqual(skipped, [])
        self.assertEqual(len(added[0]['textTajik'].split('\n')), 4)
        self.assertEqual(added[0]['primarySource']['pageStart'], 97)
        self.assertEqual(b['recordIds'], [added[0]['id']])

    def test_quatrains_printed_without_separators_become_poems(self):
        works = [published('x')]
        b = block('Мусулмонон! Зи дур ояд садое,', split='quatrains', type='rubai')
        added, _ = publish(works, [b], {'b': ['', QUATRAINS]})
        self.assertEqual(len(added), 2)
        self.assertEqual(added[1]['textTajik'].split('\n')[0],
                         'Ятиме, дардманде, бенавое,')
        self.assertEqual({r['type'] for r in added}, {'rubai'})
        self.assertEqual(len(b['recordIds']), 2)

    def test_a_needs_review_candidate_is_promoted_and_its_twins_merged(self):
        first = candidate('cand-1', 'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон')
        twin = candidate('cand-2', 'Пораҳо бар дӯш аз барги хазон бошад', page=67)
        works = [published('x'), first, twin]
        added, _ = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added[0]['id'], 'cand-1')
        self.assertEqual(first['verification']['evidenceLevel'], 'primaryChecked')
        self.assertIn('Promoted', first['editorialNotes'])
        self.assertEqual(twin['verification']['rejectionReason'],
                         'extraction_false_positive:duplicate_of:cand-1')
        self.assertIsNone(twin['textTajik'])
        self.assertEqual(len(works), 3)

    def test_a_candidate_named_in_replaces_is_repaired_not_merged_into_itself(self):
        first = candidate('cand-1', 'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон')
        works = [published('x'), first]
        added, _ = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,', replaces='cand-1')],
            {'b': ['', PAGE]})
        self.assertIs(added[0], first)
        self.assertEqual(first['verification']['evidenceLevel'], 'primaryChecked')
        self.assertEqual(len(first['textTajik'].split('\n')), 4)

    def test_a_candidate_from_another_page_is_not_promoted(self):
        far = candidate('far', 'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон', page=90)
        works = [published('x'), far]
        added, _ = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertNotEqual(added[0]['id'], 'far')
        self.assertEqual(far['verification']['evidenceLevel'], 'needsReview')

    def test_the_same_poets_candidate_citing_the_chapter_page_is_promoted(self):
        chapter = candidate('chap', 'Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон', page=50)
        chapter['authorId'] = 'sayyido'
        works = [published('x'), chapter]
        added, _ = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added[0]['id'], 'chap')

    def test_a_title_only_record_of_another_edition_is_promoted_with_the_pdf_citation(self):
        title_only = candidate('t', 'Дар баҳор аз фоқа ранги заъфарон бошад маро')
        title_only.update(authorId='sayyido', primarySource={
            'bookTitle': 'Адабиёти тоҷик (Китоби дарсӣ)', 'year': '2020',
            'pageStart': 60, 'pageEnd': 70})
        works = [published('x'), title_only]
        added, _ = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,')], {'b': ['', PAGE]})
        self.assertEqual(added[0]['id'], 't')
        self.assertEqual(title_only['primarySource']['year'], '2017')
        self.assertEqual(title_only['primarySource']['sourceReference'], REF)

    def test_a_record_holding_part_of_the_poem_is_repaired_in_place(self):
        part = published('Рӯзу шаб дар кӯча-кӯча дар ҷустуҷӯйи нон,\n'
                         'Рӯзу шаб шармандагӣ аз обу нон бошад маро.')
        works = [part]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,', replaces='old')],
            {'b': ['', PAGE]})
        self.assertEqual(skipped, [])
        self.assertIs(added[0], part)
        self.assertEqual(len(part['textTajik'].split('\n')), 4)
        self.assertIn('only part of the poem', part['editorialNotes'])

    def test_a_shorter_excerpt_in_another_book_is_merged(self):
        excerpt = published('Дар баҳор аз фоқа ранги заъфарон бошад маро,\n'
                            'Пораҳо бар дӯш аз барги хазон бошад маро.')
        excerpt.update(id='excerpt', authorId='sayyido',
                       title='Дар баҳор аз фоқа ранги заъфарон бошад маро',
                       incipit='Дар баҳор аз фоқа ранги заъфарон бошад маро,')
        excerpt['primarySource'] = dict(excerpt['primarySource'],
                                        sourceReference='docs/literature/pdfs/c.pdf')
        works = [published('x'), excerpt]
        added, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,', merges=['excerpt'])],
            {'b': ['', PAGE]})
        self.assertEqual(skipped, [])
        self.assertEqual(excerpt['verification']['rejectionReason'],
                         f"duplicate_canonical_work:{added[0]['id']}")
        self.assertEqual(excerpt['verification']['verificationMethod'],
                         'manualCanonicalDuplicateReview')
        self.assertIsNone(excerpt['textTajik'])
        self.assertIsNone(excerpt['incipit'])
        self.assertEqual(excerpt['textStatus'], 'needsReview')
        self.assertFalse(excerpt['rights']['fullTextAllowed'])
        self.assertIn('c, p. 1', added[0]['editorialNotes'])

    def test_a_fragment_cut_at_a_page_break_is_merged_with_its_own_note(self):
        fragment = published('Пораҳо бар дӯш аз барги хазон бошад маро.')
        fragment.update(id='fragment', authorId='sayyido')
        works = [published('x'), fragment]
        added, _ = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,',
            merges=['fragment'],
            mergeNote='the rest of the same poem, cut at a page break')],
            {'b': ['', PAGE]})
        self.assertIn('the rest of the same poem, cut at a page break',
                      fragment['editorialNotes'])
        self.assertNotIn('prints the opening', fragment['editorialNotes'])
        self.assertNotIn('Its opening is also printed', added[0]['editorialNotes'])

    def test_an_unknown_record_to_repair_is_reported(self):
        works = [published('x')]
        _, skipped = publish(works, [block(
            'Дар баҳор аз фоқа ранги заъфарон бошад маро,', replaces='nope')],
            {'b': ['', PAGE]})
        self.assertEqual(skipped[0][1], 'unknown record nope')


class PagesOfTest(unittest.TestCase):
    def test_the_last_line_is_found_on_the_last_page_that_prints_it(self):
        from publish_reviewed_blocks import pages_of
        pages = ['', 'ДАВОМИ НЕК РОҲАТРО!\nСатри якум,\n',
                 'Сатри дуюм,\nДавоми нек роҳатро!\n']
        self.assertEqual(pages_of(pages, 1, 2, ['Сатри якум,', 'Сатри дуюм,',
                                               'Давоми нек роҳатро!']), (1, 2))


class ShippedReviewTest(unittest.TestCase):
    def test_every_block_has_a_decision_and_a_reason(self):
        paths = glob.glob(os.path.join(ROOT, 'docs', 'literature',
                                       'EXTRACTION_REVIEW_*.json'))
        self.assertTrue(paths)
        for path in paths:
            with open(path, encoding='utf-8') as f:
                # A targeted review (Phase 11) may hold only a few blocks.
                self._check(json.load(f)['blocks'], 0)

    def _check(self, blocks, least):
        self.assertGreater(len(blocks), least)
        for b in blocks:
            self.assertIn(b['decision'], ('accept', 'reject'))
            self.assertTrue(b['reason'])
            self.assertTrue(b['leadIn'])
            if b['decision'] == 'accept':
                self.assertTrue(b['authorId'])


if __name__ == '__main__':
    unittest.main()
