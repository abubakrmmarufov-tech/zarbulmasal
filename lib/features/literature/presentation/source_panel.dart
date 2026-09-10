import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../shared/providers/app_providers.dart';
import '../domain/literary_work.dart';
import '../domain/rights_record.dart';
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
    final isPersian = lang == DisplayLanguage.persian;

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
                color: Colors.black.withOpacity(0.12),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                        isPersian ? 'منبع و بررسی اصالت' : 'Сарчашма ва санҷиш',
                        style: QalamTypography.sectionTitle(
                          color: colors.onSurface,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    IconButton(
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
                    _buildPrimarySourceSection(context, isPersian),
                    const SizedBox(height: 24),
                    if (work.secondarySource != null) ...[
                      _buildSecondarySourceSection(context, isPersian),
                      const SizedBox(height: 24),
                    ],
                    _buildVerificationSection(context, isPersian),
                    const SizedBox(height: 24),
                    _buildRightsSection(context, isPersian),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrimarySourceSection(BuildContext context, bool isPersian) {
    final colors = Theme.of(context).colorScheme;
    final primary = work.primarySource;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.menu_book,
          title: isPersian ? 'منبع اصلی (Tier A)' : 'Сарчашмаи асосӣ (Tier A)',
        ),
        const SizedBox(height: 12),
        if (primary != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest.withOpacity(0.5),
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
                    isPersian ? 'مؤلف:' : 'Муаллиф:',
                    primary.authorAsPrinted!,
                    colors,
                  ),
                ],
                if (primary.editor != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    isPersian ? 'محرر:' : 'Муҳаррир:',
                    primary.editor!,
                    colors,
                  ),
                ],
                const SizedBox(height: 4),
                _buildMetaRow(
                  isPersian ? 'نشریات:' : 'Нашриёт:',
                  '${primary.city}: ${primary.publisher}, ${primary.year}',
                  colors,
                ),
                if (primary.formattedPages != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    isPersian ? 'صفحه:' : 'Саҳифа:',
                    primary.formattedPages!,
                    colors,
                  ),
                ],
                if (primary.volume != null) ...[
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    isPersian ? 'جلد:' : 'Ҷилд:',
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
                    isPersian ? 'مؤسسه:' : 'Муассиса:',
                    primary.sourceInstitution!,
                    colors,
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 10),
                Text(
                  isPersian ? 'ارجاع کتاب‌شناختی:' : 'Иқтибоси библиографӣ:',
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
                if (primary.sourceImageVerified) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.check_circle, size: 14, color: QalamColors.forest),
                      const SizedBox(width: 6),
                      Text(
                        isPersian
                            ? 'اسکن نسخه خطی/چاپی بررسی شده است'
                            : 'Нусхаи асл дида баромада шуд',
                        style: QalamTypography.meta(color: QalamColors.forest),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ] else ...[
          Text(
            isPersian
                ? 'منبع چاپی هنوز ثبت نشده است.'
                : 'Сарчашмаи чопӣ ҳанӯз ба қайд гирифта нашудааст.',
            style: QalamTypography.bodySecondary(color: colors.onSurfaceVariant),
          ),
        ],
      ],
    );
  }

  Widget _buildSecondarySourceSection(BuildContext context, bool isPersian) {
    final colors = Theme.of(context).colorScheme;
    final secondary = work.secondarySource;
    if (secondary == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.auto_stories,
          title: isPersian ? 'منبع دوم (مقابله)' : 'Сарчашмаи дуввум (Муқобала)',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withOpacity(0.5),
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
                isPersian ? 'نشریات:' : 'Нашриёт:',
                '${secondary.city}: ${secondary.publisher}, ${secondary.year}',
                colors,
              ),
              if (secondary.formattedPages != null) ...[
                const SizedBox(height: 4),
                _buildMetaRow(
                  isPersian ? 'صفحه:' : 'Саҳифа:',
                  secondary.formattedPages!,
                  colors,
                ),
              ],
              if (work.textMatchResult != null) ...[
                const SizedBox(height: 8),
                _buildMetaRow(
                  isPersian ? 'نتیجه مقابله:' : 'Натиҷаи муқобала:',
                  work.textMatchResult!,
                  colors,
                ),
              ],
              if (work.variantNotes != null) ...[
                const SizedBox(height: 8),
                Text(
                  isPersian ? 'یادداشت‌های نسخه‌بدل:' : 'Тафовути нусхаҳо:',
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

  Widget _buildVerificationSection(BuildContext context, bool isPersian) {
    final colors = Theme.of(context).colorScheme;
    final ver = work.verification;

    final isApproved = ver.finalStatus == VerificationStatus.approved;
    final isRejected = ver.finalStatus == VerificationStatus.rejected;
    final statusColor = isApproved
        ? QalamColors.forest
        : (isRejected ? QalamColors.danger : QalamColors.burgundySoft);

    final statusText = isApproved
        ? (isPersian ? 'تأیید شده' : 'Тасдиқшуда')
        : (isRejected
            ? (isPersian ? 'رد شده' : 'Радшуда')
            : (isPersian ? 'در حال بررسی' : 'Дар баррасӣ'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader(
              context,
              icon: Icons.fact_check_outlined,
              title: isPersian ? 'بررسی‌های متن‌شناسی' : 'Санҷишҳои матншиносӣ',
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: statusColor.withOpacity(0.4), width: 0.5),
              ),
              child: Text(
                statusText,
                style: QalamTypography.meta(color: statusColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (ver.verifiedBy != null || ver.verifiedDate != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '${isPersian ? 'مصحح/محرر:' : 'Муҳаққиқ/муҳаррир:'} ${ver.verifiedBy ?? '—'} (${ver.verifiedDate ?? '—'})',
              style: QalamTypography.meta(color: colors.onSurfaceVariant),
            ),
          ),
        ],
        _buildCheckItem(
          isPersian ? 'منبع اصلی چاپی بررسی شد' : 'Сарчашмаи асосии чопӣ санҷида шуд',
          ver.primarySourceChecked,
          colors,
        ),
        _buildCheckItem(
          isPersian ? 'منبع دوم مقابله شد' : 'Сарчашмаи дуввум муқобала шуд',
          ver.secondSourceChecked,
          colors,
        ),
        _buildCheckItem(
          isPersian ? 'عنوان در نسخهٔ اصل تأیید شد' : 'Номи асар дар нашри аслӣ тасдиқ шуд',
          ver.titleChecked,
          colors,
        ),
        _buildCheckItem(
          isPersian ? 'انتساب به مؤلف محرز شد' : 'Муаллифи асар муайян ва тасдиқ шуд',
          ver.authorshipChecked,
          colors,
        ),
        _buildCheckItem(
          isPersian ? 'صفحات کتاب چاپی مستند شد' : 'Саҳифаҳои нашри чопӣ дақиқ шуд',
          ver.pageChecked,
          colors,
        ),
        _buildCheckItem(
          isPersian ? 'متن بیت‌به‌بیت مقابله شد' : 'Матн мисраъ ба мисраъ муқобала шуд',
          ver.textLineByLineChecked,
          colors,
        ),
        _buildCheckItem(
          isPersian ? 'رسم‌الخط و اعراب بررسی شد' : 'Имло, аломатҳо ва хат тасдиқ шуд',
          ver.scriptChecked,
          colors,
        ),
        _buildCheckItem(
          isPersian ? 'حقوق مؤلف مطابق قانون بررسی شد' : 'Ҳуқуқи муаллиф тибқи қонунгузорӣ тасдиқ шуд',
          ver.copyrightChecked,
          colors,
        ),
        if (ver.rejectionReason != null && ver.rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: QalamColors.danger.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${isPersian ? 'علت رد:' : 'Сабаби рад:'} ${ver.rejectionReason}',
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

  Widget _buildRightsSection(BuildContext context, bool isPersian) {
    final colors = Theme.of(context).colorScheme;
    final rights = work.rights;

    final isPublic = rights.status == RightsStatus.publicDomain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          icon: Icons.gavel_outlined,
          title: isPersian ? 'وضعیت حقوقی و کپی‌رایت' : 'Ҳуқуқи муаллиф ва мақом',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withOpacity(0.5),
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
                          ? (isPersian ? 'مالکیت عمومی (Public Domain)' : 'Моликияти умумӣ (Public Domain)')
                          : (isPersian ? 'دارای کپی‌رایت / تحت حفاظت' : 'Ҳифзшуда / Таҳти ҳимоя'),
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
                  isPersian ? 'مرجع قانونی:' : 'Асоси қонунӣ:',
                  rights.rightsSource!,
                  colors,
                ),
              ],
              if (rights.permissionReference != null) ...[
                const SizedBox(height: 6),
                _buildMetaRow(
                  isPersian ? 'سند مجوز:' : 'Ҳуҷҷати иҷозат:',
                  rights.permissionReference!,
                  colors,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildTag(
                    isPersian ? 'متن کامل' : 'Матни пурра',
                    rights.fullTextAllowed,
                    colors,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    isPersian ? 'اقتباس' : 'Иқтибос',
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

  Widget _buildSectionHeader(BuildContext context, {required IconData icon, required String title}) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: QalamTypography.eyebrow(color: colors.primary),
        ),
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
        color: tagColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: tagColor.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        '$label: ${allowed ? "✓" : "—"}',
        style: QalamTypography.meta(color: tagColor, fontSize: 11),
      ),
    );
  }
}
