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
        self.assertIn("PRIMARY CHECKED MISSING SECOND SOURCE: 6", result.stdout)


if __name__ == "__main__":
    unittest.main()
