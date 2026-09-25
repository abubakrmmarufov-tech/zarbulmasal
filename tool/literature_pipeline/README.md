# Literature pipeline scripts

Small maintenance scripts kept because CI or the tests use them. The poem,
biography and history extraction tools live in `tool/literature/` and
`tool/history/`.

- `scripts/discover_pdfs.py` writes `docs/literature/SOURCE_INVENTORY.md`
  from `docs/literature/pdfs/MANIFEST.json` and checks any local textbook
  PDFs against their SHA-256. `--update-manifest` re-reads the local PDFs
  (needs PyMuPDF) when a textbook is deliberately replaced.
- `scripts/extract_portraits.py` crops poet portraits from cited textbook
  pages into `assets/data/literature/portraits/` (tested by
  `tool/test_extract_portraits.py`).
- `scripts/merge_duplicate_works.py` merges duplicate work records (tested by
  `tool/test_merge_duplicate_works.py`).
- `scripts/sync_source_citations.py` normalises work citations to a source
  record (tested by `tool/test_provenance_linter_sources.py`).

The textbook PDFs are not in the repository. To run the extraction and audit
tools, place the seven PDFs named in the manifest in `docs/literature/pdfs/`;
`discover_pdfs.py` confirms they are the exact files cited.
