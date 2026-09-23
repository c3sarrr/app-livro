# FASE 3 — Seção 1: Cabeçalho (avatar, saudação, sino)

Checklist da fase (`design_handoff/fases/F03_header.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F03_verificacao.txt` · autorrevisão visual: `F03_comparacao.md`.

- [x] 3.1 Linha de 48 com `spaceBetween` e centralização vertical
  — `lib/features/home/presentation/sections/header_section.dart` (construção obrigatória da fase; substitui o placeholder `header`). `geometry_header_test.dart`: `SizedBox` 48 com `Row(spaceBetween, center)` de 2 filhos (identidade, `CircleIconButton`); identidade começa em y + 2 e tem o centro vertical da linha; sino colado à direita e centrado; `header` = (20, 62, 350, 48).
- [x] 3.1 Avatar 44×44 `#FED170`, borda 1,5, "M" Bricolage18 800 centralizado
  — `style_header_test.dart`: decoração cor `#FED170`, `Border.all(1,5, #1A1714)`, raio 22, sem sombra, 44 × 44; "M" = `AppTextStyles.avatarInitial` (família `Bricolage18` + fallbacks, 18 px, w800, height 1,2, tinta) com centro = centro do avatar (ε 10⁻⁹). "M" vem de `user.initial` do snapshot.
- [x] 3.1 Coluna de saudação com gap 1, largura 58,43 e textos esticados (IntrinsicWidth + stretch)
  — `geometry_header_test.dart`: `IntrinsicWidth` > `Column(min, stretch, spacing 1)`; coluna 58,445 (arquivo 58,43; tolerância de texto ±1,0), "Boa noite," e "Marina" com a largura da coluna, 1 px entre eles; identidade com `spacing: 12` (114,445 × arquivo 114,43).
- [x] 3.1 "Boa noite," Figtree 13/500 `#5B544B`; "Marina" Figtree 16/700 ls −0,1
  — `style_header_test.dart`: `body13Muted` (Figtree, 13, w500, height 1,2, ls 0, `#5B544B`) e `name16` (Figtree, 16, w700, height 1,2, ls −0,1, `#1A1714`), fallback `FigtreeExt`, "even". Saudação derivada do relógio (`HomeFormatters.greeting`, 20:00 → "Boa noite,"), nome de `user.firstName`.
- [x] 3.2 Botão 48×48 `#FFFAF1` borda 1,5; ícone `ic_bell.svg` 22 centralizado
  — `style_header_test.dart`: `CircleIconButton(size: 48)`, decoração `#FFFAF1`, `Border.all(1,5, #1A1714)`, raio 24; `AppSvg('assets/icons/ic_bell.svg', size: 22)`; `geometry_header_test.dart`: ícone em (13, 13) do botão = (335, 75, 22, 22).
- [x] 3.2 Ponto 12×12 (9 + 2×1,5) `#FF552E` com borda `#FFFAF1`, em top 9 / right 11 dentro da borda, pintado sobre o ícone
  — `style_header_test.dart`: decoração `#FF552E`, `Border.all(1,5, #FFFAF1)`, raio 6, 12 × 12; `Positioned(top: 9, right: 11)` → (23,5; 10,5) do botão = (345,5; 72,5); na `Stack` o ícone vem antes do ponto; nos pixels @3x o centro do ponto é `#FF552E` e, onde o arco do sino passa sob o anel, `#FFFAF1` (controle espelhado fora do anel: `#1A1714`).
- [x] 3.3 Semântica "Notificações, 2 novas"; callback de toque; sem ripple
  — `semantics_header_test.dart`: `find.bySemanticsLabel('Notificações, 2 novas')` → 1; nó de botão sem filhos (ícone e ponto dentro dele, sem nó próprio); "M", "Boa noite," e "Marina" legíveis; toque → callback 1×, ação semântica de toque → 2×, toque fora → nada. `style_header_test.dart`: nenhum `InkWell`/`InkResponse`/`Material`/`Ink` no cabeçalho; toque só escala 0,97 em 90 ms e volta a 1,0 (D-04). O rótulo vem de `notificationsAria(unreadNotifications)`.
- [x] Geometria 9/9 · Texto 3/3 · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
  — Geometria: `expectGeometry(idsOfSection('header'))` 9/9, maior desvio `header.identity.w` = 0,015. Texto: `expectTextLines` 3/3 — baselines 91,940 / 80,450 / 99,900 (arquivo 91,94 / 80,45 / 99,9), início/fim a ≤ 0,015. Estilo: 7 testes, sem tolerância. Visual: `--rect 0,54,390,64` `blur_mismatch_%` 0,0 (raw 0,358) → PASSOU. Não-regressão: inset × golden aprovado da F02 0,0/0,0/max 0; os 34.832 pixels alterados estão todos dentro do retângulo do header; a geometria da F02 (10 blocos, rolagem, rotas) continua verde.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  — `Formatted 67 files (0 changed)` exit 0 · `No issues found!` exit 0 · `+214: All tests passed!` exit 0 (200 anteriores + 14 da F03) · `design_handoff/` 131/131 OK.
- [x] Relatório com o lado-a-lado `F03` anexado e inspecionado
  — `build/visual_diff/F03/F03_header_lado_a_lado.png` (+ heatmap e ampliação 4×) inspecionados e anexados na conversa; análise em `F03_comparacao.md`; relatório em `RELATORIO_FASE_03.md`.
