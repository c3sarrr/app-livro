# FASE L08 — Cadastro — a carteirinha que se preenche e o formulário (nome, e-mail, senha com a força)

> Tela 08 · prancha `008_cadastro` (08 · Cadastro por e-mail, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L08_cadastro@3x.png` · `docs/design/medicao/projeto/png/redline/L08_cadastro_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/008_cadastro_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_008_cadastro.json` · `test/reference/projeto/reference_layout_008_cadastro.dart` (`kRef08`).
> Arquivos sugeridos: `lib/features/account/presentation/entry/sign_up_screen.dart`, `lib/features/account/presentation/entry/library_card_preview.dart`, `lib/features/account/presentation/entry/password_strength.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Cadastro por e-mail (08): o voltar, a carteirinha que se preenche com o nome enquanto a pessoa digita (girada 5°) e a folha — "Crie sua conta.", Nome, E-mail (com o visto de válido), Senha em foco com o olho, a barra de força, as regras, as novidades por e-mail e "Criar conta".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{card}}` = padrão `#FF552E`.

```html
<!-- Back to Login -->
<a href="#" aria-label="Voltar para o login" style="position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2;">
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg>
</a>

<svg aria-hidden="true" width="26" height="26" viewBox="0 0 24 24" style="position: absolute; left: 96px; top: 104px; z-index: 2;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>

<!-- Live library card: fills in with the name as you type -->
<div aria-label="Prévia da sua carteirinha" style="position: absolute; right: 20px; top: 60px; width: 172px; height: 108px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(5deg); z-index: 3;">
  <div style="height: 26px; padding: 0 10px; background: {{card}}; border-bottom: 1.5px solid #1A1714; display: flex; align-items: center; justify-content: space-between;">
    <span style="font-size: 9px; font-weight: 800; letter-spacing: 1.1px; white-space: nowrap;">CARTEIRINHA DE LEITORA</span>
    <svg width="12" height="12" viewBox="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>
  </div>
  <div style="position: relative; height: 80px; padding: 9px 10px 0; box-sizing: border-box; background: repeating-linear-gradient(180deg, transparent 0 17px, #EAE1D0 17px 18px);">
    <div style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 23px; line-height: 1; letter-spacing: -0.3px; white-space: nowrap;">Marina Costa</div>
    <div style="margin-top: 7px; font-size: 9px; font-weight: 800; letter-spacing: 0.8px; color: #5B544B; white-space: nowrap;">Nº 0052 · DESDE 2026</div>
    <!-- rubber stamp -->
    <span aria-hidden="true" style="position: absolute; right: 7px; bottom: -9px; width: 36px; height: 36px; border-radius: 50%; border: 1.5px solid #552CB7; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-14deg); opacity: 0.9;">
      <svg width="16" height="16" viewBox="0 0 24 24"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#552CB7"></path></svg>
    </span>
  </div>
</div>

<!-- Sign-up sheet -->
<main aria-label="Criar conta com e-mail" style="position: absolute; left: 10px; right: 10px; top: 150px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">

  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px;">Crie sua<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px;">conta.</span></h1>
  <p style="margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.4; color: #5B544B;">Um minuto e sua estante fica pronta.</p>

  <form style="margin: 18px 0 0; display: flex; flex-direction: column;">

    <!-- Name -->
    <label for="su-name" style="font-size: 13.5px; font-weight: 800; line-height: 18px;">Nome</label>
    <div style="margin-top: 6px; height: 52px; padding: 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center;">
      <input id="su-name" type="text" autocomplete="name" value="Marina Costa" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714;">
    </div>
    <p style="margin: 6px 0 0 2px; font-size: 12.5px; font-weight: 500; line-height: 16px; color: #6F665B;">Aparece na sua carteirinha e nos clubes.</p>

    <!-- Email (validated) -->
    <label for="su-email" style="margin-top: 14px; font-size: 13.5px; font-weight: 800; line-height: 18px;">E-mail</label>
    <div style="margin-top: 6px; height: 52px; padding: 0 12px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px;">
      <input id="su-email" type="email" autocomplete="email" inputmode="email" value="marina.costa@email.com" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714;">
      <span role="img" aria-label="E-mail válido" style="width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
      </span>
    </div>

    <!-- Password (focused) -->
    <label for="su-pass" style="margin-top: 14px; font-size: 13.5px; font-weight: 800; line-height: 18px;">Senha</label>
    <div style="margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}}; box-sizing: border-box; display: flex; align-items: center;">
      <span style="flex-grow: 1; min-width: 0; display: flex; align-items: center; gap: 2px;">
        <span style="font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1;">••••••••••</span>
        <span aria-hidden="true" style="width: 2px; height: 22px; border-radius: 1px; background: #1A1714;"></span>
      </span>
      <input id="su-pass" type="password" autocomplete="new-password" aria-describedby="su-pass-rules" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">
      <button type="button" aria-label="Mostrar senha" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z"></path><circle cx="12" cy="12" r="3"></circle></svg>
      </button>
    </div>

    <!-- Strength: same wavy bar as the club poll -->
    <div style="margin-top: 12px; display: flex; align-items: center; gap: 10px;">
      <span role="meter" aria-label="Força da senha" aria-valuemin="0" aria-valuemax="4" aria-valuenow="3" aria-valuetext="Forte" style="position: relative; flex-grow: 1; height: 14px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden;">
        <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 76%; background: #ABCF82;">
          <svg width="10" height="15" viewBox="0 0 10 15" preserveAspectRatio="none" style="position: absolute; top: 0; right: -5px; height: 100%;"><path d="M0 0H5Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15H0Z" fill="#ABCF82"></path><path d="M5 0Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15" fill="none" stroke="#1A1714" stroke-width="1.5" vector-effect="non-scaling-stroke"></path></svg>
        </span>
      </span>
      <span style="min-width: 44px; font-size: 13px; font-weight: 800; text-align: right; white-space: nowrap;">Forte</span>
    </div>
    <ul id="su-pass-rules" style="margin: 10px 0 0; padding: 0; list-style: none; display: flex; flex-wrap: wrap; gap: 6px 14px;">
      <li style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap;">
        <span aria-hidden="true" style="width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        8 ou mais caracteres
      </li>
      <li style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap;">
        <span aria-hidden="true" style="width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="9" height="9" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="4" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span>
        Um número ou símbolo
      </li>
    </ul>

    <!-- Newsletter opt-in: unchecked by default -->
    <label style="margin-top: 10px; min-height: 44px; display: flex; align-items: center; gap: 10px; font-size: 13.5px; font-weight: 600; line-height: 1.35; color: #3E3832;">
      <input type="checkbox" style="position: absolute; width: 1px; height: 1px; opacity: 0;">
      <span aria-hidden="true" style="width: 22px; height: 22px; flex-shrink: 0; border-radius: 7px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box;"></span>
      Quero dicas de leitura por e-mail
    </label>

    <button type="submit" style="margin-top: 8px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
      <span style="color: #F7F0E3;">Criar conta</span>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </button>
  </form>

  <p style="margin: 12px 0 0; font-size: 12px; font-weight: 500; line-height: 1.45; color: #6F665B; text-align: center; text-wrap: pretty;">Ao criar a conta, você concorda com os <a href="#" style="white-space: nowrap; font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px;">Termos de Uso</a> e a <a href="#" style="white-space: nowrap; font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px;">Política de Privacidade</a>.</p>
</main>
```

## Especificação pixel a pixel

Seção `e08.back` — retângulo absoluto no canvas 390×844: **x=16, y=58, w=48, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e08.back` | box | 0 | 0 | 48 | 48 | `position: absolute; left: 16px; top: 58px; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; z-index: 2` |  |
| 2 | `e08.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |

Seção `e08.sparkleLarge` — retângulo absoluto no canvas 390×844: **x=96, y=104, w=26, h=26**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `e08.sparkleLarge` | icon | 0 | 0 | 26 | 26 | `position: absolute; left: 96px; top: 104px; z-index: 2` |  |

Seção `e08.card` — retângulo absoluto no canvas 390×844: **x=198, y=60, w=172, h=108**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 4 | `e08.card` | box | 0 | 0 | 172 | 108 | `position: absolute; right: 20px; top: 60px; width: 172px; height: 108px; border-radius: 12px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box; overflow: hidden; transform: rotate(5deg); z-index: 3` |  |
| 5 | `e08.card.header` | box | 1.5 | 1.5 | 169 | 27.5 | `height: 26px; padding: 0 10px; background: {{card}} (padrão #FF552E); border-bottom: 1.5px solid #1A1714; display: flex; align-items: center; justify-content: space-between` |  |
| 6 | `e08.card.header.label` ±1 | text | 11.5 | 9.1 | 139.03 | 10.8 | `font-size: 9px; font-weight: 800; letter-spacing: 1.1px; white-space: nowrap` | Figtree 9/normal peso 800 ls 1.1px #1A1714 |
| 7 | `e08.card.header.icon` ±1 | icon | 150.53 | 8.5 | 9.97 | 12 | `—` |  |
| 8 | `e08.card.body` | box | 1.5 | 29 | 169 | 80 | `position: relative; height: 80px; padding: 9px 10px 0; box-sizing: border-box; background: repeating-linear-gradient(180deg, transparent 0 17px, #EAE1D0 17px 18px)` |  |
| 9 | `e08.card.name` | text | 11.5 | 38 | 149 | 23 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 23px; line-height: 1; letter-spacing: -0.3px; white-space: nowrap` | Instrument Serif itálico 23/23px peso 400 ls -0.3px #1A1714 |
| 10 | `e08.card.number` | text | 11.5 | 68 | 149 | 10.8 | `margin-top: 7px; font-size: 9px; font-weight: 800; letter-spacing: 0.8px; color: #5B544B; white-space: nowrap` | Figtree 9/normal peso 800 ls 0.8px #5B544B |
| 11 | `e08.card.stamp` | box | 127.5 | 82 | 36 | 36 | `position: absolute; right: 7px; bottom: -9px; width: 36px; height: 36px; border-radius: 50%; border: 1.5px solid #552CB7; box-sizing: border-box; display: flex; align-items: center; justify-content: center; transform: rotate(-14deg); opacity: 0.9` |  |
| 12 | `e08.card.stamp.icon` | icon | 137.5 | 92 | 16 | 16 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `e08.card`: caixa visual com `transform: rotate(5deg)` = x -4.38, y -7.29, w 180.76, h 122.58 (relativa à seção).
- `e08.card.header`: caixa visual deslocada pelo transform de um ancestral = x 4, y -5.66, w 170.75, h 42.12 (relativa à seção).
- `e08.card.header.label`: caixa visual deslocada pelo transform de um ancestral = x 14.76, y 2.78, w 139.44, h 22.88 (relativa à seção).
- `e08.card.header.icon`: caixa visual deslocada pelo transform de um ancestral = x 153.2, y 14.3, w 10.98, h 12.82 (relativa à seção).
- `e08.card.body`: caixa visual deslocada pelo transform de um ancestral = x -2.97, y 21.73, w 175.33, h 94.42 (relativa à seção).
- `e08.card.name`: caixa visual deslocada pelo transform de um ancestral = x 11.17, y 31.57, w 150.44, h 35.9 (relativa à seção).
- `e08.card.number`: caixa visual deslocada pelo transform de um ancestral = x 9.62, y 61.45, w 149.37, h 23.75 (relativa à seção).
- `e08.card.stamp`: caixa visual com `transform: rotate(-14deg)` = x 120.67, y 84.42, w 41.19, h 41.19 (relativa à seção).
- `e08.card.stamp.icon`: caixa visual deslocada pelo transform de um ancestral = x 132.11, y 95.86, w 18.31, h 18.31 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e08.card.header.label` | 1 | CARTEIRINHA DE LEITORA | 17.65 | 11.5 | 150.53 | 139.03 |
| `e08.card.name` | 1 | Marina Costa | 57.32 | 11.5 | 120.53 | 109.03 |
| `e08.card.number` | 1 | Nº 0052 · DESDE 2026 | 76.55 | 11.5 | 121.18 | 109.68 |

Seção `e08.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=150, w=370, h=684**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 13 | `e08.sheet` | box | 0 | 0 | 370 | 684 | `position: absolute; left: 10px; right: 10px; top: 150px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 14 | `e08.sheet.title` | text | 21.5 | 27.5 | 327 | 72.52 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 32) 32/31.36px peso 800 ls -1px #1A1714 |
| 15 | `e08.sheet.title.serif` ±1 | inline | 21.5 | 52.14 | 92.14 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |
| 16 | `e08.sheet.lead` | text | 21.5 | 108.02 | 327 | 20.3 | `margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.4; color: #5B544B` | Figtree 14.5/20.3px peso 500 ls normal #5B544B |
| 17 | `e08.sheet.form` | box | 21.5 | 146.32 | 327 | 447.6 | `margin: 18px 0 0; display: flex; flex-direction: column` |  |
| 18 | `e08.sheet.form.name.label` | text | 21.5 | 146.32 | 327 | 18 | `font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 19 | `e08.sheet.form.name.field` | box | 21.5 | 170.32 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center` |  |
| 20 | `e08.sheet.form.name.field.input` | box | 39 | 171.82 | 292 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 21 | `e08.sheet.form.name.hint` | text | 23.5 | 228.32 | 325 | 16 | `margin: 6px 0 0 2px; font-size: 12.5px; font-weight: 500; line-height: 16px; color: #6F665B` | Figtree 12.5/16px peso 500 ls normal #6F665B |
| 22 | `e08.sheet.form.email.label` | text | 21.5 | 258.32 | 327 | 18 | `margin-top: 14px; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 23 | `e08.sheet.form.email.field` | box | 21.5 | 282.32 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 12px 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px` |  |
| 24 | `e08.sheet.form.email.field.input` | box | 39 | 283.82 | 262 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 25 | `e08.sheet.form.email.field.valid` | box | 311 | 296.32 | 24 | 24 | `width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 26 | `e08.sheet.form.email.field.valid.icon` | icon | 316.5 | 301.82 | 13 | 13 | `—` |  |
| 27 | `e08.sheet.form.password.label` | text | 21.5 | 348.32 | 327 | 18 | `margin-top: 14px; font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 28 | `e08.sheet.form.password.field` | box | 21.5 | 372.32 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 0 0 4px {{brand}} (padrão #B6ACE4); box-sizing: border-box; display: flex; align-items: center` |  |
| 29 | `e08.sheet.form.password.field.value` | box | 39 | 387.32 | 260 | 22 | `flex-grow: 1; min-width: 0; display: flex; align-items: center; gap: 2px` |  |
| 30 | `e08.sheet.form.password.field.dots` ±1 | text | 39 | 389.32 | 107.62 | 18 | `font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1` | Figtree 18/18px peso 800 ls 2.5px #1A1714 |
| 31 | `e08.sheet.form.password.field.caret` ±1 | box | 148.62 | 387.32 | 2 | 22 | `width: 2px; height: 22px; border-radius: 1px; background: #1A1714` |  |
| 32 | `e08.sheet.form.password.field.input` | box | 39 | 394.82 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 33 | `e08.sheet.form.password.field.reveal` | box | 299 | 376.32 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 34 | `e08.sheet.form.password.field.reveal.icon` | icon | 310 | 387.32 | 22 | 22 | `—` |  |
| 35 | `e08.sheet.form.strength` | box | 21.5 | 436.32 | 327 | 15.6 | `margin-top: 12px; display: flex; align-items: center; gap: 10px` |  |
| 36 | `e08.sheet.form.strength.bar` | box | 21.5 | 437.12 | 273 | 14 | `position: relative; flex-grow: 1; height: 14px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden` |  |
| 37 | `e08.sheet.form.strength.bar.fill` | box | 23 | 438.62 | 205.2 | 11 | `position: absolute; left: 0; top: 0; bottom: 0; width: 76%; background: #ABCF82` |  |
| 38 | `e08.sheet.form.strength.bar.fill.edge` | icon | 223.2 | 438.62 | 10 | 11 | `position: absolute; top: 0; right: -5px; height: 100%` |  |
| 39 | `e08.sheet.form.strength.label` | text | 304.5 | 436.32 | 44 | 15.6 | `min-width: 44px; font-size: 13px; font-weight: 800; text-align: right; white-space: nowrap` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 40 | `e08.sheet.form.rules` | box | 21.5 | 461.92 | 327 | 16 | `margin: 10px 0 0; padding: 0; list-style: none; display: flex; flex-wrap: wrap; gap: 6px 14px` |  |
| 41 | `e08.sheet.form.rules.rule1` ±1 | text | 21.5 | 461.92 | 139.52 | 16 | `display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap` | Figtree 12.5/normal peso 600 ls normal #3E3832 |
| 42 | `e08.sheet.form.rules.rule1.check` | box | 21.5 | 461.92 | 16 | 16 | `width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 43 | `e08.sheet.form.rules.rule1.check.icon` | icon | 25 | 465.42 | 9 | 9 | `—` |  |
| 44 | `e08.sheet.form.rules.rule2` ±1 | text | 175.02 | 461.92 | 153.18 | 16 | `display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 600; color: #3E3832; white-space: nowrap` | Figtree 12.5/normal peso 600 ls normal #3E3832 |
| 45 | `e08.sheet.form.rules.rule2.check` ±1 | box | 175.02 | 461.92 | 16 | 16 | `width: 16px; height: 16px; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 46 | `e08.sheet.form.rules.rule2.check.icon` ±1 | icon | 178.52 | 465.42 | 9 | 9 | `—` |  |
| 47 | `e08.sheet.form.newsletter` | text | 21.5 | 487.92 | 327 | 44 | `margin-top: 10px; min-height: 44px; display: flex; align-items: center; gap: 10px; font-size: 13.5px; font-weight: 600; line-height: 1.35; color: #3E3832` | Figtree 13.5/18.225px peso 600 ls normal #3E3832 |
| 48 | `e08.sheet.form.newsletter.input` | box | 25.5 | 509.42 | 1 | 1 | `position: absolute; width: 1px; height: 1px; opacity: 0` |  |
| 49 | `e08.sheet.form.newsletter.box` | box | 21.5 | 498.92 | 22 | 22 | `width: 22px; height: 22px; flex-shrink: 0; border-radius: 7px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 50 | `e08.sheet.form.submit` | box | 21.5 | 539.92 | 327 | 54 | `margin-top: 8px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 51 | `e08.sheet.form.submit.label` ±1 | text | 128.26 | 557.32 | 83.49 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 52 | `e08.sheet.form.submit.icon` ±1 | icon | 221.74 | 556.92 | 20 | 20 | `—` |  |
| 53 | `e08.sheet.legal` | text | 21.5 | 605.92 | 327 | 34.8 | `margin: 12px 0 0; font-size: 12px; font-weight: 500; line-height: 1.45; color: #6F665B; text-align: center; text-wrap: pretty` | Figtree 12/17.4px peso 500 ls normal #6F665B |
| 54 | `e08.sheet.legal.terms` ±1 | inline | 243.27 | 607.42 | 80.95 | 14.4 | `white-space: nowrap; font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px` | Figtree 12/17.4px peso 700 ls normal #1A1714 |
| 55 | `e08.sheet.legal.privacy` ±1 | inline | 120.99 | 624.82 | 125.4 | 14.4 | `white-space: nowrap; font-weight: 700; color: #1A1714; text-decoration: underline; text-underline-offset: 2px` | Figtree 12/17.4px peso 700 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e08.sheet.title` *(composto)* | 1 | Crie sua | 53.74 | 21.5 | 138.93 | 117.43 |
| `e08.sheet.title` *(composto)* | 2 | conta. | 93.72 | 21.5 | 113.64 | 92.14 |
| `e08.sheet.lead` | 1 | Um minuto e sua estante fica pronta. | 123.24 | 21.5 | 261.73 | 240.23 |
| `e08.sheet.form.name.label` | 1 | Nome | 160.04 | 21.5 | 59.25 | 37.75 |
| `e08.sheet.form.name.hint` | 1 | Aparece na sua carteirinha e nos clubes. | 240.69 | 23.5 | 248.21 | 224.71 |
| `e08.sheet.form.email.label` | 1 | E-mail | 272.04 | 21.5 | 61.27 | 39.77 |
| `e08.sheet.form.password.label` | 1 | Senha | 362.04 | 21.5 | 59.99 | 38.49 |
| `e08.sheet.form.password.field.dots` | 1 | •••••••••• | 404.62 | 39 | 146.62 | 107.62 |
| `e08.sheet.form.strength.label` | 1 | Forte | 448.67 | 316.1 | 348.5 | 32.4 |
| `e08.sheet.form.rules.rule1` | 1 | 8 ou mais caracteres | 474.29 | 43.5 | 161.02 | 117.52 |
| `e08.sheet.form.rules.rule2` | 1 | Um número ou símbolo | 474.29 | 197.02 | 328.19 | 131.17 |
| `e08.sheet.form.newsletter` | 1 | Quero dicas de leitura por e-mail | 514.64 | 53.5 | 253.62 | 200.12 |
| `e08.sheet.form.submit.label` | 1 | Criar conta | 572.52 | 128.26 | 211.74 | 83.48 |
| `e08.sheet.legal` *(composto)* | 1 | Ao criar a conta, você concorda com os Termos de Uso e a | 618.82 | 27.16 | 342.84 | 315.68 |
| `e08.sheet.legal` *(composto)* | 2 | Política de Privacidade. | 636.22 | 120.99 | 249.01 | 128.02 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O voltar (48, `left 16 · top 58`, `#FFFAF1`, borda 1,5, sombra 2/2, seta 20 traço 2,2) fica por cima de tudo (`z-index 2`). O brilho creme 26 em `left 96 · top 104`.
2. Carteirinha 172 × 108 em `right 20 · top 60`, raio 12, borda 1,5, sombra 4/4, girada 5°, `z-index 3`: o cabeçalho de 26 em `{{card}}` com "CARTEIRINHA DE LEITORA" 9/800 ls 1,1 e o brilho; as linhas pautadas (`#EAE1D0` a cada 18), "Marina Costa" Instrument Serif itálico 23 ls −0,3 e "Nº 0052 · DESDE 2026" 9/800 ls 0,8; o carimbo roxo 36 girado −14° saindo 9 por baixo.
3. A folha da entrada: `left/right/bottom 10` (e um `top` por tela), padding 24–26/20/20, raio 32/32/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4, coluna. O título é sempre Bricolage 32/800 `lh 0,98` ls −1 + quebra + Instrument Serif itálico 40–42 ls −0,4, e o texto de baixo 14,5/500 `lh 1,4–1,45` `#5B544B`, 8 abaixo. Aqui: `top 150`, padding 26/20/20.
4. Campos: rótulo 13,5/800 `lh 18`; a caixa de 52, 6 abaixo, raio 16, borda 1,5, padding 0/16 (0/4/0/16 com o olho de 44), texto 16/600; o campo em foco é `#FFFAF1` com o anel `{{brand}}` de 4 (`box-shadow 0 0 0 4`), os outros `#F7F0E3`. O e-mail tem o visto 24 `#ABCF82`; a senha mostra os pontos 18/800 ls 2,5 e o cursor 2 × 22 (o input real é escondido).
5. Força: a barra de 14 (hachura, o verde até 76 % com a ponta ondulada) e "Forte" 13/800, 12 abaixo; as regras (flex-wrap, gap 6/14) com o visto em círculo 16 e 12,5/600 `#3E3832`; a caixa das novidades 22 × 22 (raio 7, `#F7F0E3`) desmarcada, 13,5/600, linha de 44.
6. "Criar conta": 54, preto, 16/800 com a seta 20, 8 abaixo; os termos 12/500, 12 abaixo.
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O brilho do cabeçalho da carteirinha encolhe no flex (12 → 9,97, ver o mapa de widgets): decidir na T16.
- O campo da senha desenha os pontos e o cursor: o `TextField` real fica escondido (opacidade 0) e os pontos são texto 18/800 ls 2,5 — o número de pontos acompanha o tamanho da senha.
- A conta da G05 pede a idade (D-69) e a prancha não tem esse passo: onde ele entra no fluxo novo é pergunta da T16.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_008_cadastro_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_008_cadastro_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `e08.sheet.legal` linha 1 «Ao criar a conta, você concorda com os»: sobra 83.82 px · estouro com a próxima palavra 0.06 px.

## Diferenças em relação à prancha 07 (seções reutilizadas: waves)

Estas seções são as mesmas widgets da 07 (fases L07_1_fundo_e_marca, L07_2_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 07.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e08.back` |  | Voltar para o login |  |
| `e08.sparkleLarge` |  |  | aria-hidden=true |
| `e08.card` |  | Prévia da sua carteirinha |  |
| `e08.card.header.icon` |  |  | aria-hidden=true |
| `e08.card.stamp` |  |  | aria-hidden=true |
| `e08.sheet` |  | Criar conta com e-mail |  |
| `e08.sheet.form.email.field.valid` | img | E-mail válido |  |
| `e08.sheet.form.email.field.valid.icon` |  |  | aria-hidden=true |
| `e08.sheet.form.password.field.caret` |  |  | aria-hidden=true |
| `e08.sheet.form.password.field.input` |  |  | aria-describedby=su-pass-rules |
| `e08.sheet.form.password.field.reveal` |  | Mostrar senha |  |
| `e08.sheet.form.password.field.reveal.icon` |  |  | aria-hidden=true |
| `e08.sheet.form.strength.bar` | meter | Força da senha | aria-valuemin=0, aria-valuemax=4, aria-valuenow=3, aria-valuetext=Forte |
| `e08.sheet.form.rules.rule1.check` |  |  | aria-hidden=true |
| `e08.sheet.form.rules.rule2.check` |  |  | aria-hidden=true |
| `e08.sheet.form.newsletter.box` |  |  | aria-hidden=true |
| `e08.sheet.form.submit.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e08.back` | CircleIconButton / NeoBox circular |  |
| `e08.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `e08.sparkleLarge` | AppSvg(AppIconsBiblioteca.sparkleCreme, size: 26) |  |
| `e08.card` | NeoBox | Transform: rotate(5deg) |
| `e08.card.header` | NeoBox |  |
| `e08.card.header.icon` | AppSvg(AppIcons.sparkleSolid, size: 9.97) | o `<svg>` de 12×12 (atributos) não tem flex-shrink: 0 e encolhe na linha que não cabe: fica com o que sobra do cabeçalho depois do rótulo "CARTEIRINHA DE LEITORA" (sem quebra), 149 − 139,03: fica 9,97×12 no layout, e o desenho (viewBox 24×24, preserveAspectRatio meet) sai 9,97×9,97, centrado na altura. A prancha mostra o ícone menor — decidir na T16 se o app repete o encolhimento (o tamanho do catálogo) ou usa o dos atributos. |
| `e08.card.body` | HatchPainter (hachura 135°) dentro do contorno |  |
| `e08.card.stamp` | CircleIconButton / NeoBox circular | Transform: rotate(-14deg) |
| `e08.card.stamp.icon` | AppSvg(AppIconsEntrada.sparkleSolidVioleta, size: 16) |  |
| `e08.sheet` | NeoBox |  |
| `e08.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e08.sheet.form.name.field` | NeoBox |  |
| `e08.sheet.form.email.field` | NeoBox |  |
| `e08.sheet.form.email.field.valid` | CircleIconButton / NeoBox circular |  |
| `e08.sheet.form.email.field.valid.icon` | AppSvg(AppIconsLeitor.checkSmall, size: 13) |  |
| `e08.sheet.form.password.field` | NeoBox |  |
| `e08.sheet.form.password.field.caret` | NeoBox |  |
| `e08.sheet.form.password.field.input` | NeoBox |  |
| `e08.sheet.form.password.field.reveal.icon` | AppSvg(AppIconsEntrada.eye, size: 22) |  |
| `e08.sheet.form.strength.bar` | HatchPainter (hachura 135°) dentro do contorno |  |
| `e08.sheet.form.strength.bar.fill` | NeoBox |  |
| `e08.sheet.form.strength.bar.fill.edge` | CustomPainter (borda_onda_preenchimento_verde) | preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): a borda ondulada da ponta da barra preenchida, esticada na altura da barra com traço fixo de 1,5 — CustomPainter, como a onda da barra do leitor. |
| `e08.sheet.form.rules.rule1.check` | CircleIconButton / NeoBox circular |  |
| `e08.sheet.form.rules.rule1.check.icon` | AppSvg(AppIconsEntrada.checkMini, size: 9) |  |
| `e08.sheet.form.rules.rule2.check` | CircleIconButton / NeoBox circular |  |
| `e08.sheet.form.rules.rule2.check.icon` | AppSvg(AppIconsEntrada.checkMini, size: 9) |  |
| `e08.sheet.form.newsletter.box` | NeoBox |  |
| `e08.sheet.form.submit` | NeoBox |  |
| `e08.sheet.form.submit.icon` | AppSvg(AppIconsEntrada.arrowForward, size: 20) |  |
| `e08.sheet.legal.terms` | TextSpan dentro do AppText.rich do pai |  |
| `e08.sheet.legal.privacy` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- A carteirinha atualiza o nome enquanto a pessoa digita (nota do design).
- `AutofillGroup` com name / email / newPassword; `TextInputAction.next` entre os campos; teclado de e-mail; o olho mostra a senha.
- Criar conta → cria a conta (G05) e vai direto para o Onboarding (12). Com o teclado aberto, o formulário rola e o botão fica visível.
- Voltar → o Login.

## Dados

- Nome, e-mail e senha digitados; a força da senha calculada no app (ex.: zxcvbn, nota do design); o número da carteirinha ("Nº 0052", a revisão de consistência) vem da conta.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L08.1** Carteirinha ao vivo
- **L08.2** Folha: nome, e-mail e senha
- **L08.3** Força, regras e novidades
- **L08.4** Criar conta → Onboarding
- **L08.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e08.back', 'e08.sparkleLarge', 'e08.card', 'e08.sheet'), todos os ids de `kRef08.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/008_cadastro_390x844@3x.png` no recorte da fase (y 44.71–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef08w360` e `kRef08w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L08.1 Carteirinha ao vivo
- [ ] L08.2 Folha: nome, e-mail e senha
- [ ] L08.3 Força, regras e novidades
- [ ] L08.4 Criar conta → Onboarding
- [ ] L08.5 Verificação + relatório
- [ ] Geometria 52/52 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
