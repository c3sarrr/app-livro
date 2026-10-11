# FASE L26b — Leitor com controles — tema Noite

> Tela 26b · prancha `26b_tema_noite` (26b · Leitor — tema Noite (com controles), canvas 390×844) · executada na **G12** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L26b_tema_noite@3x.png` · `referencia/png/redline/L26b_tema_noite_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/26b_tema_noite_390x844@{1,2,3}x.png` · `referencia/layout/layout_26b_tema_noite.json` · `test/reference/leitor/reference_layout_26b_tema_noite.dart` (`kRef26b`).
> Arquivos sugeridos: `lib/core/design_system/tokens/reader_themes.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A tela 20 no tema Noite — mesma árvore de widgets (ids `r20.*`), outros tokens.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#1F1B17`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- The page -->
<article aria-label="Dom Casmurro, página 159 de 256" style="position: absolute; left: 28px; right: 28px; top: 92px; bottom: 82px; overflow: hidden;">
  <p style="margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #E3D9C6; text-align: left; text-indent: 1.3em;">Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles olhos de Capitu. Não me acode imagem capaz de dizer, sem quebra da dignidade do estilo, o que eles foram e me fizeram. Olhos de ressaca? Vá, de ressaca. É o que me dá ideia daquela feição nova. Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, como a vaga que se retira da praia, nos dias de ressaca. Para não ser arrastado, agarrei-me às outras partes vizinhas, às orelhas, aos braços, aos cabelos espalhados pelos ombros; mas tão depressa buscava as pupilas, a onda que saía delas vinha crescendo, cava e escura, ameaçando envolver-me, puxar-me e tragar-me.</p>
</article>

<!-- Footer hidden while controls are up -->
<div style="display: none; position: absolute; left: 28px; right: 28px; bottom: 40px; display: flex; justify-content: space-between; align-items: center; font-size: 11.5px; font-weight: 600; color: #8A8073; font-variant-numeric: tabular-nums;">
  <span>pág. 159 de 256</span>
  <span>62%</span>
</div>

<!-- page fades back while the controls are up -->
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(20,17,14,0.55);"></div>

<!-- Top island -->
<header style="position: absolute; left: 14px; right: 14px; top: 54px; height: 62px; padding: 0 8px; border-radius: 31px; background: #2A2520; border: 1.5px solid #EDE3D1; box-shadow: 3px 3px 0 #0B0A08; box-sizing: border-box; display: flex; align-items: center; gap: 10px;">
  <a href="#" aria-label="Fechar o livro" style="width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#EDE3D1" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
  <span style="min-width: 0; flex-grow: 1;">
    <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.1; letter-spacing: -0.3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Dom Casmurro</span>
    <span style="display: block; margin-top: 1px; font-size: 12.5px; font-weight: 600; color: #B5AA98; white-space: nowrap;">Machado de Assis</span>
  </span>
  <button aria-label="Buscar no livro" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#EDE3D1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg></button>
  <button aria-label="Página marcada" aria-pressed="true" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center;">
    <svg width="22" height="24" sc-camel-view-box="0 0 22 24" aria-hidden="true"><path d="M4 2h14v20l-7-5-7 5z" fill="#FF552E" stroke="#EDE3D1" stroke-width="1.8" stroke-linejoin="round"></path></svg>
  </button>
</header>

<!-- Bottom island: book progress + tools -->
<section aria-label="Controles de leitura" style="position: absolute; left: 14px; right: 14px; bottom: 30px; padding: 30px 16px 14px; border-radius: 28px; background: #2A2520; border: 1.5px solid #EDE3D1; box-shadow: 3px 3px 0 #0B0A08; box-sizing: border-box;">
  <!-- scrubber -->
  <div style="position: relative; height: 26px; display: flex; align-items: center;">
    <span role="slider" aria-label="Posição no livro" aria-valuemin="1" aria-valuemax="256" aria-valuenow="159" aria-valuetext="página 159 de 256" style="position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #EDE3D1; background: repeating-linear-gradient(135deg,#3A332B 0 3px,#2A2520 3px 7px); box-sizing: border-box; overflow: hidden;">
      <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 62%; background: {{brand}};">
        <svg width="10" height="15" sc-camel-view-box="0 0 10 15" sc-camel-preserve-aspect-ratio="none" style="position: absolute; top: 0; right: -5px; height: 100%;"><path d="M0 0H5Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15H0Z" fill="{{brand}}"></path><path d="M5 0Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15" fill="none" stroke="#EDE3D1" stroke-width="1.5" vector-effect="non-scaling-stroke"></path></svg>
      </span>
    </span>
    <!-- knob + bubble -->
    <span aria-hidden="true" style="position: absolute; left: 62%; top: 50%; width: 28px; height: 28px; margin: -14px 0 0 -14px; border-radius: 50%; background: #2A2520; border: 2px solid #EDE3D1; box-shadow: 2px 2px 0 #0B0A08; box-sizing: border-box;"></span>
    <span aria-hidden="true" style="position: absolute; left: 62%; bottom: 30px; transform: translateX(-50%); height: 28px; padding: 0 10px; border-radius: 10px; background: #EDE3D1; display: flex; align-items: center; font-size: 12.5px; font-weight: 800; color: #1F1B17; white-space: nowrap;">pág. 159
      <span style="position: absolute; left: 50%; bottom: -5px; width: 10px; height: 10px; margin-left: -5px; background: #EDE3D1; transform: rotate(45deg);"></span>
    </span>
  </div>
  <div style="margin-top: 8px; display: flex; justify-content: space-between; font-size: 12.5px; font-weight: 700; color: #B5AA98; font-variant-numeric: tabular-nums;">
    <span><strong style="color: #EDE3D1; font-weight: 800;">62%</strong> do livro · 256 pág.</span>
    <span>≈ 2 h 10 min</span>
  </div>

  <!-- tools -->
  <div style="margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #4A433A; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr));">
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 19px; font-weight: 500;">Aa</span>Fonte</button>
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#EDE3D1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 14.5A8 8 0 1 1 9.5 4a6.5 6.5 0 0 0 10.5 10.5z"></path></svg></span>Tema</button>
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1;"><span style="position: relative; width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#EDE3D1" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg><span style="position: absolute; top: -8px; right: -8px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; color: #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center;">12</span></span>Grifos</button>
    <button aria-label="Anotar à mão" style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#EDE3D1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16z"></path><path d="m13.5 6.5 4 4"></path><path d="M14 20h6" stroke="#FF552E"></path></svg></span>Anotar</button>
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#EDE3D1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 6h13M8 12h13M8 18h13"></path><circle cx="3.5" cy="6" r="1" fill="#EDE3D1"></circle><circle cx="3.5" cy="12" r="1" fill="#EDE3D1"></circle><circle cx="3.5" cy="18" r="1" fill="#EDE3D1"></circle></svg></span>Sumário</button>
  </div>
</section>

<!-- e-book time counts by itself -->
<span style="position: absolute; left: 50%; top: 130px; transform: translateX(-50%); height: 30px; padding: 0 12px 0 9px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; color: #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="15" height="15" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path></svg>18 min hoje · contando sozinho</span>
```

## Especificação pixel a pixel

Seção `r20.page` — retângulo absoluto no canvas 390×844: **x=28, y=92, w=334, h=670**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `r20.page` | box | 0 | 0 | 334 | 670 | `position: absolute; left: 28px; right: 28px; top: 92px; bottom: 82px; overflow: hidden` |  |
| 2 | `r20.page.text` | text | 0 | 0 | 334 | 775.72 | `margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #E3D9C6; text-align: left; text-indent: 1.3em` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #E3D9C6 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.page.text` | 1 | Retórica dos namorados, dá-me | 26.54 | 26.65 | 332 | 305.35 |
| `r20.page.text` | 2 | uma comparação exata e poética | 61.8 | 0 | 312.39 | 312.39 |
| `r20.page.text` | 3 | para dizer o que foram aqueles | 97.06 | 0 | 294.1 | 294.1 |
| `r20.page.text` | 4 | olhos de Capitu. Não me acode | 132.32 | 0 | 293.2 | 293.2 |
| `r20.page.text` | 5 | imagem capaz de dizer, sem | 167.58 | 0 | 267.46 | 267.46 |
| `r20.page.text` | 6 | quebra da dignidade do estilo, o | 202.84 | 0 | 305.61 | 305.61 |
| `r20.page.text` | 7 | que eles foram e me fizeram. | 238.1 | 0 | 274.05 | 274.05 |
| `r20.page.text` | 8 | Olhos de ressaca? Vá, de ressaca. É | 273.36 | 0 | 329.5 | 329.5 |
| `r20.page.text` | 9 | o que me dá ideia daquela feição | 308.62 | 0 | 308.62 | 308.62 |
| `r20.page.text` | 10 | nova. Traziam não sei que fluido | 343.88 | 0 | 313.75 | 313.75 |
| `r20.page.text` | 11 | misterioso e enérgico, uma força | 379.14 | 0 | 315.35 | 315.35 |
| `r20.page.text` | 12 | que arrastava para dentro, como a | 414.4 | 0 | 327.57 | 327.57 |
| `r20.page.text` | 13 | vaga que se retira da praia, nos | 449.66 | 0 | 296.32 | 296.32 |
| `r20.page.text` | 14 | dias de ressaca. Para não ser | 484.92 | 0 | 269.89 | 269.89 |
| `r20.page.text` | 15 | arrastado, agarrei-me às outras | 520.18 | 0 | 301.46 | 301.46 |
| `r20.page.text` | 16 | partes vizinhas, às orelhas, aos | 555.44 | 0 | 297.41 | 297.41 |
| `r20.page.text` | 17 | braços, aos cabelos espalhados | 590.7 | 0 | 293.73 | 293.73 |
| `r20.page.text` | 18 | pelos ombros; mas tão depressa | 625.96 | 0 | 302.87 | 302.87 |
| `r20.page.text` | 19 | buscava as pupilas, a onda que | 661.22 | 0 | 292.33 | 292.33 |
| `r20.page.text` | 20 | saía delas vinha crescendo, cava e *(oculta: recortada)* | 696.48 | 0 | 322.79 | 322.79 |
| `r20.page.text` | 21 | escura, ameaçando envolver-me, *(oculta: recortada)* | 731.74 | 0 | 317.21 | 317.21 |
| `r20.page.text` | 22 | puxar-me e tragar-me. *(oculta: recortada)* | 767 | 0 | 218.3 | 218.3 |

Seção `r20.footer` — retângulo absoluto no canvas 390×844: **x=28, y=790.19, w=334, h=13.81**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `r20.footer` | box | 0 | 0 | 334 | 13.81 | `display: none; position: absolute; left: 28px; right: 28px; bottom: 40px; display: flex; justify-content: space-between; align-items: center; font-size: 11.5px; font-weight: 600; color: #8A8073; font-variant-numeric: tabular-nums` |  |
| 4 | `r20.footer.pageLabel` ±1 | text | 0 | 0 | 87.22 | 13.81 | `—` | Figtree 11.5/normal peso 600 ls normal #8A8073 tnum |
| 5 | `r20.footer.percent` ±1 | text | 310.31 | 0 | 23.69 | 13.81 | `—` | Figtree 11.5/normal peso 600 ls normal #8A8073 tnum |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.footer.pageLabel` | 1 | pág. 159 de 256 | 10.93 | 0 | 87.22 | 87.22 |
| `r20.footer.percent` | 1 | 62% | 10.93 | 310.31 | 334 | 23.69 |

Seção `r20.fade` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `r20.fade` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background: rgba(20,17,14,0.55)` |  |

Seção `r20.topIsland` — retângulo absoluto no canvas 390×844: **x=14, y=54, w=362, h=62**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 7 | `r20.topIsland` | box | 0 | 0 | 362 | 62 | `position: absolute; left: 14px; right: 14px; top: 54px; height: 62px; padding: 0 8px; border-radius: 31px; background: #2A2520; border: 1.5px solid #EDE3D1; box-shadow: 3px 3px 0 #0B0A08; box-sizing: border-box; display: flex; align-items: center; gap: 10px` |  |
| 8 | `r20.topIsland.close` | box | 9.5 | 9 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `r20.topIsland.close.icon` | icon | 21.5 | 21 | 20 | 20 | `—` |  |
| 10 | `r20.topIsland.titleBlock` | box | 63.5 | 13.64 | 181 | 34.71 | `min-width: 0; flex-grow: 1` |  |
| 11 | `r20.topIsland.title` | text | 63.5 | 13.64 | 181 | 18.7 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.1; letter-spacing: -0.3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Bricolage (opsz 17) 17/18.7px peso 800 ls -0.3px #EDE3D1 |
| 12 | `r20.topIsland.author` | text | 63.5 | 33.34 | 181 | 15.01 | `display: block; margin-top: 1px; font-size: 12.5px; font-weight: 600; color: #B5AA98; white-space: nowrap` | Figtree 12.5/normal peso 600 ls normal #B5AA98 |
| 13 | `r20.topIsland.search` | box | 254.5 | 9 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center` |  |
| 14 | `r20.topIsland.search.icon` | icon | 266 | 20.5 | 21 | 21 | `—` |  |
| 15 | `r20.topIsland.bookmark` | box | 308.5 | 9 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center` |  |
| 16 | `r20.topIsland.bookmark.icon` | icon | 319.5 | 19 | 22 | 24 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.topIsland.title` | 1 | Dom Casmurro | 28.61 | 63.5 | 185.81 | 122.31 |
| `r20.topIsland.author` | 1 | Machado de Assis | 45.22 | 63.5 | 165.4 | 101.9 |

Seção `r20.bottomIsland` — retângulo absoluto no canvas 390×844: **x=14, y=626.86, w=362, h=187.14**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 17 | `r20.bottomIsland` | box | 0 | 0 | 362 | 187.14 | `position: absolute; left: 14px; right: 14px; bottom: 30px; padding: 30px 16px 14px; border-radius: 28px; background: #2A2520; border: 1.5px solid #EDE3D1; box-shadow: 3px 3px 0 #0B0A08; box-sizing: border-box` |  |
| 18 | `r20.bottomIsland.scrubber` | box | 17.5 | 31.5 | 327 | 26 | `position: relative; height: 26px; display: flex; align-items: center` |  |
| 19 | `r20.bottomIsland.scrubber.track` | box | 17.5 | 36.5 | 327 | 16 | `position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #EDE3D1; background: repeating-linear-gradient(135deg,#3A332B 0 3px,#2A2520 3px 7px); box-sizing: border-box; overflow: hidden` |  |
| 20 | `r20.bottomIsland.scrubber.fill` | box | 19 | 38 | 200.88 | 13 | `position: absolute; left: 0; top: 0; bottom: 0; width: 62%; background: {{brand}} (padrão #B6ACE4)` |  |
| 21 | `r20.bottomIsland.scrubber.fill.wave` | icon | 214.88 | 38 | 10 | 13 | `position: absolute; top: 0; right: -5px; height: 100%` |  |
| 22 | `r20.bottomIsland.scrubber.knob` | box | 206.24 | 30.5 | 28 | 28 | `position: absolute; left: 62%; top: 50%; width: 28px; height: 28px; margin: -14px 0 0 -14px; border-radius: 50%; background: #2A2520; border: 2px solid #EDE3D1; box-shadow: 2px 2px 0 #0B0A08; box-sizing: border-box` |  |
| 23 | `r20.bottomIsland.scrubber.bubble` ±1 | box+text | 220.24 | -0.5 | 68.09 | 28 | `position: absolute; left: 62%; bottom: 30px; transform: translateX(-50%); height: 28px; padding: 0 10px; border-radius: 10px; background: #EDE3D1; display: flex; align-items: center; font-size: 12.5px; font-weight: 800; color: #1F1B17; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1F1B17 |
| 24 | `r20.bottomIsland.scrubber.bubble.tail` ±1 | box | 249.28 | 22.5 | 10 | 10 | `position: absolute; left: 50%; bottom: -5px; width: 10px; height: 10px; margin-left: -5px; background: #EDE3D1; transform: rotate(45deg)` |  |
| 25 | `r20.bottomIsland.progressRow` | box | 17.5 | 65.5 | 327 | 15.24 | `margin-top: 8px; display: flex; justify-content: space-between; font-size: 12.5px; font-weight: 700; color: #B5AA98; font-variant-numeric: tabular-nums` |  |
| 26 | `r20.bottomIsland.progressRow.position` ±1 | text | 17.5 | 65.5 | 132.76 | 15.24 | `—` | Figtree 12.5/normal peso 700 ls normal #B5AA98 tnum |
| 27 | `r20.bottomIsland.progressRow.position.percent` ±1 | inline | 17.5 | 65.5 | 26.21 | 15.01 | `color: #EDE3D1; font-weight: 800` | Figtree 12.5/normal peso 800 ls normal #EDE3D1 tnum |
| 28 | `r20.bottomIsland.progressRow.timeLeft` ±1 | text | 272.42 | 65.5 | 72.08 | 15.24 | `—` | Figtree 12.5/normal peso 700 ls normal #B5AA98 tnum |
| 29 | `r20.bottomIsland.tools` | box | 17.5 | 94.74 | 327 | 76.9 | `margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #4A433A; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr))` |  |
| 30 | `r20.bottomIsland.tools.font` | text | 17.5 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1` | Figtree 12/normal peso 700 ls normal #EDE3D1 |
| 31 | `r20.bottomIsland.tools.font.circle` | box+text | 24.2 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 19px; font-weight: 500` | Literata (opsz 19) 19/normal peso 500 ls normal #EDE3D1 |
| 32 | `r20.bottomIsland.tools.theme` | text | 82.9 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1` | Figtree 12/normal peso 700 ls normal #EDE3D1 |
| 33 | `r20.bottomIsland.tools.theme.circle` | box | 89.6 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 34 | `r20.bottomIsland.tools.theme.icon` | icon | 105.1 | 119.74 | 21 | 21 | `—` |  |
| 35 | `r20.bottomIsland.tools.notes` | text | 148.3 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1` | Figtree 12/normal peso 700 ls normal #EDE3D1 |
| 36 | `r20.bottomIsland.tools.notes.circle` | box | 155 | 108.24 | 52 | 44 | `position: relative; width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 37 | `r20.bottomIsland.tools.notes.icon` | icon | 170.5 | 119.74 | 21 | 21 | `—` |  |
| 38 | `r20.bottomIsland.tools.notes.badge` ±1 | box+text | 189.35 | 101.74 | 24.15 | 22 | `position: absolute; top: -8px; right: -8px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; color: #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 11/normal peso 800 ls normal #1A1714 |
| 39 | `r20.bottomIsland.tools.annotate` | text | 213.7 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1` | Figtree 12/normal peso 700 ls normal #EDE3D1 |
| 40 | `r20.bottomIsland.tools.annotate.circle` | box | 220.4 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 41 | `r20.bottomIsland.tools.annotate.icon` | icon | 235.9 | 119.74 | 21 | 21 | `—` |  |
| 42 | `r20.bottomIsland.tools.toc` | text | 279.1 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #EDE3D1` | Figtree 12/normal peso 700 ls normal #EDE3D1 |
| 43 | `r20.bottomIsland.tools.toc.circle` | box | 285.8 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #1F1B17; border: 1.5px solid #EDE3D1; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 44 | `r20.bottomIsland.tools.toc.icon` | icon | 301.3 | 119.74 | 21 | 21 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `r20.bottomIsland.scrubber.bubble`: caixa visual com `transform: translateX(-50%)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `r20.bottomIsland.scrubber.bubble.tail`: caixa visual com `transform: rotate(45deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.bottomIsland.scrubber.bubble` | 1 | pág. 159 | 17.88 | 230.24 | 278.33 | 48.09 |
| `r20.bottomIsland.progressRow.position` *(composto)* | 1 | 62% do livro · 256 pág. | 77.38 | 17.5 | 150.26 | 132.76 |
| `r20.bottomIsland.progressRow.timeLeft` | 1 | ≈ 2 h 10 min | 77.61 | 272.42 | 344.5 | 72.08 |
| `r20.bottomIsland.tools.font` | 1 | Fonte | 168.64 | 34.35 | 66.05 | 31.7 |
| `r20.bottomIsland.tools.font.circle` | 1 | Aa | 138.5 | 37.97 | 62.43 | 24.46 |
| `r20.bottomIsland.tools.theme` | 1 | Tema | 168.64 | 100.74 | 130.46 | 29.72 |
| `r20.bottomIsland.tools.notes` | 1 | Grifos | 168.64 | 164.13 | 197.87 | 33.74 |
| `r20.bottomIsland.tools.notes.badge` | 1 | 12 | 116.59 | 195.85 | 207 | 11.15 |
| `r20.bottomIsland.tools.annotate` | 1 | Anotar | 168.64 | 227.39 | 265.41 | 38.02 |
| `r20.bottomIsland.tools.toc` | 1 | Sumário | 168.64 | 289.02 | 334.58 | 45.56 |

Seção `r20.timeChip` — retângulo absoluto no canvas 390×844: **x=195, y=130, w=221.95, h=30**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 45 | `r20.timeChip` ±1 | box+text | 0 | 0 | 221.95 | 30 | `position: absolute; left: 50%; top: 130px; transform: translateX(-50%); height: 30px; padding: 0 12px 0 9px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; color: #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 46 | `r20.timeChip.icon` | icon | 10.5 | 7.5 | 15 | 15 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `r20.timeChip`: caixa visual com `transform: translateX(-50%)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `r20.timeChip.icon`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.timeChip` | 1 | 18 min hoje · contando sozinho | 19.38 | 31.5 | 208.45 | 176.95 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Papel `#1F1B17`, texto do livro `#E3D9C6`; ilhas com fundo `#2A2520`, borda `#EDE3D1`, sombra `#0B0A08`; véu `#14110E@.55`; ícones claros (variantes `_noite`); botão Tema com **lua**.
2. Todos os tokens vêm da medição (tabela de diferenças abaixo) — nada de inverter cores automaticamente.

## Armadilhas

- Fio de navalha em `r20.page.text` linha 7 «que eles foram e me fizeram.»: sobra 59.95 px · estouro com a próxima palavra 0.71 px.
- Fio de navalha em `r20.page.text` linha 19 «buscava as pupilas, a onda que»: sobra 41.67 px · estouro com a próxima palavra 0.54 px.
- `r20.bottomIsland.progressRow` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `r20.bottomIsland.progressRow.timeLeft` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `r20.page.text`.

## Diferenças em relação à prancha 20 (seções reutilizadas: page, footer, fade, topIsland, bottomIsland, timeChip)

Estas seções são as mesmas widgets da 20 (fases L20a_ilha_superior, L20b_ilha_inferior, L20c_chip_tempo); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `r20.page.text` | fonte color: #2A2520 → #E3D9C6 |
| `r20.footer.pageLabel` | fonte color: #A89D8B → #8A8073 |
| `r20.footer.percent` | fonte color: #A89D8B → #8A8073 |
| `r20.fade` | bg: "#F8F1E4@0.62" → "#14110E@0.55" |
| `r20.topIsland` | bg: "#FFFAF1" → "#2A2520"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1"; shadow: "#1A1714 3px 3px 0px 0px" → "#0B0A08 3px 3px 0px 0px" |
| `r20.topIsland.close` | bg: "#F7F0E3" → "#1F1B17"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1" |
| `r20.topIsland.title` | fonte color: #1A1714 → #EDE3D1 |
| `r20.topIsland.author` | fonte color: #5B544B → #B5AA98 |
| `r20.bottomIsland` | bg: "#FFFAF1" → "#2A2520"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1"; shadow: "#1A1714 3px 3px 0px 0px" → "#0B0A08 3px 3px 0px 0px" |
| `r20.bottomIsland.scrubber.track` | bgImage: "repeating-linear-gradient(135deg, #E9DFCC 0px, #E9DFCC 3px, #FFFAF1 3px, #FFFAF1 7px)" → "repeating-linear-gradient(135deg, #3A332B 0px, #3A332B 3px, #2A2520 3px, #2A2520 7px)"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1" |
| `r20.bottomIsland.scrubber.knob` | bg: "#FFFAF1" → "#2A2520"; border: "2px solid #1A1714" → "2px solid #EDE3D1"; shadow: "#1A1714 2px 2px 0px 0px" → "#0B0A08 2px 2px 0px 0px" |
| `r20.bottomIsland.scrubber.bubble` | bg: "#1A1714" → "#EDE3D1"; fonte color: #F7F0E3 → #1F1B17 |
| `r20.bottomIsland.scrubber.bubble.tail` | bg: "#1A1714" → "#EDE3D1" |
| `r20.bottomIsland.progressRow.position` | fonte color: #5B544B → #B5AA98 |
| `r20.bottomIsland.progressRow.position.percent` | fonte color: #1A1714 → #EDE3D1 |
| `r20.bottomIsland.progressRow.timeLeft` | fonte color: #5B544B → #B5AA98 |
| `r20.bottomIsland.tools` | border: {"top": "1.5px dashed #CFC3AE", "right": "0", "bottom": "0", "left": "0"} → {"top": "1.5px dashed #4A433A", "right": "0", "bottom": "0", "left": "0"} |
| `r20.bottomIsland.tools.font` | fonte color: #1A1714 → #EDE3D1 |
| `r20.bottomIsland.tools.font.circle` | bg: "#F7F0E3" → "#1F1B17"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1"; fonte color: #1A1714 → #EDE3D1 |
| `r20.bottomIsland.tools.theme` | fonte color: #1A1714 → #EDE3D1 |
| `r20.bottomIsland.tools.theme.circle` | bg: "#F7F0E3" → "#1F1B17"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1" |
| `r20.bottomIsland.tools.notes` | fonte color: #1A1714 → #EDE3D1 |
| `r20.bottomIsland.tools.notes.circle` | bg: "#F7F0E3" → "#1F1B17"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1" |
| `r20.bottomIsland.tools.annotate` | fonte color: #1A1714 → #EDE3D1 |
| `r20.bottomIsland.tools.annotate.circle` | bg: "#F7F0E3" → "#1F1B17"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1" |
| `r20.bottomIsland.tools.toc` | fonte color: #1A1714 → #EDE3D1 |
| `r20.bottomIsland.tools.toc.circle` | bg: "#F7F0E3" → "#1F1B17"; border: "1.5px solid #1A1714" → "1.5px solid #EDE3D1" |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `r20.page` |  | Dom Casmurro, página 159 de 256 |  |
| `r20.fade` |  |  | aria-hidden=true |
| `r20.topIsland.close` |  | Fechar o livro |  |
| `r20.topIsland.close.icon` |  |  | aria-hidden=true |
| `r20.topIsland.search` |  | Buscar no livro |  |
| `r20.topIsland.search.icon` |  |  | aria-hidden=true |
| `r20.topIsland.bookmark` |  | Página marcada | aria-pressed=true |
| `r20.topIsland.bookmark.icon` |  |  | aria-hidden=true |
| `r20.bottomIsland` |  | Controles de leitura |  |
| `r20.bottomIsland.scrubber.track` | slider | Posição no livro | aria-valuemin=1, aria-valuemax=256, aria-valuenow=159, aria-valuetext=página 159 de 256 |
| `r20.bottomIsland.scrubber.knob` |  |  | aria-hidden=true |
| `r20.bottomIsland.scrubber.bubble` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.theme.icon` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.notes.icon` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.annotate` |  | Anotar à mão |  |
| `r20.bottomIsland.tools.annotate.icon` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.toc.icon` |  |  | aria-hidden=true |
| `r20.timeChip.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `r20.fade` | NeoBox |  |
| `r20.topIsland` | NeoBox |  |
| `r20.topIsland.close` | CircleIconButton / NeoBox circular |  |
| `r20.topIsland.close.icon` | AppSvg(AppIconsLeitor.ic_arrow_left_noite, size: 20) |  |
| `r20.topIsland.search.icon` | AppSvg(AppIconsLeitor.ic_search_noite, size: 21) |  |
| `r20.topIsland.bookmark.icon` | AppSvg(AppIconsLeitor.ic_ribbon_marked_noite, size: 22) |  |
| `r20.bottomIsland` | NeoBox |  |
| `r20.bottomIsland.scrubber.track` | HatchPainter (hachura 135°) dentro do contorno |  |
| `r20.bottomIsland.scrubber.fill` | NeoBox |  |
| `r20.bottomIsland.scrubber.fill.wave` | CustomPainter (onda_preenchimento_barra_noite) | cores dinâmicas: #B6ACE4 = brand · preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): desenhar com CustomPainter esticando a forma na altura do trilho e traço fixo de 1,5. |
| `r20.bottomIsland.scrubber.knob` | CircleIconButton / NeoBox circular |  |
| `r20.bottomIsland.scrubber.bubble` | NeoBox + AppText | Transform: translateX(-50%) |
| `r20.bottomIsland.scrubber.bubble.tail` | NeoBox | Transform: rotate(45deg) |
| `r20.bottomIsland.progressRow.position.percent` | TextSpan dentro do AppText.rich do pai |  |
| `r20.bottomIsland.tools` | NeoBox |  |
| `r20.bottomIsland.tools.font.circle` | NeoBox + AppText |  |
| `r20.bottomIsland.tools.theme.circle` | NeoBox |  |
| `r20.bottomIsland.tools.theme.icon` | AppSvg(AppIconsLeitor.ic_moon, size: 21) |  |
| `r20.bottomIsland.tools.notes.circle` | NeoBox |  |
| `r20.bottomIsland.tools.notes.icon` | AppSvg(AppIconsLeitor.ic_highlighter_reader_noite, size: 21) |  |
| `r20.bottomIsland.tools.notes.badge` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `r20.bottomIsland.tools.annotate.circle` | NeoBox |  |
| `r20.bottomIsland.tools.annotate.icon` | AppSvg(AppIconsLeitor.ic_annotate_noite, size: 21) |  |
| `r20.bottomIsland.tools.toc.circle` | NeoBox |  |
| `r20.bottomIsland.tools.toc.icon` | AppSvg(AppIconsLeitor.ic_toc_noite, size: 21) |  |
| `r20.timeChip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: translateX(-50%) |
| `r20.timeChip.icon` | AppSvg(AppIconsLeitor.ic_timer, size: 15) |  |

## Interações

- Iguais à 20; o botão Tema volta ao último papel claro (D-37).

## Dados

- Tema atual (`reader_settings.theme`).

## Subfases

- **L26b.1** Tokens do tema Noite
- **L26b.2** Ilhas e ícones no Noite
- **L26b.3** Golden 26b
- **L26b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('r20.page', 'r20.footer', 'r20.fade', 'r20.topIsland', 'r20.bottomIsland', 'r20.timeChip'), todos os ids de `kRef26b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/26b_tema_noite_390x844@3x.png` no recorte da fase (y 46–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L26b.1 Tokens do tema Noite
- [ ] L26b.2 Ilhas e ícones no Noite
- [ ] L26b.3 Golden 26b
- [ ] L26b.4 Verificação + relatório
- [ ] Geometria 45/45 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
