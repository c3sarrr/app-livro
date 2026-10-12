# FASE L02 — Biblioteca — Coleções (cartões com a pilha de lombadas)

> Tela 02 · prancha `002_biblioteca` (02 · Biblioteca, canvas 390×1640) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L02_2_colecoes@3x.png` · `docs/design/medicao/projeto/png/redline/L02_2_colecoes_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/002_biblioteca_390x1640@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_002_biblioteca.json` · `test/reference/projeto/reference_layout_002_biblioteca.dart` (`kRef02`).
> Arquivos sugeridos: `lib/features/library/presentation/sections/collections_section.dart`, `lib/features/library/presentation/widgets/spine_pile.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Coleções: o título com "Ver todas" e um carrossel de cartões de 200 × 84 (Clássicos brasileiros · 14 livros, Clube Capitu · 6 livros, Faculdade · 9 PDFs), cada um com uma pilha de 3 ou 4 lombadas em CSS. O 3º cartão sai pela direita: o carrossel corta na borda.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Collections -->
<section aria-label="Coleções" style="margin-top: 22px; display: flex; flex-direction: column; gap: 8px;">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Coleções</h2>
    <a href="#" style="height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700;">Ver todas
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </a>
  </div>

  <div style="margin: 0 -20px; padding: 0 20px 4px; display: flex; gap: 12px; overflow: hidden;">
    <!-- Collection: pile of spines -->
    <a href="#" style="flex-shrink: 0; width: 200px; height: 84px; display: flex; align-items: center; gap: 12px; padding: 0 14px 0 12px; box-sizing: border-box; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714;">
      <div aria-hidden="true" style="width: 58px; height: 58px; flex-shrink: 0; display: flex; flex-direction: column; justify-content: flex-end;">
        <div style="position: relative; height: 13px; width: 80%; margin-left: 7px; background: #552CB7; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box; transform: rotate(-6deg);"><span style="position: absolute; left: 32%; top: 4.5px; width: 36%; height: 2px; border-radius: 2px; background: #FED170;"></span></div>
        <div style="position: relative; height: 13px; width: 100%; margin-top: 1px; background: #058CD7; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"><span style="position: absolute; left: 26%; top: 4.5px; width: 40%; height: 2px; border-radius: 2px; background: #FFFAF1;"></span></div>
        <div style="position: relative; height: 13px; width: 88%; margin: -1.2px 0 0 4px; background: #00995E; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"><span style="position: absolute; left: 30%; top: 4.5px; width: 34%; height: 2px; border-radius: 2px; background: #FED170;"></span></div>
        <div style="position: relative; height: 13px; width: 96%; margin: -1.2px 0 0 1px; background: #F2A815; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"><span style="position: absolute; left: 28%; top: 4.5px; width: 38%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55;"></span></div>
      </div>
      <div style="min-width: 0; display: flex; flex-direction: column; gap: 3px;">
        <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Clássicos brasileiros</span>
        <span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">14 livros</span>
      </div>
    </a>

    <a href="#" style="flex-shrink: 0; width: 200px; height: 84px; display: flex; align-items: center; gap: 12px; padding: 0 14px 0 12px; box-sizing: border-box; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714;">
      <div aria-hidden="true" style="width: 58px; height: 58px; flex-shrink: 0; display: flex; flex-direction: column; justify-content: flex-end;">
        <div style="position: relative; height: 13px; width: 84%; margin-left: 4px; background: #FF552E; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box; transform: rotate(5deg);"><span style="position: absolute; left: 30%; top: 4.5px; width: 36%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55;"></span></div>
        <div style="position: relative; height: 13px; width: 94%; margin: 1px 0 0 2px; background: #FFC1C6; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"><span style="position: absolute; left: 28%; top: 4.5px; width: 40%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55;"></span></div>
        <div style="position: relative; height: 13px; width: 100%; margin-top: -1.2px; background: #552CB7; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"><span style="position: absolute; left: 30%; top: 4.5px; width: 34%; height: 2px; border-radius: 2px; background: #FED170;"></span></div>
        <div style="position: relative; height: 13px; width: 90%; margin: -1.2px 0 0 5px; background: #FED170; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"><span style="position: absolute; left: 26%; top: 4.5px; width: 40%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55;"></span></div>
      </div>
      <div style="min-width: 0; display: flex; flex-direction: column; gap: 3px;">
        <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Clube Capitu</span>
        <span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">6 livros</span>
      </div>
    </a>

    <a href="#" style="flex-shrink: 0; width: 200px; height: 84px; display: flex; align-items: center; gap: 12px; padding: 0 14px 0 12px; box-sizing: border-box; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714;">
      <div aria-hidden="true" style="width: 58px; height: 58px; flex-shrink: 0; display: flex; flex-direction: column; justify-content: flex-end;">
        <div style="position: relative; height: 13px; width: 86%; margin-left: 5px; background: #FFFAF1; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box; transform: rotate(-4deg);"></div>
        <div style="position: relative; height: 13px; width: 100%; margin-top: 1px; background: #B6ACE4; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"></div>
        <div style="position: relative; height: 13px; width: 92%; margin: -1.2px 0 0 3px; background: #FFFAF1; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box;"></div>
      </div>
      <div style="min-width: 0; display: flex; flex-direction: column; gap: 3px;">
        <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Faculdade</span>
        <span style="font-size: 12.5px; font-weight: 500; color: #5B544B;">9 PDFs</span>
      </div>
    </a>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `b02.collections` — retângulo absoluto no canvas 390×1640: **x=20, y=208, w=350, h=140**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `b02.collections` | box | 0 | 0 | 350 | 140 | `margin-top: 22px; display: flex; flex-direction: column; gap: 8px` |  |
| 2 | `b02.collections.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `b02.collections.title` ±1 | text | 0 | 10 | 86.2 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 4 | `b02.collections.seeAll` ±1 | text | 266.11 | 0 | 83.89 | 44 | `height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 5 | `b02.collections.seeAll.icon` | icon | 332 | 13 | 18 | 18 | `—` |  |
| 6 | `b02.collections.carousel` | box | -20 | 52 | 390 | 88 | `margin: 0 -20px; padding: 0 20px 4px; display: flex; gap: 12px; overflow: hidden` |  |
| 7 | `b02.collections.card1` | box | 0 | 52 | 200 | 84 | `flex-shrink: 0; width: 200px; height: 84px; display: flex; align-items: center; gap: 12px; padding: 0 14px 0 12px; box-sizing: border-box; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714` |  |
| 8 | `b02.collections.card1.pile` | box | 13.5 | 65 | 58 | 58 | `width: 58px; height: 58px; flex-shrink: 0; display: flex; flex-direction: column; justify-content: flex-end` |  |
| 9 | `b02.collections.card1.pile.spine1` | box | 20.5 | 72.4 | 46.4 | 13 | `position: relative; height: 13px; width: 80%; margin-left: 7px; background: #552CB7; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box; transform: rotate(-6deg)` |  |
| 10 | `b02.collections.card1.pile.spine1.band` | box | 35.78 | 78.1 | 15.84 | 2 | `position: absolute; left: 32%; top: 4.5px; width: 36%; height: 2px; border-radius: 2px; background: #FED170` |  |
| 11 | `b02.collections.card1.pile.spine2` | box | 13.5 | 86.4 | 58 | 13 | `position: relative; height: 13px; width: 100%; margin-top: 1px; background: #058CD7; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 12 | `b02.collections.card1.pile.spine2.band` | box | 29.16 | 92.1 | 22.24 | 2 | `position: absolute; left: 26%; top: 4.5px; width: 40%; height: 2px; border-radius: 2px; background: #FFFAF1` |  |
| 13 | `b02.collections.card1.pile.spine3` | box | 17.5 | 98.2 | 51.04 | 13 | `position: relative; height: 13px; width: 88%; margin: -1.2px 0 0 4px; background: #00995E; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 14 | `b02.collections.card1.pile.spine3.band` | box | 33.29 | 103.9 | 16.54 | 2 | `position: absolute; left: 30%; top: 4.5px; width: 34%; height: 2px; border-radius: 2px; background: #FED170` |  |
| 15 | `b02.collections.card1.pile.spine4` | box | 14.5 | 110 | 55.68 | 13 | `position: relative; height: 13px; width: 96%; margin: -1.2px 0 0 1px; background: #F2A815; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 16 | `b02.collections.card1.pile.spine4.band` | box | 30.62 | 115.7 | 20.25 | 2 | `position: absolute; left: 28%; top: 4.5px; width: 38%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55` |  |
| 17 | `b02.collections.card1.textBlock` | box | 83.5 | 68.19 | 101 | 51.61 | `min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 18 | `b02.collections.card1.title` | text | 83.5 | 68.19 | 101 | 33.6 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 19 | `b02.collections.card1.count` | text | 83.5 | 104.8 | 101 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 20 | `b02.collections.card2` | box | 212 | 52 | 200 | 84 | `flex-shrink: 0; width: 200px; height: 84px; display: flex; align-items: center; gap: 12px; padding: 0 14px 0 12px; box-sizing: border-box; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714` |  |
| 21 | `b02.collections.card2.pile` | box | 225.5 | 65 | 58 | 58 | `width: 58px; height: 58px; flex-shrink: 0; display: flex; flex-direction: column; justify-content: flex-end` |  |
| 22 | `b02.collections.card2.pile.spine1` | box | 229.5 | 72.4 | 48.72 | 13 | `position: relative; height: 13px; width: 84%; margin-left: 4px; background: #FF552E; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box; transform: rotate(5deg)` |  |
| 23 | `b02.collections.card2.pile.spine1.band` | box | 244.6 | 78.1 | 16.68 | 2 | `position: absolute; left: 30%; top: 4.5px; width: 36%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55` |  |
| 24 | `b02.collections.card2.pile.spine2` | box | 227.5 | 86.4 | 54.52 | 13 | `position: relative; height: 13px; width: 94%; margin: 1px 0 0 2px; background: #FFC1C6; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 25 | `b02.collections.card2.pile.spine2.band` | box | 243.29 | 92.1 | 20.85 | 2 | `position: absolute; left: 28%; top: 4.5px; width: 40%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55` |  |
| 26 | `b02.collections.card2.pile.spine3` | box | 225.5 | 98.2 | 58 | 13 | `position: relative; height: 13px; width: 100%; margin-top: -1.2px; background: #552CB7; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 27 | `b02.collections.card2.pile.spine3.band` | box | 243.38 | 103.9 | 18.9 | 2 | `position: absolute; left: 30%; top: 4.5px; width: 34%; height: 2px; border-radius: 2px; background: #FED170` |  |
| 28 | `b02.collections.card2.pile.spine4` | box | 230.5 | 110 | 52.2 | 13 | `position: relative; height: 13px; width: 90%; margin: -1.2px 0 0 5px; background: #FED170; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 29 | `b02.collections.card2.pile.spine4.band` | box | 244.65 | 115.7 | 19.92 | 2 | `position: absolute; left: 26%; top: 4.5px; width: 40%; height: 2px; border-radius: 2px; background: #1A1714; opacity: 0.55` |  |
| 30 | `b02.collections.card2.textBlock` ±1 | box | 295.5 | 76.6 | 84.25 | 34.81 | `min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 31 | `b02.collections.card2.title` ±1 | text | 295.5 | 76.6 | 84.25 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 32 | `b02.collections.card2.count` ±1 | text | 295.5 | 96.39 | 84.25 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |
| 33 | `b02.collections.card3` | box | 424 | 52 | 200 | 84 | `flex-shrink: 0; width: 200px; height: 84px; display: flex; align-items: center; gap: 12px; padding: 0 14px 0 12px; box-sizing: border-box; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714` |  |
| 34 | `b02.collections.card3.pile` | box | 437.5 | 65 | 58 | 58 | `width: 58px; height: 58px; flex-shrink: 0; display: flex; flex-direction: column; justify-content: flex-end` |  |
| 35 | `b02.collections.card3.pile.spine1` | box | 442.5 | 84.2 | 49.88 | 13 | `position: relative; height: 13px; width: 86%; margin-left: 5px; background: #FFFAF1; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box; transform: rotate(-4deg)` |  |
| 36 | `b02.collections.card3.pile.spine2` | box | 437.5 | 98.2 | 58 | 13 | `position: relative; height: 13px; width: 100%; margin-top: 1px; background: #B6ACE4; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 37 | `b02.collections.card3.pile.spine3` | box | 440.5 | 110 | 53.36 | 13 | `position: relative; height: 13px; width: 92%; margin: -1.2px 0 0 3px; background: #FFFAF1; border: 1.2px solid #1A1714; border-radius: 3px; box-sizing: border-box` |  |
| 38 | `b02.collections.card3.textBlock` ±1 | box | 507.5 | 76.6 | 66.02 | 34.81 | `min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 39 | `b02.collections.card3.title` ±1 | text | 507.5 | 76.6 | 66.02 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 40 | `b02.collections.card3.count` ±1 | text | 507.5 | 96.39 | 66.02 | 15.01 | `font-size: 12.5px; font-weight: 500; color: #5B544B` | Figtree 12.5/normal peso 500 ls normal #5B544B |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `b02.collections.card1.pile.spine1`: caixa visual com `transform: rotate(-6deg)` = x 19.95, y 70.01, w 47.51, h 17.78 (relativa à seção).
- `b02.collections.card1.pile.spine1.band`: caixa visual deslocada pelo transform de um ancestral = x 35.74, y 77.28, w 15.96, h 3.65 (relativa à seção).
- `b02.collections.card2.pile.spine1`: caixa visual com `transform: rotate(5deg)` = x 229.03, y 70.3, w 49.67, h 17.2 (relativa à seção).
- `b02.collections.card2.pile.spine1.band`: caixa visual deslocada pelo transform de um ancestral = x 244.53, y 77.3, w 16.79, h 3.45 (relativa à seção).
- `b02.collections.card3.pile.spine1`: caixa visual com `transform: rotate(-4deg)` = x 442.11, y 82.48, w 50.66, h 16.45 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b02.collections.title` | 1 | Coleções | 28.6 | 0 | 86.2 | 86.2 |
| `b02.collections.seeAll` | 1 | Ver todas | 26.9 | 266.11 | 328 | 61.89 |
| `b02.collections.card1.title` | 1 | Clássicos | 81.5 | 83.5 | 143.49 | 59.99 |
| `b02.collections.card1.title` | 2 | brasileiros | 98.3 | 83.5 | 149.64 | 66.14 |
| `b02.collections.card1.count` | 1 | 14 livros | 116.68 | 83.5 | 129.45 | 45.95 |
| `b02.collections.card2.title` | 1 | Clube Capitu | 89.89 | 295.5 | 379.75 | 84.25 |
| `b02.collections.card2.count` | 1 | 6 livros | 108.27 | 295.5 | 335.56 | 40.06 |
| `b02.collections.card3.title` | 1 | Faculdade *(oculta: recortada)* | 89.89 | 507.5 | 573.52 | 66.02 |
| `b02.collections.card3.count` | 1 | 9 PDFs *(oculta: recortada)* | 108.27 | 507.5 | 546.15 | 38.65 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Seção 22 abaixo da busca, coluna com gap 8: "Coleções" Bricolage 20/800 ls −0,4 e "Ver todas" Figtree 14/700 com a seta 18 (gap 4), numa linha de 44 de altura (a área de toque).
2. Carrossel com `margin 0 −20` e `padding 0 20 4`, gap 12, `overflow: hidden` (a prancha não rola): no app, `ListView` horizontal com o mesmo recuo de 20 e o corte na borda da tela. Cartões 200 × 84, raio 22, `#FFFAF1`, borda 1,5, sem sombra, padding 0/14/0/12, gap 12.
3. A pilha (58 × 58, coluna com `justify-content: flex-end`): lombadas de 13 de altura, borda 1,2, raio 3, larguras em % do quadrado (80, 100, 88, 96…) com recuos à esquerda; as de baixo sobem 1,2 (`margin-top −1,2`: as bordas se sobrepõem) e a de cima gira (−6°, 5°, −4°). A faixa do meio de cada lombada tem 2 de altura (top 4,5, raio 2) em `#FED170`, `#FFFAF1` ou `#1A1714` a 0,55; a pilha da Faculdade (PDFs) tem 3 lombadas lisas, sem faixa.
4. Texto do cartão: nome Figtree 14/700 `lh 1,2` e contagem 12,5/500 `#5B544B`, gap 3, `min-width: 0`.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A lombada de cima gira no centro (`transform`): a tabela traz o retângulo sem o giro; o desenho girado é o da referência @3x.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `b02.collections.card3.title`, `b02.collections.card3.count`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_002_biblioteca_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_002_biblioteca_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `b02.collections.card2` | sai do quadro (x) | 72 | 42 | não | sim |  |
| 360 | `b02.collections.card2` | passa do pai (x) | 72 | 42 | não | sim | pai `b02.collections.carousel` (cortado) |
| 360 | `b02.collections.card3` | sai do quadro (x) | 284 | 254 | não | sim |  |
| 360 | `b02.collections.card3` | passa do pai (x) | 284 | 254 | não | sim | pai `b02.collections.carousel` (cortado) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `b02.collections` |  | Coleções |  |
| `b02.collections.card1.pile` |  |  | aria-hidden=true |
| `b02.collections.card2.pile` |  |  | aria-hidden=true |
| `b02.collections.card3.pile` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `b02.collections.seeAll.icon` | AppSvg(AppIcons.arrowRight, size: 18) |  |
| `b02.collections.card1` | NeoBox |  |
| `b02.collections.card1.pile.spine1` | NeoBox | Transform: rotate(-6deg) |
| `b02.collections.card1.pile.spine1.band` | NeoBox |  |
| `b02.collections.card1.pile.spine2` | NeoBox |  |
| `b02.collections.card1.pile.spine2.band` | NeoBox |  |
| `b02.collections.card1.pile.spine3` | NeoBox |  |
| `b02.collections.card1.pile.spine3.band` | NeoBox |  |
| `b02.collections.card1.pile.spine4` | NeoBox |  |
| `b02.collections.card1.pile.spine4.band` | NeoBox |  |
| `b02.collections.card2` | NeoBox |  |
| `b02.collections.card2.pile.spine1` | NeoBox | Transform: rotate(5deg) |
| `b02.collections.card2.pile.spine1.band` | NeoBox |  |
| `b02.collections.card2.pile.spine2` | NeoBox |  |
| `b02.collections.card2.pile.spine2.band` | NeoBox |  |
| `b02.collections.card2.pile.spine3` | NeoBox |  |
| `b02.collections.card2.pile.spine3.band` | NeoBox |  |
| `b02.collections.card2.pile.spine4` | NeoBox |  |
| `b02.collections.card2.pile.spine4.band` | NeoBox |  |
| `b02.collections.card3` | NeoBox |  |
| `b02.collections.card3.pile.spine1` | NeoBox | Transform: rotate(-4deg) |
| `b02.collections.card3.pile.spine2` | NeoBox |  |
| `b02.collections.card3.pile.spine3` | NeoBox |  |

## Interações

- "Ver todas" → Coleções · ver todas: tela que falta (D-268), da própria T14 — perguntar, buscar 3–5 referências, desenhar a prancha em `docs/design/novas/` e esperar o "sim" antes do Flutter (ROTEIRO §5).
- Cartão → a coleção aberta: também sem prancha; entra na mesma pergunta da T14 (a tela das coleções).
- Carrossel: arrasto horizontal (na prancha, parado no começo).

## Dados

- Coleções = as listas de livros da pessoa (o nome e quantos livros; "PDFs" quando são todos PDF). O app ainda não tem coleção no banco local: a tabela nova e a regra das cores da pilha (as do cartão, como na prancha, ou as das capas) são perguntas da T14; sem o dado, a seção segue a D-247 (fixture nos testes, some com dados reais até existir).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L02.1** Título e Ver todas
- **L02.2** Cartão da coleção com a pilha de lombadas
- **L02.3** Carrossel cortado na borda
- **L02.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('b02.collections'), todos os ids de `kRef02.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/002_biblioteca_390x1640@3x.png` no recorte da fase (y 200–356) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef02w360` e `kRef02w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L02.1 Título e Ver todas
- [ ] L02.2 Cartão da coleção com a pilha de lombadas
- [ ] L02.3 Carrossel cortado na borda
- [ ] L02.4 Verificação + relatório
- [ ] Geometria 40/40 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
