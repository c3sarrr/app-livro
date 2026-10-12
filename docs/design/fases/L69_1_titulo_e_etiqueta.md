# FASE L69 — Digitar o ISBN — o título e a etiqueta que imprime as barras enquanto a pessoa digita

> Tela 69 · prancha `069_scanner_digitar_isbn` (69 · Scanner — digitar o ISBN, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L69_1_titulo_e_etiqueta@3x.png` · `docs/design/medicao/projeto/png/redline/L69_1_titulo_e_etiqueta_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/069_scanner_digitar_isbn_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_069_scanner_digitar_isbn.json` · `test/reference/projeto/reference_layout_069_scanner_digitar_isbn.dart` (`kRef69`).
> Arquivos sugeridos: `lib/features/scanner/presentation/isbn_typing/isbn_typing_view.dart`, `lib/features/scanner/presentation/isbn_typing/isbn_sticker.dart`, `lib/features/scanner/presentation/isbn_typing/barcode_painter.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Digitar o ISBN (69): a aba Digitar com a câmera pausada (fundo escuro com pontinhos), "Digite o ISBN do verso." e a etiqueta de código de barras que se imprime enquanto a pessoa digita — o caso de um livro de sebo com o ISBN-10 (85-08-06294-X), 9 de 10 dígitos, faltando o final.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- Camera is paused on this tab: dark backdrop with a faint dot grid -->
<div aria-hidden="true" style="position: absolute; inset: 0; background-image: radial-gradient(rgba(255,250,241,0.09) 1px, transparent 1.4px); background-size: 18px 18px;"></div>

<!-- Heading -->
<div style="position: absolute; left: 24px; right: 24px; top: 128px;">
  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 27px; line-height: 1.05; letter-spacing: -0.6px; color: #FFFAF1;">Digite o ISBN<span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 31px; color: #FED170;"> do verso.</span></h1>
  <p style="margin: 6px 0 0; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #CFC6B8;">Fica embaixo do código de barras ou na ficha catalográfica, nas primeiras páginas.</p>
</div>

<!-- The label: an ISBN sticker that prints its bars as the person types -->
<div style="position: absolute; left: 22px; right: 22px; top: 226px; display: flex; flex-direction: column;">
<div style="position: relative; transform: rotate(-1.5deg);">
  <span aria-hidden="true" style="position: absolute; left: -14px; top: -6px; width: 74px; height: 22px; transform: rotate(-24deg); background: repeating-linear-gradient(90deg, #FED170 0 7px, #F6C24A 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2;"></span>
  <span aria-hidden="true" style="position: absolute; left: 268px; top: -5px; width: 74px; height: 22px; transform: rotate(21deg); background: repeating-linear-gradient(90deg, #FFC1C6 0 7px, #F8AEB5 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2;"></span>
  <section role="group" aria-label="ISBN digitado: 85-08-06294, 9 de 10 dígitos. Falta o dígito final." style="position: relative; padding: 16px 16px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; display: flex; flex-direction: column;">
    <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
      <span style="height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; display: flex; align-items: center; gap: 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 4.5h10a3 3 0 0 1 3 3V20H8a3 3 0 0 1-3-3z"></path><path d="M5 17a3 3 0 0 1 3-3h10"></path></svg>ISBN-10 · edição antiga</span>
      <span style="font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums; white-space: nowrap;">9 <span style="font-weight: 600; color: #5B544B;">de 10</span></span>
    </div>
    <div style="margin-top: 14px; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 1; letter-spacing: 0.5px; font-variant-numeric: tabular-nums; white-space: nowrap;"><span style="color: #1A1714;">85<span style="color: #A79C8B;">-</span>08<span style="color: #A79C8B;">-</span>06294</span><span style="color: #A79C8B;">-</span><span aria-hidden="true" style="position: relative; display: inline-flex; align-items: center; justify-content: center; width: 30px; height: 38px; margin-left: 2px; border-radius: 9px; border: 1.6px dashed #1A1714; background: #FFF3CF; box-sizing: border-box; vertical-align: middle;"><span style="width: 2.5px; height: 24px; border-radius: 2px; background: #FF552E;"></span></span></div>
    <p style="margin: 9px 0 0; font-size: 13px; font-weight: 600; line-height: 1.35; color: #5B544B; white-space: nowrap;">Falta o dígito final: um número ou <strong style="padding: 0 5px; border-radius: 5px; background: #FED170; border: 1px solid #1A1714; color: #1A1714; font-weight: 800;">X</strong>.</p>
    <div style="margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; flex-direction: column; align-items: center;">
      <svg aria-hidden="true" width="267" height="74" viewBox="0 0 267.0 74" font-family="Figtree, sans-serif" style="display: block; overflow: visible;"><defs><pattern id="hatch69" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(45)"><rect width="5" height="5" fill="#F7F0E3"></rect><rect width="2" height="5" fill="#E2D7C3"></rect></pattern></defs><rect x="16.0" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="21.2" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="26.4" y="0" width="7.8" height="50" fill="#552CB7"></rect><rect x="36.8" y="0" width="5.2" height="50" fill="#552CB7"></rect><rect x="49.8" y="0" width="2.6" height="50" fill="#552CB7"></rect><rect x="57.6" y="0" width="2.6" height="50" fill="#552CB7"></rect><rect x="68.0" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="75.8" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="81.0" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="94.0" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="99.2" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="107.0" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="117.4" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="125.2" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="135.6" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="140.8" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="146.0" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="159.0" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="164.2" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="169.4" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="182.4" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="190.2" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="200.6" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="211.0" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="218.8" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="224.0" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="255.2" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="260.4" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="237.5" y="0" width="17.2" height="50" rx="2" fill="url(#hatch69)" stroke="#8B8173" stroke-width="1.1" stroke-dasharray="3 2.5"></rect><text x="6" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#552CB7">9</text><text x="32.9" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#552CB7">7</text><text x="51.1" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#552CB7">8</text><text x="69.3" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">8</text><text x="87.5" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">5</text><text x="105.7" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">0</text><text x="123.9" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">8</text><text x="155.1" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">0</text><text x="173.3" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">6</text><text x="191.5" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">2</text><text x="209.7" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">9</text><text x="227.9" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">4</text><text x="246.1" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#8B8173">?</text><path d="M2.0 67 v4 H60.2 v-4" fill="none" stroke="#552CB7" stroke-width="1.3" stroke-linecap="round"></path></svg>
      <span style="align-self: flex-start; margin: 3px 0 0 2px; font-size: 11px; font-weight: 800; color: #552CB7; white-space: nowrap;">978 · o app completa sozinho</span>
    </div>
  </section>
</div>
  <div style="margin-top: 16px; display: flex; flex-direction: column; align-items: center; gap: 5px; text-align: center;">
    <p style="margin: 0; font-size: 13px; font-weight: 600; color: #CFC6B8;">Completou, a gente confere e já busca.</p>
    <p style="margin: 0; font-size: 13.5px; font-weight: 500; color: #CFC6B8;">Livro sem ISBN? <a href="#" style="font-weight: 800; color: #FFFAF1; text-decoration: underline; text-underline-offset: 3px;">Buscar pelo título</a></p>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `sc69.backdrop` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc69.backdrop` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background-image: radial-gradient(rgba(255,250,241,0.09) 1px, transparent 1.4px); background-size: 18px 18px` |  |

Seção `sc69.heading` — retângulo absoluto no canvas 390×844: **x=24, y=128, w=342, h=76.35**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `sc69.heading` | box | 0 | 0 | 342 | 76.35 | `position: absolute; left: 24px; right: 24px; top: 128px` |  |
| 3 | `sc69.heading.title` | text | 0 | 0 | 342 | 32.55 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 27px; line-height: 1.05; letter-spacing: -0.6px; color: #FFFAF1` | Bricolage (opsz 27) 27/28.35px peso 800 ls -0.6px #FFFAF1 |
| 4 | `sc69.heading.title.serif` ±1 | inline | 161.1 | -3.88 | 95.09 | 40.3 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 31px; color: #FED170` | Instrument Serif itálico 31/32.55px peso 400 ls -0.6px #FED170 |
| 5 | `sc69.heading.body` | text | 0 | 38.55 | 342 | 37.8 | `margin: 6px 0 0; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #CFC6B8` | Figtree 13.5/18.9px peso 600 ls normal #CFC6B8 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc69.heading.title` *(composto)* | 1 | Digite o ISBN do verso. | 26.81 | 0 | 256.19 | 256.19 |
| `sc69.heading.body` | 1 | Fica embaixo do código de barras ou na ficha | 52.72 | 0 | 276.02 | 276.02 |
| `sc69.heading.body` | 2 | catalográfica, nas primeiras páginas. | 71.62 | 0 | 222.42 | 222.42 |

Seção `sc69.sticker` — retângulo absoluto no canvas 390×844: **x=22, y=226, w=346, h=308.06**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `sc69.sticker` | box | 0 | 0 | 346 | 308.06 | `position: absolute; left: 22px; right: 22px; top: 226px; display: flex; flex-direction: column` |  |
| 7 | `sc69.sticker.tilt` | box | 0 | 0 | 346 | 255.25 | `position: relative; transform: rotate(-1.5deg)` |  |
| 8 | `sc69.sticker.tapeLeft` | box | -14 | -6 | 77 | 22 | `position: absolute; left: -14px; top: -6px; width: 74px; height: 22px; transform: rotate(-24deg); background: repeating-linear-gradient(90deg, #FED170 0 7px, #F6C24A 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2` |  |
| 9 | `sc69.sticker.tapeRight` | box | 268 | -5 | 77 | 22 | `position: absolute; left: 268px; top: -5px; width: 74px; height: 22px; transform: rotate(21deg); background: repeating-linear-gradient(90deg, #FFC1C6 0 7px, #F8AEB5 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2` |  |
| 10 | `sc69.sticker.card` | box | 0 | 0 | 346 | 255.25 | `position: relative; padding: 16px 16px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; display: flex; flex-direction: column` |  |
| 11 | `sc69.sticker.card.top` | box | 17.5 | 17.5 | 311 | 26 | `display: flex; align-items: center; justify-content: space-between; gap: 8px` |  |
| 12 | `sc69.sticker.card.kind` ±1 | box+text | 17.5 | 17.5 | 169.84 | 26 | `height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; display: flex; align-items: center; gap: 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; white-space: nowrap` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 13 | `sc69.sticker.card.kind.icon` | icon | 26.7 | 23.5 | 14 | 14 | `—` |  |
| 14 | `sc69.sticker.card.count` ±1 | text | 282.86 | 22.7 | 45.64 | 15.6 | `font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums; white-space: nowrap` | Figtree 13/normal peso 800 ls normal #1A1714 tnum |
| 15 | `sc69.sticker.card.count.total` ±1 | inline | 294.17 | 22.7 | 34.33 | 15.6 | `font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B tnum |
| 16 | `sc69.sticker.card.digits` | box | 17.5 | 57.5 | 311 | 38 | `margin-top: 14px; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 1; letter-spacing: 0.5px; font-variant-numeric: tabular-nums; white-space: nowrap` |  |
| 17 | `sc69.sticker.card.digits.number` ±1 | text | 17.5 | 60.5 | 205.82 | 32 | `color: #1A1714` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #1A1714 tnum |
| 18 | `sc69.sticker.card.digits.number.dash1` ±1 | inline | 58.05 | 57.3 | 11.67 | 38.4 | `color: #A79C8B` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #A79C8B tnum |
| 19 | `sc69.sticker.card.digits.number.dash2` ±1 | inline | 110.27 | 57.3 | 11.67 | 38.4 | `color: #A79C8B` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #A79C8B tnum |
| 20 | `sc69.sticker.card.digits.dash3` ±1 | text | 223.32 | 60.5 | 11.67 | 32 | `color: #A79C8B` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #A79C8B tnum |
| 21 | `sc69.sticker.card.digits.slot` ±1 | box | 236.99 | 57.5 | 30 | 38 | `position: relative; display: inline-flex; align-items: center; justify-content: center; width: 30px; height: 38px; margin-left: 2px; border-radius: 9px; border: 1.6px dashed #1A1714; background: #FFF3CF; box-sizing: border-box; vertical-align: middle` |  |
| 22 | `sc69.sticker.card.digits.slot.caret` ±1 | box | 250.74 | 64.5 | 2.5 | 24 | `width: 2.5px; height: 24px; border-radius: 2px; background: #FF552E` |  |
| 23 | `sc69.sticker.card.hint` | text | 17.5 | 104.5 | 311 | 17.55 | `margin: 9px 0 0; font-size: 13px; font-weight: 600; line-height: 1.35; color: #5B544B; white-space: nowrap` | Figtree 13/17.55px peso 600 ls normal #5B544B |
| 24 | `sc69.sticker.card.hint.key` ±1 | inline | 218.17 | 104.47 | 21.22 | 17.6 | `padding: 0 5px; border-radius: 5px; background: #FED170; border: 1px solid #1A1714; color: #1A1714; font-weight: 800` | Figtree 13/17.55px peso 800 ls normal #1A1714 |
| 25 | `sc69.sticker.card.barcode` | box | 17.5 | 136.05 | 311 | 103.7 | `margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; flex-direction: column; align-items: center` |  |
| 26 | `sc69.sticker.card.barcode.bars` | icon | 39.5 | 149.55 | 267 | 74 | `display: block; overflow: visible` |  |
| 27 | `sc69.sticker.card.barcode.prefix` ±1 | text | 19.5 | 226.55 | 147.84 | 13.2 | `align-self: flex-start; margin: 3px 0 0 2px; font-size: 11px; font-weight: 800; color: #552CB7; white-space: nowrap` | Figtree 11/normal peso 800 ls normal #552CB7 |
| 28 | `sc69.sticker.notes` | box | 0 | 271.25 | 346 | 36.81 | `margin-top: 16px; display: flex; flex-direction: column; align-items: center; gap: 5px; text-align: center` |  |
| 29 | `sc69.sticker.notes.line` ±1 | text | 57.61 | 271.25 | 230.77 | 15.6 | `margin: 0; font-size: 13px; font-weight: 600; color: #CFC6B8` | Figtree 13/normal peso 600 ls normal #CFC6B8 |
| 30 | `sc69.sticker.notes.noIsbn` ±1 | text | 66.72 | 291.85 | 212.57 | 16.21 | `margin: 0; font-size: 13.5px; font-weight: 500; color: #CFC6B8` | Figtree 13.5/normal peso 500 ls normal #CFC6B8 |
| 31 | `sc69.sticker.notes.noIsbn.link` ±1 | inline | 169.38 | 291.85 | 109.9 | 16.21 | `font-weight: 800; color: #FFFAF1; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #FFFAF1 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `sc69.sticker.tilt`: caixa visual com `transform: rotate(-1.5deg)` = x -3.28, y -4.49, w 352.56, h 264.22 (relativa à seção).
- `sc69.sticker.tapeLeft`: caixa visual com `transform: rotate(-24deg)` = x -18.14, y -17.57, w 78.97, h 53.01 (relativa à seção).
- `sc69.sticker.tapeRight`: caixa visual com `transform: rotate(21deg)` = x 263.31, y -20.67, w 79.93, h 46.44 (relativa à seção).
- `sc69.sticker.card`: caixa visual deslocada pelo transform de um ancestral = x -3.28, y -4.49, w 352.56, h 264.22 (relativa à seção).
- `sc69.sticker.card.top`: caixa visual deslocada pelo transform de um ancestral = x 14.67, y 13.47, w 311.57, h 34.13 (relativa à seção).
- `sc69.sticker.card.kind`: caixa visual deslocada pelo transform de um ancestral = x 14.67, y 17.16, w 170.47, h 30.44 (relativa à seção).
- `sc69.sticker.card.kind.icon`: caixa visual deslocada pelo transform de um ancestral = x 24.02, y 27, w 14.36, h 14.36 (relativa à seção).
- `sc69.sticker.card.count`: caixa visual deslocada pelo transform de um ancestral = x 280.07, y 18.66, w 46.04, h 16.79 (relativa à seção).
- `sc69.sticker.card.count.total`: caixa visual deslocada pelo transform de um ancestral = x 291.38, y 18.66, w 34.73, h 16.49 (relativa à seção).
- `sc69.sticker.card.digits`: caixa visual deslocada pelo transform de um ancestral = x 15.72, y 53.45, w 311.89, h 46.13 (relativa à seção).
- `sc69.sticker.card.digits.number`: caixa visual deslocada pelo transform de um ancestral = x 15.8, y 59.21, w 206.59, h 37.38 (relativa à seção).
- `sc69.sticker.card.digits.number.dash1`: caixa visual deslocada pelo transform de um ancestral = x 56.25, y 60.03, w 12.67, h 38.69 (relativa à seção).
- `sc69.sticker.card.digits.number.dash2`: caixa visual deslocada pelo transform de um ancestral = x 108.45, y 58.66, w 12.67, h 38.69 (relativa à seção).
- `sc69.sticker.card.digits.dash3`: caixa visual deslocada pelo transform de um ancestral = x 221.55, y 58.9, w 12.5, h 32.29 (relativa à seção).
- `sc69.sticker.card.digits.slot`: caixa visual deslocada pelo transform de um ancestral = x 235.13, y 55.06, w 30.98, h 38.77 (relativa à seção).
- `sc69.sticker.card.digits.slot.caret`: caixa visual deslocada pelo transform de um ancestral = x 249.06, y 62.42, w 3.13, h 24.06 (relativa à seção).
- `sc69.sticker.card.hint`: caixa visual deslocada pelo transform de um ancestral = x 16.95, y 100.44, w 311.35, h 25.68 (relativa à seção).
- `sc69.sticker.card.hint.key`: caixa visual deslocada pelo transform de um ancestral = x 217.54, y 102.74, w 21.67, h 18.15 (relativa à seção).
- `sc69.sticker.card.barcode`: caixa visual deslocada pelo transform de um ancestral = x 17.77, y 131.98, w 313.61, h 111.81 (relativa à seção).
- `sc69.sticker.card.barcode.bars`: caixa visual deslocada pelo transform de um ancestral = x 40.12, y 146.05, w 268.85, h 80.96 (relativa à seção).
- `sc69.sticker.card.barcode.prefix`: caixa visual deslocada pelo transform de um ancestral = x 22.14, y 226.66, w 148.13, h 17.07 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc69.sticker.card.kind` | 1 | ISBN-10 · edição antiga | 34.7 | 46.7 | 176.14 | 129.44 |
| `sc69.sticker.card.count` *(composto)* | 1 | 9 de 10 | 35.05 | 282.86 | 328.5 | 45.64 |
| `sc69.sticker.card.digits.number` *(composto)* | 1 | 85-08-06294 | 87.06 | 17.5 | 223.32 | 205.82 |
| `sc69.sticker.card.digits.dash3` | 1 | - | 87.06 | 223.32 | 234.99 | 11.67 |
| `sc69.sticker.card.hint` *(composto)* | 1 | Falta o dígito final: um número ou X. | 117.82 | 17.5 | 242.4 | 224.9 |
| `sc69.sticker.card.barcode.prefix` | 1 | 978 · o app completa sozinho | 237 | 19.5 | 167.34 | 147.84 |
| `sc69.sticker.notes.line` | 1 | Completou, a gente confere e já busca. | 283.6 | 57.61 | 288.38 | 230.77 |
| `sc69.sticker.notes.noIsbn` *(composto)* | 1 | Livro sem ISBN? Buscar pelo título | 304.68 | 66.72 | 279.29 | 212.57 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Fundo: pontos `radial-gradient(rgba(255,250,241,.09) 1px, transparent 1.4px)` a cada 18 sobre o escuro do Scanner.
2. Título em `left/right 24 · top 128`: "Digite o ISBN" Bricolage 27/800 `lh 1,05` ls −0,6 `#FFFAF1` + " do verso." Instrument Serif itálico 31 `#FED170`; o texto 13,5/600 `lh 1,4` `#CFC6B8`, 6 abaixo.
3. Etiqueta em `left/right 22 · top 226`, girada −1,5°: padding 16/16/14, raio 22, `#FFFAF1`, borda 1,5, sombra 5/5; duas fitas 74 × 22 (listras de 7/3 amarelas e rosa, bordas tracejadas a 25 %) giradas −24° e 21°, por cima (`z-index 2`).
4. Dentro: o chip "ISBN-10 · edição antiga" (26, `#F7F0E3`, borda 1,2, 12/800) e "9 de 10" 13/800 `tnum`; o número Bricolage 32/800 `lh 1` ls 0,5 `tnum` com os hífens `#A79C8B` e a casa do dígito que falta (30 × 38, raio 9, borda 1,6 `dashed`, `#FFF3CF`, o cursor coral 2,5 × 24); "Falta o dígito final: um número ou X." 13/600 com o X em destaque (`#FED170`, borda 1, raio 5).
5. Barras, 14 abaixo da linha tracejada: SVG 267 × 74 — o 978 em roxo `#552CB7` (o app completa), os dígitos digitados em preto, a casa que falta hachurada e tracejada com o "?" `#8B8173`, e "978 · o app completa sozinho" 11/800 roxo.
6. Embaixo, 16 abaixo da etiqueta: "Completou, a gente confere e já busca." 13/600 e "Livro sem ISBN? **Buscar pelo título**" 13,5/500, ambos `#CFC6B8` (o link `#FFFAF1`).
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As barras da prancha são o estado da fixture: no app, `CustomPainter` com os 95 módulos do EAN-13 e quantos já foram impressos, e os dígitos em `AppText` (o mapa de widgets).
- As fitas passam da etiqueta e, a 360, a da direita sai do quadro (abaixo): `clipBehavior: Clip.none` e decidir na T15 se acompanham a largura.
- A semântica da etiqueta é um texto só ("ISBN digitado: 85-08-06294, 9 de 10 dígitos. Falta o dígito final."), anunciado a cada mudança — não os pedaços desenhados.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_069_scanner_digitar_isbn_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_069_scanner_digitar_isbn_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `sc69.sticker.tapeRight` | sai do quadro (x) | 7 | 0 | **sim** | sim |  |
| 360 | `sc69.sticker.tapeRight` | passa do pai (x) | 29 | 0 | **sim** | sim | pai `sc69.sticker.tilt` (vaza) |

## Diferenças em relação à prancha 03 (seções reutilizadas: controls)

Estas seções são as mesmas widgets da 03 (fases L03_1_camera, L03_2_controles, L03_3_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `sc69.controls.mode` | retângulo ['91.92', '58', '206.15', '48'] → ['91.31', '58', '207.38', '48'] |
| `sc69.controls.mode.code` | retângulo ['96.42', '62.5', '101.25', '39'] → ['95.81', '62.5', '97.51', '39']; bg: "#B6ACE4" → null; border: "1.5px solid #1A1714" → null; fonte weightCss: 800 → 600; weightRendered: 800 → 600 |
| `sc69.controls.mode.code.icon` | retângulo ['109.92', '73', '18', '18'] → ['107.81', '73', '18', '18'] |
| `sc69.controls.mode.type` | retângulo ['199.67', '62.5', '93.9', '39'] → ['195.32', '62.5', '98.87', '39']; bg: null → "#B6ACE4"; border: null → "1.5px solid #1A1714"; fonte weightCss: 600 → 800; weightRendered: 600 → 800 |
| `sc69.controls.mode.type.icon` | retângulo ['211.67', '73', '18', '18'] → ['208.82', '73', '18', '18'] |

Só na base: `controls.torch`, `controls.torch.icon`.

Só nesta prancha: `controls.help`, `controls.help.icon`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc69.backdrop` |  |  | aria-hidden=true |
| `sc69.sticker.tapeLeft` |  |  | aria-hidden=true |
| `sc69.sticker.tapeRight` |  |  | aria-hidden=true |
| `sc69.sticker.card` | group | ISBN digitado: 85-08-06294, 9 de 10 dígitos. Falta o dígito final. |  |
| `sc69.sticker.card.kind.icon` |  |  | aria-hidden=true |
| `sc69.sticker.card.digits.slot` |  |  | aria-hidden=true |
| `sc69.sticker.card.barcode.bars` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc69.heading.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `sc69.sticker.tapeLeft` | HatchPainter (hachura 135°) dentro do contorno | Transform: rotate(-24deg) |
| `sc69.sticker.tapeRight` | HatchPainter (hachura 135°) dentro do contorno | Transform: rotate(21deg) |
| `sc69.sticker.card` | NeoBox |  |
| `sc69.sticker.card.kind` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc69.sticker.card.kind.icon` | AppSvg(AppIconsScanner.bookSimple, size: 14) |  |
| `sc69.sticker.card.count.total` | TextSpan dentro do AppText.rich do pai |  |
| `sc69.sticker.card.digits.number.dash1` | TextSpan dentro do AppText.rich do pai |  |
| `sc69.sticker.card.digits.number.dash2` | TextSpan dentro do AppText.rich do pai |  |
| `sc69.sticker.card.digits.slot` | NeoBox |  |
| `sc69.sticker.card.digits.slot.caret` | NeoBox |  |
| `sc69.sticker.card.hint.key` | TextSpan dentro do AppText.rich do pai |  |
| `sc69.sticker.card.barcode` | NeoBox |  |
| `sc69.sticker.card.barcode.bars` | CustomPainter (codigo_barras_isbn_digitado) | o código de barras do ISBN digitado (os 13 dígitos em `<text>` Figtree 700 12, o "?" dos que faltam e as barras tracejadas da parte por digitar): no app, desenhado a partir dos dígitos que a pessoa digita (barras EAN-13 por CustomPainter, dígitos em AppText); o SVG é a referência do estado da prancha. desenha fora da própria caixa (0,55 px acima da caixa; o `<svg>` tem overflow: visible): no app, sem recorte (o SvgPicture com clipBehavior: Clip.none, ou o pintor sem clip) — com o recorte padrão, o que passa some. |
| `sc69.sticker.notes.noIsbn.link` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Um `TextField` invisível (opacidade 0) com foco próprio; a etiqueta é desenhada do controller (teclado, colar, desfazer e leitor de tela funcionam sozinhos). Cada dígito novo imprime as suas barras (7 módulos, 120 ms, `TweenAnimationBuilder`); os hífens entram pela tabela oficial de faixas (nota do design).
- Começa com 978/979 → ISBN-13 (conta até 13); outro começo → ISBN-10 (conta até 10, X só na 10ª). Ao completar, confere o dígito: certo → cantos amarelos, vibração, "Buscando…" e a folha da 03, 40 ou 42; errado → a 69b. Antes de completar, nunca mostra erro.
- "?" (no lugar da lanterna) → a folha curta de onde fica o ISBN: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T15 (ROTEIRO §2b).
- Buscar pelo título → a Busca (28).

## Dados

- Os dígitos digitados (guardados até fechar o Scanner); o ISBN-10 vira 978 + 9 dígitos + novo dígito, e os dois ficam salvos no livro (nota do design). A conferência usa `features/catalog/domain/isbn.dart`.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L69.1** Fundo e título da aba Digitar
- **L69.2** Etiqueta: chip, contagem e número com hífens
- **L69.3** Barras impressas por dígito (CustomPainter)
- **L69.4** Conferência e busca ao completar
- **L69.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc69.backdrop', 'sc69.heading', 'sc69.sticker'), todos os ids de `kRef69.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/069_scanner_digitar_isbn_390x844@3x.png` no recorte da fase (y 116.12–542.06) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef69w360` e `kRef69w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L69.1 Fundo e título da aba Digitar
- [ ] L69.2 Etiqueta: chip, contagem e número com hífens
- [ ] L69.3 Barras impressas por dígito (CustomPainter)
- [ ] L69.4 Conferência e busca ao completar
- [ ] L69.5 Verificação + relatório
- [ ] Geometria 25/25 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
