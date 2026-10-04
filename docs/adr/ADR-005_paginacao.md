# ADR-005 — Paginação: motor próprio com `dart:ui`, modelo vertical exato e pintura por linha

- **Status:** aceita pelo spike S3 (G02) · aguarda a aprovação da G02 · muda **2 regras** do Anexo 03 §7.1 (ver "Decisões que mudam")
- **Data:** 03/10/2026
- **Prova:** `spikes/S3_paginacao/` (`dados/resultado_tela19.json`, `dados/resultado_epub_real.json`, `dados/comparacao_*.json`)

## Contexto

A tela 19 exige as **mesmas 19 linhas** do Chromium (Literata 20,5 / entrelinha 1,72 / recuo 1,3 em /
margens 28 / topo 92 / base 82) com baselines ±0,5 px da medição da G01; "pág. 159 de 256" precisa de
páginas de referência estáveis (D-19); o orçamento é paginar um capítulo de 40 páginas em < 120 ms, em
fatias de ≤ 4 ms (Anexo 03 §12).

## Decisão

1. **Motor próprio** (Anexo 03 §7.2): cada bloco do EPUB vira um `ui.Paragraph` com layout uma única vez
   (`computeLineMetrics`); o paginador põe linhas na página até a próxima não caber (tolerância 0,02 px);
   parágrafo partido = o mesmo `Paragraph` pintado de novo com deslocamento e recorte; título não fica
   órfão no pé da página.
2. **Modelo vertical próprio + pintura linha a linha.** O SkParagraph **arredonda a altura de cada linha
   para px inteiro** (`InternalLineMetrics::height() = round(descent − ascent + leading)`): com 35,26 px
   as linhas saem a cada **35,00 px** e a 19ª fica **4,68 px** acima do Chromium. O motor calcula o topo
   exato de cada linha somando `ascent + descent` (que o Flutter informa sem arredondar) e pinta **cada
   linha** com `clipRect` na faixa da linha + `drawParagraph` deslocado (`correcao(l) = baseline exata −
   baseline do SkParagraph`). Seleção, grifos, ondulado e tinta usam o mesmo mapeamento.
3. **Altura de linha exata** (`tamanho × entrelinha` = 35,26), **não** arredondada a 1/64 px: as
   referências do protocolo (geometria a zoom 100, PNGs supersample a zoom 10) mostram passo 35,26; o 35,25
   é artefato do Chromium a zoom 1 (que também gruda o topo do glifo em px inteiro).
4. **Recuo** = `PlaceholderSpan` (1,3 em × 0, alinhado à baseline) → 1 unidade U+FFFC no texto do
   `Paragraph`; um helper único converte offset do parágrafo ↔ offset canônico (`offsetCanonico` /
   `offsetParagrafo`), com teste.
5. **Parágrafos longos** (> ~1.200 caracteres; ajustar no aparelho na G26) têm layout **em pedaços
   costurados na última linha**: cada pedaço descarta a própria última linha e o seguinte recomeça no
   início dela. Como a quebra é gulosa (cada linha só depende de onde começa), as linhas são idênticas
   às do layout inteiro — e cada fatia de tempo fica pequena.
6. **Páginas de referência (D-19): N = 1.500 mantido.** "pág. X" = página do 1º caractere visível.

## Evidências (Flutter 3.47.2 no Windows · `flutter test`, JIT · Ryzen 5 2600X)

**Gate da tela 19** (EPUB de fixture montado no teste com o texto **exato** do arquivo):

| Variante | Linhas iguais | Baseline (máx) | Borda direita (máx) | 19 linhas ocupam |
|---|---|---|---|---|
| **Modelo exato + pintura por linha** (decisão) | **22/22** | **0,0027 px** | 0,0065 px | 669,94 de 670 |
| Altura arredondada a 1/64 (35,25) | 22/22 | 0,188 px | 0,0065 px | 669,75 de 670 |
| SkParagraph sozinho (passo 35,00) | 22/22 | **4,68 px** ✗ | 0,0065 px | 665,26 de 670 |

- Pintura @3x da página × PNG de referência (`tools/compare_images.py`, faixa do texto 0,92–390,762):
  **por linha `blur_mismatch` 0,21 % (passa ≤ 0,5 %)** · SkParagraph inteiro 9,11 % (reprova).
- Fios de navalha da G01: linha 7 estoura com a próxima palavra por **0,7118 px** (Chromium 0,711) e a
  linha 19 por **0,5381 px** (0,538) — a quebra fica igual com folga de ~500× a precisão do Flutter.
- Página 2 do fixture: linhas 20–22 no topo, nas mesmas baselines das linhas 1–3.

**EPUB real** (*Dom Casmurro*, Gutenberg #55752: 5 itens, 2.087 blocos, 394.745 caracteres):

| Tamanho | Páginas | Layout + paginação (livro todo) | ms/página | Capítulo de 40 págs | Bloco mais caro |
|---|---|---|---|---|---|
| 16 | 454 | 443 ms | 0,98 | ≈ 39 ms | 1,45 ms |
| **20,5** | 728 | 513 ms | 0,70 | **≈ 28 ms** (< 120 ✓) | 4,04 ms (1.667 car.) |
| 26 | 1.255 | 494 ms | 0,39 | ≈ 16 ms | 1,86 ms |

- Leitura do EPUB (zip + XML → 2.087 blocos): 311 ms no JIT (vai para isolate na G09 — não usa `dart:ui`).
- Só **1** bloco passou de 4 ms (20,5 px); com **pedaços de 1.200 caracteres**: 19 parágrafos longos →
  38 pedaços, **835/835 linhas idênticas** ao layout inteiro, pedaço mais caro **1,67 ms**.
- Páginas de referência: N = 1.500 → **251 páginas** (só o texto do livro, 375.569 car.) ou 264
  (EPUB inteiro, com a licença do Gutenberg); N = 1.467 daria exatamente 256. O "256" do arquivo é
  ilustrativo (D-51 f) e a ortografia de 1899 do Gutenberg ("cousa", "elle") muda a contagem; manter o
  número redondo. Na fixture o mapa é injetado (159/256).

## Decisões que mudam (perguntar ao Cesar no relatório da G02)

- Anexo 03 §7.1: "o paginador usa a mesma altura arredondada (1/64)" → **altura exata** (item 3).
- Anexo 03 §7.2: "parágrafo partido = mesmo Paragraph pintado com deslocamento e recorte" continua, mas
  **toda** pintura de texto do leitor passa a ser **por linha** (item 2).
- Achado para a G11: o arredondamento atinge **qualquer** texto de várias linhas com altura de linha
  fracionária. Nas pranchas 19–27b há **29** textos assim; **18** desviariam > 0,5 px com `Text` comum
  (ex.: citações da tela 25 com 26,4 px → 0,8 px em 3 linhas; excerto do marcador 27b com 23,25 px →
  0,5 px). O `AppText` multi-linha precisa do mesmo pintor por linha quando a altura for fracionária.

## Consequências

- Um único mapeamento linha → y (modelo exato) serve pintura, seleção (`getBoxesForRange` + correção da
  linha), grifos, tinta ancorada e **espaços abertos** (tela 24: blocos de `n × alturaLinha` no fluxo).
- Pintar 19 vezes o mesmo `Paragraph` por página é barato (o Skia descarta o que está fora do recorte);
  medir no aparelho na G26.
- Cache `page_layout_cache` por (sha, ajustes, tela, versão das fontes) continua (Anexo 03 §7.2).

## Alternativas consideradas

- **`StrutStyle` com `forceStrutHeight`**: testado — também sai com passo 35,00 (o arredondamento é da linha).
- **Um `Paragraph` por linha**: dobra o custo de shaping e perde `getBoxesForRange` entre linhas.
- **Aceitar o passo inteiro**: 4,68 px na 19ª linha e golden 9 % — reprovado.
- **WebView/HTML**: fidelidade de navegador, mas sem controle de tinta/seleção e com custo de memória.

## Pendências

- Tempos no aparelho intermediário (G26, Android em `--profile`): calibrar o tamanho dos pedaços para
  manter cada fatia ≤ 4 ms (no host, 1.200 caracteres ≈ 1,7 ms; estimar 3–5× no aparelho).
- iOS (sem Mac): repetir o gate da tela 19 quando houver Mac.

## Como reproduzir

```powershell
cd spikes\S3_paginacao; flutter test   # 6 testes; grava dados/*.json e os PNGs da página
python3 tools/compare_images.py --flutter spikes/S3_paginacao/dados/tela19_pagina_por_linha_390x844@3x.png `
  --ref handoff_v2/referencia/png/19_leitor_limpo_390x844@3x.png --scale 3 --rect 0,92,390,670 --name pagina
```
