import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG contrast of every painted text: the colour its style declares (with
/// the opacity of its ancestors) against the background actually rendered
/// behind it — the most common colour in its box on a screenshot.
///
/// Flutter's [textContrastGuideline] reads the text colour from the
/// screenshot too. For small text that colour is mostly anti-aliased edge,
/// and platforms rasterise edges differently: on the Linux CI runner
/// (FreeType) 12 px ink text on paper measured 4.4:1 and chip labels 1.5:1,
/// while the ink is 16:1. This guideline measures the theme, not the
/// rasteriser, so it gives the same answer on every platform.
///
/// Normal text needs 4.5:1; large text (18 px, or 14 px bold) 3:1.
const AccessibilityGuideline textStyleContrastGuideline =
    _TextStyleContrastGuideline();

class _TextStyleContrastGuideline extends AccessibilityGuideline {
  const _TextStyleContrastGuideline();

  static const _normal = 4.5;
  static const _large = 3.0;

  @override
  String get description => 'Text colours contrast with what is behind them';

  @override
  Future<Evaluation> evaluate(WidgetTester tester) async {
    final view = tester.binding.renderViews.first;
    final layer = view.debugLayer! as OffsetLayer;
    final bounds = view.paintBounds;
    late final ByteData bytes;
    late final int width;
    late final int height;
    await tester.runAsync(() async {
      final image = await layer.toImage(
        bounds,
        pixelRatio: 1 / tester.view.devicePixelRatio,
      );
      width = image.width;
      height = image.height;
      bytes = (await image.toByteData())!;
      image.dispose();
    });
    final screen = Offset.zero & Size(width.toDouble(), height.toDouble());

    var result = const Evaluation.pass();
    for (final element in find.byType(RichText).evaluate()) {
      final paragraph = element.renderObject;
      if (paragraph is! RenderParagraph || !paragraph.attached) continue;
      // Text on a page under a sheet or dialog is behind its scrim, and
      // out of reach, as in Flutter's own guideline.
      if (!(ModalRoute.of(element)?.isCurrent ?? true)) continue;
      if (_offstage(paragraph)) continue;
      if (!paragraph.hasSize || paragraph.size.isEmpty) continue;
      if (paragraph.text.toPlainText().trim().isEmpty) continue;
      final rect = MatrixUtils.transformRect(
        paragraph.getTransformTo(null),
        Offset.zero & paragraph.size,
      ).intersect(screen);
      if (rect.width < 1 || rect.height < 1) continue;
      final opacity = _opacity(paragraph);
      if (opacity == 0) continue;
      final background = _modeColor(bytes, width, rect);
      paragraph.text.visitChildren((span) {
        final style = span is TextSpan ? span.style : null;
        final color = style?.color;
        final text = span is TextSpan ? (span.text ?? '') : '';
        if (color == null || text.trim().isEmpty || _isIcon(text)) {
          return true;
        }
        final shown = Color.alphaBlend(
          color.withValues(alpha: color.a * opacity),
          background,
        );
        final ratio = _contrast(shown, background);
        final size = paragraph.textScaler.scale(style!.fontSize ?? 14);
        final bold = (style.fontWeight?.value ?? 400) >= 700;
        final large = size >= 18 || (size >= 14 && bold);
        final needed = large ? _large : _normal;
        if (ratio < needed - 0.005) {
          result += Evaluation.fail(
            '«${text.trim()}» at ${size.toStringAsFixed(1)} px: '
            '${ratio.toStringAsFixed(2)}:1, needs $needed:1 '
            '(text $shown on $background).\n',
          );
        }
        return true;
      });
    }
    return result;
  }

  /// An icon font glyph (private use area): not text.
  static bool _isIcon(String text) => text.trim().runes.every(
    (rune) => rune >= 0xE000 && rune <= 0xF8FF || rune >= 0xF0000,
  );

  static bool _offstage(RenderObject object) {
    for (RenderObject? node = object; node != null; node = node.parent) {
      if (node is RenderOffstage && node.offstage) return true;
    }
    return false;
  }

  /// The product of the opacity of every ancestor that fades its children.
  static double _opacity(RenderObject object) {
    var opacity = 1.0;
    for (RenderObject? node = object; node != null; node = node.parent) {
      if (node is RenderOpacity) opacity *= node.opacity;
      if (node is RenderAnimatedOpacity) opacity *= node.opacity.value;
      if (node is RenderSliverOpacity) opacity *= node.opacity;
    }
    return opacity;
  }

  static Color _modeColor(ByteData bytes, int width, Rect rect) {
    final counts = <int, int>{};
    final left = rect.left.floor(), right = rect.right.ceil();
    final top = rect.top.floor(), bottom = rect.bottom.ceil();
    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final rgba = bytes.getUint32((y * width + x) * 4);
        counts[rgba] = (counts[rgba] ?? 0) + 1;
      }
    }
    final rgba = counts.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final value = rgba.key;
    return Color.fromARGB(
      255,
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
    );
  }

  static double _contrast(Color a, Color b) {
    final (x, y) = (a.computeLuminance(), b.computeLuminance());
    return (math.max(x, y) + .05) / (math.min(x, y) + .05);
  }
}
