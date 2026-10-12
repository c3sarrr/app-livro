# FASE L64 — Editar perfil — o topo, a prévia ao vivo da capa, as cores da capa e o tipo de avatar

> Tela 64 · prancha `064_editar_perfil` (64 · Editar perfil, canvas 390×1400) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L64_1_previa_e_cor@3x.png` · `docs/design/medicao/projeto/png/redline/L64_1_previa_e_cor_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/064_editar_perfil_390x1400@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_064_editar_perfil.json` · `test/reference/projeto/reference_layout_064_editar_perfil.dart` (`kRef64`).
> Arquivos sugeridos: `lib/features/profile/presentation/edit/edit_profile_screen.dart`, `lib/features/profile/presentation/edit/profile_preview.dart`, `lib/features/profile/presentation/edit/cover_color_picker.dart`, `lib/features/profile/application/profile_draft.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Editar perfil (64), em cima: o fechar e o título, a prévia ao vivo da capa do perfil (a capa-livro em miniatura com o avatar e a câmera, o nome, a bio e as etiquetas), as 11 cores da capa com a roda de qualquer cor e o tipo de avatar (Foto ou Inicial M).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<header style="position: absolute; left: 20px; right: 20px; top: 58px; height: 48px; display: flex; align-items: center; justify-content: space-between;">
  <button aria-label="Fechar sem salvar" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"></path></svg></button>
  <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px;">Editar perfil</span>
  <span style="width: 48px;"></span>
</header>

<section aria-label="Prévia da capa do perfil" style="position: relative; margin-top: 14px; min-height: 196px; padding: 14px 16px 14px 28px; box-sizing: border-box; border-radius: 8px 22px 22px 8px; background: {{cover}}; border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; overflow: hidden;">
  <span aria-hidden="true" style="position: absolute; left: 0; top: 0; bottom: 0; width: 13px; background: rgba(26,23,20,0.12);"></span>
  <span aria-hidden="true" style="position: absolute; left: 16px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28);"></span>
  <span style="font-size: 9.5px; font-weight: 800; letter-spacing: 0.14em; color: #2C2452;">PRÉVIA AO VIVO</span>
  <div style="position: absolute; top: 16px; right: 16px; width: 74px; height: 74px;">
    <div style="width: 70px; height: 70px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; line-height: 1; padding-bottom: 4px;">M</div>
    <button aria-label="Trocar foto ou inicial" style="position: absolute; right: -6px; bottom: -4px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8h3l2-3h6l2 3h3v11H4z"></path><circle cx="12" cy="13" r="3.5"></circle></svg></button>
  </div>
  <h2 style="margin: 34px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.92; letter-spacing: -1.1px;">Marina<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 39px; letter-spacing: -0.5px;">Costa</span></h2>
  <p style="margin: 8px 0 0; max-width: 250px; font-size: 13px; font-weight: 600; line-height: 1.35; color: #2C2452;">Clássicos brasileiros, café forte e grifo tudo a lápis.</p>
  <span style="margin-top: 8px; display: flex; gap: 6px; flex-wrap: wrap;"><span style="height: 22px; padding: 0 8px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 10.5px; font-weight: 800;">ela/dela</span><span style="height: 22px; padding: 0 8px; border-radius: 999px; background: rgba(255,250,241,0.6); border: 1.2px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 10.5px; font-weight: 700;">clássicos · romance · contos</span></span>
</section>

<!-- Look -->
<div style="margin-top: 22px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">COR DA CAPA</div>

<div role="radiogroup" aria-label="Cor da capa" style="margin: 8px -20px 0; padding: 4px 20px 4px 22px; display: flex; gap: 9px; overflow: hidden; -webkit-mask-image: linear-gradient(90deg, #000 86%, transparent); mask-image: linear-gradient(90deg, #000 86%, transparent);"><button aria-label="Escolher qualquer cor" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: conic-gradient(#FF552E, #F2A815, #FED170, #ABCF82, #00995E, #058CD7, #B6ACE4, #552CB7, #FFC1C6, #FF552E); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><span style="width: 14px; height: 14px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="8" height="8" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg></span></button><button role="radio" aria-checked="true" aria-label="Lavanda" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 0 0 2.5px #F7F0E3, 0 0 0 4px #1A1714;"></button><button role="radio" aria-checked="false" aria-label="Rosa" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Verde-claro" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Amarelo" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Dourado" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F2A815; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Coral" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Azul" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #058CD7; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Verde" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #00995E; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Roxo" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #552CB7; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Creme" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box;"></button><button role="radio" aria-checked="false" aria-label="Tinta" style="width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box;"></button></div>

<div style="margin-top: 14px; display: flex; align-items: center; justify-content: space-between; gap: 10px;">
  <span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">AVATAR</span>
  <div role="radiogroup" aria-label="Tipo de avatar" style="height: 40px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(2, 92px); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1;">
    <button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 13px; font-weight: 600; color: #5B544B; display: flex; align-items: center; justify-content: center; gap: 5px;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#5B544B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8h3l2-3h6l2 3h3v11H4z"></path><circle cx="12" cy="13" r="3.5"></circle></svg>Foto</button>
    <button role="radio" aria-checked="true" style="height: 100%; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13px; font-weight: 800;">Inicial M</button>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `p64.top` — retângulo absoluto no canvas 390×1400: **x=20, y=58, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p64.top` | box | 0 | 0 | 350 | 48 | `position: absolute; left: 20px; right: 20px; top: 58px; height: 48px; display: flex; align-items: center; justify-content: space-between` |  |
| 2 | `p64.top.close` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `p64.top.close.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |
| 4 | `p64.top.title` ±1 | text | 127.06 | 13.8 | 95.89 | 20.4 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 17px; letter-spacing: -0.3px` | Bricolage (opsz 17) 17/normal peso 800 ls -0.3px #1A1714 |
| 5 | `p64.top.spacer` | box | 302 | 24 | 48 | 0 | `width: 48px` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.top.title` | 1 | Editar perfil | 29.61 | 127.06 | 222.94 | 95.88 |

Seção `p64.preview` — retângulo absoluto no canvas 390×1400: **x=20, y=126, w=350, h=222.62**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `p64.preview` | box | 0 | 0 | 350 | 222.62 | `position: relative; margin-top: 14px; min-height: 196px; padding: 14px 16px 14px 28px; box-sizing: border-box; border-radius: 8px 22px 22px 8px; background: {{cover}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; overflow: hidden` | Figtree 16/normal peso 400 ls normal #1A1714 |
| 7 | `p64.preview.spine` | box | 1.5 | 1.5 | 13 | 219.62 | `position: absolute; left: 0; top: 0; bottom: 0; width: 13px; background: rgba(26,23,20,0.12)` |  |
| 8 | `p64.preview.spineLine` | box | 17.5 | 1.5 | 1.5 | 219.62 | `position: absolute; left: 16px; top: 0; bottom: 0; width: 1.5px; background: rgba(26,23,20,0.28)` |  |
| 9 | `p64.preview.label` ±1 | inline | 29.5 | 21.67 | 95.84 | 11.41 | `font-size: 9.5px; font-weight: 800; letter-spacing: 0.14em; color: #2C2452` | Figtree 9.5/normal peso 800 ls 1.33px #2C2452 |
| 10 | `p64.preview.avatar` | box | 258.5 | 17.5 | 74 | 74 | `position: absolute; top: 16px; right: 16px; width: 74px; height: 74px` |  |
| 11 | `p64.preview.avatar.circle` | box+text | 258.5 | 17.5 | 70 | 70 | `width: 70px; height: 70px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-6deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; line-height: 1; padding-bottom: 4px` | Instrument Serif itálico 44/44px peso 400 ls normal #1A1714 |
| 12 | `p64.preview.avatar.change` | box | 308.5 | 65.5 | 30 | 30 | `position: absolute; right: -6px; bottom: -4px; width: 30px; height: 30px; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 13 | `p64.preview.avatar.change.icon` | icon | 316 | 73 | 15 | 15 | `—` |  |
| 14 | `p64.preview.name` | text | 29.5 | 68.7 | 303 | 65.32 | `margin: 34px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.92; letter-spacing: -1.1px` | Bricolage (opsz 32) 32/29.44px peso 800 ls -1.1px #1A1714 |
| 15 | `p64.preview.name.serif` ±1 | inline | 29.5 | 90.73 | 73.04 | 50.7 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 39px; letter-spacing: -0.5px` | Instrument Serif itálico 39/35.88px peso 400 ls -0.5px #1A1714 |
| 16 | `p64.preview.bio` | text | 29.5 | 142.02 | 250 | 35.1 | `margin: 8px 0 0; max-width: 250px; font-size: 13px; font-weight: 600; line-height: 1.35; color: #2C2452` | Figtree 13/17.55px peso 600 ls normal #2C2452 |
| 17 | `p64.preview.tags` | box | 29.5 | 185.12 | 303 | 22 | `margin-top: 8px; display: flex; gap: 6px; flex-wrap: wrap` |  |
| 18 | `p64.preview.tags.pronouns` ±1 | box+text | 29.5 | 185.12 | 57.96 | 22 | `height: 22px; padding: 0 8px; border-radius: 999px; background: #FFFAF1; border: 1.2px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 10.5px; font-weight: 800` | Figtree 10.5/normal peso 800 ls normal #1A1714 |
| 19 | `p64.preview.tags.genres` ±1 | box+text | 93.46 | 185.12 | 152.23 | 22 | `height: 22px; padding: 0 8px; border-radius: 999px; background: rgba(255,250,241,0.6); border: 1.2px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; font-size: 10.5px; font-weight: 700` | Figtree 10.5/normal peso 700 ls normal #1A1714 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `p64.preview.avatar.circle`: caixa visual com `transform: rotate(-6deg)` = x 255.03, y 14.03, w 76.93, h 76.93 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.preview` *(composto)* | 1 | PRÉVIA AO VIVO | 30.7 | 29.5 | 125.34 | 95.84 |
| `p64.preview` *(composto)* | 2 | Marina | 93.98 | 29.5 | 132.5 | 103 |
| `p64.preview` *(composto)* | 3 | Costa | 129.34 | 29.5 | 102.54 | 73.04 |
| `p64.preview` *(composto)* | 4 | Clássicos brasileiros, café forte e grifo | 155.34 | 29.5 | 254.57 | 225.07 |
| `p64.preview` *(composto)* | 5 | tudo a lápis. | 172.89 | 29.5 | 100.17 | 70.67 |
| `p64.preview` *(composto)* | 6 | ela/delaclássicos · romance · contos | 199.8 | 38.7 | 236.5 | 197.8 |
| `p64.preview.avatar.circle` | 1 | M | 65.46 | 278.87 | 308.13 | 29.26 |
| `p64.preview.name` *(composto)* | 1 | Marina | 93.98 | 29.5 | 132.5 | 103 |
| `p64.preview.name` *(composto)* | 2 | Costa | 129.34 | 29.5 | 102.54 | 73.04 |
| `p64.preview.bio` | 1 | Clássicos brasileiros, café forte e grifo | 155.34 | 29.5 | 254.57 | 225.07 |
| `p64.preview.bio` | 2 | tudo a lápis. | 172.89 | 29.5 | 100.17 | 70.67 |
| `p64.preview.tags.pronouns` | 1 | ela/dela | 199.8 | 38.7 | 78.26 | 39.56 |
| `p64.preview.tags.genres` | 1 | clássicos · romance · contos | 199.8 | 102.66 | 236.5 | 133.84 |

Seção `p64.colorLabel` — retângulo absoluto no canvas 390×1400: **x=20, y=370.62, w=350, h=13.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 20 | `p64.colorLabel` | text | 0 | 0 | 350 | 13.2 | `margin-top: 22px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.colorLabel` | 1 | COR DA CAPA | 10.45 | 0 | 88.91 | 88.91 |

Seção `p64.colors` — retângulo absoluto no canvas 390×1400: **x=0, y=391.82, w=390, h=40**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 21 | `p64.colors` | box | 0 | 0 | 390 | 40 | `margin: 8px -20px 0; padding: 4px 20px 4px 22px; display: flex; gap: 9px; overflow: hidden; -webkit-mask-image: linear-gradient(90deg, #000 86%, transparent); mask-image: linear-gradient(90deg, #000 86%, transparent)` |  |
| 22 | `p64.colors.custom` | box | 22 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: conic-gradient(#FF552E, #F2A815, #FED170, #ABCF82, #00995E, #058CD7, #B6ACE4, #552CB7, #FFC1C6, #FF552E); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 23 | `p64.colors.custom.dot` | box | 31 | 13 | 14 | 14 | `width: 14px; height: 14px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 24 | `p64.colors.custom.dot.icon` | icon | 34 | 16 | 8 | 8 | `—` |  |
| 25 | `p64.colors.lavender` | box | 63 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 0 0 2.5px #F7F0E3, 0 0 0 4px #1A1714` |  |
| 26 | `p64.colors.pink` | box | 104 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 27 | `p64.colors.lightGreen` | box | 145 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 28 | `p64.colors.yellow` | box | 186 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 29 | `p64.colors.gold` | box | 227 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F2A815; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 30 | `p64.colors.coral` | box | 268 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 31 | `p64.colors.blue` | box | 309 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #058CD7; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 32 | `p64.colors.green` | box | 350 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #00995E; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 33 | `p64.colors.purple` | box | 391 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #552CB7; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 34 | `p64.colors.cream` | box | 432 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F1E7D5; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 35 | `p64.colors.ink` | box | 473 | 4 | 32 | 32 | `width: 32px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box` |  |

Seção `p64.avatarType` — retângulo absoluto no canvas 390×1400: **x=20, y=445.82, w=350, h=40**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 36 | `p64.avatarType` | box | 0 | 0 | 350 | 40 | `margin-top: 14px; display: flex; align-items: center; justify-content: space-between; gap: 10px` |  |
| 37 | `p64.avatarType.label` ±1 | text | 0 | 13.4 | 49.78 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 38 | `p64.avatarType.toggle` | box | 155 | 0 | 195 | 40 | `height: 40px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(2, 92px); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1` |  |
| 39 | `p64.avatarType.toggle.photo` | text | 159.5 | 4.5 | 92 | 31 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 13px; font-weight: 600; color: #5B544B; display: flex; align-items: center; justify-content: center; gap: 5px` | Figtree 13/normal peso 600 ls normal #5B544B |
| 40 | `p64.avatarType.toggle.photo.icon` ±1 | icon | 182.41 | 13 | 14 | 14 | `—` |  |
| 41 | `p64.avatarType.toggle.initial` | box+text | 253.5 | 4.5 | 92 | 31 | `height: 100%; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.avatarType.label` | 1 | AVATAR | 23.85 | 0 | 49.78 | 49.78 |
| `p64.avatarType.toggle.photo` | 1 | Foto | 24.55 | 201.41 | 228.59 | 27.18 |
| `p64.avatarType.toggle.initial` | 1 | Inicial M | 24.55 | 274.38 | 324.62 | 50.24 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Topo em `left/right 20 · top 58`, 48 de altura: o fechar (48, `#FFFAF1`, borda 1,5, o X 20 traço 2,2), "Editar perfil" Bricolage 17/800 ls −0,3 no meio e o espaço de 48 à direita.
2. Prévia 14 abaixo: `min-height 196`, padding 14/16/14/28, raio 8/22/22/8, `{{cover}}`, borda 1,5, sombra 5/5, a lombada de 13 e o vinco em `left 16`; "PRÉVIA AO VIVO" 9,5/800 ls 0,14em `#2C2452`; o avatar 70 (girado −6°, "M" Instrument Serif 44) em `top/right 16` com a câmera 30 em `right −6 · bottom −4`; o nome Bricolage 32/800 + "Costa" Instrument Serif 39, 34 abaixo; a bio 13/600 `max-width 250`; as etiquetas de 22 (10,5/800 o pronome, 10,5/700 os gêneros sobre creme a 0,6).
3. "COR DA CAPA" 11/800 ls 1,2 `#6F665B`, 22 abaixo; a fileira das cores (`radiogroup`, margem −20, padding 4/20/4/22, gap 9, `overflow: hidden` e a máscara que apaga os 14% da direita): a roda 32 (`conic-gradient` das 9 cores, o "+" num círculo 14) e as 11 cores de 32; a escolhida com o anel duplo (2,5 `#F7F0E3` + 4 preto).
4. "AVATAR" 14 abaixo, com o seletor à direita (`radiogroup`, 40 de altura, padding 3, duas colunas de 92, raio cheio, borda 1,5): "Foto" 13/600 `#5B544B` com a câmera 14 e "Inicial M" `{{brand}}` 13/800.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A fileira das cores passa da tela já a 390 (o Roxo, o Creme e a Tinta ficam fora, sob a máscara; a 360 também o Verde, abaixo): no app, rolagem horizontal com a máscara por cima (`ShaderMask`), parada no começo.
- O anel duplo da cor escolhida é sombra (`box-shadow` 0 0 0 2,5 e 0 0 0 4): fica fora da bolinha de 32 e o padding de 4 da fileira é o que o mostra inteiro.
- A prévia usa os mesmos componentes da capa do Perfil (05) em escala menor, não um desenho à parte: o que muda na 64 aparece igual na 05.
- `p64.colors` tem máscara `linear-gradient(90deg, #000000 86%, #000000@0)` → `ShaderMask`.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_064_editar_perfil_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_064_editar_perfil_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `p64.colors.green` | sai do quadro (x) | 22 | 0 | **sim** | sim |  |
| 360 | `p64.colors.green` | passa do pai (x) | 22 | 0 | **sim** | sim | pai `p64.colors` (cortado) |
| 360 | `p64.colors.purple` | sai do quadro (x) | 63 | 33 | não | sim |  |
| 360 | `p64.colors.purple` | passa do pai (x) | 63 | 33 | não | sim | pai `p64.colors` (cortado) |
| 360 | `p64.colors.cream` | sai do quadro (x) | 104 | 74 | não | sim |  |
| 360 | `p64.colors.cream` | passa do pai (x) | 104 | 74 | não | sim | pai `p64.colors` (cortado) |
| 360 | `p64.colors.ink` | sai do quadro (x) | 145 | 115 | não | sim |  |
| 360 | `p64.colors.ink` | passa do pai (x) | 145 | 115 | não | sim | pai `p64.colors` (cortado) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p64.top.close` |  | Fechar sem salvar |  |
| `p64.top.close.icon` |  |  | aria-hidden=true |
| `p64.preview` |  | Prévia da capa do perfil |  |
| `p64.preview.spine` |  |  | aria-hidden=true |
| `p64.preview.spineLine` |  |  | aria-hidden=true |
| `p64.preview.avatar.change` |  | Trocar foto ou inicial |  |
| `p64.preview.avatar.change.icon` |  |  | aria-hidden=true |
| `p64.colors` | radiogroup | Cor da capa |  |
| `p64.colors.custom` |  | Escolher qualquer cor |  |
| `p64.colors.custom.dot.icon` |  |  | aria-hidden=true |
| `p64.colors.lavender` | radio | Lavanda | aria-checked=true |
| `p64.colors.pink` | radio | Rosa | aria-checked=false |
| `p64.colors.lightGreen` | radio | Verde-claro | aria-checked=false |
| `p64.colors.yellow` | radio | Amarelo | aria-checked=false |
| `p64.colors.gold` | radio | Dourado | aria-checked=false |
| `p64.colors.coral` | radio | Coral | aria-checked=false |
| `p64.colors.blue` | radio | Azul | aria-checked=false |
| `p64.colors.green` | radio | Verde | aria-checked=false |
| `p64.colors.purple` | radio | Roxo | aria-checked=false |
| `p64.colors.cream` | radio | Creme | aria-checked=false |
| `p64.colors.ink` | radio | Tinta | aria-checked=false |
| `p64.avatarType.toggle` | radiogroup | Tipo de avatar |  |
| `p64.avatarType.toggle.photo` | radio |  | aria-checked=false |
| `p64.avatarType.toggle.photo.icon` |  |  | aria-hidden=true |
| `p64.avatarType.toggle.initial` | radio |  | aria-checked=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p64.top.close` | CircleIconButton / NeoBox circular |  |
| `p64.top.close.icon` | AppSvg(AppIconsInicio.closeBold, size: 20) |  |
| `p64.preview` | NeoBox |  |
| `p64.preview.spine` | NeoBox |  |
| `p64.preview.spineLine` | NeoBox |  |
| `p64.preview.label` | TextSpan dentro do AppText.rich do pai |  |
| `p64.preview.avatar.circle` | CircleIconButton / NeoBox circular | Transform: rotate(-6deg) |
| `p64.preview.avatar.change` | CircleIconButton / NeoBox circular |  |
| `p64.preview.avatar.change.icon` | AppSvg(AppIconsPerfil.cameraSmall, size: 15) |  |
| `p64.preview.name.serif` | TextSpan dentro do AppText.rich do pai |  |
| `p64.preview.tags.pronouns` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.preview.tags.genres` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.colors.custom` | ConicRingPainter (anel arco-íris) |  |
| `p64.colors.custom.dot` | CircleIconButton / NeoBox circular |  |
| `p64.colors.custom.dot.icon` | AppSvg(AppIconsLeitor.plusTiny, size: 8) |  |
| `p64.colors.lavender` | CircleIconButton / NeoBox circular |  |
| `p64.colors.pink` | CircleIconButton / NeoBox circular |  |
| `p64.colors.lightGreen` | CircleIconButton / NeoBox circular |  |
| `p64.colors.yellow` | CircleIconButton / NeoBox circular |  |
| `p64.colors.gold` | CircleIconButton / NeoBox circular |  |
| `p64.colors.coral` | CircleIconButton / NeoBox circular |  |
| `p64.colors.blue` | CircleIconButton / NeoBox circular |  |
| `p64.colors.green` | CircleIconButton / NeoBox circular |  |
| `p64.colors.purple` | CircleIconButton / NeoBox circular |  |
| `p64.colors.cream` | CircleIconButton / NeoBox circular |  |
| `p64.colors.ink` | CircleIconButton / NeoBox circular |  |
| `p64.avatarType.toggle` | NeoBox |  |
| `p64.avatarType.toggle.photo.icon` | AppSvg(AppIconsPerfil.cameraSmallGrafite, size: 14) |  |
| `p64.avatarType.toggle.initial` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |

## Interações

- Fechar → volta ao Perfil; com mudanças, pergunta "Descartar alterações?" (a nota do design) — a folha da pergunta não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b) (ou o diálogo do app, se a T17 decidir).
- Câmera do avatar e "Foto" → o seletor de imagem do sistema e o recorte redondo (a nota do design: 512 px no servidor); "Inicial" → a inicial do nome.
- Cor → a prévia muda na hora (a mesma variável nos Ajustes, 06); a roda → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b) (o seletor de qualquer cor não tem prancha).

## Dados

- Um rascunho do perfil (`ProfileDraft`, a nota do design) que a prévia escuta; salvar faz uma gravação só. A cor da capa, o tipo de avatar e a foto são campos novos do perfil (no servidor): pergunta da T17.
- As 11 cores são a paleta do Clube (33) — no app, os tokens da paleta, com o nome de cada uma no rótulo.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L64.1** Topo e rascunho do perfil
- **L64.2** Prévia ao vivo
- **L64.3** Cores da capa
- **L64.4** Tipo de avatar
- **L64.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p64.top', 'p64.preview', 'p64.colorLabel', 'p64.colors', 'p64.avatarType'), todos os ids de `kRef64.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/064_editar_perfil_390x1400@3x.png` no recorte da fase (y 50–493.82) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef64w360` e `kRef64w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L64.1 Topo e rascunho do perfil
- [ ] L64.2 Prévia ao vivo
- [ ] L64.3 Cores da capa
- [ ] L64.4 Tipo de avatar
- [ ] L64.5 Verificação + relatório
- [ ] Geometria 39/39 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
