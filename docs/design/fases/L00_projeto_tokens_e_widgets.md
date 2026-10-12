# L00 — Projeto (etapas 7–11): tokens novos e mapa id → widget (insumo das T14–T18)

> Gerado por `tools/medicao/tokens_widgets.py` (T13.12, `CONJUNTO=projeto`) a partir das medições das 41 telas do projeto completo do design e dos tokens atuais do app (`lib/core/design_system/tokens/`). Dados completos: `docs/design/medicao/projeto/tokens_projeto.json` e `docs/design/medicao/projeto/mapa_widgets.json`. Cada nome proposto é uma proposta para a etapa que usa a cor primeiro (T14 → T18); "já existe" é o token de hoje com a mesma cor.

## O que as T14–T18 precisam no design system (achados da medição)

- Fontes (T13.10, D-246): a Figtree vai até 800 nas 41 (800 **real**, `Figtree-ExtraBold.ttf`; o 900 de 4 telas renderiza 800). Já no app: a Bricolage 800 por tamanho (`AppFonts.bricolageOpsz`, 13 tamanhos novos) e a 700 na 15 (`bricolageBold`), a Literata estática 14/16/24 em 600, 24 em 400 e 18 em 500 (`literataStatic`) e a Roboto 500 do botão do Google da 07 (`AppFonts.roboto`). Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` soma às features. O "≈" da 17b e as setas da 28c e da 30b caem na reserva no peso do texto (D-281: `BookNestApprox` SemiBold e ExtraBold).
- Texto que o app não desenha (R8, informativo): o botão "Continuar com a Apple" da 07 (o oficial, do sistema), o teclado numérico da 69/69b (do Android/iOS) e o input escondido do @ da 15 (D-277). Ficam no layout e nas referências com o motivo, fora da conferência de fontes.
- SVG (T13.11): 198 desenhos novos nas pastas por área (`AppIconsBiblioteca`, `AppIconsScanner`, `AppIconsEntrada`, `AppIconsPerfil`, `AppIconsCronometro` e as `AppIllustrations…` das mesmas áreas — D-284: a área da 1ª etapa que usa); 40 reusos pelo desenho (D-283), que o mapa já chama pela classe de antes (`AppIcons.navHome`, `AppIconsLeitor.search`, `AppIllustrationsInicio.coverDomCasmurro`…); 15 gráficos em `svg_graficos/` viram pintores (anéis de progresso, bordas onduladas, códigos de barras). As armadilhas de cada uso estão no catálogo e na coluna de observação do mapa: `<text>` (o `AppSvg` lê sem os textos os `withText` e eles voltam em `AppText`), 5 desenhos que passam da própria caixa (sem recorte), 3 ícones encolhidos no flex (decidir na etapa) e os 3 tracejados do scanner, pintados pelo registro `svgDashes` (D-285, D-286).
- Capas e cartões em CSS (estante, Detalhes, scanner, busca, sugestões, Perfil, favoritos, cronômetro, carteirinhas, selos, medalhas, avatares): widgets compostos (div, borda, raio, círculo, lombada), com os recortes @3x de referência em `docs/design/medicao/projeto/png/elementos/` (120). A capa da Início reusada na 07, nos Detalhes e no cronômetro tem a escala da caixa de cada uso.
- Larguras (T13.9, D-272): a 430 nada passa; a 360, as ondas da entrada, as fitas do adesivo da 69/69b, as estrelinhas, a dica da 13b e o botão do scanner são de tamanho fixo e passam da borda; os textos das capas e as reticências da 02 e as sobreposições (o 9º livro da 02, a 36a, a 05, a coleção da 03) mudam de verdade. Cada fase L traz os itens dela (seção "Nas outras larguras").
- Sombras "anel" (`box-shadow: 0 0 0 Npx`) = `BoxShadow(spreadRadius: N, blurRadius: 0)`; aro duplo = duas sombras. Todas as sombras do projeto são duras (sem desfoque).
- Props (cores dinâmicas) por tela: `brand` (lavanda, 38 telas), `reticle` (a mira do scanner), `shelf`, `cover`, `progress`, `card`, `club`, `badge`, `avatar`, `arc`, `env`, `lock`, `halo` (verde na 17, lavanda na 17b) e `goal` — sempre a prop, nunca a cor fixa; dentro dos SVGs também (catálogo → `coresDinamicas`).
- Folhas por cima de outra tela (R9: a 65 sobre a 64, a 18b sobre a 18, os avisos): o fundo esmaecido faz parte da medida; o véu é a cor `@alfa` da tabela.

## Cores (115; 75 ainda não existem em `AppColors`)

| cor | já existe | nome proposto | usos | telas | exemplo |
|---|---|---|---|---|---|
| `#1A1714` | ink |  | 1718 | 002, 003, 005, 006, 007, 008, 009, 009b, 010, 011, 012, 013, 013b, 014, 015, 016, 017, 017b, 018, 018b, 028, 028b, 028c, 028d, 030, 030b, 030c, 035, 036, 036a, 039, 040, 041, 042, 056, 058, 059, 064, 065, 069, 069b | `b02.header.title` |
| `#FFFAF1` | surface |  | 387 | 002, 003, 005, 006, 007, 008, 009, 009b, 010, 011, 012, 013, 013b, 014, 015, 016, 017, 017b, 018b, 028, 028b, 028c, 028d, 030, 030b, 030c, 035, 036, 036a, 039, 040, 041, 042, 056, 058, 059, 064, 065, 069, 069b | `b02.header.add` |
| `#5B544B` | inkMuted |  | 157 | 002, 003, 005, 006, 007, 008, 009, 009b, 010, 011, 012, 013, 013b, 014, 015, 016, 017, 017b, 018b, 028, 028b, 028c, 030, 030b, 030c, 036, 036a, 039, 040, 041, 042, 056, 058, 059, 064, 065, 069, 069b | `b02.collections.card1.count` |
| `#F7F0E3` | paper |  | 142 | 002, 003, 005, 006, 007, 008, 009, 009b, 010, 011, 012, 013, 013b, 014, 015, 016, 017, 017b, 018, 018b, 028, 028b, 028c, 028d, 030, 030b, 030c, 035, 036, 036a, 039, 040, 041, 042, 056, 058, 059, 064, 065, 069, 069b | `b02.frame` |
| `#FED170` | sun |  | 128 | 002, 003, 005, 006, 009b, 012, 013, 013b, 014, 015, 016, 017, 017b, 018, 018b, 028, 028b, 028c, 028d, 030, 030b, 030c, 036, 036a, 040, 041, 042, 056, 058, 059, 064, 065, 069, 069b | `b02.collections.card1.pile.spine1.band` |
| `#B6ACE4` | lavender |  | 117 | 002, 003, 005, 006, 008, 009, 010, 011, 012, 013, 013b, 014, 015, 016, 017, 017b, 018b, 028, 028b, 028c, 028d, 030, 030b, 036, 036a, 039, 040, 041, 042, 056, 058, 059, 064, 065, 069, 069b | `b02.collections.card3.pile.spine2` |
| `#6F665B` | labelReader |  | 96 | 002, 005, 006, 007, 008, 010, 011, 015, 016, 017, 017b, 018b, 028, 028b, 028c, 028d, 030, 030b, 036a, 059, 064, 065 | `b02.statusTabs.reading.count` |
| `#FF552E` | flame |  | 62 | 002, 003, 005, 006, 008, 009b, 012, 013, 013b, 014, 015, 016, 018, 018b, 028, 028c, 028d, 030, 030b, 035, 039, 042, 056, 059, 064, 065, 069 | `b02.collections.card2.pile.spine1` |
| `#FFC1C6` | blush |  | 54 | 002, 005, 006, 013, 016, 017, 017b, 028, 028b, 028d, 030, 030b, 036, 036a, 056, 058, 059, 064, 065, 069, 069b | `b02.collections.card2.pile.spine2` |
| `#000000` | — | black (botão da Apple, lombadas, máscaras) | 46 | 007, 013, 013b, 014, 018, 018b, 028b, 064, 069, 069b | `e07.sheet.buttons.apple` |
| `#ABCF82` | leaf |  | 45 | 002, 005, 006, 008, 011, 013, 015, 016, 017, 017b, 018b, 028, 028b, 028d, 030, 030b, 040, 056, 058, 059, 064 | `b02.shelf.book2.cover` |
| `#000000@0` | — | transparent (parada dos degradês e das máscaras) | 38 | 005, 008, 013, 013b, 014, 016, 017, 017b, 028b, 028d, 064, 069, 069b | `p05.card.body` |
| `#8A8073` | readerFooterNight |  | 31 | 015, 028b, 028d, 030, 030b, 056, 058, 064, 065 | `e15.username.field.at` |
| `#FFFFFF` | — | white (botões do Google e da Apple, campos) | 30 | 007, 008, 009, 009b, 010, 011, 015, 018b, 069, 069b | `e07.sheet.buttons.google` |
| `#E2D7C4` | markerRowBorder |  | 28 | 002, 005, 009, 009b, 017, 017b, 056, 064, 065 | `b02.statusTabs.reading` |
| `#E9DFCC` | hatchReader |  | 28 | 005, 006, 008, 011, 012, 013, 013b, 014, 017, 017b, 028b, 028c, 030b, 035 | `p05.achievements.next.bar` |
| `#CFC3AE` | dashReader |  | 25 | 005, 015, 016, 017, 017b, 018b, 030, 030b, 039, 042, 065, 069, 069b | `p05.card.divider` |
| `#3E3832` | — | inkBody (regras da senha, sinopse, textos de apoio) | 25 | 008, 011, 012, 017, 017b, 018b | `e08.sheet.form.rules.rule1` |
| `#EAE1D0` | — | rowDivider (fios entre as linhas dos ajustes) | 24 | 006, 008, 056, 058 | `aj06.reading.font` |
| `#058CD7` | azure |  | 20 | 002, 003, 005, 013b, 014, 017, 018, 018b, 028, 064, 065 | `b02.collections.card1.pile.spine2` |
| `#000000@0.18` | spine18 |  | 20 | 002, 003, 005, 013b, 014, 039, 040, 042 | `b02.shelf.book8.cover.spine` |
| `#898A8D` | — | systemKeyShadow (teclado do sistema, informativo) | 20 | 069, 069b | `sc69.keypad.key1` |
| `#552CB7` | violet |  | 18 | 002, 003, 005, 007, 008, 013b, 014, 017b, 028, 030b, 064, 069 | `b02.collections.card1.pile.spine1` |
| `#00995E` | emerald |  | 18 | 002, 005, 013b, 014, 028, 064 | `b02.collections.card1.pile.spine3` |
| `#1A1714@0.35` | dialTick |  | 18 | 005, 013b, 028, 028b, 028d | `p05.year.shelf.books.book2.line` |
| `#FFFAF1@0.55` | — | surface @ 0,55 | 14 | 005 | `p05.year.shelf.books.book1.line` |
| `#D9CCB4` | paperLineCream |  | 13 | 028b, 030, 030b | `bu28b.books.result1` |
| `#2C2452` | — | lavenderInk (texto sobre o lavanda: edição, bio) | 12 | 005, 006, 017b, 058, 064, 065 | `p05.hero.edition` |
| `#B9AE9C` | kickerOnInk |  | 12 | 018, 018b | `cr18.top.session` |
| `#F1E7D5` | — | toggleTrackOff (trilho desligado, chips neutros) | 11 | 030b, 056, 058, 064 | `n30b.reading.preview` |
| `#F2A815` | amber |  | 10 | 002, 003, 005, 013b, 014, 028, 064 | `b02.collections.card1.pile.spine4` |
| `#E4DACA` | reviewLineNeutral |  | 10 | 002, 005, 042 | `b02.shelf.book1.info.progress.bar` |
| `#2B2621` | — | inkWarm (sinopse, botões do cronômetro) | 10 | 017, 017b, 018, 018b | `d17.synopsis.text` |
| `#1E1A17` | — | cameraFrame (o quadro da câmera do scanner) | 9 | 003, 039, 040, 041, 042, 069, 069b | `sc03.frame` |
| `#000000@0.16` | — | black @ 0,16 | 9 | 064, 065 | `p64.favorites.grid.slot1.book.cover.spine` |
| `#1A1714@0.25` | — | ink @ 0,25 | 9 | 064, 069, 069b | `p64.bottom.save` |
| `#8A7F63` | tipDash |  | 8 | 005, 056 | `p05.year.shelf.books.slot1` |
| `#767676` | — | inputDots (os pontos da senha do campo) | 8 | 008, 009, 009b, 010, 011, 015, 018b | `e08.sheet.form.password.field.input` |
| `#F7F0E3@0.85` | — | paper @ 0,85 | 8 | 018, 018b | `cr18.top.minimize` |
| `#1A1714@0.4` | — | ink @ 0,4 | 8 | 028 | `bu28.genres.tile1.book.spine` |
| `#F7F0E3@0` | paperTransparent |  | 7 | 002, 005, 006, 036, 036a, 059, 064 | `b02.bottomFade` |
| `#FED170@0.95` | — | sun @ 0,95 | 7 | 028b | `bu28b.books.result1.match.mark` |
| `#2E5314` | tagReadFg |  | 6 | 002, 003, 015, 064 | `b02.shelf.book5.info.tag` |
| `#FFFDF8` | paperWhite |  | 6 | 002, 003, 006, 039, 040, 042 | `b02.shelf.book7.cover` |
| `#D9CFBD` | — | sheetHandle (a alça das folhas) | 6 | 003, 039, 040, 041, 042, 065 | `sc03.sheet.handle` |
| `#1A1714@0.12` | — | ink @ 0,12 | 6 | 005, 006, 058, 064, 065 | `p05.hero.spine` |
| `#3D3830` | tipText |  | 6 | 005, 056, 059 | `p05.activity.item3.review` |
| `#CFC6B8` | — | paperMuted (texto sobre o escuro da 69) | 6 | 069, 069b | `sc69.heading.body` |
| `#A79C8B` | — | digitPending (os traços dos dígitos que faltam) | 6 | 069, 069b | `sc69.sticker.card.digits.number.dash1` |
| `#000000@0.12` | spine12 |  | 5 | 002, 005 | `b02.shelf.book4.cover.spine` |
| `#E1EDD0` | tagReadBg |  | 5 | 002, 003, 015 | `b02.shelf.book5.info.tag` |
| `#DCD2C1` | — | coverLines (as linhas da capa desenhada) | 5 | 002 | `b02.shelf.book7.cover.lines.line1` |
| `#1A1714@0.28` | — | ink @ 0,28 | 5 | 005, 006, 058, 064, 065 | `p05.hero.spineLine` |
| `#2A2520` | bookText |  | 5 | 028b | `bu28b.highlights.quote1.text` |
| `#000000@0.14` | — | black @ 0,14 | 4 | 002, 005 | `b02.shelf.book2.cover.spine` |
| `#4A413A` | — | cameraScene (a cena da câmera — referência) | 4 | 003, 039, 040, 042 | `sc03.camera` |
| `#2B2521` | — | cameraScene (a cena da câmera — referência) | 4 | 003, 039, 040, 042 | `sc03.camera` |
| `#191512` | — | cameraScene (a cena da câmera — referência) | 4 | 003, 039, 040, 042 | `sc03.camera` |
| `#000000@0.45` | — | black @ 0,45 | 4 | 003, 039, 040, 042 | `sc03.camera.book` |
| `#14110F@0.58` | — | scannerDim @ 0,58 | 4 | 003, 039, 040, 042 | `sc03.dim` |
| `#EFE6D5` | — | cardBody (o corpo da carteirinha) | 4 | 005, 016 | `p05.card.body` |
| `#FFE9E4` | — | errorSoft (campo com erro, chip e aviso) | 4 | 009b, 040, 059, 069b | `e09b.sheet.form.password.field` |
| `#1A1714@0.45` | goalLine |  | 4 | 017, 036a | `d17.session.page` |
| `#A69C8F` | — | emptySlot (as vagas da estante vazia) | 4 | 036 | `b36.illustration.slot1` |
| `#F6C24A` | — | tapeYellow (a fita do adesivo) | 4 | 069, 069b | `sc69.sticker.tapeLeft` |
| `#F8AEB5` | — | tapePink (a fita do adesivo) | 4 | 069, 069b | `sc69.sticker.tapeRight` |
| `#000000@0.22` | spine22 |  | 3 | 002, 005, 007 | `b02.shelf.book1.cover.spine` |
| `#FF6C47` | — | cameraBook (o livro na câmera — referência) | 3 | 003, 039, 042 | `sc03.camera.book` |
| `#DB431F` | — | cameraBook (o livro na câmera — referência) | 3 | 003, 039, 042 | `sc03.camera.book` |
| `#D9D0C0` | — | themePreviewLineLight (prévia do tema claro) | 3 | 006 | `aj06.reading.theme.light.preview.line1` |
| `#CDB78E` | — | themePreviewLineSepia (prévia do tema sépia) | 3 | 006 | `aj06.reading.theme.sepia.preview.line1` |
| `#4A443D` | — | themePreviewLineDark (prévia do tema escuro) | 3 | 006 | `aj06.reading.theme.dark.preview.line1` |
| `#000000@0.1` | — | black @ 0,1 | 2 | 002, 005 | `b02.shelf.book3.cover.spine` |
| `#000000@0.15` | spine15 |  | 2 | 003, 042 | `sc03.sheet.book.cover.spine` |
| `#4A4030` | — | inkOnYellow (texto sobre o amarelo) | 2 | 006 | `aj06.goals.reminder.body` |
| `#747775` | — | googleBorder (kit da marca do Google) | 2 | 007 | `e07.sheet.buttons.google` |
| `#2B2420` | — | coverDark (capa escura da sugestão) | 2 | 013b, 014 | `e13b.suggestions.book5.cover` |
| `#000000@0.2` | — | black @ 0,2 | 2 | 017, 017b | `d17.cover.book.spine` |
| `#CFC6EE` | — | lavenderTrack (o trilho do progresso) | 2 | 017b | `d17b.progress.bar.track` |
| `#3A332C` | — | timerPause (o botão de pausar do cronômetro) | 2 | 018, 018b | `cr18.controls.pause.button` |
| `#F7F0E3@0.6` | — | paper @ 0,6 | 2 | 018, 018b | `cr18.note.button` |
| `#8F8577` | — | lockHint (o aviso de bloqueio do cronômetro) | 2 | 018, 018b | `cr18.lockHint` |
| `#3B3466` | captionOnBrand |  | 2 | 028b, 036a | `bu28b.tabs.all.count` |
| `#221D19` | — | permissionBackdrop (o fundo listrado sem permissão) | 2 | 041 | `sc41.backdrop` |
| `#FFB8A6` | — | coralSoft (ícones de aviso suave) | 2 | 056, 059 | `aj56.visibility.list.stats.icon` |
| `#FFFAF1@0.6` | — | surface @ 0,6 | 2 | 064, 065 | `p64.preview.tags.genres` |
| `#FFFAF1@0.09` | — | surface @ 0,09 | 2 | 069, 069b | `sc69.backdrop` |
| `#D1D4DA` | — | systemKeyboard (o teclado do sistema, informativo) | 2 | 069, 069b | `sc69.keypad` |
| `#EFE7D7` | tagSandBg |  | 1 | 002 | `b02.shelf.book4.info.tag` |
| `#4A4238` | inkWarm |  | 1 | 002 | `b02.shelf.book4.info.tag` |
| `#ECE7FA` | tagLavenderBg |  | 1 | 002 | `b02.shelf.book6.info.tag` |
| `#3B2D86` | tagLavenderFg |  | 1 | 002 | `b02.shelf.book6.info.tag` |
| `#3D3524` | — | inkOnYellowDeep (rótulo da meta do ano) | 1 | 005 | `p05.year.goal.count.label` |
| `#4A3B12` | — | inkOnGold (texto do plano) | 1 | 006 | `aj06.plan.body` |
| `#F1E2C4` | — | themePreviewSepia (prévia do tema sépia) | 1 | 006 | `aj06.reading.theme.sepia.preview` |
| `#4A3620` | — | themePreviewSepiaText (prévia do tema sépia) | 1 | 006 | `aj06.reading.theme.sepia.preview.sample` |
| `#1E1B18` | — | themePreviewDark (prévia do tema escuro) | 1 | 006 | `aj06.reading.theme.dark.preview` |
| `#EDE4D3` | — | themePreviewDarkText (prévia do tema escuro) | 1 | 006 | `aj06.reading.theme.dark.preview.sample` |
| `#1A1714@0.16` | — | ink @ 0,16 | 1 | 006 | `aj06.goals.reminder` |
| `#A3301A` | — | dangerDeep (excluir conta) | 1 | 006 | `aj06.footer.delete` |
| `#1F1F1F` | — | googleText (kit da marca do Google) | 1 | 007 | `e07.sheet.buttons.google` |
| `#A99E8C` | — | digitPlaceholder (o dígito vazio do código) | 1 | 010 | `e10.sheet.code.digit6` |
| `#1A1714@0.82` | — | ink @ 0,82 | 1 | 013b | `e13b.coach.spotlight` |
| `#FFFAF1@0.7` | chipGlass |  | 1 | 017 | `d17.session.page` |
| `#5B2A33` | — | clubKicker (rótulo do clube, rosa escuro) | 1 | 017 | `d17.highlights.club.kicker` |
| `#0C0A08@0.62` | — | sheetScrim @ 0,62 | 1 | 018b | `cr18b.scrim` |
| `#2F2A4A` | — | lavenderInkDeep (texto do primeiro livro) | 1 | 036a | `e36a.firstBook.body` |
| `#4A3C17` | — | inkOnYellowWarm (texto do hoje) | 1 | 036a | `e36a.today.body` |
| `#FF552E@0.45` | — | flame @ 0,45 | 1 | 039 | `sc39.scanLine` |
| `#B9DA94` | — | cameraBookGreen (o livro na câmera — referência) | 1 | 040 | `sc40.camera.book` |
| `#8DB565` | — | cameraBookGreen (o livro na câmera — referência) | 1 | 040 | `sc40.camera.book` |
| `#B83A1C` | — | danger (o rótulo de excluir) | 1 | 058 | `aj58.delete.label` |
| `#1A1714@0.5` | — | ink @ 0,5 | 1 | 065 | `p65.scrim` |
| `#F7D9A0` | — | thumbCoverGold (a capa da opção da 65) | 1 | 065 | `p65.sheet.options.option1.thumb.cover` |
| `#FFF3CF` | — | digitSlotActive (o dígito do ISBN em edição) | 1 | 069 | `sc69.sticker.card.digits.slot` |

Notas: `@a` = alfa; cores de degradê (roda de cores, véus) entram como paradas do gradiente do pintor, não como tokens soltos. `#000000@0` = `transparent` dos degradês.

## Raios

| raio | já existe | usos | exemplos |
|---|---|---|---|
| 999px | pill | 298 | `b02.search.field`, `b02.statusTabs.all`, `b02.statusTabs.all.count` |
| 50% | — | 288 | `b02.header.add`, `b02.search.filters`, `b02.shelf.book1.cover.circle` |
| 20px | navItem | 47 | `b02.nav.home`, `b02.nav.library`, `b02.nav.scanner` |
| 2px | — | 42 | `b02.collections.card1.pile.spine1.band`, `b02.collections.card1.pile.spine2.band`, `b02.collections.card1.pile.spine3.band` |
| 16px | — | 36 | `p05.card`, `e08.sheet.form.name.field`, `e08.sheet.form.email.field` |
| 6px | — | 35 | `b02.shelf.row1.plank`, `b02.shelf.row2.plank`, `b02.shelf.book5.cover.formatBadge` |
| 2px 2px 1px 1px | — | 30 | `p05.year.shelf.books.book1`, `p05.year.shelf.books.book2`, `p05.year.shelf.books.book3` |
| 1px | — | 29 | `p05.year.shelf.books.book1.line`, `p05.year.shelf.books.book2.line`, `p05.year.shelf.books.book3.line` |
| 4px 9px 9px 4px | — | 25 | `b02.shelf.book1.cover`, `b02.shelf.book2.cover`, `b02.shelf.book3.cover` |
| 4px | — | 21 | `sc03.camera.label`, `p05.favorites.shelf.books.book1.lines.line1`, `p05.favorites.shelf.books.book1.lines.line2` |
| 18px | — | 20 | `p05.year.stats.pages`, `p05.year.stats.hours`, `p05.year.stats.streak` |
| 3px | — | 19 | `b02.collections.card1.pile.spine1`, `b02.collections.card1.pile.spine2`, `b02.collections.card1.pile.spine3` |
| 12px | — | 18 | `e08.card`, `e10.sheet.code.digit1`, `e10.sheet.code.digit2` |
| 22px | cardM | 17 | `b02.collections.card1`, `b02.collections.card2`, `b02.collections.card3` |
| 24px | list | 17 | `aj06.reading.card`, `aj06.more.list`, `aj06.help.list` |
| 14px | — | 13 | `aj06.reading.theme.light.preview`, `aj06.reading.theme.sepia.preview`, `aj06.reading.theme.dark.preview` |
| 4px 8px 8px 4px | — | 12 | `bu28.genres.tile1.book`, `bu28.genres.tile2.book`, `bu28.genres.tile3.book` |
| 5px | — | 8 | `p05.year.shelf.plank`, `e13b.suggestions.book3.cover.lines.line1`, `e13b.suggestions.book3.cover.lines.line2` |
| 32px 32px 44px 44px | — | 8 | `e07.sheet`, `e08.sheet`, `e09.sheet` |
| 28px | card | 7 | `b02.nav`, `p05.year`, `p05.nav` |
| 3px 6px 6px 3px | — | 7 | `e36a.firstBook.illustration.slot1`, `e36a.firstBook.illustration.slot2`, `e36a.firstBook.illustration.slot3` |
| 3px 7px 7px 3px | — | 6 | `p05.favorites.shelf.books.book1`, `p05.favorites.shelf.books.book2`, `p05.favorites.shelf.books.book3` |
| 6px 12px 12px 6px | — | 6 | `bu28.trending.book1.cover`, `bu28.trending.book2.cover`, `bu28.trending.book3.cover` |
| 30px 30px 44px 44px | — | 5 | `sc03.sheet`, `sc39.sheet`, `sc40.sheet` |
| 3px 8px 8px 3px | — | 5 | `sc03.sheet.book.cover`, `p05.reading.grid.book1.cover.art`, `p05.reading.grid.book2.cover.art` |
| 3px 5px 5px 3px | — | 5 | `p65.sheet.head.current.cover`, `p65.sheet.options.option1.thumb.cover`, `p65.sheet.options.option2.thumb.cover` |
| 10px | — | 4 | `sc03.detected`, `n30b.reading.preview.appIcon`, `sc40.detected` |
| 20px 20px 0px 0px | — | 3 | `b02.shelf.book4.cover.arch`, `sc69.toolbar`, `sc69b.toolbar` |
| 1.5px | — | 3 | `sc03.sheet.book.collection.pile.spine1`, `sc03.sheet.book.collection.pile.spine2`, `sc03.sheet.book.collection.pile.spine3` |
| 32px 32px 0px 0px | — | 2 | `p05.reading.grid.book2.cover.arch`, `cr18b.sheet` |
| 8px 24px 24px 8px | — | 2 | `aj06.account`, `aj58.account` |
| 27px 27px 0px 0px | — | 2 | `e13b.suggestions.book6.cover.arch`, `e14.suggestions.book6.cover.arch` |
| 11px 11px 0px 0px | — | 2 | `e13b.suggestions.book6.cover.door`, `e14.suggestions.book6.cover.door` |
| 5px 14px 14px 5px | — | 2 | `d17.cover.book`, `d17b.cover.book` |
| 8px 22px 22px 8px | — | 2 | `p64.preview`, `p65.preview` |
| 9px | — | 2 | `sc69.sticker.card.digits.slot`, `sc69b.sticker.card.digits.check` |
| 13px | — | 2 | `sc69.toolbar.x`, `sc69b.toolbar.x` |
| 40px 40px 0px 0px | — | 1 | `b02.shelf.book2.cover.arch` |
| 34px 34px 0px 0px | — | 1 | `b02.shelf.book4.cover.archOutline` |
| 31px 31px 0px 0px | — | 1 | `b02.shelf.book9.cover.arch` |
| 13px 13px 0px 0px | — | 1 | `b02.shelf.book9.cover.door` |
| 44px 0px 0px 44px | — | 1 | `b02.shelf.book10.cover.capsule` |
| 8px 26px 26px 8px | — | 1 | `p05.hero` |
| 23px 23px 0px 0px | — | 1 | `p05.favorites.shelf.books.book2.arch` |
| 10px 10px 0px 0px | — | 1 | `p05.favorites.shelf.books.book2.door` |
| 32px 0px 0px 32px | — | 1 | `p05.favorites.shelf.books.book3.band` |
| 26px | — | 1 | `aj06.goals.card` |
| 4px 10px 10px 4px | — | 1 | `e07.cover` |
| 7px | — | 1 | `e08.sheet.form.newsletter.box` |
| 6px 14px 14px 6px | — | 1 | `bu28d.cover.preview.book` |
| 18px 18px 0px 0px | — | 1 | `p64.favorites.grid.slot2.book.cover.arch` |
| 7px 7px 0px 0px | — | 1 | `p64.favorites.grid.slot2.book.cover.door` |
| 13px 0px 0px 13px | — | 1 | `p64.favorites.grid.slot3.book.cover.band` |
| 8px 0px 0px 8px | — | 1 | `p65.sheet.head.current.cover.band` |

## Bordas

| borda | já existe (AppStrokes) | usos | exemplos |
|---|---|---|---|
| 1.5px solid | regular | 709 | `b02.header.add`, `b02.search.field`, `b02.search.filters` |
| 1.2px solid | thin | 60 | `b02.collections.card1.pile.spine1`, `b02.collections.card1.pile.spine2`, `b02.collections.card1.pile.spine3` |
| 1.5px dashed | regular | 39 | `p05.card.divider`, `p05.achievements.next`, `e10.sheet.code.digit6` |
| 1.3px solid | — | 35 | `bu28.trending.book1.cover.window1`, `bu28.trending.book1.cover.window2`, `bu28.trending.book1.cover.window3` |
| 1px solid | divider | 31 | `sc03.sheet.book.collection.pile.spine1`, `sc03.sheet.book.collection.pile.spine2`, `sc03.sheet.book.collection.pile.spine3` |
| 1.2px dashed | thin | 21 | `p05.year.shelf.books.slot1`, `p05.year.shelf.books.slot2`, `p05.year.shelf.books.slot3` |
| 2px inset | — | 8 | `e08.sheet.form.password.field.input`, `e09.sheet.form.password.field.input`, `e09b.sheet.form.password.field.input` |
| 3px solid | — | 4 | `sc03.detected`, `e15.photo.add`, `sc40.detected` |
| 1.8px dashed | — | 4 | `b36.illustration.slot1`, `b36.illustration.slot2`, `b36.illustration.slot3` |
| 1.6px dashed | — | 4 | `e36a.firstBook.illustration.slot1`, `e36a.firstBook.illustration.slot2`, `e36a.firstBook.illustration.slot3` |
| 1.3px dashed | — | 3 | `sc41.sheet.path`, `sc42.sheet.goal`, `aj56.blockNote` |
| 2px solid | — | 1 | `sc03.camera.book.ring` |
| 2.5px solid | — | 1 | `aj06.reading.theme.sepia.preview` |
| 2px dashed | — | 1 | `e13b.coach.ring` |
| 1.6px solid | — | 1 | `sc69b.sticker.card.digits.check` |

## Sombras (todas sem desfoque)

| sombra | usos | exemplos |
|---|---|---|
| `#1A1714 2px 2px 0px 0px` | 68 | `b02.statusTabs.all`, `sc03.status.chip`, `p05.hero.avatar.streak` |
| `#1A1714 3px 3px 0px 0px` | 35 | `sc03.sheet.book.cover`, `p05.hero.avatar.circle`, `aj06.plan` |
| `#1A1714 0px 4px 0px 0px` | 26 | `b02.nav`, `b02.nav.scanner.fab`, `sc03.sheet` |
| `#898A8D 0px 1px 0px 0px` | 20 | `sc69.keypad.key1`, `sc69.keypad.key2`, `sc69.keypad.key3` |
| `#1A1714 4px 4px 0px 0px` | 13 | `p05.card`, `p05.year`, `aj06.account` |
| `#B6ACE4 0px 0px 0px 4px` | 8 | `e08.sheet.form.password.field`, `e09.sheet.form.password.field`, `e10.sheet.code.digit5` |
| `#1A1714 -3px 3px 0px 0px` | 8 | `bu28.genres.tile1.book`, `bu28.genres.tile2.book`, `bu28.genres.tile3.book` |
| `#1A1714 5px 5px 0px 0px` | 7 | `p05.hero`, `e07.wordmark.label`, `e35.wordmark.label` |
| `#1A1714 0px 3px 0px 0px` | 5 | `b02.shelf.row1.plank`, `b02.shelf.row2.plank`, `b02.shelf.row3.plank` |
| `#000000@0.45 0px 30px 60px 0px` | 4 | `sc03.camera.book`, `sc39.camera.book`, `sc40.camera.book` |
| `#14110F@0.58 0px 0px 0px 1200px` | 4 | `sc03.dim`, `sc39.dim`, `sc40.dim` |
| `#1A1714 0px 0px 0px 1.5px, #1A1714 0px 0px 0px 1.5px inset` | 3 | `sc03.detected`, `sc40.detected`, `sc42.detected` |
| `#1A1714 6px 6px 0px 0px` | 3 | `e16.card`, `d17.cover.book`, `d17b.cover.book` |
| `#000000 3px 3px 0px 0px` | 2 | `cr18.book.cover`, `cr18b.book.cover` |
| `#3A332C 0px 0px 0px 5px` | 2 | `cr18.controls.pause.button`, `cr18b.controls.pause.button` |
| `#1A1714 0px 2px 0px 0px` | 1 | `p05.year.shelf.plank` |
| `#FF552E 3px 3px 0px 0px` | 1 | `e09b.sheet.form.password.field` |
| `#1A1714@0.82 0px 0px 0px 1400px` | 1 | `e13b.coach.spotlight` |
| `#FFFAF1 0px 0px 0px 2.5px, #1A1714 0px 0px 0px 4px` | 1 | `bu28d.cover.options.colors.swatch1` |
| `#1A1714 0px 0px 0px 1.5px, #FF552E@0.45 0px 0px 18px 4px` | 1 | `sc39.scanLine` |
| `#F7F0E3 0px 0px 0px 2.5px, #1A1714 0px 0px 0px 4px` | 1 | `p64.colors.lavender` |
| `#1A1714@0.25 0px 4px 0px 0px` | 1 | `p64.bottom.save` |
| `#1A1714@0.12 0px 0px 0px 2px` | 1 | `p65.sheet.options.option1.thumb.cover.square` |

## Estilos de texto (342 combinações medidas)

| família | tamanho | peso | altura | ls | cor | extra | família+tamanho na v1 | usos | exemplo |
|---|---|---|---|---|---|---|---|---|---|
| -apple-system | 15.5 | 500 | 20px | -0.2px | `#000000` |  | **novo** | 1 | `e07.sheet.buttons.apple` |
| Bricolage Grotesque | 15 | 700 | 15.75px | -0.5px | `#3E3832` |  | **novo** | 1 | `d17.session.today.goal` |
| Bricolage Grotesque | 15 | 700 | 15.75px | -0.5px | `#2C2452` |  | **novo** | 1 | `d17b.progress.page.total` |
| Bricolage Grotesque | 15 | 800 | normal | normal | `#FED170` |  | **novo** | 1 | `n30b.reading.preview.appIcon` |
| Bricolage Grotesque | 17 | 800 | 18.7px | -0.3px | `#1A1714` |  | sim | 1 | `p05.card.goals.daily` |
| Bricolage Grotesque | 17 | 800 | 17.85px | -0.3px | `#1A1714` |  | sim | 6 | `bu28.genres.tile1.label` |
| Bricolage Grotesque | 17 | 800 | 17.85px | -0.3px | `#F7F0E3` |  | sim | 2 | `bu28.genres.tile4.label` |
| Bricolage Grotesque | 17 | 800 | 16.15px | -0.4px | `#1A1714` |  | sim | 3 | `bu28.trending.book1.cover.title` |
| Bricolage Grotesque | 17 | 800 | 16.15px | -0.4px | `#F7F0E3` |  | sim | 1 | `bu28.trending.book4.cover.title` |
| Bricolage Grotesque | 17 | 800 | 16.66px | -0.4px | `#1A1714` |  | sim | 1 | `bu28d.cover.preview.book.title` |
| Bricolage Grotesque | 17 | 800 | normal | -0.3px | `#1A1714` |  | sim | 5 | `e36a.today.title` |
| Bricolage Grotesque | 18 | 800 | 18px | normal | `#1A1714` |  | sim | 1 | `p05.achievements.grid.badge4.medal.center.number` |
| Bricolage Grotesque | 18 | 800 | normal | -0.3px | `#1A1714` |  | sim | 2 | `e13b.suggestions.title` |
| Bricolage Grotesque | 18 | 800 | normal | normal | `#1A1714` |  | sim | 2 | `d17.highlights.club.rank` |
| Bricolage Grotesque | 18 | 800 | 19.8px | -0.4px | `#1A1714` |  | sim | 1 | `sc42.sheet.book.title` |
| Bricolage Grotesque | 18 | 800 | normal | -0.4px | `#1A1714` |  | sim | 1 | `p64.favoritesHeader.title` |
| Bricolage Grotesque | 19 | 800 | 20.9px | -0.4px | `#1A1714` |  | **novo** | 1 | `sc03.sheet.book.title` |
| Bricolage Grotesque | 20 | 800 | normal | -0.4px | `#1A1714` |  | sim | 13 | `b02.collections.title` |
| Bricolage Grotesque | 20 | 800 | 22px | -0.4px | `#1A1714` |  | sim | 4 | `e12.daily.option1.minutes` |
| Bricolage Grotesque | 20 | 800 | 21px | -0.4px | `#1A1714` |  | sim | 1 | `sc39.sheet.lead.title` |
| Bricolage Grotesque | 20 | 800 | normal | -0.5px | `#1A1714` |  | sim | 5 | `aj56.visibility.header.title` |
| Bricolage Grotesque | 21 | 800 | 21px | -0.5px | `#1A1714` | tnum | **novo** | 3 | `cr18b.sheet.stats.session.value` |
| Bricolage Grotesque | 21 | 800 | normal | -0.4px | `#1A1714` |  | **novo** | 7 | `bu28.recent.title` |
| Bricolage Grotesque | 21 | 800 | 22.05px | -0.5px | `#1A1714` |  | **novo** | 2 | `sc40.sheet.lead.title` |
| Bricolage Grotesque | 22 | 800 | normal | -0.5px | `#1A1714` |  | sim | 5 | `p05.year.title` |
| Bricolage Grotesque | 22 | 800 | 22px | normal | `#1A1714` |  | sim | 3 | `p05.achievements.grid.badge1.medal.center.number` |
| Bricolage Grotesque | 22 | 800 | 23.1px | -0.5px | `#1A1714` |  | sim | 3 | `e13b.coach.card.title` |
| Bricolage Grotesque | 22 | 800 | 22px | -0.5px | `#1A1714` |  | sim | 2 | `e16.card.goals.daily.value` |
| Bricolage Grotesque | 22 | 800 | 23.1px | normal | `#1A1714` |  | sim | 6 | `aj59.losses.books.value` |
| Bricolage Grotesque | 24 | 800 | normal | -0.5px | `#1A1714` | tnum | sim | 2 | `n30b.quiet.range.from.value` |
| Bricolage Grotesque | 25 | 800 | normal | -0.6px | `#1A1714` |  | **novo** | 3 | `p05.year.stats.pages.value` |
| Bricolage Grotesque | 25 | 800 | 25.5px | -0.6px | `#1A1714` |  | **novo** | 2 | `e36a.firstBook.title` |
| Bricolage Grotesque | 26 | 800 | 26.52px | -0.6px | `#1A1714` |  | sim | 1 | `b36.heading` |
| Bricolage Grotesque | 27 | 800 | 28.35px | -0.6px | `#FFFAF1` |  | **novo** | 2 | `sc69.heading.title` |
| Bricolage Grotesque | 28 | 800 | 28px | normal | `#1A1714` |  | **novo** | 5 | `e10.sheet.code.digit1` |
| Bricolage Grotesque | 28 | 800 | normal | -0.5px | `#1A1714` | tnum | **novo** | 1 | `n30b.reading.time.value` |
| Bricolage Grotesque | 28 | 800 | 28px | -0.7px | `#1A1714` |  | **novo** | 1 | `n30c.empty.title` |
| Bricolage Grotesque | 30 | 800 | 30px | -0.8px | `#1A1714` | tnum | **novo** | 1 | `e12.yearly.stepper.value` |
| Bricolage Grotesque | 30 | 800 | 29.4px | -1px | `#1A1714` |  | **novo** | 1 | `e16.sheet.title` |
| Bricolage Grotesque | 30 | 800 | 30px | -0.8px | `#1A1714` |  | **novo** | 1 | `bu28c.title` |
| Bricolage Grotesque | 32 | 800 | 32px | -1px | `#1A1714` |  | **novo** | 2 | `aj06.goals.yearly.value.number` |
| Bricolage Grotesque | 32 | 800 | 31.36px | -1px | `#1A1714` |  | **novo** | 7 | `e07.sheet.title` |
| Bricolage Grotesque | 32 | 800 | 29.44px | -1.1px | `#1A1714` |  | **novo** | 2 | `p64.preview.name` |
| Bricolage Grotesque | 32 | 800 | 32px | 0.5px | `#1A1714` | tnum | **novo** | 3 | `sc69.sticker.card.digits.number` |
| Bricolage Grotesque | 32 | 800 | 32px | 0.5px | `#A79C8B` | tnum | **novo** | 6 | `sc69.sticker.card.digits.number.dash1` |
| Bricolage Grotesque | 34 | 800 | 33.32px | -1.1px | `#1A1714` |  | sim | 9 | `e12.heading.title` |
| Bricolage Grotesque | 34 | 800 | 33.32px | -1px | `#1A1714` |  | sim | 1 | `bu28d.title` |
| Bricolage Grotesque | 36 | 800 | 36px | -1.2px | `#1A1714` |  | **novo** | 2 | `b02.header.title` |
| Bricolage Grotesque | 36 | 800 | 35.28px | -1.1px | `#1A1714` |  | **novo** | 4 | `bu28.title` |
| Bricolage Grotesque | 38 | 800 | 38px | -1px | `#1A1714` | tnum | **novo** | 1 | `cr18b.sheet.page.field.value` |
| Bricolage Grotesque | 38 | 800 | 37.24px | -1.2px | `#1A1714` |  | **novo** | 1 | `e36a.headline` |
| Bricolage Grotesque | 40 | 800 | 39.2px | -1.1px | `#1A1714` |  | **novo** | 1 | `d17b.title` |
| Bricolage Grotesque | 42 | 800 | 41.16px | -1.4px | `#1A1714` |  | sim | 1 | `b36.title` |
| Bricolage Grotesque | 46 | 800 | 42.32px | -1.6px | `#1A1714` |  | **novo** | 1 | `p05.hero.name` |
| Bricolage Grotesque | 46 | 800 | 46px | -1.8px | `#1A1714` |  | **novo** | 2 | `e07.wordmark.label.book` |
| Bricolage Grotesque | 58 | 800 | 49.3px | -2px | `#1A1714` |  | **novo** | 1 | `p05.year.goal.count.number` |
| Bricolage Grotesque | 74 | 800 | 74px | -2px | `#F7F0E3` | tnum | **novo** | 2 | `cr18.timer.time` |
| Figtree | 5.5 | 700 | normal | 0.77px | `#FF552E` |  | **novo** | 2 | `sc03.sheet.book.cover.author` |
| Figtree | 5.5 | 700 | normal | 0.77px | `#FED170` |  | **novo** | 2 | `e13b.suggestions.book1.cover.author` |
| Figtree | 5.5 | 700 | normal | 0.77px | `#1A1714` |  | **novo** | 2 | `e13b.suggestions.book2.cover.author` |
| Figtree | 5.5 | 700 | normal | 0.77px | `#FFFAF1` |  | **novo** | 8 | `e13b.suggestions.book3.cover.author` |
| Figtree | 6.5 | 700 | normal | 0.91px | `#F7F0E3` |  | sim | 2 | `b02.shelf.book1.cover.author` |
| Figtree | 6.5 | 700 | normal | 0.91px | `#1A1714` |  | sim | 3 | `b02.shelf.book2.cover.author` |
| Figtree | 6.5 | 700 | normal | 0.91px | `#FFFAF1` |  | sim | 2 | `b02.shelf.book8.cover.author` |
| Figtree | 6.5 | 800 | normal | 0.91px | `#6F665B` |  | sim | 1 | `b02.shelf.book7.cover.kicker` |
| Figtree | 8 | 800 | 8px | 0.8px | `#1A1714` |  | **novo** | 2 | `p05.achievements.grid.badge1.medal.center.unit` |
| Figtree | 8.5 | 700 | normal | 0.51px | `#1A1714` |  | **novo** | 4 | `sc03.camera.label.isbn` |
| Figtree | 8.5 | 800 | normal | 1.3px | `#1A1714` | tnum | **novo** | 1 | `p05.card.code.text` |
| Figtree | 9 | 800 | normal | 0.36px | `#1A1714` |  | **novo** | 2 | `b02.shelf.book5.cover.formatBadge` |
| Figtree | 9 | 800 | normal | 1.62px | `#1A1714` |  | **novo** | 4 | `sc03.camera.book.author` |
| Figtree | 9 | 800 | normal | 1.1px | `#1A1714` |  | **novo** | 1 | `e08.card.header.label` |
| Figtree | 9 | 800 | normal | 0.8px | `#5B544B` |  | **novo** | 1 | `e08.card.number` |
| Figtree | 9.5 | 800 | normal | 1.1px | `#6F665B` |  | **novo** | 2 | `e16.card.goals.daily.label` |
| Figtree | 9.5 | 800 | normal | 1.6px | `#1A1714` | tnum | **novo** | 1 | `e16.card.footer.code.text` |
| Figtree | 9.5 | 800 | normal | 1.33px | `#2C2452` |  | **novo** | 2 | `p64.preview.label` |
| Figtree | 10 | 700 | normal | normal | `#1A1714` |  | sim | 3 | `bu28.trending.book1.cover.author` |
| Figtree | 10 | 700 | normal | normal | `#F7F0E3` |  | sim | 1 | `bu28.trending.book4.cover.author` |
| Figtree | 10 | 800 | 16px | 1.4px | `#2C2452` |  | sim | 1 | `p05.hero.edition` |
| Figtree | 10 | 800 | normal | 1.3px | `#1A1714` |  | sim | 1 | `p05.card.header.title` |
| Figtree | 10 | 800 | normal | 1px | `#1A1714` | tnum | sim | 1 | `p05.card.header.number` |
| Figtree | 10 | 800 | 14px | normal | `#5B544B` |  | sim | 3 | `n30.today.list.item4.body.avatars.avatar1` |
| Figtree | 10.5 | 700 | normal | normal | `#1A1714` |  | sim | 3 | `bu28d.cover.preview.book.author` |
| Figtree | 10.5 | 800 | normal | 1.1px | `#6F665B` |  | sim | 8 | `d17.synopsis.fact1.label` |
| Figtree | 10.5 | 800 | normal | normal | `#1A1714` |  | sim | 3 | `bu28d.cover.preview.tag` |
| Figtree | 11 | 600 | normal | normal | `#5B544B` |  | sim | 15 | `b02.nav.home.label` |
| Figtree | 11 | 700 | normal | normal | `#1A1714` |  | sim | 5 | `b02.nav.scanner.label` |
| Figtree | 11 | 800 | normal | -0.2px | `#1A1714` |  | sim | 2 | `b02.nav.library.label` |
| Figtree | 11 | 800 | normal | normal | `#1A1714` |  | sim | 6 | `p05.nav.profile.label` |
| Figtree | 11 | 800 | normal | normal | `#5B544B` |  | sim | 3 | `e15.photo.info.optional` |
| Figtree | 11 | 800 | normal | 1.4px | `#1A1714` |  | sim | 1 | `e16.card.header.label` |
| Figtree | 11 | 800 | normal | 1px | `#1A1714` | tnum | sim | 1 | `e16.card.header.number` |
| Figtree | 11 | 800 | normal | 1.2px | `#6F665B` |  | sim | 20 | `d17.mood.paceLabel` |
| Figtree | 11 | 800 | normal | 1.1px | `#5B2A33` |  | sim | 1 | `d17.highlights.club.kicker` |
| Figtree | 11 | 800 | normal | 1.2px | `#2C2452` |  | sim | 1 | `d17b.progress.kicker` |
| Figtree | 11 | 800 | normal | 1px | `#1A1714` |  | sim | 2 | `d17b.highlights.club.date.weekday` |
| Figtree | 11 | 800 | normal | 1.1px | `#6F665B` |  | sim | 1 | `d17b.highlights.club.kicker` |
| Figtree | 11 | 800 | normal | 1.2px | `#3B3466` |  | sim | 1 | `e36a.firstBook.kicker` |
| Figtree | 11 | 800 | normal | normal | `#FFFAF1` |  | sim | 5 | `p64.favorites.grid.slot1.book.rank` |
| Figtree | 11 | 800 | normal | 1px | `#6F665B` |  | sim | 1 | `p65.sheet.optionsLabel` |
| Figtree | 11 | 800 | normal | normal | `#6F665B` |  | sim | 1 | `p65.sheet.options.option3.tag` |
| Figtree | 11 | 800 | normal | normal | `#552CB7` |  | sim | 1 | `sc69.sticker.card.barcode.prefix` |
| Figtree | 11.5 | 700 | normal | normal | `#4A4238` |  | sim | 1 | `b02.shelf.book4.info.tag` |
| Figtree | 11.5 | 700 | normal | normal | `#2E5314` |  | sim | 3 | `b02.shelf.book5.info.tag` |
| Figtree | 11.5 | 700 | normal | normal | `#3B2D86` |  | sim | 1 | `b02.shelf.book6.info.tag` |
| Figtree | 11.5 | 700 | normal | normal | `#1A1714` |  | sim | 2 | `d17.mood.pace.medium.percent` |
| Figtree | 11.5 | 700 | normal | normal | `#8A8073` |  | sim | 6 | `p64.fields.name.head.counter` |
| Figtree | 11.5 | 700 | 12.65px | normal | `#1A1714` |  | sim | 2 | `sc69.toolbar.x.caption` |
| Figtree | 11.5 | 800 | normal | normal | `#1A1714` |  | sim | 10 | `aj06.account.badge` |
| Figtree | 11.5 | 800 | normal | 1.8px | `#B9AE9C` |  | sim | 2 | `cr18.timer.status` |
| Figtree | 11.5 | 800 | normal | 1.6px | `#6F665B` |  | sim | 1 | `cr18b.sheet.label` |
| Figtree | 11.5 | 800 | normal | 1.3px | `#6F665B` |  | sim | 2 | `n30.today.label` |
| Figtree | 11.5 | 900 | normal | 1.1px | `#1A1714` |  | sim | 2 | `d17.cover.formatTag` |
| Figtree | 12 | 500 | 17.4px | normal | `#6F665B` |  | **novo** | 2 | `e07.sheet.legal` |
| Figtree | 12 | 600 | normal | normal | `#5B544B` | tnum | sim | 3 | `sc03.sheet.isbn` |
| Figtree | 12 | 600 | normal | normal | `#5B544B` |  | sim | 5 | `p05.card.goals.yearly` |
| Figtree | 12 | 600 | normal | normal | `#6F665B` |  | sim | 4 | `p05.activity.item1.time` |
| Figtree | 12 | 600 | normal | normal | `#8A8073` |  | sim | 3 | `bu28b.books.result1.match` |
| Figtree | 12 | 600 | 15.6px | normal | `#3D3830` |  | sim | 2 | `aj56.profileType.open.body` |
| Figtree | 12 | 700 | normal | normal | `#6F665B` |  | sim | 13 | `b02.statusTabs.reading.count` |
| Figtree | 12 | 700 | normal | normal | `#5B544B` |  | sim | 3 | `sc03.sheet.saveAs.label` |
| Figtree | 12 | 700 | 15px | normal | `#1A1714` |  | sim | 4 | `p05.achievements.grid.badge1.label` |
| Figtree | 12 | 700 | 17.4px | normal | `#1A1714` |  | sim | 4 | `e07.sheet.legal.terms` |
| Figtree | 12 | 700 | normal | normal | `#8A8073` | tnum | sim | 1 | `e15.bio.counter` |
| Figtree | 12 | 700 | normal | normal | `#3E3832` |  | sim | 8 | `d17.mood.tag1.percent` |
| Figtree | 12 | 700 | 15px | normal | `#3E3832` |  | sim | 3 | `cr18b.sheet.stats.session.label` |
| Figtree | 12 | 700 | normal | normal | `#8A8073` |  | sim | 7 | `n30.today.list.item1.time` |
| Figtree | 12 | 700 | normal | normal | `#1A1714` |  | sim | 6 | `aj59.losses.books.label` |
| Figtree | 12 | 800 | normal | normal | `#1A1714` |  | sim | 14 | `b02.statusTabs.all.count` |
| Figtree | 12 | 800 | normal | normal | `#2E5314` |  | sim | 3 | `sc03.sheet.chip` |
| Figtree | 12 | 800 | normal | 1.6px | `#B9AE9C` |  | sim | 2 | `cr18.top.session` |
| Figtree | 12 | 900 | 12px | normal | `#1A1714` |  | sim | 1 | `e09b.sheet.form.alert.badge` |
| Figtree | 12.5 | 500 | normal | normal | `#5B544B` |  | **novo** | 21 | `b02.collections.card1.count` |
| Figtree | 12.5 | 500 | 16px | normal | `#6F665B` |  | **novo** | 2 | `e08.sheet.form.name.hint` |
| Figtree | 12.5 | 500 | 16.875px | normal | `#5B544B` |  | **novo** | 1 | `e11.sheet.form.devices.body` |
| Figtree | 12.5 | 500 | normal | normal | `#6F665B` |  | **novo** | 1 | `e15.bio.hint` |
| Figtree | 12.5 | 500 | 16.25px | normal | `#5B544B` |  | **novo** | 16 | `aj56.visibility.list.shelf.body` |
| Figtree | 12.5 | 600 | 18.75px | normal | `#2C2452` |  | sim | 1 | `p05.hero.stats.text` |
| Figtree | 12.5 | 600 | normal | normal | `#5B544B` |  | sim | 8 | `p05.year.stats.pages.label` |
| Figtree | 12.5 | 600 | 16.25px | normal | `#4A3B12` |  | sim | 1 | `aj06.plan.body` |
| Figtree | 12.5 | 600 | normal | normal | `#4A4030` |  | sim | 1 | `aj06.goals.reminder.body` |
| Figtree | 12.5 | 600 | 16.875px | normal | `#4A4030` |  | sim | 1 | `aj06.goals.streak.body` |
| Figtree | 12.5 | 600 | normal | normal | `#3E3832` |  | sim | 7 | `e08.sheet.form.rules.rule1` |
| Figtree | 12.5 | 600 | normal | normal | `#6F665B` |  | sim | 13 | `e11.sheet.notice` |
| Figtree | 12.5 | 600 | 16.25px | normal | `#3E3832` |  | sim | 1 | `e12.yearly.hint` |
| Figtree | 12.5 | 600 | normal | normal | `#8F8577` |  | sim | 2 | `cr18.lockHint` |
| Figtree | 12.5 | 600 | 17.5px | normal | `#6F665B` |  | sim | 2 | `bu28d.footnote` |
| Figtree | 12.5 | 600 | 17.5px | normal | `#8A8073` |  | sim | 1 | `n30.footnote` |
| Figtree | 12.5 | 600 | 16.875px | normal | `#6F665B` |  | sim | 6 | `n30b.reading.smart.body` |
| Figtree | 12.5 | 600 | 16.875px | normal | `#4A3C17` |  | sim | 1 | `e36a.today.body` |
| Figtree | 12.5 | 600 | 17.5px | normal | `#3D3830` |  | sim | 3 | `aj56.blockNote.text` |
| Figtree | 12.5 | 700 | normal | normal | `#1A1714` |  | **novo** | 3 | `sc03.sheet.book.collection` |
| Figtree | 12.5 | 700 | normal | normal | `#5B544B` |  | **novo** | 4 | `aj06.goals.yearly.label` |
| Figtree | 12.5 | 700 | normal | normal | `#3E3832` |  | **novo** | 2 | `d17.meta.format` |
| Figtree | 12.5 | 700 | normal | normal | `#6F665B` |  | **novo** | 7 | `d17.mood.voters` |
| Figtree | 12.5 | 700 | normal | normal | `#B9AE9C` |  | **novo** | 4 | `cr18.controls.photo.label` |
| Figtree | 12.5 | 700 | normal | normal | `#F7F0E3` |  | **novo** | 2 | `cr18.controls.pause.label` |
| Figtree | 12.5 | 700 | normal | normal | `#8A8073` |  | **novo** | 3 | `aj56.visibility.header.note` |
| Figtree | 12.5 | 800 | 18.75px | normal | `#1A1714` |  | **novo** | 4 | `p05.hero.stats.followers` |
| Figtree | 12.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 14 | `p05.reading.grid.book1.caption` |
| Figtree | 12.5 | 800 | normal | normal | `#1A1714` | tnum | **novo** | 1 | `sc42.sheet.book.progress.percent` |
| Figtree | 12.5 | 900 | normal | normal | `#1A1714` |  | **novo** | 1 | `sc42.sheet.book.reading.page` |
| Figtree | 12.5 | 900 | 17.5px | normal | `#1A1714` |  | **novo** | 2 | `aj56.blockNote.text.lead` |
| Figtree | 13 | 500 | 18.2px | normal | `#5B544B` |  | sim | 1 | `e15.photo.info.hint` |
| Figtree | 13 | 500 | normal | normal | `#6F665B` |  | sim | 1 | `e15.username.status.rule` |
| Figtree | 13 | 500 | normal | normal | `#5B544B` |  | sim | 1 | `e36a.header.greeting` |
| Figtree | 13 | 600 | normal | normal | `#2C2452` |  | sim | 3 | `aj06.account.email` |
| Figtree | 13 | 600 | normal | normal | `#5B544B` |  | sim | 9 | `aj06.reading.theme.light.label` |
| Figtree | 13 | 600 | normal | normal | `#6F665B` |  | sim | 5 | `e10.sheet.help.spam` |
| Figtree | 13 | 600 | 16.9px | normal | `#5B544B` |  | sim | 3 | `e12.daily.option1.hint` |
| Figtree | 13 | 600 | 16.9px | normal | `#1A1714` |  | sim | 1 | `e12.daily.option3.hint` |
| Figtree | 13 | 600 | normal | normal | `#3E3832` |  | sim | 1 | `d17.session.total` |
| Figtree | 13 | 600 | 17.55px | normal | `#3E3832` |  | sim | 1 | `d17.session.page.text` |
| Figtree | 13 | 600 | 17.55px | normal | `#6F665B` |  | sim | 1 | `d17.session.page.text.optional` |
| Figtree | 13 | 600 | normal | normal | `#B9AE9C` |  | sim | 2 | `cr18.book.author` |
| Figtree | 13 | 600 | 17.55px | normal | `#5B544B` |  | sim | 3 | `n30b.reading.time.hint` |
| Figtree | 13 | 600 | 17.55px | normal | `#2C2452` |  | sim | 2 | `p64.preview.bio` |
| Figtree | 13 | 600 | normal | normal | `#5B544B` | tnum | sim | 2 | `sc69.sticker.card.count.total` |
| Figtree | 13 | 600 | normal | normal | `#CFC6B8` |  | sim | 1 | `sc69.sticker.notes.line` |
| Figtree | 13 | 600 | 18.2px | normal | `#CFC6B8` |  | sim | 1 | `sc69b.sticker.notes.line` |
| Figtree | 13 | 700 | normal | normal | `#5B544B` |  | sim | 1 | `p05.achievements.header.count` |
| Figtree | 13 | 700 | normal | normal | `#1A1714` |  | sim | 4 | `p05.achievements.next.title` |
| Figtree | 13 | 700 | normal | normal | `#F7F0E3` |  | sim | 2 | `cr18.note.button` |
| Figtree | 13 | 800 | 13.65px | -0.2px | `#1A1714` |  | sim | 1 | `b02.shelf.book7.cover.title` |
| Figtree | 13 | 800 | normal | normal | `#1A1714` |  | sim | 33 | `p05.hero.avatar.streak` |
| Figtree | 13 | 800 | normal | normal | `#1A1714` | tnum | sim | 7 | `e12.top.step` |
| Figtree | 13 | 800 | 17.55px | normal | `#1A1714` |  | sim | 2 | `d17.session.page.text.strong` |
| Figtree | 13 | 800 | normal | normal | `#F7F0E3` |  | sim | 3 | `cr18.top.sound` |
| Figtree | 13 | 800 | normal | normal | `#8A8073` |  | sim | 1 | `n30b.reading.days.sat` |
| Figtree | 13 | 900 | 17.55px | normal | `#1A1714` |  | sim | 1 | `sc42.sheet.goal.text.strong` |
| Figtree | 13.5 | 500 | normal | normal | `#5B544B` |  | **novo** | 4 | `sc03.sheet.footer` |
| Figtree | 13.5 | 500 | normal | normal | `#CFC6B8` |  | **novo** | 2 | `sc69.sticker.notes.noIsbn` |
| Figtree | 13.5 | 600 | 18.225px | normal | `#3E3832` |  | **novo** | 1 | `e08.sheet.form.newsletter` |
| Figtree | 13.5 | 600 | normal | normal | `#5B544B` |  | **novo** | 1 | `bu28.trending.subtitle` |
| Figtree | 13.5 | 600 | 18px | normal | `#8A8073` |  | **novo** | 3 | `bu28d.form.author.label.optional` |
| Figtree | 13.5 | 600 | 18.9px | normal | `#5B544B` |  | **novo** | 10 | `n30.today.list.item1.body` |
| Figtree | 13.5 | 600 | 18.9px | normal | `#2F2A4A` |  | **novo** | 1 | `e36a.firstBook.body` |
| Figtree | 13.5 | 600 | normal | normal | `#1A1714` |  | **novo** | 9 | `p64.pronouns.he` |
| Figtree | 13.5 | 600 | 18.9px | normal | `#CFC6B8` |  | **novo** | 2 | `sc69.heading.body` |
| Figtree | 13.5 | 700 | normal | normal | `#5B544B` |  | **novo** | 1 | `aj06.reading.header.reset` |
| Figtree | 13.5 | 700 | 18.9px | normal | `#1A1714` |  | **novo** | 1 | `e09b.sheet.form.alert.text` |
| Figtree | 13.5 | 700 | normal | normal | `#3B3466` |  | **novo** | 1 | `bu28b.tabs.all.count` |
| Figtree | 13.5 | 700 | normal | normal | `#8A8073` |  | **novo** | 3 | `bu28b.tabs.books.count` |
| Figtree | 13.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 28 | `sc03.sheet.footer.link` |
| Figtree | 13.5 | 800 | 18px | normal | `#1A1714` |  | **novo** | 16 | `e08.sheet.form.name.label` |
| Figtree | 13.5 | 800 | normal | normal | `#F7F0E3` |  | **novo** | 1 | `bu28b.clubs.club2.join` |
| Figtree | 13.5 | 800 | 18.9px | normal | `#1A1714` |  | **novo** | 2 | `n30.today.list.item1.body.author` |
| Figtree | 13.5 | 800 | normal | normal | `#FFFAF1` |  | **novo** | 2 | `sc69.sticker.notes.noIsbn.link` |
| Figtree | 13.5 | 800 | 18.225px | normal | `#1A1714` |  | **novo** | 1 | `sc69b.sticker.card.alert.text` |
| Figtree | 14 | 500 | normal | normal | `#5B544B` |  | sim | 1 | `b02.sortView.sort.prefix` |
| Figtree | 14 | 500 | 18.9px | normal | `#1A1714` |  | sim | 3 | `p05.activity.item1.text` |
| Figtree | 14 | 500 | 19.6px | normal | `#3D3830` |  | sim | 1 | `p05.activity.item3.review` |
| Figtree | 14 | 500 | 20.3px | normal | `#5B544B` |  | sim | 1 | `e13b.coach.card.body` |
| Figtree | 14 | 600 | normal | normal | `#1A1714` |  | **novo** | 15 | `b02.statusTabs.reading` |
| Figtree | 14 | 600 | normal | normal | `#5B544B` |  | **novo** | 13 | `sc03.sheet.book.author` |
| Figtree | 14 | 600 | normal | normal | `#6F665B` |  | **novo** | 1 | `e10.sheet.resend.text` |
| Figtree | 14 | 600 | normal | normal | `#B9AE9C` |  | **novo** | 2 | `cr18.timer.today` |
| Figtree | 14 | 600 | 18.9px | normal | `#1A1714` |  | **novo** | 3 | `bu28c.tips.tip1` |
| Figtree | 14 | 600 | 20.3px | normal | `#5B544B` |  | **novo** | 2 | `sc41.sheet.body` |
| Figtree | 14 | 600 | 19.6px | normal | `#5B544B` |  | **novo** | 1 | `aj56.lead` |
| Figtree | 14 | 600 | normal | normal | `#8A8073` |  | **novo** | 1 | `p65.sheet.search.placeholder` |
| Figtree | 14 | 700 | normal | normal | `#1A1714` |  | sim | 27 | `b02.collections.seeAll` |
| Figtree | 14 | 700 | 16.8px | normal | `#1A1714` |  | sim | 12 | `b02.collections.card1.title` |
| Figtree | 14 | 700 | normal | normal | `#3D3524` |  | sim | 1 | `p05.year.goal.count.label` |
| Figtree | 14 | 700 | normal | normal | `#5B544B` |  | sim | 1 | `e16.card.handle` |
| Figtree | 14 | 700 | normal | normal | `#6F665B` |  | sim | 1 | `cr18b.sheet.page.field.prefix` |
| Figtree | 14 | 800 | normal | normal | `#1A1714` |  | sim | 32 | `b02.statusTabs.all` |
| Figtree | 14 | 800 | 18.9px | normal | `#1A1714` |  | sim | 3 | `p05.activity.item1.text.book` |
| Figtree | 14 | 800 | normal | normal | `#1A1714` | tnum | sim | 2 | `aj06.goals.reminder.time` |
| Figtree | 14 | 800 | normal | normal | `#A3301A` |  | sim | 1 | `aj06.footer.delete` |
| Figtree | 14 | 800 | 22.4px | normal | `#1A1714` |  | sim | 2 | `d17.synopsis.text.more` |
| Figtree | 14 | 800 | normal | normal | `#F7F0E3` |  | sim | 2 | `cr18.timer.today.minutes` |
| Figtree | 14 | 800 | 16.8px | normal | `#1A1714` |  | sim | 4 | `bu28.trending.book1.title` |
| Figtree | 14 | 800 | 18.9px | normal | `#FF552E` |  | sim | 3 | `bu28c.tips.tip1.arrow` |
| Figtree | 14 | 800 | normal | normal | `#B83A1C` |  | sim | 1 | `aj58.delete.label` |
| Figtree | 14 | 800 | normal | 1px | `#1A1714` |  | sim | 1 | `aj59.confirm.label.word` |
| Figtree | 14.5 | 500 | 20.3px | normal | `#5B544B` |  | **novo** | 4 | `e07.sheet.lead` |
| Figtree | 14.5 | 500 | 21.025px | normal | `#5B544B` |  | **novo** | 8 | `e10.sheet.lead` |
| Figtree | 14.5 | 600 | 19.575px | normal | `#2C2452` |  | **novo** | 1 | `p05.hero.bio` |
| Figtree | 14.5 | 600 | 21.025px | normal | `#5B544B` |  | **novo** | 3 | `bu28c.body` |
| Figtree | 14.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 15 | `p05.actions.edit` |
| Figtree | 14.5 | 800 | 21.025px | normal | `#1A1714` |  | **novo** | 3 | `e10.sheet.lead.email` |
| Figtree | 14.5 | 800 | 18.125px | normal | `#1A1714` |  | **novo** | 2 | `e11.sheet.form.devices.title` |
| Figtree | 14.5 | 800 | normal | normal | `#1A1714` | tnum | **novo** | 8 | `d17.synopsis.fact1.value` |
| Figtree | 14.5 | 800 | 18.85px | normal | `#1A1714` |  | **novo** | 9 | `d17.highlights.club.title` |
| Figtree | 14.5 | 800 | 17.4px | normal | `#1A1714` |  | **novo** | 4 | `p65.sheet.options.option1.title` |
| Figtree | 15 | 600 | normal | normal | `#5B544B` |  | sim | 2 | `d17.meta.year` |
| Figtree | 15 | 700 | normal | normal | `#1A1714` |  | sim | 17 | `aj06.reading.font.title` |
| Figtree | 15 | 700 | 18px | normal | `#1A1714` |  | sim | 16 | `aj56.visibility.list.shelf.title` |
| Figtree | 15 | 800 | normal | normal | `#1A1714` |  | sim | 16 | `p05.top.handle` |
| Figtree | 15 | 800 | normal | normal | `#F7F0E3` |  | sim | 1 | `e13b.coach.card.actions.try.label` |
| Figtree | 15.5 | 600 | 22.475px | normal | `#1A1714` |  | **novo** | 3 | `p64.fields.name.field.value` |
| Figtree | 15.5 | 600 | 22.475px | normal | `#8A8073` |  | **novo** | 1 | `p64.fields.handle.field.value.at` |
| Figtree | 15.5 | 800 | normal | normal | `#1A1714` |  | **novo** | 8 | `aj06.plan.title` |
| Figtree | 15.5 | 800 | normal | normal | `#F7F0E3` |  | **novo** | 3 | `e07.sheet.buttons.email.label` |
| Figtree | 15.5 | 800 | 19.375px | normal | `#F7F0E3` |  | **novo** | 2 | `cr18.book.title` |
| Figtree | 16 | 400 | normal | normal | `#1A1714` |  | **novo** | 5 | `e10.sheet.code.label` |
| Figtree | 16 | 700 | normal | normal | `#F7F0E3` |  | sim | 3 | `sc03.sheet.actions.primary.label` |
| Figtree | 16 | 700 | normal | normal | `#1A1714` |  | sim | 2 | `e15.username.field.text` |
| Figtree | 16 | 800 | normal | normal | `#F7F0E3` |  | sim | 17 | `e08.sheet.form.submit.label` |
| Figtree | 16 | 800 | normal | normal | `#8A8073` |  | sim | 1 | `e15.username.field.at` |
| Figtree | 16 | 800 | normal | normal | `#1A1714` |  | sim | 5 | `bu28c.actions.scan` |
| Figtree | 16 | 800 | normal | 1.5px | `#1A1714` |  | sim | 1 | `aj59.confirm.field` |
| Figtree | 18 | 800 | 18px | 2.5px | `#1A1714` |  | **novo** | 4 | `e08.sheet.form.password.field.dots` |
| Figtree | 18 | 800 | normal | normal | `#1A1714` |  | **novo** | 1 | `n30b.quiet.range.arrow` |
| Figtree | 32 | 700 | 32px | normal | `#1A1714` |  | **novo** | 2 | `e07.wordmark.label` |
| Google Sans | 15 | 500 | 20px | 0.1px | `#1F1F1F` |  | **novo** | 1 | `e07.sheet.buttons.google` |
| Instrument Serif | 5.5 | 400 | 5.06px | normal | `#1A1714` |  | **novo** | 1 | `p65.sheet.options.option4.thumb.cover.title` |
| Instrument Serif | 6.1 | 400 | 5.612px | normal | `#1A1714` |  | **novo** | 2 | `p65.sheet.options.option2.thumb.cover.title` |
| Instrument Serif | 6.9 | 400 | 6.348px | normal | `#1A1714` |  | **novo** | 1 | `p65.sheet.options.option1.thumb.cover.title` |
| Instrument Serif | 8.1 | 400 | 7.452px | normal | `#1A1714` |  | **novo** | 1 | `p65.sheet.head.current.cover.title` |
| Instrument Serif | 11.8 | 400 | 10.856px | normal | `#1A1714` |  | **novo** | 1 | `p64.favorites.grid.slot4.book.cover.title` |
| Instrument Serif | 12.5 | 400 | 11.875px | normal | `#1A1714` |  | **novo** | 1 | `sc42.sheet.book.cover.title` |
| Instrument Serif | 13.4 | 400 | 12.328px | normal | `#FFFAF1` |  | **novo** | 2 | `p64.favorites.grid.slot1.book.cover.title` |
| Instrument Serif | 13.4 | 400 | 12.328px | normal | `#1A1714` |  | **novo** | 1 | `p64.favorites.grid.slot3.book.cover.title` |
| Instrument Serif | 14.5 | 400 | 13.775px | normal | `#1A1714` |  | **novo** | 1 | `sc03.sheet.book.cover.title` |
| Instrument Serif | 15 | 400 | 13.8px | normal | `#1A1714` |  | **novo** | 1 | `p05.favorites.shelf.books.book4.title` |
| Instrument Serif | 15.5 | 400 | 14.725px | normal | `#1A1714` |  | **novo** | 1 | `p05.reading.grid.book3.cover.title` |
| Instrument Serif | 17 | 400 | 15.3px | normal | `#FFFAF1` |  | **novo** | 2 | `p05.favorites.shelf.books.book1.title` |
| Instrument Serif | 18 | 400 | 16.56px | normal | `#FED170` |  | **novo** | 1 | `p05.reading.grid.book1.cover.title` |
| Instrument Serif | 18 | 400 | 16.56px | normal | `#1A1714` |  | **novo** | 1 | `p05.reading.grid.book2.cover.title` |
| Instrument Serif | 18 | 400 | 16.2px | normal | `#1A1714` |  | **novo** | 1 | `p05.favorites.shelf.books.book3.title` |
| Instrument Serif | 19 | 400 | 18.05px | normal | `#1A1714` |  | sim | 1 | `b02.shelf.book3.cover.title` |
| Instrument Serif itálico | 19 | 400 | 21.85px | normal | `#1A1714` |  | sim | 2 | `p05.activity.item2.quote` |
| Instrument Serif itálico | 19 | 400 | 19px | normal | `#5B544B` |  | sim | 2 | `e09.sheet.divider.label` |
| Instrument Serif | 19 | 400 | 17.48px | normal | `#FED170` |  | sim | 2 | `e13b.suggestions.book1.cover.title` |
| Instrument Serif | 19 | 400 | 17.48px | normal | `#1A1714` |  | sim | 2 | `e13b.suggestions.book2.cover.title` |
| Instrument Serif | 19 | 400 | 17.48px | normal | `#FFFAF1` |  | sim | 8 | `e13b.suggestions.book3.cover.title` |
| Instrument Serif | 20 | 400 | 18.4px | normal | `#1A1714` |  | **novo** | 2 | `b02.shelf.book11.cover.title` |
| Instrument Serif | 21 | 400 | 19.32px | normal | `#1A1714` |  | **novo** | 1 | `b02.shelf.book5.cover.title` |
| Instrument Serif | 21 | 400 | 19.32px | normal | `#B6ACE4` |  | **novo** | 1 | `b02.shelf.book6.cover.title` |
| Instrument Serif itálico | 21 | 400 | 23.52px | normal | `#1A1714` |  | **novo** | 4 | `sc03.camera.book.quote` |
| Instrument Serif itálico | 21 | 400 | 28.35px | normal | `#1A1714` |  | **novo** | 4 | `d17.highlights.quote.text` |
| Instrument Serif | 22 | 400 | 20.24px | normal | `#FED170` |  | sim | 1 | `b02.shelf.book1.cover.title` |
| Instrument Serif | 22 | 400 | 20.24px | normal | `#1A1714` |  | sim | 1 | `b02.shelf.book2.cover.title` |
| Instrument Serif itálico | 22 | 400 | normal | -0.4px | `#1A1714` |  | sim | 1 | `p64.favoritesHeader.title.serif` |
| Instrument Serif | 23 | 400 | 20.7px | normal | `#FFFAF1` |  | sim | 2 | `b02.shelf.book8.cover.title` |
| Instrument Serif itálico | 23 | 400 | 23px | -0.3px | `#1A1714` |  | sim | 1 | `e08.card.name` |
| Instrument Serif itálico | 23 | 400 | 24.15px | -0.4px | `#1A1714` |  | sim | 1 | `sc39.sheet.lead.title.serif` |
| Instrument Serif | 24 | 400 | 22.08px | normal | `#1A1714` |  | sim | 1 | `b02.shelf.book4.cover.title` |
| Instrument Serif | 24 | 400 | 21.6px | normal | `#1A1714` |  | sim | 1 | `b02.shelf.book10.cover.title` |
| Instrument Serif itálico | 24 | 400 | 25.2px | -0.5px | `#1A1714` |  | sim | 1 | `sc40.sheet.lead.title.serif` |
| Instrument Serif itálico | 25 | 400 | normal | -0.2px | `#1A1714` |  | **novo** | 1 | `p05.favorites.header.title.serif` |
| Instrument Serif itálico | 25 | 400 | 25px | normal | `#1A1714` |  | **novo** | 1 | `e13b.coach.tag` |
| Instrument Serif itálico | 25 | 400 | 26.25px | -0.5px | `#1A1714` |  | **novo** | 1 | `p65.sheet.head.title.serif` |
| Instrument Serif itálico | 26 | 400 | 27.3px | -0.2px | `#1A1714` |  | sim | 1 | `e13b.coach.card.title.serif` |
| Instrument Serif itálico | 27 | 400 | normal | -0.2px | `#1A1714` |  | **novo** | 2 | `p05.year.title.serif` |
| Instrument Serif itálico | 27 | 400 | 28.35px | normal | `#1A1714` |  | **novo** | 1 | `p05.year.stats.genre.value` |
| Instrument Serif itálico | 29 | 400 | 29.58px | -0.6px | `#1A1714` |  | **novo** | 1 | `sc41.sheet.title.serif` |
| Instrument Serif itálico | 30 | 400 | 30.6px | -0.6px | `#1A1714` |  | **novo** | 1 | `b36.heading.serif` |
| Instrument Serif itálico | 31 | 400 | 32.55px | -0.6px | `#FED170` |  | **novo** | 2 | `sc69.heading.title.serif` |
| Instrument Serif itálico | 32 | 400 | 32px | -0.4px | `#1A1714` |  | **novo** | 1 | `e16.card.name` |
| Instrument Serif itálico | 34 | 400 | 34px | -0.7px | `#1A1714` |  | **novo** | 1 | `n30c.empty.title.dot` |
| Instrument Serif itálico | 36 | 400 | 36px | normal | `#1A1714` |  | sim | 2 | `aj06.account.avatar` |
| Instrument Serif itálico | 36 | 400 | 36px | -0.8px | `#1A1714` |  | sim | 1 | `bu28c.title.serif` |
| Instrument Serif itálico | 39 | 400 | 35.88px | -0.5px | `#1A1714` |  | **novo** | 2 | `p64.preview.name.serif` |
| Instrument Serif itálico | 40 | 400 | 39.2px | -0.4px | `#1A1714` |  | **novo** | 2 | `e07.sheet.title.serif` |
| Instrument Serif itálico | 42 | 400 | 41.16px | -0.4px | `#1A1714` |  | sim | 7 | `e08.sheet.title.serif` |
| Instrument Serif itálico | 42 | 400 | 42px | normal | `#1A1714` |  | sim | 1 | `e16.card.avatar` |
| Instrument Serif itálico | 42 | 400 | 41.16px | -0.5px | `#1A1714` |  | sim | 3 | `aj56.headline.serif` |
| Instrument Serif itálico | 44 | 400 | 43.12px | -0.5px | `#1A1714` |  | **novo** | 1 | `d17.title.serif` |
| Instrument Serif itálico | 44 | 400 | 39.6px | normal | `#1A1714` |  | **novo** | 1 | `d17b.progress.percent` |
| Instrument Serif itálico | 44 | 400 | 43.12px | -0.4px | `#1A1714` |  | **novo** | 4 | `bu28.title.serif` |
| Instrument Serif itálico | 44 | 400 | 44px | normal | `#1A1714` |  | **novo** | 2 | `p64.preview.avatar.circle` |
| Instrument Serif itálico | 46 | 400 | 46px | -0.6px | `#1A1714` |  | **novo** | 2 | `b02.header.title.serif` |
| Instrument Serif itálico | 46 | 400 | 45.08px | -0.5px | `#1A1714` |  | **novo** | 6 | `e12.heading.title.serif` |
| Instrument Serif itálico | 50 | 400 | 49px | -0.6px | `#1A1714` |  | sim | 1 | `b36.title.serif` |
| Instrument Serif itálico | 52 | 400 | 50.96px | -0.5px | `#1A1714` |  | **novo** | 1 | `d17b.title.serif` |
| Instrument Serif itálico | 56 | 400 | 56px | -0.8px | `#1A1714` |  | **novo** | 2 | `e07.wordmark.label.nest` |
| Instrument Serif itálico | 58 | 400 | 55.1px | -0.8px | `#1A1714` |  | **novo** | 1 | `p05.hero.name.serif` |
| Instrument Serif itálico | 60 | 400 | 60px | normal | `#1A1714` |  | **novo** | 1 | `p05.hero.avatar.circle` |
| Instrument Serif itálico | 66 | 400 | 66px | normal | `#1A1714` |  | **novo** | 1 | `e15.photo.avatar` |
| Literata | 14 | 600 | normal | normal | `#1A1714` |  | **novo** | 1 | `aj06.reading.size.small` |
| Literata | 15.5 | 400 | 24.8px | normal | `#2B2621` |  | **novo** | 2 | `d17.synopsis.text` |
| Literata | 15.5 | 400 | 24.025px | normal | `#2A2520` |  | **novo** | 5 | `bu28b.highlights.quote1.text` |
| Literata | 16 | 600 | normal | normal | `#1A1714` |  | **novo** | 1 | `aj06.reading.font.value` |
| Literata | 18 | 500 | 21.6px | normal | `#1A1714` |  | **novo** | 3 | `bu28b.books.result1.title` |
| Literata | 24 | 400 | 24px | normal | `#1A1714` |  | **novo** | 1 | `aj06.reading.theme.light.preview.sample` |
| Literata | 24 | 400 | 24px | normal | `#4A3620` |  | **novo** | 1 | `aj06.reading.theme.sepia.preview.sample` |
| Literata | 24 | 400 | 24px | normal | `#EDE4D3` |  | **novo** | 1 | `aj06.reading.theme.dark.preview.sample` |
| Literata | 24 | 600 | normal | normal | `#1A1714` |  | **novo** | 1 | `aj06.reading.size.large` |
| ui-sans-serif | 9.5 | 700 | 9.5px | 2px | `#000000` |  | **novo** | 16 | `sc69.keypad.key2.letters` |
| ui-sans-serif | 25 | 400 | 25px | normal | `#000000` |  | **novo** | 20 | `sc69.keypad.key1.digit` |

## Mapa id → widget (resumo)

Cada id de cada prancha tem um widget/pintor sugerido em `docs/design/medicao/projeto/mapa_widgets.json` (e por fase nos arquivos L). Contagem por tipo:

| widget / pintor | ids |
|---|---|
| AppText | 830 |
| NeoBox | 731 |
| layout | 638 |
| AppSvg | 539 |
| CircleIconButton / NeoBox circular | 280 |
| Pill / CountBadge | 196 |
| TextSpan dentro do AppText.rich do pai | 116 |
| HatchPainter | 28 |
| CustomPainter | 23 |
| NeoBox + AppText | 14 |
| DecoratedBox | 11 |
| ConicRingPainter | 3 |

Pintores sugeridos: `HatchPainter` (as hachuras das barras, trilhos e interruptores, as fitas), os anéis de progresso e as bordas onduladas das barras (`svg_graficos/`), o código de barras EAN-13 do ISBN digitado (69, 69b: desenhado dos dígitos), a linha e o véu do scanner (a cena da câmera é a câmera ao vivo; o desenho fica só como referência), os degradês do fim das telas (`DecoratedBox(LinearGradient)`), as máscaras (`ShaderMask`: gêneros, sugestões, abas da busca, cores), a marca amarela do termo buscado (28b, o pintor de grifo por linha) e os tracejados do registro `svgDashes`. Recortes de referência visual em `docs/design/medicao/projeto/png/elementos/` e, dos tracejados, em `docs/design/medicao/projeto/png/tracejados/`.

