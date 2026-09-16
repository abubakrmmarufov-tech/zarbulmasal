## 2025-02-18 - Offloading JSON Decoding in Flutter
**Learning:** Flutter's single-threaded nature means that parsing large JSON files synchronously using `jsonDecode` blocks the main UI thread, causing jank (dropped frames), especially on lower-end mobile devices and during initial load.
**Action:** When handling large assets (like `books.json`, `poets.json`, etc.), always offload the JSON decoding to a background isolate using `compute(jsonDecode, jsonString)` from `package:flutter/foundation.dart`. This ensures the UI remains smooth while the data is processed.
