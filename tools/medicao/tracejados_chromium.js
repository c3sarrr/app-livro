// T13.11 (D-285, D-286) — a referência do Chromium para os traços tracejados do registro do app (`svgDashes`): cada
// SVG de assets/ com stroke-dasharray, só com o elemento tracejado (sem preenchimento, com os atributos herdados da
// raiz — a ponta redonda da mira), desenhado como <svg> em linha no tamanho do arquivo, fundo transparente, a 3× (o
// aparelho) e a 8× (a prova). O teste `t13_tracejados_test.dart` pinta o traço que a AppSvg monta e compara com estes
// PNGs. Uso (no WSL): NODE_PATH=$(npm root -g) node tools/medicao/tracejados_chromium.js
const fs = require('fs');
const path = require('path');

const { RAIZ, lancar } = require('./comum');

const SAIDA = path.join(RAIZ, 'docs', 'design', 'medicao', 'projeto', 'png', 'tracejados');
const ESCALAS = [3, 8];

function svgsTracejados(dir) {
  const out = [];
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const f = path.join(dir, e.name);
    if (e.isDirectory()) out.push(...svgsTracejados(f));
    else if (e.name.endsWith('.svg') && fs.readFileSync(f, 'utf8').includes('stroke-dasharray')) out.push(f);
  }
  return out.sort();
}

(async () => {
  const arquivos = svgsTracejados(path.join(RAIZ, 'assets'));
  fs.mkdirSync(SAIDA, { recursive: true });
  const browser = await lancar();
  for (const f of arquivos) {
    const texto = fs.readFileSync(f, 'utf8');
    const [, w, h] = texto.match(/<svg[^>]* width="([0-9.]+)" height="([0-9.]+)"/);
    for (const k of ESCALAS) {
      const page = await browser.newPage({ deviceScaleFactor: k, viewport: { width: Math.ceil(+w), height: Math.ceil(+h) } });
      await page.setContent('<html><body style="margin:0;background:transparent"></body></html>');
      const n = await page.evaluate((texto) => {
        const doc = new DOMParser().parseFromString(texto, 'image/svg+xml');
        const alvos = [...doc.querySelectorAll('[stroke-dasharray]')];
        if (alvos.length !== 1) return alvos.length;
        // o elemento com os ancestrais (sem os irmãos): a raiz e os <g> guardam os atributos e transformações herdados
        let copia = alvos[0].cloneNode(false);
        copia.setAttribute('fill', 'none');
        for (let p = alvos[0].parentNode; p && p.nodeType === 1; p = p.parentNode) {
          const casca = p.cloneNode(false);
          casca.appendChild(copia);
          copia = casca;
        }
        copia.style.display = 'block';
        document.body.appendChild(document.importNode(copia, true));
        return 1;
      }, texto);
      if (n !== 1) throw new Error(`${f}: ${n} elementos tracejados (o registro quer um)`);
      const nome = `${path.basename(f, '.svg')}_x${k}.png`;
      await page.screenshot({ path: path.join(SAIDA, nome), omitBackground: true, clip: { x: 0, y: 0, width: +w, height: +h } });
      await page.close();
      console.log(path.relative(RAIZ, path.join(SAIDA, nome)));
    }
  }
  await browser.close();
})();
