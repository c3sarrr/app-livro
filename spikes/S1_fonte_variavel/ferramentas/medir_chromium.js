// S1 — larguras de referência no Chromium (Playwright 1.56 / Chromium 141, --font-render-hinting=none).
// Uso (da raiz do repositório): NODE_PATH=$(npm root -g) node spikes/S1_fonte_variavel/ferramentas/medir_chromium.js
// Fonte: o binário Literata do próprio arquivo de design (subconjunto latin variável opsz+wght),
// com font-optical-sizing automático (opsz = tamanho em px), como o navegador mostra a tela 19.
// Para cada tamanho do leitor (D-20) e cada parágrafo da amostra:
//   1. quebras de linha a zoom 1 (as que a pessoa vê): texto de cada linha, recuo 1,3 em;
//   2. largura de cada linha isolada (span sem quebra) a zoom 100 (÷ 100: sem o arredondamento
//      de 1/64 px do layout) e a zoom 1 (conferência: o zoom não pode mudar o opsz).
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const RAIZ = path.resolve(__dirname, '..', '..', '..');
const S1 = path.resolve(__dirname, '..');
const FONTE = path.join(RAIZ, 'handoff_v2/referencia/fontes_do_arquivo/Literata-latin-var-opsz-wght.woff2');
const TAMANHOS = [16, 17.5, 19, 20.5, 22, 24, 26];
const LARGURA = 334; // 390 − 2 × 28 (margem Média)
const ENTRELINHA = 1.72;

const amostra = JSON.parse(fs.readFileSync(path.join(S1, 'dados/amostra.json'), 'utf8'));

function html() {
  return `<!doctype html><html><head><meta charset="utf-8"><style>
@font-face{font-family:'Literata';src:url('file://${FONTE}') format('woff2');font-weight:400 900;font-style:normal}
html,body{margin:0;padding:0}
#pag{width:${LARGURA}px}
#pag p{margin:0;text-indent:1.3em;font-family:'Literata';font-weight:400;text-align:left;hyphens:manual;
  overflow-wrap:normal;word-break:normal;font-kerning:normal;font-optical-sizing:auto;color:#2A2520}
.iso{white-space:nowrap;font-family:'Literata';font-weight:400;font-optical-sizing:auto;display:inline-block}
</style></head><body><div id="pag"></div><div id="isos"></div></body></html>`;
}

async function main() {
  const browser = await chromium.launch({ args: ['--font-render-hinting=none'] });
  const page = await browser.newPage({ viewport: { width: 1200, height: 900 } });
  await page.route('**/*', r => (r.request().url().startsWith('http') ? r.abort() : r.continue()));
  const tmp = path.join(S1, 'dados', '_medir.html');
  fs.writeFileSync(tmp, html());
  await page.goto('file://' + tmp);
  const saida = { chromium: '', fonte: path.relative(RAIZ, FONTE), largura: LARGURA, entrelinha: ENTRELINHA, tamanhos: {} };
  saida.chromium = browser.version();
  for (const s of TAMANHOS) {
    const r = await page.evaluate(async ({ s, pars, ENTRELINHA }) => {
      document.body.style.zoom = '1';
      const pag = document.getElementById('pag');
      pag.innerHTML = '';
      for (const t of pars) {
        const p = document.createElement('p');
        p.style.fontSize = s + 'px';
        p.style.lineHeight = ENTRELINHA;
        p.textContent = t;
        pag.appendChild(p);
      }
      await document.fonts.ready;
      const fontesOk = document.fonts.check(`400 ${s}px Literata`);
      // Quebras: agrupa os caracteres pelo topo do retângulo (zoom 1).
      const linhas = [];
      [...pag.children].forEach((p, ip) => {
        const no = p.firstChild;
        const txt = no.data;
        const rg = document.createRange();
        let atual = null;
        for (let i = 0; i < txt.length; i++) {
          rg.setStart(no, i); rg.setEnd(no, i + 1);
          const rs = rg.getClientRects();
          if (!rs.length) continue; // espaço colapsado no fim de linha
          const top = Math.round(rs[0].top * 64);
          if (!atual || atual.top !== top) {
            atual = { p: ip, top, ini: i, fim: i + 1 };
            linhas.push(atual);
          } else atual.fim = i + 1;
        }
      });
      const pRects = [...pag.children].map(p => p.getBoundingClientRect().height);
      return { fontesOk, pRects, linhas: linhas.map(l => ({ p: l.p, ini: l.ini, fim: l.fim, top: l.top / 64 })) };
    }, { s, pars: amostra.paragrafos, ENTRELINHA });
    // Texto de cada linha (sem o espaço final) e largura isolada a zoom 1 e 100.
    const linhas = r.linhas.map((l, k) => {
      const t = amostra.paragrafos[l.p];
      let fim = l.fim;
      while (fim > l.ini && t[fim - 1] === ' ') fim--;
      const primeira = k === 0 || r.linhas[k - 1].p !== l.p;
      return { p: l.p, ini: l.ini, fim, primeira, texto: t.slice(l.ini, fim) };
    });
    for (const z of [1, 100]) {
      const ws = await page.evaluate(async ({ s, z, textos }) => {
        document.getElementById('pag').innerHTML = '';
        document.body.style.zoom = String(z);
        const box = document.getElementById('isos');
        box.innerHTML = '';
        const spans = textos.map(t => {
          const d = document.createElement('div');
          const sp = document.createElement('span');
          sp.className = 'iso';
          sp.style.fontSize = s + 'px';
          sp.textContent = t;
          d.appendChild(sp);
          box.appendChild(d);
          return sp;
        });
        await document.fonts.ready;
        const out = spans.map(sp => sp.getBoundingClientRect().width / z);
        box.innerHTML = '';
        document.body.style.zoom = '1';
        return out;
      }, { s, z, textos: linhas.map(l => l.texto) });
      linhas.forEach((l, i) => { l[z === 1 ? 'larguraZoom1' : 'largura'] = Math.round(ws[i] * 1e5) / 1e5; });
    }
    saida.tamanhos[String(s)] = { fontesOk: r.fontesOk, alturasParagrafos: r.pRects, linhas };
    console.log(`${s}px: ${linhas.length} linhas, fonte ok=${r.fontesOk}`);
  }
  fs.unlinkSync(tmp);
  fs.writeFileSync(path.join(S1, 'dados/linhas_chromium.json'), JSON.stringify(saida, null, 1));
  await browser.close();
}

main().catch(e => { console.error(e); process.exit(1); });
