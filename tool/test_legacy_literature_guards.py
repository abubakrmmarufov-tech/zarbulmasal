import subprocess
import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class LegacyLiteratureGuardTest(unittest.TestCase):
    def test_legacy_writers_fail_closed_before_importing_dependencies(self):
        scripts = (
            ROOT / "tool/extract_curriculum_poems.py",
            ROOT / "tool/apply_curriculum_expansion.py",
        )

        for script in scripts:
            with self.subTest(script=script.name):
                result = subprocess.run(
                    [sys.executable, str(script)],
                    cwd=ROOT,
                    capture_output=True,
                    text=True,
                    check=False,
                    timeout=10,
                )

                self.assertNotEqual(result.returncode, 0)
                self.assertIn("Deprecated and disabled", result.stderr)


if __name__ == "__main__":
    unittest.main()
