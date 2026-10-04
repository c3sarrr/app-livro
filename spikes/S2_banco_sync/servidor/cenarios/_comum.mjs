// G02 · S2 — utilidades dos cenários: ambiente, aparelhos, comparação aparelho × servidor e o
// arquivo de resultados (dados/resultado_s2.json, uma seção por cenário).
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { prepararAmbiente } from '../lib/ambiente.mjs';
import { Aparelho, aguardar } from '../lib/aparelho.mjs';
import { TABELAS } from '../lib/esquema.mjs';

const RESULTADO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../dados/resultado_s2.json');

export function registrar(secao, dados) {
  fs.mkdirSync(path.dirname(RESULTADO), { recursive: true });
  const atual = fs.existsSync(RESULTADO) ? JSON.parse(fs.readFileSync(RESULTADO, 'utf8')) : {};
  atual[secao] = dados;
  fs.writeFileSync(RESULTADO, JSON.stringify(atual, null, 1) + '\n');
}

export async function ambiente(opcoes) {
  return prepararAmbiente(opcoes);
}

export async function aparelho(A, nome, uid, { pro = false, defasagemMs = 0, porteiro = true, modo } = {}) {
  return new Aparelho({ nome, uid, dir: A.dir, ambiente: A.ambiente, defasagemMs, porteiro, ...(modo ? { modo } : {}) }).abrir({ pro });
}

export async function filaVazia(ap, ms = 180000) {
  await aguardar(async () => (await ap.filaCrud()) === 0, { ms, msg: `fila de ${ap.nome} vazia` });
}

/** Impressão digital (id → version_hlc|deleted_at) de todas as tabelas, no aparelho ou no servidor. */
export async function digitalAparelho(ap) {
  const d = {};
  for (const t of TABELAS) {
    for (const r of await ap.db.getAll(`select id, version_hlc, deleted_at from ${t}`)) {
      d[`${t}/${r.id}`] = `${r.version_hlc}|${r.deleted_at ? 'X' : ''}`;
    }
  }
  return d;
}

export async function digitalServidor(servidor, uid) {
  const d = {};
  for (const t of TABELAS) {
    for (const r of await servidor.q(`select id, version_hlc, deleted_at from personal.${t} where user_id = $1`, [uid])) {
      d[`${t}/${r.id}`] = `${r.version_hlc}|${r.deleted_at ? 'X' : ''}`;
    }
  }
  return d;
}

export function diferencas(a, b) {
  const chaves = new Set([...Object.keys(a), ...Object.keys(b)]);
  let n = 0;
  for (const k of chaves) if (a[k] !== b[k]) n++;
  return n;
}
