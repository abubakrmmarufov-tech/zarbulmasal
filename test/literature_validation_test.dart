import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/data/seed/seed_poets.dart';
import 'package:zarbulmasal/data/seed/seed_poems.dart';

void main() {
  group('Literature Data Validation', () {
    test('Unique Poet IDs', () {
      final ids = seedPoets.map((p) => p.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length, reason: 'Duplicate poet IDs found');
    });

    test('Unique Poem IDs', () {
      final ids = seedPoems.map((p) => p.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length, reason: 'Duplicate poem IDs found');
    });

    test('Valid PoetID References in Poems', () {
      final poetIds = seedPoets.map((p) => p.id).toSet();
      for (var poem in seedPoems) {
        expect(
          poetIds.contains(poem.poetId),
          true,
          reason: 'Poem ${poem.id} has invalid poetId ${poem.poetId}',
        );
      }
    });

    test('No Empty Poem Text', () {
      for (var poem in seedPoems) {
        expect(
          poem.text.isNotEmpty,
          true,
          reason: 'Poem ${poem.id} has empty text',
        );
      }
    });

    test('Every Production Poem Has a Source', () {
      for (var poem in seedPoems) {
        expect(
          poem.sourceRefs.isNotEmpty,
          true,
          reason: 'Poem ${poem.id} missing sourceRef',
        );
      }
    });
  });
}
