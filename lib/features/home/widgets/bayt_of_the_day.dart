import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/reading_script_provider.dart';
import '../../literature/data/literature_providers.dart';
import '../../literature/domain/domain.dart';
import '../../literature/presentation/literary_author_display_text.dart';
import '../../literature/presentation/widgets/verse_view.dart';

/// The opening bayt of the day's poem, in the reading script, with its poet.
/// Generated Persian script carries its label here too.
class BaytOfTheDay extends ConsumerWidget {
  const BaytOfTheDay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final work = ref.watch(dailyVerseProvider).valueOrNull;
    if (work == null) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final persianScript =
        ref.watch(readingScriptProvider) == ReadingScript.persian;
    final author = ref.watch(authorByIdProvider(work.authorId)).valueOrNull;

    final persianText = work.textPersian ?? work.persianScriptRepresentation;
    final showPersian =
        persianScript && (persianText?.trim().isNotEmpty ?? false);
    final text = showPersian ? persianText! : (work.textTajik ?? '');
    final layout = VerseLayout.of(text, work.type);
    if (layout.stanzas.isEmpty) return const SizedBox.shrink();
    final firstStanza = layout.stanzas.first;
    final lines = firstStanza.unitsAreBayts
        ? firstStanza.units.first
        : firstStanza.units.take(2).expand((unit) => unit).toList();
    final generated = showPersian && work.persianScriptSource == 'generated';
    final direction = showPersian ? TextDirection.rtl : TextDirection.ltr;

    return InkWell(
      onTap: () => context.push('/literature/work/${work.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppTranslations.get('lit_daily_verse_eyebrow', lang),
              style: QalamTypography.eyebrow(color: colors.primary),
            ),
            const SizedBox(height: 12),
            // Set like the reader: an overflowing word drops under its line,
            // flush to the end edge.
            for (final line in lines)
              HangingIndentLine(
                text: line,
                textDirection: direction,
                indent: 21 * VerseView.hangingIndentEm,
                style: QalamTypography.verseText(
                  color: colors.onSurface,
                  fontSize: 21,
                  height: 1.6,
                ),
              ),
            if (generated) ...[
              const SizedBox(height: 6),
              Text(
                AppTranslations.get('lit_generated_script_label', lang),
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              LiteraryAuthorDisplayText.nameOrFallback(
                author,
                lang,
                work.authorId,
              ),
              style: QalamTypography.meta(
                color: colors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
