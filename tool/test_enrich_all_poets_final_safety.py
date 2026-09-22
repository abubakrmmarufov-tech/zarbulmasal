import ast
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class EnrichmentSafetyTest(unittest.TestCase):
    def test_enrichment_does_not_execute_mapping_source(self):
        source = (ROOT / "tool/enrich_all_poets_final.py").read_text(encoding="utf-8")
        self.assertNotIn("exec(", source)

    def test_update_poets_mappings_are_literal_data(self):
        source_path = ROOT / "tool/update_poets.py"
        tree = ast.parse(source_path.read_text(encoding="utf-8"), str(source_path))
        mappings = {}
        for node in tree.body:
            if not isinstance(node, ast.Assign):
                continue
            for target in node.targets:
                if isinstance(target, ast.Name) and target.id in {
                    "CANONICAL_FA",
                    "TEXTBOOK_MAP",
                }:
                    mappings[target.id] = ast.literal_eval(node.value)

        self.assertEqual(set(mappings), {"CANONICAL_FA", "TEXTBOOK_MAP"})
        self.assertEqual(len(mappings["CANONICAL_FA"]), 143)
        self.assertTrue(mappings["TEXTBOOK_MAP"])


if __name__ == "__main__":
    unittest.main()
