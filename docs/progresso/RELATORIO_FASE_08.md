## Relatório — FASE 8: Seção 6 — "Para você" (motivo + carrossel de capas)

### Entregue
- **Seção:** `lib/features/home/presentation/sections/for_you_section.dart` (`ForYouSection`, com `onBookTap` e `onSeeAllTap` para a
  F12), com a construção obrigatória da fase:
  - `Semantics(seção "Para você")` > `Column(stretch, min)` de largura total (o `_fullBleed` da F02 marca a Key `forYou` em 20→370);
  - cabeçalho `Padding(20)` > `SizedBox(44)` > `Row(spaceBetween)`: h3 "Para você" + link "Ver tudo" (altura de toque 44, seta 18);
  - gap 14 → chip do motivo (`Pill` 10/7/12/7, brilho 14 + texto) alinhado à esquerda → gap 14 + 4;
  - carrossel `SingleChildScrollView(horizontal, padding 20, Clip.hardEdge)` > `Row(start, gap 14)` com 3 itens de 116 (`Pressable`
    link > capa 116×174 + título/autor), o 3º cortado em 390; rola na horizontal (D-03).
- **Capas** (`lib/features/home/presentation/covers/`):
  - `memorias_postumas_cover.dart`: `#FF552E`, lombada .15, elipse 123×116 (`ShapeDecoration(OvalBorder)`), título em 3 linhas,
    autor na cor do fundo;
  - `quincas_borba_cover.dart`: `#058CD7`, lombada .18, barras 100/70/40 % (`Column(stretch)` + `FractionallySizedBox`),
    "Quincas⏎Borba";
  - `o_cortico_cover.dart`: `#00995E`, lombada .18, arco `#FED170` 34/34/0/0 + "porta" `#00995E` 14/14/0/0.
  - As 3: `NeoBox` 116×174, borda 1,5, raio 4/10/10/4, recorte suavizado na padding box, sem sombra, sem rotação, e
    `Stack(clipBehavior: Clip.none)` (o único recorte é o do `NeoBox`).
- **Dados:** `HomeFormatters.forYouReason(author)` → "Porque você lê Machado de Assis" (novo, em `application/formatters.dart`).
  Títulos e autores vêm do `ForYou` do mock (título curto "Memórias Póstumas" do `Book.shortTitle` da F02).
- **Tela:** em `home_screen.dart` o placeholder de `forYou` virou `ForYouSection()` (1 import + 1 linha). O `_Placeholder` perdeu o
  caso de id nulo, que só esta seção usava.
- **Testes (48 novos):**
  - `test/home/geometry_for_you_test.dart` (11);
  - `text_for_you_test.dart` (8);
  - `style_for_you_test.dart` (17);
  - `semantics_for_you_test.dart` (4);
  - `scroll_for_you_test.dart` (7 execuções: 4 testes, 3 deles em Android e iOS);
  - `formatters_test.dart` (+1, e o motivo conferido literalmente no HTML do arquivo).
- **Testes de fases aprovadas ajustados (não-regressão, sem mudar nenhum assert):** o carrossel é a 2ª rolagem da Início (dentro
  da 1ª), e os finders sem filtro ficaram ambíguos. Falhavam 7 testes da F02, com "Too many elements" ou "Found 2 widgets":
  `geometry_shell_test` — "Scaffold(backgroundColor: paper) … + SingleChildScrollView(primary: true)", "inset superior = max(62,
  viewPadding.top + 15)" com top 0, 47 e 59, "iOS: toque na status bar (handleScrollToTop) …" e "rolagem até o fim (extensão total
  2355,16) …"; `router_test` — "2.8 abas: … voltar a /inicio preserva a rolagem (IndexedStack)".
  - `test/support/pump_app.dart`: novo `homeScrollView()` e `homeScrollPosition` pegam a rolagem MAIS EXTERNA da HomeScreen (a
    primeira na ordem da árvore). Não filtram por direção nem por `primary`, então os asserts sobre esses campos continuam podendo
    falhar;
  - `test/home/geometry_shell_test.dart` (7 finders) e `test/home/router_test.dart` (1 finder): `find.byType(SingleChildScrollView)`
    → `homeScrollView()`.
- **Golden:** `test/golden/goldens/inicio_canvas@3x.png` regenerado, agora com a seção.
- **Documentação:** `docs/progresso/FASE_08.md`, `F08_verificacao.txt`, `F08_comparacao.md` e este relatório.
- **Evidências** em `build/visual_diff/F08/`: lado a lado, heatmap e onion; 8 recortes ampliados (referência | Flutter 3× | Flutter
  10× → 3×); `todas/`, `nao_regressao/`, `sonda_escala/` e `golden_F07_aprovado.png`.
- **Sonda:** a sonda de escala (3×/6×/10×) foi temporária, fora de `test/`, e já foi removida.

### Checklist (100%)
- [x] 8.1 Cabeçalho 44 (título 24 ls −0,6; "Ver tudo" 14/700 + seta 18 traço 2, gap 4)
  - Título 109,392 × 28,8 a y + 7,6; "Ver tudo" 78,008 × 44 à direita, seta em (332; 13); Bricolage24 24/800/1,2 ls −0,6 e Figtree
    14/700; seta `ic_arrow_right.svg` (traço 2 no viewBox 24).
- [x] 8.2 Chip 7/12/7/10, borda 1,5, brilho 14 + texto 13/600, gap 6 → 241,28×32,6
  - 241,297 × 32,600; brilho em (11,5; 9,3); texto 6 depois; `#FFFAF1`, borda 1,5, raio → 16,3, sem sombra; 11 pontos de pixel exatos.
- [x] 8.3 Carrossel 0→390, padding 20, gap 14, 18 px abaixo do chip, 3º item cortado em 390; rolagem D-03
  - 0→390 × 218,4; itens em 20 / 150 / 280; 3º de 280 a 396 cortado em 390 (pixels da última coluna).
  - No canvas: só o recorte do carrossel + 3 `clipRRect` suavizados das capas.
  - D-03: extensão 26; arrastar −100 → 26 e fica; +100 → 0; Android e iOS; a Início não rola; de volta a 0, bytes idênticos ao
    repouso (canvas inteiro) e ao golden (faixa da seção).
- [x] 8.4 Memórias: `#FF552E`, lombada .15, elipse 123×116 (OvalBorder), título 19/0,95 em 3 linhas, autor `#FF552E` só visível sobre a elipse
  - Elipse 123 × 116 (`drawOval`), "Memórias" / "Póstumas de" / "Brás Cubas", autor shrink-to-fit 78,317.
  - Nos pixels: "ACHADO DE ASSIS" em `#FF552E` sobre a tinta e a área do "M" só laranja.
- [x] 8.5 Quincas: `#058CD7`, lombada .18, barras 6 px (81/56,7/32,4, gap 6), "Quincas⏎Borba" 26/0,9, autor
  - Barras 81 / 56,7 / 32,4 × 6 à esquerda, gap 6; bloco 87 × 60,6; 19 pontos de pixel exatos.
- [x] 8.6 O Cortiço: `#00995E`, lombada .18, arco `#FED170` 68×80 (34/34/0/0) + arco `#00995E` 28×46 (14/14/0/0), título e autor
  - Arcos em (305,5; 1339,66) e (325,5; 1373,66), bases alinhadas; 14 pontos de pixel exatos (incluindo os cantos 34 e 14).
- [x] 8.7 Legendas 14/700/1,2 e 13/500; "Memórias Póstu…" (só o 1º com reticências)
  - "Memórias Póstu…" = 112,876 (arquivo 112,88); com mais uma letra estouraria 116 por 9,082. Itens 2 e 3 sem limite de linhas.
- [x] Geometria 41/41 · Texto OK · Estilo OK · Rolagem OK · Visual ≤ 0,5% · Não-regressão OK — números abaixo.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes: 0 mudanças · No issues found! · +353: All tests passed!
- [x] Relatório com lado-a-lado e heatmap inspecionados — `F08_comparacao.md`.

### Verificação
- **Geometria:** 41/41 ids dentro da tolerância. O maior desvio é `forYou.title.w` = 0,042 px; todos os 41 ≤ 0,05. A tabela da
  especificação (41 linhas, relativa à seção) bate com o JSON e com o Flutter.
- **Estilo:** 17 testes; cores, alphas, bordas e pixels sem tolerância; o raio normalizado do chip e as formas dos recortes no canvas
  com ±1e-3 / 1e-6 (ruído float32):
  - tipografia de todos os textos, cores, bordas, raios (4/10/10/4; 34/34/0/0; 14/14/0/0; 6; 999), alphas das lombadas
    (`0x26`/`0x2E`), `OvalBorder`;
  - canvas gravado (`TestRecordingPaintingContext`): ordem de pintura lombada → formas → textos em cada capa, recortes, nenhuma
    rotação, nenhum `saveLayer`, sem ripple;
  - 67 pontos de pixel @3x + 3 colunas de lombada, todos no valor exato.
- **Visual** (`compare_images.py`):

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | F08_para_voce (0, 1199, 390, 344) | 0,0 | 2,0278 | 1,63 | 229 | PASSOU |
  | forYou (`--layout`) | 0,0 | 2,1986 | 1,77 | 229 | PASSOU |
  | header / headline / hero / alsoReading / today (`--layout`) | 0,0 | 0,4113 / 1,3126 / 0,6195 / 0,8922 / 1,3001 | — | 142 / 221 / 128 / 189 / 228 | PASSOU (= F07) |
  | acima da seção (0, 0, 390, 1207) × golden aprovado da F07 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | abaixo da seção (0, 1535, 390, 855) × golden aprovado da F07 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

  As diferenças que sobram são todas de rasterização; a análise completa está em `F08_comparacao.md`:
  - **Deriva vertical da própria referência** (screenshot com `zoom: 10`): +0,1 a +0,2 px nesta seção, zero no eixo x. Compensando
    o deslocamento, os pixels > 64 caem a zero em todas as regiões, menos no título da capa Memórias.
  - **Instrument Serif a 3×** (hinting, como na F04/F06): o golden puxa "Memórias" 0,30 px para cima; a 6× e a 10× os glifos voltam à
    posição da referência.
  - **Costura de 1/3 px** na borda direita da capa Memórias: duas arestas de 50 % na mesma coluna (borda + elipse recortada) dão
    exatamente `#53261A`; some a 10×.

  Forma, posição, cor, espessura, ordem de pintura e recorte são iguais ao arquivo. Os 628.476 pixels alterados em relação ao golden
  da F07 estão todos na faixa da seção.
  Evidências: `build/visual_diff/F08/F08_para_voce_{lado_a_lado,heatmap,onion}.png` e os recortes ampliados listados em
  `F08_comparacao.md`.
- **Texto:** 15 textos, 18 linhas: strings e quebras exatas; baselines Δ ≤ 0,015; inícios e fins Δ ≤ 0,042. Reticências só no
  título do item 1. Textos derivados dos dados (provado com outro `ForYou` via override do provider).
- **Semântica e toques:** seção "Para você" (container, filhos na ordem do documento), h3 nível 3, link "Ver tudo", texto do chip,
  3 links com o texto do item; toque e `SemanticsAction.tap` chamam o callback certo; fora dos links nada dispara.
- **Qualidade:** flutter analyze com 0 problemas · dart format ok (99 arquivos, 0 mudanças) · flutter test com 353 passando ·
  `design_handoff/` intacto (131/131).
- **Estabilidade:** 3 execuções completas da suíte, todas `+353`, nenhuma "did not complete".

### Achados da revisão adversarial (corrigidos nesta fase)
- **Recorte extra na capa Memórias.** A `Stack` da capa usava o `Clip.hardEdge` padrão; como a elipse transborda, ela empilhava um
  recorte retangular **sem suavização** sobre o do `NeoBox`, e a lombada sumia da coluna física 64 (x 21,33–21,67). Corrigido com
  `Clip.none` nas 3 capas (502 pixels mudaram, todos nessa coluna, diferença máxima 5). O teste agora exige um único `clipRRect`
  suavizado por capa e o valor `0xFF873420` na coluna 64.
- **Regressão em testes da F02** (7 falhas por finder ambíguo com a 2ª rolagem). Corrigida nos finders, sem mudar asserts — ver
  "Testes de fases aprovadas ajustados" acima.
- Comentário do link "Ver tudo" corrigido: a seta não é `aria-hidden` no arquivo; ela fica fora do nome porque é um SVG sem nome
  acessível (e o `AppSvg` a exclui da árvore).

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas:
  - D-03: carrossel com rolagem horizontal, física da plataforma, repouso idêntico ao arquivo;
  - D-04: itens e "Ver tudo" com `Pressable` (sem ripple);
  - D-09: dados do mock;
  - D-15: rótulo da seção = `aria-label` do arquivo.
- O `<h3>` usa `headingLevel: 3`, como nas fases anteriores.

### Achado numa fase já aprovada (F05) — aguarda a sua decisão, nada foi alterado nela
- **O mesmo recorte extra existe na capa Dom Casmurro do hero.** O sol transborda e a `Stack` (com o `Clip.hardEdge` padrão) empilha
  um `clipRect` sem suavização sobre o `clipRRect` do `NeoBox`. As capas da F06 e da F08 pintam só o `clipRRect`. Como a capa é
  girada −3°, esse recorte deixa as arestas internas em degraus.
- **Medição** (`F08_verificacao.txt`, sondas temporárias em `build/sonda_f08b/`), com uma troca temporária para `Clip.none`, já
  desfeita (`git diff` da capa vazio):
  - 249 pixels mudam (máx. 98), todos nas arestas da capa;
  - nesses pixels, a diferença para a referência cai (> 64: 17 → 0; média 23,1 → 16,9);
  - o gate da F05 passou e continua passando.
- **Proposta, se você aprovar:** uma subfase "5.x-correção" com `Stack(clipBehavior: Clip.none)` na `DomCasmurroCover`, o golden
  regenerado e o teste de estilo da F05 exigindo um único recorte.

### Riscos/pendências
- Nenhuma na F08.
- **Informativo — semântica da seção.** O nó "Para você" mede 0→390 (a coluna de largura total que a construção obrigatória pede),
  enquanto o `<section>` do arquivo mede 20→370; a Key `forYou` (do `_fullBleed` da F02) fica fora desse nó. O conteúdo e a ordem
  lidos pelo leitor de tela estão corretos. Registro para a revisão de semântica da F12.
- **Informativo — git.**
  - As mudanças da F07 e da F08 estão sem commit (último commit: `a3054fd`, fases 5–6).
  - `test/home/failures/` (não versionado, e o `.gitignore` não o exclui) agora guarda os 4 PNGs de uma execução da suíte às 01:39
    desta fase. Nela o golden ainda era o do rascunho, de antes do `Clip.none`: o `masterImage` é esse golden e o `testImage` é o
    render corrigido. O golden foi regenerado logo depois (passo 1 do §7). Não apaguei os PNGs: sugiro removê-los ou ignorar a pasta
    no `.gitignore` antes de um commit.

✅ FASE 8 concluída — aguardando sua aprovação para iniciar a FASE 9.
