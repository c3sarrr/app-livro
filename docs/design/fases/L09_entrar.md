# FASE L09 — Entrar — o selo e a folha (e-mail, senha, "ou" e o código por e-mail)

> Tela 09 · prancha `009_entrar` (09 · Entrar com e-mail, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L09_entrar@3x.png` · `docs/design/medicao/projeto/png/redline/L09_entrar_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/009_entrar_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_009_entrar.json` · `test/reference/projeto/reference_layout_009_entrar.dart` (`kRef09`).
> Arquivos sugeridos: `lib/features/account/presentation/entry/sign_in_email_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Entrar com e-mail (09): o voltar, o selo "DE VOLTA À LEITURA · BOOKNEST" girado −10°, dois brilhos e a folha — "Que bom te ver de novo.", E-mail, Senha (com "Esqueci a senha"), Entrar, o "ou" e "Receber código por e-mail", e "Ainda não tem conta? Criar conta" no pé.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{badge}}` = padrão `#FED170`.

```html
<!-- Back to Login -->
<a href="#" aria-label="Voltar para o login" style="position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2;">
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg>
</a>

<!-- Badge: same family as the Login ring -->
<svg aria-hidden="true" width="132" height="132" viewBox="0 0 124 124" style="position: absolute; right: 30px; top: 78px; transform: rotate(-10deg);">
  <defs><path id="entrar-ring" d="M62 62m-41 0a41 41 0 1 1 82 0a41 41 0 1 1-82 0"></path></defs>
  <circle cx="65" cy="65" r="56" fill="#1A1714"></circle>
  <circle cx="62" cy="62" r="56" fill="{{badge}}" stroke="#1A1714" stroke-width="1.5"></circle>
  <circle cx="62" cy="62" r="29" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5"></circle>
  <text font-family="Figtree, sans-serif" font-size="11.5" font-weight="800" fill="#1A1714"><textPath href="#entrar-ring" textLength="252" lengthAdjust="spacing">DE VOLTA À LEITURA · BOOKNEST ·</textPath></text>
  <path d="M54 48h16v27l-8-6-8 6z" fill="#FF552E" stroke="#1A1714" stroke-width="1.8" stroke-linejoin="round"></path>
</svg>

<svg aria-hidden="true" width="30" height="30" viewBox="0 0 24 24" style="position: absolute; left: 92px; top: 150px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path></svg>

<svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" style="position: absolute; left: 150px; top: 112px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>

<!-- Sign-in sheet -->
<main aria-label="Entrar com e-mail" style="position: absolute; left: 10px; right: 10px; top: 242px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 12px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">

  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px;">Que bom te ver<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px;">de novo.</span></h1>
  <p style="margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.4; color: #5B544B;">Sua leitura está te esperando.</p>

  <form style="margin: 18px 0 0; display: flex; flex-direction: column;">

    <label for="si-email" style="font-size: 13.5px; font-weight: 800; line-height: 18px;">E-mail</label>
    <div style="margin-top: 6px; height: 52px; padding: 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center;">
      <input id="si-email" type="email" autocomplete="username" inputmode="email" value="marina.costa@email.com" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714;">
    </div>

    <div style="margin-top: 14px; display: flex; align-items: center; justify-content: space-between;">
      <label for="si-pass" style="font-size: 13.5px; font-weight: 800; line-height: 18px;">Senha</label>
      <a href="#" style="margin: -13px -8px -13px 0; padding: 0 8px; height: 44px; display: flex; align-items: center; font-size: 13.5px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px;">Esqueci a senha</a>
    </div>
    <div style="margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}}; box-sizing: border-box; display: flex; align-items: center;">
      <span style="flex-grow: 1; min-width: 0; display: flex; align-items: center; gap: 2px;">
        <span style="font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1;">•••••••••</span>
        <span aria-hidden="true" style="width: 2px; height: 22px; border-radius: 1px; background: #1A1714;"></span>
      </span>
      <input id="si-pass" type="password" autocomplete="current-password" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">
      <button type="button" aria-label="Mostrar senha" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z"></path><circle cx="12" cy="12" r="3"></circle></svg>
      </button>
    </div>

    <button type="submit" style="margin-top: 18px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
      <span style="color: #F7F0E3;">Entrar</span>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </button>
  </form>

  <!-- "ou" divider -->
  <div aria-hidden="true" style="margin-top: 14px; display: flex; align-items: center; gap: 12px;">
    <span style="flex-grow: 1; height: 1.5px; background: #E2D7C4;"></span>
    <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 19px; line-height: 1; color: #5B544B;">ou</span>
    <span style="flex-grow: 1; height: 1.5px; background: #E2D7C4;"></span>
  </div>

  <!-- Passwordless alternative -->
  <button style="margin-top: 14px; width: 100%; height: 52px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: none; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 15.5px; font-weight: 800; color: #1A1714;">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="3"></rect><path d="m4 7 8 6 8-6"></path></svg>
    Receber código por e-mail
  </button>

  <p style="margin: auto 0 0; height: 44px; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 14px; font-weight: 600; color: #5B544B;">Ainda não tem conta? <a href="#" style="font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Criar conta</a></p>
</main>
```

## Especificação pixel a pixel

Seção `e09.back` — retângulo absoluto no canvas 390×844: **x=16, y=58, w=48, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e09.back` | box | 0 | 0 | 48 | 48 | `position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2` |  |
| 2 | `e09.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |

Seção `e09.badge` — retângulo absoluto no canvas 390×844: **x=228, y=78, w=132, h=132**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `e09.badge` | icon | 0 | 0 | 132 | 132 | `position: absolute; right: 30px; top: 78px; transform: rotate(-10deg)` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `e09.badge`: caixa visual com `transform: rotate(-10deg)` = x -10.46, y -10.46, w 152.92, h 152.92 (relativa à seção).

Seção `e09.sparkleLarge` — retângulo absoluto no canvas 390×844: **x=92, y=150, w=30, h=30**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `e09.sparkleLarge` | icon | 0 | 0 | 30 | 30 | `position: absolute; left: 92px; top: 150px` |  |

Seção `e09.sparkleSmall` — retângulo absoluto no canvas 390×844: **x=150, y=112, w=18, h=18**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `e09.sparkleSmall` | icon | 0 | 0 | 18 | 18 | `position: absolute; left: 150px; top: 112px` |  |

Seção `e09.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=242, w=370, h=592**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `e09.sheet` | box | 0 | 0 | 370 | 592 | `position: absolute; left: 10px; right: 10px; top: 242px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 12px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 7 | `e09.sheet.title` | text | 21.5 | 27.5 | 327 | 72.52 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 32) 32/31.36px peso 800 ls -1px #1A1714 |
| 8 | `e09.sheet.title.serif` ±1 | inline | 21.5 | 52.14 | 119.86 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |
| 9 | `e09.sheet.lead` | text | 21.5 | 108.02 | 327 | 20.3 | `margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.4; color: #5B544B` | Figtree 14.5/20.3px peso 500 ls normal #5B544B |
| 10 | `e09.sheet.form` | box | 21.5 | 146.32 | 327 | 238 | `margin: 18px 0 0; display: flex; flex-direction: column` |  |
| 11 | `e09.sheet.form.email.label` | text | 21.5 | 146.32 | 327 | 18 | `font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 12 | `e09.sheet.form.email.field` | box | 21.5 | 170.32 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center` |  |
| 13 | `e09.sheet.form.email.field.input` | box | 39 | 171.82 | 292 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 14 | `e09.sheet.form.password.header` | box | 21.5 | 236.32 | 327 | 18 | `margin-top: 14px; display: flex; align-items: center; justify-content: space-between` |  |
| 15 | `e09.sheet.form.password.label` ±1 | text | 21.5 | 236.32 | 38.49 | 18 | `font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 16 | `e09.sheet.form.password.forgot` ±1 | text | 241.19 | 223.32 | 115.31 | 44 | `margin: -13px -8px -13px 0; padding: 0 8px; height: 44px; display: flex; align-items: center; font-size: 13.5px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 17 | `e09.sheet.form.password.field` | box | 21.5 | 260.32 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}} (padrão #B6ACE4); box-sizing: border-box; display: flex; align-items: center` |  |
| 18 | `e09.sheet.form.password.field.value` | box | 39 | 275.32 | 260 | 22 | `flex-grow: 1; min-width: 0; display: flex; align-items: center; gap: 2px` |  |
| 19 | `e09.sheet.form.password.field.dots` ±1 | text | 39 | 277.32 | 96.86 | 18 | `font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1` | Figtree 18/18px peso 800 ls 2.5px #1A1714 |
| 20 | `e09.sheet.form.password.field.caret` ±1 | box | 137.86 | 275.32 | 2 | 22 | `width: 2px; height: 22px; border-radius: 1px; background: #1A1714` |  |
| 21 | `e09.sheet.form.password.field.input` | box | 39 | 282.82 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 22 | `e09.sheet.form.password.field.reveal` | box | 299 | 264.32 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 23 | `e09.sheet.form.password.field.reveal.icon` | icon | 310 | 275.32 | 22 | 22 | `—` |  |
| 24 | `e09.sheet.form.submit` | box | 21.5 | 330.32 | 327 | 54 | `margin-top: 18px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 25 | `e09.sheet.form.submit.label` ±1 | text | 146.72 | 347.72 | 46.56 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 26 | `e09.sheet.form.submit.icon` ±1 | icon | 203.28 | 347.32 | 20 | 20 | `—` |  |
| 27 | `e09.sheet.divider` | box | 21.5 | 398.32 | 327 | 19 | `margin-top: 14px; display: flex; align-items: center; gap: 12px` |  |
| 28 | `e09.sheet.divider.lineLeft` ±1 | box | 21.5 | 407.07 | 142.74 | 1.5 | `flex-grow: 1; height: 1.5px; background: #E2D7C4` |  |
| 29 | `e09.sheet.divider.label` ±1 | text | 176.24 | 398.32 | 17.52 | 19 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 19px; line-height: 1; color: #5B544B` | Instrument Serif itálico 19/19px peso 400 ls normal #5B544B |
| 30 | `e09.sheet.divider.lineRight` ±1 | box | 205.76 | 407.07 | 142.74 | 1.5 | `flex-grow: 1; height: 1.5px; background: #E2D7C4` |  |
| 31 | `e09.sheet.code` | box+text | 21.5 | 431.32 | 327 | 52 | `margin-top: 14px; width: 100%; height: 52px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: none; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 15.5px; font-weight: 800; color: #1A1714` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 32 | `e09.sheet.code.icon` ±1 | icon | 74.81 | 447.32 | 20 | 20 | `—` |  |
| 33 | `e09.sheet.signUp` | text | 21.5 | 534.5 | 327 | 44 | `margin: auto 0 0; height: 44px; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 34 | `e09.sheet.signUp.link` ±1 | text | 220.46 | 548.1 | 73.05 | 16.8 | `font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 14/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e09.sheet.title` *(composto)* | 1 | Que bom te ver | 53.74 | 21.5 | 240.26 | 218.76 |
| `e09.sheet.title` *(composto)* | 2 | de novo. | 93.72 | 21.5 | 141.36 | 119.86 |
| `e09.sheet.lead` | 1 | Sua leitura está te esperando. | 123.24 | 21.5 | 214.27 | 192.77 |
| `e09.sheet.form.email.label` | 1 | E-mail | 160.04 | 21.5 | 61.27 | 39.77 |
| `e09.sheet.form.password.label` | 1 | Senha | 250.04 | 21.5 | 59.99 | 38.49 |
| `e09.sheet.form.password.forgot` | 1 | Esqueci a senha | 250.05 | 249.19 | 348.5 | 99.31 |
| `e09.sheet.form.password.field.dots` | 1 | ••••••••• | 292.62 | 39 | 135.86 | 96.86 |
| `e09.sheet.form.submit.label` | 1 | Entrar | 362.92 | 146.72 | 193.28 | 46.56 |
| `e09.sheet.divider.label` | 1 | ou | 414.28 | 176.24 | 193.76 | 17.52 |
| `e09.sheet.code` | 1 | Receber código por e-mail | 462.75 | 104.81 | 295.19 | 190.38 |
| `e09.sheet.signUp` | 1 | Ainda não tem conta? | 561.4 | 76.49 | 215.46 | 138.97 |
| `e09.sheet.signUp.link` | 1 | Criar conta | 561.4 | 220.46 | 293.51 | 73.05 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O voltar (48, `left 16 · top 58`, `#FFFAF1`, borda 1,5, sombra 2/2, seta 20 traço 2,2) fica por cima de tudo (`z-index 2`). Selo 132 × 132 em `right 30 · top 78`, girado −10°, na cor `{{badge}}`; brilhos creme 30 e preto 18.
2. A folha da entrada: `left/right/bottom 10` (e um `top` por tela), padding 24–26/20/20, raio 32/32/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4, coluna. O título é sempre Bricolage 32/800 `lh 0,98` ls −1 + quebra + Instrument Serif itálico 40–42 ls −0,4, e o texto de baixo 14,5/500 `lh 1,4–1,45` `#5B544B`, 8 abaixo. Aqui: `top 242`, padding 26/20/12.
3. Campos: rótulo 13,5/800 `lh 18`; a caixa de 52, 6 abaixo, raio 16, borda 1,5, padding 0/16 (0/4/0/16 com o olho de 44), texto 16/600; o campo em foco é `#FFFAF1` com o anel `{{brand}}` de 4 (`box-shadow 0 0 0 4`), os outros `#F7F0E3`. "Esqueci a senha" 13,5/800 sublinhado na linha do rótulo da senha, com área de toque de 44 (`margin −13 −8 −13 0`).
4. "Entrar": 54, preto, 18 abaixo; o "ou" Instrument Serif itálico 19 `#5B544B` entre dois traços de 1,5 `#E2D7C4` (gap 12), 14 abaixo; "Receber código por e-mail" 52, `#FFFAF1`, borda 1,5, sem sombra, envelope 20 + 15,5/800, 14 abaixo.
5. O pé "Ainda não tem conta? Criar conta" (44) vai para o fundo da folha (`margin-top: auto`).
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O selo usa `<textPath>` e a cor `{{badge}}` (o mapa de widgets): o mesmo pintor de arco da 35 e da 07.
- O pé fica no fundo da folha: a folha tem `top` e `bottom` fixos e o conteúdo é coluna — no app, `Spacer`/`Expanded` antes do pé; com o teclado aberto, o pé sobe com a rolagem.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_009_entrar_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_009_entrar_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 07 (seções reutilizadas: waves)

Estas seções são as mesmas widgets da 07 (fases L07_1_fundo_e_marca, L07_2_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 07.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e09.back` |  | Voltar para o login |  |
| `e09.badge` |  |  | aria-hidden=true |
| `e09.sparkleLarge` |  |  | aria-hidden=true |
| `e09.sparkleSmall` |  |  | aria-hidden=true |
| `e09.sheet` |  | Entrar com e-mail |  |
| `e09.sheet.form.password.field.caret` |  |  | aria-hidden=true |
| `e09.sheet.form.password.field.reveal` |  | Mostrar senha |  |
| `e09.sheet.form.password.field.reveal.icon` |  |  | aria-hidden=true |
| `e09.sheet.form.submit.icon` |  |  | aria-hidden=true |
| `e09.sheet.divider` |  |  | aria-hidden=true |
| `e09.sheet.code.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e09.back` | CircleIconButton / NeoBox circular |  |
| `e09.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `e09.badge` | AppSvg(AppIllustrationsEntrada.seloDeVoltaALeitura, size: 132×132) | cores dinâmicas: #FED170 = badge · o texto "DE VOLTA À LEITURA · BOOKNEST ·" (Figtree 800 11,5) corre num `<textPath>` em volta do círculo (textLength 252, lengthAdjust spacing): o flutter_svg não faz textPath → no app, o desenho sem o texto e as letras distribuídas no arco por um pintor com o AppFonts; a cor do selo é a prop "badge". |
| `e09.sparkleLarge` | AppSvg(AppIcons.sparkleOutline, size: 30) |  |
| `e09.sparkleSmall` | AppSvg(AppIcons.sparkleSolid, size: 18) |  |
| `e09.sheet` | NeoBox |  |
| `e09.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e09.sheet.form.email.field` | NeoBox |  |
| `e09.sheet.form.password.field` | NeoBox |  |
| `e09.sheet.form.password.field.caret` | NeoBox |  |
| `e09.sheet.form.password.field.input` | NeoBox |  |
| `e09.sheet.form.password.field.reveal.icon` | AppSvg(AppIconsEntrada.eye, size: 22) |  |
| `e09.sheet.form.submit` | NeoBox |  |
| `e09.sheet.form.submit.icon` | AppSvg(AppIconsEntrada.arrowForward, size: 20) |  |
| `e09.sheet.divider.lineLeft` | NeoBox |  |
| `e09.sheet.divider.lineRight` | NeoBox |  |
| `e09.sheet.code` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e09.sheet.code.icon` | AppSvg(AppIconsEntrada.mailTinta, size: 20) |  |

## Interações

- `AutofillGroup` com email / password (o gerenciador de senhas preenche).
- Entrar → entra e vai para a Início; a sessão fica salva (nota do design). Senha errada → a 09b.
- Esqueci a senha e Receber código por e-mail → a mesma tela do código (10).
- Criar conta → o Cadastro (08); voltar → o Login.

## Dados

- E-mail e senha; a autenticação da G05.

## Subfases

- **L09.1** Selo e brilhos
- **L09.2** Folha: e-mail, senha e Esqueci a senha
- **L09.3** Entrar, "ou" e código por e-mail
- **L09.4** Pé "Criar conta"
- **L09.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e09.back', 'e09.badge', 'e09.sparkleLarge', 'e09.sparkleSmall', 'e09.sheet'), todos os ids de `kRef09.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/009_entrar_390x844@3x.png` no recorte da fase (y 50–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef09w360` e `kRef09w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L09.1 Selo e brilhos
- [ ] L09.2 Folha: e-mail, senha e Esqueci a senha
- [ ] L09.3 Entrar, "ou" e código por e-mail
- [ ] L09.4 Pé "Criar conta"
- [ ] L09.5 Verificação + relatório
- [ ] Geometria 33/33 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
