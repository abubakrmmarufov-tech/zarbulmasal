import pymupdf
import sys

def dump_toc(pdf_path):
    doc = pymupdf.open(pdf_path)
    toc = doc.get_toc()
    for item in toc:
        print(f"Level {item[0]}: {item[1]} (Page {item[2]})")

dump_toc(sys.argv[1])
