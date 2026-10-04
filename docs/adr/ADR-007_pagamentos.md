# ADR-007 — Pagamentos: RevenueCat + webhook (Edge Function) que reconcilia pelo estado atual

- **Status:** aceita pelo spike S5 **simulado** (G02) · **pendente:** compra sandbox real nas lojas (comando/passos abaixo)
- **Data:** 03/10/2026
- **Prova:** `spikes/S5_pagamentos/` — `deno test` **14/14** (`dados/resultado_s5.json`)
- **Escolha do Cesar (início da G02):** "simular agora" — webhook com eventos de exemplo contra o banco local; a compra real fica para quando existirem as contas.

## Contexto

Assinatura de recurso digital = Play Billing / Apple IAP; o RevenueCat unifica as lojas, valida recibos e
manda webhooks (Anexo 04). O que libera recursos é `billing.entitlements` no servidor; o app só melhora a UX.

## Decisão

1. **RevenueCat** (`purchases_flutter`, versão conferida no pub.dev na G22) com `app_user_id` = id do Supabase
   (`Purchases.logIn` antes de comprar — compra exige conta).
2. **Edge Function `revenuecat-webhook`** exatamente como `spikes/S5_pagamentos/supabase/functions/...`:
   - `Authorization: Bearer <segredo>` comparado em tempo constante → 401 se errado;
   - idempotência por `event.id` (`billing.webhook_events`): processado → 200 "duplicado" sem consultar nada;
     falhou antes (`processed_at` nulo) → reprocessa;
   - **não confia na ordem**: busca `GET /v1/subscribers/{app_user_id}` e grava o **estado atual**
     (`active_until` = maior entre expiração e carência; reembolso corta em `refunded_at`);
   - `billing.subscriptions` por (loja, transação original) e `billing.entitlements` (sandbox libera o Pro e
     fica marcado — **D-48**; alerta se sandbox aparecer em conta fora da lista de teste);
   - `private.refresh_sync_access()` na mesma transação;
   - erro → grava `error` e responde **500** (o RevenueCat reenvia).
3. Conexão direta ao Postgres pela `SUPABASE_DB_URL` (os esquemas `billing`/`private` não são expostos pelo
   PostgREST); segredos só nas variáveis da função (`REVENUECAT_WEBHOOK_AUTH`, `REVENUECAT_API_KEY`).
4. `TRANSFER` não traz `app_user_id`: reconcilia todos os ids de `transferred_from` e `transferred_to`; ids
   anônimos do RevenueCat são ignorados (a compra exige login); lojas fora do app (Stripe, Amazon, Web Billing)
   são registradas como nota e ignoradas.

## Evidências (simuladas — Postgres 16 local + API do RevenueCat simulada)

| Caso (Anexo 04 §9) | Resultado |
|---|---|
| Segredo errado | **401**, nada gravado |
| Compra inicial sandbox (teste grátis 7 dias, App Store) | Pro ativo, `environment='sandbox'`, assinatura `active/trial`, bucket concedido, upload liberado; **alerta** de sandbox em conta real |
| Compra em produção (Play, anual) em conta de teste | `production`, `booknest_pro:anual`, sem alerta |
| Webhook duplicado | 1ª "processado", 2ª "duplicado" **sem nova consulta** ao RevenueCat |
| Fora de ordem (EXPIRATION velho depois do RENEWAL) | continua **Pro/active** (vale o estado atual) |
| Cancelamento (desligou a renovação) | Pro até o fim do período, `cancelled`, `will_renew=false` |
| Falha de cobrança | na carência: Pro, `in_grace_period`; carência vencida: sem Pro, `in_billing_retry`, upload bloqueado, bucket ainda concedido |
| Reembolso | Pro cai **na hora** (`refunded`), upload bloqueado (`can_sync=false`), bucket mantido; 7 dias depois o `refresh_sync_access` revoga |
| Troca mensal → anual | produto e validade atualizados |
| Expiração | sem Pro, `expired`, upload bloqueado; bucket por mais 7 dias |
| Transferência entre contas | origem perde, destino ganha o Pro |
| RevenueCat fora do ar | **500** + erro gravado; o reenvio do mesmo evento processa |
| Evento TEST / conta excluída | 200 sem mexer em nada (nota `usuario_inexistente`) |
| Tempo de resposta (22 chamadas) | p50 **3,7 ms**, p95 5,7 ms, máx 20 ms sem a latência real da API do RevenueCat (limite do `fetch`: 1,5 s; meta < 2 s) |

## Consequências

- O app nunca escreve em `billing.*`; a UX do Pro vem do `CustomerInfo` e o servidor confirma por
  `my_entitlement()` (ADR-003: porteiro do sync).
- G04: trocar o `refresh_sync_access()` global por uma versão por usuário (o webhook só precisa do afetado).
- Pendência da G00 relacionada: o identificador do app (Q5) precisa existir antes de criar os produtos nas lojas.

## Pendência — compra sandbox real (passos exatos)

1. Contas: Apple Developer (empresa: D-U-N-S/CNPJ — Q5), Google Play Console, projeto no RevenueCat.
2. Produtos: Play `booknest_pro` com *base plans* `mensal` (P1M) e `anual` (P1Y) + teste grátis 7 dias; App Store
   grupo "BookNest Pro" com `booknest_pro_mensal`/`booknest_pro_anual` + oferta introdutória; RevenueCat:
   entitlement `pro`, offering `default` com `$rc_monthly`/`$rc_annual` (Anexo 04 §2).
3. Webhook do RevenueCat → URL da função no projeto `booknest-dev` com o cabeçalho `Authorization` (segredo
   no painel do Supabase, **nunca no chat**).
4. Deploy: `supabase functions deploy revenuecat-webhook` + `supabase secrets set REVENUECAT_WEBHOOK_AUTH=… REVENUECAT_API_KEY=… CONTAS_TESTE=…`.
5. Android: testador de licença na Play Console, faixa de teste interno, `flutter run --release` no aparelho e
   comprar o mensal; conferir `billing.entitlements.environment='sandbox'`. iOS: Sandbox Tester (exige Mac).
6. Rodar os casos do Anexo 04 §9 que só existem na loja (elegibilidade do teste grátis, restaurar em outro
   aparelho, compra pendente, app offline durante a compra).

## Alternativas consideradas

- **Validação de recibo própria** (App Store Server API + Play Developer API): mais código, duas integrações,
  notificações de servidor próprias; o RevenueCat é grátis até US$ 2.500/mês de receita rastreada.
- **Confiar no conteúdo do evento** (sem consultar o estado): quebra com eventos fora de ordem — o caso de teste
  mostra o EXPIRATION atrasado derrubando o Pro se não houvesse a reconciliação.
