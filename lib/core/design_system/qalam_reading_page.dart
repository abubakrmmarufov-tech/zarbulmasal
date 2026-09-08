import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'design_system.dart';
import '../l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/empty_state.dart';

/// A shared, script-aware reading page for the daily and collection routes.
class QalamReadingPage extends ConsumerWidget {
  final Proverb? proverb;
  final bool daily;
  const QalamReadingPage({
    super.key,
    required this.proverb,
    this.daily = false,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final persian = lang == DisplayLanguage.persian;
    final p = proverb;
    String tr(String key) => AppTranslations.get(key, lang);
    final categories = ref.watch(categoriesProvider);
    final matches = categories.where((c) => c.id == p?.categoryId);
    final category = matches.isEmpty
        ? tr('detail_unknown')
        : QalamCategoryTile.nameFor(matches.first, lang);
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: tr('back'),
          onPressed: () => qalamBack(context),
          icon: const BackButtonIcon(),
        ),
        title: Text(daily ? tr('daily_title') : tr('home_edition')),
        actions: [
          if (p != null) ...[
            IconButton(
              tooltip: tr('copy_proverb'),
              icon: const Icon(Icons.copy_outlined, size: 21),
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(
                    text:
                        '${p.tajikCyrillic}\n${p.persianText}\n\n${p.meaningTj}',
                  ),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(tr('copied'))));
                }
              },
            ),
            QalamBookmark(proverbId: p.id),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: p == null
          ? SingleChildScrollView(
              child: EmptyState(
                icon: Icons.menu_book_outlined,
                title: tr(daily ? 'daily_not_available' : 'detail_loading'),
                action: OutlinedButton(
                  onPressed: () => qalamBack(context),
                  child: Text(tr('btn_return')),
                ),
              ),
            )
          : SafeArea(
              top: false,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  daily
                                      ? '${now.day} ${AppTranslations.getMonthName(now.month, lang)} / ${now.year}'
                                      : category,
                                  style: QalamTypography.eyebrow(
                                    color: colors.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                p.id
                                    .replaceAll(RegExp(r'[^0-9]'), '')
                                    .padLeft(3, '0'),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          const Divider(),
                          const SizedBox(height: 32),
                          SelectableText(
                            persian ? p.persianText : p.tajikCyrillic,
                            semanticsLabel: persian
                                ? p.persianText
                                : p.tajikCyrillic,
                            textDirection: persian
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            style: QalamTypography.heroProverb(
                              color: colors.onSurface,
                              fontSize: 35,
                              height: 1.42,
                            ),
                          ),
                          const SizedBox(height: 26),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Container(
                              width: 36,
                              height: 3,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          SelectableText(
                            persian ? p.tajikCyrillic : p.persianText,
                            semanticsLabel: persian
                                ? p.tajikCyrillic
                                : p.persianText,
                            textDirection: persian
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            style: QalamTypography.heroProverb(
                              color: colors.onSurfaceVariant,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Text(
                            tr('reading_script'),
                            style: QalamTypography.meta(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const QalamScriptSwitch(),
                          const SizedBox(height: 28),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              Text(
                                category,
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                AppTranslations.get('badges_level', lang, [
                                  p.level,
                                ]),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                tr(
                                  p.type == ProverbType.traditional
                                      ? 'badges_traditional'
                                      : 'badges_modern',
                                ),
                                style: QalamTypography.meta(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (p.meaningTj.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: '01',
                        title: tr('detail_meaning'),
                        text: p.meaningTj,
                        emphasis: true,
                      ),
                    ),
                  if (p.simpleExplanationTj.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: '02',
                        title: tr('detail_simple_explanation'),
                        text: p.simpleExplanationTj,
                      ),
                    ),
                  if (p.exampleSentenceTj.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _ReadingSection(
                        number: '03',
                        title: tr('detail_example'),
                        text: p.exampleSentenceTj,
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Divider(),
                          const SizedBox(height: 22),
                          Text(
                            tr('detail_source'),
                            style: QalamTypography.eyebrow(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            tr(
                              p.sourceStatus == SourceStatus.verified
                                  ? 'badges_verified'
                                  : 'source_unverified',
                            ),
                            style: QalamTypography.bodySecondary(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          if (p.sourceNote.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              p.sourceNote,
                              textDirection: TextDirection.ltr,
                              style: QalamTypography.bodySecondary(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ReadingSection extends StatelessWidget {
  final String number;
  final String title;
  final String text;
  final bool emphasis;
  const _ReadingSection({
    required this.number,
    required this.title,
    required this.text,
    this.emphasis = false,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: emphasis ? colors.surfaceContainerHighest : null,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$number / $title',
            style: QalamTypography.eyebrow(color: colors.primary),
          ),
          const SizedBox(height: 18),
          SelectableText(
            text,
            semanticsLabel: text,
            textDirection: TextDirection.ltr,
            style: emphasis
                ? QalamTypography.heroProverb(
                    color: colors.onSurface,
                    fontSize: 23,
                    fontWeight: FontWeight.w400,
                  )
                : QalamTypography.body(
                    color: colors.onSurface,
                    fontSize: 17,
                    height: 1.8,
                  ),
          ),
        ],
      ),
    );
  }
}
