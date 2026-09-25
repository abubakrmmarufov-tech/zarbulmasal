import json
import subprocess
import unittest
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[1]


class LiteraryContentReportTests(unittest.TestCase):
    def test_report_exposes_primary_checked_missing_second_witnesses(self):
        result = subprocess.run(
            ["dart", "run", "tool/validate_literary_content.dart"],
            cwd=REPO_ROOT,
            text=True,
            capture_output=True,
            check=False,
        )

        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        works = json.loads(
            (REPO_ROOT / "assets/data/literature/works.json").read_text(
                encoding="utf-8"
            )
        )
        expected = sum(
            1
            for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
            and not work.get("secondarySource")
        )
        self.assertGreater(expected, 0)
        self.assertIn(
            f"PRIMARY CHECKED MISSING SECOND SOURCE: {expected}", result.stdout
        )


if __name__ == "__main__":
    unittest.main()
