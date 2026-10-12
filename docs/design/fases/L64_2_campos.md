# FASE L64 — Editar perfil — nome, @ e bio, pronomes e gêneros favoritos

> Tela 64 · prancha `064_editar_perfil` (64 · Editar perfil, canvas 390×1400) · executada na **T17** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L64_2_campos@3x.png` · `docs/design/medicao/projeto/png/redline/L64_2_campos_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/064_editar_perfil_390x1400@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_064_editar_perfil.json` · `test/reference/projeto/reference_layout_064_editar_perfil.dart` (`kRef64`).
> Arquivos sugeridos: `lib/features/profile/presentation/edit/identity_fields.dart`, `lib/features/profile/presentation/edit/choice_pills.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Editar perfil (64), no meio: os campos Nome (12/40), @ de usuária ("é seu", troca a cada 30 dias) e Bio (51/120, em foco com o cursor), os pronomes (ela/dela marcado, Escrever, Não mostrar) e os gêneros favoritos (até 5, 3 escolhidos, cada um com a sua cor).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{cover}}` = padrão `#B6ACE4`.

```html
<!-- Identity -->
<div style="margin-top: 22px; display: flex; flex-direction: column; gap: 14px;">
  <label style="display: flex; flex-direction: column; gap: 6px;"><span style="display: flex; justify-content: space-between; align-items: baseline;"><span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">NOME</span><span style="font-size: 11.5px; font-weight: 700; color: #8A8073;">12 / 40</span></span><span style="min-height: 52px; padding: 0 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px;"><span style="font-size: 15.5px; font-weight: 600; line-height: 1.45; color: #1A1714;">Marina Costa</span><span style="flex-grow: 1;"></span></span></label>
  <label style="display: flex; flex-direction: column; gap: 6px;"><span style="display: flex; justify-content: space-between; align-items: baseline;"><span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">@ DE USUÁRIA</span><span style="font-size: 11.5px; font-weight: 700; color: #8A8073;">pode trocar a cada 30 dias</span></span><span style="min-height: 52px; padding: 0 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px;"><span style="font-size: 15.5px; font-weight: 600; line-height: 1.45; color: #1A1714;"><span style="color: #8A8073;">@</span>marinacosta</span><span style="flex-grow: 1;"></span><span style="display: flex; align-items: center; gap: 4px; font-size: 12px; font-weight: 800; color: #2E5314; white-space: nowrap;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#2E5314" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>é seu</span></span></label>
  <label style="display: flex; flex-direction: column; gap: 6px;"><span style="display: flex; justify-content: space-between; align-items: baseline;"><span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">BIO</span><span style="font-size: 11.5px; font-weight: 700; color: #8A8073;">51 / 120</span></span><span style="min-height: 84px; padding: 12px 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: flex-start; gap: 8px;"><span style="font-size: 15.5px; font-weight: 600; line-height: 1.45; color: #1A1714;">Clássicos brasileiros, café forte e grifo tudo a lápis.<span aria-hidden="true" style="display: inline-block; width: 2px; height: 18px; margin-left: 1px; vertical-align: -3px; background: #FF552E;"></span></span><span style="flex-grow: 1;"></span></span></label>
</div>

<!-- Pronouns -->
<div style="margin-top: 20px; display: flex; justify-content: space-between; align-items: baseline;"><span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">PRONOMES</span><span style="font-size: 11.5px; font-weight: 700; color: #8A8073;">opcional</span></div>

<div role="radiogroup" aria-label="Pronomes" style="margin-top: 8px; display: flex; flex-wrap: wrap; gap: 8px;"><button role="checkbox" aria-checked="true" style="height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>ela/dela</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">ele/dele</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">elu/delu</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">Escrever</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">Não mostrar</button></div>

<!-- Genres -->
<div style="margin-top: 20px; display: flex; justify-content: space-between; align-items: baseline;"><span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">GÊNEROS FAVORITOS</span><span style="font-size: 11.5px; font-weight: 700; color: #8A8073;">até 5 · 3 escolhidos</span></div>

<div role="group" aria-label="Gêneros favoritos" style="margin-top: 8px; display: flex; flex-wrap: wrap; gap: 8px;"><button role="checkbox" aria-checked="true" style="height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>Clássicos</button><button role="checkbox" aria-checked="true" style="height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>Romance</button><button role="checkbox" aria-checked="true" style="height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>Contos</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">Poesia</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">Ficção científica</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">Fantasia</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">Não ficção</button><button role="checkbox" aria-checked="false" style="height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap;">Mistério</button></div>
```

## Especificação pixel a pixel

Seção `p64.fields` — retângulo absoluto no canvas 390×1400: **x=20, y=507.82, w=350, h=275.43**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `p64.fields` | box | 0 | 0 | 350 | 275.43 | `margin-top: 22px; display: flex; flex-direction: column; gap: 14px` |  |
| 2 | `p64.fields.name` | box | 0 | 0 | 350 | 71.81 | `display: flex; flex-direction: column; gap: 6px` |  |
| 3 | `p64.fields.name.head` | box | 0 | 0 | 350 | 13.81 | `display: flex; justify-content: space-between; align-items: baseline` |  |
| 4 | `p64.fields.name.head.title` ±1 | text | 0 | 0.48 | 37.97 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 5 | `p64.fields.name.head.counter` ±1 | text | 313.31 | 0 | 36.69 | 13.81 | `font-size: 11.5px; font-weight: 700; color: #8A8073` | Figtree 11.5/normal peso 700 ls normal #8A8073 |
| 6 | `p64.fields.name.field` | box | 0 | 19.81 | 350 | 52 | `min-height: 52px; padding: 0 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px` |  |
| 7 | `p64.fields.name.field.value` ±1 | text | 15.5 | 34.57 | 92.99 | 22.48 | `font-size: 15.5px; font-weight: 600; line-height: 1.45; color: #1A1714` | Figtree 15.5/22.475px peso 600 ls normal #1A1714 |
| 8 | `p64.fields.name.field.spacer` ±1 | box | 116.49 | 45.81 | 218.01 | 0 | `flex-grow: 1` |  |
| 9 | `p64.fields.handle` | box | 0 | 85.81 | 350 | 71.81 | `display: flex; flex-direction: column; gap: 6px` |  |
| 10 | `p64.fields.handle.head` | box | 0 | 85.81 | 350 | 13.81 | `display: flex; justify-content: space-between; align-items: baseline` |  |
| 11 | `p64.fields.handle.head.title` ±1 | text | 0 | 86.29 | 93.33 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 12 | `p64.fields.handle.head.hint` ±1 | text | 210.38 | 85.81 | 139.62 | 13.81 | `font-size: 11.5px; font-weight: 700; color: #8A8073` | Figtree 11.5/normal peso 700 ls normal #8A8073 |
| 13 | `p64.fields.handle.field` | box | 0 | 105.62 | 350 | 52 | `min-height: 52px; padding: 0 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px` |  |
| 14 | `p64.fields.handle.field.value` ±1 | text | 15.5 | 120.38 | 102.01 | 22.48 | `font-size: 15.5px; font-weight: 600; line-height: 1.45; color: #1A1714` | Figtree 15.5/22.475px peso 600 ls normal #1A1714 |
| 15 | `p64.fields.handle.field.value.at` ±1 | inline | 15.5 | 122.31 | 15.36 | 18.61 | `color: #8A8073` | Figtree 15.5/22.475px peso 600 ls normal #8A8073 |
| 16 | `p64.fields.handle.field.spacer` ±1 | box | 125.51 | 131.62 | 155.1 | 0 | `flex-grow: 1` |  |
| 17 | `p64.fields.handle.field.status` ±1 | text | 288.62 | 124.42 | 45.88 | 14.4 | `display: flex; align-items: center; gap: 4px; font-size: 12px; font-weight: 800; color: #2E5314; white-space: nowrap` | Figtree 12/normal peso 800 ls normal #2E5314 |
| 18 | `p64.fields.handle.field.status.icon` ±1 | icon | 288.62 | 125.12 | 13 | 13 | `—` |  |
| 19 | `p64.fields.bio` | box | 0 | 171.62 | 350 | 103.81 | `display: flex; flex-direction: column; gap: 6px` |  |
| 20 | `p64.fields.bio.head` | box | 0 | 171.62 | 350 | 13.81 | `display: flex; justify-content: space-between; align-items: baseline` |  |
| 21 | `p64.fields.bio.head.title` ±1 | text | 0 | 172.1 | 22.32 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 22 | `p64.fields.bio.head.counter` ±1 | text | 309.06 | 171.62 | 40.94 | 13.81 | `font-size: 11.5px; font-weight: 700; color: #8A8073` | Figtree 11.5/normal peso 700 ls normal #8A8073 |
| 23 | `p64.fields.bio.field` | box | 0 | 191.43 | 350 | 84 | `min-height: 84px; padding: 12px 14px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: flex-start; gap: 8px` |  |
| 24 | `p64.fields.bio.field.value` | text | 15.5 | 204.93 | 311 | 44.95 | `font-size: 15.5px; font-weight: 600; line-height: 1.45; color: #1A1714` | Figtree 15.5/22.475px peso 600 ls normal #1A1714 |
| 25 | `p64.fields.bio.field.value.caret` ±1 | box | 64.02 | 229.06 | 2 | 18 | `display: inline-block; width: 2px; height: 18px; margin-left: 1px; vertical-align: -3px; background: #FF552E` |  |
| 26 | `p64.fields.bio.field.spacer` | box | 334.5 | 204.93 | 0 | 0 | `flex-grow: 1` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.fields.name.head.title` | 1 | NOME | 10.93 | 0 | 37.97 | 37.97 |
| `p64.fields.name.head.counter` | 1 | 12 / 40 | 10.93 | 313.31 | 350 | 36.69 |
| `p64.fields.name.field.value` | 1 | Marina Costa | 51.23 | 15.5 | 108.49 | 92.99 |
| `p64.fields.handle.head.title` | 1 | @ DE USUÁRIA | 96.74 | 0 | 93.33 | 93.33 |
| `p64.fields.handle.head.hint` | 1 | pode trocar a cada 30 dias | 96.74 | 210.38 | 350 | 139.62 |
| `p64.fields.handle.field.value` *(composto)* | 1 | @marinacosta | 137.04 | 15.5 | 117.51 | 102.01 |
| `p64.fields.handle.field.status` | 1 | é seu | 135.82 | 305.62 | 334.5 | 28.88 |
| `p64.fields.bio.head.title` | 1 | BIO | 182.55 | 0 | 22.32 | 22.32 |
| `p64.fields.bio.head.counter` | 1 | 51 / 120 | 182.55 | 309.06 | 350 | 40.94 |
| `p64.fields.bio.field.value` | 1 | Clássicos brasileiros, café forte e grifo tudo | 221.59 | 15.5 | 320.58 | 305.08 |
| `p64.fields.bio.field.value` | 2 | a lápis. | 244.06 | 15.5 | 63.02 | 47.52 |

Seção `p64.pronounsHeader` — retângulo absoluto no canvas 390×1400: **x=20, y=803.25, w=350, h=13.81**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 27 | `p64.pronounsHeader` | box | 0 | 0 | 350 | 13.81 | `margin-top: 20px; display: flex; justify-content: space-between; align-items: baseline` |  |
| 28 | `p64.pronounsHeader.title` ±1 | text | 0 | 0.48 | 72.06 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 29 | `p64.pronounsHeader.hint` ±1 | text | 304.94 | 0 | 45.06 | 13.81 | `font-size: 11.5px; font-weight: 700; color: #8A8073` | Figtree 11.5/normal peso 700 ls normal #8A8073 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.pronounsHeader.title` | 1 | PRONOMES | 10.93 | 0 | 72.06 | 72.06 |
| `p64.pronounsHeader.hint` | 1 | opcional | 10.93 | 304.94 | 350 | 45.06 |

Seção `p64.pronouns` — retângulo absoluto no canvas 390×1400: **x=20, y=825.06, w=350, h=84**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 30 | `p64.pronouns` | box | 0 | 0 | 350 | 84 | `margin-top: 8px; display: flex; flex-wrap: wrap; gap: 8px` |  |
| 31 | `p64.pronouns.she` ±1 | box+text | 0 | 0 | 94.87 | 38 | `height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 32 | `p64.pronouns.she.icon` | icon | 10.5 | 12 | 14 | 14 | `—` |  |
| 33 | `p64.pronouns.he` ±1 | box+text | 102.87 | 0 | 78.71 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |
| 34 | `p64.pronouns.they` ±1 | box+text | 189.57 | 0 | 79.06 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |
| 35 | `p64.pronouns.custom` ±1 | box+text | 0 | 46 | 82.15 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |
| 36 | `p64.pronouns.none` ±1 | box+text | 90.15 | 46 | 105.55 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.pronouns.she` | 1 | ela/dela | 23.72 | 29.5 | 80.37 | 50.87 |
| `p64.pronouns.he` | 1 | ele/dele | 23.72 | 117.37 | 167.07 | 49.7 |
| `p64.pronouns.they` | 1 | elu/delu | 23.72 | 204.07 | 254.13 | 50.06 |
| `p64.pronouns.custom` | 1 | Escrever | 69.72 | 14.5 | 67.65 | 53.15 |
| `p64.pronouns.none` | 1 | Não mostrar | 69.72 | 104.65 | 181.2 | 76.55 |

Seção `p64.genresHeader` — retângulo absoluto no canvas 390×1400: **x=20, y=929.06, w=350, h=13.81**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 37 | `p64.genresHeader` | box | 0 | 0 | 350 | 13.81 | `margin-top: 20px; display: flex; justify-content: space-between; align-items: baseline` |  |
| 38 | `p64.genresHeader.title` ±1 | text | 0 | 0.48 | 137.21 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 39 | `p64.genresHeader.hint` ±1 | text | 249.96 | 0 | 100.04 | 13.81 | `font-size: 11.5px; font-weight: 700; color: #8A8073` | Figtree 11.5/normal peso 700 ls normal #8A8073 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.genresHeader.title` | 1 | GÊNEROS FAVORITOS | 10.93 | 0 | 137.21 | 137.21 |
| `p64.genresHeader.hint` | 1 | até 5 · 3 escolhidos | 10.93 | 249.96 | 350 | 100.04 |

Seção `p64.genres` — retângulo absoluto no canvas 390×1400: **x=20, y=950.87, w=350, h=130**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 40 | `p64.genres` | box | 0 | 0 | 350 | 130 | `margin-top: 8px; display: flex; flex-wrap: wrap; gap: 8px` |  |
| 41 | `p64.genres.classics` ±1 | box+text | 0 | 0 | 102.91 | 38 | `height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 42 | `p64.genres.classics.icon` | icon | 10.5 | 12 | 14 | 14 | `—` |  |
| 43 | `p64.genres.romance` ±1 | box+text | 110.91 | 0 | 102.56 | 38 | `height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 44 | `p64.genres.romance.icon` ±1 | icon | 121.41 | 12 | 14 | 14 | `—` |  |
| 45 | `p64.genres.stories` ±1 | box+text | 221.47 | 0 | 89.16 | 38 | `height: 38px; padding: 0 13px 0 9px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 46 | `p64.genres.stories.icon` ±1 | icon | 231.97 | 12 | 14 | 14 | `—` |  |
| 47 | `p64.genres.poetry` ±1 | box+text | 0 | 46 | 68.91 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |
| 48 | `p64.genres.scifi` ±1 | box+text | 76.91 | 46 | 130.03 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |
| 49 | `p64.genres.fantasy` ±1 | box+text | 214.94 | 46 | 80.05 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |
| 50 | `p64.genres.nonfiction` ±1 | box+text | 0 | 92 | 95.68 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |
| 51 | `p64.genres.mystery` ±1 | box+text | 103.68 | 92 | 78.98 | 38 | `height: 38px; padding: 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; font-size: 13.5px; font-weight: 600; white-space: nowrap` | Figtree 13.5/normal peso 600 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `p64.genres.classics` | 1 | Clássicos | 23.73 | 29.5 | 88.41 | 58.91 |
| `p64.genres.romance` | 1 | Romance | 23.73 | 140.41 | 198.97 | 58.56 |
| `p64.genres.stories` | 1 | Contos | 23.73 | 250.97 | 296.13 | 45.16 |
| `p64.genres.poetry` | 1 | Poesia | 69.73 | 14.5 | 54.41 | 39.91 |
| `p64.genres.scifi` | 1 | Ficção científica | 69.73 | 91.41 | 192.44 | 101.03 |
| `p64.genres.fantasy` | 1 | Fantasia | 69.73 | 229.44 | 280.49 | 51.05 |
| `p64.genres.nonfiction` | 1 | Não ficção | 115.73 | 14.5 | 81.18 | 66.68 |
| `p64.genres.mystery` | 1 | Mistério | 115.73 | 118.18 | 168.16 | 49.98 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Campos 22 abaixo do avatar, gap 14: o rótulo 11/800 ls 1,2 `#6F665B` com o contador 11,5/700 `#8A8073` à direita; a caixa `min-height 52` (84 na bio, padding 12/14), padding 0/14, raio 16, `#FFFAF1`, borda 1,5; o texto 15,5/600 `lh 1,45`.
2. O @: o "@" em `#8A8073` e, à direita, "é seu" 12/800 `#2E5314` com o visto 13; a bio em foco tem a sombra 3/3 e o cursor coral 2 × 18 depois do texto.
3. "PRONOMES" / "opcional" e "GÊNEROS FAVORITOS" / "até 5 · 3 escolhidos", 20 abaixo; as pílulas (flex-wrap, gap 8, 8 abaixo) de 38, padding 0/13, 13,5/600 `nowrap`, borda 1,5 `#E2D7C4`; a escolhida com borda preta, 800, o visto 14 à esquerda (padding 0/13/0/9) e a cor: `{{brand}}` no pronome, a do gênero nos gêneros (`#FED170`, `#FFC1C6`, `#ABCF82`).
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Os pronomes estão num `radiogroup` com botões `role="checkbox"`: no app, escolha única com a semântica de grupo exclusivo (`inMutuallyExclusiveGroup`), como o design pede; os gêneros são `checkbox` de verdade.
- O rótulo do campo do @ diz "@ DE USUÁRIA": o gênero do texto segue o do perfil — a regra para os outros (USUÁRIO, a forma neutra) é pergunta da T17.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_064_editar_perfil_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_064_editar_perfil_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `p64.fields.handle.field.status.icon` |  |  | aria-hidden=true |
| `p64.fields.bio.field.value.caret` |  |  | aria-hidden=true |
| `p64.pronouns` | radiogroup | Pronomes |  |
| `p64.pronouns.she` | checkbox |  | aria-checked=true |
| `p64.pronouns.she.icon` |  |  | aria-hidden=true |
| `p64.pronouns.he` | checkbox |  | aria-checked=false |
| `p64.pronouns.they` | checkbox |  | aria-checked=false |
| `p64.pronouns.custom` | checkbox |  | aria-checked=false |
| `p64.pronouns.none` | checkbox |  | aria-checked=false |
| `p64.genres` | group | Gêneros favoritos |  |
| `p64.genres.classics` | checkbox |  | aria-checked=true |
| `p64.genres.classics.icon` |  |  | aria-hidden=true |
| `p64.genres.romance` | checkbox |  | aria-checked=true |
| `p64.genres.romance.icon` |  |  | aria-hidden=true |
| `p64.genres.stories` | checkbox |  | aria-checked=true |
| `p64.genres.stories.icon` |  |  | aria-hidden=true |
| `p64.genres.poetry` | checkbox |  | aria-checked=false |
| `p64.genres.scifi` | checkbox |  | aria-checked=false |
| `p64.genres.fantasy` | checkbox |  | aria-checked=false |
| `p64.genres.nonfiction` | checkbox |  | aria-checked=false |
| `p64.genres.mystery` | checkbox |  | aria-checked=false |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `p64.fields.name.field` | NeoBox |  |
| `p64.fields.handle.field` | NeoBox |  |
| `p64.fields.handle.field.value.at` | TextSpan dentro do AppText.rich do pai |  |
| `p64.fields.handle.field.status.icon` | AppSvg(AppIconsBiblioteca.checkBold, size: 13) |  |
| `p64.fields.bio.field` | NeoBox |  |
| `p64.fields.bio.field.value.caret` | NeoBox |  |
| `p64.pronouns.she` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.pronouns.she.icon` | AppSvg(AppIconsScanner.checkBoldTinta, size: 14) |  |
| `p64.pronouns.he` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.pronouns.they` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.pronouns.custom` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.pronouns.none` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.classics` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.classics.icon` | AppSvg(AppIconsScanner.checkBoldTinta, size: 14) |  |
| `p64.genres.romance` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.romance.icon` | AppSvg(AppIconsScanner.checkBoldTinta, size: 14) |  |
| `p64.genres.stories` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.stories.icon` | AppSvg(AppIconsScanner.checkBoldTinta, size: 14) |  |
| `p64.genres.poetry` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.scifi` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.fantasy` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.nonfiction` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `p64.genres.mystery` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |

## Interações

- Nome: até 40, o contador acompanha. Bio: até 120, o contador acompanha.
- @: checagem ao vivo com espera de 400 ms ("é seu", "disponível", "já existe, tente…", a nota do design); só troca a cada 30 dias — os estados de carregando, disponível e erro não têm prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b).
- Pronomes: uma escolha só (Escrever abre o campo do pronome escrito, sem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b)).
- Gêneros: até 5; o 6º não marca (o aviso não tem prancha: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T17 (ROTEIRO §2b)).

## Dados

- Nome e @ são os da conta (`AccountSummary`; o @ pela `chooseHandle` que já existe); bio, pronomes e gêneros são do perfil — os gêneros são os mesmos do Onboarding (13, da T16). A regra dos 30 dias do @ e os pronomes são campos novos: pergunta da T17.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L64.1** Campos Nome, @ e Bio com os contadores
- **L64.2** Pronomes
- **L64.3** Gêneros favoritos
- **L64.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('p64.fields', 'p64.pronounsHeader', 'p64.pronouns', 'p64.genresHeader', 'p64.genres'), todos os ids de `kRef64.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/064_editar_perfil_390x1400@3x.png` no recorte da fase (y 499.82–1088.87) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef64w360` e `kRef64w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L64.1 Campos Nome, @ e Bio com os contadores
- [ ] L64.2 Pronomes
- [ ] L64.3 Gêneros favoritos
- [ ] L64.4 Verificação + relatório
- [ ] Geometria 50/50 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
