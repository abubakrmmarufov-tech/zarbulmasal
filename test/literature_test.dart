import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/test_helper.dart'; // We created this

void main() {
  testWidgets('Literature Hub Screen renders and navigates to sections', (
    tester,
  ) async {
    await openApp(tester, route: '/', height: 1200);

    final hubFinder = find.text('Мероси адабӣ');
    await tester.scrollUntilVisible(hubFinder, 300);
    expect(hubFinder, findsOneWidget);
    final hubCard = find.ancestor(
      of: hubFinder,
      matching: find.byType(InkWell),
    );
    expect(hubCard, findsOneWidget);
    final hubCardRect = tester.getRect(hubCard);
    await tester.tapAt(Offset(hubCardRect.center.dx, hubCardRect.top + 20));
    await tester.pumpAndSettle();

    // Now we should be on Literature Hub Screen
    expect(find.text('Шоирон'), findsOneWidget);
    expect(find.text('Шеърҳо'), findsOneWidget);
  });
}
