import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CulturalHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool useGradient; // Kept for API compatibility, but we use solid + motif
  final double minHeight;

  const CulturalHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.useGradient = true,
    this.minHeight = 120,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Editorial style backgrounds
    final bgColor = isDark ? theme.colorScheme.surface : theme.scaffoldBackgroundColor;
    final textColor = isDark ? theme.colorScheme.onSurface : theme.colorScheme.primary;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: bgColor,
        // Subtle bottom border instead of full ornament
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Subtle Motif background
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.spa_rounded, // Subtle Pamir/Adras inspired organic shape
                size: 140,
                color: isDark 
                    ? theme.colorScheme.tertiary.withValues(alpha: 0.03) 
                    : theme.colorScheme.primary.withValues(alpha: 0.03),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.notoSerif(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            subtitle!,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSans(
                              fontSize: 15,
                              color: isDark 
                                  ? Colors.white.withValues(alpha: 0.6) 
                                  : Colors.black.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 16),
                    trailing!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
