# FASE 6 — Seção 4: "Também lendo" (2 cards com capas que "saltam" e anéis de progresso)

Checklist da fase (`design_handoff/fases/F06_tambem_lendo.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F06_verificacao.txt` · autorrevisão visual: `F06_comparacao.md`.

- [x] 6.1 Título Bricolage18 ls −0,3 + contador 22×22 (mín.) tinta/`#F7F0E3`, gap 8
  - **Construção** (`also_reading_section.dart`): `Semantics(seção "Também lendo")` > `Column(alsoReading, stretch, min, gap 30)`. O cabeçalho é `Row(alsoReading.header, gap 8, centro)` com:
    - `Semantics(h3, headingLevel 3)` > `AppText('Também lendo', sectionTitleS)`;
    - `CountBadge(alsoReading.count)`: rótulo `'${items.length}'` = "2", `count12OnInk`, mín. 22, altura 22, padding 7, fundo tinta, sem borda.
  - **Geometria** (`geometry_also_reading_test.dart`, "6.1"):
    - cabeçalho 350×22;
    - título 126,535 × 21,6, a y +0,200 (centrado na linha de 22);
    - contador 22×22 (6,95 + 2 × 7 = 20,95 < 22 → vale o mínimo), a 8 do título;
    - "2" centralizado, de 162,063 a 169,006 (arquivo 162,07–169,02).
  - **Estilo** (`style_also_reading_test.dart`, "6.1"):
    - título: `sectionTitleS` = Bricolage18 + fallbacks, 18/800, height 1,2, ls −0,3, tinta;
    - contador: fundo `0xFF1A1714`, raio 999 (normalizado 11: círculo), sem borda nem sombra;
    - "2": `count12OnInk` = Figtree 12, 800 → 700 (D-14), `0xFFF7F0E3`.
  - **Pixel:** tinta à esquerda do "2" em (157,5; 566,16).
- [x] 6.2 Gap de seção 30; grade 2×169 com gap 12; card `#FFFAF1`, borda 1,5, raio 22, padding 0/14/14, sem sombra, altura 123,6
  - **Construção:**
    - `home_screen.dart`: o placeholder `alsoReading` virou `AlsoReadingSection()`.
    - Grade: `Row(alsoReading.grid, start, gap 12, Clip.none)` com 2 × `Expanded(flex 1)` (minmax(0, 1fr)).
    - Card: `Pressable(isLink, sem semanticsLabel)` > `NeoBox(card, #FFFAF1, borda 1,5 tinta, raio 22, padding LTRB 14/0/14/14, sem sombra, sem recorte)` > `Column(stretch, min, gap 12)`, com a linha `SizedBox(top, 59)` e o bloco de texto.
  - **Geometria** ("6.2"):
    - grade 30 abaixo do cabeçalho; seção 175,6;
    - cards de 169 com 12 entre eles;
    - cada card mede 123,6 = 1,5 + 59 + 12 + 35,6 + 14 + 1,5;
    - linha 138×59 a (15,5; 1,5) do card (sem padding no topo);
    - bloco de texto 12 abaixo da linha e a 15,5 do fundo.
  - **Estilo** ("6.2"):
    - decoração exata: `0xFFFFFAF1`, `Border.all(1,5, #1A1714)`, raio circular 22, `boxShadow` nulo;
    - os 2 únicos recortes da seção são os `ClipRRect` das capas, dentro do conteúdo girado.
  - **Pixels:** fundo `#FFFAF1`; bordas esquerda e de baixo em tinta; papel `#F7F0E3` logo à direita e logo abaixo das bordas dos dois cards (sem sombra).
- [x] 6.3 Mrs. Dalloway: `#ABCF82`, lombada .15, arco 32×20 raio 20/20/0/0, título 11/0,95 em 10/5/8, −4°, sombra 2/2, vazando 22 px
  - **Construção** (geometria, "6.3/6.4"):
    - `SizedBox(54×59)` > `OverflowBox(altura 81, bottomCenter)` > `SizedBox(card1.cover 54×81)` > `Transform.rotate` > `KeyedSubtree(#rot)` > `MrsDallowayCover`;
    - matriz = `rotationZ(−4°)` elemento a elemento (±10⁻¹²), `alignment: center`, sem `origin`.
  - **Vazamento:** a capa termina no fundo da linha de 59 e começa 22 acima dela (20,5 acima da borda externa do card). O canto girado fica em centro + R(−4°)·(−27; −40,5), ±10⁻⁶.
  - **Estilo** ("6.3"):
    - capa: `0xFFABCF82`, borda 1,5 tinta, `AppRadii.coverS` 3/7/7/3, sombra (2, 2) blur 0 spread 0 tinta; recorte 1,5/5,5/5,5/1,5 `antiAlias`;
    - filhos na ordem lombada, arco, título: (0, 0, —, 0, w 5) · (12, 12, 7, —, h 20) · (10, —, 5, 8);
    - lombada `0x26000000` (round(0,15 × 255) = 38);
    - arco tinta 32×20 com raio 20/20/0/0 → `scaleRadii` 16/16/0/0 (fator 0,8 do CSS);
    - título `coverTitle11` (InstrumentSerif 11/400, height 0,95, tinta), texto `'Mrs.\nDalloway'` (o `<br>` do arquivo).
  - **Geometria dos filhos:** Δ 0,000.
  - **Arte sem giro no slot de layout** (`text_also_reading_test.dart`):

    | | Flutter | Arquivo |
    |---|---|---|
    | baselines | 646,225 / 656,675 | 646,22 / 656,67 |
    | início | 47,000 | 47,0 |
    | fins | 63,544 / 81,518 | 63,54 / 81,52 |

  - **Pixels** (levados pelo giro):
    - verde no meio; arco tinta; canto do arco verde (topo arredondado);
    - sombra girada à direita e embaixo em tinta, com o card logo além;
    - verde sobre a borda superior do card em (45; 607,91) e acima do card em (62,5; 595);
    - lombada `0xFF92B06F` (src-over exato 145,52 / 176,15 / 110,63).
- [x] 6.4 Orgulho e Preconceito: `#FFC1C6`, lombada .12, círculo 20 borda 1,5 em 17/13, título 9/0,95 em 9/2/8, +3°, sombra 2/2
  - **Construção:** a mesma do slot da 6.3, com `rotationZ(+3°)` e `PridePrejudiceCover`. Canto girado em (218,7; 585,3).
  - **Estilo** ("6.4"):
    - capa: `0xFFFFC1C6`, borda 1,5 tinta, 3/7/7/3, sombra (2, 2) blur 0 tinta; recorte 1,5/5,5/5,5/1,5;
    - filhos na ordem lombada, círculo, título: (0, 0, —, 0, w 5) · (17, 13) · (9, —, 2, 8);
    - lombada `0x1F000000` (round(0,12 × 255) = 31);
    - círculo `NeoBox` 20×20 border-box, sem preenchimento, borda 1,5 tinta, raio 10 (50 %);
    - título `coverTitle9` (InstrumentSerif 9/400, height 0,95, tinta), texto `'Orgulho e\nPreconceito'`.
  - **Arte sem giro:**

    | | Flutter | Arquivo |
    |---|---|---|
    | baselines | 648,395 / 656,945 | 648,39 / 656,94 |
    | início | 227,000 | 227,0 |
    | fins | 256,763 / 262,460 | 256,76 / 262,46 |

  - **Pixels:**
    - rosa no meio; centro do círculo rosa (vazado); traço do círculo em tinta;
    - sombra girada em tinta, com o card logo além;
    - rosa sobre a borda do card em (230; 607,91) e acima do card em (243,5; 595);
    - lombada `0xFFE0AAAE` (exato 224,00 / 169,54 / 173,93).
- [x] 6.5 Anéis 46×46 (r18, traço 5, cap redondo, topo, horário) 34% e 81%; rótulos 11/700 centralizados
  - **Construção** (geometria, "6.5"): `Padding(top 12)` > `SizedBox(ring 46×46)` > `Stack` com dois filhos:
    - `Positioned.fill` > `ExcludeSemantics` > `CustomPaint(ring.svg, RingProgressPainter(0,34 / 0,81), sem filho)`;
    - `Positioned.fill` > `Center(ring.label)` > `AppText(micro11Bold)`.
  - **Posição:**
    - anel encostado à direita e embaixo da linha, 13 abaixo do topo;
    - relativos à seção: (107,5; 66,5) e (288,5; 66,5);
    - o `CustomPaint` e o `Center` medem os mesmos 46×46 do anel;
    - rótulo centralizado (Δ < 10⁻⁹), com 13,2 de altura.
  - **Estilo:**
    - pintor com `radius` 18 e `stroke` 5, e progresso 0,34/0,81 vindo dos dados;
    - o teste da F01 cobre o resto do pintor: trilho `#EAE1CF`, arco tinta com ponta redonda, começo em −π/2, varredura 2π·p, Δ ≤ 0,05 px de arco contra o `stroke-dasharray` do arquivo;
    - rótulos `micro11Bold` (Figtree 11, 800 → 700) em tinta.
  - **Texto:**
    - "34%": 139,489–161,511, baseline 648,510 (arquivo 139,49–161,51 / 648,51);
    - "81%": 321,343–341,657 (arquivo 321,34–341,66).
  - **Pixels:**
    - anel 34 %: arco a 60° e na ponta inicial (−5°); trilho a 140°, 180°, 270° e −15°; miolo claro;
    - anel 81 %: arco a 90°, 180° e 270°; trilho a 320° (depois da ponta).
- [x] 6.6 Título 15/700/1,2 e autor 13/500 `#5B544B` com `maxLines: 1` + "…"; "Orgulho e Precon…"
  - **Construção** (geometria, "6.6"): `Column(textBlock, stretch, min, gap 2)` com dois `AppText`, os dois com `maxLines 1` + reticências:
    - título `title15`, 138×18;
    - autor `body13Muted`, 138×15,6, 2 abaixo do título;
    - bloco com 35,6.
  - **Estilo:** `title15` = Figtree 15/700, height 1,2, tinta; `body13Muted` = Figtree 13/500, `0xFF5B544B`.
  - **Reticências** (`text_also_reading_test.dart`, "6.6"):
    - `didExceedMaxLines`; ficam "Orgulho e Precon" + "…";
    - linha de 216,500 a 347,018 = 130,518 (arquivo 130,52), igual à largura de "Orgulho e Precon…" (130,518);
    - "Orgulho e Preconc…" mediria 138,702 e estoura 138 por 0,702 (arquivo: 0,70);
    - os outros 3 textos cabem inteiros.
  - **Semântica:** o nome do link leva o título inteiro, "Orgulho e Preconceito".
- [x] Geometria 29/29 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
  - **Geometria:** 29/29 ids; maior desvio `alsoReading.title.w` = −0,005 px. Sondagem informativa: os 29 ids também batem em 360 e 430 (±1,0; maior desvio −0,005).
  - **Texto:** 10/10 textos, 12/12 linhas, com strings e quebras exatas. Baselines com Δ 0,000 e inícios/fins com Δ ≤ 0,018. Nas capas giradas, só as quebras no canvas, mais as 4 linhas sem giro.
  - **Estilo:** 8 testes, incluindo 34 pontos de pixel @3x + 2 lombadas e sem ripple (D-04: escala 0,97 e volta a 1,0).
  - **Semântica:** 3 testes:
    - seção "Também lendo" com filhos próprios;
    - h3 com `headingLevel` 3;
    - contador "2" como texto;
    - 2 links sem aria-label, cujo nome é o texto do card: "Mrs.\nDalloway\n34%\nMrs. Dalloway\nVirginia Woolf" e "Orgulho e\nPreconceito\n81%\nOrgulho e Preconceito\nJane Austen";
    - o anel `aria-hidden` não aparece na semântica;
    - toque e ação semântica chamam o callback com o livro certo;
    - sem callback, os links não anunciam toque.
  - **Visual:**
    - `--rect 16,547,358,192` → `blur_mismatch_%` **0,0** (raw 0,8818, max 189) → PASSOU;
    - modo `--layout`: header, headline e hero idênticos à F05; alsoReading 0,0;
    - resíduo só de rasterização (hinting da Instrument Serif a 9/11 px girada, bordas de glifo, borda alinhada ao pixel na referência): a sonda 10× → 3× cai para raw 0,0433 e 47 px > 64 (`F06_comparacao.md`).
  - **Não-regressão:**
    - acima (0, 0, 390, 555) e abaixo (0, 731, 390, 1659) contra o golden APROVADO da F05: 0,0 / 0,0 / max 0;
    - os 401.015 pixels alterados estão todos no retângulo da seção;
    - testes F02–F05 verdes.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  - `Formatted 85 files (0 changed)`, exit 0.
  - `No issues found!`, exit 0.
  - `+273: All tests passed!`, exit 0: os 250 anteriores + 23 da F06 (geometria 8, texto 4, estilo 8, semântica 3).
  - `design_handoff/` 131/131 OK.
  - Suíte completa repetida mais 2 vezes: 3/3 execuções `+273`, nenhuma "did not complete".
- [x] Relatório com lado-a-lado e heatmap inspecionados
  - Inspecionados e anexados na conversa:
    - `build/visual_diff/F06/F06_tambem_lendo_lado_a_lado.png`;
    - `F06_tambem_lendo_heatmap.png`;
    - `F06_tambem_lendo_zoom_6x.png` (referência | 3× | 10× → 3×);
    - a sonda de escala (`sonda_escala/`).
  - Análise em `F06_comparacao.md`; relatório em `RELATORIO_FASE_06.md`.
