## 2024-05-24 - Flutter Main Thread JSON Jank
**Learning:** Decoding large local JSON files (> 2MB) synchronously on the main thread via `jsonDecode()` causes noticeable UI jank/dropped frames (around 200ms+ freeze on app startup or data fetch) in Flutter apps.
**Action:** Always offload large asset file parsing to background isolates using `compute(jsonDecode, jsonString)` from `package:flutter/foundation.dart` when loading seed data, repositories, or bundled catalogs.
