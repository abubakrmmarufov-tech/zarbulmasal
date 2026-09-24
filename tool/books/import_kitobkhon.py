"""Import book records from the kitobkhon.net catalogue.

Usage:
    python3 tool/books/import_kitobkhon.py <cache_dir> [--write]

Crawls https://kitobkhon.net/books?page=N and each /book/<slug> page (one
request per second, cached in <cache_dir>), and keeps Tajik-language books in
literature, history and biography categories. Every field comes from the
book's own page: title, author, publisher, year, pages, city, categories,
description, and the provider's PDF link. Nothing is inferred except links
to poets already in the app (exact name match) and the app's category IDs.

Records are marked `readableExternal` + `rightsUnclear`, like the existing
kitobkhon entries: the app links to the provider and does not re-host.
With --write, new books are appended to assets/data/books/books.json.
"""
import hashlib
import html
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from concurrent.futures import ThreadPoolExecutor

BASE = 'https://kitobkhon.net'
BOOKS = 'assets/data/books/books.json'
POETS = 'assets/data/literature/poets.json'
DELAY = 1.0
WORKERS = 4

CATEGORY_IDS = {
    'Адабиёти классикӣ': 'adabiyoti-klassiki',
    'Адабиёти муосир': 'adabiyoti-muosir',
    'Назм': 'nazm',
    'Наср': 'nasr',
    'Таърих': 'tarikh',
    'Зиндагинома': 'zindaginoma',
}
GENRES = {
    'nazm': 'poetry', 'nasr': 'prose', 'adabiyoti-klassiki': 'classical',
    'tarikh': 'history', 'zindaginoma': 'biography',
}
# The project's content policy (test/content_zero_fake_test.dart): books
# compiled from blogs or wikis are not listed.
FORBIDDEN_SOURCES = ('marifat.tj', 'wikipedia.org', 'google.com',
                     'blogspot.com', 'wordpress.com', 'wikidata.org')
FIELDS = {
    'Муаллиф': 'author', 'Нашриёт': 'publisher', 'Сол': 'year',
    'Саҳифаҳо': 'pages', 'Забон': 'language', 'Шаҳр': 'city',
}


def fetch(cache_dir, url):
    key = hashlib.sha1(url.encode()).hexdigest()
    path = os.path.join(cache_dir, key + '.html')
    if os.path.exists(path):
        return open(path, encoding='utf-8').read()
    for attempt in range(3):
        try:
            request = urllib.request.Request(
                url, headers={'User-Agent': 'Zarbulmasal-catalogue/1.0'})
            with urllib.request.urlopen(request, timeout=40) as response:
                body = response.read().decode('utf-8', 'replace')
            break
        except OSError:
            time.sleep(3 * (attempt + 1))
    else:
        return None
    with open(path, 'w', encoding='utf-8') as f:
        f.write(body)
    time.sleep(DELAY)
    return body


def visible_lines(page):
    main = re.search(r'<main.*?</main>', page, re.S)
    seg = main.group(0) if main else page
    seg = re.sub(r'<script.*?</script>|<style.*?</style>|<svg.*?</svg>', '',
                 seg, flags=re.S)
    text = html.unescape(re.sub(r'<[^>]+>', '\n', seg))
    return [re.sub(r'\s+', ' ', l).strip() for l in text.split('\n')
            if l.strip()]


def parse_book(slug, page):
    lines = visible_lines(page)
    try:
        crumb = lines.index('Китобҳо')
    except ValueError:
        return None
    title = lines[crumb + 2] if crumb + 2 < len(lines) else ''
    record = {'slug': slug, 'title': title}
    for i, line in enumerate(lines):
        if line in FIELDS and i + 1 < len(lines) and \
                FIELDS[line] not in record:
            record[FIELDS[line]] = lines[i + 1]
    # Categories: the tag lines between "Нашр дар сомона <date>" and
    # "Дар бораи китоб".
    try:
        start = lines.index('Нашр дар сомона') + 2
        end = lines.index('Дар бораи китоб')
        record['tags'] = lines[start:end]
        about = []
        for line in lines[end + 1:]:
            if line.startswith('Калидвожаҳо'):
                break
            about.append(line)
        record['about'] = ' '.join(about).strip()
    except ValueError:
        record['tags'] = []
        record['about'] = ''
    pdf = re.search(r'(/storage/books/[^"\'\s<>]+\.pdf)', page)
    record['pdf'] = safe_url(BASE + pdf.group(1)) if pdf else None
    # The book's own cover is shown twice at the top (image + zoom link);
    # covers of suggested books further down appear once each.
    covers = re.findall(r'(/storage/covers/[^"\'\s<>]+\.(?:jpe?g|png|webp))', page)
    own = [c for c in dict.fromkeys(covers) if covers.count(c) >= 2]
    record['cover'] = safe_url(BASE + own[0]) if own else None
    return record


def safe_url(url):
    """Percent-encode anything outside plain ASCII in the path."""
    return urllib.parse.quote(html.unescape(url), safe=':/%-._~')


def norm(text):
    return re.sub(r'[^\w]+', '', (text or '').lower())


def main(cache_dir, write):
    os.makedirs(cache_dir, exist_ok=True)
    books = json.load(open(BOOKS, encoding='utf-8'))
    poets = json.load(open(POETS, encoding='utf-8'))
    poet_ids = {}
    for poet in poets:
        if poet.get('recordStatus') == 'review':
            continue
        for name in [poet.get('canonicalName')] + list(poet.get('aliases') or []):
            if name:
                poet_ids[norm(name)] = poet['id']
    known_urls = {u for b in books for e in b.get('editions', [])
                  for u in (e.get('sourceUrl'), e.get('readUrl'))}
    known_ids = {b['id'] for b in books}

    first = fetch(cache_dir, f'{BASE}/books')
    last = max(int(n) for n in re.findall(r'books\?page=(\d+)', first))
    slugs = []
    for n in range(1, last + 1):
        page = first if n == 1 else fetch(cache_dir, f'{BASE}/books?page={n}')
        if page is None:
            continue
        for slug in re.findall(r'href="https://kitobkhon\.net/book/([^"/?#]+)"', page):
            if slug not in slugs:
                slugs.append(slug)
    print(f'catalogue: {len(slugs)} books on {last} pages')

    # Book pages: a few at a time (each worker still pauses between
    # requests), cached so a rerun fetches nothing twice.
    todo = [s for s in slugs
            if f'{BASE}/book/{s}' not in known_urls and s not in known_ids]
    with ThreadPoolExecutor(max_workers=WORKERS) as pool:
        fetched = dict(zip(todo, pool.map(
            lambda s: fetch(cache_dir, f'{BASE}/book/{s}'), todo)))

    added = []
    for slug in todo:
        url = f'{BASE}/book/{slug}'
        page = fetched.get(slug)
        if page is None:
            continue
        info = parse_book(slug, page)
        if not info or not info.get('title') or not info.get('pdf'):
            continue
        if info['pdf'] in known_urls or info.get('language') != 'Тоҷикӣ':
            continue
        if any(term in json.dumps(info, ensure_ascii=False).lower()
               for term in FORBIDDEN_SOURCES):
            continue
        category_ids = [CATEGORY_IDS[t] for t in info['tags'] if t in CATEGORY_IDS]
        if not category_ids:
            continue                   # not literature, history or biography
        author = info.get('author')
        author_id = poet_ids.get(norm(author)) if author else None
        year = info.get('year') if re.fullmatch(r'\d{4}', info.get('year') or '') else None
        page_count = int(info['pages']) if (info.get('pages') or '').isdigit() else None
        added.append({
            'id': slug,
            'canonicalTitle': info['title'],
            'titleTj': info['title'],
            'alternateTitles': [],
            'authorNameTj': author,
            **({'authorId': author_id} if author_id else {}),
            'descriptionTj': info['about'] or
            'Маълумоти нашрӣ ва дастрасӣ аз саҳифаи провайдер.',
            'language': 'Тоҷикӣ',
            'genres': sorted({GENRES[c] for c in category_ids if c in GENRES}),
            'categoryIds': category_ids,
            'relatedPoetIds': [author_id] if author_id else [],
            'editions': [{
                'id': f'{slug}-kitobkhon' + (f'-{year}' if year else ''),
                'bookId': slug,
                'providerId': 'kitobkhon',
                'sourceUrl': url,
                'readUrl': info['pdf'],
                **({'coverUrl': info['cover']} if info.get('cover') else {}),
                'publisher': info.get('publisher'),
                'city': info.get('city'),
                'publicationYear': year,
                'pageCount': page_count,
                'language': 'Тоҷикӣ',
                'scripts': ['cyrillic'],
                'categories': info['tags'],
                'format': 'pdf',
                'availability': 'readableExternal',
                'rightsStatus': 'rightsUnclear',
                'metadataNote': 'Провайдер PDF-ро мустақим пешниҳод мекунад; '
                                'иҷозаи бознашр мустақилона тасдиқ нашудааст.',
            }],
        })
    # Same title and author as a book already listed: another edition of it.
    by_work = {(norm(b.get('canonicalTitle')), norm(b.get('authorNameTj'))): b
               for b in books}
    editions = []
    for book in list(added):
        existing = by_work.get((norm(book['canonicalTitle']),
                                norm(book['authorNameTj'])))
        if existing is not None:
            edition = dict(book['editions'][0], bookId=existing['id'])
            editions.append((existing, edition))
            added.remove(book)
    print(f'new literature/history/biography books: {len(added)}; '
          f'new editions of listed books: {len(editions)}')
    if write and (added or editions):
        for existing, edition in editions:
            existing['editions'] = existing['editions'] + [edition]
        books.extend(added)
        with open(BOOKS, 'w', encoding='utf-8') as f:
            json.dump(books, f, ensure_ascii=False, indent=2)
            f.write('\n')
    return added


if __name__ == '__main__':
    main(sys.argv[1], '--write' in sys.argv)
