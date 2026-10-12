# FASE L28b — Busca (resultados) — os clubes, os seus trechos e o cartão do scanner

> Tela 28b · prancha `028b_busca_resultados` (28b · Busca — resultados (“capitu”), canvas 390×1040) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28b_2_clubes_e_trechos@3x.png` · `docs/design/medicao/projeto/png/redline/L28b_2_clubes_e_trechos_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028b_busca_resultados_390x1040@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028b_busca_resultados.json` · `test/reference/projeto/reference_layout_028b_busca_resultados.dart` (`kRef28b`).
> Arquivos sugeridos: `lib/features/search/presentation/results/club_result_row.dart`, `lib/features/search/presentation/results/highlight_result_card.dart`, `lib/features/search/presentation/results/scan_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Resultados: os clubes (Leitoras de Capitu, o seu, com o visto verde; Capitu sem spoiler, aberto, com "Entrar"), "Nos seus trechos" (só você vê), dois grifos do Dom Casmurro, e o cartão tracejado "Tem o livro de papel na mão?".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px;">Clubes</h2><a href="#" style="font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px;">Ver os 6</a></div>

<div style="margin-top: 4px;"><div style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px;"><span style="width: 50px; height: 50px; flex-shrink: 0; border-radius: 16px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg></span><a href="#" style="min-width: 0; flex-grow: 1;"><span style="display: block; font-size: 15.5px; font-weight: 800;">Leitoras de <mark style="background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px;">Capitu</mark></span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">Seu clube · 11 pessoas · qui 24/9</span></a><span role="img" aria-label="Você participa" style="width: 40px; height: 40px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></div><div style="padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px;"><span style="width: 50px; height: 50px; flex-shrink: 0; border-radius: 16px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg></span><a href="#" style="min-width: 0; flex-grow: 1;"><span style="display: block; font-size: 15.5px; font-weight: 800;"><mark style="background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px;">Capitu</mark> sem spoiler</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">Aberto · 214 pessoas</span></a><button style="height: 40px; padding: 0 16px; flex-shrink: 0; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13.5px; font-weight: 800; color: #F7F0E3;">Entrar</button></div></div>

<div style="margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px;">Nos seus trechos</h2><span style="font-size: 12.5px; font-weight: 700; color: #6F665B;">só você vê</span></div>

<div style="margin-top: 2px;"><a href="#" style="margin-top: 10px; padding: 12px 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; display: block;"><span style="display: block; font-family: 'Literata', Georgia, serif; font-size: 15.5px; line-height: 1.55; color: #2A2520;"><mark style="background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px;">Capitu</mark> era <mark style="background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px;">Capitu</mark>, isto é, uma criatura mui particular, mais mulher do que eu era homem.</span><span style="margin-top: 8px; display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: #6F665B;"><span style="width: 10px; height: 10px; border-radius: 50%; background: #B6ACE4; border: 1.2px solid #1A1714;"></span>Dom Casmurro · pág. 152</span></a><a href="#" style="margin-top: 10px; padding: 12px 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; display: block;"><span style="display: block; font-family: 'Literata', Georgia, serif; font-size: 15.5px; line-height: 1.55; color: #2A2520;">…o que foram aqueles olhos de <mark style="background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px;">Capitu</mark>.</span><span style="margin-top: 8px; display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: #6F665B;"><span style="width: 10px; height: 10px; border-radius: 50%; background: #FED170; border: 1.2px solid #1A1714;"></span>Dom Casmurro · pág. 159</span></a></div>

<a href="#" style="margin-top: 22px; padding: 14px 16px; border-radius: 20px; border: 1.5px dashed #1A1714; display: flex; align-items: center; gap: 12px;">
  <span style="width: 42px; height: 42px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16"></path><path d="M8 8v8M11 8v8M14 8v8M17 8v8"></path></svg></span>
  <span style="min-width: 0; flex-grow: 1;"><span style="display: block; font-size: 14.5px; font-weight: 800;">Tem o livro de papel na mão?</span><span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B;">Escaneie o código de barras e pronto</span></span>
  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m9 6 6 6-6 6"></path></svg>
</a>
```

## Especificação pixel a pixel

Seção `bu28b.clubs` — retângulo absoluto no canvas 390×1040: **x=16, y=473.2, w=358, h=179.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28b.clubs.header` | box | 0 | 0 | 358 | 25.2 | `margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 2 | `bu28b.clubs.title` ±1 | text | 0 | 0 | 68.22 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px` | Bricolage (opsz 21) 21/normal peso 800 ls -0.4px #1A1714 |
| 3 | `bu28b.clubs.seeAll` ±1 | text | 309 | 7.18 | 49 | 15.6 | `font-size: 13px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 4 | `bu28b.clubs.list` | box | 0 | 29.2 | 358 | 150.4 | `margin-top: 4px` |  |
| 5 | `bu28b.clubs.club1` | box | 0 | 29.2 | 358 | 75.2 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px` |  |
| 6 | `bu28b.clubs.club1.avatar` | box | 0 | 41.2 | 50 | 50 | `width: 50px; height: 50px; flex-shrink: 0; border-radius: 16px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 7 | `bu28b.clubs.club1.avatar.icon` | icon | 13 | 54.2 | 24 | 24 | `—` |  |
| 8 | `bu28b.clubs.club1.link` | box | 62 | 48.39 | 244 | 35.62 | `min-width: 0; flex-grow: 1` |  |
| 9 | `bu28b.clubs.club1.name` | text | 62 | 48.39 | 244 | 18.61 | `display: block; font-size: 15.5px; font-weight: 800` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 10 | `bu28b.clubs.club1.name.mark` ±1 | inline | 145.85 | 48.39 | 50.59 | 18.61 | `background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 11 | `bu28b.clubs.club1.meta` | text | 62 | 69 | 244 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 12 | `bu28b.clubs.club1.member` | box | 318 | 46.2 | 40 | 40 | `width: 40px; height: 40px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 13 | `bu28b.clubs.club1.member.icon` | icon | 329 | 57.2 | 18 | 18 | `—` |  |
| 14 | `bu28b.clubs.club2` | box | 0 | 104.4 | 358 | 75.2 | `padding: 12px 0; border-bottom: 1.2px dashed #D9CCB4; display: flex; align-items: center; gap: 12px` |  |
| 15 | `bu28b.clubs.club2.avatar` | box | 0 | 116.4 | 50 | 50 | `width: 50px; height: 50px; flex-shrink: 0; border-radius: 16px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 16 | `bu28b.clubs.club2.avatar.icon` | icon | 13 | 129.4 | 24 | 24 | `—` |  |
| 17 | `bu28b.clubs.club2.link` ±1 | box | 62 | 123.59 | 209.72 | 35.62 | `min-width: 0; flex-grow: 1` |  |
| 18 | `bu28b.clubs.club2.name` ±1 | text | 62 | 123.59 | 209.72 | 18.61 | `display: block; font-size: 15.5px; font-weight: 800` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 19 | `bu28b.clubs.club2.name.mark` ±1 | inline | 62 | 123.59 | 50.59 | 18.61 | `background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 20 | `bu28b.clubs.club2.meta` ±1 | text | 62 | 144.2 | 209.72 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 21 | `bu28b.clubs.club2.join` ±1 | box+text | 283.71 | 121.4 | 74.28 | 40 | `height: 40px; padding: 0 16px; flex-shrink: 0; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13.5px; font-weight: 800; color: #F7F0E3` | Figtree 13.5/normal peso 800 ls normal #F7F0E3 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28b.clubs.title` | 1 | Clubes | 19.53 | 0 | 68.22 | 68.22 |
| `bu28b.clubs.seeAll` | 1 | Ver os 6 | 19.53 | 309 | 358 | 49 |
| `bu28b.clubs.club1.name` *(composto)* | 1 | Leitoras de Capitu | 63.12 | 62 | 195.45 | 133.45 |
| `bu28b.clubs.club1.meta` | 1 | Seu clube · 11 pessoas · qui 24/9 | 80.88 | 62 | 243.14 | 181.14 |
| `bu28b.clubs.club2.name` *(composto)* | 1 | Capitu sem spoiler | 138.32 | 63 | 198.56 | 135.56 |
| `bu28b.clubs.club2.meta` | 1 | Aberto · 214 pessoas | 156.08 | 62 | 179.77 | 117.77 |
| `bu28b.clubs.club2.join` | 1 | Entrar | 146.13 | 301.21 | 340.5 | 39.29 |

Seção `bu28b.highlights` — retângulo absoluto no canvas 390×1040: **x=16, y=682.8, w=358, h=240.1**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 22 | `bu28b.highlights.header` | box | 0 | 0 | 358 | 25.2 | `margin-top: 30px; display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 23 | `bu28b.highlights.title` ±1 | text | 0 | 0 | 171.91 | 25.2 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; letter-spacing: -0.4px` | Bricolage (opsz 21) 21/normal peso 800 ls -0.4px #1A1714 |
| 24 | `bu28b.highlights.privacy` ±1 | text | 297.45 | 7.65 | 60.55 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #6F665B` | Figtree 12.5/normal peso 700 ls normal #6F665B |
| 25 | `bu28b.highlights.list` | box | 0 | 35.2 | 358 | 204.9 | `margin-top: 2px` |  |
| 26 | `bu28b.highlights.quote1` | box | 0 | 35.2 | 358 | 121.47 | `margin-top: 10px; padding: 12px 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; display: block` |  |
| 27 | `bu28b.highlights.quote1.text` | text | 15.5 | 48.7 | 327 | 72.08 | `display: block; font-family: 'Literata', Georgia, serif; font-size: 15.5px; line-height: 1.55; color: #2A2520` | Literata (opsz 15.5) 15.5/24.025px peso 400 ls normal #2A2520 |
| 28 | `bu28b.highlights.quote1.text.mark1` ±1 | inline | 15.5 | 49.2 | 51.08 | 23.01 | `background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px` | Literata (opsz 15.5) 15.5/24.025px peso 400 ls normal #2A2520 |
| 29 | `bu28b.highlights.quote1.text.mark2` ±1 | inline | 96.36 | 49.2 | 51.08 | 23.01 | `background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px` | Literata (opsz 15.5) 15.5/24.025px peso 400 ls normal #2A2520 |
| 30 | `bu28b.highlights.quote1.source` | text | 15.5 | 128.78 | 327 | 14.4 | `margin-top: 8px; display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 31 | `bu28b.highlights.quote1.source.dot` | box | 15.5 | 129.78 | 12.4 | 12.4 | `width: 10px; height: 10px; border-radius: 50%; background: #B6ACE4; border: 1.2px solid #1A1714` |  |
| 32 | `bu28b.highlights.quote2` | box | 0 | 166.68 | 358 | 73.42 | `margin-top: 10px; padding: 12px 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; display: block` |  |
| 33 | `bu28b.highlights.quote2.text` | text | 15.5 | 180.18 | 327 | 24.02 | `display: block; font-family: 'Literata', Georgia, serif; font-size: 15.5px; line-height: 1.55; color: #2A2520` | Literata (opsz 15.5) 15.5/24.025px peso 400 ls normal #2A2520 |
| 34 | `bu28b.highlights.quote2.text.mark` ±1 | inline | 241.32 | 180.68 | 51.08 | 23.01 | `background: linear-gradient(transparent 55%, rgba(254,209,112,0.95) 55%); color: inherit; padding: 0 1px` | Literata (opsz 15.5) 15.5/24.025px peso 400 ls normal #2A2520 |
| 35 | `bu28b.highlights.quote2.source` | text | 15.5 | 212.2 | 327 | 14.4 | `margin-top: 8px; display: flex; align-items: center; gap: 6px; font-size: 12px; font-weight: 700; color: #6F665B` | Figtree 12/normal peso 700 ls normal #6F665B |
| 36 | `bu28b.highlights.quote2.source.dot` | box | 15.5 | 213.2 | 12.4 | 12.4 | `width: 10px; height: 10px; border-radius: 50%; background: #FED170; border: 1.2px solid #1A1714` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28b.highlights.title` | 1 | Nos seus trechos | 19.53 | 0 | 171.91 | 171.91 |
| `bu28b.highlights.privacy` | 1 | só você vê | 19.53 | 297.45 | 358 | 60.55 |
| `bu28b.highlights.quote1.text` *(composto)* | 1 | Capitu era Capitu, isto é, uma criatura mui | 67.44 | 16.5 | 330.74 | 314.24 |
| `bu28b.highlights.quote1.text` *(composto)* | 2 | particular, mais mulher do que eu era | 91.46 | 15.5 | 290.4 | 274.9 |
| `bu28b.highlights.quote1.text` *(composto)* | 3 | homem. | 115.49 | 15.5 | 77.55 | 62.05 |
| `bu28b.highlights.quote1.source` | 1 | Dom Casmurro · pág. 152 | 140.18 | 33.9 | 171.04 | 137.14 |
| `bu28b.highlights.quote2.text` *(composto)* | 1 | …o que foram aqueles olhos de Capitu. | 198.92 | 15.5 | 297.56 | 282.06 |
| `bu28b.highlights.quote2.source` | 1 | Dom Casmurro · pág. 159 | 223.6 | 33.9 | 171.05 | 137.15 |

Seção `bu28b.scanCard` — retângulo absoluto no canvas 390×1040: **x=16, y=944.9, w=358, h=73**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 37 | `bu28b.scanCard` | box | 0 | 0 | 358 | 73 | `margin-top: 22px; padding: 14px 16px; border-radius: 20px; border: 1.5px dashed #1A1714; display: flex; align-items: center; gap: 12px` |  |
| 38 | `bu28b.scanCard.badge` | box | 17.5 | 15.5 | 42 | 42 | `width: 42px; height: 42px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 39 | `bu28b.scanCard.badge.icon` | icon | 28.5 | 26.5 | 20 | 20 | `—` |  |
| 40 | `bu28b.scanCard.textBlock` | box | 71.5 | 19.29 | 239 | 34.42 | `min-width: 0; flex-grow: 1` |  |
| 41 | `bu28b.scanCard.title` | text | 71.5 | 19.29 | 239 | 17.41 | `display: block; font-size: 14.5px; font-weight: 800` | Figtree 14.5/normal peso 800 ls normal #1A1714 |
| 42 | `bu28b.scanCard.subtitle` | text | 71.5 | 38.7 | 239 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 43 | `bu28b.scanCard.chevron` | icon | 322.5 | 27.5 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28b.scanCard.title` | 1 | Tem o livro de papel na mão? | 33.07 | 71.5 | 265.86 | 194.36 |
| `bu28b.scanCard.subtitle` | 1 | Escaneie o código de barras e pronto | 50.58 | 71.5 | 281.59 | 210.09 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Clubes" + "Ver os 6", 30 abaixo dos livros; linhas com a borda tracejada embaixo, gap 12: o avatar 50 (raio 16, `#FFC1C6`, as pessoas 24), o nome 15,5/800 com o termo grifado e "Seu clube · 11 pessoas · qui 24/9" 12,5/600; à direita o visto em círculo 40 `#ABCF82` ("Você participa") ou "Entrar" (pílula preta de 40, 13,5/800).
2. "Nos seus trechos" + "só você vê"; cartões com 10 entre eles: padding 12/14, raio 16, `#FFFAF1`, borda 1,5, o trecho em Literata 15,5 `lh 1,55` `#2A2520` com "Capitu" grifado e, 8 abaixo, a bolinha 10 da cor do grifo + "Dom Casmurro · pág. 152" 12/700.
3. Cartão do Scanner, 22 abaixo: padding 14/16, raio 20, borda 1,5 `dashed`, o círculo amarelo 42, "Tem o livro de papel na mão?" 14,5/800 + "Escaneie o código de barras e pronto" 12,5/600 e a seta 18.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O avatar dos dois clubes é o mesmo ícone na prancha: com dados reais, o selo e a cor de cada clube (o Criar clube, 33) — o widget recebe o desenho do clube.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028b_busca_resultados_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028b_busca_resultados_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `bu28b.scanCard.subtitle` linha 1 «Escaneie o código de barras e»: sobra 43.27 px · estouro com a próxima palavra 1.09 px.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28b.clubs.club1.avatar.icon` |  |  | aria-hidden=true |
| `bu28b.clubs.club1.member` | img | Você participa |  |
| `bu28b.clubs.club1.member.icon` |  |  | aria-hidden=true |
| `bu28b.clubs.club2.avatar.icon` |  |  | aria-hidden=true |
| `bu28b.scanCard.badge.icon` |  |  | aria-hidden=true |
| `bu28b.scanCard.chevron` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28b.clubs.club1` | NeoBox |  |
| `bu28b.clubs.club1.avatar` | NeoBox |  |
| `bu28b.clubs.club1.avatar.icon` | AppSvg(AppIconsScanner.peopleAvatar, size: 24) |  |
| `bu28b.clubs.club1.name.mark` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.clubs.club1.member` | CircleIconButton / NeoBox circular |  |
| `bu28b.clubs.club1.member.icon` | AppSvg(AppIconsScanner.checkBoldTinta, size: 18) |  |
| `bu28b.clubs.club2` | NeoBox |  |
| `bu28b.clubs.club2.avatar` | NeoBox |  |
| `bu28b.clubs.club2.avatar.icon` | AppSvg(AppIconsScanner.peopleAvatar, size: 24) |  |
| `bu28b.clubs.club2.name.mark` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.clubs.club2.join` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `bu28b.highlights.quote1` | NeoBox |  |
| `bu28b.highlights.quote1.text.mark1` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.highlights.quote1.text.mark2` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.highlights.quote1.source.dot` | CircleIconButton / NeoBox circular |  |
| `bu28b.highlights.quote2` | NeoBox |  |
| `bu28b.highlights.quote2.text.mark` | TextSpan dentro do AppText.rich do pai |  |
| `bu28b.highlights.quote2.source.dot` | CircleIconButton / NeoBox circular |  |
| `bu28b.scanCard` | NeoBox |  |
| `bu28b.scanCard.badge` | CircleIconButton / NeoBox circular |  |
| `bu28b.scanCard.badge.icon` | AppSvg(AppIconsScanner.scanBarcodeBusca, size: 20) |  |
| `bu28b.scanCard.chevron` | AppSvg(AppIconsBiblioteca.chevronRightClube, size: 18) |  |

## Interações

- Clube → a aba do clube (04), da T07: a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T15 (ROTEIRO §2b).
- Entrar → entrar no clube aberto (a T07/T12): a tela de chegada é de outra etapa — até ela existir, o toque segue o precedente da D-243 b (idêntico à prancha, sem ação, teste que documenta, ⏸ no `docs/NAVEGACAO.md`); confirmar na pergunta da T15 (ROTEIRO §2b).
- Trecho → o trecho no leitor (`AppRoutes.leitor` com `goTo`).
- Cartão do Scanner → a tela do Scanner.

## Dados

- Clubes do nosso servidor (os dados da G); trechos = os grifos e notas da própria pessoa, buscados no aparelho (só ela vê); a cor da bolinha é a do grifo.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L28b.1** Linhas de clube (participa × Entrar)
- **L28b.2** Nos seus trechos
- **L28b.3** Cartão do Scanner
- **L28b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28b.clubs', 'bu28b.highlights', 'bu28b.scanCard'), todos os ids de `kRef28b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028b_busca_resultados_390x1040@3x.png` no recorte da fase (y 465.2–1025.9) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28bw360` e `kRef28bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28b.1 Linhas de clube (participa × Entrar)
- [ ] L28b.2 Nos seus trechos
- [ ] L28b.3 Cartão do Scanner
- [ ] L28b.4 Verificação + relatório
- [ ] Geometria 38/38 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
