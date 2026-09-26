"""Recompress the bundled portraits and book covers to WebP.

Each image is scaled down (never up) so that it just covers twice the
largest box the app draws it in, keeping its aspect ratio:
  * poet portraits: 112 x 144 on the poet page -> at most 224 x 288;
  * book covers: 116 x 170 on the book page -> at most 232 x 340.
The JSON records that name an image are rewritten to the .webp path and the
original file is removed.

Usage:
    python3 tool/design/compress_images.py [--quality 80]
"""
import argparse
import json
import os
import sys

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# (directory, JSON file, (width, height) of the largest box shown, in dp)
TARGETS = [
    ('assets/data/literature/portraits', 'assets/data/literature/poets.json', (112, 144)),
    ('assets/data/books/covers', 'assets/data/books/books.json', (116, 170)),
]
SCALE = 2
IMAGE_EXTENSIONS = ('.jpg', '.jpeg', '.png', '.webp')


def target_size(size, box):
    """The size that just covers [box] at the same aspect ratio, never
    larger than [size]."""
    width, height = size
    box_w, box_h = box
    scale = min(1.0, max(box_w / width, box_h / height))
    return max(1, round(width * scale)), max(1, round(height * scale))


def to_webp(path, box, quality):
    """Writes [path] as a WebP bounded by [box]; returns the new path."""
    stem, _ = os.path.splitext(path)
    out = stem + '.webp'
    with Image.open(path) as image:
        image.load()
        if image.mode not in ('RGB', 'RGBA'):
            image = image.convert('RGB')
        size = target_size(image.size, box)
        if size != image.size:
            image = image.resize(size, Image.Resampling.LANCZOS)
        image.save(out, 'WEBP', quality=quality, method=6)
    if out != path:
        os.remove(path)
    return out


def rewrite_paths(text, renamed):
    """Replaces every old asset path in [text] with its .webp path."""
    for old, new in renamed.items():
        text = text.replace(f'"{old}"', f'"{new}"')
    return text


def compress(root, quality):
    report = []
    for directory, json_file, box in TARGETS:
        limit = (box[0] * SCALE, box[1] * SCALE)
        folder = os.path.join(root, directory)
        json_path = os.path.join(root, json_file)
        with open(json_path, encoding='utf-8') as handle:
            text = handle.read()
        names = [n for n in sorted(os.listdir(folder))
                 if n.lower().endswith(IMAGE_EXTENSIONS)]
        # Every image must be named by the JSON before anything is changed.
        unnamed = [n for n in names if f'"{directory}/{n}"' not in text]
        if unnamed:
            raise SystemExit(f'{json_file} does not name: {unnamed[:3]}')
        renamed = {}
        before = after = 0
        for name in names:
            path = os.path.join(folder, name)
            before += os.path.getsize(path)
            out = to_webp(path, limit, quality)
            after += os.path.getsize(out)
            if out != path:
                renamed[f'{directory}/{name}'] = f'{directory}/{os.path.basename(out)}'
        new_text = rewrite_paths(text, renamed)
        json.loads(new_text)
        with open(json_path, 'w', encoding='utf-8') as handle:
            handle.write(new_text)
        report.append((directory, len(renamed), before, after))
    return report


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--quality', type=int, default=80)
    args = parser.parse_args(argv)
    for directory, count, before, after in compress(ROOT, args.quality):
        print(f'{directory}: {count} files, {before:,} -> {after:,} bytes')
    return 0


if __name__ == '__main__':
    sys.exit(main())
