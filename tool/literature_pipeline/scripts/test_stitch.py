import re

raw = """Омад баҳори хуррам бо рангу бӯйи тиб
3
,
Бо сад ҳазор нузҳату
4
ороиши аҷиб.
Шояд, ки марди пир бад-ин гаҳ шавад ҷавон,
Гетӣ бадил ёфт шубоб
5
аз пайи машиб
6
.
Чархи бузургвор яке лашкаре бикард,
Лашкар-ш абри тираву боди сабо - нақиб."""

def stitch_poetry(text: str) -> str:
    lines = [l.strip() for l in text.splitlines() if l.strip()]
    merged = []
    i = 0
    while i < len(lines):
        line = lines[i]
        # Footnote number alone
        if re.match(r"^\d{1,3}$", line):
            if i + 1 < len(lines) and re.match(r"^[,\.?!;:]", lines[i+1]):
                if merged: merged[-1] += lines[i+1][0]
                lines[i+1] = lines[i+1][1:].strip()
            i += 1
            continue
        # Punctuation alone
        if re.match(r"^[,\.?!;:]$", line):
            if merged: merged[-1] += line
            i += 1
            continue
        # Strip attached footnote numbers
        line = re.sub(r"([а-яёғӣқӯҳҷ])\d{1,2}(?=[,.\s!?…»\"]|$)", r"\1", line, flags=re.IGNORECASE)
        # Check if this line is an incomplete fragment that should be merged with next
        # If line ends with hyphen or ends with conjunction like "нузҳату", "шубоб", etc.
        # Classical hemistich length is typically 30 to 65 chars.
        if len(line) < 28 and i + 1 < len(lines):
            next_line = lines[i+1]
            # if next line is not a heading and doesn't start with capital and combined length < 65
            if not re.match(r"^\d{1,3}$", next_line) and not next_line.startswith("## "):
                # If current line ends with "-" or non-punctuation, and combined is typical hemistich
                if not line.endswith((".", ",", "!", "?", "...", ":", ";")):
                    line = line + " " + next_line
                    i += 2
                    merged.append(line)
                    continue
        merged.append(line)
        i += 1
    return "\n".join(merged)

print(stitch_poetry(raw))
