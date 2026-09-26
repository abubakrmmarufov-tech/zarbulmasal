import os
import sys
import tempfile
import unittest

from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(__file__))
import build_icons as bi  # noqa: E402

NAVY = (11, 20, 39)
CORAL = (237, 106, 77)
CREAM = (241, 231, 211)


def master(size=200):
    """A small stand-in for the master: navy, a coral diamond, cream centre."""
    image = Image.new('RGB', (size, size), NAVY)
    draw = ImageDraw.Draw(image)
    c, r = size / 2, size * 0.42
    draw.polygon([(c, c - r), (c + r * 0.8, c), (c, c + r), (c - r * 0.8, c)], fill=CORAL)
    draw.polygon([(c, c - r / 3), (c + r / 4, c), (c, c + r / 3), (c - r / 4, c)], fill=CREAM)
    return image


class IconTest(unittest.TestCase):
    def test_samples_the_navy_and_the_palette(self):
        image = master()
        self.assertEqual(bi.background_color(image), NAVY)
        self.assertEqual(bi.palette(image, NAVY), (CORAL, CREAM))
        self.assertEqual(bi.to_hex(NAVY), '#0B1427')

    def test_navy_becomes_transparent_and_the_diamond_stays(self):
        keyed = bi.key_out(master(), NAVY, (CORAL, CREAM))
        self.assertEqual(keyed.getpixel((2, 2))[3], 0)
        self.assertEqual(keyed.getpixel((100, 100)), CREAM + (255,))
        coral = keyed.getpixel((100, 40))
        self.assertEqual(coral[3], 255)
        self.assertEqual(coral[:3], CORAL)

    def test_a_mixed_edge_pixel_gets_its_colour_back(self):
        mixed = tuple(round((c + n) / 2) for c, n in zip(CORAL, NAVY))
        image = Image.new('RGB', (3, 3), NAVY)
        image.putpixel((1, 1), mixed)
        pixel = bi.key_out(image, NAVY, (CORAL, CREAM)).getpixel((1, 1))
        self.assertAlmostEqual(pixel[3], 128, delta=3)
        for got, want in zip(pixel[:3], CORAL):
            self.assertAlmostEqual(got, want, delta=4)

    def test_the_foreground_fits_the_safe_zone_at_every_density(self):
        art = bi.key_out(master(), NAVY, (CORAL, CREAM))
        radius = bi.content_radius(art)
        for factor in bi.DENSITIES.values():
            layer = round(bi.LAYER_DP * factor)
            foreground = bi.place(layer, art, radius, bi.TARGET_RADIUS_DP * factor)
            self.assertEqual(foreground.size, (layer, layer))
            reach = bi.content_radius(foreground)
            self.assertLessEqual(reach, bi.SAFE_RADIUS_DP * factor)
            self.assertGreater(reach, (bi.TARGET_RADIUS_DP - 2) * factor)

    def test_monochrome_is_white_where_the_foreground_shows(self):
        art = bi.key_out(master(), NAVY, (CORAL, CREAM))
        mono = bi.monochrome(art)
        self.assertEqual(mono.getpixel((2, 2))[3], 0)
        self.assertEqual(mono.getpixel((100, 40)), (255, 255, 255, 255))

    def test_replace_color_sets_or_adds(self):
        with tempfile.TemporaryDirectory() as folder:
            path = os.path.join(folder, 'colors.xml')
            with open(path, 'w') as handle:
                handle.write('<resources>\n    <color name="a">#000000</color>\n</resources>\n')
            bi.replace_color(path, 'a', '#0B1427')
            bi.replace_color(path, 'b', '#F1E7D3')
            text = open(path).read()
            self.assertIn('<color name="a">#0B1427</color>', text)
            self.assertIn('<color name="b">#F1E7D3</color>', text)

    def test_manifest_colour_is_set_in_place(self):
        with tempfile.TemporaryDirectory() as folder:
            path = os.path.join(folder, 'manifest.json')
            with open(path, 'w') as handle:
                handle.write('{\n  "background_color": "#F3ECDD",\n  "theme_color": "#1A1714"\n}\n')
            bi.set_manifest_color(path, 'background_color', '#0B1427')
            self.assertEqual(
                open(path).read(),
                '{\n  "background_color": "#0B1427",\n  "theme_color": "#1A1714"\n}\n')
            with self.assertRaises(ValueError):
                bi.set_manifest_color(path, 'missing', '#000000')


if __name__ == '__main__':
    unittest.main()
