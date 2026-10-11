// G01.8 — extrai cada <svg> com id das 13 pranchas (DOM renderizado: viewBox real, props resolvidas),
// com a cor herdada (currentColor) e o tamanho medido. Saída: tools/medicao/tmp/svgs.json
// Uso: NODE_PATH=$(npm root -g) node tools/medicao/svgs.js
const fs = require('fs');
const path = require('path');
const { CFG, pranchas, lancar, abrir, idmap, tmpDir } = require('./comum');

(async () => {
  const browser = await lancar();
  const out = {};
  for (const p of pranchas('todas')) {
    const ids = idmap(p).ids;
    const { page } = await abrir(browser, p, { zoom: 1, viewportH: p.canvas[1] });
    out[p.slug] = await page.evaluate(({ ids, frameSel }) => {
      const res = {};
      for (const el of document.querySelectorAll(frameSel + ' svg[data-dc-tpl], ' + frameSel + '[data-dc-tpl] svg')) {
        const id = ids[el.getAttribute('data-dc-tpl')]; if (!id) continue;
        const c = el.cloneNode(true);
        c.removeAttribute('data-dc-tpl'); c.querySelectorAll('[data-dc-tpl]').forEach(n => n.removeAttribute('data-dc-tpl'));
        c.removeAttribute('style'); c.removeAttribute('class'); c.removeAttribute('aria-hidden');
        const r = el.getBoundingClientRect(); const cs = getComputedStyle(el);
        res[id] = { svg: c.outerHTML, w: r.width, h: r.height, color: cs.color, style: el.getAttribute('style') || '',
          aria: el.getAttribute('aria-label') || null, role: el.getAttribute('role') || null };
      }
      return res;
    }, { ids, frameSel: CFG.frame });
    await page.close();
  }
  await browser.close();
  fs.writeFileSync(path.join(tmpDir(), 'svgs.json'), JSON.stringify(out, null, 1));
  console.log(Object.entries(out).map(([k, v]) => `${k}: ${Object.keys(v).length}`).join('\n'));
})();
