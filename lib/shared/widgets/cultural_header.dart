import 'package:flutter/material.dart';

class CulturalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool useGradient;
  final double minHeight;

  const CulturalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.useGradient = true,
    this.minHeight = 140,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        gradient: useGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF2D1F0E),
                        const Color(0xFF3D2A12),
                        const Color(0xFF4A3018),
                      ]
                    : [
                        const Color(0xFFC2410C),
                        const Color(0xFFB91C1C),
                        const Color(0xFF9A3412),
                      ],
              )
            : null,
        color: useGradient
            ? null
            : (isDark ? const Color(0xFF2D1F0E) : const Color(0xFFB91C1C)),
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                        style: const TextStyle(
                          fontFamily: 'NotoSerif',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'NotoSans',
                              fontSize: 15,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  trailing != null ? trailing! : const SizedBox.shrink(),
                ],
              ),
              const SizedBox(height: 16),
              // Atlas textile-inspired decorative border
              _buildOrnamentLine(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrnamentLine(bool isDark) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.transparent,
                  const Color(0xFFD4A843),
                  const Color(0xFFF5DEB3),
                  const Color(0xFFD4A843),
                  Colors.transparent,
                ]
              : [
                  Colors.transparent,
                  Colors.white.withValues(alpha: 0.3),
                  Colors.white,
                  Colors.white.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
        ),
      ),
    );
  }
}
