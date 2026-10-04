// Payloads reais (CrudEntry → RPC sync_apply_changes): jsonb em texto, recusas que não travam a fila,
// erro transitório que derruba o lote inteiro (e é repetido), HLC no futuro, partição fora do intervalo,
// e o formato dos valores na volta (timestamp, numeric, boolean).
import assert from 'node:assert/strict';
import crypto from 'node:crypto';
import pg from 'pg';
import { test } from 'node:test';
import { aguardar } from '../lib/aparelho.mjs';
import { gerarAcervo, gravarAcervo } from '../lib/dados.mjs';
import { ambiente, aparelho, filaVazia, registrar } from './_comum.mjs';

test('payloads reais contra a RPC', async () => {
  const A = await ambiente({ lockTimeoutMs: 500 });
  const r = {};
  const uid = await A.servidor.novoUsuario();
  const outro = await A.servidor.novoUsuario();
  await A.servidor.darPro(uid);
  await A.servidor.darPro(outro);
  const a = await aparelho(A, 'pay', uid, { pro: true });
  const o = await aparelho(A, 'pay_outro', outro, { pro: true });
  const acervo = gerarAcervo({ uid, hlc: a.hlc, total: 6200 });
  await gravarAcervo(a.db, acervo);
  await gravarAcervo(o.db, { user_books: gerarAcervo({ uid: outro, hlc: o.hlc, total: 0 }).user_books.slice(0, 1) });
  await a.conectar();
  await o.conectar();
  await filaVazia(a);
  await filaVazia(o);

  // (a) jsonb que chega como texto vira objeto/array de verdade
  const tipos = await A.servidor.q(
    `select (select jsonb_typeof(locator) from personal.reading_positions where user_id = $1 limit 1) loc,
            (select jsonb_typeof(favorite_colors) from personal.pen_presets where user_id = $1) cores`, [uid]);
  assert.deepEqual(tipos[0], { loc: 'object', cores: 'array' });
  r.jsonb_em_texto = tipos[0];

  // (b) recusa: grifo apontando para o livro de OUTRA pessoa, no meio de 3 linhas válidas
  const livroOutro = (await o.db.get('select id from user_books')).id;
  const livroMeu = (await a.db.get('select id from user_books limit 1')).id;
  const base = acervo.annotations[0];
  const mk = (ub) => ({ ...base, id: crypto.randomUUID(), user_book_id: ub, group_id: crypto.randomUUID(), version_hlc: a.hlc.enviar() });
  const ruim = mk(livroOutro);
  await gravarAcervo(a.db, { annotations: [mk(livroMeu), ruim, mk(livroMeu), mk(livroMeu)] });
  await filaVazia(a);
  const rej = await a.db.getAll('select * from sync_rejections');
  assert.equal(rej.length, 1);
  assert.equal(rej[0].linha_id, ruim.id);
  assert.ok(JSON.parse(rej[0].operacao).data.user_book_id === livroOutro, 'a operação inteira ficou guardada');
  assert.equal(await A.servidor.linha('annotations', ruim.id), undefined);
  assert.ok(await a.db.getOptional('select id from annotations where id = ?', [ruim.id]), 'tabelas próprias: a linha recusada continua no aparelho');
  r.recusa = { codigo: rej[0].codigo, motivo: rej[0].motivo.slice(0, 80), validas_no_mesmo_lote: 3, linha_continua_no_aparelho: true };

  // (c) erro transitório: a linha está travada por outra transação → lock_timeout (55P03) → o lote
  //     inteiro falha (HTTP 500), nada é tirado da fila, o SDK repete e aplica quando a trava sai
  const alvo = acervo.annotations[1].id;
  const trava = new pg.Client({ connectionString: A.env.PS_FONTE_URI });
  await trava.connect();
  await trava.query('begin');
  await trava.query('select id from personal.annotations where id = $1 for update', [alvo]);
  const errosAntes = a.ev.errosServidor;
  await a.db.execute('update annotations set color = ?, updated_at = ?, version_hlc = ? where id = ?', ['#C7B8F5', new Date().toISOString(), a.hlc.enviar(), alvo]);
  await aguardar(() => a.ev.errosServidor > errosAntes, { msg: 'lote falhou com a trava' });
  assert.equal(await a.filaCrud(), 1, 'nada saiu da fila');
  await trava.query('rollback');
  await trava.end();
  await filaVazia(a);
  assert.equal((await A.servidor.linha('annotations', alvo)).color, '#C7B8F5');
  r.erro_transitorio = { tentativas_falhas: a.ev.errosServidor - errosAntes, aplicado_depois: true };

  // (d) HLC no futuro (relógio do aparelho 10 min adiantado) → recusa invalid_hlc
  const adiantado = await aparelho(A, 'adiantado', uid, { pro: true, defasagemMs: 10 * 60000 });
  await adiantado.conectar();
  await aguardar(async () => (await adiantado.db.get('select count(*) n from user_books')).n > 0, { msg: 'adiantado sincronizou' });
  const lv = (await adiantado.db.get('select id from user_books limit 1')).id;
  await adiantado.db.execute('update user_books set title = ?, version_hlc = ? where id = ?', ['futuro', adiantado.hlc.enviar(), lv]);
  await filaVazia(adiantado);
  const rf = await adiantado.db.get("select motivo from sync_rejections where linha_id = ?", [lv]);
  assert.match(rf.motivo, /invalid_hlc/);
  r.hlc_no_futuro = rf.motivo;

  // (e) sessão fora do intervalo das partições (2023) → recusa; sessão de hoje → aceita
  const s = acervo.reading_sessions[0];
  const velha = { ...s, id: crypto.randomUUID(), started_at: '2023-05-01T10:00:00.000Z', ended_at: '2023-05-01T10:10:00.000Z', version_hlc: a.hlc.enviar() };
  const hoje = { ...s, id: crypto.randomUUID(), started_at: new Date(Date.now() - 600000).toISOString(), ended_at: new Date().toISOString(), version_hlc: a.hlc.enviar() };
  await gravarAcervo(a.db, { reading_sessions: [velha, hoje] });
  await filaVazia(a);
  assert.match((await a.db.get('select motivo from sync_rejections where linha_id = ?', [velha.id])).motivo, /started_at_out_of_range/);
  const part = (await A.servidor.q('select tableoid::regclass::text p from personal.reading_sessions where id = $1', [hoje.id]))[0].p;
  r.particoes = { fora_do_intervalo: 'recusada (started_at_out_of_range)', de_hoje: part };

  // (f) formato dos valores na volta (aparelho novo baixando)
  const b = await aparelho(A, 'pay_b', uid, { pro: true });
  await b.conectar();
  await aguardar(async () => (await b.db.get('select count(*) n from annotations')).n >= 4703, { msg: 'B baixou' });
  const orig = acervo.reading_positions[0];
  const pb = await b.db.get('select created_at, progression from reading_positions where id = ?', [orig.id]);
  const pen = await b.db.get('select pen_width_mm, favorite_colors from pen_presets');
  const ink = await b.db.get('select collapsed, typeof(collapsed) t from ink_layers limit 1');
  r.formato_na_volta = {
    timestamptz_enviado: orig.created_at,
    timestamptz_recebido: pb.created_at,
    numeric_progression_enviado: orig.progression,
    numeric_progression_recebido: pb.progression,
    numeric_pen_width_mm: pen.pen_width_mm,
    jsonb_recebido: pen.favorite_colors,
    boolean_recebido: `${ink.collapsed} (${ink.t})`,
  };
  registrar('06_payloads_rpc', r);
  for (const x of [a, o, adiantado, b]) await x.fechar();
  await A.fechar();
});
