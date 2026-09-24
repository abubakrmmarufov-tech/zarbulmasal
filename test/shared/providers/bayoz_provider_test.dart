import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/shared/providers/bayoz_provider.dart';

Future<BayozNotifier> _notifier([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  var tick = 0;
  return BayozNotifier(
    await SharedPreferences.getInstance(),
    clock: () => DateTime.utc(2026, 9, 24, 12, 0, tick++),
  );
}

const _poem = BayozItem(BayozItemKind.work, 'rudaki');
const _proverb = BayozItem(BayozItemKind.proverb, '21');

void main() {
  test('creates, fills, renames and deletes a Баёз', () async {
    final notifier = await _notifier();
    final id = await notifier.create('  Барои модарам  ');
    expect(id, isNotNull);
    expect(notifier.state.single.title, 'Барои модарам');

    await notifier.toggle(id!, _poem);
    await notifier.toggle(id, _proverb);
    expect(notifier.state.single.items, [_poem, _proverb]);

    await notifier.toggle(id, _poem);
    expect(notifier.state.single.items, [_proverb]);

    await notifier.rename(id, 'Бухоро');
    expect(notifier.state.single.title, 'Бухоро');

    await notifier.delete(id);
    expect(notifier.state, isEmpty);
  });

  test('rejects an empty title and caps long titles', () async {
    final notifier = await _notifier();
    expect(await notifier.create('   '), isNull);
    final id = await notifier.create('ж' * 200);
    expect(notifier.state.single.title.length, Bayoz.maxTitleLength);
    await notifier.rename(id!, '  ');
    expect(notifier.state.single.title.length, Bayoz.maxTitleLength);
  });

  test('persists across restarts', () async {
    final notifier = await _notifier();
    final id = await notifier.create('Бухоро');
    await notifier.toggle(id!, _poem);

    final reloaded = BayozNotifier(await SharedPreferences.getInstance());
    expect(reloaded.state.single.title, 'Бухоро');
    expect(reloaded.state.single.items, [_poem]);
  });

  test('drops malformed stored data instead of failing', () async {
    final stored = jsonEncode([
      {
        'id': 'ok',
        'title': 'Дуруст',
        'createdAt': '2026-09-24T00:00:00.000Z',
        'items': [
          {'kind': 'work', 'id': 'rudaki'},
          {'kind': 'poet', 'id': 'x'},
          {'kind': 'work', 'id': ''},
          {'kind': 'work', 'id': 'rudaki'},
        ],
      },
      {'id': 'no-title', 'createdAt': '2026-09-24T00:00:00.000Z', 'items': []},
      'not a map',
    ]);
    final notifier = await _notifier({BayozNotifier.storageKey: stored});
    expect(notifier.state, hasLength(1));
    expect(notifier.state.single.items, [_poem]);

    final corrupt = await _notifier({BayozNotifier.storageKey: '{oops'});
    expect(corrupt.state, isEmpty);
  });

  test(
    'two anthologies created in the same clock tick get distinct ids',
    () async {
      SharedPreferences.setMockInitialValues({});
      final notifier = BayozNotifier(
        await SharedPreferences.getInstance(),
        clock: () => DateTime.utc(2026, 9, 24),
      );
      final a = await notifier.create('Якум');
      final b = await notifier.create('Дуюм');
      expect(a, isNot(b));
      await notifier.toggle(a!, _poem);
      expect(notifier.state.firstWhere((x) => x.id == b).items, isEmpty);
    },
  );
}
