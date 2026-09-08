import 'package:flutter/material.dart';
import 'qalam_typography.dart';

/// A quiet, full-width preference row. Text can wrap without a fixed height.
class QalamSettingRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool showBorder;

  const QalamSettingRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: 22),
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: padding,
          decoration: BoxDecoration(
            border: showBorder
                ? Border(bottom: BorderSide(color: colors.outlineVariant))
                : null,
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 16)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: QalamTypography.sectionTitle(
                        color: colors.onSurface,
                        fontSize: 19,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle!,
                        style: QalamTypography.bodySecondary(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 16), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compatibility wrapper for plain supporting icons, without a container.
class QalamIconTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const QalamIconTile({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) => Icon(icon, color: color, size: size);
}
