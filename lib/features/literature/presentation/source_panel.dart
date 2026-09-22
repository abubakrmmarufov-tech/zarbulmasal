import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/literary_work.dart';
import '../domain/rights_record.dart';
import '../domain/source_edition.dart';
import '../domain/verification_record.dart';

/// A modal bottom sheet panel displaying full provenance metadata
/// for a [LiteraryWork], including primary/secondary printed witnesses,
/// philological collation checklist, and intellectual property rights clearance.
class SourcePanel extends ConsumerWidget {
  final LiteraryWork work;

  const SourcePanel({super.key, required this.work});

  /// Static helper to display [SourcePanel] inside a modal bottom sheet.
  static Future<void> show(BuildContext context, LiteraryWork work) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SourcePanel(work: work),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.verified_outlined,
                      size: 22,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppTranslations.get('lit_source_panel_title', lang),
                        style: QalamTypography.sectionTitle(
                          color: colors.onSurface,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: AppTranslations.get('btn_close', lang),
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  children: [
                    _buildPrimarySourceSection(context, lang),
                    const SizedBox(height: 24),
                    if (work.secondarySource != null) ...[
                      _buildSecondarySourceSection(context, lang),
                      const SizedBox(height: 24),
                    ],
                    if (work.sourceOccurrences.isNotEmpty) ...[
                      _buildSourceOccurrencesSection(context, lang),
                      const SizedBox(height: 24),
                    ],
                    _buildVerificationSection(context, lang),
                    const SizedBox(height: 24),
                    _buildRightsSection(context, lang),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrimarySourceSection(
    BuildContext context,
    DisplayLanguage lang,
  ) {
    final colors = Theme.of(context).colorScheme;
    final primary = work.primarySource;
    final primaryImagePath =
        primary?.sourceImagePath ??
        'assets/data/literature/page_images/${work.id}.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.menu_book,
          title: AppTranslations.get('lit_source_tier_a', lang),
        ),
        const SizedBox(height: 12),
        if (primary != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              border: Border.all(color: colors.outlineVariant, width: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary.bookTitle,
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 17,
                  ),
                ),
                if (primary.authorAsPrinted != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    '${AppTranslations.get('lit_source_author', lang)}:',
                    primary.authorAsPrinted!,
                    colors,
                  ),
                ],
                if (primary.editor != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    '${AppTranslations.get('lit_source_editor', lang)}:',
                    primary.editor!,
                    colors,
                  ),
                ],
                const SizedBox(height: 4),
                _buildMetaRow(
                  '${AppTranslations.get('lit_source_publisher', lang)}:',
                  '${primary.city}: ${primary.publisher}, ${primary.year}',
                  colors,
                ),
                if (primary.formattedPages != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    '${AppTranslations.get('lit_source_page', lang)}:',
                    primary.formattedPages!,
                    colors,
                  ),
                ],
                if (primary.volume != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    '${AppTranslations.get('lit_source_volume', lang)}:',
                    primary.volume!,
                    colors,
                  ),
                ],
                if (primary.isbn != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow('ISBN:', primary.isbn!, colors),
                ],
                if (primary.sourceInstitution != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    '${AppTranslations.get('lit_source_institution', lang)}:',
                    primary.sourceInstitution!,
                    colors,
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Text(
                  AppTranslations.get('lit_source_biblio_citation', lang),
                  style: QalamTypography.meta(color: colors.primary),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  primary.citation,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                if (work.isPageImageDisplayable &&
                    primary.sourceImageVerified) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    button: true,
                    excludeSemantics: true,
                    label:
                        '${AppTranslations.get('lit_source_page_image_title', lang)}. '
                        '${AppTranslations.get('lit_source_page_image_hint', lang)}',
                    onTap: () => _showPageImageDialog(context, lang),
                    child: InkWell(
                      onTap: () => _showPageImageDialog(context, lang),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: QalamColors.forest.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: QalamColors.forest.withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: SizedBox(
                                width: 48,
                                height: 64,
                                child: Image.asset(
                                  primaryImagePath,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, _) => Container(
                                    color: colors.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.menu_book,
                                      size: 24,
                                      color: QalamColors.forest,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.verified,
                                        size: 16,
                                        color: QalamColors.forest,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          AppTranslations.get(
                                            'lit_source_page_image_title',
                                            lang,
                                          ),
                                          style: QalamTypography.sectionTitle(
                                            color: QalamColors.forest,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppTranslations.get(
                                      'lit_source_page_image_hint',
                                      lang,
                                    ),
                                    style: QalamTypography.meta(
                                      color: colors.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.fullscreen,
                              size: 22,
                              color: QalamColors.forest,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ] else if (primary.sourceImageVerified &&
                    primary.sourceImagePaths.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: colors.outlineVariant,
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline, color: colors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTranslations.get(
                                  'lit_source_page_image_withheld_title',
                                  lang,
                                ),
                                style: QalamTypography.sectionTitle(
                                  color: colors.onSurface,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                AppTranslations.get(
                                  'lit_source_page_image_withheld_hint',
                                  lang,
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
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Text(
            AppTranslations.get('lit_source_not_registered', lang),
            style: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSecondarySourceSection(
    BuildContext context,
    DisplayLanguage lang,
  ) {
    final colors = Theme.of(context).colorScheme;
    final secondary = work.secondarySource;
    if (secondary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.auto_stories,
          title: AppTranslations.get('lit_source_sec_proof', lang),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            border: Border.all(color: colors.outlineVariant, width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                secondary.bookTitle,
                style: QalamTypography.sectionTitle(
                  color: colors.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              _buildMetaRow(
                '${AppTranslations.get('lit_source_publisher', lang)}:',
                '${secondary.city}: ${secondary.publisher}, ${secondary.year}',
                colors,
              ),
              if (secondary.formattedPages != null) ...[
                const SizedBox(height: 4),
                _buildMetaRow(
                  '${AppTranslations.get('lit_source_page', lang)}:',
                  secondary.formattedPages!,
                  colors,
                ),
              ],
              _buildCitationBlock(lang, secondary, colors),
              if (work.textMatchResult != null) ...[
                const SizedBox(height: 8),
                _buildMetaRow(
                  AppTranslations.get('lit_source_comparison_result', lang),
                  work.textMatchResult!,
                  colors,
                ),
              ],
              if (work.variantNotes != null) ...[
                const SizedBox(height: 8),
                Text(
                  AppTranslations.get('lit_source_variant_notes', lang),
                  style: QalamTypography.meta(color: colors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  work.variantNotes!,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSourceOccurrencesSection(
    BuildContext context,
    DisplayLanguage lang,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.library_books_outlined,
          title: AppTranslations.get('lit_source_occurrences_title', lang),
        ),
        const SizedBox(height: 12),
        for (final occurrence in work.sourceOccurrences) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
              border: Border.all(color: colors.outlineVariant, width: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  occurrence.bookTitle,
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                _buildMetaRow(
                  '${AppTranslations.get('lit_source_publisher', lang)}:',
                  '${occurrence.city}: ${occurrence.publisher}, ${occurrence.year}',
                  colors,
                ),
                if (occurrence.formattedPages != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    '${AppTranslations.get('lit_source_page', lang)}:',
                    occurrence.formattedPages!,
                    colors,
                  ),
                ],
                _buildCitationBlock(lang, occurrence, colors),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCitationBlock(
    DisplayLanguage lang,
    SourceEdition source,
    ColorScheme colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, color: colors.outlineVariant),
          const SizedBox(height: 10),
          Text(
            AppTranslations.get('lit_source_biblio_citation', lang),
            style: QalamTypography.meta(color: colors.primary),
          ),
          const SizedBox(height: 4),
          SelectableText(
            source.citation,
            key: ValueKey<String>('source-citation-${source.citation}'),
            style: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationSection(BuildContext context, DisplayLanguage lang) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ver = work.verification;

    final isApproved =
        ver.evidenceLevel == VerificationLevel.editoriallyApproved;
    final isRejected = ver.evidenceLevel == VerificationLevel.rejected;
    final statusColor = isApproved
        ? QalamColors.forest
        : (isRejected
              ? QalamColors.danger
              : (isDark ? QalamColors.antiqueGoldSoft : QalamColors.burgundy));

    final statusText = isApproved
        ? AppTranslations.get('lit_source_verified_label', lang)
        : (isRejected
              ? AppTranslations.get('lit_source_rejected_label', lang)
              : AppTranslations.get('lit_source_review_label', lang));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              context,
              icon: Icons.fact_check_outlined,
              title: AppTranslations.get('lit_source_textual_checks', lang),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
              child: Text(
                statusText,
                style: QalamTypography.meta(color: statusColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ver.evidenceHash != null || ver.verifiedAt != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${AppTranslations.get('lit_source_checker_label', lang)} ${ver.evidenceHash ?? '—'} (${ver.verifiedAt ?? '—'})',
              style: QalamTypography.meta(color: colors.onSurfaceVariant),
            ),
          ),
        ],
        _buildCheckItem(
          AppTranslations.get('lit_source_check_primary', lang),
          (ver.evidenceLevel.index >= VerificationLevel.primaryChecked.index),
          colors,
        ),
        _buildCheckItem(
          AppTranslations.get('lit_source_check_secondary', lang),
          ver.pageVerified,
          colors,
        ),
        _buildCheckItem(
          AppTranslations.get('lit_source_check_title', lang),
          (ver.evidenceLevel.index >= VerificationLevel.sourceLocated.index),
          colors,
        ),
        _buildCheckItem(
          AppTranslations.get('lit_source_check_author', lang),
          (ver.evidenceLevel.index >= VerificationLevel.sourceLocated.index),
          colors,
        ),
        _buildCheckItem(
          AppTranslations.get('lit_source_check_pages', lang),
          ver.pageVerified,
          colors,
        ),
        _buildCheckItem(
          AppTranslations.get('lit_source_check_lines', lang),
          (ver.evidenceLevel.index >= VerificationLevel.collated.index),
          colors,
        ),
        _buildCheckItem(
          AppTranslations.get('lit_source_check_orthography', lang),
          (ver.evidenceLevel.index >= VerificationLevel.collated.index),
          colors,
        ),
        _buildCheckItem(
          AppTranslations.get('lit_source_check_copyright', lang),
          (ver.evidenceLevel.index >=
              VerificationLevel.editoriallyApproved.index),
          colors,
        ),
        if (ver.rejectionReason != null && ver.rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: QalamColors.danger.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${AppTranslations.get('lit_source_rejection_reason', lang)} ${ver.rejectionReason}',
              style: QalamTypography.bodySecondary(
                color: QalamColors.danger,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRightsSection(BuildContext context, DisplayLanguage lang) {
    final colors = Theme.of(context).colorScheme;
    final rights = work.rights;

    final isPublic = rights.status == RightsStatus.publicDomain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.gavel_outlined,
          title: AppTranslations.get('lit_source_copyright_status', lang),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            border: Border.all(color: colors.outlineVariant, width: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isPublic ? Icons.public : Icons.copyright,
                    size: 18,
                    color: isPublic ? QalamColors.forest : colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isPublic
                          ? AppTranslations.get(
                              'lit_rights_public_domain',
                              lang,
                            )
                          : AppTranslations.get('lit_rights_protected', lang),
                      style: QalamTypography.label(
                        color: isPublic ? QalamColors.forest : colors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rights.reasoning,
                style: QalamTypography.bodySecondary(
                  color: colors.onSurface,
                  fontSize: 13,
                ),
              ),
              if (rights.rightsSource != null) ...[
                const SizedBox(height: 6),
                _buildMetaRow(
                  AppTranslations.get('lit_source_legal_basis', lang),
                  rights.rightsSource!,
                  colors,
                ),
              ],
              if (rights.permissionReference != null) ...[
                const SizedBox(height: 6),
                _buildMetaRow(
                  AppTranslations.get('lit_source_license_doc', lang),
                  rights.permissionReference!,
                  colors,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTag(
                    AppTranslations.get('lit_source_full_text', lang),
                    rights.fullTextAllowed,
                    colors,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    AppTranslations.get('lit_source_excerpt', lang),
                    rights.excerptAllowed,
                    colors,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.primary),
        const SizedBox(width: 8),
        Text(title, style: QalamTypography.eyebrow(color: colors.primary)),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: QalamTypography.meta(color: colors.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: QalamTypography.bodySecondary(
              color: colors.onSurface,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String label, bool passed, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 16,
            color: passed ? QalamColors.forest : colors.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: QalamTypography.bodySecondary(
                color: passed ? colors.onSurface : colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, bool allowed, ColorScheme colors) {
    final tagColor = allowed ? QalamColors.forest : colors.outline;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tagColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: tagColor.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Text(
        '$label: ${allowed ? "✓" : "—"}',
        style: QalamTypography.meta(color: tagColor, fontSize: 11),
      ),
    );
  }

  void _showPageImageDialog(BuildContext context, DisplayLanguage lang) {
    if (!work.isPageImageDisplayable) return;
    final primary = work.primarySource;
    final configuredPaths = primary?.sourceImagePaths ?? const <String>[];
    final imagePaths = configuredPaths.isNotEmpty
        ? configuredPaths
        : <String>[
            primary?.sourceImagePath ??
                'assets/data/literature/page_images/${work.id}.png',
          ];
    var currentPage = 0;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog.fullscreen(
          backgroundColor: Colors.black.withValues(alpha: 0.95),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                tooltip: AppTranslations.get('lit_source_page_close', lang),
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              title: Text(
                primary?.bookTitle != null
                    ? '${primary!.bookTitle} ${primary.formattedPages != null ? "(${primary.formattedPages})" : ""}'
                    : AppTranslations.get('lit_source_page_title', lang),
                style: QalamTypography.sectionTitle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            body: Stack(
              children: [
                PageView.builder(
                  itemCount: imagePaths.length,
                  onPageChanged: (index) => setState(() => currentPage = index),
                  itemBuilder: (context, index) => Center(
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Semantics(
                        image: true,
                        label:
                            '${AppTranslations.get('lit_source_page_title', lang)}. '
                            '${AppTranslations.get('lit_source_page_counter', lang, [index + 1, imagePaths.length])}',
                        child: Image.asset(
                          imagePaths[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Text(
                              AppTranslations.get(
                                'lit_source_image_unavailable',
                                lang,
                              ),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (imagePaths.length > 1)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 16,
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: Text(
                              AppTranslations.get(
                                'lit_source_page_counter',
                                lang,
                                [currentPage + 1, imagePaths.length],
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
