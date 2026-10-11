# handoff_v2 — BookNest: Leitor (telas 19–27b) + dados reais + nuvem + assinatura

Pacote de trabalho para a próxima etapa do app de leitura em Flutter (`app_livros`). Continua o pacote `design_handoff/` (tela Início, fases F00–F13 — não mexer nele).

## Como usar

1. Responda as perguntas do `05_DECISOES_E_PERGUNTAS.md` §4 que puder (principalmente Q1, Q5, Q12 e Q13).
2. Abra uma sessão nova do Claude com a pasta `app_livros` conectada e cole o `00_PROMPT_MESTRE_V2.md` inteiro.
3. O agente faz uma fase por vez (G00, G01, …), entrega relatório e para. Responda "OK, próxima fase".

## Conteúdo

| Arquivo/pasta | O que é |
|---|---|
| `00_PROMPT_MESTRE_V2.md` | Papel, estado do repositório, regras, arquitetura, **fases G00–G28** com checklists, verificação, relatório, ordem recomendada |
| `01_INVENTARIO_TELAS.md` | As 13 pranchas do arquivo novo, tela por tela: elementos, textos, interações, dados, armadilhas; mapa de navegação; consistência entre telas; telas 01–18 pendentes |
| `02_ARQUITETURA_DADOS.md` | Onde mora cada dado (aparelho / nuvem / Pro / catálogo), banco local, modelo de domínio, Supabase, RLS, sincronização PowerSync, catálogo e scanner, rotinas, volumes, segurança, LGPD |
| `03_MOTOR_DO_LEITOR.md` | EPUB/PDF, conteúdo canônico, localizadores e âncoras, páginas de referência, paginação, tempo de leitura, seleção, tinta (ferramentas, ancoragem, codec), busca, acessibilidade, orçamentos |
| `04_ASSINATURA_E_PAGAMENTOS.md` | Produtos, RevenueCat, fluxos, webhook, o que o Pro libera, paywall, retenção, testes |
| `05_DECISOES_E_PERGUNTAS.md` | Decisões propostas D-16…D-53 (inclui a lista de divergências conhecidas do arquivo), ADRs a provar, dependências novas, **perguntas Q1–Q13** |
| `sql/` | Esquema Supabase de referência + stub local (com os privilégios padrão do Supabase) + testes de fumaça (**23/23 OK** num Postgres 16 em 03/10/2026, incluindo ataques com JWT forjado) |
| `referencia/original/` | O HTML do Claude Design (13 pranchas) — fonte da verdade |
| `referencia/extraido/` | Marcação literal de cada prancha (sem os `@font-face`) |
| `referencia/previa/` | Prévias @2x renderizadas no Chromium — **não medidas**, só orientação |
| `referencia/fontes_do_arquivo/` | Os 6 binários de fonte embutidos no arquivo (licença OFL) |

## Rodar os testes do SQL (opcional, precisa de Postgres 16+ local)

```bash
createdb booknest_teste
psql -d booknest_teste -v ON_ERROR_STOP=1 -f sql/00_stub_supabase_local.sql
psql -d booknest_teste -v ON_ERROR_STOP=1 -f sql/01_schema_booknest.sql
psql -d booknest_teste -v ON_ERROR_STOP=1 -f sql/02_testes_rls.sql   # termina com "TODOS OS TESTES PASSARAM"
```
O stub simula `auth`, `storage` e os papéis do Supabase; no projeto real use `supabase start` e as migrations da G04.

## Achados importantes do arquivo novo

- O arquivo tem só as pranchas **19 a 27b** (todas do Leitor + "Grifos e notas"); as telas 01–18 não vieram.
- **Figtree 800 é 800 de verdade** aqui (na Início renderizava 700) — medido no Chromium.
- **Literata** (texto do livro) é variável com *optical size*; o navegador usa `opsz = tamanho`.
- Os números de exemplo das telas são coerentes entre si (12 anotações = 6 + 2 + 1 + 3; páginas do sumário batem com a lista de grifos; "faltam 18" = cap. 50 − 32) — viram testes da fixture.
- Exceção: as contagens por rótulo do marca-texto (5/3/2/2) só fecham se forem de **todos os livros** (D-40).
