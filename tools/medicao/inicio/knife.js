const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.launch({args:['--font-render-hinting=none']});
  const page = await browser.newPage({ viewport: { width: 3900, height: 1000 }, deviceScaleFactor: 1 });
  await page.goto('file://' + process.cwd() + '/original.html');
  await page.waitForTimeout(3500);
  const out = await page.evaluate(async () => {
    await document.fonts.ready; const Z = 10; document.body.style.zoom = Z; document.body.style.display='block';
    await new Promise(r => setTimeout(r, 300));
    const frame = document.querySelector('main').parentElement;
    frame.querySelectorAll('*').forEach(e => { if (e.style && e.style.transform) e.style.transform = 'none'; });
    const res = [];
    const measure = (el, text) => { const s = document.createElement('span'); const cs = getComputedStyle(el); s.style.cssText = `position:absolute;white-space:nowrap;font-family:${cs.fontFamily};font-size:${cs.fontSize};font-weight:${cs.fontWeight};font-style:${cs.fontStyle};letter-spacing:${cs.letterSpacing};`; s.textContent = text; el.appendChild(s); const w = s.getBoundingClientRect().width / Z; s.remove(); return w; };
    // candidates: elements with text that wraps or could wrap
    const cands = [...frame.querySelectorAll('*')].filter(e => [...e.childNodes].some(n => n.nodeType===3 && n.textContent.trim()));
    for (const e of cands) {
      const cs = getComputedStyle(e);
      const contentW = (e.getBoundingClientRect().width / Z) - parseFloat(cs.paddingLeft) - parseFloat(cs.paddingRight) - parseFloat(cs.borderLeftWidth) - parseFloat(cs.borderRightWidth);
      // collect text only (ignoring nested elements if any)
      if (e.children.length && ![...e.children].every(c => c.tagName==='BR')) continue;
      const parts = []; let cur = '';
      e.childNodes.forEach(n => { if (n.nodeType===3) cur += n.textContent; else if (n.tagName==='BR') { parts.push(cur); cur=''; } });
      parts.push(cur);
      for (const p of parts) {
        const words = p.replace(/\s+/g,' ').trim().split(' ').filter(Boolean); if (!words.length) continue;
        // greedy wrap
        let lines = []; let line = words[0];
        for (let i = 1; i < words.length; i++) { const t = line + ' ' + words[i]; if (measure(e, t) <= contentW + 0.001) line = t; else { lines.push(line); line = words[i]; } }
        lines.push(line);
        // margins
        const info = lines.map((l, i) => { const w = measure(e, l); const next = lines[i+1] ? l + ' ' + lines[i+1].split(' ')[0] : null; const wn = next ? measure(e, next) : null; return { l, w: +w.toFixed(3), slack: +(contentW - w).toFixed(3), overflowIfNextWordJoined: wn ? +(wn - contentW).toFixed(3) : null }; });
        res.push({ tpl: e.getAttribute('data-dc-tpl'), contentW: +contentW.toFixed(3), ws: cs.whiteSpace, tw: cs.textWrap || cs.textWrapMode, info });
      }
    }
    return res;
  });
  for (const r of out) {
    const risky = r.info.some(i => (i.slack < 1.5 && r.ws !== 'nowrap') || (i.overflowIfNextWordJoined !== null && i.overflowIfNextWordJoined < 1.5));
    console.log(`t${r.tpl} cw=${r.contentW} ws=${r.ws} ${risky ? '*** RISK ***' : ''}`);
    for (const i of r.info) console.log(`     "${i.l}" w=${i.w} slack=${i.slack}${i.overflowIfNextWordJoined!==null ? ' joinNextOverflow='+i.overflowIfNextWordJoined : ''}`);
  }
  await browser.close();
})();
