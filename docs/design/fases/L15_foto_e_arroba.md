# FASE L15 — Onboarding 4/4 — a foto, o @ e a frase sobre você

> Tela 15 · prancha `015_onboarding_foto` (15 · Onboarding 4/4 — Foto e @, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L15_foto_e_arroba@3x.png` · `docs/design/medicao/projeto/png/redline/L15_foto_e_arroba_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/015_onboarding_foto_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_015_onboarding_foto.json` · `test/reference/projeto/reference_layout_015_onboarding_foto.dart` (`kRef15`).
> Arquivos sugeridos: `lib/features/account/presentation/onboarding/profile_step.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Onboarding 4/4 — Foto e @ (15): "Quase lá! Seu perfil.", o avatar com a inicial M (girado −5°) e a câmera, "Escolher da galeria", o nome de usuário com o visto e "Disponível", a frase sobre você (0/80) e "Criar minha carteirinha".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{progress}}` = padrão `#FF552E`, `{{avatar}}` = padrão `#FED170`.

```html
<div style="position: relative; margin-top: 36px;">
  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px;">Quase lá!<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px;">Seu perfil.</span></h1>
  <svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" style="position: absolute; right: 14px; top: 30px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>
</div>

<p style="margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B;">É assim que você aparece nos clubes.</p>

<!-- Photo (optional): letter avatar until a photo is chosen -->
<div style="margin-top: 22px; display: flex; align-items: center; gap: 20px;">
  <div style="position: relative; width: 112px; height: 112px; flex-shrink: 0;">
    <span role="img" aria-label="Avatar com a inicial M" style="position: absolute; inset: 0; border-radius: 50%; background: {{avatar}}; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-5deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 66px; line-height: 1; padding-bottom: 6px;">M</span>
    <button aria-label="Adicionar foto" style="position: absolute; right: -6px; bottom: -4px; width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #1A1714; border: 3px solid #F7F0E3; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFAF1" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3z"></path><circle cx="12" cy="13" r="3.5"></circle></svg>
    </button>
  </div>
  <div style="min-width: 0; display: flex; flex-direction: column; align-items: flex-start;">
    <span style="display: flex; align-items: center; gap: 8px;">
      <span style="font-size: 15px; font-weight: 800;">Foto de perfil</span>
      <span style="height: 22px; padding: 0 8px; border-radius: 999px; border: 1.5px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #5B544B;">Opcional</span>
    </span>
    <span style="margin-top: 4px; font-size: 13px; font-weight: 500; line-height: 1.4; color: #5B544B;">Sem foto, usamos a sua inicial.</span>
    <button style="margin-top: 10px; height: 40px; padding: 0 14px 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 13.5px; font-weight: 800;">
      <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="3"></rect><circle cx="9" cy="9" r="2"></circle><path d="m21 15-3.1-3.1a2 2 0 0 0-2.8 0L6 21"></path></svg>
      Escolher da galeria
    </button>
  </div>
</div>

<!-- Username: suggested from the name, checked while typing -->
<label for="ob-user" style="margin-top: 24px; font-size: 13.5px; font-weight: 800; line-height: 18px;">Nome de usuário</label>

<div style="margin-top: 6px; height: 52px; padding: 0 12px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}}; box-sizing: border-box; display: flex; align-items: center; gap: 2px;">
  <span aria-hidden="true" style="font-size: 16px; font-weight: 800; color: #8A8073;">@</span>
  <span style="display: flex; align-items: center; flex-grow: 1; min-width: 0;">
    <span style="font-size: 16px; font-weight: 700;">marinacosta</span>
    <span aria-hidden="true" style="margin-left: 1px; width: 2px; height: 22px; border-radius: 1px; background: #1A1714;"></span>
  </span>
  <input id="ob-user" type="text" autocomplete="username" autocapitalize="none" value="marinacosta" aria-describedby="ob-user-status" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">
  <span aria-hidden="true" style="width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.8" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
</div>

<p id="ob-user-status" role="status" style="margin: 10px 0 0 2px; display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 700; color: #1A1714;">
  <span style="height: 22px; padding: 0 9px; border-radius: 999px; background: #E1EDD0; display: flex; align-items: center; font-size: 12px; font-weight: 800; color: #2E5314;">Disponível</span>
  <span style="font-weight: 500; color: #6F665B;">Letras, números, ponto e _</span>
</p>

<!-- Optional one-liner shown on the profile -->
<div style="margin-top: 22px; display: flex; align-items: center; justify-content: space-between;">
  <span style="display: flex; align-items: center; gap: 8px;">
    <label for="ob-bio" style="font-size: 13.5px; font-weight: 800; line-height: 18px;">Uma frase sobre você</label>
    <span style="height: 22px; padding: 0 8px; border-radius: 999px; border: 1.5px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #5B544B;">Opcional</span>
  </span>
  <span aria-hidden="true" style="font-size: 12px; font-weight: 700; color: #8A8073; font-variant-numeric: tabular-nums;">0/80</span>
</div>

<div style="position: relative; margin-top: 6px;">
  <textarea id="ob-bio" rows="2" maxlength="80" placeholder="Ex.: Leio um capítulo antes de dormir." style="display: block; width: 100%; height: 76px; padding: 13px 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; resize: none; outline: none; font-family: inherit; font-size: 15px; font-weight: 500; line-height: 1.4; color: #1A1714;"></textarea>
  <svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#8A8073" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="position: absolute; right: 12px; bottom: 12px;"><path d="M12 20h9"></path><path d="M16.4 3.6a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"></path></svg>
</div>

<p style="margin: 8px 0 0 2px; font-size: 12.5px; font-weight: 500; color: #6F665B;">Aparece no seu Perfil. Dá para mudar quando quiser.</p>

<button style="margin-top: auto; flex-shrink: 0; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
  <span style="color: #F7F0E3;">Criar minha carteirinha</span>
  <svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170"></path></svg>
</button>
```

## Especificação pixel a pixel

Seção `e15.heading` — retângulo absoluto no canvas 390×844: **x=20, y=142, w=350, h=78.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e15.heading` | box | 0 | 0 | 350 | 78.4 | `position: relative; margin-top: 36px` |  |
| 2 | `e15.heading.title` | text | 0 | 0 | 350 | 78.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1.1px #1A1714 |
| 3 | `e15.heading.title.serif` ±1 | inline | 0 | 25.96 | 160.93 | 59.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px` | Instrument Serif itálico 46/45.08px peso 400 ls -0.5px #1A1714 |
| 4 | `e15.heading.sparkle` | icon | 312 | 30 | 24 | 24 | `position: absolute; right: 14px; top: 30px` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e15.heading.title` *(composto)* | 1 | Quase lá! | 27.88 | 0 | 139.47 | 139.47 |
| `e15.heading.title` *(composto)* | 2 | Seu perfil. | 71.5 | 0 | 160.93 | 160.93 |

Seção `e15.lead` — retângulo absoluto no canvas 390×844: **x=20, y=230.4, w=350, h=21.02**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `e15.lead` | text | 0 | 0 | 350 | 21.02 | `margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B` | Figtree 14.5/21.025px peso 500 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e15.lead` | 1 | É assim que você aparece nos clubes. | 15.58 | 0 | 244.33 | 244.33 |

Seção `e15.photo` — retângulo absoluto no canvas 390×844: **x=20, y=273.43, w=350, h=112**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `e15.photo` | box | 0 | 0 | 350 | 112 | `margin-top: 22px; display: flex; align-items: center; gap: 20px` |  |
| 7 | `e15.photo.avatarWrap` | box | 0 | 0 | 112 | 112 | `position: relative; width: 112px; height: 112px; flex-shrink: 0` |  |
| 8 | `e15.photo.avatar` | box+text | 0 | 0 | 112 | 112 | `position: absolute; inset: 0; border-radius: 50%; background: {{avatar}} (padrão #FED170); border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-5deg); font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 66px; line-height: 1; padding-bottom: 6px` | Instrument Serif itálico 66/66px peso 400 ls normal #1A1714 |
| 9 | `e15.photo.add` | box | 74 | 72 | 44 | 44 | `position: absolute; right: -6px; bottom: -4px; width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #1A1714; border: 3px solid #F7F0E3; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 10 | `e15.photo.add.icon` | icon | 86 | 84 | 20 | 20 | `—` |  |
| 11 | `e15.photo.info` ±1 | box | 132 | 8.89 | 177.74 | 94.2 | `min-width: 0; display: flex; flex-direction: column; align-items: flex-start` |  |
| 12 | `e15.photo.info.titleRow` ±1 | box | 132 | 8.89 | 166.59 | 22 | `display: flex; align-items: center; gap: 8px` |  |
| 13 | `e15.photo.info.title` ±1 | text | 132 | 10.89 | 93.67 | 18 | `font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 14 | `e15.photo.info.optional` ±1 | box+text | 233.68 | 8.89 | 64.91 | 22 | `height: 22px; padding: 0 8px; border-radius: 999px; border: 1.5px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #5B544B` | Figtree 11/normal peso 800 ls normal #5B544B |
| 15 | `e15.photo.info.hint` ±1 | text | 132 | 34.89 | 177.74 | 18.2 | `margin-top: 4px; font-size: 13px; font-weight: 500; line-height: 1.4; color: #5B544B` | Figtree 13/18.2px peso 500 ls normal #5B544B |
| 16 | `e15.photo.info.gallery` ±1 | box+text | 132 | 63.09 | 171.46 | 40 | `margin-top: 10px; height: 40px; padding: 0 14px 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 13.5px; font-weight: 800` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 17 | `e15.photo.info.gallery.icon` | icon | 145.5 | 74.59 | 17 | 17 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `e15.photo.avatar`: caixa visual com `transform: rotate(-5deg)` = x -4.67, y -4.67, w 121.33, h 121.33 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e15.photo.avatar` | 1 | M | 75.44 | 34.05 | 77.94 | 43.89 |
| `e15.photo.info.title` | 1 | Foto de perfil | 25.14 | 132 | 225.68 | 93.68 |
| `e15.photo.info.optional` | 1 | Opcional | 23.75 | 243.18 | 289.09 | 45.91 |
| `e15.photo.info.hint` | 1 | Sem foto, usamos a sua inicial. | 48.55 | 132 | 309.74 | 177.74 |
| `e15.photo.info.gallery` | 1 | Escolher da galeria | 87.82 | 169.5 | 287.96 | 118.46 |

Seção `e15.username` — retângulo absoluto no canvas 390×844: **x=20, y=409.43, w=350, h=108**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 18 | `e15.username.label` | text | 0 | 0 | 350 | 18 | `margin-top: 24px; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 19 | `e15.username.field` | box | 0 | 24 | 350 | 52 | `margin-top: 6px; height: 52px; padding: 0 12px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}} (padrão #B6ACE4); box-sizing: border-box; display: flex; align-items: center; gap: 2px` |  |
| 20 | `e15.username.field.at` ±1 | text | 17.5 | 40.39 | 15.89 | 19.2 | `font-size: 16px; font-weight: 800; color: #8A8073` | Figtree 16/normal peso 800 ls normal #8A8073 |
| 21 | `e15.username.field.value` ±1 | box | 35.39 | 39 | 275.11 | 22 | `display: flex; align-items: center; flex-grow: 1; min-width: 0` |  |
| 22 | `e15.username.field.text` ±1 | text | 35.39 | 40.39 | 90.66 | 19.2 | `font-size: 16px; font-weight: 700` | Figtree 16/normal peso 700 ls normal #1A1714 |
| 23 | `e15.username.field.caret` ±1 | box | 127.04 | 39 | 2 | 22 | `margin-left: 1px; width: 2px; height: 22px; border-radius: 1px; background: #1A1714` |  |
| 24 | `e15.username.field.input` | box | 17.5 | 46.5 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 25 | `e15.username.field.valid` | box | 312.5 | 38 | 24 | 24 | `width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 26 | `e15.username.field.valid.icon` | icon | 319 | 44.5 | 11 | 11 | `—` |  |
| 27 | `e15.username.status` | box | 2 | 86 | 348 | 22 | `margin: 10px 0 0 2px; display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 700; color: #1A1714` |  |
| 28 | `e15.username.status.chip` ±1 | box+text | 2 | 86 | 76.43 | 22 | `height: 22px; padding: 0 9px; border-radius: 999px; background: #E1EDD0; display: flex; align-items: center; font-size: 12px; font-weight: 800; color: #2E5314` | Figtree 12/normal peso 800 ls normal #2E5314 |
| 29 | `e15.username.status.rule` ±1 | text | 84.43 | 89.19 | 153.85 | 15.6 | `font-weight: 500; color: #6F665B` | Figtree 13/normal peso 500 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e15.username.label` | 1 | Nome de usuário | 13.71 | 0 | 105.87 | 105.87 |
| `e15.username.field.at` | 1 | @ | 55.59 | 17.5 | 33.39 | 15.89 |
| `e15.username.field.text` | 1 | marinacosta | 55.59 | 35.39 | 126.04 | 90.65 |
| `e15.username.status.chip` | 1 | Disponível | 101.19 | 11 | 69.43 | 58.43 |
| `e15.username.status.rule` | 1 | Letras, números, ponto e _ | 101.55 | 84.43 | 238.28 | 153.85 |

Seção `e15.bio` — retângulo absoluto no canvas 390×844: **x=20, y=539.42, w=350, h=127.01**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 30 | `e15.bio.header` | box | 0 | 0 | 350 | 22 | `margin-top: 22px; display: flex; align-items: center; justify-content: space-between` |  |
| 31 | `e15.bio.header.labelRow` ±1 | box | 0 | 0 | 208.87 | 22 | `display: flex; align-items: center; gap: 8px` |  |
| 32 | `e15.bio.label` ±1 | text | 0 | 2 | 135.96 | 18 | `font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 33 | `e15.bio.optional` ±1 | box+text | 143.96 | 0 | 64.91 | 22 | `height: 22px; padding: 0 8px; border-radius: 999px; border: 1.5px solid #CFC3AE; box-sizing: border-box; display: flex; align-items: center; font-size: 11px; font-weight: 800; color: #5B544B` | Figtree 11/normal peso 800 ls normal #5B544B |
| 34 | `e15.bio.counter` ±1 | text | 322.06 | 3.81 | 27.94 | 14.4 | `font-size: 12px; font-weight: 700; color: #8A8073; font-variant-numeric: tabular-nums` | Figtree 12/normal peso 700 ls normal #8A8073 tnum |
| 35 | `e15.bio.field` | box | 0 | 28 | 350 | 76 | `position: relative; margin-top: 6px` |  |
| 36 | `e15.bio.field.input` | box | 0 | 28 | 350 | 76 | `display: block; width: 100%; height: 76px; padding: 13px 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; resize: none; outline: none; font-family: inherit; font-size: 15px; font-weight: 500; line-height: 1.4; color: #1A1714` |  |
| 37 | `e15.bio.field.icon` | icon | 320 | 74 | 18 | 18 | `position: absolute; right: 12px; bottom: 12px` |  |
| 38 | `e15.bio.hint` | text | 2 | 112 | 348 | 15.01 | `margin: 8px 0 0 2px; font-size: 12.5px; font-weight: 500; color: #6F665B` | Figtree 12.5/normal peso 500 ls normal #6F665B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e15.bio.label` | 1 | Uma frase sobre você | 15.72 | 0 | 135.96 | 135.96 |
| `e15.bio.optional` | 1 | Opcional | 14.85 | 153.46 | 199.37 | 45.91 |
| `e15.bio.counter` | 1 | 0/80 | 15.2 | 322.06 | 350 | 27.94 |
| `e15.bio.hint` | 1 | Aparece no seu Perfil. Dá para mudar quando quiser. | 123.88 | 2 | 294.36 | 292.36 |

Seção `e15.continue` — retângulo absoluto no canvas 390×844: **x=20, y=756, w=350, h=54**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 39 | `e15.continue` | box | 0 | 0 | 350 | 54 | `margin-top: auto; flex-shrink: 0; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 40 | `e15.continue.label` ±1 | text | 74.1 | 17.4 | 171.81 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 41 | `e15.continue.icon` ±1 | icon | 255.9 | 17 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e15.continue.label` | 1 | Criar minha carteirinha | 32.6 | 74.1 | 245.9 | 171.8 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo com "4 de 4" e a barra toda em `{{progress}}` (sem hachura nem ponta); título "Quase lá!" + "Seu perfil." Instrument Serif 46.
2. Foto, 22 abaixo (gap 20): o avatar 112 (`{{avatar}}`, borda 1,5, sombra 4/4, girado −5°, "M" Instrument Serif itálico 66) e a câmera 44 preta com a borda 3 `#F7F0E3` em `right −6 · bottom −4`; ao lado, "Foto de perfil" 15/800 + "Opcional" (pílula 22, borda `#CFC3AE`), o texto 13/500 e "Escolher da galeria" (40).
3. Usuário, 24 abaixo: o campo em foco (anel `{{brand}}`): "@" 16/800 `#8A8073`, "marinacosta" 16/700, o cursor e o visto 24; embaixo, "Disponível" (pílula `#E1EDD0`/`#2E5314`) + "Letras, números, ponto e _" 500 `#6F665B` (`role=status`).
4. Frase, 22 abaixo: rótulo + "Opcional" + "0/80" 12/700 `tnum`; a área de 76 (padding 13/16, `#F7F0E3`) com o lápis 18 no canto; o texto 12,5/500, 8 abaixo. "Criar minha carteirinha" 54 com a estrela amarela, no fundo.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O input do @ é o `TextField` escondido atrás do texto desenhado (o "marinacosta" é um `<span>`): o input usa a fonte do sistema no navegador (R8, abaixo), mas não aparece — no app, o texto desenhado vem do controller.
- "Ex.: Leio um capítulo antes de dormir." é o `placeholder` do `textarea` (cor padrão do Chromium).
- `e15.username.field.input` usa glifo de fonte do sistema (Liberation Sans (11 glifo(s))) — no navegador o resultado depende da máquina.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_015_onboarding_foto_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_015_onboarding_foto_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 14 (seções reutilizadas: waves, top)

Estas seções são as mesmas widgets da 14 (fases L14_1_busca, L14_2_sugestoes); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `e15.top.step` | texto «3 de 4» → «4 de 4» |
| `e15.top.progress` | bg: null → "#FF552E"; bgImage: "repeating-linear-gradient(135deg, #E9DFCC 0px, #E9DFCC 3px, #FFFAF1 3px, #FFFAF1 7px)" → null |

Só na base: `top.progress.fill`, `top.progress.fill.edge`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e15.heading.sparkle` |  |  | aria-hidden=true |
| `e15.photo.avatar` | img | Avatar com a inicial M |  |
| `e15.photo.add` |  | Adicionar foto |  |
| `e15.photo.add.icon` |  |  | aria-hidden=true |
| `e15.photo.info.gallery.icon` |  |  | aria-hidden=true |
| `e15.username.field.at` |  |  | aria-hidden=true |
| `e15.username.field.caret` |  |  | aria-hidden=true |
| `e15.username.field.input` |  |  | aria-describedby=ob-user-status |
| `e15.username.field.valid` |  |  | aria-hidden=true |
| `e15.username.status` | status |  |  |
| `e15.bio.counter` |  |  | aria-hidden=true |
| `e15.bio.field.icon` |  |  | aria-hidden=true |
| `e15.continue.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e15.heading.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e15.heading.sparkle` | AppSvg(AppIconsScanner.sparkleLavanda, size: 24) |  |
| `e15.photo.avatar` | CircleIconButton / NeoBox circular | Transform: rotate(-5deg) |
| `e15.photo.add` | CircleIconButton / NeoBox circular |  |
| `e15.photo.add.icon` | AppSvg(AppIconsEntrada.cameraCreme, size: 20) |  |
| `e15.photo.info.optional` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e15.photo.info.gallery` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e15.photo.info.gallery.icon` | AppSvg(AppIconsEntrada.imageSmall, size: 17) |  |
| `e15.username.field` | NeoBox |  |
| `e15.username.field.caret` | NeoBox |  |
| `e15.username.field.input` | NeoBox |  |
| `e15.username.field.valid` | CircleIconButton / NeoBox circular |  |
| `e15.username.field.valid.icon` | AppSvg(AppIconsEntrada.checkValid, size: 11) |  |
| `e15.username.status.chip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e15.bio.optional` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e15.bio.field.input` | NeoBox |  |
| `e15.bio.field.icon` | AppSvg(AppIconsEntrada.pencilNote, size: 18) |  |
| `e15.continue` | NeoBox |  |
| `e15.continue.icon` | AppSvg(AppIconsInicio.sparkleSolidYellow, size: 20) |  |

## Interações

- Câmera e Escolher da galeria → `image_picker` (câmera ou galeria); sem foto, a inicial.
- @ sugerido pelo nome e conferido enquanto digita (~400 ms depois da última tecla); em uso → "Já em uso" e chips com ideias parecidas (nota do design; esse estado não tem prancha).
- Frase opcional até 80 caracteres, mostrada no Perfil.
- Criar minha carteirinha → a carteirinha pronta (16).

## Dados

- Nome (do cadastro), o @ (a regra e a checagem da G05, D-69), a foto e a frase.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L15.1** Avatar e foto
- **L15.2** @ com a checagem ao vivo
- **L15.3** Frase sobre você
- **L15.4** Criar minha carteirinha
- **L15.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e15.heading', 'e15.lead', 'e15.photo', 'e15.username', 'e15.bio', 'e15.continue'), todos os ids de `kRef15.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/015_onboarding_foto_390x844@3x.png` no recorte da fase (y 134–818) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef15w360` e `kRef15w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L15.1 Avatar e foto
- [ ] L15.2 @ com a checagem ao vivo
- [ ] L15.3 Frase sobre você
- [ ] L15.4 Criar minha carteirinha
- [ ] L15.5 Verificação + relatório
- [ ] Geometria 40/40 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
