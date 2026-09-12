import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';

/// A screen presenting canonical Tajik literary authors and poets.
class PoetsListScreen extends ConsumerStatefulWidget {
  const PoetsListScreen({super.key});

  @override
  ConsumerState<PoetsListScreen> createState() => _PoetsListScreenState();
}

class _PoetsListScreenState extends ConsumerState<PoetsListScreen> {
  String _filterQuery = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final authorsAsync = ref.watch(literaryAuthorsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Top back button
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
            // Header
            SliverToBoxAdapter(
              child: QalamPageHeader(
                eyebrow: isPersian ? '۰۱ / شاعران' : '01 / ШОИРОН',
                title: AppTranslations.get('lit_poets', lang),
                subtitle: isPersian
                    ? 'بزرگان ادب کلاسیک و معاصر تاجیک با زندگینامه و اسناد معتبر'
                    : 'Бузургони адабиёти классик ва муосири тоҷик бо зиндагиномаи мустанад',
              ),
            ),
            // Filter Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: TextField(
                  onChanged: (val) {
                    setState(() {
                      _filterQuery = val.trim().toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: isPersian
                        ? 'جستجوی شاعر بر اساس نام یا دوره...'
                        : 'Ҷустуҷӯи шоир аз рӯи ном ё давр...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _filterQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              setState(() {
                                _filterQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: colors.surfaceContainerHighest.withValues(
                      alpha: 0.4,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Poets list
            authorsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: isPersian
                        ? 'خطا در بارگیری شاعران'
                        : 'Хато ҳангоми боргирии шоирон',
                    subtitle: err.toString(),
                  ),
                ),
              ),
              data: (authors) {
                final filtered = authors.where((author) {
                  if (_filterQuery.isEmpty) return true;
                  final matchName = author.canonicalName.toLowerCase().contains(
                    _filterQuery,
                  );
                  final matchFa =
                      author.canonicalNamePersian?.toLowerCase().contains(
                        _filterQuery,
                      ) ??
                      false;
                  final matchPeriod = author.literaryPeriod
                      .toLowerCase()
                      .contains(_filterQuery);
                  final matchAliases = author.aliases.any(
                    (a) => a.toLowerCase().contains(_filterQuery),
                  );
                  return matchName || matchFa || matchPeriod || matchAliases;
                }).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.search_off,
                        title: isPersian ? 'شاعری یافت نشد' : 'Шоире ёфт нашуд',
                        subtitle: isPersian
                            ? 'با عبارت جستجوی مورد نظر نتیجه‌ای پیدا نشد.'
                            : 'Бо ин вожа шоире дар феҳрист ёфт нашуд.',
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final poet = filtered[index];
                    final name =
                        (isPersian && poet.canonicalNamePersian != null)
                        ? poet.canonicalNamePersian!
                        : poet.canonicalName;
                    return QalamPoetCard(
                      name: name,
                      dates: poet.lifespan,
                      period: poet.literaryPeriod,
                      isPublicDomain: poet.isPublicDomain,
                      onTap: () => context.push('/literature/poet/${poet.id}'),
                    );
                  }, childCount: filtered.length),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }
}
