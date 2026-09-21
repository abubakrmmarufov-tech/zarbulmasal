import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/recent_activity_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../data/reader_preferences_provider.dart';
import '../domain/domain.dart';
import 'source_panel.dart';

/// A reader screen displaying a verified [LiteraryWork] with full provenance,
/// script-aware typography, collation badge, and bottom action bar.
class PoemReaderScreen extends ConsumerWidget {
  final String workId;

  const PoemReaderScreen({super.key, required this.workId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final worksAsync = ref.watch(approvedWorksProvider);
    final allWorksAsync = ref.watch(literaryWorksProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('back', lang),
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          AppTranslations.get('lit_reader_title', lang),
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 18,
          ),
        ),
      ),
      body: worksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: AppTranslations.get('lit_work_error_title', lang),
            subtitle: AppTranslations.get('lit_work_error_sub', lang),
            action: OutlinedButton(
              onPressed: () {
                ref.invalidate(literaryWorksProvider);
                ref.invalidate(approvedWorksProvider);
              },
              child: Text(AppTranslations.get('btn_retry', lang)),
            ),
          ),
        ),
        data: (works) {
          final work = works.cast<LiteraryWork?>().firstWhere(
            (w) => w?.id == workId,
            orElse: () => null,
          );

          if (work == null) {
            final pendingWork = allWorksAsync.valueOrNull
                ?.cast<LiteraryWork?>()
                .firstWhere(
                  (candidate) => candidate?.id == workId,
                  orElse: () => null,
                );
            if (pendingWork != null &&
                (pendingWork.verification.evidenceLevel ==
                        VerificationLevel.needsReview ||
                    pendingWork.verification.evidenceLevel ==
                        VerificationLevel.primaryChecked)) {
              return _PendingWorkState(work: pendingWork);
            }

            return Center(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: AppTranslations.get('lit_work_not_found_title', lang),
                subtitle: AppTranslations.get('lit_work_not_found_sub', lang),
                action: OutlinedButton(
                  onPressed: () => qalamBack(context),
                  child: Text(AppTranslations.get('back', lang)),
                ),
              ),
            );
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(recentActivityProvider.notifier)
                .addActivity(
                  RecentActivity(
                    id: work.id,
                    type: RecentActivityType.work,
                    title: isPersian && work.titlePersian != null
                        ? work.titlePersian!
                        : work.title,
                    subtitle: AppTranslations.get('lit_genre_poem', lang),
                    timestamp: DateTime.now(),
                    route: '/literature/work/${work.id}',
                  ),
                );
          });

          return _PoemReaderContent(work: work);
        },
      ),
    );
  }
}

/// Explains why a known textbook candidate cannot be read yet.
class _PendingWorkState extends ConsumerWidget {
  final LiteraryWork work;

  const _PendingWorkState({required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final citation = work.primarySource?.citation;
    final sourceNote = citation == null
        ? ''
        : '\n\n${AppTranslations.get('lit_work_source_registered', lang, [citation])}';
    final rightsNote = work.rights.status.name == 'unknown'
        ? '\n\n${AppTranslations.get('lit_work_rights_pending', lang)}'
        : '';

    return Center(
      child: EmptyState(
        icon: Icons.hourglass_empty,
        title: AppTranslations.get('lit_work_pending_title', lang),
        subtitle:
            '${AppTranslations.get('lit_work_pending_sub', lang)}$rightsNote$sourceNote',
        action: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (work.primarySource != null)
              OutlinedButton.icon(
                onPressed: () => SourcePanel.show(context, work),
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(AppTranslations.get('lit_source_and_docs', lang)),
              ),
            OutlinedButton(
              onPressed: () => qalamBack(context),
              child: Text(AppTranslations.get('back', lang)),
            ),
          ],
        ),
      ),
    );
  }
}

enum ReaderScriptMode { tajik, persian, parallel }

class _PoemReaderContent extends ConsumerStatefulWidget {
  final LiteraryWork work;

  const _PoemReaderContent({required this.work});

  @override
  ConsumerState<_PoemReaderContent> createState() => _PoemReaderContentState();
}

class _PoemReaderContentState extends ConsumerState<_PoemReaderContent> {
  ReaderScriptMode? _userScriptMode;

  @override
  Widget build(BuildContext context) {
    final work = widget.work;
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final authorAsync = ref.watch(authorByIdProvider(work.authorId));
    final author = authorAsync.valueOrNull;

    final isFavorited = ref.watch(literaryFavoritesProvider).contains(work.id);
    final readerPrefs = ref.watch(readerPreferencesProvider);

    final title =
        (isPersian &&
            work.titlePersian != null &&
            work.titlePersian!.isNotEmpty)
        ? work.titlePersian!
        : work.title;

    final authorName = author != null
        ? ((isPersian && author.canonicalNamePersian != null)
              ? author.canonicalNamePersian!
              : author.canonicalName)
        : work.authorId;

    final hasGeneratedPersian =
        work.persianScriptSource == 'generated' && work.hasPersianDisplay;
    final hasBothScripts = work.hasTajikText && work.hasPersianText;
    final defaultMode =
        (isPersian && (work.hasPersianText || hasGeneratedPersian))
        ? ReaderScriptMode.persian
        : (work.hasTajikText
              ? ReaderScriptMode.tajik
              : ReaderScriptMode.persian);
    final currentScriptMode = _userScriptMode ?? defaultMode;

    final hasVerifiedText =
        work.isDisplayable &&
        ((currentScriptMode == ReaderScriptMode.tajik && work.hasTajikText) ||
            (currentScriptMode == ReaderScriptMode.persian &&
                (work.hasPersianText || hasGeneratedPersian)) ||
            (currentScriptMode == ReaderScriptMode.parallel &&
                hasBothScripts) ||
            (work.hasTajikText || work.hasPersianText));

    final readerFontSize = (22.0 + readerPrefs.fontSizeDelta).clamp(14.0, 36.0);

    return Column(
      children: [
        // Reader scrollable content
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Genre & Verification row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _genreName(work.type, lang),
                              style: QalamTypography.meta(
                                color: colors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          QalamSourceBadge(
                            isVerified:
                                work.verification.evidenceLevel ==
                                VerificationLevel.editoriallyApproved,
                            label: AppTranslations.get('lit_verified', lang),
                          ),
                          if (work.isPageImageDisplayable)
                            InkWell(
                              onTap: () => SourcePanel.show(context, work),
                              borderRadius: BorderRadius.circular(4),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: QalamColors.forest.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: QalamColors.forest.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.photo_library_outlined,
                                      size: 13,
                                      color: QalamColors.forest,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppTranslations.get(
                                        'lit_page_image',
                                        lang,
                                      ),
                                      style: QalamTypography.meta(
                                        color: QalamColors.forest,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Title
                      Text(
                        title,
                        style: QalamTypography.pageTitle(
                          color: colors.onSurface,
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Author Link
                      InkWell(
                        onTap: () {
                          if (work.authorId.isNotEmpty) {
                            context.push('/literature/poet/${work.authorId}');
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              authorName,
                              style: QalamTypography.sectionTitle(
                                color: colors.primary,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Directionality.of(context) == TextDirection.rtl
                                  ? Icons.arrow_back_ios
                                  : Icons.arrow_forward_ios,
                              size: 13,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                      if (author != null &&
                          author.hasAuditableBiographySource &&
                          (author.lifespan.isNotEmpty ||
                              author.birthDateExact != null ||
                              author.deathDateExact != null)) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 13,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                (author.birthDateExact != null ||
                                        author.deathDateExact != null)
                                    ? AppTranslations.get(
                                        'lit_author_dates',
                                        lang,
                                        [
                                          author.birthDateExact ??
                                              author.birthYear ??
                                              "—",
                                          author.deathDateExact ??
                                              author.deathYear ??
                                              (isPersian
                                                  ? "در قید حیات"
                                                  : "дар ҳаёт"),
                                        ],
                                      )
                                    : AppTranslations.formatDigits(
                                        author.lifespan,
                                        lang,
                                      ),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (work.hasAuditableCompositionEvidence &&
                          ((work.compositionDate != null &&
                                  work.compositionDate!.isNotEmpty) ||
                              (work.compositionContext != null &&
                                  work.compositionContext!.isNotEmpty))) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (work.hasAuditableCompositionEvidence &&
                                work.compositionDate != null &&
                                work.compositionDate!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: colors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.history_edu,
                                      size: 15,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppTranslations.get(
                                        'lit_comp_date',
                                        lang,
                                        [
                                          AppTranslations.formatDigits(
                                            work.compositionDate!,
                                            lang,
                                          ),
                                        ],
                                      ),
                                      style: QalamTypography.meta(
                                        color: colors.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (work.hasAuditableCompositionEvidence &&
                                work.compositionContext != null &&
                                work.compositionContext!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest
                                      .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: colors.outlineVariant.withValues(
                                      alpha: 0.5,
                                    ),
                                    width: 0.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.place_outlined,
                                      size: 15,
                                      color: colors.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      AppTranslations.get(
                                        'lit_comp_context',
                                        lang,
                                        [work.compositionContext!],
                                      ),
                                      style: QalamTypography.meta(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 16),

                      // Script Switcher when both scripts exist
                      if (hasBothScripts) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: [
                                ChoiceChip(
                                  label: Text(
                                    AppTranslations.get(
                                      'lit_script_cyrillic',
                                      lang,
                                    ),
                                  ),
                                  selected:
                                      currentScriptMode ==
                                      ReaderScriptMode.tajik,
                                  onSelected: (_) => setState(
                                    () => _userScriptMode =
                                        ReaderScriptMode.tajik,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  label: Text(
                                    AppTranslations.get(
                                      'lit_script_persian',
                                      lang,
                                    ),
                                  ),
                                  selected:
                                      currentScriptMode ==
                                      ReaderScriptMode.persian,
                                  onSelected: (_) => setState(
                                    () => _userScriptMode =
                                        ReaderScriptMode.persian,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ChoiceChip(
                                  avatar: const Icon(
                                    Icons.compare_arrows,
                                    size: 16,
                                  ),
                                  label: Text(
                                    AppTranslations.get(
                                      'lit_script_parallel',
                                      lang,
                                    ),
                                  ),
                                  selected:
                                      currentScriptMode ==
                                      ReaderScriptMode.parallel,
                                  onSelected: (_) => setState(
                                    () => _userScriptMode =
                                        ReaderScriptMode.parallel,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (isPersian && hasGeneratedPersian) ...[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 15,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  AppTranslations.get(
                                    'lit_generated_script_notice',
                                    lang,
                                  ),
                                  style: QalamTypography.meta(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Text body or Review Placeholder
                      if (hasVerifiedText) ...[
                        if (currentScriptMode == ReaderScriptMode.parallel &&
                            hasBothScripts)
                          _buildParallelVerses(
                            context,
                            work.textTajik!,
                            work.textPersian!,
                            readerFontSize,
                            readerPrefs.lineHeightMultiplier,
                            colors,
                          )
                        else if (currentScriptMode ==
                                ReaderScriptMode.persian &&
                            (work.hasPersianText || hasGeneratedPersian))
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: SelectableText(
                              work.textPersian ??
                                  work.persianScriptRepresentation!,
                              textAlign: TextAlign.right,
                              style: QalamTypography.heroProverb(
                                color: colors.onSurface,
                                fontSize: readerFontSize,
                                height: readerPrefs.lineHeightMultiplier,
                              ),
                            ),
                          )
                        else
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: SelectableText(
                              work.textTajik ??
                                  work.textPersian ??
                                  work.persianScriptRepresentation ??
                                  '',
                              textAlign: TextAlign.left,
                              style: QalamTypography.heroProverb(
                                color: colors.onSurface,
                                fontSize: readerFontSize,
                                height: readerPrefs.lineHeightMultiplier,
                              ),
                            ),
                          ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                            border: Border.all(
                              color: colors.outlineVariant,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.hourglass_empty,
                                    size: 20,
                                    color: colors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      AppTranslations.get(
                                        'lit_editorial_review_pending',
                                        lang,
                                      ),
                                      style: QalamTypography.sectionTitle(
                                        color: colors.onSurface,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppTranslations.get(
                                  'lit_editorial_policy_notice',
                                  lang,
                                ),
                                style: QalamTypography.bodySecondary(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              if (work.incipit != null &&
                                  work.incipit!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  AppTranslations.get(
                                    'lit_incipit_label',
                                    lang,
                                  ),
                                  style: QalamTypography.meta(
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '«${work.incipit}»',
                                  style: QalamTypography.heroProverb(
                                    color: colors.onSurface,
                                    fontSize:
                                        (18.0 + readerPrefs.fontSizeDelta * 0.5)
                                            .clamp(14.0, 28.0),
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      if (work.editorialNotes != null &&
                          work.editorialNotes!.isNotEmpty) ...[
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: colors.outlineVariant,
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTranslations.get(
                                  'lit_editorial_notes_label',
                                  lang,
                                ),
                                style: QalamTypography.meta(
                                  color: colors.primary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                work.editorialNotes!,
                                style: QalamTypography.bodySecondary(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bottom action bar with font scaling controls
        Container(
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
                  // Bookmark button
                  IconButton(
                    tooltip: isFavorited
                        ? AppTranslations.get('bookmark_remove', lang)
                        : AppTranslations.get('bookmark_add', lang),
                    icon: Icon(
                      isFavorited ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorited
                          ? colors.primary
                          : colors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      ref
                          .read(literaryFavoritesProvider.notifier)
                          .toggle(work.id);
                    },
                  ),
                  // Copy button (only if rights permit full text)
                  if (work.rights.fullTextAllowed) ...[
                    IconButton(
                      tooltip: AppTranslations.get('lit_copy_poem', lang),
                      icon: const Icon(Icons.copy_outlined),
                      onPressed: () async {
                        final String activeText;
                        if (currentScriptMode == ReaderScriptMode.parallel &&
                            hasBothScripts) {
                          activeText =
                              '${work.textTajik}\n\n${work.textPersian}';
                        } else if (currentScriptMode ==
                                ReaderScriptMode.persian &&
                            (work.hasPersianText || hasGeneratedPersian)) {
                          activeText =
                              work.textPersian ??
                              work.persianScriptRepresentation!;
                        } else {
                          activeText =
                              work.textTajik ??
                              work.textPersian ??
                              work.persianScriptRepresentation ??
                              '';
                        }
                        final textToShare = hasVerifiedText
                            ? '$title\n$authorName\n\n$activeText'
                            : '$title\n$authorName';
                        try {
                          await Clipboard.setData(
                            ClipboardData(text: textToShare),
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppTranslations.get('lit_copied_toast', lang),
                                ),
                              ),
                            );
                          }
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppTranslations.get(
                                    'lit_copy_unavailable',
                                    lang,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ],
                  // Font Size Controls (A- / A+)
                  IconButton(
                    tooltip: AppTranslations.get(
                      'lit_work_decrease_font',
                      lang,
                    ),
                    icon: const Icon(Icons.text_decrease, size: 20),
                    onPressed: () => ref
                        .read(readerPreferencesProvider.notifier)
                        .decreaseFontSize(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      isPersian
                          ? '${AppTranslations.formatDigits('${(100 + readerPrefs.fontSizeDelta * 5).round()}', DisplayLanguage.persian)}٪'
                          : '${(100 + readerPrefs.fontSizeDelta * 5).round()}%',
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: AppTranslations.get(
                      'lit_work_increase_font',
                      lang,
                    ),
                    icon: const Icon(Icons.text_increase, size: 20),
                    onPressed: () => ref
                        .read(readerPreferencesProvider.notifier)
                        .increaseFontSize(),
                  ),
                  const SizedBox(width: 8),
                  // Source (Манбаъ) button
                  OutlinedButton.icon(
                    onPressed: () => SourcePanel.show(context, work),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: Text(
                      AppTranslations.get('lit_source_and_docs', lang),
                      style: QalamTypography.meta(
                        color: colors.onSurface,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParallelVerses(
    BuildContext context,
    String tajikText,
    String persianText,
    double fontSize,
    double lineHeight,
    ColorScheme colors,
  ) {
    final tjLines = tajikText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();
    final faLines = persianText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    final count = tjLines.length > faLines.length
        ? tjLines.length
        : faLines.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < count; i++) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(QalamSpacing.cardRadius),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (i < tjLines.length)
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: SelectableText(
                      tjLines[i],
                      style: QalamTypography.heroProverb(
                        color: colors.onSurface,
                        fontSize: fontSize,
                        height: lineHeight,
                      ),
                    ),
                  ),
                if (i < tjLines.length && i < faLines.length)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Divider(
                      height: 1,
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                if (i < faLines.length)
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: SelectableText(
                      faLines[i],
                      textAlign: TextAlign.right,
                      style: QalamTypography.heroProverb(
                        color: colors.primary,
                        fontSize: fontSize * 0.95,
                        height: lineHeight,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _genreName(WorkType type, DisplayLanguage lang) {
    switch (type) {
      case WorkType.ghazal:
        return AppTranslations.get('lit_genre_ghazal', lang);
      case WorkType.rubai:
        return AppTranslations.get('lit_genre_rubai', lang);
      case WorkType.qasida:
        return AppTranslations.get('lit_genre_qasida', lang);
      case WorkType.poem:
        return AppTranslations.get('lit_genre_poem', lang);
      case WorkType.fragment:
        return AppTranslations.get('lit_genre_qita', lang);
      case WorkType.folk:
        return AppTranslations.get('lit_genre_folk', lang);
      case WorkType.anthem:
        return AppTranslations.get('lit_genre_song', lang);
      case WorkType.epic:
        return AppTranslations.get('lit_genre_masnavi', lang);
      case WorkType.other:
        return AppTranslations.get('lit_genre_other', lang);
    }
  }
}
