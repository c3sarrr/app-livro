## Relatório — FASE 11: Navegação inferior flutuante, FAB "Scanner" e fade inferior

### Entregue
- **Fade:** `lib/features/shell/presentation/bottom_fade.dart` — `DecoratedBox` com `LinearGradient(topCenter → bottomCenter, [#F7F0E3 alpha 0, #F7F0E3], stops [0, 0.55])`
  em `ExcludeSemantics`. O início tem o mesmo RGB do papel (como `rgba(247,240,227,0)`), então a interpolação do Skia dá o mesmo resultado da do navegador.
- **Barra:** `floating_nav_bar.dart` (`FloatingNavBar`, `ConsumerWidget`) — `Semantics(container, explicitChildNodes, "Navegação principal")` >
  `NeoBox(surface, borda 1,5, raio 28, sombra 0/4, padding 8)` > `Row(spacing 4, stretch)` de 5 `Expanded`:
  - abas (`_TabItem`): `Pressable(isLink)` + `Column(center, gap 3)` [ícone 22, rótulo 11]; ativa = `NeoBox(brand, borda 1,5, raio 20)` com `Semantics(selected: true)`
    dentro do `Pressable`; ícone/rótulo por estado (D-07: `_extrapolado_*` quando a aba não é a Início);
  - Scanner (`_ScannerItem`): `Pressable(isLink, semanticsLabel "Scanner: escanear livro ou página")` com `Column(end)` e só o rótulo "Scanner" (`Padding(bottom 2)`).
  - A cor da pílula vem de `homeThemeProvider.select(brand)` (o mesmo do hero).
- **FAB:** `scanner_fab.dart` (`ScannerFab`) — `ExcludeSemantics > Pressable > NeoBox` 60×60 (`#FED170`, borda 1,5, raio 999, sombra 0/4) com `ic_nav_scanner` 28 (`nav.scanner.icon`);
  `ScannerFab.bottom(navBottom)` = `navBottom + 70 − (1,5 + 8 − 30) − 60` (= `navBottom + 30,5`).
- **Shell:** `main_shell.dart` — `Stack`: conteúdo → `IgnorePointer(BottomFade)` → `FloatingNavBar` → `ScannerFab` (irmão da barra, depois dela; `left (w−60)/2`). `onSelect` =
  `shell.goBranch(i, initialLocation: i == currentIndex)`; scanner = `context.push(AppRoutes.scanner)` (D-08), o mesmo callback na barra e no FAB.
- **Testes (44 novos):** `geometry_nav_test.dart` (11), `text_nav_test.dart` (3), `style_nav_test.dart` (10), `touch_nav_test.dart` (13), `semantics_nav_test.dart` (6),
  `golden_viewport_test.dart` (1).
- **Testes de fases anteriores ajustados (2), por exigência da própria F11:** `geometry_shell_test.dart` (F02, "camadas na ordem do HTML": os 3 placeholders viraram as 4 camadas reais) e
  `style_hero_test.dart` (F05, tema `brand`: a pílula da barra agora também muda; o teste admite mudança só no cartão + no retângulo `nav.home`, 0 pixels fora). Nenhum outro teste de fase aprovada foi alterado.
- **Goldens:** `test/golden/goldens/inicio_canvas@3x.png` regenerado (agora com a barra e o FAB) e `inicio_viewport@3x.png` novo (390×844, safe 47/34, 1170×2532).
- **Documentação:** `docs/progresso/FASE_11.md`, `F11_verificacao.txt`, `F11_comparacao.md` e este relatório.
- **Evidências** em `build/visual_diff/F11/`: lado a lado, heatmap e onion do canvas e do viewport, `F11_nav_fade_secao_golden_redline.png`, 4 recortes ampliados, `todas/`,
  `viewport/` e `golden_F10_aprovado.png` (cópia do golden aprovado da F10, para a não-regressão).

### Checklist (100%)
- [x] 11.1 Fade 390×150 transparente→`#F7F0E3` em 55%, sem toque, abaixo da barra na ordem de pintura
  - Rampa provada sobre fundo preto (alpha 0 no topo, linear até 82,5 px, papel exato até o fim); `IgnorePointer`; pixel da barra continua `#FFFAF1`; 0 pixels diferentes da referência na região só-fade.
- [x] 11.2 Barra 358×70 em bottom 30, `#FFFAF1`, borda 1,5, raio 28, sombra (0,4,0), padding 8, 5 colunas de 64,6 com gap 4
  - Barra (16; 2290) 358 × 70; itens 64,6 × 51 com gap 4,000000; decoração e 17 pontos de pixel @3x exatos (fundo, bordas, cantos, sombra só embaixo, fade abaixo da barra).
- [x] 11.3 Ativo: brand + borda 1,5 + raio 20, casa preenchida `#FFFAF1`, "Início" 700 tinta; inativos: 600 `#5B544B`
  - Pílula `#B6ACE4`/1,5/raio 20 (pixels exatos), `ic_nav_home_active` (fill `#FFFAF1`, traço 1,8); "Início" Figtree 11/700; Biblioteca/Clubes/Perfil Figtree 11/600 `#5B544B`; D-07 verificado nas 3 abas.
- [x] 11.4 FAB 60×60 `#FED170` borda 1,5 sombra (0,4) com ícone 28, topo 20,5 acima da barra, 100% tocável; rótulo "Scanner" 700 tinta embaixo (padding 2)
  - FAB em (165; 2269,5), ícone em (+16; +16); pixels exatos (cor, bordas, sombra, por cima da borda da barra); toque em 7 pontos e em y 2275 do canvas abre `/scanner` uma vez; rótulo 41,3 × 15,2 em y +45,3.
- [x] 11.5 go_router: troca de aba, ativo correto, `/scanner` por push; tema brand aplicado
  - Troca de aba nos 4 itens (rota, ramo, placeholder, pílula); rolagem da Início preservada; `/scanner` em `fullscreenDialog` no navigator raiz, aba ativa inalterada; `brand` (4 opções) segue o hero.
- [x] 11.5 Semântica da navegação (container, selecionado, rótulo do scanner sem duplicar)
  - Nó `Navegação principal` com 5 links na ordem do documento = travessia; `selected` só no ativo e sem nó extra; Scanner em 1 nó; em toda a árvore só 1 nó fala de "Scanner"; ações semânticas = toques.
- [x] Geometria 18/18 · Viewport OK · Golden do viewport ≤ 0,5% · Toques OK · Visual ≤ 0,5% · Não-regressão OK — números abaixo.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes: 0 mudanças · No issues found! · +465: All tests passed!
- [x] Relatório com lado-a-lado (canvas e viewport) inspecionados — `F11_comparacao.md`.

### Verificação
- **Geometria:** 18/18 ids (17 da seção `nav` + `bottomFade`) dentro da tolerância; maior desvio `nav.library.label.w` = −0,016 px. A tabela da especificação (17 linhas + fade) bate com o
  Flutter a ≤ 0,05; todos os boxes e ícones com Δ 0,000. No aparelho 390×844 (safe 47/34): nav em y 744, FAB em y 723,5, fade em 694 — iguais depois de rolar até o fim; safe 48 → 730 / 709,5;
  larguras 360/430: barra 16…w−16, FAB centrado em w/2 (validação formal na F13).
- **Estilo:** 10 testes, sem tolerância nas cores, bordas e pixels (a rampa do fade tem ±2 por canal; ±1 no papel dentro da rampa):
  - decorações da barra, da pílula, dos inativos (sem caixa), do FAB e do fade; tipografia dos 5 rótulos; os 5 SVGs e o conteúdo de cada um (fill, stroke, stroke-width, viewBox);
  - tema (4 opções de `brand`), aba ativa ≠ Início (D-07) e 44 pontos de pixel @3x exatos (barra, bordas, cantos, sombra, pílula, itens inativos, FAB, ordem de pintura);
  - gradiente do fade sobre fundo preto (7 pontos da rampa + 5 do trecho opaco).
- **Visual** (`compare_images.py`):

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | F11_nav_fade, canvas (0, 2230, 390, 160) | 0,0 | 0,1255 | 0,258 | 99 | PASSOU |
  | bottomFade / nav (`--layout`) | 0,0 / 0,0 | 0,1288 / 0,2545 | 0,264 / 0,512 | 99 / 99 | PASSOU |
  | header / headline / hero / alsoReading / today / forYou / club / recent (`--layout`) | 0,0 | 0,4113 / 1,3126 / 0,6195 / 0,8922 / 1,3001 / 2,1986 / 2,2549 / 0,8938 | — | 142 / 221 / 128 / 189 / 228 / 229 / 229 / 189 | PASSOU (= F10) |
  | Viewport 390×844 × derivada (0, 0, 390, 844) | 0,0 | 0,5499 | 0,648 | 221 | PASSOU |
  | Viewport, faixa inferior (0, 694, 390, 150) | 0,0 | 0,1502 | 0,473 | 108 | PASSOU |
  | golden F11 × golden F10 aprovado, acima de y 2240 | — | 0 pixels alterados | — | 0 | PASSOU |

  Fade: 0 pixels diferentes da referência em todas as regiões só-fade. Na faixa do canvas, só 76 de 561.600 pixels passam de 64 (0,014 %), todos em arestas de glifos e arcos; recortes ampliados do FAB,
  do item ativo, dos rótulos e do canto da barra: forma, cor, posição e ordem de pintura idênticas. As 240.446 diferenças contra o golden da F10 estão todas em y 2269,3–2364 / x 16–374 (barra + FAB).
- **Texto:** 5 rótulos, 1 linha cada: strings exatas; baselines Δ 0,000 (2341,35 / 2345,75); inícios e fins Δ ≤ 0,015; larguras da tabela ≤ 0,026.
- **Semântica e toques:** `Navegação principal` com 5 links; `selected` só no ativo; Scanner em um nó com o `aria-label` do arquivo; FAB/ícones/fade fora da árvore. Toques: FAB em 7 pontos, item e rótulo do Scanner,
  4 abas, aba ativa repetida, fade que deixa o toque passar, vão e padding da barra que o seguram, feedback D-04 (0,97 e cancelamento por arrastar); ações semânticas fazem o mesmo.
- **Qualidade:** flutter analyze com 0 problemas · dart format ok (123 arquivos, 0 mudanças) · flutter test com 465 passando · `design_handoff/` intacto (git limpo; `handoff_checksums.txt` OK).
- **Estabilidade:** 3 execuções completas da suíte (+465 nas três), nenhuma "did not complete".

### Autorrevisão (§8)
Conferi `secoes/F11_nav_fade@3x`, o redline e o golden lado a lado, linha a linha da tabela, e o viewport contra a derivada. Achados e correções desta fase:
- **F05 (`style_hero_test`):** o `brand` agora também colore a pílula da barra (exigência da F11); o teste que dizia "só o cartão" foi ajustado como descrito em "Entregue".
- **F02 (`geometry_shell_test`):** o teste das camadas assertava os placeholders; atualizado para as camadas reais.
- **Item "Scanner" sob o FAB:** o centro do item fica sob o círculo (pinta por cima); só o rótulo é toque de item. Um toque nunca dispara duas vezes (testado em 7 pontos do FAB).
- A fase não pediu revisores independentes; esta foi uma revisão minha, não de terceiros.

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas: D-01 (barra/fade fixos), D-02 (`navBottom = max(30, viewPadding.bottom − 4)`), D-04 (`Pressable`, feedback 0,97), D-07 (abas ≠ Início ativas com a mesma regra
  e os SVGs `_extrapolado_*`), D-08 (Scanner por push, aba ativa inalterada), D-11 (`brand`), D-14 (Figtree 800 → 700) e D-15 (rótulo do Scanner = `aria-label` do arquivo).
- Detalhes da construção que vão além do trecho da fase, todos neutros:
  - `main_shell.dart` importa `AppRoutes` de `router.dart` (que importa o shell): import circular entre os dois arquivos, aceito pelo Dart e pelo analyzer, só para não duplicar o caminho `/scanner`;
  - tocar a aba já ativa usa `goBranch(initialLocation: true)` (padrão do go_router): na Início/placeholders de rota única não muda nada (testado, rolagem preservada);
  - a Key de cada item fica no `Pressable` (retângulo do `<a>`, 64,6 × 51), e a do rótulo do Scanner na caixa com o `padding-bottom` (41,3 × 15,2), como na tabela.

### Riscos/pendências
- Nenhum.
- Observação (mesma da capa da F06 e do CTA da F09, não alterada, para a F12 decidir): o `Pressable` do FAB é opaco no quadrado 60×60, então os quatro cantos fora do círculo também abrem o scanner; no navegador a
  área fora do raio não recebe o toque.
- Observação de processo: o `flutter test --update-goldens …` (passo 1 do §7) rodou normalmente desta vez (2 goldens gerados).

✅ FASE 11 concluída — aguardando sua aprovação para iniciar a FASE 12.
