import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/l10n/app_translations.dart';
import '../../data/models/proverb.dart';
import '../../shared/providers/app_providers.dart';
import 'quiz_engine.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentIndex = 0;
  List<QuizQuestion> _quizQuestions = [];
  int? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _loadQuestions() {
    final catalog = ref.read(proverbsProvider);
    final questions = QuizEngine.generateQuiz(
      catalog: catalog,
      questionCount: 5,
    );
    setState(() {
      _quizQuestions = questions;
      _currentIndex = 0;
      _selectedAnswer = null;
      _answered = false;
      _correctCount = 0;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _back() => context.canPop() ? context.pop() : context.go('/');

  String _text(String tj, String fa, DisplayLanguage lang) =>
      lang == DisplayLanguage.persian ? fa : tj;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final all = ref.watch(proverbsProvider);
    final lang = ref.watch(displayLanguageProvider);
    final persian = lang == DisplayLanguage.persian;
    final empty = _quizQuestions.isEmpty;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: AppTranslations.get('btn_return', lang),
          onPressed: _back,
          icon: const BackButtonIcon(),
        ),
        title: Text(AppTranslations.get('quiz_title', lang)),
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
            : SingleChildScrollView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(
                  QalamSpacing.pageH,
                  12,
                  QalamSpacing.pageH,
                  32,
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: _question(colors, lang, persian, all),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _question(
    ColorScheme colors,
    DisplayLanguage lang,
    bool persian,
    List<Proverb> all,
  ) {
    final currentQ = _quizQuestions[_currentIndex];
    final proverb = currentQ.proverb;
    final options = currentQ.options;
    final selectedCorrect =
        _selectedAnswer != null &&
        _selectedAnswer == currentQ.correctOptionIndex;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_currentIndex + 1}'.padLeft(2, '0'),
              style: QalamTypography.pageTitle(
                color: colors.primary,
                fontSize: 56,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  AppTranslations.get('quiz_question_of', lang, [
                    '${_currentIndex + 1}',
                    '${_quizQuestions.length}',
                  ]),
                  style: QalamTypography.meta(color: colors.onSurfaceVariant),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (_currentIndex + 1) / _quizQuestions.length,
          color: colors.primary,
          backgroundColor: colors.outlineVariant,
          minHeight: 2,
          semanticsLabel: AppTranslations.get('quiz_title', lang),
        ),
        const SizedBox(height: 32),
        Text(
          persian ? proverb.persianText : proverb.tajikCyrillic,
          textDirection: persian ? TextDirection.rtl : TextDirection.ltr,
          style: QalamTypography.heroProverb(
            color: colors.onSurface,
            fontSize: 30,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          persian ? proverb.tajikCyrillic : proverb.persianText,
          textDirection: persian ? TextDirection.ltr : TextDirection.rtl,
          style: QalamTypography.bodySecondary(
            color: colors.onSurfaceVariant,
            fontSize: 17,
            height: 1.7,
          ),
        ),
        const SizedBox(height: 36),
        Text(
          AppTranslations.get('quiz_choose_meaning', lang),
          style: QalamTypography.label(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        ...options.asMap().entries.map(
          (entry) => QalamChoice(
            index: entry.key,
            text: entry.value,
            correctLabel: _text('Ҷавоби дуруст', 'پاسخ درست', lang),
            incorrectLabel: _text('Ҷавоби нодуруст', 'پاسخ نادرست', lang),
            isSelected: _selectedAnswer == entry.key,
            isCorrect: entry.key == currentQ.correctOptionIndex,
            revealed: _answered,
            textDirection: TextDirection.ltr,
            onTap: _answered
                ? null
                : () => setState(() {
                    _selectedAnswer = entry.key;
                    _answered = true;
                    if (entry.key == currentQ.correctOptionIndex) {
                      _correctCount++;
                    }
                  }),
          ),
        ),
        if (_answered) ...[
          const SizedBox(height: 14),
          Semantics(
            liveRegion: true,
            child: Text(
              selectedCorrect
                  ? _text('Дуруст. Офарин!', 'درست است. آفرین!', lang)
                  : _text(
                      'Ин ҷавоб дуруст нест. Маънои дуруст бо ✓ нишон дода шудааст.',
                      'این پاسخ درست نیست. معنی درست با ✓ مشخص شده است.',
                      lang,
                    ),
              style: QalamTypography.body(
                color: colors.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_currentIndex == _quizQuestions.length - 1) {
                _showResults(lang);
              } else {
                setState(() {
                  _currentIndex++;
                  _selectedAnswer = null;
                  _answered = false;
                });
                _scroll.jumpTo(0);
              }
            },
            child: Text(
              AppTranslations.get(
                _currentIndex == _quizQuestions.length - 1
                    ? 'btn_see_results'
                    : 'btn_next_question',
                lang,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showResults(DisplayLanguage lang) {
    final percent = (_correctCount / _quizQuestions.length * 100).round();
    final feedback = percent >= 80
        ? 'quiz_excellent'
        : percent >= 50
        ? 'quiz_good'
        : 'quiz_needs_work';
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return Dialog(
          insetPadding: const EdgeInsets.all(24),
          shape: const RoundedRectangleBorder(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _text('НАТИҶАИ ШУМО', 'نتیجهٔ شما', lang),
                  style: QalamTypography.eyebrow(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 28),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    '$percent%',
                    textDirection: TextDirection.ltr,
                    style: QalamTypography.pageTitle(
                      color: colors.primary,
                      fontSize: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: colors.outlineVariant),
                const SizedBox(height: 16),
                Text(
                  AppTranslations.get('quiz_correct_of', lang, [
                    '$_correctCount',
                    '${_quizQuestions.length}',
                  ]),
                  style: QalamTypography.sectionTitle(
                    color: colors.onSurface,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppTranslations.get(feedback, lang),
                  style: QalamTypography.body(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _loadQuestions();
                  },
                  child: Text(AppTranslations.get('btn_new_quiz', lang)),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _back();
                  },
                  child: Text(AppTranslations.get('btn_return', lang)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
