# S5 · Pagamentos (simulado) — ADR-007

Edge Function `revenuecat-webhook` (Deno/TypeScript, como roda no Supabase) testada contra o Postgres local
com o SQL de referência e uma API REST do RevenueCat simulada. A compra sandbox de verdade fica pendente até
existirem as contas (escolha do Cesar no início da G02).

| Arquivo | O que é |
|---|---|
| `supabase/functions/revenuecat-webhook/index.ts` | A função: segredo, idempotência por `event.id`, estado atual pela API REST, upsert de `billing.*`, `refresh_sync_access()`, erro → 500 |
| `supabase/functions/revenuecat-webhook/reconciliar.ts` | Lógica pura: assinante do RevenueCat → linhas de `billing.subscriptions`/`billing.entitlements` |
| `testes/webhook_test.ts` | 14 testes (compra sandbox/produção, teste grátis, duplicado, fora de ordem, cancelamento, carência, retentativa, reembolso, troca de plano, expiração, transferência, RevenueCat fora do ar, TEST, conta excluída, tempo) |
| `scripts/rodar_testes.sh` | Recria `booknest_s5` e roda os testes |
| `dados/resultado_s5.json` | Resultado de cada caso e tempos |

```bash
# Postgres local (variáveis PG*) + Deno 2.9
DENO=/caminho/do/deno bash spikes/S5_pagamentos/scripts/rodar_testes.sh
```
