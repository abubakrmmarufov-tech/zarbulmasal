import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/vocabulary_providers.dart';
import '../domain/vocabulary_entry.dart';

class VocabularyDetailScreen extends ConsumerWidget {
  final String entryId;

  const VocabularyDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final async = ref.watch(vocabularyEntryProvider(entryId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          AppTranslations.get('vocab_title', lang),
          style: QalamTypography.sectionTitle(color: colors.onSurface),
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: AppTranslations.get('vocab_load_error', lang),
            subtitle: AppTranslations.get('vocab_load_error_sub', lang),
            action: OutlinedButton(
              onPressed: () => ref.invalidate(vocabularyEntryProvider(entryId)),
              child: Text(AppTranslations.get('btn_retry', lang)),
            ),
          ),
        ),
        data: (entry) {
          if (entry == null) {
            return Center(
              child: EmptyState(
                icon: Icons.search_off,
                title: AppTranslations.get('vocab_missing', lang),
                subtitle: AppTranslations.get('vocab_missing_sub', lang),
                action: OutlinedButton(
                  onPressed: () => context.go('/vocabulary'),
                  child: Text(AppTranslations.get('vocab_back_to_list', lang)),
                ),
              ),
            );
          }
          return _VocabularyDetailBody(entry: entry, lang: lang);
        },
      ),
    );
  }
}

class _VocabularyDetailBody extends StatelessWidget {
  final VocabularyEntry entry;
  final DisplayLanguage lang;

  const _VocabularyDetailBody({required this.entry, required this.lang});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPersian = lang == DisplayLanguage.persian;

    final term = isPersian && entry.hasPersianTerm
        ? entry.termPersian!
        : entry.term;
    final originalTerm = isPersian ? entry.term : entry.termPersian;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
      children: [
        if (isPersian && !entry.hasPersianTerm && originalTerm != null) ...[
          Text(
            originalTerm,
            style: QalamTypography.meta(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          term,
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 26,
          ),
        ),
        const SizedBox(height: 16),
        for (var index = 0; index < entry.distinctMeanings.length; index++) ...[
          _MeaningBlock(
            meaning: entry.distinctMeanings[index],
            lang: lang,
            showSourceKindLabel: entry.distinctMeanings.length > 1,
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        Text(
          AppTranslations.get('vocab_sources', lang),
          style: QalamTypography.sectionTitle(color: colors.onSurface),
        ),
        const SizedBox(height: 8),
        for (final source in entry.sources)
          _SourceTile(source: source, lang: lang),
        if (entry.sources.isEmpty)
          Text(
            AppTranslations.get('vocab_sources_empty', lang),
            style: QalamTypography.meta(color: colors.onSurfaceVariant),
          ),
      ],
    );
  }
}

class _MeaningBlock extends StatelessWidget {
  final VocabularyMeaning meaning;
  final DisplayLanguage lang;
  final bool showSourceKindLabel;

  const _MeaningBlock({
    required this.meaning,
    required this.lang,
    required this.showSourceKindLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPersian = lang == DisplayLanguage.persian;
    final primaryText = isPersian && meaning.hasPersianText
        ? meaning.persianText!
        : meaning.text;
    final showTajikTag = isPersian && !meaning.hasPersianText;
    final showSecondary =
        isPersian &&
        meaning.hasPersianText &&
        meaning.text.trim().isNotEmpty &&
        meaning.text.trim() != primaryText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSourceKindLabel || showTajikTag) ...[
            Row(
              children: [
                if (showSourceKindLabel) ...[
                  _MeaningPill(
                    label: _kindLabel(meaning.kind, lang),
                    color: colors.primary,
                    background: colors.primary.withValues(alpha: 0.1),
                  ),
                  const SizedBox(width: 6),
                ],
                if (showTajikTag)
                  _MeaningPill(
                    label: AppTranslations.get('vocab_tajik_meaning', lang),
                    color: colors.onSurfaceVariant,
                    background: colors.surfaceContainerHighest,
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Text(
            primaryText,
            style: QalamTypography.body(color: colors.onSurface),
          ),
          if (showSecondary) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                meaning.text,
                style: QalamTypography.bodySecondary(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _kindLabel(VocabularyKind kind, DisplayLanguage lang) {
    return switch (kind) {
      VocabularyKind.proverb => AppTranslations.get('vocab_kind_proverb', lang),
      VocabularyKind.history => AppTranslations.get('vocab_kind_history', lang),
      VocabularyKind.literaryAuthor => AppTranslations.get(
        'vocab_kind_author',
        lang,
      ),
    };
  }
}

class _MeaningPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;

  const _MeaningPill({
    required this.label,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: QalamTypography.meta(color: color, fontSize: 11),
      ),
    );
  }
}

class _SourceTile extends StatelessWidget {
  final VocabularySource source;
  final DisplayLanguage lang;

  const _SourceTile({required this.source, required this.lang});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final contextText = lang == DisplayLanguage.persian
        ? (source.contextPersian?.trim().isNotEmpty == true
              ? source.contextPersian!
              : source.contextTj)
        : source.contextTj;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: ListTile(
        leading: Icon(_sourceIcon(source.kind), color: colors.primary),
        title: Text(
          _sourceTitle(source, lang),
          style: QalamTypography.body(color: colors.onSurface),
        ),
        subtitle: contextText.trim().isEmpty
            ? null
            : Text(
                contextText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
        trailing: const QalamChevron(size: 20),
        onTap: () => context.push(source.route),
      ),
    );
  }

  String _sourceTitle(VocabularySource source, DisplayLanguage lang) {
    return switch (source.kind) {
      VocabularyKind.proverb => AppTranslations.get('vocab_kind_proverb', lang),
      VocabularyKind.history => AppTranslations.get('vocab_kind_history', lang),
      VocabularyKind.literaryAuthor => AppTranslations.get(
        'vocab_kind_author',
        lang,
      ),
    };
  }

  IconData _sourceIcon(VocabularyKind kind) {
    return switch (kind) {
      VocabularyKind.proverb => Icons.format_quote,
      VocabularyKind.history => Icons.timeline,
      VocabularyKind.literaryAuthor => Icons.person_outline,
    };
  }
}
