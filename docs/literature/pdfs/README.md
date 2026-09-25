# Textbook PDFs

The seven Tajik literature textbooks (grades 5–11) that every poem, biography
and Lexicon entry cites are **not stored in this repository**. `MANIFEST.json`
names each file with its size, SHA-256 and page count, so a citation always
points at one exact file.

To run the extraction and audit tools, copy the PDFs here under the names in
the manifest, then check them:

    python3 tool/literature_pipeline/scripts/discover_pdfs.py
