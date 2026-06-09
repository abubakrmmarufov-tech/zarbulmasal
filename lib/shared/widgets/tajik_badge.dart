import 'package:flutter/material.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';

class TajikBadge extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final double borderRadius;

  const TajikBadge({
    super.key,
    this.icon,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderRadius = 20,
  });

  factory TajikBadge.category({
    Key? key,
    required String text,
    required IconData icon,
    required Color accentColor,
  }) {
    return TajikBadge(
      key: key,
      icon: icon,
      text: text,
      backgroundColor: accentColor.withValues(alpha: 0.12),
      foregroundColor: accentColor,
    );
  }

  factory TajikBadge.level({
    Key? key,
    required String text,
    required Color accentColor,
  }) {
    return TajikBadge(
      key: key,
      text: text,
      backgroundColor: accentColor.withValues(alpha: 0.12),
      foregroundColor: accentColor,
    );
  }

  factory TajikBadge.type({
    Key? key,
    required bool isTraditional,
    required Color primaryColor,
    DisplayLanguage displayLanguage = DisplayLanguage.tajik,
  }) {
    final text = AppTranslations.get(
      isTraditional ? 'badges_traditional' : 'badges_modern',
      displayLanguage,
    );
    return TajikBadge(
      key: key,
      text: text,
      backgroundColor: isTraditional
          ? primaryColor.withValues(alpha: 0.12)
          : Colors.grey.withValues(alpha: 0.12),
      foregroundColor: isTraditional ? primaryColor : Colors.grey.shade600,
    );
  }

  factory TajikBadge.verified({
    Key? key,
    required bool isVerified,
    DisplayLanguage displayLanguage = DisplayLanguage.tajik,
  }) {
    final text = AppTranslations.get(
      isVerified ? 'badges_verified' : 'badges_unverified',
      displayLanguage,
    );
    return TajikBadge(
      key: key,
      icon: isVerified ? Icons.verified : Icons.help_outline,
      text: text,
      backgroundColor: isVerified
          ? Colors.green.withValues(alpha: 0.12)
          : Colors.amber.withValues(alpha: 0.12),
      foregroundColor: isVerified ? Colors.green.shade700 : Colors.amber.shade700,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: foregroundColor),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              fontFamily: 'NotoSans',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
