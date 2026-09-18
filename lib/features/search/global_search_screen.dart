import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../core/utils/search_normalizer.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../literature/data/literature_providers.dart';
import '../history/data/history_providers.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final proverbs = ref.watch(proverbsProvider);
    final authorsAsync = ref.watch(literaryAuthorsProvider);
    final worksAsync = ref.watch(approvedWorksProvider);
    final historyAsync = ref.watch(historyEntriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isPersian
                ? 'جستجوی شاعر، شعر، ضرب‌المثل یا تاریخ...'
                : 'Ҷустуҷӯи шоир, шеър, зарбулмасал ё таърих...',
            border: InputBorder.none,
            hintStyle: QalamTypography.bodySecondary(
              color: colors.onSurfaceVariant,
            ),
          ),
          style: QalamTypography.body(color: colors.onSurface),
          onChanged: (val) {
            setState(() {
              _query = SearchNormalizer.normalize(val);
            });
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              tooltip: isPersian ? 'پاک کردن جستجو' : 'Пок кардани ҷустуҷӯ',
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body:
          (authorsAsync.isLoading ||
              worksAsync.isLoading ||
              historyAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : (authorsAsync.hasError ||
                worksAsync.hasError ||
                historyAsync.hasError)
          ? Center(
              child: EmptyState(
                icon: Icons.error_outline,
                title: isPersian ? 'خطا در جستجو' : 'Хатои ҷустуҷӯ',
                subtitle: isPersian
                    ? 'لطفاً دوباره تلاش کنید.'
                    : 'Лутфан дубора кӯшиш кунед.',
                action: OutlinedButton(
                  onPressed: () {
                    ref.invalidate(literaryAuthorsProvider);
                    ref.invalidate(approvedWorksProvider);
                    ref.invalidate(historyEntriesProvider);
                  },
                  child: Text(
                    isPersian ? 'تلاش دوباره' : 'Дубора кӯшиш кардан',
                  ),
                ),
              ),
            )
          : _query.isEmpty
          ? _buildEmptyState(context, isPersian)
          : _buildSearchResults(
              context,
              proverbs,
              authorsAsync.valueOrNull ?? [],
              worksAsync.valueOrNull ?? [],
              historyAsync.valueOrNull ?? [],
              lang,
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isPersian) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isPersian
                ? 'جستجو در کل زرب‌المثل'
                : 'Ҷустуҷӯ дар кулли Зарбулмасал',
            style: QalamTypography.sectionTitle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<dynamic> proverbs,
    List<dynamic> authors,
    List<dynamic> works,
    List<dynamic> history,
    DisplayLanguage lang,
  ) {
    final isPersian = lang == DisplayLanguage.persian;

    final matchingAuthors = authors.where((a) {
      if (!a.hasCanonicalName) return false;
      return SearchNormalizer.matchesAny([
        a.canonicalName,
        a.canonicalNamePersian ?? '',
        a.literaryPeriod,
        a.birthPlace ?? '',
        ...a.aliases,
      ], _query);
    }).toList();

    final matchingWorks = works.where((w) {
      return SearchNormalizer.matchesAny([
        w.title,
        w.titlePersian ?? '',
        w.incipit ?? '',
      ], _query);
    }).toList();

    final matchingProverbs = proverbs.where((p) {
      return SearchNormalizer.matchesAny([
        p.tajik,
        p.persian ?? '',
        p.literalTranslation ?? '',
      ], _query);
    }).toList();

    final matchingHistory = history.where((h) {
      return SearchNormalizer.matchesAny([
        h.title,
        h.titlePersian ?? '',
        h.summary ?? '',
        h.summaryPersian ?? '',
      ], _query);
    }).toList();

    if (matchingAuthors.isEmpty &&
        matchingWorks.isEmpty &&
        matchingProverbs.isEmpty &&
        matchingHistory.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.search_off,
          title: isPersian ? 'نتیجه‌ای یافت نشد' : 'Мундариҷа ёфт нашуд',
          subtitle: isPersian
              ? 'با عبارت «$_query» چیزی پیدا نشد.'
              : 'Бо вожаи «$_query» чизе ёфт нашуд.',
        ),
      );
    }

    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        if (matchingAuthors.isNotEmpty) ...[
          _buildSectionHeader(isPersian ? 'شاعران' : 'Шоирон', colors),
          for (final author in matchingAuthors)
            ListTile(
              title: Text(
                (isPersian && author.canonicalNamePersian != null)
                    ? author.canonicalNamePersian!
                    : author.canonicalName,
              ),
              subtitle: Text(author.literaryPeriod),
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: author.id,
                        type: RecentActivityType.poet,
                        title:
                            (isPersian && author.canonicalNamePersian != null)
                            ? author.canonicalNamePersian!
                            : author.canonicalName,
                        subtitle: author.literaryPeriod,
                        timestamp: DateTime.now(),
                        route: '/literature/poet/${author.id}',
                      ),
                    );
                context.push('/literature/poet/${author.id}');
              },
            ),
        ],
        if (matchingWorks.isNotEmpty) ...[
          _buildSectionHeader(
            isPersian ? 'شعرها و آثار' : 'Шеърҳо ва осор',
            colors,
          ),
          for (final work in matchingWorks)
            ListTile(
              title: Text(
                (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title,
              ),
              subtitle: work.incipit != null
                  ? Text(
                      work.incipit!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: work.id,
                        type: RecentActivityType.work,
                        title: (isPersian && work.titlePersian != null)
                            ? work.titlePersian!
                            : work.title,
                        subtitle: isPersian ? 'شعر' : 'Шеър',
                        timestamp: DateTime.now(),
                        route: '/literature/work/${work.id}',
                      ),
                    );
                context.push('/literature/work/${work.id}');
              },
            ),
        ],
        if (matchingProverbs.isNotEmpty) ...[
          _buildSectionHeader(
            isPersian ? 'ضرب‌المثل‌ها' : 'Зарбулмасалҳо',
            colors,
          ),
          for (final proverb in matchingProverbs)
            ListTile(
              title: Text(
                isPersian ? (proverb.persian ?? proverb.tajik) : proverb.tajik,
              ),
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: proverb.id,
                        type: RecentActivityType.proverb,
                        title: isPersian
                            ? (proverb.persian ?? proverb.tajik)
                            : proverb.tajik,
                        subtitle: isPersian ? 'ضرب‌المثل' : 'Зарбулмасал',
                        timestamp: DateTime.now(),
                        route: '/proverb/${proverb.id}',
                      ),
                    );
                context.push('/proverb/${proverb.id}');
              },
            ),
        ],
        if (matchingHistory.isNotEmpty) ...[
          _buildSectionHeader(isPersian ? 'تاریخ' : 'Таърих', colors),
          for (final entry in matchingHistory)
            ListTile(
              title: Text(
                (isPersian && entry.titlePersian != null)
                    ? entry.titlePersian!
                    : entry.title,
              ),
              subtitle: entry.date != null ? Text(entry.date!) : null,
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: entry.id,
                        type: RecentActivityType.history,
                        title: (isPersian && entry.titlePersian != null)
                            ? entry.titlePersian!
                            : entry.title,
                        subtitle: isPersian ? 'تاریخ' : 'Таърих',
                        timestamp: DateTime.now(),
                        route: '/history/${entry.id}',
                      ),
                    );
                context.push('/history/${entry.id}');
              },
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(title, style: QalamTypography.eyebrow(color: colors.primary)),
    );
  }
}
