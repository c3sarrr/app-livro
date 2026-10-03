// G01.2 — renderiza cada prancha ISOLADA (bundle aninhado extraído, rede bloqueada) @2x e grava:
//   tools/medicao/tmp/render/<slug>_<hinting>@2x.png  +  tools/medicao/tmp/render/render.json
// (frame encontrado, retângulo, erros de JS, URLs bloqueadas, fontes carregadas/pendentes).
// Uso: NODE_PATH=$(npm root -g) node tools/medicao/conferir_render.js [todas|19,20…] [padrao|nenhum]
const fs = require('fs');
const path = require('path');
const { CFG, pranchas, lancar, abrir, saidaDir } = require('./comum');

(async () => {
  const sel = pranchas(process.argv[2]);
  const hinting = process.argv[3] || 'nenhum';
  const dsf = +(process.argv[4] || 2);
  const out = saidaDir('tools', 'medicao', 'tmp', 'render');
  const browser = await lancar({ hinting });
  const rel = {};
  for (const p of sel) {
    const { page, bloqueadas, erros } = await abrir(browser, p, { zoom: 1, dsf, viewportH: p.canvas[1] });
    const info = await page.evaluate((sel) => {
      const f = document.querySelector(sel);
      const r = f.getBoundingClientRect();
      const fontes = [...document.fonts].map(x => ({ family: x.family.replace(/"/g, ''), weight: x.weight, style: x.style, status: x.status, range: x.unicodeRange }));
      return { rect: [r.x, r.y, r.width, r.height], tpls: document.querySelectorAll('[data-dc-tpl]').length,
               carregadas: [...new Set(fontes.filter(x => x.status === 'loaded').map(x => `${x.family} ${x.weight} ${x.style}`))].sort(),
               naoCarregadas: fontes.filter(x => x.status !== 'loaded').length };
    }, CFG.frame);
    const png = path.join(out, `${p.slug}_${hinting}@${dsf}x.png`);
    await page.screenshot({ path: png, clip: { x: 0, y: 0, width: p.canvas[0], height: p.canvas[1] } });
    rel[p.slug] = { ...info, erros, bloqueadas: [...new Set(bloqueadas.map(u => new URL(u).host))].sort() };
    const ok = info.rect.join() === [0, 0, ...p.canvas].join() && !erros.length;
    console.log(`${ok ? 'OK ' : 'ERR'} ${p.slug.padEnd(24)} frame=${info.rect.join('×')} tpls=${info.tpls} erros=${erros.length} fontes=${info.carregadas.length}`);
    await page.close();
  }
  await browser.close();
  fs.writeFileSync(path.join(out, `render_${hinting}.json`), JSON.stringify(rel, null, 1) + '\n');
})();
