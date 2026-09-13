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
        error: (err, _) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: isPersian ? 'خطا در بارگیری' : 'Хато ҳангоми боргирӣ',
            subtitle: err.toString(),
            action: OutlinedButton(
              onPressed: () => qalamBack(context),
              child: Text(isPersian ? 'بازگشت' : 'Бозгашт'),
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
  final AsyncValue<List<dynamic>> canonAsync;

  const _PoetDetailContent({
    required this.poet,
    required this.worksAsync,
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
                // Official Titles
                if (poet.officialTitles.isNotEmpty) ...[
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
                        isPersian
                            ? 'منبع استناد زندگینامه:'
                            : 'Сарчашмаи истинод:',
                        style: QalamTypography.meta(color: colors.primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        poet.biographySource,
                        style: QalamTypography.bodySecondary(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 24),
                // Works Section Title
                Text(
                  isPersian ? 'آثار و اشعار' : 'Осор ва шеърҳо',
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 12),
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
          error: (err, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text('Хато: $err'),
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
        const SliverToBoxAdapter(child: SizedBox(height: 48)),
      ],
    );
  }
}
