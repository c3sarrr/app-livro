# Anexo 04 — Assinatura Pro e pagamentos

> Parte do pacote `handoff_v2/` · versão 2.0 · 03/10/2026
> Base de produto: `monetizacao/plano_gratis_vs_pro.md` (v3). Preço pedido pelo Cesar: **R$ 9,99/mês** e **R$ 79,99/ano** — o doc v3 fala em R$ 9,90/R$ 79,90 → confirmar (D-26) e conferir se o ponto de preço existe no App Store Connect/Play Console.
> Isto é especificação técnica, não parecer jurídico nem contábil: termos, impostos e política de privacidade passam por advogado/contador antes da publicação.

---

## 1. Regras de loja que definem a arquitetura

- Assinatura de recurso digital **dentro do app** = Google Play Billing (Android) e Apple In-App Purchase (iOS). Sem link para pagamento externo na v1 (as regras sobre pagamento alternativo no Brasil mudam; reavaliar com as regras vigentes antes de qualquer mudança).
- Obrigatórios: botão **"Restaurar compras"**; termos da assinatura visíveis antes de comprar (preço, período, renovação automática, como cancelar); links para Termos de Uso e Política de Privacidade; **excluir a conta dentro do app** (Apple 5.1.1(v)) e **página web para pedir a exclusão** (exigência do Google Play); se houver login com Google, oferecer também **"Entrar com a Apple"** no iOS (diretriz 4.8).
- Camada de pagamento: **RevenueCat** (`purchases_flutter` — versão 10.14.0 publicada em 01/10/2026; requer iOS 13+ e Android 5.0+). Ele valida recibos, unifica as duas lojas, controla elegibilidade de teste grátis e envia webhooks.

## 2. Produtos

| Loja | Configuração |
|---|---|
| Google Play | 1 assinatura `booknest_pro` com 2 *base plans*: `mensal` (P1M) e `anual` (P1Y); oferta de teste grátis 7 dias no plano mensal e no anual (elegibilidade: nunca assinou). No RevenueCat/webhook o produto aparece como `booknest_pro:mensal` / `booknest_pro:anual` |
| App Store | Grupo de assinatura "BookNest Pro" com `booknest_pro_mensal` e `booknest_pro_anual` **no mesmo nível** (troca vale na próxima renovação); oferta introdutória "teste grátis 7 dias" |
| RevenueCat | Entitlement **`pro`**; Offering `default` com pacotes `$rc_monthly` e `$rc_annual`; app_user_id = **id do usuário no Supabase** |

- Preço exibido **sempre** do `StoreProduct.priceString` (localizado, com impostos da loja); nunca escrito no código. "Economia" do anual calculada com os preços da loja (12 × mensal − anual).
- Compartilhamento familiar: desligado (dados pessoais são individuais).

## 3. Quem pode assinar

Assinar **exige conta** (o Pro é nuvem). Fluxo: paywall → "Entrar para assinar" (se convidado — D-25) → `Purchases.logIn(userId)` → compra. Isso evita compras "órfãs" num id anônimo do RevenueCat.

## 4. Fluxos no app

```
Abrir app ──▶ Purchases.configure(apiKey da plataforma, appUserID = userId?)
            └▶ CustomerInfo em cache (SDK) → estado "pro" para a UX imediatamente
Login ─────▶ Purchases.logIn(userId)   (alias de compras feitas antes, se houver)
Logout ────▶ Purchases.logOut()
Paywall ───▶ getOfferings() → produtos com preço da loja → purchasePackage(pkg)
            ├ sucesso → CustomerInfo.entitlements.active['pro'] → liga o sync (aguarda o servidor confirmar)
            ├ cancelado pelo usuário → volta sem erro
            └ pendente (ex.: aprovação/pagamento pendente) → mensagem "pagamento em análise"
Restaurar ─▶ restorePurchases()
Gerenciar ─▶ link para a gestão de assinaturas da loja (URL de gerenciamento do CustomerInfo)
```

- Ouvir `addCustomerInfoUpdateListener` para refletir renovações, carência, cancelamento.
- Estado da UX do Pro = RevenueCat (rápido, funciona offline com cache). **Estado que libera recursos no servidor = `billing.entitlements`** (via webhook). Se divergirem por alguns segundos, o app mostra "ativando o Pro…" e reconsulta `public.my_entitlement()` com recuo exponencial (até 60 s), depois segue.
- Offline: confiar no cache do CustomerInfo até a expiração informada + 3 dias para recursos **locais**; recursos de nuvem dependem do servidor.

## 5. Webhook (Edge Function `revenuecat-webhook`)

1. Conferir o cabeçalho `Authorization` (segredo configurado no RevenueCat). Inválido → 401.
2. `insert into billing.webhook_events (event_id, …) on conflict do nothing` → se já existia **e** `processed_at` está preenchido, responder 200 (idempotência); se existia com `processed_at` nulo (falhou antes), **processar de novo**.
3. **Não confiar na ordem dos eventos:** buscar o estado atual do assinante na API REST do RevenueCat (`app_user_id`) e reconciliar.
4. `upsert billing.subscriptions` (por `store` + `original_transaction_id`) e `billing.entitlements` (`active_until` = expiração, incluindo a carência da loja quando o status for `in_grace_period`).
5. `select private.refresh_sync_access()` (ou atualização pontual do usuário) → concede/revoga o bucket do PowerSync.
6. Marcar `processed_at`; em erro, gravar `error` e responder 500 (o RevenueCat reenvia).
7. Responder em < 2 s (trabalho pesado em fila, se necessário).

Eventos tratados (todos reconciliados pelo estado atual): compra inicial, renovação, cancelamento (desligou a renovação), reativação, problema de cobrança, troca de produto, expiração, pausa (Android), transferência, extensão, reembolso/revogação, eventos de teste do painel.

(G04, revisão) A **transferência** (`TRANSFER`) não traz `app_user_id`: a Edge Function busca e aplica o estado de cada conta de `transferred_from` e `transferred_to`. No banco, uma compra com id da loja (Play) pertence a uma conta só — restaurada em outra, o dono anterior perde o Pro na hora; sem id da loja (App Store na API v1: "produto@data da compra"), a chave é por usuário e a assinatura que sumiu do estado do RevenueCat sai do banco. Estado buscado antes do último aplicado (webhooks do mesmo usuário em paralelo) é ignorado.

**Sandbox (D-48):** a revisão da Apple e o TestFlight compram em **sandbox** — se o backend de produção recusasse sandbox, o revisor não conseguiria testar o Pro e o app seria rejeitado. Por isso o sandbox **libera** o Pro também em produção, mas fica marcado (`billing.entitlements.environment = 'sandbox'`) e fora dos relatórios de receita; um alerta avisa se aparecer sandbox em conta que não é de teste.

## 6. O que o Pro libera (e onde é verificado)

| Recurso | Grátis | Pro | Verificação no servidor |
|---|---|---|---|
| Ler, grifar, anotar à mão, metas, scanner, busca no catálogo próprio | ✅ (local) | ✅ | — (local) |
| Sincronizar dados pessoais / 2º aparelho | ❌ | ✅ | `sync_apply_changes` exige Pro; bucket do PowerSync só com `sync_access` |
| Guardar e-books na nuvem (2 GB) | ❌ | ✅ | política do bucket `ebooks` + Edge Function de upload |
| Estatísticas mês/ano/comparação, cards para compartilhar | só semana | ✅ | local (dados do aparelho); sem dado sensível no servidor |
| Ver perfis e posts de outras pessoas | prévia | ✅ | RLS `can_view_profile_content` + `profile_preview` |
| Criar clubes | 1 | ilimitados | trigger `clubs_before_insert` |
| Personalização da carteirinha | padrão | exclusivas + selo | coluna/flag no perfil verificada por RLS (quando a tela existir) |
| Consultas externas de ISBN | 30/dia | 150/dia | `private.consume_quota` na Edge Function |
| Exportar | ver D-24 | tudo | Edge Function `export-data` |

## 7. Momentos de upgrade (paywall) — do doc de monetização

Marcos de valor (10 livros na estante, 50 grifos, 30 dias de sequência: "Sua estante só existe neste celular"); tocar em "Ver estatísticas completas"; entrar com a conta num 2º aparelho; criar o 2º clube; tocar no perfil de outra pessoa ("Assine para ver tudo"). Regras: no máximo 1 paywall espontâneo por semana; nunca durante a leitura; sempre com "Agora não". **A tela de paywall não está no arquivo** → aguarda o design das telas 01–18 (ou um arquivo novo). Sem design, nada de paywall inventado (só o placeholder técnico para testar a compra em sandbox).

## 8. Fim do Pro e retenção

- Cancelou → continua Pro até o fim do período (e da carência, se houver).
- Expirou → `entitlements.active_until` no passado → sync revogado; o app avisa "Seus dados continuam neste celular. Na nuvem, ficam guardados até <data>" (texto final depende do design).
- 12 meses depois do fim → `private.run_retention` apaga os dados pessoais da nuvem; e-mail 30 dias antes (`retention_warning`) e depois (`retention_purged`).
- Pedido de exclusão de conta → imediato, mesmo dentro dos 12 meses (LGPD), incluindo `DELETE` do assinante no RevenueCat e arquivos do Storage.

## 9. Testes

- Sandbox: Google Play (testadores de licença, faixa de teste interno) e App Store (Sandbox + arquivo de configuração StoreKit para testes locais).
- Casos obrigatórios: compra mensal, compra anual, teste grátis (elegível e não elegível), cancelar e expirar, carência por falha de cobrança, restaurar em outro aparelho, trocar mensal→anual, reembolso, webhook duplicado, webhook fora de ordem, app offline durante a compra, compra com outro usuário logado no aparelho.
- Testes automatizados da Edge Function (Deno) com payloads de exemplo do RevenueCat + banco local (`supabase start`).

## 10. Números de referência (doc de monetização v3, câmbio de 02/10/2026)

Taxa de loja 15 % (programas para pequenas empresas / assinaturas); RevenueCat grátis até US$ 2.500/mês de receita rastreada e 1 % acima (conferir o preço vigente na G22).

**Ponto de equilíbrio da infraestrutura (refeito com o PowerSync):** custos fixos ≈ Supabase Pro US$ 25 (R$ 130) + PowerSync Cloud Pro US$ 49 (R$ 256) + Workers US$ 5 (R$ 26) + Apple US$ 99/ano (R$ 43/mês) ≈ **R$ 455/mês** (US$ 1 = R$ 5,22; Sentry, PostHog e Resend nos planos gratuitos no início — conferir limites). Receita líquida por assinante ≈ R$ 8,49/mês no mensal (R$ 9,99 − 15 %) e ≈ R$ 5,67/mês no anual (R$ 79,99 ÷ 12 − 15 %) → equilíbrio entre **≈ 54 e 80 assinantes**, conforme a mistura mensal/anual. Com PowerSync self-host (uma VM pequena em São Paulo), ≈ 25–35. O doc v3 dizia ≈ 21 porque não contava o PowerSync. Peso da infraestrutura na receita bruta (cenários do doc v3, com PowerSync Cloud): **≈ 13 % na tração** (10 mil usuários, 400 assinantes: ≈ R$ 508 de R$ 3.960) e **≈ 3 % no crescimento** (50 mil, 2.500 assinantes: ≈ R$ 780 de R$ 24.750); com PowerSync self-host, a tração cai para ≈ 9 %.
