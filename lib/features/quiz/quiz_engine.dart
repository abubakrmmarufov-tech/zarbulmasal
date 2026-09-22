import 'dart:math';
import '../../data/models/proverb.dart';

class QuizQuestion {
  final Proverb proverb;
  final List<String> options;
  final int correctOptionIndex;

  const QuizQuestion({
    required this.proverb,
    required this.options,
    required this.correctOptionIndex,
  });
}

class QuizEngine {
  QuizEngine._();

  static final RegExp _wordRegex = RegExp(r'[\w\u0400-\u04FF]+');
  static final Map<String, Set<String>> _wordCache = <String, Set<String>>{};

  static void clearCache() => _wordCache.clear();

  static Set<String> _extractWords(String s) {
    if (_wordCache.length > 2048) {
      _wordCache.clear();
    }
    return _wordCache.putIfAbsent(
      s,
      () => _wordRegex
          .allMatches(s.toLowerCase())
          .map((m) => m.group(0)!)
          .toSet(),
    );
  }

  static double _similarityFromSets(Set<String> wordsA, Set<String> wordsB) {
    if (wordsA.isEmpty || wordsB.isEmpty) return 0.0;
    var intersection = 0;
    for (final word in wordsA) {
      if (wordsB.contains(word)) {
        intersection++;
      }
    }
    final union = wordsA.length + wordsB.length - intersection;
    return union == 0 ? 0.0 : intersection / union;
  }

  static double wordSimilarity(String a, String b) {
    return _similarityFromSets(_extractWords(a), _extractWords(b));
  }

  static bool isVariantOrRelated(Proverb a, Proverb b) {
    if (a.id == b.id) return true;
    if (a.canonicalId != null && a.canonicalId == b.id) return true;
    if (b.canonicalId != null && b.canonicalId == a.id) return true;
    if (a.canonicalId != null &&
        b.canonicalId != null &&
        a.canonicalId == b.canonicalId) {
      return true;
    }
    if (a.variants.contains(b.id) || b.variants.contains(a.id)) {
      return true;
    }
    return false;
  }

  /// Selects eligible canonical proverbs for questions.
  static List<Proverb> getEligibleQuestionProverbs(List<Proverb> catalog) {
    return catalog
        .where(
          (p) =>
              p.isCanonical &&
              p.sourceStatus != SourceStatus.needsReview &&
              p.sourceStatus != SourceStatus.unverified &&
              p.meaningTj.trim().isNotEmpty,
        )
        .toList();
  }

  /// Generates a set of 5 quiz questions ensuring no variant or semantic collisions.
  static List<QuizQuestion> generateQuiz({
    required List<Proverb> catalog,
    int questionCount = 5,
    Random? random,
  }) {
    final rng = random ?? Random();
    final eligibleQuestions = getEligibleQuestionProverbs(catalog);
    if (eligibleQuestions.isEmpty) return [];

    final shuffled = List<Proverb>.from(eligibleQuestions)..shuffle(rng);
    final count = min(questionCount, shuffled.length);
    final questions = <QuizQuestion>[];

    for (final p in shuffled) {
      if (questions.length >= count) break;
      try {
        questions.add(generateQuestion(p, catalog, random: rng));
      } catch (_) {
        // Continue to next eligible proverb if safe distractors could not be formed
      }
    }

    return questions;
  }

  /// Generates options for a single question proverb.
  static QuizQuestion generateQuestion(
    Proverb proverb,
    List<Proverb> allProverbs, {
    Random? random,
  }) {
    final rng = random ?? Random();
    final correctMeaning = proverb.meaningTj.trim();
    final correctWords = _extractWords(correctMeaning);

    // Candidate pool: exclude needsReview, unverified, variants, and exact meanings
    final candidates = allProverbs.where((c) {
      if (c.sourceStatus == SourceStatus.needsReview ||
          c.sourceStatus == SourceStatus.unverified) {
        return false;
      }
      if (isVariantOrRelated(proverb, c)) return false;
      final cMeaning = c.meaningTj.trim();
      if (cMeaning.isEmpty || cMeaning == correctMeaning) return false;
      // Filter out high semantic / word overlap (>= 0.35)
      if (_similarityFromSets(correctWords, _extractWords(cMeaning)) >= 0.35) {
        return false;
      }
      return true;
    }).toList()..shuffle(rng);

    // Prioritize candidates from different categories
    candidates.sort((a, b) {
      final aDiffCategory = a.categoryId != proverb.categoryId ? 0 : 1;
      final bDiffCategory = b.categoryId != proverb.categoryId ? 0 : 1;
      return aDiffCategory.compareTo(bDiffCategory);
    });

    final chosenDistractors = <Proverb>[];
    final chosenWords = <Set<String>>[];

    for (final candidate in candidates) {
      if (chosenDistractors.length >= 3) break;

      final candMeaning = candidate.meaningTj.trim();
      final candWords = _extractWords(candMeaning);

      // Ensure candidate is not a variant of already chosen distractors
      var conflictsWithChosen = false;
      for (var i = 0; i < chosenDistractors.length; i++) {
        final chosen = chosenDistractors[i];
        if (isVariantOrRelated(candidate, chosen) ||
            candMeaning == chosen.meaningTj.trim() ||
            _similarityFromSets(candWords, chosenWords[i]) >= 0.35) {
          conflictsWithChosen = true;
          break;
        }
      }

      if (!conflictsWithChosen) {
        chosenDistractors.add(candidate);
        chosenWords.add(candWords);
      }
    }

    // Fallback if strict criteria yielded fewer than 3: relax category/similarity slightly
    if (chosenDistractors.length < 3) {
      final fallbackPool = allProverbs.where((c) {
        if (c.sourceStatus == SourceStatus.needsReview ||
            c.sourceStatus == SourceStatus.unverified) {
          return false;
        }
        if (c.id == proverb.id || isVariantOrRelated(proverb, c)) return false;
        final cMeaning = c.meaningTj.trim();
        if (cMeaning.isEmpty || cMeaning == correctMeaning) return false;
        return !chosenDistractors.any(
          (chosen) => chosen.id == c.id || chosen.meaningTj.trim() == cMeaning,
        );
      }).toList()..shuffle(rng);

      for (final candidate in fallbackPool) {
        if (chosenDistractors.length >= 3) break;
        final candMeaning = candidate.meaningTj.trim();
        final candWords = _extractWords(candMeaning);
        var conflictsWithChosen = false;
        for (var i = 0; i < chosenDistractors.length; i++) {
          final chosen = chosenDistractors[i];
          if (isVariantOrRelated(candidate, chosen) ||
              candMeaning == chosen.meaningTj.trim() ||
              _similarityFromSets(candWords, chosenWords[i]) >= 0.35) {
            conflictsWithChosen = true;
            break;
          }
        }
        if (!conflictsWithChosen) {
          chosenDistractors.add(candidate);
          chosenWords.add(candWords);
        }
      }
    }

    if (chosenDistractors.length < 3) {
      throw StateError(
        'Cannot generate a four-option quiz question for proverb '
        '${proverb.id}: fewer than three safe distractors are available.',
      );
    }

    final options = [
      correctMeaning,
      ...chosenDistractors.map((d) => d.meaningTj.trim()),
    ]..shuffle(rng);

    return QuizQuestion(
      proverb: proverb,
      options: options,
      correctOptionIndex: options.indexOf(correctMeaning),
    );
  }
}
