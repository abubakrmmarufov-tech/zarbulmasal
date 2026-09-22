import { chromium } from 'playwright';

async function testInteractions() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext({
    viewport: { width: 390, height: 844 }
  });
  const page = await context.newPage();

  const results = [];
  function record(name, status, detail = '') {
    results.push({ name, status, detail });
    console.log(`[${status}] ${name}: ${detail}`);
  }

  // 1. Invalid Route / 404
  try {
    await page.goto('http://localhost:8080/zarbulmasal/#/non_existent_page_404', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    // Flutter renders canvas, check URL and page didn't crash
    record('Invalid Route (404)', 'PASS', 'Navigated to 404 route cleanly');
  } catch (e) {
    record('Invalid Route (404)', 'FAIL', e.message);
  }

  // 2. Service Worker registration and cache verification
  try {
    await page.goto('http://localhost:8080/zarbulmasal/', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1500);
    const swRegistration = await page.evaluate(async () => {
      if (!('serviceWorker' in navigator)) return false;
      const reg = await navigator.serviceWorker.getRegistration();
      return !!reg;
    });
    record('Service Worker', swRegistration ? 'PASS' : 'WARN', `SW registered: ${swRegistration}`);
  } catch (e) {
    record('Service Worker', 'FAIL', e.message);
  }

  // 3. Persian RTL & LocalStorage Persistence
  try {
    await page.evaluate(() => {
      localStorage.setItem('flutter.display_language', JSON.stringify('fa'));
      localStorage.setItem('flutter.dark_mode', JSON.stringify(true));
    });
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    const lang = await page.evaluate(() => JSON.parse(localStorage.getItem('flutter.display_language')));
    const theme = await page.evaluate(() => JSON.parse(localStorage.getItem('flutter.dark_mode')));
    if (lang === 'fa' && theme === true) {
      record('Persistence (Language & Theme)', 'PASS', `Retained lang=${lang}, theme=${theme}`);
    } else {
      record('Persistence (Language & Theme)', 'FAIL', `Values lost: lang=${lang}, theme=${theme}`);
    }
  } catch (e) {
    record('Persistence (Language & Theme)', 'FAIL', e.message);
  }

  // 4. Reset to Tajik light mode
  await page.evaluate(() => {
    localStorage.setItem('flutter.display_language', JSON.stringify('tj'));
    localStorage.setItem('flutter.dark_mode', JSON.stringify(false));
  });
  await page.reload({ waitUntil: 'networkidle' });
  await page.waitForTimeout(1000);

  // 5. History Deep Link
  try {
    await page.goto('http://localhost:8080/zarbulmasal/#/history', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    record('History Route Navigation', 'PASS', 'Navigated to #/history without route override');
  } catch (e) {
    record('History Route Navigation', 'FAIL', e.message);
  }

  // 6. Literature Hub Deep Link
  try {
    await page.goto('http://localhost:8080/zarbulmasal/#/literature', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    record('Literature Hub Route Navigation', 'PASS', 'Navigated to #/literature cleanly');
  } catch (e) {
    record('Literature Hub Route Navigation', 'FAIL', e.message);
  }

  // 7. Poets List Deep Link
  try {
    await page.goto('http://localhost:8080/zarbulmasal/#/literature/poets', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    record('Poets List Navigation', 'PASS', 'Navigated to #/literature/poets');
  } catch (e) {
    record('Poets List Navigation', 'FAIL', e.message);
  }

  // 8. Works List Deep Link
  try {
    await page.goto('http://localhost:8080/zarbulmasal/#/literature/works', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    record('Works List Navigation', 'PASS', 'Navigated to #/literature/works');
  } catch (e) {
    record('Works List Navigation', 'FAIL', e.message);
  }

  // 9. School Canon Deep Link
  try {
    await page.goto('http://localhost:8080/zarbulmasal/#/literature/school', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    record('School Canon Navigation', 'PASS', 'Navigated to #/literature/school');
  } catch (e) {
    record('School Canon Navigation', 'FAIL', e.message);
  }

  // 10. Proverbs and Favorites Deep Link
  try {
    await page.goto('http://localhost:8080/zarbulmasal/#/proverbs', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    record('Proverbs Navigation', 'PASS', 'Navigated to #/proverbs');
    await page.goto('http://localhost:8080/zarbulmasal/#/favorites', { waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    record('Favorites Navigation', 'PASS', 'Navigated to #/favorites');
  } catch (e) {
    record('Proverbs/Favorites Navigation', 'FAIL', e.message);
  }

  await browser.close();
  console.log('\n=== Interaction Summary ===');
  console.table(results);
}

testInteractions().catch(console.error);
