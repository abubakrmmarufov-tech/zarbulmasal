import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PamirSilhouette extends StatelessWidget {
  final double height;
  final bool darkMode;

  const PamirSilhouette({
    super.key,
    this.height = 48,
    this.darkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _PamirPainter(darkMode: darkMode),
      ),
    );
  }
}

class _PamirPainter extends CustomPainter {
  final bool darkMode;

  _PamirPainter({required this.darkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = (darkMode ? Colors.white : Colors.white)
          .withValues(alpha: darkMode ? 0.05 : 0.12)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = (darkMode ? Colors.white : AppColors.accentGold)
          .withValues(alpha: darkMode ? 0.15 : 0.25)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.55);
    path.lineTo(size.width * 0.12, size.height * 0.45);
    path.lineTo(size.width * 0.18, size.height * 0.55);
    path.lineTo(size.width * 0.28, size.height * 0.30);
    path.lineTo(size.width * 0.38, size.height * 0.45);
    path.lineTo(size.width * 0.45, size.height * 0.20);
    path.lineTo(size.width * 0.52, size.height * 0.38);
    path.lineTo(size.width * 0.62, size.height * 0.15);
    path.lineTo(size.width * 0.70, size.height * 0.35);
    path.lineTo(size.width * 0.80, size.height * 0.28);
    path.lineTo(size.width * 0.88, size.height * 0.40);
    path.lineTo(size.width * 0.95, size.height * 0.30);
    path.lineTo(size.width, size.height * 0.45);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _PamirPainter oldDelegate) =>
      darkMode != oldDelegate.darkMode;
}
