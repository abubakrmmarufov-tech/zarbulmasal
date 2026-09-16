import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../literature/data/literature_providers.dart';
import '../data/history_providers.dart';
import '../domain/history_domain.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final String entryId;

  const HistoryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;
    final entriesAsync = ref.watch(historyEntriesProvider);
    final booksAsync = ref.watch(historyBooksProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: isPersian ? 'بازگشت' : 'Бозгашт',
          icon: const BackButtonIcon(),
          onPressed: () => qalamBack(context),
        ),
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (entries) {
          final entry = entries.firstWhere(
            (e) => e.id == entryId,
            orElse: () => entries.first, // Fallback, shouldn't happen if routed correctly
          );

          if (entry.id != entryId) {
             return Center(child: Text(isPersian ? 'یافت نشد' : 'Ёфт нашуд'));
          }

          final books = booksAsync.valueOrNull ?? [];
          final sourceBook = books.where((b) => b.id == entry.sourceBookId).firstOrNull;

          final title = isPersian && entry.titlePersian != null
              ? entry.titlePersian!
              : entry.title;

          final summary = isPersian && entry.summaryPersian != null
              ? entry.summaryPersian!
              : entry.summary;

          final significance = isPersian && entry.significancePersian != null
              ? entry.significancePersian
              : entry.significance;

          final section = entry.sourceSection.isNotEmpty
              ? entry.sourceSection
              : (isPersian ? 'بخش نامعلوم' : 'Қисмати номаълум');

          final capital = isPersian && entry.capitalPersian != null
              ? entry.capitalPersian
              : entry.capital;

          final territory = isPersian && entry.territoryPersian != null
              ? entry.territoryPersian
              : entry.territory;

          final dates = isPersian && entry.datesPersian != null
              ? entry.datesPersian
              : entry.dates;

          final keyFigures = isPersian && entry.keyFiguresPersian.isNotEmpty
              ? entry.keyFiguresPersian
              : entry.keyFigures;

          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            _getIconForKind(entry.kind),
                            size: 24,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getKindLabel(entry.kind, isPersian),
                              style: QalamTypography.eyebrow(color: colors.primary),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isPersian
                                  ? 'صنف ${AppTranslations.formatDigits(entry.grade, DisplayLanguage.persian)}'
                                  : 'Синфи ${entry.grade}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colors.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: QalamTypography.pageTitle(
                          color: colors.onSurface,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.period,
                        style: QalamTypography.meta(
                          color: colors.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (dates != null || capital != null || territory != null || keyFigures.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: colors.outlineVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (dates != null && dates.isNotEmpty) ...[
                                _DetailRow(
                                  icon: Icons.calendar_today,
                                  label: isPersian ? 'دورهٔ زمانی' : 'Давраи замонӣ',
                                  value: dates,
                                ),
                              ],
                              if (capital != null && capital.isNotEmpty) ...[
                                if (dates != null && dates.isNotEmpty)
                                  const Divider(height: 16),
                                _DetailRow(
                                  icon: Icons.location_city,
                                  label: isPersian ? 'پایتخت' : 'Пойтахт',
                                  value: capital,
                                ),
                              ],
                              if (territory != null && territory.isNotEmpty) ...[
                                if ((dates != null && dates.isNotEmpty) ||
                                    (capital != null && capital.isNotEmpty))
                                  const Divider(height: 16),
                                _DetailRow(
                                  icon: Icons.map,
                                  label: isPersian ? 'قلمرو' : 'Қаламрав',
                                  value: territory,
                                ),
                              ],
                              if (keyFigures.isNotEmpty) ...[
                                if ((capital != null && capital.isNotEmpty) ||
                                    (territory != null && territory.isNotEmpty) ||
                                    (dates != null && dates.isNotEmpty))
                                  const Divider(height: 16),
                                _DetailRow(
                                  icon: Icons.people_outline,
                                  label: isPersian ? 'چهره‌ها و حکمرانان' : 'Чеҳраҳо ва ҳукмронон',
                                  value: keyFigures.join(', '),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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
                        ),
                      ),
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
                            height: 1.6,
                          ),
                        ),
                      ],
                      if (entry.relatedAuthorIds.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          isPersian ? 'شاعران و ادبان وابسته' : 'Шоирон ва адибони пайвандӣ',
                          style: QalamTypography.eyebrow(color: colors.primary),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: entry.relatedAuthorIds.map((authorId) {
                            final authorAsync = ref.watch(authorByIdProvider(authorId));
                            final author = authorAsync.valueOrNull;
                            final authorName = author != null
                                ? ((isPersian && author.canonicalNamePersian != null)
                                      ? author.canonicalNamePersian!
                                      : author.canonicalName)
                                : (authorId == 'rudaki'
                                      ? (isPersian ? 'ابوعبدالله رودکی' : 'Абӯабдуллоҳи Рӯдакӣ')
                                      : authorId);
                            return ActionChip(
                              avatar: const Icon(Icons.auto_stories_outlined, size: 16),
                              label: Text(authorName),
                              onPressed: () {
                                context.push('/literature/poet/$authorId');
                              },
                            );
                          }).toList(),
                        ),
                      ],
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colors.outlineVariant),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.menu_book, size: 18, color: colors.primary),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isPersian
                                        ? 'منبع مستند: کتاب درسی تاریخ خلق تاجیک'
                                        : 'Сарчашмаи таълимӣ: Китоби дарсии «Таърихи халқи тоҷик»',
                                    style: QalamTypography.eyebrow(color: colors.primary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isPersian
                                  ? 'صنف ${AppTranslations.formatDigits(entry.grade, DisplayLanguage.persian)} · $section'
                                  : 'Синфи ${entry.grade} · $section',
                              style: QalamTypography.meta(color: colors.onSurface),
                            ),
                            if (sourceBook != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                '${sourceBook.title} (${sourceBook.author})',
                                style: QalamTypography.meta(color: colors.onSurfaceVariant),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 48), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForKind(HistoryEntryKind kind) {
    return switch (kind) {
      HistoryEntryKind.empire => Icons.account_balance,
      HistoryEntryKind.person => Icons.person,
      HistoryEntryKind.event => Icons.event,
      HistoryEntryKind.place => Icons.place,
      HistoryEntryKind.poem => Icons.menu_book,
      HistoryEntryKind.oral => Icons.record_voice_over,
    };
  }

  String _getKindLabel(HistoryEntryKind kind, bool isPersian) {
    if (isPersian) {
      return switch (kind) {
        HistoryEntryKind.empire => 'دولت و امپراتوری',
        HistoryEntryKind.person => 'شخصیت تاریخی',
        HistoryEntryKind.event => 'رویداد تاریخی',
        HistoryEntryKind.place => 'جایگاه تاریخی',
        HistoryEntryKind.poem => 'شاعر و شعر',
        HistoryEntryKind.oral => 'روایت شفاهی',
      };
    }
    return switch (kind) {
      HistoryEntryKind.empire => 'ДАВЛАТ ВА ИМПЕРИЯ',
      HistoryEntryKind.person => 'ШАХСИЯТИ ТАЪРИХӢ',
      HistoryEntryKind.event => 'ВОҚЕАИ ТАЪРИХӢ',
      HistoryEntryKind.place => 'ҶОЙИ ТАЪРИХӢ',
      HistoryEntryKind.poem => 'ШОИР ВА ШЕЪР',
      HistoryEntryKind.oral => 'РИВОЯТИ ШИФОҲӢ',
    };
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
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
        Icon(icon, size: 16, color: colors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: colors.onSurface,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 13, color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
