# Navegação do BookNest — rotas, toques das telas prontas, o mapa e como chegar

Feita na R00 (R00.5, regra R4). Diz, para as **16 telas prontas** (01, 01b, 60, 19–27b, 25 — `docs/design/projeto/COBERTURA.md`),
o que cada toque faz hoje, e onde cada rota do app está no caminho até a v1.0. A R01 (integração final) troca todos os 🟡
pela tela de verdade e liga o que falta do Mapa de navegação (tela 00).

**As classes (R4):**

- ✅ **leva à tela certa** — a tela (ou a camada: folha, painel, modo) que o design mostra;
- ⏸ **sem ação por decisão** — o toque existe e não faz nada até a etapa dele (a D-243 b), com a decisão;
- 🟡 **leva a um placeholder** — a tela "em breve" da rota (ou o aviso "Chega numa próxima fase"), com a etapa que a troca.

**A prova (R5):** `test/app/navegacao_test.dart` percorre a tabela (b) inteira no app (a Início da prancha 01 e o leitor e os
grifos do banco do modo demonstração — o alvo (2) da D-267): cada ✅ chega ao destino, cada ⏸ não muda a rota nem a árvore,
cada 🟡 é alcançado e listado na saída. O mesmo percurso roda no Galaxy S22+ (`integration_test/navegacao_test.dart`) e
`test/design/navegacao_doc_test.dart` confere esta tabela com a lista do teste (`test/support/navegacao.dart`), linha a linha.

## (a) As rotas

As rotas de `lib/app/router.dart`. As abas ficam num `StatefulShellRoute` (cada aba guarda a própria pilha e a rolagem);
as outras abrem por cima, no navigator raiz (D-08).

| Rota | O que mostra hoje | Telas do projeto que vão para lá | Etapa que troca |
|---|---|---|---|
| `/inicio` (aba) | a Início nova (01, 01b, 60) ✅; o primeiro acesso e os estados sem prancha (`home_states.dart`) | 01, 01b, 60 ✅ · 36a 🟠 | T16 (36a), T05 (o cartão da revisão ligado) |
| `/biblioteca` (aba) | placeholder "Biblioteca" com o bloco mínimo de importar EPUB/PDF (D-87) | 02, 36 | T14 |
| `/clubes` (aba) | placeholder "Clubes" | 04 | T07 |
| `/perfil` (aba) | placeholder "Perfil" com o bloco mínimo da conta (D-69): exportar, sair, excluir | 05 · 58, 59 🟠 | T17 |
| `/scanner` | o scanner provisório no estilo do app (D-76): câmera num cartão, o livro achado | 03, 39, 40, 41, 42, 69, 69b, 28d 🟠 | T15 |
| `/notificacoes` | placeholder "Notificações" | 30, 30c | T17 |
| `/leitor/:bookId` (`?ir=` salta a uma anotação) | o leitor de verdade ✅ | 19, 20, 21, 22, 23, 23b, 24, 24b, 26, 26b, 27, 27b ✅ | — (a busca dentro do livro, sem prancha, é da T15 — D-268) |
| `/livro/:bookId` | placeholder "Livro" | 17, 17b | T14 |
| `/livro/:bookId/destaques` (`?de=leitor`) | a tela 25 de verdade ✅ | 25 ✅ | — |
| `/para-voce` | placeholder "Para você" | Coleções · ver todas (falta no projeto — D-268) | T14 |
| `/clube/:clubId/discussao` | placeholder "Discussão" | 31 | T08 |
| `/entrar` | o Entrar mínimo (D-21): e-mail e código de 6 dígitos | 07, 10 🟠 | T16 |
| `/conta/cadastro` | a conclusão do cadastro mínima (D-21): o @ | 15 🟠 | T16 |
| `/_ds` (só na depuração) | a galeria do design system (F01) | — | sai na G27 (não entra no build de loja) |
| `/_pro` (só na depuração) | a tela técnica do Pro (D-230) | 83, 84 🟠 | T19 |
| folha da sessão (sem rota: `PageRouteBuilder` `sessao-papel`, D-256) | a folha mínima da sessão do papel | 18, 18b 🟠 | T18 |

## (b) Os toques das telas prontas

Uma linha por elemento que muda de tela, abre uma camada, leva a um placeholder ou não faz nada por decisão. A origem é
de onde o toque sai (o percurso chega lá antes de tocar); a chave é a `ValueKey` do widget (os gestos sem chave têm um
nome com `@`; as linhas que dependem do livro, um `N`). O que muda um valor dentro da mesma tela está em (b2).

| Origem | Chave | Classe | Leva a | Decisão / etapa |
|---|---|---|---|---|
| `abas` | `nav.home` | ✅ | a Início (de outra aba) | D-07 |
| `abas` | `nav.library` | 🟡 | "Biblioteca" (com o bloco de importar) | T14 · D-87 |
| `abas` | `nav.clubs` | 🟡 | "Clubes" | T07 |
| `abas` | `nav.profile` | 🟡 | "Perfil" (com o bloco da conta) | T17 · D-69 |
| `abas` | `nav.scanner.fab` | ✅ | o scanner (provisório) | D-08, D-76 |
| `abas` | `nav.scanner.label` | ✅ | o scanner (provisório) | D-08, D-76 |
| `inicio` | `header.bell` | 🟡 | "Notificações" | T17 |
| `inicio` | `header.search` | ⏸ | — (a busca 28 é da T15) | D-243 b |
| `inicio` | `hero.cta` | ✅ | o leitor (19) na posição; livro de papel → "Livro" | D-123 |
| `inicio` | `hero.notesButton` | ✅ | os grifos (25) | D-195 |
| `inicio` | `alsoReading.card1.cover` | 🟡 | "Livro" (o papel sem página: só a capa é link) | T14 · D-253 |
| `inicio` | `alsoReading.card2` | 🟡 | "Livro" | T14 · D-79 |
| `inicio` | `alsoReading.card1.play` | ✅ | a 01b: a sessão do papel começa, a mini-barra aparece | D-253, D-262 |
| `inicio` | `today.readNow` | ✅ | a 01b: a sessão do livro de papel mais recente | D-258 |
| `inicio` | `review.cta` | ⏸ | — (a revisão 61 é da T05; o cartão só com a fixture — D-247) | D-243 b |
| `inicio` | `forYou.seeAll` | 🟡 | "Para você" (Coleções · ver todas, que falta no projeto) | T14 · D-268 |
| `inicio` | `forYou.item1` | 🟡 | "Livro" | T14 · D-79 |
| `inicio` | `forYou.item2` | 🟡 | "Livro" | T14 · D-79 |
| `inicio` | `forYou.item3` | 🟡 | "Livro" | T14 · D-79 |
| `inicio` | `club.cta` | 🟡 | "Discussão" (a 31) | T08 |
| `inicio` | `recent.libraryLink` | 🟡 | "Biblioteca" (troca de aba) | T14 |
| `inicio` | `recent.row0.textBlock` | 🟡 | "Livro" | T14 · D-79 |
| `inicio` | `recent.row1.textBlock` | 🟡 | "Livro" | T14 · D-79 |
| `inicio` | `recent.row2.textBlock` | 🟡 | "Livro" | T14 · D-79 |
| `inicio` | `recent.row0.more` | ⏸ | — (o menu ⋯ não tem prancha) | D-243 b |
| `inicio` | `recent.row1.more` | ⏸ | — (o menu ⋯ não tem prancha) | D-243 b |
| `inicio` | `recent.row2.more` | ⏸ | — (o menu ⋯ não tem prancha) | D-243 b |
| `inicio01b` | `miniBar` | ✅ | a folha da sessão (no lugar da 18) | D-256 |
| `folha` | `session.sheet.close` | ✅ | fecha: volta à 01b, a sessão segue | D-262 |
| `folha` | `session.sheet.veil` | ✅ | fecha: volta à 01b | D-256 |
| `folha` | `session.sheet.discard` | ✅ | a confirmação "Descartar esta sessão?" | D-256 |
| `folha` | `session.sheet.end` | ✅ | encerra com a página: a sessão vai ao banco, a mini-barra sai (no lugar da 18b) | D-256, D-260 |
| `folha.confirmar` | `session.sheet.back` | ✅ | volta à folha | D-256 |
| `folha.confirmar` | `session.sheet.confirmDiscard` | ✅ | descarta: a folha e a mini-barra saem | D-262 |
| `leitor19` | `r19.pagina@meio` | ✅ | os controles (20) | D-117 |
| `leitor19` | `r19.pagina@segurar` | ✅ | a seleção de texto (21) | D-45, D-136 |
| `leitor20` | `r20.topIsland.close` | ✅ | fecha o livro: a Início | D-117 |
| `leitor20` | `r20.topIsland.search` | ✅ | a busca no livro (sem prancha; a da T15 é a que falta) | D-120, D-268 |
| `leitor20` | `r20.bottomIsland.tools.font` | ✅ | os ajustes de leitura (26) | D-141 |
| `leitor20` | `r20.bottomIsland.tools.theme` | ✅ | o Tema Noite com os controles (26b) | D-121 |
| `leitor20` | `r20.bottomIsland.tools.notes` | ✅ | os grifos (25), por cima do leitor | R13 |
| `leitor20` | `r20.bottomIsland.tools.annotate` | ✅ | o modo anotação (22) | D-164 |
| `leitor20` | `r20.bottomIsland.tools.toc` | ✅ | o sumário (27) | — |
| `leitor21` | `r21.toolbar.actions.note` | ✅ | a nota de texto (folha sem prancha) | D-131 |
| `leitor21` | `r21.toolbar.colors.other` | ✅ | "Outra cor" (folha sem prancha) | D-178 |
| `leitor21` | `r21.toolbar.actions.search` | ✅ | a busca no livro com o trecho | D-23 |
| `leitor22` | `ann.done` | ✅ | sai do modo anotação (grava numa transação) | D-42 |
| `leitor22` | `ann.toolShelf.pen` | ✅ | os ajustes da caneta (23) — a ferramenta ativa abre o painel | R1, R4 |
| `leitor22` | `ann.toolShelf.marker` | ✅ | os ajustes do marca-texto (23b) — o 1º toque escolhe, o 2º abre | R1, R4 |
| `leitor22` | `ann.island.colorWell` | ✅ | o painel da ferramenta de tinta (23) | R2 |
| `leitor23` | `ann.penPanel.close` | ✅ | fecha o painel: volta à 22 | — |
| `leitor23` | `ann.fade` | ✅ | o véu fecha o painel: volta à 22 | R3 |
| `leitor23b` | `ann.markerPanel.close` | ✅ | fecha o painel: volta à 22 | — |
| `leitor23b` | `ann.markerPanel.colorsHeader.editLabels` | ✅ | os rótulos das cores (folha sem prancha) | D-177 |
| `leitor26` | `rs.sheet.close` | ✅ | fecha os ajustes: volta à 20 | D-141 |
| `leitor26` | `rs.backdrop` | ✅ | o toque acima da folha fecha os ajustes | D-141 |
| `leitor27` | `toc.sheet.tabs.bookmarks` | ✅ | a aba Marcadas (27b) | D-154 |
| `leitor27` | `toc.sheet.close` | ✅ | fecha o sumário | — |
| `leitor27` | `toc.fade` | ✅ | o véu fecha o sumário | D-141 |
| `leitor27` | `toc.sheet.chapters.chN` | ✅ | vai ao capítulo: o sumário e os controles fecham | D-151 |
| `leitor27` | `toc.sheet.club` | 🟡 | o aviso "Chega numa próxima fase" (a faixa do clube abre a 31) | T08 · D-149 |
| `leitor27b` | `bm.sheet.tabs.chapters` | ✅ | a aba Capítulos (27) | D-154 |
| `leitor27b` | `bm.sheet.close` | ✅ | fecha o sumário | — |
| `leitor27b` | `bm.sheet.bookmarks.item1.link` | ✅ | vai à página marcada | D-151, D-158 |
| `grifos` | `hl.topBar.back` | ✅ | volta ao leitor | R13 |
| `grifos` | `hl.topBar.export` | ✅ | a folha de exportar | D-194 |
| `grifos` | `hl.list.card1.body.quote` | ✅ | o leitor no grifo | D-195 |
| `grifos` | `hl.list.card1.head.more` | ✅ | a folha ⋯ do cartão | D-192 |
| `grifos` | `hl.list.cardN.body.club.chip` | 🟡 | "Discussão" (o grifo compartilhado no clube) | T08 |
| `grifos` | `hl.end.cta` | ✅ | "Continuar lendo": volta ao leitor | D-198 |
| `grifos.mais` | `hl.more.note` | ✅ | a nota do grifo (a folha da nota) | — |
| `grifos.mais` | `hl.more.close` | ✅ | fecha a folha ⋯ | — |
| `grifos.exportar` | `hl.export.cancel` | ✅ | fecha a folha de exportar | — |
| `grifos.exportar` | `hl.export.formats.pdf` | 🟡 | o aviso "Chega numa próxima fase" (o PDF com desenhos é do Pro) | T19 · D-65 |

### (b2) O que muda dentro da mesma tela

Não muda de tela nem abre camada; cada um tem o teste que o prova.

| Tela | Chaves | O que faz | Teste |
|---|---|---|---|
| 01b | `alsoReading.card1.play` (com a sessão), `miniBar.pause`, `session.sheet.toggle` | pausa e retoma a sessão do papel (D-257) | `test/home/inicio01b/toques_test.dart`, `session_sheet_test.dart` |
| 19 | toque no terço da esquerda / da direita, arrastar | vira a página (D-107) | `reader_page_view_test.dart` |
| 19 | toque num link interno, num grifo, numa faixa de nota à mão | segue o link (D-108), seleciona o grifo (D-132), abre a nota (D-184) | `reader_page_view_test.dart`, `reader_screen_g13_test.dart`, `hand_note_mode_test.dart` |
| 20 | `r20.topIsland.bookmark`, `r20.bottomIsland.scrubber` | marca a página (D-124), salta pela barra (D-119) | `reader_screen_g12_test.dart`, `scrubber_test.dart` |
| 21 | `r21.toolbar.colors.yellow` / `pink` / `green` / `lavender` / `underline`, `.actions.copy`, `.actions.share` | grifa, recolore, apaga com desfazer (D-130, D-132); copia e compartilha (D-39) | `highlight_toolbar_test.dart`, `reader_screen_g13_test.dart` |
| 22 | `ann.toolShelf.line` / `eraser` / `lasso` / `space`, `ann.island.width.*`, `ann.island.undo` / `redo` | troca a ferramenta e a espessura, desfaz e refaz (R1, R18); o Espaço abre a 24 arrastando | `tool_shelf_test.dart`, `annotation_island_test.dart`, `reader_screen_g18_test.dart` |
| 23 | `ann.penPanel.tips.*`, `.size.slider`, `.favorites.*`, `.picker.*` | ponta, espessura, cores favoritas (D-175, D-248) | `pen_panel_test.dart` |
| 23b | `ann.markerPanel.styles.*`, `.colors.*`, `.heights.*` | estilo, cor e altura do marca-texto (R18) | `marker_panel_test.dart` |
| 24b | `ann.page.handNote.actions.collapse` / `delete`, `ann.page.handNote.open`, `.handle` | recolhe, apaga com desfazer (D-185), reabre, aumenta (D-186) | `hand_note_mode_test.dart` |
| 26 | `rs.sheet.size.*`, `rs.sheet.fonts.*`, `rs.sheet.papers.*`, `rs.sheet.spacing.*`, `rs.sheet.margins.*` | os ajustes de leitura (D-143, D-144, D-147) | `reader_settings_sheet_test.dart` |
| 27b | `bm.sheet.bookmarks.itemN.ribbon` | tira e devolve a marca (D-152) | `toc_bookmarks_test.dart` |
| 25 | `hl.search`, `hl.types.*`, `hl.filters.colors.*`, `hl.filters.clubOnly`, `hl.empty.clear` | busca e filtros (R1, D-196, D-202, D-203) | `l25a_test.dart`, `l25b_test.dart`, `l25d_test.dart` |
| 25 | `hl.more.colors.*`, `hl.more.delete`, `hl.more.share`, `hl.export.formats.*`, `hl.export.go` | recolore, apaga com desfazer (D-193), compartilha no clube (com conta — G21), exporta (D-194) | `highlight_more_sheet_test.dart`, `highlights_share_flow_test.dart`, `highlight_export_sheet_test.dart` |

### Estados que o mundo de referência não tem

Os toques dos estados sem prancha da Início e do leitor (não entram no percurso: o mundo tem livros e o leitor abre):

| Chave | Estado | Leva a | Teste |
|---|---|---|---|
| `hero.invite.cta` | estante vazia / sem leitura (36a, D-78) | o scanner / a Biblioteca | `test/home/inicio_estados_test.dart` |
| `home.error.retry` | a Início com erro (D-85) | tenta de novo | `test/home/inicio_estados_test.dart` |
| "Tentar de novo" / "Voltar" | o leitor com erro (D-21) | tenta de novo / fecha o livro | `reader_screen_test.dart` |

## (c) O mapa ao lado

As ligações do Mapa de navegação (tela 00) que saem ou chegam às telas prontas (`docs/design/medicao/projeto/mapa_navegacao.json`),
e onde cada uma está no app.

| No mapa | No app hoje |
|---|---|
| 01 Início → 17b Detalhes · e-book | 🟡 os cartões de livro da Início (Também lendo, Para você, Recém-chegados) abrem o placeholder "Livro" — T14 |
| 01 Início → 60 Grifos de hoje | ✅ a 60 é a 01 rolada até o cartão; com dados reais o cartão só volta na T05 (D-247) |
| 01 Início → 30 Notificações | 🟡 o sino abre o placeholder "Notificações" — T17 |
| 01 Início → 28 Busca · explorar | ⏸ a lupa não faz nada (D-243 b) — T15 |
| 01 Início → 107 Convite · Início | ainda não (T23) |
| 17b Detalhes · e-book → 19 Leitor | ainda não (a 17b é da T14); hoje o "Continuar lendo" do herói vai direto à 19 ✅ |
| 20 Controles → 25 Grifos e notas | ✅ `r20.bottomIsland.tools.notes` |
| 20 Controles → 26 Ajustes (Aa) | ✅ `r20.bottomIsland.tools.font` |
| 20 Controles → 27 Sumário | ✅ `r20.bottomIsland.tools.toc` |
| 20 Controles → 22 Modo anotação | ✅ `r20.bottomIsland.tools.annotate` |
| 25 Grifos e notas → 110 Convite · ao enviar | ainda não (T23) |
| A barra de baixo (as 5 áreas) | Início ✅ · Biblioteca 🟡 T14 · Scanner ✅ (provisório, D-76; T15) · Clubes 🟡 T07 · Perfil 🟡 T17 |

## (d) Como chegar no celular

No alvo (1) do modo demonstração (D-267: o app de verdade sobre o banco do demo, com o mundo de referência; o banco do
app normal não é aberto). Pelo computador, com o celular no USB:

```
flutter run --profile -t test/fixtures/main_demonstracao.dart -d RXCT200CA6F
```

`--dart-define=BOOKNEST_DEMO_RECOMECAR=true` apaga o banco e as pastas do demo antes de abrir (o mundo volta ao estado de
referência). **Nunca `flutter install`** (desinstala o app antes — e com ele os dados do app normal); o `flutter drive`
só com `--keep-app-running`; o `flutter test integration_test` só com `--no-uninstall`. A Início igual à prancha (com o
cartão da revisão e o Para você) é o alvo (2): `-t test/fixtures/main_mundo_referencia.dart`.

| Tela | Como chegar |
|---|---|
| 01 | abre na Início, no topo |
| 60 | no alvo (2), rolar a Início até "Seus grifos de hoje" (no alvo (1) o cartão não existe até a T05 — D-247) |
| 01b | em "Também lendo", tocar o play do Brás Cubas: a mini-barra aparece; tocar nela abre a folha da sessão |
| 19 | "Continuar lendo" no herói: o Dom Casmurro na pág. 159 de 256 |
| 20 | na 19, tocar no meio da página |
| 21 | na 19, segurar uma palavra do terço de cima da página |
| 22 | na 20, "Anotar à mão" |
| 23 | na 22, tocar a caneta (a ferramenta ativa) ou o poço de cor |
| 23b | na 22, tocar o marca-texto duas vezes (o 1º escolhe, o 2º abre o painel) |
| 24 | na 22, escolher "Espaço" e arrastar para baixo entre duas linhas, segurando no meio |
| 24b | na 22, na pág. 159: a nota à mão do mundo aberta na página |
| 25 | na 20, "Grifos" (ou, na Início, o botão de notas do herói) |
| 26 | na 20, "Aa Fonte" |
| 26b | na 20, "Tema": o Noite, com os controles |
| 27 | na 20, "Sumário" |
| 27b | no sumário, a aba "Marcadas" |
