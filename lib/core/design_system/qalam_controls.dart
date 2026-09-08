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
    return IconButton(
      tooltip: AppTranslations.get(
        saved ? 'bookmark_remove' : 'bookmark_add',
        lang,
      ),
      isSelected: saved,
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(proverbId),
      icon: Icon(
        saved ? Icons.bookmark : Icons.bookmark_outline,
        color: color ?? (saved ? Theme.of(context).colorScheme.primary : null),
        size: 23,
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
      spacing: 12,
      children: [
        for (final value in DisplayLanguage.values)
          Semantics(
            selected: lang == value,
            child: TextButton(
              onPressed: () =>
                  ref.read(displayLanguageProvider.notifier).setLanguage(value),
              style: TextButton.styleFrom(
                foregroundColor: lang == value
                    ? colors.primary
                    : colors.onSurfaceVariant,
                side: BorderSide(
                  color: lang == value ? colors.primary : colors.outline,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                value == DisplayLanguage.persian ? 'فارسی' : 'Тоҷикӣ',
                style: QalamTypography.label(
                  color: lang == value
                      ? colors.primary
                      : colors.onSurfaceVariant,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class QalamSectionLink extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const QalamSectionLink({
    super.key,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.outline)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(number, style: QalamTypography.meta(color: colors.primary)),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: QalamTypography.sectionTitle(
                        color: colors.onSurface,
                        fontSize: 23,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
