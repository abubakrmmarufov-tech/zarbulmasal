import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:zarbulmasal/router/app_router.dart';

void main() {
  test('app router reflects imperative navigation in browser URLs', () {
    expect(appRouter, isA<GoRouter>());
    expect(GoRouter.optionURLReflectsImperativeAPIs, isTrue);
  });
}
