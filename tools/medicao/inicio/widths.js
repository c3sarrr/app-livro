const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const idmap = JSON.parse(fs.readFileSync('idmap.json'));
  const browser = await chromium.launch({args:['--font-render-hinting=none']});
  for (const W of [360, 430]) {
    // geometry at zoom 100
    let page = await browser.newPage({ viewport: { width: W*100, height: 1000 }, deviceScaleFactor: 1 });
    await page.goto('file://' + process.cwd() + '/original.html');
    await page.waitForTimeout(3500);
    const geo = await page.evaluate(async ({W, idmap}) => {
      await document.fonts.ready; const Z = 100;
      const f = document.querySelector('main').parentElement; f.style.width = W + 'px';
      document.body.style.zoom = Z; document.body.style.display='block'; document.body.style.margin='0';
      await new Promise(r => setTimeout(r, 400));
      const fr = f.getBoundingClientRect();
      const all = [f, ...f.querySelectorAll('*')]; const saved = all.map(e => e.style.transform); all.forEach(e => { if (e.style.transform) e.style.transform = 'none'; });
      const out = {}; for (const e of all) { const id = idmap[e.getAttribute('data-dc-tpl')]; if (!id) continue; const r = e.getBoundingClientRect(); out[id] = [+((r.x-fr.x)/Z).toFixed(2), +((r.y-fr.y)/Z).toFixed(2), +(r.width/Z).toFixed(2), +(r.height/Z).toFixed(2)]; }
      all.forEach((e,i) => { if (saved[i]) e.style.transform = saved[i]; });
      return out;
    }, {W, idmap});
    fs.writeFileSync(`layout_w${W}_cru.json`, JSON.stringify(geo));
    await page.close();
    // picture at zoom 10 tiles -> 2x
    page = await browser.newPage({ viewport: { width: W*10, height: 2000 }, deviceScaleFactor: 1 });
    await page.goto('file://' + process.cwd() + '/original.html');
    await page.waitForTimeout(3500);
    await page.evaluate(async (W) => { await document.fonts.ready; const f = document.querySelector('main').parentElement; f.style.width = W + 'px'; document.body.style.zoom = 10; document.body.style.display='block'; document.body.style.margin='0'; }, W);
    await page.waitForTimeout(600);
    fs.mkdirSync(`wtiles${W}`, {recursive: true});
    for (let y = 0, i = 0; y < 23900; y += 2000, i++) await page.screenshot({ path: `wtiles${W}/t${String(i).padStart(2,'0')}.png`, clip: { x: 0, y, width: W*10, height: Math.min(2000, 23900-y) }, fullPage: true });
    await page.close();
    console.log('done', W);
  }
  await browser.close();
})();
