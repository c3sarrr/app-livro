// Critério eliminatório 1 (Anexo 02 §3.1): o Grátis escreve sem alimentar a fila de upload (tabelas
// próprias com gatilhos desligados; ou localOnly no padrão de views) —
// a fila (ps_crud) não cresce, nada sai pela rede e os dados sobrevivem a fechar/abrir o banco.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { gerarAcervo, gravarAcervo } from '../lib/dados.mjs';
import { total } from '../lib/servidor.mjs';
import { ambiente, aparelho, registrar } from './_comum.mjs';

test('Grátis: 10 mil linhas, fila de upload zero, zero rede', async () => {
  const A = await ambiente();
  const uid = await A.servidor.novoUsuario();
  let a = await aparelho(A, 'gratis', uid);
  const acervo = gerarAcervo({ uid, hlc: a.hlc });
  // "vários dias" de uso: 20 transações de ~500 linhas, com a rede ligada o tempo todo
  const t0 = Date.now();
  const entradas = Object.entries(acervo).flatMap(([t, ls]) => ls.map((l) => [t, l]));
  for (let i = 0; i < entradas.length; i += 500) {
    const fatia = {};
    for (const [t, l] of entradas.slice(i, i + 500)) (fatia[t] ??= []).push(l);
    await gravarAcervo(a.db, fatia);
    assert.equal(await a.filaCrud(), 0, `fila depois do lote ${i / 500}`);
  }
  const gravacaoMs = Date.now() - t0;
  // atualizações e exclusões lógicas também não entram na fila
  await a.db.execute("update annotations set note_text = 'editada', version_hlc = ? where kind = 'note'", [a.hlc.enviar()]);
  await a.db.execute("update bookmarks set deleted_at = ?, version_hlc = ? where substr(id, 1, 1) in ('0', '1')", [new Date().toISOString(), a.hlc.enviar()]);
  const contagem = await a.contar();
  assert.equal(total(contagem), 10000);
  assert.equal(await a.filaCrud(), 0);
  assert.equal(a.conexoesDeRede, 0, 'o aparelho Grátis não abriu nenhuma conexão');
  assert.equal(total(await A.servidor.contar(uid)), 0, 'nada no servidor');
  // fecha e reabre: os dados continuam (são a única cópia)
  await a.fechar();
  a = await aparelho(A, 'gratis', uid);
  assert.equal(total(await a.contar()), 10000);
  const tamanho = (await a.db.get('select page_count * page_size as b from pragma_page_count(), pragma_page_size()')).b;
  registrar('01_gratis_localonly', {
    modo: a.modo,
    linhas: 10000,
    transacoes: Math.ceil(entradas.length / 500),
    gravacao_ms: gravacaoMs,
    fila_ps_crud: 0,
    conexoes_de_rede: a.conexoesDeRede,
    linhas_no_servidor: 0,
    banco_local_bytes: tamanho,
  });
  await a.fechar();
  await A.fechar();
});
