"""Builds the bundled «Муҳр» typefaces from the upstream Google Fonts files.

Upstream sources (SIL OFL 1.1): https://github.com/google/fonts/tree/main/ofl
  ebgaramond, ptserif, golostext, notonastaliqurdu, vazirmatn

Each variable font is instanced at the weights the design system uses, then
subset to the scripts it serves (Cyrillic + Latin, or Arabic + Latin) while
keeping every OpenType layout feature (Nastaliq and Naskh shaping depend on
them). Static instances avoid variable-axis quirks in Flutter and keep the
offline bundle small.

Usage:
  python3 tool/design/build_fonts.py <upstream_dir> assets/fonts
Requires fontTools (pip install fonttools).
"""

import shutil
import sys
from pathlib import Path

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer


def ranges(*spans):
    out = set()
    for span in spans:
        start, end = span if isinstance(span, tuple) else (span, span)
        out.update(range(start, end + 1))
    return out


LATIN = ranges(
    (0x20, 0x7E), (0xA0, 0xFF), (0x2010, 0x2027), (0x2030, 0x203A),
    (0x2190, 0x2193), 0x2116, 0x2212,
)
CYRILLIC = LATIN | ranges((0x300, 0x36F), (0x400, 0x52F))
ARABIC = LATIN | ranges(
    (0x600, 0x6FF), (0x750, 0x77F), (0xFB50, 0xFDFF), (0xFE70, 0xFEFF),
    (0x200C, 0x200F), (0x2066, 0x2069),
)

# (source file, output name, wght instance or None for static, unicodes)
BUILDS = [
    ("EBGaramond.ttf", "EBGaramond-Medium.ttf", 500, CYRILLIC),
    ("EBGaramond.ttf", "EBGaramond-SemiBold.ttf", 600, CYRILLIC),
    ("EBGaramond-Italic.ttf", "EBGaramond-Italic.ttf", 400, CYRILLIC),
    ("PTSerif.ttf", "PTSerif-Regular.ttf", None, CYRILLIC),
    ("PTSerif-Bold.ttf", "PTSerif-Bold.ttf", None, CYRILLIC),
    ("PTSerif-Italic.ttf", "PTSerif-Italic.ttf", None, CYRILLIC),
    ("GolosText.ttf", "GolosText-Regular.ttf", 400, CYRILLIC),
    ("GolosText.ttf", "GolosText-Medium.ttf", 500, CYRILLIC),
    ("GolosText.ttf", "GolosText-SemiBold.ttf", 600, CYRILLIC),
    ("GolosText.ttf", "GolosText-Bold.ttf", 700, CYRILLIC),
    ("NotoNastaliqUrdu.ttf", "NotoNastaliqUrdu-Regular.ttf", None, ARABIC),
    ("Vazirmatn.ttf", "Vazirmatn-Regular.ttf", 400, ARABIC),
    ("Vazirmatn.ttf", "Vazirmatn-Medium.ttf", 500, ARABIC),
    ("Vazirmatn.ttf", "Vazirmatn-Bold.ttf", 700, ARABIC),
]


def build(source: Path, target: Path, weight, unicodes) -> None:
    font = TTFont(source)
    # Noto Nastaliq stays variable (default wght 400): instancing it grows the
    # file, and Flutter draws the default instance.
    if weight is not None and "fvar" in font:
        font = instancer.instantiateVariableFont(font, {"wght": weight})
    options = subset.Options()
    # Arabic-script shaping needs every feature; Cyrillic/Latin faces keep
    # fontTools' standard set (kern, liga, calt, ccmp, locl, mark, mkmk, …).
    if unicodes is ARABIC:
        options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.notdef_outline = True
    options.hinting = False
    options.desubroutinize = True
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(unicodes=unicodes)
    subsetter.subset(font)
    font.save(target)
    # Keep the upstream file when subsetting does not make it smaller (the
    # Nastaliq font's shared variation data grows when re-encoded).
    if weight is None and target.stat().st_size > source.stat().st_size:
        shutil.copyfile(source, target)


def main() -> None:
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    for source, name, weight, unicodes in BUILDS:
        target = out / name
        build(src / source, target, weight, unicodes)
        print(f"{name:34} {target.stat().st_size // 1024:5} KB")


if __name__ == "__main__":
    main()
