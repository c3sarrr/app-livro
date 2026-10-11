// Critério eliminatório 2: virar Pro sobe TUDO (10 mil linhas), mesmo com modo avião no meio do
// upload; o 2º aparelho baixa tudo; aparelho e servidor ficam idênticos.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { aguardar, espera } from '../lib/aparelho.mjs';
import { gerarAcervo, gravarAcervo } from '../lib/dados.mjs';
import { total } from '../lib/servidor.mjs';
import { ambiente, aparelho, diferencas, digitalAparelho, digitalServidor, filaVazia, registrar } from './_comum.mjs';

test('virar Pro: enfileira tudo e sobe 10 mil linhas com modo avião no meio', async () => {
  const A = await ambiente();
  const uid = await A.servidor.novoUsuario();
  const a = await aparelho(A, 'a', uid);
  await gravarAcervo(a.db, gerarAcervo({ uid, hlc: a.hlc }));
  assert.equal(await a.filaCrud(), 0);

  await A.servidor.darPro(uid);
  assert.equal(await a.podeConectar(), true, 'o servidor confirma o Pro antes de conectar');
  const t0 = Date.now();
  await a.virarPro({ conectar: false });
  assert.equal(await a.filaCrud(), 10000, 'cópia entrou na fila como PUT');
  if (a.modo === 'views') assert.equal(total(await a.contar('inativa_local_')), 0);
  assert.equal(total(await a.contar()), 10000, 'o app continua vendo as mesmas 10 mil linhas');
  await a.conectar();
  // modo avião no meio do upload
  await aguardar(() => a.ev.lotes >= 3, { msg: '3 lotes enviados' });
  a.modoAviao(true);
  const lotesNoCorte = a.ev.lotes;
  // escrevendo offline enquanto isso
  const extra = gerarAcervo({ uid, hlc: a.hlc, total: 0 }).bookmarks.slice(0, 50);
  for (const b of extra) b.user_book_id = (await a.db.get('select id from user_books limit 1')).id;
  await gravarAcervo(a.db, { bookmarks: extra });
  await espera(1500);
  assert.equal(a.ev.lotes, lotesNoCorte, 'nada sobe em modo avião');
  a.modoAviao(false);
  await filaVazia(a);
  const uploadMs = Date.now() - t0;
  const noServidor = await A.servidor.contar(uid);
  assert.equal(total(noServidor), 10050);
  assert.equal(a.ev.recusadas, 0);
  assert.ok(a.ev.errosRede >= 0);
  await aguardar(async () => diferencas(await digitalAparelho(a), await digitalServidor(A.servidor, uid)) === 0, { msg: 'A = servidor' });

  // 2º aparelho: entra com a conta (já Pro) e baixa tudo
  const b = await aparelho(A, 'b', uid, { pro: true });
  const t1 = Date.now();
  await b.conectar();
  await aguardar(async () => total(await b.contar()) === 10050, { ms: 120000, msg: 'B baixou tudo' });
  const downloadMs = Date.now() - t1;
  assert.equal(diferencas(await digitalAparelho(b), await digitalServidor(A.servidor, uid)), 0);
  // a tabela particionada chegou inteira (sessões de várias partições)
  const parts = await A.servidor.q(
    `select tableoid::regclass::text p, count(*)::int n from personal.reading_sessions where user_id = $1 group by 1 order by 1`, [uid]);
  assert.ok(parts.length >= 10, 'sessões em ≥ 10 partições');
  assert.equal((await b.db.get('select count(*) n from reading_sessions')).n, noServidor.reading_sessions);

  const cheios = A.api.metricas.lotesMs.filter((l) => l.n === 500).map((l) => l.ms).sort((x, y) => x - y);
  const pct = (q) => Number(cheios[Math.min(cheios.length - 1, Math.round((cheios.length - 1) * q))].toFixed(1));
  registrar('02_virar_pro', {
    modo: a.modo,
    rpc_lote_500_ms: { n: cheios.length, p50: pct(0.5), p95: pct(0.95), max: pct(1) },
    linhas: 10050,
    lotes: a.ev.lotes,
    upload_ms_com_corte: uploadMs,
    lotes_antes_do_corte: lotesNoCorte,
    erros_de_rede_no_corte: a.ev.errosRede,
    download_2o_aparelho_ms: downloadMs,
    download_2o_aparelho_bytes: b.proxySync.bytesRecebidos,
    upload_bytes_rpc: a.proxyApi.bytesEnviados,
    particoes_de_sessoes: parts.length,
    diferencas_aparelho_servidor: 0,
  });
  await a.fechar();
  await b.fechar();
  await A.fechar();
});
