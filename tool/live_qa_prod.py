import asyncio
import sys
from playwright.async_api import async_playwright

async def run_live_qa(url):
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        context = await browser.new_context(viewport={"width": 390, "height": 844})
        page = await context.new_page()
        
        errors = []
        page.on("console", lambda msg: errors.append(f"Console {msg.type}: {msg.text}") if msg.type in ["error"] else None)
        page.on("requestfailed", lambda req: errors.append(f"Failed to load: {req.url}"))

        print(f"Loading {url} ...")
        await page.goto(url, wait_until="networkidle", timeout=30000)
        
        # Test 1: no blank screen (wait for flutter to render)
        await asyncio.sleep(5)
        body_html = await page.content()
        
        print("Waiting for flutter...")
        # Check manifest
        manifest = await page.evaluate("() => document.querySelector('link[rel=manifest]')?.href")
        print(f"Manifest link: {manifest}")

        # Check Service Worker
        sw = await page.evaluate("() => navigator.serviceWorker ? navigator.serviceWorker.getRegistrations().then(r => r.length) : 0")
        print(f"Service Workers registered: {sw}")

        # Ensure no CSP errors in errors array
        csp_errors = [e for e in errors if 'Content Security Policy' in e]

        # Basic screenshot to verify visual loading
        await page.screenshot(path="live_qa_final.png")

        print(f"Errors encountered: {errors}")
        print(f"CSP Errors: {csp_errors}")
        await browser.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <url>")
    else:
        asyncio.run(run_live_qa(sys.argv[1]))
