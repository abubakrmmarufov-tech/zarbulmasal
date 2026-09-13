"""Read-only Playwright smoke suite for the deployed Flutter web app.

Flutter CanvasKit renders the app into a canvas, so its semantics tree is not
always available to headless Chromium. The interaction checks therefore use
coordinates derived from the stable phone layout and assert visible screenshot
changes after each action.
"""

from __future__ import annotations

import asyncio
import json
import sys

from playwright.async_api import TimeoutError as PlaywrightTimeoutError
from playwright.async_api import async_playwright


VIEWPORTS = (
    (320, 568),
    (375, 667),
    (390, 844),
    (430, 932),
    (568, 320),
)


async def load_app(page, url: str) -> None:
    # Flutter's service worker keeps requests alive, so networkidle needs a
    # generous timeout; it is still useful to wait for the deployment's core
    # assets before interacting with the CanvasKit surface.
    await page.goto(url, wait_until="networkidle", timeout=60_000)
    await page.wait_for_timeout(4_000)


async def screenshot_bytes(page, path: str) -> bytes:
    return await page.screenshot(path=path, full_page=False)


async def tap_until_changed(
    page, before: bytes, x: float, y_positions: tuple[float, ...]
) -> bytes:
    """Tap likely interior points and stop when the real UI visibly changes."""
    after = before
    for y in y_positions:
        await page.mouse.click(x, y)
        await page.wait_for_timeout(500)
        after = await page.screenshot()
        if after != before:
            return after
    return after


async def run(url: str) -> int:
    failures: list[str] = []
    results: list[dict[str, object]] = []

    async with async_playwright() as playwright:
        browser = await playwright.chromium.launch()
        for width, height in VIEWPORTS:
            console_errors: list[str] = []
            page_errors: list[str] = []
            failed_requests: list[str] = []
            http_failures: list[str] = []
            context = await browser.new_context(
                viewport={"width": width, "height": height},
                device_scale_factor=1,
            )
            page = await context.new_page()
            page.on(
                "console",
                lambda message: console_errors.append(
                    f"{message.type}: {message.text}"
                )
                if message.type == "error"
                else None,
            )
            page.on("pageerror", lambda error: page_errors.append(str(error)))
            page.on("requestfailed", lambda request: failed_requests.append(request.url))
            page.on(
                "response",
                lambda response: http_failures.append(
                    f"{response.status} {response.url}"
                )
                if response.status >= 400
                else None,
            )

            try:
                await load_app(page, url)
            except PlaywrightTimeoutError as error:
                failures.append(f"{width}px deployment did not finish loading: {error}")
                await context.close()
                continue

            overflow = await page.evaluate(
                """() => ({
                  document: document.documentElement.scrollWidth > window.innerWidth + 1,
                  body: document.body.scrollWidth > window.innerWidth + 1,
                })"""
            )
            if overflow["document"] or overflow["body"]:
                failures.append(f"{width}px viewport has horizontal overflow: {overflow}")

            await screenshot_bytes(page, f"/tmp/zarbulmasal-mobile-{width}.png")
            action_result: dict[str, object] = {}

            if width in (320, 390):
                artifact_suffix = "" if width == 390 else f"-{width}"
                # Dismiss the first-launch tour, then open the real proverb
                # search form from the bottom navigation at both supported
                # portrait phone sizes.
                await page.mouse.click(80, height - 140)
                await page.wait_for_timeout(400)
                await page.mouse.click(width * 0.31, height - 30)
                await page.wait_for_timeout(800)
                before_search = await screenshot_bytes(
                    page,
                    f"/tmp/zarbulmasal-proverbs-before-search{artifact_suffix}.png",
                )
                await page.mouse.click(width * 0.41, 190)
                await page.keyboard.type("модар")
                await page.wait_for_timeout(700)
                after_search = await screenshot_bytes(
                    page, f"/tmp/zarbulmasal-proverbs-search{artifact_suffix}.png"
                )
                if before_search == after_search:
                    failures.append(f"{width}px proverb search produced no visible change")

                # Deep-link to the quiz screen after the navigation check and
                # exercise answer feedback with a real pointer action. Using
                # the hash route avoids making the test depend on scroll
                # position after the search field has had focus.
                await load_app(page, f"{url.rstrip('/')}/#/quiz")
                if width == 320:
                    # The compact viewport needs a short scroll to expose the
                    # first answer card before a user can tap it.
                    await page.mouse.wheel(0, 280)
                    await page.wait_for_timeout(500)
                before_answer = await screenshot_bytes(
                    page,
                    f"/tmp/zarbulmasal-quiz-before-answer{artifact_suffix}.png",
                )
                # Question wrapping changes the first card's vertical position
                # by a few dozen pixels. Try two interior points, never the
                # border/gap, and keep the first pointer action that changes
                # the real feedback state.
                after_answer = await tap_until_changed(
                    page,
                    before_answer,
                    width / 2,
                    (420, 480) if width == 390 else (390, 430, 470),
                )
                await page.screenshot(
                    path=f"/tmp/zarbulmasal-quiz-answer-feedback{artifact_suffix}.png"
                )
                if before_answer == after_answer:
                    failures.append(f"{width}px quiz answer produced no visible feedback")

                # Deep-link to flashcards and reveal the first card. This is
                # still a real pointer interaction on the deployed surface.
                await load_app(page, f"{url.rstrip('/')}/#/flashcards")
                before_reveal = await screenshot_bytes(
                    page, f"/tmp/zarbulmasal-flashcard-front{artifact_suffix}.png"
                )
                await page.mouse.click(width / 2, height * 0.53)
                await page.wait_for_timeout(500)
                after_reveal = await screenshot_bytes(
                    page, f"/tmp/zarbulmasal-flashcard-reveal{artifact_suffix}.png"
                )
                if before_reveal == after_reveal:
                    failures.append(f"{width}px flashcard reveal produced no visible change")

                action_result = {
                    "search_changed": before_search != after_search,
                    "quiz_feedback_changed": before_answer != after_answer,
                    "flashcard_reveal_changed": before_reveal != after_reveal,
                }

            results.append(
                {
                    "viewport": f"{width}x{height}",
                    "horizontal_overflow": overflow,
                    "actions": action_result,
                    "console_errors": console_errors,
                    "page_errors": page_errors,
                    "failed_requests": failed_requests,
                    "http_failures": http_failures,
                }
            )
            if console_errors or page_errors or failed_requests or http_failures:
                failures.append(
                    f"{width}px browser errors: "
                    f"console={console_errors}, page={page_errors}, "
                    f"requests={failed_requests}, http={http_failures}"
                )
            await context.close()
        await browser.close()

    print(
        json.dumps(
            {"url": url, "results": results, "failures": failures},
            ensure_ascii=False,
            indent=2,
        )
    )
    return 1 if failures else 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        raise SystemExit("usage: python3 tool/mobile_qa.py <url>")
    raise SystemExit(asyncio.run(run(sys.argv[1])))
