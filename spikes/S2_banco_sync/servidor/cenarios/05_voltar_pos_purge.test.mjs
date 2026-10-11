// Critério eliminatório 4: voltar a ser Pro depois do purge (12 meses) repovoa a nuvem a partir do
// aparelho — inclusive as exclusões lógicas —, com modo avião no meio; e voltar ANTES do purge
// reconcilia pelo LWW (o que não mudou é ignorado; o que mudou no Grátis vence).
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { aguardar } from '../lib/aparelho.mjs';
import { gerarAcervo, gravarAcervo } from '../lib/dados.mjs';
import { total } from '../lib/servidor.mjs';
import { ambiente, aparelho, diferencas, digitalAparelho, digitalServidor, filaVazia, registrar } from './_comum.mjs';

async function exPro(A, nome) {
  const uid = await A.servidor.novoUsuario();
  await A.servidor.darPro(uid);
  const a = await aparelho(A, nome, uid, { pro: true });
  await gravarAcervo(a.db, gerarAcervo({ uid, hlc: a.hlc }));
  await a.conectar();
  await filaVazia(a);
  await a.perderPro();
  await A.servidor.tirarPro(uid);
  await A.servidor.passarSeteDias(uid);
  // uso no Grátis: edições e exclusões lógicas (só no aparelho)
  const agora = new Date().toISOString();
  await a.db.execute("update annotations set note_text = 'editada no Grátis', updated_at = ?, version_hlc = ? where kind = 'note' and substr(id, 1, 1) in ('0','1','2')", [agora, a.hlc.enviar()]);
  await a.db.execute("update bookmarks set deleted_at = ?, updated_at = ?, version_hlc = ? where substr(id, 1, 1) in ('0','1')", [agora, agora, a.hlc.enviar()]);
  assert.equal(await a.filaCrud(), 0, 'Grátis não enfileira');
  return { uid, a };
}

test('voltar ao Pro depois do purge repovoa a nuvem (com modo avião) e antes do purge reconcilia', async () => {
  const A = await ambiente();
  const r = {};

  // Depois do purge: a nuvem está vazia
  {
    const { uid, a } = await exPro(A, 'pospurge');
    await A.servidor.purgar(uid);
    assert.equal(total(await A.servidor.contar(uid)), 0);
    const tombstones = (await a.db.get('select count(*) n from bookmarks where deleted_at is not null')).n;
    await A.servidor.darPro(uid);
    assert.equal(await a.podeConectar(), true);
    const t0 = Date.now();
    await a.virarPro({ conectar: false });
    assert.equal(await a.filaCrud(), 10000, 'todas as linhas (inclusive exclusões lógicas) como PUT');
    await a.conectar();
    await aguardar(() => a.ev.lotes >= 5, { msg: '5 lotes' });
    a.modoAviao(true);
    await new Promise((s) => setTimeout(s, 1000));
    a.modoAviao(false);
    await filaVazia(a);
    const ms = Date.now() - t0;
    assert.equal(total(await A.servidor.contar(uid)), 10000);
    await aguardar(async () => diferencas(await digitalAparelho(a), await digitalServidor(A.servidor, uid)) === 0, { msg: 'nuvem = aparelho' });
    const tombNuvem = Number((await A.servidor.q('select count(*) n from personal.bookmarks where user_id = $1 and deleted_at is not null', [uid]))[0].n);
    assert.equal(tombNuvem, tombstones);
    // aparelho novo baixa exatamente o que o antigo tinha
    const b = await aparelho(A, 'pospurge_b', uid, { pro: true });
    await b.conectar();
    await aguardar(async () => total(await b.contar()) === 10000, { msg: 'B baixou' });
    assert.equal(diferencas(await digitalAparelho(b), await digitalAparelho(a)), 0);
    r.depois_do_purge = { linhas: 10000, exclusoes_logicas_repovoadas: tombNuvem, upload_ms_com_corte: ms, erros_de_rede: a.ev.errosRede, diferencas_novo_aparelho: 0 };
    await a.fechar();
    await b.fechar();
  }

  // Antes do purge (dentro dos 12 meses): a nuvem ainda tem a versão antiga de tudo
  {
    const { uid, a } = await exPro(A, 'prepurge');
    const editadas = (await a.db.get("select count(*) n from annotations where note_text = 'editada no Grátis'")).n;
    const apagadas = (await a.db.get('select count(*) n from bookmarks where deleted_at is not null')).n;
    await A.servidor.darPro(uid);
    await a.virarPro();
    await filaVazia(a);
    assert.equal(a.ev.aplicadas - 10000, editadas + apagadas, 'só o que mudou no Grátis foi aplicado');
    assert.equal(a.ev.ignoradas, 10000 - editadas - apagadas, 'o resto o LWW ignorou (mesmo HLC)');
    await aguardar(async () => diferencas(await digitalAparelho(a), await digitalServidor(A.servidor, uid)) === 0, { msg: 'nuvem = aparelho' });
    r.antes_do_purge = { aplicadas_na_volta: editadas + apagadas, ignoradas_pelo_lww: a.ev.ignoradas };
    await a.fechar();
  }

  registrar('05_voltar_pos_purge', r);
  await A.fechar();
});
