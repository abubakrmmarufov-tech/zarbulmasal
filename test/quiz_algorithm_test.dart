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

    test(
      'seed variant links are relational IDs with reciprocal canonicals',
      () {
        const expectedVariantIds = {
          '43': ['44'],
          '70': ['149'],
          '96': ['170'],
          '98': ['97'],
          '120': ['166'],
          '168': ['112'],
          '169': ['71'],
        };
        final proverbsById = {
          for (final proverb in seedProverbs) proverb.id: proverb,
        };

        for (final entry in expectedVariantIds.entries) {
          final canonical = proverbsById[entry.key]!;
          expect(
            canonical.variants,
            entry.value,
            reason: 'Canonical ${entry.key}',
          );

          for (final variantId in canonical.variants) {
            final variant = proverbsById[variantId];
            expect(
              variant,
              isNotNull,
              reason: 'Variant ID $variantId must resolve in the corpus',
            );
            expect(
              variant!.canonicalId,
              canonical.id,
              reason: 'Variant $variantId must point back to ${canonical.id}',
            );
          }
        }

        for (final canonical in seedProverbs.where(
          (p) => p.variants.isNotEmpty,
        )) {
          for (final variantId in canonical.variants) {
            final variant = proverbsById[variantId];
            expect(
              variant,
              isNotNull,
              reason: 'Dangling variant ID $variantId',
            );
            expect(variant!.canonicalId, canonical.id);
          }
        }

        for (final variant in seedProverbs.where(
          (p) => p.canonicalId != null,
        )) {
          final canonical = proverbsById[variant.canonicalId];
          expect(
            canonical,
            isNotNull,
            reason: 'Dangling canonical ID ${variant.canonicalId}',
          );
          expect(
            canonical!.variants,
            contains(variant.id),
            reason: 'Canonical ${canonical.id} must link back to ${variant.id}',
          );
        }
      },
    );

    test('variant links do not depend on editable proverb text', () {
      final canonical = _testProverb(id: 'canonical', variants: ['variant']);
      final editedVariant = _testProverb(
        id: 'variant',
        tajikCyrillic: 'Матни таҳриршуда.',
      );

      expect(QuizEngine.isVariantOrRelated(canonical, editedVariant), isTrue);
    });

    test('matching text alone does not make unrelated proverbs variants', () {
      final canonical = _testProverb(id: 'canonical', variants: ['variant']);
      final unrelated = _testProverb(id: 'unrelated', tajikCyrillic: 'variant');

      expect(QuizEngine.isVariantOrRelated(canonical, unrelated), isFalse);
    });

    test('fallback keeps source and meaning eligibility guarantees', () {
      final target = _testProverb(id: 'target', meaningTj: 'як ду се чор');
      final validDistractors = [
        _testProverb(id: 'valid-1', meaningTj: 'як ду се панҷ'),
        _testProverb(id: 'valid-2', meaningTj: 'як ду чор шаш'),
        _testProverb(id: 'valid-3', meaningTj: 'як се чор ҳафт'),
      ];
      final catalog = [
        target,
        ...validDistractors,
        _testProverb(
          id: 'needs-review',
          meaningTj: 'номзади носанҷида',
          sourceStatus: SourceStatus.needsReview,
        ),
        _testProverb(
          id: 'unverified',
          meaningTj: 'номзади тасдиқнашуда',
          sourceStatus: SourceStatus.unverified,
        ),
        _testProverb(id: 'empty-meaning', meaningTj: '   '),
      ];
      final expectedOptions = {
        target.meaningTj,
        ...validDistractors.map((proverb) => proverb.meaningTj),
      };

      for (var seed = 0; seed < 20; seed++) {
        final question = QuizEngine.generateQuestion(
          target,
          catalog,
          random: Random(seed),
        );
        expect(
          question.options.toSet(),
          expectedOptions,
          reason: 'Seed $seed must not relax source or empty-meaning checks',
        );
      }
    });

    test('fallback never selects related distractors together', () {
      final target = _testProverb(id: 'target', meaningTj: 'як ду се чор');
      final canonicalDistractor = _testProverb(
        id: 'candidate-canonical',
        meaningTj: 'як ду се панҷ',
        variants: ['candidate-variant'],
      );
      final variantDistractor = _testProverb(
        id: 'candidate-variant',
        meaningTj: 'як ду се ҳашт',
        canonicalId: canonicalDistractor.id,
      );
      final catalog = [
        target,
        canonicalDistractor,
        variantDistractor,
        _testProverb(id: 'safe-1', meaningTj: 'як ду чор шаш'),
        _testProverb(id: 'safe-2', meaningTj: 'як се чор ҳафт'),
      ];

      for (var seed = 0; seed < 20; seed++) {
        final question = QuizEngine.generateQuestion(
          target,
          catalog,
          random: Random(seed),
        );
        final options = question.options.toSet();
        expect(question.options, hasLength(4));
        expect(
          options.contains(canonicalDistractor.meaningTj) &&
              options.contains(variantDistractor.meaningTj),
          isFalse,
          reason: 'Seed $seed selected two distractors from one variant group',
        );
      }
    });

    test('fails explicitly when three safe distractors are unavailable', () {
      final target = _testProverb(id: 'target');
      final catalog = [
        target,
        _testProverb(id: 'safe-1', meaningTj: 'Якум'),
        _testProverb(id: 'safe-2', meaningTj: 'Дуюм'),
      ];

      expect(
        () => QuizEngine.generateQuestion(target, catalog),
        throwsA(isA<StateError>()),
      );
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

Proverb _testProverb({
  required String id,
  String tajikCyrillic = 'Матн',
  String meaningTj = 'Маъно',
  String? canonicalId,
  List<String> variants = const [],
  SourceStatus sourceStatus = SourceStatus.bookAttested,
}) {
  return Proverb(
    id: id,
    tajikCyrillic: tajikCyrillic,
    persianText: 'متن',
    simpleExplanationTj: 'Шарҳ',
    meaningTj: meaningTj,
    exampleSentenceTj: 'Мисол',
    categoryId: 'test',
    level: 1,
    type: ProverbType.traditional,
    sourceStatus: sourceStatus,
    sourceNote: 'Test fixture',
    canonicalId: canonicalId,
    variants: variants,
  );
}
