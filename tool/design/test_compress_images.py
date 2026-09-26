import json
import os
import sys
import tempfile
import unittest

from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import compress_images  # noqa: E402


class TargetSizeTest(unittest.TestCase):
    def test_scales_down_to_just_cover_the_box(self):
        self.assertEqual(compress_images.target_size((446, 569), (224, 288)),
                         (226, 288))
        self.assertEqual(compress_images.target_size((579, 811), (232, 340)),
                         (243, 340))

    def test_never_scales_up(self):
        self.assertEqual(compress_images.target_size((128, 179), (224, 288)),
                         (128, 179))

    def test_a_wide_image_keeps_its_height_at_the_box(self):
        self.assertEqual(compress_images.target_size((800, 400), (224, 288)),
                         (576, 288))


class CompressTest(unittest.TestCase):
    def setUp(self):
        self.root = tempfile.mkdtemp()
        self.folder = os.path.join(self.root, 'img')
        os.makedirs(self.folder)
        Image.new('RGB', (500, 640), 'red').save(
            os.path.join(self.folder, 'a.jpeg'), 'JPEG')
        Image.new('RGB', (100, 120), 'blue').save(
            os.path.join(self.folder, 'b.jpg'), 'JPEG')
        self.json_path = os.path.join(self.root, 'records.json')
        with open(self.json_path, 'w', encoding='utf-8') as handle:
            json.dump([{'assetPath': 'img/a.jpeg'},
                       {'assetPath': 'img/b.jpg'}], handle)
        self.targets = compress_images.TARGETS
        compress_images.TARGETS = [('img', 'records.json', (112, 144))]

    def tearDown(self):
        compress_images.TARGETS = self.targets

    def test_writes_bounded_webp_and_rewrites_paths(self):
        report = compress_images.compress(self.root, 80)
        self.assertEqual(report[0][:2], ('img', 2))
        self.assertEqual(sorted(os.listdir(self.folder)), ['a.webp', 'b.webp'])
        with Image.open(os.path.join(self.folder, 'a.webp')) as image:
            self.assertEqual(image.format, 'WEBP')
            self.assertEqual(image.size, (225, 288))
        with Image.open(os.path.join(self.folder, 'b.webp')) as image:
            self.assertEqual(image.size, (100, 120))
        with open(self.json_path, encoding='utf-8') as handle:
            records = json.load(handle)
        self.assertEqual([r['assetPath'] for r in records],
                         ['img/a.webp', 'img/b.webp'])

    def test_a_second_run_leaves_finished_webp_untouched(self):
        compress_images.compress(self.root, 80)
        path = os.path.join(self.folder, 'a.webp')
        with open(path, 'rb') as handle:
            first = handle.read()
        report = compress_images.compress(self.root, 80)
        with open(path, 'rb') as handle:
            self.assertEqual(handle.read(), first)
        self.assertEqual(report[0][1], 0)

    def test_an_oversized_webp_is_still_reduced(self):
        Image.new('RGB', (900, 1200), 'green').save(
            os.path.join(self.folder, 'c.webp'), 'WEBP')
        with open(self.json_path, 'w', encoding='utf-8') as handle:
            json.dump([{'assetPath': 'img/a.jpeg'}, {'assetPath': 'img/b.jpg'},
                       {'assetPath': 'img/c.webp'}], handle)
        compress_images.compress(self.root, 80)
        with Image.open(os.path.join(self.folder, 'c.webp')) as image:
            self.assertEqual(image.size, (224, 299))

    def test_refuses_an_image_no_record_names(self):
        Image.new('RGB', (10, 10)).save(
            os.path.join(self.folder, 'orphan.png'), 'PNG')
        with self.assertRaises(SystemExit):
            compress_images.compress(self.root, 80)
        self.assertIn('a.jpeg', os.listdir(self.folder))


if __name__ == '__main__':
    unittest.main()
