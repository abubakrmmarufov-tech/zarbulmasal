import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_work.dart';
import '../domain/verification_record.dart';

/// A screen listing all verified and approved literary works.
class WorksListScreen extends ConsumerWidget {
  const WorksListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final approvedWorksAsync = ref.watch(approvedWorksProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top back button bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
                    icon: const BackButtonIcon(),
                    onPressed: () => qalamBack(context),
                  ),
                ),
              ),
            ),
            // Page Header
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: isPersian ? '۰۲ / شعرها' : '02 / ШЕЪРҲО',
                title: AppTranslations.get('lit_poems', lang),
                subtitle: isPersian
                    ? 'غزل‌ها، رباعی‌ها و آثار منظوم بررسی‌شده و معتبر'
                    : 'Ғазалҳо, рубоиҳо ва осори манзуми тасдиқшуда аз нусхаҳои чопӣ',
              ),
            ),
            // Works content
            approvedWorksAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: isPersian
                        ? 'خطا در بارگیری آثار'
                        : 'Хато ҳангоми боргирии асарҳо',
                    subtitle: err.toString(),
                  ),
                ),
              ),
              data: (works) {
                if (works.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: EmptyState(
                          icon: Icons.menu_book_outlined,
                          title: isPersian
                              ? 'آثار در حال بررسی است'
                              : 'Осор дар марҳилаи санҷиш қарор дорад',
                          subtitle: isPersian
                              ? 'طبق استانداردهای علمی برنامه، متن اشعار تنها پس از مقابلهٔ فیزیکی با نسخه‌های چاپی معتبر و ثبت شناسنامه در دسترس قرار می‌گیرد.'
                              : 'Мутобиқи меъёрҳои илмии барнома, матни асарҳо танҳо пас аз муқобала бо нусхаҳои чопии муътамад ва сабти манбаъ нашр мегардад.',
                          action: OutlinedButton(
                            onPressed: () => context.push('/literature/poets'),
                            child: Text(
                              isPersian
                                  ? 'مشاهدهٔ شاعران'
                                  : 'Дидани рӯйхати шоирон',
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final work = works[index];
                      return _WorkListItem(work: work);
                    },
                    childCount: works.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkListItem extends ConsumerWidget {
  final LiteraryWork work;

  const _WorkListItem({required this.work});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final authorAsync = ref.watch(authorByIdProvider(work.authorId));
    final author = authorAsync.valueOrNull;

    final title = (isPersian && work.titlePersian != null && work.titlePersian!.isNotEmpty)
        ? work.titlePersian!
        : work.title;

    final authorName = author != null
        ? ((isPersian && author.canonicalNamePersian != null)
            ? author.canonicalNamePersian!
            : author.canonicalName)
        : work.authorId;

    return InkWell(
      onTap: () => context.push('/literature/work/${work.id}'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: QalamSpacing.pageH,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 19,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authorName,
                    style: QalamTypography.meta(
                      color: colors.primary,
                      fontSize: 13,
                    ),
                  ),
                  if (work.incipit != null && work.incipit!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      '«${work.incipit}»',
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (work.verification.finalStatus == VerificationStatus.approved)
              const Icon(Icons.check_circle_outline, size: 16, color: QalamColors.forest),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: colors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
