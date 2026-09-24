import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/domain/oral_heritage_entry.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';
import 'package:zarbulmasal/features/literature/domain/portrait_record.dart';

void main() {
  group('PortraitRecord', () {
    test('round trips source provenance and rejects non-local sources', () {
      const portrait = PortraitRecord(
        assetPath: 'assets/data/literature/portraits/rudaki.png',
        sourceType: PortraitSourceType.uploadedBook,
        sourceReference: 'docs/literature/pdfs/adabiet sinfi 5.pdf',
        sourcePage: 49,
        rightsStatus: 'unknown',
      );

      final restored = PortraitRecord.fromJson(portrait.toJson());
      expect(restored, portrait);
      expect(restored.isSourceBacked, isTrue);
      expect(restored.citation, 'adabiet sinfi 5.pdf, PDF p. 49');

      expect(
        portrait
            .copyWith(assetPath: 'https://example.test/face.jpg')
            .isSourceBacked,
        isFalse,
      );
      expect(
        PortraitRecord.fromJson({
          'assetPath': 'assets/data/literature/portraits/rudaki.png',
          'sourceType': 'uploaded_book',
          'sourceReference': 'docs/literature/pdfs/adabiet sinfi 5.pdf',
          'sourcePage': '49',
        }).sourcePage,
        49,
      );
    });
  });

  group('RightsRecord and RightsStatus', () {
    test('RightsStatus fromString handles case and format variations', () {
      expect(
        RightsStatus.fromString('publicDomain'),
        RightsStatus.publicDomain,
      );
      expect(
        RightsStatus.fromString('public_domain'),
        RightsStatus.publicDomain,
      );
      expect(
        RightsStatus.fromString('PUBLIC_DOMAIN'),
        RightsStatus.publicDomain,
      );
      expect(
        RightsStatus.fromString('permission_granted'),
        RightsStatus.permissionGranted,
      );
      expect(RightsStatus.fromString('excerpt_only'), RightsStatus.excerptOnly);
      expect(RightsStatus.fromString('folklore'), RightsStatus.folklore);
      expect(RightsStatus.fromString('blocked'), RightsStatus.blocked);
      expect(RightsStatus.fromString('unknown'), RightsStatus.unknown);
      expect(RightsStatus.fromString('invalid-string'), RightsStatus.unknown);
      expect(RightsStatus.fromString(null), RightsStatus.unknown);
    });

    test('RightsStatus helper getters', () {
      expect(RightsStatus.publicDomain.allowsFullText, isTrue);
      expect(RightsStatus.permissionGranted.allowsFullText, isTrue);
      expect(RightsStatus.folklore.allowsFullText, isTrue);
      expect(RightsStatus.excerptOnly.allowsFullText, isFalse);
      expect(RightsStatus.blocked.allowsFullText, isFalse);

      expect(RightsStatus.publicDomain.allowsExcerpt, isTrue);
      expect(RightsStatus.excerptOnly.allowsExcerpt, isTrue);
      expect(RightsStatus.blocked.allowsExcerpt, isFalse);
      expect(RightsStatus.unknown.allowsExcerpt, isFalse);
    });

    test('RightsRecord fromJson / toJson / copyWith serialization', () {
      final json = {
        'authorDeathYear': '941',
        'status': 'public_domain',
        'reasoning': 'Deceased > 50 years',
        'rightsSource': 'Law No. 726, Art. 17',
        'fullTextAllowed': true,
        'excerptAllowed': true,
        'permissionReference': null,
      };

      final record = RightsRecord.fromJson(json);
      expect(record.authorDeathYear, '941');
      expect(record.status, RightsStatus.publicDomain);
      expect(record.reasoning, 'Deceased > 50 years');
      expect(record.rightsSource, 'Law No. 726, Art. 17');
      expect(record.fullTextAllowed, isTrue);
      expect(record.excerptAllowed, isTrue);
      expect(record.permissionReference, isNull);

      final serialized = record.toJson();
      expect(serialized['status'], 'publicDomain');
      expect(serialized['fullTextAllowed'], isTrue);

      final copy = record.copyWith(
        status: RightsStatus.blocked,
        fullTextAllowed: false,
      );
      expect(copy.status, RightsStatus.blocked);
      expect(copy.fullTextAllowed, isFalse);
      expect(copy.authorDeathYear, '941');
    });
  });

  group('SourceEdition', () {
    test('SourceEdition fromJson / toJson / copyWith and citation', () {
      final json = {
        'bookTitle': 'Ахтарони адаб: Рӯдакӣ',
        'authorAsPrinted': 'А. Рӯдакӣ',
        'editor': 'А. Абдуллоев',
        'volume': '1',
        'edition': '1',
        'publisher': 'Адиб',
        'city': 'Душанбе',
        'year': 1999,
        'isbn': '978-99947-2-123-4',
        'pageStart': 45,
        'pageEnd': 46,
        'sourceInstitution': 'КМТ',
        'sourceType': 'printed-book-scan',
        'sourceReference': 'INV-4412',
        'accessDate': '2026-09-10',
        'sourceImageVerified': true,
        'sourceImagePaths': [
          'assets/data/literature/page_images/page-45.png',
          'assets/data/literature/page_images/page-46.png',
        ],
      };

      final edition = SourceEdition.fromJson(json);
      expect(edition.bookTitle, 'Ахтарони адаб: Рӯдакӣ');
      expect(edition.year, '1999');
      expect(edition.pageStart, 45);
      expect(edition.pageEnd, 46);
      expect(edition.formattedPages, 'с. 45–46');
      expect(edition.sourceImageVerified, isTrue);
      expect(edition.sourceImagePaths, [
        'assets/data/literature/page_images/page-45.png',
        'assets/data/literature/page_images/page-46.png',
      ]);
      expect(
        () =>
            edition.sourceImagePaths.add('assets/data/literature/page-47.png'),
        throwsUnsupportedError,
      );
      expect(
        edition.citation,
        'А. Рӯдакӣ. Ахтарони адаб: Рӯдакӣ, ҷ. 1 / Зери таҳрири А. Абдуллоев — Душанбе: Адиб, 1999. — с. 45–46.',
      );

      final copy = edition.copyWith(pageEnd: 45);
      expect(copy.formattedPages, 'с. 45');

      final serialized = edition.toJson();
      expect(serialized['publisher'], 'Адиб');
      expect(serialized['sourceType'], 'printed-book-scan');
      expect(serialized['sourceImagePath'], endsWith('page-45.png'));
      expect(serialized['sourceImagePaths'], hasLength(2));
    });
  });

  group('LiteraryAuthor', () {
    test('LiteraryAuthor fromJson / toJson / copyWith', () {
      final json = {
        'id': 'rudaki',
        'canonicalName': 'Абӯабдуллоҳи Рӯдакӣ',
        'canonicalNamePersian': 'ابوعبدالله رودکی',
        'aliases': ['Одамушшуаро', 'Султони шоирон'],
        'birthYear': '858',
        'deathYear': '941',
        'birthPlace': 'Панҷрӯд, Панҷакент',
        'birthPlacePersian': 'پنج‌رود، پنجکنت',
        'literaryPeriod': 'Асри тиллоӣ (IX–X)',
        'literaryPeriodPersian': 'عصر طلایی (سده‌های ۹ و ۱۰)',
        'biographyTj': 'Сардафтари адабиёти классикии тоҷик.',
        'biographyFa': 'پدر شعر فارسی.',
        'biographySource': 'Таърихи адабиёти тоҷик, Дониш, 2012',
        'recordStatus': 'active',
        'majorWorkIds': ['boyi-juyi-muliyon'],
        'officialTitles': ['Одамушшуаро'],
        'officialTitlesPersian': ['آدم‌الشعرا'],
        'educationGrades': ['5', '8', '10'],
        'rights': {
          'status': 'public_domain',
          'reasoning': 'Deceased 941 CE (> 50 years)',
          'fullTextAllowed': true,
          'excerptAllowed': true,
        },
      };

      final author = LiteraryAuthor.fromJson(json);
      expect(author.id, 'rudaki');
      expect(author.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');
      expect(author.recordStatus, 'active');
      expect(author.isDeceased, isTrue);
      expect(author.lifespan, '858 – 941');
      expect(author.birthPlacePersian, 'پنج‌رود، پنجکنت');
      expect(author.literaryPeriodPersian, 'عصر طلایی (سده‌های ۹ و ۱۰)');
      expect(author.officialTitlesPersian, ['آدم‌الشعرا']);
      expect(author.hasAuditableBiographySource, isFalse);
      expect(author.biographyTjProvenance, 'UNSUPPORTED_GENERATED');
      expect(author.biographyFaProvenance, 'UNSUPPORTED_GENERATED');

      final pageCitedAuthor = author.copyWith(
        biographySource: 'Адабиёти тоҷик, синфи 5, с. 49',
        biographyTjProvenance: 'SOURCE_BACKED',
      );
      expect(pageCitedAuthor.hasAuditableBiographySource, isTrue);
      expect(author.isPublicDomain, isTrue);
      expect(author.aliases.length, 2);
      expect(author.educationGrades, ['5', '8', '10']);

      final serialized = author.toJson();
      expect(serialized['id'], 'rudaki');
      expect(serialized['birthPlacePersian'], 'پنج‌رود، پنجکنت');
      expect(serialized['literaryPeriodPersian'], 'عصر طلایی (سده‌های ۹ و ۱۰)');
      expect(serialized['officialTitlesPersian'], ['آدم‌الشعرا']);
      expect(
        (serialized['rights'] as Map<String, dynamic>)['status'],
        'publicDomain',
      );

      final copy = author.copyWith(biographyTj: 'Навшуда');
      expect(copy.biographyTj, 'Навшуда');
      expect(copy.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');
      expect(
        copy
            .copyWith(literaryPeriodPersian: 'دورهٔ تازه')
            .literaryPeriodPersian,
        'دورهٔ تازه',
      );
    });

    test(
      'a missing death year is not presented as proof that an author is alive',
      () {
        final author = LiteraryAuthor.fromJson({
          'id': 'unknown-death',
          'canonicalName': 'Шоири номаълум',
          'birthYear': '1947',
          'literaryPeriod': 'Адабиёти тоҷик',
          'biographyTj': '',
          'biographySource': '',
          'rights': {'status': 'unknown'},
        });

        expect(author.lifespan, '1947');
        expect(author.lifespan, isNot(contains('дар ҳаёт')));
      },
    );

    test('rejected extraction artifacts are not public authors', () {
      final author = LiteraryAuthor.fromJson({
        'id': 'artifact',
        'canonicalName': 'Мисраъҳои',
        'recordStatus': 'rejected',
        'literaryPeriod': 'Адабиёти тоҷик',
        'biographyTj': '',
        'biographySource': '',
        'rights': {'status': 'unknown'},
      });

      expect(author.hasCanonicalName, isFalse);
      expect(author.toJson()['recordStatus'], 'rejected');
      expect(author.copyWith(recordStatus: 'active').hasCanonicalName, isTrue);

      expect(author.copyWith(recordStatus: 'review').hasCanonicalName, isFalse);
    });

    test(
      'missing biography provenance cannot become source-backed at runtime',
      () {
        final author = LiteraryAuthor.fromJson({
          'id': 'unreviewed',
          'canonicalName': 'Ношинос',
          'literaryPeriod': 'номаълум',
          'biographyTj': 'Матни санҷиданашуда.',
          'biographySource': 'Китоб, с. 12',
          'rights': {'status': 'unknown'},
        });

        expect(author.hasAuditableBiographySource, isFalse);
        expect(author.hasAuditableTajikBiography, isFalse);
        expect(author.hasAuditablePersianBiography, isFalse);
      },
    );
  });

  group('LiteraryWork', () {
    test('preserves all source occurrences for one canonical work', () {
      final source = {
        'bookTitle': 'Адабиёти тоҷик, синфи 7',
        'publisher': 'Маориф',
        'city': 'Душанбе',
        'year': '2018',
        'pageStart': 104,
        'sourceType': 'textbook',
        'sourceReference': 'docs/literature/pdfs/adabiyot sinfi 7.pdf',
      };
      final work = LiteraryWork.fromJson({
        'id': 'kamol-canonical',
        'authorId': 'kamol_khujandi',
        'title': 'Гар биҷӯянд, ба сад қарн наёбанд, Камол',
        'type': 'poem',
        'sourceOccurrences': [source],
        'rights': {'status': 'unknown'},
        'verification': {'evidenceLevel': 'needsReview'},
      });

      expect(work.sourceOccurrences, hasLength(1));
      expect(work.sourceOccurrences.single.pageStart, 104);
      expect(
        LiteraryWork.fromJson(work.toJson()).sourceOccurrences,
        hasLength(1),
      );
    });

    test('Enums parse properly', () {
      expect(WorkType.fromString('ghazal'), WorkType.ghazal);
      expect(WorkType.fromString('rubai'), WorkType.rubai);
      expect(TextStatus.fromString('verified'), TextStatus.verified);
      expect(TextStatus.fromString('needs_review'), TextStatus.needsReview);
      expect(
        ScriptSource.fromString('persian_arabic'),
        ScriptSource.persianArabic,
      );
      expect(
        EditorialTransformation.fromString('none'),
        EditorialTransformation.none,
      );
    });

    test('Displayability accepts approved or permitted-source poems', () {
      const rightsAllowed = RightsRecord(
        status: RightsStatus.publicDomain,
        reasoning: 'PD',
        fullTextAllowed: true,
        excerptAllowed: true,
      );
      const verifiedRecord = VerificationRecord(
        evidenceLevel: VerificationLevel.editoriallyApproved,
        pageVerified: true,
      );

      const unverifiedWork = LiteraryWork(
        id: 'w1',
        authorId: 'rudaki',
        title: 'Бӯи ҷӯи Мӯлиён',
        primarySource: SourceEdition(
          bookTitle: 'Осори санҷишӣ',
          publisher: 'Нашриёт',
          city: 'Душанбе',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
          sourceImageVerified: true,
        ),
        rights: rightsAllowed,
        verification: VerificationRecord(
          evidenceLevel: VerificationLevel.editoriallyApproved,
          pageVerified: true,
        ),
        textStatus: TextStatus.needsReview,
      );
      expect(unverifiedWork.isDisplayable, isFalse);
      expect(unverifiedWork.hasAuditableReviewCitation, isFalse);
      expect(unverifiedWork.isPageImageDisplayable, isFalse);
      expect(
        unverifiedWork.isExcerptDisplayable,
        isFalse,
        reason: 'Review-only text must never be rendered as an excerpt.',
      );

      final pageLinkedReviewWork = unverifiedWork.copyWith(
        primarySource: unverifiedWork.primarySource!.copyWith(
          sourceReference: 'docs/literature/pdfs/review.pdf',
        ),
      );
      expect(pageLinkedReviewWork.hasAuditableReviewCitation, isTrue);

      final verifiedWork = unverifiedWork.copyWith(
        verification: verifiedRecord,
        textStatus: TextStatus.verified,
        textTajik: 'Бӯи ҷӯи Мӯлиён ояд ҳаме...',
      );
      expect(verifiedWork.isDisplayable, isTrue);
      expect(
        verifiedWork.isPageImageDisplayable,
        isFalse,
        reason:
            'A verified flag without a local image path must stay image-free.',
      );
      final verifiedWorkWithImage = verifiedWork.copyWith(
        primarySource: verifiedWork.primarySource!.copyWith(
          sourceImagePaths: const [
            'assets/data/literature/page_images/rudaki_gar_bar_sari_nafsi_grade6_2014_p12.png',
          ],
        ),
      );
      expect(verifiedWorkWithImage.isPageImageDisplayable, isTrue);
      expect(verifiedWork.hasTajikText, isTrue);

      final sourceAttestedWork = verifiedWork.copyWith(
        primarySource: verifiedWork.primarySource!.copyWith(
          sourceReference: 'docs/literature/pdfs/adabiet sinfi 5.pdf',
        ),
        rights: const RightsRecord(
          status: RightsStatus.unknown,
          reasoning: 'No separate rights determination recorded.',
          fullTextAllowed: false,
          excerptAllowed: false,
        ),
        verification: const VerificationRecord(
          evidenceLevel: VerificationLevel.primaryChecked,
          pageVerified: true,
        ),
      );
      expect(
        sourceAttestedWork.isDisplayable,
        isTrue,
        reason:
            'One page-checked uploaded textbook is sufficient under the publication policy.',
      );

      final untrustedSourceWork = sourceAttestedWork.copyWith(
        primarySource: sourceAttestedWork.primarySource!.copyWith(
          sourceReference: 'https://example.com/unreviewed.pdf',
        ),
      );
      expect(untrustedSourceWork.isDisplayable, isFalse);

      final blockedWork = verifiedWork.copyWith(textStatus: TextStatus.blocked);
      expect(blockedWork.isDisplayable, isFalse);
      expect(blockedWork.isExcerptDisplayable, isFalse);
    });

    test('verse coherence rejects fragments, one-word and stitched texts', () {
      const base = LiteraryWork(
        id: 'coherence-base',
        authorId: 'rudaki',
        title: 'Санҷиш',
        primarySource: SourceEdition(
          bookTitle: 'Китоби санҷишӣ',
          publisher: 'Нашриёт',
          city: 'Душанбе',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
        ),
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
        textStatus: TextStatus.verified,
      );

      // A genuine multi-hemistiche verse is coherent.
      expect(
        base
            .copyWith(
              textTajik:
                  'Бӯи ҷӯи Мӯлиён ояд ҳаме,\n'
                  'Ёди ёри мӯлиён ояд ҳаме,\n'
                  'Шӯхи қатронӣ ба ман, ёди дилбарӣ,\n'
                  'Абрӯи яккаи ҷаҳон ояд ҳаме.',
            )
            .hasCoherentVerseStructure,
        isTrue,
      );

      // A single bayt (2 hemistiches) is a fragment, never a readable poem.
      expect(
        base
            .copyWith(
              textTajik:
                  'Камол, аз Каъба рафтӣ бар дари ёр,\n'
                  'Ҳазорат офарин, мардона рафтӣ.',
            )
            .hasCoherentVerseStructure,
        isFalse,
        reason: 'A two-hemistich single bayt is a fragment of a ghazal.',
      );

      // A one-word text is not a work.
      expect(
        base.copyWith(textTajik: 'Ҳеч').hasCoherentVerseStructure,
        isFalse,
      );

      // Page/stitching markers from glued-together scans are not a work.
      expect(
        base
            .copyWith(
              textTajik:
                  'Агар ду бародар ниҳад пушт-пушт,\n'
                  'Тани кӯҳро хок молад ба мушт.\n'
                  '## 48 (Page 48)\n'
                  'Бузургӣ саросар ба гуфтор нест,\n'
                  'Дусад гуфта чун ними кирдор нест.',
            )
            .hasCoherentVerseStructure,
        isFalse,
        reason: 'Stitched pages are synthetic, not a coherent work.',
      );
    });

    test('verse coherence ignores appended attribution and truncated gloss lines', () {
      const base = LiteraryWork(
        id: 'coherence-noise',
        authorId: 'rudaki',
        title: 'Санҷиш',
        primarySource: SourceEdition(
          bookTitle: 'Китоби санҷишӣ',
          publisher: 'Нашриёт',
          city: 'Душанбе',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
        ),
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
        textStatus: TextStatus.verified,
      );

      // Real failure: a genuine four-hemistiche rubai with a truncated
      // prose-gloss line appended. The gloss must not add a hemistich.
      expect(
        base
            .copyWith(
              textTajik:
                  'Майлам ба шароби ноб бошад доим,\n'
                  'Гӯшам ба наю рубоб бошад доим.\n'
                  'Гар хоки маро кӯзагарон кӯза кунанд,\n'
                  'Он кӯза пур аз шароб бошад доим.\n'
                  'Хайём гуфтааст, ки агар лавҳаи қазо (тақдир, сарнавишт) дар',
            )
            .hasCoherentVerseStructure,
        isTrue,
        reason:
            'Four real hemistiches stay coherent; the gloss line is ignored.',
      );

      // Real failure: a genuine four-hemistiche poem with a pure
      // parenthesized author attribution appended.
      expect(
        base
            .copyWith(
              textTajik:
                  'Шоири фарзонаро асру замон\n'
                  'Бар ниёзи хештан меоварад.\n'
                  'Модаре танҳо назояд шоире,\n'
                  'Халқ ӯро баҳри худ меофарад.\n'
                  '(Лоиқ Шералӣ)',
            )
            .hasCoherentVerseStructure,
        isTrue,
        reason:
            'Four real hemistiches stay coherent; the attribution is ignored.',
      );

      // Appended noise must not inflate a genuine fragment into a readable work.
      expect(
        base
            .copyWith(
              textTajik:
                  'Шоири фарзонаро асру замон\n'
                  'Бар ниёзи хештан меоварад.\n'
                  '(Лоиқ Шералӣ)',
            )
            .hasCoherentVerseStructure,
        isFalse,
        reason:
            'Two real hemistiches plus an attribution line are still a fragment.',
      );
      expect(
        base
            .copyWith(
              textTajik:
                  'Майлам ба шароби ноб бошад доим,\n'
                  'Гӯшам ба наю рубоб бошад доим.\n'
                  'Хайём гуфтааст, ки агар лавҳаи қазо (тақдир, сарнавишт) дар',
            )
            .hasCoherentVerseStructure,
        isFalse,
        reason:
            'Two real hemistiches plus a truncated gloss are still a fragment.',
      );

      // A line that is only an attribution is not a work at all.
      expect(
        base.copyWith(textTajik: '(Лоиқ Шералӣ)').hasCoherentVerseStructure,
        isFalse,
      );

      // Legitimate counterexample: parenthetical text inside a genuine
      // hemistich is preserved and does not break coherence.
      expect(
        base
            .copyWith(
              textTajik:
                  'Майлам ба шароби ноб бошад доим,\n'
                  'Гӯшам ба наю рубоб бошад доим.\n'
                  'Гар хоки маро (эҳ, азиз) кӯзагарон кӯза кунанд,\n'
                  'Он кӯза пур аз шароб бошад доим.',
            )
            .hasCoherentVerseStructure,
        isTrue,
      );

      // Legitimate counterexample: a short three-hemistiche form stays coherent.
      expect(
        base
            .copyWith(
              textTajik:
                  'Бӯи ҷӯи Мӯлиён ояд ҳаме,\n'
                  'Ёди ёри мӯлиён ояд ҳаме,\n'
                  'Абрӯи яккаи ҷаҳон ояд ҳаме.',
            )
            .hasCoherentVerseStructure,
        isTrue,
        reason: 'A genuine short form must not be rejected.',
      );
    });

    test('generated Persian fields are never a Persian source witness', () {
      const generated = LiteraryWork(
        id: 'gen-persian',
        authorId: 'rudaki',
        title: 'Санҷиш',
        textTajik:
            'Бӯи ҷӯи Мӯлиён ояд ҳаме,\n'
            'Ёди ёри мӯлиён ояд ҳаме,\n'
            'Шӯхи қатронӣ ба ман, ёди дилбарӣ,\n'
            'Абрӯи яккаи ҷаҳон ояд ҳаме.',
        textPersian: 'بوی جوی مولیان آید همی',
        persianScriptSource: 'generated',
        primarySource: SourceEdition(
          bookTitle: 'Китоби санҷишӣ',
          publisher: 'Нашриёт',
          city: 'Душанбе',
          year: '2026',
          pageStart: 1,
          sourceType: SourceEditionType.criticalEdition,
        ),
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
        textStatus: TextStatus.verified,
      );
      expect(
        generated.hasPersianText,
        isFalse,
        reason:
            'A generated transliteration is not an original Persian witness.',
      );
      expect(generated.hasPersianDisplay, isTrue);
      expect(generated.hasCoherentVerseStructure, isTrue);
    });

    test('biography audit requires an allowlisted provenance value', () {
      final invalid = LiteraryAuthor.fromJson({
        'id': 'invalid-provenance',
        'canonicalName': 'Санҷиш',
        'literaryPeriod': 'Санҷиш',
        'biographyTj': 'Матни санҷишнашуда',
        'biographyFa': 'متن آزمایشی',
        'biographySource': 'Китоби санҷишӣ, с. 12',
        'biographyTjProvenance': 'UNTRUSTED_IMPORT',
        'biographyFaProvenance': 'UNTRUSTED_IMPORT',
        'rights': {
          'status': 'unknown',
          'reasoning': 'test',
          'fullTextAllowed': false,
          'excerptAllowed': false,
        },
      });

      expect(invalid.hasAuditableBiographySource, isFalse);
      expect(invalid.hasAuditableTajikBiography, isFalse);
      expect(invalid.hasAuditablePersianBiography, isFalse);
    });

    test('LiteraryWork fromJson / toJson roundtrip', () {
      final json = {
        'id': 'rudaki-boyi-juyi-muliyon',
        'authorId': 'rudaki',
        'title': 'Бӯи ҷӯи Мӯлиён',
        'titlePersian': 'بوی جوی مولیان',
        'incipit': 'Бӯи ҷӯи Мӯлиён ояд ҳаме',
        'type': 'ghazal',
        'scriptSource': 'both',
        'textTajik': '',
        'textPersian': '',
        'textStatus': 'needs_review',
        'editorial': 'none',
        'editorialNotes': 'Collation pending',
        'primarySource': {
          'bookTitle': 'Ахтарони адаб: Рӯдакӣ',
          'publisher': 'Адиб',
          'city': 'Душанбе',
          'year': '1999',
          'sourceType': 'printed-book-scan',
        },
        'textMatchResult': 'exact',
        'variantNotes': null,
        'rights': {
          'status': 'public_domain',
          'reasoning': 'Public domain',
          'fullTextAllowed': true,
          'excerptAllowed': true,
        },
        'verification': {'final_status': 'needs_review'},
      };

      final work = LiteraryWork.fromJson(json);
      expect(work.id, 'rudaki-boyi-juyi-muliyon');
      expect(work.type, WorkType.ghazal);
      expect(work.scriptSource, ScriptSource.both);
      expect(work.textStatus, TextStatus.needsReview);
      expect(work.primarySource?.bookTitle, 'Ахтарони адаб: Рӯдакӣ');
      expect(work.isDisplayable, isFalse);

      final serialized = work.toJson();
      expect(serialized['type'], 'ghazal');
      expect(serialized['scriptSource'], 'both');
      expect(
        (serialized['primarySource'] as Map<String, dynamic>)['city'],
        'Душанбе',
      );
    });
  });

  group('SchoolCanonEntry', () {
    test('SchoolCanonEntry fromJson / toJson / copyWith', () {
      final json = {
        'id': 'canon-rudaki-grade5',
        'workId': 'rudaki-boyi-juyi-muliyon',
        'authorId': 'rudaki',
        'grade': '5',
        'subject': 'Хониши адабӣ',
        'textbookTitle': 'Хониши адабӣ барои синфи 5',
        'textbookAuthors': 'С. Амирқулов',
        'textbookPublisher': 'Маориф',
        'textbookYear': '2019',
        'sourceId': 'tj_literature_grade_5_2017',
        'curriculumType': 'mandatory',
        'sourceEvidence': 'Барномаи таълимӣ, с. 34',
      };

      final entry = SchoolCanonEntry.fromJson(json);
      expect(entry.id, 'canon-rudaki-grade5');
      expect(entry.grade, '5');
      expect(entry.sourceId, 'tj_literature_grade_5_2017');
      expect(entry.isMandatory, isTrue);
      expect(entry.isCitationVerified, isFalse);

      final serialized = entry.toJson();
      expect(serialized['subject'], 'Хониши адабӣ');

      final copy = entry.copyWith(curriculumType: 'recommended');
      expect(copy.isMandatory, isFalse);
    });
  });

  group('OralHeritageEntry', () {
    test('OralHeritageType fromString parsing', () {
      expect(
        OralHeritageType.fromString('zarbulmasal'),
        OralHeritageType.zarbulmasal,
      );
      expect(OralHeritageType.fromString('maqol'), OralHeritageType.maqol);
      expect(OralHeritageType.fromString('chiston'), OralHeritageType.chiston);
      expect(
        OralHeritageType.fromString('dubayti_khalqi'),
        OralHeritageType.dubaytiKhalqi,
      );
      expect(
        OralHeritageType.fromString('rubai_khalqi'),
        OralHeritageType.rubaiKhalqi,
      );
      expect(OralHeritageType.fromString('afsona'), OralHeritageType.afsona);
      expect(OralHeritageType.fromString('unknown'), OralHeritageType.other);
    });

    test('OralHeritageEntry fromJson / toJson / copyWith and citation', () {
      final json = {
        'id': 'folk-maqol-001',
        'text': 'Офтобро бо доман пӯшида намешавад.',
        'textPersian': 'آفتاب را با دامن پوشیده نمی‌شود.',
        'type': 'zarbulmasal',
        'region': 'Умумитоҷикӣ',
        'collectionSource': 'Зарбулмасалҳои тоҷикӣ',
        'collector': 'Б. Шермуҳаммадов',
        'publisher': 'Дониш',
        'year': '1975',
        'page': '84',
        'verification': {
          'final_status': 'approved',
          'primary_source_checked': true,
          'second_source_checked': true,
          'title_checked': true,
          'authorship_checked': true,
          'page_checked': true,
          'text_line_by_line_checked': true,
          'script_checked': true,
          'copyright_checked': true,
        },
      };

      final entry = OralHeritageEntry.fromJson(json);
      expect(entry.id, 'folk-maqol-001');
      expect(entry.type, OralHeritageType.zarbulmasal);

      expect(
        entry.citation,
        'Б. Шермуҳаммадов. Зарбулмасалҳои тоҷикӣ — Дониш, 1975. — с. 84.',
      );

      final serialized = entry.toJson();
      expect(serialized['text'], 'Офтобро бо доман пӯшида намешавад.');
      expect(serialized['type'], 'zarbulmasal');

      final copy = entry.copyWith(region: 'Бадахшон');
      expect(copy.region, 'Бадахшон');
    });
  });
}
