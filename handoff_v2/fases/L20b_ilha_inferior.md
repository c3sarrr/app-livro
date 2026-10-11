# FASE L20b — Leitor com controles — ilha inferior (posição e ferramentas)

> Tela 20 · prancha `20_leitor_controles` (20 · Leitor — com controles, canvas 390×844) · executada na **G12** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L20b_ilha_inferior@3x.png` · `referencia/png/redline/L20b_ilha_inferior_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/20_leitor_controles_390x844@{1,2,3}x.png` · `referencia/layout/layout_20_leitor_controles.json` · `test/reference/leitor/reference_layout_20_leitor_controles.dart` (`kRef20`).
> Arquivos sugeridos: `lib/features/reader/presentation/bottom_island.dart`, `lib/features/reader/presentation/scrubber.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Ilha "Controles de leitura": barra de posição com balão, linha de progresso e as 5 ferramentas.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- Bottom island: book progress + tools -->
<section aria-label="Controles de leitura" style="position: absolute; left: 14px; right: 14px; bottom: 30px; padding: 30px 16px 14px; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box;">
  <!-- scrubber -->
  <div style="position: relative; height: 26px; display: flex; align-items: center;">
    <span role="slider" aria-label="Posição no livro" aria-valuemin="1" aria-valuemax="256" aria-valuenow="159" aria-valuetext="página 159 de 256" style="position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden;">
      <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 62%; background: {{brand}};">
        <svg width="10" height="15" sc-camel-view-box="0 0 10 15" sc-camel-preserve-aspect-ratio="none" style="position: absolute; top: 0; right: -5px; height: 100%;"><path d="M0 0H5Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15H0Z" fill="{{brand}}"></path><path d="M5 0Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15" fill="none" stroke="#1A1714" stroke-width="1.5" vector-effect="non-scaling-stroke"></path></svg>
      </span>
    </span>
    <!-- knob + bubble -->
    <span aria-hidden="true" style="position: absolute; left: 62%; top: 50%; width: 28px; height: 28px; margin: -14px 0 0 -14px; border-radius: 50%; background: #FFFAF1; border: 2px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box;"></span>
    <span aria-hidden="true" style="position: absolute; left: 62%; bottom: 30px; transform: translateX(-50%); height: 28px; padding: 0 10px; border-radius: 10px; background: #1A1714; display: flex; align-items: center; font-size: 12.5px; font-weight: 800; color: #F7F0E3; white-space: nowrap;">pág. 159
      <span style="position: absolute; left: 50%; bottom: -5px; width: 10px; height: 10px; margin-left: -5px; background: #1A1714; transform: rotate(45deg);"></span>
    </span>
  </div>
  <div style="margin-top: 8px; display: flex; justify-content: space-between; font-size: 12.5px; font-weight: 700; color: #5B544B; font-variant-numeric: tabular-nums;">
    <span><strong style="color: #1A1714; font-weight: 800;">62%</strong> do livro · 256 pág.</span>
    <span>≈ 2 h 10 min</span>
  </div>

  <!-- tools -->
  <div style="margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr));">
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 19px; font-weight: 500;">Aa</span>Fonte</button>
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="4"></circle><path d="M12 2v2M12 20v2M4.9 4.9l1.4 1.4M17.7 17.7l1.4 1.4M2 12h2M20 12h2M4.9 19.1l1.4-1.4M17.7 6.3l1.4-1.4"></path></svg></span>Tema</button>
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714;"><span style="position: relative; width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 11-6 6v3h9l3-3"></path><path d="m22 12-4.6 4.6a2 2 0 0 1-2.8 0l-5.2-5.2a2 2 0 0 1 0-2.8L14 4"></path></svg><span style="position: absolute; top: -8px; right: -8px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center;">12</span></span>Grifos</button>
    <button aria-label="Anotar à mão" style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16z"></path><path d="m13.5 6.5 4 4"></path><path d="M14 20h6" stroke="#FF552E"></path></svg></span>Anotar</button>
    <button style="display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714;"><span style="width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M8 6h13M8 12h13M8 18h13"></path><circle cx="3.5" cy="6" r="1" fill="#1A1714"></circle><circle cx="3.5" cy="12" r="1" fill="#1A1714"></circle><circle cx="3.5" cy="18" r="1" fill="#1A1714"></circle></svg></span>Sumário</button>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `r20.bottomIsland` — retângulo absoluto no canvas 390×844: **x=14, y=626.86, w=362, h=187.14**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `r20.bottomIsland` | box | 0 | 0 | 362 | 187.14 | `position: absolute; left: 14px; right: 14px; bottom: 30px; padding: 30px 16px 14px; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box` |  |
| 2 | `r20.bottomIsland.scrubber` | box | 17.5 | 31.5 | 327 | 26 | `position: relative; height: 26px; display: flex; align-items: center` |  |
| 3 | `r20.bottomIsland.scrubber.track` | box | 17.5 | 36.5 | 327 | 16 | `position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden` |  |
| 4 | `r20.bottomIsland.scrubber.fill` | box | 19 | 38 | 200.88 | 13 | `position: absolute; left: 0; top: 0; bottom: 0; width: 62%; background: {{brand}} (padrão #B6ACE4)` |  |
| 5 | `r20.bottomIsland.scrubber.fill.wave` | icon | 214.88 | 38 | 10 | 13 | `position: absolute; top: 0; right: -5px; height: 100%` |  |
| 6 | `r20.bottomIsland.scrubber.knob` | box | 206.24 | 30.5 | 28 | 28 | `position: absolute; left: 62%; top: 50%; width: 28px; height: 28px; margin: -14px 0 0 -14px; border-radius: 50%; background: #FFFAF1; border: 2px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box` |  |
| 7 | `r20.bottomIsland.scrubber.bubble` ±1 | box+text | 220.24 | -0.5 | 68.09 | 28 | `position: absolute; left: 62%; bottom: 30px; transform: translateX(-50%); height: 28px; padding: 0 10px; border-radius: 10px; background: #1A1714; display: flex; align-items: center; font-size: 12.5px; font-weight: 800; color: #F7F0E3; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #F7F0E3 |
| 8 | `r20.bottomIsland.scrubber.bubble.tail` ±1 | box | 249.28 | 22.5 | 10 | 10 | `position: absolute; left: 50%; bottom: -5px; width: 10px; height: 10px; margin-left: -5px; background: #1A1714; transform: rotate(45deg)` |  |
| 9 | `r20.bottomIsland.progressRow` | box | 17.5 | 65.5 | 327 | 15.24 | `margin-top: 8px; display: flex; justify-content: space-between; font-size: 12.5px; font-weight: 700; color: #5B544B; font-variant-numeric: tabular-nums` |  |
| 10 | `r20.bottomIsland.progressRow.position` ±1 | text | 17.5 | 65.5 | 132.76 | 15.24 | `—` | Figtree 12.5/normal peso 700 ls normal #5B544B tnum |
| 11 | `r20.bottomIsland.progressRow.position.percent` ±1 | inline | 17.5 | 65.5 | 26.21 | 15.01 | `color: #1A1714; font-weight: 800` | Figtree 12.5/normal peso 800 ls normal #1A1714 tnum |
| 12 | `r20.bottomIsland.progressRow.timeLeft` ±1 | text | 272.42 | 65.5 | 72.08 | 15.24 | `—` | Figtree 12.5/normal peso 700 ls normal #5B544B tnum |
| 13 | `r20.bottomIsland.tools` | box | 17.5 | 94.74 | 327 | 76.9 | `margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr))` |  |
| 14 | `r20.bottomIsland.tools.font` | text | 17.5 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 15 | `r20.bottomIsland.tools.font.circle` | box+text | 24.2 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 19px; font-weight: 500` | Literata (opsz 19) 19/normal peso 500 ls normal #1A1714 |
| 16 | `r20.bottomIsland.tools.theme` | text | 82.9 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 17 | `r20.bottomIsland.tools.theme.circle` | box | 89.6 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 18 | `r20.bottomIsland.tools.theme.icon` | icon | 105.1 | 119.74 | 21 | 21 | `—` |  |
| 19 | `r20.bottomIsland.tools.notes` | text | 148.3 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 20 | `r20.bottomIsland.tools.notes.circle` | box | 155 | 108.24 | 52 | 44 | `position: relative; width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 21 | `r20.bottomIsland.tools.notes.icon` | icon | 170.5 | 119.74 | 21 | 21 | `—` |  |
| 22 | `r20.bottomIsland.tools.notes.badge` ±1 | box+text | 189.35 | 101.74 | 24.15 | 22 | `position: absolute; top: -8px; right: -8px; min-width: 22px; height: 22px; padding: 0 5px; box-sizing: border-box; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; font-size: 11px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 11/normal peso 800 ls normal #1A1714 |
| 23 | `r20.bottomIsland.tools.annotate` | text | 213.7 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 24 | `r20.bottomIsland.tools.annotate.circle` | box | 220.4 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 25 | `r20.bottomIsland.tools.annotate.icon` | icon | 235.9 | 119.74 | 21 | 21 | `—` |  |
| 26 | `r20.bottomIsland.tools.toc` | text | 279.1 | 108.24 | 65.4 | 63.4 | `display: flex; flex-direction: column; align-items: center; gap: 5px; padding: 0; border: none; background: transparent; font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 27 | `r20.bottomIsland.tools.toc.circle` | box | 285.8 | 108.24 | 52 | 44 | `width: 52px; height: 44px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 28 | `r20.bottomIsland.tools.toc.icon` | icon | 301.3 | 119.74 | 21 | 21 | `—` |  |

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

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Ilha: `left/right 14 · bottom 30`, padding 30/16/14, raio 28, `#FFFAF1`, borda 1,5, sombra 3/3 → 362 × 187,14.
2. Barra (`role=slider`, valor 159 de 1–256): trilho 16 de altura, raio 999, borda 1,5, **hachura 135° `#E9DFCC`/`#FFFAF1` (3/7 px)** — reutilizar `HatchPainter` com as cores do leitor; preenchimento `brand` até 62 % terminando numa **onda** (SVG 10×15 esticado na altura, traço 1,5 sem escala → CustomPainter).
3. Botão 28×28 (borda 2, sombra 2/2) centrado em 62 %; balão preto "pág. 159" (Figtree 12,5/800 `#F7F0E3`, raio 10, `translateX(-50%)`) com bico de 10×10 girado 45°.
4. Linha de progresso: "**62%** do livro · 256 pág." (12,5; `strong` 800 `#1A1714`, resto 700 `#5B544B`) × "≈ 2 h 10 min", tabulares, `space-between`.
5. Ferramentas: faixa com traço tracejado `#CFC3AE` em cima (padding-top 12) e 5 colunas iguais; cada uma = caixa 52×44 raio 16 `#F7F0E3` com borda 1,5 (ícone 21, ou "Aa" em Literata 19/500 na Fonte) + rótulo Figtree 12/700. Contador amarelo "12" (`#FED170`, borda 1,5, raio 999, Figtree 11/800) sobre "Grifos" em `top −8 · right −8`.

## Armadilhas

- "≈" não existe na Figtree: no navegador cai numa fonte do sistema (na medição, Inter Bold). Decisão pendente (relatório G01).
- `r20.bottomIsland.progressRow` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `r20.bottomIsland.progressRow.timeLeft` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `r20.bottomIsland` |  | Controles de leitura |  |
| `r20.bottomIsland.scrubber.track` | slider | Posição no livro | aria-valuemin=1, aria-valuemax=256, aria-valuenow=159, aria-valuetext=página 159 de 256 |
| `r20.bottomIsland.scrubber.knob` |  |  | aria-hidden=true |
| `r20.bottomIsland.scrubber.bubble` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.theme.icon` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.notes.icon` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.annotate` |  | Anotar à mão |  |
| `r20.bottomIsland.tools.annotate.icon` |  |  | aria-hidden=true |
| `r20.bottomIsland.tools.toc.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `r20.bottomIsland` | NeoBox |  |
| `r20.bottomIsland.scrubber.track` | HatchPainter (hachura 135°) dentro do contorno |  |
| `r20.bottomIsland.scrubber.fill` | NeoBox |  |
| `r20.bottomIsland.scrubber.fill.wave` | CustomPainter (onda_preenchimento_barra) | cores dinâmicas: #B6ACE4 = brand · preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): desenhar com CustomPainter esticando a forma na altura do trilho e traço fixo de 1,5. |
| `r20.bottomIsland.scrubber.knob` | CircleIconButton / NeoBox circular |  |
| `r20.bottomIsland.scrubber.bubble` | NeoBox + AppText | Transform: translateX(-50%) |
| `r20.bottomIsland.scrubber.bubble.tail` | NeoBox | Transform: rotate(45deg) |
| `r20.bottomIsland.progressRow.position.percent` | TextSpan dentro do AppText.rich do pai |  |
| `r20.bottomIsland.tools` | NeoBox |  |
| `r20.bottomIsland.tools.font.circle` | NeoBox + AppText |  |
| `r20.bottomIsland.tools.theme.circle` | NeoBox |  |
| `r20.bottomIsland.tools.theme.icon` | AppSvg(AppIconsLeitor.ic_sun, size: 21) |  |
| `r20.bottomIsland.tools.notes.circle` | NeoBox |  |
| `r20.bottomIsland.tools.notes.icon` | AppSvg(AppIconsLeitor.ic_highlighter_reader, size: 21) |  |
| `r20.bottomIsland.tools.notes.badge` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `r20.bottomIsland.tools.annotate.circle` | NeoBox |  |
| `r20.bottomIsland.tools.annotate.icon` | AppSvg(AppIconsLeitor.ic_annotate, size: 21) |  |
| `r20.bottomIsland.tools.toc.circle` | NeoBox |  |
| `r20.bottomIsland.tools.toc.icon` | AppSvg(AppIconsLeitor.ic_toc, size: 21) |  |

## Interações

- Arrastar a barra mostra o balão e só navega ao soltar (D-22).
- Aa → tela 26 · Tema → alterna Creme/Noite (D-37) · Grifos → tela 25 · Anotar → tela 22 · Sumário → tela 27.

## Dados

- Progresso (62 %), total de páginas (256), tempo restante (Anexo 03 §8), contador = total de anotações do livro (6 + 2 + 1 + 3 = 12).

## Subfases

- **L20b.1** Ilha
- **L20b.2** Barra de posição (hachura + onda + botão + balão)
- **L20b.3** Linha de progresso
- **L20b.4** Ferramentas + contador
- **L20b.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('r20.bottomIsland'), todos os ids de `kRef20.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/20_leitor_controles_390x844@3x.png` no recorte da fase (y 618.36–822) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L20b.1 Ilha
- [ ] L20b.2 Barra de posição (hachura + onda + botão + balão)
- [ ] L20b.3 Linha de progresso
- [ ] L20b.4 Ferramentas + contador
- [ ] L20b.5 Verificação + relatório
- [ ] Geometria 27/27 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
