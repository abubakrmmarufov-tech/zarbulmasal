import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/cultural_header.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  List<Proverb> _quizProverbs = [];
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    final proverbs = ref.read(proverbsProvider);
    final shuffled = List<Proverb>.from(proverbs)..shuffle(Random());
    setState(() {
      _quizProverbs = shuffled.take(5).toList();
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _correctCount = 0;
    });
  }

  List<String> _getAnswerOptions(Proverb proverb, List<Proverb> allProverbs) {
    final correct = proverb.meaningTj;
    final others = allProverbs
        .where((p) => p.id != proverb.id)
        .map((p) => p.meaningTj)
        .toList()
      ..shuffle(Random());
    final options = [correct, ...others.take(3)];
    options.shuffle(Random());
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allProverbs = ref.watch(proverbsProvider);

    if (_quizProverbs.isEmpty) {
      return const Scaffold(
        body: CulturalHeader(title: 'Квиз', subtitle: 'Загрузка...'),
      );
    }

    final currentProverb = _quizProverbs[_currentIndex];
    final options = _getAnswerOptions(currentProverb, allProverbs);
    final isLast = _currentIndex == _quizProverbs.length - 1;

    return Scaffold(
      body: Column(
        children: [
          CulturalHeader(
            title: 'Квиз',
            subtitle: 'Савол ${_currentIndex + 1} аз ${_quizProverbs.length}',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: (_currentIndex + 1) / _quizProverbs.length,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    color: AppColors.accentGold,
                  ),
                  const SizedBox(height: 20),

                  // Proverb question card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: colorScheme.surface,
                      border: Border.all(
                        color: AppColors.accentGold.withValues(alpha: 0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_quote,
                          size: 36,
                          color: AppColors.accentGold.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          currentProverb.tajikCyrillic,
                          style: TextStyle(
                            fontFamily: 'NotoSerif',
                            fontSize: 20,
                            height: 1.6,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          currentProverb.persianText,
                          style: TextStyle(
                            fontFamily: 'NotoSans',
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text(
                    'Маънои дурустро интихоб кунед:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 15,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...options.asMap().entries.map((entry) {
                    final option = entry.value;
                    final isCorrect = option == currentProverb.meaningTj;
                    final isSelected = _selectedAnswer == entry.key;

                    Color? bgColor;
                    Color? borderColor;
                    Color? textColor;
                    IconData? trailingIcon;

                    if (_answered) {
                      if (isCorrect) {
                        bgColor = const Color(0xFF166534).withValues(alpha: 0.1);
                        borderColor = const Color(0xFF166534);
                        textColor = const Color(0xFF166534);
                        trailingIcon = Icons.check_circle;
                      } else if (isSelected) {
                        bgColor = const Color(0xFFB91C1C).withValues(alpha: 0.1);
                        borderColor = const Color(0xFFB91C1C);
                        textColor = const Color(0xFFB91C1C);
                        trailingIcon = Icons.cancel;
                      }
                    } else if (isSelected) {
                      bgColor = colorScheme.primaryContainer;
                      borderColor = colorScheme.primary;
                      textColor = colorScheme.onSurface;
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: bgColor ?? colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: _answered
                              ? null
                              : () {
                                  setState(() {
                                    _selectedAnswer = entry.key;
                                    _answered = true;
                                    if (isCorrect) _correctCount++;
                                  });
                                },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 80),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: borderColor ?? colorScheme.outline.withValues(alpha: 0.4),
                                width: borderColor != null ? 2 : 1.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    option,
                                    style: TextStyle(
                                      fontFamily: 'NotoSans',
                                      fontSize: 16,
                                      height: 1.5,
                                      color: textColor ?? colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (trailingIcon != null)
                                  Icon(trailingIcon, color: borderColor, size: 26),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  if (_answered) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (isLast) {
                            _showResults(context);
                          } else {
                            setState(() {
                              _currentIndex++;
                              _selectedAnswer = null;
                              _answered = false;
                            });
                          }
                        },
                        child: Text(isLast ? 'Натиҷаро бинед' : 'Саволи нав'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResults(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (_correctCount / _quizProverbs.length * 100).round();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              percent >= 80 ? Icons.emoji_events : percent >= 50 ? Icons.thumb_up : Icons.refresh,
              size: 64,
              color: AppColors.accentGold,
            ),
            const SizedBox(height: 16),
            Text(
              '$_correctCount аз ${_quizProverbs.length} дуруст',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              '$percent%',
              style: const TextStyle(
                fontFamily: 'NotoSerif',
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              percent >= 80 ? 'Аъло!' : percent >= 50 ? 'Хуб!' : 'Кобили қабул.',
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Бозгашт'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadQuestions();
            },
            child: const Text('Квизи нав'),
          ),
        ],
      ),
    );
  }
}
