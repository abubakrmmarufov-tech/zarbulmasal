import unittest
from pathlib import Path
import json
import sys
import tempfile

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from tool.deep_browser_audit import (
    _work_is_displayable,
    load_browser_route_cases,
    load_catalog_detail_routes,
    load_dark_mode_route_cases,
    load_persian_route_cases,
    load_router_route_patterns,
)


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
        routes = load_catalog_detail_routes()
        poets = json.loads(
            Path('assets/data/literature/poets.json').read_text(encoding='utf-8')
        )
        books = json.loads(
            Path('assets/data/books/books.json').read_text(encoding='utf-8')
        )

        poet_routes = [route for route, _, _ in routes if route.startswith('/#/literature/poet/')]
        book_routes = [route for route, _, _ in routes if route.startswith('/#/books/')]
        public_poet_count = sum(
            poet.get('recordStatus', 'active') == 'active'
            and poet.get('canonicalName', '').strip().lower() != 'unknown'
            for poet in poets
        )
        self.assertEqual(len(poet_routes), public_poet_count)
        self.assertEqual(len(book_routes), len(books))
        self.assertTrue(all(marker for _, _, marker in routes))


class DeepBrowserAuditRouteInventoryTest(unittest.TestCase):
    def test_route_patterns_are_read_from_the_current_go_router(self):
        expected = [
            '/',
            '/explore',
            '/learn',
            '/saved',
            '/saved/bayoz/:id',
            '/search',
            '/proverbs',
            '/categories',
            '/favorites',
            '/settings',
            '/proverb/:id',
            '/levels',
            '/quiz',
            '/flashcards',
            '/daily',
            '/literature',
            '/literature/poets',
            '/literature/poet/:id',
            '/literature/poets/:id',
            '/literature/works',
            '/literature/work/:id',
            '/literature/works/:id',
            '/literature/school',
            '/literature/oral',
            '/literature/search',
            '/history',
            '/history/:id',
            '/books',
            '/books/:id',
            '/books/category/:id',
            '/books/author/:id',
            '/vocabulary',
            '/vocabulary/:id',
        ]

        self.assertEqual(load_router_route_patterns(), expected)

    def test_route_parser_ignores_non_routes_and_commented_examples(self):
        fixture = '''
// GoRoute(path: '/commented-out')
GoRoute(path: '/first')
final routeData = {'path': '/not-a-router-route'};
GoRoute(
  path: "/second",
  builder: buildSecond,
)
'''
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            self.assertEqual(
                load_router_route_patterns(router_path),
                ['/first', '/second'],
            )

    def test_route_parser_preserves_comment_markers_inside_strings(self):
        fixture = "final example = 'https://example.test'; GoRoute(path: '/after-url')"
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            self.assertEqual(
                load_router_route_patterns(router_path),
                ['/after-url'],
            )

    def test_route_parser_ignores_route_like_text_inside_strings(self):
        fixture = '''
final example = "GoRoute(path: '/not-a-route')";
GoRoute(path: '/real-route')
'''
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            self.assertEqual(
                load_router_route_patterns(router_path),
                ['/real-route'],
            )

    def test_route_parser_finds_path_after_other_named_arguments(self):
        fixture = '''
GoRoute(
  name: 'sample',
  path: '/named-first',
  builder: buildSample,
)
'''
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            self.assertEqual(
                load_router_route_patterns(router_path),
                ['/named-first'],
            )

    def test_route_parser_supports_raw_and_triple_quoted_path_literals(self):
        fixture = '''
GoRoute(path: r'/raw-path')
GoRoute(path: ''' + "'''/single-triple'''" + ''')
GoRoute(path: """/double-triple""")
'''
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            self.assertEqual(
                load_router_route_patterns(router_path),
                ['/raw-path', '/single-triple', '/double-triple'],
            )

    def test_route_parser_decodes_escaped_path_literals(self):
        fixture = r"GoRoute(path: '/foo\u0062ar')"
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            self.assertEqual(
                load_router_route_patterns(router_path),
                ['/foobar'],
            )

    def test_route_parser_fails_closed_on_interpolated_paths(self):
        fixture = "GoRoute(path: '/foo/${bar}')"
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            with self.assertRaisesRegex(ValueError, '(?i)interpolated'):
                load_router_route_patterns(router_path)

    def test_route_parser_fails_closed_on_concatenated_paths(self):
        fixture = "GoRoute(path: '/foo' + '/bar')"
        with tempfile.TemporaryDirectory() as temp_dir:
            router_path = Path(temp_dir) / 'router.dart'
            router_path.write_text(fixture, encoding='utf-8')
            with self.assertRaisesRegex(ValueError, 'single static string'):
                load_router_route_patterns(router_path)

    def test_browser_inventory_covers_every_current_router_pattern(self):
        expected_patterns = set(load_router_route_patterns())
        cases = load_browser_route_cases()

        self.assertEqual({pattern for pattern, _, _, _ in cases}, expected_patterns)
        self.assertTrue(all(route.startswith('/') for _, route, _, _ in cases))
        for pattern in expected_patterns:
            self.assertTrue(any(case[0] == pattern for case in cases), pattern)

    def test_current_catalogs_supply_all_catalog_detail_fixtures(self):
        cases = load_browser_route_cases()
        poets = json.loads(
            Path('assets/data/literature/poets.json').read_text(encoding='utf-8')
        )
        public_poet_count = sum(
            poet.get('recordStatus', 'active') == 'active'
            and poet.get('canonicalName', '').strip().lower() != 'unknown'
            for poet in poets
        )
        book_count = len(json.loads(
            Path('assets/data/books/books.json').read_text(encoding='utf-8')
        ))

        self.assertEqual(
            sum(pattern == '/literature/poet/:id' for pattern, _, _, _ in cases),
            public_poet_count,
        )
        self.assertEqual(
            sum(pattern == '/books/:id' for pattern, _, _, _ in cases),
            book_count,
        )
        for pattern in (
            '/proverb/:id',
            '/books/category/:id',
            '/books/author/:id',
            '/literature/work/:id',
            '/literature/works/:id',
            '/history/:id',
            '/vocabulary/:id',
        ):
            self.assertTrue(
                all(
                    marker
                    for route_pattern, _, _, marker in cases
                    if route_pattern == pattern
                ),
                pattern,
            )
        reader_cases = [
            case
            for case in cases
            if case[0] in ('/literature/work/:id', '/literature/works/:id')
        ]
        self.assertTrue(reader_cases)
        self.assertTrue(any(case[0] == '/literature/work/:id' for case in reader_cases))
        self.assertTrue(any(case[0] == '/literature/works/:id' for case in reader_cases))
        for case in reader_cases:
            self.assertTrue(case[3])
        self.assertTrue(
            any(case[3] != 'Асар дар санҷиш аст' for case in reader_cases),
            'readable source-attested works must be exercised by the reader fixture',
        )

    def test_vocabulary_detail_fixture_matches_the_route_smoke_test(self):
        cases = load_browser_route_cases()
        vocab_cases = [
            case for case in cases if case[0] == '/vocabulary/:id'
        ]
        self.assertEqual(len(vocab_cases), 1)
        _, route, _, marker = vocab_cases[0]
        # Same entry the Dart route smoke test exercises
        # (test/mobile_route_smoke_test.dart -> /vocabulary/vocab-proverb-21).
        self.assertEqual(route, '/#/vocabulary/vocab-proverb-21')
        self.assertTrue(marker)
        # The marker is the aggregated entry's term: the proverb's own text,
        # which the detail screen renders as its title.
        seed = Path('lib/data/seed/seed_proverbs_part1.dart').read_text(encoding='utf-8')
        self.assertIn(marker, seed)

    def test_reader_cases_match_dart_readable_and_pending_gate(self):
        works = json.loads(
            Path('assets/data/literature/works.json').read_text(encoding='utf-8')
        )
        by_id = {
            record['id']: record
            for record in works
            if isinstance(record.get('id'), str) and record['id'].strip()
        }
        cases = load_browser_route_cases()
        reader_cases = [
            case
            for case in cases
            if case[0] in ('/literature/work/:id', '/literature/works/:id')
        ]
        self.assertTrue(reader_cases)
        for _, route, _, marker in reader_cases:
            work_id = route.rsplit('/', 1)[-1]
            record = by_id[work_id]
            evidence_level = (record.get('verification') or {}).get('evidenceLevel')
            if _work_is_displayable(record):
                self.assertEqual(marker, record.get('title'))
            else:
                self.assertEqual(marker, 'Асар дар санҷиш аст')
                self.assertIn(evidence_level, ('needsReview', 'primaryChecked'))

    def test_language_and_dark_mode_smokes_use_router_derived_routes(self):
        cases = load_browser_route_cases()
        available_urls = {route for _, route, _, _ in cases}

        self.assertTrue(all(route in available_urls for route, _, _ in load_persian_route_cases(cases)))
        dark_cases = load_dark_mode_route_cases(cases)
        self.assertTrue(all(route in available_urls for route, _ in dark_cases))
        self.assertTrue(any('/literature/poet/' in route for route, _ in dark_cases))

    def test_unmapped_dynamic_route_fails_closed(self):
        with self.assertRaisesRegex(ValueError, 'No browser fixture is defined'):
            load_browser_route_cases(['/new-feature/:id'])


if __name__ == '__main__':
    unittest.main()
