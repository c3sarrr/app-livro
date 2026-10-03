const { chromium } = require('playwright');
(async () => {
  const Z = 10, TILE = 2000;
  const browser = await chromium.launch({args:['--font-render-hinting=none']});
  const page = await browser.newPage({ viewport: { width: 390*Z, height: TILE }, deviceScaleFactor: 1 });
  await page.goto('file://' + process.cwd() + '/original.html');
  await page.waitForTimeout(3500);
  await page.evaluate(async (Z) => { await document.fonts.ready; document.body.style.zoom = Z; document.body.style.display='block'; document.body.style.margin='0'; }, Z);
  await page.waitForTimeout(800);
  const H = 2390*Z;
  for (let y = 0, i = 0; y < H; y += TILE, i++) {
    const h = Math.min(TILE, H - y);
    await page.screenshot({ path: `tiles/t${String(i).padStart(2,'0')}.png`, clip: { x: 0, y, width: 390*Z, height: h }, fullPage: true });
  }
  await browser.close();
  console.log('done');
})();
