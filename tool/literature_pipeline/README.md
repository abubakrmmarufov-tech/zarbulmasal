# Literature Pipeline

This directory contains the data extraction and processing pipeline used to generate the Zarbulmasal Literary Heritage section.
The pipeline reads Tajik school literature textbooks (Grades 5-11), extracts candidate poets and works, and merges them into the application's JSON assets.
Extracted material is not publication evidence: generated records remain `needsReview` until editorial provenance, rights, and dual-witness collation are completed.

## Files
- `discover_pdfs.py`: Scans `docs/literature/pdfs/` and reports basic metadata about the textbooks (pages, file size).
- `dump_markdown.py`: Uses `pymupdf4llm` to convert the PDFs into markdown text chunks, handling the complex layouts of the textbooks.
- `fix_encoding.py`: Corrects legacy Cyrillic encodings (e.g., `њ`->`ҳ`, `ќ`->`қ`) found in older Tajik PDFs before they are fed to LLMs.
- `extract.py`, `parse.py`, `test_extract*.py`: The Python scripts used by the AI extraction agents to parse the markdown chunks and extract structured JSON (poets, biographies, poems).
- `merge_json.py`: Merges the individual JSON outputs from the chunked processing back into a unified format.
- `build_assets.py`: The current dry-run-first aggregator. Reads extracted JSONs, preserves existing curated records, and proposes candidate records in `assets/data/literature/` without inventing pages or bibliographic details.
- `build_db.py`: Compatibility alias for `build_assets.py`; it no longer generates deleted Dart seed files.
- `migrate_to_prod.py`: Compatibility alias for `build_assets.py`; it no longer reads deleted legacy seed files or fabricates production-ready records.
- `create_audit.py`: Generates the provenance audits (`POET_AUDIT.md` and `POEM_AUDIT.md`) directly from the parsed data to ensure that every poem can be traced back to its PDF source and page.

## Data Directories (in `docs/literature/`)
- `pdfs/`: Source PDFs (Ignored in git due to size/copyright).
- `dumps/`: Raw markdown dumps from the PDFs.
- `chunks/`: Markdown split into smaller chunks to fit LLM context limits.
- `extracted/`: JSON output from the LLMs.

## Usage
These scripts are meant to be run by AI agents with the correct API keys and context configurations. If you are adding a new textbook:
1. Place the PDF in `docs/literature/pdfs/`.
2. Run `dump_markdown.py` to extract text.
3. Deploy the `book_manager` agent to process the chunks and extract JSON.
4. Run `python3 tool/literature_pipeline/scripts/build_assets.py` from the repository root to review a dry-run candidate count.
5. Pass `--write` only after reviewing the candidate output, then run `dart run tool/validate_literature_json.dart` and `dart run tool/validate_literary_content.dart`.
6. Run `create_audit.py` to update the audit trails.
