import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/history/domain/history_entry.dart';
import 'package:zarbulmasal/features/history/domain/history_section.dart';

void main() {
  group('HistoryDetailSection round-trip', () {
    test('preserves all fields through toJson/fromJson', () {
      const section = HistoryDetailSection(
        heading: 'Замин ва пайдоиш',
        headingPersian: 'سرزمین و پیدایش',
        body: 'Матоне дар бораи пайдоиш.\n\nПорчаи дуюм.',
        bodyPersian: 'متن درباره پیدایش.\n\nپاراگراف دوم.',
        sourceBookId: 'history-5',
        printedPage: 34,
        pdfPage: 34,
        persianIsEditorial: true,
      );

      final restored = HistoryDetailSection.fromJson(section.toJson());
      expect(restored.toJson(), equals(section.toJson()));
      expect(restored.body, contains('Порчаи дуюм.'));
      expect(restored.persianIsEditorial, isTrue);
    });

    test('omits optional keys when absent', () {
      const section = HistoryDetailSection(heading: 'Ном', body: 'Матн');

      final json = section.toJson();
      expect(json.containsKey('bodyPersian'), isFalse);
      expect(json.containsKey('printedPage'), isFalse);
      expect(json.containsKey('sourceBookId'), isFalse);
    });

    test('fails closed on invalid or incomplete data', () {
      final empty = HistoryDetailSection.fromJson(const {});
      expect(empty.heading, isEmpty);
      expect(empty.body, isEmpty);
      expect(empty.printedPage, isNull);

      final typed = HistoryDetailSection.fromJson({
        'heading': 123,
        'body': ['not', 'a', 'string'],
        'printedPage': 'not-a-number',
        'pdfPage': null,
        'sourceBookId': 42,
      });
      expect(typed.heading, isEmpty);
      expect(typed.body, isEmpty);
      expect(typed.printedPage, isNull);
      expect(typed.sourceBookId, isNull);

      final strings = HistoryDetailSection.fromJson({
        'heading': 'Ном',
        'body': 'Матн',
        'printedPage': 12.7,
        'pdfPage': 12.7,
      });
      expect(strings.printedPage, 12);
      expect(strings.pdfPage, 12);
    });

    test('defaults persianIsEditorial to true when Persian is supplied', () {
      final section = HistoryDetailSection.fromJson({
        'heading': 'Ном',
        'body': 'Матн',
        'bodyPersian': 'متن',
      });
      expect(section.persianIsEditorial, isTrue);
    });

    test('round-trips an inclusive printed/PDF page range', () {
      const section = HistoryDetailSection(
        heading: 'Сохтор',
        body: 'Матн.',
        printedPage: 133,
        pdfPage: 133,
        printedPageEnd: 137,
        pdfPageEnd: 137,
      );

      final restored = HistoryDetailSection.fromJson(section.toJson());
      expect(restored.printedPage, 133);
      expect(restored.printedPageEnd, 137);
      expect(restored.pdfPageEnd, 137);
      expect(restored.toJson(), equals(section.toJson()));
    });

    test('range end fields are optional and default to null', () {
      const section = HistoryDetailSection(
        heading: 'Ном',
        body: 'Матн',
        printedPage: 12,
        pdfPage: 12,
      );

      final json = section.toJson();
      expect(json.containsKey('printedPageEnd'), isFalse);
      expect(json.containsKey('pdfPageEnd'), isFalse);
      final restored = HistoryDetailSection.fromJson(json);
      expect(restored.printedPageEnd, isNull);
      expect(restored.pdfPageEnd, isNull);
    });

    test('range end fields fail closed on malformed values', () {
      final section = HistoryDetailSection.fromJson({
        'heading': 'Ном',
        'body': 'Матн',
        'printedPageEnd': 'seven',
        'pdfPageEnd': 12.9,
      });

      expect(section.printedPageEnd, isNull);
      expect(section.pdfPageEnd, 12);
    });
  });

  group('HistoryEntry sections integration', () {
    test('entry round-trips a full sections list', () {
      final json = <String, dynamic>{
        'id': 'empire-samanid',
        'kind': 'empire',
        'title': 'Сомониён',
        'summary': 'Хулоса.',
        'period': 'Асрҳои IX–X',
        'grade': '7',
        'sourceBookId': 'history-7',
        'sourceSection': 'Боби II',
        'keywords': [],
        'sections': [
          {
            'heading': 'Замин ва пайдоиш',
            'headingPersian': 'سرزمین و پیدایش',
            'body': 'Матни порчаи аввал.\n\nМатни порчаи дуюм.',
            'bodyPersian': 'متن پاراگراف اول.\n\nمتن پاراگراف دوم.',
            'sourceBookId': 'history-7',
            'printedPage': 56,
            'pdfPage': 56,
            'persianIsEditorial': true,
          },
          {
            'heading': 'Дарбор ва идора',
            'body': 'Матни давлатдорӣ.',
            'printedPage': 58,
          },
        ],
      };

      final entry = HistoryEntry.fromJson(json);
      expect(entry.sections, hasLength(2));
      expect(entry.sections.first.headingPersian, 'سرزمین و پیدایش');
      expect(entry.sections.last.bodyPersian, isNull);
      expect(entry.toJson()['sections'], equals(json['sections']));
      expect(entry.toJson(), equals(json));
    });

    test('missing or malformed sections default to an empty list safely', () {
      final missing = HistoryEntry.fromJson({
        'id': 'x',
        'kind': 'event',
        'title': 'X',
        'summary': '',
        'period': '',
        'grade': '5',
        'sourceBookId': 'history-5',
        'sourceSection': '',
      });
      expect(missing.sections, isEmpty);
      expect(missing.toJson().containsKey('sections'), isFalse);

      final malformed = HistoryEntry.fromJson({
        'id': 'y',
        'kind': 'event',
        'title': 'Y',
        'summary': '',
        'period': '',
        'grade': '5',
        'sourceBookId': 'history-5',
        'sourceSection': '',
        'sections': [
          'ignored-string',
          7,
          {'heading': 'Ok', 'body': 'Танҳо бахши дуруст.'},
          null,
        ],
      });
      expect(malformed.sections, hasLength(1));
      expect(malformed.sections.single.heading, 'Ok');
      expect(malformed.sections.single.body, 'Танҳо бахши дуруст.');
    });

    test('entry round-trips a section with an inclusive page range', () {
      final json = <String, dynamic>{
        'id': 'empire-kushan',
        'kind': 'empire',
        'title': 'Кӯшониён',
        'summary': 'Хулоса.',
        'period': 'Асрҳои I–III',
        'grade': '6',
        'sourceBookId': 'history-6',
        'sourceSection': 'Боби III',
        'keywords': [],
        'sections': [
          {
            'heading': 'Таърихи Кушониён',
            'body': 'Матн.',
            'printedPage': 192,
            'pdfPage': 192,
            'printedPageEnd': 194,
            'pdfPageEnd': 194,
          },
        ],
      };

      final entry = HistoryEntry.fromJson(json);
      final section = entry.sections.single;
      expect(section.printedPage, 192);
      expect(section.printedPageEnd, 194);
      expect(section.pdfPageEnd, 194);
      expect(entry.toJson(), equals(json));
    });

    test('sections can reference a different source book than the entry', () {
      const section = HistoryDetailSection(
        heading: 'Корнома',
        body: 'Матн',
        sourceBookId: 'history-6',
      );
      const entry = HistoryEntry(
        id: 'e',
        kind: HistoryEntryKind.event,
        title: 'E',
        summary: '',
        period: '',
        grade: '7',
        sourceBookId: 'history-7',
        sourceSection: '',
        sections: [section],
      );
      expect(entry.sections.single.sourceBookId, 'history-6');
      expect(entry.sourceBookId, 'history-7');
    });
  });

  group('bundled History reading sections', () {
    final entries =
        (jsonDecode(File('assets/data/history/entries.json').readAsStringSync())
                as List)
            .cast<Map<String, dynamic>>();
    final books =
        (jsonDecode(File('assets/data/history/books.json').readAsStringSync())
                as List)
            .cast<Map<String, dynamic>>();
    final bookIds = books.map((b) => b['id']).toSet();

    test('every empire and dynasty has a cited reading section', () {
      final thin = entries
          .where((e) => e['kind'] == 'empire')
          .where((e) => (e['sections'] as List?)?.isEmpty ?? true)
          .map((e) => e['id'])
          .toList();
      expect(thin, isEmpty);
    });

    test('each section cites a known textbook and a page', () {
      for (final entry in entries) {
        for (final raw in (entry['sections'] as List?) ?? const []) {
          final section = HistoryDetailSection.fromJson(
            raw as Map<String, dynamic>,
          );
          final book = section.sourceBookId ?? entry['sourceBookId'];
          expect(bookIds, contains(book), reason: '${entry['id']}');
          expect(section.printedPage, isNotNull, reason: '${entry['id']}');
          expect(section.body.trim(), isNotEmpty);
        }
      }
    });

    test('grade 6-11 textbooks link to their maorif.tj PDF', () {
      for (final book in books.where(
        (b) => (b['id'] as String).startsWith('history-') && b['grade'] != '5',
      )) {
        expect(
          book['textbookPdfUrl'],
          startsWith('https://maorif.tj/storage/libraries/'),
        );
      }
    });
  });
}
