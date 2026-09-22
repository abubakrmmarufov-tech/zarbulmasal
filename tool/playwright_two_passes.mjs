import { chromium } from 'playwright';

async function runTwoPasses() {
  const browser = await chromium.launch({ headless: true });

  // Pass 1: Forward user journey
  console.log('=== Starting Regression Pass 1: Forward User Journey ===');
  {
    const context = await browser.newContext({ viewport: { width: 390, height: 844 } });
    const page = await context.newPage();
    const pass1Errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') pass1Errors.push(msg.text());
    });
    page.on('pageerror', err => pass1Errors.push(err.message));

    const seq1 = [
      '',
      '#/quiz',
      '#/flashcards',
      '#/proverbs',
      '#/proverb/1',
      '#/literature',
      '#/literature/poets',
      '#/literature/poet/rudaki',
      '#/literature/search',
      '#/history'
    ];

    for (const step of seq1) {
      await page.goto(`http://localhost:8080/zarbulmasal/${step}`, { waitUntil: 'networkidle' });
      await page.waitForTimeout(600);
      console.log(`  [Pass 1] Checked: /${step}`);
    }
    await context.close();
    console.log(`Pass 1 completed. Errors: ${pass1Errors.length}`);
    if (pass1Errors.length > 0) throw new Error('Pass 1 failed: ' + JSON.stringify(pass1Errors));
  }

  // Pass 2: Alternate Persian & Cross-Feature Journey
  console.log('\n=== Starting Regression Pass 2: Alternate Persian & Cross-Feature Journey ===');
  {
    const context = await browser.newContext({ viewport: { width: 390, height: 844 } });
    const page = await context.newPage();
    const pass2Errors = [];
    page.on('console', msg => {
      if (msg.type() === 'error') pass2Errors.push(msg.text());
    });
    page.on('pageerror', err => pass2Errors.push(err.message));

    // Enable Persian & dark theme
    await page.goto('http://localhost:8080/zarbulmasal/');
    await page.evaluate(() => {
      localStorage.setItem('flutter.display_language', JSON.stringify('fa'));
      localStorage.setItem('flutter.dark_mode', JSON.stringify(true));
    });
    await page.reload({ waitUntil: 'networkidle' });

    const seq2 = [
      '#/settings',
      '#/history',
      '#/literature/works',
      '#/literature/school',
      '#/literature/oral',
      '#/categories',
      '#/levels',
      '#/daily',
      '#/favorites',
      ''
    ];

    for (const step of seq2) {
      await page.goto(`http://localhost:8080/zarbulmasal/${step}`, { waitUntil: 'networkidle' });
      await page.waitForTimeout(600);
      console.log(`  [Pass 2] Checked: /${step}`);
    }
    await context.close();
    console.log(`Pass 2 completed. Errors: ${pass2Errors.length}`);
    if (pass2Errors.length > 0) throw new Error('Pass 2 failed: ' + JSON.stringify(pass2Errors));
  }

  await browser.close();
  console.log('\n>>> Both final regression passes completed with 0 errors! <<<');
}

runTwoPasses().catch(err => {
  console.error(err);
  process.exit(1);
});
