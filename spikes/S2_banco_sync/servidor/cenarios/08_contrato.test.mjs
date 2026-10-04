// Teste de contrato (Anexo 02 §3.2): colunas do esquema local = colunas de personal.* no Postgres.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { COLUNAS } from '../lib/esquema.mjs';
import { ambiente, registrar } from './_comum.mjs';

const esperado = (tipoPg) =>
  ['integer', 'smallint', 'bigint', 'boolean'].includes(tipoPg) ? 'INTEGER' : 'TEXT';

test('contrato de colunas aparelho × servidor', async () => {
  const A = await ambiente();
  const linhas = await A.servidor.q(
    `select table_name t, column_name c, data_type d from information_schema.columns
      where table_schema = 'personal' and table_name = any($1) and column_name <> 'id' order by 1, ordinal_position`,
    [Object.keys(COLUNAS)],
  );
  const servidor = {};
  for (const l of linhas) (servidor[l.t] ??= {})[l.c] = l.d;
  let colunas = 0;
  for (const [t, cols] of Object.entries(COLUNAS)) {
    assert.deepEqual(Object.keys(cols).sort(), Object.keys(servidor[t]).sort(), `colunas de ${t}`);
    for (const [c, def] of Object.entries(cols)) {
      assert.equal(def.type, esperado(servidor[t][c]), `${t}.${c} (${servidor[t][c]})`);
      colunas++;
    }
  }
  registrar('08_contrato', { tabelas: Object.keys(COLUNAS).length, colunas });
  await A.fechar();
});
