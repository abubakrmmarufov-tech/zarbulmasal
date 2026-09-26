import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/bayoz_provider.dart';
import '../../shared/providers/reading_script_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../data/models/proverb.dart';
import '../literature/data/literature_providers.dart';
import '../literature/domain/literary_work.dart';
import '../literature/presentation/literary_work_display_text.dart';
import '../../shared/widgets/bayoz_dialogs.dart';

/// One «Баёз»: its texts in the order they were collected.
class BayozDetailScreen extends ConsumerWidget {
  const BayozDetailScreen({super.key, required this.bayozId});

  final String bayozId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final colors = Theme.of(context).colorScheme;
    String tr(String key) => AppTranslations.get(key, lang);
    final bayoz = ref
        .watch(bayozProvider)
        .where((candidate) => candidate.id == bayozId)
        .firstOrNull;

    if (bayoz == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: EmptyState(
            icon: Icons.menu_book_outlined,
            title: tr('saved_title'),
            action: OutlinedButton(
              onPressed: () => qalamBack(context),
              child: Text(tr('back')),
            ),
          ),
        ),
      );
    }

    final worksAsync = ref.watch(approvedWorksProvider);
    final catalogLoaded = worksAsync.hasValue;
    final works = <String, LiteraryWork>{
      for (final work in worksAsync.valueOrNull ?? const []) work.id: work,
    };
    final proverbs = <String, Proverb>{
      for (final proverb in ref.watch(proverbsProvider)) proverb.id: proverb,
    };
    final persian = ref.watch(readingScriptProvider) == ReadingScript.persian;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: tr('back'),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        actions: [
          IconButton(
            tooltip: tr('bayoz_rename'),
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final name = await askBayozName(
                context,
                lang,
                initial: bayoz.title,
                actionLabel: tr('bayoz_rename'),
              );
              if (name != null) {
                await ref.read(bayozProvider.notifier).rename(bayoz.id, name);
              }
            },
          ),
          IconButton(
            tooltip: tr('bayoz_delete'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, bayoz, lang),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
        children: [
          Text(
            tr('saved_title').toUpperCase(),
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            bayoz.title,
            style: QalamTypography.monographTitle(
              color: colors.onSurface,
              fontSize: 34,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppTranslations.get('bayoz_count', lang, [
              AppTranslations.formatNumber(bayoz.items.length, lang),
            ]),
            style: QalamTypography.meta(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          if (bayoz.items.isEmpty)
            Text(
              tr('bayoz_empty'),
              style: QalamTypography.bodySecondary(
                color: colors.onSurfaceVariant,
              ),
            ),
          for (final item in bayoz.items)
            if (_resolve(item, works, proverbs, persian) case (
              final title,
              final route,
            ))
              _ItemRow(
                title: title,
                subtitle: item.kind == BayozItemKind.work
                    ? tr('lit_genre_poem')
                    : (lang == DisplayLanguage.persian
                          ? 'ضرب‌المثل'
                          : 'Зарбулмасал'),
                onTap: () => context.push(route),
                onRemove: () =>
                    ref.read(bayozProvider.notifier).toggle(bayoz.id, item),
                removeLabel: tr('bayoz_remove_item'),
              )
            else if (catalogLoaded)
              // The text is no longer published: say so, and let the reader
              // remove the reference.
              _ItemRow(
                title: tr('bayoz_item_unavailable'),
                onRemove: () =>
                    ref.read(bayozProvider.notifier).toggle(bayoz.id, item),
                removeLabel: tr('bayoz_remove_item'),
              ),
        ],
      ),
    );
  }

  /// Title and route — or `null` when the text is no longer published.
  static (String, String)? _resolve(
    BayozItem item,
    Map<String, LiteraryWork> works,
    Map<String, Proverb> proverbs,
    bool persian,
  ) {
    switch (item.kind) {
      case BayozItemKind.work:
        final work = works[item.id];
        if (work == null) return null;
        return (
          persian
              ? LiteraryWorkDisplayText.title(work, DisplayLanguage.persian)
              : work.title,
          '/literature/work/${item.id}',
        );
      case BayozItemKind.proverb:
        final proverb = proverbs[item.id];
        if (proverb == null) return null;
        final text = persian && proverb.persianText.isNotEmpty
            ? proverb.persianText
            : proverb.tajikCyrillic;
        return (text, '/proverb/${item.id}');
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Bayoz bayoz,
    DisplayLanguage lang,
  ) async {
    String tr(String key) => AppTranslations.get(key, lang);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tr('bayoz_delete')),
        content: Text(tr('bayoz_delete_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(tr('dialog_cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(tr('dialog_yes')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(bayozProvider.notifier).delete(bayoz.id);
    if (context.mounted) qalamBack(context);
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.title,
    required this.onRemove,
    required this.removeLabel,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final VoidCallback onRemove;
  final String removeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: QalamIndexRow(
            title: title,
            subtitle: subtitle,
            onTap: onTap ?? () {},
          ),
        ),
        IconButton(
          tooltip: removeLabel,
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: onRemove,
        ),
      ],
    );
  }
}
