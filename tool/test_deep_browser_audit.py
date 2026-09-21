import unittest
from pathlib import Path


class DeepBrowserAuditPreferenceTest(unittest.TestCase):
    def test_flutter_web_preferences_are_json_encoded(self):
        source = Path('tool/deep_browser_audit.py').read_text(encoding='utf-8')

        self.assertIn(
            "window.localStorage.setItem('flutter.display_language', JSON.stringify('tj'))",
            source,
        )
        self.assertIn(
            "window.localStorage.setItem('flutter.display_language', JSON.stringify('fa'))",
            source,
        )
        self.assertIn(
            "window.localStorage.setItem('flutter.onboarding_complete', JSON.stringify(true))",
            source,
        )
        self.assertIn(
            "window.localStorage.setItem('flutter.dark_mode', JSON.stringify(false))",
            source,
        )
        self.assertNotIn(
            "window.localStorage.setItem('flutter.display_language', 'fa')",
            source,
        )

    def test_persian_pass_has_content_markers(self):
        source = Path('tool/deep_browser_audit.py').read_text(encoding='utf-8')

        self.assertIn("'/': ('خانه', 'ضرب‌المثل‌ها')", source)
        self.assertIn("'/#/literature': ('میراث ادبی',)", source)
        self.assertIn("'/#/books/badi-boron': ('کتابخانه', 'Kitobkhon · kitobkhon.net')", source)
        self.assertIn("if 'Асосӣ' in body_text:", source)
        self.assertIn("await page_fa.locator('body').inner_text()", source)
        self.assertIn("document.querySelector('flt-semantics-placeholder')?.click()", source)

    def test_ci_runs_pinned_browser_audit_against_release_web_artifact(self):
        workflow = Path('.github/workflows/ci.yml').read_text(encoding='utf-8')

        self.assertIn("playwright==1.62.0", workflow)
        self.assertIn("playwright install --with-deps chromium", workflow)
        self.assertIn("python3 tool/deep_browser_audit.py \\\n            http://127.0.0.1:8080/zarbulmasal/", workflow)

    def test_catalog_detail_routes_are_derived_from_checked_in_assets(self):
        source = Path('tool/deep_browser_audit.py').read_text(encoding='utf-8')

        self.assertIn("assets/data/literature/poets.json", source)
        self.assertIn("assets/data/books/books.json", source)
        self.assertIn('yield from load_catalog_detail_routes()', source)
        self.assertIn('expected_marker', source)
        self.assertIn('Catalog route', source)


if __name__ == '__main__':
    unittest.main()
