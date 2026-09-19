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

class QalamScriptSwitch extends ConsumerWidget {
  const QalamScriptSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        for (final value in DisplayLanguage.values)
          Semantics(
            selected: lang == value,
            child: OutlinedButton(
              onPressed: () =>
                  ref.read(displayLanguageProvider.notifier).setLanguage(value),
              style: OutlinedButton.styleFrom(
                foregroundColor: lang == value
                    ? colors.primary
                    : colors.onSurfaceVariant,
                backgroundColor: lang == value
                    ? colors.primary.withValues(alpha: 0.08)
                    : Colors.transparent,
                side: BorderSide(
                  color: lang == value ? colors.primary : colors.outlineVariant,
                  width: lang == value ? 1.5 : 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                minimumSize: const Size(44, 40),
              ),
              child: Text(
                value == DisplayLanguage.persian
                    ? 'فارسی (عربی)'
                    : 'Тоҷикӣ (Кириллӣ)',
                style: QalamTypography.label(
                  color: lang == value
                      ? colors.primary
                      : colors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class QalamSectionLink extends ConsumerWidget {
  final String number;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const QalamSectionLink({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final enabled = onTap != null;
    final contentColor = enabled
        ? colors.onSurface
        : colors.onSurfaceVariant.withValues(alpha: 0.60);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(QalamSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 32,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  number,
                  style: QalamTypography.eyebrow(
                    color: enabled
                        ? colors.primary
                        : colors.onSurfaceVariant.withValues(alpha: 0.60),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: QalamTypography.sectionTitle(
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
