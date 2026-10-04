// G02 · S2 — PLANO A' (decisão do spike): tabelas SQLite PRÓPRIAS ("raw tables" do PowerSync).
//
// Por que (cenário 04): no padrão de views "localOnly → synced", o SDK reconecta sozinho com o token
// em cache quando a rede volta; se o bucket foi revogado nesse meio-tempo, o PowerSync APAGA as
// linhas do aparelho (medido: 7.000 → 0 em < 1 s). Com tabelas próprias, quem aplica o que vem do
// servidor são as instruções `put`/`delete` daqui:
//   * put    = upsert com LWW pelo version_hlc (nunca volta uma versão mais nova do aparelho);
//   * delete = NÃO apaga (o modelo só usa exclusão lógica); só registra que a nuvem removeu a linha;
//   * colunas que o servidor manda e o app ainda não conhece vão para `_extras` (parâmetro "Rest"):
//     a migração que cria a coluna depois a preenche dali (senão o valor se perderia — cenário 07).
// E a fila de upload é alimentada por gatilhos que só gravam quando o modo do app é 'pro' e a escrita
// não veio da própria sincronização (powersync_in_sync_operation()). Grátis: os mesmos gatilhos,
// desligados → fila sempre vazia. Uma tabela física por entidade → o drift pode ser dono do esquema.
import { Schema } from '@powersync/node';
import { COLUNAS, TABELAS } from './esquema.mjs';

const tipoSqlite = (c) => (c.type === 'INTEGER' ? 'INTEGER' : 'TEXT');

export function esquemaBruto() {
  const s = new Schema({});
  const brutas = {};
  for (const t of TABELAS) {
    const cols = Object.keys(COLUNAS[t]);
    brutas[t] = {
      put: {
        sql:
          `INSERT INTO ${t} (id, ${cols.join(', ')}, _extras) VALUES (?, ${cols.map(() => '?').join(', ')}, ?) ` +
          `ON CONFLICT(id) DO UPDATE SET ${cols.map((c) => `${c} = excluded.${c}`).join(', ')}, _extras = excluded._extras ` +
          `WHERE excluded.version_hlc >= ${t}.version_hlc`,
        params: ['Id', ...cols.map((c) => ({ Column: c })), 'Rest'],
      },
      delete: {
        sql: `INSERT INTO s2_remocoes_ignoradas (tabela, linha_id, em) VALUES ('${t}', ?, datetime('now'))`,
        params: ['Id'],
      },
    };
  }
  s.withRawTables(brutas);
  return s;
}

/** DDL das tabelas próprias + gatilhos da fila (idempotente). Na G06 isto é migração do drift. */
export function ddlBruto() {
  const ddl = [
    `CREATE TABLE IF NOT EXISTS app_kv (chave TEXT PRIMARY KEY, valor TEXT) STRICT`,
    `INSERT OR IGNORE INTO app_kv VALUES ('sync', 'gratis')`,
    `CREATE TABLE IF NOT EXISTS s2_remocoes_ignoradas (tabela TEXT, linha_id TEXT, em TEXT)`,
    `CREATE TABLE IF NOT EXISTS sync_rejections (id TEXT PRIMARY KEY, tabela TEXT, linha_id TEXT, motivo TEXT, codigo TEXT, em TEXT, operacao TEXT)`,
  ];
  for (const t of TABELAS) {
    const cols = Object.entries(COLUNAS[t]);
    ddl.push(
      `CREATE TABLE IF NOT EXISTS ${t} (id TEXT PRIMARY KEY NOT NULL, ${cols.map(([c, d]) => `${c} ${tipoSqlite(d)}`).join(', ')}, _extras TEXT) STRICT`,
      `CREATE INDEX IF NOT EXISTS ${t}_por_usuario ON ${t} (user_id, updated_at)`,
    );
    const json = `json_object(${cols.map(([c]) => `'${c}', NEW.${c}`).join(', ')})`;
    const quando = `WHEN NOT powersync_in_sync_operation() AND (SELECT valor FROM app_kv WHERE chave = 'sync') = 'pro'`;
    for (const ev of ['INSERT', 'UPDATE']) {
      ddl.push(
        `CREATE TRIGGER IF NOT EXISTS ${t}_fila_${ev.toLowerCase()} AFTER ${ev} ON ${t} FOR EACH ROW ${quando} ` +
          `BEGIN INSERT INTO powersync_crud (op, id, type, data) VALUES ('PUT', NEW.id, '${t}', ${json}); END`,
      );
    }
  }
  return ddl;
}

/** Enfileira TODAS as linhas como PUT (virar Pro / voltar ao Pro — inclui exclusões lógicas). */
export function enfileirarTudo() {
  return TABELAS.map((t) => {
    const cols = Object.keys(COLUNAS[t]);
    return `INSERT INTO powersync_crud (op, id, type, data) SELECT 'PUT', id, '${t}', json_object(${cols.map((c) => `'${c}', ${c}`).join(', ')}) FROM ${t}`;
  });
}
