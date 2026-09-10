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
    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final canonAsync = ref.watch(schoolCanonProvider);
    final oralAsync = ref.watch(oralHeritageProvider);

    final authorsCount = authorsAsync.valueOrNull?.length ?? 0;
    final canonCount = canonAsync.valueOrNull?.length ?? 0;
    final oralCount = oralAsync.valueOrNull?.length ?? 0;

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
                    eyebrow: isPersian ? 'گنجینهٔ ادب تاجیک' : 'ГАНҶИНАИ АДАБИ ТОҶИК',
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
                      loading: () => const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                      data: (work) => _DailyVerseCard(
                        work: work,
                        isPersian: isPersian,
                      ),
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
                          style: QalamTypography.eyebrow(
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // 01: Poets
                        QalamSectionLink(
                          number: '01',
                          title: AppTranslations.get('lit_poets', lang),
                          subtitle: isPersian
                              ? 'زندگینامه و آثار $authorsCount شاعر و ادیب بزرگ'
                              : 'Зиндагинома ва осори $authorsCount шоир ва адиби бузург',
                          onTap: () => context.push('/literature/poets'),
                        ),
                        // 02: Works / Poems
                        QalamSectionLink(
                          number: '02',
                          title: AppTranslations.get('lit_poems', lang),
                          subtitle: isPersian
                              ? 'غزل‌ها، قصیده‌ها و رباعی‌های تصحیح‌شده'
                              : 'Ғазалҳо, қасидаҳо ва рубоиҳои санҷидашуда',
                          onTap: () => context.push('/literature/works'),
                        ),
                        // 03: School Canon
                        QalamSectionLink(
                          number: '03',
                          title: AppTranslations.get('lit_school', lang),
                          subtitle: isPersian
                              ? 'برنامهٔ درسی صنف‌های ۴ تا ۱۱ ($canonCount مدخل درسی)'
                              : 'Барномаи таълимии синфҳои 4–11 ($canonCount мавзӯъ)',
                          onTap: () => context.push('/literature/school'),
                        ),
                        // 04: Oral Heritage
                        QalamSectionLink(
                          number: '04',
                          title: AppTranslations.get('lit_oral', lang),
                          subtitle: isPersian
                              ? 'ضرب‌المثل‌ها، چیستان‌ها و دوبیتی‌های عامیانه ($oralCount مدخل)'
                              : 'Зарбулмасалҳо, чистонҳо ва дубайтиҳои халқӣ ($oralCount намуна)',
                          onTap: () => context.push('/literature/oral'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 48),
                ),
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

  const _DailyVerseCard({
    required this.work,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? QalamColors.inkCard : QalamColors.ink;
    final textColor = isDark ? QalamColors.paperText : QalamColors.paper;
    final accentColor =
        isDark ? QalamColors.antiqueGoldSoft : QalamColors.burgundySoft;
    final mutedColor =
        isDark ? QalamColors.paperTextSoft : QalamColors.inkMute;

    if (work == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(QalamSpacing.cardRadius),
          border: Border.all(color: colors.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.auto_stories, size: 28, color: colors.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPersian ? 'بیت روز' : 'БАЙТИ РӮЗ',
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPersian
                        ? 'اشعار تأییدشده به صورت روزانه نمایش داده می‌شوند.'
                        : 'Байтҳои санҷидашуда ба таври рӯзона интихоб ва муаррифӣ мегарданд.',
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
