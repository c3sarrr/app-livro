# S2 · Banco local + sincronização Pro — ADR-002 · ADR-003

Prova do Anexo 02 §3.1/§6 com o serviço PowerSync de verdade, o SQL de referência (`handoff_v2/sql`) e a
RPC `public.sync_apply_changes`, incluindo os **4 critérios eliminatórios com modo avião no meio**.

| Pasta | O que é | Onde roda |
|---|---|---|
| `servidor/` | Postgres 16 (lógico) + **serviço PowerSync 1.27** (npm `@powersync/service-image`, armazenamento em Postgres) + "PostgREST" mínimo (JWT HS256 → papel `authenticated` → RPC) + aparelhos simulados com o SDK `@powersync/node` (mesmo núcleo Rust 0.5.3 do SDK Dart) | container Linux, Node 24 |
| `servidor/cenarios/` | 8 cenários `node --test` (Grátis, virar Pro, 2 aparelhos/LWW, perder o Pro, voltar após o purge, payloads da RPC, FTS5/migração, contrato de colunas) | |
| `cliente_dart/` | O lado do app em Dart: SDK `powersync` 2.4 + **drift** 2.35 (`drift_sqlite_async`) na mesma conexão, tabelas próprias, fila só no Pro, FTS5, migração | Windows, `dart test` |
| `dados/` | `resultado_s2.json` (cenários) e `resultado_s2_dart.json` (cliente Dart) | |

```bash
# container (Postgres 16 em 127.0.0.1:55432 com wal_level=logical; Node 24 em $NODE)
cd spikes/S2_banco_sync/servidor && npm install
NODE=/caminho/do/node24 bash scripts/rodar_cenarios.sh      # recria bancos, sobe o serviço, roda os 8 cenários
```
```powershell
# Windows
cd spikes\S2_banco_sync\cliente_dart; dart pub get; dart run build_runner build; dart test
```

Achados que mudam o Anexo 02 (detalhes e números nos ADRs):
1. **O padrão de views "localOnly ↔ synced" reprova o critério 3**: quando a rede volta, o SDK reconecta
   sozinho com o token em cache (o `fetchCredentials` não é chamado de novo) e, se o bucket foi revogado,
   o PowerSync apaga as linhas do aparelho (10.000 → 0). **Decisão: tabelas próprias ("raw tables")** com
   `delete` que não apaga + gatilhos de fila que só gravam no modo Pro.
2. `publish_via_partition_root` **não é suportado** (PSYNC_S1143): partições publicadas pelo nome e juntadas
   no stream com o curinga `reading_sessions_%`.
3. `bucket_definitions` é legado: **Sync Streams** (edição 3).
4. HLC: toda escrita faz `receive(HLC da versão lida)` antes do `send()` — sem isso, um aparelho com relógio
   atrasado perde edições sem conflito nenhum (controle negativo no cenário 03).
5. Colunas novas: o `put` guarda o que o app ainda não conhece em `_extras` ("Rest") e a migração recupera.
