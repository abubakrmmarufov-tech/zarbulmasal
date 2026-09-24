import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import 'design_system.dart';

void qalamBack(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/');
  }
}

class QalamBookmark extends ConsumerWidget {
  final String proverbId;
  final Color? color;
  const QalamBookmark({super.key, required this.proverbId, this.color});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(favoritesProvider).contains(proverbId);
    final lang = ref.watch(displayLanguageProvider);
    final activeColor = color ?? Theme.of(context).colorScheme.primary;
    final inactiveColor =
        color ?? Theme.of(context).colorScheme.onSurfaceVariant;

    return IconButton(
      tooltip: AppTranslations.get(
        saved ? 'bookmark_remove' : 'bookmark_add',
        lang,
      ),
      isSelected: saved,
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(proverbId),
      icon: Icon(
        saved ? Icons.bookmark : Icons.bookmark_outline,
        color: saved ? activeColor : inactiveColor,
        size: 22,
      ),
    );
  }
}

class QalamSectionLink extends ConsumerWidget {
  /// Shown only where order means something (levels, grades); running
  /// numbers on a plain index carry no meaning and are omitted.
  final String? number;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const QalamSectionLink({
    super.key,
    this.number,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final displayNumber = number == null
        ? null
        : AppTranslations.formatDigits(number!, lang);
    final enabled = onTap != null;
    final contentColor = enabled
        ? colors.onSurface
        : colors.onSurfaceVariant.withValues(alpha: 0.60);

    final theme = Theme.of(context);
    // A boxed catalogue slip, like every list item in the app.
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: theme.brightness == Brightness.dark
            ? colors.surfaceContainer
            : colors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (displayNumber != null) ...[
                  Container(
                    width: 32,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      displayNumber,
                      style: QalamTypography.eyebrow(
                        color: enabled
                            ? colors.primary
                            : colors.onSurfaceVariant.withValues(alpha: 0.60),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: QalamTypography.literaryTitle(
                          color: contentColor,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: QalamTypography.bodySecondary(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  enabled
                      ? (isPersian ? Icons.arrow_back : Icons.arrow_forward)
                      : Icons.hourglass_empty,
                  size: 18,
                  color: enabled ? colors.primary : colors.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Directionality-aware chevron icon that points forward according to text direction.
/// Points right in LTR (Tajik Cyrillic) and left in RTL (Persian).
class QalamChevron extends StatelessWidget {
  final double size;
  final Color? color;

  const QalamChevron({super.key, this.size = 20, this.color});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    return Icon(
      isRtl ? Icons.chevron_left : Icons.chevron_right,
      size: size,
      color: color ?? Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
