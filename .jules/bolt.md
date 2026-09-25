## 2024-05-20 - [Cache Authors JSON Decoding]
**Learning:** In Flutter, repeated synchronous JSON decoding of large files in repositories (like `loadAuthors`) blocks the main thread causing UI jank, and redundant parsing wastes memory.
**Action:** Always cache the `Future` of parsed assets (e.g., `_authorsFuture`) and offload `jsonDecode` to a background isolate using `compute()` for any file larger than trivial size.
