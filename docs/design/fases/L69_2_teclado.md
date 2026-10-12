# FASE L69 — Digitar o ISBN — a barra de teclas do app (X, colar, esconder) sobre o teclado numérico do sistema

> Tela 69 · prancha `069_scanner_digitar_isbn` (69 · Scanner — digitar o ISBN, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L69_2_teclado@3x.png` · `docs/design/medicao/projeto/png/redline/L69_2_teclado_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/069_scanner_digitar_isbn_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_069_scanner_digitar_isbn.json` · `test/reference/projeto/reference_layout_069_scanner_digitar_isbn.dart` (`kRef69`).
> Arquivos sugeridos: `lib/features/scanner/presentation/isbn_typing/isbn_keys_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A barra de teclas do app (X "dígito final", Colar e esconder o teclado) presa em cima do teclado numérico do sistema — o teclado do sistema aparece na prancha só como contexto.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- Accessory bar: app widget pinned on top of the system number pad (keeps the X the pad lacks) -->
<div role="toolbar" aria-label="Teclas extras" style="position: absolute; left: 0; right: 0; top: 538px; height: 56px; padding: 0 12px; box-sizing: border-box; display: flex; align-items: center; gap: 8px; background: #FFFAF1; border-top: 1.5px solid #1A1714; border-radius: 20px 20px 0 0;">
  <button aria-label="Digitar X, o dígito final do ISBN-10" style="height: 42px; padding: 0 14px 0 12px; border-radius: 13px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px;">
    <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1;">X</span>
    <span style="font-size: 11.5px; font-weight: 700; line-height: 1.1; text-align: left; color: #1A1714;">dígito<br>final</span>
  </button>
  <button aria-label="Colar ISBN copiado" style="height: 42px; padding: 0 14px 0 11px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="7" y="4" width="10" height="4" rx="1.5"></rect><path d="M9 6H6.5A1.5 1.5 0 0 0 5 7.5v12A1.5 1.5 0 0 0 6.5 21h11a1.5 1.5 0 0 0 1.5-1.5v-12A1.5 1.5 0 0 0 17.5 6H15"></path></svg>Colar</button>
  <span style="flex-grow: 1;"></span>
  <button aria-label="Esconder teclado" style="width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2.5" y="3.5" width="19" height="11" rx="2.5"></rect><path d="M6.5 7.5h.01M10 7.5h.01M14 7.5h.01M17.5 7.5h.01M8 11h8"></path><path d="m9 18 3 3 3-3"></path></svg></button>
</div>

<!-- System number pad (phone's own keyboard; shown for context, not styled by the app) -->
<div aria-hidden="true" style="position: absolute; left: 0; right: 0; top: 594px; bottom: 0; padding: 6px 6px 0; box-sizing: border-box; background: #D1D4DA; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); grid-auto-rows: 46px; gap: 7px 6px;">
  <span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">1</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">2</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">ABC</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">3</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">DEF</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">4</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">GHI</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">5</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">JKL</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">6</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">MNO</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">7</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">PQRS</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">8</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">TUV</span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">9</span><span style="margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1;">WXYZ</span></span><span></span><span style="height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000;"><span style="font-size: 25px; font-weight: 400; line-height: 1;">0</span></span><span style="height: 46px; display: flex; align-items: center; justify-content: center;"><svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 5H9l-6 7 6 7h12a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1z" stroke-linejoin="round"></path><path d="m12.5 9.5 5 5M17.5 9.5l-5 5"></path></svg></span>
</div>
```

## Especificação pixel a pixel

Seção `sc69.toolbar` — retângulo absoluto no canvas 390×844: **x=0, y=538, w=390, h=56**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc69.toolbar` | box | 0 | 0 | 390 | 56 | `position: absolute; left: 0; right: 0; top: 538px; height: 56px; padding: 0 12px; box-sizing: border-box; display: flex; align-items: center; gap: 8px; background: #FFFAF1; border-top: 1.5px solid #1A1714; border-radius: 20px 20px 0 0` |  |
| 2 | `sc69.toolbar.x` ±1 | box | 12 | 7.75 | 83.58 | 42 | `height: 42px; padding: 0 14px 0 12px; border-radius: 13px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 8px` |  |
| 3 | `sc69.toolbar.x.key` ±1 | text | 25.5 | 17.75 | 15.6 | 22 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1` | Bricolage (opsz 22) 22/22px peso 800 ls normal #1A1714 |
| 4 | `sc69.toolbar.x.caption` ±1 | text | 49.1 | 16.1 | 30.98 | 25.3 | `font-size: 11.5px; font-weight: 700; line-height: 1.1; text-align: left; color: #1A1714` | Figtree 11.5/12.65px peso 700 ls normal #1A1714 |
| 5 | `sc69.toolbar.paste` ±1 | box+text | 103.58 | 7.75 | 88.07 | 42 | `height: 42px; padding: 0 14px 0 11px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 6 | `sc69.toolbar.paste.icon` ±1 | icon | 116.08 | 19.75 | 18 | 18 | `—` |  |
| 7 | `sc69.toolbar.spacer` ±1 | box | 199.65 | 28.75 | 126.35 | 0 | `flex-grow: 1` |  |
| 8 | `sc69.toolbar.hide` | box | 334 | 6.75 | 44 | 44 | `width: 44px; height: 44px; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `sc69.toolbar.hide.icon` | icon | 345.5 | 18.25 | 21 | 21 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc69.toolbar.x.key` | 1 | X | 36.01 | 25.5 | 41.1 | 15.6 |
| `sc69.toolbar.x.caption` | 1 | dígito | 26.45 | 49.1 | 80.08 | 30.98 |
| `sc69.toolbar.x.caption` | 2 | final | 39.1 | 49.1 | 72.12 | 23.02 |
| `sc69.toolbar.paste` | 1 | Colar | 33.65 | 141.08 | 176.15 | 35.07 |

Seção `sc69.keypad` — retângulo absoluto no canvas 390×844: **x=0, y=594, w=390, h=250**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 10 | `sc69.keypad` | box | 0 | 0 | 390 | 250 | `position: absolute; left: 0; right: 0; top: 594px; bottom: 0; padding: 6px 6px 0; box-sizing: border-box; background: #D1D4DA; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); grid-auto-rows: 46px; gap: 7px 6px` |  |
| 11 | `sc69.keypad.key1` | box | 6 | 6 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 12 | `sc69.keypad.key1.digit` ±1 | text | 61.92 | 16.5 | 10.17 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 13 | `sc69.keypad.key2` | box | 134 | 6 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 14 | `sc69.keypad.key2.digit` ±1 | text | 187.38 | 11.25 | 15.25 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 15 | `sc69.keypad.key2.letters` ±1 | text | 181.8 | 37.25 | 26.41 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 16 | `sc69.keypad.key3` | box | 262 | 6 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 17 | `sc69.keypad.key3.digit` ±1 | text | 315.28 | 11.25 | 15.44 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 18 | `sc69.keypad.key3.letters` ±1 | text | 310.9 | 37.25 | 24.21 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 19 | `sc69.keypad.key4` | box | 6 | 59 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 20 | `sc69.keypad.key4.digit` ±1 | text | 58.92 | 64.25 | 16.15 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 21 | `sc69.keypad.key4.letters` ±1 | text | 55.55 | 90.25 | 22.89 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 22 | `sc69.keypad.key5` | box | 134 | 59 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 23 | `sc69.keypad.key5.digit` ±1 | text | 187.4 | 64.25 | 15.2 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 24 | `sc69.keypad.key5.letters` ±1 | text | 183.12 | 90.25 | 23.76 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 25 | `sc69.keypad.key6` | box | 262 | 59 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 26 | `sc69.keypad.key6.digit` ±1 | text | 315.25 | 64.25 | 15.5 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 27 | `sc69.keypad.key6.letters` ±1 | text | 308.29 | 90.25 | 29.41 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 28 | `sc69.keypad.key7` | box | 6 | 112 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 29 | `sc69.keypad.key7.digit` ±1 | text | 59.93 | 117.25 | 14.15 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 30 | `sc69.keypad.key7.letters` ±1 | text | 50 | 143.25 | 33.99 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 31 | `sc69.keypad.key8` | box | 134 | 112 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 32 | `sc69.keypad.key8.digit` ±1 | text | 187.27 | 117.25 | 15.47 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 33 | `sc69.keypad.key8.letters` ±1 | text | 181.81 | 143.25 | 26.39 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 34 | `sc69.keypad.key9` | box | 262 | 112 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 35 | `sc69.keypad.key9.digit` ±1 | text | 315.25 | 117.25 | 15.5 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 36 | `sc69.keypad.key9.letters` ±1 | text | 303.94 | 143.25 | 38.12 | 9.5 | `margin-top: 1px; font-size: 9.5px; font-weight: 700; letter-spacing: 2px; line-height: 1` | ui-sans-serif 9.5/9.5px peso 700→**800** ls 2px #000000 |
| 37 | `sc69.keypad.blank` | box | 6 | 165 | 122 | 46 | `—` |  |
| 38 | `sc69.keypad.key0` | box | 134 | 165 | 122 | 46 | `height: 46px; border-radius: 6px; background: #FFFFFF; box-shadow: 0 1px 0 #898A8D; display: flex; flex-direction: column; align-items: center; justify-content: center; font-family: ui-sans-serif, system-ui, sans-serif; color: #000` |  |
| 39 | `sc69.keypad.key0.digit` ±1 | text | 187.11 | 175.5 | 15.77 | 25 | `font-size: 25px; font-weight: 400; line-height: 1` | ui-sans-serif 25/25px peso 400→**800** ls normal #000000 |
| 40 | `sc69.keypad.delete` | box | 262 | 165 | 122 | 46 | `height: 46px; display: flex; align-items: center; justify-content: center` |  |
| 41 | `sc69.keypad.delete.icon` | icon | 310 | 175 | 26 | 26 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc69.keypad.key1.digit` | 1 | 1 | 36.15 | 61.92 | 72.08 | 10.16 |
| `sc69.keypad.key2.digit` | 1 | 2 | 30.9 | 187.38 | 202.62 | 15.24 |
| `sc69.keypad.key2.letters` | 1 | ABC | 44.72 | 181.8 | 208.2 | 26.4 |
| `sc69.keypad.key3.digit` | 1 | 3 | 30.9 | 315.28 | 330.72 | 15.44 |
| `sc69.keypad.key3.letters` | 1 | DEF | 44.72 | 310.9 | 335.1 | 24.2 |
| `sc69.keypad.key4.digit` | 1 | 4 | 83.9 | 58.92 | 75.08 | 16.16 |
| `sc69.keypad.key4.letters` | 1 | GHI | 97.72 | 55.55 | 78.45 | 22.9 |
| `sc69.keypad.key5.digit` | 1 | 5 | 83.9 | 187.4 | 202.6 | 15.2 |
| `sc69.keypad.key5.letters` | 1 | JKL | 97.72 | 183.12 | 206.88 | 23.76 |
| `sc69.keypad.key6.digit` | 1 | 6 | 83.9 | 315.25 | 330.75 | 15.5 |
| `sc69.keypad.key6.letters` | 1 | MNO | 97.72 | 308.29 | 337.71 | 29.42 |
| `sc69.keypad.key7.digit` | 1 | 7 | 136.9 | 59.93 | 74.07 | 14.14 |
| `sc69.keypad.key7.letters` | 1 | PQRS | 150.72 | 50 | 84 | 34 |
| `sc69.keypad.key8.digit` | 1 | 8 | 136.9 | 187.27 | 202.73 | 15.46 |
| `sc69.keypad.key8.letters` | 1 | TUV | 150.72 | 181.81 | 208.19 | 26.38 |
| `sc69.keypad.key9.digit` | 1 | 9 | 136.9 | 315.25 | 330.75 | 15.5 |
| `sc69.keypad.key9.letters` | 1 | WXYZ | 150.72 | 303.94 | 342.06 | 38.12 |
| `sc69.keypad.key0.digit` | 1 | 0 | 195.15 | 187.11 | 202.89 | 15.78 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Barra em top 538 (logo acima do teclado), 56 de altura, padding 0/12, gap 8, `#FFFAF1`, borda de cima 1,5, raio 20/20/0/0.
2. X: 42 de altura, padding 0/14/0/12, raio 13, `#FED170`, borda 1,5, sombra 2/2, "X" Bricolage 22/800 + "dígito / final" 11,5/700 `lh 1,1` em 2 linhas.
3. Colar: pílula de 42, padding 0/14/0/11, `#FFFAF1`, borda 1,5, prancheta 18 + 14/800; um espaço flexível; esconder: círculo 44 `#F7F0E3` com o teclado e a seta 21.
4. O teclado (top 594 até o fim): é o do sistema, desenhado na prancha com a fonte do sistema — o app não o desenha.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O teclado da prancha é o do iPhone desenhado com a fonte do sistema (as reservas R8 abaixo): fica fora dos testes de fidelidade — o golden recorta até a barra (y < 594) ou usa o teclado real do aparelho; confirmar na T15.
- A barra fica presa ao teclado: a posição 538 é a da prancha com o teclado de 250; no app, `bottom: MediaQuery.viewInsetsOf(context).bottom`.
- `sc69.keypad.key1` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key1.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key2` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key2.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key2.letters` usa glifo de fonte do sistema (Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key3` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key3.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key3.letters` usa glifo de fonte do sistema (Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key4` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key4.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key4.letters` usa glifo de fonte do sistema (Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key5` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key5.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key5.letters` usa glifo de fonte do sistema (Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key6` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key6.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key6.letters` usa glifo de fonte do sistema (Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key7` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (4 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key7.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key7.letters` usa glifo de fonte do sistema (Inter (4 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key8` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key8.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key8.letters` usa glifo de fonte do sistema (Inter (3 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key9` usa glifo de fonte do sistema (Inter (1 glifo(s)), Inter (4 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key9.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key9.letters` usa glifo de fonte do sistema (Inter (4 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key0` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.
- `sc69.keypad.key0.digit` usa glifo de fonte do sistema (Inter (1 glifo(s))) — no navegador o resultado depende da máquina.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_069_scanner_digitar_isbn_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_069_scanner_digitar_isbn_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc69.toolbar` | toolbar | Teclas extras |  |
| `sc69.toolbar.x` |  | Digitar X, o dígito final do ISBN-10 |  |
| `sc69.toolbar.paste` |  | Colar ISBN copiado |  |
| `sc69.toolbar.paste.icon` |  |  | aria-hidden=true |
| `sc69.toolbar.hide` |  | Esconder teclado |  |
| `sc69.toolbar.hide.icon` |  |  | aria-hidden=true |
| `sc69.keypad` |  |  | aria-hidden=true |
| `sc69.keypad.delete.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc69.toolbar` | NeoBox |  |
| `sc69.toolbar.x` | NeoBox |  |
| `sc69.toolbar.paste` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc69.toolbar.paste.icon` | AppSvg(AppIconsScanner.clipboard, size: 18) |  |
| `sc69.toolbar.hide` | CircleIconButton / NeoBox circular |  |
| `sc69.toolbar.hide.icon` | AppSvg(AppIconsScanner.keyboardHide, size: 21) |  |
| `sc69.keypad` | NeoBox |  |
| `sc69.keypad.key1` | NeoBox |  |
| `sc69.keypad.key2` | NeoBox |  |
| `sc69.keypad.key3` | NeoBox |  |
| `sc69.keypad.key4` | NeoBox |  |
| `sc69.keypad.key5` | NeoBox |  |
| `sc69.keypad.key6` | NeoBox |  |
| `sc69.keypad.key7` | NeoBox |  |
| `sc69.keypad.key8` | NeoBox |  |
| `sc69.keypad.key9` | NeoBox |  |
| `sc69.keypad.key0` | NeoBox |  |
| `sc69.keypad.delete.icon` | AppSvg(AppIconsScanner.backspace, size: 26) | a tecla de apagar do teclado do sistema (R8, informativo): o app não desenha o teclado; fica como referência. |

## Interações

- X → acrescenta "X" sem tirar o foco; amarelo só quando faz sentido (ISBN-10 com 9 dígitos); fora disso apagado, e o leitor de tela diz "só para ISBN de 10 dígitos" (nota do design).
- Colar → aparece quando há algo copiado; aceita qualquer formato e guarda só os dígitos e o X.
- Esconder teclado → tira o foco; a barra desce junto (`bottom: viewInsets`).

## Dados

- O conteúdo da área de transferência (só para mostrar o Colar).

## Subfases

- **L69.1** Barra de teclas presa ao teclado
- **L69.2** X condicional, Colar e esconder
- **L69.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc69.toolbar', 'sc69.keypad'), todos os ids de `kRef69.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/069_scanner_digitar_isbn_390x844@3x.png` no recorte da fase (y 530–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef69w360` e `kRef69w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L69.1 Barra de teclas presa ao teclado
- [ ] L69.2 X condicional, Colar e esconder
- [ ] L69.3 Verificação + relatório
- [ ] Geometria 41/41 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
