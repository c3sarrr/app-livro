// FTS5 local (busca da tela 25) sobre as tabelas próprias e migração de esquema dos dois lados
// (coluna nova no aparelho antes do servidor e depois no servidor), com dados preservados.
import assert from 'node:assert/strict';
import { test } from 'node:test';
import { Schema } from '@powersync/node';
import { aguardar } from '../lib/aparelho.mjs';
import { gerarAcervo, gravarAcervo } from '../lib/dados.mjs';
import { COLUNAS } from '../lib/esquema.mjs';
import { esquemaBruto } from '../lib/esquema_bruto.mjs';
import { ambiente, aparelho, filaVazia, registrar } from './_comum.mjs';

// Anexo 02 §3.3: annotations_fts mantida por gatilhos; tokenizador unicode61 sem acentos.
const FTS = [
  `CREATE VIRTUAL TABLE IF NOT EXISTS annotations_fts USING fts5(id UNINDEXED, texto, tokenize = "unicode61 remove_diacritics 2")`,
  `CREATE TRIGGER IF NOT EXISTS annotations_fts_ins AFTER INSERT ON annotations BEGIN
     INSERT INTO annotations_fts (id, texto) VALUES (NEW.id, coalesce(NEW.note_text, '')); END`,
  `CREATE TRIGGER IF NOT EXISTS annotations_fts_upd AFTER UPDATE ON annotations BEGIN
     DELETE FROM annotations_fts WHERE id = OLD.id;
     INSERT INTO annotations_fts (id, texto) VALUES (NEW.id, coalesce(NEW.note_text, '')); END`,
  `CREATE TRIGGER IF NOT EXISTS annotations_fts_del AFTER DELETE ON annotations BEGIN
     DELETE FROM annotations_fts WHERE id = OLD.id; END`,
];

async function comFts(ap) {
  await ap.db.writeTransaction(async (tx) => {
    for (const sql of FTS) await tx.execute(sql);
  });
  return ap;
}

const buscar = (ap, q) => ap.db.getAll('select id from annotations_fts where annotations_fts match ?', [q]);

test('FTS5 nas tabelas próprias + migração de esquema nos dois lados', async (t) => {
  const A = await ambiente();
  t.after(async () => {
    await A.servidor.q('alter table personal.annotations drop column if exists lang').catch(() => {});
    delete COLUNAS.annotations.lang;
  });
  const r = {};
  const uid = await A.servidor.novoUsuario();
  const a = await comFts(await aparelho(A, 'fts_a', uid));
  await gravarAcervo(a.db, gerarAcervo({ uid, hlc: a.hlc }));
  const t0 = performance.now();
  const achados = await buscar(a, 'capítu'); // com acento, acha "Capitu"
  const buscaMs = performance.now() - t0;
  assert.equal(achados.length, 1000);
  assert.equal((await buscar(a, 'ressaca AND olhos')).length, 1000);
  r.fts_gratis = { notas: 1000, achados_capitu_com_acento: achados.length, busca_ms: Number(buscaMs.toFixed(2)) };

  // virar Pro e um 2º aparelho: a busca funciona no que veio pela sincronização (gatilhos no put)
  await A.servidor.darPro(uid);
  await a.virarPro();
  await filaVazia(a);
  const b = await comFts(await aparelho(A, 'fts_b', uid, { pro: true }));
  await b.conectar();
  await aguardar(async () => (await b.db.get('select count(*) n from annotations')).n === 4700, { msg: 'B baixou' });
  assert.equal((await buscar(b, 'capitu')).length, 1000);
  await b.db.execute("update annotations set note_text = 'uma lembrança de Matacavalos', version_hlc = ? where id = (select id from annotations where kind = 'note' limit 1)", [b.hlc.enviar()]);
  assert.equal((await buscar(b, 'matacavalos')).length, 1);
  await filaVazia(b);
  await aguardar(async () => (await buscar(a, 'matacavalos')).length === 1, { msg: 'A recebeu a edição e reindexou' });
  r.fts_pro = { aparelho_novo_achados: 1000, edicao_remota_reindexada: true };

  // Migração do app: coluna nova + put novo + gatilhos novos + preenche a coluna com o que já tinha
  // chegado em `_extras` (valor que o servidor mandou antes de o app conhecer a coluna).
  const migrar = async (ap) => {
    await ap.desconectar();
    await ap.db.execute('ALTER TABLE annotations ADD COLUMN lang TEXT');
    await ap.db.execute("UPDATE annotations SET lang = json_extract(_extras, '$.lang') WHERE _extras IS NOT NULL");
    COLUNAS.annotations.lang = COLUNAS.annotations.note_text; // TEXT
    await ap.db.updateSchema(esquemaBruto()); // put passa a incluir lang
    await ap.db.execute('DROP TRIGGER annotations_fila_insert');
    await ap.db.execute('DROP TRIGGER annotations_fila_update');
    await ap.db.writeTransaction(async (tx) => {
      for (const sql of (await import('../lib/esquema_bruto.mjs')).ddlBruto()) await tx.execute(sql);
    });
    await ap.conectar();
  };

  // Migração 1: o APP ganha a coluna antes do servidor (app novo, servidor velho) → a RPC ignora a chave
  await migrar(a);
  const nota = (await a.db.get("select id from annotations where kind = 'note' limit 1")).id;
  await a.db.execute('update annotations set lang = ?, version_hlc = ? where id = ?', ['pt-BR', a.hlc.enviar(), nota]);
  await filaVazia(a);
  assert.equal(a.ev.recusadas, 0, 'servidor velho ignora a coluna desconhecida (não recusa)');
  assert.equal((await A.servidor.linha('annotations', nota)).lang, undefined);
  r.migracao_app_antes = { recusas: 0, coluna_ignorada_no_servidor: true, buscas_continuam: (await buscar(a, 'capitu')).length };

  // Migração 2: o SERVIDOR ganha a coluna; B (ainda sem a coluna) RECEBE o valor antes de migrar —
  // o caso que perderia o dado: ele fica em `_extras` e a migração de B o recupera.
  await A.servidor.q('alter table personal.annotations add column lang text');
  const hlcNovo = a.hlc.enviar();
  await a.db.execute('update annotations set lang = ?, version_hlc = ? where id = ?', ['pt-BR', hlcNovo, nota]);
  await filaVazia(a);
  assert.equal((await A.servidor.linha('annotations', nota)).lang, 'pt-BR');
  await aguardar(async () => (await b.db.get('select version_hlc v from annotations where id = ?', [nota])).v === hlcNovo, { msg: 'B recebeu a versão nova (sem a coluna)' });
  const extras = JSON.parse((await b.db.get('select _extras e from annotations where id = ?', [nota])).e);
  assert.equal(extras.lang, 'pt-BR', 'o valor desconhecido ficou guardado em _extras');
  await migrar(b);
  assert.equal((await b.db.get('select lang from annotations where id = ?', [nota])).lang, 'pt-BR', 'migração recuperou de _extras');
  assert.equal((await b.db.get('select count(*) n from annotations')).n, 4700, 'nenhuma linha perdida na migração');
  r.migracao_servidor_depois = { valor_novo_no_servidor: 'pt-BR', chegou_antes_da_migracao_em_extras: true, recuperado_na_migracao: true, linhas_preservadas: 4700 };

  await A.servidor.q('alter table personal.annotations drop column if exists lang'); // volta ao SQL de referência
  delete COLUNAS.annotations.lang;
  registrar('07_fts_migracao', r);
  await a.fechar();
  await b.fechar();
  await A.fechar();
});
