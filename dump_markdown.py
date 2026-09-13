import pymupdf
import sys
import os

def fix_text(text):
    if not text: return ""
    mapping = {
        'њ': 'ҳ', 'Њ': 'Ҳ',
        'ќ': 'қ', 'Ќ': 'Қ',
        'љ': 'ҷ', 'Љ': 'Ҷ',
        'ѓ': 'ғ', 'Ѓ': 'Ғ',
        'ў': 'ӯ', 'Ў': 'Ӯ',
        'ї': 'ӣ', 'Ї': 'Ӣ'
    }
    for k, v in mapping.items():
        text = text.replace(k, v)
    return text

def dump_pdf(pdf_path, out_path):
    doc = pymupdf.open(pdf_path)
    with open(out_path, 'w', encoding='utf-8') as f:
        for page_num in range(len(doc)):
            page = doc[page_num]
            blocks = page.get_text("dict")["blocks"]
            for block in blocks:
                if "lines" in block:
                    for line in block["lines"]:
                        for span in line["spans"]:
                            text = fix_text(span["text"]).strip()
                            if not text:
                                continue
                            # Heuristic: if font is large or bold, make it a heading
                            size = span["size"]
                            flags = span["flags"]
                            is_bold = flags & 2**4
                            
                            # Standard text is usually around 10-12. Headings 14+
                            if size > 14 or is_bold:
                                f.write(f"\n## {text} (Page {page_num+1})\n")
                            else:
                                f.write(f"{text}\n")
                    f.write("\n")
    print(f"Dumped {pdf_path} to {out_path}")

os.makedirs("docs/literature/dumps", exist_ok=True)
pdf_dir = "docs/literature/pdfs"
for pdf in os.listdir(pdf_dir):
    if pdf.endswith('.pdf'):
        dump_pdf(os.path.join(pdf_dir, pdf), os.path.join("docs/literature/dumps", pdf.replace(".pdf", ".md")))

