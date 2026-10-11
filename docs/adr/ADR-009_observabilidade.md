# ADR-009 — Observabilidade: Sentry (falhas, sem PII, região UE) + PostHog só com consentimento (região UE)

- **Status:** aceita (G02) · aguarda a aprovação da G02 e a **Q8** (ok do Cesar para as duas ferramentas)
- **Data:** 03/10/2026
- **Prova exigida:** política de privacidade compatível (Anexo 05 §2) — conferida contra a documentação dos fornecedores (abaixo) e o mapa de dados do Anexo 02 §12.

## Decisão

1. **Sentry** (`sentry_flutter`) para falhas e desempenho:
   - organização criada na região **UE (Frankfurt)** — a região **não muda depois** de criada (documentação do Sentry);
   - `sendDefaultPii = false`, sem capturas de tela/hierarquia de widgets, sem corpo de requisição;
   - `beforeSend`/`beforeBreadcrumb` removem texto de grifo/nota, títulos de livro, e-mail e tokens (lista
     fechada de chaves permitidas nos eventos);
   - usuário identificado só por um id aleatório por instalação (não o id do Supabase); retenção 90 dias.
   - Base legal: legítimo interesse (diagnóstico) — Anexo 02 §12.
2. **PostHog** (`posthog_flutter`) para métricas de produto, **desligado por padrão** e só ligado com
   consentimento explícito (opt-in) — e nunca para contas de adolescentes enquanto a G25 não decidir (Q13):
   - projeto na **PostHog Cloud UE (Frankfurt)**; "descartar IP do cliente" ligado no projeto;
   - eventos anônimos sem conteúdo (ex.: "livro importado", nunca o título); sem gravação de sessão;
   - revogar o consentimento apaga a pessoa (a API de exclusão do PostHog processa em segundo plano).
3. Logs do app (Anexo 02 §11): sem dado pessoal; nível de log de produção = aviso.
4. **Grátis:** Sentry (sem PII) e PostHog (com consentimento) estão na lista branca do teste de privacidade
   (prompt v2 §4.3.7); qualquer outra chamada com dado pessoal reprova o teste.

## Evidências (documentação consultada em 03/10/2026)

| Item | Fonte | O que vale para o app |
|---|---|---|
| Regiões do Sentry: EUA (Iowa) e UE (Frankfurt); não muda depois de criar a organização | docs.sentry.io — Data Storage Location | criar a organização já na UE |
| PostHog Cloud em EUA e UE (Frankfurt), recomendada a UE para dado pessoal de europeus; opção de descartar o IP; exclusão de pessoa assíncrona | posthog.com/docs/privacy/data-storage | projeto UE + IP descartado + exclusão ao revogar |
| Transferência internacional (LGPD art. 33) | Anexo 02 §12 | Sentry e PostHog entram na política como suboperadores fora do Brasil (UE) |

## Consequências

- A política de privacidade (G25) lista Sentry e PostHog, finalidade, região (UE), retenção e o opt-in.
- O app tem uma tela/opção de consentimento de analytics (sem design no arquivo → D-21 até o design chegar).

## Alternativas consideradas

- **Firebase Crashlytics/Analytics:** dados nos EUA, analytics ligado por padrão, mistura com o FCM — evitado.
- **Self-host do PostHog/GlitchTip:** dados no Brasil, mas operação extra; reavaliar se o volume crescer.

## Pendências

- **Q8:** aprovação do Cesar. Contas criadas por ele (DSN/chaves públicas no `env/*.json` local, fora do git).
