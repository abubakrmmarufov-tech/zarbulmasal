import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _currentIndex = 0;
  List<Proverb> _flashcards = [];
  bool _showMeaning = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    final shuffled = List<Proverb>.from(ref.read(proverbsProvider))
      ..shuffle(Random());
    setState(() {
      _flashcards = shuffled.take(10).toList();
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final lang = ref.watch(displayLanguageProvider);
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
        child: empty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(QalamSpacing.pageH),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppTranslations.get('detail_no_proverbs', lang),
                        style: QalamTypography.sectionTitle(
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton(
                        onPressed: _back,
                        child: Text(AppTranslations.get('btn_return', lang)),
                      ),
                    ],
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final cardHeight = (constraints.maxHeight - 180).clamp(
                    320.0,
                    620.0,
                  );
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
                                  '${_currentIndex + 1}'.padLeft(2, '0'),
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
                                        '${_currentIndex + 1}',
                                        '${_flashcards.length}',
                                      ],
                                    ),
                                    style: QalamTypography.meta(
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: (_currentIndex + 1) / _flashcards.length,
                              color: colors.primary,
                              backgroundColor: colors.outlineVariant,
                              minHeight: 2,
                              semanticsLabel: AppTranslations.get(
                                'flashcards_title',
                                lang,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              height: cardHeight,
                              child: QalamFlashCard(
                                key: ValueKey(_flashcards[_currentIndex].id),
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
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: _currentIndex == 0
                                        ? null
                                        : () => _go(-1),
                                    child: Text(
                                      AppTranslations.get('btn_previous', lang),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed:
                                        _currentIndex == _flashcards.length - 1
                                        ? _loadCards
                                        : () => _go(1),
                                    child: Text(
                                      AppTranslations.get(
                                        _currentIndex == _flashcards.length - 1
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
    );
  }
}
