import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/data/literature_repository.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LiteratureRepository', () {
    late LiteratureRepository repository;

    setUp(() {
      repository = LiteratureRepository();
    });

    test('loadAuthors loads verified authors from assets', () async {
      final authors = await repository.loadAuthors();
      expect(authors, isNotEmpty);
      expect(authors.length, 10);

      final rudaki = authors.firstWhere((a) => a.id == 'rudaki');
      expect(rudaki.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');
      expect(rudaki.canonicalNamePersian, 'ابوعبدالله رودکی');
      expect(rudaki.birthYear, '~858');
      expect(rudaki.rights.status, RightsStatus.publicDomain);
      expect(rudaki.rights.fullTextAllowed, isTrue);
    });

    test('loadWorks loads registered works from assets', () async {
      final works = await repository.loadWorks();
      expect(works, isA<List<LiteraryWork>>());
      // Initial canonical works asset starts empty until verification
      expect(works, isEmpty);
    });

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
      expect(folklore, isEmpty);
    });

    group('getApprovedWorks', () {
      final approvedWork = const LiteraryWork(
        id: 'approved-1',
        authorId: 'rudaki',
        title: 'Бӯи ҷӯи Мӯлиён',
        textTajik: 'Бӯи ҷӯи Мӯлиён ояд ҳаме',
        textStatus: TextStatus.verified,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          primarySourceChecked: true,
          secondSourceChecked: true,
          titleChecked: true,
          authorshipChecked: true,
          pageChecked: true,
          textLineByLineChecked: true,
          scriptChecked: true,
          copyrightChecked: true,
          finalStatus: VerificationStatus.approved,
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
          finalStatus: VerificationStatus.needsReview,
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
          finalStatus: VerificationStatus.rejected,
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

      test('getApprovedWorks loads works from asset when omitted', () async {
        final approved = await repository.getApprovedWorks();
        expect(approved, isA<List<LiteraryWork>>());
        expect(approved, isEmpty);
      });
    });

    group('getDailyVerse', () {
      final work1 = const LiteraryWork(
        id: 'work-1',
        authorId: 'rudaki',
        title: 'Work 1',
        textTajik: 'Text 1',
        textStatus: TextStatus.verified,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          primarySourceChecked: true,
          secondSourceChecked: true,
          titleChecked: true,
          authorshipChecked: true,
          pageChecked: true,
          textLineByLineChecked: true,
          scriptChecked: true,
          copyrightChecked: true,
          finalStatus: VerificationStatus.approved,
        ),
      );

      final work2 = const LiteraryWork(
        id: 'work-2',
        authorId: 'rudaki',
        title: 'Work 2',
        textTajik: 'Text 2',
        textStatus: TextStatus.verified,
        rights: RightsRecord(
          status: RightsStatus.publicDomain,
          reasoning: 'PD',
          fullTextAllowed: true,
          excerptAllowed: true,
        ),
        verification: VerificationRecord(
          primarySourceChecked: true,
          secondSourceChecked: true,
          titleChecked: true,
          authorshipChecked: true,
          pageChecked: true,
          textLineByLineChecked: true,
          scriptChecked: true,
          copyrightChecked: true,
          finalStatus: VerificationStatus.approved,
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
          finalStatus: VerificationStatus.needsReview,
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
