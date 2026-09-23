const { chromium } = require('playwright');
const fs = require('fs');
(async () => {
  const idmap = JSON.parse(fs.readFileSync('idmap.json'));
  const browser = await chromium.launch({args:['--font-render-hinting=none']});
  const page = await browser.newPage({ viewport: { width: 39000, height: 1000 }, deviceScaleFactor: 1 });
  await page.goto('file://' + process.cwd() + '/original.html');
  await page.waitForTimeout(3500);
  const res = await page.evaluate(async (idmap) => {
    await document.fonts.ready; const Z = 100; document.body.style.zoom = Z; document.body.style.display='block'; document.body.style.margin='0';
    await new Promise(r => setTimeout(r, 300));
    const f = document.querySelector('main').parentElement;
    const all = [f, ...f.querySelectorAll('*')]; all.forEach(e => { if (e.style.transform) e.style.transform = 'none'; });
    const snap = () => { const fr = f.getBoundingClientRect(); const o = {}; for (const e of all) { const id = idmap[e.getAttribute('data-dc-tpl')]; if (!id) continue; const r = e.getBoundingClientRect(); o[id] = [(r.x-fr.x)/Z, (r.y-fr.y)/Z, r.width/Z, r.height/Z]; } return o; };
    const a = snap();
    // perturb text widths only (word-spacing + letter-spacing add), keep line heights
    const st = document.createElement('style'); st.textContent = '* { word-spacing: 0.4px !important; }'; document.head.appendChild(st);
    await new Promise(r => setTimeout(r, 200));
    // also add tiny letter spacing to every element on top of its own
    for (const e of all) { const cs = getComputedStyle(e); const ls = cs.letterSpacing === 'normal' ? 0 : parseFloat(cs.letterSpacing); e.style.letterSpacing = (ls + 0.05) + 'px'; }
    await new Promise(r => setTimeout(r, 200));
    const b = snap();
    const flags = {};
    for (const k of Object.keys(a)) { const dx = Math.abs(a[k][0]-b[k][0]) > 0.01, dw = Math.abs(a[k][2]-b[k][2]) > 0.01, dy = Math.abs(a[k][1]-b[k][1]) > 0.01, dh = Math.abs(a[k][3]-b[k][3]) > 0.01; flags[k] = { x: dx, w: dw, y: dy, h: dh }; }
    return flags;
  }, idmap);
  fs.writeFileSync('text_dependency.json', JSON.stringify(res));
  const hx = Object.entries(res).filter(([k,v]) => v.x || v.w).map(([k]) => k);
  const vy = Object.entries(res).filter(([k,v]) => v.y || v.h).map(([k]) => k);
  console.log('horizontal text-dependent:', hx.length, '\nvertical changed (should be few, due to wrapping):', vy.join(', '));
  await browser.close();
})();
