## 2024-09-24 - [Cache repeatedly fetched authors JSON]
**Learning:** Parsing large JSON files like poets.json on the main thread recursively can block UI and parsing the same 402KB file continuously results in unnecessary allocation.
**Action:** Cache the resulting Future inside the repository and use background isolates via `compute()` for asynchronous parsing.
