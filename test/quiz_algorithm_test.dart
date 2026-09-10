import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/data/models/proverb.dart';
import 'package:zarbulmasal/data/seed/seed_proverbs.dart';
import 'package:zarbulmasal/features/quiz/quiz_engine.dart';

void main() {
  group('QuizEngine - Content and Collision Prevention', () {
    test(
      'eligible question proverbs exclude needsReview, unverified, and variants',
      () {
        final eligible = QuizEngine.getEligibleQuestionProverbs(seedProverbs);
        expect(eligible, isNotEmpty);

        for (final p in eligible) {
          expect(p.isCanonical, isTrue, reason: 'ID ${p.id} must be canonical');
          expect(
            p.sourceStatus,
            isNot(equals(SourceStatus.needsReview)),
            reason: 'ID ${p.id} cannot be needsReview',
          );
          expect(
            p.sourceStatus,
            isNot(equals(SourceStatus.unverified)),
            reason: 'ID ${p.id} cannot be unverified',
          );
          expect(p.meaningTj.trim(), isNotEmpty);
        }

        // Explicitly verify ID 28 is excluded
        expect(
          eligible.any((p) => p.id == '28'),
          isFalse,
          reason: 'ID 28 (needsReview) must not be a quiz question',
        );

        // Explicitly verify known variants are excluded from being questions
        const knownVariants = ['44', '71', '97', '112', '149', '166', '170'];
        for (final varId in knownVariants) {
          expect(
            eligible.any((p) => p.id == varId),
            isFalse,
            reason: 'Variant ID $varId must not be a quiz question',
          );
        }
      },
    );

    test(
      'single question generation yields exactly 4 distinct options with correct answer',
      () {
        final canonicals = QuizEngine.getEligibleQuestionProverbs(seedProverbs);
        for (final proverb in canonicals) {
          final q = QuizEngine.generateQuestion(
            proverb,
            seedProverbs,
            random: Random(42),
          );
          expect(
            q.options.length,
            4,
            reason: 'Proverb ${proverb.id} must have 4 options',
          );
          expect(
            q.options.toSet().length,
            4,
            reason: 'Proverb ${proverb.id} options must all be distinct',
          );
          expect(q.options[q.correctOptionIndex], proverb.meaningTj.trim());
        }
      },
    );

    test('distractors are never variants of the target question proverb', () {
      final canonicals = QuizEngine.getEligibleQuestionProverbs(seedProverbs);

      for (final proverb in canonicals) {
        final q = QuizEngine.generateQuestion(
          proverb,
          seedProverbs,
          random: Random(123),
        );
        for (var i = 0; i < q.options.length; i++) {
          if (i == q.correctOptionIndex) continue;
          final distractorMeaning = q.options[i];

          // Find proverbs that have this meaning
          final matchingProverbs = seedProverbs.where(
            (p) => p.meaningTj.trim() == distractorMeaning,
          );
          for (final candidate in matchingProverbs) {
            expect(
              QuizEngine.isVariantOrRelated(proverb, candidate),
              isFalse,
              reason:
                  'Question ${proverb.id} cannot have variant ${candidate.id} as distractor',
            );
          }
        }
      }
    });

    test('word similarity helper accurately identifies textual similarity', () {
      expect(QuizEngine.wordSimilarity('салом дӯстам', 'салом дӯстам'), 1.0);
      expect(QuizEngine.wordSimilarity('салом дӯстам', 'хайр бародар'), 0.0);
      expect(
        QuizEngine.wordSimilarity(
          'Забони сурх сари сабзро медиҳад бар бод.',
          'Забони сурх сари сабзро мехӯрад.',
        ),
        greaterThan(0.4),
      );
    });

    test('2,000 randomized quiz simulations execute without any collision', () {
      final rng = Random(999);
      for (var iteration = 0; iteration < 2000; iteration++) {
        final quiz = QuizEngine.generateQuiz(
          catalog: seedProverbs,
          questionCount: 5,
          random: rng,
        );

        expect(
          quiz.length,
          5,
          reason: 'Iteration $iteration: quiz should have 5 questions',
        );

        // Verify all 5 questions in the quiz are distinct
        final questionIds = quiz.map((q) => q.proverb.id).toSet();
        expect(
          questionIds.length,
          5,
          reason:
              'Iteration $iteration: question proverbs must all be distinct',
        );

        for (final q in quiz) {
          // Assert exactly 4 options
          expect(
            q.options.length,
            4,
            reason:
                'Iteration $iteration: question ${q.proverb.id} must have 4 options',
          );

          // Assert zero duplicate options
          expect(
            q.options.toSet().length,
            4,
            reason:
                'Iteration $iteration: question ${q.proverb.id} has duplicate options: ${q.options}',
          );

          // Assert correct index points to correct meaning
          expect(q.options[q.correctOptionIndex], q.proverb.meaningTj.trim());

          // Assert no distractor matches correct meaning
          for (var i = 0; i < q.options.length; i++) {
            if (i == q.correctOptionIndex) continue;
            expect(q.options[i], isNot(equals(q.proverb.meaningTj.trim())));
          }
        }
      }
    });
  });
}
