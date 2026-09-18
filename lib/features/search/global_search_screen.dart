import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../core/utils/search_normalizer.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/recent_activity_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../literature/data/literature_providers.dart';
import '../literature/domain/domain.dart';
import '../history/data/history_providers.dart';
import '../history/domain/history_domain.dart';

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
            hintText: AppTranslations.get('search_hint_global', lang),
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
              authorsAsync.valueOrNull ?? const [],
              worksAsync.valueOrNull ?? const [],
              historyAsync.valueOrNull ?? const [],
              lang,
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isPersian) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
            const SizedBox(height: 8),
            Text(
              isPersian
                  ? 'می‌توانید نام شاعران، عنوان شعرها، ضرب‌المثل‌ها و رویدادهای تاریخی را جستجو کنید.'
                  : 'Шумо метавонед номи шоирон, унвони шеърҳо, зарбулмасалҳо ва рӯйдодҳои таърихиро ҷустуҷӯ намоед.',
              textAlign: TextAlign.center,
              style: QalamTypography.bodySecondary(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    BuildContext context,
    List<Proverb> proverbs,
    List<LiteraryAuthor> authors,
    List<LiteraryWork> works,
    List<HistoryEntry> history,
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
        p.tajikCyrillic,
        p.persianText,
        p.meaningTj,
        p.simpleExplanationTj,
      ], _query);
    }).toList();

    final matchingHistory = history.where((h) {
      return SearchNormalizer.matchesAny([
        h.title,
        h.titlePersian ?? '',
        h.summary,
        h.summaryPersian ?? '',
        ...h.keywords,
        ...h.keyFigures,
        ...h.keyFiguresPersian,
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
          _buildSectionHeader(
            isPersian
                ? 'شاعران (${matchingAuthors.length})'
                : 'Шоирон (${matchingAuthors.length})',
            colors,
          ),
          for (final author in matchingAuthors)
            ListTile(
              leading: Icon(Icons.person_outline, color: colors.primary),
              title: Text(
                (isPersian && author.canonicalNamePersian != null)
                    ? author.canonicalNamePersian!
                    : author.canonicalName,
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: Text(
                author.literaryPeriod,
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
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
            isPersian
                ? 'شعرها و آثار (${matchingWorks.length})'
                : 'Шеърҳо ва осор (${matchingWorks.length})',
            colors,
          ),
          for (final work in matchingWorks)
            ListTile(
              leading: Icon(Icons.auto_stories_outlined, color: colors.primary),
              title: Text(
                (isPersian && work.titlePersian != null)
                    ? work.titlePersian!
                    : work.title,
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: work.incipit != null
                  ? Text(
                      work.incipit!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  : null,
              trailing: const Icon(Icons.chevron_right, size: 20),
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
            isPersian
                ? 'ضرب‌المثل‌ها (${matchingProverbs.length})'
                : 'Зарбулмасалҳо (${matchingProverbs.length})',
            colors,
          ),
          for (final proverb in matchingProverbs)
            ListTile(
              leading: Icon(Icons.menu_book_outlined, color: colors.primary),
              title: Text(
                isPersian
                    ? (proverb.persianText.isNotEmpty
                          ? proverb.persianText
                          : proverb.tajikCyrillic)
                    : proverb.tajikCyrillic,
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: Text(
                proverb.meaningTj,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: QalamTypography.meta(color: colors.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                ref
                    .read(recentActivityProvider.notifier)
                    .addActivity(
                      RecentActivity(
                        id: proverb.id,
                        type: RecentActivityType.proverb,
                        title: isPersian
                            ? (proverb.persianText.isNotEmpty
                                  ? proverb.persianText
                                  : proverb.tajikCyrillic)
                            : proverb.tajikCyrillic,
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
          _buildSectionHeader(
            isPersian
                ? 'تاریخ (${matchingHistory.length})'
                : 'Таърих (${matchingHistory.length})',
            colors,
          ),
          for (final entry in matchingHistory)
            ListTile(
              leading: Icon(Icons.timeline, color: colors.primary),
              title: Text(
                (isPersian && entry.titlePersian != null)
                    ? entry.titlePersian!
                    : entry.title,
                style: QalamTypography.body(color: colors.onSurface),
              ),
              subtitle: entry.dates != null
                  ? Text(
                      entry.dates!,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    )
                  : Text(
                      entry.period,
                      style: QalamTypography.meta(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
              trailing: const Icon(Icons.chevron_right, size: 20),
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
