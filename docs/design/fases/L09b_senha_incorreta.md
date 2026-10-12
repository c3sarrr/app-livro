# FASE L09b — Entrar (senha incorreta) — o campo rosado, o aviso e o código em amarelo

> Tela 09b · prancha `009b_entrar_senha_incorreta` (09b · Entrar — senha incorreta, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L09b_senha_incorreta@3x.png` · `docs/design/medicao/projeto/png/redline/L09b_senha_incorreta_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/009b_entrar_senha_incorreta_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_009b_entrar_senha_incorreta.json` · `test/reference/projeto/reference_layout_009b_entrar_senha_incorreta.dart` (`kRef09b`).
> Arquivos sugeridos: `lib/features/account/presentation/entry/sign_in_email_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Entrar com a senha incorreta (09b): o campo da senha rosado com a sombra coral, o aviso "Senha incorreta. Tente de novo ou entre com um código." e o botão do código em amarelo, para mostrar a saída. O resto é a 09.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{badge}}` = padrão `#FED170`.

```html
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
    <div style="margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFE9E4; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #FF552E; box-sizing: border-box; display: flex; align-items: center;">
      <span style="flex-grow: 1; min-width: 0; font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1;">••••••••</span>
      <input id="si-pass" type="password" autocomplete="current-password" aria-invalid="true" aria-describedby="si-pass-error" style="position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none;">
      <button type="button" aria-label="Mostrar senha" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 12s3.6-7 10-7 10 7 10 7-3.6 7-10 7S2 12 2 12Z"></path><circle cx="12" cy="12" r="3"></circle></svg>
      </button>
    </div>
    <p id="si-pass-error" role="alert" style="margin: 12px 0 0; display: flex; align-items: flex-start; gap: 8px; font-size: 13.5px; font-weight: 700; line-height: 1.4; color: #1A1714;">
      <span aria-hidden="true" style="width: 20px; height: 20px; flex-shrink: 0; margin-top: -1px; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 900; line-height: 1; color: #1A1714;">!</span>
      <span>Senha incorreta. Tente de novo ou entre com um código.</span>
    </p>

    <button type="submit" style="margin-top: 16px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3;">
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
  <button style="margin-top: 14px; width: 100%; height: 52px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 15.5px; font-weight: 800; color: #1A1714;">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="3"></rect><path d="m4 7 8 6 8-6"></path></svg>
    Receber código por e-mail
  </button>

  <p style="margin: auto 0 0; height: 44px; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 14px; font-weight: 600; color: #5B544B;">Ainda não tem conta? <a href="#" style="font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Criar conta</a></p>
</main>
```

## Especificação pixel a pixel

Seção `e09b.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=242, w=370, h=592**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e09b.sheet` | box | 0 | 0 | 370 | 592 | `position: absolute; left: 10px; right: 10px; top: 242px; bottom: 10px; box-sizing: border-box; padding: 26px 20px 12px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 2 | `e09b.sheet.title` | text | 21.5 | 27.5 | 327 | 72.52 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 32) 32/31.36px peso 800 ls -1px #1A1714 |
| 3 | `e09b.sheet.title.serif` ±1 | inline | 21.5 | 52.14 | 119.86 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |
| 4 | `e09b.sheet.lead` | text | 21.5 | 108.02 | 327 | 20.3 | `margin: 8px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.4; color: #5B544B` | Figtree 14.5/20.3px peso 500 ls normal #5B544B |
| 5 | `e09b.sheet.form` | box | 21.5 | 146.32 | 327 | 285.8 | `margin: 18px 0 0; display: flex; flex-direction: column` |  |
| 6 | `e09b.sheet.form.email.label` | text | 21.5 | 146.32 | 327 | 18 | `font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 7 | `e09b.sheet.form.email.field` | box | 21.5 | 170.32 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 16px; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center` |  |
| 8 | `e09b.sheet.form.email.field.input` | box | 39 | 171.82 | 292 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 16px; font-weight: 600; color: #1A1714` |  |
| 9 | `e09b.sheet.form.password.header` | box | 21.5 | 236.32 | 327 | 18 | `margin-top: 14px; display: flex; align-items: center; justify-content: space-between` |  |
| 10 | `e09b.sheet.form.password.label` ±1 | text | 21.5 | 236.32 | 38.49 | 18 | `font-size: 13.5px; font-weight: 800; line-height: 18px` | Figtree 13.5/18px peso 800 ls normal #1A1714 |
| 11 | `e09b.sheet.form.password.forgot` ±1 | text | 241.19 | 223.32 | 115.31 | 44 | `margin: -13px -8px -13px 0; padding: 0 8px; height: 44px; display: flex; align-items: center; font-size: 13.5px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 12 | `e09b.sheet.form.password.field` | box | 21.5 | 260.32 | 327 | 52 | `margin-top: 6px; height: 52px; padding: 0 4px 0 16px; border-radius: 16px; background: #FFE9E4; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #FF552E; box-sizing: border-box; display: flex; align-items: center` |  |
| 13 | `e09b.sheet.form.password.field.dots` | text | 39 | 277.32 | 260 | 18 | `flex-grow: 1; min-width: 0; font-size: 18px; font-weight: 800; letter-spacing: 2.5px; line-height: 1` | Figtree 18/18px peso 800 ls 2.5px #1A1714 |
| 14 | `e09b.sheet.form.password.field.input` | box | 39 | 282.82 | 9 | 7 | `position: absolute; width: 1px; height: 1px; opacity: 0; pointer-events: none` |  |
| 15 | `e09b.sheet.form.password.field.reveal` | box | 299 | 264.32 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 16 | `e09b.sheet.form.password.field.reveal.icon` | icon | 310 | 275.32 | 22 | 22 | `—` |  |
| 17 | `e09b.sheet.form.alert` | box | 21.5 | 324.32 | 327 | 37.8 | `margin: 12px 0 0; display: flex; align-items: flex-start; gap: 8px; font-size: 13.5px; font-weight: 700; line-height: 1.4; color: #1A1714` |  |
| 18 | `e09b.sheet.form.alert.badge` | box+text | 21.5 | 323.32 | 20 | 20 | `width: 20px; height: 20px; flex-shrink: 0; margin-top: -1px; border-radius: 50%; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: 900; line-height: 1; color: #1A1714` | Figtree 12/12px peso 900→**800** ls normal #1A1714 |
| 19 | `e09b.sheet.form.alert.text` | text | 49.5 | 324.32 | 299 | 37.8 | `—` | Figtree 13.5/18.9px peso 700 ls normal #1A1714 |
| 20 | `e09b.sheet.form.submit` | box | 21.5 | 378.12 | 327 | 54 | `margin-top: 16px; width: 100%; height: 54px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 800; color: #F7F0E3` |  |
| 21 | `e09b.sheet.form.submit.label` ±1 | text | 146.72 | 395.52 | 46.56 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 800 ls normal #F7F0E3 |
| 22 | `e09b.sheet.form.submit.icon` ±1 | icon | 203.28 | 395.12 | 20 | 20 | `—` |  |
| 23 | `e09b.sheet.divider` | box | 21.5 | 446.12 | 327 | 19 | `margin-top: 14px; display: flex; align-items: center; gap: 12px` |  |
| 24 | `e09b.sheet.divider.lineLeft` ±1 | box | 21.5 | 454.87 | 142.74 | 1.5 | `flex-grow: 1; height: 1.5px; background: #E2D7C4` |  |
| 25 | `e09b.sheet.divider.label` ±1 | text | 176.24 | 446.12 | 17.52 | 19 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 19px; line-height: 1; color: #5B544B` | Instrument Serif itálico 19/19px peso 400 ls normal #5B544B |
| 26 | `e09b.sheet.divider.lineRight` ±1 | box | 205.76 | 454.87 | 142.74 | 1.5 | `flex-grow: 1; height: 1.5px; background: #E2D7C4` |  |
| 27 | `e09b.sheet.code` | box+text | 21.5 | 479.12 | 327 | 52 | `margin-top: 14px; width: 100%; height: 52px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 15.5px; font-weight: 800; color: #1A1714` | Figtree 15.5/normal peso 800 ls normal #1A1714 |
| 28 | `e09b.sheet.code.icon` ±1 | icon | 74.81 | 495.12 | 20 | 20 | `—` |  |
| 29 | `e09b.sheet.signUp` | text | 21.5 | 534.5 | 327 | 44 | `margin: auto 0 0; height: 44px; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 30 | `e09b.sheet.signUp.link` ±1 | text | 220.46 | 548.1 | 73.05 | 16.8 | `font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 14/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e09b.sheet.title` *(composto)* | 1 | Que bom te ver | 53.74 | 21.5 | 240.26 | 218.76 |
| `e09b.sheet.title` *(composto)* | 2 | de novo. | 93.72 | 21.5 | 141.36 | 119.86 |
| `e09b.sheet.lead` | 1 | Sua leitura está te esperando. | 123.24 | 21.5 | 214.27 | 192.77 |
| `e09b.sheet.form.email.label` | 1 | E-mail | 160.04 | 21.5 | 61.27 | 39.77 |
| `e09b.sheet.form.password.label` | 1 | Senha | 250.04 | 21.5 | 59.99 | 38.49 |
| `e09b.sheet.form.password.forgot` | 1 | Esqueci a senha | 250.05 | 249.19 | 348.5 | 99.31 |
| `e09b.sheet.form.password.field.dots` | 1 | •••••••• | 292.62 | 39 | 125.1 | 86.1 |
| `e09b.sheet.form.alert.badge` | 1 | ! | 337.52 | 29.59 | 33.41 | 3.82 |
| `e09b.sheet.form.alert.text` | 1 | Senha incorreta. Tente de novo ou entre com | 338.49 | 49.5 | 326.65 | 277.15 |
| `e09b.sheet.form.alert.text` | 2 | um código. | 357.39 | 49.5 | 118.24 | 68.74 |
| `e09b.sheet.form.submit.label` | 1 | Entrar | 410.72 | 146.72 | 193.28 | 46.56 |
| `e09b.sheet.divider.label` | 1 | ou | 462.08 | 176.24 | 193.76 | 17.52 |
| `e09b.sheet.code` | 1 | Receber código por e-mail | 510.54 | 104.81 | 295.19 | 190.38 |
| `e09b.sheet.signUp` | 1 | Ainda não tem conta? | 561.4 | 76.49 | 215.46 | 138.97 |
| `e09b.sheet.signUp.link` | 1 | Criar conta | 561.4 | 220.46 | 293.51 | 73.05 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Campo da senha: `#FFE9E4`, borda 1,5, sombra dura coral `3/3 #FF552E` (no lugar do anel de foco), os pontos sem o cursor ocupando o campo (260 de largura).
2. Aviso, 12 abaixo (`role=alert`): o "!" num círculo coral 20 (12/900 → 800) e o texto 13,5/700 `lh 1,4` `#1A1714`, gap 8, `align-items: flex-start` (o círculo sobe 1).
3. "Entrar" 16 abaixo do aviso (não 18); "Receber código por e-mail" em `#FED170` com sombra 3/3.
4. O aviso faz o formulário crescer 47,8 (T13.6): tudo abaixo desce, e o pé continua no fundo.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O "!" do círculo é Figtree 900, que renderiza 800 (D-246).
- Os pontos da senha sem cursor ocupam o campo inteiro (260): com uma senha longa, cortar ou reticências não têm prancha — o `TextField` real faz a rolagem do texto.
- Fio de navalha em `e09b.sheet.form.alert.text` linha 1 «Senha incorreta. Tente de novo ou entre com»: sobra 21.84 px · estouro com a próxima palavra 0.81 px.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_009b_entrar_senha_incorreta_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_009b_entrar_senha_incorreta_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 09 (seções reutilizadas: waves, back, badge, sparkleLarge, sparkleSmall)

Estas seções são as mesmas widgets da 09 (fases L09_entrar); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 09.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e09b.sheet` |  | Entrar com e-mail |  |
| `e09b.sheet.form.password.field.input` |  |  | aria-invalid=true, aria-describedby=si-pass-error |
| `e09b.sheet.form.password.field.reveal` |  | Mostrar senha |  |
| `e09b.sheet.form.password.field.reveal.icon` |  |  | aria-hidden=true |
| `e09b.sheet.form.alert` | alert |  |  |
| `e09b.sheet.form.alert.badge` |  |  | aria-hidden=true |
| `e09b.sheet.form.submit.icon` |  |  | aria-hidden=true |
| `e09b.sheet.divider` |  |  | aria-hidden=true |
| `e09b.sheet.code.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e09b.sheet` | NeoBox |  |
| `e09b.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e09b.sheet.form.email.field` | NeoBox |  |
| `e09b.sheet.form.password.field` | NeoBox |  |
| `e09b.sheet.form.password.field.input` | NeoBox |  |
| `e09b.sheet.form.password.field.reveal.icon` | AppSvg(AppIconsEntrada.eye, size: 22) |  |
| `e09b.sheet.form.alert.badge` | CircleIconButton / NeoBox circular |  |
| `e09b.sheet.form.submit` | NeoBox |  |
| `e09b.sheet.form.submit.icon` | AppSvg(AppIconsEntrada.arrowForward, size: 20) |  |
| `e09b.sheet.divider.lineLeft` | NeoBox |  |
| `e09b.sheet.divider.lineRight` | NeoBox |  |
| `e09b.sheet.code` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e09b.sheet.code.icon` | AppSvg(AppIconsEntrada.mailTinta, size: 20) |  |

## Interações

- A mensagem é lida pelo leitor de tela (`role=alert`, `aria-invalid` no campo).
- A volta ao campo normal não tem prancha: se o aviso some ao editar a senha ou só na próxima tentativa é pergunta da T16.
- Receber código por e-mail → a tela do código (10).

## Dados

- O erro vem da autenticação (senha errada); outros erros (sem rede, conta inexistente) não têm prancha — os textos são da T24 (estados do app) ou pergunta da T16.

## Subfases

- **L09b.1** Campo rosado com a sombra coral
- **L09b.2** Aviso anunciado
- **L09b.3** Botão do código em amarelo
- **L09b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e09b.sheet'), todos os ids de `kRef09b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/009b_entrar_senha_incorreta_390x844@3x.png` no recorte da fase (y 234–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef09bw360` e `kRef09bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L09b.1 Campo rosado com a sombra coral
- [ ] L09b.2 Aviso anunciado
- [ ] L09b.3 Botão do código em amarelo
- [ ] L09b.4 Verificação + relatório
- [ ] Geometria 29/29 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
