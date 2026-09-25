"""Tests for fix_lookalike_letters.py (python3 -m unittest)."""
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(__file__))
from fix_lookalike_letters import fix_all  # noqa: E402


def record(level='primaryChecked', **fields):
    base = {'id': 'r', 'title': 'Яке Руму', 'incipit': None,
            'textTajik': 'Яке аз дасти зулми Инглистон\nXалоси мулки Ҳиндустон',
            'persianScriptRepresentation': 'old', 'persianScriptSource': 'generated',
            'titlePersian': 'old', 'titlePersianSource': 'generated',
            'verification': {'evidenceLevel': level}}
    base.update(fields)
    return base


class FixAllTest(unittest.TestCase):
    def test_words_are_fixed_logged_and_the_generated_script_redone(self):
        r = record()
        log = fix_all([r])
        self.assertEqual(log, [{'id': 'r', 'field': 'textTajik',
                                'before': 'Xалоси', 'after': 'Халоси'}])
        self.assertIn('Халоси', r['textTajik'])
        self.assertNotEqual(r['persianScriptRepresentation'], 'old')
        self.assertEqual(r['titlePersian'], 'old')     # the title did not change

    def test_rejected_records_and_clean_records_are_left_alone(self):
        rejected = record(level='rejected')
        clean = record(textTajik='Яке Руму яке Юнон парастад')
        self.assertEqual(fix_all([rejected, clean]), [])
        self.assertIn('Xалоси', rejected['textTajik'])

    def test_a_script_given_by_a_source_is_not_regenerated(self):
        r = record(persianScriptSource='source')
        fix_all([r])
        self.assertEqual(r['persianScriptRepresentation'], 'old')


if __name__ == '__main__':
    unittest.main()
