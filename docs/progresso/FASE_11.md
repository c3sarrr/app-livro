# FASE 11 — Navegação inferior flutuante, FAB "Scanner" e fade inferior

Checklist da fase (`design_handoff/fases/F11_navegacao_inferior.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F11_verificacao.txt` · autorrevisão visual: `F11_comparacao.md`.

- [x] 11.1 Fade 390×150 transparente→`#F7F0E3` em 55%, sem toque, abaixo da barra na ordem de pintura
  - `BottomFade` = `DecoratedBox(LinearGradient(topCenter→bottomCenter, [#F7F0E300, #F7F0E3], stops [0, 0.55]))` em `ExcludeSemantics`;
    no shell: `Positioned(bottom 0, h 150) > IgnorePointer > BottomFade(Key 'bottomFade')`, 2º filho do `Stack` (antes da barra).
  - Rampa provada sobre fundo preto (`style_nav_test`): alpha 0 no topo, linear até 82,5 px (±2 por canal) e papel exato daí até o fim;
    hit test não passa pelo fade; pixel da barra continua `#FFFAF1` (o fade pinta antes dela).
- [x] 11.2 Barra 358×70 em bottom 30, `#FFFAF1`, borda 1,5, raio 28, sombra (0,4,0), padding 8, 5 colunas de 64,6 com gap 4
  - `FloatingNavBar` = `NeoBox(surface, border 1,5, raio 28, drop4, padding 8) > Row(spacing 4, stretch) > 5 × Expanded`; itens 64,6 × 51 em
    y 2299,5 (gap 4,000000); barra em (16; 2290); pixels @3x: fundo, 4 bordas, canto de raio 28 (3 pontos), sombra (0,4) só embaixo.
- [x] 11.3 Ativo: brand + borda 1,5 + raio 20, casa preenchida `#FFFAF1`, "Início" 700 tinta; inativos: 600 `#5B544B`
  - Pílula `#B6ACE4`, borda 1,5, raio 20, sem sombra (pixels: preenchimento, 4 bordas, canto de raio 20); ícone `ic_nav_home_active` (fill
    `#FFFAF1`, traço 1,8); "Início" `micro11Bold` (Figtree 11/700/1,2 `#1A1714`); inativos sem `DecoratedBox`, `navLabel` (11/600 `#5B544B`).
  - D-07: com outra aba ativa a pílula, o ícone `_extrapolado_*` preenchido e o rótulo 700 passam para ela; a Início volta ao repouso.
- [x] 11.4 FAB 60×60 `#FED170` borda 1,5 sombra (0,4) com ícone 28, topo 20,5 acima da barra, 100% tocável; rótulo "Scanner" 700 tinta embaixo (padding 2)
  - FAB irmão da barra, depois dela, em (165; 2269,5): `left (w−60)/2`, `bottom navBottom + 30,5` (`ScannerFab.bottom`); `NeoBox` círculo (raio 999),
    sombra (0,4), `ic_nav_scanner` 28 centrado (+16; +16). Pixels: cor, 4 bordas, sombra, por cima da borda superior da barra, canto do quadrado fora do círculo.
  - Toque em 7 pontos (acima da barra, topo, esquerda/direita, centro, parte baixa, sombra) e em y = 2275 do canvas: abre `/scanner` uma única vez.
  - Rótulo "Scanner": `Padding(bottom 2) > AppText` 41,3 × 15,2 em y +45,3, item com `Column(end)`.
- [x] 11.5 go_router: troca de aba, ativo correto, `/scanner` por push; tema brand aplicado
  - `shell.goBranch(i, initialLocation: i == currentIndex)`; `context.push('/scanner')` (fullscreenDialog no navigator raiz, aba ativa não muda, um pop volta).
  - Tocar Biblioteca/Clubes/Perfil/Início troca rota, ramo, placeholder e pílula; rolagem da Início preservada (600,0 → 600,0); aba ativa tocada de novo não muda nada.
  - `brand` (as 4 opções) muda a pílula junto com o hero.
- [x] 11.5 Semântica da navegação (container, selecionado, rótulo do scanner sem duplicar)
  - `Semantics(container, explicitChildNodes, 'Navegação principal')` com 5 nós-filhos (links) na ordem do documento = travessia; `selected` só no ativo (dentro do
    `Pressable`, sem nó extra); Scanner = 1 nó com o `aria-label` do arquivo; FAB e fade `ExcludeSemantics`; em toda a árvore só 1 nó fala de "Scanner".
- [x] Geometria 18/18 · Viewport OK · Golden do viewport ≤ 0,5% · Toques OK · Visual ≤ 0,5% · Não-regressão OK
  - Geometria 18/18 (maior desvio `nav.library.label.w` −0,016); tabela de 17 linhas + fade ≤ 0,05; textos: baselines Δ 0,000.
  - Viewport 390×844 (safe 47/34): nav y 744, FAB y 723,5, fade 694; após rolar até o fim, mesmo lugar; safe 48 → 730 / 709,5; larguras 360/430 coerentes.
  - Golden do viewport `0,0,390,844`: `blur_mismatch_%` 0,0 (raw 0,5499; max 221) → PASSOU; faixa `0,694,390,150`: 0,0 (raw 0,1502).
  - Visual canvas `--rect 0,2230,390,160`: `blur_mismatch_%` 0,0 (raw 0,1255; mean_abs 0,258; max 99) → PASSOU.
  - Não-regressão: `--layout` com as 10 seções PASSOU (F03–F10 com os mesmos números da F10); golden F11 × golden F10 aprovado: 0 pixels alterados acima de y 2240
    (alterações só em y 2269,3–2364 / x 16–374 = barra + FAB).
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  - `Formatted 123 files (0 changed)`, exit 0 · `No issues found!`, exit 0 · `+465: All tests passed!`, exit 0 (421 anteriores + 44 da F11);
    3 execuções completas, nenhuma "did not complete"; `design_handoff/` intacto (git sem mudanças; checksums OK).
- [x] Relatório com lado-a-lado (canvas e viewport) inspecionados
  - `build/visual_diff/F11/F11_nav_fade_secao_golden_redline.png`, `F11_nav_fade_lado_a_lado/heatmap/onion.png`, `viewport/F11_viewport_*.png`,
    4 recortes ampliados (`zoom_fab/home_item/rotulos/canto_esq.png`); análise em `F11_comparacao.md`; relatório em `RELATORIO_FASE_11.md`.
