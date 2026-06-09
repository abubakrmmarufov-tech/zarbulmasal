import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Widget child;

  const SplashScreen({super.key, required this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _scaleController.forward();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _glowController.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        setState(() => _showSplash = false);
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_showSplash) return widget.child;
    return _SplashContent(
      fadeAnimation: _fadeAnimation,
      glowAnimation: _glowAnimation,
      scaleAnimation: _scaleAnimation,
    );
  }
}

class _SplashContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> glowAnimation;
  final Animation<double> scaleAnimation;

  const _SplashContent({
    required this.fadeAnimation,
    required this.glowAnimation,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgTop = isDark
        ? const Color(0xFF1C0F05)
        : const Color(0xFFFFF8F0);
    final bgBottom = isDark
        ? const Color(0xFF0D0702)
        : const Color(0xFFFAF0E0);
    final textColor = isDark
        ? const Color(0xFFF5EFE0)
        : const Color(0xFF1C1917);
    final subtitleColor = isDark
        ? const Color(0xFFB8A882)
        : const Color(0xFF57534E);

    return AnimatedBuilder(
      animation: fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: fadeAnimation.value.clamp(0.0, 1.0),
          child: Scaffold(
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgTop, bgBottom],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    CustomPaint(
                      size: const Size(280, 280),
                      painter: _TextilePatternPainter(isDark: isDark),
                    ),
                    AnimatedBuilder(
                      animation: glowAnimation,
                      builder: (context, child) {
                        final glow = glowAnimation.value.clamp(0.0, 1.0);
                        return Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentGold
                                    .withValues(alpha: 0.35 * glow),
                                blurRadius: 30 * glow,
                                spreadRadius: 8 * glow,
                              ),
                              BoxShadow(
                                color: AppColors.accentGold
                                    .withValues(alpha: 0.12 * glow),
                                blurRadius: 60 * glow,
                                spreadRadius: 20 * glow,
                              ),
                            ],
                          ),
                          child: Transform.scale(
                            scale: scaleAnimation.value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.accentGold,
                                    AppColors.accentGold.withValues(alpha: 0.7),
                                  ],
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 3,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'З',
                                  style: TextStyle(
                                    fontFamily: 'NotoSerif',
                                    fontSize: 72,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Transform.scale(
                      scale: scaleAnimation.value.clamp(0.0, 1.0),
                      child: Column(
                        children: [
                          Text(
                            'Зарбулмасал',
                            style: TextStyle(
                              fontFamily: 'NotoSerif',
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ҳикмати ҳазорсолаи тоҷик',
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 16,
                              color: subtitleColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: CustomPaint(
                        size: const Size(200, 12),
                        painter: _OrnamentPainter(
                          color: AppColors.accentGold.withValues(alpha: isDark ? 0.4 : 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TextilePatternPainter extends CustomPainter {
  final bool isDark;

  _TextilePatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: isDark ? 0.04 : 0.06)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    const radius = 120.0;

    for (int i = 1; i <= 6; i++) {
      final r = radius * (i / 6);
      _drawDashedCircle(canvas, center, r, paint);
    }

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, end, paint);
    }

    final diamondPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: isDark ? 0.05 : 0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4) + (math.pi / 8);
      final r = radius * 0.65;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);

      final path = Path();
      path.moveTo(x, y - 8);
      path.lineTo(x + 6, y);
      path.lineTo(x, y + 8);
      path.lineTo(x - 6, y);
      path.close();
      canvas.drawPath(path, diamondPaint);
    }
  }

  void _drawDashedCircle(Canvas canvas, Offset center, double radius, Paint paint) {
    const dashCount = 60;
    const gapRatio = 0.5;
    final dashAngle = (2 * math.pi) / dashCount;
    final gapAngle = dashAngle * gapRatio;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashAngle + gapAngle);
      final sweepAngle = dashAngle * (1 - gapRatio);

      final path = Path();
      path.addArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrnamentPainter extends CustomPainter {
  final Color color;

  _OrnamentPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final diamondPath = Path();
    diamondPath.moveTo(centerX, 0);
    diamondPath.lineTo(centerX + 6, centerY);
    diamondPath.lineTo(centerX, size.height);
    diamondPath.lineTo(centerX - 6, centerY);
    diamondPath.close();
    canvas.drawPath(diamondPath, paint..style = PaintingStyle.fill);

    canvas.drawLine(Offset(0, centerY), Offset(centerX - 12, centerY), paint);
    canvas.drawLine(Offset(centerX + 12, centerY), Offset(size.width, centerY), paint);

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(0, centerY), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width, centerY), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
