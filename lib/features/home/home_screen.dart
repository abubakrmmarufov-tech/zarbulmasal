import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../shared/providers/app_providers.dart';

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
    final isPersian = lang == DisplayLanguage.persian;
    String tr(String key) => AppTranslations.get(key, lang);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tr('app_name'),
                            style: QalamTypography.label(
                              color: colors.onSurface,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        Text(
                          'З / ض',
                          style: QalamTypography.heroProverb(
                            color: colors.primary,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 24),
                    Text(
                      tr('home_headline'),
                      style: QalamTypography.pageTitle(
                        color: colors.onSurface,
                        fontSize: 46,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      tr('app_tagline'),
                      style: QalamTypography.bodySecondary(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (daily != null)
              SliverToBoxAdapter(
                child: QalamDailyHero(
                  proverb: daily,
                  onOpen: () => context.push('/daily'),
                ),
              ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '01 / ${tr('home_learning')}',
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      tr('home_learn'),
                      style: QalamTypography.sectionTitle(
                        color: colors.onSurface,
                        fontSize: 29,
                      ),
                    ),
                    const SizedBox(height: 12),
                    QalamSectionLink(
                      number: '01',
                      title: tr('quiz_title'),
                      subtitle: tr('quiz_desc'),
                      onTap: () => context.push('/quiz'),
                    ),
                    QalamSectionLink(
                      number: '02',
                      title: tr('flashcards_title'),
                      subtitle: tr('flashcards_desc'),
                      onTap: () => context.push('/flashcards'),
                    ),
                    QalamSectionLink(
                      number: '03',
                      title: tr('levels_title'),
                      subtitle: AppTranslations.get('levels_subtitle', lang, [
                        availableLevels.length,
                      ]),
                      onTap: () => context.push('/levels'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: QalamLiteratureCard(
                onTap: () => context.push('/literature'),
                title: 'Мероси адабӣ',
                subtitle: isPersian
                    ? 'گنجینه شعر و حکمت تاجیک'
                    : 'Ганҷинаи шеър ва ҳикмати тоҷик',
                sectionLabel: '01 / АДАБИЁТ',
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '02 / ${tr('categories_title')}',
                      style: QalamTypography.eyebrow(color: colors.primary),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${categories.length}',
                          style: QalamTypography.pageTitle(
                            color: colors.onSurface,
                            fontSize: 72,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              tr('categories_subtitle'),
                              style: QalamTypography.sectionTitle(
                                color: colors.onSurface,
                                fontSize: 23,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    for (final category in categories.take(3))
                      QalamSectionLink(
                        number: '${categories.indexOf(category) + 1}'.padLeft(
                          2,
                          '0',
                        ),
                        title: QalamCategoryTile.nameFor(category, lang),
                        subtitle:
                            AppTranslations.get('proverb_count_label', lang, [
                              proverbs
                                  .where((p) => p.categoryId == category.id)
                                  .length,
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
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: '03 / ${tr('home_explore')}',
                title: tr('home_proverbs'),
                subtitle: AppTranslations.get('proverb_count_label', lang, [
                  proverbs.length,
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
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: OutlinedButton(
                  onPressed: () => context.go('/proverbs'),
                  child: Text(tr('btn_see_all')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
