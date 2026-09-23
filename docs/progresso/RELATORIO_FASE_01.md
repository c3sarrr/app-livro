## Relatório — FASE 1: Design System (tokens, texto exato, pintores e primitivos)

### Entregue
- Tokens (`lib/core/design_system/tokens/`): `app_colors.dart`, `app_strokes.dart`, `app_shadows.dart`, `app_radii.dart`, `app_spacing.dart`, `app_typography.dart` (`AppFonts` + os 46 `AppTextStyles`), `app_icons.dart`.
- Texto: `text/app_text.dart` (`AppText` + `RenderAppText`).
- Pintores (`painters/`): `hatch_painter.dart`, `chromium_dash.dart`, `ring_progress_painter.dart`, `goal_dial_painter.dart`, `top_border_crescent_painter.dart`.
- Primitivos (`widgets/`): `neo_box.dart`, `pill.dart`, `count_badge.dart`, `circle_icon_button.dart`, `pressable.dart`, `stadium_progress_bar.dart`, `app_svg.dart`.
- Galeria (só debug): `gallery/design_system_gallery.dart` (`DesignSystemGallery` + `DesignSystemGalleryContent`; a rota `/_ds` entra na F02).
- Testes (`test/design_system/`, 111 novos): `app_colors_test`, `tokens_test`, `app_typography_test`, `app_text_test`, `text_lines_test`, `app_icons_test`, `painters_test`, `primitives_test`, `design_system_rules_test`, `gallery_test`.
- Harness: `test/support/text_lines.dart` (`expectTextLines`), `test/support/capture.dart` (captura @3x e pixels), `precacheAppIcons` em `test/support/precache_svgs.dart`.
- Goldens (`test/golden/goldens/`): `ds_galeria@3x.png`, `ds_apptext_reticencias@3x.png`, `ds_apptext_intrinseca@3x.png`, `ds_anel_34@3x.png`, `ds_anel_81@3x.png`, `ds_dial@3x.png`, `ds_meia_lua@3x.png`, `ds_semana@3x.png`.
- Documentação: `docs/progresso/FASE_01.md` (checklist com evidências e desvios), `F01_verificacao.txt` (saídas literais), `F01_comparacao.md` (autorrevisão visual).
- Removidos os `.gitkeep` das pastas que deixaram de estar vazias (`design_system/{painters,text,tokens,widgets}`, `test/golden/goldens`).
- Git: no início desta fase fiz o commit da FASE 0 aprovada (`70ae231 feat(inicio): fase 0 — Preparação do projeto e do laboratório de fidelidade`, como pede a F00 0.1.4). A FASE 1 fica sem commit até a sua aprovação.

### Checklist (100%)
- [x] 1.1 `AppColors` (32 constantes + 2 listas) — evidência: `app_colors_test` 3/3 (32 ARGB, 8 alphas = `round(a × 255)`, 2 listas)
- [x] 1.2 `AppStrokes`, `AppShadows`, `AppRadii`, `AppSpacing` — evidência: `tokens_test` 4/4, valores literais
- [x] 1.3 `AppFonts` com asserts — evidência: opsz inexistente (16, 30) e Figtree `w800`/`w300` disparam assert; 11 px → `Bricolage12`
- [x] 1.3 Catálogo com os 46 tokens — evidência: 46/46 conferidos contra a tabela (família, tamanho, peso, itálico, height, letterSpacing, cor, "even", fallbacks)
- [x] 1.3 Prova tipográfica 42/42 — evidência: maior Δ de largura 0,043 (±0,10); altura Δ 0,000 (±0,01); saída colada em `FASE_01.md`
- [x] 1.4 Prova Text × AppText — evidência: **Text = 58,445 × 16,000 | AppText = 58,445 × 15,600**
- [x] 1.4 `AppText` + `RenderAppText` — evidência: API, regras de tamanho, `_dx`, semântica e `debugLines` da referência + 2 correções exigidas por este SDK (ver Decisões); 13 testes
- [x] 1.4 Testes (b)–(g) — evidência: (b) largura = intrínseca exata 58,44543; (c) "Orgulho e Precon…" termina em 130,52 (arquivo: 130,52), golden com `blur_mismatch_%` 0,0 contra o arquivo; (d) 12,78000; (e) 90,16 / 34,44 / 82,66; (f) início 0,00 (cru −0,70 / +0,50) e −0,500 px medido nos pixels; (g) bytes idênticos após consultas intrínsecas e dentro de `IntrinsicWidth`
- [x] 1.4 `test/support/text_lines.dart` — evidência: 15 conferências verdes (12 das variantes + 3 textos do arquivo, um de 3 linhas a ≤ 0,005 px); teste negativo acusa quebra errada
- [x] 1.5 `AppIcons` + `AppSvg` + pré-cache — evidência: os 18 caminhos = `assets/icons`, byte a byte iguais ao handoff; `AppSvg` 22 × 22 sem colorFilter e sem semântica; haste da seta a 18 px = 1,500 px; `precacheAppIcons` = `AppIcons.all`
- [x] 1.6 `HatchPainter` — evidência: 3 amostras da F01 + 6 de direção "/"; cena `ds_semana` com `blur_mismatch_%` 0,0
- [x] 1.6 `chromiumDashStarts` — evidência: 263,6 → 59 traços, vão 1,4931; 288 → 64, vão 1,5238; ambos terminam com traço
- [x] 1.6 `RingProgressPainter` + golden — evidência: Δ do arco × SVG 0,047 / 0,009 px; `ds_anel_34` / `ds_anel_81` com `blur_mismatch_%` 0,0
- [x] 1.6 `GoalDialPainter` — evidência: pino (30,137; 91,597); 31 marcações, a última com 0,160; ordem face → marcações → arco → pino; `ds_dial` com `blur_mismatch_%` 0,0
- [x] 1.6 `TopBorderCrescentPainter` + golden — evidência: borda 1,5 no topo e 0 nas laterais; `ds_meia_lua` + `ds_semana` (`blur_mismatch_%` 0,0)
- [x] 1.7 `NeoBox` — evidência: `ClipRRect` com raio 26,5 na padding box, dentro da caixa decorada; nos pixels, borda e sombra intactas
- [x] 1.7 Assinaturas exatas — evidência: idênticas à F01; 16 variantes do arquivo passam em `expectGeometry` + `expectTextLines`; `Pressable` 0,97 / 90 ms / 120 ms, flag e semântica
- [x] 1.7 Sem widgets Material em `core/design_system/` — evidência: `design_system_rules_test` 10/10 nos 21 arquivos
- [x] 1.8 `DesignSystemGallery` + golden — evidência: `ds_galeria@3x.png` (1170 × 12485, anexo); rola num aparelho 390 × 844 sem erros
- [x] `dart format` / `flutter analyze` / `flutter test` — evidência: 0 mudanças · No issues found! · +120: All tests passed!
- [x] Relatório no modelo — este documento

### Verificação
- Geometria: nenhuma seção da tela nesta fase. As 16 variantes dos primitivos, montadas nos retângulos do arquivo, passam em `expectGeometry`: 24/24 ids (maior desvio `club.pill.w` = 0,019 px).
- Estilo: 32 cores + 8 opções (ARGB exato), 46 tokens × 8 propriedades, decoração do `NeoBox`, chamadas, cores e traços dos 5 pintores — todos exatos.
- Visual (autorrevisão com o gate da §7; recortes da referência @3x na mesma caixa):

  | Região | raw_mismatch_% | blur_mismatch_% | Resultado |
  |---|---:|---:|---|
  | reticências (alsoReading.card2.title) | 6,7141 | 0,0 | PASSOU |
  | anel 34 % | 1,8426 | 0,0 | PASSOU |
  | anel 81 % | 1,7753 | 0,0 | PASSOU |
  | dial | 1,2917 | 0,0 | PASSOU |
  | gráfico da semana (hachuras, meias-luas, meta) | 1,3015 | 0,0 | PASSOU |

  Lado a lado e heatmap inspecionados: diferenças só de suavização de borda. PNGs em `build/visual_diff/F01/`; detalhes em `F01_comparacao.md`.
- Texto: prova tipográfica 42/42; `expectTextLines` 15/15; baseline de pintura provada nos pixels (a 10×: "HHH" em 12,4 para 12,35 esperado; o parágrafo cru pinta em 12,0).
- flutter analyze: 0 problemas · dart format: ok (44 arquivos, 0 mudanças) · flutter test: 120 passaram (9 da F00 + 111 da F01) · `design_handoff/` intacto (131/131).

### Decisões fora do arquivo usadas nesta fase
- D-04 (`Pressable`), D-07 (4 ícones extrapolados em `AppIcons`), D-10 (alturas das barras na cena de verificação), D-11 (`brandOptions`/`weekColorOptions`), D-14 (Figtree 800 → 700).
- Desvios do código de referência do `AppText`, com o comportamento obrigatório mantido (detalhes e linhas do Skia em `FASE_01.md`):
  1. altura = soma de `ascent + descent` por linha, porque o SkParagraph arredonda a altura de cada linha (`Run.h`) — o mesmo princípio da sua decisão A na F00;
  2. pintura na baseline exata: o SkParagraph pinta os glifos em `floor(baseline + 0,5)` (`TextLine.cpp`); texto de várias linhas é pintado linha a linha;
  3. `debugLines` com a baseline exata;
  4. construtor com parâmetros nomeados privados (Dart 3.13), exigidos pelo lint.

  Peço que confirme esses desvios junto com a aprovação.

### Riscos/pendências
- Nenhuma.
- Informativo para a F02: `matchesGoldenFile(Finder)` captura a 1×, então o golden do canvas precisa usar `captureAt` (3×), senão o `compare_images.py` recusa por tamanho diferente.

✅ FASE 1 concluída — aguardando sua aprovação para iniciar a FASE 2.
