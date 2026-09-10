import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/l10n/app_translations.dart';
import '../../../shared/providers/app_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../data/literature_providers.dart';
import '../domain/oral_heritage_entry.dart';

/// A screen displaying verified folklore and oral literary heritage
/// of the Tajik people: proverbs, riddles, folk dubaytis, and folk rubais.
class OralHeritageScreen extends ConsumerStatefulWidget {
  const OralHeritageScreen({super.key});

  @override
  ConsumerState<OralHeritageScreen> createState() => _OralHeritageScreenState();
}

class _OralHeritageScreenState extends ConsumerState<OralHeritageScreen> {
  OralHeritageType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(displayLanguageProvider);
    final isPersian = lang == DisplayLanguage.persian;

    final oralAsync = ref.watch(oralHeritageProvider);

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
                eyebrow: isPersian ? '۰۴ / میراث شفاهی' : '04 / МЕРОСИ ШИФОҲӢ',
                title: AppTranslations.get('lit_oral', lang),
                subtitle: isPersian
                    ? 'ضرب‌المثل‌ها، چیستان‌ها، دوبیتی‌ها و ادبیات عامیانهٔ ضبط‌شده توسط دانشمندان فلکلور'
                    : 'Зарбулмасалҳо, чистонҳо, дубайтиҳо ва фолклори сабтшудаи мардуми тоҷик',
              ),
            ),
            // Genre Filter Chips
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text(isPersian ? 'همه' : 'Ҳама'),
                      selected: _selectedType == null,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedType = null);
                      },
                    ),
                    const SizedBox(width: 8),
                    for (final type in OralHeritageType.values) ...[
                      if (type != OralHeritageType.other) ...[
                        ChoiceChip(
                          label: Text(_typeName(type, isPersian)),
                          selected: _selectedType == type,
                          onSelected: (selected) {
                            setState(() {
                              _selectedType = selected ? type : null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),
            // List of entries
            oralAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: isPersian
                        ? 'خطا در بارگیری میراث شفاهی'
                        : 'Хато ҳангоми боргирӣ',
                    subtitle: err.toString(),
                  ),
                ),
              ),
              data: (entries) {
                final filtered = _selectedType == null
                    ? entries
                    : entries.where((e) => e.type == _selectedType).toList();

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: EmptyState(
                        icon: Icons.record_voice_over_outlined,
                        title: isPersian
                            ? 'نمونه‌ای یافت نشد'
                            : 'Намунае ёфт нашуд',
                        subtitle: isPersian
                            ? 'مدخل‌های ادبیات عامیانه در مرحلهٔ بررسی و مقابله با کتاب‌های فولکلور قرار دارند.'
                            : 'Намунаҳои фолклор дар марҳилаи санҷиш ва муқобала бо маҷмӯаҳои чопӣ қарор доранд.',
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final entry = filtered[index];
                      return _OralEntryCard(
                        entry: entry,
                        isPersian: isPersian,
                      );
                    },
                    childCount: filtered.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 48),
            ),
          ],
        ),
      ),
    );
  }

  String _typeName(OralHeritageType type, bool isPersian) {
    switch (type) {
      case OralHeritageType.zarbulmasal:
        return isPersian ? 'ضرب‌المثل' : 'Зарбулмасал';
      case OralHeritageType.maqol:
        return isPersian ? 'مقال' : 'Мақол';
      case OralHeritageType.chiston:
        return isPersian ? 'چیستان' : 'Чистон';
      case OralHeritageType.dubaytiKhalqi:
        return isPersian ? 'دوبیتی خلقی' : 'Дубайтии халқӣ';
      case OralHeritageType.rubaiKhalqi:
        return isPersian ? 'رباعی خلقی' : 'Рубоии халқӣ';
      case OralHeritageType.afsona:
        return isPersian ? 'افسانه' : 'Афсона';
      case OralHeritageType.other:
        return isPersian ? 'دیگر' : 'Дигар';
    }
  }
}

class _OralEntryCard extends StatelessWidget {
  final OralHeritageEntry entry;
  final bool isPersian;

  const _OralEntryCard({
    required this.entry,
    required this.isPersian,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final displayText = (isPersian &&
            entry.textPersian != null &&
            entry.textPersian!.isNotEmpty)
        ? entry.textPersian!
        : entry.text;

    final isRtl = isPersian;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: QalamSpacing.pageH,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: type, region, verification badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: colors.primary.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  entry.type.name,
                  style: QalamTypography.meta(
                    color: colors.primary,
                    fontSize: 11,
                  ),
                ),
              ),
              if (entry.region != null && entry.region!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '•  ${entry.region}',
                  style: QalamTypography.meta(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              if (entry.isVerified)
                const Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: QalamColors.forest,
                ),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 16),
                tooltip: isPersian ? 'کپی' : 'Нусхабардорӣ',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: displayText));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isPersian ? 'کپی شد' : 'Матн нусхабардорӣ шуд',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Folklore Text
          SelectableText(
            displayText,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: QalamTypography.heroProverb(
              color: colors.onSurface,
              fontSize: 20,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          // Citation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.book_outlined,
                size: 14,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  entry.citation,
                  style: QalamTypography.bodySecondary(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
