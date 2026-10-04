# L00 — Tokens novos e mapa id → widget (insumo da G11)

> Gerado por `tools/medicao/tokens_widgets.py` (G01.10) a partir das medições das 13 pranchas e dos tokens atuais do app (`lib/core/design_system/tokens/`). Dados completos: `referencia/tokens_leitor.json` e `referencia/mapa_widgets.json`.

## O que a G11 precisa mudar no design system (achados da medição)

- `AppFonts.bricolage` arredonda o tamanho para escolher a família (`size.round()`): 15,5 viraria 16. As famílias novas são `Bricolage15_5`, `Bricolage17`, `Bricolage23` — usar o tamanho exato (opsz = font-size).
- `AppFonts.figtree` aceita só 400–700 (D-14, Início). Nas telas 19–27b o 800 é real (D-16): família `Figtree` ganha o w800 (`Figtree-ExtraBold.ttf`); a Início continua pedindo w700 para o CSS 800. O CSS 900 da 23b renderiza 800.
- Literata: estáticas por tamanho para a interface (sumário, cartões da 25, prévias) e a variável (`LiterataVF`) para o texto do livro (D-17, spike S1).
- Sombras "anel" (`box-shadow: 0 0 0 Npx`) = `BoxShadow(spreadRadius: N, blurRadius: 0)`; aro duplo = duas sombras.
- Cores `brand` e `ink` são props (dinâmicas) também dentro de SVG (catálogo de SVGs → `coresDinamicas`).
- Tema Noite: tokens próprios (tabela de diferenças da `L26b_tema_noite.md`), nada de inversão automática.

## Cores (70; 56 ainda não existem em `AppColors`)

| cor | já existe | nome proposto | usos | telas | exemplo |
|---|---|---|---|---|---|
| `#1A1714` | ink |  | 440 | 20, 21, 22, 23, 23b, 24, 24b, 25, 26, 26b, 27, 27b | `r20.topIsland` |
| `#2A2520` | — | bookText (Creme) · ilha da Noite | 74 | 19, 20, 21, 22, 23, 23b, 24, 24b, 25, 26, 26b, 27, 27b | `r19.page.text` |
| `#FFFAF1` | surface |  | 74 | 20, 21, 22, 23, 23b, 24, 24b, 25, 26, 27, 27b | `r20.topIsland` |
| `#F7F0E3` | paper |  | 59 | 20, 22, 23, 23b, 24, 24b, 25, 26, 27, 27b | `r20.topIsland.close` |
| `#6F665B` | — | inkLabel | 57 | 21, 22, 23, 23b, 24, 24b, 25, 26, 27, 27b | `r21.toolbar.colors.label` |
| `#FF552E` | flame |  | 52 | 21, 22, 23, 23b, 24, 24b, 25, 26, 27, 27b | `r21.toolbar.colors.other` |
| `#8A8073` | — | inkSoft | 47 | 23b, 25, 26, 26b, 27, 27b | `mk.markerPanel.colors.yellow.count` |
| `#FED170` | sun |  | 40 | 20, 21, 22, 23, 23b, 24, 24b, 25, 26b, 27 | `r20.bottomIsland.tools.notes.badge` |
| `#B6ACE4` | lavender |  | 35 | 20, 21, 22, 23, 23b, 24, 24b, 25, 26, 26b, 27, 27b | `r20.bottomIsland.scrubber.fill` |
| `#000000@0` | — | — | 35 | 21, 22, 23, 23b, 24, 24b, 25, 26, 27, 27b | `r21.page.text.highlight` |
| `#ABCF82` | leaf |  | 22 | 21, 22, 23, 23b, 24, 24b, 25, 27 | `r21.toolbar.colors.green` |
| `#EDE3D1` | — | inkNight | 21 | 26, 26b | `rs.sheet.papers.night.sample` |
| `#CFC3AE` | — | dashLine | 20 | 20, 21, 22, 23, 23b, 24, 24b, 25, 26, 27, 27b | `r20.bottomIsland.tools` |
| `#F8F1E4` | — | paperCream | 17 | 19, 20, 21, 22, 23, 23b, 24, 24b, 26, 27, 27b | `r19.frame` |
| `#5B544B` | inkMuted |  | 15 | 20, 22, 23, 23b, 24, 24b, 25, 27, 27b | `r20.topIsland.author` |
| `#552CB7` | violet |  | 15 | 21, 22, 23, 23b, 24, 24b | `r21.toolbar.colors.other` |
| `#FFC1C6` | blush |  | 13 | 21, 22, 23, 23b, 24, 24b, 25, 27 | `r21.toolbar.colors.pink` |
| `#E3D8C4` | — | — | 12 | 27 | `toc.sheet.chapters.ch25.link` |
| `#1F1B17` | — | paperNight | 9 | 26, 26b | `rs.sheet.papers.night.card` |
| `#A89D8B` | — | readerFooter | 7 | 19, 20, 21, 24b | `r19.footer.pageLabel` |
| `#F2A815` | amber |  | 7 | 21, 22, 23, 23b, 24, 24b | `r21.toolbar.colors.other` |
| `#00995E` | emerald |  | 7 | 21, 22, 23, 23b, 24, 24b | `r21.toolbar.colors.other` |
| `#058CD7` | azure |  | 7 | 21, 22, 23, 23b, 24, 24b | `r21.toolbar.colors.other` |
| `#F8F1E4@0` | — | paperCream | 5 | 22, 23, 23b, 24, 24b | `ann.deskEdge` |
| `#E9DFCC` | — | hatchReader | 4 | 20, 23 | `r20.bottomIsland.scrubber.track` |
| `#FED170@0.95` | — | — | 4 | 23b | `mk.markerPanel.preview.highlight` |
| `#EFE5D3` | — | ruleLine | 4 | 24b, 25 | `hn.page.handNote.rule1` |
| `#FED170@0.9` | — | — | 4 | 25 | `hl.list.card1.body.quote.mark` |
| `#E2D7C4` | — | — | 3 | 23b | `mk.markerPanel.colors.pink` |
| `#FFFDF8` | — | paperWhite | 3 | 24b, 25, 26 | `hn.page.handNote` |
| `#000000` | — | — | 3 | 25, 27 | `hl.types` |
| `#3B3466` | — | — | 3 | 26, 27, 27b | `rs.sheet.fonts.literata.caption` |
| `#4A433A` | — | — | 3 | 26, 26b | `rs.sheet.papers.night.line1` |
| `#0B0A08` | — | shadowNight | 3 | 26b | `r20.topIsland` |
| `#B5AA98` | — | — | 3 | 26b | `r20.topIsland.author` |
| `#4A4238` | inkWarm |  | 3 | 27b | `bm.sheet.bookmarks.item1.excerpt` |
| `#FED170@0.85` | — | — | 2 | 21 | `r21.page.text.highlight` |
| `#F8F1E4@0.66` | — | paperCream | 2 | 23, 23b | `pen.fade` |
| `#E6DBC6` | — | — | 2 | 23 | `pen.penPanel.preview` |
| `#FF0000` | — | — | 2 | 23 | `pen.penPanel.picker.wheel` |
| `#B6ACE4@0.32` | — | — | 2 | 24 | `sp.page.spaceOpener.area` |
| `#FFFDF8@0.9` | — | paperWhite | 2 | 24 | `sp.page.spaceOpener.area` |
| `#FFC1C6@0.95` | — | — | 2 | 25 | `hl.list.card2.body.quote.mark` |
| `#FFFAF1@0.85` | — | — | 2 | 25 | `hl.list.card2.body.note.tape` |
| `#5B4A1C` | — | — | 2 | 25 | `hl.list.card2.body.note.label` |
| `#ABCF82@0.85` | — | — | 2 | 25 | `hl.list.card3.body.quote.mark` |
| `#B6ACE4@0.75` | — | — | 2 | 25 | `hl.list.card5.body.quote.mark` |
| `#5B3A3E` | — | — | 2 | 25, 27 | `hl.list.card5.body.club.chip.replies` |
| `#D9CCB4` | — | — | 2 | 26 | `rs.sheet.papers.cream.line1` |
| `#E3DCCD` | — | — | 2 | 26 | `rs.sheet.papers.white.line1` |
| `#CDB48C` | — | — | 2 | 26 | `rs.sheet.papers.sepia.line1` |
| `#3A332B` | — | — | 2 | 26b | `r20.bottomIsland.scrubber.track` |
| `#1A1714@0.28` | — | — | 2 | 27, 27b | `toc.fade` |
| `#F8F1E4@0.62` | — | paperCream | 1 | 20 | `r20.fade` |
| `#B6ACE4@0.62` | — | — | 1 | 21 | `r21.page.text.selection` |
| `#B6ACE4@0.42` | — | — | 1 | 22 | `ann.page.text.wavy.touchRing` |
| `#FFFFFF` | — | white | 1 | 23 | `pen.penPanel.picker.wheel` |
| `#FFFFFF@0` | — | white | 1 | 23 | `pen.penPanel.picker.wheel` |
| `#FFFF00` | — | — | 1 | 23 | `pen.penPanel.picker.wheel` |
| `#00FF00` | — | — | 1 | 23 | `pen.penPanel.picker.wheel` |
| `#00FFFF` | — | — | 1 | 23 | `pen.penPanel.picker.wheel` |
| `#0000FF` | — | — | 1 | 23 | `pen.penPanel.picker.wheel` |
| `#FF00FF` | — | — | 1 | 23 | `pen.penPanel.picker.wheel` |
| `#8A7F63` | — | — | 1 | 23b | `mk.markerPanel.tip` |
| `#3D3830` | — | — | 1 | 23b | `mk.markerPanel.tip.text` |
| `#B6ACE4@0.55` | — | — | 1 | 24 | `sp.page.spaceOpener.finger` |
| `#EEDDBF` | — | paperSepia | 1 | 26 | `rs.sheet.papers.sepia.card` |
| `#4A3622` | — | bookTextSepia | 1 | 26 | `rs.sheet.papers.sepia.sample` |
| `#E3D9C6` | — | bookTextNight | 1 | 26b | `r20.page.text` |
| `#14110E@0.55` | — | — | 1 | 26b | `r20.fade` |

Notas: `@a` = alfa; cores de degradê (roda de cores, véus) entram como paradas do gradiente do pintor, não como tokens soltos. `#000000@0` = `transparent` dos degradês.

## Raios

| raio | já existe | usos | exemplos |
|---|---|---|---|
| 50% | — | 142 | `r20.topIsland.close`, `r20.topIsland.search`, `r20.topIsland.bookmark` |
| 999px | pill | 74 | `r20.bottomIsland.scrubber.track`, `r20.bottomIsland.tools.notes.badge`, `r20.timeChip` |
| 16px | — | 28 | `r20.bottomIsland.tools.font.circle`, `r20.bottomIsland.tools.theme.circle`, `r20.bottomIsland.tools.notes.circle` |
| 2px | — | 27 | `r21.page.text.selection`, `ann.page.text.doubleUnderline.line1`, `ann.page.text.doubleUnderline.line2` |
| 26px | — | 17 | `ann.modePill`, `ann.done`, `ann.island` |
| 3px | — | 12 | `r21.page.text.highlight`, `mk.markerPanel.preview.highlight`, `mk.markerPanel.styles.fill.sample.word` |
| 14px | — | 11 | `r21.toolbar.actions.note`, `r21.toolbar.actions.copy`, `r21.toolbar.actions.share` |
| 20px | navItem | 8 | `hl.list.card1`, `hl.list.card2`, `hl.list.card3` |
| 18px | — | 5 | `hn.page.handNote`, `toc.sheet.club`, `bm.sheet.bookmarks.item1.row` |
| 32px 32px 44px 44px | — | 3 | `rs.sheet`, `toc.sheet`, `bm.sheet` |
| 31px | — | 2 | `r20.topIsland`, `r20.topIsland` |
| 28px | card | 2 | `r20.bottomIsland`, `r20.bottomIsland` |
| 10px | — | 2 | `r20.bottomIsland.scrubber.bubble`, `r20.bottomIsland.scrubber.bubble` |
| 22px | cardM | 2 | `r21.toolbar`, `hl.end` |
| 12px | — | 2 | `hl.list.card2.body.note`, `hl.list.card5.body.note` |
| 999px 0px 0px 999px | — | 1 | `pen.penPanel.size.slider.fill` |
| 6px | — | 1 | `pen.penPanel.picker.hex.swatch` |
| 9px | — | 1 | `sp.page.spaceOpener.sizeChip` |

## Bordas

| borda | já existe (AppStrokes) | usos | exemplos |
|---|---|---|---|
| 1.5px solid | regular | 225 | `r20.topIsland`, `r20.topIsland.close`, `r20.bottomIsland` |
| 1.5px dashed | regular | 23 | `r20.bottomIsland.tools`, `r21.toolbar.colors`, `ann.page.text.wavy.touchRing` |
| 1.3px solid | — | 15 | `toc.sheet.chapters.ch25.marks.highlight`, `toc.sheet.chapters.ch25.read`, `toc.sheet.chapters.ch26.read` |
| 1.2px solid | thin | 13 | `mk.markerPanel.heights.low.sample`, `mk.markerPanel.heights.medium.sample`, `mk.markerPanel.heights.high.sample` |
| 1.2px dashed | thin | 12 | `toc.sheet.chapters.ch25.link`, `toc.sheet.chapters.ch26.link`, `toc.sheet.chapters.ch27.link` |
| 2px solid | — | 3 | `r20.bottomIsland.scrubber.knob`, `pen.penPanel.size.slider.knob`, `r20.bottomIsland.scrubber.knob` |
| 3px solid | — | 2 | `pen.penPanel.picker.wheel.cursor`, `pen.penPanel.picker.brightness.knob` |
| 1.3px dashed | — | 1 | `mk.markerPanel.tip` |

## Sombras (todas sem desfoque)

| sombra | usos | exemplos |
|---|---|---|
| `#1A1714 3px 3px 0px 0px` | 26 | `r20.topIsland`, `r20.bottomIsland`, `r21.toolbar` |
| `#1A1714 2px 2px 0px 0px` | 16 | `r20.bottomIsland.scrubber.knob`, `pen.penPanel.tips.ballpoint`, `pen.penPanel.size.slider.knob` |
| `#FFFAF1 0px 0px 0px 2.5px` | 5 | `ann.island.colorWell.ink`, `pen.island.colorWell.ink`, `mk.island.colorWell.ink` |
| `#1A1714 0px 0px 0px 1px` | 5 | `ann.island.width.thin.dot`, `pen.island.width.thin.dot`, `mk.island.width.thin.dot` |
| `#1A1714 0px 0px 0px 1.2px` | 5 | `ann.island.width.medium.dot`, `pen.island.width.medium.dot`, `mk.island.width.medium.dot` |
| `#1A1714 0px 0px 0px 1.4px` | 5 | `ann.island.width.thick.dot`, `pen.island.width.thick.dot`, `mk.island.width.thick.dot` |
| `#1A1714 0px 4px 0px 0px` | 3 | `rs.sheet`, `toc.sheet`, `bm.sheet` |
| `#1A1714 4px 4px 0px 0px` | 2 | `pen.penPanel`, `mk.markerPanel` |
| `#FFFAF1 0px 0px 0px 2.5px, #1A1714 0px 0px 0px 4px` | 2 | `pen.penPanel.favorites.coral`, `mk.markerPanel.colors.yellow.swatch` |
| `#0B0A08 3px 3px 0px 0px` | 2 | `r20.topIsland`, `r20.bottomIsland` |
| `#1A1714 0px 0px 0px 1.5px, #1A1714 2px 2px 0px 1.5px` | 1 | `pen.penPanel.picker.wheel.cursor` |
| `#1A1714 0px 0px 0px 1.5px` | 1 | `pen.penPanel.picker.brightness.knob` |
| `#0B0A08 2px 2px 0px 0px` | 1 | `r20.bottomIsland.scrubber.knob` |

## Estilos de texto (90 combinações medidas)

| família | tamanho | peso | altura | ls | cor | extra | família+tamanho na v1 | usos | exemplo |
|---|---|---|---|---|---|---|---|---|---|
| Atkinson Hyperlegible | 26 | 400 | 28.6px | normal | `#1A1714` |  | **novo** | 1 | `rs.sheet.fonts.atkinson.sample` |
| Bricolage Grotesque | 15.5 | 800 | 17.05px | -0.2px | `#1A1714` |  | **novo** | 5 | `ann.modePill.title` |
| Bricolage Grotesque | 17 | 800 | 18.7px | -0.3px | `#1A1714` |  | **novo** | 1 | `r20.topIsland.title` |
| Bricolage Grotesque | 17 | 800 | 18.7px | -0.3px | `#EDE3D1` |  | **novo** | 1 | `r20.topIsland.title` |
| Bricolage Grotesque | 22 | 800 | 23.1px | -0.4px | `#1A1714` |  | sim | 2 | `pen.penPanel.title` |
| Bricolage Grotesque | 23 | 800 | normal | -0.5px | `#1A1714` |  | **novo** | 1 | `rs.sheet.title` |
| Bricolage Grotesque | 26 | 800 | 26px | -0.6px | `#1A1714` |  | sim | 2 | `toc.sheet.title` |
| Bricolage Grotesque | 34 | 800 | 33.32px | -1px | `#1A1714` |  | sim | 1 | `hl.title` |
| Figtree | 10 | 700 | normal | normal | `#6F665B` |  | sim | 25 | `ann.island.labels.marker` |
| Figtree | 10 | 800 | normal | normal | `#1A1714` |  | sim | 5 | `ann.island.labels.pen.pill` |
| Figtree | 10.5 | 600 | normal | normal | `#3B3466` |  | **novo** | 1 | `rs.sheet.fonts.literata.caption` |
| Figtree | 10.5 | 600 | normal | normal | `#8A8073` |  | **novo** | 3 | `rs.sheet.fonts.lora.caption` |
| Figtree | 10.5 | 800 | normal | 0.9px | `#1A1714` |  | **novo** | 11 | `hl.list.card1.head.highlight` |
| Figtree | 10.5 | 800 | normal | 1px | `#5B4A1C` |  | **novo** | 2 | `hl.list.card2.body.note.label` |
| Figtree | 10.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 1 | `hl.list.card7.body.handNote.tag` |
| Figtree | 11 | 600 | normal | normal | `#8A8073` |  | sim | 4 | `mk.markerPanel.colors.yellow.count` |
| Figtree | 11 | 700 | normal | normal | `#A89D8B` |  | sim | 1 | `hn.page.handNote.hint` |
| Figtree | 11 | 800 | normal | normal | `#1A1714` |  | sim | 3 | `r20.bottomIsland.tools.notes.badge` |
| Figtree | 11 | 800 | 11px | 1.2px | `#6F665B` |  | sim | 1 | `r21.toolbar.colors.label` |
| Figtree | 11 | 800 | normal | 1.2px | `#6F665B` |  | sim | 11 | `pen.penPanel.tipLabel` |
| Figtree | 11 | 800 | normal | 1px | `#6F665B` |  | sim | 1 | `hl.filters.colors.label` |
| Figtree | 11 | 800 | normal | 0.8px | `#5B3A3E` |  | sim | 1 | `toc.sheet.club.kicker` |
| Figtree | 11.5 | 600 | normal | normal | `#A89D8B` | tnum | **novo** | 6 | `r19.footer.pageLabel` |
| Figtree | 11.5 | 600 | normal | normal | `#5B544B` |  | **novo** | 5 | `ann.modePill.subtitle` |
| Figtree | 11.5 | 600 | normal | normal | `#8A8073` | tnum | **novo** | 2 | `r20.footer.pageLabel` |
| Figtree | 11.5 | 700 | normal | normal | `#8A8073` |  | **novo** | 3 | `bm.sheet.bookmarks.item1.date` |
| Figtree | 11.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 7 | `r21.toolbar.actions.note` |
| Figtree | 11.5 | 800 | normal | normal | `#6F665B` |  | **novo** | 3 | `toc.sheet.chapters.ch25.marks.count` |
| Figtree | 12 | 700 | normal | normal | `#1A1714` |  | sim | 8 | `r20.bottomIsland.tools.font` |
| Figtree | 12 | 700 | normal | normal | `#8A8073` |  | sim | 8 | `hl.list.card1.head.date` |
| Figtree | 12 | 700 | normal | normal | `#EDE3D1` |  | sim | 5 | `r20.bottomIsland.tools.font` |
| Figtree | 12 | 700 | normal | normal | `#6F665B` |  | sim | 3 | `bm.sheet.bookmarks.item1.head.chapter` |
| Figtree | 12 | 800 | normal | normal | `#1A1714` |  | sim | 11 | `pen.penPanel.tips.ballpoint` |
| Figtree | 12 | 800 | normal | 0.5px | `#8A8073` |  | sim | 12 | `toc.sheet.chapters.ch25.numeral` |
| Figtree | 12 | 800 | normal | 0.5px | `#1A1714` |  | sim | 1 | `toc.sheet.chapters.ch32.numeral` |
| Figtree | 12.5 | 600 | normal | normal | `#5B544B` |  | **novo** | 3 | `r20.topIsland.author` |
| Figtree | 12.5 | 600 | 16.875px | normal | `#3D3830` |  | **novo** | 1 | `mk.markerPanel.tip.text` |
| Figtree | 12.5 | 600 | normal | normal | `#B5AA98` |  | **novo** | 1 | `r20.topIsland.author` |
| Figtree | 12.5 | 700 | normal | normal | `#5B544B` | tnum | **novo** | 2 | `r20.bottomIsland.progressRow.position` |
| Figtree | 12.5 | 700 | normal | normal | `#5B3A3E` |  | **novo** | 1 | `hl.list.card5.body.club.chip.replies` |
| Figtree | 12.5 | 700 | normal | normal | `#B5AA98` | tnum | **novo** | 2 | `r20.bottomIsland.progressRow.position` |
| Figtree | 12.5 | 800 | normal | normal | `#F7F0E3` |  | **novo** | 2 | `r20.bottomIsland.scrubber.bubble` |
| Figtree | 12.5 | 800 | normal | normal | `#1A1714` | tnum | **novo** | 9 | `r20.bottomIsland.progressRow.position.percent` |
| Figtree | 12.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 5 | `r20.timeChip` |
| Figtree | 12.5 | 800 | normal | normal | `#1F1B17` |  | **novo** | 1 | `r20.bottomIsland.scrubber.bubble` |
| Figtree | 12.5 | 800 | normal | normal | `#EDE3D1` | tnum | **novo** | 1 | `r20.bottomIsland.progressRow.position.percent` |
| Figtree | 12.5 | 900 | 16.875px | normal | `#1A1714` |  | **novo** | 1 | `mk.markerPanel.tip.text.strong` |
| Figtree | 13 | 600 | normal | normal | `#5B544B` |  | sim | 4 | `mk.markerPanel.heights.low` |
| Figtree | 13 | 600 | 18.85px | normal | `#6F665B` |  | sim | 1 | `bm.sheet.hint.text` |
| Figtree | 13 | 700 | normal | normal | `#1A1714` |  | sim | 4 | `rs.sheet.spacing.tight` |
| Figtree | 13 | 700 | normal | normal | `#6F665B` | tnum | sim | 12 | `toc.sheet.chapters.ch25.page` |
| Figtree | 13 | 800 | normal | normal | `#1A1714` | tnum | sim | 2 | `pen.penPanel.sizeHeader.value` |
| Figtree | 13 | 800 | normal | normal | `#1A1714` |  | sim | 4 | `mk.markerPanel.heights.medium` |
| Figtree | 13.5 | 700 | normal | normal | `#1A1714` |  | **novo** | 1 | `hl.types.all.count` |
| Figtree | 13.5 | 700 | normal | normal | `#8A8073` |  | **novo** | 4 | `hl.types.highlights.count` |
| Figtree | 13.5 | 800 | 15.525px | normal | `#1A1714` |  | **novo** | 4 | `mk.markerPanel.colors.yellow.label` |
| Figtree | 13.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 5 | `hl.types.all` |
| Figtree | 14 | 600 | normal | normal | `#5B544B` |  | **novo** | 1 | `hl.subtitle` |
| Figtree | 14 | 700 | normal | normal | `#3B3466` |  | sim | 2 | `toc.sheet.tabs.chapters.count` |
| Figtree | 14 | 700 | normal | normal | `#1A1714` |  | sim | 2 | `toc.sheet.tabs.bookmarks` |
| Figtree | 14 | 700 | normal | normal | `#8A8073` |  | sim | 2 | `toc.sheet.tabs.bookmarks.count` |
| Figtree | 14 | 800 | normal | normal | `#1A1714` |  | sim | 4 | `hl.topBar.export` |
| Figtree | 14.5 | 700 | 20.3px | normal | `#1A1714` |  | **novo** | 2 | `hl.list.card2.body.note.text` |
| Figtree | 15 | 800 | normal | normal | `#1A1714` |  | sim | 6 | `ann.done` |
| Figtree | 15 | 800 | normal | 0.6px | `#1A1714` | tnum | sim | 1 | `pen.penPanel.picker.hex.value` |
| Figtree | 15.5 | 800 | normal | normal | `#F7F0E3` |  | **novo** | 1 | `hl.end.cta.label` |
| Figtree | 26 | 400 | 28.6px | normal | `#1A1714` |  | **novo** | 1 | `rs.sheet.fonts.figtree.sample` |
| Instrument Serif itálico | 22 | 400 | 25.3px | normal | `#1A1714` |  | sim | 1 | `hl.end.text` |
| Instrument Serif itálico | 28 | 400 | normal | -0.2px | `#1A1714` |  | **novo** | 1 | `rs.sheet.title.serif` |
| Instrument Serif itálico | 42 | 400 | 41.16px | -0.4px | `#1A1714` |  | **novo** | 1 | `hl.title.serif` |
| Literata | 15 | 500 | normal | normal | `#1A1714` |  | **novo** | 1 | `rs.sheet.size.smaller` |
| Literata | 15.5 | 400 | 23.25px | normal | `#4A4238` |  | **novo** | 3 | `bm.sheet.bookmarks.item1.excerpt` |
| Literata | 16 | 400 | 19.2px | normal | `#2A2520` |  | **novo** | 6 | `mk.markerPanel.styles.fill.sample` |
| Literata | 16 | 400 | 20px | normal | `#2A2520` |  | **novo** | 7 | `toc.sheet.chapters.ch25.title` |
| Literata | 16 | 400 | 20px | normal | `#1A1714` |  | **novo** | 5 | `toc.sheet.chapters.ch33.title` |
| Literata | 16.5 | 400 | 26.4px | normal | `#2A2520` |  | **novo** | 17 | `hl.list.card1.body.quote` |
| Literata | 16.5 | 400 | 26.4px | normal | `#8A8073` |  | **novo** | 9 | `hl.list.card1.body.quote.context` |
| Literata | 17 | 400 | 25.5px | normal | `#2A2520` |  | **novo** | 2 | `mk.markerPanel.preview` |
| Literata | 17 | 500 | 21.25px | normal | `#1A1714` |  | **novo** | 1 | `toc.sheet.chapters.ch32.title` |
| Literata | 18 | 400 | 18px | normal | `#2A2520` |  | **novo** | 1 | `rs.sheet.papers.cream.sample` |
| Literata | 18 | 400 | 18px | normal | `#1A1714` |  | **novo** | 1 | `rs.sheet.papers.white.sample` |
| Literata | 18 | 400 | 18px | normal | `#4A3622` |  | **novo** | 1 | `rs.sheet.papers.sepia.sample` |
| Literata | 18 | 400 | 18px | normal | `#EDE3D1` |  | **novo** | 1 | `rs.sheet.papers.night.sample` |
| Literata | 19 | 500 | normal | normal | `#1A1714` |  | **novo** | 1 | `r20.bottomIsland.tools.font.circle` |
| Literata | 19 | 500 | normal | normal | `#EDE3D1` |  | **novo** | 1 | `r20.bottomIsland.tools.font.circle` |
| Literata | 20.5 | 400 | 35.26px | normal | `#2A2520` |  | **novo** | 36 | `r19.page.text` |
| Literata | 20.5 | 400 | 35.26px | normal | `#E3D9C6` |  | **novo** | 1 | `r20.page.text` |
| Literata | 25 | 500 | normal | normal | `#1A1714` |  | **novo** | 1 | `rs.sheet.size.larger` |
| Literata | 26 | 400 | 28.6px | normal | `#1A1714` |  | **novo** | 1 | `rs.sheet.fonts.literata.sample` |
| Lora | 26 | 400 | 28.6px | normal | `#1A1714` |  | **novo** | 1 | `rs.sheet.fonts.lora.sample` |

## Mapa id → widget (resumo)

Cada id de cada prancha tem um widget/pintor sugerido em `referencia/mapa_widgets.json` (e por fase nos arquivos L). Contagem por tipo:

| widget / pintor | ids |
|---|---|
| layout | 217 |
| AppText | 214 |
| NeoBox | 166 |
| CircleIconButton / NeoBox circular | 131 |
| AppSvg | 127 |
| TextSpan dentro do AppText.rich do pai | 53 |
| Pill / CountBadge | 53 |
| InkStrokesPainter | 26 |
| NeoBox + AppText | 17 |
| ConicRingPainter | 6 |
| DecoratedBox | 6 |
| HatchPainter | 5 |
| CustomPainter | 3 |
| ColorWheelPainter | 1 |

Pintores novos sugeridos para a G11: `HatchPainter` com cores do leitor (barra de posição, espessura, espaço roxo), `ColorWheelPainter` (roda HSV), `ConicRingPainter` (poço de cor e "outra cor"), onda do fim do preenchimento (`svg_graficos/onda_preenchimento_barra.svg`), anel de progresso do capítulo, pintor de tinta (traços da fixture, `svg_tinta/`), pintor de grifo (fundo por altura, sublinhado, ondulado) e máscaras (`ShaderMask`) da faixa de tipos e da lista de capítulos. Recortes de referência visual em `referencia/png/elementos/`.

