# STATUS — onde estamos

> Atualizado no fim de cada etapa (ROTEIRO §4, item 6). A ordem das etapas está em `docs/ROTEIRO.md`.

**Atualizado em:** 12/10/2026, no fim da etapa 6 · T13 (medição do projeto).

| | |
|---|---|
| **Última etapa concluída** | 6 · T13, medição do projeto (branch `feat/t13-medicao-projeto`, aguardando aprovação) |
| **Próxima etapa** | ▶ **7 · T14, Biblioteca e Detalhes do livro** (+ Coleções · ver todas, Trocar a capa e o título curto da D-270); as fases L já estão em `docs/design/fases/` (`LEIA-ME_projeto.md`) |
| **Depois** | 8 · T15, Scanner e Busca · 9 · T16, Entrada e onboarding |
| **Telas do design** | 128 no projeto · 16 no app e iguais (Início 01, 01b, 60 e as 13 do leitor 19–27b, provadas no celular) · as outras 112 com etapa (`docs/design/projeto/COBERTURA.md`); as 41 das etapas 7–11 medidas na T13 (layouts, PNG, fios de navalha, 360 e 430, fontes, SVGs, tokens, mapa e 73 fases L) · 9 faltando no projeto, cada uma na etapa de quem a abre (D-268) |
| **Branch atual** | `feat/t13-medicao-projeto` (só local, sem push), a partir da `main` em `debd9ed`; a `main` está igual ao `origin/main` (com a R00) |
| **Próxima decisão livre** | D-287 |

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

Os toques de cada tela pronta e onde cada um leva (✅ tela certa · ⏸ sem ação por decisão · 🟡 placeholder, com a etapa
que troca) estão em `docs/NAVEGACAO.md`; o teste `test/app/navegacao_test.dart` percorre as 74 ligações (18 🟡).

### O modo demonstração (D-267)

Para ver as telas prontas com os dados do design, sem mexer nos seus dados, pelo computador com o celular no USB:

```bash
python3 tools/celular/demo.py
```

O script compila o alvo (1) em perfil, confere que o build tem a assinatura do app instalado e que o celular tem
espaço, guarda o APK do seu app normal (em `%LOCALAPPDATA%\booknest\celular\`, fora do repositório), instala por
cima com `adb install -r` e abre o app. Os seus dados ficam onde estão, mas o ícone passa a abrir o demo; para voltar:

```bash
python3 tools/celular/demo.py --voltar
```

É o app de verdade sobre um banco só do demo (`booknest_demo.db` e pastas `*_demo`), com o mundo de referência (dom
20/09/2026 20:00, o relógio anda) e o catálogo do demo (D-269); sem servidor. `--recomecar` instala um build que
recomeça o mundo a cada abertura (rode de novo sem ele depois). A Início igual à prancha: `--alvo 2` (o mesmo banco do
demo). **Nunca `flutter install`** (desinstala o app antes, e com ele os seus dados). O `flutter run` e o
`flutter drive` também desinstalam quando a instalação por cima falha (outra assinatura, pouco espaço): só depois da
conferência do script, o `flutter drive` só com `--keep-app-running` e o `flutter test integration_test` só com
`--no-uninstall`. A prova das 16 telas lado a lado com as pranchas está em `docs/progresso/R00_celular.md`.

## Histórico

| Data | Etapa | Commit | Observação |
|---|---|---|---|
| até 09/10/2026 | 0 · G00–G22 | `cd55500` (G22) | base, leitor, dados, conta, sync, social, Pro técnico |
| 10/10/2026 | 1 · T01 | branch `feat/t01-leitor-acertos` | leitor 23–24b |
| 10/10/2026 | 2 · T02 | `f449f14` | medição da Início e da revisão |
| 10/10/2026 | 3 · T03 | `6b14a57` | Início nova |
| 10/10/2026 | 4 · T04 | `7754c53` | cronômetro do livro de papel |
| 10/10/2026 | — | — | roteiro único criado; projeto completo do design baixado; decisões: abas primeiro, 128 telas na v1.0 |
| 11/10/2026 | 5 · R00 | `debd9ed` (na `main`) | `main` em dia; 35/35 pranchas iguais no projeto; cobertura das 128; mapa e `NAVEGACAO.md`; percurso das 74 ligações; modo demonstração (D-267, D-269); as 16 telas no Galaxy S22+; D-268, D-270 |
| 11–12/10/2026 | 6 · T13 | branch `feat/t13-medicao-projeto` | a ferramenta lê os `.dc.html` (19/19 telas antigas iguais); as 41 telas das etapas 7–11 medidas (ids, layouts, PNG, fios no navegador, 360 e 430); fontes, 198 SVGs com as classes por área, tokens, mapa e 73 fases L; duas rodadas iguais, G01 305/305 e o manifesto da T02 inteiro; D-271…D-286 |
