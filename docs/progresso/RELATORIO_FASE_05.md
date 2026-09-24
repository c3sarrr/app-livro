## Relatório — FASE 5: Seção 3 — Cartão "Continuar lendo" (hero)

### Entregue
- Seção: `lib/features/home/presentation/sections/continue_reading_hero.dart` (`ContinueReadingHero`, construção obrigatória da fase: `Semantics(seção)` > `NeoBox(hero, brand, borda 1,5, raio 28, sombra 4/4, recorte)` > `Stack` [`Padding(20)` > `Column(gap 20)` [`IntrinsicHeight` > `Row(hero.topRow)` [capa no `Align(topLeft)`, metadados], ações], brilho 30, brilho 14]; callbacks `onContinueTap`/`onHighlightsTap` para a F12).
- Capa: `lib/features/home/presentation/covers/dom_casmurro_cover.dart` (`DomCasmurroCover`: `NeoBox` 104×156 violeta, borda 1,5, raio 4/10/10/4, sombra 3/3, recorte + lombada, sol, anel, bloco de texto; quebra forçada do autor documentada).
- `lib/features/home/presentation/home_screen.dart`: o placeholder `hero` virou `ContinueReadingHero()` (1 import + 1 linha).
- Testes (26 novos): `test/home/geometry_hero_test.dart` (9), `text_hero_test.dart` (4), `style_hero_test.dart` (11), `semantics_hero_test.dart` (2).
- Golden: `test/golden/goldens/inicio_canvas@3x.png` regenerado (agora com o hero).
- Documentação: `docs/progresso/FASE_05.md`, `F05_verificacao.txt`, `F05_comparacao.md`, este relatório.
- Evidências: `build/visual_diff/F05/` (lado a lado, heatmap, onion, `F05_hero_zoom_bordas_6x.png`, `todas/`, `nao_regressao/`, `sonda_escala/`, `golden_aprovado_F04.png`). A sonda de escala foi um teste temporário, já removido.
- Histórico: a primeira sessão da F05 foi interrompida depois de escrever a capa e o cartão (sem ligar na tela e sem testes). Nesta sessão revisei esse código contra a tabela, número por número; ele ficou como estava, e daqui saíram a ligação na tela, os testes, a verificação e a documentação.

### Checklist (100%)
- [x] 5.1 Cartão 350×275, fundo brand, borda 1,5, raio 28, sombra (4,4,0), recorte interno 26,5, padding 20, gap 20 — evidência: decoração exata em teste; `ClipRRect` raio 26,5 em 347×272; 275 = 1,5 + 20 + 158 + 20 + 54 + 20 + 1,5
- [x] 5.1 Brilho 30 em top18/right18 e brilho 14 em top54/right50, pintados por cima — evidência: `Positioned` depois do conteúdo na `Stack`; (320,50; 267,66) e (304,50; 303,66), Δ 0,000
- [x] 5.2 Capa 104×156 no slot com margem 2/0/0/2, dentro de `Align(topLeft)`; rotação −3° com Key no slot e `#rot` no conteúdo — evidência: árvore e matriz de rotação conferidas; em 360 px a linha mede 158,8 e a capa continua 104×156 no topo
- [x] 5.2 Lombada 7 px .22 · sol 70 em −20/−20 recortado · anel 21×21 content-box · ordem de pintura — evidência: `Positioned`/decorações exatas; pixels do sol recortado, do anel vazado e da lombada (`0xFF42228F`)
- [x] 5.2 "Dom⏎Casmurro" 22/0,92 `#FED170`; "MACHADO DE⏎ASSIS" 6,5/700 ls 0,91 `#F7F0E3` (quebra forçada documentada) — evidência: tokens pela mesma instância; "MACHADO DE ASSIS" mede 78,317 em 78,000; as 4 linhas sem giro a ≤ 0,02 px do arquivo
- [x] 5.3 Pílula 104,55×27,4 à esquerda; gap 10; título 24/1,05 ls −0,6; autor 14/500 `#2F2A40`; gap 3 — evidência: 104,554 × 27,4; 25,2 e 16,8; gaps 10 e 3
- [x] 5.4 "62%" × "~2h 10min" por baseline; gap 8; barra 181×10 com preenchimento 110,36×7 — evidência: baselines 402,640 / 402,640; barra 181×10; preenchimento 110,36 × 7 a (1,5; 1,5)
- [x] 5.5 CTA 243×54 centralizado; botão 54 com badge 24,61×22 em top −4/right −4 — evidência: ícone em 89,034 e rótulo em 119,034 (folgas iguais); badge 24,609 × 22 em (326,391; 445,160)
- [x] 5.5 Semânticas: seção, h2 "Dom Casmurro", CTA (link), destaques (14), barra (62%) — evidência: árvore semântica conferida nó a nó; toques e ações semânticas chamam os callbacks
- [x] Geometria 30/30 · Texto OK · Estilo OK · Tema OK · Visual ≤ 0,5% · Não-regressão OK — evidência: números abaixo
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes — evidência: 0 mudanças · No issues found! · +250: All tests passed!
- [x] Relatório com lado-a-lado e heatmap inspecionados — evidência: lado a lado, heatmap, ampliação 6× e sonda abertos e anexados na conversa

### Verificação
- Geometria: 30/30 ids da seção dentro da tolerância (maior desvio: `hero.cta.label.w` = +0,043 px; em y/h o maior é `hero.cover.textBlock` = 0,020). Os 10 blocos da F02, os 9 ids da F03 e o `headline` da F04 continuam verdes.
- Estilo: 11 testes — decorações exatas (cor, borda, raio, sombra dura, recorte) do cartão, da capa e dos 4 filhos, da pílula, da barra, do CTA, do botão e do badge; os 9 estilos de texto pela mesma instância do token; 20 pontos de pixel @3x (8 deles através do giro da capa); tema; sem ripple e escala 0,97 (D-04).
- Tema: nas 4 opções de `brandOptions` o fundo do cartão assume a cor exata e 0 pixels mudam fora do cartão (lavanda 0 mudanças; rosa 498.726; verde 498.744; amarelo 498.744).
- Visual:

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | hero (16, 244, 358, 284) | 0,0 | 0,6331 | 0,702 | 128 | PASSOU |
  | hero, modo `--layout` | 0,0 | 0,6195 | 0,687 | 128 | PASSOU |
  | header / headline, modo `--layout` (não-regressão) | 0,0 / 0,0 | 0,4113 / 1,3126 | — | 142 / 221 | PASSOU (iguais à F04) |
  | topo (0, 0, 390, 244) × golden aprovado da F04 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | abaixo do hero (0, 528, 390, 1862) × golden aprovado da F04 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | informativo: sonda 10× reduzida a 3× × referência | 0,0 | 0,0791 | 0,497 | 77 | PASSOU |

  Diferenças residuais, todas de rasterização (análise em `F05_comparacao.md`). Nos textos Figtree/Bricolage e no brilho grande é suavização de borda, que some a 10× (ex.: título 286 → 0 pixels acima de 64). No título da capa, os topos da altura-x de "Casmurro" saem 1 px de dispositivo acima: é o hinting da Instrument Serif, a mesma assinatura da F04. Na barra aparece uma costura clara de 1 px de dispositivo onde a borda interna e o preenchimento coincidem (y 419,16 e 426,16). É conflação do anti-aliasing: a referência também tem essa costura na curva da ponta (canal G até 52), mas não nas retas, porque o Chromium alinhou a caixa ao pixel no supersample 10×. Forma, posição, cor, espessura, ordem de pintura e recorte são iguais ao arquivo. Os 877.030 pixels alterados em relação ao golden da F04 estão todos no retângulo do hero + sombra.
- Texto: 9/9 textos e 11/11 linhas (quebras idênticas; baselines Δ ≤ 0,001; inícios/fins Δ ≤ 0,05); capa: "Dom / Casmurro" e "MACHADO DE / ASSIS", e sem o giro as 4 linhas ficam a ≤ 0,02 px do arquivo; strings derivadas dos dados ("Cap. 92 de 148", "62%", "~2h 10min", "14").
- flutter analyze: 0 problemas · dart format: ok (78 arquivos, 0 mudanças) · flutter test: 250 passaram · `design_handoff/` intacto (131/131).
- Estabilidade da suíte: numa checagem repetida antes deste relatório, 1 de 9 execuções completas terminou com os 3 testes de `geometry_header_test.dart` (F03, não tocado nesta fase) como "did not complete". O processo desse arquivo não terminou e nenhuma asserção falhou. Não reproduziu nas 7 execuções seguintes, incluindo a mesma sequência `analyze` → `test`. A memória no pico ficou em 1,32 GB em 6 processos, com 4,24 GB livres. Registro completo no fim de `F05_verificacao.txt`.

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas: D-04 (toque sem ripple, escala 0,97 no CTA e no botão), D-11 (`brand` configurável no fundo do cartão), D-14 (badge "14" 800 → 700), D-15 (rótulos semânticos = `aria-label`).
- A quebra forçada "MACHADO DE⏎ASSIS" é a exceção prevista na própria F05 (fio de navalha de 0,33 px numa arte estática); o rótulo semântico continua sem a quebra. O `<h2>` usa `headingLevel: 2`, como o `<h1>` da F04 usou 1.

### Riscos/pendências
- Nenhuma.
- Informativo — git: as mudanças da F05 estão sem commit (último commit: `511a169`, fases 1–4). `test/home/failures/` (4 PNGs de falha de golden com data de 20:23, anteriores a esta sessão e ao commit `511a169`) continua não versionado: não é desta fase e pode ser apagado.
- Informativo — a costura da barra é só do rasterizador. Eliminá-la no golden exigiria mudar o primitivo `StadiumProgressBar` da F01 (fase aprovada); não mexo sem o seu pedido.

✅ FASE 5 concluída — aguardando sua aprovação para iniciar a FASE 6.
