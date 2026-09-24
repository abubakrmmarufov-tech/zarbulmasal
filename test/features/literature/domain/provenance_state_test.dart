import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

LiteraryWork _work({
  VerificationLevel level = VerificationLevel.primaryChecked,
  bool pageVerified = true,
  SourceEdition? secondary,
  String? match,
  TextStatus textStatus = TextStatus.verified,
}) {
  return LiteraryWork(
    id: 'w',
    authorId: 'a',
    title: 'T',
    textTajik: 'a\nb\nc\nd',
    textStatus: textStatus,
    primarySource: const SourceEdition(
      bookTitle: 'Адабиёти тоҷик',
      authorAsPrinted: 'Муаллиф',
      publisher: 'Маориф',
      city: 'Душанбе',
      year: '2017',
      pageStart: 54,
      pageEnd: 54,
      sourceType: SourceEditionType.officialTextbook,
    ),
    secondarySource: secondary,
    textMatchResult: match,
    rights: const RightsRecord(
      status: RightsStatus.sourceAttested,
      reasoning: 'x',
      fullTextAllowed: true,
      excerptAllowed: true,
    ),
    verification: VerificationRecord(
      evidenceLevel: level,
      pageVerified: pageVerified,
    ),
  );
}

const _secondWitness = SourceEdition(
  bookTitle: 'Адабиёти тоҷик',
  authorAsPrinted: 'Муаллиф',
  publisher: 'Маориф',
  city: 'Душанбе',
  year: '2025',
  pageStart: 56,
  pageEnd: 56,
  sourceType: SourceEditionType.officialTextbook,
);

void main() {
  group('ProvenanceState.of', () {
    test('editorially approved work gets the pressed seal', () {
      final state = ProvenanceState.of(
        _work(level: VerificationLevel.editoriallyApproved),
      );
      expect(state.seal, ProvenanceSeal.pressed);
      expect(state.isEditoriallyApproved, isTrue);
    });

    test('textStatus "verified" alone never earns the pressed seal', () {
      final state = ProvenanceState.of(_work(textStatus: TextStatus.verified));
      expect(state.seal, isNot(ProvenanceSeal.pressed));
      expect(state.isEditoriallyApproved, isFalse);
    });

    test('page-checked work with a collated second witness is outline', () {
      final state = ProvenanceState.of(
        _work(secondary: _secondWitness, match: 'exact'),
      );
      expect(state.seal, ProvenanceSeal.outline);
      expect(state.hasCollatedSecondWitness, isTrue);
    });

    test('second witness without a recorded comparison is not "collated"', () {
      final state = ProvenanceState.of(_work(secondary: _secondWitness));
      expect(state.seal, ProvenanceSeal.outline);
      expect(state.hasCollatedSecondWitness, isFalse);
    });

    test('primary-only page-checked work is outline without witness', () {
      final state = ProvenanceState.of(_work());
      expect(state.seal, ProvenanceSeal.outline);
      expect(state.hasCollatedSecondWitness, isFalse);
    });

    test('checked level without a verified page is absent', () {
      final state = ProvenanceState.of(_work(pageVerified: false));
      expect(state.seal, ProvenanceSeal.absent);
    });

    for (final level in [
      VerificationLevel.needsReview,
      VerificationLevel.extracted,
      VerificationLevel.sourceLocated,
      VerificationLevel.rejected,
    ]) {
      test('${level.name} is absent', () {
        expect(
          ProvenanceState.of(_work(level: level)).seal,
          ProvenanceSeal.absent,
        );
      });
    }
  });

  group('shipped catalog', () {
    late List<LiteraryWork> works;

    setUpAll(() {
      final raw =
          jsonDecode(
                File(
                  'assets/data/literature/runtime_works.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      works = expandRuntimeWorks(
        raw,
      ).map(LiteraryWork.fromJson).where((work) => work.isDisplayable).toList();
    });

    test('no displayable work is presented as editorially approved', () {
      // The data holds zero editoriallyApproved records today; the seal must
      // follow the data, not the legacy `textStatus: verified` flag.
      for (final work in works) {
        final state = ProvenanceState.of(work);
        expect(
          state.seal == ProvenanceSeal.pressed,
          work.verification.evidenceLevel ==
              VerificationLevel.editoriallyApproved,
          reason: work.id,
        );
      }
    });

    test('every displayable work has an outline or pressed seal', () {
      expect(works, isNotEmpty);
      for (final work in works) {
        expect(
          ProvenanceState.of(work).seal,
          isNot(ProvenanceSeal.absent),
          reason: work.id,
        );
      }
    });
  });
}
