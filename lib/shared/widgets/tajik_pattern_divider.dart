import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TajikPatternDivider extends StatelessWidget {
  const TajikPatternDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = isDark ? AppColors.tertiaryGoldDark : AppColors.accentGold;

    return SizedBox(
      height: 16,
      child: CustomPaint(
        size: const Size(double.infinity, 16),
        painter: _TajikPatternPainter(goldColor: gold, isDark: isDark),
      ),
    );
  }
}

class _TajikPatternPainter extends CustomPainter {
  final Color goldColor;
  final bool isDark;

  _TajikPatternPainter({required this.goldColor, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = goldColor.withValues(alpha: isDark ? 0.6 : 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = goldColor.withValues(alpha: isDark ? 0.8 : 1.0)
      ..style = PaintingStyle.fill;

    const dashWidth = 12.0;
    const dashSpace = 6.0;
    const dotRadius = 2.5;
    final centerY = size.height / 2;
    var x = 0.0;

    while (x < size.width) {
      canvas.drawLine(
        Offset(x, centerY),
        Offset((x + dashWidth).clamp(0, size.width), centerY),
        paint,
      );
      x += dashWidth + dashSpace;
    }

    final diamondCount = (size.width / (dashWidth * 3)).floor();
    for (int i = 0; i < diamondCount; i++) {
      final cx = (i * dashWidth * 3) + dashWidth * 1.5;
      if (cx > size.width - 6) break;
      canvas.drawCircle(Offset(cx, centerY), dotRadius, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TajikPatternPainter oldDelegate) =>
      goldColor != oldDelegate.goldColor || isDark != oldDelegate.isDark;
}
