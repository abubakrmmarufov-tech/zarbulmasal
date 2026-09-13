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

    final poetsCount = poetsAsync.valueOrNull?.length ?? 0;
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
