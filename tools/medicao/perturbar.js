// G01.6 — dependência de texto (perturb da v1) e quebras "fio de navalha" (knife da v1), por prancha.
//  dependência: mede todos os ids (zoom 100, transforms neutralizados), alarga TODO texto um pouco
//    (word-spacing +0,4 px e letter-spacing +0,05 px) e mede de novo → ids cujo x/w (ou y/h) mudam
//    dependem da largura do texto (no teste: tolerância ±1,0 em x/w, como na v1).
//  fio de navalha: para cada linha medida, sobra = largura disponível − largura da linha e
//    estouro = largura (linha + próxima palavra) − largura disponível. Sobra ou estouro < 1,5 px =
//    quebra frágil: diferença mínima de métrica entre Chromium e Flutter muda a quebra.
// Saída: handoff_v2/referencia/layout/text_dependency.json e knife_edges.json ({slug: …})
// Uso: NODE_PATH=$(npm root -g) node tools/medicao/perturbar.js [todas|19,20…]
const fs = require('fs');
const path = require('path');
const { CFG, RAIZ, pranchas, lancar, abrir, idmap, caminho } = require('./comum');

const Z = 100;
const LIMIAR = 1.5;
// D-275: o fio de navalha de uma linha só (conjuntos.json → facaLinhaUnica; o projeto)
const UNICA = !!require('./conjunto').C.facaLinhaUnica;

(async () => {
  const sel = pranchas(process.argv[2]);
  const out = caminho('layout');
  const depF = path.join(out, 'text_dependency.json');
  const kniF = path.join(out, 'knife_edges.json');
  const dep = fs.existsSync(depF) && process.argv[2] && process.argv[2] !== 'todas' ? JSON.parse(fs.readFileSync(depF)) : {};
  const kni = fs.existsSync(kniF) && process.argv[2] && process.argv[2] !== 'todas' ? JSON.parse(fs.readFileSync(kniF)) : {};
  const browser = await lancar();
  for (const p of sel) {
    const ids = idmap(p).ids;
    const layout = JSON.parse(fs.readFileSync(path.join(out, `layout_${p.slug}.json`)));
    // ── fio de navalha (página sem perturbação) ──
    let { page } = await abrir(browser, p, { zoom: Z, viewportH: 1000 });
    const alvos = Object.entries(layout.elements)
      .filter(([, e]) => (e.lines && e.lines.length) || (e.linesAll && e.linesAll.length))
      .map(([k, e]) => ({ k, tpl: e.tpl, lines: (e.linesAll || e.lines).map(l => l.text), composto: !!e.linesAll }));
    const facas = await page.evaluate(async ({ Z, alvos, LIMIAR, UNICA, frameSel }) => {
      const frame = document.querySelector(frameSel);
      frame.querySelectorAll('*').forEach(e => { if (e.style && e.style.transform) e.style.transform = 'none'; });
      await new Promise(r => setTimeout(r, 200));
      const res = {};
      for (const a of alvos) {
        const el = frame.querySelector(`[data-dc-tpl="${a.tpl}"]`) || (frame.getAttribute('data-dc-tpl') == a.tpl ? frame : null);
        if (!el) continue;
        const cs = getComputedStyle(el);
        if (cs.whiteSpace === 'nowrap' || cs.whiteSpace === 'pre' || cs.display === 'inline') continue; // inline: coberto pelo texto composto do pai
        if (a.lines.length < 2 && !(el.scrollWidth > 0)) continue;
        // D-275 (conjuntos com facaLinhaUnica: o projeto): a linha ÚNICA que pode quebrar (tem espaço; caixa que não é
        // flex/grid) numa caixa de largura imposta, com sobra < 1,5 px, também é fio de navalha. A largura é a real da
        // linha (Range sobre os nós de texto: pesos e filhos inline como estão). Sobra 0 = caixa do tamanho do texto
        // (cresce com ele e não quebra).
        if (UNICA && a.lines.length === 1 && /\s/.test(a.lines[0].trim()) && !/flex|grid/.test(cs.display)) {
          const r = el.getBoundingClientRect();
          const disp = r.width / Z - parseFloat(cs.paddingLeft) - parseFloat(cs.paddingRight) - parseFloat(cs.borderLeftWidth)
            - parseFloat(cs.borderRightWidth) - (parseFloat(cs.textIndent) || 0);
          let esq = Infinity, dir = -Infinity;
          const tw = document.createTreeWalker(el, NodeFilter.SHOW_TEXT);
          for (let n = tw.nextNode(); n; n = tw.nextNode()) {
            if (!n.textContent.trim()) continue;
            let anc = n.parentElement, fora = false;
            for (; anc && anc !== el; anc = anc.parentElement) {
              const q = getComputedStyle(anc);
              if (q.position === 'absolute' || q.position === 'fixed' || anc.tagName.toLowerCase() === 'svg') { fora = true; break; }
            }
            if (fora) continue;
            const rg = document.createRange(); rg.selectNodeContents(n);
            for (const rc of rg.getClientRects()) { esq = Math.min(esq, rc.left); dir = Math.max(dir, rc.right); }
          }
          const w = (dir - esq) / Z, sobra = disp - w;
          const linha = { linha: 1, texto: a.lines[0], largura: +w.toFixed(3), disponivel: +disp.toFixed(3), sobra: +sobra.toFixed(3),
            estouroComProxima: null };
          const risco = sobra > 0.001 && sobra < LIMIAR;
          if (risco || sobra < -0.01) res[a.k] = { composto: a.composto, quebraPadrao: cs.textWrapStyle || 'auto', linhaUnica: true,
            riscos: risco ? [linha] : [], quebrasImpostas: [], linhas: [linha] };
          continue;
        }
        // texto composto com outra família/tamanho num filho (ex.: "Ajustes *de leitura*") não dá para medir com uma fonte só
        const fontesFilhos = (n) => [...n.children].flatMap(c => { const q = getComputedStyle(c);
          if (q.position === 'absolute' || q.position === 'fixed' || c.tagName.toLowerCase() === 'svg' || q.display !== 'inline') return [];
          return [q.fontFamily + '|' + q.fontSize, ...fontesFilhos(c)]; });
        if (a.composto && fontesFilhos(el).some(f => f !== cs.fontFamily + '|' + cs.fontSize)) continue;
        const r = el.getBoundingClientRect();
        const contentW = r.width / Z - parseFloat(cs.paddingLeft) - parseFloat(cs.paddingRight) - parseFloat(cs.borderLeftWidth) - parseFloat(cs.borderRightWidth);
        const indent = parseFloat(cs.textIndent) || 0;
        const medir = (t) => {
          const s = document.createElement('span');
          s.style.cssText = `position:absolute;white-space:pre;text-indent:0;font-family:${cs.fontFamily};font-size:${cs.fontSize};font-weight:${cs.fontWeight};font-style:${cs.fontStyle};letter-spacing:${cs.letterSpacing};word-spacing:${cs.wordSpacing};font-variant-numeric:${cs.fontVariantNumeric};font-feature-settings:${cs.fontFeatureSettings};`;
          s.textContent = t; el.appendChild(s); const w = s.getBoundingClientRect().width / Z; s.remove(); return w;
        };
        const info = [];
        for (let i = 0; i < a.lines.length; i++) {
          const disp = contentW - (i === 0 ? indent : 0);
          const w = medir(a.lines[i]);
          const prox = a.lines[i + 1] ? a.lines[i + 1].split(' ')[0] : null;
          const wj = prox ? medir(a.lines[i] + ' ' + prox) : null;
          info.push({ linha: i + 1, texto: a.lines[i], largura: +w.toFixed(3), disponivel: +disp.toFixed(3), sobra: +(disp - w).toFixed(3),
            estouroComProxima: wj !== null ? +(wj - disp).toFixed(3) : null });
        }
        // risco = linha cheia por < 1,5 px (sobra) ou próxima palavra entraria faltando < 1,5 px (estouro ≥ 0).
        // estouro < 0 = a próxima palavra caberia, mas a quebra é imposta (<br>, trecho nowrap, regra de quebra).
        const riscos = info.filter(x => (a.lines.length > 1 && x.sobra >= 0 && x.sobra < LIMIAR) || (x.estouroComProxima !== null && x.estouroComProxima >= 0 && x.estouroComProxima < LIMIAR));
        const impostas = info.filter(x => x.estouroComProxima !== null && x.estouroComProxima < 0).map(x => x.linha);
        if (riscos.length || info.some(x => x.sobra < -0.01)) res[a.k] = { composto: a.composto, quebraPadrao: cs.textWrapStyle || 'auto', riscos, quebrasImpostas: impostas, linhas: info };
      }
      return res;
    }, { Z, alvos, LIMIAR, UNICA, frameSel: CFG.frame });
    await page.close();
    // ── dependência de texto ──
    ({ page } = await abrir(browser, p, { zoom: Z, viewportH: 1000 }));
    const flags = await page.evaluate(async ({ Z, ids, frameSel }) => {
      const f = document.querySelector(frameSel);
      const all = [f, ...f.querySelectorAll('*')];
      all.forEach(e => { if (e.style && e.style.transform) e.style.transform = 'none'; });
      await new Promise(r => setTimeout(r, 200));
      const snap = () => { const fr = f.getBoundingClientRect(); const o = {}; for (const e of all) { const id = ids[e.getAttribute('data-dc-tpl')]; if (!id) continue; const r = e.getBoundingClientRect(); o[id] = [(r.x - fr.x) / Z, (r.y - fr.y) / Z, r.width / Z, r.height / Z]; } return o; };
      const a = snap();
      const st = document.createElement('style'); st.textContent = '* { word-spacing: 0.4px !important; }'; document.head.appendChild(st);
      for (const e of all) { if (!e.style) continue; const cs = getComputedStyle(e); const ls = cs.letterSpacing === 'normal' ? 0 : parseFloat(cs.letterSpacing); e.style.letterSpacing = (ls + 0.05) + 'px'; }
      await new Promise(r => setTimeout(r, 200));
      const b = snap(); const o = {};
      for (const k of Object.keys(a)) o[k] = { x: Math.abs(a[k][0] - b[k][0]) > 0.01, y: Math.abs(a[k][1] - b[k][1]) > 0.01, w: Math.abs(a[k][2] - b[k][2]) > 0.01, h: Math.abs(a[k][3] - b[k][3]) > 0.01 };
      return o;
    }, { Z, ids, frameSel: CFG.frame });
    await page.close();
    dep[p.slug] = Object.fromEntries(Object.entries(flags).sort());
    kni[p.slug] = facas;
    const hx = Object.values(flags).filter(f => f.x || f.w).length, vy = Object.entries(flags).filter(([, f]) => f.y || f.h).map(([k]) => k);
    console.log(`${p.slug.padEnd(24)} x/w dependem do texto: ${String(hx).padStart(3)} · y/h mudam (quebra): ${vy.length} · fio de navalha: ${Object.keys(facas).length ? Object.keys(facas).join(', ') : '—'}`);
  }
  await browser.close();
  const ord = o => Object.fromEntries(CFG.pranchas.filter(p => o[p.slug]).map(p => [p.slug, o[p.slug]]));
  fs.writeFileSync(depF, JSON.stringify(ord(dep), null, 1) + '\n');
  fs.writeFileSync(kniF, JSON.stringify(ord(kni), null, 1) + '\n');
})();
