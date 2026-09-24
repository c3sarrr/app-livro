## Relatório — FASE 6: Seção 4 — "Também lendo" (2 cards com capas que "saltam" e anéis de progresso)

### Entregue
- **Seção:** `lib/features/home/presentation/sections/also_reading_section.dart` (`AlsoReadingSection`), com a construção obrigatória da fase:
  - `Semantics(seção)` > `Column(gap 30)` com o cabeçalho (h3 + contador 22×22, gap 8) e a grade `Row(gap 12)` de 2 `Expanded`;
  - cada card: `Pressable(link)` > `NeoBox` 169 × 123,6 > linha 59 (capa + anel) + bloco de texto;
  - capa no `OverflowBox` (vaza 22 px) com `Transform.rotate`, Key no slot e `#rot` no conteúdo;
  - anel: `CustomPaint(RingProgressPainter)` + rótulo centralizado;
  - callback `onBookTap(Book)` para a F12.
- **Capas:**
  - `covers/mrs_dalloway_cover.dart`: 54×81 verde, borda 1,5, raio 3/7/7/3, sombra 2/2, recorte, com lombada .15, arco 32×20 (raio 20/20/0/0) e "Mrs.⏎Dalloway".
  - `covers/pride_prejudice_cover.dart`: rosa, com lombada .12, círculo vazado 20×20 e "Orgulho e⏎Preconceito".
- **Tela:** em `lib/features/home/presentation/home_screen.dart` o placeholder `alsoReading` virou `AlsoReadingSection()` (1 import + 1 linha).
- **Testes (23 novos):**
  - `test/home/geometry_also_reading_test.dart` (8);
  - `text_also_reading_test.dart` (4);
  - `style_also_reading_test.dart` (8);
  - `semantics_also_reading_test.dart` (3).
- **Golden:** `test/golden/goldens/inicio_canvas@3x.png` regenerado, agora com a seção.
- **Documentação:** `docs/progresso/FASE_06.md`, `F06_verificacao.txt`, `F06_comparacao.md` e este relatório.
- **Evidências** em `build/visual_diff/F06/`:
  - lado a lado, heatmap e onion;
  - `F06_tambem_lendo_zoom_6x.png` (referência | 3× | 10× → 3×);
  - `todas/`, `nao_regressao/` e `sonda_escala/`;
  - `golden_F05_aprovado.png`.
- **Sondas:** as três foram testes temporários, já removidos: escala, larguras 360/430 e toque.

### Checklist (100%)
- [x] 6.1 Título Bricolage18 ls −0,3 + contador 22×22 (mín.) tinta/`#F7F0E3`, gap 8
  - Título 126,535 × 21,6 a y +0,2.
  - Contador 22×22 a 8 do título, com o "2" centralizado.
  - Tokens `sectionTitleS` e `count12OnInk` pela mesma instância; fundo tinta, raio 999 → 11.
- [x] 6.2 Gap de seção 30; grade 2×169 com gap 12; card `#FFFAF1`, borda 1,5, raio 22, padding 0/14/14, sem sombra, altura 123,6
  - 123,6 = 1,5 + 59 + 12 + 35,6 + 14 + 1,5.
  - Decoração exata e `boxShadow` nulo; papel logo além das bordas (pixels).
  - Os únicos recortes da seção são os das capas.
- [x] 6.3 Mrs. Dalloway: `#ABCF82`, lombada .15, arco 32×20 raio 20/20/0/0, título 11/0,95 em 10/5/8, −4°, sombra 2/2, vazando 22 px
  - Matriz `rotationZ(−4°)` e canto girado exatos.
  - Filhos com Δ 0,000; arco normalizado a 16/16/0/0.
  - Nos pixels, o verde cobre a borda superior do card e aparece 12 px acima dela.
  - Sem o giro, as 2 linhas ficam a ≤ 0,005 px do arquivo.
- [x] 6.4 Orgulho e Preconceito: `#FFC1C6`, lombada .12, círculo 20 borda 1,5 em 17/13, título 9/0,95 em 9/2/8, +3°, sombra 2/2
  - Mesma construção, com +3°.
  - Círculo vazado nos pixels; lombada `0xFFE0AAAE`.
  - Sem o giro, as 2 linhas ficam a ≤ 0,005 px do arquivo.
- [x] 6.5 Anéis 46×46 (r18, traço 5, cap redondo, topo, horário) 34% e 81%; rótulos 11/700 centralizados
  - `CustomPaint` com 46×46 (não 0×0).
  - Anel a (107,5; 66,5) e (288,5; 66,5).
  - Pixels em 10 ângulos, com arco, trilho e as duas pontas.
  - "34%" em 139,489–161,511 e "81%" em 321,343–341,657.
- [x] 6.6 Título 15/700/1,2 e autor 13/500 `#5B544B` com `maxLines: 1` + "…"; "Orgulho e Precon…"
  - A linha truncada mede 130,518 = largura de "Orgulho e Precon…" (arquivo 130,52).
  - Mais uma letra estouraria 138 por 0,702 (arquivo: 0,70).
- [x] Geometria 29/29 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK — números abaixo.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes: 0 mudanças · No issues found! · +273: All tests passed!
- [x] Relatório com lado-a-lado e heatmap inspecionados: lado a lado, heatmap, ampliação 6× e sonda abertos e anexados na conversa.

### Verificação
- **Geometria:** 29/29 ids da seção dentro da tolerância.
  - Maior desvio: `alsoReading.title.w` = −0,005 px.
  - Todos os retângulos das capas, arco, círculo, anéis e textos têm Δ 0,000.
  - F02–F05 continuam verdes.
  - Sondagem informativa: em 360 e 430 os 29 ids também batem (maior desvio −0,005). A validação formal é da F13.
- **Estilo:** 8 testes.
  - Decorações exatas de cards, contador, capas, lombadas, arco e círculo.
  - Os 7 estilos de texto pela mesma instância do token; raio do arco normalizado 16.
  - 34 pontos de pixel @3x e 2 lombadas por composição src-over (13 deles através do giro).
  - Sem ripple, com escala 0,97 (D-04).
- **Semântica:** 3 testes.
  - Seção "Também lendo" com filhos próprios; h3 com `headingLevel` 3; contador "2" como texto.
  - 2 links cujo nome é o texto do card; o anel `aria-hidden` fica fora.
  - Toque e ação semântica entregam o livro certo.
- **Visual:**

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | alsoReading (16, 547, 358, 192) | 0,0 | 0,8818 | 0,971 | 189 | PASSOU |
  | alsoReading, modo `--layout` | 0,0 | 0,8922 | 0,982 | 189 | PASSOU |
  | header / headline / hero, modo `--layout` (não-regressão) | 0,0 / 0,0 / 0,0 | 0,4113 / 1,3126 / 0,6195 | — | 142 / 221 / 128 | PASSOU (iguais à F05) |
  | acima da seção (0, 0, 390, 555) × golden aprovado da F05 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | abaixo da seção (0, 731, 390, 1659) × golden aprovado da F05 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | informativo: sonda 10× reduzida a 3× × referência | 0,0 | 0,0433 | 0,421 | 123 | PASSOU |

  As diferenças que sobram são todas de rasterização; a análise completa está em `F06_comparacao.md`:
  - **Títulos das capas (max 189, no "o" de "Preconceito").** Instrument Serif a 9 e 11 px, girada, com o hinting da fonte (mesma assinatura da F04/F05). Os centroides dos 31 glifos ficam a ≤ 0,203 px lógico a 3× e a ≤ 0,137 a 10× → 3×; a posição das linhas é exata sem o giro.
  - **Figtree/Bricolage.** Suavização de borda de glifo, que some a 10×: o título da seção cai de 564 para 0 pixels acima de 64.
  - **Linha fraca na borda de baixo dos cards.** No supersample 10× o Chromium alinhou as bordas da caixa ao pixel (≤ 0,07 px; a referência começa a borda em ≥ 729,33, e o Flutter pinta os 729,26 exatos do CSS).

  Forma, posição, cor, espessura, ordem de pintura e recorte são iguais ao arquivo. Os 401.015 pixels alterados em relação ao golden da F05 estão todos no retângulo da seção.
- **Texto:** 10/10 textos e 12/12 linhas.
  - Quebras idênticas; baselines com Δ 0,000; inícios/fins com Δ ≤ 0,018.
  - Capas: "Mrs. / Dalloway" e "Orgulho e / Preconceito".
  - "Orgulho e Precon…" com reticências.
  - Strings derivadas dos dados: "2", "34%", "81%", títulos e autores.
- **Qualidade:** flutter analyze com 0 problemas · dart format ok (85 arquivos, 0 mudanças) · flutter test com 273 passando · `design_handoff/` intacto (131/131).
- **Estabilidade:** 3 execuções completas da suíte, todas `+273`, nenhuma "did not complete".

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas:
  - D-04: toque sem ripple, com escala 0,97 nos cards.
  - D-14: "2", "34%" e "81%" com 800 → 700.
  - D-15: rótulo da seção = `aria-label`. Os links não têm `aria-label` no arquivo, então o nome é o texto do card, como pede a F06.
- As quebras "Mrs.⏎Dalloway" e "Orgulho e⏎Preconceito" são os `<br>` do arquivo (exceção das artes de capa).
- O `<h3>` usa `headingLevel: 3`, como o h1/h2 das fases anteriores.

### Riscos/pendências
- Nenhuma.
- **Informativo (interação, fica para a F12 ou para quando você pedir).** No HTML, a parte da capa que vaza acima do card é filha do `<a>` e o clique ali abre o livro. No Flutter o teste de toque fica limitado ao retângulo do card: medi com uma sonda e um toque 10 px acima da borda, sobre a capa, não dispara (dentro do card dispara). O visual não muda. Resolver exige estender a área de toque além do card, o que é assunto de interação; não mexi.
- **Informativo — git.** As mudanças da F05 e da F06 estão sem commit (último commit: `511a169`, fases 1–4). `test/home/failures/` (PNGs antigos, de 20:23) continua não versionado e pode ser apagado.

✅ FASE 6 concluída — aguardando sua aprovação para iniciar a FASE 7.
