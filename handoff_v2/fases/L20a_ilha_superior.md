# FASE L20a — Leitor com controles — página esmaecida e ilha superior

> Tela 20 · prancha `20_leitor_controles` (20 · Leitor — com controles, canvas 390×844) · executada na **G12** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L20a_ilha_superior@3x.png` · `referencia/png/redline/L20a_ilha_superior_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/20_leitor_controles_390x844@{1,2,3}x.png` · `referencia/layout/layout_20_leitor_controles.json` · `test/reference/leitor/reference_layout_20_leitor_controles.dart` (`kRef20`).
> Arquivos sugeridos: `lib/features/reader/presentation/top_island.dart`, `lib/features/reader/presentation/page_fade.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Controles abertos: a página esmaece e a ilha superior aparece. O rodapé some (ainda existe no layout, coberto pelo véu).

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- The page -->
<article aria-label="Dom Casmurro, página 159 de 256" style="position: absolute; left: 28px; right: 28px; top: 92px; bottom: 82px; overflow: hidden;">
  <p style="margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em;">Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles olhos de Capitu. Não me acode imagem capaz de dizer, sem quebra da dignidade do estilo, o que eles foram e me fizeram. Olhos de ressaca? Vá, de ressaca. É o que me dá ideia daquela feição nova. Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, como a vaga que se retira da praia, nos dias de ressaca. Para não ser arrastado, agarrei-me às outras partes vizinhas, às orelhas, aos braços, aos cabelos espalhados pelos ombros; mas tão depressa buscava as pupilas, a onda que saía delas vinha crescendo, cava e escura, ameaçando envolver-me, puxar-me e tragar-me.</p>
</article>

<!-- Footer hidden while controls are up -->
<div style="display: none; position: absolute; left: 28px; right: 28px; bottom: 40px; display: flex; justify-content: space-between; align-items: center; font-size: 11.5px; font-weight: 600; color: #A89D8B; font-variant-numeric: tabular-nums;">
  <span>pág. 159 de 256</span>
  <span>62%</span>
</div>

<!-- page fades back while the controls are up -->
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(248,241,228,0.62);"></div>

<!-- Top island -->
<header style="position: absolute; left: 14px; right: 14px; top: 54px; height: 62px; padding: 0 8px; border-radius: 31px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px;">
  <a href="#" aria-label="Fechar o livro" style="width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
  <span style="min-width: 0; flex-grow: 1;">
    <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.1; letter-spacing: -0.3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Dom Casmurro</span>
    <span style="display: block; margin-top: 1px; font-size: 12.5px; font-weight: 600; color: #5B544B; white-space: nowrap;">Machado de Assis</span>
  </span>
  <button aria-label="Buscar no livro" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg></button>
  <button aria-label="Página marcada" aria-pressed="true" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center;">
    <svg width="22" height="24" sc-camel-view-box="0 0 22 24" aria-hidden="true"><path d="M4 2h14v20l-7-5-7 5z" fill="#FF552E" stroke="#1A1714" stroke-width="1.8" stroke-linejoin="round"></path></svg>
  </button>
</header>
```

## Especificação pixel a pixel

Seção `r20.page` — retângulo absoluto no canvas 390×844: **x=28, y=92, w=334, h=670**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `r20.page` | box | 0 | 0 | 334 | 670 | `position: absolute; left: 28px; right: 28px; top: 92px; bottom: 82px; overflow: hidden` |  |
| 2 | `r20.page.text` | text | 0 | 0 | 334 | 775.72 | `margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |

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
| 3 | `r20.footer` | box | 0 | 0 | 334 | 13.81 | `display: none; position: absolute; left: 28px; right: 28px; bottom: 40px; display: flex; justify-content: space-between; align-items: center; font-size: 11.5px; font-weight: 600; color: #A89D8B; font-variant-numeric: tabular-nums` |  |
| 4 | `r20.footer.pageLabel` ±1 | text | 0 | 0 | 87.22 | 13.81 | `—` | Figtree 11.5/normal peso 600 ls normal #A89D8B tnum |
| 5 | `r20.footer.percent` ±1 | text | 310.31 | 0 | 23.69 | 13.81 | `—` | Figtree 11.5/normal peso 600 ls normal #A89D8B tnum |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.footer.pageLabel` | 1 | pág. 159 de 256 | 10.93 | 0 | 87.22 | 87.22 |
| `r20.footer.percent` | 1 | 62% | 10.93 | 310.31 | 334 | 23.69 |

Seção `r20.fade` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `r20.fade` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background: rgba(248,241,228,0.62)` |  |

Seção `r20.topIsland` — retângulo absoluto no canvas 390×844: **x=14, y=54, w=362, h=62**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 7 | `r20.topIsland` | box | 0 | 0 | 362 | 62 | `position: absolute; left: 14px; right: 14px; top: 54px; height: 62px; padding: 0 8px; border-radius: 31px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px` |  |
| 8 | `r20.topIsland.close` | box | 9.5 | 9 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `r20.topIsland.close.icon` | icon | 21.5 | 21 | 20 | 20 | `—` |  |
| 10 | `r20.topIsland.titleBlock` | box | 63.5 | 13.64 | 181 | 34.71 | `min-width: 0; flex-grow: 1` |  |
| 11 | `r20.topIsland.title` | text | 63.5 | 13.64 | 181 | 18.7 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.1; letter-spacing: -0.3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Bricolage (opsz 17) 17/18.7px peso 800 ls -0.3px #1A1714 |
| 12 | `r20.topIsland.author` | text | 63.5 | 33.34 | 181 | 15.01 | `display: block; margin-top: 1px; font-size: 12.5px; font-weight: 600; color: #5B544B; white-space: nowrap` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 13 | `r20.topIsland.search` | box | 254.5 | 9 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center` |  |
| 14 | `r20.topIsland.search.icon` | icon | 266 | 20.5 | 21 | 21 | `—` |  |
| 15 | `r20.topIsland.bookmark` | box | 308.5 | 9 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: transparent; border: none; display: flex; align-items: center; justify-content: center` |  |
| 16 | `r20.topIsland.bookmark.icon` | icon | 319.5 | 19 | 22 | 24 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.topIsland.title` | 1 | Dom Casmurro | 28.61 | 63.5 | 185.81 | 122.31 |
| `r20.topIsland.author` | 1 | Machado de Assis | 45.22 | 63.5 | 165.4 | 101.9 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Véu `fade` (tela inteira) com `paper` a 62 % (`#F8F1E4@0.62`) por cima da página — a página fica no lugar, só esmaece. Na Noite (26b) o véu é `#14110E@0.55`.
2. Ilha superior: `left/right 14 · top 54`, altura 62, raio 31, fundo `#FFFAF1`, borda 1,5, sombra dura 3/3. Padding horizontal 8.
3. Fechar (44×44, círculo `#F7F0E3`, seta 20) · título "Dom Casmurro" Bricolage 17/800 + autor Figtree 12,5/600 `#5B544B` (bloco 181 de largura, título com `nowrap` + `text-overflow: ellipsis` — não é efetivo aqui, mas implemente o "…" para títulos longos) · Buscar (lupa 21) · fita do marcador (22×24, coral `#FF552E`).
4. A fita é um `button` com `aria-pressed="true"` (página marcada): toggle real que cria/remove o marcador (lista da 27b).

## Armadilhas

- Fio de navalha em `r20.page.text` linha 7 «que eles foram e me fizeram.»: sobra 59.95 px · estouro com a próxima palavra 0.71 px.
- Fio de navalha em `r20.page.text` linha 19 «buscava as pupilas, a onda que»: sobra 41.67 px · estouro com a próxima palavra 0.54 px.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `r20.page.text`.

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

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `r20.fade` | NeoBox |  |
| `r20.topIsland` | NeoBox |  |
| `r20.topIsland.close` | CircleIconButton / NeoBox circular |  |
| `r20.topIsland.close.icon` | AppSvg(AppIconsLeitor.ic_arrow_left, size: 20) |  |
| `r20.topIsland.search.icon` | AppSvg(AppIconsLeitor.ic_search, size: 21) |  |
| `r20.topIsland.bookmark.icon` | AppSvg(AppIconsLeitor.ic_ribbon_marked, size: 22) |  |

## Interações

- Fechar → sai do leitor (volta à rota anterior).
- Buscar → busca no livro (UI mínima D-23).
- Fita → marca/desmarca a página atual.

## Dados

- Título/autor do livro; marcador existe na página de referência atual?

## Subfases

- **L20a.1** Véu da página
- **L20a.2** Ilha e botões
- **L20a.3** Título com reticências
- **L20a.4** Fita (toggle + semântica pressed)
- **L20a.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('r20.page', 'r20.footer', 'r20.fade', 'r20.topIsland'), todos os ids de `kRef20.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/20_leitor_controles_390x844@3x.png` no recorte da fase (y 46–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L20a.1 Véu da página
- [ ] L20a.2 Ilha e botões
- [ ] L20a.3 Título com reticências
- [ ] L20a.4 Fita (toggle + semântica pressed)
- [ ] L20a.5 Verificação + relatório
- [ ] Geometria 16/16 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
