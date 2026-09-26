import io
import json
import os
import sys
import tempfile
import unittest

from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
import fetch_covers as fc  # noqa: E402


def png(width, height, color=(120, 40, 30)):
    buffer = io.BytesIO()
    Image.new('RGB', (width, height), color).save(buffer, 'PNG')
    return buffer.getvalue()


def jpeg(width, height, color=(20, 40, 90)):
    """A cover-like image: a field with a lighter band across it."""
    image = Image.new('RGB', (width, height), color)
    image.paste((230, 220, 200), (0, height // 3, width, height // 2))
    buffer = io.BytesIO()
    image.save(buffer, 'JPEG')
    return buffer.getvalue()


class CoverUrlTest(unittest.TestCase):
    def test_reads_og_image(self):
        html = ('<head><meta property="og:image" '
                'content="https://kitobkhon.net/storage/covers/a.jpg"></head>')
        self.assertEqual(fc.cover_url_from_page(html, 'https://kitobkhon.net/book/a'),
                         'https://kitobkhon.net/storage/covers/a.jpg')

    def test_the_site_placeholder_is_no_cover(self):
        html = ('<meta property="og:image" '
                'content="https://kitobkhon.net/images/cover.png">'
                '<img src="https://kitobkhon.net/images/cover.png" '
                'class="cover-default">')
        self.assertIsNone(fc.cover_url_from_page(html, 'https://kitobkhon.net/book/a'))

    def test_khirad_cover(self):
        html = ('<meta property="og:image" '
                'content="https://khirad.tj/img/books/navruznoma.jpg">')
        self.assertEqual(fc.cover_url_from_page(html, 'https://khirad.tj/books/navruznoma'),
                         'https://khirad.tj/img/books/navruznoma.jpg')

    def test_relative_og_image_is_resolved(self):
        html = '<meta content="/storage/covers/b.jpg" property="og:image">'
        self.assertEqual(fc.cover_url_from_page(html, 'https://kitobkhon.net/book/b'),
                         'https://kitobkhon.net/storage/covers/b.jpg')

    def test_a_page_without_og_image_has_no_cover(self):
        self.assertIsNone(fc.cover_url_from_page('<html></html>', 'https://x.tj/b'))

    def test_only_the_book_sites_are_trusted(self):
        html = '<meta property="og:image" content="https://evil.example/a.jpg">'
        self.assertIsNone(fc.cover_url_from_page(html, 'https://kitobkhon.net/book/a'))


class ImageCheckTest(unittest.TestCase):
    def test_accepts_a_real_cover(self):
        verdict = fc.check_image(jpeg(300, 450), 'image/jpeg')
        self.assertEqual(verdict['status'], 'ok')
        self.assertEqual((verdict['width'], verdict['height']), (300, 450))
        self.assertEqual(verdict['format'], 'JPEG')

    def test_rejects_an_html_error_page(self):
        verdict = fc.check_image(b'<!DOCTYPE html><title>404</title>', 'text/html')
        self.assertEqual(verdict['status'], 'rejected')
        self.assertIn('content type', verdict['reason'])

    def test_rejects_bytes_that_do_not_decode(self):
        verdict = fc.check_image(b'\xff\xd8\xff garbage', 'image/jpeg')
        self.assertEqual(verdict['status'], 'rejected')
        self.assertIn('decode', verdict['reason'])

    def test_rejects_a_tiny_placeholder(self):
        verdict = fc.check_image(png(40, 60), 'image/png')
        self.assertEqual(verdict['status'], 'rejected')
        self.assertIn('small', verdict['reason'])

    def test_rejects_a_single_colour_image(self):
        blank = png(300, 450, (255, 255, 255))
        verdict = fc.check_image(blank, 'image/png')
        self.assertEqual(verdict['status'], 'rejected')
        self.assertIn('blank', verdict['reason'])


class PlaceholderTest(unittest.TestCase):
    def test_an_image_shared_by_many_books_is_a_placeholder(self):
        results = {k: {'status': 'ok', 'sha256': 'x'} for k in 'abcdef'}
        results['g'] = {'status': 'ok', 'sha256': 'y'}
        marked = fc.reject_shared_images(results)
        self.assertEqual(marked['a']['status'], 'rejected')
        self.assertIn('placeholder', marked['a']['reason'])
        self.assertEqual(marked['g']['status'], 'ok')
        # The input is not changed.
        self.assertEqual(results['a']['status'], 'ok')

    def test_volumes_of_a_series_may_share_their_cover(self):
        results = {k: {'status': 'ok', 'sha256': 'x'} for k in 'abc'}
        marked = fc.reject_shared_images(results)
        self.assertTrue(all(r['status'] == 'ok' for r in marked.values()))


class FakeClient:
    def __init__(self, answers):
        self.answers = answers
        self.asked = []

    def get(self, url):
        self.asked.append(url)
        return self.answers[url]


class CoverStepTest(unittest.TestCase):
    def test_the_page_decides_a_recorded_url_is_not_used(self):
        edition = {'id': 'e', 'sourceUrl': 'https://kitobkhon.net/book/e',
                   'coverUrl': 'https://kitobkhon.net/storage/covers/other.jpg'}
        record = {'pageCoverUrl': None}
        client = FakeClient({})
        with tempfile.TemporaryDirectory() as folder:
            fc._cover_step(client, edition, record, folder)
        self.assertEqual(client.asked, [])
        self.assertEqual(record['result']['status'], 'none')
        self.assertIn('shows no cover', record['result']['reason'])

    def test_the_page_cover_is_downloaded_and_kept(self):
        url = 'https://kitobkhon.net/storage/covers/e.jpg'
        edition = {'id': 'e', 'sourceUrl': 'https://kitobkhon.net/book/e'}
        record = {'pageCoverUrl': url}
        client = FakeClient({url: (200, 'image/jpeg', jpeg(300, 450), None)})
        with tempfile.TemporaryDirectory() as folder:
            fc._cover_step(client, edition, record, folder)
            self.assertEqual(record['result']['status'], 'ok')
            self.assertTrue(os.path.exists(record['result']['file']))


class AssetNameTest(unittest.TestCase):
    def test_single_edition_books_use_the_book_id(self):
        books = [{'id': 'badi-boron', 'editions': [{'id': 'badi-boron-kitobkhon-1978'}]}]
        self.assertEqual(fc.asset_names(books),
                         {'badi-boron-kitobkhon-1978': 'badi-boron'})

    def test_books_with_several_editions_use_the_edition_id(self):
        books = [{'id': 'b', 'editions': [{'id': 'b-1'}, {'id': 'b-2'}]}]
        self.assertEqual(fc.asset_names(books), {'b-1': 'b-1', 'b-2': 'b-2'})


class StateTest(unittest.TestCase):
    def test_state_survives_a_restart(self):
        with tempfile.TemporaryDirectory() as folder:
            path = os.path.join(folder, 'state.json')
            state = fc.load_state(path)
            self.assertEqual(state, {})
            fc.save_state(path, {'e1': {'page': {'status': 200}}})
            self.assertEqual(fc.load_state(path), {'e1': {'page': {'status': 200}}})
            with open(path, encoding='utf-8') as handle:
                json.load(handle)

    def test_dead_links(self):
        state = {
            'e1': {'page': {'url': 'p1', 'status': 404}, 'cover': {'url': 'c1', 'status': 200}},
            'e2': {'page': {'url': 'p2', 'status': 200}, 'cover': {'url': 'c2', 'status': 404}},
            'e3': {'page': {'url': 'p3', 'status': 200}, 'cover': {'url': 'c3', 'status': 200}},
            'e4': {'page': {'url': 'p4', 'status': None, 'error': 'timeout'}},
        }
        dead = fc.dead_links(state)
        self.assertEqual([(d['editionId'], d['kind']) for d in dead],
                         [('e1', 'page'), ('e2', 'cover'), ('e4', 'page')])


if __name__ == '__main__':
    unittest.main()
