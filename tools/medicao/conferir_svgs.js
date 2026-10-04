// G01.8 — prova de que os SVGs exportados reproduzem o arquivo: em cada prancha, troca cada <svg> com id
// pelo arquivo exportado (<img src="data:…"> com o mesmo estilo e o tamanho medido) e compara a foto
// com a original (zoom 4). Diferença esperada só no ic_underline (o "a" em <text> perde a Literata
// quando o SVG vira imagem isolada — armadilha registrada no catálogo).
// Uso: [CATS=ic,il] NODE_PATH=$(npm root -g) node tools/medicao/conferir_svgs.js && python3 tools/medicao/conferir_svgs.py
const fs = require('fs');
const path = require('path');

const { CFG, RAIZ, pranchas, lancar, abrir, idmap } = require('./comum');

(async () => {
  const cat = JSON.parse(fs.readFileSync(path.join(RAIZ, 'handoff_v2', 'referencia', 'svg_catalogo.json')));
  const browser = await lancar();
  const Z = 4, res = {};
  for (const p of pranchas('todas')) {
    const ids = idmap(p).ids;
    const cats = (process.env.CATS || 'ic,il,tinta,graf').split(',');
    const trocas = Object.entries(cat.usos).filter(([, u]) => u[p.slug] && cats.includes(cat.arquivos[u[p.slug].arquivo].categoria)).map(([id, u]) => ({ id, arq: u[p.slug].arquivo,
      data: 'data:image/svg+xml;base64,' + fs.readFileSync(path.join(RAIZ, u[p.slug].arquivo)).toString('base64') }));
    if (!trocas.length) continue;
    const { page } = await abrir(browser, p, { zoom: Z, viewportH: Math.min(p.canvas[1] * Z, 4000) });
    const shot = async (n) => { const f = `/tmp/claude-0/svgcmp_${p.slug}_${n}.png`; await page.screenshot({ path: f, clip: { x: 0, y: 0, width: p.canvas[0] * Z, height: p.canvas[1] * Z }, fullPage: true }); return f; };
    const a = await shot('a');
    await page.evaluate(({ trocas, ids }) => {
      const inv = Object.fromEntries(Object.entries(ids).map(([t, id]) => [id, t]));
      for (const t of trocas) {
        const el = document.querySelector(`[data-dc-tpl="${inv[t.id]}"]`);
        const r = el.getBoundingClientRect(); const z = parseFloat(document.body.style.zoom) || 1;
        const img = document.createElement('img');
        img.setAttribute('style', el.getAttribute('style') || '');
        img.style.width = (r.width / z) + 'px'; img.style.height = (r.height / z) + 'px';
        img.style.display = getComputedStyle(el).display === 'block' ? 'block' : 'inline-block';
        img.style.verticalAlign = getComputedStyle(el).verticalAlign;
        img.src = t.data; el.replaceWith(img);
      }
    }, { trocas, ids });
    await page.waitForTimeout(600);
    const b = await shot('b');
    res[p.slug] = { a, b, trocas: trocas.length };
    await page.close();
  }
  await browser.close();
  fs.writeFileSync('/tmp/claude-0/svgcmp.json', JSON.stringify(res));
})();
