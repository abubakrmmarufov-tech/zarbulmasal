import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../data/models/learning_mastery.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/providers/learning_providers.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _currentIndex = 0;
  List<Proverb> _flashcards = [];
  bool _showMeaning = false;
  MasteryFilter _activeFilter = MasteryFilter.all;

  @override
  void initState() {
    super.initState();
    _activeFilter = ref.read(flashcardsFilterProvider);
    _loadCards(_activeFilter);
  }

  void _loadCards([MasteryFilter? filter]) {
    final targetFilter = filter ?? _activeFilter;
    if (ref.read(flashcardsFilterProvider) != targetFilter) {
      ref.read(flashcardsFilterProvider.notifier).state = targetFilter;
    }
    final allProverbs = ref.read(proverbsProvider);
    final masteryMap = ref.read(proverbMasteryProvider);

    List<Proverb> pool;
    switch (targetFilter) {
      case MasteryFilter.all:
        pool = List<Proverb>.from(allProverbs)..shuffle(Random());
        break;
      case MasteryFilter.again:
        pool =
            allProverbs
                .where((p) => masteryMap[p.id]?.level == MasteryLevel.again)
                .toList()
              ..shuffle(Random());
        break;
      case MasteryFilter.learning:
        pool =
            allProverbs
                .where((p) => masteryMap[p.id]?.level == MasteryLevel.learning)
                .toList()
              ..shuffle(Random());
        break;
      case MasteryFilter.mastered:
        pool =
            allProverbs
                .where((p) => masteryMap[p.id]?.level == MasteryLevel.mastered)
                .toList()
              ..shuffle(Random());
        break;
    }

    setState(() {
      _activeFilter = targetFilter;
      _flashcards = pool.take(15).toList();
      _currentIndex = 0;
      _showMeaning = false;
    });
  }

  void _go(int delta) {
    final next = _currentIndex + delta;
    if (next < 0 || next >= _flashcards.length) return;
    setState(() {
      _currentIndex = next;
      _showMeaning = false;
    });
  }

  void _back() => context.canPop() ? context.pop() : context.go('/');

  Future<void> _rateCard(
    MasteryLevel level,
    String translationKey,
    DisplayLanguage lang,
  ) async {
    if (_flashcards.isEmpty || _currentIndex >= _flashcards.length) return;
    final proverb = _flashcards[_currentIndex];
    await ref
        .read(proverbMasteryProvider.notifier)
        .recordReview(
          proverb.id,
          level,
          isCorrect: level == MasteryLevel.mastered,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppTranslations.get(translationKey, lang)),
        duration: const Duration(milliseconds: 800),
      ),
    );
    _go(1);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
    final stats = ref.watch(masteryStatsProvider);
    final masteryMap = ref.watch(proverbMasteryProvider);
    final persian = lang == DisplayLanguage.persian;
    final empty = _flashcards.isEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_return', lang),
          onPressed: _back,
          icon: const BackButtonIcon(),
        ),
        title: Text(AppTranslations.get('flashcards_title', lang)),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _filterChip(
                    label: AppTranslations.get('flashcards_filter_all', lang),
                    count: stats.totalProverbs,
                    filter: MasteryFilter.all,
                    colors: colors,
                    lang: lang,
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: AppTranslations.get('flashcards_filter_again', lang),
                    count: stats.againCount,
                    filter: MasteryFilter.again,
                    colors: colors,
                    lang: lang,
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: AppTranslations.get(
                      'flashcards_filter_learning',
                      lang,
                    ),
                    count: stats.learningCount,
                    filter: MasteryFilter.learning,
                    colors: colors,
                    lang: lang,
                  ),
                  const SizedBox(width: 8),
                  _filterChip(
                    label: AppTranslations.get(
                      'flashcards_filter_mastered',
                      lang,
                    ),
                    count: stats.masteredCount,
                    filter: MasteryFilter.mastered,
                    colors: colors,
                    lang: lang,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: empty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(QalamSpacing.pageH),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _activeFilter == MasteryFilter.all
                                  ? AppTranslations.get(
                                      'detail_no_proverbs',
                                      lang,
                                    )
                                  : AppTranslations.get(
                                      'flashcards_empty_filter',
                                      lang,
                                    ),
                              textAlign: TextAlign.center,
                              style: QalamTypography.sectionTitle(
                                color: colors.onSurface,
                              ),
                            ),
                            if (_activeFilter != MasteryFilter.all) ...[
                              const SizedBox(height: 8),
                              Text(
                                AppTranslations.get(
                                  'flashcards_empty_hint',
                                  lang,
                                ),
                                textAlign: TextAlign.center,
                                style: QalamTypography.bodySecondary(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            OutlinedButton(
                              onPressed: _activeFilter == MasteryFilter.all
                                  ? _back
                                  : () => _loadCards(MasteryFilter.all),
                              child: Text(
                                _activeFilter == MasteryFilter.all
                                    ? AppTranslations.get('btn_return', lang)
                                    : AppTranslations.get(
                                        'flashcards_filter_all',
                                        lang,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final currentProverb = _flashcards[_currentIndex];
                        final currentMastery =
                            masteryMap[currentProverb.id]?.level ??
                            MasteryLevel.unseen;
                        final cardHeight =
                            (constraints.maxHeight - (_showMeaning ? 250 : 180))
                                .clamp(240.0, 560.0);

                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            QalamSpacing.pageH,
                            8,
                            QalamSpacing.pageH,
                            24,
                          ),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 640),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppTranslations.formatDigits(
                                          '${_currentIndex + 1}'.padLeft(
                                            2,
                                            '0',
                                          ),
                                          lang,
                                        ),
                                        style: QalamTypography.pageTitle(
                                          color: colors.primary,
                                          fontSize: 40,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          AppTranslations.get(
                                            'flashcards_card_of',
                                            lang,
                                            [
                                              AppTranslations.formatDigits(
                                                '${_currentIndex + 1}',
                                                lang,
                                              ),
                                              AppTranslations.formatDigits(
                                                '${_flashcards.length}',
                                                lang,
                                              ),
                                            ],
                                          ),
                                          style: QalamTypography.meta(
                                            color: colors.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      if (currentMastery !=
                                          MasteryLevel.unseen) ...[
                                        _masteryBadge(
                                          currentMastery,
                                          colors,
                                          lang,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value:
                                        (_currentIndex + 1) /
                                        _flashcards.length,
                                    color: colors.primary,
                                    backgroundColor: colors.outlineVariant,
                                    minHeight: 2,
                                    semanticsLabel: AppTranslations.get(
                                      'flashcards_title',
                                      lang,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    height: cardHeight,
                                    child: QalamFlashCard(
                                      key: ValueKey(
                                        _flashcards[_currentIndex].id,
                                      ),
                                      proverb: _flashcards[_currentIndex],
                                      isPersian: persian,
                                      showMeaning: _showMeaning,
                                      onTap: () => setState(
                                        () => _showMeaning = !_showMeaning,
                                      ),
                                      onSwipeLeft: () => _go(-1),
                                      onSwipeRight: () => _go(1),
                                    ),
                                  ),
                                  if (_showMeaning) ...[
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: colors.error,
                                              side: BorderSide(
                                                color: colors.error.withValues(
                                                  alpha: 0.5,
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                            ),
                                            onPressed: () => _rateCard(
                                              MasteryLevel.again,
                                              'flashcard_mastery_again',
                                              lang,
                                            ),
                                            child: Text(
                                              AppTranslations.get(
                                                'flashcard_mastery_again',
                                                lang,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: colors.primary,
                                              side: BorderSide(
                                                color: colors.primary
                                                    .withValues(alpha: 0.5),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                            ),
                                            onPressed: () => _rateCard(
                                              MasteryLevel.learning,
                                              'flashcard_mastery_learning',
                                              lang,
                                            ),
                                            child: Text(
                                              AppTranslations.get(
                                                'flashcard_mastery_learning',
                                                lang,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: const Color(
                                                0xFF2E6B34,
                                              ),
                                              side: const BorderSide(
                                                color: Color(0xFF2E6B34),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                  ),
                                            ),
                                            onPressed: () => _rateCard(
                                              MasteryLevel.mastered,
                                              'flashcard_mastery_mastered',
                                              lang,
                                            ),
                                            child: Text(
                                              AppTranslations.get(
                                                'flashcard_mastery_mastered',
                                                lang,
                                              ),
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: _currentIndex == 0
                                              ? null
                                              : () => _go(-1),
                                          child: Text(
                                            AppTranslations.get(
                                              'btn_previous',
                                              lang,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed:
                                              _currentIndex ==
                                                  _flashcards.length - 1
                                              ? () => _loadCards()
                                              : () => _go(1),
                                          child: Text(
                                            AppTranslations.get(
                                              _currentIndex ==
                                                      _flashcards.length - 1
                                                  ? 'btn_start_over'
                                                  : 'btn_next',
                                              lang,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip({
    required String label,
    required int count,
    required MasteryFilter filter,
    required ColorScheme colors,
    required DisplayLanguage lang,
  }) {
    final selected = _activeFilter == filter;
    final countFormatted = AppTranslations.formatDigits('$count', lang);
    return ChoiceChip(
      selected: selected,
      label: Text('$label ($countFormatted)'),
      onSelected: (_) => _loadCards(filter),
      selectedColor: colors.primaryContainer,
      labelStyle: TextStyle(
        color: selected ? colors.onPrimaryContainer : colors.onSurface,
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _masteryBadge(
    MasteryLevel level,
    ColorScheme colors,
    DisplayLanguage lang,
  ) {
    Color bg;
    Color fg;
    String text;
    switch (level) {
      case MasteryLevel.mastered:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E6B34);
        text = AppTranslations.get('flashcard_mastery_mastered', lang);
        break;
      case MasteryLevel.learning:
        bg = colors.primaryContainer;
        fg = colors.onPrimaryContainer;
        text = AppTranslations.get('flashcard_mastery_learning', lang);
        break;
      case MasteryLevel.again:
        bg = const Color(0xFFFFEBEE);
        fg = colors.error;
        text = AppTranslations.get('flashcard_mastery_again', lang);
        break;
      case MasteryLevel.unseen:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
