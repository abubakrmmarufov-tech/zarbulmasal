# Literature Pipeline

This directory contains the data extraction and processing pipeline used to generate the Zarbulmasal Literary Heritage section. 
The pipeline was designed to read Tajik school literature textbooks (Grades 5-11), extract poets and poems using Claude/Gemini, and structure them into the application's Dart seed files.

## Files
- `discover_pdfs.py`: Scans `docs/literature/pdfs/` and reports basic metadata about the textbooks (pages, file size).
- `dump_markdown.py`: Uses `pymupdf4llm` to convert the PDFs into markdown text chunks, handling the complex layouts of the textbooks.
- `fix_encoding.py`: Corrects legacy Cyrillic encodings (e.g., `њ`->`ҳ`, `ќ`->`қ`) found in older Tajik PDFs before they are fed to LLMs.
- `extract.py`, `parse.py`, `test_extract*.py`: The Python scripts used by the AI extraction agents to parse the markdown chunks and extract structured JSON (poets, biographies, poems).
- `merge_json.py`: Merges the individual JSON outputs from the chunked processing back into a unified format.
- `build_db.py`: The final aggregator. Reads the extracted JSONs, validates them, and generates `lib/data/seed/seed_poets.dart` and `lib/data/seed/seed_poems.dart`.
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
4. Run `build_db.py` to regenerate the Dart seed files.
5. Run `create_audit.py` to update the audit trails.
