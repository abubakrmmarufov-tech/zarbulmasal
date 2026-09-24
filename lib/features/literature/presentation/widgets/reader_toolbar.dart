import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../core/l10n/app_translations.dart';
import '../../../../shared/providers/app_providers.dart';
import '../../data/literature_providers.dart';
import '../../data/reader_preferences_provider.dart';
import '../../domain/domain.dart';
import '../../../../shared/providers/bayoz_provider.dart';
import '../../../../shared/widgets/bayoz_dialogs.dart';

/// Sticky reader toolbar: save, collect, copy (only when rights allow full
/// text) and text size.
class ReaderToolbar extends ConsumerWidget {
  const ReaderToolbar({super.key, required this.work, required this.copyText});

  final LiteraryWork work;

  /// Exactly what the reader currently shows (title, poet, and text).
  final String copyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isFavorited = ref.watch(literaryFavoritesProvider).contains(work.id);
    String tr(String key) => AppTranslations.get(key, lang);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              IconButton(
                tooltip: tr(isFavorited ? 'bookmark_remove' : 'bookmark_add'),
                icon: Icon(
                  isFavorited ? Icons.bookmark : Icons.bookmark_border,
                  color: isFavorited ? colors.primary : colors.onSurfaceVariant,
                ),
                onPressed: () => ref
                    .read(literaryFavoritesProvider.notifier)
                    .toggle(work.id),
              ),
              IconButton(
                tooltip: tr('bayoz_add_to'),
                icon: const Icon(Icons.library_add_outlined),
                onPressed: () => BayozPickerSheet.show(
                  context,
                  BayozItem(BayozItemKind.work, work.id),
                ),
              ),
              if (work.rights.fullTextAllowed)
                IconButton(
                  tooltip: tr('lit_copy_poem'),
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () => _copy(context, lang),
                ),
              IconButton(
                tooltip: tr('lit_text_size'),
                icon: const Icon(Icons.text_fields),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  showDragHandle: true,
                  builder: (context) => const ReaderTextSizeSheet(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _copy(BuildContext context, DisplayLanguage lang) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await Clipboard.setData(ClipboardData(text: copyText));
      messenger.showSnackBar(
        SnackBar(content: Text(AppTranslations.get('lit_copied_toast', lang))),
      );
    } on PlatformException {
      messenger.showSnackBar(
        SnackBar(
          content: Text(AppTranslations.get('lit_copy_unavailable', lang)),
        ),
      );
    }
  }
}

/// «Aa»: reading text size, kept out of the toolbar so it stays one row.
class ReaderTextSizeSheet extends ConsumerWidget {
  const ReaderTextSizeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final prefs = ref.watch(readerPreferencesProvider);
    final notifier = ref.read(readerPreferencesProvider.notifier);
    final percent = (100 + prefs.fontSizeDelta * 5).round();
    String tr(String key) => AppTranslations.get(key, lang);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: tr('lit_work_decrease_font'),
              icon: const Icon(Icons.text_decrease),
              onPressed: notifier.decreaseFontSize,
            ),
            SizedBox(
              width: 72,
              child: Text(
                lang == DisplayLanguage.persian
                    ? '${AppTranslations.formatDigits('$percent', lang)}٪'
                    : '$percent%',
                textAlign: TextAlign.center,
                style: QalamTypography.label(
                  color: colors.onSurface,
                  fontSize: 16,
                ),
              ),
            ),
            IconButton(
              tooltip: tr('lit_work_increase_font'),
              icon: const Icon(Icons.text_increase),
              onPressed: notifier.increaseFontSize,
            ),
          ],
        ),
      ),
    );
  }
}
