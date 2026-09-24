import 'dart:math' as math;

import 'package:flutter/material.dart';

/// «Атлас» — a procedural ikat (atlas/adras) print, seeded from a collection
/// ID so every collection wears its own, stable pattern with no image rights.
///
/// Used only on collection covers, share cards and the splash — never behind
/// reading text. The motif grammar here is a PLACEHOLDER: vertical warp bands
/// of stacked lozenges with feathered ("abr") edges, pending a textile
/// specialist's design.
class AtlasCover extends StatelessWidget {
  const AtlasCover({super.key, required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: AtlasPainter(seed: seed),
      child: const SizedBox.expand(),
    );
  }
}

/// A palette: the silk ground plus three dyes.
class AtlasPalette {
  const AtlasPalette(this.ground, this.dyes);
  final Color ground;
  final List<Color> dyes;
}

class AtlasPainter extends CustomPainter {
  AtlasPainter({required this.seed});

  final String seed;

  static const palettes = [
    AtlasPalette(Color(0xFFF1E4C8), [
      Color(0xFFB02E1C),
      Color(0xFF2B3A67),
      Color(0xFFD9A441),
    ]),
    AtlasPalette(Color(0xFFEDE0CF), [
      Color(0xFF7A1F4B),
      Color(0xFF1F6F5C),
      Color(0xFFE0B64C),
    ]),
    AtlasPalette(Color(0xFFF3E6D2), [
      Color(0xFF1D3F8A),
      Color(0xFFC0392B),
      Color(0xFF2E2A24),
    ]),
    AtlasPalette(Color(0xFFEFE3CC), [
      Color(0xFF8C2414),
      Color(0xFF3F6B2E),
      Color(0xFF203D5C),
    ]),
    AtlasPalette(Color(0xFFF2E2D2), [
      Color(0xFFC04A7A),
      Color(0xFF214E7A),
      Color(0xFFE2A93B),
    ]),
    AtlasPalette(Color(0xFFEAE0CC), [
      Color(0xFF5B2C6F),
      Color(0xFFB8611F),
      Color(0xFF1E4D4A),
    ]),
  ];

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
    final hash = stableHash(seed);
    final random = math.Random(hash);
    final palette = palettes[hash % palettes.length];
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.ground);

    final bands = 3 + random.nextInt(3);
    final bandWidth = size.width / bands;
    for (var b = 0; b < bands; b++) {
      final left = b * bandWidth;
      final lozengeHeight = bandWidth * (1.0 + random.nextDouble() * 0.8);
      final phase = random.nextDouble() * lozengeHeight;
      final dye = palette.dyes[(b + hash) % palette.dyes.length];
      final accent = palette.dyes[(b + hash + 1) % palette.dyes.length];
      for (
        var y = -lozengeHeight + phase;
        y < size.height;
        y += lozengeHeight
      ) {
        _lozenge(canvas, left, y, bandWidth, lozengeHeight, dye, random);
        _lozenge(
          canvas,
          left + bandWidth * 0.3,
          y + lozengeHeight * 0.3,
          bandWidth * 0.4,
          lozengeHeight * 0.4,
          accent,
          random,
        );
      }
    }
  }

  /// One lozenge drawn as a few jittered, translucent passes so its edges
  /// feather like resist-dyed warp threads.
  void _lozenge(
    Canvas canvas,
    double left,
    double top,
    double width,
    double height,
    Color color,
    math.Random random,
  ) {
    const passes = 4;
    for (var i = 0; i < passes; i++) {
      final jitter = (random.nextDouble() - 0.5) * width * 0.12;
      final path = Path()
        ..moveTo(left + width / 2 + jitter, top)
        ..lineTo(left + width + jitter, top + height / 2)
        ..lineTo(left + width / 2 + jitter, top + height)
        ..lineTo(left + jitter, top + height / 2)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = color.withValues(alpha: i == 0 ? 0.9 : 0.25),
      );
    }
  }

  @override
  bool shouldRepaint(AtlasPainter oldDelegate) => oldDelegate.seed != seed;
}
