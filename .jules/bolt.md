## 2024-05-14 - Isolate JSON decoding for large files
**Learning:** Parsing large JSON files (like 2MB literary works) synchronously on the main thread causes significant UI jank and frame drops in Flutter.
**Action:** Use `compute(jsonDecode, jsonString)` from `package:flutter/foundation.dart` to offload the parsing of large JSON assets to a background isolate.
