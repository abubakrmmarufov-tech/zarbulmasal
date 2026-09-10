import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Literary Content Validation', () {
    late List poets;
    late List works;
    late List sources;
    late List canon;
    late List oral;

    setUpAll(() {
      poets = jsonDecode(File('assets/data/literature/poets.json').readAsStringSync()) as List;
      works = jsonDecode(File('assets/data/literature/works.json').readAsStringSync()) as List;
      sources = jsonDecode(File('assets/data/literature/sources.json').readAsStringSync()) as List;
      canon = jsonDecode(File('assets/data/literature/school_canon.json').readAsStringSync()) as List;
      oral = jsonDecode(File('assets/data/literature/oral_heritage.json').readAsStringSync()) as List;
    });

    test('No duplicate IDs', () {
      final poetIds = poets.map((p) => p['id']).toSet();
      expect(poetIds.length, poets.length, reason: 'Duplicate poet IDs found');

      final workIds = works.map((w) => w['id']).toSet();
      expect(workIds.length, works.length, reason: 'Duplicate work IDs found');

      final sourceIds = sources.map((s) => s['id']).toSet();
      expect(sourceIds.length, sources.length, reason: 'Duplicate source IDs found');
    });

    test('All authors referenced by works exist', () {
      final poetIds = poets.map((p) => p['id']).toSet();
      for (final work in works) {
        expect(poetIds.contains(work['authorId']), isTrue,
            reason: "Work ${work['id']} references unknown author ${work['authorId']}");
      }
    });

    test('All works referenced by school canon exist', () {
      final workIds = works.map((w) => w['id']).toSet();
      for (final entry in canon) {
        if (entry['workId'] != null && entry['workId'].toString().isNotEmpty) {
           expect(workIds.contains(entry['workId']), isTrue,
            reason: "Canon entry ${entry['id']} references unknown work ${entry['workId']}");
        }
      }
    });

    test('Approved works have required provenance and rights', () {
      for (final work in works) {
        final verification = work['verification'] ?? {};
        if (verification['finalStatus'] == 'approved') {
          expect(work['primarySource'], isNotNull,
              reason: "Approved work ${work['id']} missing primarySource");
          expect(work['textStatus'], equals('verified'),
              reason: "Approved work ${work['id']} must have verified textStatus");
          
          final rights = work['rights'];
          expect(rights, isNotNull, reason: "Work ${work['id']} missing rights");
          expect(rights['status'], isNot(equals('unknown')),
              reason: "Approved work ${work['id']} has unknown rights");
          expect(rights['status'], isNot(equals('blocked')),
              reason: "Approved work ${work['id']} has blocked rights");
        }
      }
    });
  });
}
