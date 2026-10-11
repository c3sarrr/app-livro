// Critério eliminatório 3: perder o Pro NÃO apaga nada do aparelho — expiração prevista, reembolso
// detectado já conectado e reembolso enquanto o aparelho estava em modo avião. Controle negativo:
// sem o "porteiro" no conector, o SDK reconecta sozinho e o PowerSync apaga as linhas do aparelho.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { aguardar, espera } from '../lib/aparelho.mjs';
import { gerarAcervo, gravarAcervo } from '../lib/dados.mjs';
import { total } from '../lib/servidor.mjs';
import { ambiente, aparelho, filaVazia, registrar } from './_comum.mjs';

async function proSincronizado(A, nome, opcoes = {}) {
  const uid = await A.servidor.novoUsuario();
  await A.servidor.darPro(uid);
  const a = await aparelho(A, nome, uid, { pro: true, ...opcoes });
  await gravarAcervo(a.db, gerarAcervo({ uid, hlc: a.hlc }));
  await a.conectar();
  await filaVazia(a);
  assert.equal(total(await A.servidor.contar(uid)), 10000);
  return { uid, a };
}

async function marcadoresOffline(a, n) {
  const livro = (await a.db.get('select id from user_books limit 1')).id;
  const ls = gerarAcervo({ uid: a.uid, hlc: a.hlc, total: 0 }).bookmarks.slice(0, n);
  for (const b of ls) b.user_book_id = livro;
  await gravarAcervo(a.db, { bookmarks: ls });
}

test('perder o Pro não apaga nada local (4 caminhos + controle negativo)', async () => {
  const A = await ambiente();
  const r = {};

  // (a) Expiração prevista, com o aparelho em modo avião e 20 escritas ainda na fila
  {
    const { uid, a } = await proSincronizado(A, 'exp');
    a.modoAviao(true);
    await marcadoresOffline(a, 20);
    assert.equal(await a.filaCrud(), 20);
    await a.perderPro(); // o app sabe a data de expiração (RevenueCat) e age antes dela
    assert.equal(total(await a.contar()), 10020);
    assert.equal(await a.filaCrud(), 0);
    await A.servidor.tirarPro(uid);
    await A.servidor.passarSeteDias(uid);
    assert.equal(await A.servidor.bucketConcedido(uid), false);
    a.modoAviao(false);
    assert.equal(await a.podeConectar(), false, 'o servidor diz que não é mais Pro');
    const syncAntes = a.proxySync.conexoes;
    await espera(1500);
    assert.equal(total(await a.contar()), 10020, 'nada apagado');
    assert.equal(a.proxySync.conexoes, syncAntes, 'nenhuma conexão de sync depois de perder o Pro');
    r.expiracao_prevista = { modo: a.modo, local_depois: 10020, escritas_offline_preservadas: 20, nuvem: total(await A.servidor.contar(uid)) };
    await a.fechar();
  }

  // (b) Reembolso detectado já conectado: upload barrado na hora (pro_required); bucket ainda vale 7 dias
  {
    const { uid, a } = await proSincronizado(A, 'reemb');
    let avisado = 0;
    a.aoPerderPro = () => avisado++;
    await A.servidor.tirarPro(uid);
    assert.equal(await A.servidor.bucketConcedido(uid), true, 'bucket mantido por 7 dias');
    await marcadoresOffline(a, 5); // escrita depois do reembolso (ainda conectado)
    await aguardar(() => a.ev.proRequired > 0, { msg: 'upload recusado com pro_required' });
    assert.ok(avisado > 0, 'o conector avisou o app');
    await a.perderPro(); // reação do app (RevenueCat listener ou pro_required)
    assert.equal(total(await a.contar()), 10005, 'inclusive as 5 que não subiram');
    await A.servidor.passarSeteDias(uid);
    await espera(1500);
    assert.equal(total(await a.contar()), 10005);
    r.reembolso_conectado = { modo: a.modo, local_depois: 10005, pro_required: a.ev.proRequired, escritas_nao_enviadas_preservadas: 5 };
    await a.fechar();
  }

  // (c) Reembolso + 7 dias enquanto o aparelho estava em modo avião. Quando a rede volta, o SDK
  //     RECONECTA SOZINHO com o token em cache (o fetchCredentials não é chamado de novo — medido) e
  //     recebe a remoção do bucket. Com tabelas próprias, o `delete` não apaga: nada se perde; o app
  //     descobre na checagem periódica do Pro (ou no pro_required) e sai do modo Pro.
  {
    const { uid, a } = await proSincronizado(A, 'aviao');
    const credAntes = a.ev.credenciais;
    a.modoAviao(true);
    await A.servidor.tirarPro(uid);
    await A.servidor.passarSeteDias(uid); // bucket revogado no servidor
    a.modoAviao(false);
    await aguardar(async () => (await a.remocoesIgnoradas()) >= 10000, { ms: 30000, msg: 'remoção do bucket chegou' });
    assert.equal(total(await a.contar()), 10000, 'nada apagado');
    assert.equal(a.ev.credenciais, credAntes, 'reconectou sem pedir credencial nova (token em cache)');
    assert.equal(await a.podeConectar(), false);
    await a.perderPro();
    assert.equal(total(await a.contar()), 10000);
    r.reembolso_em_modo_aviao = {
      modo: a.modo,
      local_depois: 10000,
      remocoes_do_bucket_neutralizadas: await a.remocoesIgnoradas(),
      reconectou_com_token_em_cache: true,
    };
    await a.fechar();
  }

  // (d) PIOR CASO com tabelas próprias: sem porteiro e sem o app reagir, conectado quando o bucket some
  {
    const { uid, a } = await proSincronizado(A, 'bruto_sem_porteiro', { porteiro: false });
    await A.servidor.tirarPro(uid);
    await A.servidor.passarSeteDias(uid);
    await aguardar(async () => (await a.remocoesIgnoradas()) >= 10000, { ms: 30000, msg: 'remoção do bucket chegou' });
    assert.equal(total(await a.contar()), 10000, 'tabelas próprias: o delete do PowerSync não apaga');
    r.pior_caso_tabelas_proprias = { local_antes: 10000, local_depois: total(await a.contar()), remocoes_neutralizadas: await a.remocoesIgnoradas() };
    await a.fechar();
  }

  // (e) CONTROLE NEGATIVO — padrão de views do Anexo 02 §3.1 (localOnly ↔ synced), mesmo caminho (c):
  //     o SDK reconecta com o token em cache e o PowerSync apaga as linhas do aparelho.
  {
    const { uid, a } = await proSincronizado(A, 'views_c', { modo: 'views' });
    a.modoAviao(true);
    await A.servidor.tirarPro(uid);
    await A.servidor.passarSeteDias(uid);
    a.modoAviao(false);
    await aguardar(async () => total(await a.contar()) < 10000, { ms: 30000, msg: 'PowerSync apagando as linhas' }).catch(() => {});
    const sobrou = total(await a.contar());
    r.controle_negativo_views = { modo: 'views', local_antes: 10000, local_depois: sobrou, porteiro_chamado: a.ev.porteiroBarrou > 0 };
    assert.equal(sobrou, 0, 'com views, o aparelho perde tudo mesmo com o porteiro — risco que reprova o padrão');
    await a.fechar();
  }

  registrar('04_perder_pro', r);
  await A.fechar();
});
