## Relatório — FASE 4: Seção 2 — Título editorial "Continue / sua história."

### Entregue
- Seção: `lib/features/home/presentation/sections/headline_section.dart` (`HeadlineSection`, construção obrigatória da fase: `Semantics(container, header, headingLevel: 1, label, excludeSemantics)` > `Column(Key headline, stretch)` > 2 `AppText`).
- `lib/features/home/presentation/home_screen.dart`: o placeholder `headline` virou `HeadlineSection()` (1 import + 1 linha).
- Testes (10 novos): `test/home/geometry_headline_test.dart` (4), `text_headline_test.dart` (2), `style_headline_test.dart` (3), `semantics_headline_test.dart` (1).
- Subfase **2.8-correção** (F02, aprovada por você nesta fase): `test/home/geometry_shell_test.dart` — 4 asserções de altura acumulada com ε 10⁻⁹ / igualdade exata passaram a ±10⁻³ px (`_float32Noise`, motivo documentado); registro com checklist próprio em `docs/progresso/FASE_02.md`. Nenhum código de produção mudou por ela.
- Golden: `test/golden/goldens/inicio_canvas@3x.png` regenerado (agora com o título).
- Documentação: `docs/progresso/FASE_04.md`, `F04_verificacao.txt`, `F04_comparacao.md`, este relatório.
- Evidências: `build/visual_diff/F04/` (lado a lado, heatmap, onion, `F04_headline_zoom_linha2_9x.png`, `todas/`, `nao_regressao/`, `sonda_escala/`, `golden_aprovado_F03.png`). A sonda de escala foi um teste temporário, já removido.

### Checklist (100%)
- [x] 4.1 `Column` (Key `headline`) com `AppText('Continue', displayXL)` + `AppText('sua história.', displaySerifXL)` em `Semantics(container, header, label, excludeSemantics)` — evidência: árvore conferida em teste (tokens pela mesma instância; `headingLevel` 1)
- [x] 4.1 Alturas 41,16 e 49 (fator 0,98, even); início das duas linhas em x = 20,00 ± 0,05 — evidência: 41,16000175 + 49,0 empilhadas; início 20,000 / 20,000 (cru 19,300 / 19,700)
- [x] 4.2 Retângulo 20/134/350/90,16 (±0,5) — evidência: (20,000; 134,000; 350,000; 90,160), Δ 0,000
- [x] 4.2 Baselines 168,44 e 216,66; larguras 170,69 e 219,65 — evidência: 168,440 / 216,660; 170,715 / 219,650
- [x] 4.2 Semântica: um único nó de cabeçalho "Continue sua história." — evidência: 1 nó `isHeader` (h1) com o rótulo, 0 filhos, nenhum nó "Continue"/"sua história."
- [x] Visual ≤ 0,5% · Não-regressão OK — evidência: `blur_mismatch_%` 0,0; topo × golden da F03 idêntico; F03 verde; 2.8-correção aprovada
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes — evidência: 0 mudanças · No issues found! · +224: All tests passed!
- [x] Relatório com lado-a-lado anexado e inspecionado — evidência: lado a lado, heatmap e ampliação abertos e anexados

### Verificação
- Geometria: 1/1 id da seção dentro da tolerância (`headline`: maior desvio 0,000 px). Os 10 blocos da F02 e os 9 ids da F03 continuam verdes (maior desvio da F02: `forYou.y` = 0,000002).
- Estilo: 3/3 testes, 25 asserts exatos — os dois tokens propriedade a propriedade (família + fallbacks, tamanho, peso, itálico, height, letter-spacing, cor, "even") e os pixels @3x da faixa: só tinta `#1A1714` sobre papel `#F7F0E3`, pixel mais escuro exatamente `0xFF1A1714`.
- Visual:

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | headline (0, 126, 390, 106) | 0,0 | 1,1724 | 1,166 | 221 | PASSOU |
  | headline, modo `--layout` | 0,0 | 1,3126 | 1,306 | 221 | PASSOU |
  | header, modo `--layout` (não-regressão) | 0,0 | 0,4113 | 0,53 | 142 | PASSOU |
  | topo (0, 0, 390, 126) × golden aprovado da F03 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | informativo: sonda 10× reduzida a 3× × referência | 0,0 | 0,0263 | 0,326 | 59 | PASSOU |

  O `max` 221 vem dos pingos dos "i" e do acento de "ó", que a 3× saem até 0,50 px mais altos. Não é layout: é o hinting vertical da Instrument Serif (o TTF traz programa TrueType completo; Bricolage e Figtree não têm) a 150 ppem. Renderizado pelo próprio Flutter a 6× e a 10×, o mesmo título fica a ≤ 0,07 px da referência em todos os glifos (massa ≤ 0,5 %); em x o desvio é ≤ 0,07 px em qualquer escala. Não há API para desligar hinting no Flutter e trocar o TTF é proibido. Tabela por glifo e análise em `F04_comparacao.md`.
- Texto: 2/2 linhas ("Continue" / "sua história."), 2/2 strings exatas ("ó" pré-composto, "." no itálico, sem `\n`), baselines e extensões dentro de ±0,5.
- flutter analyze: 0 problemas · dart format: ok (72 arquivos, 0 mudanças) · flutter test: 224 passaram · `design_handoff/` intacto (131/131).

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. A semântica segue a convenção §5.1 do prompt mestre (título de 2 linhas: `label` sem quebra + `excludeSemantics`), com `headingLevel: 1` como a fase pede quando o SDK tem o parâmetro.
- Correção aprovada por você: subfase 2.8-correção (tolerância de ruído float32 de ±10⁻³ px em 4 asserções da F02).

### Riscos/pendências
- Nenhuma.
- Informativo — git: continua só o commit da F00; F01 a F04 estão sem commit.

✅ FASE 4 concluída — aguardando sua aprovação para iniciar a FASE 5.
