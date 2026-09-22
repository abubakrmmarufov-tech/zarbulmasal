## 2024-10-24 - [Isolate JSON Parsing for Flutter UI Smoothness]
**Learning:** [In Flutter apps with significant bundled JSON datasets (like historical and literary content), synchronous JSON parsing on the main thread via `jsonDecode` blocks the UI event loop, causing noticeable frame drops and jank during app initialization and route transitions.]
**Action:** [Always use `await compute(jsonDecode, jsonString)` from `package:flutter/foundation.dart` to offload large JSON asset decoding to background isolates, ensuring buttery smooth 60fps/120fps UI rendering.]
