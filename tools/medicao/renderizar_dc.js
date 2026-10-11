// R00 (R00.2) — renderiza uma tela do projeto completo (`docs/design/projeto/telas/*.dc.html`) no Chromium, com o
// `dc-runtime.js` servido como o `./support.js` que os arquivos chamam e as fontes do arquivo antigo embutidas (o
// projeto pede as fontes ao Google Fonts; a rede fica bloqueada). O PNG do quadro (--dsf 1, 2 ou 3) vai para
// `tools/medicao/tmp/r00/dc/`, para o `tools/compare_images.py` contra o PNG medido da prancha (a referência que os
// testes usam). Com --antiga <pasta da extração antiga> (ex.: tools/medicao/pranchas_inicio2/001b_inicio_lendo_agora),
// renderiza também o bundle antigo nas mesmas condições (uma cópia no disco do WSL: o /mnt/c é lento demais para ele)
// e grava o PNG ao lado, para comparar os dois. A medição de verdade dos `.dc.html` é da T13: aqui é só a prova de que
// eles renderizam igual às exportações antigas.
//   MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'node tools/medicao/renderizar_dc.js telas/MainLendo.dc.html --dsf 3'
//   MSYS_NO_PATHCONV=1 wsl bash tools/medicao/wsl.sh 'node tools/medicao/renderizar_dc.js telas/MapaNavegacao.dc.html'
const fs = require('fs');
const os = require('os');
const path = require('path');
const { lancar } = require('./comum');
const { RAIZ } = require('./conjunto');

const PROJETO = path.join(RAIZ, 'docs', 'design', 'projeto');
const FONTES_DE = path.join(RAIZ, 'tools', 'medicao', 'pranchas_inicio2', '001b_inicio_lendo_agora');
const SAIDA = path.join(RAIZ, 'tools', 'medicao', 'tmp', 'r00', 'dc');

function argumento(nome) {
  const i = process.argv.indexOf(nome);
  return i > 0 ? process.argv[i + 1] : null;
}

// O <helmet> antigo (as @font-face com os ids dos assets) com as urls apontando para a pasta assets/ da cópia.
function helmetComFontes() {
  const antigo = fs.readFileSync(path.join(FONTES_DE, 'template.html'), 'utf8');
  const helmet = antigo.slice(antigo.indexOf('<helmet>'), antigo.indexOf('</helmet>') + '</helmet>'.length);
  return helmet.replace(/url\("([0-9a-f-]{36})"\)/g, (_, id) => `url("assets/${id}.woff2")`);
}

// A cópia da tela: o <helmet> trocado pelo das fontes embutidas; support.js = dc-runtime.js; os assets ao lado.
function montar(arquivo) {
  const nome = path.basename(arquivo, '.dc.html');
  const dir = path.join(SAIDA, nome);
  fs.rmSync(dir, { recursive: true, force: true });
  fs.mkdirSync(path.join(dir, 'assets'), { recursive: true });
  const html = fs.readFileSync(path.join(PROJETO, arquivo), 'utf8');
  const i = html.indexOf('<helmet>');
  const j = html.indexOf('</helmet>') + '</helmet>'.length;
  if (i < 0 || j < i) throw new Error(`${arquivo}: sem <helmet>`);
  fs.writeFileSync(path.join(dir, 'index.html'), html.slice(0, i) + helmetComFontes() + html.slice(j));
  fs.copyFileSync(path.join(PROJETO, 'dc-runtime.js'), path.join(dir, 'support.js'));
  for (const f of fs.readdirSync(path.join(FONTES_DE, 'assets'))) {
    if (f.endsWith('.woff2')) fs.copyFileSync(path.join(FONTES_DE, 'assets', f), path.join(dir, 'assets', f));
  }
  return { nome, dir };
}

// O quadro da tela: o primeiro elemento com a largura e a altura do canvas declarados no data-props ($preview).
// A foto é pelo recorte da página (o `elementHandle.screenshot` espera o elemento "parar", e a 01b antiga não para).
async function fotografar(page, el, arquivo) {
  const b = await el.boundingBox();
  await page.screenshot({ path: arquivo, clip: b, animations: 'disabled', fullPage: true });
}

async function quadro(page, w, h) {
  const handle = await page.evaluateHandle(({ w, h }) => {
    for (const el of document.querySelectorAll('body *')) {
      const r = el.getBoundingClientRect();
      if (Math.abs(r.width - w) < 0.5 && Math.abs(r.height - h) < 0.5) return el;
    }
    return null;
  }, { w, h });
  const el = handle.asElement();
  if (!el) throw new Error(`quadro ${w}×${h} não encontrado`);
  return el;
}

(async () => {
  const arquivo = process.argv[2];
  if (!arquivo) throw new Error('uso: renderizar_dc.js telas/<Tela>.dc.html [--dsf 1|2|3]');
  const dsf = +(argumento('--dsf') || 1);
  const props = JSON.parse(
    fs.readFileSync(path.join(PROJETO, arquivo), 'utf8').match(/data-props='([^']*)'/)[1],
  );
  const { width: w, height: h } = props.$preview;
  const { nome, dir } = montar(arquivo);

  const browser = await lancar();
  const page = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: dsf });
  const bloqueadas = [];
  await page.route('**/*', r => {
    const u = r.request().url();
    if (u.startsWith('http')) { bloqueadas.push(u); return r.abort(); }
    return r.continue();
  });
  const erros = [];
  page.on('pageerror', e => erros.push(String(e)));
  await page.goto('file://' + path.join(dir, 'index.html'));
  await page.evaluate(async () => { await document.fonts.ready; document.body.style.margin = '0'; });
  await page.waitForTimeout(600);
  const el = await quadro(page, w, h);
  const png = path.join(SAIDA, `${nome}_${w}x${h}@${dsf}x.png`);
  await fotografar(page, el, png);
  const fontes = await page.evaluate(() => [...document.fonts].filter(f => f.status === 'loaded').length);
  console.log(`${nome}: ${w}×${h} @${dsf}x → ${path.relative(RAIZ, png)} · fontes carregadas: ${fontes} · erros: ${
    erros.length ? erros.join(' | ') : 'nenhum'} · rede bloqueada: ${bloqueadas.length}`);
  if (erros.length) process.exitCode = 1;

  const antiga = argumento('--antiga');
  if (antiga) {
    const tmp = fs.mkdtempSync(path.join(os.tmpdir(), 'r00_antiga_'));
    fs.cpSync(path.join(RAIZ, antiga), tmp, { recursive: true });
    const p2 = await browser.newPage({ viewport: { width: w, height: h }, deviceScaleFactor: dsf });
    await p2.route('**/*', r => (r.request().url().startsWith('http') ? r.abort() : r.continue()));
    const erros2 = [];
    p2.on('pageerror', e => erros2.push(String(e)));
    await p2.goto('file://' + path.join(tmp, 'original.html'), { timeout: 180000 });
    await p2.waitForFunction(() => !!document.querySelector('#dc-root'), null, { timeout: 120000 });
    await p2.evaluate(async () => { await document.fonts.ready; document.body.style.margin = '0'; });
    await p2.waitForTimeout(600);
    const el2 = await quadro(p2, w, h);
    const png2 = path.join(SAIDA, `${nome}_${w}x${h}@${dsf}x_antiga.png`);
    await fotografar(p2, el2, png2);
    console.log(`antiga ${antiga} @${dsf}x → ${path.relative(RAIZ, png2)} · erros: ${erros2.length ? erros2.join(' | ') : 'nenhum'}`);
    fs.rmSync(tmp, { recursive: true, force: true });
  }
  await browser.close();
})().catch(e => { console.error(e); process.exit(2); });
