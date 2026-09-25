import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../history/data/history_providers.dart';
import '../../history/domain/history_entry.dart';
import '../../literature/data/literature_providers.dart';
import '../../literature/domain/poet_era.dart';

/// A titled horizontal row of cards.
class _Strip extends StatelessWidget {
  const _Strip({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 28, bottom: 10),
          child: Text(
            title.toUpperCase(),
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
        ),
        SizedBox(
          // Room for two title lines and a meta line at the reader's text
          // size, so large system fonts never clip a card.
          height: 28 + MediaQuery.textScalerOf(context).scale(68),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, index) => children[index],
          ),
        ),
      ],
    );
  }
}

/// A small boxed card in a strip: a serif title and one line under it.
class _StripCard extends StatelessWidget {
  const _StripCard({
    required this.title,
    required this.onTap,
    this.subtitle,
    this.width = 168,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      child: Material(
        color: colors.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: colors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: QalamTypography.literaryTitle(
                      color: colors.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
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

/// Poets by era: three cards with counts, each opening the filtered list.
class PoetEraStrip extends ConsumerWidget {
  const PoetEraStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final poets = ref.watch(literaryAuthorsProvider).valueOrNull;
    if (poets == null) return const SizedBox.shrink();
    final counts = <PoetEra, int>{};
    for (final poet in poets.where((p) => p.hasCanonicalName)) {
      final era = PoetEra.of(poet);
      if (era != null) counts[era] = (counts[era] ?? 0) + 1;
    }
    return _Strip(
      title: AppTranslations.get('explore_eras_title', lang),
      children: [
        for (final era in PoetEra.values)
          _StripCard(
            title: AppTranslations.get(era.labelKey, lang),
            subtitle: AppTranslations.get('explore_poets_count', lang, [
              AppTranslations.formatNumber(counts[era] ?? 0, lang),
            ]),
            onTap: () => context.push('/literature/poets?era=${era.name}'),
          ),
      ],
    );
  }
}

/// School grades 5-11, each opening the grade's literature programme.
class GradeStrip extends ConsumerWidget {
  const GradeStrip({super.key});

  static const grades = ['5', '6', '7', '8', '9', '10', '11'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    return _Strip(
      title: AppTranslations.get('explore_grades_title', lang),
      children: [
        for (final grade in grades)
          _StripCard(
            width: 112,
            title: AppTranslations.get('hist_filter_grade', lang, [
              AppTranslations.formatDigits(grade, lang),
            ]),
            onTap: () => context.push('/literature/school?grade=$grade'),
          ),
      ],
    );
  }
}

/// Empires and dynasties in the order the textbooks teach them.
class HistoryTimelineStrip extends ConsumerWidget {
  const HistoryTimelineStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final entries = ref.watch(historyEntriesProvider).valueOrNull;
    if (entries == null) return const SizedBox.shrink();
    final states = [
      for (final entry in entries)
        if (entry.kind == HistoryEntryKind.empire ||
            entry.kind == HistoryEntryKind.dynasty)
          entry,
    ];
    // Stable by grade: the file keeps each grade's entries in the order
    // its textbook teaches them.
    int grade(HistoryEntry e) => int.tryParse(e.grade) ?? 99;
    final position = {for (var i = 0; i < states.length; i++) states[i]: i};
    final ordered = [...states]
      ..sort((a, b) {
        final byGrade = grade(a).compareTo(grade(b));
        return byGrade != 0 ? byGrade : position[a]!.compareTo(position[b]!);
      });
    if (ordered.isEmpty) return const SizedBox.shrink();
    return _Strip(
      title: AppTranslations.get('explore_timeline_title', lang),
      children: [
        for (final entry in ordered)
          _StripCard(
            title: isPersian && (entry.titlePersian?.isNotEmpty ?? false)
                ? entry.titlePersian!
                : entry.title,
            subtitle: isPersian && (entry.datesPersian?.isNotEmpty ?? false)
                ? entry.datesPersian
                : entry.dates ?? entry.period,
            onTap: () => context.push('/history/${entry.id}'),
          ),
      ],
    );
  }
}
