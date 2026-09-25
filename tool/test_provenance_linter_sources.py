import contextlib
import io
import json
import os
import stat
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from tool import provenance_linter
from tool.literature_pipeline.scripts import sync_source_citations


class ProvenanceLinterSourceTest(unittest.TestCase):
    def test_json_loader_rejects_duplicate_object_keys(self):
        with tempfile.TemporaryDirectory() as directory:
            duplicate_path = Path(directory) / "duplicate.json"
            duplicate_path.write_text(
                '{"id": "one", "id": "two"}', encoding="utf-8"
            )

            with self.assertRaises(provenance_linter.DuplicateJsonKeyError):
                provenance_linter.load(duplicate_path)

    def test_rejected_duplicate_canonical_records_are_quarantined(self):
        self.assertEqual(provenance_linter.main(), 0)

    def test_linter_reports_malformed_source_catalog_record_without_crashing(self):
        sources = json.loads(provenance_linter.SOURCES_PATH.read_text(encoding="utf-8"))
        sources.append(None)

        with tempfile.TemporaryDirectory() as directory:
            sources_path = Path(directory) / "sources.json"
            sources_path.write_text(
                json.dumps(sources, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "SOURCES_PATH", sources_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("RECORD_FORMAT", stderr.getvalue())

    def test_linter_rejects_malformed_unused_source_catalog_metadata(self):
        sources = json.loads(
            provenance_linter.SOURCES_PATH.read_text(encoding="utf-8")
        )
        sources.append({
            "id": "malformed-unused-source",
            "bookTitle": {"not": "text"},
            "sourceReference": 123,
        })

        with tempfile.TemporaryDirectory() as directory:
            sources_path = Path(directory) / "sources.json"
            sources_path.write_text(
                json.dumps(sources, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "SOURCES_PATH", sources_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("SOURCE_CATALOG_FIELD", stderr.getvalue())
        self.assertIn("bookTitle", stderr.getvalue())
        self.assertIn("sourceReference", stderr.getvalue())

    def test_uploaded_pdf_inventory_matches_active_source_records(self):
        inventory = Path('docs/literature/SOURCE_INVENTORY.md').read_text(
            encoding='utf-8'
        )
        sources = json.loads(
            Path('assets/data/literature/sources.json').read_text(
                encoding='utf-8'
            )
        )
        local_sources = [
            source
            for source in sources
            if str(source.get('sourceReference', '')).startswith(
                'docs/literature/pdfs/'
            )
        ]

        self.assertEqual(len(local_sources), 7)
        self.assertNotIn('TBD', inventory)
        for source in local_sources:
            filename = Path(source['sourceReference']).name
            self.assertIn(f'`{filename}`', inventory)
            self.assertIn(str(source['year']), inventory)
            self.assertIn(source['publisher'], inventory)
            self.assertIn(source['id'], inventory)

    def test_grade5_work_citations_match_uploaded_pdf_bibliography(self):
        sources = json.loads(
            Path('assets/data/literature/sources.json').read_text(
                encoding='utf-8'
            )
        )
        works = json.loads(
            Path('assets/data/literature/works.json').read_text(
                encoding='utf-8'
            )
        )
        source = next(
            item for item in sources
            if item.get('id') == 'tj_literature_grade_5_2017'
        )
        citation_fields = (
            'bookTitle',
            'authorAsPrinted',
            'editor',
            'edition',
            'publisher',
            'city',
            'year',
            'isbn',
            'sourceType',
            'sourceInstitution',
        )
        mismatches = []

        for work in works:
            citations = [
                work.get(slot) or {}
                for slot in ('primarySource', 'secondarySource')
            ]
            citations.extend(work.get('sourceOccurrences') or [])
            for citation in citations:
                if citation.get('sourceReference') != source['sourceReference']:
                    continue
                for field in citation_fields:
                    if source.get(field) in (None, ''):
                        continue
                    if citation.get(field) != source.get(field):
                        mismatches.append((work.get('id'), field))

        self.assertEqual(mismatches, [])

    def test_linter_rejects_catalog_mismatches_in_every_citation_slot(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        sources = json.loads(
            Path("assets/data/literature/sources.json").read_text(encoding="utf-8")
        )
        source_reference = next(
            source["sourceReference"]
            for source in sources
            if source.get("id") == "tj_literature_grade_7_2018"
        )
        slots = ("primarySource", "secondarySource", "sourceOccurrences")

        for slot in slots:
            corrupted_works = json.loads(json.dumps(works))
            target = next(
                work
                for work in corrupted_works
                if any(
                    citation.get("sourceReference") == source_reference
                    for citation in (
                        work.get(slot) or []
                        if slot == "sourceOccurrences"
                        else [work.get(slot) or {}]
                    )
                )
            )
            if slot == "sourceOccurrences":
                citation = next(
                    item for item in target[slot]
                    if item.get("sourceReference") == source_reference
                )
            else:
                citation = target[slot]
            citation["bookTitle"] = "Incorrect title"

            with self.subTest(slot=slot), tempfile.TemporaryDirectory() as directory:
                works_path = Path(directory) / "works.json"
                works_path.write_text(
                    json.dumps(corrupted_works, ensure_ascii=False), encoding="utf-8"
                )
                stderr = io.StringIO()
                with patch.object(provenance_linter, "WORKS_PATH", works_path):
                    with contextlib.redirect_stderr(stderr):
                        result = provenance_linter.main()

                self.assertEqual(result, 1)
                self.assertIn("SOURCE_CATALOG_BIBLIOGRAPHY", stderr.getvalue())

    def test_linter_rejects_citations_missing_from_the_source_catalog(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        sources = json.loads(
            provenance_linter.SOURCES_PATH.read_text(encoding="utf-8")
        )
        source_reference = next(
            source["sourceReference"]
            for source in sources
            if source.get("id") == "tj_literature_grade_7_2018"
        )
        sources = [
            source
            for source in sources
            if source.get("id") != "tj_literature_grade_7_2018"
        ]

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            sources_path = Path(directory) / "sources.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            sources_path.write_text(
                json.dumps(sources, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with (
                patch.object(provenance_linter, "WORKS_PATH", works_path),
                patch.object(provenance_linter, "SOURCES_PATH", sources_path),
                contextlib.redirect_stderr(stderr),
            ):
                result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("SOURCE_CATALOG_MISSING", stderr.getvalue())
        self.assertIn(source_reference, stderr.getvalue())

    def test_linter_rejects_verified_page_image_missing_from_disk(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
        )
        target["primarySource"]["sourceImagePath"] = (
            "assets/data/literature/page_images/missing-verified-page.png"
        )

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("IMAGE_EVIDENCE", stderr.getvalue())

    def test_source_citation_sync_preserves_page_evidence_and_does_not_mutate_input(self):
        source_reference = 'https://maorif.tj/storage/libraries/example.pdf'
        sources = [{
            'id': 'source-a',
            'sourceReference': source_reference,
            'bookTitle': 'Китоби расмӣ',
            'authorAsPrinted': 'Муаллифи китоб',
            'editor': 'Муҳаррир',
            'edition': 'Нашри сеюм',
            'publisher': 'Маориф',
            'city': 'Душанбе',
            'year': '2025',
            'isbn': '978-99985-00-00-0',
            'sourceType': 'official-textbook',
            'sourceInstitution': 'Вазорати маориф',
            'accessDate': '2026-09-20',
        }]
        works = [{
            'id': 'work-a',
            'textStatus': 'needsReview',
            'primarySource': {
                'sourceReference': source_reference,
                'bookTitle': 'Wrong title',
                'year': '2024',
                'accessDate': '2026-09-19',
                'pageStart': 42,
                'pageEnd': 43,
                'sourceImageVerified': True,
                'sourceImagePath': 'assets/data/literature/page_images/p42.png',
            },
            'secondarySource': {
                'sourceReference': source_reference,
                'bookTitle': 'Older title',
                'accessDate': '2026-09-18',
                'pageStart': 55,
                'pageEnd': 56,
                'sourceImagePath': 'assets/data/literature/page_images/secondary.png',
            },
            'sourceOccurrences': [{
                'sourceReference': source_reference,
                'bookTitle': 'Older title',
                'accessDate': '2026-09-17',
                'pageStart': 87,
            }],
            'textTajik': 'Муҳтавои шеър бетағйир мемонад.',
            'rights': {'status': 'unknown', 'fullTextAllowed': False},
        }]
        original = json.loads(json.dumps(works))

        plan = sync_source_citations.normalize_citations(
            works, sources, 'source-a'
        )

        self.assertEqual(works, original)
        self.assertEqual(plan.matched_citations, 3)
        self.assertEqual(plan.changed_citations, 3)
        self.assertEqual(plan.changed_fields, 30)
        citation = plan.works[0]['primarySource']
        for field in ('bookTitle', 'authorAsPrinted', 'editor', 'edition',
                      'publisher', 'city', 'year', 'isbn', 'sourceType',
                      'sourceInstitution'):
            self.assertEqual(citation[field], sources[0][field])
        self.assertEqual(citation['accessDate'], '2026-09-19')
        self.assertEqual(citation['pageStart'], 42)
        self.assertEqual(citation['pageEnd'], 43)
        self.assertTrue(citation['sourceImageVerified'])
        self.assertEqual(citation['sourceImagePath'], 'assets/data/literature/page_images/p42.png')
        secondary = plan.works[0]['secondarySource']
        self.assertEqual(secondary['bookTitle'], sources[0]['bookTitle'])
        self.assertEqual(secondary['pageStart'], 55)
        self.assertEqual(secondary['pageEnd'], 56)
        self.assertEqual(secondary['accessDate'], '2026-09-18')
        self.assertEqual(
            secondary['sourceImagePath'],
            'assets/data/literature/page_images/secondary.png',
        )
        occurrence = plan.works[0]['sourceOccurrences'][0]
        self.assertEqual(occurrence['bookTitle'], sources[0]['bookTitle'])
        self.assertEqual(occurrence['pageStart'], 87)
        self.assertEqual(occurrence['accessDate'], '2026-09-17')
        self.assertEqual(plan.works[0]['textStatus'], 'needsReview')
        self.assertEqual(plan.works[0]['textTajik'], works[0]['textTajik'])
        self.assertEqual(plan.works[0]['rights'], works[0]['rights'])

    def test_source_citation_sync_matches_trimmed_citation_references(self):
        source_reference = "https://maorif.tj/storage/libraries/example.pdf"
        sources = [{
            "id": "source-a",
            "sourceReference": source_reference,
            "bookTitle": "Китоби расмӣ",
            "publisher": "Маориф",
        }]
        works = [{
            "id": "work-a",
            "primarySource": {
                "sourceReference": f" {source_reference} ",
                "bookTitle": "Номи нодуруст",
            },
        }]

        plan = sync_source_citations.normalize_citations(works, sources, "source-a")

        self.assertEqual(plan.matched_citations, 1)
        self.assertEqual(plan.changed_citations, 1)
        self.assertEqual(plan.changed_fields, 2)
        citation = plan.works[0]["primarySource"]
        self.assertEqual(citation["bookTitle"], "Китоби расмӣ")
        self.assertEqual(citation["publisher"], "Маориф")
        self.assertEqual(citation["sourceReference"], f" {source_reference} ")

    def test_source_citation_sync_rejects_missing_or_ambiguous_source_identity(self):
        with self.assertRaisesRegex(ValueError, 'exactly one source record'):
            sync_source_citations.normalize_citations([], [], 'missing')

        duplicate_sources = [
            {'id': 'duplicate', 'sourceReference': 'https://maorif.tj/a.pdf'},
            {'id': 'duplicate', 'sourceReference': 'https://maorif.tj/b.pdf'},
        ]
        with self.assertRaisesRegex(ValueError, 'exactly one source record'):
            sync_source_citations.normalize_citations([], duplicate_sources, 'duplicate')

        with self.assertRaisesRegex(ValueError, 'source records must be objects'):
            sync_source_citations.normalize_citations([], [None], 'missing')

        with self.assertRaisesRegex(ValueError, 'sourceOccurrences must contain objects'):
            sync_source_citations.normalize_citations(
                [{'id': 'work-a', 'sourceOccurrences': [None]}],
                [{
                    'id': 'source-a',
                    'sourceReference': 'https://maorif.tj/a.pdf',
                    'bookTitle': 'Book',
                }],
                'source-a',
            )

        with self.assertRaisesRegex(ValueError, 'exactly one source record'):
            sync_source_citations.normalize_citations(
                [],
                [
                    {
                        'id': 'selected',
                        'sourceReference': 'https://maorif.tj/a.pdf',
                        'bookTitle': 'Book',
                    },
                    {
                        'id': 'ambiguous',
                        'sourceReference': 'https://maorif.tj/a.pdf ',
                        'bookTitle': 'Other book',
                    },
                ],
                'selected',
            )

        with self.assertRaisesRegex(ValueError, 'bibliographic field.*string'):
            sync_source_citations.normalize_citations(
                [],
                [{
                    'id': 'bad-metadata',
                    'sourceReference': 'https://maorif.tj/a.pdf',
                    'bookTitle': {'unexpected': 'object'},
                }],
                'bad-metadata',
            )

    def test_source_citation_sync_rejects_sources_outside_user_policy(self):
        sources = [{
            'id': 'unapproved',
            'sourceReference': 'https://example.org/book.pdf',
            'bookTitle': 'Some book',
        }]
        with self.assertRaisesRegex(ValueError, 'uploaded PDF or maorif.tj'):
            sync_source_citations.normalize_citations([], sources, 'unapproved')

    def test_atomic_source_sync_preserves_existing_file_permissions(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / 'works.json'
            target.write_text('{"old": true}\n', encoding='utf-8')
            os.chmod(target, 0o644)

            sync_source_citations._write_json_atomically(target, {'new': True})

            self.assertEqual(stat.S_IMODE(target.stat().st_mode), 0o644)

    def test_source_register_marks_unchecked_bibliography_as_non_evidence(self):
        register = Path('docs/literature/SOURCE_REGISTER.md').read_text(
            encoding='utf-8'
        )

        self.assertIn('Evidence boundary', register)
        self.assertIn('LEGACY CLAIM — UNVERIFIED IN CURRENT CHECKOUT', register)
        self.assertNotIn('CONSULTED (Witness', register)
        self.assertNotIn('ACTIVE CORE REPOSITORY', register)

    def _lint(self, works):
        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()
        return result, stderr.getvalue()

    def _text_layer_work(self, works):
        return next(
            work
            for work in works
            if work["verification"].get("verificationMethod")
            == provenance_linter.TEXT_LAYER_METHOD
        )

    def test_text_layer_extraction_is_page_evidence_at_primary_checked(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = self._text_layer_work(works)
        self.assertIsNot(target["primarySource"].get("sourceImageVerified"), True)

        result, stderr = self._lint(works)

        self.assertEqual(result, 0, stderr)

    def test_editorial_approval_still_requires_a_page_image(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = self._text_layer_work(works)
        target["verification"]["evidenceLevel"] = "editoriallyApproved"

        result, stderr = self._lint(works)

        self.assertEqual(result, 1)
        self.assertIn(f"work:{target['id']}", stderr)
        self.assertIn("PAGE_IMAGE_EVIDENCE", stderr)

    def test_text_layer_exception_needs_an_uploaded_textbook_pdf(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = self._text_layer_work(works)
        target["primarySource"]["sourceReference"] = "https://maorif.tj/book.pdf"

        result, stderr = self._lint(works)

        self.assertEqual(result, 1)
        self.assertIn(f"work:{target['id']}", stderr)

    def test_page_checked_witness_requires_verified_local_page_image(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
            and work["verification"].get("verificationMethod")
            != provenance_linter.TEXT_LAYER_METHOD
        )
        target["primarySource"]["sourceImageVerified"] = False

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("PAGE_IMAGE_EVIDENCE", stderr.getvalue())

    def test_page_image_evidence_must_resolve_to_the_declared_local_file(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
        )
        image_name = Path(target["primarySource"]["sourceImagePath"]).name
        target["primarySource"]["sourceImagePath"] = f"untrusted/{image_name}"

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("IMAGE_EVIDENCE", stderr.getvalue())

    def test_image_backed_secondary_witness_must_exist_locally(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["id"] == "7673c21c-eabd-4f67-954c-99af1028a7a7"
        )
        target["secondarySource"]["sourceImagePath"] = "missing-secondary-page.png"

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("IMAGE_EVIDENCE", stderr.getvalue())
        self.assertIn("secondarySource", stderr.getvalue())

    def test_secondary_witness_requires_explicit_collation_notes(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["id"] == "7673c21c-eabd-4f67-954c-99af1028a7a7"
        )
        target["textMatchResult"] = None
        target["variantNotes"] = None

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("SECONDARY_COLLATION", stderr.getvalue())

    def test_checked_witness_requires_complete_bibliographic_identity(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
        )
        target["primarySource"]["publisher"] = ""

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("SOURCE_BIBLIOGRAPHY", stderr.getvalue())

    def test_checked_witness_source_reference_stays_inside_approved_pdf_corpus(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
        )
        target["primarySource"]["sourceReference"] = "assets/secret.pdf"

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("SOURCE_REFERENCE", stderr.getvalue())

    def test_checked_source_pdf_must_be_in_the_pdf_manifest(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
        )
        target["primarySource"]["sourceReference"] = (
            "docs/literature/pdfs/unknown book.pdf"
        )

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("not in the PDF manifest", stderr.getvalue())

    def test_manifest_pdfs_pass_without_local_copies(self):
        # CI checks out the repository without the textbook PDFs.
        with tempfile.TemporaryDirectory() as directory:
            pdf_dir = Path(directory)
            (pdf_dir / "MANIFEST.json").write_text(
                (provenance_linter.PDF_DIR / "MANIFEST.json").read_text(
                    encoding="utf-8"
                ),
                encoding="utf-8",
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "PDF_DIR", pdf_dir):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertNotIn("SOURCE_REFERENCE", stderr.getvalue())
        self.assertEqual(result, 0, stderr.getvalue()[-2000:])

    def test_secondary_witness_requires_inspected_local_page_image(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["id"] == "7673c21c-eabd-4f67-954c-99af1028a7a7"
        )
        target["secondarySource"]["sourceImageVerified"] = False

        with tempfile.TemporaryDirectory() as directory:
            works_path = Path(directory) / "works.json"
            works_path.write_text(
                json.dumps(works, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "WORKS_PATH", works_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("PAGE_IMAGE_EVIDENCE", stderr.getvalue())

    def test_bundled_book_cover_must_exist_inside_approved_directory(self):
        app_books = json.loads(
            provenance_linter.APP_BOOKS_PATH.read_text(encoding="utf-8")
        )
        target = next(
            edition
            for book in app_books
            for edition in book["editions"]
            if edition.get("coverAssetPath")
        )
        target["coverAssetPath"] = "assets/data/books/covers/missing.jpg"

        with tempfile.TemporaryDirectory() as directory:
            books_path = Path(directory) / "books.json"
            books_path.write_text(
                json.dumps(app_books, ensure_ascii=False), encoding="utf-8"
            )
            stderr = io.StringIO()
            with patch.object(provenance_linter, "APP_BOOKS_PATH", books_path):
                with contextlib.redirect_stderr(stderr):
                    result = provenance_linter.main()

        self.assertEqual(result, 1)
        self.assertIn("BOOK_COVER_ASSET_MISSING", stderr.getvalue())


if __name__ == "__main__":
    unittest.main()
