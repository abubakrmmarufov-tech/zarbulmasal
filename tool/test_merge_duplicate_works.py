import sys
import unittest
from pathlib import Path

try:
    from tool.literature_pipeline.scripts import merge_duplicate_works
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from literature_pipeline.scripts import merge_duplicate_works


class MergeDuplicateWorksTest(unittest.TestCase):
    def test_same_author_extraction_duplicates_merge_and_retain_sources(self):
        source = {
            "bookTitle": "Grade 7",
            "publisher": "Маориф",
            "city": "Душанбе",
            "year": "2018",
            "pageStart": 104,
            "sourceType": "official-textbook",
        }
        works = [
            {
                "id": "a",
                "authorId": "kamol",
                "title": "Гар биҷӯянд, ба сад қарн наёбанд",
                "incipit": None,
                "verification": {"evidenceLevel": "needsReview"},
                "primarySource": source,
            },
            {
                "id": "b",
                "authorId": "kamol",
                "title": "Гар биҷӯянд ба сад қарн наёбанд",
                "incipit": None,
                "verification": {"evidenceLevel": "needsReview"},
                "primarySource": {**source, "pageStart": 190},
            },
        ]

        merged, removed = merge_duplicate_works.merge(works)

        self.assertEqual(removed, 1)
        self.assertEqual([work["id"] for work in merged], ["a"])
        self.assertEqual(
            [source["pageStart"] for source in merged[0]["sourceOccurrences"]],
            [104, 190],
        )

    def test_reviewed_or_full_text_records_are_not_merged(self):
        works = [
            {
                "id": "a",
                "authorId": "same",
                "title": "Same",
                "verification": {"evidenceLevel": "primaryChecked"},
            },
            {
                "id": "b",
                "authorId": "same",
                "title": "Same",
                "verification": {"evidenceLevel": "needsReview"},
            },
        ]
        merged, removed = merge_duplicate_works.merge(works)
        self.assertEqual(removed, 0)
        self.assertEqual(len(merged), 2)


if __name__ == "__main__":
    unittest.main()
