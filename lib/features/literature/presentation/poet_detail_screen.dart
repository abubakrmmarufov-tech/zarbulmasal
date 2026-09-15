import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/literary_author.dart';
import '../domain/literary_work.dart';
import '../domain/verification_record.dart';
import '../../history/data/history_providers.dart';
import '../../history/domain/history_domain.dart';

/// A detailed monograph view for a canonical Tajik author/poet,
/// displaying verified biography, source citations, curriculum links, and works.
class PoetDetailScreen extends ConsumerWidget {
  final String poetId;

  const PoetDetailScreen({super.key, required this.poetId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final authorAsync = ref.watch(authorByIdProvider(poetId));
    final worksAsync = ref.watch(worksByAuthorProvider(poetId));
    final reviewWorksAsync = ref.watch(
      worksUnderReviewByAuthorProvider(poetId),
    );
    final canonAsync = ref.watch(schoolCanonByAuthorProvider(poetId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: Text(
          isPersian ? 'زندگینامه و آثار' : 'Зиндагинома ва осор',
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 18,
          ),
        ),
      ),
      body: authorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: isPersian ? 'خطا در بارگیری' : 'Хато ҳангоми боргирӣ',
            subtitle: isPersian
                ? 'اطلاعات شاعر بارگیری نشد. لطفاً دوباره تلاش کنید.'
                : 'Маълумоти шоир бор нашуд. Лутфан дубора кӯшиш кунед.',
            action: OutlinedButton(
              onPressed: () => ref.invalidate(authorByIdProvider(poetId)),
              child: Text(isPersian ? 'تلاش دوباره' : 'Дубора кӯшиш кардан'),
            ),
          ),
        ),
        data: (poet) {
          if (poet == null) {
            return Center(
              child: EmptyState(
                icon: Icons.person_off_outlined,
                title: isPersian ? 'شاعر یافت نشد' : 'Шоир ёфт нашуд',
                subtitle: isPersian
                    ? 'اطلاعات این مؤلف در پایگاه داده ثبت نشده است.'
                    : 'Маълумоти ин шоир дар пойгоҳи маълумот пайдо нашуд.',
                action: OutlinedButton(
                  onPressed: () => qalamBack(context),
                  child: Text(isPersian ? 'بازگشت' : 'Бозгашт'),
                ),
              ),
            );
          }

          return _PoetDetailContent(
            poet: poet,
            worksAsync: worksAsync,
            reviewWorksAsync: reviewWorksAsync,
            canonAsync: canonAsync,
          );
        },
      ),
    );
  }
}

class _PoetDetailContent extends ConsumerWidget {
  final LiteraryAuthor poet;
  final AsyncValue<List<LiteraryWork>> worksAsync;
  final AsyncValue<List<LiteraryWork>> reviewWorksAsync;
  final AsyncValue<List<dynamic>> canonAsync;

  const _PoetDetailContent({
    required this.poet,
    required this.worksAsync,
    required this.reviewWorksAsync,
    required this.canonAsync,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final name = (isPersian && poet.canonicalNamePersian != null)
        ? poet.canonicalNamePersian!
        : poet.canonicalName;

    final altName = (isPersian && poet.canonicalNamePersian != null)
        ? poet.canonicalName
        : poet.canonicalNamePersian;

    final biography = (isPersian && poet.biographyFa != null)
        ? poet.biographyFa!
        : poet.biographyTj;
    final hasAuditableBiography = poet.hasAuditableBiographySource;
    final biographySourceLabel = poet.hasAuditableBiographySource
        ? (isPersian ? 'منبع استناد زندگینامه:' : 'Сарчашмаи истинод:')
        : (isPersian
              ? 'منبع صفحه‌دارِ تأییدشده ثبت نشده است:'
              : 'Сарчашмаи саҳифадори санҷидашуда сабт нашудааст:');
    final biographySourceText = poet.hasAuditableBiographySource
        ? poet.biographySource
        : (isPersian
              ? 'برچسب واردشده: ${poet.biographySource}'
              : 'Барчаспи воридотӣ: ${poet.biographySource}');

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period & Public Domain badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        poet.literaryPeriod.toUpperCase(),
                        style: QalamTypography.eyebrow(color: colors.primary),
                      ),
                    ),
                    if (poet.isPublicDomain) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: QalamColors.forest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: QalamColors.forest.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.public,
                              size: 13,
                              color: QalamColors.forest,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isPersian ? 'مالکیت عمومی' : 'Моликияти умумӣ',
                              style: QalamTypography.meta(
                                color: QalamColors.forest,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                // Main Name
                Text(
                  name,
                  textDirection:
                      (isPersian && poet.canonicalNamePersian != null)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: QalamTypography.pageTitle(
                    color: colors.onSurface,
                    fontSize: 34,
                  ),
                ),
                if (altName != null && altName.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    altName,
                    textDirection:
                        (isPersian && poet.canonicalNamePersian != null)
                        ? TextDirection.ltr
                        : TextDirection.rtl,
                    style: QalamTypography.heroProverb(
                      color: colors.onSurfaceVariant,
                      fontSize: 20,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Dates and birthplace
                if (hasAuditableBiography) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 15,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppTranslations.formatDigits(poet.lifespan, lang),
                        style: QalamTypography.meta(
                          color: colors.primary,
                          fontSize: 14,
                        ),
                      ),
                      if (poet.birthPlace != null &&
                          poet.birthPlace!.isNotEmpty) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.place_outlined,
                          size: 16,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            poet.birthPlace!,
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ] else if (poet.lifespan.isNotEmpty ||
                    (poet.birthPlace?.isNotEmpty ?? false))
                  Text(
                    isPersian
                        ? 'تاریخ و زادگاه تا بررسی صفحهٔ منبع در دست بررسی است.'
                        : 'Санаҳо ва зодгоҳ то санҷиши саҳифаи сарчашма дар интизоранд.',
                    style: QalamTypography.meta(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                if (hasAuditableBiography &&
                    (poet.birthDateExact != null ||
                        poet.deathDateExact != null)) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_edu,
                          size: 16,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPersian
                              ? 'ولادت: ${poet.birthDateExact ?? poet.birthYear ?? "—"} · وفات: ${poet.deathDateExact ?? poet.deathYear ?? "در قید حیات"}'
                              : 'Таваллуд: ${poet.birthDateExact ?? poet.birthYear ?? "—"} · Вафот: ${poet.deathDateExact ?? poet.deathYear ?? "дар ҳаёт"}',
                          style: QalamTypography.meta(
                            color: colors.onSurface,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                // Poem count badge (Approved + Review candidates)
                worksAsync.maybeWhen(
                  data: (works) {
                    final reviewWorks = reviewWorksAsync.valueOrNull ?? [];
                    final approvedCount = works.length;
                    final reviewCount = reviewWorks.length;
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories,
                                size: 16,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isPersian
                                    ? 'اشعار تأییدشده در برنامه: ${AppTranslations.formatDigits(approvedCount.toString(), lang)}'
                                    : 'Шеърҳои тасдиқшуда дар барнома: $approvedCount',
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (reviewCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest.withValues(
                                alpha: 0.7,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.hourglass_empty,
                                  size: 15,
                                  color: colors.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isPersian
                                      ? 'رکوردها تحت بررسی: ${AppTranslations.formatDigits(reviewCount.toString(), lang)}'
                                      : 'Сабтҳо таҳти санҷиш: $reviewCount',
                                  style: QalamTypography.meta(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                  orElse: () => const SizedBox.shrink(),
                ),
                // Official Titles
                if (hasAuditableBiography &&
                    poet.officialTitles.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: poet.officialTitles.map((title) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerHighest.withValues(
                            alpha: 0.6,
                          ),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: colors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          title,
                          style: QalamTypography.meta(
                            color: colors.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 24),
                // Biography Section
                Text(
                  isPersian ? 'زندگینامه' : 'Зиндагинома',
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 14),
                if (hasAuditableBiography && biography.trim().isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isPersian && poet.biographyFa == null) ...[
                        Text(
                          'این زندگی‌نامه فعلاً به خط سیریلیک تاجیکی نمایش داده می‌شود.',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      SelectableText(
                        biography,
                        textDirection: (isPersian && poet.biographyFa != null)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        textAlign: (isPersian && poet.biographyFa != null)
                            ? TextAlign.right
                            : TextAlign.left,
                        style: QalamTypography.body(
                          color: colors.onSurface,
                          fontSize: 16,
                          height: 1.75,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    isPersian
                        ? 'متن زندگینامه تا ثبت و بررسی ارجاع صفحه‌دار در دسترس نیست.'
                        : 'Матни тарҷумаиҳолӣ то сабт ва санҷиши истиноди саҳифадор дастрас нест.',
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ),
                const SizedBox(height: 16),
                // Biography Source Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.4,
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
                        biographySourceLabel,
                        style: QalamTypography.meta(color: colors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        biographySourceText,
                        style: QalamTypography.bodySecondary(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                if (poet.relatedHistoryEntryIds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    isPersian ? 'جهان او را بشناسید' : 'Ҷаҳони ӯро бишносед',
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isPersian
                        ? 'دوره‌ها، حاکمان و وقایع تاریخی هم‌دوره در برنامه'
                        : 'Давлатҳо, чеҳраҳо ва воқеаҳои таърихии ҳамзамон дар таърихи халқи тоҷик',
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      final entriesAsync = ref.watch(historyEntriesProvider);
                      final allEntries =
                          entriesAsync.valueOrNull ?? const <HistoryEntry>[];
                      final idSet = poet.relatedHistoryEntryIds.toSet();
                      final related = allEntries
                          .where((e) => idSet.contains(e.id))
                          .toList();
                      if (related.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: related.map((entry) {
                          final title =
                              (isPersian && entry.titlePersian != null)
                              ? entry.titlePersian!
                              : entry.title;
                          return ActionChip(
                            avatar: const Icon(
                              Icons.account_balance_outlined,
                              size: 16,
                            ),
                            label: Text(title),
                            onPressed: () => context.push('/history'),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 24),
                // Works Section Title
                worksAsync.maybeWhen(
                  data: (works) => Text(
                    isPersian
                        ? 'آثار تأییدشده در برنامه (${AppTranslations.formatDigits(works.length.toString(), lang)})'
                        : 'Осори тасдиқшуда дар барнома (${works.length})',
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 22,
                    ),
                  ),
                  orElse: () => Text(
                    isPersian
                        ? 'آثار تأییدشده дар برنامه'
                        : 'Осори тасдиқшуда дар барнома',
                    style: QalamTypography.sectionTitle(
                      color: colors.onSurface,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                reviewWorksAsync.maybeWhen(
                  data: (reviewWorks) => reviewWorks.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            isPersian
                                ? 'رکوردهای آثار در بررسی: ${AppTranslations.formatDigits(reviewWorks.length.toString(), lang)}'
                                : 'Сабтҳои асар дар санҷиш: ${reviewWorks.length}',
                            style: QalamTypography.meta(
                              color: colors.primary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
        // Works list by this author
        worksAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (_, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: EmptyState(
                icon: Icons.error_outline,
                title: isPersian
                    ? 'خطا در بارگیری آثار'
                    : 'Хато ҳангоми боргирии осор',
                subtitle: isPersian
                    ? 'آثار شاعر بارگیری نشد. لطفاً دوباره تلاش کنید.'
                    : 'Осори шоир бор нашуд. Лутфан дубора кӯшиш кунед.',
                action: OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(worksByAuthorProvider(poet.id)),
                  child: Text(
                    isPersian ? 'تلاش دوباره' : 'Дубора кӯшиш кардан',
                  ),
                ),
              ),
            ),
          ),
          data: (works) {
            if (works.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isPersian
                                ? 'اشعار این شاعر در حال تطبیق با نسخه‌های خطی و چاپی معتبر است.'
                                : 'Матнҳои осори ин шоир дар марҳилаи муқобала ва санҷиши сарчашмаҳо қарор доранд.',
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final work = works[index];
                final workTitle = (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title;

                return InkWell(
                  onTap: () => context.push('/literature/work/${work.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colors.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workTitle,
                                style: QalamTypography.sectionTitle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                ),
                              ),
                              if (work.incipit != null) ...[
                                const SizedBox(height: 4),
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
                              if (work.hasAuditableCompositionEvidence &&
                                  work.compositionDate != null &&
                                  work.compositionDate!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 13,
                                      color: colors.primary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      isPersian
                                          ? 'سرایش: ${work.compositionDate}'
                                          : 'Таълиф: ${work.compositionDate}',
                                      style: TextStyle(
                                        color: colors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (work.hasAuditableCompositionEvidence &&
                                        work.compositionContext != null &&
                                        work
                                            .compositionContext!
                                            .isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '· ${work.compositionContext}',
                                          style: QalamTypography.meta(
                                            color: colors.onSurfaceVariant,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (work.verification.finalStatus ==
                            VerificationStatus.approved)
                          const Icon(
                            Icons.check_circle_outline,
                            size: 16,
                            color: QalamColors.forest,
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: works.length),
            );
          },
        ),
        reviewWorksAsync.when(
          loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
          error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          data: (reviewWorks) {
            if (reviewWorks.isEmpty) {
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final work = reviewWorks[index];
                final workTitle = (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title;
                final citation = work.primarySource?.citation;
                final hasPageCitation = work.primarySource?.pageStart != null;

                return InkWell(
                  onTap: () => context.push('/literature/work/${work.id}'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.18,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: colors.outlineVariant,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          size: 18,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workTitle,
                                style: QalamTypography.sectionTitle(
                                  color: colors.onSurface,
                                  fontSize: 17,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isPersian
                                    ? 'در بررسی منبع؛ متن هنوز منتشر نشده است'
                                    : 'Дар санҷиши сарчашма; матн ҳанӯз нашр нашудааст',
                                style: QalamTypography.meta(
                                  color: colors.primary,
                                  fontSize: 12,
                                ),
                              ),
                              if (hasPageCitation &&
                                  citation != null &&
                                  citation.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  citation,
                                  style: QalamTypography.meta(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ] else ...[
                                const SizedBox(height: 4),
                                Text(
                                  isPersian
                                      ? 'شماره صفحه چاپی هنوز ثبت نشده است'
                                      : 'Рақами саҳифаи чопӣ ҳанӯз сабт нашудааст',
                                  style: QalamTypography.meta(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: reviewWorks.length),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}
