# FASE L24 — Abrindo espaço (arrastar)

> Tela 24 · prancha `24_abrindo_espaco` (24 · Leitor — abrindo espaço (arrastar), canvas 390×844) · executada na **G18** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L24_abrindo_espaco@3x.png` · `referencia/png/redline/L24_abrindo_espaco_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/24_abrindo_espaco_390x844@{1,2,3}x.png` · `referencia/layout/layout_24_abrindo_espaco.json` · `test/reference/leitor/reference_layout_24_abrindo_espaco.dart` (`kRef24`).
> Arquivos sugeridos: `lib/features/reader/presentation/space_opener.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Ferramenta Espaço ativa: o dedo começou entre duas linhas e arrasta para baixo; o texto de baixo desce.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- The page: same layout as the clean reader, nudged down; text is locked (no reflow) while drawing -->
<article aria-label="Dom Casmurro, página 159 de 256 — modo anotação" style="position: absolute; left: 28px; right: 28px; top: 116px; bottom: 0; overflow: hidden;">
  <p style="margin: 0; padding-top: 6px; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em;">Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles <span style="position: relative; white-space: nowrap;"><svg aria-hidden="true" sc-camel-view-box="0 0 100 20" sc-camel-preserve-aspect-ratio="none" style="position: absolute; left: -5px; top: 3px; width: calc(100% + 10px); height: calc(100% - 4px); mix-blend-mode: multiply; pointer-events: none;"><path d="M2 4C20 1.5 45 3.5 70 2.5S94 2 98.5 3.5L99 17C82 18.5 60 16.5 38 18S8 18.5 1.5 17.5Z" fill="#FED170" opacity="0.9"></path></svg>olhos de Capitu</span>. Não me acode imagem capaz de dizer, sem quebra da dignidade do estilo, o que eles foram e me fizeram. <span style="position: relative; white-space: nowrap;"><svg aria-hidden="true" sc-camel-view-box="0 0 100 40" sc-camel-preserve-aspect-ratio="none" style="position: absolute; left: -9px; top: -6px; width: calc(100% + 18px); height: calc(100% + 12px); overflow: visible; pointer-events: none;"><path d="M60 3C86 2 99 10 98.5 21 97.5 33 76 38.5 48 37.5 20 36.5 2 30 2.5 19 3.5 8 25 2.5 53 3.5 70 4.5 83 8.5 88 12.5" fill="none" stroke="#FF552E" stroke-width="2.3" stroke-linecap="round" vector-effect="non-scaling-stroke"></path></svg><svg aria-hidden="true" width="34" height="12" sc-camel-view-box="0 0 34 12" style="position: absolute; left: 50%; top: -14px; margin-left: -17px; overflow: visible; pointer-events: none;"><path d="M1 7.5Q4 3 7 7.5T13 7.5 19 7.5 25 7.5 31 7.5" fill="none" stroke="#FF552E" stroke-width="1.8" stroke-linecap="round"></path></svg>Olhos de ressaca?</span> Vá, de ressaca.</p>

  <!-- Opening: the finger started between two lines (purple seam) and is dragging down; height snaps to whole lines -->
  <div role="status" aria-label="Abrindo espaço: 3 linhas" style="position: relative; margin: 14px 0 24px; height: 104px; font-family: 'Figtree', sans-serif;">
    <span aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 0; bottom: 0; border-radius: 14px; border: 1.5px dashed #552CB7; background: repeating-linear-gradient(135deg, rgba(182,172,228,0.32) 0 4px, rgba(255,253,248,0.9) 4px 9px); box-sizing: border-box;"></span>
    <span aria-hidden="true" style="position: absolute; left: 4px; right: 4px; top: -1px; height: 2.5px; border-radius: 2px; background: #552CB7;"></span>
    <span aria-hidden="true" style="position: absolute; left: 0; top: -4.5px; width: 10px; height: 10px; border-radius: 50%; background: #552CB7;"></span>
    <span aria-hidden="true" style="position: absolute; right: 0; top: -4.5px; width: 10px; height: 10px; border-radius: 50%; background: #552CB7;"></span>
    <!-- trail of the drag -->
    <svg aria-hidden="true" width="24" height="86" sc-camel-view-box="0 0 24 86" style="position: absolute; left: 58%; top: 2px; margin-left: -12px; overflow: visible;">
      <path d="M12 4V62" fill="none" stroke="#552CB7" stroke-width="2.2" stroke-linecap="round" stroke-dasharray="1 7"></path>
      <path d="M5 26 12 33 19 26M5 44 12 51 19 44" fill="none" stroke="#552CB7" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path>
      <circle cx="12" cy="4" r="4" fill="#552CB7"></circle>
    </svg>
    <!-- finger on the moving edge -->
    <span aria-hidden="true" style="position: absolute; left: 58%; bottom: -21px; width: 42px; height: 42px; margin-left: -21px; border-radius: 50%; background: rgba(182,172,228,0.55); border: 1.5px dashed #1A1714; box-sizing: border-box;"></span>
    <!-- live size, snapped to lines -->
    <span style="position: absolute; left: 14px; top: 50%; height: 28px; margin-top: -14px; padding: 0 10px; border-radius: 9px; background: #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; color: #F7F0E3; white-space: nowrap;"><svg width="14" height="14" sc-camel-view-box="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3v18M7 7l5-4 5 4M7 17l5 4 5-4"></path></svg>3 linhas</span>
  </div>

  <p style="margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left;">É o que me dá ideia daquela feição nova. Traziam não sei que <span style="position: relative; white-space: nowrap;"><svg aria-hidden="true" height="10" style="position: absolute; left: -1px; bottom: -9px; width: calc(100% + 2px); overflow: hidden; pointer-events: none;"><path d="M0 5 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0 q3 -4.5 6 0 t6 0" fill="none" stroke="#FF552E" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"></path></svg>fluido misterioso</span> e enérgico, uma força que arrastava para dentro, como <span style="position: relative; white-space: nowrap;"><span aria-hidden="true" style="position: absolute; left: -2px; right: -2px; bottom: -3px; height: 2.4px; border-radius: 2px; background: #FF552E;"></span><span aria-hidden="true" style="position: absolute; left: -2px; right: -2px; bottom: -8px; height: 2.4px; border-radius: 2px; background: #FF552E;"></span>a vaga que se retira</span> da praia, nos dias de ressaca. Para não ser arrastado, agarrei-me às outras partes vizinhas, às orelhas, aos braços, aos cabelos espalhados pelos ombros; mas tão depressa buscava as pupilas, a onda que saía delas vinha crescendo, cava e escura, ameaçando envolver-me, puxar-me e tragar-me.</p>
</article>
```

## Especificação pixel a pixel

Seção `sp.page` — retângulo absoluto no canvas 390×844: **x=28, y=116, w=334, h=728**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sp.page` | box | 0 | 0 | 334 | 728 | `position: absolute; left: 28px; right: 28px; top: 116px; bottom: 0; overflow: hidden` |  |
| 2 | `sp.page.text` | text | 0 | 0 | 334 | 288.08 | `margin: 0; padding-top: 6px; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 3 | `sp.page.text.handHighlight` ±1 | inline | 0 | 114.19 | 148.92 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 4 | `sp.page.text.handHighlight.stroke` ±1 | icon | -5 | 117.19 | 158.92 | 26.44 | `position: absolute; left: -5px; top: 3px; width: calc(100% + 10px); height: calc(100% - 4px); mix-blend-mode: multiply; pointer-events: none` |  |
| 5 | `sp.page.text.circled` ±1 | inline | 0 | 255.23 | 168.54 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 6 | `sp.page.text.circled.ellipse` ±1 | icon | -9 | 249.23 | 186.54 | 42.44 | `position: absolute; left: -9px; top: -6px; width: calc(100% + 18px); height: calc(100% + 12px); overflow: visible; pointer-events: none` |  |
| 7 | `sp.page.text.circled.flourish` ±1 | icon | 67.27 | 241.23 | 34 | 12 | `position: absolute; left: 50%; top: -14px; margin-left: -17px; overflow: visible; pointer-events: none` |  |
| 8 | `sp.page.spaceOpener` | box | 0 | 302.08 | 334 | 104 | `position: relative; margin: 14px 0 24px; height: 104px; font-family: 'Figtree', sans-serif` |  |
| 9 | `sp.page.spaceOpener.area` | box | 0 | 302.08 | 334 | 104 | `position: absolute; left: 0; right: 0; top: 0; bottom: 0; border-radius: 14px; border: 1.5px dashed #552CB7; background: repeating-linear-gradient(135deg, rgba(182,172,228,0.32) 0 4px, rgba(255,253,248,0.9) 4px 9px); box-sizing: border-box` |  |
| 10 | `sp.page.spaceOpener.seam` | box | 4 | 301.08 | 326 | 2.5 | `position: absolute; left: 4px; right: 4px; top: -1px; height: 2.5px; border-radius: 2px; background: #552CB7` |  |
| 11 | `sp.page.spaceOpener.seamDotLeft` | box | 0 | 297.58 | 10 | 10 | `position: absolute; left: 0; top: -4.5px; width: 10px; height: 10px; border-radius: 50%; background: #552CB7` |  |
| 12 | `sp.page.spaceOpener.seamDotRight` | box | 324 | 297.58 | 10 | 10 | `position: absolute; right: 0; top: -4.5px; width: 10px; height: 10px; border-radius: 50%; background: #552CB7` |  |
| 13 | `sp.page.spaceOpener.trail` | icon | 181.72 | 304.08 | 24 | 86 | `position: absolute; left: 58%; top: 2px; margin-left: -12px; overflow: visible` |  |
| 14 | `sp.page.spaceOpener.finger` | box | 172.72 | 385.08 | 42 | 42 | `position: absolute; left: 58%; bottom: -21px; width: 42px; height: 42px; margin-left: -21px; border-radius: 50%; background: rgba(182,172,228,0.55); border: 1.5px dashed #1A1714; box-sizing: border-box` |  |
| 15 | `sp.page.spaceOpener.sizeChip` ±1 | box+text | 14 | 340.08 | 83.7 | 28 | `position: absolute; left: 14px; top: 50%; height: 28px; margin-top: -14px; padding: 0 10px; border-radius: 9px; background: #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; color: #F7F0E3; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #F7F0E3 |
| 16 | `sp.page.spaceOpener.sizeChip.icon` | icon | 24 | 347.08 | 14 | 14 | `—` |  |
| 17 | `sp.page.textBelow` | text | 0 | 430.08 | 334 | 493.64 | `margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 18 | `sp.page.textBelow.wavy` ±1 | inline | 0 | 503.01 | 165.14 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 19 | `sp.page.textBelow.wavy.wave` ±1 | icon | -1 | 532.45 | 167.14 | 10 | `position: absolute; left: -1px; bottom: -9px; width: calc(100% + 2px); overflow: hidden; pointer-events: none` |  |
| 20 | `sp.page.textBelow.doubleUnderline` ±1 | inline | 57.67 | 573.53 | 183.47 | 30.44 | `position: relative; white-space: nowrap` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |
| 21 | `sp.page.textBelow.doubleUnderline.line1` ±1 | box | 55.67 | 604.57 | 187.47 | 2.4 | `position: absolute; left: -2px; right: -2px; bottom: -3px; height: 2.4px; border-radius: 2px; background: #FF552E` |  |
| 22 | `sp.page.textBelow.doubleUnderline.line2` ±1 | box | 55.67 | 609.57 | 187.47 | 2.4 | `position: absolute; left: -2px; right: -2px; bottom: -8px; height: 2.4px; border-radius: 2px; background: #FF552E` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sp.page.text` *(composto)* | 1 | Retórica dos namorados, dá-me | 32.54 | 26.65 | 332 | 305.35 |
| `sp.page.text` *(composto)* | 2 | uma comparação exata e poética | 67.8 | 0 | 312.39 | 312.39 |
| `sp.page.text` *(composto)* | 3 | para dizer o que foram aqueles | 103.06 | 0 | 294.1 | 294.1 |
| `sp.page.text` *(composto)* | 4 | olhos de Capitu. Não me acode | 138.32 | 0 | 293.2 | 293.2 |
| `sp.page.text` *(composto)* | 5 | imagem capaz de dizer, sem | 173.58 | 0 | 267.46 | 267.46 |
| `sp.page.text` *(composto)* | 6 | quebra da dignidade do estilo, o | 208.84 | 0 | 305.61 | 305.61 |
| `sp.page.text` *(composto)* | 7 | que eles foram e me fizeram. | 244.1 | 0 | 274.05 | 274.05 |
| `sp.page.text` *(composto)* | 8 | Olhos de ressaca? Vá, de ressaca. | 279.36 | 0 | 312.43 | 312.43 |
| `sp.page.spaceOpener.sizeChip` | 1 | 3 linhas | 358.45 | 44 | 87.7 | 43.7 |
| `sp.page.textBelow` *(composto)* | 1 | É o que me dá ideia daquela feição | 456.62 | 0 | 325.69 | 325.69 |
| `sp.page.textBelow` *(composto)* | 2 | nova. Traziam não sei que | 491.88 | 0 | 252.27 | 252.27 |
| `sp.page.textBelow` *(composto)* | 3 | fluido misterioso e enérgico, uma | 527.14 | 0 | 322.57 | 322.57 |
| `sp.page.textBelow` *(composto)* | 4 | força que arrastava para dentro, | 562.4 | 0 | 309.03 | 309.03 |
| `sp.page.textBelow` *(composto)* | 5 | como a vaga que se retira da praia, | 597.66 | 0 | 330.66 | 330.66 |
| `sp.page.textBelow` *(composto)* | 6 | nos dias de ressaca. Para não ser | 632.92 | 0 | 308.34 | 308.34 |
| `sp.page.textBelow` *(composto)* | 7 | arrastado, agarrei-me às outras | 668.18 | 0 | 301.46 | 301.46 |
| `sp.page.textBelow` *(composto)* | 8 | partes vizinhas, às orelhas, aos | 703.44 | 0 | 297.41 | 297.41 |
| `sp.page.textBelow` *(composto)* | 9 | braços, aos cabelos espalhados | 738.7 | 0 | 293.73 | 293.73 |
| `sp.page.textBelow` *(composto)* | 10 | pelos ombros; mas tão depressa *(oculta: recortada)* | 773.96 | 0 | 302.87 | 302.87 |
| `sp.page.textBelow` *(composto)* | 11 | buscava as pupilas, a onda que *(oculta: recortada)* | 809.22 | 0 | 292.33 | 292.33 |
| `sp.page.textBelow` *(composto)* | 12 | saía delas vinha crescendo, cava e *(oculta: recortada)* | 844.48 | 0 | 322.79 | 322.79 |
| `sp.page.textBelow` *(composto)* | 13 | escura, ameaçando envolver-me, *(oculta: recortada)* | 879.74 | 0 | 317.21 | 317.21 |
| `sp.page.textBelow` *(composto)* | 14 | puxar-me e tragar-me. *(oculta: recortada)* | 915 | 0 | 218.3 | 218.3 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O espaço é um bloco de 104 de altura (`margin 14/0/24`) entre "Vá, de ressaca." e "É o que me dá ideia…": área tracejada roxa `#552CB7` com hachura `rgba(182,172,228,.32)`/`rgba(255,253,248,.9)` (4/9 px), raio 14.
2. Costura roxa 2,5 no topo com bolinhas 10 nas pontas; rastro do arrasto (SVG tracejado); dedo (círculo 42 lavanda tracejado) na borda que se move; chip vivo "↕ 3 linhas" (tinta, Figtree 12,5/800, `role=status`).
3. O texto de baixo é um 2º parágrafo **sem recuo**; as quebras mudam (linha "nova. Traziam não sei que" termina antes porque "fluido misterioso" é `nowrap`).
4. Subtítulo do topo: "Arraste entre as linhas"; prateleira com o Espaço ativo (cor `brand`).

## Armadilhas

- Fio de navalha em `sp.page.text` linha 7 «que eles foram e me fizeram.»: sobra 59.95 px · estouro com a próxima palavra 0.71 px.
- Fio de navalha em `sp.page.textBelow` linha 11 «buscava as pupilas, a onda que»: sobra 41.67 px · estouro com a próxima palavra 0.54 px.
- `sp.page.text.handHighlight.stroke` usa `mix-blend-mode: multiply`.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `sp.page.textBelow`.

## Diferenças em relação à prancha 22 (seções reutilizadas: deskEdge, modePill, done, toolShelf, island)

Estas seções são as mesmas widgets da 22 (fases L22a_pagina_anotada, L22b_topo_modo_anotacao, L22c_prateleira_ferramentas, L22d_ilha_anotacao); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `sp.modePill` | retângulo ['14', '50', '202.48', '52'] → ['14', '50', '189.25', '52']; position: {"top": "50px", "right": "173.52px", "bottom": "742px", "left": "14px"} → {"top": "50px", "right": "186.753px", "bottom": "742px", "left": "14px"} |
| `sp.modePill.texts` | retângulo ['69.5', '59.57', '129.48', '32.86'] → ['69.5', '59.57', '116.25', '32.86'] |
| `sp.modePill.title` | retângulo ['69.5', '59.57', '129.48', '17.05'] → ['69.5', '59.57', '116.25', '17.05'] |
| `sp.modePill.subtitle` | retângulo ['69.5', '78.62', '129.48', '13.81'] → ['69.5', '78.62', '116.25', '13.81']; texto «2 dedos movem a página» → «Arraste entre as linhas» |
| `sp.toolShelf.pen` | transform: "translateY(-12px)" → null; transformMatrix: "matrix(1, 0, 0, 1, 0, -12)" → null |
| `sp.toolShelf.space` | transform: null → "translateY(-12px)"; transformMatrix: null → "matrix(1, 0, 0, 1, 0, -12)" |
| `sp.island.labels.pen` | font: null → {"family": "Figtree", "size": 10.0, "weightCss": 700, "weightRendered": 700, "style": "normal", "lineHeight": "normal", "letterSpacing": "normal", "color": "#6F665B", "whiteSpace": "nowrap"}; texto «» → «Caneta» |
| `sp.island.labels.space` | font: {"family": "Figtree", "size": 10.0, "weightCss": 700, "weightRendered": 700, "style": "normal", "lineHeight": "normal", "letterSpacing": "normal", "color": "#6F665B", "whiteSpace": "nowrap"} → null; texto «Espaço» → «» |

Só na base: `island.labels.pen.pill`.

Só nesta prancha: `island.labels.space.pill`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sp.page` |  | Dom Casmurro, página 159 de 256 — modo anotação |  |
| `sp.page.text.handHighlight.stroke` |  |  | aria-hidden=true |
| `sp.page.text.circled.ellipse` |  |  | aria-hidden=true |
| `sp.page.text.circled.flourish` |  |  | aria-hidden=true |
| `sp.page.spaceOpener` | status | Abrindo espaço: 3 linhas |  |
| `sp.page.spaceOpener.area` |  |  | aria-hidden=true |
| `sp.page.spaceOpener.seam` |  |  | aria-hidden=true |
| `sp.page.spaceOpener.seamDotLeft` |  |  | aria-hidden=true |
| `sp.page.spaceOpener.seamDotRight` |  |  | aria-hidden=true |
| `sp.page.spaceOpener.trail` |  |  | aria-hidden=true |
| `sp.page.spaceOpener.finger` |  |  | aria-hidden=true |
| `sp.page.spaceOpener.sizeChip.icon` |  |  | aria-hidden=true |
| `sp.page.textBelow.wavy.wave` |  |  | aria-hidden=true |
| `sp.page.textBelow.doubleUnderline.line1` |  |  | aria-hidden=true |
| `sp.page.textBelow.doubleUnderline.line2` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sp.page.text.handHighlight` | TextSpan dentro do AppText.rich do pai |  |
| `sp.page.text.handHighlight.stroke` | InkStrokesPainter (traços da fixture: grifo_mao_livre_capitu) |  |
| `sp.page.text.circled` | TextSpan dentro do AppText.rich do pai |  |
| `sp.page.text.circled.ellipse` | InkStrokesPainter (traços da fixture: elipse_olhos_de_ressaca) | vector-effect="non-scaling-stroke" e preserveAspectRatio="none" (esticado sobre o trecho): na app é tinta (traços salvos), não asset. |
| `sp.page.text.circled.flourish` | InkStrokesPainter (traços da fixture: risco_sobre_olhos_de_ressaca) |  |
| `sp.page.spaceOpener.area` | HatchPainter (hachura 135°) dentro do contorno |  |
| `sp.page.spaceOpener.seam` | NeoBox |  |
| `sp.page.spaceOpener.seamDotLeft` | CircleIconButton / NeoBox circular |  |
| `sp.page.spaceOpener.seamDotRight` | CircleIconButton / NeoBox circular |  |
| `sp.page.spaceOpener.trail` | InkStrokesPainter (traços da fixture: rastro_arrasto_espaco) |  |
| `sp.page.spaceOpener.finger` | CircleIconButton / NeoBox circular |  |
| `sp.page.spaceOpener.sizeChip` | NeoBox + AppText |  |
| `sp.page.spaceOpener.sizeChip.icon` | AppSvg(AppIconsLeitor.ic_arrows_vertical, size: 14) |  |
| `sp.page.textBelow.wavy` | TextSpan dentro do AppText.rich do pai |  |
| `sp.page.textBelow.wavy.wave` | InkStrokesPainter (traços da fixture: ondulado_fluido_misterioso) |  |
| `sp.page.textBelow.doubleUnderline` | TextSpan dentro do AppText.rich do pai |  |
| `sp.page.textBelow.doubleUnderline.line1` | NeoBox |  |
| `sp.page.textBelow.doubleUnderline.line2` | NeoBox |  |

## Interações

- Arrastar abre o espaço em linhas inteiras (mín. 1, máx. 12 — D-41); soltar cria a camada.

## Dados

- `ink_layers(kind=space, space_lines=n)` ancorado na posição da costura.

## Subfases

- **L24.1** Espaço (área + costura + rastro + dedo)
- **L24.2** Chip de linhas
- **L24.3** Texto de baixo reposicionado
- **L24.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sp.page'), todos os ids de `kRef24.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/24_abrindo_espaco_390x844@3x.png` no recorte da fase (y 108–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L24.1 Espaço (área + costura + rastro + dedo)
- [ ] L24.2 Chip de linhas
- [ ] L24.3 Texto de baixo reposicionado
- [ ] L24.4 Verificação + relatório
- [ ] Geometria 18/18 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
