import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Share of pixels that may differ before a golden fails. Each platform
/// compares against its own images (see screens_golden_test.dart), so none.
const goldenTolerance = 0.0;

/// Goldens use the default test font, not the bundled families, so they
/// test layout and colour rather than type. Its glyph edges are still
/// rasterised by the platform, hence one set of images per platform. This
/// file shadows test/flutter_test_config.dart for this folder only.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final previous = goldenFileComparator;
  if (previous is LocalFileComparator) {
    goldenFileComparator = TolerantGoldenComparator(
      Uri.parse('${previous.basedir}golden_test.dart'),
      tolerance: goldenTolerance,
    );
  }
  await testMain();
}

/// A [LocalFileComparator] that passes when at most [tolerance] of the
/// pixels differ.
class TolerantGoldenComparator extends LocalFileComparator {
  TolerantGoldenComparator(super.testFile, {required this.tolerance})
    : assert(tolerance >= 0 && tolerance <= 1);

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) {
      result.dispose();
      return true;
    }
    final error = await generateFailureOutput(result, golden, basedir);
    result.dispose();
    throw FlutterError(error);
  }
}
