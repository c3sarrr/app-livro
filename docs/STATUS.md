# STATUS — onde estamos

> Atualizado no fim de cada etapa (ROTEIRO §4, item 6). A ordem das etapas está em `docs/ROTEIRO.md`.

**Atualizado em:** 10/10/2026, quando o roteiro único foi criado e o projeto completo do design (128 telas) entrou em
`docs/design/projeto/`.

| | |
|---|---|
| **Última etapa concluída** | 4 · T04, cronômetro do livro de papel (commit `7754c53`, 10/10 22:56) |
| **Próxima etapa** | ▶ **5 · R00, Arrumação** (ROTEIRO §7) |
| **Depois** | 6 · T13, medição do projeto · 7 · T14, Biblioteca e Detalhes do livro |
| **Telas do design** | 128 no projeto · 16 já no app (Início 01, 01b, 60 e as 13 do leitor 19–27b) · as outras 112 têm etapa |
| **Branch atual** | `feat/t04-cronometro-papel` (limpa, igual ao remoto) |
| **main** | 478 commits atrás, sem nada próprio: avança com `--ff-only` (vai na R00) |
| **Sem commit ainda** | `CLAUDE.md`, `docs/ROTEIRO.md`, `docs/STATUS.md`, `docs/design/projeto/` (vão na R00) |

## O que o app mostra hoje no celular

| Onde | O que aparece | Por quê | Muda na etapa |
|---|---|---|---|
| Aba **Início** | A Início nova (01) | T03 | revisão na 12 · T05 |
| Mini-barra do cronômetro | Só com sessão aberta: "play" de um livro de **papel** em "Também lendo" ou "Ler agora" | T04 | tela cheia na 11 · T18 |
| **Leitor** (19–27b) e **Grifos** (25) | Iguais às pranchas | G11–G20, T01 | — (só abre com um livro importado) |
| Aba **Biblioteca** | Título e botão de importar | ainda não feita | 7 · T14 |
| **Scanner** | Provisório | ainda não feito | 8 · T15 |
| Entrar e cadastro | Telas mínimas | ainda não feitas | 9 · T16 |
| Aba **Perfil** | Título e bloco da conta | ainda não feito | 10 · T17 |
| Aba **Clubes** | Só o título | ainda não feita | 14 · T07 |
| Livro, Notificações, Discussão | Placeholder | ainda não feitas | 7 · T14 · 10 · T17 · 15 · T08 |

Celular sem livros importados mostra os estados vazios. O modo demonstração da R00 resolve isso (se aprovado).

## Histórico

| Data | Etapa | Commit | Observação |
|---|---|---|---|
| até 09/10/2026 | 0 · G00–G22 | `cd55500` (G22) | base, leitor, dados, conta, sync, social, Pro técnico |
| 10/10/2026 | 1 · T01 | branch `feat/t01-leitor-acertos` | leitor 23–24b |
| 10/10/2026 | 2 · T02 | `f449f14` | medição da Início e da revisão |
| 10/10/2026 | 3 · T03 | `6b14a57` | Início nova |
| 10/10/2026 | 4 · T04 | `7754c53` | cronômetro do livro de papel |
| 10/10/2026 | — | — | roteiro único criado; projeto completo do design baixado; decisões: abas primeiro, 128 telas na v1.0 |
