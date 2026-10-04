# FASE L19 — Leitor — modo limpo

> Tela 19 · prancha `19_leitor_limpo` (19 · Leitor — modo limpo (e-book), canvas 390×844) · executada na **G11** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L19_leitor_limpo@3x.png` · `referencia/png/redline/L19_leitor_limpo_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/19_leitor_limpo_390x844@{1,2,3}x.png` · `referencia/layout/layout_19_leitor_limpo.json` · `test/reference/leitor/reference_layout_19_leitor_limpo.dart` (`kRef19`).
> Arquivos sugeridos: `lib/features/reader/presentation/clean_page.dart`, `lib/features/reader/presentation/reader_footer.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A página do e-book sem nenhum controle; rodapé discreto com a página de referência e o percentual.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`.

```html
<!-- The page -->
<article aria-label="Dom Casmurro, página 159 de 256" style="position: absolute; left: 28px; right: 28px; top: 92px; bottom: 82px; overflow: hidden;">
  <p style="margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em;">Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles olhos de Capitu. Não me acode imagem capaz de dizer, sem quebra da dignidade do estilo, o que eles foram e me fizeram. Olhos de ressaca? Vá, de ressaca. É o que me dá ideia daquela feição nova. Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, como a vaga que se retira da praia, nos dias de ressaca. Para não ser arrastado, agarrei-me às outras partes vizinhas, às orelhas, aos braços, aos cabelos espalhados pelos ombros; mas tão depressa buscava as pupilas, a onda que saía delas vinha crescendo, cava e escura, ameaçando envolver-me, puxar-me e tragar-me.</p>
</article>

<!-- Footer: page + book progress, very quiet -->
<div style="position: absolute; left: 28px; right: 28px; bottom: 40px; display: flex; justify-content: space-between; align-items: center; font-size: 11.5px; font-weight: 600; color: #A89D8B; font-variant-numeric: tabular-nums;">
  <span>pág. 159 de 256</span>
  <span>62%</span>
</div>
```

## Especificação pixel a pixel

Seção `r19.page` — retângulo absoluto no canvas 390×844: **x=28, y=92, w=334, h=670**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `r19.page` | box | 0 | 0 | 334 | 670 | `position: absolute; left: 28px; right: 28px; top: 92px; bottom: 82px; overflow: hidden` |  |
| 2 | `r19.page.text` | text | 0 | 0 | 334 | 775.72 | `margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r19.page.text` | 1 | Retórica dos namorados, dá-me | 26.54 | 26.65 | 332 | 305.35 |
| `r19.page.text` | 2 | uma comparação exata e poética | 61.8 | 0 | 312.39 | 312.39 |
| `r19.page.text` | 3 | para dizer o que foram aqueles | 97.06 | 0 | 294.1 | 294.1 |
| `r19.page.text` | 4 | olhos de Capitu. Não me acode | 132.32 | 0 | 293.2 | 293.2 |
| `r19.page.text` | 5 | imagem capaz de dizer, sem | 167.58 | 0 | 267.46 | 267.46 |
| `r19.page.text` | 6 | quebra da dignidade do estilo, o | 202.84 | 0 | 305.61 | 305.61 |
| `r19.page.text` | 7 | que eles foram e me fizeram. | 238.1 | 0 | 274.05 | 274.05 |
| `r19.page.text` | 8 | Olhos de ressaca? Vá, de ressaca. É | 273.36 | 0 | 329.5 | 329.5 |
| `r19.page.text` | 9 | o que me dá ideia daquela feição | 308.62 | 0 | 308.62 | 308.62 |
| `r19.page.text` | 10 | nova. Traziam não sei que fluido | 343.88 | 0 | 313.75 | 313.75 |
| `r19.page.text` | 11 | misterioso e enérgico, uma força | 379.14 | 0 | 315.35 | 315.35 |
| `r19.page.text` | 12 | que arrastava para dentro, como a | 414.4 | 0 | 327.57 | 327.57 |
| `r19.page.text` | 13 | vaga que se retira da praia, nos | 449.66 | 0 | 296.32 | 296.32 |
| `r19.page.text` | 14 | dias de ressaca. Para não ser | 484.92 | 0 | 269.89 | 269.89 |
| `r19.page.text` | 15 | arrastado, agarrei-me às outras | 520.18 | 0 | 301.46 | 301.46 |
| `r19.page.text` | 16 | partes vizinhas, às orelhas, aos | 555.44 | 0 | 297.41 | 297.41 |
| `r19.page.text` | 17 | braços, aos cabelos espalhados | 590.7 | 0 | 293.73 | 293.73 |
| `r19.page.text` | 18 | pelos ombros; mas tão depressa | 625.96 | 0 | 302.87 | 302.87 |
| `r19.page.text` | 19 | buscava as pupilas, a onda que | 661.22 | 0 | 292.33 | 292.33 |
| `r19.page.text` | 20 | saía delas vinha crescendo, cava e *(oculta: recortada)* | 696.48 | 0 | 322.79 | 322.79 |
| `r19.page.text` | 21 | escura, ameaçando envolver-me, *(oculta: recortada)* | 731.74 | 0 | 317.21 | 317.21 |
| `r19.page.text` | 22 | puxar-me e tragar-me. *(oculta: recortada)* | 767 | 0 | 218.3 | 218.3 |

Seção `r19.footer` — retângulo absoluto no canvas 390×844: **x=28, y=790.19, w=334, h=13.81**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `r19.footer` | box | 0 | 0 | 334 | 13.81 | `position: absolute; left: 28px; right: 28px; bottom: 40px; display: flex; justify-content: space-between; align-items: center; font-size: 11.5px; font-weight: 600; color: #A89D8B; font-variant-numeric: tabular-nums` |  |
| 4 | `r19.footer.pageLabel` ±1 | text | 0 | 0 | 87.22 | 13.81 | `—` | Figtree 11.5/normal peso 600 ls normal #A89D8B tnum |
| 5 | `r19.footer.percent` ±1 | text | 310.31 | 0 | 23.69 | 13.81 | `—` | Figtree 11.5/normal peso 600 ls normal #A89D8B tnum |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r19.footer.pageLabel` | 1 | pág. 159 de 256 | 10.93 | 0 | 87.22 | 87.22 |
| `r19.footer.percent` | 1 | 62% | 10.93 | 310.31 | 334 | 23.69 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A página é um `article` absoluto `left/right 28 · top 92 · bottom 82` com `overflow: hidden`; o parágrafo é Literata 20,5 / `line-height 1,72` (35,26) / `text-indent 1,3 em` (26,65) / `#2A2520`, alinhado à esquerda. São **19 linhas visíveis**; as 3 seguintes existem no layout e ficam cortadas (`hidden` na referência).
2. Recuo da 1ª linha: o Flutter não tem `text-indent` → `PlaceholderSpan` de 26,65 no começo do parágrafo (Anexo 03; validar no S3).
3. Fios de navalha: linha 7 ("…me fizeram." + "Olhos" faltaria 0,711 px) e linha 19 ("…a onda que" + "saía", 0,538 px). Com as fontes da G01.7 (avanços do HVAR, ≤ 0,01 px do Chromium) as quebras batem; qualquer outra fonte/arredondamento muda o parágrafo inteiro.
4. Rodapé: `left/right 28 · bottom 40`, Figtree 11,5/600 `#A89D8B`, **números tabulares** (`FontFeature.tabularFigures()`); "pág. 159 de 256" à esquerda e "62%" à direita (`space-between`).
5. Fundo = `paper` (prop, padrão `#F8F1E4` = Creme). Os 4 papéis vêm da tela 26 (D-51 b: Sépia = `#EEDDBF`).

## Armadilhas

- Fio de navalha em `r19.page.text` linha 7 «que eles foram e me fizeram.»: sobra 59.95 px · estouro com a próxima palavra 0.71 px.
- Fio de navalha em `r19.page.text` linha 19 «buscava as pupilas, a onda que»: sobra 41.67 px · estouro com a próxima palavra 0.54 px.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `r19.page.text`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `r19.page` |  | Dom Casmurro, página 159 de 256 |  |

## Interações

- Toque no centro → controles (tela 20); terços laterais / arrasto horizontal → vira a página (D-22, 220 ms easeOutCubic).
- Pressão longa numa palavra → seleção (tela 21).

## Dados

- Texto = layout do capítulo atual (paginador, G10); "pág. 159" = página de referência do 1º caractere visível (D-19); "256" = total de páginas de referência; "62%" = caractere global ÷ total.

## Subfases

- **L19.1** Página (parágrafo com recuo, 19 linhas idênticas)
- **L19.2** Rodapé tabular
- **L19.3** Papel/tema (paper)
- **L19.4** Gestos de virar página
- **L19.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('r19.page', 'r19.footer'), todos os ids de `kRef19.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/19_leitor_limpo_390x844@3x.png` no recorte da fase (y 84–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L19.1 Página (parágrafo com recuo, 19 linhas idênticas)
- [ ] L19.2 Rodapé tabular
- [ ] L19.3 Papel/tema (paper)
- [ ] L19.4 Gestos de virar página
- [ ] L19.5 Verificação + relatório
- [ ] Geometria 5/5 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
