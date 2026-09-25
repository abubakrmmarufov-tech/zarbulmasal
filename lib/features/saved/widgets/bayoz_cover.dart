import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';

/// A typeset «Баёз» cover: the anthology's title on a framed paper plate,
/// with its count. [isNew] draws the dashed "new Баёз" cover instead.
class BayozCover extends StatelessWidget {
  const BayozCover({
    super.key,
    required this.title,
    required this.onTap,
    this.countLabel,
    this.isNew = false,
  });

  final String title;
  final String? countLabel;
  final bool isNew;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: [title, ?countLabel].join(', '),
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isNew ? null : colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
            border: Border.all(
              color: isNew ? colors.outlineVariant : colors.primary,
              width: isNew ? 1 : 1.2,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: isNew
                ? null
                : BoxDecoration(
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.35),
                    ),
                  ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isNew)
                  Icon(Icons.add, color: colors.primary, size: 22)
                else
                  Container(width: 24, height: 2, color: colors.primary),
                const SizedBox(height: 28),
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: QalamTypography.literaryTitle(
                    color: isNew ? colors.primary : colors.onSurface,
                    fontSize: 20,
                    height: 1.15,
                  ),
                ),
                if (countLabel != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    countLabel!,
                    style: QalamTypography.meta(color: colors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
