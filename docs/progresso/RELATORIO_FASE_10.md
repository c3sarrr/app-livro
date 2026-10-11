## Relatório — FASE 10: Seção 8 — "Recém-chegados" (lista com mini-capas e flex-shrink do CSS)

### Entregue
- **Algoritmo:** `lib/features/home/application/css_flex.dart` — `resolveTextAndTag` (CSS Flexbox §9.7, exatamente o da fase, mais um piso de 0
  no texto para linhas estreitas demais) e as medidas intrínsecas `measure` (max-content) e `longestWord` (min-content), feitas com
  `ui.Paragraph` e os mesmos estilos do `AppText`, sem arredondar.
- **Mini-capas** (`presentation/covers/`), todas 44 × 66, borda 1,2, raio 3/7/7/3, recorte na padding box:
  - `frankenstein_mini_cover.dart` — fundo tinta, lua 22 e barra 27,6 × 3 em `#B6ACE4`;
  - `o_alienista_mini_cover.dart` — lavanda, lombada 4, anel 20 e ponto 8;
  - `senhora_mini_cover.dart` — âmbar, lombada 4 e arco vazado 23,6 × 26 sem a borda de baixo (`ArchBorderPainter`: faixa em "U" num
    caminho só; raios 13 → 11,8, como o CSS reduz quando os dois de cima somam mais que a largura).
- **Seção:** `presentation/sections/recently_added_section.dart` (`RecentlyAddedSection`, com `onBookTap`, `onMoreTap` e `onLibraryTap`
  para a F12):
  - `Semantics(seção "Adicionados recentemente")` > `Column(recent, gap 10)` [cabeçalho 44, `NeoBox(recent.list)`];
  - lista = `#FFFAF1`, raio 24, padding 14/4/8/4, sem borda/sombra/recorte, com 3 linhas;
  - linha = `LayoutBuilder` → `Container` (padding 12, `border-bottom` 1 `#E9E1D2` nas linhas 0 e 1) > `Row(center, gap 14)` [capa,
    `SizedBox(w.text)` > `Pressable(link)` > coluna título + subtítulo, `SizedBox(w.tag)` > `Pill(5/10)`, `CircleIconButton(44)`];
  - nada de `Expanded`/`Flexible`: as larguras vêm de `resolveTextAndTag`.
- **Tela:** em `home_screen.dart` o placeholder de `recent` virou `RecentlyAddedSection()` (o `_Placeholder` deixou de ser usado e foi
  removido; nenhuma seção é mais placeholder).
- **Testes (39 novos):** `test/home/css_flex_test.dart` (11), `geometry_recent_test.dart` (9), `text_recent_test.dart` (5),
  `style_recent_test.dart` (10), `semantics_recent_test.dart` (4). Nenhum teste de fase aprovada foi alterado.
- **Golden:** `test/golden/goldens/inicio_canvas@3x.png` regenerado, agora com a seção.
- **Documentação:** `docs/progresso/FASE_10.md`, `F10_verificacao.txt`, `F10_comparacao.md` e este relatório.
- **Evidências** em `build/visual_diff/F10/`: lado a lado, heatmap, onion, `F10_recem_chegados_secao_golden_redline.png`, 4 recortes
  ampliados, `todas/`, `nao_regressao/` e `golden_F09_aprovado.png`. A sonda 360/430 foi temporária, fora de `test/`, e já removida.

### Checklist (100%)
- [x] 10.1 Cabeçalho 44 com "Recém-chegados" 24 ls −0,6 e link "Biblioteca" + seta
  - Título 195,506 × 28,8 em y + 7,6 (arquivo 195,47); link 86,19 × 44; seta 18; baselines Δ 0,000.
- [x] 10.2 Lista `#FFFAF1` raio 24 padding 4/8/4/14, sem borda/sombra; alturas de linha 91/91/90; divisores 1 px `#E9E1D2`
  - Lista 350 × 280 = 4 + 91 + 91 + 90 + 4; divisor de x = 14 a 342 (34→362), só nas linhas 0 e 1; pixels exatos.
- [x] 10.3 Frankenstein, O Alienista e Senhora (capas, lombadas, anel, ponto, arco sem base)
  - Todas as posições da tabela; arco da Senhora: pernas e topo em tinta, miolo e base em âmbar (pixels exatos).
- [x] 10.4 `resolveTextAndTag` + 3 testes da tabela verdes
  - 126,54/71,46 · 129,83/68,17 · 148,56/49,44 (±0,05) com os valores do arquivo e com as medidas reais das fontes.
- [x] 10.5 Linha 2 reproduz o arquivo: subtítulo em 2 linhas e selo "Quero"/"ler" 68,17×38,8 centralizado
  - "Machado de Assis ·" / "PDF" e "Quero" / "ler"; texto 129,83, selo 68,17 × 38,8, centralizado na altura da capa.
- [x] 10.5 Selos: "Quero ler" `#ECE7FA`/`#3B2D86`, "Novo" `#EFE7D7`/`#4A4238`
  - Sem borda, raio 999, padding 5 10, Figtree 12/700; pixels dos fundos exatos.
- [x] 10.6 Botões 44×44 transparentes com ícone 20 e semântica
  - 44 sem fundo/borda, ícone 20 (3 círculos r 1,8); rótulos "Mais opções para Frankenstein / O Alienista / Senhora".
- [x] Geometria 37/37 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK — números abaixo.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes: 0 mudanças · No issues found! · +421: All tests passed!
- [x] Relatório com lado-a-lado e heatmap inspecionados — `F10_comparacao.md`.

### Verificação
- **Geometria:** 37/37 ids dentro da tolerância; maior desvio `recent.title.w` = 0,036 px. A tabela da especificação (37 linhas,
  relativa à seção) bate com o Flutter a ≤ 0,05. Numa sonda nas larguras 360 e 430 (validação formal é da F13), os 37 ids também
  batem com `reference_layout_w360/w430` (maior desvio 0,0364).
- **Estilo:** 10 testes, sem tolerância nas cores, bordas e pixels:
  - decorações da lista, das linhas, das capas, dos selos e do botão; tipografia dos 11 textos (Bricolage24 24/800/1,2 ls −0,6,
    Figtree 14/700, 15/700, 13/500 `#5B544B`, 12/700 `#3B2D86` e `#4A4238`);
  - canvas gravado (`TestRecordingPaintingContext`): só 3 recortes, todos suavizados e na padding box de cada capa (1,8/5,8/5,8/1,8);
    nenhum `saveLayer`; a sequência completa de formas na ordem do arquivo (lista → divisor → capa → selo, por linha);
  - 40 pontos de pixel @3x exatos (lista e cantos, divisores e suas pontas, capas e filhos, arco aberto embaixo, selos, os três pontos do
    botão, sem sombra).
- **Visual** (`compare_images.py`):

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | F10_recem_chegados (16, 1873, 358, 351) | 0,0 | 0,891 | 0,973 | 189 | PASSOU |
  | recent (`--layout`) | 0,0 | 0,8938 | 0,976 | 189 | PASSOU |
  | header / headline / hero / alsoReading / today / forYou / club (`--layout`) | 0,0 | 0,4113 / 1,3126 / 0,6195 / 0,8922 / 1,3001 / 2,1986 / 2,2549 | — | 142 / 221 / 128 / 189 / 228 / 229 / 229 | PASSOU (= F09) |
  | acima da seção (0, 0, 390, 1873) × golden aprovado da F09 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |
  | abaixo da seção (0, 2224, 390, 166) × golden aprovado da F09 | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

  `bottomFade` e `nav` aparecem como FALHOU no modo `--layout` por definição: são da F11 e ainda não existem. Os 897.810 pixels
  alterados em relação ao golden da F09 estão todos na faixa da seção (x 20–370, y 1892,7–2215,3).

  O que sobra é rasterização (análise completa em `F10_comparacao.md`): 6.905 pixels > 64 (0,66 % da faixa), concentrados no título
  e nos glifos (hinting de Bricolage 24 / Figtree a 3×: o mesmo −1 px físico que "Para você" já tinha), nas arestas das capas
  (deriva de +0,1 a +0,2 px da própria referência) e na suavização das curvas. Recortes ampliados do arco, do anel/ponto, do selo
  "Quero"/"ler" e das capas: forma, cor e ordem de pintura idênticas.
- **Texto:** 11 textos, 13 linhas: strings e quebras exatas; baselines Δ 0,000; inícios e fins Δ ≤ 0,042 (`row0.subtitle` fim).
  O algoritmo vem dos dados: com "Quero ler" na linha da Senhora, texto e selo encolhem em proporção (128,97 / 69,03) e quebram,
  e o Frankenstein com "Novo" deixa de quebrar (provado com outro `RecentItem` via override do provider).
- **Semântica e toques:** seção "Adicionados recentemente" com 11 nós na ordem do documento (h3 nível 3 "Recém-chegados", link
  "Biblioteca", e por linha o link com título + subtítulo, o selo e o botão "Mais opções para …"); capas, ícones e divisores fora da
  árvore. A travessia do leitor de tela coincide com a ordem do documento (nenhuma inversão nesta seção). Os callbacks
  (`onBookTap`, `onMoreTap`, `onLibraryTap`) disparam só nos próprios alvos, por toque e por ação semântica; sem callbacks nada tem ação.
- **Qualidade:** flutter analyze com 0 problemas · dart format ok (114 arquivos, 0 mudanças) · flutter test com 421 passando ·
  `design_handoff/` intacto.
- **Estabilidade:** 3 execuções completas da suíte (`+420` ×2 e a final `+421`), nenhuma "did not complete".

### Autorrevisão (§8)
Conferi o `secoes/F10@3x`, o redline e o golden lado a lado, percorrendo a tabela linha a linha. Achado e corrigido nesta fase:
- **Linha estreita demais:** com `available` muito pequeno, o texto podia sair negativo e um `SizedBox` com largura negativa quebraria
  em debug. O CSS trata isso como `min-width: 0`; agora `resolveTextAndTag` devolve no mínimo 0 (com os dados do arquivo nada muda;
  teste novo no `css_flex_test.dart`). A fase não pediu revisores independentes; esta foi uma revisão minha, não de terceiros.

### Decisões fora do arquivo usadas nesta fase
- Nenhuma decisão D-xx nova. Usadas: D-04 (links e botões com `Pressable`, sem ripple), D-09 (dados do mock), D-12 (a linha "O Alienista"
  reproduz o arquivo: autor em 2 linhas e selo "Quero"/"ler"; não corrigido) e D-15 (rótulos = `aria-label` do arquivo).
- Detalhes da construção que vão além do trecho da fase, todos neutros ou mais fiéis ao CSS:
  - as mini-capas recebem o prefixo da Key (`id`) e a Key `recent.rowN.cover` fica no `NeoBox` da própria arte, em vez de
    `MiniCover(key: …)`: evita duas widgets com a mesma Key e mantém as Keys corretas se a ordem dos dados mudar;
  - `Stack(clipBehavior: Clip.none)` dentro das capas: o único recorte é o do `NeoBox`, suavizado (como nas capas da F08);
  - `ArchBorderPainter` em vez de `BoxDecoration` para o arco, porque o Flutter não pinta `borderRadius` com bordas de lados diferentes;
  - os helpers `measure`/`longestWord` ficam em `css_flex.dart`, junto do algoritmo.

### Riscos/pendências
- Nenhum.
- Observação de processo: o `flutter test --update-goldens …` (passo 1 do §7) foi negado pelo classificador de permissões do ambiente
  na primeira tentativa; ele não foi repetido nem contornado, e o próprio usuário o executou e liberou a continuação. O golden
  aprovado da F09, usado na não-regressão, foi recuperado do git (`HEAD`).

✅ FASE 10 concluída — aguardando sua aprovação para iniciar a FASE 11.
