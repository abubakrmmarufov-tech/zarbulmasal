import asyncio
import json
import os
import sys
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

ROUTES = [
    ('/', 'home'),
    ('/#/proverbs', 'proverbs'),
    ('/#/daily', 'daily'),
    ('/#/quiz', 'quiz'),
    ('/#/flashcards', 'flashcards'),
    ('/#/categories', 'categories'),
    ('/#/levels', 'levels'),
    ('/#/favorites', 'favorites'),
    ('/#/settings', 'settings'),
    ('/#/literature', 'literature_hub'),
    ('/#/literature/poets', 'poets'),
    ('/#/literature/poet/rudaki', 'poet_rudaki'),
    ('/#/literature/works', 'works'),
    ('/#/literature/school', 'school_canon'),
    ('/#/literature/search', 'literature_search'),
    ('/#/history', 'history'),
]

INIT_SCRIPT_DEFAULT = '''
try {
    window.localStorage.setItem('flutter.onboarding_complete', 'true');
    window.localStorage.setItem('flutter.display_language', 'tj');
    window.localStorage.setItem('flutter.dark_mode', 'false');
} catch(e) {}
'''

INIT_SCRIPT_FA = '''
try {
    window.localStorage.setItem('flutter.onboarding_complete', 'true');
    window.localStorage.setItem('flutter.display_language', 'fa');
    window.localStorage.setItem('flutter.dark_mode', 'false');
} catch(e) {}
'''

INIT_SCRIPT_DARK = '''
try {
    window.localStorage.setItem('flutter.onboarding_complete', 'true');
    window.localStorage.setItem('flutter.display_language', 'tj');
    window.localStorage.setItem('flutter.dark_mode', 'true');
} catch(e) {}
'''

async def dismiss_coach_marks(page):
    try:
        skip_btn = page.locator('button:has-text("Гузаштан"), button:has-text("رد کردن")')
        if await skip_btn.count() > 0:
            await skip_btn.first.click(timeout=1000)
            await page.wait_for_timeout(400)
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
            page.on('console', lambda msg: console_logs.append(f'{msg.type}: {msg.text}') if msg.type in ('error', 'warning') else None)
            page.on('pageerror', lambda err: page_errors.append(str(err)))

            try:
                await page.goto(BASE_URL, wait_until='networkidle', timeout=45000)
                await page.wait_for_timeout(2500)
                await dismiss_coach_marks(page)

                overflow = await page.evaluate('''() => ({
                    docScroll: document.documentElement.scrollWidth,
                    winInner: window.innerWidth,
                    bodyScroll: document.body.scrollWidth,
                    hasOverflow: document.documentElement.scrollWidth > window.innerWidth + 1 || document.body.scrollWidth > window.innerWidth + 1
                })''')

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
                })
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

        for route, name in ROUTES:
            url = BASE_URL.rstrip('/') + route
            try:
                print(f'  Visiting {name}: {url}', flush=True)
                await page.goto(url, wait_until='networkidle', timeout=30000)
                await page.wait_for_timeout(2000)
                await dismiss_coach_marks(page)
                screenshot_path = os.path.join(OUT_DIR, f'route_{name}_390.png')
                await page.screenshot(path=screenshot_path)
                report['routes_tested'].append({'route': route, 'name': name, 'status': 'ok'})
            except Exception as e:
                print(f'  Failed {name}: {e}', flush=True)
                report['routes_tested'].append({'route': route, 'name': name, 'error': str(e)})

        await context.close()

        # Pass 3: Test Persian / RTL mode
        print('Testing Persian / RTL mode...', flush=True)
        context_fa = await browser.new_context(
            viewport={'width': 390, 'height': 844},
            device_scale_factor=1,
        )
        await context_fa.add_init_script(INIT_SCRIPT_FA)
        page_fa = await context_fa.new_page()
        for route, name in [
            ('/', 'home_fa'),
            ('/#/proverbs', 'proverbs_fa'),
            ('/#/literature', 'literature_fa'),
            ('/#/history', 'history_fa'),
            ('/#/quiz', 'quiz_fa'),
            ('/#/flashcards', 'flashcards_fa'),
            ('/#/daily', 'daily_fa'),
        ]:
            url = BASE_URL.rstrip('/') + route
            try:
                print(f'  Visiting FA {name}: {url}', flush=True)
                await page_fa.goto(url, wait_until='networkidle', timeout=30000)
                await page_fa.wait_for_timeout(2000)
                await dismiss_coach_marks(page_fa)
                screenshot_path = os.path.join(OUT_DIR, f'fa_{name}_390.png')
                await page_fa.screenshot(path=screenshot_path)
            except Exception as e:
                print(f'  Failed fa {name}: {e}', flush=True)

        await context_fa.close()

        # Pass 4: Test Dark Mode
        print('Testing Dark Mode...', flush=True)
        context_dark = await browser.new_context(
            viewport={'width': 390, 'height': 844},
            device_scale_factor=1,
        )
        await context_dark.add_init_script(INIT_SCRIPT_DARK)
        page_dark = await context_dark.new_page()
        for route, name in [
            ('/', 'home_dark'),
            ('/#/proverbs', 'proverbs_dark'),
            ('/#/literature', 'literature_dark'),
            ('/#/literature/poet/rudaki', 'poet_dark'),
            ('/#/history', 'history_dark'),
            ('/#/quiz', 'quiz_dark'),
        ]:
            url = BASE_URL.rstrip('/') + route
            try:
                print(f'  Visiting Dark {name}: {url}', flush=True)
                await page_dark.goto(url, wait_until='networkidle', timeout=30000)
                await page_dark.wait_for_timeout(2000)
                await dismiss_coach_marks(page_dark)
                screenshot_path = os.path.join(OUT_DIR, f'dark_{name}_390.png')
                await page_dark.screenshot(path=screenshot_path)
            except Exception as e:
                print(f'  Failed dark {name}: {e}', flush=True)

        await context_dark.close()
        await browser.close()

    summary_file = os.path.join(OUT_DIR, 'audit_report.json')
    with open(summary_file, 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    print(f'Audit complete! Report saved to {summary_file}', flush=True)

if __name__ == '__main__':
    asyncio.run(audit())
