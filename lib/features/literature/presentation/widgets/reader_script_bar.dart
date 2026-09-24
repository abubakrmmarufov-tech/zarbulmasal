import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_translations.dart';
import '../../../../shared/providers/app_providers.dart';

/// Which text the poem reader shows. Only affects the text, never the
/// interface language or layout direction.
enum ReaderScriptMode { tajik, persian, parallel }

/// Script chips shown only when the work has a second script to switch to
/// (or, in Persian reading mode, to reach the Cyrillic original).
class ReaderScriptBar extends ConsumerWidget {
  const ReaderScriptBar({
    super.key,
    required this.mode,
    required this.showParallel,
    required this.onSelected,
  });

  final ReaderScriptMode mode;
  final bool showParallel;
  final ValueChanged<ReaderScriptMode> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    String tr(String key) => AppTranslations.get(key, lang);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: Text(tr('lit_script_cyrillic')),
            selected: mode == ReaderScriptMode.tajik,
            onSelected: (_) => onSelected(ReaderScriptMode.tajik),
          ),
          ChoiceChip(
            label: Text(tr('lit_script_persian')),
            selected: mode == ReaderScriptMode.persian,
            onSelected: (_) => onSelected(ReaderScriptMode.persian),
          ),
          if (showParallel)
            ChoiceChip(
              avatar: const Icon(Icons.compare_arrows, size: 16),
              label: Text(tr('lit_script_parallel')),
              selected: mode == ReaderScriptMode.parallel,
              onSelected: (_) => onSelected(ReaderScriptMode.parallel),
            ),
        ],
      ),
    );
  }
}
