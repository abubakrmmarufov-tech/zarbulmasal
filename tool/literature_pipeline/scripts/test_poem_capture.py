import re

with open("docs/literature/dumps/adabiet sinfi 5.md") as f:
    text = f.read()

# Test searching for Rudaki poems
def extract_section(text, header_title, stop_keywords):
    pos = text.find(header_title)
    if pos == -1: return ""
    sub = text[pos + len(header_title):]
    # find first stop keyword
    min_stop = len(sub)
    for kw in stop_keywords:
        kpos = sub.find(kw)
        if kpos != -1 and kpos < min_stop:
            min_stop = kpos
    return sub[:min_stop].strip()

sample = extract_section(text, "## БАҲОРИ ХУРРАМ (Page 52)", ["## Луғат", "## Савол"])
print("BAHORI KHURRAM extracted raw:")
print(repr(sample[:300]))
