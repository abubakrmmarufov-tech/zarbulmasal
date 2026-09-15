import 'dart:math';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/quiz/quiz_engine.dart';

void main() {
  // Warmup
  for (var i = 0; i < 50; i++) {
    QuizEngine.generateQuiz(
      catalog: seedProverbs,
      questionCount: 5,
      random: Random(i),
    );
  }

  final stopwatch = Stopwatch()..start();
  final rng = Random(999);
  for (var iteration = 0; iteration < 2000; iteration++) {
    final quiz = QuizEngine.generateQuiz(
      catalog: seedProverbs,
      questionCount: 5,
      random: rng,
    );
    if (quiz.length != 5) {
      throw StateError('Quiz length must be 5');
    }
  }
  stopwatch.stop();
  // ignore: avoid_print
  print(
    'BENCHMARK_RESULT: ${stopwatch.elapsedMilliseconds}ms (${stopwatch.elapsedMilliseconds / 2000}ms/quiz)',
  );
}
