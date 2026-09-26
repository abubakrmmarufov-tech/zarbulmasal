import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import clean_verse_marks as cvm  # noqa: E402


class FootnoteTest(unittest.TestCase):
    def test_a_marker_in_the_gap_between_words_becomes_the_space(self):
        self.assertEqual(cvm.clean_line('Аз басити91марғзор афзун бувад.'),
                         'Аз басити марғзор афзун бувад.')
        self.assertEqual(cvm.clean_line('Чунки аъмо123толиби Ҳақ омадаст,'),
                         'Чунки аъмо толиби Ҳақ омадаст,')

    def test_a_marker_after_punctuation_or_before_a_word_goes(self):
        self.assertEqual(cvm.clean_line('Мунъиме,6 к-ӯ дошт меҳмонро наку,'),
                         'Мунъиме, к-ӯ дошт меҳмонро наку,')
        self.assertEqual(cvm.clean_line('Бар афсонааш гашт наҳмор 27шод.'),
                         'Бар афсонааш гашт наҳмор шод.')
        self.assertEqual(cvm.clean_line('Хоҷа гуфташ: «Фӣ амониллаҳ» 99бирав,'),
                         'Хоҷа гуфташ: «Фӣ амониллаҳ» бирав,')
        self.assertEqual(cvm.clean_line('«Муъминам, «Янзур бинуриллаҳ» 112'),
                         '«Муъминам, «Янзур бинуриллаҳ»')
        self.assertEqual(cvm.clean_line('Лавҳи симин2-ш бар канор ниҳод'),
                         'Лавҳи симин-ш бар канор ниҳод')

    def test_three_for_ze_is_a_lookalike(self):
        self.assertEqual(cvm.clean_line('3-он чӣ бояд, набуд чизе кам.'),
                         'З-он чӣ бояд, набуд чизе кам.')

    def test_verse_without_marks_is_unchanged(self):
        for line in ['Гуфт: - Ай хоҷа, пушаймонӣ зи чист?!',
                     'Дар ин хона – таваллудгоҳи инсон,']:
            self.assertEqual(cvm.clean_line(line), line)


class GlossTest(unittest.TestCase):
    def test_a_footnote_gloss_is_not_verse(self):
        self.assertTrue(cvm.is_gloss('Муқтазӣ - сабаб, боис.'))
        self.assertTrue(cvm.is_gloss('Тобадон - равзан барои ворид шудани рӯшноӣ.'))
        # Printed inline under «Ҳону ҳон!» (grade 7, p. 85).
        self.assertTrue(cvm.is_gloss('Ҳону ҳон - огоҳ бош, хабардор бош.'))

    def test_verse_with_a_dash_is_verse(self):
        for line in ['Андак - андак дар дили ӯ сард шуд.',
                     'Кӯҳи барфин – оби ширин дорад он,',
                     'Гуфт: - Ҷони ҳар ду дар дасти шумост.']:
            self.assertFalse(cvm.is_gloss(line), line)


class CleanTextTest(unittest.TestCase):
    def test_changes_are_listed_line_by_line(self):
        text, changes = cvm.clean_text(
            'Бар афсонааш гашт наҳмор 27шод.\nМуқтазӣ - сабаб, боис.\nХуб аст.',
            glosses={'Муқтазӣ - сабаб, боис.'})
        self.assertEqual(text, 'Бар афсонааш гашт наҳмор шод.\nХуб аст.')
        self.assertEqual([c['after'] for c in changes],
                         ['Бар афсонааш гашт наҳмор шод.', None])



class LogTest(unittest.TestCase):
    def test_a_rerun_keeps_the_earlier_changes(self):
        earlier = [{'id': 'a', 'changes': [{'before': 'x1', 'after': 'x'}]}]
        later = [{'id': 'b', 'changes': [{'before': 'y2', 'after': 'y'}]},
                 {'id': 'a', 'changes': [{'before': 'x1', 'after': 'x'}]}]
        merged = cvm.merge_logs(earlier, later)
        self.assertEqual([entry['id'] for entry in merged], ['a', 'b'])
        self.assertEqual(len(merged[0]['changes']), 1)


if __name__ == '__main__':
    unittest.main()
