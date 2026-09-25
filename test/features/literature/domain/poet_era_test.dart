import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/features/literature/domain/domain.dart';

LiteraryAuthor _poet({String? born, String? died}) => LiteraryAuthor.fromJson({
  'id': 'p',
  'canonicalName': 'Шоир',
  'birthYear': born,
  'deathYear': died,
});

void main() {
  test('the era follows the recorded birth year', () {
    expect(PoetEra.of(_poet(born: '858', died: '941')), PoetEra.classical);
    expect(PoetEra.of(_poet(born: '~980')), PoetEra.classical);
    expect(PoetEra.of(_poet(born: '1525', died: '1588')), PoetEra.later);
    expect(PoetEra.of(_poet(born: '1878', died: '1954')), PoetEra.later);
    expect(PoetEra.of(_poet(born: '1911')), PoetEra.modern);
  });

  test('without a birth year the death year places the poet', () {
    expect(PoetEra.of(_poet(died: '1141')), PoetEra.classical);
    expect(
      PoetEra.of(_poet(born: 'охири асри ХI', died: '1187/88')),
      PoetEra.classical,
    );
  });

  test('no year, no era; names round-trip', () {
    expect(PoetEra.of(_poet()), isNull);
    expect(PoetEra.fromName('modern'), PoetEra.modern);
    expect(PoetEra.fromName('nope'), isNull);
  });
}
