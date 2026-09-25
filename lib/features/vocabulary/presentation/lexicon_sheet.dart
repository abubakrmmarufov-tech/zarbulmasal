import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../data/words_provider.dart';
import '../domain/lexicon_index.dart';
import '../domain/word_entry.dart';

/// Shows the Lexicon's meaning of [word], tapped in a poem, in a bottom
/// sheet: each headword it is found under, its meaning as the textbook
/// glossary prints it, and the book and page.
Future<void> showLexiconSheet(BuildContext context, String word) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => LexiconSheet(word: word),
  );
}

class LexiconSheet extends ConsumerWidget {
  const LexiconSheet({super.key, required this.word});

  /// The word as printed in the poem.
  final String word;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);
    final index = ref.watch(lexiconIndexProvider);
    final entries = index.valueOrNull?.lookup(word);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          children: [
            Semantics(
              header: true,
              child: Text(
                word,
                textDirection: TextDirection.ltr,
                style: QalamTypography.literaryTitle(
                  color: colors.onSurface,
                  fontSize: 26,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (entries == null)
              Text(
                tr('lex_sheet_loading'),
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              )
            else if (entries.isEmpty) ...[
              Text(
                tr('lex_sheet_not_found'),
                style: QalamTypography.bodySecondary(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.translate),
                  label: Text(tr('lex_sheet_open')),
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/vocabulary');
                  },
                ),
              ),
            ] else
              for (final entry in entries)
                _Meaning(entry: entry, showHeadword: !_same(entry.term, word)),
          ],
        ),
      ),
    );
  }

  static bool _same(String a, String b) => a.toLowerCase() == b.toLowerCase();
}

class _Meaning extends ConsumerWidget {
  const _Meaning({required this.entry, required this.showHeadword});

  final WordEntry entry;

  /// Whether to name the headword: the word was found under its stem
  /// («гулҳо» under «Гул»).
  final bool showHeadword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final grade = LexiconIndex.gradeOf(entry);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeadword)
            Text(
              entry.term,
              textDirection: TextDirection.ltr,
              style: QalamTypography.literaryTitle(
                color: colors.primary,
                fontSize: 18,
              ),
            ),
          Text(
            entry.definition,
            textDirection: TextDirection.ltr,
            style: QalamTypography.body(color: colors.onSurface),
          ),
          if (grade != null && entry.pdfPage > 0) ...[
            const SizedBox(height: 4),
            Text(
              AppTranslations.get('lex_sheet_source', lang, [
                AppTranslations.formatDigits(grade, lang),
                AppTranslations.formatNumber(entry.pdfPage, lang),
              ]),
              style: QalamTypography.meta(
                color: colors.onSurfaceVariant,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
