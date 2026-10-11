// G02 · S2 — lê o ambiente local gerado por scripts/ambiente.sh e sobe a "API" (PostgREST mínimo).
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { iniciarApi } from './api.mjs';
import { Servidor } from './servidor.mjs';

const PADRAO = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../../_dados/s2_run/ps.env');

export function lerEnv(arquivo = process.env.PS_ENV ?? (process.env.RUN ? path.join(process.env.RUN, 'ps.env') : PADRAO)) {
  const env = {};
  for (const l of fs.readFileSync(arquivo, 'utf8').split('\n')) {
    const m = l.match(/^([A-Z_]+)=(.*)$/);
    if (m) env[m[1]] = m[2];
  }
  return env;
}

export async function prepararAmbiente({ lockTimeoutMs } = {}) {
  const env = lerEnv();
  const api = await iniciarApi({ conexao: env.PS_FONTE_URI, segredoB64: env.PS_JWT_K, lockTimeoutMs });
  const servidor = new Servidor(env.PS_FONTE_URI);
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 's2-'));
  return {
    env,
    api,
    servidor,
    dir,
    ambiente: { portaServico: Number(env.PS_PORTA), portaApi: api.porta, segredoB64: env.PS_JWT_K },
    async fechar() {
      await api.fechar();
      await servidor.fechar();
    },
  };
}
