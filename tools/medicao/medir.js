// G01.4 — mede cada prancha isolada (mesma técnica da v1, generalizada para as 13 pranchas):
//  passo A (zoom 100, transforms neutralizados): retângulo de layout de cada id, linhas de texto
//          (por caractere, com topo/base/baseline), larguras naturais (max/min-content), métricas
//          de fonte por (família, peso, estilo, tamanho) medidas no próprio Chromium;
//  passo B (zoom 100, transforms ativos): retângulo visual (caixa envolvente com rotação/translate);
//  passo C (zoom 100 — no zoom 1 o Chromium arredonda bordas de 1,5 px para 1 px no estilo computado;
//          com zoom os valores voltam sem zoom e exatos, como na v1): estilos computados + fontes reais usadas por nó de texto (CDP
//          CSS.getPlatformFontsForNode — revela fallback do sistema para glifos fora das fontes).
// Saída: tools/medicao/tmp/medicao/<slug>/medida.json
// Uso: NODE_PATH=$(npm root -g) node tools/medicao/medir.js [todas|19,20,…]
const fs = require('fs');
const path = require('path');
const { CFG, pranchas, lancar, abrir, tmpDir, idmap: lerIdmap } = require('./comum');

const Z = 100;

async function passoA(page, ids) {
  return page.evaluate(async ({ Z, ids, frameSel }) => {
    const frame = document.querySelector(frameSel);
    const all = [frame, ...frame.querySelectorAll('*')];
    all.forEach(e => { if (e.style && e.style.transform) { e.dataset.tf = e.style.transform; e.style.transform = 'none'; } });
    await new Promise(r => setTimeout(r, 200));
    const fr = frame.getBoundingClientRect();
    const X = v => +((v - fr.x) / Z).toFixed(3), Y = v => +((v - fr.y) / Z).toFixed(3), L = v => +(v / Z).toFixed(3);
    const byTpl = {};
    for (const e of all) { const t = e.getAttribute('data-dc-tpl'); if (t && ids[t]) byTpl[t] = e; }
    const elems = {};
    for (const [t, e] of Object.entries(byTpl)) {
      const r = e.getBoundingClientRect();
      const direct = [...e.childNodes].filter(n => n.nodeType === 3).map(n => n.textContent).join('').replace(/\s+/g, ' ').trim();
      elems[ids[t]] = { tpl: +t, tag: e.tagName.toLowerCase(), x: X(r.x), y: Y(r.y), w: L(r.width), h: L(r.height),
        text: direct || undefined, aria: e.getAttribute('aria-label') || undefined, role: e.getAttribute('role') || undefined,
        transform: e.dataset.tf || undefined };
    }
    // ── linhas: caracteres agrupados em linhas na ordem do DOM ──
    const fontKey = el => { const cs = getComputedStyle(el); return [cs.fontFamily.split(',')[0].replace(/['"]/g, '').trim(), cs.fontWeight, cs.fontStyle, cs.fontSize].join('|'); };
    const keys = new Set();
    const charsOf = (nodes) => {
      const out = [];
      for (const n of nodes) {
        const s = n.textContent; const k = fontKey(n.parentElement); keys.add(k);
        for (let i = 0; i < s.length; i++) {
          const rg = document.createRange(); rg.setStart(n, i); rg.setEnd(n, i + 1);
          const rs = [...rg.getClientRects()].filter(q => q.width > 0 || q.height > 0); if (!rs.length) continue;
          const q = rs[0]; out.push({ c: s[i], x0: q.left, x1: q.right, y0: q.top, y1: q.bottom, k });
        }
      }
      return out;
    };
    const group = (chars) => {
      const lines = []; let cur = null;
      for (const ch of chars) {
        const cy = (ch.y0 + ch.y1) / 2;
        const novo = !cur || (ch.x0 < cur.lastX - 0.5 * Z && cy > cur.cy + 2 * Z);
        if (novo) { cur = { chars: [], lastX: -1e9, cy }; lines.push(cur); }
        cur.chars.push(ch); cur.lastX = ch.x1;
      }
      return lines.map(l => {
        const vis = l.chars.filter(c => /\S/.test(c.c));
        const base = vis.length ? vis : l.chars;
        return { text: l.chars.map(c => c.c).join('').replace(/\s+/g, ' ').trim(),
          left: X(Math.min(...base.map(c => c.x0))), right: X(Math.max(...base.map(c => c.x1))),
          top: Y(Math.min(...base.map(c => c.y0))), bottom: Y(Math.max(...base.map(c => c.y1))),
          _tops: base.map(c => [Y(c.y0), c.k]) };
      }).filter(l => l.text);
    };
    const inFlowText = (el) => {
      const out = [];
      const walk = (n) => {
        for (const c of n.childNodes) {
          if (c.nodeType === 3) { if (c.textContent.length) out.push(c); continue; }
          if (c.nodeType !== 1 || c.tagName.toLowerCase() === 'svg') continue;
          const p = getComputedStyle(c).position; if (p === 'absolute' || p === 'fixed') continue;
          walk(c);
        }
      };
      walk(el); return out;
    };
    const lines = {}, linesAll = {};
    for (const [t, e] of Object.entries(byTpl)) {
      const tn = [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim());
      if (tn.length) lines[ids[t]] = group(charsOf(tn));
      const hasInlineText = [...e.children].some(c => c.textContent.trim() && getComputedStyle(c).display === 'inline' && !['absolute', 'fixed'].includes(getComputedStyle(c).position) && c.tagName.toLowerCase() !== 'svg');
      // texto composto: o elemento tem texto próprio OU é um bloco (p, h1…) cujo texto está todo em filhos inline
      if (hasInlineText && (tn.length || !getComputedStyle(e).display.startsWith('inline'))) linesAll[ids[t]] = group(charsOf(inFlowText(e)));
    }
    // ── métricas de fonte medidas: topo do glifo vs. marcador na linha de base ──
    const metrics = {};
    const host = document.createElement('div'); host.style.cssText = 'position:absolute;left:0;top:0;white-space:nowrap;'; document.body.appendChild(host);
    for (const k of keys) {
      const [fam, wt, st, sz] = k.split('|');
      const sp = document.createElement('span'); sp.style.cssText = `font-family:'${fam}';font-weight:${wt};font-style:${st};font-size:${sz};line-height:normal;`;
      sp.textContent = 'H'; const mk = document.createElement('span'); mk.style.cssText = 'display:inline-block;width:0;height:0;vertical-align:baseline;';
      sp.appendChild(mk); host.appendChild(sp);
      const rg = document.createRange(); rg.setStart(sp.firstChild, 0); rg.setEnd(sp.firstChild, 1);
      const q = rg.getClientRects()[0]; const b = mk.getBoundingClientRect().top;
      metrics[k] = { ascent: +((b - q.top) / Z).toFixed(4), descent: +((q.bottom - b) / Z).toFixed(4) };
    }
    host.remove();
    const withBaseline = (ls) => ls.map(l => {
      const bs = l._tops.map(([top, k]) => top + metrics[k].ascent).sort((a, b) => a - b);
      const bl = bs[Math.floor(bs.length / 2)];
      const { _tops, ...rest } = l; return { ...rest, baseline: +bl.toFixed(3), baselineSpread: +(bs[bs.length - 1] - bs[0]).toFixed(3) };
    });
    for (const k of Object.keys(lines)) lines[k] = withBaseline(lines[k]);
    for (const k of Object.keys(linesAll)) linesAll[k] = withBaseline(linesAll[k]);
    // ── larguras naturais (como na v1) ──
    const natural = {};
    for (const [t, e] of Object.entries(byTpl)) {
      if (!e.textContent.trim() || e.tagName.toLowerCase() === 'svg' || !lines[ids[t]] && !linesAll[ids[t]]) continue;
      const c = e.cloneNode(true);
      Object.assign(c.style, { position: 'absolute', left: '0', top: '0', width: 'max-content', maxWidth: 'none', minWidth: '0', flexGrow: '0', whiteSpace: 'nowrap', transform: 'none' });
      e.parentElement.appendChild(c); const w = c.getBoundingClientRect().width / Z;
      c.style.whiteSpace = ''; c.style.width = 'min-content'; const mw = c.getBoundingClientRect().width / Z; c.remove();
      natural[ids[t]] = { maxContent: +w.toFixed(3), minContent: +mw.toFixed(3) };
    }
    all.forEach(e => { if (e.dataset && e.dataset.tf) { e.style.transform = e.dataset.tf; delete e.dataset.tf; } });
    return { frame: { w: fr.width / Z, h: fr.height / Z }, elems, lines, linesAll, natural, fontMetrics: metrics };
  }, { Z, ids, frameSel: CFG.frame });
}

async function passoB(page, ids) {
  return page.evaluate(({ Z, ids, frameSel }) => {
    const frame = document.querySelector(frameSel); const fr = frame.getBoundingClientRect(); const vis = {};
    for (const e of [frame, ...frame.querySelectorAll('[data-dc-tpl]')]) {
      const t = e.getAttribute('data-dc-tpl'); if (!ids[t]) continue; const r = e.getBoundingClientRect();
      vis[ids[t]] = [+((r.x - fr.x) / Z).toFixed(3), +((r.y - fr.y) / Z).toFixed(3), +(r.width / Z).toFixed(3), +(r.height / Z).toFixed(3)];
    }
    return vis;
  }, { Z, ids, frameSel: CFG.frame });
}

const PROPS = ['display', 'position', 'top', 'right', 'bottom', 'left', 'zIndex', 'boxSizing', 'overflow', 'overflowX', 'overflowY',
  'backgroundColor', 'backgroundImage', 'backgroundSize', 'backgroundPosition', 'backgroundRepeat',
  'borderTopWidth', 'borderRightWidth', 'borderBottomWidth', 'borderLeftWidth', 'borderTopStyle', 'borderRightStyle', 'borderBottomStyle', 'borderLeftStyle',
  'borderTopColor', 'borderRightColor', 'borderBottomColor', 'borderLeftColor',
  'borderTopLeftRadius', 'borderTopRightRadius', 'borderBottomRightRadius', 'borderBottomLeftRadius',
  'boxShadow', 'opacity', 'mixBlendMode', 'filter', 'transform', 'transformOrigin',
  'paddingTop', 'paddingRight', 'paddingBottom', 'paddingLeft', 'marginTop', 'marginRight', 'marginBottom', 'marginLeft',
  'width', 'height', 'minWidth', 'maxWidth', 'flexGrow', 'flexShrink', 'flexBasis', 'flexDirection', 'alignItems', 'justifyContent', 'gap', 'gridTemplateColumns',
  'fontFamily', 'fontSize', 'fontWeight', 'fontStyle', 'lineHeight', 'letterSpacing', 'wordSpacing', 'color', 'textAlign', 'textIndent',
  'textTransform', 'textDecorationLine', 'textDecorationColor', 'textDecorationStyle', 'textDecorationThickness', 'textUnderlineOffset',
  'whiteSpace', 'textOverflow', 'textWrapMode', 'textWrapStyle', 'wordBreak', 'overflowWrap', 'hyphens', 'verticalAlign',
  'fontVariantNumeric', 'fontFeatureSettings', 'fontVariationSettings', 'fontOpticalSizing', 'fontKerning', 'fontSynthesis',
  'webkitBoxDecorationBreak', 'webkitMaskImage', 'maskImage', 'clipPath', 'pointerEvents', 'visibility', 'cursor', 'outlineStyle', 'outlineWidth', 'outlineColor', 'objectFit'];

async function passoC(page, ids) {
  const styles = await page.evaluate(({ ids, frameSel, PROPS }) => {
    const frame = document.querySelector(frameSel); const out = {};
    for (const e of [frame, ...frame.querySelectorAll('[data-dc-tpl]')]) {
      const t = e.getAttribute('data-dc-tpl'); if (!ids[t]) continue; const cs = getComputedStyle(e); const o = {};
      for (const p of PROPS) o[p] = cs[p];
      out[ids[t]] = o;
    }
    return out;
  }, { ids, frameSel: CFG.frame, PROPS });
  // fontes reais por elemento (CDP)
  const cdp = await page.context().newCDPSession(page);
  await cdp.send('DOM.enable'); await cdp.send('CSS.enable');
  const { root } = await cdp.send('DOM.getDocument', { depth: -1, pierce: true });
  const plataforma = {};
  for (const [t, id] of Object.entries(ids)) {
    const { nodeId } = await cdp.send('DOM.querySelector', { nodeId: root.nodeId, selector: `[data-dc-tpl="${t}"]` });
    if (!nodeId) continue;
    const { fonts } = await cdp.send('CSS.getPlatformFontsForNode', { nodeId });
    if (fonts && fonts.length) plataforma[id] = fonts.map(f => ({ family: f.familyName, postScript: f.postScriptName, custom: f.isCustomFont, glyphs: f.glyphCount }));
  }
  await cdp.detach();
  return { styles, plataforma };
}

(async () => {
  const sel = pranchas(process.argv[2]);
  const browser = await lancar();
  for (const p of sel) {
    const im = lerIdmap(p); if (!im) throw new Error(`sem idmap para ${p.slug} (rode idmaps_spec.py)`);
    const ids = im.ids;
    let { page, erros } = await abrir(browser, p, { zoom: Z, viewportH: 1000 });
    const A = await passoA(page, ids);
    const B = await passoB(page, ids);
    await page.close();
    ({ page } = await abrir(browser, p, { zoom: Z, viewportH: 1000 }));
    const C = await passoC(page, ids);
    await page.close();
    const faltando = Object.values(ids).filter(id => !A.elems[id]);
    const out = { prancha: p.slug, prefixo: p.prefixo, canvas: p.canvas, zoom: Z, ...A, vis: B, ...C, faltando, errosJs: erros };
    const dir = tmpDir('medicao', p.slug);
    fs.writeFileSync(path.join(dir, 'medida.json'), JSON.stringify(out, null, 1) + '\n');
    const fallback = Object.entries(C.plataforma).filter(([, fs]) => fs.some(f => !f.custom)).map(([k, fs]) => `${k}:${fs.filter(f => !f.custom).map(f => f.family + '×' + f.glyphs).join('+')}`);
    console.log(`${p.slug.padEnd(24)} frame=${A.frame.w}×${A.frame.h} ids=${Object.keys(A.elems).length}/${Object.keys(ids).length} linhas=${Object.keys(A.lines).length} linhasCompostas=${Object.keys(A.linesAll).length} métricas=${Object.keys(A.fontMetrics).length} fallback=${fallback.length ? fallback.join(' ') : '—'}`);
  }
  await browser.close();
})();
