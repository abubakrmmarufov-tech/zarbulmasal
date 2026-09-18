import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/providers/recent_activity_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../literature/data/literature_providers.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';

/// Full-screen detail view for a specific historical entry (dynasty, person, event, or site).
class HistoryDetailScreen extends ConsumerWidget {
  final String entryId;

  const HistoryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final entryAsync = ref.watch(historyEntryByIdProvider(entryId));
    final booksAsync = ref.watch(historyBooksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPersian ? 'شناسنامهٔ تاریخی' : 'Шиносномаи таърихӣ',
          style: QalamTypography.sectionTitle(
            color: colors.onSurface,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/history');
            }
          },
        ),
      ),
      body: entryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: isPersian
                ? 'خطا در بارگیری مدخل'
                : 'Хато дар боргирии маълумот',
            subtitle: err.toString(),
            action: OutlinedButton(
              onPressed: () =>
                  ref.invalidate(historyEntryByIdProvider(entryId)),
              child: Text(isPersian ? 'تلاش مجدد' : 'Кӯшиши дубора'),
            ),
          ),
        ),
        data: (entry) {
          if (entry == null) {
            return Center(
              child: EmptyState(
                icon: Icons.search_off,
                title: isPersian
                    ? 'مدخل تاریخی یافت نشد'
                    : 'Маълумот ёфт нашуд',
                subtitle: isPersian
                    ? 'این مدخل در مجموعهٔ تاریخی برنامه موجود نیست.'
                    : 'Ин маълумот дар сабтҳои таърихӣ вуҷуд надорад.',
                action: OutlinedButton(
                  onPressed: () => context.go('/history'),
                  child: Text(
                    isPersian ? 'بازگشت به تاریخ' : 'Бозгашт ба таърих',
                  ),
                ),
              ),
            );
          }

          final books = booksAsync.valueOrNull ?? [];
          final sourceBook = books
              .where((b) => b.id == entry.sourceBookId)
              .firstOrNull;

          final title = isPersian && entry.titlePersian != null
              ? entry.titlePersian!
              : entry.title;
          final summary = isPersian && entry.summaryPersian != null
              ? entry.summaryPersian!
              : entry.summary;
          final dates = isPersian && entry.datesPersian != null
              ? entry.datesPersian!
              : (entry.dates ?? entry.period);
          final capital = isPersian && entry.capitalPersian != null
              ? entry.capitalPersian
              : entry.capital;
          final territory = isPersian && entry.territoryPersian != null
              ? entry.territoryPersian
              : entry.territory;
          final significance = isPersian && entry.significancePersian != null
              ? entry.significancePersian
              : entry.significance;
          final keyFigures = isPersian && entry.keyFiguresPersian.isNotEmpty
              ? entry.keyFiguresPersian
              : entry.keyFigures;
          final section = entry.sourceSection;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref
                .read(recentActivityProvider.notifier)
                .addActivity(
                  RecentActivity(
                    id: entry.id,
                    type: RecentActivityType.history,
                    title: isPersian && entry.titlePersian != null
                        ? entry.titlePersian!
                        : entry.title,
                    subtitle: isPersian ? 'تاریخ' : 'Таърих',
                    timestamp: DateTime.now(),
                    route: '/history/${entry.id}',
                  ),
                );
          });

          return Directionality(
            textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              children: [
                // Kind badge & Grade Chip
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _iconForKind(entry.kind),
                            size: 16,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _kindLabel(entry.kind, isPersian),
                            style: QalamTypography.eyebrow(
                              color: colors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPersian
                            ? 'صنف ${AppTranslations.formatDigits(entry.grade, lang)}'
                            : 'Синфи ${entry.grade}',
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: QalamTypography.pageTitle(
                    color: colors.onSurface,
                    fontSize: 26,
                  ),
                ),
                if (dates.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 18, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dates,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 20),
                // Capital, Territory, Key Figures
                if ((capital != null && capital.isNotEmpty) ||
                    (territory != null && territory.isNotEmpty) ||
                    keyFigures.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius: BorderRadius.circular(
                        QalamSpacing.cardRadius,
                      ),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.6),
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (capital != null && capital.isNotEmpty) ...[
                          _DetailLine(
                            icon: Icons.location_city,
                            label: isPersian ? 'پایتخت' : 'Пойтахт',
                            value: capital,
                          ),
                        ],
                        if (territory != null && territory.isNotEmpty) ...[
                          if (capital != null && capital.isNotEmpty)
                            const Divider(height: 20),
                          _DetailLine(
                            icon: Icons.public,
                            label: isPersian ? 'قلمرو' : 'Ҳудуд',
                            value: territory,
                          ),
                        ],
                        if (keyFigures.isNotEmpty) ...[
                          if ((capital != null && capital.isNotEmpty) ||
                              (territory != null && territory.isNotEmpty))
                            const Divider(height: 20),
                          _DetailLine(
                            icon: Icons.people_outline,
                            label: isPersian
                                ? 'چهره‌ها و حکمرانان'
                                : 'Чеҳраҳо ва ҳукмронон',
                            value: keyFigures.join(', '),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                // Historical Summary
                Text(
                  isPersian ? 'خلاصهٔ تاریخی' : 'Хулосаи таърихӣ',
                  style: QalamTypography.eyebrow(color: colors.primary),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  style: QalamTypography.body(
                    color: colors.onSurface,
                    height: 1.6,
                    fontSize: 16,
                  ),
                ),
                // Historical Significance
                if (significance != null && significance.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    isPersian ? 'اهمیت تاریخی' : 'Аҳамияти таърихӣ',
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    significance,
                    style: QalamTypography.bodySecondary(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                      fontSize: 15,
                    ),
                  ),
                ],
                // Related Poets
                if (entry.relatedAuthorIds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    isPersian
                        ? 'شاعران و ادیبان هم‌دوره'
                        : 'Шоирон ва адибони ҳамдавр',
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.relatedAuthorIds.map((authorId) {
                          final authorAsync = ref.watch(
                            authorByIdProvider(authorId),
                          );
                          final author = authorAsync.valueOrNull;
                          final authorName = author != null
                              ? ((isPersian &&
                                        author.canonicalNamePersian != null)
                                    ? author.canonicalNamePersian!
                                    : author.canonicalName)
                              : (authorId == 'rudaki'
                                    ? (isPersian
                                          ? 'ابوعبدالله رودکی'
                                          : 'Абӯабдуллоҳи Рӯдакӣ')
                                    : authorId);
                          return ActionChip(
                            avatar: const Icon(Icons.auto_stories, size: 16),
                            label: Text(authorName),
                            onPressed: () {
                              context.push('/literature/poet/$authorId');
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
                // Related Works
                if (entry.relatedWorkIds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    isPersian ? 'آثار ادبی مرتبط' : 'Осори адабии пайвандӣ',
                    style: QalamTypography.eyebrow(color: colors.primary),
                  ),
                  const SizedBox(height: 10),
                  Consumer(
                    builder: (context, ref, _) {
                      final approvedWorks =
                          ref.watch(approvedWorksProvider).valueOrNull ?? [];
                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entry.relatedWorkIds.map((workId) {
                          final matched = approvedWorks
                              .where((w) => w.id == workId)
                              .firstOrNull;
                          final workTitle = matched != null
                              ? (isPersian && matched.titlePersian != null
                                    ? matched.titlePersian!
                                    : matched.title)
                              : (workId == 'poem-shahnameh'
                                    ? (isPersian ? 'شاهنامه' : 'Шоҳнома')
                                    : workId);
                          return ActionChip(
                            avatar: const Icon(Icons.menu_book, size: 16),
                            label: Text(workTitle),
                            onPressed: () {
                              if (matched != null) {
                                context.push('/literature/work/${matched.id}');
                              } else {
                                context.push('/literature/works');
                              }
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 28),
                // Official Source Card with Website Launcher
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(
                      QalamSpacing.cardRadius,
                    ),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isPersian
                                  ? 'منبع مستند: کتاب درسی تاریخ халқи тоҷик'
                                  : 'Сарчашмаи таълимӣ: Китоби дарсии «Таърихи халқи тоҷик»',
                              style: QalamTypography.eyebrow(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isPersian
                            ? 'صنف ${AppTranslations.formatDigits(entry.grade, lang)} · $section'
                            : 'Синфи ${entry.grade} · $section',
                        style: QalamTypography.sectionTitle(
                          color: colors.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      if (sourceBook != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${sourceBook.title} (${sourceBook.author})',
                          style: QalamTypography.meta(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        if (sourceBook.sourceUrl.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                            ),
                            icon: const Icon(Icons.open_in_browser, size: 20),
                            label: Text(
                              isPersian
                                  ? 'ورود به وبگاه رسمی کتاب (marifat.tj)'
                                  : 'Мутолиа дар сомонаи расмӣ (marifat.tj)',
                            ),
                            onPressed: () async {
                              final uri = Uri.parse(sourceBook.sourceUrl);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static IconData _iconForKind(HistoryEntryKind kind) => switch (kind) {
    HistoryEntryKind.empire => Icons.account_balance,
    HistoryEntryKind.person => Icons.person,
    HistoryEntryKind.event => Icons.event,
    HistoryEntryKind.place => Icons.location_on,
    HistoryEntryKind.poem => Icons.auto_stories,
    HistoryEntryKind.oral => Icons.record_voice_over,
  };

  static String _kindLabel(
    HistoryEntryKind kind,
    bool isPersian,
  ) => switch (kind) {
    HistoryEntryKind.empire => isPersian ? 'دولت و سلسله' : 'Давлат ва силсила',
    HistoryEntryKind.person => isPersian ? 'شخصیت تاریخی' : 'Шахсияти таърихӣ',
    HistoryEntryKind.event => isPersian ? 'رویداد تاریخی' : 'Рӯйдоди таърихӣ',
    HistoryEntryKind.place => isPersian ? 'مکان تاریخی' : 'Макони таърихӣ',
    HistoryEntryKind.poem => isPersian ? 'میراث ادبی' : 'Мероси адабӣ',
    HistoryEntryKind.oral => isPersian ? 'روایت شفاهی' : 'Ривояти шифоҳӣ',
  };
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: QalamTypography.meta(color: colors.primary, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: QalamTypography.body(color: colors.onSurface, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
