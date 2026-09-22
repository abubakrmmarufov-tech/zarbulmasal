import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

class _CountingAssetBundle extends AssetBundle {
  _CountingAssetBundle(this.assets);

  final Map<String, String> assets;
  final Map<String, int> loadStringCalls = {};

  @override
  Future<ByteData> load(String key) async {
    final value = assets[key];
    if (value == null) throw FlutterError('Missing test asset: $key');
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loadStringCalls[key] = (loadStringCalls[key] ?? 0) + 1;
    final value = assets[key];
    if (value == null) throw FlutterError('Missing test asset: $key');
    return value;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiteratureRepository', () {
    late LiteratureRepository repository;
    const verifiedSource = SourceEdition(
      bookTitle: 'Сарчашмаи санҷишӣ',
      publisher: 'Нашриёт',
      city: 'Душанбе',
      year: '2026',
      pageStart: 1,
      sourceType: SourceEditionType.criticalEdition,
    );

    setUp(() {
      repository = LiteratureRepository();
    });

    test('loadAuthors loads verified authors from assets', () async {
      final authors = await repository.loadAuthors();
      expect(authors, isNotEmpty);

      final rudaki = authors.firstWhere((a) => a.id == 'rudaki');
      expect(rudaki.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');
      expect(rudaki.canonicalNamePersian, 'ابوعبدالله رودکی');
      expect(rudaki.birthYear, '858');
      // Rights evidence was not sufficient to retain the old public-domain
      // claim, so the repaired catalog fails closed until it is re-established.
      expect(rudaki.rights.status, RightsStatus.unknown);
      expect(rudaki.rights.fullTextAllowed, isFalse);
    });

    test('loadWorks loads registered works from assets', () async {
      final works = await repository.loadWorks();
      expect(works, isA<List<LiteraryWork>>());
      // Candidate records are loaded, but publication remains fail-closed.
      expect(works, isNotEmpty);
    });

    test(
      'loadWorks shares successful loads without caching failures',
      () async {
        final bundle = _CountingAssetBundle({
          LiteratureRepository.worksAssetPath: '[]',
        });
        final cachedRepository = LiteratureRepository(bundle: bundle);

        final loadedWorks = await cachedRepository.loadWorks();
        await cachedRepository.loadWorks();

        expect(bundle.loadStringCalls[LiteratureRepository.worksAssetPath], 1);
        expect(() => loadedWorks.clear(), throwsUnsupportedError);

        final failingBundle = _CountingAssetBundle({});
        final retryableRepository = LiteratureRepository(bundle: failingBundle);
        await expectLater(
          retryableRepository.loadWorks(),
          throwsA(isA<FlutterError>()),
        );
        await expectLater(
          retryableRepository.loadWorks(),
          throwsA(isA<FlutterError>()),
        );
        expect(
          failingBundle.loadStringCalls[LiteratureRepository.worksAssetPath],
          2,
        );
      },
    );

    test('loadSources loads bibliographic editions from assets', () async {
      final sources = await repository.loadSources();
      expect(sources, isNotEmpty);
      expect(sources.length, greaterThanOrEqualTo(15));

      final firstSource = sources.first;
      expect(firstSource.bookTitle, isNotEmpty);
      expect(firstSource.publisher, isNotEmpty);
      expect(firstSource.city, isNotEmpty);
    });

    test(
      'loadSchoolCanon loads official curriculum entries from assets',
      () async {
        final canon = await repository.loadSchoolCanon();
        expect(canon, isNotEmpty);
        expect(canon.length, greaterThanOrEqualTo(20));

        final rudakiCanon = canon.where((c) => c.authorId == 'rudaki').toList();
        expect(rudakiCanon, isNotEmpty);
        expect(rudakiCanon.every((c) => c.isMandatory), isTrue);
      },
    );

    test('loadOralHeritage loads folklore oral heritage from assets', () async {
      final folklore = await repository.loadOralHeritage();
      expect(folklore, isA<List<OralHeritageEntry>>());
      expect(folklore, isNotEmpty);
    });

    test('normalizes common Persian keyboard variants for search', () {
      expect(LiteratureRepository.normalizeSearchText('  رُودكي‌  '), 'رودکی');
    });

    group('getApprovedWorks', () {
      final approvedWork = const LiteraryWork(
        id: 'approved-1',
        authorId: 'rudaki',
        title: 'Бӯи ҷӯи Мӯлиён',
        textTajik: 'Бӯи ҷӯи Мӯлиён ояд ҳаме',
        textStatus: TextStatus.verified,
        primarySource: verifiedSource,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );

      final unverifiedWork = const LiteraryWork(
        id: 'unverified-1',
        authorId: 'rudaki',
        title: 'Шеъри тасдиқнашуда',
        textStatus: TextStatus.needsReview,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.needsReview,
        ),
      );

      final blockedWork = const LiteraryWork(
        id: 'blocked-1',
        authorId: 'contemporary',
        title: 'Шеъри масдудшуда',
        textStatus: TextStatus.blocked,
        rights: RightsRecord(
          status: RightsStatus.blocked,
          reasoning: 'Blocked content',
          fullTextAllowed: false,
          excerptAllowed: false,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.rejected,
        ),
      );

      test('filters passed works list by isDisplayable', () async {
        final mixed = [approvedWork, unverifiedWork, blockedWork];
        final filtered = await repository.getApprovedWorks(mixed);

        expect(filtered.length, 1);
        expect(filtered.first.id, 'approved-1');
        expect(filtered.first.isDisplayable, isTrue);
      });

      test('filterApprovedWorks works synchronously', () {
        final mixed = [approvedWork, unverifiedWork, blockedWork];
        final filtered = repository.filterApprovedWorks(mixed);

        expect(filtered.length, 1);
        expect(filtered.first.id, 'approved-1');
      });

      test(
        'getApprovedWorks returns verified asset works with source pages',
        () async {
          final approved = await repository.getApprovedWorks();
          expect(approved, isA<List<LiteraryWork>>());
        },
      );
    });

    group('getDailyVerse', () {
      final work1 = const LiteraryWork(
        id: 'work-1',
        authorId: 'rudaki',
        title: 'Work 1',
        textTajik: 'Text 1',
        textStatus: TextStatus.verified,
        primarySource: verifiedSource,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );

      final work2 = const LiteraryWork(
        id: 'work-2',
        authorId: 'rudaki',
        title: 'Work 2',
        textTajik: 'Text 2',
        textStatus: TextStatus.verified,
        primarySource: verifiedSource,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
      );

      final unapprovedWork = const LiteraryWork(
        id: 'work-unapproved',
        authorId: 'rudaki',
        title: 'Unapproved',
        textStatus: TextStatus.needsReview,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.needsReview,
        ),
      );

      test('returns null when works list is empty', () {
        final result = repository.getDailyVerse(DateTime(2026, 9, 10), []);
        expect(result, isNull);
      });

      test('returns null when no works in list are approved', () {
        final result = repository.getDailyVerse(DateTime(2026, 9, 10), [
          unapprovedWork,
        ]);
        expect(result, isNull);
      });

      test('deterministically selects work for same date', () {
        final works = [work1, work2, unapprovedWork];
        final date = DateTime(2026, 9, 10, 14, 30);
        final dateSameDayDifferentTime = DateTime(2026, 9, 10, 23, 59);

        final result1 = repository.getDailyVerse(date, works);
        final result2 = repository.getDailyVerse(
          dateSameDayDifferentTime,
          works,
        );

        expect(result1, isNotNull);
        expect(result1!.id, isIn(['work-1', 'work-2']));
        expect(result1.id, result2!.id);
      });

      test('cycles between approved works on consecutive days', () {
        final works = [work1, work2];
        final day1 = DateTime(2026, 9, 10);
        final day2 = DateTime(2026, 9, 11);

        final result1 = repository.getDailyVerse(day1, works);
        final result2 = repository.getDailyVerse(day2, works);

        expect(result1, isNotNull);
        expect(result2, isNotNull);
        expect(result1!.id, isNot(equals(result2!.id)));
      });
    });

    group('Helper lookup methods', () {
      test(
        'getAuthorById finds existing author and null for missing',
        () async {
          final rudaki = await repository.getAuthorById('rudaki');
          expect(rudaki, isNotNull);
          expect(rudaki!.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');

          final unknown = await repository.getAuthorById('non-existent');
          expect(unknown, isNull);
        },
      );

      test('getCanonByAuthor returns canon entries for given author', () async {
        final canon = await repository.getCanonByAuthor('rudaki');
        expect(canon, isNotEmpty);
        expect(canon.every((c) => c.authorId == 'rudaki'), isTrue);

        final emptyCanon = await repository.getCanonByAuthor('non-existent');
        expect(emptyCanon, isEmpty);
      });

      test('getWorksByAuthor returns works for given author', () async {
        final works = await repository.getWorksByAuthor('rudaki');
        expect(works, isA<List<LiteraryWork>>());
      });
    });
  });
}
