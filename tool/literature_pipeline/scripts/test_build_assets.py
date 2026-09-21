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
        self.assertEqual(poets[0]["rights"]["status"], "unknown")
        self.assertEqual(poets[0]["rights"]["excerptAllowed"], False)
        self.assertEqual(poets[0]["biographyTj"], "")
        self.assertEqual(
            poets[0]["biographyTjProvenance"],
            "UNSUPPORTED_GENERATED",
        )
        self.assertEqual(
            poets[0]["biographyFaProvenance"],
            "UNSUPPORTED_GENERATED",
        )
        self.assertIn("withheld", poets[0]["biographyQuarantineNote"])
        self.assertEqual(works[0]["textStatus"], "needsReview")
        self.assertIsNone(works[0]["textTajik"])
        self.assertIsNone(works[0]["incipit"])
        self.assertEqual(works[0]["rights"]["status"], "unknown")
        self.assertEqual(works[0]["rights"]["excerptAllowed"], False)
        self.assertIsNone(works[0]["primarySource"]["pageStart"])
        self.assertIsNone(works[0]["secondarySource"])
        self.assertEqual(
            works[0]["verification"]["evidenceLevel"],
            "needsReview",
        )
        self.assertFalse(works[0]["verification"]["pageVerified"])
        self.assertNotIn("finalStatus", works[0]["verification"])
        self.assertNotIn("pageChecked", works[0]["verification"])


if __name__ == "__main__":
    unittest.main()
