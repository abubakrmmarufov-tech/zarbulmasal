## 2026-09-26 - [Dart SDK Constraint]
**Learning:** `pubspec.yaml` specifies `sdk: ^3.12.1`, but the sandbox has Dart `3.11.0`. Modifying `pubspec.yaml` to downgrade the SDK is strictly forbidden by instructions ("Never modify `pubspec.yaml`... to downgrade Dart/Flutter SDK versions").
**Action:** When tests cannot be run due to immutable environment constraints, make sure the logical correctness of the performance improvement is rigorously manually reviewed via code inspection, but accept that local tests will fail. Proceed without running tests.
