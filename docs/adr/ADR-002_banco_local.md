# ADR-002 — Banco local: SQLite do SDK PowerSync + drift como dono do esquema (tabelas próprias)

- **Status:** **aceita** (spike S2 na G02; implementada na G03; confirmada pelo Cesar em 04/10/2026 — Q20) · ajusta o Anexo 02 §3.1–3.3
- **Data:** 03/10/2026
- **Prova:** `spikes/S2_banco_sync/` (`dados/resultado_s2_dart.json`, `dados/resultado_s2.json`)

## Contexto

Toda conta lê e escreve num SQLite no aparelho (local primeiro); o Grátis tem ali a **única cópia**; o Pro
sincroniza o mesmo esquema. O Anexo 02 propôs SQLite do PowerSync + drift, com tabelas `localOnly` e
sincronizadas trocadas por nomes de view.

## Decisão

1. **SQLite do SDK `powersync`** (2.4.0; núcleo Rust 0.5.3, SQLite 3.53.4 com FTS5, empacotados por *build
   hooks* — nada de `sqlite3_flutter_libs`) e **drift** (2.35.1 + `drift_sqlite_async` 0.3.1) **na mesma
   conexão**: o drift cria as tabelas, faz as migrações (`schemaVersion`/`onUpgrade`), as consultas tipadas e
   os gatilhos; o PowerSync cuida só da fila de upload e de aplicar o que vem do servidor.
2. **Tabelas próprias** ("raw tables" do PowerSync), uma tabela física `STRICT` por entidade com as mesmas
   colunas de `personal.*` (+ `_extras TEXT` local), em vez das views "localOnly ↔ synced" (o motivo está no
   ADR-003: as views deixam o PowerSync apagar a única cópia).
3. **Fila só no Pro:** gatilhos `AFTER INSERT/UPDATE` gravam um `PUT` com a linha inteira em `powersync_crud`
   **somente** quando `app_kv.sync = 'pro'` e a escrita não veio da própria sincronização
   (`powersync_in_sync_operation()`). Grátis = mesmos gatilhos, desligados → a fila nunca cresce.
4. **Exclusão = lógica** (`deleted_at` + HLC novo) em todas as contas (Anexo 02 §1.7) — nunca `DELETE` físico
   de dado pessoal fora da retenção/exclusão de conta.
5. **FTS5** `annotations_fts` (tokenizador `unicode61 remove_diacritics 2`) mantida por gatilhos do drift.
6. **Colunas novas:** o `put` guarda em `_extras` (parâmetro "Rest") o que o servidor manda e o app ainda não
   conhece; a migração do drift que cria a coluna a preenche de `_extras` (`json_extract`).
7. **Formato canônico** dos valores em TEXT: data/hora `YYYY-MM-DDTHH:MM:SS.ffffffZ` (6 casas — é o que volta
   do servidor; o `toIso8601String()` do Dart omite as casas quando são zero → usar um formatador próprio);
   JSON comparado depois de decodificado (o Postgres devolve `["a", "b"]` com espaço).

## Evidências

| Prova (Windows, `dart test`) | Resultado |
|---|---|
| Núcleo no Dart | PowerSync core **0.5.3/2ba6b280**, SQLite **3.53.4** — o mesmo do SDK Node usado nos cenários |
| Grátis: 10.000 linhas pelo drift (`batch`) | 805 ms; **fila 0** |
| Pro: as mesmas 10.000 com gatilhos ligados | 2.369 ms; 10.000 `PUT` → **21 lotes de 500** do `getCrudBatch`; payload = `{table, op:"PUT", id, data:{linha inteira}, hlc}` (formato da RPC) |
| Edição pelo drift no Pro | entra como `PUT` com a linha inteira (sem `PATCH` → não quebra depois do purge) |
| FTS5 pelo drift | "capítu" (com acento) acha 9.940 notas em **3,0 ms** |
| Migração v1 → v2 (coluna nova) | 500 linhas preservadas; `user_version` 2; gatilho refeito com a coluna; valor recuperado de `_extras` |
| Banco do aparelho (cenário 01, 10.000 linhas) | 4,96 MB |

## Consequências

- O drift vira a única fonte do esquema local (tabelas, índices, FTS, gatilhos) com teste de migração de
  todas as versões (Anexo 02 §3.5); a G03 gera os 10 `Table` do drift a partir do SQL (teste de contrato:
  126 colunas conferidas no cenário 08).
- `insert/update` do drift são as únicas portas de escrita; o modo (Grátis/Pro) é uma linha em `app_kv`.
- O mesmo arquivo serve o plano B (ADR-003): os gatilhos passariam a gravar numa fila própria.

## Alternativas consideradas

- **Views `localOnly` ↔ sincronizadas** (Anexo 02 §3.1): reprovada no critério 3 (ADR-003).
- **Tabelas JSON padrão do PowerSync + drift só para consultas:** o drift não seria dono das migrações; FTS
  e índices em cima de views JSON; mesma exposição ao apagamento.
- **Isar/ObjectBox/Hive:** sem SQL/FTS5, sem o caminho de sync do PowerSync.

## Pendências

- ~~G03: os 10 `Table` completos do drift, `uuid_v7.dart`, `hlc.dart` (com a regra `receive` antes do `send`
  — ADR-003) e o teste de migração de todas as versões.~~ **Feito na G03** (`lib/core/data/`): 19 tabelas
  (10 pessoais + só locais), `LocalVersioning` (porta única das versões), contrato de colunas (126) e
  instantâneo `drift_schemas/app_database/drift_schema_v1.json` com teste de migração. Sem chaves
  estrangeiras locais (o PowerSync aplica um checkpoint em qualquer ordem); integridade pelo servidor e
  pelos DAOs.
- `android:allowBackup="false"`/`dataExtractionRules` e exclusão do iCloud para o arquivo do banco (Anexo 02 §12).
