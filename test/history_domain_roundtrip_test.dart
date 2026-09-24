import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/history/domain/history_book.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';
import 'package:zarbulmasal/features/history/domain/history_epoch.dart';
import 'package:zarbulmasal/features/history/domain/history_section.dart';

void main() {
  test('history claim provenance preserves optional evidence fields', () {
    const claim = HistoryClaimProvenance(
      claim: 'A source-backed claim',
      claimPersian: 'ادعای مستند',
      sourceBookId: 'history-5',
      printedPage: 42,
      pdfPage: 47,
      status: 'NEEDS_REVIEW',
      statusNote: 'Second witness required',
    );

    expect(
      HistoryClaimProvenance.fromJson(claim.toJson()).toJson(),
      equals(claim.toJson()),
    );
  });

  test('missing or unknown claim status fails closed', () {
    final missing = HistoryClaimProvenance.fromJson({
      'claim': 'A claim',
      'sourceBookId': 'history-5',
    });
    final unknown = HistoryClaimProvenance.fromJson({
      'claim': 'A claim',
      'sourceBookId': 'history-5',
      'status': 'invented-status',
    });

    expect(missing.status, 'NEEDS_REVIEW');
    expect(unknown.status, 'NEEDS_REVIEW');
  });

  test('directly constructed unknown claim status fails closed', () {
    const claim = HistoryClaimProvenance(
      claim: 'A claim',
      sourceBookId: 'history-5',
      status: 'invented-status',
    );

    expect(claim.status, 'NEEDS_REVIEW');
    expect(claim.toJson()['status'], 'NEEDS_REVIEW');
  });

  test('history entries round-trip the complete structured record', () {
    final json = <String, dynamic>{
      'id': 'samanids',
      'kind': 'dynasty',
      'title': 'Сомониён',
      'titlePersian': 'سامانیان',
      'summary': 'A source-backed summary.',
      'summaryPersian': 'خلاصه مستند.',
      'period': 'Асрҳои IX–X',
      'periodPersian': 'قرن‌های ۹–۱۰',
      'grade': '6',
      'sourceBookId': 'history-6',
      'sourceSection': 'Давлати Сомониён',
      'keywords': ['сомониён', 'Бухоро'],
      'capital': 'Бухоро',
      'capitalPersian': 'بخارا',
      'territory': 'Мовароуннаҳр',
      'territoryPersian': 'ماوراءالنهر',
      'keyFigures': ['Исмоили Сомонӣ'],
      'keyFiguresPersian': ['اسماعیل سامانی'],
      'significance': 'A cultural centre.',
      'significancePersian': 'مرکز فرهنگی.',
      'dates': '819–999',
      'datesPersian': '۸۱۹–۹۹۹',
      'founder': 'Исмоили Сомонӣ',
      'founderPersian': 'اسماعیل سامانی',
      'rulers': ['Исмоил', 'Наср'],
      'rulersPersian': ['اسماعیل', 'نصر'],
      'predecessor': 'Саффориён',
      'successor': 'Қарахониён',
      'religion': 'Ислом',
      'religionPersian': 'اسلام',
      'origins': 'Мовароуннаҳр',
      'originsPersian': 'ماوراءالنهر',
      'culture': 'Рушди адабиёт',
      'culturePersian': 'رشد ادبیات',
      'decline': 'Тағйири ҳокимият',
      'declinePersian': 'تغییر قدرت',
      'relatedAuthorIds': ['rudaki'],
      'relatedWorkIds': ['rudaki-poem'],
      'relatedEntryIds': ['samanid-capital'],
      'claimProvenance': [
        {
          'claim': 'The capital was Bukhara.',
          'sourceBookId': 'history-6',
          'printedPage': 88,
          'pdfPage': 94,
          'status': 'VERIFIED_UPLOADED_BOOK_PAGE',
        },
      ],
      'sections': [
        {
          'heading': 'Замин ва пайдоиш',
          'headingPersian': 'سرزمین و پیدایش',
          'body': 'Матни порчаи аввал.\n\nМатни порчаи дуюм.',
          'bodyPersian': 'متن پاراگراف اول.',
          'sourceBookId': 'history-6',
          'printedPage': 89,
          'pdfPage': 95,
          'printedPageEnd': 92,
          'pdfPageEnd': 98,
          'persianIsEditorial': true,
        },
      ],
    };

    final entry = HistoryEntry.fromJson(json);

    expect(entry.kind, HistoryEntryKind.dynasty);
    expect(entry.epoch, HistoryEpoch.samanid);
    expect(entry.sections, hasLength(1));
    expect(entry.sections.single, isA<HistoryDetailSection>());
    expect(entry.toJson(), equals(json));
  });

  test('history entries use safe defaults for incomplete or unknown data', () {
    final entry = HistoryEntry.fromJson({
      'id': 'unknown',
      'kind': 'not-a-kind',
      'grade': 8,
      'keywords': ['event', 12],
      'claimProvenance': [
        {'claim': 'kept'},
        'ignored',
      ],
      'sections': [
        'ignored-string',
        {'heading': 'Ok', 'body': 'Танҳо бахши дуруст.'},
      ],
    });

    expect(entry.kind, HistoryEntryKind.event);
    expect(entry.grade, '8');
    expect(entry.keywords, ['event']);
    expect(entry.claimProvenance.single.claim, 'kept');
    expect(entry.sections.single.heading, 'Ok');
    expect(entry.sections.single.body, 'Танҳо бахши дуруст.');
    expect(entry.toJson(), {
      'id': 'unknown',
      'kind': 'event',
      'title': '',
      'summary': '',
      'period': '',
      'grade': '8',
      'sourceBookId': '',
      'sourceSection': '',
      'keywords': ['event'],
      'claimProvenance': [
        {'claim': 'kept', 'sourceBookId': '', 'status': 'NEEDS_REVIEW'},
      ],
      'sections': [
        {'heading': 'Ok', 'body': 'Танҳо бахши дуруст.'},
      ],
    });
  });

  test(
    'history book round-trips metadata and keeps unsafe links unavailable',
    () {
      final book = HistoryBook.fromJson({
        'id': 'history-7',
        'grade': 7,
        'title': 'History',
        'titlePersian': 'تاریخ',
        'author': 'Author',
        'authorPersian': 'نویسنده',
        'year': 2018,
        'edition': 'Second',
        'description': 'Description',
        'descriptionPersian': 'شرح',
        'sourceUrl': 'https://maorif.tj/history',
        'isUploadedBook': true,
        'localPath': '/books/history-7.pdf',
        'pages': 320,
        'publisher': 'Маориф',
      });

      expect(book.toJson(), {
        'id': 'history-7',
        'grade': '7',
        'title': 'History',
        'titlePersian': 'تاریخ',
        'author': 'Author',
        'authorPersian': 'نویسنده',
        'year': '2018',
        'edition': 'Second',
        'description': 'Description',
        'descriptionPersian': 'شرح',
        'sourceUrl': 'https://maorif.tj/history',
        'isUploadedBook': true,
        'localPath': '/books/history-7.pdf',
        'pages': 320,
        'publisher': 'Маориф',
      });
      expect(book.externalSourceUri, isNotNull);
    },
  );

  test('history epoch labels and language selection are complete', () {
    for (final epoch in HistoryEpoch.values) {
      expect(epoch.labelTajik, isNotEmpty);
      expect(epoch.labelPersian, isNotEmpty);
      expect(epoch.periodTajik, isNotEmpty);
      expect(epoch.periodPersian, isNotEmpty);
      expect(epoch.label('DisplayLanguage.persian'), epoch.labelPersian);
      expect(epoch.period('DisplayLanguage.persian'), epoch.periodPersian);
      expect(epoch.label('DisplayLanguage.tajik'), epoch.labelTajik);
      expect(epoch.period('DisplayLanguage.tajik'), epoch.periodTajik);
    }
  });
}
