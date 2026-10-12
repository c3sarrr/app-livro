# FASE L10 — Código de 6 dígitos — o envelope e a folha (as 6 peças, reenviar e abrir o e-mail)

> Tela 10 · prancha `010_codigo` (10 · Código de 6 dígitos, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L10_codigo@3x.png` · `docs/design/medicao/projeto/png/redline/L10_codigo_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/010_codigo_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_010_codigo.json` · `test/reference/projeto/reference_layout_010_codigo.dart` (`kRef10`).
> Arquivos sugeridos: `lib/features/account/presentation/entry/otp_code_screen.dart`, `lib/features/account/presentation/entry/otp_tiles.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Código de 6 dígitos (10): o voltar, o envelope com a carta saindo (o código "482 7••"), dois brilhos e a folha — "Confira seu e-mail.", o e-mail mascarado, as 6 peças (4 8 2 – 7, a peça em foco e a vazia), o reenviar com a contagem (0:42), a dica do spam e "Abrir app de e-mail".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{env}}` = padrão `#B6ACE4`.

```html
<!-- Back -->
<a href="#" aria-label="Voltar" style="position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2;">
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg>
</a>

<!-- Envelope sticker: the letter with the code is coming out -->
<svg aria-hidden="true" width="238" height="200" viewBox="0 0 190 160" style="position: absolute; left: 112px; top: 168px; transform: rotate(-7deg); overflow: visible;">
  <polygon points="6,64 95,2 184,64" fill="{{env}}" stroke="#1A1714" stroke-width="1.5" stroke-linejoin="round"></polygon>
  <rect x="28" y="-12" width="134" height="100" rx="6" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5"></rect>
  <line x1="40" y1="16" x2="150" y2="16" stroke="#EAE1D0" stroke-width="1.2"></line>
  <text x="40" y="8" font-family="Figtree, sans-serif" font-size="9" font-weight="800" letter-spacing="1.2" fill="#5B544B">SEU CÓDIGO</text>
  <text x="40" y="48" font-family="'Bricolage Grotesque', sans-serif" font-size="27" font-weight="800" letter-spacing="2" fill="#1A1714">482 7••</text>
  <rect x="10" y="68" width="178" height="88" rx="8" fill="#1A1714"></rect>
  <rect x="6" y="64" width="178" height="88" rx="8" fill="{{env}}" stroke="#1A1714" stroke-width="1.5"></rect>
  <path d="M9 149 76 102M181 149 114 102" fill="none" stroke="#1A1714" stroke-width="1.5" stroke-linecap="round"></path>
  <circle cx="95" cy="98" r="16" fill="#FF552E" stroke="#1A1714" stroke-width="1.5"></circle>
  <path d="M95 87.5C95.3 92.2 96.2 94.6 102.5 95.5 96.2 96.4 95.3 98.8 95 103.5 94.7 98.8 93.8 96.4 87.5 95.5 93.8 94.6 94.7 92.2 95 87.5Z" fill="#FFFAF1" transform="translate(0 2.5)"></path>
</svg>

<svg aria-hidden="true" width="28" height="28" viewBox="0 0 24 24" style="position: absolute; left: 62px; top: 246px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path></svg>

<svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" style="position: absolute; left: 330px; top: 128px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>

<!-- Code sheet -->
<main aria-label="Digite o código" style="position: absolute; left: 10px; right: 10px; top: 428px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">

  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px;">Confira seu<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px;">e-mail.</span></h1>
  <p style="margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B; text-wrap: pretty;">Mandamos um código de 6 dígitos para <strong style="font-weight: 800; color: #1A1714; white-space: nowrap;">m••••@email.com</strong>.</p>

  <!-- One real input (one-time-code autofill + paste) drawn as six tiles -->
  <label for="otp" style="position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0);">Código de 6 dígitos</label>
  <input id="otp" type="text" inputmode="numeric" autocomplete="one-time-code" maxlength="6" value="4827" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">
  <div aria-hidden="true" style="margin-top: 22px; display: flex; align-items: center; justify-content: center;">
    <div style="display: flex; gap: 8px;">
      <span style="width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1;">4</span>
      <span style="width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1;">8</span>
      <span style="width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1;">2</span>
    </div>
    <span style="width: 26px; display: flex; justify-content: center;"><span style="width: 10px; height: 2.5px; border-radius: 2px; background: #1A1714;"></span></span>
    <div style="display: flex; gap: 8px;">
      <span style="width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1;">7</span>
      <span style="width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}}; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><span style="width: 2px; height: 26px; border-radius: 1px; background: #1A1714;"></span></span>
      <span style="width: 44px; height: 56px; border-radius: 12px; background: #F7F0E3; border: 1.5px dashed #A99E8C; box-sizing: border-box;"></span>
    </div>
  </div>

  <!-- Resend cooldown -->
  <div style="margin-top: 14px; height: 44px; display: flex; align-items: center; justify-content: center; gap: 8px;">
    <svg width="22" height="22" viewBox="0 0 22 22" aria-hidden="true" style="transform: rotate(-90deg);">
      <circle cx="11" cy="11" r="8.5" fill="none" stroke="#EAE1D0" stroke-width="3"></circle>
      <circle cx="11" cy="11" r="8.5" fill="none" stroke="{{brand}}" stroke-width="3" stroke-dasharray="53.4" stroke-dashoffset="16" stroke-linecap="round"></circle>
    </svg>
    <span style="font-size: 14px; font-weight: 600; color: #6F665B;">Reenviar código em <span style="font-weight: 800; color: #1A1714; font-variant-numeric: tabular-nums;">0:42</span></span>
  </div>

  <div style="margin-top: 10px; display: flex; flex-direction: column; align-items: center;">
    <p style="margin: 0 0 12px; display: flex; align-items: center; gap: 7px; font-size: 13px; font-weight: 600; color: #6F665B;">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="9"></circle><path d="M12 8v5"></path><path d="M12 16.5v.01"></path></svg>
      Não chegou? Olhe a caixa de spam.
    </p>
    <button style="width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="3"></rect><path d="m4 7 8 6 8-6"></path></svg>
      <span style="color: #F7F0E3;">Abrir app de e-mail</span>
    </button>
  </div>
</main>
```

## Especificação pixel a pixel

Seção `e10.back` — retângulo absoluto no canvas 390×844: **x=16, y=58, w=48, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e10.back` | box | 0 | 0 | 48 | 48 | `position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2` |  |
| 2 | `e10.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |

Seção `e10.envelope` — retângulo absoluto no canvas 390×844: **x=112, y=168, w=238, h=200**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `e10.envelope` | icon | 0 | 0 | 238 | 200 | `position: absolute; left: 112px; top: 168px; transform: rotate(-7deg); overflow: visible` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `e10.envelope`: caixa visual com `transform: rotate(-7deg)` = x -11.3, y -13.76, w 260.6, h 227.51 (relativa à seção).

Seção `e10.sparkleLarge` — retângulo absoluto no canvas 390×844: **x=62, y=246, w=28, h=28**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `e10.sparkleLarge` | icon | 0 | 0 | 28 | 28 | `position: absolute; left: 62px; top: 246px` |  |

Seção `e10.sparkleSmall` — retângulo absoluto no canvas 390×844: **x=330, y=128, w=18, h=18**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `e10.sparkleSmall` | icon | 0 | 0 | 18 | 18 | `position: absolute; left: 330px; top: 128px` |  |

Seção `e10.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=428, w=370, h=406**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `e10.sheet` | box | 0 | 0 | 370 | 406 | `position: absolute; left: 10px; right: 10px; top: 428px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 7 | `e10.sheet.title` | text | 21.5 | 27.5 | 327 | 72.52 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 32) 32/31.36px peso 800 ls -1px #1A1714 |
| 8 | `e10.sheet.title.serif` ±1 | inline | 21.5 | 52.14 | 112.28 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |
| 9 | `e10.sheet.lead` | text | 21.5 | 108.02 | 327 | 42.05 | `margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B; text-wrap: pretty` | Figtree 14.5/21.025px peso 500 ls normal #5B544B |
| 10 | `e10.sheet.lead.email` ±1 | inline | 21.5 | 130.85 | 123.29 | 17.41 | `font-weight: 800; color: #1A1714; white-space: nowrap` | Figtree 14.5/21.025px peso 800 ls normal #1A1714 |
| 11 | `e10.sheet.code.label` | text | 21.5 | 27.5 | 1 | 1 | `position: absolute; width: 1px; height: 1px; overflow: hidden; clip: rect(0 0 0 0)` | Figtree 16/normal peso 400 ls normal #1A1714 |
| 12 | `e10.sheet.code.input` | box | 21.5 | 27.5 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 13 | `e10.sheet.code` | box | 21.5 | 172.07 | 327 | 56 | `margin-top: 22px; display: flex; align-items: center; justify-content: center` |  |
| 14 | `e10.sheet.code.group1` | box | 24 | 172.07 | 148 | 56 | `display: flex; gap: 8px` |  |
| 15 | `e10.sheet.code.digit1` | box+text | 24 | 172.07 | 44 | 56 | `width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1` | Bricolage (opsz 28) 28/28px peso 800 ls normal #1A1714 |
| 16 | `e10.sheet.code.digit2` | box+text | 76 | 172.07 | 44 | 56 | `width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1` | Bricolage (opsz 28) 28/28px peso 800 ls normal #1A1714 |
| 17 | `e10.sheet.code.digit3` | box+text | 128 | 172.07 | 44 | 56 | `width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1` | Bricolage (opsz 28) 28/28px peso 800 ls normal #1A1714 |
| 18 | `e10.sheet.code.dash` | box | 172 | 198.82 | 26 | 2.5 | `width: 26px; display: flex; justify-content: center` |  |
| 19 | `e10.sheet.code.dash.bar` | box | 180 | 198.82 | 10 | 2.5 | `width: 10px; height: 2.5px; border-radius: 2px; background: #1A1714` |  |
| 20 | `e10.sheet.code.group2` | box | 198 | 172.07 | 148 | 56 | `display: flex; gap: 8px` |  |
| 21 | `e10.sheet.code.digit4` | box+text | 198 | 172.07 | 44 | 56 | `width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 28px; line-height: 1` | Bricolage (opsz 28) 28/28px peso 800 ls normal #1A1714 |
| 22 | `e10.sheet.code.digit5` | box | 250 | 172.07 | 44 | 56 | `width: 44px; height: 56px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}} (padrão #B6ACE4); box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 23 | `e10.sheet.code.digit5.caret` | box | 271 | 187.07 | 2 | 26 | `width: 2px; height: 26px; border-radius: 1px; background: #1A1714` |  |
| 24 | `e10.sheet.code.digit6` | box | 302 | 172.07 | 44 | 56 | `width: 44px; height: 56px; border-radius: 12px; background: #F7F0E3; border: 1.5px dashed #A99E8C; box-sizing: border-box` |  |
| 25 | `e10.sheet.resend` | box | 21.5 | 242.07 | 327 | 44 | `margin-top: 14px; height: 44px; display: flex; align-items: center; justify-content: center; gap: 8px` |  |
| 26 | `e10.sheet.resend.timer` ±1 | icon | 89.61 | 253.07 | 22 | 22 | `transform: rotate(-90deg)` |  |
| 27 | `e10.sheet.resend.text` ±1 | text | 119.62 | 255.67 | 160.77 | 16.8 | `font-size: 14px; font-weight: 600; color: #6F665B` | Figtree 14/normal peso 600 ls normal #6F665B |
| 28 | `e10.sheet.resend.text.time` ±1 | inline | 249.14 | 255.67 | 31.25 | 16.8 | `font-weight: 800; color: #1A1714; font-variant-numeric: tabular-nums` | Figtree 14/normal peso 800 ls normal #1A1714 tnum |
| 29 | `e10.sheet.help` | box | 21.5 | 296.07 | 327 | 82 | `margin-top: 10px; display: flex; flex-direction: column; align-items: center` |  |
| 30 | `e10.sheet.help.spam` ±1 | text | 69.14 | 296.07 | 231.73 | 16 | `margin: 0 0 12px; display: flex; align-items: center; gap: 7px; font-size: 13px; font-weight: 600; color: #6F665B` | Figtree 13/normal peso 600 ls normal #6F665B |
| 31 | `e10.sheet.help.spam.icon` ±1 | icon | 69.14 | 296.07 | 16 | 16 | `—` |  |
| 32 | `e10.sheet.help.openMail` | box | 21.5 | 324.07 | 327 | 54 | `width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 33 | `e10.sheet.help.openMail.icon` ±1 | icon | 98.52 | 341.07 | 20 | 20 | `—` |  |
| 34 | `e10.sheet.help.openMail.label` ±1 | text | 128.52 | 341.47 | 142.96 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e10.sheet.title` *(composto)* | 1 | Confira seu | 53.74 | 21.5 | 187.97 | 166.47 |
| `e10.sheet.title` *(composto)* | 2 | e-mail. | 93.72 | 21.5 | 133.78 | 112.28 |
| `e10.sheet.lead` *(composto)* | 1 | Mandamos um código de 6 dígitos para | 123.6 | 21.5 | 278.16 | 256.66 |
| `e10.sheet.lead` *(composto)* | 2 | m••••@email.com. | 144.62 | 21.5 | 147.97 | 126.47 |
| `e10.sheet.code.label` | 1 | Código | 42.7 | 21.5 | 74.08 | 52.58 |
| `e10.sheet.code.label` | 2 | de | 61.9 | 21.5 | 39.61 | 18.11 |
| `e10.sheet.code.label` | 3 | 6 | 81.1 | 21.5 | 30.56 | 9.06 |
| `e10.sheet.code.label` | 4 | dígitos | 100.3 | 21.5 | 70.44 | 48.94 |
| `e10.sheet.code.digit1` | 1 | 4 | 209.31 | 37.14 | 54.86 | 17.72 |
| `e10.sheet.code.digit2` | 1 | 8 | 209.31 | 88.87 | 107.13 | 18.26 |
| `e10.sheet.code.digit3` | 1 | 2 | 209.31 | 141.56 | 158.44 | 16.88 |
| `e10.sheet.code.digit4` | 1 | 7 | 209.31 | 212.82 | 227.18 | 14.36 |
| `e10.sheet.resend.text` *(composto)* | 1 | Reenviar código em 0:42 | 268.97 | 119.62 | 280.38 | 160.76 |
| `e10.sheet.help.spam` | 1 | Não chegou? Olhe a caixa de spam. | 308.62 | 92.14 | 300.87 | 208.73 |
| `e10.sheet.help.openMail.label` | 1 | Abrir app de e-mail | 356.67 | 128.52 | 271.48 | 142.96 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O voltar (48, `left 16 · top 58`, `#FFFAF1`, borda 1,5, sombra 2/2, seta 20 traço 2,2) fica por cima de tudo (`z-index 2`). Envelope 238 × 200 (viewBox 190 × 160) em `left 112 · top 168`, girado −7°, na cor `{{env}}`, com a carta passando 16 acima da caixa.
2. A folha da entrada: `left/right/bottom 10` (e um `top` por tela), padding 24–26/20/20, raio 32/32/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4, coluna. O título é sempre Bricolage 32/800 `lh 0,98` ls −1 + quebra + Instrument Serif itálico 40–42 ls −0,4, e o texto de baixo 14,5/500 `lh 1,4–1,45` `#5B544B`, 8 abaixo. Aqui: `top 428`, padding 26/20/20; o e-mail "m••••@email.com" em 800 `nowrap`.
3. Peças, 22 abaixo, centradas: dois grupos de 3 (gap 8) com o traço 10 × 2,5 no meio (26 de largura). Peça 44 × 56, raio 12, borda 1,5, sombra 3/3, o dígito Bricolage 28/800; a em foco sem sombra, com o anel `{{brand}}` de 4 e o cursor 2 × 26; a vazia `#F7F0E3` com a borda 1,5 `dashed #A99E8C`.
4. Reenviar (44, 14 abaixo): o anel 22 girado −90° (trilho `#EAE1D0`, o `{{brand}}` com `dasharray 53,4` e `offset 16`) + "Reenviar código em **0:42**" 14/600 (o tempo 800 `tnum`).
5. "Não chegou? Olhe a caixa de spam." 13/600 com o ícone 16, 10 abaixo; "Abrir app de e-mail" 54, preto, 12 abaixo.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O rótulo do código é só Semantics (o `<label>` escondido "Código de 6 dígitos"): as peças são `aria-hidden`.
- O envelope tem `<text>` com o código ("482 7••"): no app, o código digitado de verdade em `AppText`, os que faltam em •; e a carta passa 16 acima da caixa (`Clip.none`) — o mapa de widgets.
- A 360 os dois grupos passam 4,5 do pai (abaixo): as peças têm largura fixa (44) — decidir na T16 se encolhem.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_010_codigo_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_010_codigo_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `e10.sheet.code.group1` | passa do pai (x) | 4.5 | 0 | **sim** | sim | pai `e10.sheet.code` (vaza) |
| 360 | `e10.sheet.code.group2` | passa do pai (x) | 4.5 | 0 | **sim** | sim | pai `e10.sheet.code` (vaza) |

## Diferenças em relação à prancha 07 (seções reutilizadas: waves)

Estas seções são as mesmas widgets da 07 (fases L07_1_fundo_e_marca, L07_2_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 07.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e10.back` |  | Voltar |  |
| `e10.envelope` |  |  | aria-hidden=true |
| `e10.sparkleLarge` |  |  | aria-hidden=true |
| `e10.sparkleSmall` |  |  | aria-hidden=true |
| `e10.sheet` |  | Digite o código |  |
| `e10.sheet.code` |  |  | aria-hidden=true |
| `e10.sheet.resend.timer` |  |  | aria-hidden=true |
| `e10.sheet.help.spam.icon` |  |  | aria-hidden=true |
| `e10.sheet.help.openMail.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e10.back` | CircleIconButton / NeoBox circular |  |
| `e10.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `e10.envelope` | AppSvg(AppIllustrationsEntrada.envelopeCodigo, size: 238×200) | cores dinâmicas: #B6ACE4 = env · tem `<text>` ("SEU CÓDIGO" Figtree 800 9 ls 1,2 e "482 7••" Bricolage 800 27 ls 2): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho sem os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7) — o código é o enviado de verdade, com os dígitos que faltam em •. desenha fora da própria caixa (o papel em y −12 do viewBox 190×160: sai 16 px acima da caixa 238×200; o `<svg>` tem overflow: visible): no app, sem recorte (o SvgPicture com clipBehavior: Clip.none, ou o pintor sem clip) — com o recorte padrão, o que passa some. |
| `e10.sparkleLarge` | AppSvg(AppIcons.sparkleOutline, size: 28) |  |
| `e10.sparkleSmall` | AppSvg(AppIcons.sparkleSolid, size: 18) |  |
| `e10.sheet` | NeoBox |  |
| `e10.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e10.sheet.lead.email` | TextSpan dentro do AppText.rich do pai |  |
| `e10.sheet.code.input` | NeoBox |  |
| `e10.sheet.code.digit1` | NeoBox + AppText |  |
| `e10.sheet.code.digit2` | NeoBox + AppText |  |
| `e10.sheet.code.digit3` | NeoBox + AppText |  |
| `e10.sheet.code.dash.bar` | NeoBox |  |
| `e10.sheet.code.digit4` | NeoBox + AppText |  |
| `e10.sheet.code.digit5` | NeoBox |  |
| `e10.sheet.code.digit5.caret` | NeoBox |  |
| `e10.sheet.code.digit6` | NeoBox |  |
| `e10.sheet.resend.timer` | CustomPainter (anel_reenviar_codigo) | cores dinâmicas: #B6ACE4 = brand · stroke-dasharray = progresso (dasharray 53,4 com dashoffset 16 → 70 % restante da contagem): anel desenhado por CustomPainter com o valor real; o SVG é a referência do estado da prancha. |
| `e10.sheet.resend.text.time` | TextSpan dentro do AppText.rich do pai |  |
| `e10.sheet.help.spam.icon` | AppSvg(AppIconsEntrada.alertCinza, size: 16) |  |
| `e10.sheet.help.openMail` | NeoBox |  |
| `e10.sheet.help.openMail.icon` | AppSvg(AppIconsEntrada.mail, size: 20) |  |

## Interações

- Um `TextField` invisível (`AutofillHints.oneTimeCode`, numérico, 6) desenhado como 6 peças; colar preenche todas; no 6º dígito verifica sem botão (nota do design).
- Reenviar libera depois de 60 s (o anel mostra o que falta).
- Abrir app de e-mail → `url_launcher`.
- Código certo: vindo de "Esqueci a senha" → a Nova senha (11); vindo de "Receber código" → a Início. Código errado não tem prancha — pergunta da T16.

## Dados

- O e-mail da pessoa mascarado (a regra da máscara: a 1ª letra e o domínio); o código enviado pelo servidor (autenticação sem senha da G05).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L10.1** Envelope e brilhos
- **L10.2** Seis peças sobre um campo invisível
- **L10.3** Reenviar com a contagem
- **L10.4** Spam e abrir o e-mail
- **L10.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e10.back', 'e10.envelope', 'e10.sparkleLarge', 'e10.sparkleSmall', 'e10.sheet'), todos os ids de `kRef10.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/010_codigo_390x844@3x.png` no recorte da fase (y 50–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef10w360` e `kRef10w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L10.1 Envelope e brilhos
- [ ] L10.2 Seis peças sobre um campo invisível
- [ ] L10.3 Reenviar com a contagem
- [ ] L10.4 Spam e abrir o e-mail
- [ ] L10.5 Verificação + relatório
- [ ] Geometria 31/31 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
