import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../../../shared/providers/reading_script_provider.dart';
import '../../../history/data/history_providers.dart';
import '../../data/literature_providers.dart';
import '../../domain/domain.dart';
import '../literary_author_display_text.dart';
import '../literary_work_display_text.dart';

/// What follows a poem: previous/next in the works collection, more by the
/// same poet, and the poet's period in History (from the poet's own
/// `relatedHistoryEntryIds`; nothing is inferred).
class ReaderEndOfText extends ConsumerWidget {
  const ReaderEndOfText({
    super.key,
    required this.work,
    this.showNeighbours = true,
    this.showConnections = true,
  });

  final LiteraryWork work;

  /// Previous/next in the collection (under the text).
  final bool showNeighbours;

  /// More by the poet and the period (in the desktop context pane).
  final bool showConnections;

  /// How many other works by the same poet are listed before "poet page".
  static const int maxMoreByPoet = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final persianTitles =
        ref.watch(readingScriptProvider) == ReadingScript.persian;
    String tr(String key) => AppTranslations.get(key, lang);

    final works = ref.watch(approvedWorksProvider).valueOrNull ?? const [];
    final index = works.indexWhere((candidate) => candidate.id == work.id);
    final author = ref.watch(authorByIdProvider(work.authorId)).valueOrNull;
    final history = ref.watch(historyEntriesProvider).valueOrNull ?? const [];

    String title(LiteraryWork w) => persianTitles
        ? LiteraryWorkDisplayText.title(w, DisplayLanguage.persian)
        : w.title;
    TextDirection direction() =>
        persianTitles ? TextDirection.rtl : TextDirection.ltr;

    QalamNeighbour? neighbour(int at, String labelKey) {
      if (index < 0 || at < 0 || at >= works.length) return null;
      final target = works[at];
      return QalamNeighbour(
        label: tr(labelKey),
        title: title(target),
        titleDirection: direction(),
        onTap: () => context.push('/literature/work/${target.id}'),
      );
    }

    final byPoet = works
        .where((w) => w.authorId == work.authorId && w.id != work.id)
        .take(maxMoreByPoet)
        .toList();
    final poetName = LiteraryAuthorDisplayText.nameOrFallback(
      author,
      lang,
      work.authorId,
    );

    final isPersianUi = lang == DisplayLanguage.persian;
    final periodIds = author?.relatedHistoryEntryIds.toSet() ?? const {};
    final period = history.where(
      (entry) =>
          periodIds.contains(entry.id) &&
          (!isPersianUi || (entry.titlePersian?.trim().isNotEmpty ?? false)),
    );

    return QalamEndOfText(
      heading: tr('end_heading'),
      previous: showNeighbours ? neighbour(index - 1, 'end_previous') : null,
      next: showNeighbours ? neighbour(index + 1, 'end_next') : null,
      groups: [
        if (showConnections) ...[
          QalamRelatedGroup(
            title: AppTranslations.get('end_more_by', lang, [poetName]),
            rows: [
              for (final other in byPoet)
                QalamIndexRow(
                  title: title(other),
                  subtitle: LiteraryWorkDisplayText.distinctIncipit(
                    other,
                    lang,
                  ),
                  onTap: () => context.push('/literature/work/${other.id}'),
                ),
              if (author != null)
                QalamIndexRow(
                  title: tr('end_poet_page'),
                  onTap: () => context.push('/literature/poet/${author.id}'),
                ),
            ],
          ),
          QalamRelatedGroup(
            title: tr('end_same_period'),
            rows: [
              for (final entry in period)
                QalamIndexRow(
                  title: isPersianUi
                      ? (entry.titlePersian ?? '').trim()
                      : entry.title,
                  subtitle: isPersianUi
                      ? (entry.datesPersian ?? entry.periodPersian)
                      : (entry.dates ?? entry.period),
                  onTap: () => context.push('/history/${entry.id}'),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
