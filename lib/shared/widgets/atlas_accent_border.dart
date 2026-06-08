import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AtlasAccentBorder extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final bool enabled;

  const AtlasAccentBorder({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.tertiaryGoldDark : AppColors.accentGold;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: gold.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            child,
            // Top-left corner ornament
            Positioned(
              top: 0,
              left: 0,
              child: _CornerOrnament(gold: gold, isDark: isDark, corner: _Corner.topLeft),
            ),
            // Top-right corner ornament
            Positioned(
              top: 0,
              right: 0,
              child: _CornerOrnament(gold: gold, isDark: isDark, corner: _Corner.topRight),
            ),
            // Bottom-left corner ornament
            Positioned(
              bottom: 0,
              left: 0,
              child: _CornerOrnament(gold: gold, isDark: isDark, corner: _Corner.bottomLeft),
            ),
            // Bottom-right corner ornament
            Positioned(
              bottom: 0,
              right: 0,
              child: _CornerOrnament(gold: gold, isDark: isDark, corner: _Corner.bottomRight),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _CornerOrnament extends StatelessWidget {
  final Color gold;
  final bool isDark;
  final _Corner corner;

  const _CornerOrnament({
    required this.gold,
    required this.isDark,
    required this.corner,
  });

  @override
  Widget build(BuildContext context) {
    const size = 14.0;
    return CustomPaint(
      size: const Size(size, size),
      painter: _CornerPainter(goldColor: gold, corner: corner),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color goldColor;
  final _Corner corner;

  _CornerPainter({required this.goldColor, required this.corner});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = goldColor.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, size.height * 0.6);
        path.lineTo(0, 0);
        path.lineTo(size.width * 0.6, 0);
        canvas.drawPath(path, paint);
        canvas.drawCircle(const Offset(0, 0), 2, Paint()..color = goldColor..style = PaintingStyle.fill);
        break;
      case _Corner.topRight:
        path.moveTo(size.width * 0.4, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height * 0.6);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(size.width, 0), 2, Paint()..color = goldColor..style = PaintingStyle.fill);
        break;
      case _Corner.bottomLeft:
        path.moveTo(0, size.height * 0.4);
        path.lineTo(0, size.height);
        path.lineTo(size.width * 0.6, size.height);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(0, size.height), 2, Paint()..color = goldColor..style = PaintingStyle.fill);
        break;
      case _Corner.bottomRight:
        path.moveTo(size.width * 0.4, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, size.height * 0.4);
        canvas.drawPath(path, paint);
        canvas.drawCircle(Offset(size.width, size.height), 2, Paint()..color = goldColor..style = PaintingStyle.fill);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      goldColor != oldDelegate.goldColor || corner != oldDelegate.corner;
}
