import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import 'design_system.dart';

/// An open chapter entry. Levels describe the catalog, not invented progress.
class QalamLevelCard extends ConsumerWidget {
  final int level;
  final bool isSelected;
  final VoidCallback onTap;

  const QalamLevelCard({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final language = ref.watch(displayLanguageProvider);
    final isPersian = language == DisplayLanguage.persian;
    final name = isPersian
        ? AppConstants.getLevelNameFa(level)
        : AppConstants.getLevelName(level);
    final count = ref
        .watch(proverbsProvider)
        .where((p) => p.level == level)
        .length;
    final group = level <= 3
        ? 'beginner'
        : level <= 6
        ? 'intermediate'
        : level <= 9
        ? 'advanced'
        : 'master';
    final numeral = Text(
      AppTranslations.formatDigits('$level'.padLeft(2, '0'), language),
      style: QalamTypography.pageTitle(color: colors.primary, fontSize: 54),
    );
    final heading = Text(
      name,
      style: QalamTypography.sectionTitle(
        color: colors.onSurface,
        fontSize: 24,
      ),
    );
    final largeText = MediaQuery.textScalerOf(context).scale(16) > 22;
    return Semantics(
      selected: isSelected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 26),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: colors.outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (largeText) ...[
                  numeral,
                  const SizedBox(height: 8),
                  heading,
                ] else
                  Row(
                    children: [
                      numeral,
                      const SizedBox(width: 24),
                      Expanded(child: heading),
                      const SizedBox(width: 12),
                      Icon(
                        isSelected ? Icons.check : Icons.arrow_forward,
                        size: 22,
                        color: isSelected ? colors.primary : colors.onSurface,
                      ),
                    ],
                  ),
                const SizedBox(height: 14),
                Text(
                  AppTranslations.get('level_desc_$level', language),
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    Text(
                      AppTranslations.get('progression_$group', language),
                      style: QalamTypography.meta(color: colors.primary),
                    ),
                    Text(
                      '${AppTranslations.formatNumber(count, language)} ${AppTranslations.get('levels_proverbs', language)}',
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    if (largeText && isSelected)
                      Icon(Icons.check, size: 20, color: colors.primary),
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
