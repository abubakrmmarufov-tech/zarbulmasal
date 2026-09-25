import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/literary_author.dart';
import 'package:zarbulmasal/features/literature/domain/literary_work.dart';
import 'package:zarbulmasal/features/literature/domain/rights_record.dart';
import 'package:zarbulmasal/features/literature/domain/source_edition.dart';
import 'package:zarbulmasal/features/literature/domain/verification_record.dart';

void main() {
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
}
