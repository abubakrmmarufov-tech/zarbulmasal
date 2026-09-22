import unittest

from tool.provenance_repair_loop1_detect import source_image_paths


class ProvenanceDetectorTest(unittest.TestCase):
    def test_source_image_paths_prefers_complete_multi_page_evidence(self):
        self.assertEqual(
            source_image_paths(
                {
                    "sourceImagePath": "legacy.png",
                    "sourceImagePaths": ["page-106.png", "page-107.png"],
                }
            ),
            ["page-106.png", "page-107.png"],
        )
        self.assertEqual(source_image_paths({"sourceImagePath": "legacy.png"}), ["legacy.png"])
        self.assertEqual(source_image_paths({"sourceImagePaths": [None, "", "page.png"]}), ["page.png"])


if __name__ == "__main__":
    unittest.main()
