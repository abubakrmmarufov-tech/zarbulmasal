import io
import tempfile
import unittest
from contextlib import redirect_stderr
from pathlib import Path

from tool.check_coverage import CoverageError, enforce_threshold, main, parse_lcov


class CoverageGateTest(unittest.TestCase):
    def test_parse_lcov_sums_line_records(self):
        report = """
TN:
SF:lib/one.dart
LF:10
LH:8
end_of_record
SF:lib/two.dart
LF:5
LH:4
end_of_record
"""

        coverage = parse_lcov(report)

        self.assertEqual(coverage.lines_found, 15)
        self.assertEqual(coverage.lines_hit, 12)
        self.assertAlmostEqual(coverage.percent, 80.0)

    def test_parse_lcov_rejects_incomplete_or_impossible_records(self):
        with self.assertRaises(CoverageError):
            parse_lcov("SF:lib/broken.dart\nLF:10\nend_of_record\n")

        with self.assertRaises(CoverageError):
            parse_lcov("SF:lib/impossible.dart\nLF:2\nLH:3\nend_of_record\n")

    def test_enforce_threshold_rejects_below_minimum(self):
        report = "SF:lib/one.dart\nLF:10\nLH:7\nend_of_record\n"

        with self.assertRaises(CoverageError):
            enforce_threshold(parse_lcov(report), 80.0)

    def test_main_reports_success_and_failure(self):
        with tempfile.TemporaryDirectory() as directory:
            report_path = Path(directory) / "lcov.info"
            report_path.write_text(
                "SF:lib/one.dart\nLF:4\nLH:4\nend_of_record\n",
                encoding="utf-8",
            )

            self.assertEqual(main([str(report_path), "--minimum", "80"]), 0)

            report_path.write_text(
                "SF:lib/one.dart\nLF:4\nLH:3\nend_of_record\n",
                encoding="utf-8",
            )
            error = io.StringIO()
            with redirect_stderr(error):
                self.assertEqual(main([str(report_path), "--minimum", "80"]), 1)
            self.assertIn("below minimum", error.getvalue())


if __name__ == "__main__":
    unittest.main()
