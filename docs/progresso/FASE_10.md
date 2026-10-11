# FASE 10 — Seção 8: "Recém-chegados" (lista com mini-capas e flex-shrink do CSS)

Checklist da fase (`design_handoff/fases/F10_recem_chegados.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F10_verificacao.txt` · autorrevisão visual: `F10_comparacao.md`.

- [x] 10.1 Cabeçalho 44 com "Recém-chegados" 24 ls −0,6 e link "Biblioteca" + seta
  - Geometria: título 195,506 × 28,8 em y + 7,6 (arquivo 195,47 — Δ +0,036), link 86,19 × 44, seta 18 em (332; 13); baselines 29,92 / 26,9
    (Δ 0,000); `Bricolage24` 24/800/1,2 ls −0,6, "Biblioteca" Figtree 14/700, SVG `ic_arrow_right` 18 com traço 2, gap 4.
- [x] 10.2 Lista `#FFFAF1` raio 24 padding 4/8/4/14, sem borda/sombra; alturas de linha 91/91/90; divisores 1 px `#E9E1D2`
  - Lista 350 × 280 em (0; 54) = 4 + 91 + 91 + 90 + 4; linhas 328 × 91 / 91 / 90 em x 14 (34→362 no canvas); `border-bottom` 1
    `#E9E1D2` só nas linhas 0 e 1 (a última sem `decoration`); pixels do divisor exatos (x 14→342, 1 px) e a lista sem borda/sombra.
- [x] 10.3 Frankenstein (tinta, lua 22, barra 27,6×3), O Alienista (lavanda, lombada 4, anel 20, ponto 8), Senhora (âmbar, lombada 4, arco 23,6×26 sem base)
  - Capas 44 × 66, borda 1,2, raio 3/7/7/3, recorte suavizado na padding box (1,8/5,8/5,8/1,8); filhos nas posições do arquivo;
    arco em "U" (`ArchBorderPainter`, raios 13 → 11,8 como o CSS) sem a borda de baixo — pixels: pernas e topo em tinta, miolo e base em âmbar.
- [x] 10.4 `resolveTextAndTag` + 3 testes da tabela verdes
  - `test/home/css_flex_test.dart` (11 testes): 126,54/71,46 · 129,83/68,17 · 148,56/49,44 (±0,05); base interna × externa; piso do
    min-content; piso 0 do texto; medidas intrínsecas com as fontes do arquivo (estouro medido 12,18 × arquivo ≈ 12,13: fontes com
    desvio ≤ 0,05 por texto, §6.1).
- [x] 10.5 Linha 2 reproduz o arquivo: subtítulo em 2 linhas e selo "Quero"/"ler" 68,17×38,8 centralizado
  - Texto 129,83 / selo 68,17 × 38,8 (Δ ≤ 0,05); linhas "Machado de Assis ·"/"PDF" e "Quero"/"ler"; selo centralizado na altura da
    capa; golden e recortes ampliados conferidos (`zoom_selo_linha1.png`).
- [x] 10.5 Selos: "Quero ler" `#ECE7FA`/`#3B2D86`, "Novo" `#EFE7D7`/`#4A4238`
  - Pill sem borda, raio 999 normalizado, padding 5 10; Figtree 12/700; pixels dos fundos exatos.
- [x] 10.6 Botões 44×44 transparentes com ícone 20 e semântica
  - `CircleIconButton` 44 sem fundo/borda; ícone 20 em (+12; +12), 3 círculos r 1,8 (pixels exatos); `Mais opções para <título>`.
- [x] Geometria 37/37 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
  - Geometria 37/37 (maior desvio `recent.title.w` 0,036); tabela de 37 linhas ≤ 0,05.
  - Texto: 11 textos / 13 linhas, Δ ≤ 0,042.
  - Estilo: 10 testes (decorações, tipografia, recortes, ordem de pintura, 40 pixels @3x exatos).
  - Visual `--rect 16,1873,358,351`: `blur_mismatch_%` 0,0 (raw 0,891; mean_abs 0,973; max 189) → PASSOU.
  - Não-regressão: seções F03–F09 repetem os números da F09; acima/abaixo da seção 0,0 / max 0 contra o golden aprovado da F09; os
    897.810 pixels alterados estão todos dentro da seção.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  - `Formatted 114 files (0 changed)`, exit 0 · `No issues found!`, exit 0 · `+421: All tests passed!`, exit 0 (382 anteriores + 39
    da F10: geometria 9, texto 5, estilo 10, semântica 4, css_flex 11).
  - Estabilidade: a suíte completa rodou mais 2 vezes (`+420`, antes do último teste), nenhuma linha "did not complete";
    `design_handoff/` intacto.
- [x] Relatório com lado-a-lado e heatmap inspecionados
  - Autorrevisão do §8: `secoes/F10@3x` | golden | `redline/F10@3x` (`F10_recem_chegados_secao_golden_redline.png`), lado a lado, heatmap
    e 4 recortes ampliados; análise em `F10_comparacao.md`; relatório em `RELATORIO_FASE_10.md`.
