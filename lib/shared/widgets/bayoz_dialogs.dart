import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../providers/app_providers.dart';
import '../providers/bayoz_provider.dart';

/// Asks for a Баёз name; returns the trimmed name or `null` if cancelled.
Future<String?> askBayozName(
  BuildContext context,
  DisplayLanguage lang, {
  String initial = '',
  String? actionLabel,
}) async {
  final name = await showDialog<String>(
    context: context,
    builder: (context) => _BayozNameDialog(
      lang: lang,
      initial: initial,
      actionLabel: actionLabel,
    ),
  );
  return name == null || name.isEmpty ? null : name;
}

/// Owns its text controller so it is disposed only after the dialog's exit
/// animation has finished.
class _BayozNameDialog extends StatefulWidget {
  const _BayozNameDialog({
    required this.lang,
    required this.initial,
    this.actionLabel,
  });

  final DisplayLanguage lang;
  final String initial;
  final String? actionLabel;

  @override
  State<_BayozNameDialog> createState() => _BayozNameDialogState();
}

class _BayozNameDialogState extends State<_BayozNameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String tr(String key) => AppTranslations.get(key, widget.lang);
    return AlertDialog(
      title: Text(tr(widget.initial.isEmpty ? 'bayoz_new' : 'bayoz_rename')),
      content: TextField(
        controller: _controller,
        autofocus: true,
        inputFormatters: [
          LengthLimitingTextInputFormatter(Bayoz.maxTitleLength),
        ],
        decoration: InputDecoration(hintText: tr('bayoz_name_hint')),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('dialog_cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(widget.actionLabel ?? tr('bayoz_create')),
        ),
      ],
    );
  }
}

/// A sheet listing every Баёз with a check for whether [item] is in it.
class BayozPickerSheet extends ConsumerWidget {
  const BayozPickerSheet({super.key, required this.item});

  final BayozItem item;

  static Future<void> show(BuildContext context, BayozItem item) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => BayozPickerSheet(item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final collections = ref.watch(bayozProvider);
    final colors = Theme.of(context).colorScheme;
    String tr(String key) => AppTranslations.get(key, lang);

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          Text(
            tr('bayoz_add_to'),
            style: QalamTypography.sectionTitle(
              color: colors.onSurface,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 8),
          for (final bayoz in collections)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: bayoz.contains(item),
              title: Text(bayoz.title),
              subtitle: Text(
                AppTranslations.get(
                  _isFull(bayoz, item) ? 'bayoz_full' : 'bayoz_count',
                  lang,
                  [AppTranslations.formatNumber(bayoz.items.length, lang)],
                ),
              ),
              onChanged: _isFull(bayoz, item)
                  ? null
                  : (_) =>
                        ref.read(bayozProvider.notifier).toggle(bayoz.id, item),
            ),
          if (collections.length < BayozNotifier.maxCollections)
            TextButton.icon(
              onPressed: () async {
                final name = await askBayozName(context, lang);
                if (name == null) return;
                final notifier = ref.read(bayozProvider.notifier);
                final id = await notifier.create(name);
                if (id != null) await notifier.toggle(id, item);
              },
              icon: const Icon(Icons.add),
              label: Text(tr('bayoz_new')),
            ),
        ],
      ),
    );
  }

  /// A Баёз at [BayozNotifier.maxItems] takes no more; what it holds can
  /// still be taken out.
  static bool _isFull(Bayoz bayoz, BayozItem item) =>
      !bayoz.contains(item) && bayoz.items.length >= BayozNotifier.maxItems;
}
