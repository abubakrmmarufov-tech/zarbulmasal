import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TextileDivider extends StatelessWidget {
  final double height;
  final bool centered;

  const TextileDivider({
    super.key,
    this.height = 24,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.tertiaryGoldDark : AppColors.accentGold;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _TextilePainter(
          goldColor: gold,
          isDark: isDark,
          centered: centered,
        ),
      ),
    );
  }
}

class _TextilePainter extends CustomPainter {
  final Color goldColor;
  final bool isDark;
  final bool centered;

  _TextilePainter({
    required this.goldColor,
    required this.isDark,
    required this.centered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = goldColor.withValues(alpha: isDark ? 0.5 : 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = goldColor.withValues(alpha: isDark ? 0.6 : 0.9)
      ..style = PaintingStyle.fill;

    final centerY = size.height / 2;
    final spacing = 14.0;
    final startX = centered ? (size.width - (size.width ~/ spacing * spacing)) / 2 : 0.0;

    // Draw horizontal line
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      paint..color = goldColor.withValues(alpha: isDark ? 0.3 : 0.4),
    );

    // Draw diamond motifs
    var x = startX;
    while (x < size.width) {
      final cx = x + spacing / 2;
      if (cx > size.width) break;

      // Diamond shape
      final diamondPath = Path()
        ..moveTo(cx, centerY - 5)
        ..lineTo(cx + 4, centerY)
        ..lineTo(cx, centerY + 5)
        ..lineTo(cx - 4, centerY)
        ..close();

      canvas.drawPath(diamondPath, fillPaint..color = goldColor.withValues(alpha: isDark ? 0.5 : 0.7));
      canvas.drawPath(diamondPath, paint..color = goldColor.withValues(alpha: isDark ? 0.4 : 0.5));

      // Small dots flanking the diamond
      canvas.drawCircle(Offset(cx - spacing / 3, centerY), 1.5, fillPaint..color = goldColor.withValues(alpha: isDark ? 0.4 : 0.6));
      canvas.drawCircle(Offset(cx + spacing / 3, centerY), 1.5, fillPaint..color = goldColor.withValues(alpha: isDark ? 0.4 : 0.6));

      x += spacing;
    }
  }

  @override
  bool shouldRepaint(covariant _TextilePainter oldDelegate) =>
      goldColor != oldDelegate.goldColor ||
      isDark != oldDelegate.isDark ||
      centered != oldDelegate.centered;
}
