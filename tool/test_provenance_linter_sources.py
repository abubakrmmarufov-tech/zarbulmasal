import contextlib
import io
import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from tool import provenance_linter


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

    def test_source_register_marks_unchecked_bibliography_as_non_evidence(self):
        register = Path('docs/literature/SOURCE_REGISTER.md').read_text(
            encoding='utf-8'
        )

        self.assertIn('Evidence boundary', register)
        self.assertIn('LEGACY CLAIM — UNVERIFIED IN CURRENT CHECKOUT', register)
        self.assertNotIn('CONSULTED (Witness', register)
        self.assertNotIn('ACTIVE CORE REPOSITORY', register)

    def test_page_checked_witness_requires_verified_local_page_image(self):
        works = json.loads(provenance_linter.WORKS_PATH.read_text(encoding="utf-8"))
        target = next(
            work
            for work in works
            if work["verification"]["evidenceLevel"] == "primaryChecked"
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
