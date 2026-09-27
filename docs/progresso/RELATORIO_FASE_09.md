## Relatório — FASE 9: Seção 7 — Ticket do clube do livro ("Leitoras de Capitu")

### Entregue
- **Seção:** `lib/features/home/presentation/sections/book_club_ticket.dart` (`BookClubTicket`, com `onDiscussionTap` para a F12),
  com a construção obrigatória da fase:
  - `Semantics(seção "Seu clube do livro")` > `ClipRRect(club, raio 28)` > `Stack(Clip.none)` [ticket, entalhe de cima, entalhe de
    baixo];
  - ticket = `NeoBox(#FFFAF1, borda 1,5, raio 28, recorte)` > `IntrinsicHeight` > `Row(stretch)` [`Expanded(Padding(corpo, 18 16 18
    18))`, `SizedBox(canhoto, 92)`];
  - corpo = `Column(gap 14)`: linha superior (pílula "Clube do livro" + avatares A/J/L/"+8" sobrepostos), título em 2 `AppText`
    ("Leitoras de" / "Capitu") sob um único nó h3 + subtítulo, progresso (trilho hachurado com `LayoutBuilder`, preenchimento 54 %
    com a borda direita, marcador "M" em 62 %; legendas) e o CTA (`Pressable` link: balão + "Abrir discussão" + badge "3");
  - canhoto = `ColoredBox(#FFC1C6)` + perfuração (`ChromiumDashPainter` vertical, 59 traços) + coluna centrada (ENCONTRO / QUI 24 SET
    / pílula 20h);
  - entalhes = `NeoBox` 26 `#F7F0E3` com borda 1,5, fora da semântica, pintados por cima do ticket e cortados em meio círculo pelo
    recorte da seção.
- **Dados:** formatadores novos em `application/formatters.dart` — `clubName` ("Leitoras de Capitu", nome do h3),
  `groupProgressLabel` ("Grupo em 54%") e `userProgressLabel` ("Você em 62%") —, com testes unitários e conferidos literalmente no
  HTML do arquivo. Todo o resto vem dos formatadores da F02 sobre o `BookClub` do mock.
- **Tela:** em `home_screen.dart` o placeholder de `club` virou `BookClubTicket()` (1 import + 1 linha).
- **Testes (29 novos):**
  - `test/home/geometry_club_test.dart` (10);
  - `text_club_test.dart` (5);
  - `style_club_test.dart` (10);
  - `semantics_club_test.dart` (2);
  - `formatters_test.dart` (+2).
  - Nenhum teste de fase aprovada foi alterado.
- **Golden:** `test/golden/goldens/inicio_canvas@3x.png` regenerado, agora com a seção.
- **Documentação:** `docs/progresso/FASE_09.md`, `F09_verificacao.txt`, `F09_comparacao.md` e este relatório.
- **Evidências** em `build/visual_diff/F09/`: lado a lado, heatmap e onion; 8 recortes ampliados (referência | Flutter 3× | Flutter
  10× → 3×); `F09_clube_secao_golden_redline.png`; `todas/`, `nao_regressao/`, `sonda_escala/` e `golden_F08_aprovado.png`.
- **Sondas:** as sondas em Dart (escala 3×/6×/10×, larguras 360/430, ordem de travessia, canvas) foram temporárias, fora de
  `test/`, e já foram removidas. Os scripts de análise ficaram em `build/sonda_f09/`.

### Checklist (100%)
- [x] 9.1 Seção recorta com raio 28 (sem borda); ticket `#FFFAF1` borda 1,5 raio 28; corpo 255 + canhoto 92; altura 266,6
  - Construção conferida widget a widget; altura 266,600000 = 1,5 + 18 + 27,4 + 14 + 77,8 + 14 + 34,4 + 14 + 46 + 18 + 1,5; no canvas
    só 3 `clipRRect` suavizados (seção 28, ticket 26,5, trilho).
- [x] 9.2 Perfuração: borda esquerda tracejada 1,5 do canhoto (59 traços, vão 1,4931)
  - 59 `drawRect` 1,5 × 3 nas posições do Chromium sobre o fundo `#FFC1C6`; vão 1,49310; pixels do traço 30 e do vão exatos.
- [x] 9.2 Entalhes 26×26 `#F7F0E3` borda 1,5 em right 79,75, top/bottom −13, recortados em meio círculo, por cima do ticket
  - Centro em x = 257,25 = meio da perfuração, y 0 e 266,6; as 4 últimas formas pintadas; 7 pontos de pixel (miolo, anel, metade
    cortada, borda interrompida).
- [x] 9.3 Pílula "Clube do livro" nowrap 99,38×27,4; avatares A/J/L/+8 26×26 sobrepostos (−8) com cores e fontes corretas
  - Pílula 99,399 × 27,4 (nowrap: largura ilimitada na `Row`); avatares em 0 / 18 / 36 / 54, `#B6ACE4` / `#ABCF82` / `#FFC1C6` / "+8"
    `#FFFAF1`, Figtree 11/700 e 10/700; o J pinta sobre o A.
- [x] 9.4 "Leitoras de" 22/1 ls −0,5 + "Capitu" itálico 36/0,95 ls −0,4 em coluna de 2 `AppText` (56,2) com um único nó de cabeçalho "Leitoras de Capitu"; subtítulo com "·"
  - Linhas 22 + 34,2; baselines 18,260 / 51,340 a partir do topo (arquivo 18,26 / 51,34); um nó h3 (nível 3) "Leitoras de Capitu".
- [x] 9.5 Trilho 12 hachurado; preenchimento 117,72 com borda direita 1,5; marcador 24 em 62% transbordando 6 px
  - Preenchimento 0,54 × 218 = 117,72 × 9; marcador com o centro em 176,52 (absoluto), 6 acima e 6 abaixo; hachura, borda direita e
    marcador em pixels exatos.
- [x] 9.5 Legendas "Grupo em 54%" (600 `#5B544B`) × "Você em 62%" (700 tinta)
  - Nas pontas da linha, 8 abaixo do trilho; baselines 1758,660 (arquivo 1758,66).
- [x] 9.6 CTA 221×46 com balão 18 + rótulo 14/700 + badge "3" (20×20 `#FF552E`, texto tinta)
  - Grupo 18 + 8 + 98,636 + 8 + 20 centralizado; SVG com traço `#F7F0E3` 1,8; badge `#FF552E` sem borda, "3" Figtree 11/700 tinta.
- [x] 9.7 Canhoto: ENCONTRO 10 ls 1 `#4A2F33`; QUI/SET 12 ls 0,96; "24" Bricolage42/0,95 ls −1,5; pílula 20h 46,36×26,6; gaps 12
  - Bloco 131,3 centrado (topo em 67,65); cada item centrado em x = 303,25; pílula 46,353 × 26,6.
- [x] Geometria 34/34 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK — números abaixo.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes: 0 mudanças · No issues found! · +382: All tests passed!
- [x] Relatório com lado-a-lado e heatmap inspecionados — `F09_comparacao.md`.

### Verificação
- **Geometria:** 34/34 ids dentro da tolerância; maior desvio `club.pill.w` = 0,019 px. A tabela da especificação (34 linhas,
  relativa à seção) bate com o JSON e com o Flutter a ≤ 0,019. Numa sonda nas larguras 360 e 430 (validação formal é da F13), os 34
  ids também batem com `reference_layout_w360/w430` (maior desvio 0,019).
- **Estilo:** 10 testes, sem tolerância nas cores, alphas, bordas e pixels:
  - decorações e tipografia de todos os textos (instâncias Bricolage 22 / 42 / 12, Figtree 800 → 700, letter-spacing 1,0 / 0,96 /
    −0,5 / −0,4 / −1,5);
  - canvas gravado (`TestRecordingPaintingContext`): 3 recortes suavizados, nenhum `clipRect`/`saveLayer`, a única transformação é a
    escala 0,75 do SVG, e a sequência completa de formas na ordem do arquivo (ticket → pílula → A J L +8 → trilho → marcador → CTA →
    badge → canhoto + 59 traços → 20h → entalhes);
  - 40 pontos de pixel @3x exatos (os mesmos valores também na referência);
  - dados nos extremos: progresso 0 → o fio de 1,5 da borda direita (piso do border-box) em tinta exata; 1 → 218; sem avatares →
    0 × 0.
- **Visual** (`compare_images.py`):

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | F09_clube (16, 1566, 358, 284) | 0,0 | 2,2346 | 2,002 | 229 | PASSOU |
  | club (`--layout`) | 0,0 | 2,2549 | 2,02 | 229 | PASSOU |
  | header / headline / hero / alsoReading / today / forYou (`--layout`) | 0,0 | 0,4113 / 1,3126 / 0,6195 / 0,8922 / 1,3001 / 2,1986 | — | 142 / 221 / 128 / 189 / 228 / 229 | PASSOU (= F08) |
  | acima da seção (0, 0, 390, 1574) × golden aprovado da F08 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | abaixo da seção (0, 1842, 390, 548) × golden aprovado da F08 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

  As diferenças que sobram são todas de rasterização; a análise completa está em `F09_comparacao.md`:
  - **Deriva vertical da própria referência** (screenshot com `zoom: 10`): +0,07 a +0,20 px nesta seção, zero no eixo x (as bordas
    esquerda e direita do ticket coincidem pixel a pixel). Compensando o deslocamento, os pixels > 64 caem a zero em todas as regiões
    (restam 3, com máx. 65, nas pontas arredondadas).
  - **Instrument Serif a 3×** ("Capitu", hinting, como na F04/F06/F08): 1.308 pixels > 64 a 3×, 0 a 10× com a deriva compensada.
  - **Arestas coincidentes nas bordas de cima e de baixo da seção:** o recorte da seção, a borda do ticket e o miolo dos entalhes
    caem na mesma linha física de cobertura parcial; o Skia multiplica as coberturas, e sobra um fio de 1/3 px na abertura dos
    entalhes (4,5 % de tinta em cima, 12 % embaixo), visível só em zoom ≥ 5×. Forma, cor, ordem de pintura e recortes são os do
    arquivo.

  Os 828.112 pixels alterados em relação ao golden da F08 estão todos na faixa da seção (x 20–370, y 1574,33–1841,33).
- **Texto:** 17 textos, 18 linhas: strings e quebras exatas; baselines Δ 0,000; inícios e fins Δ ≤ 0,022. Textos visíveis e
  acessíveis derivados dos dados (provado com outro `BookClub` via override do provider).
- **Semântica e toques:** seção "Seu clube do livro" com 10 nós na ordem do documento (o badge "3 mensagens novas" dentro do link);
  h3 nível 3 "Leitoras de Capitu"; progressbar "Progresso do grupo" = "54%"; "Você", "11 participantes" e o canhoto com os
  `aria-label` do arquivo; entalhes, perfuração, letras dos avatares e o "M" fora da árvore. Só o CTA é interativo: toque e
  `SemanticsAction.tap` chamam `onDiscussionTap`; nada mais dispara.
- **Qualidade:** flutter analyze com 0 problemas · dart format ok (104 arquivos, 0 mudanças) · flutter test com 382 passando ·
  `design_handoff/` intacto (131/131).
- **Estabilidade:** 3 execuções completas da suíte, todas `+382`, nenhuma "did not complete".

### Revisão adversarial (2 revisores independentes: fidelidade ao arquivo × armadilhas de renderização)
Nenhum achado bloqueante ou importante. Corrigido nesta fase:
- **Piso do border-box no preenchimento:** com `box-sizing: border-box`, a caixa de `width: 54%` nunca fica mais estreita que a
  própria borda direita. Abaixo de 1,5 / 218 (0,69 %) o CSS ainda mostra o fio de 1,5 no começo do trilho; o Flutter não mostrava
  nada. Agora `widthFactor = max(progresso, 1,5 / 218)`. Com os dados do arquivo (0,54) nada muda: o golden ficou byte a byte igual.
- **Grupo de avatares vazio:** media 8 × 26; agora 0 × 0, como o flex vazio do CSS.
- **Testes:** a ordem de travessia fixada como lista; os textos acessíveis conferidos também com os dados trocados; três asserções
  tautológicas trocadas por medições (o `clubName` contra as partes capturadas do HTML, a caixa de conteúdo do canhoto medida no
  `Center`); o `ExcludeSemantics` conferido como pai direto e ativo do entalhe e da perfuração.

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas: D-04 (CTA com `Pressable`, sem ripple), D-09 (dados do mock), D-14 (Figtree 800 → 700) e D-15
  (rótulos = `aria-label` do arquivo).
- Detalhes da construção que vão além do trecho da fase, todos neutros ou mais fiéis ao CSS:
  - `Stack(clipBehavior: Clip.none)` na seção: os entalhes transbordam 13 px, e com o `Clip.hardEdge` padrão a Stack empilharia
    um recorte retangular sem suavização que o arquivo não tem (o único recorte é o `overflow: hidden` da `<section>`, o
    `ClipRRect`). O canvas prova 3 recortes, todos suavizados.
  - `headingLevel: 3` no h3, como nas fases anteriores; `mainAxisSize.min` nas colunas internas (altura auto do CSS, sem efeito
    sob altura ilimitada).
  - O piso do border-box no preenchimento (acima) e a largura do grupo de avatares derivada da quantidade (80 para os dados do
    arquivo).

### Informativo — para a F12 ou para quando você decidir (nada foi alterado fora desta fase)
- **Ordem de leitura do leitor de tela.** A árvore segue o documento, mas a travessia é a ordenação geométrica padrão do Flutter e
  troca três pares: "11 participantes" ↔ "Clube do livro", "Você" ↔ "Progresso do grupo" e "Abrir discussão" ↔ "Você em 62%". O
  mesmo já acontece em fases aprovadas: no hero (F05) os textos da capa vêm depois dos metadados, e no cartão do dia (F07) "de 30
  min" troca com "Faltam 12 min…". Uma saída seria `OrdinalSortKey` em documento na revisão de semântica da F12.
- **Área de toque do CTA.** O `Pressable` (F01) é opaco no retângulo 221 × 46 inteiro, então os quatro cantos fora da cápsula
  também tocam o link. No navegador, a área fora da curva da borda não recebe o toque. É o mesmo tema da capa da F06.
- **Papel da progressbar.** Segue a convenção §5.1 (rótulo + valor "54%"), como a F05. O SDK atual tem `SemanticsRole.progressBar`
  com mínimo e máximo; adotar isso é uma decisão para F05 e F09 juntas.
- **Latente, sem efeito hoje:** o `LayoutBuilder` do trilho (da construção obrigatória) não calcula layout seco nem largura
  intrínseca. Nenhum ancestral pede isso hoje; se um dia pedir, há uma alternativa sem `LayoutBuilder`. Os 6 px do marcador que
  transbordam o trilho não recebem toque, sem efeito porque o marcador não é interativo.

### Pendências de fases anteriores (continuam aguardando você)
- A proposta de subfase "5.x-correção" do relatório da F08 (`Stack(clipBehavior: Clip.none)` na capa Dom Casmurro do hero) continua
  sem decisão; nada foi alterado na F05.
- **Git:** F07, F08 e F09 estão sem commit (último commit: `a3054fd`, fases 5–6). `test/home/failures/` ainda guarda os 4 PNGs da
  execução da F08 citada no relatório anterior; não os apaguei.

### Riscos/pendências
- Nenhuma na F09.

✅ FASE 9 concluída — aguardando sua aprovação para iniciar a FASE 10.
