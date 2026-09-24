import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/data/runtime_works_codec.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

import '../../../../tool/build_runtime_literature.dart'
    show buildRuntimeCatalogJson;

const Set<VerificationLevel> _checkedLevels = {
  VerificationLevel.primaryChecked,
  VerificationLevel.secondWitnessLocated,
  VerificationLevel.collated,
  VerificationLevel.editoriallyApproved,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final canonicalFile = File('assets/data/literature/works.json');
  final runtimeFile = File('assets/data/literature/runtime_works.json');

  late List<dynamic> canonical;
  late List<Map<String, dynamic>> expanded;
  late Map<String, Map<String, dynamic>> canonicalById;
  late Map<String, Map<String, dynamic>> runtimeById;

  setUpAll(() {
    canonical = jsonDecode(canonicalFile.readAsStringSync()) as List<dynamic>;
    final runtimeDecoded = jsonDecode(runtimeFile.readAsStringSync());
    expanded = expandRuntimeWorks(runtimeDecoded);
    canonicalById = {
      for (final raw in canonical)
        if (raw is Map<String, dynamic>) raw['id'] as String: raw,
    };
    runtimeById = {for (final work in expanded) work['id'] as String: work};
  });

  group('runtime catalog', () {
    test('is byte-deterministic: regenerating yields the committed bytes', () {
      final regenerated = buildRuntimeCatalogJson(canonical);
      expect(regenerated, runtimeFile.readAsStringSync());
    });

    test('preserves every canonical work id exactly once', () {
      expect(expanded.length, canonical.length);
      expect(canonicalById.keys.toSet(), runtimeById.keys.toSet());
    });

    test('keeps every displayable work fully readable with evidence', () {
      final displayableIds = <String>[];
      for (final entry in canonicalById.entries) {
        final canonicalWork = LiteraryWork.fromJson(entry.value);
        if (!canonicalWork.isDisplayable) continue;
        displayableIds.add(entry.key);

        final runtimeWork = LiteraryWork.fromJson(runtimeById[entry.key]!);
        expect(runtimeWork.isDisplayable, isTrue, reason: entry.key);
        expect(
          runtimeWork.textTajik,
          canonicalWork.textTajik,
          reason: entry.key,
        );
        expect(
          runtimeWork.textPersian,
          canonicalWork.textPersian,
          reason: entry.key,
        );
        expect(runtimeWork.incipit, canonicalWork.incipit, reason: entry.key);
        expect(
          runtimeWork.primarySource,
          canonicalWork.primarySource,
          reason: entry.key,
        );
        expect(runtimeWork.rights, canonicalWork.rights, reason: entry.key);
        expect(
          runtimeWork.verification,
          canonicalWork.verification,
          reason: entry.key,
        );
      }
      expect(displayableIds, isNotEmpty);
    });

    test('keeps every auditable review citation and provenance', () {
      var citationCount = 0;
      for (final entry in canonicalById.entries) {
        final canonicalWork = LiteraryWork.fromJson(entry.value);
        if (!canonicalWork.hasAuditableReviewCitation) continue;
        citationCount++;

        final runtimeWork = LiteraryWork.fromJson(runtimeById[entry.key]!);
        expect(
          runtimeWork.hasAuditableReviewCitation,
          isTrue,
          reason: entry.key,
        );
        final canonicalSource = canonicalWork.primarySource!;
        final runtimeSource = runtimeWork.primarySource!;
        expect(
          runtimeSource.pageStart,
          canonicalSource.pageStart,
          reason: entry.key,
        );
        expect(
          runtimeSource.pageEnd,
          canonicalSource.pageEnd,
          reason: entry.key,
        );
        expect(
          runtimeSource.sourceReference,
          canonicalSource.sourceReference,
          reason: entry.key,
        );
        expect(
          runtimeSource.bookTitle,
          canonicalSource.bookTitle,
          reason: entry.key,
        );
        expect(
          runtimeSource.citation,
          canonicalSource.citation,
          reason: entry.key,
        );
        expect(
          runtimeWork.verification.evidenceLevel,
          canonicalWork.verification.evidenceLevel,
          reason: entry.key,
        );
      }
      expect(citationCount, greaterThan(0));
    });

    test('preserves the searchable review set', () {
      bool searchable(LiteraryWork work) =>
          work.hasAuditableReviewCitation &&
          _checkedLevels.contains(work.verification.evidenceLevel);

      final canonicalSearchable = canonicalById.values
          .map(LiteraryWork.fromJson)
          .where(searchable)
          .map((work) => work.id)
          .toSet();
      final runtimeSearchable = runtimeById.values
          .map(LiteraryWork.fromJson)
          .where(searchable)
          .map((work) => work.id)
          .toSet();
      expect(runtimeSearchable, canonicalSearchable);
      expect(runtimeSearchable, isNotEmpty);
    });

    test('preserves the approved (displayable) and under-review counts', () {
      final canonicalApproved = canonicalById.values
          .map(LiteraryWork.fromJson)
          .where((work) => work.isDisplayable)
          .length;
      final runtimeApproved = runtimeById.values
          .map(LiteraryWork.fromJson)
          .where((work) => work.isDisplayable)
          .length;
      expect(runtimeApproved, canonicalApproved);

      int reviewCount(Iterable<Map<String, dynamic>> works) => works
          .map(LiteraryWork.fromJson)
          .where(
            (work) =>
                !work.isDisplayable &&
                work.verification.evidenceLevel != VerificationLevel.rejected,
          )
          .length;
      expect(
        reviewCount(runtimeById.values),
        reviewCount(canonicalById.values),
      );
    });

    test('preserves per-author under-review and sourced-review counts', () {
      Map<String, int> countByAuthor(
        Iterable<Map<String, dynamic>> works, {
        required bool sourced,
      }) {
        final counts = <String, int>{};
        for (final work in works.map(LiteraryWork.fromJson)) {
          if (work.isDisplayable ||
              work.verification.evidenceLevel == VerificationLevel.rejected) {
            continue;
          }
          if (sourced && !work.hasAuditableReviewCitation) continue;
          counts[work.authorId] = (counts[work.authorId] ?? 0) + 1;
        }
        return counts;
      }

      expect(
        countByAuthor(runtimeById.values, sourced: false),
        countByAuthor(canonicalById.values, sourced: false),
      );
      expect(
        countByAuthor(runtimeById.values, sourced: true),
        countByAuthor(canonicalById.values, sourced: true),
      );
    });

    test('stubs are never readable works and carry identity only', () {
      final stubIds = <String>[];
      for (final entry in canonicalById.entries) {
        final canonicalWork = LiteraryWork.fromJson(entry.value);
        if (canonicalWork.isDisplayable ||
            canonicalWork.hasAuditableReviewCitation) {
          continue;
        }
        stubIds.add(entry.key);

        final runtimeMap = runtimeById[entry.key]!;
        final runtimeWork = LiteraryWork.fromJson(runtimeMap);
        expect(runtimeWork.isDisplayable, isFalse, reason: entry.key);
        expect(
          runtimeWork.hasAuditableReviewCitation,
          isFalse,
          reason: entry.key,
        );
        expect(runtimeMap['primarySource'], isNull, reason: entry.key);
        expect(runtimeMap['secondarySource'], isNull, reason: entry.key);
        expect(runtimeMap['sourceOccurrences'], isNull, reason: entry.key);
        expect(runtimeMap['rights'], isNull, reason: entry.key);
        expect(runtimeMap['textTajik'], isNull, reason: entry.key);
        expect(runtimeMap['textPersian'], isNull, reason: entry.key);
        expect(runtimeMap['id'], canonicalWork.id);
        expect(runtimeMap['authorId'], canonicalWork.authorId);
        expect(runtimeMap['title'], canonicalWork.title);
        expect(
          (runtimeMap['verification'] as Map)['evidenceLevel'],
          canonicalWork.verification.evidenceLevel.name,
          reason: entry.key,
        );
      }
      expect(stubIds, isNotEmpty);
    });

    test('school canon and history work references resolve in the runtime', () {
      final canon =
          jsonDecode(
                File(
                  'assets/data/literature/school_canon.json',
                ).readAsStringSync(),
              )
              as List;
      for (final entry in canon) {
        final workId = (entry as Map)['workId'];
        if (workId == null || workId.toString().trim().isEmpty) continue;
        expect(
          runtimeById.containsKey(workId),
          isTrue,
          reason: 'Canon entry references missing runtime work $workId',
        );
      }

      final history =
          jsonDecode(
                File('assets/data/history/entries.json').readAsStringSync(),
              )
              as List;
      for (final entry in history) {
        final related = (entry as Map)['relatedWorkIds'];
        if (related is! List) continue;
        for (final workId in related.whereType<String>()) {
          final work = runtimeById[workId];
          expect(
            work,
            isNotNull,
            reason: 'History references missing runtime work $workId',
          );
          if (work != null) {
            final model = LiteraryWork.fromJson(work);
            expect(model.isDisplayable, isTrue, reason: workId);
          }
        }
      }
    });

    test(
      'repository loads the runtime catalog with canonical counts',
      () async {
        final repository = LiteratureRepository();
        final works = await repository.loadWorks();
        expect(works.length, canonical.length);

        final approved = repository.filterApprovedWorks(works);
        final canonicalApproved = canonicalById.values
            .map(LiteraryWork.fromJson)
            .where((work) => work.isDisplayable)
            .length;
        expect(approved.length, canonicalApproved);

        final searchable = works
            .where(
              (work) =>
                  work.hasAuditableReviewCitation &&
                  _checkedLevels.contains(work.verification.evidenceLevel),
            )
            .toList();
        final canonicalSearchable = canonicalById.values
            .map(LiteraryWork.fromJson)
            .where(
              (work) =>
                  work.hasAuditableReviewCitation &&
                  _checkedLevels.contains(work.verification.evidenceLevel),
            )
            .length;
        expect(searchable.length, canonicalSearchable);
        expect(searchable, isNotEmpty);
      },
    );

    test('repository works asset points at the runtime catalog', () {
      // Pins the asset switch: the bundled works asset is the derived runtime
      // catalog, while the canonical works.json stays in the repo as the
      // editorial source of truth (used by the content/provenance validators).
      expect(
        LiteratureRepository.worksAssetPath,
        'assets/data/literature/runtime_works.json',
      );
    });
  });

  group('runtime_works_codec', () {
    test('expands dictionary references into plain source and rights maps', () {
      final decoded = {
        'version': 1,
        'sources': [
          {
            'bookTitle': 'Адабиёти тоҷик',
            'publisher': 'Маориф',
            'city': 'Душанбе',
            'year': '2017',
            'sourceType': 'official-textbook',
          },
        ],
        'rights': [
          {
            'status': 'publicDomain',
            'reasoning': 'PD',
            'fullTextAllowed': true,
            'excerptAllowed': true,
          },
        ],
        'works': [
          {
            'id': 'w1',
            'authorId': 'a1',
            'title': 'Шеър',
            'primarySource': {'s': 0, 'pageStart': 12},
            'secondarySource': {'s': 0, 'pageEnd': 14},
            'sourceOccurrences': [
              {'s': 0, 'pageStart': 30, 'pageEnd': 31},
            ],
            'rights': {'r': 0},
            'verification': {
              'evidenceLevel': 'primaryChecked',
              'pageVerified': true,
            },
          },
        ],
      };

      final expanded = expandRuntimeWorks(decoded);
      expect(expanded, hasLength(1));
      final work = expanded.single;
      expect(work['id'], 'w1');

      final primary = work['primarySource'] as Map<String, dynamic>;
      expect(primary['bookTitle'], 'Адабиёти тоҷик');
      expect(primary['publisher'], 'Маориф');
      expect(primary['pageStart'], 12);

      final secondary = work['secondarySource'] as Map<String, dynamic>;
      expect(secondary['bookTitle'], 'Адабиёти тоҷик');
      expect(secondary['pageEnd'], 14);

      final occurrence =
          (work['sourceOccurrences'] as List).single as Map<String, dynamic>;
      expect(occurrence['pageStart'], 30);
      expect(occurrence['pageEnd'], 31);

      final rights = work['rights'] as Map<String, dynamic>;
      expect(rights['status'], 'publicDomain');
      expect(rights['fullTextAllowed'], true);

      final model = LiteraryWork.fromJson(work);
      expect(model.primarySource!.pageStart, 12);
      expect(model.primarySource!.bookTitle, 'Адабиёти тоҷик');
      expect(model.rights.status, RightsStatus.publicDomain);
      expect(
        model.verification.evidenceLevel,
        VerificationLevel.primaryChecked,
      );
    });

    test('passes a legacy top-level list through unchanged', () {
      final decoded = [
        {'id': 'w1', 'authorId': 'a1', 'title': 'Шеър'},
      ];
      final expanded = expandRuntimeWorks(decoded);
      expect(expanded, hasLength(1));
      expect(expanded.single['id'], 'w1');
      expect(expanded.single['title'], 'Шеър');
    });

    test('returns empty when the decoded value is neither list nor map', () {
      expect(expandRuntimeWorks('nonsense'), isEmpty);
      expect(expandRuntimeWorks(null), isEmpty);
    });

    test(
      'returns a corrupt source reference unchanged rather than guessing',
      () {
        final decoded = {
          'version': 1,
          'sources': <Map<String, dynamic>>[],
          'rights': <Map<String, dynamic>>[],
          'works': [
            {
              'id': 'w1',
              'authorId': 'a1',
              'title': 'Шеър',
              'primarySource': {'s': 7, 'pageStart': 1},
            },
          ],
        };
        final expanded = expandRuntimeWorks(decoded);
        final primary =
            expanded.single['primarySource'] as Map<String, dynamic>;
        // Out-of-range index is not silently coerced: the reference is returned
        // verbatim so a corrupt catalog fails loudly in validation instead.
        expect(primary['s'], 7);
        expect(primary['pageStart'], 1);
      },
    );
  });

  group('runtime builder source-image normalization', () {
    test(
      'falls back to legacy sourceImagePath when sourceImagePaths is empty',
      () {
        final canonical = [
          {
            'id': 'w-legacy-singular-path',
            'authorId': 'a1',
            'title': 'Шеър',
            'primarySource': <String, dynamic>{
              'bookTitle': 'Адабиёти тоҷик',
              'publisher': 'Маориф',
              'city': 'Душанбе',
              'year': '2017',
              'sourceType': 'official-textbook',
              'sourceReference': 'docs/literature/pdfs/grade5.pdf',
              'pageStart': 54,
              'sourceImagePaths': <String>[],
              'sourceImagePath': 'legacy/scan-054.png',
            },
          },
        ];
        final runtime = jsonDecode(buildRuntimeCatalogJson(canonical));
        final expanded = expandRuntimeWorks(runtime);
        final source = expanded.single['primarySource'] as Map<String, dynamic>;
        // An empty plural list must not silently drop the legacy single-image
        // witness: the builder normalizes it the way SourceEdition does.
        expect(source['sourceImagePaths'], ['legacy/scan-054.png']);
        final model = LiteraryWork.fromJson(expanded.single);
        expect(model.primarySource!.sourceImagePaths, ['legacy/scan-054.png']);
      },
    );

    test('keeps a non-empty plural list and ignores the singular key', () {
      final canonical = [
        {
          'id': 'w-plural-wins',
          'authorId': 'a1',
          'title': 'Шеър',
          'primarySource': <String, dynamic>{
            'bookTitle': 'Адабиёти тоҷик',
            'publisher': 'Маориф',
            'city': 'Душанбе',
            'year': '2017',
            'sourceType': 'official-textbook',
            'sourceReference': 'docs/literature/pdfs/grade5.pdf',
            'pageStart': 54,
            'sourceImagePaths': <String>['a/1.png', 'a/2.png'],
            'sourceImagePath': 'legacy/scan-054.png',
          },
        },
      ];
      final runtime = jsonDecode(buildRuntimeCatalogJson(canonical));
      final expanded = expandRuntimeWorks(runtime);
      final source = expanded.single['primarySource'] as Map<String, dynamic>;
      expect(source['sourceImagePaths'], ['a/1.png', 'a/2.png']);
    });
  });

  group('stub-loss invariants', () {
    test('no stub loses a field any public screen renders', () {
      var stubCount = 0;
      for (final entry in canonicalById.entries) {
        final canonicalWork = LiteraryWork.fromJson(entry.value);
        if (canonicalWork.isDisplayable ||
            canonicalWork.hasAuditableReviewCitation) {
          continue;
        }
        stubCount++;
        expect(
          canonicalWork.hasAuditableCompositionEvidence,
          isFalse,
          reason: entry.key,
        );
        expect(canonicalWork.isExcerptDisplayable, isFalse, reason: entry.key);
      }
      expect(stubCount, greaterThan(0));
    });
  });
}
