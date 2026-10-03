// G01.2 — renderiza o bundle RAIZ (todas as pranchas em iframes, como o Claude Design mostra) e
// fotografa cada iframe @2x. Força posições inteiras (h2 com altura inteira) para o recorte não pegar
// meio pixel. Saída: tools/medicao/tmp/render/<slug>_raiz_<hinting>@2x.png
// Uso: NODE_PATH=$(npm root -g) node tools/medicao/render_raiz.js [padrao|nenhum]
const path = require('path');
const { CFG, RAIZ, lancar, saidaDir } = require('./comum');

(async () => {
  const hinting = process.argv[2] || 'nenhum';
  const dsf = +(process.argv[3] || 2);
  const out = saidaDir('tools', 'medicao', 'tmp', 'render');
  const browser = await lancar({ hinting });
  const page = await browser.newPage({ viewport: { width: 600, height: 2400 }, deviceScaleFactor: dsf });
  await page.route('**/*', r => r.request().url().startsWith('http') ? r.abort() : r.continue());
  await page.goto('file://' + path.join(RAIZ, CFG.fonte));
  await page.waitForFunction(n => document.querySelectorAll('iframe').length === n, CFG.pranchas.length, { timeout: 30000 });
  await page.addStyleTag({ content: '.board h2{line-height:20px !important;height:20px}' });
  await page.waitForTimeout(6000);
  const frames = await page.$$('iframe');
  // depois de carregar, o src vira blob: — a ordem dos iframes é a de page_order (= pranchas.json)
  for (const [i, p] of CFG.pranchas.entries()) {
    const el = frames[i];
    const titulo = await el.getAttribute('title');
    if (titulo !== p.titulo) throw new Error(`iframe ${i}: título "${titulo}" ≠ "${p.titulo}"`);
    await el.scrollIntoViewIfNeeded();
    const fr = await el.contentFrame();
    await fr.waitForFunction(sel => !!document.querySelector(sel), CFG.frame, { timeout: 20000 });
    await fr.evaluate(() => document.fonts.ready);
    await page.waitForTimeout(500);
    const box = await el.boundingBox();
    if (![box.x, box.y].every(Number.isInteger)) throw new Error(`${p.slug}: iframe em posição fracionária ${JSON.stringify(box)}`);
    await el.screenshot({ path: path.join(out, `${p.slug}_raiz_${hinting}@${dsf}x.png`) });
    console.log(p.slug, JSON.stringify(box));
  }
  await browser.close();
})();
