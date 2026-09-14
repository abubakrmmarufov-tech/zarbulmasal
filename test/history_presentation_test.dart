import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helper.dart';

void main() {
  testWidgets('history textbook cards expose source actions', (tester) async {
    await openApp(
      tester,
      route: '/history',
      width: 390,
      height: 844,
      disableAnimations: true,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 4));
    expect(find.byTooltip('Дидани манбаъ'), findsAtLeastNWidgets(2));
    expect(find.text('Дидани манбаи аслӣ'), findsWidgets);
  });

  testWidgets('loaded history cards stay stable on a small large-text phone', (
    tester,
  ) async {
    await openApp(
      tester,
      route: '/history',
      width: 320,
      height: 568,
      scale: 2,
      disableAnimations: true,
      settle: false,
    );
    await tester.pump(const Duration(seconds: 4));

    expect(tester.takeException(), isNull);
  });
}
