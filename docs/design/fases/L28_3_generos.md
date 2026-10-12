# FASE L28 — Busca (Explorar) — os 8 gêneros (cada um com o livrinho inclinado)

> Tela 28 · prancha `028_busca_explorar` (28 · Busca — Explorar (antes de digitar), canvas 390×1520) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28_3_generos@3x.png` · `docs/design/medicao/projeto/png/redline/L28_3_generos_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028_busca_explorar.json` · `test/reference/projeto/reference_layout_028_busca_explorar.dart` (`kRef28`).
> Arquivos sugeridos: `lib/features/search/presentation/sections/genre_tiles.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Busca (Explorar): os 8 gêneros em blocos coloridos de 2 colunas (Romance, Fantasia, Clássicos brasileiros, Suspense, Ficção científica, Poesia, Não ficção, Quadrinhos), cada um com um livrinho inclinado no canto, e "Ver todos".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px;">Gêneros</h2><a href="#" style="font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px;">Ver todos</a></div>

<div style="margin-top: 12px; display: grid; grid-template-columns: 1fr 1fr; gap: 10px;"><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714;">Romance</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714;">Fantasia</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714;">Clássicos brasileiros</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #00995E; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #552CB7; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #F7F0E3;">Suspense</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #058CD7; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #F7F0E3;">Ficção científica</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714;">Poesia</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #F2A815; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714;">Não ficção</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a><a href="#" style="position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block;"><span style="position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714;">Quadrinhos</span><span aria-hidden="true" style="position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg);"><span style="position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4);"></span><span style="position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714;"></span><span style="position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6;"></span></span></a></div>
```

## Especificação pixel a pixel

Seção `bu28.genres` — retângulo absoluto no canvas 390×1520: **x=16, y=592.8, w=358, h=451.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28.genres.header` | box | 0 | 0 | 358 | 25.2 | `margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 2 | `bu28.genres.title` ±1 | text | 0 | 0 | 83.81 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px` | Bricolage (opsz 21) 21/normal peso 800 ls -0.4px #1A1714 |
| 3 | `bu28.genres.seeAll` ±1 | text | 299.07 | 7.18 | 58.93 | 15.6 | `font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 4 | `bu28.genres.grid` | box | 0 | 37.2 | 358 | 414 | `margin-top: 12px; display: grid; grid-template-columns: 1fr 1fr; gap: 10px` |  |
| 5 | `bu28.genres.tile1` | box | 0 | 37.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 6 | `bu28.genres.tile1.label` | text | 15.5 | 51.7 | 92 | 17.85 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #1A1714 |
| 7 | `bu28.genres.tile1.book` | box | 129.5 | 74.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg)` |  |
| 8 | `bu28.genres.tile1.book.spine` | box | 137 | 76.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 9 | `bu28.genres.tile1.book.line1` | box | 143 | 88.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 10 | `bu28.genres.tile1.book.line2` | box | 143 | 95.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |
| 11 | `bu28.genres.tile2` | box | 184 | 37.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 12 | `bu28.genres.tile2.label` | text | 199.5 | 51.7 | 92 | 17.85 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #1A1714 |
| 13 | `bu28.genres.tile2.book` | box | 313.5 | 74.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg)` |  |
| 14 | `bu28.genres.tile2.book.spine` | box | 321 | 76.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 15 | `bu28.genres.tile2.book.line1` | box | 327 | 88.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 16 | `bu28.genres.tile2.book.line2` | box | 327 | 95.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |
| 17 | `bu28.genres.tile3` | box | 0 | 143.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 18 | `bu28.genres.tile3.label` | text | 15.5 | 157.7 | 92 | 35.7 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #1A1714 |
| 19 | `bu28.genres.tile3.book` | box | 129.5 | 180.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #00995E; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg)` |  |
| 20 | `bu28.genres.tile3.book.spine` | box | 137 | 182.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 21 | `bu28.genres.tile3.book.line1` | box | 143 | 194.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 22 | `bu28.genres.tile3.book.line2` | box | 143 | 201.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |
| 23 | `bu28.genres.tile4` | box | 184 | 143.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #552CB7; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 24 | `bu28.genres.tile4.label` | text | 199.5 | 157.7 | 92 | 17.85 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #F7F0E3` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #F7F0E3 |
| 25 | `bu28.genres.tile4.book` | box | 313.5 | 180.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg)` |  |
| 26 | `bu28.genres.tile4.book.spine` | box | 321 | 182.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 27 | `bu28.genres.tile4.book.line1` | box | 327 | 194.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 28 | `bu28.genres.tile4.book.line2` | box | 327 | 201.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |
| 29 | `bu28.genres.tile5` | box | 0 | 249.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #058CD7; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 30 | `bu28.genres.tile5.label` | text | 15.5 | 263.7 | 92 | 35.7 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #F7F0E3` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #F7F0E3 |
| 31 | `bu28.genres.tile5.book` | box | 129.5 | 286.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #B6ACE4; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg)` |  |
| 32 | `bu28.genres.tile5.book.spine` | box | 137 | 288.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 33 | `bu28.genres.tile5.book.line1` | box | 143 | 300.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 34 | `bu28.genres.tile5.book.line2` | box | 143 | 307.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |
| 35 | `bu28.genres.tile6` | box | 184 | 249.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 36 | `bu28.genres.tile6.label` | text | 199.5 | 263.7 | 92 | 17.85 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #1A1714 |
| 37 | `bu28.genres.tile6.book` | box | 313.5 | 286.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FFC1C6; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg)` |  |
| 38 | `bu28.genres.tile6.book.spine` | box | 321 | 288.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 39 | `bu28.genres.tile6.book.line1` | box | 327 | 300.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 40 | `bu28.genres.tile6.book.line2` | box | 327 | 307.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |
| 41 | `bu28.genres.tile7` | box | 0 | 355.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #F2A815; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 42 | `bu28.genres.tile7.label` | text | 15.5 | 369.7 | 92 | 17.85 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #1A1714 |
| 43 | `bu28.genres.tile7.book` | box | 129.5 | 392.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(16deg)` |  |
| 44 | `bu28.genres.tile7.book.spine` | box | 137 | 394.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 45 | `bu28.genres.tile7.book.line1` | box | 143 | 406.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 46 | `bu28.genres.tile7.book.line2` | box | 143 | 413.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |
| 47 | `bu28.genres.tile8` | box | 184 | 355.2 | 174 | 96 | `position: relative; height: 96px; padding: 13px 14px; border-radius: 20px; background: #FF552E; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; overflow: hidden; display: block` |  |
| 48 | `bu28.genres.tile8.label` | text | 199.5 | 369.7 | 92 | 17.85 | `position: relative; z-index: 1; display: block; max-width: 92px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; line-height: 1.05; letter-spacing: -0.3px; color: #1A1714` | Bricolage (opsz 17) 17/17.85px peso 800 ls -0.3px #1A1714 |
| 49 | `bu28.genres.tile8.book` | box | 313.5 | 392.7 | 55 | 75 | `position: absolute; right: -12px; bottom: -18px; width: 52px; height: 72px; border-radius: 4px 8px 8px 4px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: -3px 3px 0 #1A1714; transform: rotate(-14deg)` |  |
| 50 | `bu28.genres.tile8.book.spine` | box | 321 | 394.2 | 1.5 | 72 | `position: absolute; left: 6px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.4)` |  |
| 51 | `bu28.genres.tile8.book.line1` | box | 327 | 406.2 | 33 | 3 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 3px; border-radius: 2px; background: #1A1714` |  |
| 52 | `bu28.genres.tile8.book.line2` | box | 327 | 413.2 | 26 | 3 | `position: absolute; left: 12px; right: 14px; top: 19px; height: 3px; border-radius: 2px; background: #1A1714; opacity: 0.6` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `bu28.genres.tile1.book`: caixa visual com `transform: rotate(16deg)` = x 120.23, y 68.57, w 73.54, h 87.25 (relativa à seção).
- `bu28.genres.tile1.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 127.85, y 72.08, w 21.29, h 69.62 (relativa à seção).
- `bu28.genres.tile1.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 149.33, y 85.27, w 32.55, h 11.98 (relativa à seção).
- `bu28.genres.tile1.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 147.4, y 92, w 25.82, h 10.05 (relativa à seção).
- `bu28.genres.tile2.book`: caixa visual com `transform: rotate(-14deg)` = x 305.25, y 69.16, w 71.51, h 86.08 (relativa à seção).
- `bu28.genres.tile2.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 312.88, y 81.74, w 18.87, h 70.22 (relativa à seção).
- `bu28.genres.tile2.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 321.61, y 84.32, w 32.75, h 10.89 (relativa à seção).
- `bu28.genres.tile2.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 323.3, y 92.8, w 25.95, h 9.2 (relativa à seção).
- `bu28.genres.tile3.book`: caixa visual com `transform: rotate(16deg)` = x 120.23, y 174.57, w 73.54, h 87.25 (relativa à seção).
- `bu28.genres.tile3.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 127.85, y 178.08, w 21.29, h 69.62 (relativa à seção).
- `bu28.genres.tile3.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 149.33, y 191.27, w 32.55, h 11.98 (relativa à seção).
- `bu28.genres.tile3.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 147.4, y 198, w 25.82, h 10.05 (relativa à seção).
- `bu28.genres.tile4.book`: caixa visual com `transform: rotate(-14deg)` = x 305.25, y 175.16, w 71.51, h 86.08 (relativa à seção).
- `bu28.genres.tile4.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 312.88, y 187.74, w 18.87, h 70.22 (relativa à seção).
- `bu28.genres.tile4.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 321.61, y 190.32, w 32.75, h 10.89 (relativa à seção).
- `bu28.genres.tile4.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 323.3, y 198.8, w 25.95, h 9.2 (relativa à seção).
- `bu28.genres.tile5.book`: caixa visual com `transform: rotate(16deg)` = x 120.23, y 280.57, w 73.54, h 87.25 (relativa à seção).
- `bu28.genres.tile5.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 127.85, y 284.08, w 21.29, h 69.62 (relativa à seção).
- `bu28.genres.tile5.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 149.33, y 297.27, w 32.55, h 11.98 (relativa à seção).
- `bu28.genres.tile5.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 147.4, y 304, w 25.82, h 10.05 (relativa à seção).
- `bu28.genres.tile6.book`: caixa visual com `transform: rotate(-14deg)` = x 305.25, y 281.16, w 71.51, h 86.08 (relativa à seção).
- `bu28.genres.tile6.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 312.88, y 293.74, w 18.87, h 70.22 (relativa à seção).
- `bu28.genres.tile6.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 321.61, y 296.32, w 32.75, h 10.89 (relativa à seção).
- `bu28.genres.tile6.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 323.3, y 304.8, w 25.95, h 9.2 (relativa à seção).
- `bu28.genres.tile7.book`: caixa visual com `transform: rotate(16deg)` = x 120.23, y 386.57, w 73.54, h 87.25 (relativa à seção).
- `bu28.genres.tile7.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 127.85, y 390.08, w 21.29, h 69.62 (relativa à seção).
- `bu28.genres.tile7.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 149.33, y 403.27, w 32.55, h 11.98 (relativa à seção).
- `bu28.genres.tile7.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 147.4, y 410, w 25.82, h 10.05 (relativa à seção).
- `bu28.genres.tile8.book`: caixa visual com `transform: rotate(-14deg)` = x 305.25, y 387.16, w 71.51, h 86.08 (relativa à seção).
- `bu28.genres.tile8.book.spine`: caixa visual deslocada pelo transform de um ancestral = x 312.88, y 399.74, w 18.87, h 70.22 (relativa à seção).
- `bu28.genres.tile8.book.line1`: caixa visual deslocada pelo transform de um ancestral = x 321.61, y 402.32, w 32.75, h 10.89 (relativa à seção).
- `bu28.genres.tile8.book.line2`: caixa visual deslocada pelo transform de um ancestral = x 323.3, y 410.8, w 25.95, h 9.2 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28.genres.title` | 1 | Gêneros | 19.53 | 0 | 83.81 | 83.81 |
| `bu28.genres.seeAll` | 1 | Ver todos | 19.53 | 299.07 | 358 | 58.93 |
| `bu28.genres.tile1.label` | 1 | Romance | 66.23 | 15.5 | 92.28 | 76.78 |
| `bu28.genres.tile2.label` | 1 | Fantasia | 66.23 | 199.5 | 268.83 | 69.33 |
| `bu28.genres.tile3.label` | 1 | Clássicos | 172.23 | 15.5 | 92.38 | 76.88 |
| `bu28.genres.tile3.label` | 2 | brasileiros | 190.08 | 15.5 | 101.71 | 86.21 |
| `bu28.genres.tile4.label` | 1 | Suspense | 172.23 | 199.5 | 279.51 | 80.01 |
| `bu28.genres.tile5.label` | 1 | Ficção | 278.23 | 15.5 | 68.54 | 53.04 |
| `bu28.genres.tile5.label` | 2 | científica | 296.08 | 15.5 | 91.08 | 75.58 |
| `bu28.genres.tile6.label` | 1 | Poesia | 278.23 | 199.5 | 253.4 | 53.9 |
| `bu28.genres.tile7.label` | 1 | Não ficção | 384.23 | 15.5 | 101.67 | 86.17 |
| `bu28.genres.tile8.label` | 1 | Quadrinhos | 384.23 | 199.5 | 294.6 | 95.1 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Gêneros" Bricolage 21/800 e "Ver todos" 13/800 sublinhado, 30 abaixo dos climas.
2. Grade de 2 colunas (gap 10), blocos de 96: padding 13/14, raio 20, borda 1,5, sombra 2/2, `overflow: hidden`; o nome Bricolage 17/800 `lh 1,05` ls −0,3, `max-width 92` (quebra em 2 linhas), branco creme nos fundos escuros (Suspense, Ficção científica).
3. O livrinho: 52 × 72 em `right −12 · bottom −18`, raio 4/8/8/4, borda 1,5, sombra dura −3/3 (para a esquerda), girado 16° ou −14° alternando; a lombada de 1,5 a 6 da borda e duas linhas pretas de 3 (a 2ª a 0,6).
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- "Quadrinhos" não cabe nos 92 de `max-width` e passa 3,10 (T13.5): o navegador deixa vazar; o Flutter quebra a palavra no meio. Medir com a largura máxima e deixar a linha passar (sem quebra dentro da palavra).
- O livrinho é cortado pelo bloco (`overflow: hidden`) e a sombra dele vai para a esquerda: `ClipRRect` no bloco com o livrinho girado dentro.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028_busca_explorar_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028_busca_explorar_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28.genres.tile1.book` |  |  | aria-hidden=true |
| `bu28.genres.tile2.book` |  |  | aria-hidden=true |
| `bu28.genres.tile3.book` |  |  | aria-hidden=true |
| `bu28.genres.tile4.book` |  |  | aria-hidden=true |
| `bu28.genres.tile5.book` |  |  | aria-hidden=true |
| `bu28.genres.tile6.book` |  |  | aria-hidden=true |
| `bu28.genres.tile7.book` |  |  | aria-hidden=true |
| `bu28.genres.tile8.book` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28.genres.tile1` | NeoBox |  |
| `bu28.genres.tile1.book` | NeoBox | Transform: rotate(16deg) |
| `bu28.genres.tile1.book.spine` | NeoBox |  |
| `bu28.genres.tile1.book.line1` | NeoBox |  |
| `bu28.genres.tile1.book.line2` | NeoBox |  |
| `bu28.genres.tile2` | NeoBox |  |
| `bu28.genres.tile2.book` | NeoBox | Transform: rotate(-14deg) |
| `bu28.genres.tile2.book.spine` | NeoBox |  |
| `bu28.genres.tile2.book.line1` | NeoBox |  |
| `bu28.genres.tile2.book.line2` | NeoBox |  |
| `bu28.genres.tile3` | NeoBox |  |
| `bu28.genres.tile3.book` | NeoBox | Transform: rotate(16deg) |
| `bu28.genres.tile3.book.spine` | NeoBox |  |
| `bu28.genres.tile3.book.line1` | NeoBox |  |
| `bu28.genres.tile3.book.line2` | NeoBox |  |
| `bu28.genres.tile4` | NeoBox |  |
| `bu28.genres.tile4.book` | NeoBox | Transform: rotate(-14deg) |
| `bu28.genres.tile4.book.spine` | NeoBox |  |
| `bu28.genres.tile4.book.line1` | NeoBox |  |
| `bu28.genres.tile4.book.line2` | NeoBox |  |
| `bu28.genres.tile5` | NeoBox |  |
| `bu28.genres.tile5.book` | NeoBox | Transform: rotate(16deg) |
| `bu28.genres.tile5.book.spine` | NeoBox |  |
| `bu28.genres.tile5.book.line1` | NeoBox |  |
| `bu28.genres.tile5.book.line2` | NeoBox |  |
| `bu28.genres.tile6` | NeoBox |  |
| `bu28.genres.tile6.book` | NeoBox | Transform: rotate(-14deg) |
| `bu28.genres.tile6.book.spine` | NeoBox |  |
| `bu28.genres.tile6.book.line1` | NeoBox |  |
| `bu28.genres.tile6.book.line2` | NeoBox |  |
| `bu28.genres.tile7` | NeoBox |  |
| `bu28.genres.tile7.book` | NeoBox | Transform: rotate(16deg) |
| `bu28.genres.tile7.book.spine` | NeoBox |  |
| `bu28.genres.tile7.book.line1` | NeoBox |  |
| `bu28.genres.tile7.book.line2` | NeoBox |  |
| `bu28.genres.tile8` | NeoBox |  |
| `bu28.genres.tile8.book` | NeoBox | Transform: rotate(-14deg) |
| `bu28.genres.tile8.book.spine` | NeoBox |  |
| `bu28.genres.tile8.book.line1` | NeoBox |  |
| `bu28.genres.tile8.book.line2` | NeoBox |  |

## Interações

- Gênero → os livros do gênero: a lista não tem prancha — sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b).
- Ver todos → a lista completa dos gêneros (a mesma do Onboarding, "Mais gêneros"): sem prancha — sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b).

## Dados

- Os mesmos gêneros do Onboarding (13); a ordem e as cores são do app.

## Subfases

- **L28.1** Grade dos gêneros
- **L28.2** Livrinho inclinado no canto
- **L28.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28.genres'), todos os ids de `kRef28.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@3x.png` no recorte da fase (y 584.8–1074.62) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28w360` e `kRef28w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28.1 Grade dos gêneros
- [ ] L28.2 Livrinho inclinado no canto
- [ ] L28.3 Verificação + relatório
- [ ] Geometria 52/52 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
