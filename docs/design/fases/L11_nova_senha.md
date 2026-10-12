# FASE L11 — Nova senha — o cadeado aberto e a folha (a senha, a força, as regras e os outros aparelhos)

> Tela 11 · prancha `011_nova_senha` (11 · Nova senha, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L11_nova_senha@3x.png` · `docs/design/medicao/projeto/png/redline/L11_nova_senha_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/011_nova_senha_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_011_nova_senha.json` · `test/reference/projeto/reference_layout_011_nova_senha.dart` (`kRef11`).
> Arquivos sugeridos: `lib/features/account/presentation/entry/new_password_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Nova senha (11): o voltar, o cadeado aberto girado 8°, dois brilhos e a folha — "Crie uma senha nova." para a conta, o campo com o olho, a força "Muito forte", as 3 regras, a chave "Sair dos outros aparelhos" (ligada) e "Salvar e entrar".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{lock}}` = padrão `#FED170`.

```html
<!-- Back to the code screen -->
<a href="#" aria-label="Voltar" style="position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2;">
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg>
</a>

<!-- Open padlock sticker -->
<svg aria-hidden="true" width="140" height="158" viewBox="0 0 160 180" style="position: absolute; left: 184px; top: 72px; transform: rotate(8deg); overflow: visible;">
  <!-- shackle (open: right leg lifted out of the body) -->
  <path d="M50 92V50a30 30 0 0 1 60 0v14" fill="none" stroke="#1A1714" stroke-width="20" stroke-linecap="round"></path>
  <path d="M50 92V50a30 30 0 0 1 60 0v14" fill="none" stroke="#E9DFCC" stroke-width="14" stroke-linecap="round"></path>
  <path d="M45 84V50" fill="none" stroke="#FFFAF1" stroke-width="3" stroke-linecap="round" opacity="0.9"></path>
  <!-- body -->
  <rect x="25" y="86" width="120" height="90" rx="18" fill="#1A1714"></rect>
  <rect x="20" y="82" width="120" height="90" rx="18" fill="{{lock}}" stroke="#1A1714" stroke-width="1.5"></rect>
  <path d="M20 104h120M20 150h120" stroke="#1A1714" stroke-width="1.5" opacity="0.22"></path>
  <circle cx="80" cy="120" r="10" fill="#1A1714"></circle>
  <path d="M76 124h8l2.5 18h-13z" fill="#1A1714"></path>
  <circle cx="34" cy="94" r="2.6" fill="#1A1714"></circle>
  <circle cx="126" cy="94" r="2.6" fill="#1A1714"></circle>
  <circle cx="34" cy="160" r="2.6" fill="#1A1714"></circle>
  <circle cx="126" cy="160" r="2.6" fill="#1A1714"></circle>
</svg>

<svg aria-hidden="true" width="30" height="30" viewBox="0 0 24 24" style="position: absolute; left: 112px; top: 172px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path></svg>

<svg aria-hidden="true" width="18" height="18" viewBox="0 0 24 24" style="position: absolute; left: 346px; top: 180px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>

<!-- New password sheet -->
<main aria-label="Criar senha nova" style="position: absolute; left: 10px; right: 10px; top: 278px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">

  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px;">Crie uma<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px;">senha nova.</span></h1>
  <p style="margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B;">Para a conta <strong style="font-weight: 800; color: #1A1714; white-space: nowrap;">marina.costa@email.com</strong></p>

  <form style="margin: 18px 0 0; display: flex; flex-direction: column;">
    <!-- hidden username keeps password managers linked to the right account -->
    <input type="email" autocomplete="username" value="marina.costa@email.com" aria-hidden="true" tabindex="-1" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">

    <label for="np-pass" style="font-size: 13.5px; font-weight: 800; line-height: 18px;">Nova senha</label>
    <div style="margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}}; box-sizing: border-box; display: flex; align-items: center;">
      <span style="flex-grow: 1; min-width: 0; display: flex; align-items: center; gap: 2px;">
        <span style="font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1;">•••••••••••</span>
        <span aria-hidden="true" style="width: 2px; height: 22px; border-radius: 1px; background: #1A1714;"></span>
      </span>
      <input id="np-pass" type="password" autocomplete="new-password" aria-describedby="np-rules" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">
      <button type="button" aria-label="Mostrar senha" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z"></path><circle cx="12" cy="12" r="3"></circle></svg>
      </button>
    </div>

    <!-- Strength: same wavy bar as Cadastro -->
    <div style="margin-top: 12px; display: flex; align-items: center; gap: 10px;">
      <span role="meter" aria-label="Força da senha" aria-valuemin="0" aria-valuemax="4" aria-valuenow="4" aria-valuetext="Muito forte" style="position: relative; flex-grow: 1; height: 14px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden;">
        <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 88%; background: #ABCF82;">
          <svg width="10" height="15" viewBox="0 0 10 15" preserveAspectRatio="none" style="position: absolute; top: 0; right: -5px; height: 100%;"><path d="M0 0H5Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15H0Z" fill="#ABCF82"></path><path d="M5 0Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15" fill="none" stroke="#1A1714" stroke-width="1.5" vector-effect="non-scaling-stroke"></path></svg>
        </span>
      </span>
      <span style="font-size: 13px; font-weight: 800; text-align: right; white-space: nowrap;">Muito forte</span>
    </div>
    <ul id="np-rules" style="margin: 10px 0 0; padding: 0; list-style: none; display: flex; flex-wrap: wrap; gap: 6px 14px;">
      <li style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap;">
        <span aria-hidden="true" style="width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        8 ou mais caracteres
      </li>
      <li style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap;">
        <span aria-hidden="true" style="width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        Um número ou símbolo
      </li>
      <li style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap;">
        <span aria-hidden="true" style="width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        Diferente da senha antiga
      </li>
    </ul>

    <!-- Other devices: user's choice, starts ON -->
    <div style="margin-top: 14px; padding: 12px 12px 12px 16px; border-radius: 18px; background: #F7F0E3; border: 1.5px solid #1A1714; display: flex; align-items: center; gap: 12px;">
      <span style="flex-grow: 1; min-width: 0;">
        <span id="np-dev" style="display: block; font-size: 14.5px; font-weight: 800; line-height: 1.25;">Sair dos outros aparelhos</span>
        <span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 500; line-height: 1.35; color: #5B544B;">Fecha a conta no celular e no computador onde ela estiver aberta.</span>
      </span>
      <button type="button" role="switch" aria-checked="true" aria-labelledby="np-dev" style="position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
        <span style="position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
      </button>
    </div>

    <button type="submit" style="margin-top: 16px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
      <span style="color: #F7F0E3;">Salvar e entrar</span>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </button>
  </form>

  <p style="margin: 12px 0 0; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 12.5px; font-weight: 600; color: #6F665B;">
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3 4.5 6v5.5c0 4.6 3.2 8.4 7.5 9.5 4.3-1.1 7.5-4.9 7.5-9.5V6z"></path></svg>
    Você vai receber um aviso por e-mail.
  </p>
</main>
```

## Especificação pixel a pixel

Seção `e11.back` — retângulo absoluto no canvas 390×844: **x=16, y=58, w=48, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e11.back` | box | 0 | 0 | 48 | 48 | `position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2` |  |
| 2 | `e11.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |

Seção `e11.padlock` — retângulo absoluto no canvas 390×844: **x=184, y=72, w=140, h=158**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `e11.padlock` | icon | 0 | 0 | 140 | 158 | `position: absolute; left: 184px; top: 72px; transform: rotate(8deg); overflow: visible` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `e11.padlock`: caixa visual com `transform: rotate(8deg)` = x -10.31, y -8.97, w 160.63, h 175.95 (relativa à seção).

Seção `e11.sparkleLarge` — retângulo absoluto no canvas 390×844: **x=112, y=172, w=30, h=30**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `e11.sparkleLarge` | icon | 0 | 0 | 30 | 30 | `position: absolute; left: 112px; top: 172px` |  |

Seção `e11.sparkleSmall` — retângulo absoluto no canvas 390×844: **x=346, y=180, w=18, h=18**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `e11.sparkleSmall` | icon | 0 | 0 | 18 | 18 | `position: absolute; left: 346px; top: 180px` |  |

Seção `e11.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=278, w=370, h=556**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `e11.sheet` | box | 0 | 0 | 370 | 556 | `position: absolute; left: 10px; right: 10px; top: 278px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 7 | `e11.sheet.title` | text | 21.5 | 27.5 | 327 | 72.52 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 32) 32/31.36px peso 800 ls -1px #1A1714 |
| 8 | `e11.sheet.title.serif` ±1 | inline | 21.5 | 52.14 | 177.5 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |
| 9 | `e11.sheet.lead` | text | 21.5 | 108.02 | 327 | 21.02 | `margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B` | Figtree 14.5/21.025px peso 500 ls normal #5B544B |
| 10 | `e11.sheet.lead.email` ±1 | inline | 105.36 | 109.82 | 171.27 | 17.41 | `font-weight: 800; color: #1A1714; white-space: nowrap` | Figtree 14.5/21.025px peso 800 ls normal #1A1714 |
| 11 | `e11.sheet.form` | box | 21.5 | 147.05 | 327 | 316.48 | `margin: 18px 0 0; display: flex; flex-direction: column` |  |
| 12 | `e11.sheet.form.username` | box | 21.5 | 147.05 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 13 | `e11.sheet.form.password.label` | text | 21.5 | 147.05 | 327 | 18 | `font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 14 | `e11.sheet.form.password.field` | box | 21.5 | 171.05 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}} (padrão #B6ACE4); box-sizing: border-box; display: flex; align-items: center` |  |
| 15 | `e11.sheet.form.password.field.value` | box | 39 | 186.05 | 260 | 22 | `flex-grow: 1; min-width: 0; display: flex; align-items: center; gap: 2px` |  |
| 16 | `e11.sheet.form.password.field.dots` ±1 | text | 39 | 188.05 | 118.38 | 18 | `font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1` | Figtree 18/18px peso 800 ls 2.5px #1A1714 |
| 17 | `e11.sheet.form.password.field.caret` ±1 | box | 159.38 | 186.05 | 2 | 22 | `width: 2px; height: 22px; border-radius: 1px; background: #1A1714` |  |
| 18 | `e11.sheet.form.password.field.input` | box | 39 | 193.55 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 19 | `e11.sheet.form.password.field.reveal` | box | 299 | 175.05 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 20 | `e11.sheet.form.password.field.reveal.icon` | icon | 310 | 186.05 | 22 | 22 | `—` |  |
| 21 | `e11.sheet.form.strength` | box | 21.5 | 235.04 | 327 | 15.6 | `margin-top: 12px; display: flex; align-items: center; gap: 10px` |  |
| 22 | `e11.sheet.form.strength.bar` ±1 | box | 21.5 | 235.85 | 248.62 | 14 | `position: relative; flex-grow: 1; height: 14px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden` |  |
| 23 | `e11.sheet.form.strength.bar.fill` ±1 | box | 23 | 237.35 | 216.15 | 11 | `position: absolute; left: 0; top: 0; bottom: 0; width: 88%; background: #ABCF82` |  |
| 24 | `e11.sheet.form.strength.bar.fill.edge` ±1 | icon | 234.15 | 237.35 | 10 | 11 | `position: absolute; top: 0; right: -5px; height: 100%` |  |
| 25 | `e11.sheet.form.strength.label` ±1 | text | 280.12 | 235.04 | 68.38 | 15.6 | `font-size: 13px; font-weight: 800; text-align: right; white-space: nowrap` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 26 | `e11.sheet.form.rules` | box | 21.5 | 260.64 | 327 | 38 | `margin: 10px 0 0; padding: 0; list-style: none; display: flex; flex-wrap: wrap; gap: 6px 14px` |  |
| 27 | `e11.sheet.form.rules.rule1` ±1 | text | 21.5 | 260.64 | 139.52 | 16 | `display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap` | Figtree 12.5/normal peso 600 ls normal #3E3832 |
| 28 | `e11.sheet.form.rules.rule1.check` | box | 21.5 | 260.64 | 16 | 16 | `width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 29 | `e11.sheet.form.rules.rule1.check.icon` | icon | 25 | 264.14 | 9 | 9 | `—` |  |
| 30 | `e11.sheet.form.rules.rule2` ±1 | text | 175.02 | 260.64 | 153.18 | 16 | `display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap` | Figtree 12.5/normal peso 600 ls normal #3E3832 |
| 31 | `e11.sheet.form.rules.rule2.check` ±1 | box | 175.02 | 260.64 | 16 | 16 | `width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 32 | `e11.sheet.form.rules.rule2.check.icon` ±1 | icon | 178.52 | 264.14 | 9 | 9 | `—` |  |
| 33 | `e11.sheet.form.rules.rule3` ±1 | text | 21.5 | 282.64 | 167.57 | 16 | `display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap` | Figtree 12.5/normal peso 600 ls normal #3E3832 |
| 34 | `e11.sheet.form.rules.rule3.check` | box | 21.5 | 282.64 | 16 | 16 | `width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 35 | `e11.sheet.form.rules.rule3.check.icon` | icon | 25 | 286.14 | 9 | 9 | `—` |  |
| 36 | `e11.sheet.form.devices` | box | 21.5 | 312.64 | 327 | 80.88 | `margin-top: 14px; padding: 12px 12px 12px 16px; border-radius: 18px; background: #F7F0E3; border: 1.5px solid #1A1714; display: flex; align-items: center; gap: 12px` |  |
| 37 | `e11.sheet.form.devices.textBlock` | box | 39 | 326.14 | 230 | 53.88 | `flex-grow: 1; min-width: 0` |  |
| 38 | `e11.sheet.form.devices.title` | text | 39 | 326.14 | 230 | 18.12 | `display: block; font-size: 14.5px; font-weight: 800; line-height: 1.25` | Figtree 14.5/18.125px peso 800 ls normal #1A1714 |
| 39 | `e11.sheet.form.devices.body` | text | 39 | 346.27 | 230 | 33.75 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 500; line-height: 1.35; color: #5B544B` | Figtree 12.5/16.875px peso 500 ls normal #5B544B |
| 40 | `e11.sheet.form.devices.switch` | box | 281 | 337.08 | 54 | 32 | `position: relative; width: 54px; height: 32px; flex-shrink: 0; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 41 | `e11.sheet.form.devices.switch.thumb` | box | 307 | 341.08 | 24 | 24 | `position: absolute; top: 2.5px; right: 2.5px; width: 24px; height: 24px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 42 | `e11.sheet.form.devices.switch.thumb.icon` | icon | 313.5 | 347.58 | 11 | 11 | `—` |  |
| 43 | `e11.sheet.form.submit` | box | 21.5 | 409.52 | 327 | 54 | `margin-top: 16px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 44 | `e11.sheet.form.submit.label` ±1 | text | 115.56 | 426.92 | 108.88 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 45 | `e11.sheet.form.submit.icon` ±1 | icon | 234.44 | 426.52 | 20 | 20 | `—` |  |
| 46 | `e11.sheet.notice` | text | 21.5 | 475.52 | 327 | 15.01 | `margin: 12px 0 0; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 12.5px; font-weight: 600; color: #6F665B` | Figtree 12.5/normal peso 600 ls normal #6F665B |
| 47 | `e11.sheet.notice.icon` ±1 | icon | 67.75 | 475.52 | 15 | 15 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e11.sheet.title` *(composto)* | 1 | Crie uma | 53.74 | 21.5 | 151.6 | 130.1 |
| `e11.sheet.title` *(composto)* | 2 | senha nova. | 93.72 | 21.5 | 199 | 177.5 |
| `e11.sheet.lead` *(composto)* | 1 | Para a conta marina.costa@email.com | 123.6 | 21.5 | 276.64 | 255.14 |
| `e11.sheet.form.password.label` | 1 | Nova senha | 160.76 | 21.5 | 94.2 | 72.7 |
| `e11.sheet.form.password.field.dots` | 1 | ••••••••••• | 203.35 | 39 | 157.38 | 118.38 |
| `e11.sheet.form.strength.label` | 1 | Muito forte | 247.39 | 280.12 | 348.5 | 68.38 |
| `e11.sheet.form.rules.rule1` | 1 | 8 ou mais caracteres | 273.02 | 43.5 | 161.02 | 117.52 |
| `e11.sheet.form.rules.rule2` | 1 | Um número ou símbolo | 273.02 | 197.02 | 328.19 | 131.17 |
| `e11.sheet.form.rules.rule3` | 1 | Diferente da senha antiga | 295.02 | 43.5 | 189.07 | 145.57 |
| `e11.sheet.form.devices.title` | 1 | Sair dos outros aparelhos | 340.27 | 39 | 209.3 | 170.3 |
| `e11.sheet.form.devices.body` | 1 | Fecha a conta no celular e no | 359.08 | 39 | 202.32 | 163.32 |
| `e11.sheet.form.devices.body` | 2 | computador onde ela estiver aberta. | 375.96 | 39 | 242.24 | 203.24 |
| `e11.sheet.form.submit.label` | 1 | Salvar e entrar | 442.12 | 115.56 | 224.44 | 108.88 |
| `e11.sheet.notice` | 1 | Você vai receber um aviso por e-mail. | 487.4 | 89.75 | 302.25 | 212.5 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O voltar (48, `left 16 · top 58`, `#FFFAF1`, borda 1,5, sombra 2/2, seta 20 traço 2,2) fica por cima de tudo (`z-index 2`). Cadeado 140 × 158 em `left 184 · top 72`, girado 8°, na cor `{{lock}}`.
2. A folha da entrada: `left/right/bottom 10` (e um `top` por tela), padding 24–26/20/20, raio 32/32/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4, coluna. O título é sempre Bricolage 32/800 `lh 0,98` ls −1 + quebra + Instrument Serif itálico 40–42 ls −0,4, e o texto de baixo 14,5/500 `lh 1,4–1,45` `#5B544B`, 8 abaixo. Aqui: `top 278`, padding 26/20/20; o e-mail da conta em 800 `nowrap`.
3. Campos: rótulo 13,5/800 `lh 18`; a caixa de 52, 6 abaixo, raio 16, borda 1,5, padding 0/16 (0/4/0/16 com o olho de 44), texto 16/600; o campo em foco é `#FFFAF1` com o anel `{{brand}}` de 4 (`box-shadow 0 0 0 4`), os outros `#F7F0E3`. Força: a barra com o verde até 88 % e "Muito forte"; as regras 8 ou mais caracteres, Um número ou símbolo e Diferente da senha antiga.
4. Outros aparelhos, 14 abaixo: padding 12/12/12/16, raio 18, `#F7F0E3`, borda 1,5; "Sair dos outros aparelhos" 14,5/800 e o texto 12,5/500; a chave 54 × 32 `{{brand}}` com a bolinha 24 e o visto (o desenho dos Lembretes, T17).
5. "Salvar e entrar" 54, 16 abaixo; o aviso com o escudo 15 + "Você vai receber um aviso por e-mail." 12,5/600, 12 abaixo.
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A chave é a de 54 × 32 com o visto (o desenho dos Ajustes e dos Lembretes), não a de 52 × 32 da Conta: ver a armadilha das chaves da T17.
- A 360 o brilho pequeno sai 4 do quadro (abaixo).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_011_nova_senha_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_011_nova_senha_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `e11.sparkleSmall` | sai do quadro (x) | 4 | 0 | **sim** | sim |  |

## Diferenças em relação à prancha 07 (seções reutilizadas: waves)

Estas seções são as mesmas widgets da 07 (fases L07_1_fundo_e_marca, L07_2_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 07.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e11.back` |  | Voltar |  |
| `e11.padlock` |  |  | aria-hidden=true |
| `e11.sparkleLarge` |  |  | aria-hidden=true |
| `e11.sparkleSmall` |  |  | aria-hidden=true |
| `e11.sheet` |  | Criar senha nova |  |
| `e11.sheet.form.username` |  |  | aria-hidden=true |
| `e11.sheet.form.password.field.caret` |  |  | aria-hidden=true |
| `e11.sheet.form.password.field.input` |  |  | aria-describedby=np-rules |
| `e11.sheet.form.password.field.reveal` |  | Mostrar senha |  |
| `e11.sheet.form.password.field.reveal.icon` |  |  | aria-hidden=true |
| `e11.sheet.form.strength.bar` | meter | Força da senha | aria-valuemin=0, aria-valuemax=4, aria-valuenow=4, aria-valuetext=Muito forte |
| `e11.sheet.form.rules.rule1.check` |  |  | aria-hidden=true |
| `e11.sheet.form.rules.rule2.check` |  |  | aria-hidden=true |
| `e11.sheet.form.rules.rule3.check` |  |  | aria-hidden=true |
| `e11.sheet.form.devices.switch` | switch |  | aria-checked=true, aria-labelledby=np-dev |
| `e11.sheet.form.devices.switch.thumb.icon` |  |  | aria-hidden=true |
| `e11.sheet.form.submit.icon` |  |  | aria-hidden=true |
| `e11.sheet.notice.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e11.back` | CircleIconButton / NeoBox circular |  |
| `e11.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `e11.padlock` | AppSvg(AppIllustrationsEntrada.cadeadoAberto, size: 140×158) | cores dinâmicas: #FED170 = lock |
| `e11.sparkleLarge` | AppSvg(AppIcons.sparkleOutline, size: 30) |  |
| `e11.sparkleSmall` | AppSvg(AppIcons.sparkleSolid, size: 18) |  |
| `e11.sheet` | NeoBox |  |
| `e11.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e11.sheet.lead.email` | TextSpan dentro do AppText.rich do pai |  |
| `e11.sheet.form.username` | NeoBox |  |
| `e11.sheet.form.password.field` | NeoBox |  |
| `e11.sheet.form.password.field.caret` | NeoBox |  |
| `e11.sheet.form.password.field.input` | NeoBox |  |
| `e11.sheet.form.password.field.reveal.icon` | AppSvg(AppIconsEntrada.eye, size: 22) |  |
| `e11.sheet.form.strength.bar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `e11.sheet.form.strength.bar.fill` | NeoBox |  |
| `e11.sheet.form.strength.bar.fill.edge` | CustomPainter (borda_onda_preenchimento_verde) | preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): a borda ondulada da ponta da barra preenchida, esticada na altura da barra com traço fixo de 1,5 — CustomPainter, como a onda da barra do leitor. |
| `e11.sheet.form.rules.rule1.check` | CircleIconButton / NeoBox circular |  |
| `e11.sheet.form.rules.rule1.check.icon` | AppSvg(AppIconsEntrada.checkMini, size: 9) |  |
| `e11.sheet.form.rules.rule2.check` | CircleIconButton / NeoBox circular |  |
| `e11.sheet.form.rules.rule2.check.icon` | AppSvg(AppIconsEntrada.checkMini, size: 9) |  |
| `e11.sheet.form.rules.rule3.check` | CircleIconButton / NeoBox circular |  |
| `e11.sheet.form.rules.rule3.check.icon` | AppSvg(AppIconsEntrada.checkMini, size: 9) |  |
| `e11.sheet.form.devices` | NeoBox |  |
| `e11.sheet.form.devices.switch` | NeoBox |  |
| `e11.sheet.form.devices.switch.thumb` | CircleIconButton / NeoBox circular |  |
| `e11.sheet.form.devices.switch.thumb.icon` | AppSvg(AppIconsInicio.checkTiny, size: 11) |  |
| `e11.sheet.form.submit` | NeoBox |  |
| `e11.sheet.form.submit.icon` | AppSvg(AppIconsEntrada.arrowForward, size: 20) |  |
| `e11.sheet.notice.icon` | AppSvg(AppIconsEntrada.shield, size: 15) |  |

## Interações

- `AutofillHints.newPassword` e o e-mail num campo oculto (`username`), para o gerenciador salvar na conta certa (nota do design).
- "Diferente da senha antiga" é conferida pelo servidor (nota do design): quando a regra ganha o visto (ao digitar ou ao salvar) é pergunta da T16.
- Sair dos outros aparelhos: começa ligado; a pessoa pode desligar.
- Salvar e entrar → entra direto na Início com o aviso rápido "Senha nova salva"; o app manda o e-mail.

## Dados

- O e-mail da conta, a senha nova, a força calculada no app.

## Subfases

- **L11.1** Cadeado e brilhos
- **L11.2** Senha, força e regras
- **L11.3** Outros aparelhos (a chave)
- **L11.4** Salvar e entrar
- **L11.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e11.back', 'e11.padlock', 'e11.sparkleLarge', 'e11.sparkleSmall', 'e11.sheet'), todos os ids de `kRef11.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/011_nova_senha_390x844@3x.png` no recorte da fase (y 50–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef11w360` e `kRef11w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L11.1 Cadeado e brilhos
- [ ] L11.2 Senha, força e regras
- [ ] L11.3 Outros aparelhos (a chave)
- [ ] L11.4 Salvar e entrar
- [ ] L11.5 Verificação + relatório
- [ ] Geometria 45/45 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
