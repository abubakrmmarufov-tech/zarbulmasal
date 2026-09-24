import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../literature/data/literature_providers.dart';
import '../../literature/presentation/literary_author_display_text.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';

/// What follows a history entry: previous/next entry of the same family in
/// the catalogue's own order, the poets of the period and related works.
///
/// Poets come from the entry's `relatedAuthorIds` and from poets whose
/// `relatedHistoryEntryIds` name this entry; works from `relatedWorkIds`.
/// Records that cannot be resolved are left out rather than shown as IDs.
class HistoryEndOfText extends ConsumerWidget {
  const HistoryEndOfText({super.key, required this.entry});

  final HistoryEntry entry;

  /// States (empires and dynasties) read as one sequence of periods; other
  /// kinds step through their own kind.
  static String familyOf(HistoryEntryKind kind) => switch (kind) {
    HistoryEntryKind.empire || HistoryEntryKind.dynasty => 'state',
    _ => kind.name,
  };

  /// The entries before and after [entry] within its family, in [entries]
  /// order (the order the History list shows).
  static ({HistoryEntry? previous, HistoryEntry? next}) neighboursOf(
    HistoryEntry entry,
    List<HistoryEntry> entries,
  ) {
    final family = familyOf(entry.kind);
    final sequence = entries
        .where((candidate) => familyOf(candidate.kind) == family)
        .toList(growable: false);
    final index = sequence.indexWhere((candidate) => candidate.id == entry.id);
    if (index < 0) return (previous: null, next: null);
    return (
      previous: index > 0 ? sequence[index - 1] : null,
      next: index + 1 < sequence.length ? sequence[index + 1] : null,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    String tr(String key) => AppTranslations.get(key, lang);

    final entries = ref.watch(historyEntriesProvider).valueOrNull ?? const [];
    final authors = ref.watch(literaryAuthorsProvider).valueOrNull ?? const [];
    final works = ref.watch(approvedWorksProvider).valueOrNull ?? const [];

    String? titleOf(HistoryEntry target) {
      if (!isPersian) return target.title;
      final persian = target.titlePersian?.trim() ?? '';
      return persian.isEmpty ? null : persian;
    }

    QalamNeighbour? neighbour(HistoryEntry? target, String labelKey) {
      if (target == null) return null;
      final title = titleOf(target);
      if (title == null) return null;
      return QalamNeighbour(
        label: tr(labelKey),
        title: title,
        onTap: () => context.push('/history/${target.id}'),
      );
    }

    final around = neighboursOf(entry, entries);

    final poetIds = <String>{
      ...entry.relatedAuthorIds,
      for (final author in authors)
        if (author.relatedHistoryEntryIds.contains(entry.id)) author.id,
    };
    final poets = [
      for (final id in poetIds)
        ?authors.where((author) => author.id == id).firstOrNull,
    ];
    final relatedWorks =
        [
          for (final id in entry.relatedWorkIds)
            ?works.where((work) => work.id == id).firstOrNull,
        ].where(
          (work) =>
              !isPersian || (work.titlePersian?.trim().isNotEmpty ?? false),
        );

    return QalamEndOfText(
      heading: tr('end_heading'),
      previous: neighbour(around.previous, 'end_previous'),
      next: neighbour(around.next, 'end_next'),
      groups: [
        QalamRelatedGroup(
          title: tr('hist_related_authors'),
          rows: [
            for (final poet in poets)
              QalamIndexRow(
                title: LiteraryAuthorDisplayText.nameOrFallback(
                  poet,
                  lang,
                  poet.id,
                ),
                subtitle: poet.hasAuditableBiographySource
                    ? LiteraryAuthorDisplayText.lifespan(poet, lang)
                    : null,
                onTap: () => context.push('/literature/poet/${poet.id}'),
              ),
          ],
        ),
        QalamRelatedGroup(
          title: tr('hist_related_works'),
          rows: [
            for (final work in relatedWorks)
              QalamIndexRow(
                title: isPersian
                    ? (work.titlePersian ?? '').trim()
                    : work.title,
                subtitle: isPersian && work.titlePersianSource == 'generated'
                    ? tr('lit_generated_script_label')
                    : null,
                onTap: () => context.push('/literature/work/${work.id}'),
              ),
          ],
        ),
      ],
    );
  }
}
