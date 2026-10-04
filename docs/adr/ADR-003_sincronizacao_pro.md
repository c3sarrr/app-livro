# ADR-003 — Sincronização Pro: PowerSync (Sync Streams + tabelas próprias) com upload pela RPC

- **Status:** **aceita** pelo spike S2 (G02), **com mudanças no desenho do Anexo 02** · confirmada pelo Cesar em 04/10/2026 (Q20)
- **Data:** 03/10/2026
- **Prova:** `spikes/S2_banco_sync/servidor` — 8 cenários, **8/8 em 2 rodadas completas do zero com o código final** (uma rodada anterior expôs a perda de coluna que o `_extras` corrigiu) (`dados/resultado_s2.json`)

## Contexto

Pro sincroniza os dados pessoais entre aparelhos; Grátis nunca envia dado pessoal; perder o Pro **não pode
apagar nada** do aparelho; voltar ao Pro (antes ou depois do purge de 12 meses) repovoa a nuvem. O Anexo 02
propôs PowerSync com views "localOnly ↔ synced", regras `bucket_definitions` e publicação com
`publish_via_partition_root`, e listou 4 critérios eliminatórios com modo avião no meio.

## Ambiente do spike

Postgres 16 (wal_level=logical) com o stub do Supabase + `01_schema_booknest.sql` sem mudanças · serviço
**PowerSync 1.27.0** (npm, edição Open, armazenamento de buckets em **Postgres**) · "PostgREST" mínimo
(JWT HS256 `aud=authenticated` → `set role authenticated` + `request.jwt.claims` → RPC) · aparelhos
simulados com **`@powersync/node` 1.1.1** (núcleo Rust 0.5.3 = o do SDK Dart 2.4.0) · modo avião = proxy TCP
por aparelho que derruba as conexões. `supabase start` não roda aqui (Docker sem daemon; 6 GB livres no
Windows) — pendência para a G04.

## Decisão

1. **PowerSync** para o Pro, com **Sync Streams** (edição 3 — `bucket_definitions` é legado no serviço 1.27):
   ```yaml
   config: { edition: 3 }
   with:
     pro: SELECT user_id FROM billing.sync_access WHERE user_id = auth.user_id() AND granted = true
   streams:
     pessoal:
       auto_subscribe: true
       queries:
         - SELECT * FROM personal.user_books WHERE user_id IN pro
         - SELECT * FROM personal."reading_sessions_%" AS reading_sessions WHERE user_id IN pro
         # … as outras 8 tabelas pessoais
   ```
2. **Publicação sem `publish_via_partition_root`** (o serviço recusa: `PSYNC_S1143`). A tabela particionada é
   publicada pela raiz; cada partição chega com o próprio nome e o curinga `reading_sessions_%` junta todas
   (partições novas entram sozinhas). Medido: sessões de **11 partições** chegaram ao 2º aparelho.
3. **Tabelas próprias no aparelho** (ADR-002) com:
   - `put` = upsert com LWW (`WHERE excluded.version_hlc >= version_hlc`) + `_extras` ("Rest");
   - **`delete` que não apaga** (só registra) — o modelo usa só exclusão lógica; remoção de bucket nunca
     apaga dado do aparelho;
   - gatilhos de fila ligados só no modo Pro.
4. **Upload sempre `PUT` com a linha inteira** pela RPC `sync_apply_changes` (lotes de 500). Recusas saem da
   fila e vão para `sync_rejections` **com a operação inteira**; erro transitório (5xx) derruba o lote e o SDK
   repete.
5. **HLC:** toda escrita faz `receive(version_hlc da linha lida)` antes do `send()` (Anexo 02 §3.4).
6. **Porteiro + reação do app:** o conector só entrega credencial se `my_entitlement()` disser Pro; o app sai do
   modo Pro (desconecta, liga o modo Grátis, `disconnectAndClear(clearLocal:false)`) na expiração prevista
   (RevenueCat), no `pro_required` do upload e na checagem periódica. **Não é a proteção principal** (ver 3).
7. **Hospedagem: PowerSync Cloud, região BR (Brasil)** — existe (IPs AWS São Paulo na lista de filtragem de IP
   da documentação) → dados no Brasil sem operar servidor. Plano de saída: self-host da edição Open (o mesmo
   serviço deste spike, um processo Node + Postgres) numa VM em `sa-east-1`. Responde à **Q7**.

## Evidências (`dados/resultado_s2.json`)

| Critério / prova | Resultado |
|---|---|
| **1 · Grátis sem fila** | 10.000 linhas em 20 transações (1,8 s): **fila 0**, **0 conexões de rede**, 0 linhas no servidor; dados intactos ao reabrir |
| **2 · Virar Pro sobe tudo** | 10.000 `PUT` na fila → **10.050** no servidor (50 escritas feitas em modo avião durante o upload); corte depois de 3 lotes, 2 erros de rede, retomada sozinha; **0 diferenças** aparelho × servidor; 2º aparelho baixa tudo em **0,7 s** (1,57 MB) |
| **3 · Perder o Pro não apaga nada** | expiração prevista offline com 20 escritas na fila → 10.020 preservadas · reembolso detectado conectado (`pro_required`) → 10.005 preservadas · reembolso + 7 dias **em modo avião**: o SDK reconectou **com o token em cache** e recebeu a remoção do bucket → **10.000 remoções neutralizadas, 0 apagadas** · pior caso (sem porteiro, conectado) → 10.000 preservadas |
| **Controle negativo do 3** (views do Anexo 02 §3.1) | mesmo caminho do modo avião: **10.000 → 0 linhas** no aparelho (o porteiro nem é chamado) |
| **4 · Voltar após o purge** | nuvem vazia → virar Pro com corte no meio → **10.000** de volta, inclusive **82 exclusões lógicas**; aparelho novo idêntico. Antes do purge: só as **288** linhas mudadas no Grátis aplicadas, **9.712** ignoradas pelo LWW |
| 2 aparelhos offline, relógios ±5 min | maior HLC vence nas duas ordens de reconexão; edições sem conflito dos dois lados preservadas; exclusão lógica propagada |
| Controle negativo do HLC | sem `receive` antes do `send`, o aparelho com relógio 5 min atrasado teve **3 edições ignoradas** (perdidas) |
| Payloads reais → RPC | jsonb em texto vira objeto/array · FK de outro usuário → recusa `23503` sem travar as 3 válidas do lote; linha recusada **continua no aparelho** · trava de linha → `55P03` → lote inteiro repetido e aplicado · HLC +10 min → `invalid_hlc` · sessão de 2023 → `started_at_out_of_range`; de hoje → partição `2026_10` |
| Formato na volta | `timestamptz` "…58.136Z" → "…58.136000Z"; numeric "0.00000"/"1.2" preservados; jsonb volta com espaços; boolean → 0/1 |
| FTS5 + migração | busca sem acento 3,1 ms; aparelho novo reindexa pelo `put`; coluna nova no app antes do servidor → ignorada sem recusa; coluna nova no servidor recebida **antes** da migração do aparelho → guardada em `_extras` e recuperada |
| Contrato de colunas | 10 tabelas, **126 colunas** iguais (nome e tipo SQLite) ao Postgres |
| RPC, lote de 500 operações | p50 **205–291 ms**, p95 **424–559 ms** (rodadas completas; Postgres local) — acima da meta de 400 ms do Anexo 02 §10 |

## Mudanças no Anexo 02 (perguntar ao Cesar no relatório da G02)

1. §3.1: views "localOnly ↔ synced" → **tabelas próprias** com `delete` que não apaga e fila por gatilho.
2. §6.2: `bucket_definitions` → **Sync Streams**; sem `publish_via_partition_root`; curinga para as partições.
3. §3.4: regra explícita "`receive` da versão lida antes de cada `send`".
4. §6.1: upload sempre `PUT` (sem `PATCH`); `sync_rejections` guarda a operação inteira.
5. §3.2: `_extras` local em cada tabela; formato canônico de data/hora com 6 casas.
6. Q7: PowerSync **Cloud na região BR** (recomendado) × self-host (plano de saída).
7. G04: otimizar a RPC (aplicar por tabela com `jsonb_populate_recordset` em vez de SQL dinâmico por operação)
   para o p95 de 500 operações ficar < 400 ms.

## Custo (preços públicos consultados em 03/10/2026)

PowerSync Cloud **Free**: 2 GB sincronizados/mês, 50 clientes simultâneos (desenvolvimento). **Pro**: a partir de
**US$ 49/mês** com 30 GB sincronizados (US$ 1/GB a mais), 1.000 clientes simultâneos de pico (US$ 30 por mil a
mais) e 10 GB hospedados (US$ 1/GB). Medido: a carga inicial de um acervo de 10.000 linhas é **1,57 MB** →
30 GB ≈ 19 mil cargas completas por mês; o custo do Pro é dominado pelos clientes simultâneos, não pelos dados
(coerente com o Anexo 04 §10). Self-host: licença FSL-1.1-ALv2 do serviço (uso próprio permitido; vira
Apache 2.0 em 2 anos; não é parecer jurídico) + uma VM pequena em `sa-east-1`.

## LGPD / região

Com a região BR do PowerSync Cloud, os dados pessoais do Pro ficam no Brasil (Supabase `sa-east-1` + PowerSync
BR). O PowerSync entra na lista de suboperadores da política de privacidade (há página pública de
suboperadores). O Grátis não envia dado pessoal (critério 1).

## Plano B (se o PowerSync falhar na G06 ou no aparelho)

**drift puro + sincronização própria**, aproveitando o desenho acima quase inteiro: os mesmos gatilhos passam a
gravar numa fila própria (`outbox`) em vez de `powersync_crud`; o upload continua pela RPC
`sync_apply_changes`; o download vira uma RPC `sync_pull(desde_hlc)` paginada por `(user_id, version_hlc)`
(índices já existem por `updated_at`; trocar para `version_hlc`), aplicada com o mesmo upsert LWW. Sem
remoção automática no aparelho por construção. Custa: tempo real (Realtime do Supabase ou polling) e
resolução de lacunas de HLC entre aparelhos; estimativa +1 fase (M) na trilha A.

## Pendências

- G04 (feito): `supabase start` (Docker no WSL) com Postgres 17.11 e as 15 migrations; a publicação
  `powersync` (10 tabelas pessoais + `billing.sync_access`, sem `publish_via_partition_root`, toda partição
  das sessões replicada pelo próprio nome) é conferida por teste pgTAP. **Os 8 cenários com o serviço
  PowerSync passam para a G06**, junto com o conector Dart real (o mesmo roteiro, contra o Supabase local).
- G04 (feito — item 7 das mudanças): a RPC grava os PUTs em lote por tabela (migration
  `sincronizacao_em_lote`): lotes de 500 operações com 100 mil usuários no Postgres 17 local —
  p50 47–48 ms, p95 63–154 ms em 3 rodadas (antes: p50 238 ms / p95 459 ms); ver
  `docs/progresso/RELATORIO_G04.md`.
- G06: as partições de `reading_sessions` agora nascem com RLS e privilégios explícitos
  (`private.secure_session_partition`, revisão da G04) — partição não herda GRANT. Se o PowerSync
  usar um papel próprio, ele entra nessa função com SELECT (senão o snapshot das partições novas falha).
- G06 (e-books na nuvem): download por URL curta emitida por Edge Function e exclusão pelo
  servidor; depois disso, tirar a política SELECT do bucket `ebooks` (hoje o dono pode gerar link
  assinado de validade longa — achado #5 da revisão da G04, a parte da cota já foi corrigida).
- G06: o conector Dart real (com `fetchCredentials` = sessão do Supabase), teste de integração Dart ↔ serviço
  e os mesmos 4 critérios no aparelho; checagem periódica do Pro com o RevenueCat.
- G03 (feito): a regra receive-antes-de-send virou a porta única `LocalVersioning.write` (ler, versionar e
  gravar numa transação) + gatilho `<tabela>_version_guard` que recusa versão local menor que a gravada; um
  HLC salvo > 5 min à frente do relógio é ignorado na abertura (relógio adiantado e depois acertado).
- G06: relógio do aparelho > 5 min adiantado → a RPC recusa (`invalid_hlc`, não repetível) toda escrita do
  período. Falta (a) medir a defasagem pela hora do servidor (resposta da RPC/checkpoint) e avisar/limitar
  o HLC, e (b) reenfileirar com versão nova as linhas recusadas por `invalid_hlc` depois que o relógio
  voltar (hoje elas vão para `sync_rejections`).
- G06: checar no upload os únicos parciais do servidor também para linhas que chegaram de outro aparelho
  (o DAO já recusa duplicata local de arquivo na estante e de cor nos rótulos — `DuplicateActiveRow`).
