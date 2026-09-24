// Font proof sheet for the «Муҳр» redesign (Phase 0).
//
// Renders candidate typefaces through Flutter's own text shaper so Tajik
// Cyrillic (Ҷ Ҳ Қ Ғ Ӣ Ӯ) and Persian (Nastaliq + Naskh) can be judged exactly
// as the app would draw them. Candidate TTFs are loaded at runtime from
// FONT_PROOF_DIR, so nothing is added to pubspec.yaml before a typeface is
// approved. Sample texts are read verbatim from the bundled assets.
//
//   FONT_PROOF_DIR=/path/to/fonts FONT_PROOF_OUT=/path/to/out \
//     flutter test tool/design/font_proof_test.dart
library;

import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';

const _tajikLetters = 'Ҷ Ҳ Қ Ғ Ӣ Ӯ   ҷ ҳ қ ғ ӣ ӯ   Ё ё';
const _persianLetters = 'پ چ ژ گ ک ی   ۰۱۲۳۴۵۶۷۸۹   « » ، ؛ ؟';

class _Candidate {
  const _Candidate(this.family, this.file, this.note, {this.current = false});
  final String family;
  final String file;
  final String note;
  final bool current;
}

const _display = [
  _Candidate(
    'CormorantGaramond',
    'CormorantGaramond',
    'Exhibit serif · proposed',
  ),
  _Candidate('Brygada1918', 'Brygada1918', 'Exhibit serif · alternative'),
  _Candidate('EBGaramond', 'EBGaramond', 'Exhibit/reading serif · alternative'),
  _Candidate('NotoSerif', 'NotoSerif', 'Current serif', current: true),
];
const _reading = [
  _Candidate('PTSerif', 'PTSerif', 'Reading serif · proposed'),
  _Candidate('EBGaramond', 'EBGaramond', 'Reading serif · alternative'),
  _Candidate('Brygada1918', 'Brygada1918', 'Reading serif · alternative'),
  _Candidate('NotoSerif', 'NotoSerif', 'Current serif', current: true),
];
const _ui = [
  _Candidate('GolosText', 'GolosText', 'UI grotesque · proposed'),
  _Candidate('Onest', 'Onest', 'UI grotesque · alternative'),
  _Candidate('NotoSans', 'NotoSans', 'Current sans', current: true),
];
const _rejected = [
  _Candidate(
    'Literata',
    'Literata',
    'Listed in report §12 — FAILS glyph proof',
  ),
  _Candidate('Manrope', 'Manrope', 'Listed in report §12 — FAILS glyph proof'),
];
const _nastaliq = [
  _Candidate(
    'NotoNastaliqUrdu',
    'NotoNastaliqUrdu',
    'Nastaliq exhibit · proposed (Urdu-tuned: needs a Persian reader)',
  ),
  _Candidate('Gulzar', 'Gulzar', 'Nastaliq exhibit · alternative (Urdu-tuned)'),
];
const _naskh = [
  _Candidate(
    'NotoNaskhArabic',
    'NotoNaskhArabic',
    'Persian reading · keep (current)',
    current: true,
  ),
  _Candidate('Vazirmatn', 'Vazirmatn', 'Persian UI sans · proposed'),
  _Candidate('MarkaziText', 'MarkaziText', 'Persian reading · alternative'),
];

class _Palette {
  const _Palette(
    this.paper,
    this.ink,
    this.soft,
    this.rule,
    this.accent,
    this.bad,
  );
  final Color paper, ink, soft, rule, accent, bad;
}

// Proposal tokens (see docs/design/PHASE_0_PLAN.md): «Муҳр» day, «Шаб» night.
const _day = _Palette(
  Color(0xFFF3ECDD),
  Color(0xFF1A1714),
  Color(0xFF4F473E),
  Color(0x261A1714),
  Color(0xFFB02E1C),
  Color(0xFFB02E1C),
);
const _night = _Palette(
  Color(0xFF0B1222),
  Color(0xFFEFE7D6),
  Color(0xFFBDB5A4),
  Color(0x33EFE7D6),
  Color(0xFFEC6A52),
  Color(0xFFEC6A52),
);

// Token swatches shown at the top of the sheet: (name, colour, contrast note).
const _daySwatches = [
  ('paper', Color(0xFFF3ECDD), 'ground'),
  ('paperRaised', Color(0xFFFAF6EC), 'sheets'),
  ('paperSunk', Color(0xFFE8DFCB), 'wells'),
  ('ink', Color(0xFF1A1714), '15.2:1'),
  ('inkSoft', Color(0xFF4F473E), '7.8:1'),
  ('inkMute', Color(0xFF6B6256), '5.1:1'),
  ('vermilion', Color(0xFFB02E1C), '5.5:1 · seal + action'),
];
const _nightSwatches = [
  ('lapis', Color(0xFF0B1222), 'ground'),
  ('lapisRaised', Color(0xFF131C33), 'sheets'),
  ('lapisSunk', Color(0xFF070C18), 'wells'),
  ('ivory', Color(0xFFEFE7D6), '15.2:1'),
  ('ivorySoft', Color(0xFFBDB5A4), '9.2:1'),
  ('ivoryMute', Color(0xFF948D7E), '5.7:1'),
  ('vermilion', Color(0xFFEC6A52), '6.0:1 · seal + action'),
];

void main() {
  final fontDir = Platform.environment['FONT_PROOF_DIR'];
  final outDir = Platform.environment['FONT_PROOF_OUT'];

  if (fontDir == null || outDir == null) {
    test('font proof', () {}, skip: 'Set FONT_PROOF_DIR and FONT_PROOF_OUT');
    return;
  }

  late Map<String, dynamic> coverage;
  late _Samples samples;

  setUpAll(() async {
    final families = {
      for (final c in [
        ..._display,
        ..._reading,
        ..._ui,
        ..._rejected,
        ..._nastaliq,
        ..._naskh,
      ])
        c.family: c.file,
    };
    for (final entry in families.entries) {
      final bytes = File('$fontDir/${entry.value}.ttf').readAsBytesSync();
      final loader = FontLoader(entry.key)
        ..addFont(Future.value(ByteData.sublistView(bytes)));
      await loader.load();
    }
    coverage =
        jsonDecode(File('$fontDir/coverage.json').readAsStringSync())
            as Map<String, dynamic>;
    samples = _Samples.load();
  });

  for (final width in [390.0, 1440.0]) {
    for (final dark in [false, true]) {
      final name = 'font_proof_${width.toInt()}_${dark ? 'dark' : 'light'}';
      testWidgets(name, (tester) async {
        final ratio = width < 600 ? 2.0 : 1.0;
        tester.view.physicalSize = Size(width * ratio, 9000 * ratio);
        tester.view.devicePixelRatio = ratio;
        addTearDown(tester.view.reset);

        final key = GlobalKey();
        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(
              size: Size(width, 9000),
              devicePixelRatio: ratio,
            ),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: key,
                  child: _ProofSheet(
                    width: width,
                    palette: dark ? _night : _day,
                    coverage: coverage,
                    samples: samples,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.runAsync(() async {
          final boundary =
              key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: ratio);
          final png = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$outDir/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
        });
      });
    }
  }
}

class _Samples {
  _Samples(
    this.proverbTj,
    this.proverbFa,
    this.proverbId,
    this.verse,
    this.verseLabel,
    this.titleFa,
    this.titleFaLabel,
  );

  final String proverbTj,
      proverbFa,
      proverbId,
      verse,
      verseLabel,
      titleFa,
      titleFaLabel;

  static _Samples load() {
    final proverb = seedProverbs.first;
    final works =
        (jsonDecode(
                  File(
                    'assets/data/literature/runtime_works.json',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>)['works']
            as List<dynamic>;
    Map<String, dynamic> work(String id) =>
        works.cast<Map<String, dynamic>>().firstWhere((w) => w['id'] == id);
    final rudaki = work('rudaki_buyi_juyi_muliyon_grade5_2017_p54');
    final saadi = work('d02917e3-6e5f-4f65-9166-ad705decb7be');
    final lines = (rudaki['textTajik'] as String)
        .split('\n')
        .take(4)
        .join('\n');
    return _Samples(
      proverb.tajikCyrillic,
      proverb.persianText,
      proverb.id,
      lines,
      'runtime_works.json · ${rudaki['id']} · first 2 bayts, verbatim',
      saadi['titlePersian'] as String,
      'runtime_works.json · ${saadi['id']} · titlePersian '
          '(titlePersianSource: ${saadi['titlePersianSource'] ?? 'not recorded'})',
    );
  }
}

class _ProofSheet extends StatelessWidget {
  const _ProofSheet({
    required this.width,
    required this.palette,
    required this.coverage,
    required this.samples,
  });

  final double width;
  final _Palette palette;
  final Map<String, dynamic> coverage;
  final _Samples samples;

  bool get _wide => width >= 1000;
  double get _gutter => _wide ? 48 : 16;

  @override
  Widget build(BuildContext context) {
    final columnWidth = _wide ? (width - _gutter * 3) / 2 : width - _gutter * 2;
    Widget grid(List<Widget> children) => Wrap(
      spacing: _gutter,
      runSpacing: 8,
      children: [
        for (final c in children) SizedBox(width: columnWidth, child: c),
      ],
    );

    return Container(
      width: width,
      color: palette.paper,
      padding: EdgeInsets.fromLTRB(_gutter, 32, _gutter, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('ФОНТ · PROOF SHEET', style: _meta(palette.accent, letter: 2)),
          const SizedBox(height: 8),
          Text(
            'Зарбулмасал — Phase 0 font proof',
            style: _t('GolosText', 22, palette.ink, weight: 600),
          ),
          const SizedBox(height: 4),
          Text(
            '${width.toInt()} px · ${palette == _night ? '«Шаб» lapis night' : '«Муҳр» ivory day'} · '
            'rendered by Flutter (flutter_tester, Skia + HarfBuzz). Samples are verbatim from assets. '
            'Coverage = cmap check against every character in assets/data + UI strings.',
            style: _t('GolosText', 13, palette.soft),
          ),
          _section(
            'Tokens · ${palette == _night ? '«Шаб» lapis night' : '«Муҳр» ivory day'} (WCAG vs ground)',
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final (name, color, note)
                  in palette == _night ? _nightSwatches : _daySwatches)
                SizedBox(
                  width: _wide ? 180 : (width - _gutter * 2 - 12) / 2,
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(color: palette.rule),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$name\n$note',
                          style: _meta(palette.ink, size: 11),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          _section('A · Exhibit serif — Tajik Cyrillic, monumental'),
          grid([
            for (final c in _display)
              _specimen(c, [
                _line(c.family, _tajikLetters, 22),
                _line(
                  c.family,
                  samples.proverbTj,
                  _wide ? 64 : 40,
                  weight: 500,
                  height: 1.12,
                ),
              ], caption: 'seedProverbs #${samples.proverbId} · tajikCyrillic'),
          ]),
          _section('B · Reading serif — verse (bayts, 19 px)'),
          grid([
            for (final c in _reading)
              _specimen(c, [
                _line(c.family, 'Бӯйи Ҷӯйи Мулиён', 26, weight: 600),
                _line(c.family, samples.verse, 19, height: 1.7),
                _line(c.family, _tajikLetters, 16, weight: 700),
              ], caption: samples.verseLabel),
          ]),
          _section('C · UI grotesque — interface'),
          grid([
            for (final c in _ui)
              _specimen(
                c,
                [
                  _line(
                    c.family,
                    'Асосӣ · Кашф · Омӯзиш · Маҳфуз · Танзимот',
                    15,
                    weight: 500,
                  ),
                  _line(
                    c.family,
                    'Идомаи хондан  ·  Ҳоло чизе маҳфуз нашудааст',
                    14,
                  ),
                  _line(
                    c.family,
                    'ҶУСТУҶӮ · ҒАНҶИНА · ҚАСИДА · ӢӮ',
                    11,
                    weight: 700,
                    letter: 1.6,
                  ),
                  _line(c.family, _tajikLetters, 20),
                ],
                caption:
                    'app_translations.dart (tj) · verbatim keys; caps row = eyebrow test',
              ),
          ]),
          _section(
            'D · Rejected — listed in report §12 but missing Tajik glyphs',
          ),
          grid([
            for (final c in _rejected)
              _specimen(c, [
                _line(c.family, _tajikLetters, 24),
                _line(c.family, samples.verse, 19, height: 1.6),
              ], caption: 'Missing glyphs render as blanks/tofu: do not adopt'),
          ]),
          _section('E · Persian Nastaliq — exhibited verse (RTL)'),
          grid([
            for (final c in _nastaliq)
              _specimen(
                c,
                [
                  _line(
                    c.family,
                    samples.proverbFa,
                    _wide ? 44 : 30,
                    rtl: true,
                    height: 2.0,
                  ),
                  _line(c.family, samples.titleFa, 26, rtl: true, height: 2.0),
                  _line(c.family, _persianLetters, 20, rtl: true, height: 2.0),
                ],
                caption:
                    'seedProverbs #${samples.proverbId} · persianText  /  ${samples.titleFaLabel}',
              ),
          ]),
          _section('F · Persian Naskh — reading and UI (RTL)'),
          grid([
            for (final c in _naskh)
              _specimen(c, [
                _line(c.family, samples.proverbFa, 24, rtl: true, height: 1.7),
                _line(c.family, samples.titleFa, 20, rtl: true, height: 1.7),
                _line(c.family, _persianLetters, 18, rtl: true, height: 1.7),
              ], caption: 'Same samples as E'),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 40, bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(height: 1, color: palette.ink),
        const SizedBox(height: 10),
        Text(
          title.toUpperCase(),
          style: _meta(palette.ink, letter: 1.4, weight: 700),
        ),
      ],
    ),
  );

  Widget _specimen(
    _Candidate c,
    List<Widget> lines, {
    required String caption,
  }) {
    final cov = coverage[c.file] as Map<String, dynamic>?;
    final core = (cov?['coreMissing'] as String?) ?? '?';
    final all = ((cov?['allMissing'] as List<dynamic>?) ?? const []).join(' ');
    final passes = core.isEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: palette.rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: c.family,
                  style: _meta(palette.ink, weight: 700, size: 13),
                ),
                TextSpan(text: '   ${c.note}', style: _meta(palette.soft)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            passes
                ? 'PASS · script letters covered${all.isEmpty ? ' · all corpus chars covered' : ' · also missing: $all'}'
                : 'FAIL · missing script letters: $core${all.isEmpty ? '' : ' · $all'}',
            style: _meta(
              passes ? palette.soft : palette.bad,
              weight: passes ? 400 : 700,
            ),
          ),
          const SizedBox(height: 12),
          ...lines.expand((l) => [l, const SizedBox(height: 10)]),
          Text(caption, style: _meta(palette.soft, size: 11)),
        ],
      ),
    );
  }

  Widget _line(
    String family,
    String text,
    double size, {
    int weight = 400,
    double height = 1.35,
    bool rtl = false,
    double letter = 0,
  }) => SizedBox(
    width: double.infinity,
    child: Text(
      text,
      textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
      textAlign: rtl ? TextAlign.right : TextAlign.left,
      style: _t(
        family,
        size,
        palette.ink,
        weight: weight,
        height: height,
        letter: letter,
      ),
    ),
  );

  TextStyle _meta(
    Color color, {
    double letter = 0,
    int weight = 400,
    double size = 12,
  }) => _t('GolosText', size, color, weight: weight, letter: letter);

  // Only the named family is used — no fallback — so missing glyphs stay visible.
  TextStyle _t(
    String family,
    double size,
    Color color, {
    int weight = 400,
    double height = 1.35,
    double letter = 0,
  }) => TextStyle(
    fontFamily: family,
    fontSize: size,
    height: height,
    color: color,
    letterSpacing: letter,
    fontWeight: FontWeight.values[(weight ~/ 100) - 1],
    fontVariations: [FontVariation('wght', weight.toDouble())],
  );
}
