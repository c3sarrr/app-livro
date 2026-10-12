# FASE L28b — Busca (resultados) — as abas por tipo e os livros (o seu e o novo)

> Tela 28b · prancha `028b_busca_resultados` (28b · Busca — resultados (“capitu”), canvas 390×1040) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28b_1_abas_e_livros@3x.png` · `docs/design/medicao/projeto/png/redline/L28b_1_abas_e_livros_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028b_busca_resultados_390x1040@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028b_busca_resultados.json` · `test/reference/projeto/reference_layout_028b_busca_resultados.dart` (`kRef28b`).
> Arquivos sugeridos: `lib/features/search/presentation/search_results.dart`, `lib/features/search/presentation/results/result_tabs.dart`, `lib/features/search/presentation/results/book_result_row.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Resultados da busca ("capitu", 28b): as abas por tipo (Tudo 18 · Livros 9 · Clubes 6 · Seus trechos 3) com a máscara que apaga a direita, e os livros — Dom Casmurro, que já está na estante, com a seta, e um livro novo com o "+".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div role="tablist" aria-label="Tipo de resultado" style="margin: 0 -16px; padding: 4px 16px 4px; display: flex; gap: 8px; overflow: hidden; -webkit-mask-image: linear-gradient(90deg, #000 88%, transparent); mask-image: linear-gradient(90deg, #000 88%, transparent);"><button role="tab" aria-selected="true" style="height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap;">Tudo <span style="font-weight: 700; color: #3B3466;">18</span></button><button role="tab" aria-selected="false" style="height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap;">Livros <span style="font-weight: 700; color: #8A8073;">9</span></button><button role="tab" aria-selected="false" style="height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap;">Clubes <span style="font-weight: 700; color: #8A8073;">6</span></button><button role="tab" aria-selected="false" style="height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap;">Seus trechos <span style="font-weight: 700; color: #8A8073;">3</span></button></div>

<div style="margin-top: 20px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px;">Livros</h2><a href="#" style="font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px;">Ver os 9</a></div>

<div style="margin-top: 4px;"><a href="#" style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 14px;"><span aria-hidden="true" style="position: relative; display: block; width: 58px; height: 84px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg);"><span style="position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35);"></span><svg width="100%" height="40" viewBox="0 0 58 40" style="position: absolute; left: 0; top: 22px;"><path d="M20 22c6-9 18-9 24 0-6 9-18 9-24 0Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3"></path><circle cx="32" cy="22" r="4.5" fill="#1A1714"></circle></svg></span><span style="min-width: 0; flex-grow: 1;"><span style="display: block; font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1.2; font-weight: 500;">Dom Casmurro</span><span style="display: block; margin-top: 3px; font-size: 13px; font-weight: 600; color: #5B544B;">Machado de Assis</span><span style="margin-top: 7px; display: flex; align-items: center; gap: 8px;"><span style="height: 24px; padding: 0 8px; border-radius: 999px; background: #ABCF82; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 11px; font-weight: 800; white-space: nowrap;">NA SUA ESTANTE</span><span style="font-size: 12px; font-weight: 700; color: #6F665B; white-space: nowrap;">e-book · 62%</span></span><span style="display: block; margin-top: 6px; font-size: 12px; font-weight: 600; color: #8A8073;"><mark style="background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px;">Capitu</mark> é a personagem principal</span></span><span aria-hidden="true" style="width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg></span></a><a href="#" style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 14px;"><span aria-hidden="true" style="position: relative; display: block; width: 58px; height: 84px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg);"><span style="position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35);"></span><svg width="100%" height="40" viewBox="0 0 58 40" style="position: absolute; left: 0; top: 18px;"><path d="M14 26q5-6 10 0t10 0 10 0" fill="none" stroke="#1A1714" stroke-width="1.6" stroke-linecap="round"></path><path d="M18 34q5-6 10 0t10 0" fill="none" stroke="#1A1714" stroke-width="1.6" stroke-linecap="round"></path></svg></span><span style="min-width: 0; flex-grow: 1;"><span style="display: block; font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1.2; font-weight: 500;"><mark style="background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px;">Capitu</mark>: memórias póstumas</span><span style="display: block; margin-top: 3px; font-size: 13px; font-weight: 600; color: #5B544B;">Domício Proença Filho</span><span style="display: block; margin-top: 6px; font-size: 12px; font-weight: 600; color: #8A8073;">romance · 1998</span></span><button aria-label="Adicionar à estante" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg></button></a></div>
```

## Especificação pixel a pixel

Seção `bu28b.tabs` — retângulo absoluto no canvas 390×1040: **x=0, y=122, w=390, h=46**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28b.tabs` | box | 0 | 0 | 390 | 46 | `margin: 0 -16px; padding: 4px 16px 4px; display: flex; gap: 8px; overflow: hidden; -webkit-mask-image: linear-gradient(90deg, #000 88%, transparent); mask-image: linear-gradient(90deg, #000 88%, transparent)` |  |
| 2 | `bu28b.tabs.all` ±1 | box+text | 16 | 4 | 77.44 | 38 | `height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 3 | `bu28b.tabs.all.count` ±1 | inline | 64.98 | 14.9 | 13.96 | 16.21 | `font-weight: 700; color: #3B3466` | Figtree 13.5/normal peso 700 ls normal #3B3466 |
| 4 | `bu28b.tabs.books` ±1 | box+text | 101.44 | 4 | 78.5 | 38 | `height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 5 | `bu28b.tabs.books.count` ±1 | inline | 157.61 | 14.9 | 7.83 | 16.21 | `font-weight: 700; color: #8A8073` | Figtree 13.5/normal peso 700 ls normal #8A8073 |
| 6 | `bu28b.tabs.clubs` ±1 | box+text | 187.94 | 4 | 83.15 | 38 | `height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 7 | `bu28b.tabs.clubs.count` ±1 | inline | 248.76 | 14.9 | 7.83 | 16.21 | `font-weight: 700; color: #8A8073` | Figtree 13.5/normal peso 700 ls normal #8A8073 |
| 8 | `bu28b.tabs.highlights` ±1 | box+text | 279.09 | 4 | 120.73 | 38 | `height: 38px; padding: 0 13px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1; box-sizing: border-box; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 9 | `bu28b.tabs.highlights.count` ±1 | inline | 377.82 | 14.9 | 7.51 | 16.21 | `font-weight: 700; color: #8A8073` | Figtree 13.5/normal peso 700 ls normal #8A8073 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28b.tabs.all` *(composto)* | 1 | Tudo 18 | 27.72 | 30.5 | 78.94 | 48.44 |
| `bu28b.tabs.books` *(composto)* | 1 | Livros 9 | 27.72 | 115.94 | 165.44 | 49.5 |
| `bu28b.tabs.clubs` *(composto)* | 1 | Clubes 6 | 27.72 | 202.44 | 256.59 | 54.15 |
| `bu28b.tabs.highlights` *(composto)* | 1 | Seus trechos 3 | 27.72 | 293.59 | 385.32 | 91.73 |

Seção `bu28b.books` — retângulo absoluto no canvas 390×1040: **x=16, y=188, w=358, h=255.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 10 | `bu28b.books.header` | box | 0 | 0 | 358 | 25.2 | `margin-top: 20px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 11 | `bu28b.books.title` ±1 | text | 0 | 0 | 59.89 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px` | Bricolage (opsz 21) 21/normal peso 800 ls -0.4px #1A1714 |
| 12 | `bu28b.books.seeAll` ±1 | text | 309 | 7.18 | 49 | 15.6 | `font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 13 | `bu28b.books.list` | box | 0 | 29.2 | 358 | 226 | `margin-top: 4px` |  |
| 14 | `bu28b.books.result1` | box | 0 | 29.2 | 358 | 116.8 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 14px` |  |
| 15 | `bu28b.books.result1.cover` | box | 0 | 45 | 58 | 84 | `position: relative; display: block; width: 58px; height: 84px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg)` |  |
| 16 | `bu28b.books.result1.cover.spine` | box | 8.5 | 46.5 | 1.5 | 81 | `position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35)` |  |
| 17 | `bu28b.books.result1.cover.art` | icon | 1.5 | 68.5 | 55 | 40 | `position: absolute; left: 0; top: 22px` |  |
| 18 | `bu28b.books.result1.textBlock` | box | 72 | 41.2 | 228 | 91.6 | `min-width: 0; flex-grow: 1` |  |
| 19 | `bu28b.books.result1.title` | text | 72 | 41.2 | 228 | 21.6 | `display: block; font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1.2; font-weight: 500` | Literata (opsz 18) 18/21.6px peso 500 ls normal #1A1714 |
| 20 | `bu28b.books.result1.author` | text | 72 | 65.8 | 228 | 15.6 | `display: block; margin-top: 3px; font-size: 13px; font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B |
| 21 | `bu28b.books.result1.status` | box | 72 | 88.4 | 228 | 24 | `margin-top: 7px; display: flex; align-items: center; gap: 8px` |  |
| 22 | `bu28b.books.result1.status.chip` ±1 | box+text | 72 | 88.4 | 111.31 | 24 | `height: 24px; padding: 0 8px; border-radius: 999px; background: #ABCF82; border: 1.3px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 11px; font-weight: 800; white-space: nowrap` | Figtree 11/normal peso 800 ls normal #1A1714 |
| 23 | `bu28b.books.result1.status.progress` ±1 | text | 191.31 | 93.2 | 71.59 | 14.4 | `font-size: 12px; font-weight: 700; color: #6F665B; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #6F665B |
| 24 | `bu28b.books.result1.match` | text | 72 | 118.4 | 228 | 14.4 | `display: block; margin-top: 6px; font-size: 12px; font-weight: 600; color: #8A8073` | Figtree 12/normal peso 600 ls normal #8A8073 |
| 25 | `bu28b.books.result1.match.mark` ±1 | inline | 72 | 118.4 | 38.61 | 14.4 | `background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px` | Figtree 12/normal peso 600 ls normal #8A8073 |
| 26 | `bu28b.books.result1.open` | box | 314 | 65 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 27 | `bu28b.books.result1.open.icon` | icon | 327 | 78 | 18 | 18 | `—` |  |
| 28 | `bu28b.books.result2` | box | 0 | 146 | 358 | 109.2 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 14px` |  |
| 29 | `bu28b.books.result2.cover` | box | 0 | 158 | 58 | 84 | `position: relative; display: block; width: 58px; height: 84px; flex-shrink: 0; border-radius: 6px 12px 12px 6px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(0deg)` |  |
| 30 | `bu28b.books.result2.cover.spine` | box | 8.5 | 159.5 | 1.5 | 81 | `position: absolute; left: 7px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.35)` |  |
| 31 | `bu28b.books.result2.cover.art` | icon | 1.5 | 177.5 | 55 | 40 | `position: absolute; left: 0; top: 18px` |  |
| 32 | `bu28b.books.result2.textBlock` | box | 72 | 158.9 | 228 | 82.2 | `min-width: 0; flex-grow: 1` |  |
| 33 | `bu28b.books.result2.title` | text | 72 | 158.9 | 228 | 43.2 | `display: block; font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1.2; font-weight: 500` | Literata (opsz 18) 18/21.6px peso 500 ls normal #1A1714 |
| 34 | `bu28b.books.result2.title.mark` ±1 | inline | 72 | 156.33 | 60.13 | 26.73 | `background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px` | Literata (opsz 18) 18/21.6px peso 500 ls normal #1A1714 |
| 35 | `bu28b.books.result2.author` | text | 72 | 205.1 | 228 | 15.6 | `display: block; margin-top: 3px; font-size: 13px; font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B |
| 36 | `bu28b.books.result2.meta` | text | 72 | 226.7 | 228 | 14.4 | `display: block; margin-top: 6px; font-size: 12px; font-weight: 600; color: #8A8073` | Figtree 12/normal peso 600 ls normal #8A8073 |
| 37 | `bu28b.books.result2.add` | box | 314 | 178 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 38 | `bu28b.books.result2.add.icon` | icon | 327 | 191 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28b.books.title` | 1 | Livros | 19.53 | 0 | 59.89 | 59.89 |
| `bu28b.books.seeAll` | 1 | Ver os 9 | 19.53 | 309 | 358 | 49 |
| `bu28b.books.result1.title` | 1 | Dom Casmurro | 59.82 | 72 | 205.39 | 133.39 |
| `bu28b.books.result1.author` | 1 | Machado de Assis | 78.15 | 72 | 177.98 | 105.98 |
| `bu28b.books.result1.status.chip` | 1 | NA SUA ESTANTE | 104.25 | 81.3 | 174.01 | 92.71 |
| `bu28b.books.result1.status.progress` | 1 | e-book · 62% | 104.6 | 191.31 | 262.9 | 71.59 |
| `bu28b.books.result1.match` *(composto)* | 1 | Capitu é a personagem principal | 129.8 | 73 | 250.09 | 177.09 |
| `bu28b.books.result2.title` *(composto)* | 1 | Capitu: memórias | 177.52 | 73 | 229.84 | 156.84 |
| `bu28b.books.result2.title` *(composto)* | 2 | póstumas | 199.12 | 72 | 156.75 | 84.75 |
| `bu28b.books.result2.author` | 1 | Domício Proença Filho | 217.45 | 72 | 203.91 | 131.91 |
| `bu28b.books.result2.meta` | 1 | romance · 1998 | 238.1 | 72 | 154.93 | 82.93 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Abas (`margin 0 −16`, padding 4/16, gap 8, `overflow: hidden`) com a máscara `linear-gradient(90deg, #000 88%, transparente)`: pílulas de 38, padding 0/13, borda 1,5, 13,5/800; a marcada em `{{brand}}` com sombra 2/2 e o número `#3B3466`; as outras `#FFFAF1` com o número `#8A8073`.
2. "Livros" Bricolage 21/800 e "Ver os 9", 20 abaixo; linhas com padding 12/0 e a borda de baixo 1,2 `dashed #D9CCB4`, gap 14.
3. Linha: capa 58 × 84 (raio 6/12/12/6, sombra 2/2, o desenho centrado); o título em Literata 18/500 `lh 1,2`, o autor 13/600; "NA SUA ESTANTE" (pílula de 24 `#ABCF82`, borda 1,3, 11/800) + "e-book · 62%" 12/700; a linha do porquê 12/600 `#8A8073` com "Capitu" grifado (`mark`: amarelo de 55 % para baixo).
4. À direita: a seta num círculo preto 44 (o livro da estante) ou o "+" num círculo `#FFFAF1` 44 (o novo).
5. O que muda da 28 na barra: o anel de foco `{{brand}}` de 4, o X de limpar e a lupa encolhida.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Com o X de limpar, a lupa do campo encolhe no flex (20 → 16,78 de largura; a altura fica 20 — T13.5): decidir na T15 se o app repete.
- A máscara das abas (`ShaderMask`) apaga as últimas 12 %: a aba "Seus trechos" fica meio apagada na borda.
- O grifo do termo (`mark`) é um degradê de 55 % para baixo, `padding 0 1`: o `TextSpan` com fundo não faz meia altura — pintar por trás das letras (como o marca-texto dos grifos).
- `bu28b.tabs` tem máscara `linear-gradient(90deg, #000000 88%, #000000@0)` → `ShaderMask`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028b_busca_resultados_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028b_busca_resultados_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `bu28b.tabs.highlights` | sai do quadro (x) | 39.82 | 9.82 | não | sim |  |
| 360 | `bu28b.tabs.highlights` | passa do pai (x) | 39.82 | 9.82 | não | sim | pai `bu28b.tabs` (cortado) |

## Diferenças em relação à prancha 28 (seções reutilizadas: searchBar)

Estas seções são as mesmas widgets da 28 (fases L28_1_busca_e_titulo, L28_2_recentes_e_clima, L28_3_generos, L28_4_em_alta); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `bu28b.searchBar` | position: {"top": "54px", "right": "16px", "bottom": "1416px", "left": "16px"} → {"top": "54px", "right": "16px", "bottom": "936px", "left": "16px"} |
| `bu28b.searchBar.field` | shadow: null → "#B6ACE4 0px 0px 0px 4px" |
| `bu28b.searchBar.field.icon` | retângulo ['87.5', '69', '20', '20'] → ['87.5', '69', '16.78', '20'] |
| `bu28b.searchBar.field.input` | retângulo ['116.5', '55.5', '186', '47'] → ['113.28', '55.5', '156.22', '47'] |

Só nesta prancha: `searchBar.field.clear`, `searchBar.field.clear.icon`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28b.tabs` | tablist | Tipo de resultado |  |
| `bu28b.tabs.all` | tab |  | aria-selected=true |
| `bu28b.tabs.books` | tab |  | aria-selected=false |
| `bu28b.tabs.clubs` | tab |  | aria-selected=false |
| `bu28b.tabs.highlights` | tab |  | aria-selected=false |
| `bu28b.books.result1.cover` |  |  | aria-hidden=true |
| `bu28b.books.result1.open` |  |  | aria-hidden=true |
| `bu28b.books.result1.open.icon` |  |  | aria-hidden=true |
| `bu28b.books.result2.cover` |  |  | aria-hidden=true |
| `bu28b.books.result2.add` |  | Adicionar à estante |  |
| `bu28b.books.result2.add.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28b.tabs.all` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28b.tabs.all.count` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.tabs.books` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28b.tabs.books.count` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.tabs.clubs` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28b.tabs.clubs.count` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.tabs.highlights` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28b.tabs.highlights.count` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.books.result1` | NeoBox |  |
| `bu28b.books.result1.cover` | NeoBox | Transform: rotate(0deg) |
| `bu28b.books.result1.cover.spine` | NeoBox |  |
| `bu28b.books.result1.cover.art` | AppSvg(AppIllustrationsScanner.capaDomCasmurroOlho, size: 55×40) | width="100%" (a largura da caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa (BoxFit.contain, centrada). |
| `bu28b.books.result1.status.chip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28b.books.result1.match.mark` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.books.result1.open` | CircleIconButton / NeoBox circular |  |
| `bu28b.books.result1.open.icon` | AppSvg(AppIconsScanner.arrowNextPapel, size: 18) |  |
| `bu28b.books.result2` | NeoBox |  |
| `bu28b.books.result2.cover` | NeoBox | Transform: rotate(0deg) |
| `bu28b.books.result2.cover.spine` | NeoBox |  |
| `bu28b.books.result2.cover.art` | AppSvg(AppIllustrationsScanner.capaCapituMemorias, size: 55×40) | width="100%" (a largura da caixa da capa): o arquivo sai com a largura medida; no app, a ilustração ocupa a caixa da capa (BoxFit.contain, centrada). |
| `bu28b.books.result2.title.mark` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.books.result2.add` | CircleIconButton / NeoBox circular |  |
| `bu28b.books.result2.add.icon` | AppSvg(AppIconsScanner.plusAdd, size: 18) |  |

## Interações

- Aba → filtra por tipo; "Ver os 9" → a aba Livros.
- Livro da estante → os Detalhes (17).
- "+" → adiciona o livro à estante: com que status e se abre a folha do Scanner (03) é pergunta da T15.
- X do campo → limpa e volta para o Explorar (28).

## Dados

- Livros do catálogo (a API de livros "a definir" na nota do design; hoje, as camadas do catálogo da G07), guardados em cache; "NA SUA ESTANTE" e o progresso do banco local; o grifo amarelo marca o termo buscado no título e na linha do porquê.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L28b.1** Abas por tipo com a máscara
- **L28b.2** Linha de livro (na estante × novo)
- **L28b.3** Termo grifado
- **L28b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28b.tabs', 'bu28b.books'), todos os ids de `kRef28b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028b_busca_resultados_390x1040@3x.png` no recorte da fase (y 114–451.2) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28bw360` e `kRef28bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28b.1 Abas por tipo com a máscara
- [ ] L28b.2 Linha de livro (na estante × novo)
- [ ] L28b.3 Termo grifado
- [ ] L28b.4 Verificação + relatório
- [ ] Geometria 32/32 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
