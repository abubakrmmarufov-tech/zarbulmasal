import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';

const outDir = 'output/playwright';
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

async function runAudit() {
  const browser = await chromium.launch({ headless: true });
  const errors = [];

  const viewports = [
    { name: 'phone_320', width: 320, height: 568 },
    { name: 'phone_390', width: 390, height: 844 },
    { name: 'desktop', width: 1280, height: 800 }
  ];

  const routes = [
    { path: '', name: 'home' },
    { path: '#/history', name: 'history' },
    { path: '#/literature', name: 'literature_hub' },
    { path: '#/literature/poets', name: 'poets_list' },
    { path: '#/literature/works', name: 'works_list' },
    { path: '#/literature/school', name: 'school_canon' },
    { path: '#/literature/oral', name: 'oral_heritage' },
    { path: '#/literature/search', name: 'literature_search' },
    { path: '#/proverbs', name: 'proverbs' },
    { path: '#/categories', name: 'categories' },
    { path: '#/favorites', name: 'favorites' },
    { path: '#/quiz', name: 'quiz' },
    { path: '#/flashcards', name: 'flashcards' },
    { path: '#/daily', name: 'daily' },
    { path: '#/levels', name: 'levels' },
    { path: '#/settings', name: 'settings' }
  ];

  console.log('=== Starting Playwright Browser Audit ===');

  for (const vp of viewports) {
    console.log(`\nTesting viewport: ${vp.name} (${vp.width}x${vp.height})`);
    const context = await browser.newContext({
      viewport: { width: vp.width, height: vp.height }
    });
    const page = await context.newPage();

    page.on('console', msg => {
      if (msg.type() === 'error') {
        const text = msg.text();
        // Ignore expected network or analytics if any
        console.error(`[Console Error][${vp.name}]: ${text}`);
        errors.push({ vp: vp.name, error: text });
      }
    });

    page.on('pageerror', err => {
      console.error(`[Page Error][${vp.name}]: ${err.message}`);
      errors.push({ vp: vp.name, error: err.message });
    });

    for (const r of routes) {
      const url = `http://localhost:8080/zarbulmasal/${r.path}`;
      try {
        await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
        // Wait for flutter canvas / engine
        await page.waitForTimeout(1000);

        const screenshotPath = path.join(outDir, `${vp.name}_${r.name}.png`);
        await page.screenshot({ path: screenshotPath });
        console.log(`  ✓ ${r.name} -> ${screenshotPath}`);
      } catch (e) {
        console.error(`  ✗ ${r.name} failed: ${e.message}`);
        errors.push({ vp: vp.name, route: r.name, error: e.message });
      }
    }
    await context.close();
  }

  // Persian Mode Test on 390 viewport
  console.log('\nTesting Persian RTL Mode (390x844)...');
  {
    const context = await browser.newContext({
      viewport: { width: 390, height: 844 }
    });
    const page = await context.newPage();
    
    // Set localStorage language to 'fa' (Persian)
    await page.goto('http://localhost:8080/zarbulmasal/');
    await page.evaluate(() => {
      localStorage.setItem('flutter.zarbulmasal_lang', 'fa');
    });
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);

    const faRoutes = [
      { path: '', name: 'home_fa' },
      { path: '#/history', name: 'history_fa' },
      { path: '#/literature', name: 'literature_hub_fa' },
      { path: '#/literature/poets', name: 'poets_list_fa' },
      { path: '#/literature/works', name: 'works_list_fa' },
      { path: '#/flashcards', name: 'flashcards_fa' },
      { path: '#/settings', name: 'settings_fa' }
    ];

    for (const r of faRoutes) {
      const url = `http://localhost:8080/zarbulmasal/${r.path}`;
      await page.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
      await page.waitForTimeout(1000);
      const screenshotPath = path.join(outDir, `fa_${r.name}.png`);
      await page.screenshot({ path: screenshotPath });
      console.log(`  ✓ ${r.name} (RTL) -> ${screenshotPath}`);
    }
    await context.close();
  }

  // Dark Mode Test
  console.log('\nTesting Dark Mode Theme...');
  {
    const context = await browser.newContext({
      viewport: { width: 390, height: 844 },
      colorScheme: 'dark'
    });
    const page = await context.newPage();
    await page.goto('http://localhost:8080/zarbulmasal/');
    await page.evaluate(() => {
      localStorage.setItem('flutter.zarbulmasal_theme', 'dark');
    });
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForTimeout(1000);
    const screenshotPath = path.join(outDir, 'dark_home.png');
    await page.screenshot({ path: screenshotPath });
    console.log(`  ✓ dark_home -> ${screenshotPath}`);
    await context.close();
  }

  await browser.close();

  console.log('\n=== Playwright Audit Completed ===');
  console.log(`Total errors captured: ${errors.length}`);
  if (errors.length > 0) {
    console.log('Errors:', JSON.stringify(errors, null, 2));
  }
}

runAudit().catch(err => {
  console.error('Audit fatal failure:', err);
  process.exit(1);
});
