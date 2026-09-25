import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// «Атлас» — a procedural ikat (atlas/adras) print, seeded from a collection
/// ID so every collection wears its own, stable pattern with no image rights.
///
/// Used only on collection covers, share cards and the splash — never behind
/// reading text. The motif grammar follows the craft, not a scan of any one
/// cloth:
///  * nested lozenges ("чашм", the eye) with a dark outline and hooked
///    tips, mirrored left–right like the tied warp bundles;
///  * a comb of zigzags between the motif columns;
///  * the "abr" (cloud) edge: warp threads dyed slightly out of register,
///    drawn by painting each motif whole and then shifting thread-wide
///    vertical slices by a smooth random walk;
///  * a faint warp striation over everything.
/// Pending a textile specialist's review.
class AtlasCover extends StatelessWidget {
  const AtlasCover({super.key, required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    // Painted once and cached: the band never changes for a seed.
    return RepaintBoundary(
      child: CustomPaint(
        painter: AtlasPainter(
          seed: seed,
          devicePixelRatio: MediaQuery.maybeDevicePixelRatioOf(context) ?? 1,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

/// A palette: the silk ground, three dyes and the outline ink.
class AtlasPalette {
  const AtlasPalette(this.ground, this.dyes, this.ink);
  final Color ground;
  final List<Color> dyes;
  final Color ink;
}

class AtlasPainter extends CustomPainter {
  AtlasPainter({required this.seed, this.devicePixelRatio = 1});

  final String seed;
  final double devicePixelRatio;

  /// Motif layers already rasterised, by seed, size and pixel ratio. The
  /// thread slices are then cheap image blits instead of re-drawn paths.
  static final _cache = <String, ui.Image>{}; // insertion-ordered
  static const _cacheSize = 24;

  static const palettes = [
    AtlasPalette(Color(0xFFF1E4C8), [
      Color(0xFFB02E1C),
      Color(0xFF2B3A67),
      Color(0xFFD9A441),
    ], Color(0xFF1C1B2E)),
    AtlasPalette(Color(0xFFEDE0CF), [
      Color(0xFF7A1F4B),
      Color(0xFF1F6F5C),
      Color(0xFFE0B64C),
    ], Color(0xFF231A22)),
    AtlasPalette(Color(0xFFF3E6D2), [
      Color(0xFF1D3F8A),
      Color(0xFFC0392B),
      Color(0xFFE3B23C),
    ], Color(0xFF161B2E)),
    AtlasPalette(Color(0xFFEFE3CC), [
      Color(0xFF8C2414),
      Color(0xFF3F6B2E),
      Color(0xFFD99A2B),
    ], Color(0xFF1D2A3A)),
    AtlasPalette(Color(0xFFF2E2D2), [
      Color(0xFFC04A7A),
      Color(0xFF214E7A),
      Color(0xFFE2A93B),
    ], Color(0xFF1B2233)),
    AtlasPalette(Color(0xFFEAE0CC), [
      Color(0xFF5B2C6F),
      Color(0xFFB8611F),
      Color(0xFF1E4D4A),
    ], Color(0xFF1E1A24)),
  ];

  /// Width of one warp thread slice, in logical pixels.
  static const threadWidth = 1.5;

  /// A stable hash (FNV-1a) so the print never changes between runs.
  static int stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final hash = stableHash(seed);
    final palette = palettes[hash % palettes.length];
    final layout = _Layout.from(hash, size);

    // Shifted thread slices must not spill past the band.
    canvas.clipRect(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.ground);
    final motifs = _motifImage(size, layout, palette);
    final ratio = devicePixelRatio;

    // The abr edge: one smooth random walk of vertical offsets across the
    // warp, so neighbouring threads shift together like tied bundles.
    final random = math.Random(hash ^ 0x5bd1e995);
    final amplitude = (size.height * 0.06).clamp(1.5, 4.0);
    final blit = Paint()..filterQuality = FilterQuality.low;
    var drift = 0.0;
    for (var x = 0.0; x < size.width; x += threadWidth) {
      drift = (drift + (random.nextDouble() - 0.5) * amplitude * 0.9).clamp(
        -amplitude,
        amplitude,
      );
      final width = math.min(threadWidth, size.width - x);
      canvas.drawImageRect(
        motifs,
        Rect.fromLTWH(x * ratio, 0, width * ratio, size.height * ratio),
        Rect.fromLTWH(x, drift, width, size.height),
        blit,
      );
    }

    // Warp striation: faint threads over the whole cloth.
    final warp = Paint()
      ..color = palette.ink.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;
    for (var x = 0.0; x < size.width; x += threadWidth * 2) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), warp);
    }
  }

  ui.Image _motifImage(Size size, _Layout layout, AtlasPalette palette) {
    final key = '$seed|${size.width}x${size.height}|$devicePixelRatio';
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached; // most recently used goes last
      return cached;
    }
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(devicePixelRatio);
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.ground);
    _motifs(canvas, size, layout, palette);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      (size.width * devicePixelRatio).ceil(),
      (size.height * devicePixelRatio).ceil(),
    );
    picture.dispose();
    _cache[key] = image;
    if (_cache.length > _cacheSize) {
      _cache.remove(_cache.keys.first)?.dispose();
    }
    return image;
  }

  /// Motif columns across the band: eye columns alternating with narrower
  /// comb columns, each repeated down the band.
  void _motifs(Canvas canvas, Size size, _Layout layout, AtlasPalette p) {
    var x = 0.0;
    for (var c = 0; c < layout.columns; c++) {
      final dyeA = p.dyes[(layout.shift + c) % p.dyes.length];
      final dyeB = p.dyes[(layout.shift + c + 1) % p.dyes.length];
      if (c.isOdd) {
        final width = layout.columnWidth * 0.5;
        _comb(canvas, x, width, size.height, dyeB, p.ink, layout.phase);
        x += width;
        continue;
      }
      for (
        var y = -layout.motifHeight + layout.phase;
        y < size.height;
        y += layout.motifHeight
      ) {
        _eye(
          canvas,
          Rect.fromLTWH(x, y, layout.columnWidth, layout.motifHeight),
          dyeA,
          dyeB,
          p,
        );
      }
      x += layout.columnWidth;
    }
  }

  /// Nested lozenges with an ink outline and hooked side tips.
  void _eye(Canvas canvas, Rect r, Color outer, Color core, AtlasPalette p) {
    Path diamond(Rect box) => Path()
      ..moveTo(box.center.dx, box.top)
      ..lineTo(box.right, box.center.dy)
      ..lineTo(box.center.dx, box.bottom)
      ..lineTo(box.left, box.center.dy)
      ..close();

    final ink = Paint()..color = p.ink;
    canvas.drawPath(diamond(r.deflate(0.5)), ink);
    canvas.drawPath(diamond(r.deflate(r.width * 0.07)), Paint()..color = outer);
    canvas.drawPath(
      diamond(r.deflate(r.width * 0.22)),
      Paint()..color = p.ground,
    );
    canvas.drawPath(diamond(r.deflate(r.width * 0.3)), ink);
    canvas.drawPath(diamond(r.deflate(r.width * 0.34)), Paint()..color = core);

    // Hooks ("шох", ram's horns) at the side tips, mirrored.
    final hook = Paint()
      ..color = p.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.8, r.width * 0.03)
      ..strokeCap = StrokeCap.round;
    final h = r.height * 0.11;
    for (final side in [-1.0, 1.0]) {
      final tip = Offset(r.center.dx + side * r.width / 2, r.center.dy);
      canvas.drawArc(
        Rect.fromCenter(
          center: tip.translate(-side * h * 0.2, -h),
          width: h,
          height: h,
        ),
        side < 0 ? 0 : math.pi,
        math.pi,
        false,
        hook,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: tip.translate(-side * h * 0.2, h),
          width: h,
          height: h,
        ),
        side < 0 ? math.pi : 0,
        math.pi,
        false,
        hook,
      );
    }
  }

  /// A comb of stacked chevrons in the narrow column between the eyes.
  void _comb(
    Canvas canvas,
    double left,
    double width,
    double height,
    Color dye,
    Color ink,
    double phase,
  ) {
    final inset = width * 0.15;
    final x0 = left + inset;
    final w = width - inset * 2;
    final step = w * 1.2;
    final fill = Paint()..color = dye;
    final edge = Paint()
      ..color = ink.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var y = -step + (phase % step); y < height; y += step) {
      final path = Path()
        ..moveTo(x0, y)
        ..lineTo(x0 + w / 2, y + step * 0.45)
        ..lineTo(x0 + w, y)
        ..lineTo(x0 + w, y + step * 0.35)
        ..lineTo(x0 + w / 2, y + step * 0.8)
        ..lineTo(x0, y + step * 0.35)
        ..close();
      canvas.drawPath(path, fill);
      canvas.drawPath(path, edge);
    }
  }

  @override
  bool shouldRepaint(AtlasPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.devicePixelRatio != devicePixelRatio;
}

/// The seeded proportions of one print.
class _Layout {
  const _Layout({
    required this.columns,
    required this.columnWidth,
    required this.motifHeight,
    required this.phase,
    required this.shift,
  });

  factory _Layout.from(int hash, Size size) {
    final random = math.Random(hash);
    // Eyes sized from the band's height, so a thin band shows one whole row
    // of eyes rather than cut halves; an eye is about 1.6× as tall as wide.
    final target = math.min(size.height * 0.62, size.width / 4);
    final eyes =
        (size.width / (target * 1.5)).round().clamp(3, 11) +
        (random.nextBool() ? 0 : 1);
    final columns = eyes * 2 - 1;
    // Eyes and the combs between them (half as wide) fill the width.
    final columnWidth = size.width / (eyes + (eyes - 1) * 0.5);
    final oneRow = size.height <= columnWidth * 2.2;
    final motifHeight = oneRow
        ? size.height
        : columnWidth * (1.4 + random.nextDouble() * 0.3);
    return _Layout(
      columns: columns,
      columnWidth: columnWidth,
      motifHeight: motifHeight,
      phase: oneRow ? 0 : random.nextDouble() * motifHeight,
      shift: hash % 3,
    );
  }

  final int columns;
  final double columnWidth;
  final double motifHeight;
  final double phase;
  final int shift;
}
