// G01.8 — prova de que os SVGs exportados reproduzem o arquivo: em cada prancha, troca cada <svg> com id
// pelo arquivo exportado (<img src="data:…"> com o mesmo estilo e o tamanho medido) e compara a foto
// com a original (zoom 4). Diferença esperada só no ic_underline (o "a" em <text> perde a Literata
// quando o SVG vira imagem isolada — armadilha registrada no catálogo).
// Uso: [CONJUNTO=inicio2] [CATS=ic,il] [MODO=inline] NODE_PATH=$(npm root -g) node tools/medicao/conferir_svgs.js [slug,…] && python3 tools/medicao/conferir_svgs.py
// T02: catálogo e fotos pelo conjunto (svgCatalogo; fotos na pasta tmp do conjunto, não mais em /tmp/claude-0).
// T13.11: MODO=inline troca cada <svg> pelo arquivo EM LINHA (fotos em svgcmp_inline/): o novo <svg> leva só o style e
// o width/height do original (o mesmo layout; sem class), os ids do arquivo com prefixo por troca (t<k>_) e herda a
// fonte e a cor da página — prova a geometria sem o que é do <img>: o encaixe da caixa no pixel, a reamostragem do
// <img> girado, o recorte do que passa da caixa e o <text> sem as fontes da página. O padrão (<img>) mostra essas armadilhas.
const fs = require('fs');
const path = require('path');

const { RAIZ, pranchas, lancar, abrir, idmap, tmpDir, caminho } = require('./comum');

(async () => {
  const cat = JSON.parse(fs.readFileSync(caminho('svgCatalogo')));
  const browser = await lancar();
  const Z = 4, res = {}, INLINE = process.env.MODO === 'inline', PASTA = INLINE ? 'svgcmp_inline' : 'svgcmp';
  for (const p of pranchas(process.argv[2] || 'todas')) {
    const ids = idmap(p).ids;
    const cats = (process.env.CATS || 'ic,il,tinta,graf').split(',');
    const trocas = Object.entries(cat.usos).filter(([, u]) => u[p.slug] && cats.includes(cat.arquivos[u[p.slug].arquivo].categoria)).map(([id, u]) => ({ id, arq: u[p.slug].arquivo,
      data: 'data:image/svg+xml;base64,' + fs.readFileSync(path.join(RAIZ, u[p.slug].arquivo)).toString('base64'),
      texto: fs.readFileSync(path.join(RAIZ, u[p.slug].arquivo), 'utf8') }));
    if (!trocas.length) continue;
    const { page } = await abrir(browser, p, { zoom: Z, viewportH: Math.min(p.canvas[1] * Z, 4000) });
    const shot = async (n) => { const f = path.join(tmpDir(PASTA), `${p.slug}_${n}.png`); await page.screenshot({ path: f, clip: { x: 0, y: 0, width: p.canvas[0] * Z, height: p.canvas[1] * Z }, fullPage: true }); return f; };
    const a = await shot('a');
    await page.evaluate(({ trocas, ids, INLINE }) => {
      const inv = Object.fromEntries(Object.entries(ids).map(([t, id]) => [id, t]));
      for (const [k, t] of trocas.entries()) {
        const el = document.querySelector(`[data-dc-tpl="${inv[t.id]}"]`);
        if (INLINE) {
          let txt = t.texto;
          for (const [, id] of [...t.texto.matchAll(/\bid="([^"]+)"/g)]) {
            txt = txt.split(`id="${id}"`).join(`id="t${k}_${id}"`).split(`#${id})`).join(`#t${k}_${id})`).split(`href="#${id}"`).join(`href="#t${k}_${id}"`);
          }
          const novo = document.importNode(new DOMParser().parseFromString(txt, 'image/svg+xml').documentElement, true);
          novo.removeAttribute('width'); novo.removeAttribute('height');
          for (const a of ['width', 'height', 'style']) if (el.hasAttribute(a)) novo.setAttribute(a, el.getAttribute(a));
          el.replaceWith(novo);
          continue;
        }
        const r = el.getBoundingClientRect(); const z = parseFloat(document.body.style.zoom) || 1;
        const img = document.createElement('img');
        img.setAttribute('style', el.getAttribute('style') || '');
        // T02: o tamanho do layout (getComputedStyle, sem os giros dos pais), não o retângulo visível — na 62 os
        // selos ficam em cartões girados; sem giro os dois são iguais (leitor)
        const cs = getComputedStyle(el), cw = parseFloat(cs.width), ch = parseFloat(cs.height);
        img.style.width = (cw > 0 ? cw : r.width / z) + 'px'; img.style.height = (ch > 0 ? ch : r.height / z) + 'px';
        img.style.display = getComputedStyle(el).display === 'block' ? 'block' : 'inline-block';
        img.style.verticalAlign = getComputedStyle(el).verticalAlign;
        img.src = t.data; el.replaceWith(img);
      }
    }, { trocas, ids, INLINE });
    await page.waitForTimeout(600);
    const b = await shot('b');
    res[p.slug] = { a, b, trocas: trocas.length };
    await page.close();
  }
  await browser.close();
  fs.writeFileSync(path.join(tmpDir(PASTA), 'svgcmp.json'), JSON.stringify(res));
})();
