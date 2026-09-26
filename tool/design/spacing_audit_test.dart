// Spacing audit: every main screen at 320 and 390 px wide, in Tajik and
// Persian, at text scale 1.0 and 1.3. For each it saves a screenshot and
// measures the real glyph boxes of every text and icon on screen, then flags
//   * text touching an icon or other text on the same line (gap < 4 px),
//   * text colliding with text above or below (boxes overlap),
//   * text touching the edge of its box, chip or button (inset < 4 px).
//
//   SPACING_OUT=/path/to/out flutter test tool/design/spacing_audit_test.dart
//
// Optional: SPACING_ONLY=home,reader runs only the named screens. Findings
// go to <out>/findings.json; screenshots to <out>/<screen>_<w>_<lang>_<scale>.png.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zarbulmasal/features/books/data/books_providers.dart';
import 'package:zarbulmasal/features/books/domain/book.dart';
import 'package:zarbulmasal/features/history/data/history_providers.dart';
import 'package:zarbulmasal/features/history/data/history_repository.dart';
import 'package:zarbulmasal/features/history/domain/history_domain.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';
import 'package:zarbulmasal/features/vocabulary/data/words_provider.dart';
import 'package:zarbulmasal/features/vocabulary/domain/word_entry.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

import '../../test/helpers/file_asset_bundle.dart';
import '../../test/helpers/test_helper.dart';

const _poem = '/literature/work/rudaki_buyi_juyi_muliyon_grade5_2017_p54';

/// (name, route, onboarding done).
const _screens = [
  ('onboarding', '/', false),
  ('home', '/', true),
  ('explore', '/explore', true),
  ('learn', '/learn', true),
  ('saved', '/saved', true),
  ('search', '/search', true),
  ('proverbs', '/proverbs', true),
  ('categories', '/categories', true),
  ('proverb', '/proverb/26', true),
  ('daily', '/daily', true),
  ('levels', '/levels', true),
  ('quiz', '/quiz', true),
  ('flashcards', '/flashcards', true),
  ('settings', '/settings', true),
  ('literature', '/literature', true),
  ('poets', '/literature/poets', true),
  ('poet', '/literature/poet/rudaki', true),
  ('works', '/literature/works', true),
  ('works_ghazal', '/literature/works?form=ghazal', true),
  ('reader', _poem, true),
  ('school', '/literature/school', true),
  ('oral', '/literature/oral', true),
  ('lit_search', '/literature/search', true),
  ('history', '/history', true),
  ('history_entry', '/history/person-ayni', true),
  ('books', '/books', true),
  ('book', '/books/badi-boron', true),
  ('lexicon', '/vocabulary', true),
  ('lexicon_entry', '/vocabulary/vocab-proverb-26', true),
];

const _widths = [320.0, 390.0];
const _scales = [1.0, 1.3];
const _minGap = 4.0;

Future<void> _loadFonts() async {
  final manifest =
      jsonDecode(await rootBundle.loadString('FontManifest.json')) as List;
  for (final family in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(family['family'] as String);
    for (final font in (family['fonts'] as List).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
  final flutterRoot =
      Platform.environment['FLUTTER_ROOT'] ?? '/opt/homebrew/share/flutter';
  final icons = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  );
  if (icons.existsSync()) {
    final loader = FontLoader('MaterialIcons')
      ..addFont(Future.value(ByteData.sublistView(icons.readAsBytesSync())));
    await loader.load();
  }
}

List<dynamic> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as List<dynamic>;

List<Override> _catalogues() {
  final works = expandRuntimeWorks(
    jsonDecode(
      File('assets/data/literature/runtime_works.json').readAsStringSync(),
    ),
  ).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();
  final words = _json('assets/data/vocabulary/words.json')
      .whereType<Map<String, dynamic>>()
      .map(WordEntry.fromJson)
      .where((w) => w.term.isNotEmpty && w.definition.isNotEmpty)
      .toList();
  final entries = _json('assets/data/history/entries.json')
      .whereType<Map>()
      .map((m) => HistoryEntry.fromJson(Map<String, dynamic>.from(m)))
      .toList();
  final books = _json(
    'assets/data/books/books.json',
  ).cast<Map<String, dynamic>>().map(Book.fromJson).toList();
  final providers = _json(
    'assets/data/books/providers.json',
  ).cast<Map<String, dynamic>>().map(BookProvider.fromJson).toList();
  final bundle = FileAssetBundle();
  return [
    booksProvider.overrideWith((ref) async => books),
    bookProvidersProvider.overrideWith((ref) async => providers),
    literatureRepositoryProvider.overrideWithValue(
      LiteratureRepository(bundle: bundle),
    ),
    historyRepositoryProvider.overrideWithValue(
      HistoryRepository(bundle: bundle),
    ),
    approvedWorksProvider.overrideWith((ref) => Future.value(works)),
    literaryWorksProvider.overrideWith((ref) => Future.value(works)),
    historyEntriesProvider.overrideWith((ref) async => entries),
    wordsProvider.overrideWith((ref) async => words),
  ];
}

/// A piece of ink on screen: one paragraph's glyph boxes, or an icon.
class _Leaf {
  _Leaf(this.paragraph, this.label, this.isIcon, this.boxes);

  final RenderParagraph paragraph;
  final String label;
  final bool isIcon;
  final List<Rect> boxes;

  Rect get bounds => boxes.reduce((a, b) => a.expandToInclude(b));
}

bool _isIconSpan(InlineSpan span) {
  final family = span.style?.fontFamily ?? '';
  return family.contains('MaterialIcons') || family.contains('CupertinoIcons');
}

/// The part of the screen [object] can paint in: the intersection of its
/// scrolling viewports and clips.
Rect _clip(RenderObject object, Rect screen) {
  var clip = screen;
  for (var node = object.parent; node != null; node = node.parent) {
    final clips =
        node is RenderViewportBase ||
        node is RenderClipRect ||
        node is RenderClipRRect ||
        node is RenderClipPath;
    if (clips && node is RenderBox && node.hasSize) {
      clip = clip.intersect(node.localToGlobal(Offset.zero) & node.size);
    }
  }
  return clip;
}

/// The font size [paragraph] is mostly set in, after text scaling.
double _fontSize(RenderParagraph paragraph) {
  double? size;
  paragraph.text.visitChildren((span) {
    size = span.style?.fontSize;
    return size == null;
  });
  return paragraph.textScaler.scale(size ?? 14);
}

/// Visible ink of [paragraph] in global coordinates, one rect per line:
/// the words only (a wrapped line's trailing space is not ink), cut to the
/// glyph height rather than the line height, and clipped to what can paint.
List<Rect> _inkBoxes(RenderParagraph paragraph, Rect screen, bool isIcon) {
  final text = paragraph.text.toPlainText();
  if (text.trim().isEmpty || !paragraph.hasSize) return const [];
  final transform = paragraph.getTransformTo(null);
  final clip = _clip(paragraph, screen);
  final lines = <double, Rect>{};
  for (final word in RegExp(r'\S+').allMatches(text)) {
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: word.start, extentOffset: word.end),
    );
    for (final box in boxes) {
      final rect = box.toRect();
      final key = rect.top.roundToDouble();
      lines[key] = lines[key]?.expandToInclude(rect) ?? rect;
    }
  }
  final em = _fontSize(paragraph);
  return lines.values
      .map((rect) {
        // Material icons draw inside a 2/24 margin of their square.
        if (isIcon) return rect.deflate(rect.shortestSide / 12);
        final ink = math.min(rect.height, em * 1.3);
        return Rect.fromCenter(
          center: rect.center,
          width: rect.width,
          height: ink,
        );
      })
      .map((rect) => MatrixUtils.transformRect(transform, rect))
      .where((rect) => rect.overlaps(clip))
      .map((rect) => rect.intersect(clip))
      .where((rect) => rect.width > 0.5 && rect.height > 0.5)
      .toList();
}

/// Whether [object] is hidden: offstage, fully transparent or not painted.
bool _hidden(RenderObject object) {
  if (object is RenderOffstage && object.offstage) return true;
  if (object is RenderOpacity && object.opacity == 0) return true;
  if (object is RenderAnimatedOpacity && object.opacity.value == 0) {
    return true;
  }
  return false;
}

void _collect(RenderObject object, Rect screen, List<_Leaf> leaves) {
  if (_hidden(object)) return;
  if (object is RenderIndexedStack) {
    // Only the shown tab paints; the others keep their state offstage.
    var child = object.firstChild;
    for (var i = 0; child != null; i++) {
      if (i == object.index) _collect(child, screen, leaves);
      child = object.childAfter(child);
    }
    return;
  }
  if (object is RenderParagraph) {
    final isIcon =
        _isIconSpan(object.text) ||
        (object.text is TextSpan &&
            ((object.text as TextSpan).children?.any(_isIconSpan) ?? false));
    final boxes = _inkBoxes(object, screen, isIcon);
    if (boxes.isNotEmpty) {
      final text = object.text.toPlainText().trim();
      leaves.add(
        _Leaf(
          object,
          text.length > 40 ? '${text.substring(0, 40)}…' : text,
          isIcon,
          boxes,
        ),
      );
    }
  }
  object.visitChildren((child) => _collect(child, screen, leaves));
}

/// The nearest visible box drawn around [object]: a bordered or filled
/// decoration, or a Material chip/button shape.
({Rect rect, bool top, bool bottom, bool left, bool right, String kind})?
_container(RenderObject object) {
  for (var node = object.parent; node != null; node = node.parent) {
    if (node is RenderDecoratedBox && node.hasSize) {
      final decoration = node.decoration;
      if (decoration is BoxDecoration) {
        final border = decoration.border;
        final filled = (decoration.color?.a ?? 0) > 0.05;
        if (border is Border || filled) {
          final b = border is Border ? border : null;
          bool side(BorderSide? s) =>
              filled ||
              (s != null && s.style != BorderStyle.none && s.width > 0);
          return (
            rect: MatrixUtils.transformRect(
              node.getTransformTo(null),
              Offset.zero & node.size,
            ),
            top: side(b?.top),
            bottom: side(b?.bottom),
            left: side(b?.left),
            right: side(b?.right),
            kind: filled ? 'filled box' : 'bordered box',
          );
        }
      } else if (decoration is ShapeDecoration) {
        return (
          rect: MatrixUtils.transformRect(
            node.getTransformTo(null),
            Offset.zero & node.size,
          ),
          top: true,
          bottom: true,
          left: true,
          right: true,
          kind: 'shape',
        );
      }
    }
    if (node is RenderPhysicalShape && node.hasSize) {
      final visible = node.color.a > 0.05 || node.elevation > 0;
      if (visible && node.size.width < 600) {
        return (
          rect: MatrixUtils.transformRect(
            node.getTransformTo(null),
            Offset.zero & node.size,
          ),
          top: true,
          bottom: true,
          left: true,
          right: true,
          kind: 'material shape',
        );
      }
    }
  }
  return null;
}

double _overlap(double a0, double a1, double b0, double b1) =>
    math.min(a1, b1) - math.max(a0, b0);

List<Map<String, Object>> _audit(Size view) {
  final screen = Offset.zero & view;
  final leaves = <_Leaf>[];
  for (final renderView in TestWidgetsFlutterBinding.instance.renderViews) {
    _collect(renderView, screen, leaves);
  }
  final visible = leaves
      .where((leaf) => leaf.bounds.overlaps(screen))
      .toList(growable: false);
  final findings = <Map<String, Object>>[];

  // Same line: an icon or text too close to another one.
  for (var i = 0; i < visible.length; i++) {
    for (var j = i + 1; j < visible.length; j++) {
      final a = visible[i], b = visible[j];
      for (final ra in a.boxes) {
        for (final rb in b.boxes) {
          final vertical = _overlap(ra.top, ra.bottom, rb.top, rb.bottom);
          final horizontal = _overlap(ra.left, ra.right, rb.left, rb.right);
          final shorter = math.min(ra.height, rb.height);
          if (vertical > shorter * 0.5) {
            final gap = -horizontal;
            if (gap < _minGap) {
              findings.add({
                'kind': gap < 0 ? 'overlap on a line' : 'touching on a line',
                'a': a.label,
                'b': b.label,
                'gap': double.parse(gap.toStringAsFixed(1)),
                'icon': a.isIcon || b.isIcon,
              });
            }
          } else if (horizontal > 2 && vertical > 2) {
            findings.add({
              'kind': 'lines collide',
              'a': a.label,
              'b': b.label,
              'gap': double.parse((-vertical).toStringAsFixed(1)),
              'icon': a.isIcon || b.isIcon,
            });
          }
        }
      }
    }
  }

  // Text or icon touching the edge of the box drawn around it.
  for (final leaf in visible) {
    final box = _container(leaf.paragraph);
    if (box == null) continue;
    final ink = leaf.bounds;
    final insets = <String, double>{
      if (box.left) 'left': ink.left - box.rect.left,
      if (box.right) 'right': box.rect.right - ink.right,
      if (box.top) 'top': ink.top - box.rect.top,
      if (box.bottom) 'bottom': box.rect.bottom - ink.bottom,
    };
    for (final MapEntry(key: side, value: inset) in insets.entries) {
      final limit = (side == 'left' || side == 'right') ? _minGap : 1.0;
      if (inset < limit) {
        findings.add({
          'kind': 'touches ${box.kind} $side',
          'a': leaf.label,
          'b': '${box.rect.width.round()}×${box.rect.height.round()}',
          'gap': double.parse(inset.toStringAsFixed(1)),
          'icon': leaf.isIcon,
        });
      }
    }
  }
  return findings;
}

void main() {
  final out = Platform.environment['SPACING_OUT'];
  final only = Platform.environment['SPACING_ONLY']?.split(',').toSet();
  final results = <String, Object>{};

  setUpAll(() async {
    WidgetsApp.debugAllowBannerOverride = false;
    await _loadFonts();
  });

  tearDownAll(() {
    if (out == null) return;
    File(
      '$out/findings.json',
    ).writeAsStringSync(const JsonEncoder.withIndent(' ').convert(results));
  });

  for (final (name, route, onboarded) in _screens) {
    if (only != null && !only.contains(name)) continue;
    for (final width in _widths) {
      for (final language in DisplayLanguage.values) {
        for (final scale in _scales) {
          final lang = language == DisplayLanguage.persian ? 'fa' : 'tj';
          final id = '${name}_${width.round()}_${lang}_$scale';
          testWidgets(id, (tester) async {
            if (out == null) return;
            final height = width == 320 ? 640.0 : 844.0;
            await openApp(
              tester,
              route: route,
              width: width,
              height: height,
              scale: scale,
              language: language,
              onboardingComplete: onboarded,
              disableAnimations: true,
              settle: false,
              overrides: _catalogues(),
            );
            for (var i = 0; i < 10; i++) {
              await tester.runAsync(
                () => Future<void>.delayed(const Duration(milliseconds: 400)),
              );
              await tester.pump(const Duration(milliseconds: 300));
            }
            final errors = <String>[];
            for (var e = tester.takeException(); e != null;) {
              errors.add(e.toString().split('\n').first);
              e = tester.takeException();
            }
            final view = tester.binding.renderViews.first;
            results[id] = {
              'route': route,
              'errors': errors,
              'findings': _audit(view.size),
            };
            final layer = view.debugLayer! as OffsetLayer;
            await tester.runAsync(() async {
              final image = await layer.toImage(
                Offset.zero & view.size,
                pixelRatio: 1.5,
              );
              final data = await image.toByteData(
                format: ui.ImageByteFormat.png,
              );
              File('$out/$id.png').writeAsBytesSync(data!.buffer.asUint8List());
            });
          });
        }
      }
    }
  }
}
