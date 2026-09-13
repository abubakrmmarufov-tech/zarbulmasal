#!/usr/bin/env python3
"""Small fixture test for the provenance-preserving asset builder."""

import unittest

from build_assets import build_candidates


class BuildAssetsTest(unittest.TestCase):
    def test_extracted_candidate_is_pending_and_does_not_invent_pages(self):
        poets, works, new_poets, new_works = build_candidates(
            [
                {
                    "name": "Шоири санҷишӣ",
                    "birth_death": "1900 - 1970",
                    "bio": "Маълумоти санҷишӣ",
                    "poems": [{"title": "Номи санҷишӣ", "content": "Байти санҷишӣ"}],
                    "_source": "docs/literature/extracted/fixture.json",
                }
            ],
            [],
            [],
        )

        self.assertEqual((new_poets, new_works), (1, 1))
        self.assertEqual(poets[0]["rights"]["fullTextAllowed"], False)
        self.assertEqual(works[0]["textStatus"], "needsReview")
        self.assertIsNone(works[0]["primarySource"]["pageStart"])
        self.assertIsNone(works[0]["secondarySource"])
        self.assertEqual(works[0]["verification"]["finalStatus"], "needsReview")


if __name__ == "__main__":
    unittest.main()
