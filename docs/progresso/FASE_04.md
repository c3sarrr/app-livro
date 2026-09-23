# FASE 4 — Seção 2: Título editorial "Continue / sua história."

Checklist da fase (`design_handoff/fases/F04_headline.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F04_verificacao.txt` · autorrevisão visual: `F04_comparacao.md`.

- [x] 4.1 `Column` (Key `headline`) com `AppText('Continue', displayXL)` + `AppText('sua história.', displaySerifXL)`, envolvida em `Semantics(container, header, label, excludeSemantics)`
  — `lib/features/home/presentation/sections/headline_section.dart` (construção obrigatória da fase, com `headingLevel: 1` porque o SDK 3.47.2 tem o parâmetro); o placeholder `headline` da F02 virou `HeadlineSection()`. `geometry_headline_test.dart` ("4.1 construção"): o `Semantics` pai da coluna tem `container`, `header`, `headingLevel` 1, `label` "Continue sua história.", `excludeSemantics` e não tem `explicitChildNodes`; a coluna tem `stretch`, `spacing` 0 e exatamente 2 filhos: `AppText` "Continue" com o token `displayXL` (mesma instância) e `AppText` "sua história." com `displaySerifXL`, ambos sem `maxLines`/reticências, `TextAlign.start`.
- [x] 4.1 Alturas de linha 41,16 e 49 (fator 0,98), distribuição even; início das duas linhas em x = 20,00 (±0,05, correção de meio letter-spacing ativa)
  — `geometry_headline_test.dart`: linhas de 41,16000175 e 49,0 px, empilhadas sem vão (topo da 2ª = base da 1ª), cada uma com largura tight 350 a partir de x = 20; `style_headline_test.dart`: height 0,98 e `TextLeadingDistribution.even` nos dois estilos (42 × 0,98 = 41,16; 50 × 0,98 = 49). `debugLines()` em contexto: início 20,000 e 20,000; o parágrafo cru do SkParagraph começaria em 19,300 e 19,700 (`[meio letter-spacing] início AppText (20.000, 20.000) | cru (sem correção) (19.300, 19.700)`).
- [x] 4.2 Retângulo 20/134/350/90,16 (±0,5)
  — `expectGeometry(['headline'])`: obtido (20,000; 134,000; 350,000; 90,160), Δ 0,000 em x, y, w e h (`idsOfSection('headline')` = `['headline']`; `headline.serif` é inline).
- [x] 4.2 Baselines 168,44 e 216,66 (±0,5); larguras 170,69 e 219,65 (±1,0)
  — `expectTextLines(tester, 'headline')` (as duas linhas juntas, como um parágrafo): "Continue" baseline 168,440, 20,000 → 190,715; "sua história." baseline 216,660, 20,000 → 239,650. Larguras 170,715 (Δ +0,025) e 219,650 (Δ 0,000). `text_headline_test.dart` também confere as strings exatas ("ó" pré-composto U+00F3, sem U+0301; "." dentro do itálico; nenhum `\n`) e 1 linha por `AppText`, sem reticências.
- [x] 4.2 Semântica: um único nó de cabeçalho "Continue sua história."
  — `semantics_headline_test.dart` (`ensureSemantics`): o nó da Key `headline` tem label "Continue sua história.", `isHeader`, `headingLevel` 1 e 0 filhos; os dois `AppText` caem nesse mesmo nó; na árvore inteira há exatamente 1 nó cabeçalho com esse rótulo, 0 nós "Continue", 0 nós "sua história." e 1 único nó cujo rótulo contém "Continue" ou "história".
- [x] Visual ≤ 0,5% · Não-regressão OK
  — `--rect 0,126,390,106`: `blur_mismatch_%` 0,0 (raw 1,1724; max 221) → PASSOU; modo `--layout`: `header` 0,0 e `headline` 0,0 → PASSOU. Diferenças só de rasterização (hinting vertical da Instrument Serif a 150 ppem: a sonda a 10× reduzida a 3× dá raw 0,0263 e max 59) — análise em `F04_comparacao.md`. Não-regressão: topo (0, 0, 390, 126) × golden aprovado da F03 = 0,0/0,0/max 0; dos 43.235 pixels alterados, 43.205 estão no retângulo do `headline` e 30 no sobressalto do "s" itálico em x 19..20 (presentes também na referência); testes da F03 verdes. Os 3 testes da F02 que exigiam alturas acumuladas exatas (±10⁻⁹) passaram a receber o ruído float32 do texto (1,75·10⁻⁶ px) — resolvido com a subfase **2.8-correção** aprovada pelo usuário (registrada em `FASE_02.md`).
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  — `Formatted 72 files (0 changed)` exit 0 · `No issues found!` exit 0 · `+224: All tests passed!` exit 0 (214 anteriores + 10 da F04) · `design_handoff/` 131/131 OK.
- [x] Relatório com lado-a-lado anexado e inspecionado
  — `build/visual_diff/F04/F04_headline_lado_a_lado.png`, heatmap, onion e `F04_headline_zoom_linha2_9x.png` inspecionados e anexados na conversa; relatório em `RELATORIO_FASE_04.md`.
