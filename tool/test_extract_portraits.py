import json
import sys
import tempfile
import unittest
from pathlib import Path

try:
    from tool.literature_pipeline.scripts import extract_portraits
except ModuleNotFoundError:
    sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
    from literature_pipeline.scripts import extract_portraits


class ExtractPortraitsTest(unittest.TestCase):
    def test_bundled_portraits_are_all_referenced_by_poets(self):
        poets = json.loads(
            (extract_portraits.ROOT / "assets/data/literature/poets.json").read_text(
                encoding="utf-8"
            )
        )
        referenced = {
            extract_portraits.ROOT / poet["portrait"]["assetPath"]
            for poet in poets
            if isinstance(poet.get("portrait"), dict)
            and isinstance(poet["portrait"].get("assetPath"), str)
        }
        bundled = set(
            (extract_portraits.ROOT / "assets/data/literature/portraits").glob("*")
        )
        self.assertEqual(bundled, referenced)

    def test_manifest_is_explicit_and_unique(self):
        entries = extract_portraits.load_manifest()
        self.assertEqual(len(entries), 67)
        self.assertEqual(len({entry["authorId"] for entry in entries}), 67)
        by_author = {entry["authorId"]: entry for entry in entries}
        self.assertEqual(
            (by_author["1a55efdd-6a1f-43b8-834f-94af060b4329"]["pdf"], by_author["1a55efdd-6a1f-43b8-834f-94af060b4329"]["pdfPage"]),
            ("adabiet sinfi 5.pdf", 62),
        )
        self.assertEqual(
            (by_author["3ec91317-fcfe-4960-9ca0-fd87f3e96875"]["pdf"], by_author["3ec91317-fcfe-4960-9ca0-fd87f3e96875"]["pdfPage"]),
            ("adabiet sinfi 5.pdf", 100),
        )
        self.assertTrue(all(Path(entry["pdf"]).name == entry["pdf"] for entry in entries))

    def test_manifest_matches_poet_assets_and_provenance(self):
        root = extract_portraits.ROOT
        poets = json.loads(
            (root / "assets/data/literature/poets.json").read_text(
                encoding="utf-8"
            )
        )
        entries = extract_portraits.load_manifest()
        poet_by_id = {poet["id"]: poet for poet in poets}
        portrait_poets = {
            poet["id"]: poet
            for poet in poets
            if isinstance(poet.get("portrait"), dict)
        }

        self.assertEqual(set(portrait_poets), {entry["authorId"] for entry in entries})
        for entry in entries:
            poet = poet_by_id[entry["authorId"]]
            portrait = poet["portrait"]
            asset_path = portrait["assetPath"]
            self.assertTrue(
                asset_path.startswith("assets/data/literature/portraits/"),
                entry["authorId"],
            )
            self.assertTrue((root / asset_path).is_file(), asset_path)
            self.assertIn(
                portrait["sourceType"],
                {"uploaded_book", "user_upload", "maorif_tj"},
            )
            self.assertIsInstance(portrait["sourcePage"], int)
            self.assertGreater(portrait["sourcePage"], 0)
            source_reference = portrait["sourceReference"]
            self.assertTrue(
                source_reference.startswith("docs/literature/pdfs/")
                or "maorif.tj" in source_reference,
                source_reference,
            )
            self.assertEqual(portrait["rightsStatus"], "unknown")

    def test_duplicate_author_mapping_is_rejected(self):
        with tempfile.TemporaryDirectory() as directory:
            manifest = Path(directory) / "manifest.json"
            manifest.write_text(
                json.dumps([
                    {"authorId": "one", "pdf": "book.pdf", "pdfPage": 1},
                    {"authorId": "one", "pdf": "book.pdf", "pdfPage": 2},
                ]),
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "duplicate portrait authorId"):
                extract_portraits.load_manifest(manifest)

    def test_manifest_rejects_path_traversal_pdf_names(self):
        with tempfile.TemporaryDirectory() as directory:
            manifest = Path(directory) / "manifest.json"
            manifest.write_text(
                json.dumps([
                    {"authorId": "one", "pdf": "../book.pdf", "pdfPage": 1},
                ]),
                encoding="utf-8",
            )
            with self.assertRaisesRegex(ValueError, "PDF must be a basename"):
                extract_portraits.load_manifest(manifest)

    def test_portrait_extraction_ignores_unpainted_image_resources(self):
        class FakePage:
            def get_image_info(self, *, xrefs):
                self.assert_xrefs = xrefs
                return [
                    {"xref": 11, "bbox": (0, 0, 0, 0)},
                    {"xref": 12, "bbox": (10, 10, 120, 300)},
                ]

        class FakeDocument:
            def __init__(self):
                self.page = FakePage()
                self.extracted_xrefs = []

            def load_page(self, page_number):
                if page_number != 0:
                    raise AssertionError(f"unexpected page number: {page_number}")
                return self.page

            def extract_image(self, xref):
                self.extracted_xrefs.append(xref)
                return {
                    "image": b"visible-portrait",
                    "ext": "jpeg",
                    "width": 110,
                    "height": 290,
                }

        document = FakeDocument()
        image, extension, width, height = extract_portraits._portrait_image(
            document,
            1,
        )

        self.assertEqual(document.extracted_xrefs, [12])
        self.assertEqual(image, b"visible-portrait")
        self.assertEqual(extension, "jpeg")
        self.assertEqual((width, height), (110, 290))

    def test_normalize_portrait_inverts_a_detected_negative(self):
        from io import BytesIO

        from PIL import Image

        source = Image.new("RGB", (4, 4), "black")
        source.putpixel((2, 2), (255, 255, 255))
        raw = BytesIO()
        source.save(raw, format="PNG")

        normalized = extract_portraits.normalize_portrait(raw.getvalue(), "png")
        with Image.open(BytesIO(normalized)) as image:
            self.assertEqual(image.getpixel((0, 0)), (255, 255, 255))
            self.assertEqual(image.getpixel((2, 2)), (0, 0, 0))


if __name__ == "__main__":
    unittest.main()
