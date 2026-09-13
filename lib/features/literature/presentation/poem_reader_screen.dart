import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          isPersian ? 'خوانش شعر' : 'Хониши шеър',
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 18,
          ),
        ),
      ),
      body: worksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: isPersian
                ? 'خطا در بارگیری اثر'
                : 'Хато ҳангоми боргирии асар',
            subtitle: err.toString(),
            action: OutlinedButton(
              onPressed: () => qalamBack(context),
              child: Text(isPersian ? 'بازگشت' : 'Бозгашт'),
            ),
          ),
        ),
        data: (works) {
          final work = works.cast<LiteraryWork?>().firstWhere(
            (w) => w?.id == workId,
            orElse: () => null,
          );

          if (work == null) {
            return Center(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: isPersian ? 'اثر یافت نشد' : 'Асар ёфт нашуд',
                subtitle: isPersian
                    ? 'اثر با شناسهٔ مورد نظر در دسترس نیست.'
                    : 'Асаре бо ин нишонӣ ёфт нашуд.',
                action: OutlinedButton(
                  onPressed: () => qalamBack(context),
                  child: Text(isPersian ? 'بازگشت' : 'Бозгашт'),
                ),
              ),
            );
          }

          return _PoemReaderContent(work: work);
        },
      ),
    );
  }
}

class _PoemReaderContent extends ConsumerWidget {
  final LiteraryWork work;

  const _PoemReaderContent({required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final authorAsync = ref.watch(authorByIdProvider(work.authorId));
    final author = authorAsync.valueOrNull;

    final isFavorited = ref.watch(literaryFavoritesProvider).contains(work.id);

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

    final displayText = (isPersian && work.hasPersianText)
        ? work.textPersian!
        : (work.hasTajikText ? work.textTajik! : (work.textPersian ?? ''));

    final isRtl =
        isPersian ||
        (work.scriptSource == ScriptSource.persianArabic && !work.hasTajikText);
    final hasVerifiedText = work.isDisplayable && displayText.trim().isNotEmpty;

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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              _genreName(work.type, isPersian),
                              style: QalamTypography.meta(
                                color: colors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          QalamSourceBadge(
                            isVerified:
                                work.verification.finalStatus ==
                                VerificationStatus.approved,
                            label: isPersian
                                ? 'متن تأیید شده است'
                                : 'Матн санҷида шудааст',
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
                              Icons.arrow_forward_ios,
                              size: 13,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 28),
                      // Text body or Review Placeholder
                      if (hasVerifiedText) ...[
                        SelectableText(
                          displayText,
                          textDirection: isRtl
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign: isRtl ? TextAlign.right : TextAlign.left,
                          style: QalamTypography.heroProverb(
                            color: colors.onSurface,
                            fontSize: 22,
                            height: 1.85,
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
                                      isPersian
                                          ? 'متن در حال مقابله با نسخ چاپی است'
                                          : 'Матн дар ҳоли муқобала бо нусхаҳои чопӣ аст',
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
                                isPersian
                                    ? 'طبق خط‌مشی ویرایشی زرین‌مثل، متن اشعار تنها پس از تأیید حداقل دو نسخهٔ معتبر چاپی منتشر می‌شود تا از صحت و امانت‌داری ادبی اطمینان حاصل گردد.'
                                    : 'Мутобиқи сиёсати нашрии «Зарбулмасал», матни шеърҳо танҳо пас аз муқобала бо на камтар аз ду сарчашмаи чопии муътамад ва имзои муҳаррир нашр карда мешавад.',
                                style: QalamTypography.bodySecondary(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 14,
                                ),
                              ),
                              if (work.incipit != null &&
                                  work.incipit!.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Text(
                                  isPersian ? 'مطلع اثر:' : 'Матлаи асар:',
                                  style: QalamTypography.meta(
                                    color: colors.primary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '«${work.incipit}»',
                                  style: QalamTypography.heroProverb(
                                    color: colors.onSurface,
                                    fontSize: 18,
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
                                isPersian
                                    ? 'یادداشت‌های تصحیح و رسم‌الخط:'
                                    : 'Шарҳҳои матншиносӣ ва имло:',
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
        // Bottom action bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(color: colors.outlineVariant, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Bookmark button
                IconButton(
                  tooltip: isFavorited
                      ? (isPersian
                            ? 'حذف از نشان‌شده‌ها'
                            : 'Аз маҳфуз баровардан')
                      : (isPersian ? 'نشان کردن' : 'Маҳфуз кардан'),
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
                    tooltip: isPersian ? 'کپی متن' : 'Нусхаи матн',
                    icon: const Icon(Icons.copy_outlined),
                    onPressed: () async {
                      final textToShare = hasVerifiedText
                          ? '$title\n$authorName\n\n$displayText'
                          : '$title\n$authorName';
                      try {
                        await Clipboard.setData(
                          ClipboardData(text: textToShare),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isPersian
                                    ? 'متن در حافظه کپی شد'
                                    : 'Матн нусхабардорӣ шуд',
                              ),
                            ),
                          );
                        }
                      } catch (_) {}
                    },
                  ),
                ],
                const Spacer(),
                // Source (Манбаъ) button
                OutlinedButton.icon(
                  onPressed: () => SourcePanel.show(context, work),
                  icon: const Icon(Icons.menu_book_outlined, size: 18),
                  label: Text(
                    isPersian ? 'منبع و اسناد' : 'Манбаъ',
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
      ],
    );
  }

  String _genreName(WorkType type, bool isPersian) {
    switch (type) {
      case WorkType.ghazal:
        return isPersian ? 'غزل' : 'Ғазал';
      case WorkType.rubai:
        return isPersian ? 'رباعی' : 'Рубоӣ';
      case WorkType.qasida:
        return isPersian ? 'قصیده' : 'Қасида';
      case WorkType.poem:
        return isPersian ? 'شعر' : 'Шеър';
      case WorkType.fragment:
        return isPersian ? 'قطعه' : 'Қитъа';
      case WorkType.folk:
        return isPersian ? 'خلقی' : 'Халқӣ';
      case WorkType.anthem:
        return isPersian ? 'سرود' : 'Суруд';
      case WorkType.epic:
        return isPersian ? 'منظومه' : 'Достон';
      case WorkType.other:
        return isPersian ? 'اثر ادبی' : 'Асари адабӣ';
    }
  }
}
