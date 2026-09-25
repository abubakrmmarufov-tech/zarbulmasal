// The app, with the Flutter Driver extension, for the device health check
// in test_driver/app_health_test.dart. Run in profile mode:
//
//   flutter drive --profile --target=test_driver/app_health.dart -d <device>
//
// The host sends plain commands; the app obeys them with the real router
// and catalogue:
//   go:<route>        open a route
//   scroll:<n>        scroll the screen's vertical list down n times
//   type:<text>       type into the screen's first text field
//   rss               the process's resident memory, in bytes
//   soak:<poems>:<poets>  open that many poems and poet pages in a row
//   longest           the id of the longest readable poem
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zarbulmasal/app.dart';
import 'package:zarbulmasal/core/constants/app_constants.dart';
import 'package:zarbulmasal/features/literature/data/literature_providers.dart';
import 'package:zarbulmasal/router/app_router.dart';
import 'package:zarbulmasal/shared/providers/app_providers.dart';

late final ProviderContainer _container;

Future<void> main() async {
  enableFlutterDriverExtension(handler: _handle);
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(AppConstants.prefsOnboardingComplete, true);
  _container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  runApp(
    UncontrolledProviderScope(
      container: _container,
      child: const ZarbulmasalApp(),
    ),
  );
}

Future<String> _handle(String? command) async {
  final parts = (command ?? '').split(':');
  switch (parts.first) {
    case 'go':
      await _go(parts.sublist(1).join(':'));
      return 'ok';
    case 'scroll':
      for (var i = 0; i < int.parse(parts[1]); i++) {
        await _scrollOnce();
      }
      return 'ok';
    case 'type':
      await _type(parts.sublist(1).join(':'));
      return 'ok';
    case 'rss':
      return '${ProcessInfo.currentRss}';
    case 'longest':
      final works = await _container.read(approvedWorksProvider.future);
      final longest = works.reduce(
        (a, b) =>
            (a.textTajik?.length ?? 0) >= (b.textTajik?.length ?? 0) ? a : b,
      );
      return jsonEncode({
        'id': longest.id,
        'lines': longest.textTajik?.split('\n').length,
        'readable': works.length,
      });
    case 'soak':
      return _soak(int.parse(parts[1]), int.parse(parts[2]));
  }
  return 'unknown command';
}

Future<void> _go(String route) async {
  appRouter.go(route);
  await _frames(12);
}

/// Lets the app draw [count] frames at its own pace.
Future<void> _frames(int count) async {
  for (var i = 0; i < count; i++) {
    WidgetsBinding.instance.scheduleFrame();
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 16));
  }
}

/// The largest vertical scrollable on screen: the page's own list.
ScrollableState? _mainScrollable() {
  ScrollableState? best;
  var bestHeight = 0.0;
  void visit(Element element) {
    if (element is StatefulElement && element.state is ScrollableState) {
      final state = element.state as ScrollableState;
      final box = element.renderObject;
      if (state.position.axis == Axis.vertical &&
          box is RenderBox &&
          box.hasSize &&
          box.size.height > bestHeight) {
        best = state;
        bestHeight = box.size.height;
      }
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  return best;
}

Future<void> _scrollOnce() async {
  final position = _mainScrollable()?.position;
  if (position == null) return;
  final target = (position.pixels + 600).clamp(
    position.minScrollExtent,
    position.maxScrollExtent,
  );
  await position.animateTo(
    target,
    duration: const Duration(milliseconds: 250),
    curve: Curves.linear,
  );
  await _frames(2);
}

Future<void> _type(String text) async {
  EditableTextState? field;
  void visit(Element element) {
    if (field == null &&
        element is StatefulElement &&
        element.state is EditableTextState) {
      field = element.state as EditableTextState;
    }
    element.visitChildren(visit);
  }

  WidgetsBinding.instance.rootElement?.visitChildren(visit);
  field?.userUpdateTextEditingValue(
    TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    ),
    SelectionChangedCause.keyboard,
  );
  await _frames(12);
}

Future<String> _soak(int poems, int poets) async {
  final works = await _container.read(approvedWorksProvider.future);
  final authors = (await _container.read(
    literaryAuthorsProvider.future,
  )).where((poet) => poet.hasCanonicalName).toList();
  final step = works.length ~/ poems;
  for (var i = 0; i < poems; i++) {
    await _go('/literature/work/${works[i * step].id}');
  }
  final poetStep = authors.length ~/ poets;
  for (var i = 0; i < poets; i++) {
    await _go('/literature/poet/${authors[i * poetStep].id}');
  }
  return 'ok';
}
