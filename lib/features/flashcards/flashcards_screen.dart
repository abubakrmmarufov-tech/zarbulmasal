import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/l10n/app_translations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/pamir_silhouette.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _currentIndex = 0;
  List<dynamic> _flashcards = [];
  bool _showMeaning = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() {
    final proverbs = ref.read(proverbsProvider);
    final shuffled = List.from(proverbs)..shuffle(Random());
    setState(() {
      _flashcards = shuffled.take(10).toList();
      _currentIndex = 0;
      _showMeaning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final displayLang = ref.watch(displayLanguageProvider);
    final isPersian = displayLang == DisplayLanguage.persian;

    if (_flashcards.isEmpty) {
      return Scaffold(
        body: Column(
          children: [
            _buildTopBar(context, displayLang),
            Expanded(
              child: Center(
                child: Text(
                  AppTranslations.get('flashcards_loading', displayLang),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final proverb = _flashcards[_currentIndex];
    final isLast = _currentIndex == _flashcards.length - 1;
    final isFirst = _currentIndex == 0;

    return Scaffold(
      body: Column(
        children: [
          _buildTopBar(context, displayLang),
          PamirSilhouette(
            height: 24,
            darkMode: Theme.of(context).brightness == Brightness.dark,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _flashcards.length,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _showMeaning = !_showMeaning),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: colorScheme.surface,
                          border: Border.all(
                            color: AppColors.accentGold.withValues(alpha: 0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: _showMeaning
                            ? SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF166534).withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb,
                                        size: 36,
                                        color: Color(0xFF166534),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      AppTranslations.get('flashcards_meaning', displayLang),
                                      style: TextStyle(
                                        fontFamily: 'NotoSans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      proverb.meaningTj,
                                      style: TextStyle(
                                        fontFamily: 'NotoSerif',
                                        fontSize: 18,
                                        height: 1.7,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      AppTranslations.get('flashcards_explanation', displayLang),
                                      style: TextStyle(
                                        fontFamily: 'NotoSans',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      proverb.simpleExplanationTj,
                                      style: TextStyle(
                                        fontFamily: 'NotoSans',
                                        fontSize: 16,
                                        height: 1.7,
                                        color: colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 28),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.touch_app,
                                          size: 16,
                                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            AppTranslations.get('flashcards_tap_to_hide', displayLang),
                                            style: TextStyle(
                                              fontFamily: 'NotoSans',
                                              fontSize: 13,
                                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.touch_app,
                                    size: 40,
                                    color: AppColors.accentGold.withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isPersian ? proverb.persianText : proverb.tajikCyrillic,
                                    style: TextStyle(
                                      fontFamily: 'NotoSerif',
                                      fontSize: 22,
                                      height: 1.7,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: isPersian ? TextDirection.rtl : TextDirection.ltr,
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    isPersian ? proverb.tajikCyrillic : proverb.persianText,
                                    style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      fontSize: 17,
                                      fontStyle: FontStyle.italic,
                                      height: 1.5,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                    textDirection: isPersian ? TextDirection.ltr : TextDirection.rtl,
                                  ),
                                  const SizedBox(height: 28),
                                  SizedBox(
                                    height: 52,
                                    child: ElevatedButton.icon(
                                      onPressed: () => setState(() => _showMeaning = true),
                                      icon: const Icon(Icons.visibility),
                                      label: Text(AppTranslations.get('btn_show_meaning', displayLang)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.accentGold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: isFirst
                                ? null
                                : () {
                                    setState(() {
                                      _currentIndex--;
                                      _showMeaning = false;
                                    });
                                  },
                            icon: const Icon(Icons.arrow_back),
                            label: Text(AppTranslations.get('btn_previous', displayLang)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: isLast
                                ? _loadCards
                                : () {
                                    setState(() {
                                      _currentIndex++;
                                      _showMeaning = false;
                                    });
                                  },
                            icon: Icon(isLast ? Icons.replay : Icons.arrow_forward),
                            label: Text(
                              isLast
                                  ? AppTranslations.get('btn_start_over', displayLang)
                                  : AppTranslations.get('btn_next', displayLang),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGold,
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
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, DisplayLanguage displayLang) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardOf = AppTranslations.get(
      'flashcards_card_of',
      displayLang,
      [(_currentIndex + 1).toString(), _flashcards.isEmpty ? '0' : _flashcards.length.toString()],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.12),
            colorScheme.primary.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/'),
                tooltip: AppTranslations.get('btn_back_home', displayLang),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppTranslations.get('flashcards_title', displayLang),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: 'NotoSerif',
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      cardOf,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
