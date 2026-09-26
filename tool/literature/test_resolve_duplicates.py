import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import resolve_duplicates as rd  # noqa: E402


def work(id, text, title=None):
    return {
        'id': id, 'authorId': 'p', 'title': title or text.split('\n')[0],
        'textTajik': text, 'incipit': text.split('\n')[0],
        'persianScriptSource': 'generated', 'persianScriptRepresentation': 'x',
        'verification': {'evidenceLevel': 'primaryChecked'},
        'rights': {'status': 'publicDomain'},
    }


class RetireTest(unittest.TestCase):
    def test_a_fragment_is_retired_into_the_full_poem(self):
        full = work('full', 'а\nб\nв\nг')
        part = work('part', 'в\nг')
        by_id = {'full': full, 'part': part}
        rd.retire(by_id, {'retire': 'part', 'into': 'full',
                          'note': 'the second page of the same ghazal'})
        self.assertEqual(part['verification']['evidenceLevel'], 'rejected')
        self.assertEqual(part['verification']['rejectionReason'],
                         'duplicate_canonical_work:full')
        self.assertIsNone(part['textTajik'])
        self.assertIn('the second page of the same ghazal', part['editorialNotes'])
        # The full poem is untouched.
        self.assertEqual(full['textTajik'], 'а\nб\nв\nг')

    def test_retiring_needs_the_lines_to_be_in_the_fuller_record(self):
        by_id = {'a': work('a', 'а\nб'), 'b': work('b', 'в\nг')}
        with self.assertRaises(ValueError):
            rd.retire(by_id, {'retire': 'b', 'into': 'a', 'note': 'x'})


    def test_a_reprint_with_spelling_variants_is_retired_with_them_noted(self):
        full = work('full', 'Дигар поро ба по бе ҳеч мезад.\nЯке ором.')
        reprint = work('reprint', 'Дигар поро ба по бе ҳеҷ мезад.\nЯке ором.')
        by_id = {'full': full, 'reprint': reprint}
        with self.assertRaises(ValueError):
            rd.retire(by_id, {'retire': 'reprint', 'into': 'full', 'note': 'x'})
        rd.retire(by_id, {'retire': 'reprint', 'into': 'full', 'note': 'x',
                          'variants': True})
        self.assertIn('«Дигар поро ба по бе ҳеҷ мезад.»',
                      reprint['editorialNotes'])


class TrimTest(unittest.TestCase):
    def test_a_record_that_lumped_several_poems_keeps_its_own(self):
        lumped = work('r', 'а\nб\nв\nг\n\nд\nе\nж\nз')
        changes = rd.trim({'r': lumped}, {'trim': 'r', 'stanzas': 1,
                                          'note': 'one rubai'})
        self.assertEqual(lumped['textTajik'], 'а\nб\nв\nг')
        self.assertEqual(changes['removedLines'], 4)
        self.assertIn('one rubai', lumped['editorialNotes'])


    def test_a_second_run_changes_nothing(self):
        lumped = work('r', 'а\nб\nв\nг\n\nд\nе\nж\nз')
        decision = {'trim': 'r', 'stanzas': 1, 'note': 'one rubai'}
        rd.trim({'r': lumped}, decision)
        notes = lumped['editorialNotes']
        self.assertEqual(rd.trim({'r': lumped}, decision)['removedLines'], 0)
        self.assertEqual(lumped['editorialNotes'], notes)


if __name__ == '__main__':
    unittest.main()
