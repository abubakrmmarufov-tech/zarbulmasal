import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../literature/data/literature_providers.dart';

/// «Синфи шумо»: the grades that actually appear in the school canon data,
/// each opening the canon filtered to that grade.
class GradeLens extends ConsumerWidget {
  const GradeLens({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(schoolCanonProvider).valueOrNull;
    if (entries == null || entries.isEmpty) return const SizedBox.shrink();
    final lang = ref.watch(displayLanguageProvider);
    final grades = entries.map((entry) => entry.grade).toSet().toList()
      ..sort((a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            AppTranslations.get('home_grade_lens', lang).toUpperCase(),
            style: QalamTypography.eyebrow(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final grade in grades)
              ActionChip(
                label: Text(
                  AppTranslations.get('home_grade_chip', lang, [
                    AppTranslations.formatDigits(grade, lang),
                  ]),
                ),
                onPressed: () =>
                    context.push('/literature/school?grade=$grade'),
              ),
          ],
        ),
      ],
    );
  }
}
