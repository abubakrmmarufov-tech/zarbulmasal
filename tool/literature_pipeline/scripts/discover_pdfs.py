import fitz  # PyMuPDF
import os

pdf_dir = "docs/literature/pdfs"
pdfs = [f for f in os.listdir(pdf_dir) if f.endswith('.pdf')]
pdfs.sort()

inventory_md = """# Source Inventory

| Filename | Book Title | Author/Editor | Publisher | Year | Edition | Volume | PDF Pages | Text Quality |
|---|---|---|---|---|---|---|---|---|
"""

for pdf in pdfs:
    path = os.path.join(pdf_dir, pdf)
    doc = fitz.open(path)
    num_pages = len(doc)
    text = doc[0].get_text() + doc[1].get_text() + doc[2].get_text()
    
    # Try to guess title from first pages
    lines = [line.strip() for line in text.split('\n') if line.strip()]
    
    # Simple check for OCR/clean
    if len(text.strip()) > 100:
        quality = "Clean (Encoding requires map)"
    else:
        quality = "Requires OCR"
        
    inventory_md += f"| {pdf} | TBD | TBD | TBD | TBD | TBD | TBD | {num_pages} | {quality} |\n"
    
with open("docs/literature/SOURCE_INVENTORY.md", "w") as f:
    f.write(inventory_md)
    
print("Done creating inventory draft.")
