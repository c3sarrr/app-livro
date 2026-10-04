# spikes/ — G02 · Spikes técnicos

Provas das decisões arriscadas **antes** de construir (prompt mestre v2 §6, G02; Anexo 05 §2).
Nada aqui entra no app: cada spike é um pacote/pasta próprio, fora de `lib/`, com números
e um ADR em `docs/adr/`. O `analysis_options.yaml` da raiz exclui `spikes/**`; cada pacote Dart/Flutter
tem o próprio `analysis_options.yaml` e é analisado/testado dentro da própria pasta.

| Pasta | Pergunta | Onde roda | ADR |
|---|---|---|---|
| `S1_fonte_variavel/` | Literata variável (`opsz`) dá as mesmas larguras/quebras do Chromium? | Chromium no container (referência) + `flutter test` no Windows | ADR-004 (D-17) |
| `S3_paginacao/` | O paginador com `dart:ui` reproduz as 19 linhas da tela 19? Quanto custa por página? Qual N das páginas de referência? | `flutter test` no Windows | ADR-005 (D-19) |
| `S4_tinta/` | Codec BNK1, suavização e custo por ponto (latência em aparelho: pendente) | `dart test` no Windows | ADR-006 |
| `S2_banco_sync/` | PowerSync + SQLite local + RPC `sync_apply_changes`: 10 mil linhas, 2 aparelhos, tabela particionada, os 4 fluxos eliminatórios com modo avião | Postgres 16 + serviço PowerSync + clientes no container; drift/FTS5 no Windows | ADR-002 · ADR-003 |
| `S5_pagamentos/` | Webhook do RevenueCat (Edge Function) contra o banco local: idempotência, fora de ordem, sandbox, reembolso (compra real: pendente) | Deno + Postgres 16 no container | ADR-007 |

Dados baixados (EPUB de domínio público de *Dom Casmurro*, Project Gutenberg #55752) ficam em
`spikes/_dados/` (fora do git); os scripts conferem o sha256.

```powershell
# EPUB real (Windows)
Invoke-WebRequest https://www.gutenberg.org/ebooks/55752.epub3.images -OutFile spikes\_dados\pg55752.epub
# sha256 esperado: 847b26bbc6bfefcf7cc323a94eacefd3c7a9657e66749cb360b77b34a3e994fd
```
