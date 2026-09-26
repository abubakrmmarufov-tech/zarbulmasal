"""Build every app icon from the owner's master image.

Master: docs/design/icon final.png (a navy square, a coral ikat diamond with
a cream centre). Outputs:
  * Android adaptive icon (API 26+): a solid background colour sampled from
    the master, a foreground whose diamond is scaled into the 66 dp safe
    circle of the 108 dp layer (no launcher mask can clip it), and a
    monochrome layer for themed icons; mipmap-anydpi-v26/ic_launcher.xml;
  * legacy launcher icons (mipmap-*/ic_launcher.webp, lossless);
  * the Play Store icon, 512 x 512 PNG;
  * web: Icon-192/512, the maskable pair (diamond inside the 80% safe
    circle) and favicon.png;
  * assets/branding: the master at 1024 px and the adaptive layers;
  * the launch background colour (Android launch screen and the web app's
    splash), set to the icon's navy.

Usage:
    python3 tool/design/build_icons.py
"""
import math
import os
import re
import sys
from collections import Counter

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
MASTER = 'docs/design/icon final.png'
RES = 'android/app/src/main/res'

# Android adaptive icon geometry, in dp.
LAYER_DP = 108
SAFE_RADIUS_DP = 33
TARGET_RADIUS_DP = 31          # the diamond's farthest pixel, with margin
DENSITIES = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}
LEGACY_DP = 48
# Web maskable icons keep content inside a circle of 40% of the size.
MASKABLE_RADIUS = 0.36
# Pixels closer than this (RGB distance) to the navy are background.
NAVY_TOLERANCE = 24


def to_hex(color):
    return '#{:02X}{:02X}{:02X}'.format(*color[:3])


def background_color(image):
    """The most common colour on the master's outer edge."""
    rgb = image.convert('RGB')
    w, h = rgb.size
    px = rgb.load()
    edge = ([px[x, 0] for x in range(w)] + [px[x, h - 1] for x in range(w)]
            + [px[0, y] for y in range(h)] + [px[w - 1, y] for y in range(h)])
    return Counter(edge).most_common(1)[0][0]


def palette(image, navy):
    """(coral, cream): the most common saturated and light colours."""
    rgb = image.convert('RGB')
    counts = Counter(rgb.get_flattened_data() if hasattr(rgb, 'get_flattened_data')
                     else rgb.getdata())
    coral = cream = None
    for color, _ in counts.most_common():
        if _distance(color, navy) < 80:
            continue
        r, g, b = color
        if coral is None and r - b > 100:
            coral = color
        if cream is None and min(r, g, b) > 190:
            cream = color
        if coral and cream:
            break
    return coral, cream


def _distance(a, b):
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(a[:3], b[:3])))


def key_out(image, navy, colors, tolerance=NAVY_TOLERANCE):
    """RGBA copy where the navy becomes transparent. A pixel that blends
    navy with one of [colors] (anti-aliased edges) becomes that colour with
    the blend's share as alpha, so the diamond keeps soft edges on any
    background; every other pixel stays opaque."""
    rgb = image.convert('RGB')
    out = Image.new('RGBA', rgb.size)
    src = rgb.load()
    dst = out.load()
    w, h = rgb.size
    for y in range(h):
        for x in range(w):
            dst[x, y] = _unmix(src[x, y], navy, colors, tolerance)
    return out


def _unmix(pixel, navy, colors, tolerance):
    if _distance(pixel, navy) <= tolerance:
        return (0, 0, 0, 0)
    best = None
    for color in colors:
        axis = [c - n for c, n in zip(color, navy)]
        length = sum(a * a for a in axis)
        share = sum((p - n) * a for p, n, a in zip(pixel, navy, axis)) / length
        mixed = [n + share * a for n, a in zip(navy, axis)]
        residual = math.sqrt(sum((p - m) ** 2 for p, m in zip(pixel, mixed)))
        if best is None or residual < best[0]:
            best = (residual, share, color)
    residual, share, color = best
    if share >= 0.97 or residual > 30:
        return tuple(pixel[:3]) + (255,)
    return tuple(color) + (max(1, round(max(0.0, share) * 255)),)


def content_radius(rgba, center=None):
    """Distance from the centre to the farthest visible pixel."""
    w, h = rgba.size
    cx, cy = center or ((w - 1) / 2, (h - 1) / 2)
    alpha = rgba.getchannel('A').load()
    far = 0.0
    for y in range(h):
        for x in range(w):
            if alpha[x, y] > 16:
                far = max(far, math.hypot(x - cx, y - cy))
    return far


def place(layer_px, art, art_radius, target_radius_px, fill=None):
    """A square [layer_px] canvas with [art] scaled so its content radius is
    [target_radius_px], centred; [fill] paints the canvas first."""
    scale = target_radius_px / art_radius
    size = max(1, round(art.width * scale))
    scaled = art.resize((size, size), Image.Resampling.LANCZOS)
    canvas = Image.new('RGBA', (layer_px, layer_px), fill or (0, 0, 0, 0))
    offset = (layer_px - size) // 2
    canvas.alpha_composite(scaled, (offset, offset))
    return canvas


def monochrome(foreground):
    """White where the foreground is visible; Android tints it."""
    mask = foreground.getchannel('A')
    out = Image.new('RGBA', foreground.size, (255, 255, 255, 0))
    out.putalpha(mask)
    return out


def rounded(image, radius_fraction):
    """[image] with rounded corners (transparent outside)."""
    w, h = image.size
    scale = 4
    mask = Image.new('L', (w * scale, h * scale), 0)
    from PIL import ImageDraw
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, w * scale - 1, h * scale - 1),
        radius=round(min(w, h) * radius_fraction * scale), fill=255)
    mask = mask.resize((w, h), Image.Resampling.LANCZOS)
    out = image.convert('RGBA')
    out.putalpha(mask)
    return out


def replace_color(path, name, value):
    """Sets <color name="[name]"> in a colors.xml, adding it if missing."""
    with open(path, encoding='utf-8') as handle:
        text = handle.read()
    tag = f'<color name="{name}">{value}</color>'
    pattern = re.compile(rf'<color name="{re.escape(name)}">[^<]*</color>')
    if pattern.search(text):
        text = pattern.sub(tag, text)
    else:
        text = text.replace('</resources>', f'    {tag}\n</resources>')
    with open(path, 'w', encoding='utf-8') as handle:
        handle.write(text)


def set_manifest_color(path, key, value):
    """Sets a "[key]": "#RRGGBB" entry of a web manifest in place, keeping
    the file's layout."""
    with open(path, encoding='utf-8') as handle:
        text = handle.read()
    pattern = re.compile(rf'("{re.escape(key)}"\s*:\s*)"[^"]*"')
    if not pattern.search(text):
        raise ValueError(f'{path} has no "{key}"')
    with open(path, 'w', encoding='utf-8') as handle:
        handle.write(pattern.sub(lambda m: f'{m.group(1)}"{value}"', text, count=1))


ADAPTIVE_XML = """<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background"/>
  <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
  <monochrome android:drawable="@mipmap/ic_launcher_monochrome"/>
</adaptive-icon>
"""


def build(root=ROOT):
    master = Image.open(os.path.join(root, MASTER)).convert('RGB')
    navy = background_color(master)
    coral, cream = palette(master, navy)
    art = key_out(master, navy, (coral, cream))
    radius = content_radius(art)
    report = {'navy': to_hex(navy), 'coral': to_hex(coral), 'cream': to_hex(cream)}

    res = os.path.join(root, RES)
    for density, factor in DENSITIES.items():
        folder = os.path.join(res, f'mipmap-{density}')
        os.makedirs(folder, exist_ok=True)
        layer = round(LAYER_DP * factor)
        foreground = place(layer, art, radius, TARGET_RADIUS_DP * factor)
        foreground.save(os.path.join(folder, 'ic_launcher_foreground.webp'),
                        'WEBP', lossless=True, method=6)
        monochrome(foreground).save(
            os.path.join(folder, 'ic_launcher_monochrome.webp'),
            'WEBP', lossless=True, method=6)
        legacy = master.resize((round(LEGACY_DP * factor),) * 2,
                               Image.Resampling.LANCZOS)
        rounded(legacy, 0.18).save(os.path.join(folder, 'ic_launcher.webp'),
                                   'WEBP', lossless=True, method=6)
        old = os.path.join(folder, 'ic_launcher.png')
        if os.path.exists(old):
            os.remove(old)
        old_drawable = os.path.join(res, f'drawable-{density}', 'ic_launcher_foreground.png')
        if os.path.exists(old_drawable):
            os.remove(old_drawable)
            try:
                os.rmdir(os.path.dirname(old_drawable))
            except OSError:
                pass
    anydpi = os.path.join(res, 'mipmap-anydpi-v26')
    os.makedirs(anydpi, exist_ok=True)
    with open(os.path.join(anydpi, 'ic_launcher.xml'), 'w', encoding='utf-8') as handle:
        handle.write(ADAPTIVE_XML)
    replace_color(os.path.join(res, 'values', 'colors.xml'), 'ic_launcher_background', to_hex(navy))
    replace_color(os.path.join(res, 'values', 'colors.xml'), 'launch_background', to_hex(navy))
    replace_color(os.path.join(res, 'values-night', 'colors.xml'), 'launch_background', to_hex(navy))

    web = os.path.join(root, 'web')
    set_manifest_color(os.path.join(web, 'manifest.json'), 'background_color', to_hex(navy))
    full = master.convert('RGBA')
    for size in (192, 512):
        full.resize((size, size), Image.Resampling.LANCZOS).save(
            os.path.join(web, 'icons', f'Icon-{size}.png'), optimize=True)
        place(size, art, radius, size * MASKABLE_RADIUS, fill=navy + (255,)).save(
            os.path.join(web, 'icons', f'Icon-maskable-{size}.png'), optimize=True)
    full.resize((32, 32), Image.Resampling.LANCZOS).save(
        os.path.join(web, 'favicon.png'), optimize=True)

    store = os.path.join(root, 'docs', 'store')
    os.makedirs(store, exist_ok=True)
    full.resize((512, 512), Image.Resampling.LANCZOS).convert('RGB').save(
        os.path.join(store, 'play_icon_512.png'), optimize=True)

    branding = os.path.join(root, 'assets', 'branding')
    os.makedirs(branding, exist_ok=True)
    full.resize((1024, 1024), Image.Resampling.LANCZOS).convert('RGB').save(
        os.path.join(branding, 'zarbulmasal_icon.png'), optimize=True)
    big = place(432, art, radius, TARGET_RADIUS_DP * 4)
    big.save(os.path.join(branding, 'adaptive_foreground_432.png'), optimize=True)
    monochrome(big).save(os.path.join(branding, 'adaptive_monochrome_432.png'), optimize=True)
    return report


def main():
    report = build()
    for name, value in report.items():
        print(f'{name}: {value}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
