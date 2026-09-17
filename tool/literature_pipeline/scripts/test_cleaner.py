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
Лашкар-ш абри тираву боди сабо - нақиб.
Наффот - барқи равшану тундар-ш - таблзан,
Дидам ҳазор хайлу надидам чунин муҳиб.
Он абр бин, ки гиряд чун марди сӯгвор
В-он раъд бин, ки нолад чун ошиқи каиб.
Хуршедро зи абр диҳад рӯй гоҳ-гоҳ
Чун он ҳисорие, ки гузар дорад аз рақиб...
Лола миёни кишт бихандад ҳаме зи дур,
Чун панҷаи арӯс ба ҳинно шуда хазиб.
Булбул ҳаме бихонад дар шохсори бед,
Сор аз дарахти сарв мар-ӯро шуда муҷиб..."""

def clean_poetry_text(raw_text: str) -> str:
    lines = raw_text.splitlines()
    cleaned_lines = []
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if not line:
            if cleaned_lines and cleaned_lines[-1] != "":
                cleaned_lines.append("")
            i += 1
            continue
        
        # Check if line is a lone footnote number
        if re.match(r"^\d{1,3}$", line):
            # Check if next line is punctuation like comma, dot, colon
            if i + 1 < len(lines) and re.match(r"^[,\.?!;:]$", lines[i+1].strip()):
                punct = lines[i+1].strip()
                if cleaned_lines and cleaned_lines[-1] != "":
                    cleaned_lines[-1] += punct
                i += 2
                continue
            # Or if it was just an inline footnote split
            i += 1
            continue
            
        # Check if line starts with orphaned punctuation from footnote
        if re.match(r"^[,\.?!;:]", line) and cleaned_lines and cleaned_lines[-1] != "":
            cleaned_lines[-1] += line[0]
            line = line[1:].strip()
            if not line:
                i += 1
                continue
                
        # Strip trailing or attached footnote numbers on words, e.g. машиб6 -> машиб
        line = re.sub(r"([а-яёғӣқӯҳҷ])\d{1,2}(?=[,.\s!?…»\"]|$)", r"\1", line, flags=re.IGNORECASE)
        # Fix broken words inside hemistich if any, e.g. "нузҳату\nороиши"
        # If previous line does not end with punctuation and length is short, check if it was split
        cleaned_lines.append(line)
        i += 1
        
    # Second pass: stitch lines that are half-hemistichs if appropriate
    return "\n".join(cleaned_lines)

print("CLEANED:")
print(clean_poetry_text(raw))
