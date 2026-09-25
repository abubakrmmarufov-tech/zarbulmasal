"""Tests for excerpt_textbooks.py (python3 -m unittest)."""
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(__file__))
import excerpt_textbooks as X  # noqa: E402


def pages(texts):
    root = tempfile.mkdtemp()
    os.makedirs(os.path.join(root, '9'))
    for n, text in texts.items():
        with open(os.path.join(root, '9', f'{n}.txt'), 'w', encoding='utf-8') as f:
            f.write(text)
    return root


class ExcerptTest(unittest.TestCase):
    def test_a_paragraph_carried_from_the_previous_page_starts_at_a_sentence(self):
        root = pages({148: (
            'дер давом накард ва баста шуд. Октябри соли 1908 бо ташаббуси\n'
            'Мунзим ва Садриддин Айнӣ дар Бухоро аввалин мактаби усули нав\n'
            'кушода шуд, ки он 12 нафар хонанда дошт ва ба таълим сар кард.\n'
            '                               148\n')})
        body, first, last = X.excerpt(root, 9, 148, 148, r'Айнӣ')
        self.assertTrue(body.startswith('Октябри соли 1908'))
        self.assertEqual((first, last), (148, 148))

    def test_soft_hyphens_are_removed(self):
        root = pages({148: (
            '    Шоир дар шеърҳояш ҷаб\xadру ситами мардуми заҳматкашро\n'
            'муттаҳам намуда, зиндагии пеш аз исломиро таъриф менамуд ва Айнӣ.\n'
            '                               148\n')})
        body, _, _ = X.excerpt(root, 9, 148, 148, r'Айнӣ')
        self.assertIn('ҷабру', body)


if __name__ == '__main__':
    unittest.main()
