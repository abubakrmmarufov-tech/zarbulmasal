import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/learning_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final daily = ref.watch(dailyProverbProvider);
    final proverbs = ref.watch(proverbsProvider);
    final categories = ref.watch(categoriesProvider);
    final availableLevels = ref.watch(availableLevelsProvider);
    final stats = ref.watch(masteryStatsProvider);
    final isPersian = lang == DisplayLanguage.persian;
    String tr(String key) => AppTranslations.get(key, lang);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Publication Masthead Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  20,
                  QalamSpacing.pageH,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Masthead Top Row
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                QalamSpacing.radiusXs,
                              ),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.25),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              tr('app_name').toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: QalamTypography.eyebrow(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPersian ? 'ض' : 'З / ض',
                          style: QalamTypography.heroProverb(
                            color: colors.primary,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Divider(color: colors.outlineVariant, height: 1),
                    const SizedBox(height: 22),
                    Text(
                      tr('home_headline'),
                      style: QalamTypography.pageTitle(
                        color: colors.onSurface,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      tr('app_tagline'),
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Signature Daily Proverb Hero Folio
            if (daily != null)
              SliverToBoxAdapter(
                child: QalamDailyHero(
                  proverb: daily,
                  onOpen: () => context.push('/daily'),
                ),
              ),

            // Section 01: Learning & Mastery Portal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  32,
                  QalamSpacing.pageH,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppTranslations.formatDigits('01', lang)} / ${tr('home_learning').toUpperCase()}',
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr('home_learn'),
                      style: QalamTypography.sectionTitle(
                        color: colors.onSurface,
                        fontSize: 24,
                      ),
                    ),
                    if (stats.masteredCount > 0 || stats.learningCount > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(
                            QalamSpacing.radiusSm,
                          ),
                          border: Border.all(
                            color: colors.outlineVariant,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.auto_stories_outlined,
                              size: 18,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppTranslations.get('home_mastery_stat', lang, [
                                  AppTranslations.formatDigits(
                                    '${stats.masteredCount}',
                                    lang,
                                  ),
                                  AppTranslations.formatDigits(
                                    '${stats.totalProverbs}',
                                    lang,
                                  ),
                                ]),
                                style: QalamTypography.meta(
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    QalamSectionLink(
                      number: AppTranslations.formatDigits('01', lang),
                      title: tr('quiz_title'),
                      subtitle: tr('quiz_desc'),
                      onTap: () => context.push('/quiz'),
                    ),
                    QalamSectionLink(
                      number: AppTranslations.formatDigits('02', lang),
                      title: tr('flashcards_title'),
                      subtitle: tr('flashcards_desc'),
                      onTap: () => context.push('/flashcards'),
                    ),
                    QalamSectionLink(
                      number: AppTranslations.formatDigits('03', lang),
                      title: tr('levels_title'),
                      subtitle: AppTranslations.get('levels_subtitle', lang, [
                        AppTranslations.formatDigits(
                          '${availableLevels.length}',
                          lang,
                        ),
                      ]),
                      onTap: () => context.push('/levels'),
                    ),
                  ],
                ),
              ),
            ),

            // Feature Banner: Literary Heritage
            SliverToBoxAdapter(
              child: QalamLiteratureCard(
                onTap: () => context.push('/literature'),
                title: isPersian ? 'میراث ادبی' : 'Мероси адабӣ',
                subtitle: isPersian
                    ? 'گنجینه شعر و حکمت تاجیک'
                    : 'Ганҷинаи шеър ва ҳикмати тоҷик',
                sectionLabel: isPersian ? '۰۱ / ادبیات' : '01 / АДАБИЁТ',
              ),
            ),

            // Section 02: Categories Index
            SliverToBoxAdapter(
              child: Container(
                color: colors.surfaceContainerLow,
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  28,
                  QalamSpacing.pageH,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppTranslations.formatDigits('02', lang)} / ${tr('categories_title').toUpperCase()}',
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppTranslations.formatDigits(
                            '${categories.length}',
                            lang,
                          ),
                          style: QalamTypography.pageTitle(
                            color: colors.onSurface,
                            fontSize: 42,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              tr('categories_subtitle'),
                              style: QalamTypography.sectionTitle(
                                color: colors.onSurface,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final category in categories.take(3))
                      QalamSectionLink(
                        number: AppTranslations.formatDigits(
                          '${categories.indexOf(category) + 1}'.padLeft(2, '0'),
                          lang,
                        ),
                        title: QalamCategoryTile.nameFor(category, lang),
                        subtitle:
                            AppTranslations.get('proverb_count_label', lang, [
                              AppTranslations.formatDigits(
                                '${proverbs.where((p) => p.categoryId == category.id).length}',
                                lang,
                              ),
                            ]),
                        onTap: () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              category.id;
                          ref.read(selectedLevelProvider.notifier).state = null;
                          ref.read(searchQueryProvider.notifier).state = '';
                          context.go('/proverbs');
                        },
                      ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go('/categories'),
                      child: Text(tr('btn_see_all')),
                    ),
                  ],
                ),
              ),
            ),

            // Section 03: Proverbs Explorer
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow:
                    '${AppTranslations.formatDigits('03', lang)} / ${tr('home_explore').toUpperCase()}',
                title: tr('home_proverbs'),
                subtitle: AppTranslations.get('proverb_count_label', lang, [
                  AppTranslations.formatDigits('${proverbs.length}', lang),
                ]),
                showRule: false,
              ),
            ),
            SliverList.builder(
              itemCount: proverbs.take(3).length,
              itemBuilder: (context, index) => QalamProverbCard(
                proverb: proverbs[index],
                onTap: () => context.push('/proverb/${proverbs[index].id}'),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  20,
                  QalamSpacing.pageH,
                  28,
                ),
                child: OutlinedButton(
                  onPressed: () => context.go('/proverbs'),
                  child: Text(tr('btn_see_all')),
                ),
              ),
            ),

            // Section 04: Literature Portal
            SliverToBoxAdapter(
              child: Container(
                color: colors.surfaceContainerLow,
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  28,
                  QalamSpacing.pageH,
                  28,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppTranslations.formatDigits('04', lang)} / ${tr('literature_title').toUpperCase()}',
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr('literature_title'),
                      style: QalamTypography.sectionTitle(
                        color: colors.onSurface,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 14),
                    QalamSectionLink(
                      number: AppTranslations.formatDigits('01', lang),
                      title: tr('poets_title'),
                      subtitle: tr('poets_desc'),
                      onTap: () => context.push('/literature/poets'),
                    ),
                    QalamSectionLink(
                      number: AppTranslations.formatDigits('02', lang),
                      title: tr('poems_title'),
                      subtitle: tr('poems_desc'),
                      onTap: () => context.push('/literature/works'),
                    ),
                  ],
                ),
              ),
            ),

            // Section 05: History Portal
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  16,
                  QalamSpacing.pageH,
                  36,
                ),
                child: QalamSectionLink(
                  number: AppTranslations.formatDigits('05', lang),
                  title: isPersian ? 'تاریخ مردم تاجیک' : 'Таърихи халқи тоҷик',
                  subtitle: isPersian
                      ? 'پژوهش منبع‌محور از کتاب‌های صنف‌های ۵ تا ۱۱ و گاه‌شمار'
                      : 'Тадқиқоти сарчашмабунёд аз китобҳои синфҳои 5–11 ва хатти замон',
                  onTap: () => context.push('/history'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
