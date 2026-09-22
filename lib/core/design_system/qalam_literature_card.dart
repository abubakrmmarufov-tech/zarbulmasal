import 'package:flutter/material.dart';
import 'qalam_colors.dart';
import 'qalam_typography.dart';
import 'qalam_spacing.dart';

/// A prominent editorial card for the home screen that serves as the
/// entry point to the Мероси адабӣ (Literary Heritage) section.
///
/// Uses the same dark-ink surface treatment as [QalamDailyHero] to
/// signal cultural weight and importance within the editorial flow.
class QalamLiteratureCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String subtitle;
  final String sectionLabel;

  const QalamLiteratureCard({
    super.key,
    required this.onTap,
    required this.title,
    required this.subtitle,
    required this.sectionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final bg = isDark ? QalamColors.inkCard : QalamColors.ink;
    final textColor = isDark ? QalamColors.paperText : QalamColors.paper;
    // The card uses an ink surface in both themes. Keep the light-theme
    // eyebrow and supporting copy on the paper-text ramp; the softer
    // burgundy/ink-muted pair falls below WCAG 4.5:1 for normal text.
    final mutedColor = QalamColors.paperTextSoft;
    final accentColor = isDark
        ? QalamColors.antiqueGoldSoft
        : QalamColors.antiqueGold;
    final borderColor = isDark
        ? QalamColors.hairlineDark
        : QalamColors.hairline;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: QalamSpacing.pageH,
        vertical: QalamSpacing.sectionVTight,
      ),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(QalamSpacing.cardRadius),
          side: BorderSide(color: borderColor, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(QalamSpacing.cardPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionLabel,
                  style: QalamTypography.eyebrow(color: accentColor),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: QalamTypography.literaryTitle(
                              color: textColor,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subtitle,
                            style: QalamTypography.bodySecondary(
                              color: mutedColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      isRtl ? Icons.arrow_back : Icons.arrow_forward,
                      color: accentColor,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
