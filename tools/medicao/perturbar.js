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
// D-280: o fio de navalha de texto medido no navegador (conjuntos.json → facaNavegador; o projeto e a Início)
const NAV = !!require('./conjunto').C.facaNavegador;
const TETO = 4096; // até onde a sobra é procurada (px); além disso a linha não quebra ao crescer

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
    let facas = await page.evaluate(async ({ Z, alvos, LIMIAR, UNICA, NAV, ids, frameSel }) => {
      const frame = document.querySelector(frameSel);
      frame.querySelectorAll('*').forEach(e => { if (e.style && e.style.transform) e.style.transform = 'none'; });
      await new Promise(r => setTimeout(r, 200));
      const res = {};
      // D-280: com facaNavegador o fio de navalha de texto é medido no navegador (facasNavegador, abaixo); aqui só a
      // estimativa da G01 (o leitor) e as fileiras da D-278
      for (const a of NAV ? [] : alvos) {
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
        // D-276: sobra 0 = a linha dá a largura da caixa (a caixa é do tamanho do texto e cresce junto): não é risco,
        // como na linha única (D-275). Nenhum risco do leitor e da Início tinha sobra 0.
        const riscos = info.filter(x => (a.lines.length > 1 && x.sobra > 0.001 && x.sobra < LIMIAR) || (x.estouroComProxima !== null && x.estouroComProxima >= 0 && x.estouroComProxima < LIMIAR));
        const impostas = info.filter(x => x.estouroComProxima !== null && x.estouroComProxima < 0).map(x => x.linha);
        if (riscos.length || info.some(x => x.sobra < -0.01)) res[a.k] = { composto: a.composto, quebraPadrao: cs.textWrapStyle || 'auto', riscos, quebrasImpostas: impostas, linhas: info };
      }
      // D-278 (conjuntos com facaLinhaUnica: o projeto): a fileira de um flex-wrap também é fio de navalha — os chips
      // de uma fileira cheia por < 1,5 px (sobra) ou o 1º item da fileira seguinte que caberia faltando < 1,5 px
      // (estouro): uma diferença mínima de largura de texto muda as fileiras e desloca todos os itens seguintes. A
      // quebra usa o tamanho hipotético de cada item (o flex-basis, antes de crescer ou encolher): crescer e encolher
      // são desligados enquanto se mede (não mudam as fileiras) e voltam depois. A entrada fica no id do contêiner,
      // com `fileiras: true`; cada "linha" é uma fileira e o texto, os textos dos itens separados por " | " (o "·" aparece dentro dos textos).
      if (UNICA) {
        const px = v => parseFloat(v) || 0;
        for (const el of [frame, ...frame.querySelectorAll('[data-dc-tpl]')]) {
          const id = ids[el.getAttribute('data-dc-tpl')];
          if (!id) continue;
          const cs = getComputedStyle(el);
          if (!/flex/.test(cs.display) || !/^wrap/.test(cs.flexWrap)) continue; // wrap ou wrap-reverse (não o nowrap)
          const itens = [...el.children].filter(c => { const q = getComputedStyle(c);
            return q.display !== 'none' && q.position !== 'absolute' && q.position !== 'fixed'; });
          if (!itens.length) continue;
          const lin = /row/.test(cs.flexDirection);
          const antes = itens.map(c => [c.style.flexGrow, c.style.flexShrink]);
          itens.forEach(c => { c.style.flexGrow = '0'; c.style.flexShrink = '0'; });
          const r = el.getBoundingClientRect();
          const disp = lin ? r.width / Z - px(cs.paddingLeft) - px(cs.paddingRight) - px(cs.borderLeftWidth) - px(cs.borderRightWidth)
            : r.height / Z - px(cs.paddingTop) - px(cs.paddingBottom) - px(cs.borderTopWidth) - px(cs.borderBottomWidth);
          const gap = px(lin ? cs.columnGap : cs.rowGap);
          // a ordem do flex (order, estável) e o sentido do eixo principal: uma fileira nova começa quando o item volta
          const ord = itens.map((c, i) => ({ c, i, o: px(getComputedStyle(c).order) })).sort((a, b) => a.o - b.o || a.i - b.i);
          const sinal = (lin ? (/reverse/.test(cs.flexDirection) !== (cs.direction === 'rtl')) : /reverse/.test(cs.flexDirection)) ? -1 : 1;
          const med = ord.map(({ c }) => { const q = getComputedStyle(c), b = c.getBoundingClientRect();
            return { ini: (lin ? b.left : b.top) * sinal,
              ext: lin ? b.width / Z + px(q.marginLeft) + px(q.marginRight) : b.height / Z + px(q.marginTop) + px(q.marginBottom),
              texto: (c.innerText || '').replace(/\s+/g, ' ').trim() || ids[c.getAttribute('data-dc-tpl')] || c.tagName.toLowerCase() }; });
          itens.forEach((c, i) => { c.style.flexGrow = antes[i][0]; c.style.flexShrink = antes[i][1]; });
          const fileiras = [];
          med.forEach((m, i) => { const a = med[i - 1];
            if (!i || m.ini < a.ini || (m.ini === a.ini && a.ext > 0.001)) fileiras.push([]);
            fileiras[fileiras.length - 1].push(m); });
          const info = fileiras.map((f, i) => {
            const usado = f.reduce((s, m) => s + m.ext, 0) + gap * (f.length - 1);
            const prox = fileiras[i + 1] ? fileiras[i + 1][0].ext : null;
            return { linha: i + 1, texto: f.map(m => m.texto).join(' | '), largura: +usado.toFixed(3), disponivel: +disp.toFixed(3),
              sobra: +(disp - usado).toFixed(3), estouroComProxima: prox !== null ? +(usado + gap + prox - disp).toFixed(3) : null };
          });
          const riscos = info.filter(x => (x.sobra > 0.001 && x.sobra < LIMIAR) || (x.estouroComProxima !== null && x.estouroComProxima >= 0 && x.estouroComProxima < LIMIAR));
          if (!riscos.length && !info.some(x => x.sobra < -0.01)) continue;
          if (res[id]) throw new Error(`${id}: fio de navalha de texto e de fileira no mesmo id`);
          res[id] = { composto: false, fileiras: true, quebraPadrao: cs.flexWrap, riscos, quebrasImpostas: [], linhas: info };
        }
      }
      return res;
    }, { Z, alvos, LIMIAR, UNICA, NAV, ids, frameSel: CFG.frame });
    await page.close();
    if (NAV) {
      ({ page } = await abrir(browser, p, { zoom: Z, viewportH: 1000 }));
      const nav = await facasNavegador(page, { Z, alvos, LIMIAR, UNICA, TETO, frameSel: CFG.frame });
      await page.close();
      // a ordem de antes: os fios de texto (na ordem dos alvos) e depois as fileiras
      for (const k of Object.keys(nav)) if (facas[k]) throw new Error(`${k}: fio de navalha de texto e de fileira no mesmo id`);
      facas = { ...nav, ...facas };
    }
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

// D-280 — o fio de navalha de texto medido no navegador (conjuntos com facaNavegador: o projeto e a Início). A G01
// estimava cada linha como texto simples na fonte da caixa contra a largura da caixa, e errava com trecho em outro
// peso na linha, texto ao lado de outro item numa caixa flex, <br> cuja junção não caberia, próxima palavra dentro de
// trecho nowrap e text-wrap: pretty/balance. Aqui, para cada linha, +δ ou −δ (px) num <span> em volta do último espaço
// entre palavras da linha (ou do último caractere, se ela tem uma palavra só) alarga ou estreita só aquela linha, e o
// navegador quebra de novo: a sobra é o menor δ que muda as quebras do texto; o estouro, o menor encolhimento que faz a
// próxima palavra subir. O δ vai como margem à direita do <span> (encolhe sem limite); no texto com text-wrap: pretty ou
// balance vai como word-spacing (letter-spacing no caractere), porque com margem diferente de zero o Chromium deixa de
// aplicar o pretty e quebra do jeito simples — e aí o estouro maior do que os espaços da linha conseguem encolher (uns
// 3–4 px) fica null sem virar quebra imposta. Trava: com δ = 0 as quebras têm de ser as da prancha. Sem mudança até o teto: a linha não quebra ao crescer (sobra null; ex.:
// uma palavra só, ou caixa do tamanho do texto com espaço de sobra — a D-276) ou a quebra é imposta (estouro null:
// <br>, nowrap). A largura da linha é a real (caracteres visíveis, cada um na sua fonte); disponível = largura + sobra.
async function facasNavegador(page, { Z, alvos, LIMIAR, UNICA, TETO, frameSel }) {
  return page.evaluate(async ({ Z, alvos, LIMIAR, UNICA, TETO, frameSel }) => {
    const frame = document.querySelector(frameSel);
    frame.querySelectorAll('*').forEach(e => { if (e.style && e.style.transform) e.style.transform = 'none'; });
    await new Promise(r => setTimeout(r, 200));
    // o texto solto dentro de uma caixa flex/grid é um item anônimo, e o <span> do teste viraria outro item: cada trecho
    // contíguo de texto filho direto vai num <span> (o mesmo item, agora com elemento) — nenhuma caixa pode se mover
    const caixas = () => [...frame.querySelectorAll('[data-dc-tpl]')].map(e => { const r = e.getBoundingClientRect();
      return [r.x, r.y, r.width, r.height].map(v => v.toFixed(3)).join(','); }).join(';');
    const antes = caixas();
    for (const c of [frame, ...frame.querySelectorAll('*')]) {
      if (!/flex|grid/.test(getComputedStyle(c).display)) continue;
      let run = [];
      const fecha = () => {
        if (run.some(n => n.textContent.trim())) { const sp = document.createElement('span'); run[0].before(sp); run.forEach(n => sp.appendChild(n)); }
        run = [];
      };
      for (const n of [...c.childNodes]) { if (n.nodeType === 3) run.push(n); else fecha(); }
      fecha();
    }
    await new Promise(r => setTimeout(r, 50));
    if (caixas() !== antes) throw new Error('D-280: embrulhar o texto solto de flex/grid moveu caixas');
    const fora = (n, el) => {
      for (let anc = n.parentElement; anc && anc !== el; anc = anc.parentElement) {
        const q = getComputedStyle(anc);
        if (q.position === 'absolute' || q.position === 'fixed' || anc.tagName.toLowerCase() === 'svg') return true;
      }
      return false;
    };
    // os caracteres desenhados, em ordem, agrupados em linhas (nova linha quando o caractere volta para a esquerda e desce)
    const linhasDe = (el) => {
      const chars = [];
      const tw = document.createTreeWalker(el, NodeFilter.SHOW_TEXT);
      for (let n = tw.nextNode(); n; n = tw.nextNode()) {
        if (fora(n, el)) continue;
        const t = n.textContent;
        for (let i = 0; i < t.length; i++) {
          const rg = document.createRange(); rg.setStart(n, i); rg.setEnd(n, i + 1);
          const rc = [...rg.getClientRects()].find(x => x.width > 0 || x.height > 0);
          if (rc) chars.push({ c: t[i], n, o: i, l: rc.left / Z, r: rc.right / Z, top: rc.top / Z });
        }
      }
      const linhas = [];
      let cur = null;
      for (const ch of chars) {
        if (!cur || (ch.l < cur.ult.r - 1 && ch.top > cur.ult.top + 1)) { cur = { cs: [] }; linhas.push(cur); }
        cur.cs.push(ch); cur.ult = ch;
      }
      return linhas.map(l => l.cs).filter(cs => cs.some(x => x.c.trim()));
    };
    // as quebras: a altura de cada caractere desenhado em relação à caixa do texto (o espaçamento do teste só move os
    // caracteres na horizontal; mudar de linha muda a altura). Reagrupar em linhas falharia com a linha encolhida a
    // quase nada (o 1º caractere da linha de baixo começa onde ela termina).
    const assinatura = (el) => {
      const t0 = el.getBoundingClientRect().top;
      const out = [];
      const tw = document.createTreeWalker(el, NodeFilter.SHOW_TEXT);
      for (let n = tw.nextNode(); n; n = tw.nextNode()) {
        if (fora(n, el)) continue;
        const t = n.textContent;
        for (let i = 0; i < t.length; i++) {
          if (!t[i].trim()) continue;
          const rg = document.createRange(); rg.setStart(n, i); rg.setEnd(n, i + 1);
          const rc = [...rg.getClientRects()].find(x => x.width > 0 || x.height > 0);
          if (rc) out.push(((rc.top - t0) / Z).toFixed(2));
        }
      }
      return out.join(',');
    };
    // +delta (px) num <span> em volta do caractere (n, o) — margem à direita ou, com espacamento, word-spacing (espaço)
    // ou letter-spacing (outro caractere) somado ao do pai; devolve a assinatura das linhas e desfaz
    const testa = (el, n, o, delta, espacamento) => {
      const pai = n.parentNode;
      const q = getComputedStyle(n.parentElement);
      const prop = !espacamento ? 'marginRight' : n.textContent[o].trim() ? 'letterSpacing' : 'wordSpacing';
      const v0 = !espacamento || q[prop] === 'normal' ? 0 : parseFloat(q[prop]);
      const meio = o === 0 ? n : n.splitText(o); // o === 0: o próprio nó (vazio, o normalize() o tiraria do DOM)
      meio.splitText(1);
      const sp = document.createElement('span');
      sp.style[prop] = (v0 + delta) + 'px';
      meio.replaceWith(sp); sp.appendChild(meio);
      const a = assinatura(el);
      sp.replaceWith(meio); pai.normalize();
      return a;
    };
    // o menor |δ| (sinal +1 alarga, −1 encolhe) que muda as quebras, até o teto; null = não muda
    const limiar = (el, alvo, sinal, base, teto, esp) => {
      let lo = 0, hi = Math.min(LIMIAR, teto);
      if (testa(el, alvo.n, alvo.o, sinal * hi, esp) === base) {
        if (hi >= teto) return null;
        for (;;) {
          lo = hi; hi = Math.min(hi * 2, teto);
          if (testa(el, alvo.n, alvo.o, sinal * hi, esp) !== base) break;
          if (hi >= teto) return null;
        }
      }
      while (hi - lo > 0.0002) { const m = (lo + hi) / 2; if (testa(el, alvo.n, alvo.o, sinal * m, esp) === base) lo = m; else hi = m; }
      return +((lo + hi) / 2).toFixed(3); // o meio do intervalo: erro de no máximo 0,0001
    };
    const px = v => parseFloat(v) || 0;
    const res = {};
    for (const a of alvos) {
      const el = frame.querySelector(`[data-dc-tpl="${a.tpl}"]`) || (frame.getAttribute('data-dc-tpl') == a.tpl ? frame : null);
      if (!el) continue;
      const cs = getComputedStyle(el);
      if (cs.whiteSpace === 'nowrap' || cs.whiteSpace === 'pre' || cs.display === 'inline') continue; // inline: coberto pelo texto composto do pai
      if (el.closest('svg')) continue; // texto de SVG não quebra linha
      const linhas = linhasDe(el);
      if (!linhas.length) continue;
      if (linhas.length !== a.lines.length) throw new Error(`${a.k}: ${linhas.length} linha(s) no navegador × ${a.lines.length} no layout`);
      const base = assinatura(el);
      const r = el.getBoundingClientRect();
      const contentW = r.width / Z - px(cs.paddingLeft) - px(cs.paddingRight) - px(cs.borderLeftWidth) - px(cs.borderRightWidth);
      const indent = px(cs.textIndent);
      const med = linhas.map((l, i) => {
        const vis = l.filter(x => x.c.trim());
        const ini = l.indexOf(vis[0]), fim = l.indexOf(vis[vis.length - 1]);
        const esp = l.slice(ini, fim).reverse().find(x => x.c === ' ' || x.c === String.fromCharCode(160));
        return { alvo: esp || vis[vis.length - 1], largura: Math.max(...vis.map(x => x.r)) - Math.min(...vis.map(x => x.l)),
          caixa: contentW - (i === 0 ? indent : 0) };
      });
      const esp = /pretty|balance/.test(cs.textWrapStyle || '');
      med.forEach((m, i) => { if (testa(el, m.alvo.n, m.alvo.o, 0, esp) !== base) throw new Error(`${a.k}: com δ = 0 as quebras já mudam (linha ${i + 1})`); });
      // 1º passo, só até o limiar: há risco (ou alguma linha estoura a caixa)?
      const curta = med.map((m, i) => ({ sobra: limiar(el, m.alvo, +1, base, LIMIAR, esp),
        estouro: i + 1 < med.length ? limiar(el, m.alvo, -1, base, LIMIAR, esp) : null }));
      const risco = x => (x.sobra !== null && (med.length > 1 || UNICA)) || x.estouro !== null;
      const estoura = med.some(m => m.largura > m.caixa + 0.01);
      if (!curta.some(risco) && !estoura) continue;
      // 2º passo: os valores exatos de todas as linhas (a sobra até o teto; o estouro até a largura da própria linha)
      const info = med.map((m, i) => {
        const sobra = curta[i].sobra !== null ? curta[i].sobra : limiar(el, m.alvo, +1, base, TETO, esp);
        const estouro = i + 1 >= med.length ? null : curta[i].estouro !== null ? curta[i].estouro : limiar(el, m.alvo, -1, base, m.largura, esp);
        return { linha: i + 1, texto: a.lines[i], largura: +m.largura.toFixed(3),
          disponivel: +(sobra !== null ? m.largura + sobra : m.caixa).toFixed(3), sobra, estouroComProxima: estouro };
      });
      const riscos = info.filter((x, i) => risco(curta[i]));
      // quebra imposta: a próxima palavra não sobe nem com a linha encolhida a nada (no pretty/balance não dá para saber)
      const impostas = esp ? [] : info.filter(x => x.linha < info.length && x.estouroComProxima === null).map(x => x.linha);
      res[a.k] = { composto: a.composto, quebraPadrao: cs.textWrapStyle || 'auto', ...(info.length === 1 ? { linhaUnica: true } : {}),
        riscos, quebrasImpostas: impostas, linhas: info };
    }
    return res;
  }, { Z, alvos, LIMIAR, UNICA, TETO, frameSel });
}
