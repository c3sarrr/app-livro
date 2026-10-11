# L00 — Início e revisão: tokens novos e mapa id → widget (insumo das T03–T05)

> Gerado por `tools/medicao/tokens_widgets.py` (T02, `CONJUNTO=inicio2`) a partir das medições das 6 pranchas (01, 01b, 60, 61, 62, 63) e dos tokens atuais do app (`lib/core/design_system/tokens/`). Dados completos: `docs/design/medicao/inicio2/tokens_inicio2.json` e `docs/design/medicao/inicio2/mapa_widgets.json`.

## O que as T03–T05 precisam no design system (achados da medição)

- Fontes (D-246): nas 01, 01b e 60 a Figtree 800/900 renderiza **700** (o arquivo declara até 700 — `AppFonts.figtree` como hoje); nas 61–63 o 800 é real (`Figtree-ExtraBold.ttf`, já existe; 900 → 800).
- Famílias novas geradas na T02 (`tools/fonts/fontes_inicio2.json`): `Bricolage14` (63), `Bricolage32` (62), `Literata15` Regular (62; a família já tinha o Medium) e `Literata22` (61) — `AppFonts.bricolageOpsz`, `literataStatic` e o pubspec ganham esses tamanhos na fase que os usa. A Bricolage 11 usa a 12 (o eixo opsz começa em 12). A Instrument Serif é estática: os tamanhos novos (20, 24, 25, 40 e 64 itálico) usam os arquivos que já existem.
- SVG: 16 desenhos já existem como asset (Início v1 e leitor) e o catálogo aponta para eles; 27 novos em `assets/icons/inicio2/`, `assets/illustrations/inicio2/` e dois gráficos em `docs/design/medicao/inicio2/svg_graficos/` (anel do livro e mostrador da meta → CustomPainter). Classes propostas: `AppIconsInicio` e `AppIllustrationsInicio`.
- Capas: só a do herói (Dom Casmurro) e a da mini-barra (Brás Cubas com asas) são SVG — com `<text>` e `slice` (armadilha no catálogo); as demais capas e os cartões da revisão são CSS (div, borda, raio, círculo) → widgets compostos.
- Sombras "anel": o aro coral do "pausar" (`0 0 0 3 #FF552E`) e o aro duplo da cor marcada na 63 = `BoxShadow(spreadRadius: N, blurRadius: 0)`; aro duplo = duas sombras.
- Grifo por linha (`box-decoration-break: clone`) em rosa 95 % (61, 62) e creme (63): o pintor de grifo do leitor (G13) serve.
- `{{brand}}` (lavanda) pinta o herói, o Início ativo, o progresso da mini-barra, o "Mais vezes", o segmento atual da 61, a pílula da sequência na 62 e o botão do interruptor ligado na 63 — sempre a prop, nunca a cor fixa.

## Cores (52; 13 ainda não existem em `AppColors`)

| cor | já existe | nome proposto | usos | telas | exemplo |
|---|---|---|---|---|---|
| `#1A1714` | ink |  | 555 | 001, 001b, 060, 061, 062, 063 | `i01.header.avatar` |
| `#FFFAF1` | surface |  | 149 | 001, 001b, 060, 061, 062, 063 | `i01.header.search` |
| `#5B544B` | inkMuted |  | 65 | 001, 001b, 060 | `i01.header.greeting` |
| `#F7F0E3` | paper |  | 52 | 001, 001b, 060, 061, 062, 063 | `i01.frame` |
| `#B6ACE4` | lavender |  | 49 | 001, 001b, 060, 061, 062, 063 | `i01.hero` |
| `#EFE6D4` | hatch |  | 42 | 001, 001b, 060 | `i01.today.week.bar0` |
| `#FED170` | sun |  | 33 | 001, 001b, 060, 061, 062, 063 | `i01.header.avatar` |
| `#FFC1C6` | blush |  | 25 | 001, 001b, 060, 061, 062, 063 | `i01.alsoReading.card2.cover` |
| `#ABCF82` | leaf |  | 22 | 001, 001b, 060, 061, 062, 063 | `i01.review.art.card1.line0` |
| `#FF552E` | flame |  | 17 | 001, 001b, 060 | `i01.header.bell.dot` |
| `#E4DACA` | — | reviewLineNeutral (traços dos cartõezinhos da revisão) | 17 | 001, 060, 062 | `i01.review.art.card1.line2` |
| `#000000@0.18` | spine18 |  | 9 | 001, 001b, 060 | `i01.alsoReading.card1.cover.spine` |
| `#000000@0.12` | spine12 |  | 9 | 001, 001b, 060 | `i01.alsoReading.card2.cover.spine` |
| `#058CD7` | azure |  | 7 | 001, 001b, 060 | `i01.alsoReading.card1.cover` |
| `#E2D7C4` | markerRowBorder |  | 7 | 001, 001b, 060, 063 | `i01.alsoReading.card1.meta` |
| `#2F2A40` | inkPlum |  | 6 | 001, 001b, 060 | `i01.hero.author` |
| `#1A1714@0.14` | decoRing |  | 6 | 001, 001b, 060 | `i01.today.decoCircleLarge` |
| `#4A4238` | inkWarm |  | 6 | 001, 001b, 060 | `i01.today.dial.caption` |
| `#FFFAF1@0.7` | chipGlass |  | 6 | 001, 001b, 060 | `i01.today.chip.sessions` |
| `#FDE2B2` | hatchToday |  | 6 | 001, 001b, 060 | `i01.today.week.bar6` |
| `#00995E` | emerald |  | 6 | 001, 001b, 060 | `i01.forYou.item3.cover` |
| `#E9E1D2` | divider |  | 6 | 001, 001b, 060 | `i01.recent.row0` |
| `#E9DFCC` | hatchReader |  | 6 | 061 | `rv61.header.progress.step2` |
| `#000000@0` | — | — | 6 | 061, 062, 063 | `rv61.deck.card.quote.mark` |
| `#552CB7` | violet |  | 5 | 001, 001b, 060, 061, 062 | `i01.hero.cover` |
| `#F7F0E3@0` | paperTransparent |  | 4 | 001, 001b, 060, 062 | `i01.bottomFade` |
| `#2A2520` | bookText |  | 4 | 061, 062 | `rv61.deck.card.quote` |
| `#FFC1C6@0.95` | — | highlightPink @ 0,95 (grifo da revisão) | 4 | 061, 062 | `rv61.deck.card.quote.mark` |
| `#000000@0.22` | spine22 |  | 3 | 001, 001b, 060 | `i01.hero.cover.spine` |
| `#6F665B` | labelReader |  | 3 | 001, 060, 062 | `i01.review.kicker` |
| `#000000@0.15` | spine15 |  | 3 | 001, 001b, 060 | `i01.forYou.item1.cover.spine` |
| `#4A2F33` | stubLabel |  | 3 | 001, 001b, 060 | `i01.club.stub.label` |
| `#ECE7FA` | tagLavenderBg |  | 3 | 001, 001b, 060 | `i01.recent.row0.tag` |
| `#3B2D86` | tagLavenderFg |  | 3 | 001, 001b, 060 | `i01.recent.row0.tag` |
| `#E1EDD0` | — | tagReadBg (pílula "Lido") | 3 | 001, 001b, 060 | `i01.recent.row1.tag` |
| `#2E5314` | — | tagReadText (pílula "Lido") | 3 | 001, 001b, 060 | `i01.recent.row1.tag` |
| `#F2A815` | amber |  | 3 | 001, 001b, 060 | `i01.recent.row2.cover` |
| `#EFE7D7` | tagSandBg |  | 3 | 001, 001b, 060 | `i01.recent.row2.tag` |
| `#8A8073` | readerFooterNight |  | 3 | 061 | `rv61.deck.card.footer.when` |
| `#FFFAF1@0.85` | — | surface @ 0,85 (fita da nota) | 2 | 061, 062 | `rv61.deck.card.note.tape` |
| `#5B4A1C` | noteLabel |  | 2 | 061, 062 | `rv61.deck.card.note.label` |
| `#3E2A2D` | — | shareInkPink (textos da prévia rosa) | 2 | 063 | `rv63.sheet.preview.author` |
| `#1A1714@0.35` | dialTick |  | 1 | 001b | `i01b.miniBar` |
| `#B9AE9C` | — | miniBarKicker ("LENDO · PAPEL") | 1 | 001b | `i01b.miniBar.kicker` |
| `#CFC3AE` | dashReader |  | 1 | 061 | `rv61.deck.card.footer` |
| `#8A7F63` | tipDash |  | 1 | 062 | `rv62.summary.tomorrow` |
| `#3D3830` | tipText |  | 1 | 062 | `rv62.summary.tomorrow.text` |
| `#1A1714@0.25` | — | ink @ 0,25 / 0,35 (sombras do CTA e da mini-barra) | 1 | 062 | `rv62.footer.cta` |
| `#2B2521` | — | scrimShare (fundo da 63) | 1 | 063 | `rv63.scrim` |
| `#D9CFBD` | — | sheetHandle | 1 | 063 | `rv63.sheet.handle` |
| `#EDE4D3` | — | toggleDivider | 1 | 063 | `rv63.sheet.toggles.note` |
| `#F1E7D5` | — | toggleTrackOff | 1 | 063 | `rv63.sheet.toggles.note.switch` |

Notas: `@a` = alfa; cores de degradê (roda de cores, véus) entram como paradas do gradiente do pintor, não como tokens soltos. `#000000@0` = `transparent` dos degradês.

## Raios

| raio | já existe | usos | exemplos |
|---|---|---|---|
| 999px | pill | 129 | `i01.hero.pagePill`, `i01.hero.formatPill`, `i01.hero.progressBar` |
| 50% | — | 98 | `i01.header.avatar`, `i01.header.search`, `i01.header.bell` |
| 3px | — | 30 | `i01.review.art.card1.line0`, `i01.review.art.card1.line1`, `i01.review.art.card1.line2` |
| 28px | card | 17 | `i01.hero`, `i01.today`, `i01.review` |
| 3px 7px 7px 3px | — | 15 | `i01.alsoReading.card1.cover`, `i01.alsoReading.card2.cover`, `i01.recent.row0.cover` |
| 20px | navItem | 15 | `i01.nav.home`, `i01.nav.library`, `i01.nav.scanner` |
| 2px | — | 15 | `rv62.summary.art.card1.line0`, `rv62.summary.art.card1.line1`, `rv62.summary.art.card1.line2` |
| 4px 10px 10px 4px | — | 12 | `i01.hero.cover`, `i01.forYou.item1.cover`, `i01.forYou.item2.cover` |
| 22px | cardM | 11 | `i01.alsoReading.card1`, `i01.alsoReading.card2`, `i01.today.week` |
| 6px | — | 9 | `i01.forYou.item2.cover.line1`, `i01.forYou.item2.cover.line2`, `i01.forYou.item2.cover.line3` |
| 10px | — | 8 | `i01.review.art.card1`, `i01.review.art.card2`, `i01.review.art.card3` |
| 18px | — | 7 | `rv62.summary.tomorrow`, `rv63.sheet.preview`, `rv63.sheet.toggles` |
| 9px | — | 5 | `rv62.summary.art.card1`, `rv62.summary.art.card2`, `rv62.summary.art.card3` |
| 2px 2px 0px 0px | — | 3 | `i01.alsoReading.card1.cover.hat`, `i01b.alsoReading.card1.cover.hat`, `i60.alsoReading.card1.cover.hat` |
| 34px 34px 0px 0px | — | 3 | `i01.forYou.item3.cover.archOuter`, `i01b.forYou.item3.cover.archOuter`, `i60.forYou.item3.cover.archOuter` |
| 14px 14px 0px 0px | — | 3 | `i01.forYou.item3.cover.archInner`, `i01b.forYou.item3.cover.archInner`, `i60.forYou.item3.cover.archInner` |
| 24px | list | 3 | `i01.recent.list`, `i01b.recent.list`, `i60.recent.list` |
| 13px 13px 0px 0px | — | 3 | `i01.recent.row2.cover.arch`, `i01b.recent.row2.cover.arch`, `i60.recent.row2.cover.arch` |
| 26px | — | 3 | `rv61.deck.behind2`, `rv61.deck.behind1`, `rv61.deck.card` |
| 16px | — | 3 | `rv62.summary.stats.more`, `rv62.summary.stats.less`, `rv62.summary.stats.newNote` |
| 1.5px 3px 3px 1.5px | — | 2 | `rv61.deck.card.top.book.spine`, `rv62.summary.newNote.top.book.spine` |
| 0px 4px 4px 0px | — | 1 | `i01b.miniBar.progress` |
| 2px 5px 5px 2px | — | 1 | `i01b.miniBar.cover` |
| 32px 32px 0px 0px | — | 1 | `rv63.sheet` |

## Bordas

| borda | já existe (AppStrokes) | usos | exemplos |
|---|---|---|---|
| 1.5px solid | regular | 202 | `i01.header.avatar`, `i01.header.search`, `i01.header.bell` |
| 1.2px solid | thin | 51 | `i01.alsoReading.card1.meta`, `i01.alsoReading.card2.meta`, `i01.today.chip.sessions` |
| 1.3px solid | — | 10 | `rv61.header.progress.step0`, `rv61.header.progress.step1`, `rv61.header.progress.step2` |
| 1px solid | divider | 7 | `i01.recent.row0`, `i01.recent.row1`, `i01b.recent.row0` |
| 1.5px dashed | regular | 6 | `i01.today.week.goalLine`, `i01.club.stub`, `i01b.today.week.goalLine` |
| 1.4px solid | — | 5 | `rv62.summary.art.card1`, `rv62.summary.art.card2`, `rv62.summary.art.card3` |
| 1.1px solid | — | 2 | `rv61.deck.card.top.tag.dot`, `rv62.summary.newNote.top.tag.dot` |
| 1px dashed | divider | 1 | `rv61.deck.card.footer` |
| 1.3px dashed | — | 1 | `rv62.summary.tomorrow` |
| 1.2px dashed | thin | 1 | `rv63.sheet.preview.footer` |

## Sombras (todas sem desfoque)

| sombra | usos | exemplos |
|---|---|---|
| `#1A1714 2px 2px 0px 0px` | 21 | `i01.alsoReading.card1.cover`, `i01.alsoReading.card2.cover`, `i01.review.art.card1` |
| `#1A1714 4px 4px 0px 0px` | 9 | `i01.hero`, `i01.today`, `i01.review` |
| `#1A1714 3px 3px 0px 0px` | 6 | `i01.hero.cover`, `i01b.hero.cover`, `i60.hero.cover` |
| `#1A1714 0px 4px 0px 0px` | 6 | `i01.nav`, `i01.nav.scanner.fab`, `i01b.nav` |
| `#FF552E 0px 0px 0px 3px` | 1 | `i01b.alsoReading.card1.play` |
| `#1A1714@0.35 0px 4px 0px 0px` | 1 | `i01b.miniBar` |
| `#1A1714@0.25 0px 4px 0px 0px` | 1 | `rv62.footer.cta` |
| `#1A1714 5px 5px 0px 0px` | 1 | `rv63.sheet.preview` |
| `#FFFAF1 0px 0px 0px 2.5px, #1A1714 0px 0px 0px 4px` | 1 | `rv63.sheet.colors.pink` |

## Estilos de texto (83 combinações medidas)

| família | tamanho | peso | altura | ls | cor | extra | família+tamanho na v1 | usos | exemplo |
|---|---|---|---|---|---|---|---|---|---|
| Bricolage Grotesque | 11 | 800 | normal | normal | `#1A1714` |  | sim | 4 | `i01.club.youMarker` |
| Bricolage Grotesque | 14 | 800 | 15.4px | normal | `#1A1714` |  | **novo** | 1 | `rv63.sheet.preview.book` |
| Bricolage Grotesque | 17 | 800 | normal | -0.3px | `#1A1714` |  | sim | 2 | `rv61.header.title` |
| Bricolage Grotesque | 18 | 800 | normal | normal | `#1A1714` |  | sim | 3 | `i01.header.avatar` |
| Bricolage Grotesque | 18 | 800 | normal | -0.3px | `#1A1714` |  | sim | 3 | `i01.alsoReading.title` |
| Bricolage Grotesque | 20 | 800 | normal | -0.4px | `#1A1714` |  | sim | 4 | `i01.today.title` |
| Bricolage Grotesque | 20 | 800 | 21px | -0.5px | `#1A1714` |  | sim | 2 | `i01.review.title` |
| Bricolage Grotesque | 22 | 800 | 22px | -0.5px | `#1A1714` |  | sim | 3 | `i01.club.title` |
| Bricolage Grotesque | 22 | 800 | 23.1px | normal | `#1A1714` |  | sim | 3 | `rv62.summary.stats.more.value` |
| Bricolage Grotesque | 24 | 800 | 25.2px | -0.6px | `#1A1714` |  | sim | 3 | `i01.hero.title` |
| Bricolage Grotesque | 24 | 800 | normal | -0.6px | `#1A1714` |  | sim | 6 | `i01.forYou.title` |
| Bricolage Grotesque | 24 | 800 | normal | -0.6px | `#F7F0E3` | tnum | sim | 1 | `i01b.miniBar.time` |
| Bricolage Grotesque | 26 | 800 | normal | -0.6px | `#1A1714` |  | sim | 3 | `i01.hero.percent` |
| Bricolage Grotesque | 32 | 800 | 31.36px | -1px | `#1A1714` |  | **novo** | 1 | `rv62.summary.title` |
| Bricolage Grotesque | 34 | 800 | 34px | -1px | `#1A1714` |  | sim | 3 | `i01.today.dial.value` |
| Bricolage Grotesque | 42 | 800 | 41.16px | -1.4px | `#1A1714` |  | sim | 3 | `i01.headline` |
| Bricolage Grotesque | 42 | 800 | 39.9px | -1.5px | `#1A1714` |  | sim | 3 | `i01.club.stub.day` |
| Figtree | 6.5 | 700 | normal | 0.91px | `#FF552E` |  | sim | 3 | `i01.forYou.item1.cover.author` |
| Figtree | 6.5 | 700 | normal | 0.91px | `#FFFAF1` |  | sim | 6 | `i01.forYou.item2.cover.author` |
| Figtree | 10 | 800 | normal | normal | `#1A1714` |  | sim | 3 | `i01.club.avatar3` |
| Figtree | 10 | 800 | normal | 1px | `#4A2F33` |  | sim | 3 | `i01.club.stub.label` |
| Figtree | 10 | 800 | normal | 1px | `#5B4A1C` |  | sim | 2 | `rv61.deck.card.note.label` |
| Figtree | 10 | 800 | normal | normal | `#3E2A2D` |  | sim | 1 | `rv63.sheet.preview.footer.handle` |
| Figtree | 10.5 | 800 | normal | 1.4px | `#B9AE9C` |  | **novo** | 1 | `i01b.miniBar.kicker` |
| Figtree | 11 | 600 | normal | normal | `#5B544B` |  | sim | 9 | `i01.nav.library.label` |
| Figtree | 11 | 700 | normal | normal | `#4A4238` |  | sim | 3 | `i01.today.dial.caption` |
| Figtree | 11 | 700 | normal | normal | `#5B544B` |  | sim | 18 | `i01.today.week.label0` |
| Figtree | 11 | 700 | normal | normal | `#1A1714` |  | sim | 3 | `i01.nav.scanner.label` |
| Figtree | 11 | 700 | normal | normal | `#3E2A2D` |  | sim | 1 | `rv63.sheet.preview.author` |
| Figtree | 11 | 800 | normal | normal | `#1A1714` |  | sim | 26 | `i01.hero.notesButton.badge` |
| Figtree | 11 | 800 | normal | 1px | `#6F665B` |  | sim | 2 | `i01.review.kicker` |
| Figtree | 11 | 900 | normal | 0.8px | `#1A1714` |  | sim | 3 | `i01.hero.formatPill` |
| Figtree | 11.5 | 700 | normal | normal | `#1A1714` |  | **novo** | 6 | `i01.alsoReading.card1.meta` |
| Figtree | 11.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 2 | `rv61.deck.card.top.book.label` |
| Figtree | 12 | 600 | normal | normal | `#2F2A40` |  | sim | 3 | `i01.hero.timeLeft` |
| Figtree | 12 | 600 | normal | normal | `#5B544B` |  | sim | 6 | `i01.today.week.total` |
| Figtree | 12 | 700 | normal | normal | `#1A1714` |  | sim | 19 | `i01.hero.pagePill` |
| Figtree | 12 | 700 | normal | normal | `#3B2D86` |  | sim | 3 | `i01.recent.row0.tag` |
| Figtree | 12 | 700 | normal | normal | `#2E5314` |  | sim | 3 | `i01.recent.row1.tag` |
| Figtree | 12 | 700 | normal | normal | `#4A4238` |  | sim | 3 | `i01.recent.row2.tag` |
| Figtree | 12 | 700 | normal | normal | `#8A8073` |  | sim | 3 | `rv61.deck.card.footer.when` |
| Figtree | 12 | 800 | normal | normal | `#F7F0E3` |  | sim | 3 | `i01.alsoReading.count` |
| Figtree | 12 | 800 | normal | normal | `#1A1714` |  | sim | 3 | `i01.club.youLabel` |
| Figtree | 12 | 800 | normal | 0.96px | `#1A1714` |  | sim | 6 | `i01.club.stub.weekday` |
| Figtree | 12.5 | 600 | 16.875px | normal | `#5B544B` |  | **novo** | 2 | `i01.review.subtitle` |
| Figtree | 12.5 | 600 | normal | normal | `#6F665B` |  | **novo** | 1 | `rv62.footer.settings` |
| Figtree | 12.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 1 | `rv62.footer.settings.link` |
| Figtree | 13 | 500 | normal | normal | `#5B544B` |  | sim | 30 | `i01.header.greeting` |
| Figtree | 13 | 600 | normal | normal | `#1A1714` |  | sim | 6 | `i01.today.footer.text` |
| Figtree | 13 | 600 | 18.2px | normal | `#3D3830` |  | sim | 1 | `rv62.summary.tomorrow.text` |
| Figtree | 13 | 700 | 17.55px | normal | `#1A1714` |  | sim | 2 | `rv61.deck.card.note.text` |
| Figtree | 13 | 800 | normal | normal | `#1A1714` |  | sim | 13 | `i01.today.streakPill` |
| Figtree | 13 | 800 | normal | normal | `#1A1714` | tnum | sim | 2 | `rv61.header.counter` |
| Figtree | 13 | 900 | 18.2px | normal | `#1A1714` |  | sim | 1 | `rv62.summary.tomorrow.text.strong` |
| Figtree | 14 | 500 | normal | normal | `#2F2A40` |  | sim | 3 | `i01.hero.author` |
| Figtree | 14 | 700 | normal | normal | `#1A1714` |  | sim | 8 | `i01.forYou.seeAll` |
| Figtree | 14 | 700 | 16.8px | normal | `#1A1714` |  | sim | 9 | `i01.forYou.item1.title` |
| Figtree | 14 | 700 | normal | normal | `#F7F0E3` |  | sim | 3 | `i01.club.cta.label` |
| Figtree | 14 | 800 | normal | normal | `#F7F0E3` |  | sim | 5 | `i01.today.readNow.label` |
| Figtree | 14 | 800 | normal | normal | `#1A1714` |  | sim | 2 | `rv61.actions.less` |
| Figtree | 15 | 600 | 19.5px | normal | `#1A1714` |  | sim | 3 | `i01.today.goalText.sentence` |
| Figtree | 15 | 700 | 18px | normal | `#1A1714` |  | sim | 6 | `i01.alsoReading.card1.title` |
| Figtree | 15 | 700 | normal | normal | `#1A1714` |  | sim | 9 | `i01.recent.row0.title` |
| Figtree | 15 | 800 | 19.5px | normal | `#1A1714` |  | sim | 3 | `i01.today.goalText.sentence.strong` |
| Figtree | 15 | 800 | 18px | normal | `#F7F0E3` |  | sim | 1 | `i01b.miniBar.title` |
| Figtree | 15.5 | 800 | normal | normal | `#F7F0E3` |  | **novo** | 2 | `rv61.actions.next.label` |
| Figtree | 16 | 700 | normal | -0.1px | `#1A1714` |  | sim | 3 | `i01.header.name` |
| Figtree | 16 | 700 | normal | normal | `#F7F0E3` |  | sim | 3 | `i01.hero.cta.label` |
| Instrument Serif | 9 | 400 | 8.55px | normal | `#1A1714` |  | sim | 3 | `i01.alsoReading.card2.cover.title` |
| Instrument Serif | 11 | 400 | 10.45px | normal | `#FED170` |  | sim | 3 | `i01.alsoReading.card1.cover.title` |
| Instrument Serif itálico | 20 | 400 | normal | -0.3px | `#1A1714` |  | **novo** | 2 | `rv61.header.title.serif` |
| Instrument Serif | 22 | 400 | 20.9px | normal | `#1A1714` |  | sim | 3 | `i01.forYou.item1.cover.title` |
| Instrument Serif itálico | 23 | 400 | normal | -0.2px | `#1A1714` |  | sim | 3 | `i01.today.title.serif` |
| Instrument Serif itálico | 24 | 400 | 25.2px | -0.5px | `#1A1714` |  | **novo** | 2 | `i01.review.title.serif` |
| Instrument Serif itálico | 24 | 400 | normal | -0.4px | `#1A1714` |  | **novo** | 1 | `rv63.sheet.title.serif` |
| Instrument Serif itálico | 25 | 400 | 27px | -0.2px | `#1A1714` |  | **novo** | 2 | `rv63.sheet.preview.quote` |
| Instrument Serif | 26 | 400 | 23.4px | normal | `#FFFAF1` |  | sim | 6 | `i01.forYou.item2.cover.title` |
| Instrument Serif itálico | 36 | 400 | 34.2px | -0.4px | `#1A1714` |  | sim | 3 | `i01.club.title.serif` |
| Instrument Serif itálico | 40 | 400 | 39.2px | -1px | `#1A1714` |  | **novo** | 1 | `rv62.summary.title.serif` |
| Instrument Serif itálico | 50 | 400 | 49px | -0.6px | `#1A1714` |  | sim | 3 | `i01.headline.serif` |
| Instrument Serif itálico | 64 | 400 | 38.4px | normal | `#1A1714` |  | **novo** | 1 | `rv63.sheet.preview.quoteMark` |
| Literata | 15 | 400 | 22.5px | normal | `#2A2520` |  | **novo** | 2 | `rv62.summary.newNote.quote` |
| Literata | 22 | 400 | 34.1px | normal | `#2A2520` |  | **novo** | 2 | `rv61.deck.card.quote` |

## Mapa id → widget (resumo)

Cada id de cada prancha tem um widget/pintor sugerido em `docs/design/medicao/inicio2/mapa_widgets.json` (e por fase nos arquivos L). Contagem por tipo:

| widget / pintor | ids |
|---|---|
| NeoBox | 252 |
| AppText | 248 |
| layout | 229 |
| AppSvg | 103 |
| CircleIconButton / NeoBox circular | 89 |
| Pill / CountBadge | 53 |
| HatchPainter | 27 |
| TextSpan dentro do AppText.rich do pai | 26 |
| CustomPainter | 6 |
| DecoratedBox | 5 |

Pintores sugeridos: `HatchPainter` (semana, clube, segmentos da revisão), mostrador da meta e anel do livro (`svg_graficos/`), pintor de grifo por linha (61, 62, 63), degradês inferiores (`DecoratedBox(LinearGradient)`: 150/55 % na 01, 240/48 % na 01b, rodapé da 62) e o `RepaintBoundary` da prévia da 63 (a imagem compartilhada). Recortes de referência visual (capas em CSS, cartões da revisão, hachuras, degradês) em `docs/design/medicao/inicio2/png/elementos/`.

