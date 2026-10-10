// Funções comuns das ferramentas de medição v2 (telas 19–27b; T02: qualquer conjunto de conjuntos.json).
// Requer Playwright 1.56 (Chromium 141) — o mesmo da v1. Rodar a partir da raiz do repositório:
//   NODE_PATH=$(npm root -g) [CONJUNTO=inicio2] node tools/medicao/<script>.js <slug|todas> [opções]
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const { RAIZ, caminho } = require('./conjunto');

const CFG = JSON.parse(fs.readFileSync(caminho('indice'), 'utf8'));
const PRANCHAS_DIR = caminho('extracao');

function pranchas(arg) {
  if (!arg || arg === 'todas') return CFG.pranchas;
  const want = arg.split(',');
  const sel = CFG.pranchas.filter(p => want.includes(p.slug) || want.includes(p.tela));
  if (!sel.length) throw new Error(`prancha desconhecida: ${arg}`);
  return sel;
}

// hinting 'nenhum' (padrão das medições): --font-render-hinting=none, mesmas métricas da v1.
// hinting 'padrao': como as prévias de handoff_v2/referencia/previa (só para a conferência G01.2).
async function lancar({ hinting = 'nenhum' } = {}) {
  return chromium.launch({ args: hinting === 'nenhum' ? ['--font-render-hinting=none'] : [] });
}

// Abre a prancha isolada (bundle aninhado extraído) com a rede bloqueada; espera as fontes;
// aplica zoom Z ao body (técnica da v1: layout em CSS px × Z sem arredondamento de pixel).
async function abrir(browser, p, { zoom = 1, viewportH = null, dsf = 1 } = {}) {
  const [w, h] = p.canvas;
  const page = await browser.newPage({
    viewport: { width: Math.round(w * zoom), height: viewportH || Math.min(Math.round(h * zoom), 4000) },
    deviceScaleFactor: dsf,
  });
  const bloqueadas = [];
  await page.route('**/*', r => {
    const u = r.request().url();
    if (u.startsWith('http')) { bloqueadas.push(u); return r.abort(); }
    return r.continue();
  });
  const erros = [];
  page.on('pageerror', e => erros.push(String(e)));
  await page.goto('file://' + path.join(PRANCHAS_DIR, base(p), 'original.html'));
  await page.waitForFunction(sel => !!document.querySelector(sel), CFG.frame, { timeout: 20000 });
  await page.evaluate(async ({ zoom, largura, frameSel }) => {
    await document.fonts.ready;
    document.body.style.margin = '0';
    document.body.style.display = 'block';
    if (zoom !== 1) document.body.style.zoom = String(zoom);
    // T03: a mesma prancha com outra largura (o quadro tem `width` fixa; o resto é CSS fluido — F13 da v1)
    if (largura) document.querySelector(frameSel).style.width = `${largura}px`;
  }, { zoom, largura: p.largura || 0, frameSel: CFG.frame });
  await page.waitForTimeout(400);
  await page.evaluate(() => document.fonts.ready);
  return { page, bloqueadas, erros };
}

function saidaDir(...partes) {
  const d = path.join(RAIZ, ...partes);
  fs.mkdirSync(d, { recursive: true });
  return d;
}

// Pasta de temporários do conjunto (tools/medicao/tmp no leitor), criada se faltar.
function tmpDir(...partes) {
  const d = caminho('tmp', ...partes);
  fs.mkdirSync(d, { recursive: true });
  return d;
}

// T03: a entrada de uma largura (pranchas_inicio2_larguras.json) usa a extração e o idmap da prancha "base".
function base(p) {
  return p.base || p.slug;
}

function idmap(p) {
  const f = caminho('idmaps', `${base(p)}.json`);
  return fs.existsSync(f) ? JSON.parse(fs.readFileSync(f, 'utf8')) : null;
}

module.exports = { CFG, RAIZ, PRANCHAS_DIR, pranchas, lancar, abrir, saidaDir, tmpDir, idmap, caminho, base };
