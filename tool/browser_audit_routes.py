"""Routes for the deep browser audit: the app's route patterns, read from
the router source, and a concrete URL for each, taken from the checked-in
data (see deep_browser_audit.py)."""
import asyncio
import json
import os
import re
import sys
from urllib.parse import quote
from playwright.async_api import async_playwright

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
ROUTER_SOURCE = 'lib/router/app_router.dart'


def _strip_dart_comments(source):
    """Mask Dart comments without changing source offsets or quoted strings."""
    output = []
    index = 0
    quote = None
    triple_quoted = False
    raw_string = False
    block_comment_depth = 0

    while index < len(source):
        if block_comment_depth:
            if source.startswith('/*', index):
                block_comment_depth += 1
                output.extend('  ')
                index += 2
            elif source.startswith('*/', index):
                block_comment_depth -= 1
                output.extend('  ')
                index += 2
            else:
                output.append('\n' if source[index] == '\n' else ' ')
                index += 1
            continue

        if quote is not None:
            closing = quote * (3 if triple_quoted else 1)
            if source.startswith(closing, index):
                output.append(closing)
                index += len(closing)
                quote = None
                triple_quoted = False
                raw_string = False
            elif source[index] == '\\' and not raw_string:
                output.append(source[index:index + 2])
                index += 2
            else:
                output.append(source[index])
                index += 1
            continue

        if source.startswith('//', index):
            newline = source.find('\n', index)
            if newline == -1:
                output.extend(' ' * (len(source) - index))
                break
            output.extend(' ' * (newline - index))
            output.append('\n')
            index = newline + 1
            continue
        if source.startswith('/*', index):
            block_comment_depth = 1
            output.extend('  ')
            index += 2
            continue

        character = source[index]
        if character in ('\'', '"'):
            quote = character
            triple_quoted = source.startswith(character * 3, index)
            previous_is_raw_prefix = (
                index > 0
                and source[index - 1] in ('r', 'R')
                and (index == 1 or not (source[index - 2].isalnum() or source[index - 2] == '_'))
            )
            raw_string = previous_is_raw_prefix
            delimiter_length = 3 if triple_quoted else 1
            output.append(source[index:index + delimiter_length])
            index += delimiter_length
            continue

        output.append(character)
        index += 1

    return ''.join(output)


def _mask_dart_string_contents(source):
    """Mask quoted Dart string contents so route-like examples are ignored."""
    masked = list(source)
    index = 0

    while index < len(source):
        if source[index] not in ('\'', '"'):
            index += 1
            continue

        quote = source[index]
        triple_quoted = source.startswith(quote * 3, index)
        delimiter_length = 3 if triple_quoted else 1
        raw_string = (
            index > 0
            and source[index - 1] in ('r', 'R')
            and (index == 1 or not (source[index - 2].isalnum() or source[index - 2] == '_'))
        )
        content_start = index + delimiter_length
        index = content_start

        while index < len(source):
            closing = quote * delimiter_length
            if source.startswith(closing, index):
                for content_index in range(content_start, index):
                    if source[content_index] != '\n':
                        masked[content_index] = ' '
                index += delimiter_length
                break
            if source[index] == '\\' and not raw_string:
                index += 2
            else:
                index += 1
        else:
            for content_index in range(content_start, len(source)):
                if source[content_index] != '\n':
                    masked[content_index] = ' '

    return ''.join(masked)


def _read_json_records(relative_path):
    path = os.path.join(PROJECT_ROOT, relative_path)
    with open(path, encoding='utf-8') as catalog_file:
        records = json.load(catalog_file)
    if not isinstance(records, list):
        raise ValueError(f'Expected a list in {relative_path}')
    if any(not isinstance(record, dict) for record in records):
        raise ValueError(f'Invalid catalog record in {relative_path}')
    return records


def _matching_parenthesis_end(source, opening_index):
    depth = 0
    for index in range(opening_index, len(source)):
        if source[index] == '(':
            depth += 1
        elif source[index] == ')':
            depth -= 1
            if depth == 0:
                return index
    return None


def _top_level_route_path(source, call_start, call_end):
    delimiters = {'(': ')', '[': ']', '{': '}'}
    closing_delimiters = {closing: opening for opening, closing in delimiters.items()}
    stack = []
    index = call_start

    while index < call_end:
        if not stack and (index == call_start or not (
            source[index - 1].isalnum() or source[index - 1] in '_$'
        )):
            match = re.match(
                r"path\s*:\s*(?:[rR])?(['\"])(?:\1\1)?(.*?)\1(?:\1\1)?",
                source[index:call_end],
                flags=re.DOTALL,
            )
            if match:
                trailing_expression = source[index + match.end():call_end].lstrip()
                if trailing_expression and not trailing_expression.startswith(','):
                    raise ValueError(
                        'GoRoute path must be a single static string literal'
                    )
                value_start = index + match.start(2)
                value_end = index + match.end(2)
                quote_index = index + match.start(1)
                raw_string = (
                    quote_index > 0
                    and source[quote_index - 1] in ('r', 'R')
                    and (quote_index == 1 or not (
                        source[quote_index - 2].isalnum()
                        or source[quote_index - 2] in '_$'
                    ))
                )
                return value_start, value_end, raw_string

        character = source[index]
        if character in delimiters:
            stack.append(character)
        elif character in closing_delimiters and stack:
            if stack[-1] == closing_delimiters[character]:
                stack.pop()
        index += 1

    return None


def _decode_dart_route_literal(value, raw_string):
    if raw_string:
        return value

    decoded = []
    index = 0
    simple_escapes = {
        'b': '\b',
        'f': '\f',
        'n': '\n',
        'r': '\r',
        't': '\t',
        'v': '\v',
        '\\': '\\',
        "'": "'",
        '"': '"',
        '$': '$',
    }
    while index < len(value):
        character = value[index]
        if character == '$':
            raise ValueError('Interpolated GoRoute paths are not supported')
        if character != '\\':
            decoded.append(character)
            index += 1
            continue

        index += 1
        if index >= len(value):
            raise ValueError('Incomplete escape in GoRoute path literal')
        escape = value[index]
        if escape in simple_escapes:
            decoded.append(simple_escapes[escape])
            index += 1
            continue
        if escape == 'x':
            digits = value[index + 1:index + 3]
            if len(digits) != 2 or not re.fullmatch(r'[0-9a-fA-F]{2}', digits):
                raise ValueError('Invalid hexadecimal escape in GoRoute path literal')
            decoded.append(chr(int(digits, 16)))
            index += 3
            continue
        if escape == 'u':
            if index + 1 < len(value) and value[index + 1] == '{':
                closing = value.find('}', index + 2)
                digits = value[index + 2:closing] if closing != -1 else ''
                if not 1 <= len(digits) <= 6 or not re.fullmatch(r'[0-9a-fA-F]+', digits):
                    raise ValueError('Invalid Unicode escape in GoRoute path literal')
                codepoint = int(digits, 16)
                if codepoint > 0x10FFFF:
                    raise ValueError('Unicode escape is out of range in GoRoute path literal')
                decoded.append(chr(codepoint))
                index = closing + 1
                continue
            digits = value[index + 1:index + 5]
            if len(digits) != 4 or not re.fullmatch(r'[0-9a-fA-F]{4}', digits):
                raise ValueError('Invalid Unicode escape in GoRoute path literal')
            decoded.append(chr(int(digits, 16)))
            index += 5
            continue
        if escape in ('\n', '\r'):
            index += 1
            if escape == '\r' and index < len(value) and value[index] == '\n':
                index += 1
            continue
        raise ValueError(f'Unsupported escape in GoRoute path literal: \\{escape}')

    return ''.join(decoded)


def load_router_route_patterns(router_path=None):
    """Read route templates directly from the current GoRouter declaration."""
    path = router_path or os.path.join(PROJECT_ROOT, ROUTER_SOURCE)
    with open(path, encoding='utf-8') as router_file:
        source = router_file.read()
    source_without_comments = _strip_dart_comments(source)
    source_code = _mask_dart_string_contents(source_without_comments)
    patterns = []
    for call in re.finditer(r'\bGoRoute\s*\(', source_code):
        opening_index = call.end() - 1
        closing_index = _matching_parenthesis_end(source_code, opening_index)
        if closing_index is None:
            raise ValueError(f'Unclosed GoRoute declaration in {path}')
        path_span = _top_level_route_path(
            source_code,
            opening_index + 1,
            closing_index,
        )
        if path_span is None:
            raise ValueError(f'GoRoute without a static path declaration in {path}')
        value_start, value_end, raw_string = path_span
        try:
            route_path = _decode_dart_route_literal(
                source[value_start:value_end],
                raw_string,
            )
        except ValueError as error:
            raise ValueError(f'{error} in {path}') from error
        patterns.append(route_path)
    if not patterns:
        raise ValueError(f'No GoRouter path declarations found in {path}')
    return list(dict.fromkeys(patterns))


def _browser_url(route_pattern, identifier=None):
    route_path = route_pattern
    if identifier is not None:
        route_path = route_path.replace(':id', quote(identifier, safe=''))
    return '/' if route_path == '/' else f'/#{route_path}'


def _route_name(route_pattern, identifier=None):
    if route_pattern == '/':
        return 'home'
    base = re.sub(r'[^a-zA-Z0-9]+', '_', route_pattern).strip('_')
    if identifier is not None:
        suffix = re.sub(r'[^a-zA-Z0-9]+', '_', identifier).strip('_')
        return f'{base}_{suffix}'
    return base


def _first_valid_record(relative_path, marker_key=None):
    for record in _read_json_records(relative_path):
        identifier = record.get('id')
        marker = record.get(marker_key) if marker_key else None
        if isinstance(identifier, str) and identifier.strip():
            if marker_key is None or (isinstance(marker, str) and marker.strip()):
                return record
    raise ValueError(f'No valid route fixture found in {relative_path}')


def _work_is_displayable(record):
    """Mirror LiteraryWork.isDisplayable in lib/features/literature/domain.

    The source-attested publication path accepts one exact, page-checked
    occurrence in an uploaded PDF or on maorif.tj, matching the Dart gate the
    reader actually applies. The audit must not guess pending/readable status
    by evidence level alone.
    """
    if record.get('textStatus') != 'verified':
        return False
    if not any(record.get(field) for field in ('textTajik', 'textPersian')):
        return False
    verification = record.get('verification') or {}
    primary = record.get('primarySource') or {}
    rights = record.get('rights') or {}
    if verification.get('pageVerified') is not True or primary.get('pageStart') is None:
        return False

    evidence_level = verification.get('evidenceLevel')
    rights_status = rights.get('status')
    traditionally_approved = (
        evidence_level == 'editoriallyApproved'
        and rights_status in (
            'publicDomain', 'permissionGranted', 'sourceAttested', 'folklore'
        )
        and rights.get('fullTextAllowed') is True
    )
    if traditionally_approved:
        return True

    # isPermittedSourceAttested
    checked_levels = (
        'primaryChecked', 'secondWitnessLocated', 'collated', 'editoriallyApproved'
    )
    source_reference = str(primary.get('sourceReference') or '').strip()
    if evidence_level not in checked_levels or not source_reference:
        return False
    normalized = source_reference.replace('\\', '/').lower()
    if normalized.startswith(('docs/literature/pdfs/', 'pdf books/')):
        return normalized.endswith('.pdf')

    from urllib.parse import urlparse
    uri = urlparse(source_reference)
    host = (uri.hostname or '').lower()
    return uri.scheme == 'https' and (
        host == 'maorif.tj' or host.endswith('.maorif.tj')
    )


def _first_seed_proverb_fixture():
    """Return (id, tajikCyrillic) for the first production proverb fixture."""
    # The seed list is split into parts; the first part holds the first
    # production proverb.
    seed_path = os.path.join(PROJECT_ROOT, 'lib/data/seed/seed_proverbs_part1.dart')
    with open(seed_path, encoding='utf-8') as seed_file:
        source = seed_file.read()
    match = re.search(
        r"Proverb\s*\(\s*id\s*:\s*(['\"])(.*?)\1,(.*?)(?=\n\s*\),)",
        source,
        flags=re.DOTALL,
    )
    marker_match = (
        re.search(
            r"tajikCyrillic\s*:\s*(['\"])((?:\\.|(?!\1).)*)\1",
            match.group(3),
        )
        if match
        else None
    )
    if not match or not marker_match:
        raise ValueError(f'No proverb route fixture found in {seed_path}')
    return match.group(2), marker_match.group(2)


def _dynamic_route_records(route_pattern):
    """Return (id, visible marker) fixtures for a supported dynamic route."""
    if route_pattern == '/literature/poet/:id':
        all_poets = _read_json_records('assets/data/literature/poets.json')
        return [
            (record.get('id'), record.get('canonicalName'))
            for record in all_poets
            if record.get('recordStatus', 'active') == 'active'
            and isinstance(record.get('canonicalName'), str)
            and record['canonicalName'].strip()
            and record['canonicalName'].strip().lower() != 'unknown'
        ]
    if route_pattern == '/literature/poets/:id':
        all_poets = _read_json_records('assets/data/literature/poets.json')
        record = next(
            (
                item for item in all_poets
                if item.get('recordStatus', 'active') == 'active'
                and item.get('id')
                and item.get('canonicalName')
                and item['canonicalName'].strip().lower() != 'unknown'
            ),
            None,
        )
        return [(record['id'], record['canonicalName'])] if record else []
    if route_pattern in ('/literature/work/:id', '/literature/works/:id'):
        works = _read_json_records('assets/data/literature/works.json')

        # The Dart reader shows a displayable work's title before it ever
        # consults the pending marker, so readable works must win the fixture.
        displayable_work = next((
            record for record in works
            if isinstance(record.get('id'), str)
            and record['id'].strip()
            and isinstance(record.get('title'), str)
            and record['title'].strip()
            and _work_is_displayable(record)
        ), None)
        if displayable_work:
            return [(displayable_work['id'], displayable_work['title'])]

        # A work still under review is only "pending" when the Dart readable
        # gate has NOT opened it.
        pending_work = next((
            record for record in works
            if isinstance(record.get('id'), str)
            and record['id'].strip()
            and isinstance(record.get('title'), str)
            and record['title'].strip()
            and (record.get('verification') or {}).get('evidenceLevel')
            in ('needsReview', 'primaryChecked')
            and not _work_is_displayable(record)
        ), None)
        if pending_work:
            return [(pending_work['id'], 'Асар дар санҷиш аст')]
        raise ValueError('No approved or reviewable literary work route fixture exists')
    if route_pattern == '/history/:id':
        first_history_entry = _first_valid_record('assets/data/history/entries.json', 'title')
        return [(first_history_entry['id'], first_history_entry['title'])]
    if route_pattern == '/books/:id':
        all_books = _read_json_records('assets/data/books/books.json')
        return [
            (record.get('id'), record.get('titleTj'))
            for record in all_books
        ]
    if route_pattern == '/books/category/:id':
        all_books = _read_json_records('assets/data/books/books.json')
        first_category = next((
            category
            for book in all_books
            for category in book.get('categoryIds', [])
            if isinstance(category, str)
            and category.strip()
            and isinstance(book.get('titleTj'), str)
            and book['titleTj'].strip()
        ), None)
        if first_category is None:
            return []
        matching_count = sum(
            first_category in book.get('categoryIds', []) for book in all_books
        )
        return [(first_category, f'{matching_count} китоб')]
    if route_pattern == '/books/author/:id':
        all_books = _read_json_records('assets/data/books/books.json')
        first_author = next((
            book.get('authorId')
            for book in all_books
            if isinstance(book.get('authorId'), str)
            and book['authorId'].strip()
            and isinstance(book.get('titleTj'), str)
            and book['titleTj'].strip()
        ), None)
        if first_author is None:
            return []
        matching_count = sum(book.get('authorId') == first_author for book in all_books)
        return [(first_author, f'{matching_count} китоб')]
    if route_pattern == '/proverb/:id':
        return [_first_seed_proverb_fixture()]
    if route_pattern == '/vocabulary/:id':
        # Vocabulary entries are aggregated at runtime from proverbs, history,
        # and literary authors. The proverb-backed fixture mirrors the route
        # smoke test (test/mobile_route_smoke_test.dart), which exercises
        # /vocabulary/vocab-proverb-21, and its marker is the entry's term —
        # the real proverb text rendered as the detail title.
        proverb_id, proverb_term = _first_seed_proverb_fixture()
        return [(f'vocab-proverb-{proverb_id}', proverb_term)]
    if route_pattern == '/saved/bayoz/:id':
        # A reader's own collection: a fresh browser has none, so the
        # screen is opened on an id that shows its not-found state.
        return [('audit-missing-collection', None)]
    raise ValueError(f'No browser fixture is defined for dynamic route {route_pattern}')


def load_browser_route_cases(route_patterns=None):
    """Build route cases from GoRouter plus checked-in catalog fixtures.

    All publicly renderable poet and book detail records are exercised. Other
    dynamic route types get a representative real ID, and every static route
    is tested directly.
    New unsupported dynamic routes fail closed so the QA inventory cannot
    silently omit a newly added screen.
    """
    patterns = route_patterns if route_patterns is not None else load_router_route_patterns()
    cases = []
    seen = set()
    for pattern in patterns:
        if ':' in pattern:
            records = _dynamic_route_records(pattern)
            for identifier, marker in records:
                if not isinstance(identifier, str) or not identifier.strip():
                    raise ValueError(f'Missing catalog ID for route {pattern}')
                if marker is not None and (not isinstance(marker, str) or not marker.strip()):
                    raise ValueError(f'Missing expected route marker for {pattern}/{identifier}')
                route = _browser_url(pattern, identifier)
                case = (pattern, route, _route_name(pattern, identifier), marker)
                if (pattern, route) not in seen:
                    cases.append(case)
                    seen.add((pattern, route))
        else:
            route = _browser_url(pattern)
            cases.append((pattern, route, _route_name(pattern), None))
    return cases


def load_catalog_detail_routes():
    """Return all source-backed poet and book detail routes for browser QA."""
    return [
        (route, name, marker)
        for pattern, route, name, marker in load_browser_route_cases()
        if pattern in ('/literature/poet/:id', '/books/:id')
    ]


def iter_routes_for_browser_qa():
    """Yield router-derived routes, including catalog detail pages."""
    for _, route, name, marker in load_browser_route_cases():
        yield route, name, marker
