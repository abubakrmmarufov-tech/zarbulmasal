## 2026-09-17 - Offload JSON decoding to background isolates
**Learning:** Large JSON files parsed synchronously via `jsonDecode` cause main thread UI jank in Flutter apps. This is specifically relevant in projects like Zarbulmasal that load extensive literary or historical datasets from local assets on startup.
**Action:** Use Flutter's `compute(jsonDecode, jsonString)` from `package:flutter/foundation.dart` to parse large JSON strings in a background isolate instead of running it on the main thread.
