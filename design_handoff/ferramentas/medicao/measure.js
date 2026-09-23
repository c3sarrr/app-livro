const { chromium } = require('playwright');
const fs = require('fs');
const Z = parseFloat(process.argv[2] || '10');
(async () => {
  const idmap = JSON.parse(fs.readFileSync('idmap.json'));
  const browser = await chromium.launch({args:['--font-render-hinting=none']});
  const page = await browser.newPage({ viewport: { width: Math.round(390*Z), height: 1000 }, deviceScaleFactor: 1 });
  await page.goto('file://' + process.cwd() + '/original.html');
  await page.waitForTimeout(3500);
  const data = await page.evaluate(async ({Z, idmap}) => {
    await document.fonts.ready;
    document.body.style.zoom = Z; document.body.style.display = 'block'; document.body.style.margin = '0';
    await new Promise(r => setTimeout(r, 300));
    const frame = document.querySelector('main').parentElement;
    const fr = frame.getBoundingClientRect();
    const all = [frame, ...frame.querySelectorAll('*')];
    const saved = all.map(e => e.style ? e.style.transform : '');
    all.forEach(e => { if (e.style && e.style.transform) e.style.transform = 'none'; });
    const R = (r) => ({ x: +((r.x - fr.x)/Z).toFixed(3), y: +((r.y - fr.y)/Z).toFixed(3), w: +(r.width/Z).toFixed(3), h: +(r.height/Z).toFixed(3) });
    const elems = {};
    all.forEach((e, i) => {
      const tpl = e.getAttribute('data-dc-tpl'); const id = idmap[tpl]; if (!id) return;
      const cs = getComputedStyle(e);
      const direct = [...e.childNodes].filter(n => n.nodeType === 3).map(n => n.textContent.replace(/\s+/g,' ').trim()).filter(Boolean).join(' ');
      elems[id] = { tpl: +tpl, tag: e.tagName.toLowerCase(), ...R(e.getBoundingClientRect()), text: direct, aria: e.getAttribute('aria-label') || undefined,
        font: { family: cs.fontFamily.split(',')[0].replace(/['"]/g,''), size: cs.fontSize, weight: cs.fontWeight, style: cs.fontStyle, lineHeight: cs.lineHeight, letterSpacing: cs.letterSpacing, color: cs.color },
        transform: saved[i] || undefined };
    });
    // text lines
    const lines = {};
    for (const e of all) {
      const tpl = e.getAttribute('data-dc-tpl'); const id = idmap[tpl]; if (!id) continue;
      const tn = [...e.childNodes].filter(n => n.nodeType === 3 && n.textContent.trim());
      if (!tn.length) continue;
      const L = [];
      for (const n of tn) {
        const s = n.textContent;
        for (let k = 0; k < s.length; k++) {
          const rg = document.createRange(); rg.setStart(n, k); rg.setEnd(n, k+1);
          const rs = [...rg.getClientRects()]; if (!rs.length) continue;
          const r = rs[0]; const top = +((r.y - fr.y)/Z).toFixed(2);
          let line = L.find(l => Math.abs(l.top - top) < 0.5);
          if (!line) { line = { top, bottom: +((r.bottom - fr.y)/Z).toFixed(2), left: +((r.x - fr.x)/Z).toFixed(2), right: +((r.right - fr.x)/Z).toFixed(2), text: '' }; L.push(line); }
          line.text += s[k]; line.left = Math.min(line.left, +((r.x - fr.x)/Z).toFixed(2)); line.right = Math.max(line.right, +((r.right - fr.x)/Z).toFixed(2));
        }
      }
      L.forEach(l => l.text = l.text.replace(/\s+/g, ' ').trim());
      lines[id] = L.filter(l => l.text);
    }
    // natural widths for text-bearing elements (max-content)
    const natural = {};
    for (const e of all) {
      const tpl = e.getAttribute('data-dc-tpl'); const id = idmap[tpl]; if (!id) continue;
      if (!e.textContent.trim()) continue;
      if (['frame','main','header','hero','alsoReading','today','forYou','club','recent','nav'].includes(id)) continue;
      const c = e.cloneNode(true); c.style.position = 'absolute'; c.style.left = '0'; c.style.top = '0'; c.style.width = 'max-content'; c.style.maxWidth = 'none'; c.style.minWidth = '0'; c.style.flexGrow = '0'; c.style.whiteSpace = 'nowrap'; c.style.transform='none';
      e.parentElement.appendChild(c); const w = c.getBoundingClientRect().width / Z; 
      c.style.whiteSpace = ''; c.style.width = 'min-content'; const mw = c.getBoundingClientRect().width / Z;
      c.remove();
      natural[id] = { maxContent: +w.toFixed(3), minContent: +mw.toFixed(3) };
    }
    all.forEach((e, i) => { if (e.style && saved[i]) e.style.transform = saved[i]; });
    return { zoom: Z, frame: { w: fr.width / Z, h: fr.height / Z }, elems, lines, natural };
  }, {Z, idmap});
  fs.writeFileSync(`layout_z${Z}.json`, JSON.stringify(data, null, 1));
  console.log('elements', Object.keys(data.elems).length, 'text elements', Object.keys(data.lines).length, 'frame', JSON.stringify(data.frame));
  await browser.close();
})();
