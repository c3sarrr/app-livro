# docs/adr — Registros de decisão de arquitetura

Formato: contexto → decisão → evidências (com os números do spike) → consequências → alternativas →
pendências → como reproduzir. Uma decisão só vira definitiva depois que o Cesar aprova a fase que a provou;
mudança posterior = ADR novo que **substitui** o antigo (o antigo fica, marcado "substituído por").

| ADR | Assunto | Prova | Status |
|---|---|---|---|
| [ADR-001](ADR-001_backend.md) | Backend: Supabase em `sa-east-1` | SQL de referência 23/23 | aceita (G02) |
| [ADR-002](ADR-002_banco_local.md) | Banco local: SQLite do PowerSync + drift dono do esquema (tabelas próprias) | spike S2 | aceita (G02) — muda o Anexo 02 §3.1 |
| [ADR-003](ADR-003_sincronizacao_pro.md) | Sincronização Pro: PowerSync (Sync Streams + tabelas próprias) + RPC | spike S2 | aceita (G02) — muda o Anexo 02 §3.1/§6 |
| [ADR-004](ADR-004_fonte_do_leitor.md) | Fonte do leitor: Literata variável com `opsz` explícito | spike S1 | aceita (G02) |
| [ADR-005](ADR-005_paginacao.md) | Paginação: motor próprio com `dart:ui`, modelo vertical exato e pintura por linha | spike S3 | aceita (G02) — muda o Anexo 03 §7.1 |
| [ADR-006](ADR-006_tinta.md) | Tinta: `Listener` + suavização própria + BNK1 | spike S4 (simulado) | aceita com pendência |
| [ADR-007](ADR-007_pagamentos.md) | Pagamentos: RevenueCat + webhook | spike S5 (simulado) | aceita com pendência |
| [ADR-008](ADR-008_catalogo_isbn.md) | Catálogo/ISBN em camadas (BrasilAPI primeiro) | amostra real (300 ISBNs) | aceita (G02) |
| [ADR-009](ADR-009_observabilidade.md) | Observabilidade: Sentry (UE, sem PII) + PostHog opt-in (UE) | documentação dos fornecedores | aceita (G02) — depende da Q8 |
| [ADR-010](ADR-010_notificacoes.md) | Notificações: FCM/APNs + locais | aparelho (pendente) | aceita com pendência |
