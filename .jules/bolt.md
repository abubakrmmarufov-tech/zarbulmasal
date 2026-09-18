## 2024-09-18 - Offload JSON Parsing to Background Isolate
**Learning:** Parsing large JSON files (such as historical entries and literature works) on the main thread using synchronous `jsonDecode` causes significant UI jank and frame drops in Flutter applications.
**Action:** Use Flutter's `compute` function to offload JSON parsing to a background isolate, ensuring the main thread remains unblocked and the UI stays responsive.
