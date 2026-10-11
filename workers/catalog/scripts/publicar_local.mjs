// Publica a saída do pipeline (tools/catalog) no R2 LOCAL do Worker (D-75: nada na nuvem na G07).
// Uso: node scripts/publicar_local.mjs <pasta "publicar" do pipeline>
// O `wrangler dev --persist-to .wrangler/state` enxerga os mesmos objetos.
import { readdir, readFile } from 'node:fs/promises';
import { join, relative, sep } from 'node:path';
import { getPlatformProxy } from 'wrangler';
import { emParalelo } from './em_paralelo.mjs';

const origem = process.argv[2];
if (!origem) {
  console.error('uso: node scripts/publicar_local.mjs <pasta publicar>');
  process.exit(2);
}

async function* arquivos(pasta) {
  for (const e of await readdir(pasta, { withFileTypes: true })) {
    const p = join(pasta, e.name);
    if (e.isDirectory()) yield* arquivos(p);
    else if (e.isFile() && !e.name.endsWith('.db')) yield p; // o .db descomprimido fica só no PC
  }
}

const { env, dispose } = await getPlatformProxy({ configPath: 'wrangler.jsonc', persist: { path: '.wrangler/state/v3' } });
// vários envios ao mesmo tempo: com dezenas de milhares de shards (dados reais: ~50 mil), um por vez levava mais
// de uma hora lendo a pasta do WSL pela rede do Windows. Qualquer falha interrompe ANTES dos manifestos.
const CONCORRENCIA = 16;
let n = 0;
let bytes = 0;
const inicio = Date.now();
// manifestos por último: o app só vê a versão nova quando tudo já está lá
const adiados = [];
async function* paraEnviar() {
  for await (const p of arquivos(origem)) {
    const chave = relative(origem, p).split(sep).join('/');
    if (chave === 'catalog/v1/manifest.json' || chave === 'isbn/v1/index.json') adiados.push([chave, p]);
    else yield [chave, p];
  }
}
try {
  await emParalelo(paraEnviar(), CONCORRENCIA, async ([chave, p]) => {
    const dados = await readFile(p);
    await env.CATALOGO.put(chave, dados);
    bytes += dados.length;
    if (++n % 2000 === 0) console.log(`${n} objetos…`);
  });
  for (const [chave, p] of adiados) {
    await env.CATALOGO.put(chave, await readFile(p));
    n++;
  }
} catch (e) {
  console.error(`falhou depois de ${n} objetos; os manifestos NÃO foram publicados:`, e);
  await dispose();
  process.exit(1);
}
console.log(JSON.stringify({ objetos: n, bytes, segundos: Math.round((Date.now() - inicio) / 1000) }));
await dispose();
