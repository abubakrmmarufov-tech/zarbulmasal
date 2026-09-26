import asyncio
import json
import os
import re
import sys
from urllib.parse import quote
from playwright.async_api import async_playwright

BASE_URL = sys.argv[1] if len(sys.argv) > 1 else 'https://abubakrmmarufov-tech.github.io/zarbulmasal/'
OUT_DIR = sys.argv[2] if len(sys.argv) > 2 else '/tmp/zarbulmasal_audit'

VIEWPORTS = [
    ('320x568', 320, 568),
    ('360x800', 360, 800),
    ('375x667', 375, 667),
    ('390x844', 390, 844),
    ('430x932', 430, 932),
    ('landscape_844x390', 844, 390),
    ('tablet_800x1280', 800, 1280),
    ('desktop_1280x800', 1280, 800),
]

try:
    from tool.browser_audit_routes import (  # noqa: F401
        PROJECT_ROOT,
        ROUTER_SOURCE,
        _work_is_displayable,
        load_browser_route_cases,
        load_catalog_detail_routes,
        load_router_route_patterns,
        iter_routes_for_browser_qa,
    )
except ImportError:  # run as a script from tool/
    from browser_audit_routes import (  # noqa: F401
        PROJECT_ROOT,
        ROUTER_SOURCE,
        _work_is_displayable,
        load_browser_route_cases,
        load_catalog_detail_routes,
        load_router_route_patterns,
        iter_routes_for_browser_qa,
    )

INIT_SCRIPT_DEFAULT = '''
try {
    window.localStorage.setItem('flutter.onboarding_complete', JSON.stringify(true));
    window.localStorage.setItem('flutter.display_language', JSON.stringify('tj'));
    window.localStorage.setItem('flutter.dark_mode', JSON.stringify(false));
} catch(e) {}
'''

INIT_SCRIPT_FA = '''
try {
    window.localStorage.setItem('flutter.onboarding_complete', JSON.stringify(true));
    window.localStorage.setItem('flutter.display_language', JSON.stringify('fa'));
    window.localStorage.setItem('flutter.dark_mode', JSON.stringify(false));
} catch(e) {}
'''

INIT_SCRIPT_DARK = '''
try {
    window.localStorage.setItem('flutter.onboarding_complete', JSON.stringify(true));
    window.localStorage.setItem('flutter.display_language', JSON.stringify('tj'));
    window.localStorage.setItem('flutter.dark_mode', JSON.stringify(true));
} catch(e) {}
'''

PERSIAN_MARKERS = {
    '/': ('خانه', 'ضرب‌المثل‌ها'),
    '/#/proverbs': ('ضرب‌المثل‌ها',),
    '/#/literature': ('میراث ادبی',),
    '/#/history': ('تاریخ مردم تاجیک',),
    '/#/quiz': ('آزمون',),
    '/#/flashcards': ('کارت‌های آموزشی',),
    '/#/daily': ('ضرب‌المثل روز',),
    '/#/books': ('کتابخانه',),
    '/#/books/badi-boron': ('کتابخانه', 'منبع: kitobkhon.net'),
}

def load_persian_route_cases(route_cases=None):
    """Resolve the Persian visual-smoke routes against the current inventory."""
    available_cases = route_cases or load_browser_route_cases()
    by_url = {route: (name, marker) for _, route, name, marker in available_cases}
    resolved = []
    for route in PERSIAN_MARKERS:
        if route not in by_url:
            raise ValueError(f'Persian QA route is not present in GoRouter: {route}')
        name, _ = by_url[route]
        resolved.append((route, f'{name}_fa', PERSIAN_MARKERS[route]))
    return resolved


def load_dark_mode_route_cases(route_cases=None):
    """Select current GoRouter cases for dark-mode visual smoke coverage."""
    available_cases = route_cases or load_browser_route_cases()
    preferred_patterns = (
        '/',
        '/proverbs',
        '/books',
        '/literature',
        '/literature/poet/:id',
        '/history',
        '/quiz',
    )
    by_pattern = {}
    for pattern, route, name, _ in available_cases:
        by_pattern.setdefault(pattern, (route, name))
    missing_patterns = [
        pattern for pattern in preferred_patterns if pattern not in by_pattern
    ]
    if missing_patterns:
        raise ValueError(f'Dark-mode QA routes are not present in GoRouter: {missing_patterns}')
    return [
        (by_pattern[pattern][0], f'{by_pattern[pattern][1]}_dark')
        for pattern in preferred_patterns
    ]


async def dismiss_coach_marks(page):
    try:
        skip_btn = page.locator('button:has-text("Гузаштан"), button:has-text("رد کردن")')
        if await skip_btn.count() > 0:
            await skip_btn.first.click(timeout=1000)
            await page.wait_for_timeout(400)
    except Exception:
        pass


async def enable_accessibility(page):
    """Expose Flutter's semantics tree so localized route assertions inspect real UI text."""
    try:
        placeholder = page.locator('flt-semantics-placeholder')
        if await placeholder.count() > 0:
            await page.evaluate(
                "document.querySelector('flt-semantics-placeholder')?.click()"
            )
            await page.wait_for_timeout(300)
    except Exception:
        pass

async def audit():
    os.makedirs(OUT_DIR, exist_ok=True)
    report = {
        'base_url': BASE_URL,
        'viewports_tested': [],
        'routes_tested': [],
        'errors': [],
        'overflows': [],
        'console_errors': [],
        'page_errors': [],
        'request_failures': [],
    }

    async with async_playwright() as p:
        browser = await p.chromium.launch()

        # Pass 1: Test key viewports on home
        for vp_name, width, height in VIEWPORTS:
            print(f'Auditing viewport {vp_name} ({width}x{height})...', flush=True)
            context = await browser.new_context(
                viewport={'width': width, 'height': height},
                device_scale_factor=1,
            )
            await context.add_init_script(INIT_SCRIPT_DEFAULT)
            page = await context.new_page()

            console_logs = []
            page_errors = []
            request_failures = []
            page.on('console', lambda msg: console_logs.append(f'{msg.type}: {msg.text}') if msg.type in ('error', 'warning') else None)
            page.on('pageerror', lambda err: page_errors.append(str(err)))
            page.on('requestfailed', lambda request: request_failures.append(
                f'{request.method} {request.url}: {request.failure}'
            ))

            try:
                await page.goto(BASE_URL, wait_until='networkidle', timeout=45000)
                await page.wait_for_timeout(2500)
                await dismiss_coach_marks(page)

                overflow = await page.evaluate('''() => {
                    // Flutter's semantics bridge adds a top-level, off-screen
                    // paragraph whose width is not application layout. Keep
                    // raw bodyScroll for diagnosis, but judge overflow from
                    // the actual non-semantics layout roots.
                    const layoutRoots = [...document.body.children].filter(
                        (element) => element.tagName !== 'P',
                    );
                    const layoutScroll = Math.max(
                        window.innerWidth,
                        ...layoutRoots.map(
                            (element) => element.getBoundingClientRect().right,
                        ),
                    );
                    return {
                        docScroll: document.documentElement.scrollWidth,
                        winInner: window.innerWidth,
                        bodyScroll: document.body.scrollWidth,
                        layoutScroll,
                        hasOverflow:
                            document.documentElement.scrollWidth > window.innerWidth + 1 ||
                            layoutScroll > window.innerWidth + 1,
                    };
                }''')

                screenshot_path = os.path.join(OUT_DIR, f'home_{vp_name}.png')
                await page.screenshot(path=screenshot_path)

                if overflow['hasOverflow']:
                    report['overflows'].append({
                        'viewport': vp_name,
                        'route': '/',
                        'overflow': overflow,
                    })

                report['viewports_tested'].append({
                    'viewport': vp_name,
                    'width': width,
                    'height': height,
                    'overflow': overflow,
                    'console_logs': console_logs,
                    'page_errors': page_errors,
                    'request_failures': request_failures,
                })
                report['console_errors'].extend(
                    {'viewport': vp_name, 'message': message}
                    for message in console_logs
                    if message.startswith('error:')
                )
                report['page_errors'].extend(
                    {'viewport': vp_name, 'message': message}
                    for message in page_errors
                )
                report['request_failures'].extend(
                    {'viewport': vp_name, 'message': message}
                    for message in request_failures
                )
            except Exception as e:
                report['errors'].append({'viewport': vp_name, 'error': str(e)})
            finally:
                await context.close()

        # Pass 2: Test all routes at 390x844 (standard mobile)
        print('Testing all routes at 390x844...', flush=True)
        context = await browser.new_context(
            viewport={'width': 390, 'height': 844},
            device_scale_factor=1,
        )
        await context.add_init_script(INIT_SCRIPT_DEFAULT)
        page = await context.new_page()
        route_diagnostics = {
            'console_errors': [],
            'page_errors': [],
            'request_failures': [],
        }
        page.on('console', lambda msg: route_diagnostics['console_errors'].append(msg.text) if msg.type == 'error' else None)
        page.on('pageerror', lambda err: route_diagnostics['page_errors'].append(str(err)))
        page.on('requestfailed', lambda request: route_diagnostics['request_failures'].append(
            f'{request.method} {request.url}: {request.failure}'
        ))

        for route, name, expected_marker in iter_routes_for_browser_qa():
            url = BASE_URL.rstrip('/') + route
            route_diagnostics['console_errors'] = []
            route_diagnostics['page_errors'] = []
            route_diagnostics['request_failures'] = []
            try:
                print(f'  Visiting {name}: {url}', flush=True)
                await page.goto(url, wait_until='networkidle', timeout=30000)
                await page.wait_for_timeout(500 if expected_marker else 2000)
                await dismiss_coach_marks(page)
                overflow = await page.evaluate('''() => {
                    // Ignore the off-screen semantics paragraph when it is
                    // enabled for catalog-marker assertions.
                    const layoutRoots = [...document.body.children].filter(
                        (element) => element.tagName !== 'P',
                    );
                    const layoutScroll = Math.max(
                        window.innerWidth,
                        ...layoutRoots.map(
                            (element) => element.getBoundingClientRect().right,
                        ),
                    );
                    return {
                        docScroll: document.documentElement.scrollWidth,
                        winInner: window.innerWidth,
                        bodyScroll: document.body.scrollWidth,
                        layoutScroll,
                        hasOverflow:
                            document.documentElement.scrollWidth > window.innerWidth + 1 ||
                            layoutScroll > window.innerWidth + 1,
                    };
                }''')
                if expected_marker:
                    # Measure layout before enabling Flutter semantics. The
                    # semantics bridge adds an off-screen accessibility
                    # paragraph whose width is not app layout.
                    await enable_accessibility(page)
                    body_text = await page.locator('body').inner_text()
                    # Names the catalogue stores in capitals («АНВАРӢ») are
                    # shown in title case, so markers ignore case.
                    if expected_marker.casefold() not in body_text.casefold():
                        raise AssertionError(
                            f'Catalog route {route} is missing its expected marker '
                            f'{expected_marker!r}'
                        )
                if overflow['hasOverflow']:
                    report['overflows'].append({
                        'viewport': '390x844',
                        'route': route,
                        'overflow': overflow,
                    })
                if expected_marker is None:
                    screenshot_path = os.path.join(OUT_DIR, f'route_{name}_390.png')
                    await page.screenshot(path=screenshot_path)
                diagnostics = {
                    'console_errors': route_diagnostics['console_errors'][:],
                    'page_errors': route_diagnostics['page_errors'][:],
                    'request_failures': route_diagnostics['request_failures'][:],
                }
                report['routes_tested'].append({
                    'route': route,
                    'name': name,
                    'status': 'ok' if not any(diagnostics.values()) else 'failed',
                    'overflow': overflow,
                    'diagnostics': diagnostics,
                })
                report['console_errors'].extend(
                    {'route': route, 'message': message}
                    for message in diagnostics['console_errors']
                )
                report['page_errors'].extend(
                    {'route': route, 'message': message}
                    for message in diagnostics['page_errors']
                )
                report['request_failures'].extend(
                    {'route': route, 'message': message}
                    for message in diagnostics['request_failures']
                )
            except Exception as e:
                print(f'  Failed {name}: {e}', flush=True)
                report['routes_tested'].append({'route': route, 'name': name, 'error': str(e)})
                report['errors'].append({'route': route, 'name': name, 'error': str(e)})

        await context.close()

        # Pass 3: Test Persian / RTL mode
        print('Testing Persian / RTL mode...', flush=True)
        context_fa = await browser.new_context(
            viewport={'width': 390, 'height': 844},
            device_scale_factor=1,
        )
        await context_fa.add_init_script(INIT_SCRIPT_FA)
        page_fa = await context_fa.new_page()
        fa_diagnostics = {
            'console_errors': [],
            'page_errors': [],
            'request_failures': [],
        }
        page_fa.on('console', lambda msg: fa_diagnostics['console_errors'].append(msg.text) if msg.type == 'error' else None)
        page_fa.on('pageerror', lambda err: fa_diagnostics['page_errors'].append(str(err)))
        page_fa.on('requestfailed', lambda request: fa_diagnostics['request_failures'].append(
            f'{request.method} {request.url}: {request.failure}'
        ))
        for route, name, expected_markers in load_persian_route_cases():
            url = BASE_URL.rstrip('/') + route
            fa_diagnostics['console_errors'] = []
            fa_diagnostics['page_errors'] = []
            fa_diagnostics['request_failures'] = []
            try:
                print(f'  Visiting FA {name}: {url}', flush=True)
                await page_fa.goto(url, wait_until='networkidle', timeout=30000)
                await page_fa.wait_for_timeout(2000)
                await dismiss_coach_marks(page_fa)
                await enable_accessibility(page_fa)
                body_text = await page_fa.locator('body').inner_text()
                missing_markers = [
                    marker
                    for marker in expected_markers
                    if marker not in body_text
                ]
                if missing_markers:
                    raise AssertionError(
                        f'Persian route {route} is missing localized markers: '
                        f'{missing_markers}'
                    )
                if 'Асосӣ' in body_text:
                    raise AssertionError(
                        f'Persian route {route} rendered the Tajik home navigation label'
                    )
                screenshot_path = os.path.join(OUT_DIR, f'fa_{name}_390.png')
                await page_fa.screenshot(path=screenshot_path)
                report['routes_tested'].append({
                    'route': route,
                    'name': name,
                    'mode': 'persian',
                    'status': 'ok' if not any(fa_diagnostics.values()) else 'failed',
                    'diagnostics': {key: value[:] for key, value in fa_diagnostics.items()},
                })
                report['console_errors'].extend(
                    {'route': route, 'mode': 'persian', 'message': message}
                    for message in fa_diagnostics['console_errors']
                )
                report['page_errors'].extend(
                    {'route': route, 'mode': 'persian', 'message': message}
                    for message in fa_diagnostics['page_errors']
                )
                report['request_failures'].extend(
                    {'route': route, 'mode': 'persian', 'message': message}
                    for message in fa_diagnostics['request_failures']
                )
            except Exception as e:
                print(f'  Failed fa {name}: {e}', flush=True)
                report['errors'].append({'route': route, 'name': name, 'mode': 'persian', 'error': str(e)})

        await context_fa.close()

        # Pass 4: Test Dark Mode
        print('Testing Dark Mode...', flush=True)
        context_dark = await browser.new_context(
            viewport={'width': 390, 'height': 844},
            device_scale_factor=1,
        )
        await context_dark.add_init_script(INIT_SCRIPT_DARK)
        page_dark = await context_dark.new_page()
        dark_diagnostics = {
            'console_errors': [],
            'page_errors': [],
            'request_failures': [],
        }
        page_dark.on('console', lambda msg: dark_diagnostics['console_errors'].append(msg.text) if msg.type == 'error' else None)
        page_dark.on('pageerror', lambda err: dark_diagnostics['page_errors'].append(str(err)))
        page_dark.on('requestfailed', lambda request: dark_diagnostics['request_failures'].append(
            f'{request.method} {request.url}: {request.failure}'
        ))
        for route, name in load_dark_mode_route_cases():
            url = BASE_URL.rstrip('/') + route
            dark_diagnostics['console_errors'] = []
            dark_diagnostics['page_errors'] = []
            dark_diagnostics['request_failures'] = []
            try:
                print(f'  Visiting Dark {name}: {url}', flush=True)
                await page_dark.goto(url, wait_until='networkidle', timeout=30000)
                await page_dark.wait_for_timeout(2000)
                await dismiss_coach_marks(page_dark)
                screenshot_path = os.path.join(OUT_DIR, f'dark_{name}_390.png')
                await page_dark.screenshot(path=screenshot_path)
                report['routes_tested'].append({
                    'route': route,
                    'name': name,
                    'mode': 'dark',
                    'status': 'ok' if not any(dark_diagnostics.values()) else 'failed',
                    'diagnostics': {key: value[:] for key, value in dark_diagnostics.items()},
                })
                report['console_errors'].extend(
                    {'route': route, 'mode': 'dark', 'message': message}
                    for message in dark_diagnostics['console_errors']
                )
                report['page_errors'].extend(
                    {'route': route, 'mode': 'dark', 'message': message}
                    for message in dark_diagnostics['page_errors']
                )
                report['request_failures'].extend(
                    {'route': route, 'mode': 'dark', 'message': message}
                    for message in dark_diagnostics['request_failures']
                )
            except Exception as e:
                print(f'  Failed dark {name}: {e}', flush=True)
                report['errors'].append({'route': route, 'name': name, 'mode': 'dark', 'error': str(e)})

        await context_dark.close()
        await browser.close()

    summary_file = os.path.join(OUT_DIR, 'audit_report.json')
    with open(summary_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    print(f'Audit complete! Report saved to {summary_file}', flush=True)
    failures = {
        key: value
        for key, value in report.items()
        if key in ('errors', 'overflows', 'console_errors', 'page_errors', 'request_failures') and value
    }
    if failures:
        print(f'Audit failed: {json.dumps(failures, ensure_ascii=False)}', file=sys.stderr)
        raise SystemExit(1)

if __name__ == '__main__':
    asyncio.run(audit())
