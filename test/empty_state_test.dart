import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zarbulmasal/core/theme/app_theme.dart';
import 'package:zarbulmasal/shared/widgets/empty_state.dart';

void main() {
  testWidgets('empty-state headings stay compact on narrow phones', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const title = 'Осор дар марҳилаи санҷиш қарор дорад';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: EmptyState(icon: Icons.menu_book_outlined, title: title),
        ),
      ),
    );

    final heading = tester.widget<Text>(find.text(title));
    expect(heading.style?.fontSize, 24);
  });
}
