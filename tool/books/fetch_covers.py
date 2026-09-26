"""Download book covers from the book sites, at build time only.

The app stays offline: this tool runs on a developer machine, keeps only
real cover images and bundles them as assets. It is polite to the sites
(one request a second, a clear User-Agent) and resumable: every answer is
saved to a state file, so a rerun continues where the last one stopped.

For each edition it
  1. opens the book page (`sourceUrl`) and reads the cover from `og:image`;
     the sites' shared placeholder (kitobkhon.net's /images/cover.png) means
     the book has no cover;
  2. downloads that cover and keeps it only if the server calls it an image,
     it decodes, it is not tiny and not blank, and no more than five
     editions share it (volumes of a series share one cover; an image used
     more widely is a placeholder). A coverUrl recorded at import is not
     used when the page shows none.

Usage:
    python3 tool/books/fetch_covers.py [--limit N]        # download
    python3 tool/books/fetch_covers.py --report-only      # report from state
    python3 tool/books/fetch_covers.py --apply            # bundle the covers

--apply copies each kept cover to assets/data/books/covers/<name>.<ext> and
sets the edition's coverAssetPath (coverUrl and rightsStatus are kept as
recorded; a missing coverUrl is set to the image's address). Then run
tool/design/compress_images.py to make them WebP.
"""
import argparse
import datetime
import hashlib
import html as html_lib
import io
import json
import os
import re
import shutil
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

from PIL import Image, ImageStat, UnidentifiedImageError

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BOOKS = 'assets/data/books/books.json'
COVERS = 'assets/data/books/covers'
WORK = 'build/book_covers'

USER_AGENT = ('ZarbulmasalCoverFetcher/1.0 '
              '(+https://github.com/abubakrmmarufov-tech/zarbulmasal; '
              'build-time cover download, 1 request/s)')
DELAY = 1.0
TIMEOUT = 30
RETRIES = 3
TRUSTED_HOSTS = ('kitobkhon.net', 'khirad.tj')
PLACEHOLDER_PATHS = ('/images/cover.png',)
MIN_WIDTH, MIN_HEIGHT = 100, 140
SHARED_LIMIT = 5
EXTENSIONS = {'JPEG': '.jpg', 'PNG': '.png', 'WEBP': '.webp'}

_OG_IMAGE = re.compile(
    r'<meta\b(?=[^>]*\bproperty\s*=\s*["\']og:image["\'])'
    r'[^>]*\bcontent\s*=\s*["\']([^"\']+)["\']', re.I)


def _trusted(url):
    host = (urllib.parse.urlsplit(url).hostname or '').lower()
    return any(host == h or host.endswith('.' + h) for h in TRUSTED_HOSTS)


def cover_url_from_page(page_html, page_url):
    """The cover a book page names in og:image; None when it names the
    site's placeholder, nothing, or an image on another site."""
    match = _OG_IMAGE.search(page_html)
    if not match:
        return None
    url = urllib.parse.urljoin(page_url, html_lib.unescape(match.group(1).strip()))
    if not _trusted(url):
        return None
    if urllib.parse.urlsplit(url).path in PLACEHOLDER_PATHS:
        return None
    return url


def check_image(data, content_type):
    """Whether downloaded bytes are a real cover: an image by content type,
    decodable, at least MIN_WIDTH x MIN_HEIGHT and not a single colour."""
    verdict = {'sha256': hashlib.sha256(data).hexdigest(), 'bytes': len(data)}
    if not (content_type or '').lower().startswith('image/'):
        return {**verdict, 'status': 'rejected',
                'reason': f'content type {content_type!r} is not an image'}
    try:
        with Image.open(io.BytesIO(data)) as image:
            image.load()
            width, height = image.size
            fmt = image.format
            extrema = ImageStat.Stat(image.convert('L')).extrema[0]
    except (UnidentifiedImageError, OSError, SyntaxError) as error:
        return {**verdict, 'status': 'rejected',
                'reason': f'does not decode: {error}'}
    verdict.update(width=width, height=height, format=fmt)
    if width < MIN_WIDTH or height < MIN_HEIGHT:
        return {**verdict, 'status': 'rejected',
                'reason': f'too small for a cover ({width}x{height})'}
    if extrema[1] - extrema[0] < 8:
        return {**verdict, 'status': 'rejected', 'reason': 'blank image'}
    return {**verdict, 'status': 'ok'}


def reject_shared_images(results, limit=SHARED_LIMIT):
    """A copy of [results] where an image kept for more than [limit]
    editions is rejected as a placeholder (volumes of one series share a
    cover, so a few may)."""
    counts = {}
    for result in results.values():
        if result.get('status') == 'ok':
            counts[result['sha256']] = counts.get(result['sha256'], 0) + 1
    marked = {}
    for key, result in results.items():
        shared = counts.get(result.get('sha256'), 0)
        if result.get('status') == 'ok' and shared > limit:
            marked[key] = {**result, 'status': 'rejected',
                           'reason': f'placeholder: the same image is used by {shared} editions'}
        else:
            marked[key] = dict(result)
    return marked


def asset_names(books):
    """{edition id: file stem}: the book id, or the edition id when a book
    has several editions."""
    names = {}
    for book in books:
        editions = book.get('editions') or []
        for edition in editions:
            names[edition['id']] = book['id'] if len(editions) == 1 else edition['id']
    return names


def load_state(path):
    if not os.path.exists(path):
        return {}
    with open(path, encoding='utf-8') as handle:
        return json.load(handle)


def save_state(path, state):
    os.makedirs(os.path.dirname(path) or '.', exist_ok=True)
    temporary = path + '.tmp'
    with open(temporary, 'w', encoding='utf-8') as handle:
        json.dump(state, handle, ensure_ascii=False, indent=1)
    os.replace(temporary, path)


def dead_links(state):
    """Pages and covers that answered with an error or not at all."""
    dead = []
    for edition_id, record in state.items():
        for kind in ('page', 'cover'):
            answer = record.get(kind)
            if not answer:
                continue
            status = answer.get('status')
            if status is None or status >= 400:
                dead.append({'editionId': edition_id, 'kind': kind,
                             'url': answer.get('url'), 'status': status,
                             'error': answer.get('error')})
    return dead


class Client:
    """Fetches with the tool's User-Agent, at most one request per DELAY."""

    def __init__(self, delay=DELAY):
        self.delay = delay
        self.last = 0.0
        self.requests = 0

    def get(self, url):
        """(status, content type, body, error); status None when the server
        never answered. Retries network errors and 5xx answers."""
        error = None
        for attempt in range(RETRIES):
            wait = self.last + self.delay * (1 + attempt) - time.monotonic()
            if wait > 0:
                time.sleep(wait)
            self.last = time.monotonic()
            self.requests += 1
            request = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
            try:
                with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
                    return (response.status, response.headers.get('Content-Type', ''),
                            response.read(), None)
            except urllib.error.HTTPError as http_error:
                if http_error.code < 500:
                    return (http_error.code, http_error.headers.get('Content-Type', ''),
                            b'', None)
                error = f'HTTP {http_error.code}'
            except (urllib.error.URLError, TimeoutError, OSError) as network_error:
                error = str(getattr(network_error, 'reason', network_error))
        return (None, '', b'', error)


def _page_step(client, edition, record):
    status, _, body, error = client.get(edition['sourceUrl'])
    record['page'] = {'url': edition['sourceUrl'], 'status': status}
    if error:
        record['page']['error'] = error
    page_cover = None
    if status == 200:
        page_cover = cover_url_from_page(body.decode('utf-8', 'replace'),
                                         edition['sourceUrl'])
    record['pageCoverUrl'] = page_cover


def _cover_step(client, edition, record, images):
    # The book page is the authority: when it shows the site's placeholder,
    # a coverUrl recorded at import is not used (one named another book's
    # cover).
    url = record.get('pageCoverUrl')
    if not url:
        record['cover'] = None
        record['result'] = {'status': 'none',
                            'reason': 'the book page shows no cover (the site placeholder)'}
        return
    if not _trusted(url):
        record['cover'] = None
        record['result'] = {'status': 'rejected', 'reason': f'untrusted host: {url}'}
        return
    status, content_type, body, error = client.get(url)
    record['cover'] = {'url': url, 'status': status, 'contentType': content_type}
    if error:
        record['cover']['error'] = error
    if status != 200:
        record['result'] = {'status': 'failed', 'reason': f'HTTP {status or error}'}
        return
    verdict = check_image(body, content_type)
    if verdict['status'] == 'ok':
        path = os.path.join(images, edition['id'] + EXTENSIONS.get(verdict['format'], '.img'))
        with open(path, 'wb') as handle:
            handle.write(body)
        verdict['file'] = path
    record['result'] = verdict


def download(root, limit=None, delay=DELAY):
    with open(os.path.join(root, BOOKS), encoding='utf-8') as handle:
        books = json.load(handle)
    work = os.path.join(root, WORK)
    images = os.path.join(work, 'images')
    os.makedirs(images, exist_ok=True)
    state_path = os.path.join(work, 'state.json')
    state = load_state(state_path)
    client = Client(delay)
    done = 0
    for book in books:
        for edition in book['editions']:
            if 'result' in state.get(edition['id'], {}):
                continue
            if limit is not None and done >= limit:
                save_state(state_path, state)
                return state
            record = state.setdefault(edition['id'], {'bookId': book['id']})
            if 'page' not in record:
                _page_step(client, edition, record)
                save_state(state_path, state)
            _cover_step(client, edition, record, images)
            save_state(state_path, state)
            done += 1
            if done % 25 == 0:
                print(f'{done} editions, {client.requests} requests', flush=True)
    return state


def report(root, state, date):
    with open(os.path.join(root, BOOKS), encoding='utf-8') as handle:
        books = json.load(handle)
    results = reject_shared_images(
        {key: record.get('result', {}) for key, record in state.items()})
    rows = []
    for book in books:
        for edition in book['editions']:
            record = state.get(edition['id'], {})
            result = results.get(edition['id'], {})
            cover = record.get('cover') or {}
            rows.append({
                'bookId': book['id'],
                'editionId': edition['id'],
                'provider': edition.get('providerId'),
                'pageUrl': edition.get('sourceUrl'),
                'pageStatus': (record.get('page') or {}).get('status'),
                'url': cover.get('url'),
                'httpStatus': cover.get('status'),
                'status': result.get('status', 'not fetched'),
                'reason': result.get('reason'),
                'sha256': result.get('sha256'),
                'bytes': result.get('bytes'),
                'width': result.get('width'),
                'height': result.get('height'),
                'alreadyBundled': bool(edition.get('coverAssetPath')),
            })
    counts = {}
    for row in rows:
        counts[row['status']] = counts.get(row['status'], 0) + 1
    return {
        'date': date,
        'source': 'Build-time download from the book pages (sourceUrl) on '
                  'kitobkhon.net and khirad.tj; the app never fetches covers.',
        'userAgent': USER_AGENT,
        'rules': {
            'delaySeconds': DELAY,
            'minSize': [MIN_WIDTH, MIN_HEIGHT],
            'placeholderPaths': list(PLACEHOLDER_PATHS),
            'sharedImageLimit': SHARED_LIMIT,
        },
        'counts': counts,
        'deadLinks': dead_links(state),
        'covers': rows,
    }, results


def apply(root, state, results):
    """Bundles every kept cover the app does not have yet."""
    path = os.path.join(root, BOOKS)
    with open(path, encoding='utf-8') as handle:
        books = json.load(handle)
    names = asset_names(books)
    added = 0
    for book in books:
        for edition in book['editions']:
            result = results.get(edition['id'], {})
            if result.get('status') != 'ok' or edition.get('coverAssetPath'):
                continue
            source = result['file']
            extension = os.path.splitext(source)[1]
            asset = f'{COVERS}/{names[edition["id"]]}{extension}'
            shutil.copyfile(source, os.path.join(root, asset))
            edition['coverAssetPath'] = asset
            if not edition.get('coverUrl'):
                edition['coverUrl'] = state[edition['id']]['cover']['url']
            added += 1
    with open(path, 'w', encoding='utf-8') as handle:
        handle.write(json.dumps(books, ensure_ascii=False, indent=2) + '\n')
    return added


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    parser.add_argument('--limit', type=int)
    parser.add_argument('--report-only', action='store_true')
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--date', default=datetime.date.today().isoformat())
    args = parser.parse_args(argv)
    work = os.path.join(ROOT, WORK)
    if args.report_only or args.apply:
        state = load_state(os.path.join(work, 'state.json'))
    else:
        state = download(ROOT, args.limit)
    data, results = report(ROOT, state, args.date)
    out = os.path.join(ROOT, f'docs/content/BOOK_COVERS_{args.date}.json')
    with open(out, 'w', encoding='utf-8') as handle:
        handle.write(json.dumps(data, ensure_ascii=False, indent=1) + '\n')
    print(json.dumps(data['counts']), f'dead links: {len(data["deadLinks"])}')
    if args.apply:
        print(f'bundled {apply(ROOT, state, results)} covers')
    return 0


if __name__ == '__main__':
    sys.exit(main())
