import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 38, color: colors.primary),
            const SizedBox(height: 28),
            Text(
              title,
              style: QalamTypography.sectionTitle(
                color: colors.onSurface,
                fontSize: 29,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 16),
              Text(
                subtitle!,
                style: QalamTypography.body(color: colors.onSurfaceVariant),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 28), action!],
          ],
        ),
      ),
    );
  }
}
