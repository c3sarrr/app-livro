// Dois aparelhos offline editando os mesmos dados, com relógios defasados: na reconexão (em
// qualquer ordem) vale o último escritor pelo HLC — servidor, A e B terminam iguais.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { aguardar } from '../lib/aparelho.mjs';
import { gerarAcervo, gravarAcervo } from '../lib/dados.mjs';
import { total } from '../lib/servidor.mjs';
import { ambiente, aparelho, diferencas, digitalAparelho, digitalServidor, filaVazia, registrar } from './_comum.mjs';

async function cenario(A, ordem, defasagemB, n, { semReceive = false } = {}) {
  const uid = await A.servidor.novoUsuario();
  await A.servidor.darPro(uid);
  const a = await aparelho(A, `a${n}`, uid, { pro: true });
  const b = await aparelho(A, `b${n}`, uid, { pro: true, defasagemMs: defasagemB });
  await gravarAcervo(a.db, gerarAcervo({ uid, hlc: a.hlc, total: 9200 }));
  await a.conectar();
  await filaVazia(a);
  await b.conectar();
  const noServidor = total(await A.servidor.contar(uid));
  assert.equal(noServidor, 9200);
  await aguardar(async () => total(await b.contar()) === noServidor, { msg: 'B sincronizado' });

  const notas = await a.db.getAll("select id from annotations where kind = 'note' order by id limit 4");
  const [x, y, z, w] = notas.map((r) => r.id);
  a.modoAviao(true);
  b.modoAviao(true);
  // A: edita X e Y; B: edita X (relógio defasado) e Z e apaga W (exclusão lógica)
  // Regra do HLC (Anexo 02 §3.4 "receive"): antes de escrever, o relógio absorve o HLC da versão
  // lida — a edição sempre supera a versão em que se baseou, mesmo com o relógio do aparelho atrasado.
  const hlcDaEscrita = async (ap, id) => {
    if (semReceive) return ap.hlc.enviar();
    ap.hlc.receber((await ap.db.get('select version_hlc v from annotations where id = ?', [id])).v);
    return ap.hlc.enviar();
  };
  const editar = async (ap, id, texto) =>
    ap.db.execute('update annotations set note_text = ?, updated_at = ?, version_hlc = ? where id = ?',
      [texto, new Date(ap.hlc.agora()).toISOString(), await hlcDaEscrita(ap, id), id]);
  await editar(a, x, 'A editou X');
  await editar(a, y, 'A editou Y');
  await new Promise((r) => setTimeout(r, 20));
  await editar(b, x, 'B editou X');
  await editar(b, z, 'B editou Z');
  await b.db.execute('update annotations set deleted_at = ?, version_hlc = ? where id = ?', [new Date().toISOString(), await hlcDaEscrita(b, w), w]);
  const hlcA = (await a.db.get('select version_hlc v from annotations where id = ?', [x])).v;
  const hlcB = (await b.db.get('select version_hlc v from annotations where id = ?', [x])).v;
  const vencedorX = hlcA > hlcB ? 'A editou X' : 'B editou X';

  const [p1, p2] = ordem === 'A primeiro' ? [a, b] : [b, a];
  p1.modoAviao(false);
  await filaVazia(p1);
  p2.modoAviao(false);
  await filaVazia(p2);
  if (process.env.S2_DIAG) {
    for (const id of [x, y, z, w]) console.log('srv', id.slice(0, 8), (await A.servidor.linha('annotations', id)).note_text, (await A.servidor.linha('annotations', id)).version_hlc);
    console.log('evA', a.ev, 'evB', b.ev, 'rejB', await b.db.getAll('select * from sync_rejections'), 'rejA', await a.db.getAll('select * from sync_rejections'));
  }
  if (semReceive) {
    // controle negativo: sem o "receive", as edições de B (relógio 5 min atrasado) perdem para a
    // versão ORIGINAL das linhas — Z e W voltam ao que eram, sem conflito nenhum de verdade
    await aguardar(async () => diferencas(await digitalAparelho(b), await digitalServidor(A.servidor, uid)) === 0, { msg: 'B = servidor' });
    const zPerdida = (await b.db.get('select note_text t from annotations where id = ?', [z])).t !== 'B editou Z';
    const r = { ordem, defasagem_b_ms: defasagemB, sem_receive: true, edicoes_de_b_ignoradas: b.ev.ignoradas, z_perdida: zPerdida };
    await a.fechar();
    await b.fechar();
    return r;
  }
  const servidorX = (await A.servidor.linha('annotations', x)).note_text;
  assert.equal(servidorX, vencedorX, 'servidor: maior HLC vence');
  for (const ap of [a, b]) {
    await aguardar(async () => diferencas(await digitalAparelho(ap), await digitalServidor(A.servidor, uid)) === 0, { msg: `${ap.nome} = servidor` });
    assert.equal((await ap.db.get('select note_text t from annotations where id = ?', [x])).t, vencedorX);
    assert.equal((await ap.db.get('select note_text t from annotations where id = ?', [y])).t, 'A editou Y');
    assert.equal((await ap.db.get('select note_text t from annotations where id = ?', [z])).t, 'B editou Z');
    assert.ok((await ap.db.get('select deleted_at d from annotations where id = ?', [w])).d, 'W apagada nos dois');
  }
  const r = { ordem, defasagem_b_ms: defasagemB, vencedor_x: vencedorX, ignoradas_pelo_lww: a.ev.ignoradas + b.ev.ignoradas };
  await a.fechar();
  await b.fechar();
  return r;
}

test('LWW por HLC com 2 aparelhos offline e relógios defasados (as duas ordens)', async () => {
  const A = await ambiente();
  const casos = [];
  casos.push(await cenario(A, 'A primeiro', +5 * 60000 - 1000, 1)); // B 5 min adiantado: B vence mesmo subindo depois
  casos.push(await cenario(A, 'B primeiro', -5 * 60000, 2)); // B 5 min atrasado: A vence X; Z e W de B valem
  assert.equal(casos[0].vencedor_x, 'B editou X');
  assert.equal(casos[1].vencedor_x, 'A editou X');
  const controle = await cenario(A, 'B primeiro', -5 * 60000, 3, { semReceive: true });
  assert.equal(controle.z_perdida, true, 'sem a regra, a edição de Z se perde');
  registrar('03_dois_aparelhos', {
    modo: process.env.S2_MODO ?? 'bruto',
    regra: 'HLC da escrita = send() depois de receive(HLC da versão lida)',
    casos,
    controle_negativo_sem_receive: controle,
  });
  await A.fechar();
});
