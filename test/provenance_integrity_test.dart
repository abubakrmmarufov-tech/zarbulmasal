import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Provenance Integrity Guard', () {
    late List<dynamic> works;

    setUpAll(() {
      final worksFile = File('assets/data/literature/works.json');
      works = jsonDecode(worksFile.readAsStringSync()) as List<dynamic>;
    });

    test('Works with exact page numbers must have photographic or high-quality source evidence', () {
      for (final work in works) {
        final w = work as Map<String, dynamic>;
        final p = w['primarySource'] as Map<String, dynamic>?;
        
        if (p != null && p['pageBoundary'] != null) {
          final verification = w['verification'] as Map<String, dynamic>?;
          final level = verification?['evidenceLevel'] as String? ?? 'extracted';
          
          // If we claim to know the page number, the level MUST be sourceLocated or higher
          // and we MUST NOT just have a placeholder
          expect(
            level, 
            isNot(equals('extracted')), 
            reason: 'Work ${w['id']} claims page ${p['pageBoundary']} but evidence level is only extracted.'
          );
        }
      }
    });

    test('No generic secondary source spam', () {
      int commonSecondaryCount = 0;
      
      for (final work in works) {
        final w = work as Map<String, dynamic>;
        final s = w['secondWitness'] as Map<String, dynamic>?;
        
        if (s != null && s['description'] == 'Academic collation source') {
          commonSecondaryCount++;
        }
      }
      
      // If someone mass-added "Academic collation source" to more than 100 works, it's a hallucination
      expect(
        commonSecondaryCount,
        lessThan(100),
        reason: 'Detected massive generic secondary source usage ($commonSecondaryCount instances). This indicates fake verification.'
      );
    });

    test('No fake institutional verifiedBy names', () {
      final fakeInstitutions = [
        'Institute of Language and Literature',
        'Институти забон ва адабиёт',
        'Academy of Sciences',
        'AI Verifier',
        'Zarbulmasal System'
      ];
      
      for (final work in works) {
        final w = work as Map<String, dynamic>;
        final v = w['verification'] as Map<String, dynamic>?;
        
        if (v != null) {
          final verifiedBy = (v['verifiedBy'] as List<dynamic>?)?.cast<String>() ?? [];
          for (final person in verifiedBy) {
            for (final fake in fakeInstitutions) {
              expect(
                person.toLowerCase().contains(fake.toLowerCase()),
                isFalse,
                reason: 'Work ${w['id']} uses a fake or institutional verifiedBy: $person'
              );
            }
          }
        }
      }
    });

    test('No bulk verification of 100% of the corpus', () {
      int editoriallyApproved = 0;
      int sourceLocated = 0;
      
      for (final work in works) {
        final w = work as Map<String, dynamic>;
        final v = w['verification'] as Map<String, dynamic>?;
        final level = v?['evidenceLevel'] as String? ?? 'extracted';
        
        if (level == 'editoriallyApproved') editoriallyApproved++;
        if (level == 'sourceLocated') sourceLocated++;
      }
      
      // It is impossible for humans to verify 100% of the works so quickly.
      // If someone tries to merge 1400 approved works at once, fail it.
      expect(
        editoriallyApproved,
        lessThan(1000),
        reason: 'Too many works ($editoriallyApproved) claimed as editorially approved. This indicates fake bulk verification.'
      );
    });
  });
}
