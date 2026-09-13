import asyncio
import sys
from playwright.async_api import async_playwright

async def run_live_qa(url):
    async with async_playwright() as p:
        browser = await p.chromium.launch()
        context = await browser.new_context(viewport={"width": 390, "height": 844})
        page = await context.new_page()
        
        errors = []
        page.on("console", lambda msg: errors.append(f"Console {msg.type}: {msg.text}") if msg.type in ["error", "warning"] else None)
        page.on("requestfailed", lambda req: errors.append(f"Failed to load: {req.url}"))

        print(f"Loading {url} ...")
        await page.goto(url, wait_until="networkidle", timeout=20000)
        
        # Test 1: no blank screen (wait for flutter to render)
        await asyncio.sleep(5)
        body_html = await page.content()
        if "<canvas" not in body_html and "<flt-glass-pane" not in body_html:
            errors.append("Flutter app didn't render properly (no canvas or flt-glass-pane found).")

        # Check manifest
        manifest = await page.evaluate("() => document.querySelector('link[rel=manifest]')?.href")
        print(f"Manifest link: {manifest}")

        # Basic screenshot to verify visual loading
        await page.screenshot(path="live_qa_home.png")

        # Stop network to test offline? 
        # But we also need to click around. We'll do it if necessary.
        print(f"Errors encountered: {errors}")
        await browser.close()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python script.py <url>")
    else:
        asyncio.run(run_live_qa(sys.argv[1]))
