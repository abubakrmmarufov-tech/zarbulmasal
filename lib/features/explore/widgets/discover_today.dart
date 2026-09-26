import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../core/l10n/script_direction.dart';
import '../../../shared/providers/app_providers.dart';
import '../../literature/data/literature_providers.dart';
import '../../literature/presentation/literary_author_display_text.dart';
import '../../literature/presentation/literary_work_display_text.dart';
import '../../vocabulary/data/words_provider.dart';

/// One poem, one proverb and one word, chosen by the day. "Again" draws a
/// new three. Offline: every pick comes from the bundled collections.
class DiscoverToday extends ConsumerStatefulWidget {
  const DiscoverToday({super.key, this.today});

  /// The day the picks follow. Defaults to the shared Tajikistan calendar
  /// day ([dailyDateProvider]), so a frozen clock freezes the picks too.
  final DateTime? today;

  @override
  ConsumerState<DiscoverToday> createState() => _DiscoverTodayState();
}

class _DiscoverTodayState extends ConsumerState<DiscoverToday> {
  int _draw = 0;

  /// A stable index for the day and draw, spread differently per list.
  int _pick(int length, int salt) {
    final DateTime date = widget.today ?? ref.watch(dailyDateProvider);
    // Whole calendar days in UTC, so the pick never shifts with the
    // device's time zone.
    final day = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(2024)).inDays;
    return ((day + _draw * 37) * 7919 + salt * 104729).abs() % length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    String tr(String key) => AppTranslations.get(key, lang);

    final works = ref.watch(approvedWorksProvider).valueOrNull ?? const [];
    final proverbs = ref.watch(proverbsProvider);
    final words = ref.watch(wordsProvider).valueOrNull ?? const [];

    final slips = <Widget>[];
    if (works.isNotEmpty) {
      final work = works[_pick(works.length, 1)];
      final poet = ref.watch(authorByIdProvider(work.authorId)).valueOrNull;
      slips.add(
        _DiscoverSlip(
          label: tr('explore_discover_poem'),
          title: LiteraryWorkDisplayText.title(work, lang),
          detail: LiteraryAuthorDisplayText.nameOrFallback(
            poet,
            lang,
            work.authorId,
          ),
          onTap: () => context.push('/literature/work/${work.id}'),
        ),
      );
    }
    if (proverbs.isNotEmpty) {
      final proverb = proverbs[_pick(proverbs.length, 2)];
      final text = isPersian && proverb.persianText.trim().isNotEmpty
          ? proverb.persianText
          : proverb.tajikCyrillic;
      slips.add(
        _DiscoverSlip(
          label: tr('explore_discover_proverb'),
          title: text,
          detail: isPersian ? null : proverb.meaningTj,
          onTap: () => context.push('/proverb/${proverb.id}'),
        ),
      );
    }
    if (words.isNotEmpty) {
      final word = words[_pick(words.length, 3)];
      slips.add(
        _DiscoverSlip(
          label: tr('explore_discover_word'),
          title: word.term,
          detail: word.definition,
          onTap: () => context.push(
            Uri(
              path: '/vocabulary',
              queryParameters: {'word': word.term},
            ).toString(),
          ),
        ),
      );
    }
    if (slips.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tr('explore_discover_title').toUpperCase(),
                style: QalamTypography.eyebrow(color: colors.primary),
              ),
            ),
            IconButton(
              tooltip: tr('explore_discover_again'),
              icon: const Icon(Icons.shuffle_rounded),
              onPressed: () => setState(() => _draw++),
            ),
          ],
        ),
        ...slips,
      ],
    );
  }
}

class _DiscoverSlip extends StatelessWidget {
  const _DiscoverSlip({
    required this.label,
    required this.title,
    required this.onTap,
    this.detail,
  });

  final String label;
  final String title;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return QalamSlip(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: QalamTypography.meta(color: colors.primary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textDirection: scriptDirection(title),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: QalamTypography.literaryTitle(
              color: colors.onSurface,
              fontSize: 18,
            ),
          ),
          if (detail != null && detail!.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detail!,
              textDirection: scriptDirection(detail!),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: QalamTypography.bodySecondary(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
