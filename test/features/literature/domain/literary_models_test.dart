import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/domain/oral_heritage_entry.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/school_canon_entry.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';

void main() {
  group('RightsRecord and RightsStatus', () {
    test('RightsStatus fromString handles case and format variations', () {
      expect(RightsStatus.fromString('publicDomain'), RightsStatus.publicDomain);
      expect(RightsStatus.fromString('public_domain'), RightsStatus.publicDomain);
      expect(RightsStatus.fromString('PUBLIC_DOMAIN'), RightsStatus.publicDomain);
      expect(RightsStatus.fromString('permission_granted'), RightsStatus.permissionGranted);
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

      final copy = record.copyWith(status: RightsStatus.blocked, fullTextAllowed: false);
      expect(copy.status, RightsStatus.blocked);
      expect(copy.fullTextAllowed, isFalse);
      expect(copy.authorDeathYear, '941');
    });
  });

  group('VerificationRecord and VerificationStatus', () {
    test('VerificationStatus fromString parsing', () {
      expect(VerificationStatus.fromString('approved'), VerificationStatus.approved);
      expect(VerificationStatus.fromString('rejected'), VerificationStatus.rejected);
      expect(VerificationStatus.fromString('needs_review'), VerificationStatus.needsReview);
      expect(VerificationStatus.fromString('needsReview'), VerificationStatus.needsReview);
      expect(VerificationStatus.fromString('unknown'), VerificationStatus.needsReview);
    });

    test('isFullyVerified requires all 8 checks and approved status', () {
      const incomplete = VerificationRecord(
        primarySourceChecked: true,
        secondSourceChecked: true,
        finalStatus: VerificationStatus.approved,
      );
      expect(incomplete.isFullyVerified, isFalse);

      const complete = VerificationRecord(
        verifiedBy: 'Senior Editor',
        verifiedDate: '2026-09-10',
        primarySourceChecked: true,
        secondSourceChecked: true,
        titleChecked: true,
        authorshipChecked: true,
        pageChecked: true,
        textLineByLineChecked: true,
        scriptChecked: true,
        copyrightChecked: true,
        finalStatus: VerificationStatus.approved,
      );
      expect(complete.isFullyVerified, isTrue);
    });

    test('VerificationRecord fromJson / toJson / copyWith', () {
      final json = {
        'verified_by': 'Test Editor',
        'verified_date': '2026-09-10',
        'primary_source_checked': true,
        'second_source_checked': true,
        'title_checked': true,
        'authorship_checked': true,
        'page_checked': true,
        'text_line_by_line_checked': true,
        'script_checked': true,
        'copyright_checked': true,
        'final_status': 'approved',
        'rejection_reason': null,
      };

      final record = VerificationRecord.fromJson(json);
      expect(record.isFullyVerified, isTrue);
      expect(record.verifiedBy, 'Test Editor');

      final serialized = record.toJson();
      expect(serialized['finalStatus'], 'approved');

      final rejected = record.copyWith(
        finalStatus: VerificationStatus.rejected,
        rejectionReason: 'Variant mismatch',
      );
      expect(rejected.finalStatus, VerificationStatus.rejected);
      expect(rejected.rejectionReason, 'Variant mismatch');
      expect(rejected.isFullyVerified, isFalse);
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
      };

      final edition = SourceEdition.fromJson(json);
      expect(edition.bookTitle, 'Ахтарони адаб: Рӯдакӣ');
      expect(edition.year, '1999');
      expect(edition.pageStart, 45);
      expect(edition.pageEnd, 46);
      expect(edition.formattedPages, 'с. 45–46');
      expect(edition.sourceImageVerified, isTrue);
      expect(
        edition.citation,
        'А. Рӯдакӣ. Ахтарони адаб: Рӯдакӣ, ҷ. 1 / Зери таҳрири А. Абдуллоев — Душанбе: Адиб, 1999. — с. 45–46.',
      );

      final copy = edition.copyWith(pageEnd: 45);
      expect(copy.formattedPages, 'с. 45');

      final serialized = edition.toJson();
      expect(serialized['publisher'], 'Адиб');
      expect(serialized['sourceType'], 'printed-book-scan');
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
        'literaryPeriod': 'Асри тиллоӣ (IX–X)',
        'biographyTj': 'Сардафтари адабиёти классикии тоҷик.',
        'biographyFa': 'پدر شعر فارسی.',
        'biographySource': 'Таърихи адабиёти тоҷик, Дониш, 2012',
        'majorWorkIds': ['boyi-juyi-muliyon'],
        'officialTitles': ['Одамушшуаро'],
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
      expect(author.isDeceased, isTrue);
      expect(author.lifespan, '858 – 941');
      expect(author.isPublicDomain, isTrue);
      expect(author.aliases.length, 2);
      expect(author.educationGrades, ['5', '8', '10']);

      final serialized = author.toJson();
      expect(serialized['id'], 'rudaki');
      expect((serialized['rights'] as Map<String, dynamic>)['status'], 'publicDomain');

      final copy = author.copyWith(biographyTj: 'Навшуда');
      expect(copy.biographyTj, 'Навшуда');
      expect(copy.canonicalName, 'Абӯабдуллоҳи Рӯдакӣ');
    });
  });

  group('LiteraryWork', () {
    test('Enums parse properly', () {
      expect(WorkType.fromString('ghazal'), WorkType.ghazal);
      expect(WorkType.fromString('rubai'), WorkType.rubai);
      expect(TextStatus.fromString('verified'), TextStatus.verified);
      expect(TextStatus.fromString('needs_review'), TextStatus.needsReview);
      expect(ScriptSource.fromString('persian_arabic'), ScriptSource.persianArabic);
      expect(EditorialTransformation.fromString('none'), EditorialTransformation.none);
    });

    test('Displayability logic enforces rights, verification, and textStatus', () {
      const rightsAllowed = RightsRecord(
        status: RightsStatus.publicDomain,
        reasoning: 'PD',
        fullTextAllowed: true,
        excerptAllowed: true,
      );
      const verifiedRecord = VerificationRecord(
        primarySourceChecked: true,
        secondSourceChecked: true,
        titleChecked: true,
        authorshipChecked: true,
        pageChecked: true,
        textLineByLineChecked: true,
        scriptChecked: true,
        copyrightChecked: true,
        finalStatus: VerificationStatus.approved,
      );

      const unverifiedWork = LiteraryWork(
        id: 'w1',
        authorId: 'rudaki',
        title: 'Бӯи ҷӯи Мӯлиён',
        rights: rightsAllowed,
        verification: VerificationRecord(),
        textStatus: TextStatus.needsReview,
      );
      expect(unverifiedWork.isDisplayable, isFalse);
      expect(unverifiedWork.isExcerptDisplayable, isTrue);

      final verifiedWork = unverifiedWork.copyWith(
        verification: verifiedRecord,
        textStatus: TextStatus.verified,
        textTajik: 'Бӯи ҷӯи Мӯлиён ояд ҳаме...',
      );
      expect(verifiedWork.isDisplayable, isTrue);
      expect(verifiedWork.hasTajikText, isTrue);

      final blockedWork = verifiedWork.copyWith(
        textStatus: TextStatus.blocked,
      );
      expect(blockedWork.isDisplayable, isFalse);
      expect(blockedWork.isExcerptDisplayable, isFalse);
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
        'verification': {
          'final_status': 'needs_review',
        },
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
      expect((serialized['primarySource'] as Map<String, dynamic>)['city'], 'Душанбе');
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
        'curriculumType': 'mandatory',
        'sourceEvidence': 'Барномаи таълимӣ, с. 34',
      };

      final entry = SchoolCanonEntry.fromJson(json);
      expect(entry.id, 'canon-rudaki-grade5');
      expect(entry.grade, '5');
      expect(entry.isMandatory, isTrue);

      final serialized = entry.toJson();
      expect(serialized['subject'], 'Хониши адабӣ');

      final copy = entry.copyWith(curriculumType: 'recommended');
      expect(copy.isMandatory, isFalse);
    });
  });

  group('OralHeritageEntry', () {
    test('OralHeritageType fromString parsing', () {
      expect(OralHeritageType.fromString('zarbulmasal'), OralHeritageType.zarbulmasal);
      expect(OralHeritageType.fromString('maqol'), OralHeritageType.maqol);
      expect(OralHeritageType.fromString('chiston'), OralHeritageType.chiston);
      expect(OralHeritageType.fromString('dubayti_khalqi'), OralHeritageType.dubaytiKhalqi);
      expect(OralHeritageType.fromString('rubai_khalqi'), OralHeritageType.rubaiKhalqi);
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
      expect(entry.isVerified, isTrue);
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
