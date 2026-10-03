// G01.5 — fotografa cada prancha isolada com zoom 10 (supersample 10×, como a v1) em faixas de 2000 px.
// Saída: tools/medicao/tmp/supershot/<slug>/t00.png… (largura 3900; altura total = canvas × 10)
// Uso: NODE_PATH=$(npm root -g) node tools/medicao/supershot.js [todas|19,20…] [zoom=10]
//      (zoom 20 só para a conferência de convergência: saída em tmp/supershot_z20/)
//      CSS_EXTRA='<css>' SUFIXO=corrigida → aplica CSS antes de fotografar e grava em tmp/supershot/<slug>_<sufixo>/
//      (usado só para a variante corrigida da 21: texto que vaza da página escondido — ver relatório G01)
const fs = require('fs');
const path = require('path');
const { pranchas, lancar, abrir, saidaDir } = require('./comum');

(async () => {
  const Z = +(process.argv[3] || 10), TILE = 2000;
  const browser = await lancar();
  for (const p of pranchas(process.argv[2])) {
    const [w, h] = p.canvas;
    const { page, erros } = await abrir(browser, p, { zoom: Z, viewportH: TILE });
    if (process.env.CSS_EXTRA) { await page.addStyleTag({ content: process.env.CSS_EXTRA }); await page.waitForTimeout(300); }
    const nome = process.env.SUFIXO ? `${p.slug}_${process.env.SUFIXO}` : p.slug;
    const dir = saidaDir('tools', 'medicao', 'tmp', Z === 10 ? 'supershot' : `supershot_z${Z}`, nome);
    for (const f of fs.readdirSync(dir)) fs.unlinkSync(path.join(dir, f));
    const H = h * Z;
    let n = 0;
    for (let y = 0; y < H; y += TILE, n++) {
      await page.screenshot({ path: path.join(dir, `t${String(n).padStart(2, '0')}.png`),
        clip: { x: 0, y, width: w * Z, height: Math.min(TILE, H - y) }, fullPage: true });
    }
    console.log(`${nome.padEnd(24)} ${n} faixas ${w * Z}×${H}${erros.length ? ' ERROS ' + erros : ''}`);
    await page.close();
  }
  await browser.close();
})();
