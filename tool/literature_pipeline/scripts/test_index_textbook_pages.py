#!/usr/bin/env python3
"""Tests for the non-publishing textbook page candidate locator."""

import unittest

from index_textbook_pages import (
    author_names,
    find_author_page_candidates,
    normalize_tajik,
    page_signals,
)


class TextbookPageCandidateTest(unittest.TestCase):
    def test_normalization_matches_legacy_tajik_pdf_letters(self):
        self.assertEqual(normalize_tajik("РЎДАКЇ"), "рӯдакӣ")
        self.assertEqual(normalize_tajik("  Рӯдакӣ\n"), "рӯдакӣ")

    def test_candidates_are_page_references_not_source_claims(self):
        candidates = find_author_page_candidates(
            author_id="rudaki",
            names=["Абӯабдуллоҳи Рӯдакӣ", "Рӯдакӣ"],
            pages=[
                (1, "Сарсухан"),
                (42, "РЎДАКЇ\nНамунаи ашъор"),
            ],
        )

        self.assertEqual(
            candidates,
            [
                {
                    "authorId": "rudaki",
                    "pdfPage": 42,
                    "matchedName": "Рӯдакӣ",
                    "pageSignals": ["poetry_cue"],
                }
            ],
        )

    def test_page_signals_flag_exercises_without_treating_them_as_poems(self):
        self.assertEqual(
            page_signals("Рӯдакӣ\n1. Савол дар бораи шеър\n2. Ҷавобро интихоб кунед"),
            ["question_numbering", "poetry_cue"],
        )
        self.assertEqual(page_signals("Рӯдакӣ\nМатни номаълум"), ["name_hit_only"])

    def test_candidate_search_uses_only_the_canonical_author_name(self):
        self.assertEqual(
            author_names(
                {"canonicalName": "Абӯабдуллоҳи Рӯдакӣ", "aliases": ["Дар"]}
            ),
            ["Абӯабдуллоҳи Рӯдакӣ"],
        )

    def test_candidate_search_rejects_too_short_extracted_names(self):
        self.assertEqual(author_names({"canonicalName": "Дар"}), [])


if __name__ == "__main__":
    unittest.main()
