# FASE 9 — Seção 7: Ticket do clube do livro ("Leitoras de Capitu")

Checklist da fase (`design_handoff/fases/F09_clube_do_livro.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F09_verificacao.txt` · autorrevisão visual: `F09_comparacao.md`.

- [x] 9.1 Seção recorta com raio 28 (sem borda); ticket `#FFFAF1` borda 1,5 raio 28; corpo 255 + canhoto 92; altura 266,6
  - **Construção** (`book_club_ticket.dart`): `Semantics(seção "Seu clube do livro")` > `ClipRRect(club, raio 28, antiAlias)` >
    `Stack(Clip.none)` [`NeoBox(club.ticket)`, `Positioned(top −13, right 79,75)` > entalhe, `Positioned(bottom −13, right 79,75)` >
    entalhe]; ticket > `IntrinsicHeight` > `Row(stretch)` [`Expanded(Padding(club.body, LTRB 18/18/16/18) > Column(stretch, gap 14))`,
    `SizedBox(club.stub, 92)`]. Nada pinta entre a seção e o ticket (sem fundo/borda na seção).
  - **Geometria** (`geometry_club_test.dart`, "9.1"): seção (20; 1574,56) 350 × 266,6, 40 abaixo de "Para você"; corpo (1,5; 1,5)
    255 = 350 − 3 − 92; canhoto 92 × 263,6 (= altura do corpo); altura = 1,5 + 18 + 27,4 + 14 + 77,8 + 14 + 34,4 + 14 + 46 + 18 + 1,5
    = 266,600000.
  - **Estilo** (`style_club_test.dart`, "9.1"): ticket `#FFFAF1`, borda 1,5 tinta, raio 28, sem sombra; recorte dos filhos na padding
    box com raio 26,5 (`clipRRect` suavizado).
  - **Canvas:** só 3 recortes, todos suavizados — seção (0, 0, 350, 266,6, raio 28), ticket (1,5; 1,5 → 348,5; 265,1, raio 26,5) e
    trilho (raio 997,5 → 4,5 normalizado); nenhum `clipRect`, nenhum `saveLayer`.
  - **Pixels:** fundo, bordas de cima/esquerda/direita, meio do anel do canto a 45°, papel fora do canto, sem sombra à direita e embaixo.
- [x] 9.2 Perfuração: borda esquerda tracejada 1,5 do canhoto (59 traços, vão 1,4931)
  - **Construção:** `_Stub` = `Semantics(aria-label)` > `ColoredBox(#FFC1C6)` > `Stack` [`Positioned(left 0, top 0, bottom 0, width 1,5)`
    > `ExcludeSemantics` > `CustomPaint(ChromiumDashPainter(vertical))`, `Padding(9,5 / 18 / 8 / 18)` > `Center` > `Column(min, gap 12)`].
  - **Geometria:** perfuração em (256,5; 1,5) 1,5 × 263,6 → `chromiumDashStarts(263,6; 1,5)` = 59 traços, vão 1,49310 (58 daria
    1,57193, mais longe do ideal 1,5), último termina em 263,6.
  - **Canvas:** o fundo do canhoto (`drawRect #FFC1C6` 92 × 263,6) seguido de 59 `drawRect` 1,5 × 3 tinta nas posições do Chromium.
  - **Pixels:** traço 30 em tinta e o vão seguinte mostrando o fundo `#FFC1C6`.
- [x] 9.2 Entalhes 26×26 `#F7F0E3` borda 1,5 em right 79,75, top/bottom −13, recortados em meio círculo, por cima do ticket
  - **Geometria:** 26 × 26 em (244,25; −13) e (244,25; 253,6); centro x = 350 − 92,75 = 257,25 = centro da perfuração; centro y
    sobre a borda de cima (0) e a de baixo (266,6).
  - **Estilo:** `#F7F0E3`, borda 1,5 tinta, raio 13, sem sombra, `ExcludeSemantics` (`aria-hidden`).
  - **Canvas:** os entalhes são as 4 últimas formas pintadas (fundo + borda cada), dentro do recorte da seção e fora do recorte do
    ticket.
  - **Pixels (7):** miolo `#F7F0E3` por cima da perfuração, anel em tinta (em cima e embaixo), a metade de fora cortada pela seção
    (papel onde seria o anel), e a borda de cima do ticket interrompida pelo entalhe.
- [x] 9.3 Pílula "Clube do livro" nowrap 99,38×27,4; avatares A/J/L/+8 26×26 sobrepostos (−8) com cores e fontes corretas
  - **Construção:** `Row(club.topRow, spaceBetween, centro, gap 8)` [`Pill(club.pill, 5/10, #FFC1C6, borda 1,5)`, `Semantics("11
    participantes")` > `SizedBox(club.avatars, 80 × 26)` > `Stack` com os avatares em `left` 0 / 18 / 36 / 54, na ordem A, J, L, "+8"].
  - **Geometria:** pílula 99,399 × 27,400 (arquivo 99,38 × 27,4), texto em x + 11,5; grupo 80 × 26 encostado à direita, y + 0,7;
    cada inicial centrada no círculo. A largura do grupo sai da quantidade (26 + 18 × (n − 1)); sem avatares, 0 × 0, como o flex vazio
    do CSS (`style_club_test.dart`, "dados nos extremos").
  - **nowrap:** a pílula é filho não flexível da `Row` → o texto é diagramado com largura ilimitada (`maxWidth = ∞`): não há largura em
    que quebre (teste de texto "9.3 nowrap").
  - **Estilo:** pílula `#FFC1C6`, borda 1,5, raio 999; texto Figtree 12/700 tinta; avatares `#B6ACE4` / `#ABCF82` / `#FFC1C6` (dos dados)
    e "+8" `#FFFAF1`, borda 1,5, raio 13; Figtree 11/700 (A/J/L) e 10/700 ("+8") — CSS 800 → 700 (D-14).
  - **Canvas/pixels:** A → J → L → "+8" nessa ordem; a borda esquerda do J pinta sobre o A e o A continua logo antes dela.
- [x] 9.4 "Leitoras de" 22/1 ls −0,5 + "Capitu" itálico 36/0,95 ls −0,4 em coluna de 2 `AppText` (56,2) com um único nó de cabeçalho "Leitoras de Capitu"; subtítulo com "·"
  - **Construção:** `Semantics(h3, headingLevel 3, label "Leitoras de Capitu", excludeSemantics)` > `Column(club.title, stretch)`
    [`AppText(namePrefix)`, `AppText(nameHighlight)`]; bloco `Column(club.titleBlock, gap 6)` com o subtítulo.
  - **Geometria:** linhas 21,999999 + 34,200001 = 56,2; baselines 18,260 e 51,340 a partir do topo (arquivo 18,26 e 51,34); bloco
    77,8.
  - **Estilo:** Bricolage22 22/800/1 ls −0,5 tinta; InstrumentSerif itálico 36/400/0,95 ls −0,4 tinta; subtítulo Figtree 13/500
    `#5B544B`.
  - **Texto:** "Leitoras de" 1653,720 / "Capitu" 1686,800 (arquivo 1653,72 / 1686,8); subtítulo "Dom Casmurro · até o cap. 100" com
    U+00B7 entre espaços.
  - **Semântica:** um único nó de cabeçalho "Leitoras de Capitu" (nível 3), sem filhos, do tamanho do título.
- [x] 9.5 Trilho 12 hachurado; preenchimento 117,72 com borda direita 1,5; marcador 24 em 62% transbordando 6 px
  - **Construção:** `SizedBox(club.progressTrack, 12)` > `LayoutBuilder` > `Stack(Clip.none)` [`Positioned.fill` > `Semantics(progressbar)`
    > `NeoBox(club.progressBar, borda 1,5, raio 999, recorte)` > `Stack` [hachura, `Align` > `FractionallySizedBox(máx(0,54; 1,5 / 218))`
    > `DecoratedBox(club.progressFill)`], `Positioned(left w × 0,62 − 12, top −6)` > `Semantics("Você")` > marcador].
  - **Piso do border-box:** com `box-sizing: border-box`, a caixa de `width: 54%` nunca é mais estreita que a própria borda direita
    (1,5); o `máx` reproduz isso abaixo de 0,69 % e não muda nada com os dados do arquivo (golden byte a byte igual).
  - **Geometria:** trilho 221 × 12; preenchimento 0,54 × 218 = 117,72 × 9 na padding box; marcador 24 com o centro em 39,5 + 137,02 =
    176,52 (absoluto) e na metade da altura → 6 acima e 6 abaixo; à direita do fim do preenchimento.
  - **Extremos** (`style_club_test.dart`, "dados nos extremos"): progresso 0 → preenchimento 1,5 × 9, com o fio da borda direita em tinta
    exata e a hachura logo depois; progresso 1 → 218; 0,54 → 117,72.
  - **Estilo:** trilho sem fundo próprio, borda 1,5 tinta, raio 999 (recorte interno 4,5); `HatchPainter(#EFE6D4 / #FFFAF1)` cobrindo a
    padding box; preenchimento `#FFC1C6` com borda SÓ à direita (1,5 tinta), sem raio; marcador `#FED170`, borda 1,5, raio 12, "M"
    Bricolage12 11/800 tinta.
  - **Canvas:** borda do trilho → recorte → hachura (shader) → preenchimento → borda direita (caminho 1,5 na ponta de 117,72) → marcador
    por cima.
  - **Pixels (10):** borda do trilho, preenchimento, borda direita do preenchimento, 4 pontos da hachura (listra t = 134,5 / 141,5 e
    base t = 138 / 145), fundo do marcador, borda do marcador acima do trilho e o marcador cobrindo a borda do trilho.
- [x] 9.5 Legendas "Grupo em 54%" (600 `#5B544B`) × "Você em 62%" (700 tinta)
  - **Dados:** formatadores novos `groupProgressLabel` / `userProgressLabel` (sobre `percent`), com testes unitários e conferidos
    literalmente no HTML.
  - **Geometria:** 8 abaixo do trilho; "Grupo em 54%" 81,130 à esquerda, "Você em 62%" 74,870 encostado à direita (arquivo 81,12 /
    74,88).
  - **Estilo:** Figtree 12/600 `#5B544B` × Figtree 12/700 tinta (CSS 800 → 700).
  - **Texto:** baselines 1758,660 (arquivo 1758,66).
- [x] 9.6 CTA 221×46 com balão 18 + rótulo 14/700 + badge "3" (20×20 `#FF552E`, texto tinta)
  - **Construção:** `Pressable(link)` > `NeoBox(club.cta, 46, tinta, raio 999)` > `Row(centro, gap 8)` [`AppSvg(ic_message_circle, 18)`,
    `AppText("Abrir discussão")`, `Semantics("3 mensagens novas")` > `CountBadge(mín. 20, 20, padding 6, #FF552E)`].
  - **Geometria:** balão 18 + 8 + rótulo 98,636 + 8 + badge 20, margens iguais (centralizado) e tudo centrado na altura; o "3" centrado
    no mínimo de 20.
  - **Estilo:** CTA tinta, sem borda; SVG com traço `#F7F0E3` 1,8 no viewBox 24 (escala 0,75 no canvas), sem `colorFilter`; rótulo
    Figtree 14/700 `#F7F0E3`; badge `#FF552E` sem borda, texto Figtree 11/700 tinta.
  - **Pixels (3):** ponta esquerda e topo do CTA em tinta; badge `#FF552E`.
  - **Toques:** só o CTA (balão, rótulo, badge, pontas e ação semântica) chama `onDiscussionTap`.
- [x] 9.7 Canhoto: ENCONTRO 10 ls 1 `#4A2F33`; QUI/SET 12 ls 0,96; "24" Bricolage42/0,95 ls −1,5; pílula 20h 46,36×26,6; gaps 12
  - **Geometria:** caixa de conteúdo 74,5 × 227,6; bloco 12 + 12 + 68,7 + 12 + 26,6 = 131,3 centrado (topo em 67,65, sobras iguais);
    cada item e cada linha da data centrados em x = 303,25; data = coluna da largura do "24" (48,227; arquivo 48,24); pílula 46,353 ×
    26,600 (arquivo 46,36 × 26,6).
  - **Estilo:** ENCONTRO Figtree 10/700 ls 1,0 (0,1em) `#4A2F33`; QUI/SET Figtree 12/700 ls 0,96 (0,08em) tinta; "24" Bricolage42
    42/800/0,95 ls −1,5 tinta; pílula `#FFFAF1`, borda 1,5, raio 999, padding 4 10, texto Figtree 13/700 tinta.
  - **Texto:** ENCONTRO 1651,710 · QUI 1677,610 · 24 1714,420 · SET 1731,910 · 20h 1764,760 (arquivo 1651,71 / 1677,61 / 1714,42 /
    1731,91 / 1764,76).
  - **Dados:** QUI / 24 / SET / 20h e o `aria-label` do canhoto saem de `nextMeeting` pelos formatadores da F02.
- [x] Geometria 34/34 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
  - **Geometria:** 34/34 ids; maior desvio `club.pill.w` = 0,019 px; a tabela da especificação (34 linhas) bate com o JSON e com o
    Flutter a ≤ 0,019.
  - **Texto:** 17 textos (18 linhas) com strings e quebras exatas; baselines, inícios e fins com Δ ≤ 0,022 (`club.subtitle` fim).
  - **Estilo:** 10 testes: decorações, tipografia de todos os textos, pintores, ordem de pintura e recortes no canvas, 40 pontos de
    pixel @3x exatos e os dados nos extremos.
  - **Semântica:** seção "Seu clube do livro" com 10 nós na ordem do documento (+ o badge dentro do link); h3 nível 3; progressbar
    "Progresso do grupo" = "54%"; entalhes, perfuração, letras dos avatares e "M" fora da árvore. A travessia padrão do Flutter é
    geométrica e troca 3 pares (fixada no teste; informativo para a F12, como nas F05 e F07 — ver o relatório).
  - **Visual:** `--rect 16,1566,358,284` → `blur_mismatch_%` **0,0** (raw 2,2346, mean_abs 2,002, max 229) → PASSOU; no modo `--layout`
    as 6 seções anteriores repetem os números da F08 e `club` dá 0,0.
  - **Resíduo:** só rasterização (`F09_comparacao.md`): deriva vertical +0,07…+0,20 px da própria referência (dx 0), hinting da
    Instrument Serif a 3× e a suavização de arestas coincidentes nas bordas de cima/baixo da seção.
  - **Não-regressão:** acima (0, 0, 390, 1574) e abaixo (0, 1842, 390, 548) contra o golden APROVADO da F08: 0,0 / 0,0 / max 0; os
    828.112 pixels alterados estão todos na faixa da seção; testes F00–F08 verdes sem alteração.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  - `Formatted 104 files (0 changed)`, exit 0.
  - `No issues found!`, exit 0.
  - `+382: All tests passed!`, exit 0: os 353 anteriores + 29 da F09 (geometria 10, texto 5, estilo 10, semântica 2, formatadores 2).
  - Estabilidade: a suíte completa rodou mais 2 vezes em seguida, `+382` nas duas, nenhuma linha "did not complete"; `design_handoff/`
    intacto (131/131).
- [x] Relatório com lado-a-lado e heatmap inspecionados
  - Autorrevisão do §8: `secoes/F09_clube@3x.png` | golden | `redline/F09_clube_redline@3x.png` lado a lado
    (`F09_clube_secao_golden_redline.png`).
  - Inspecionados: `F09_clube_lado_a_lado.png`, `F09_clube_heatmap.png` e os 8 recortes ampliados (referência | Flutter 3× | Flutter
    10× → 3×).
  - Análise em `F09_comparacao.md`; relatório em `RELATORIO_FASE_09.md`.
