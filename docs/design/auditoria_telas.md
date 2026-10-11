# Auditoria das telas × HTML do design

> 10/10/2026 · só leitura (nenhum código, fase, prompt mestre, `design_handoff/`, `handoff_v2/` ou
> `docs/design/referencia/` foi alterado) · branch `feat/g22-pro-revenuecat`, HEAD `cd55500`.
> Lidos: `CLAUDE.md`, `docs/design/LEIA-ME.md`, `handoff_v2/00_PROMPT_MESTRE_V2.md` (§6, §7, trilha T, §11),
> `handoff_v2/01_INVENTARIO_TELAS.md` (§0, §15), `docs/design/estados_sem_design.md`, `lib/app/router.dart`,
> `lib/features/*/presentation`, os relatórios G01, G08, G11–G22 e F13.

## 0. Como foi feito

- As pranchas foram extraídas com `tools/medicao/extrair_bundle.py --aninhado` para uma pasta temporária (fora do
  repositório): as 16 do clube com `tools/medicao/pranchas_clube.json`; as 6 da Início e da revisão com um índice
  feito na hora (o repositório ainda não tem um para esse arquivo). A extração conferiu `page_order`, títulos e canvas
  das 22: **OK**.
- Cada prancha foi renderizada isolada no Chromium 141 (`--font-render-hinting=none`, rede bloqueada), com o texto
  visível e as `@font-face` declaradas. A Início da v1 (`design_handoff/.../Redesign mobile — App de leitura.html`)
  foi renderizada do mesmo jeito para comparar com a 01 nova (lado a lado e `diff` do texto).
- As telas 19–27b foram conferidas pelos testes e relatórios das fases (G11–G21) e pela métrica do
  `tools/compare_images.py` (σ 1,5, limiar 24) refeita sobre os goldens do repositório.
- Não rodei `flutter test`: os números de teste citados são os dos relatórios.

> **Achado fora do escopo, mas importante:** a G22 **já foi implementada e fechada** neste branch (commits
> `c8cfca0`…`cd55500`, 09/10/2026 19:55–23:44; `docs/progresso/G22.md` diz "G22 concluída"). Não mexi nela. O pedido
> "não comece a G22" chegou depois disso.

## 1. Os arquivos do design e as pranchas

| Arquivo | Pranchas | Medidas? |
|---|---|---|
| `design_handoff/referencia/original/Redesign mobile — App de leitura.html` (v1) | Início (390 × 2390) | **Sim** (F00–F13): `design_handoff/referencia/layout`, `test/reference/reference_layout*.dart` |
| `handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html` | 19, 20, 21, 22, 23, 23b, 24, 24b, 25, 26, 26b, 27, 27b | **Sim** (G01): `handoff_v2/referencia/layout`, `png`, `test/reference/leitor/` |
| `docs/design/referencia/Redesign_mobile___App_de_leitura__1_.html` | 01 (390 × 2650), 01b, 60, 61, 62, 63 | **Não.** Nem índice de extração existe |
| `docs/design/referencia/Redesign_mobile___App_de_leitura_2.html` | 04, 31, 32, 33, 34, 47, 48, 49, 50, 70, 71, 72, 73, 102, 103, 104 | **Não** (G01-bis não feita). Só o índice `tools/medicao/pranchas_clube.json` (commit `05502ab`). Nenhum `layout_c*.json`, PNG, `idmap` ou fase L |

**Resposta direta às duas perguntas do pedido:**
- **01b e 60–63 não existem no app.** Não há rota, widget nem dado para a mini-barra do cronômetro (01b), para o cartão
  "Seus grifos de hoje" (01/60) nem para a revisão (61–63). A Início do app é a da **v1**, não a 01 nova.
- **As pranchas do clube não estão medidas.** A G21 só criou os dados que 04, 31, 32 e 70–73 pedem (D-211) e o índice
  de extração; a medição (G01-bis) nunca rodou. O app não tem nenhuma tela do clube: `/clubes` e
  `/clube/:clubId/discussao` são `PlaceholderScreen`.

## 2. Resumo

| Classe | Quantas | Quais |
|---|---|---|
| **(A)** tem prancha e está fiel | **9 pranchas** (leitor) | 19, 20, 21, 22, 25, 26, 26b, 27, 27b — rotas `/leitor/:bookId` e `/livro/:bookId/destaques`. Três têm exceção **aprovada**: 21 (D-55, versão corrigida), 25 (D-204, miniaturas de tinta), 26 (D-147, "baixa visão") |
| **(B) leve** — fiel nos gates, mas com diferença visível que ficou sem decisão | **4 pranchas** (leitor) | 23, 23b, 24, 24b: o Desfazer e o "+" apagados (na prancha, acesos), a íris da 24b em fileiras, o traço do dedo e o rastro da 24; recortes do golden que deixam a pílula/prateleira/ilha sem comparação. A tinta coral da 23b é exceção aprovada (D-59) |
| **(B)** tem prancha, mas o app está diferente, simplificado ou não tem a tela | **22 pranchas** | Início nova: 01, 01b, 60, 61, 62, 63 · Clube: 04, 31, 32, 33, 34, 47, 48, 49, 50, 70, 71, 72, 73, 102, 103, 104. Só 3 já têm rota (`/inicio`, `/clubes`, `/clube/:clubId/discussao`); as outras 19 não existem no app |
| **(C)** não tem prancha em nenhum HTML | **9 telas com rota** + estados e folhas | `/biblioteca`, `/perfil`, `/scanner`, `/notificacoes`, `/livro/:bookId`, `/para-voce`, `/entrar`, `/conta/cadastro`, `/_pro` (paywall) — mais as folhas e estados da §5.2 |
| fora da classificação | 1 | `/_ds` (galeria do design system, só depuração — não é tela do produto) |

A Início que está no app é **(A) contra a v1** (F13: 248/248 ids, maior desvio 0,043 px, 10/10 seções com
`blur_mismatch_%` 0,0; G08: todos os testes de fidelidade verdes com a fixture) e **(B) contra a 01 nova**. Como o
`docs/design/LEIA-ME.md` e o `CLAUDE.md` apontam a 01 de `docs/design/referencia/` como a Início do design, ela conta
como (B) — e a troca precisa da sua decisão (proposta D-240 no plano).

## 3. O leitor (19–27b): 9 fiéis (A) e 4 com diferença leve (B)

Como a fidelidade é provada (vale para todas):
- **Geometria, texto, estilo e semântica:** testes de fase contra os `kRef` gerados na G01
  (`test/reference/leitor/reference_layout_<tela>.dart`), ±0,5 px (±1,0 em x/w dos ids que dependem de texto).
- **Visual:** os testes de `test/golden/` geram o golden @3x do app; a comparação com o PNG do HTML
  (`handoff_v2/referencia/png/`) é feita com `tools/compare_images.py` e registrada no relatório da fase. **Não há
  teste automático que compare o golden com o PNG do HTML** — ele compara o golden consigo mesmo. Um desvio novo
  numa tela A só aparece se alguém rodar a comparação de novo (proposta no plano: a T01 entrega um script que refaz a
  comparação de todas as telas, e a G28 o roda).

Recortes dos goldens das fases: 19 e 21 y 84–844; 20 e 26b y 46–844; 26 y 46–842 (a faixa de cima fora do recorte dá
0,0 %). As fases L do leitor rodam a 390 × 844, só em Creme (19/21/26) e Noite (26b): Branco e Sépia não têm prancha.
Os 5 goldens das telas 19, 20, 21, 26 e 26b não mudam desde a G14; refeita agora a comparação com os PNGs do HTML,
os números abaixo se repetem.

### 19 · Leitor limpo (G11) — fiel

- **Prancha:** `handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html` › "19 · Leitor — modo limpo
  (e-book)"; PNG `handoff_v2/referencia/png/19_leitor_limpo_390x844@3x.png`.
- **Testes:** `test/features/reader/presentation/l19_test.dart` (5 ids do `kRef19`, as 19 linhas com texto, baseline e
  bordas ±0,5, estilo, semântica "Dom Casmurro, página 159 de 256", 159/256/62 % calculados);
  `test/features/reader/layout/tela19_gate_test.dart` (22/22 linhas, fios de navalha 7 e 19);
  `test/golden/leitor_19_test.dart`.
- **Resultado (RELATORIO_G11.md:39):** geometria 5/5 (texto da pág. 159: baseline 0,0027 px, borda 0,0065 px —
  G10.md:196); visual 0,19 % (página 0,238, rodapé 0,0).
- **Sem prancha:** barra de status escondida (D-105), rodapé de Branco/Sépia/Noite derivado (D-110), "Abrindo/Preparando
  o livro…" e os erros (D-21/D-113/D-123, `reader_states.dart`), "← Voltar à pág. N" (D-108), PDF básico (D-109),
  imagens (D-114).
- **Veredito: (A).**

### 20 · Leitor com controles (G12) — fiel

- **Testes:** `l20_test.dart` (`test/support/fase_l20.dart`: 45 ids + 1 inline, linhas e baselines, estilo, semântica,
  dados), `islands_test`, `bottom_island_test`, `scrubber_test`, `reader_chrome_palette_test`,
  `test/golden/leitor_20_test.dart`.
- **Resultado (RELATORIO_G12.md:41):** 45/45; visual **0,0 %** em todas as seções.
- **Ressalva de dado:** o "≈ 2 h 10 min" é escrito à mão na prancha; com o mundo real a conta dá ~1 h 10, então o teste
  injeta a velocidade (`test/support/dados_t20.dart:48-54`). O layout está provado; o valor só com a injeção.
- **Sem prancha:** painel de busca no livro (D-23/D-120), pílula de volta depois do salto (D-119), o Tema que alterna e
  grava (D-37/D-121), salto pela barra (D-22), fita desmarcada com ícone extrapolado (D-124).
- **Veredito: (A).**

### 26b · Tema Noite com controles (G12) — fiel

- **Testes:** `l26b_test.dart` (`fase_l20.dart` com papel Noite), `test/golden/leitor_26b_test.dart`.
- **Resultado:** 45/45 + 1 inline; visual **0,0 %** em todas as seções.
- **Diferença aceita:** a marca da busca no Noite em duas camadas de cor (D-127).
- **Veredito: (A).**

### 21 · Seleção de texto (G13) — fiel à versão corrigida aprovada

- **Testes:** `l21_test.dart` (`test/support/fase_l21.dart`: 34 ids, grifo e seleção linha a linha, 19 linhas + 5
  textos da barra, estilo, semântica D-57, Copiar letra por letra), `highlight_toolbar_test`, `selection_layer_test`,
  `test/golden/leitor_21_test.dart` **contra `21_selecao_texto_corrigida_390x844@3x.png`**.
- **Resultado:** 34/34; visual 0,12 % na página e 0,03 % na barra.
- **Por que "corrigida":** a prancha literal tem `overflow: visible` no `article`, as linhas 20–22 vazam e a 20 encosta
  no rodapé (G01.md:53,62). A **D-55** (aprovada 03/10) adotou a versão de 19 linhas com o rodapé limpo. Contra a
  prancha literal o app dá 2,67 % — de propósito.
- **Diferenças aceitas:** um só "Trecho selecionado" (D-57), `brand` global (D-51a), Noite sem prancha (barra, lupa,
  folha), a nota mostra e edita só a mais antiga (D-138), PDF sem seleção (D-134).
- **Sem prancha:** folha da nota (D-131/D-23), folha "Outra cor" (D-178/D-38), lupa (D-135), barra do grifo existente
  com anel (D-132/D-137), "Trecho copiado" e "Grifo apagado · Desfazer" (D-136/D-139), Sublinhar (D-130).
- **Veredito: (A)**, com a exceção D-55.

### 26 · Ajustes de leitura (G14) — fiel, com um texto aprovado diferente

- **Testes:** `l26_test.dart` (`test/support/fase_l26.dart`: 83 ids, 14 linhas da prévia + textos da folha, estilo,
  semântica, dados), `reader_settings_sheet_test`, `test/golden/leitor_26_test.dart`.
- **Resultado:** 83/83; visual 0,15 % (`rs.page` **0,43 %** — a seção mais perto do limite —, `rs.sheet` 0,14 %,
  pílula 0,0).
- **Diferença aprovada:** a legenda da Atkinson é **"baixa visão"** no lugar de **"dislexia"**, e o rótulo do leitor de
  tela acompanha (**D-147**, G14.md:56).
- **Sem prancha:** folha no Noite (D-143), tela baixa com rolagem interna (D-145), toque nos pontos e "A" desabilitado
  nas pontas (D-144), fechar por ×/Voltar/toque/alça (D-141/D-142).
- **Veredito: (A)**, com a exceção D-147.

**Comum às 19, 20, 26 e 26b (D-169):** nos instantâneos das pranchas, a tinta, o grifo à mão e a nota à mão "de hoje"
ficam no banco sem lugar — contam no "12" e não pintam. Com dados reais o app pinta tudo isso nessas telas, e a
prancha não mostra (não é diferença de fidelidade: é o dado). **Pendência perdida:** "repaginar quando a tela muda de
tamanho" (G11.md:340, G12.md:296, atribuída à G14) não foi feita nem listada; `reader_screen.dart:249-263` lê o
viewport uma vez — a D-209 (retrato travado) só atenua.

### 22 · Modo anotação (G16) — fiel

- **Prancha:** arquivo (1) › "22 · Leitor — modo anotação".
- **Testes:** `test/features/reader/presentation/l22a…l22d_test.dart` (`test/support/fase_l22.dart`, 20 testes, 56 ids
  do `kRef22`, a tinta por pontos contra o caminho SVG, as 22 linhas do parágrafo, estilo, semântica, dados);
  `test/golden/leitor_22_test.dart` (recortes y 108–844, 42–110, 656–754, 716–822); peças em
  `annotation_top_bar_test`, `tool_shelf_test`, `annotation_island_test`, `annotation_canvas_test`.
- **Resultado (G16.md:509–525):** L22 20/20; tinta: elipse 0,119 px, risco 0,125 px, onda 0,000 px; golden
  0,20 / 0,00 / 0,16 / 0,00 %.
- **Diferenças pequenas registradas:** barras da Reta 2,2 px × 2,4 (G16.md:584); linhas 20–21 do parágrafo não
  pintadas (G16.md:588); com EPUB real as linhas 10–14 quebram como na 19 (D-160 — só o EPUB de teste tem NBSP).
- **Sem prancha** (D-21/D-46/D-165/D-166/D-168/D-191): contorno do Laço, Borracha, Reta com encaixe de 15°, anel sem
  ponto, pílulas "Não deu para salvar", "Seleção grande demais…", "A nota está cheia", 2 dedos com batente, rascunho.
- **Veredito: (A).**

### 23 · Ajustes da caneta (G17) — (B) leve

- **Testes:** `l23_test.dart` (`test/support/fase_l23.dart`, 48 ids, 11 textos), `test/golden/leitor_23_test.dart`
  (recorte **só do painel**, y 117–673,63), `pen_panel_test`, `tool_panel_frame_test`, `color_picker_test`.
- **Resultado:** golden 0,21 % (G17.md:385).
- **Diferenças visíveis que ficaram (G17.md "Desvios", não são decisões):**
  - o **"+" das favoritas aparece apagado** (a D-175 apaga quando a cor já é favorita); na prancha ele está **aceso**;
  - o **Desfazer aparece apagado** (o modo acabou de abrir, sem passos); na prancha está **aceso**.
- **Sem pixel contra o PNG:** a pílula, a prateleira e a ilha deste estado ficam fora do recorte do golden.
- **Sem prancha:** painel da Reta (seta em 251, derivado), favoritas até 12 com pressão longa e "Cor tirada das
  favoritas" (D-175), hex digitável com o painel subindo (D-176), Noite (R26).
- **Veredito: (B)** — diferença pequena de estado (dois botões apagados que a prancha mostra acesos).

### 23b · Ajustes do marca-texto (G17) — (B) leve

- **Testes:** `l23b_test.dart` (53 ids + 4), `leitor_23_test.dart` (recorte y 100,86–673,63), `marker_panel_test`,
  `marker_preview_test`, `labels_sheet_test`, `other_color_sheet_test`, `wavy_underline_test`.
- **Resultado:** golden 0,14 %; L23b 5/5.
- **Diferenças:** Desfazer apagado (prancha: aceso) — resíduo; a **tinta antiga fica coral** e na prancha é amarela —
  essa é **decisão aprovada (D-59)**, fica como está salvo se você quiser rever.
- **Sem prancha:** a folha "Rótulos" de "Editar rótulos" (D-177/D-23) e a folha "Outra cor" (D-178). A prévia é gerada
  da página (D-171) e só iguala o arquivo na pág. 159.
- **Veredito: (B)** leve (o Desfazer); a cor coral é exceção aprovada.

### 24 · Abrindo espaço (G18) — (B) leve

- **Testes:** `l24_test.dart` (`test/support/fase_l24.dart`, 18 ids + 7 que mudam da 22, 8 linhas de cima e 14 de
  baixo, chip), `test/golden/leitor_24_test.dart` (recorte y 108–844, **sem a pílula**), `space_opener_test`,
  `hand_note_layout_test`.
- **Resultado:** golden **0,36 %** — o mais perto do limite (G18.md:296–298).
- **Diferenças que ficaram:** Desfazer apagado (prancha: aceso); **os traços do dedo do abridor são diferentes e o
  rastro é um pouco mais curto**; o anel do toque fica escondido (G18.md:358).
- **Veredito: (B)** leve.

### 24b · Nota à mão escrita (G18) — (B) leve

- **Testes:** `l24b_test.dart` (24 ids, tinta ≤ 0,5 px por dentro da borda, dados `space` e `handwriting`),
  `leitor_24_test.dart` (recorte y 108–844), `hand_note_test`, `hand_note_mode_test`.
- **Resultado:** golden **0,37 %**.
- **Diferenças que ficaram:** Desfazer apagado; **a íris do desenho é preenchida em fileiras** (9 a cada 1,5) em vez da
  espiral do SVG, "para o golden" (G18.md:359; `test/fixtures/tinta_do_mundo.dart:336`); a menor caixa da tinta é de
  3 linhas (G18.md:360).
- **Sem prancha:** faixa recolhida e "Abrir a nota" (D-184), "Nota apagada · Desfazer" (D-185), alça com limite
  (D-186), nota vazia descartada (D-188), "A nota está cheia" (D-191), leitor limpo com a nota sem botões (D-183).
- **Veredito: (B)** leve.

**Comum às 22–24b:** não há prancha do tema Noite para nenhuma delas — todo o Noite do modo anotação é derivado
(D-167, R26, R14, D-174, D-180, D-190) e só foi conferido por testes de pixel e a olho. Pendência de aparelho: latência
do traço (G16) e a costura de 1 px dos cruzamentos do Marca-texto no Noite (G18.md:410–413).

### 25 · Grifos e notas (G19) — fiel, com exceção aprovada

- **Prancha:** `handoff_v2/referencia/original/Redesign mobile — App de leitura (1).html` › "25 · Grifos e notas
  (Dom Casmurro)", 390 × 2170.
- **Testes:** `test/features/highlights/presentation/l25a_test.dart` (topo, 11 ids), `l25b_test.dart` (filtros,
  22 ids), `l25c_test.dart` (lista), `l25d_test.dart` (fim e vazios) com `test/support/fase_l25.dart`;
  `test/golden/leitor_25_test.dart` (390 × 2170 @3x). Resultado: 163/163 ids.
- **Visual (refeito agora sobre o golden do repositório):** L25a 0,27 %, L25b 0,00 %, **L25c 0,96 %**, L25d 0,01 %.
- **Diferenças aceitas:** a L25c passa do gate de 0,5 % por causa das miniaturas de tinta, que saem dos traços salvos e
  não do `<svg>` do arquivo — **D-204** (0,0000 % sem as 4 caixas, `tools/medicao/g19/golden_sem_tinta.py`);
  datas sem "ontem" (D-205); o golden termina em 2170, então o botão "Continuar lendo" nunca foi comparado em pixel
  (D-56).
- **Sem prancha dentro da tela** (vão para a §5.2): folhas "Mais opções" e "Exportar" (com "PDF com desenhos · PRO"
  mostrando "Chega numa próxima fase"), vazios (D-198), "sem lugar" (D-199), o × da busca (D-203), e as folhas da G21
  ("Antes de publicar", "Compartilhar em…", "Já está em Leitoras de Capitu").
- **Veredito: (A)**, com a exceção D-204.

### 27 · Sumário, aba Capítulos (G15) — fiel

- **Testes:** `test/features/reader/presentation/l27_test.dart` (`test/support/fase_l27.dart`: 131 ids, texto,
  estilo, semântica, dados); `test/golden/leitor_27_test.dart`. RELATORIO_G15: 5/5, golden 0,0 % (raw 0,72 %);
  refeito agora: 0,0 % (o golden foi regenerado na G20 por 18 px de antialias de um ícone).
- **Diferenças aceitas (sem prancha ou regra):** partes do livro (D-153, mínimo D-21), "Este livro não tem sumário."
  (D-21), sumário no tema Noite derivado das ilhas (D-154 — a 26b não desenha o sumário), numerais do livro
  (D-150/D-155–D-157), "1 marca" (D-51c), rótulos do leitor de tela (D-158). A seta da faixa do clube ainda mostra
  "Chega numa próxima fase" (`reader_screen.dart:1801`) — espera a 31 (T05).
- **Veredito: (A).**

### 27b · Sumário, aba Marcadas (G15) — fiel

- **Testes:** `l27b_test.dart` (`faseL27(marcadas: true)`, 53 ids); `test/golden/leitor_27b_test.dart`. Golden 0,0 %
  (raw 0,94 %).
- **Diferenças aceitas:** fita tirada só no contorno até a folha fechar (D-152), rótulo "Abrir na página N" (D-158),
  dica no Noite com fita vazia (D-154).
- **Veredito: (A).**

### Efeitos da G20 e da G21 sobre as telas A

- **G20:** nenhuma mudança visual deliberada; alvos de toque crescem por dentro (`TapTarget`), o golden da 27 foi
  regenerado e continua 0,0 % contra a prancha. Pendência aberta: a lista de contraste medida a pedido (D-208) —
  #8A8073 sobre #FFFAF1 = 3,73:1, #A89D8B no rodapé = 2,36–2,57:1 — as cores seguem o arquivo.
- **G21:** o caminho "com os dados do arquivo" da 25 não mudou (o golden não muda desde `0846e64`); o ticket do clube
  da Início (`book_club_ticket.dart`) e a faixa da 27 não foram tocados — só a fonte de dados. O ticket com dados reais
  foi conferido só por captura (g21_02), não por golden.

## 4. (B) Telas com prancha que estão diferentes ou faltam

### 4.1 Início nova — arquivo `Redesign_mobile___App_de_leitura__1_.html`

#### 01 · Início (Home), 390 × 2650 — rota `/inicio` existe, mas é a Início da v1 (390 × 2390)

Diferenças concretas (01 nova × app):

| Área | No app (v1) | Na prancha 01 |
|---|---|---|
| Cabeçalho | só o sininho à direita | **botão de busca** (círculo com lupa) à esquerda do sininho |
| Herói — capa | Dom Casmurro roxo com sol amarelo | **arte nova**: céu noturno com lua e estrelas, título em amarelo, o **olho** e o **mar** em ondas embaixo |
| Herói — pílula | "Cap. 92 de 148" | **"pág. 159 de 256"** |
| Herói — selo | — | pílula amarela **"E-BOOK"** (formato do livro) colada à estrela |
| Herói — contador do lápis | 14 | **12** |
| Também lendo — contador | 2 | **3** |
| Também lendo — 1º cartão | Mrs. Dalloway, anel 34 % | **Brás Cubas** (capa azul com cartola), **botão redondo preto com "play"** amarelo no lugar do anel (livro de papel: começa o cronômetro) |
| Também lendo — linha extra | — | pílula com ícone de livro: **"Papel · 3h 40min"** e **"Papel · pág. 344"** (os cartões ficam mais altos) |
| Seu dia de leitura | chips "24 páginas" e "2 destaques" à direita do dial | texto da meta + **botão preto "Ler agora"** (ícone de cronômetro); chips **"2 sessões"** e "2 destaques" embaixo; o cartão cresce |
| **Seção nova** | — | cartão **"REVISÃO · 5 GRIFOS · 2 MIN / Seus grifos *de hoje* / De Dom Casmurro, Quincas Borba e Iracema. / ✦ Revisar"**, com a ilustração de cartões e estrela, entre o Dia de leitura e o Para você |
| Para você | Memórias Póstumas de Brás Cubas, Quincas Borba, O Cortiço | **Esaú e Jacó, Memorial de Aires, Casa de Pensão** (mesmos modelos de capa) |
| Clube (ticket) | "Dom Casmurro · até o cap. 100" | **"até o cap. 50"** (igual ao leitor e ao clube) |
| Recém-chegados | O Alienista "Quero ler"; Senhora "José de Alencar · EPUB" | O Alienista com pílula **verde "Lido"** (estilo novo); Senhora **"· Papel"** |
| Barra de navegação | — | igual |
| Fontes | Figtree 800 → 700 (D-14) | o arquivo também só declara Figtree até 700 → a D-14 continua valendo |

A 01 nova **acaba com as divergências da D-60/Q25** (cap. 92 × XXXII, cap. 100 × L, 14 × 12): ela usa os números do
leitor e do clube. Em compensação, o texto dela diverge da 01b (o Para você da 01b mostra Esaú e Jacó, Quincas Borba
e O Cortiço) — cada prancha tem os próprios valores, como a D-60 já prevê.

#### 01b · Início — lendo agora (cronômetro ativo), 390 × 844 — não existe no app

A mesma Início com uma sessão de cronômetro rodando num livro de papel:
- **mini-barra escura acima da barra de navegação** (comentário do arquivo: "mini bar while a timer session runs (tap
  opens the timer)"): capa pequena de Brás Cubas (cartola com asas), "● LENDO · PAPEL", "Brás Cubas", **"08:42"**,
  botão redondo de pausa;
- o cartão de Brás Cubas em "Também lendo" troca o "play" por **pausa com anel coral**;
- o cartão "Seus grifos de hoje" não aparece nesta prancha.
- A **tela do cronômetro** que o toque abre **não tem prancha** (§5.2).

#### 60 · Início — grifos de hoje (revisão), 390 × 844 — não existe no app

É a Início rolada até o cartão "Seus grifos de hoje" (mesmo conteúdo da 01, viewport 844 com a barra fixa). Serve de
referência do cartão em viewport; não é uma tela nova.

#### 61 · Revisão — grifo 2 de 5, 390 × 844 — não existe no app

Tela cheia nova: × para fechar, título "Revisão *de hoje*", "2 de 5", barra de 5 segmentos (1 cheio, 1 em progresso),
**baralho de cartões** (os próximos aparecem atrás, em lavanda e verde), cartão com "Dom Casmurro · pág. 6", etiqueta
"personagem", trecho em Literata 22 com fundo do grifo rosa, post-it amarelo "NOTA / É o livro todo nessa frase.",
"Você grifou há 17 dias" / "revisto 1 vez", "deslize o cartão para o próximo"; botões "− Menos vezes", "+ Mais vezes",
lápis (editar nota), compartilhar e **"Próximo →"**.

#### 62 · Revisão — fim, 390 × 844 — não existe no app

"5 de 5", 5 cartões com ✓, **"Revisão *feita.*"**, pílula "✦ 7 dias seguidos revisando", três caixas ("2 mais
vezes", "1 menos vezes", "1 nota nova" em amarelo), cartão do grifo com "NOTA NOVA · HOJE", caixa tracejada
"Amanhã, 8h: mais 5, com "A vida é uma ópera" de volta — você pediu mais vezes.", **"Voltar a ler · pág. 159"** e o
link "Mudar horário e quantidade" (a folha que ele abre não tem prancha).

#### 63 · Revisão — imagem para compartilhar, 390 × 844 — não existe no app

Folha escura "Compartilhar *grifo*" com ×: cartão rosa com aspas, o trecho em Instrument Serif itálico, "Dom
Casmurro / Machado de Assis · pág. 6", "grifado por @marinacosta", "BookNest"; 6 bolinhas de cor (branco, amarelo,
rosa ativo, verde, lavanda, preto); interruptores "Mostrar minha nota" (desligado) e "Mostrar meu @" (ligado); ações
"Salvar", "Stories", "Copiar texto", "Mais".

### 4.2 Clube — arquivo `Redesign_mobile___App_de_leitura_2.html`

Todas as 16 usam Figtree 800 **real** (o arquivo declara 800, como a D-16 do leitor) e Literata em 31–50/70–73.
As pranchas 04, 102 e 104 usam Instrument Serif itálico em 600 e 800, que o arquivo só declara em 400: é **negrito
sintético do Chromium** — armadilha para a medição.

| Prancha | Canvas | No app | O que a prancha tem (diferença = a tela inteira) |
|---|---|---|---|
| **04** · Clube — Leitoras de Capitu | 390 × 2430 | `/clubes` = `PlaceholderScreen('Clubes')` | É a **aba Clubes**: título "Seus *clubes.*" com "+"; seletor de clubes (Leitoras de Capitu com 3, Sci-fi às quartas, Poesia de domingo); herói rosa (11 leitoras, Clássicos brasileiros, "LENDO JUNTAS · SEMANA 2 DE 6", meta "até o cap. 50 na quinta"); "Onde cada uma está" (trilho de 256 páginas, contas das leitoras, bandeira "cap. 50 · qui", "Grupo 54% · Você 62%", "Atualizar"); ticket do próximo encontro com Vou/Talvez/Não vou; "Discussões" sem spoiler (semanas 1–6, a 2 em destaque com a pergunta da semana e "Responder", 3–6 trancadas); cartão "Próximo *livro*" (enquete com 3 opções, "Seu voto", "Mudar meu voto", "Faltam 2 votos"); grifo compartilhado ("7 leitoras grifaram", ♥ 9, 💬 4); barra de navegação com Clubes ativo |
| **31** · Discussão da semana (sem spoiler) | 390 × 1330 | `/clube/:clubId/discussao` = placeholder | topo "Semana 2 · caps. 26–50 / Leitoras de Capitu" com ⋯; cartão da pergunta da semana ("12 respostas · 3 novas", "sem spoiler"); aviso do borrado; abas "Mais curtidas / Mais recentes"; respostas com avatar, anfitriã/você, hora, citação do livro com página, curtidas, "N respostas", "Responder"; **resposta borrada** "Fala da pág. 201 · você está na 159" com "Mostrar mesmo assim"; compositor "Responder à pergunta…" |
| **32** · Membros e onde cada uma está | 390 × 1190 | não existe | "Convidar"; "11 leitoras *de Capitu.*"; cartão do encontro (8 vão · 3 talvez); ordenação "Mais à frente / Nome / Presença"; 11 linhas com barra de progresso, % e pílula vai/talvez; "você"; aviso de privacidade; "Sair do clube" |
| **33** · Criar clube | 390 × 1560 | não existe | "Criar *um clube.*" com selo ao vivo; nome (17/40); cores do clube por elemento (selo, cartão e convite, barras — "Uma cor para todas / Cada uma escolhe") com prévia ao vivo; primeiro livro com "Trocar"; dividir em 4/6/8 semanas; dias e hora dos encontros, online/presencial; "Só com convite / Aberto"; proteção contra spoiler; "Criar e convidar" |
| **34** · Clube criado — convite (link e QR) | 390 × 1030 | não existe | "Clube criado! *Agora, chame gente.*"; cartão-convite (amarelo, recortes) com **QR** e o selo; link `booknest.app/c/poesia-de-domingo` + "Copiar"; validade (7 dias, 12 pessoas); "Compartilhar", "Mostrar QR"; "Quem você segue" com Convidar/Convidada |
| **47** · Enquete — criar | 390 × 1210 | não existe | "Nova enquete"; "Qual vai ser o *próximo livro?*"; "Cada uma indica / Eu escolho"; indicações por pessoa (−/+); prazos (linha do tempo indicação → votação → resultado, 3 + 6 dias); 4 regras com interruptores; "Abrir enquete" |
| **48** · Enquete — indicar um livro | 390 × 844 | não existe | folha sobre a enquete em fase de indicação; busca "Título, autor ou ISBN" com botão do scanner; "DA SUA ESTANTE" (3 livros, um "já indicado"); "Por que ler? (opcional)" 84/140; "Indicar Memórias Póstumas". **A tela da enquete em fase de indicação aparece só esmaecida por baixo da folha** — não tem prancha própria |
| **49** · Enquete — votar | 390 × 1110 | não existe | "Próximo *livro*", "8 de 11 votaram", "fecha ter, 20h", aviso "os números aparecem depois do seu voto"; 3 cartões de livro com quem indicou e o porquê ("Na sua estante · Lendo", "Você leu · 4,5 ★"); "Votar em Memórias Póstumas" |
| **50** · Enquete — resultado | 390 × 1150 | não existe | "ENQUETE FECHADA · 11 DE 11"; capa com carimbo "ESCOLHIDO"; começa/ritmo/encontro; "Como você vai ler?" (Já tenho / Vou arranjar / E-book); contagem final com avatares; "Pôr na minha agenda" |
| **70** · Encontro — detalhe | 390 × 2070 | não existe | "Quinta tem *encontro.*"; ticket grande ("ENCONTRO 2 DE 6", 24 QUI SET 20h, pauta, anfitriã, "ADMITE 1 LEITORA · Marina · Nº 0052", carimbo VOU); Vou/Talvez/Não vou; "Mandar um recado para a Ana"; "Sua leitura até quinta" com trilho e "Continuar na pág. 159"; chamada do clube (abre 15 min antes) e lembretes com "Ajustar"; perguntas na ordem da anfitriã com "Sugerir uma pergunta"; "Quem vai" (vão/talvez/não vão) e "Ver as 11 leitoras" |
| **71** · Encontro — na hora (sala aberta) | 390 × 990 | não existe | "A sala *está aberta.*"; contador "13 MIN", "SALA ABERTA DESDE 19H45", quem já está na sala, "Entrar na chamada"; meta da semana cumprida; perguntas à mão; "Vou atrasar uns minutos" / "Não vou conseguir" |
| **72** · Encontro — mudar presença com recado | 390 × 844 | não existe | folha sobre a 70: "Você vai *na quinta?*", Vou/Talvez/Não vou, recado para a Ana (63/140), "Só a Ana / O clube todo", "Com a mudança: 7 vão · 4 talvez", "Salvar resposta" |
| **73** · Encontro — depois (resumo) | 390 × 1450 | não existe | "Encontro *encerrado.*"; ticket sem canhoto com carimbo FUI, 9 leitoras, duração 1h32; "O canhoto foi para a sua carteirinha · 2 de 6"; quem foi; o que conversamos (Conversada / Ficou para a semana 3, anotação da anfitriã); "Semana que vem" com o ticket pequeno |
| **102** · Quem votou (enquete aberta, da 04) | 390 × 844 | não existe | folha sobre a 04: "Quem votou *em cada livro.*", "9 de 11 votaram", abas por livro com contagem, lista com hora do voto, "Faltam Dani e Fê" |
| **103** · Quem votou (resultado, da 50) | 390 × 844 | não existe | folha sobre a 50: mesmo formato, "VENCEU", 11 de 11 |
| **104** · Voto secreto (variação) | 390 × 844 | não existe | folha sobre a 04 com o carimbo "SECRETO" e "Ninguém vê quem votou em quê, nem a anfitriã. Só os números." |

Dados que já existem no servidor para elas (G21): `club_overview` (04), `week_thread` (31),
`club_members_overview` (32), `meeting_overview` (70, 72, 73), `set_rsvp`, recado (`meeting_notes`), perguntas,
curtidas, cores, spoiler por página (D-218), `create_club` e `create_invite` (33–34, sem a tela, o link nem o link
profundo). **Não existem:** enquetes (47–50, 102–104), a sala da chamada e quem está nela (71), a duração e quem foi
(73), a carteirinha e o canhoto (D-211 adiou tudo isso "para quando as telas vierem").

## 5. (C) Sem prancha em nenhum HTML

### 5.1 Telas com rota

| Rota | Hoje no app | Decisão que permite | O que o design precisa desenhar |
|---|---|---|---|
| `/biblioteca` | `PlaceholderScreen('Biblioteca')` + bloco de importar (G09) | D-07, D-87, D-21 | a estante (lista/grade, filtros por estado e formato, ordenar), importar EPUB/PDF, vazia |
| `/perfil` | `PlaceholderScreen('Perfil')` + bloco da conta (G05/G06/G22) | D-69, D-21, D-231 | o perfil (nome, @, estatísticas publicadas, seguidores), a conta (exportar, sair, excluir + confirmações), o Pro (plano, restaurar, gerenciar), a sincronização |
| `/scanner` | `ScannerScreen` provisória (câmera num cartão, pílulas, cartão de resultado) | D-76 | câmera e todos os estados de `estados_sem_design.md` §G07 (achou, já na estante, não achou + sugestão da comunidade + adicionar à mão + ler a capa, digitar ISBN, sem permissão, sem rede/limite) |
| `/notificacoes` | placeholder | D-07, D-212 | a lista (respostas do clube, seguidores e pedidos, encontros, enquetes), vazia |
| `/livro/:bookId` | placeholder | D-07 | o detalhe do livro (capa, dados, progresso, abrir o leitor, grifos, "Guardar na nuvem"/"Baixar" do Pro — G06) |
| `/para-voce` | placeholder | D-07 | "Ver tudo" do Para você |
| `/entrar` | `SignInScreen` (primitivos D-21) | D-21, D-64…D-69 | método (e-mail, Google, Apple), código de 6 dígitos, idade (data de nascimento, menor de 13, verificação da loja) |
| `/conta/cadastro` | `OnboardingScreen` (D-21) | D-21 | escolher o @, faixa etária, menor de 13 com conta |
| `/_pro` (só depuração) | `ProTechScreen`, paywall de trabalho | D-230, D-231 | o paywall: planos mensal/anual com preço da loja, teste grátis de 7 dias, textos obrigatórios das lojas, termos e privacidade, restaurar. Sem ele, o build de produção não vende (D-230) |

### 5.2 Folhas, estados e destinos sem prancha

**Ligados às telas (B)** — o elemento que abre está na prancha; o destino não:
- 01: a **busca** (lupa do cabeçalho).
- 01b: a **tela do cronômetro** (toque na mini-barra) e o **fim da sessão de papel** (onde se registra a página — a
  01 mostra "Papel · pág. 344", então alguém digita a página).
- 62: **"Mudar horário e quantidade"** da revisão.
- 61: o **editor da nota** pelo lápis (o leitor tem o editor mínimo D-23).
- 04: a aba Clubes **sem nenhum clube** (entrar/criar) e o menu ⋯ do herói.
- 31: o menu ⋯ (denunciar, bloquear — D-52).
- 32: a confirmação de **"Sair do clube"**.
- 33: o **"Trocar"** do primeiro livro (escolher o livro).
- 34/convite: a tela de quem **abre o link** `booknest.app/c/…` (entrar no clube).
- 70: **"Sugerir uma pergunta"**, **"Ajustar"** os lembretes, o menu ⋯ e o ícone de calendário.
- 71: **"Vou atrasar uns minutos"** e **"Não vou conseguir"** (se abrem algo).
- 73: a **carteirinha** e o canhoto.

**Já no app, por decisão** (a implementação segue as decisões; o design ainda não desenhou):
- Leitor: "Abrindo/Preparando o livro…" e os erros (D-21/D-113/D-123), "← Voltar à pág. N" (D-108), busca no livro
  (D-23/D-120), Tema que alterna (D-37/D-121), folha da nota (D-131/D-23), "Outra cor" (D-178/D-38), lupa (D-135),
  barra do grifo existente (D-132/D-137), pílulas "Trecho copiado"/"Grifo apagado · Desfazer" (D-136/D-139), Sublinhar
  (D-130), folha "Rótulos" (D-177), favoritas e hex (D-175/D-176), Laço/Borracha/Reta e suas pílulas
  (D-46/D-168/D-191), nota à mão recolhida e apagada (D-183–D-188), todo o tema Noite que não é a 26b
  (D-110/D-143/D-154/D-167/D-174/D-180/D-190).
- 25: folhas "Mais opções" e "Exportar" (D-23/D-192/D-194, padrão da folha da nota D-131), vazios (D-198), "sem
  lugar" (D-199), pílulas de aviso; da G21: "Antes de publicar" (regras provisórias até a G25), "Compartilhar em…",
  "Já está em Leitoras de Capitu" (D-222).
- 27: partes do livro (D-153), "Este livro não tem sumário." (D-21), sumário no Noite (D-154).
- Início: estante vazia, nada em leitura, convidado, meta batida, selo, livro sem foto, carregando, erro
  (D-78…D-85, `home_states.dart`).
- Conta, sincronização, Pro no Perfil, importar: tudo de `estados_sem_design.md` §G05, §G06, §G09, §G22.

> `docs/design/estados_sem_design.md` só lista G05–G09, G21 e G22. Nada do leitor (G11–G20) está lá: as folhas e
> estados acima estão só nos G1x.md e não chegam à lista que vai para o design.

## 6. O que exportar do Claude Design

Os números das pranchas são os do seu projeto no Claude Design (os arquivos já trazem 01, 04, 31…104, então a
numeração não é mais "01–18"). Abaixo, o **nome** que cada prancha deveria ter (no padrão "NN · Tela — estado") e quem
espera por ela. Onde a tela ainda não existe no projeto, ela precisa ser desenhada antes de exportar.

**Telas inteiras (bloqueiam fases):**

| # | Nome sugerido da prancha | Rota / quem usa |
|---|---|---|
| C1 | `NN · Biblioteca — estante` (+ `— vazia`) | `/biblioteca` |
| C2 | `NN · Livro — detalhe` | `/livro/:bookId` (e "Biblioteca →", capas) |
| C3 | `NN · Para você — ver tudo` | `/para-voce` |
| C4 | `NN · Perfil` (o seu) | `/perfil` |
| C5 | `NN · Perfil — de outra pessoa` (prévia do Grátis e completo do Pro, seguir/pedido) | social da G21, gatilho do paywall |
| C6 | `NN · Conta e ajustes` (exportar, sair, excluir + confirmações, Pro, sincronização) | bloco da conta do Perfil |
| C7 | `NN · Notificações` (+ `— vazia`) | `/notificacoes`, G23 |
| C8 | `NN · Scanner` + estados (`— achou`, `— já na estante`, `— não achou`, `— digitar ISBN`, `— sem câmera`) | `/scanner` |
| C9 | `NN · Entrar ou criar conta` + `— código` + `— idade` | `/entrar` |
| C10 | `NN · Concluir cadastro — escolher o @` | `/conta/cadastro` |
| C11 | `NN · Boas-vindas — seus dados só neste celular` (onboarding) | Anexo 01 §15 |
| C12 | `NN · Assinatura — Pro` (paywall) + `— assinante` | `/_pro` → produção (D-230) |
| C13 | `NN · Clubes — sem clube` | aba Clubes (04) para quem não tem clube |
| C14 | `NN · Busca` | lupa da 01 |
| C15 | `NN · Cronômetro de leitura` + `— fim da sessão (página do papel)` | toque na mini-barra da 01b |
| C16 | `NN · Convite — entrar no clube` (quem abre o link/QR) | 34 |

**Folhas e estados (bloqueiam só o elemento):**

| # | Nome sugerido | Onde |
|---|---|---|
| C17 | `NN · Revisão — horário e quantidade` | 62 |
| C18 | `NN · Encontro — sugerir pergunta` e `NN · Encontro — lembretes` | 70 |
| C19 | `NN · Carteirinha de leitora` | 73 |
| C20 | `NN · Clube — menu, denunciar e bloquear` (+ `— sair do clube`) | 04, 31, 32 |
| C21 | `NN · Clube — escolher livro` | "Trocar" da 33 (talvez reaproveitar a 48) |
| C22 | `NN · Enquete — indicações abertas` (a tela que fica atrás da 48) | 47 → 48 |
| C23 | `NN · Leitor — busca no livro`, `— nota`, `— outra cor`, `— rótulos` | leitor (hoje D-23/D-38) |
| C24 | `NN · Grifos — mais opções`, `— exportar`, `— compartilhar no clube`, `— antes de publicar` | 25 (hoje D-23/D-222) |
| C25 | `NN · Estados — carregando / vazio / erro / sem conexão` (um padrão para o app todo) | D-21 em todas as telas |

Exporte no mesmo formato dos dois arquivos de `docs/design/referencia/` (o HTML do Claude Design com as pranchas),
como um arquivo novo — por exemplo `Redesign_mobile___App_de_leitura_3.html` —, sem substituir os que já estão lá.
