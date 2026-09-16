import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../data/literature_providers.dart';
import '../domain/literary_work.dart';

/// The central landing hub for the "Мероси адабӣ" (Literary Heritage) feature.
///
/// Provides entry points to Poets, Verified Works, National School Canon,
/// Oral Heritage, and the Daily Verse.
class LiteratureHubScreen extends ConsumerWidget {
  const LiteratureHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final dailyVerseAsync = ref.watch(dailyVerseProvider);
    final oralAsync = ref.watch(oralHeritageProvider);
    final schoolCanonAsync = ref.watch(schoolCanonProvider);

    final oralCount = oralAsync.valueOrNull?.length ?? 0;
    final poetsAsync = ref.watch(literaryAuthorsProvider);
    final worksAsync = ref.watch(approvedWorksProvider);

    final poetsCount =
        poetsAsync.valueOrNull?.where((poet) => poet.hasCanonicalName).length ??
        0;
    final worksCount = worksAsync.valueOrNull?.length ?? 0;
    final formattedPoetsCount = AppTranslations.formatNumber(poetsCount, lang);
    final formattedWorksCount = AppTranslations.formatNumber(worksCount, lang);
    final formattedOralCount = AppTranslations.formatNumber(oralCount, lang);
    final schoolCanonCount = schoolCanonAsync.valueOrNull?.length ?? 0;
    final formattedSchoolCanonCount = AppTranslations.formatNumber(
      schoolCanonCount,
      lang,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverSafeArea(
            bottom: false,
            sliver: SliverMainAxisGroup(
              slivers: [
                // Top Action Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
                          icon: const BackButtonIcon(),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/');
                            }
                          },
                        ),
                        IconButton(
                          tooltip: isPersian ? 'جستجو' : 'Ҷустуҷӯ',
                          icon: const Icon(Icons.search, size: 22),
                          onPressed: () => context.push('/literature/search'),
                        ),
                      ],
                    ),
                  ),
                ),
                // Page Header
                SliverToBoxAdapter(
                  child: QalamPageHeader(
                    eyebrow: isPersian
                        ? 'گنجینهٔ ادب تاجیک'
                        : 'ГАНҶИНАИ АДАБИ ТОҶИК',
                    title: AppTranslations.get('lit_title', lang),
                    subtitle: isPersian
                        ? 'گنجینهٔ شعر و حکمت تاجیک با استناد به نسخه‌های چاپی و معتبر'
                        : 'Ганҷинаи шеър ва ҳикмати тоҷик бо истинод ба сарчашмаҳои чопии муътамад',
                  ),
                ),
                // Daily Verse Section (at top)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QalamSpacing.pageH,
                      vertical: 8,
                    ),
                    child: dailyVerseAsync.when(
                      loading: () => _DailyVerseStatus(
                        isPersian: isPersian,
                        title: AppTranslations.get('lit_daily_verse', lang),
                        subtitle: isPersian
                            ? 'در حال بررسی آثار معتبر...'
                            : 'Осори санҷидашуда боргирӣ мешаванд...',
                      ),
                      error: (_, _) => _DailyVerseStatus(
                        isPersian: isPersian,
                        title: isPersian
                            ? 'بیت روز موقتاً در دسترس نیست'
                            : 'Байти рӯз муваққатан дастрас нест',
                        subtitle: isPersian
                            ? 'داده‌های ادبی را دوباره بارگیری کنید.'
                            : 'Маълумоти адабиро дубора боргирӣ кунед.',
                        onRetry: () => ref.invalidate(dailyVerseProvider),
                      ),
                      data: (work) => work == null
                          ? _DailyVerseStatus(
                              isPersian: isPersian,
                              title: AppTranslations.get(
                                'lit_daily_pending_title',
                                lang,
                              ),
                              subtitle: AppTranslations.get(
                                'lit_daily_pending_subtitle',
                                lang,
                              ),
                            )
                          : _DailyVerseCard(work: work, isPersian: isPersian),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                // Featured Poems Showcase
                if (worksAsync.valueOrNull != null &&
                    worksAsync.valueOrNull!.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _FeaturedWorksShowcase(
                      works: worksAsync.valueOrNull!,
                      isPersian: isPersian,
                      dailyVerseId: dailyVerseAsync.valueOrNull?.id,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                // 5 Section Links
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: QalamSpacing.pageH,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPersian ? 'بخش‌های گنجینه' : 'БАХШҲОИ ГАНҶИНА',
                          style: QalamTypography.eyebrow(color: colors.primary),
                        ),
                        const SizedBox(height: 12),
                        QalamSectionLink(
                          number: '00',
                          title: isPersian
                              ? 'تاریخ مردم تاجیک'
                              : 'Таърихи халқи тоҷик',
                          subtitle: isPersian
                              ? 'نام‌ها، دولت‌ها و شعرهای کتاب‌های صنف‌های ۵ تا ۱۱'
                              : 'Номҳо, давлатҳо ва шеърҳои китобҳои синфҳои 5–11',
                          onTap: () => context.push('/history'),
                        ),
                        // 01: Poets
                        QalamSectionLink(
                          number: '01',
                          title: AppTranslations.get('lit_poets', lang),
                          subtitle: isPersian
                              ? 'زندگینامه و آثار $formattedPoetsCount شاعر و ادیب بزرگ'
                              : 'Зиндагинома ва осори $formattedPoetsCount шоир ва адиби бузург',
                          onTap: () => context.push('/literature/poets'),
                        ),
                        // 02: Works / Poems
                        QalamSectionLink(
                          number: '02',
                          title: AppTranslations.get('lit_poems', lang),
                          subtitle: worksCount > 0
                              ? (isPersian
                                    ? 'غزل‌ها، قصیده‌ها و رباعی‌های تصحیح‌شده ($formattedWorksCount اثر)'
                                    : 'Ғазалҳо, қасидаҳо ва рубоиҳои санҷидашуда ($formattedWorksCount асар)')
                              : (isPersian
                                    ? 'غزل‌ها، قصیده‌ها و رباعی‌های در حال مقابله و تصحیح'
                                    : 'Ғазалҳо, қасидаҳо ва рубоиҳои дар ҳоли тасдиқ ва муқобала'),
                          onTap: () => context.push('/literature/works'),
                        ),
                        // 03: School Canon
                        QalamSectionLink(
                          number: '03',
                          title: AppTranslations.get('lit_school', lang),
                          subtitle: schoolCanonCount > 0
                              ? '${AppTranslations.get('lit_school_desc', lang)} ($formattedSchoolCanonCount ${isPersian ? 'اثر' : 'асар'})'
                              : AppTranslations.get('lit_school_desc', lang),
                          onTap: () => context.push('/literature/school'),
                        ),
                        // 04: Oral Heritage
                        QalamSectionLink(
                          number: '04',
                          title: AppTranslations.get('lit_oral', lang),
                          subtitle: oralCount > 0
                              ? (isPersian
                                    ? 'ضرب‌المثل‌ها، چیستان‌ها و دوبیتی‌های عامیانه ($formattedOralCount مدخل)'
                                    : 'Зарбулмасалҳо, чистонҳо ва дубайтиҳои халқӣ ($formattedOralCount намуна)')
                              : AppTranslations.get(
                                  'lit_oral_coming_soon',
                                  lang,
                                ),
                          onTap: oralCount > 0
                              ? () => context.push('/literature/oral')
                              : null,
                        ),
                        // 05: Search
                        QalamSectionLink(
                          number: '05',
                          title: AppTranslations.get('lit_search', lang),
                          subtitle: AppTranslations.get(
                            'lit_search_desc',
                            lang,
                          ),
                          onTap: () => context.push('/literature/search'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 48)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyVerseStatus extends StatelessWidget {
  final bool isPersian;
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;

  const _DailyVerseStatus({
    required this.isPersian,
    required this.title,
    required this.subtitle,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(QalamSpacing.cardPad),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(QalamSpacing.cardRadius),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.menu_book_outlined, color: colors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: isPersian
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  textAlign: isPersian ? TextAlign.right : TextAlign.left,
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: isPersian ? TextAlign.right : TextAlign.left,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: onRetry,
                    child: Text(
                      isPersian ? 'تلاش دوباره' : 'Дубора кӯшиш кардан',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A featured card at the top of the Literature Hub displaying the Daily Verse.
class _DailyVerseCard extends ConsumerWidget {
  final LiteraryWork? work;
  final bool isPersian;

  const _DailyVerseCard({required this.work, required this.isPersian});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (work == null) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? QalamColors.inkCard : QalamColors.ink;
    final textColor = isDark ? QalamColors.paperText : QalamColors.paper;
    final accentColor = isDark
        ? QalamColors.antiqueGoldSoft
        : QalamColors.burgundySoft;
    final mutedColor = isDark ? QalamColors.paperTextSoft : QalamColors.inkMute;

    final authorAsync = ref.watch(authorByIdProvider(work!.authorId));
    final author = authorAsync.valueOrNull;
    final authorName = author != null
        ? ((isPersian && author.canonicalNamePersian != null)
              ? author.canonicalNamePersian!
              : author.canonicalName)
        : work!.authorId;

    final verseText = (work!.incipit != null && work!.incipit!.isNotEmpty)
        ? '«${work!.incipit}»'
        : (isPersian && work!.titlePersian != null
              ? work!.titlePersian!
              : work!.title);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(QalamSpacing.cardRadius),
      child: InkWell(
        onTap: () => context.push('/literature/work/${work!.id}'),
        borderRadius: BorderRadius.circular(QalamSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(QalamSpacing.cardPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isPersian ? 'بیت روز' : 'БАЙТИ РӮЗ',
                    style: QalamTypography.eyebrow(color: accentColor),
                  ),
                  Icon(Icons.arrow_forward, color: accentColor, size: 18),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                verseText,
                style: QalamTypography.heroProverb(
                  color: textColor,
                  fontSize: 22,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    authorName,
                    style: QalamTypography.meta(
                      color: accentColor,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isPersian ? 'خوانش کامل' : 'Мутолиаи асар',
                    style: QalamTypography.meta(
                      color: mutedColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A horizontally scrollable showcase of canonical poems and works.
class _FeaturedWorksShowcase extends ConsumerWidget {
  final List<LiteraryWork> works;
  final bool isPersian;
  final String? dailyVerseId;

  const _FeaturedWorksShowcase({
    required this.works,
    required this.isPersian,
    this.dailyVerseId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Filter out the daily verse work so we don't duplicate it in the showcase
    final available = works
        .where((w) => dailyVerseId == null || w.id != dailyVerseId)
        .toList();
    if (available.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;

    // Pick top prominent works that have incipits or text
    final featured = available.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: QalamSpacing.pageH),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isPersian
                    ? 'شاهکارهای ادب فارسی و تاجیکی'
                    : 'ШЕЪРҲОИ БАРГУЗИДА',
                style: QalamTypography.eyebrow(color: colors.primary),
              ),
              TextButton(
                onPressed: () => context.push('/literature/works'),
                child: Text(
                  isPersian ? 'همهٔ آثار' : 'Ҳамаи асарҳо',
                  style: TextStyle(fontSize: 12, color: colors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: QalamSpacing.pageH),
            itemCount: featured.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final work = featured[index];
              final authorAsync = ref.watch(authorByIdProvider(work.authorId));
              final author = authorAsync.valueOrNull;
              final authorName = author != null
                  ? ((isPersian && author.canonicalNamePersian != null)
                        ? author.canonicalNamePersian!
                        : author.canonicalName)
                  : work.authorId;

              final title = (isPersian && work.titlePersian != null)
                  ? work.titlePersian!
                  : work.title;

              final incipit = work.incipit ?? '';

              return SizedBox(
                width: 260,
                child: Card(
                  elevation: 0,
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.7),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/literature/work/${work.id}'),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: isPersian
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _genreLabel(work.type, isPersian),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: colors.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: colors.onSurfaceVariant,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: QalamTypography.sectionTitle(
                              color: colors.onSurface,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            authorName,
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          if (incipit.isNotEmpty)
                            Text(
                              '«$incipit»',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontStyle: FontStyle.italic,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  static String _genreLabel(WorkType type, bool isPersian) {
    switch (type) {
      case WorkType.ghazal:
        return isPersian ? 'غزل' : 'Ғазал';
      case WorkType.rubai:
        return isPersian ? 'رباعی' : 'Рубоӣ';
      case WorkType.qasida:
        return isPersian ? 'قصیده' : 'Қасида';
      case WorkType.poem:
        return isPersian ? 'شعر' : 'Шеър';
      case WorkType.epic:
        return isPersian ? 'حماسه' : 'Ҳамоса';
      case WorkType.folk:
        return isPersian ? 'فولکلور' : 'Халқӣ';
      default:
        return isPersian ? 'اثر منظوم' : 'Шеър';
    }
  }
}
