# FASE L69b — Digitar o ISBN (não confere) — a etiqueta tremida, o X digitado e o aviso

> Tela 69b · prancha `069b_scanner_isbn_nao_confere` (69b · Scanner — ISBN não confere, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L69b_nao_confere@3x.png` · `docs/design/medicao/projeto/png/redline/L69b_nao_confere_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/069b_scanner_isbn_nao_confere_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_069b_scanner_isbn_nao_confere.json` · `test/reference/projeto/reference_layout_069b_scanner_isbn_nao_confere.dart` (`kRef69b`).
> Arquivos sugeridos: `lib/features/scanner/presentation/isbn_typing/isbn_sticker.dart`, `lib/features/scanner/presentation/isbn_typing/isbn_keys_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

ISBN não confere (69b): a etiqueta treme uma vez e fica girada −3°, com as marcas rosa do tremor, o X digitado na casa rosa, o aviso "Esse número não confere." e, embaixo, "O erro mais comum: dois vizinhos trocados." O X da barra apaga e Colar vira "Apagar tudo".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- The label after one shake: the number is complete but the check character doesn't match -->
<div style="position: absolute; left: 22px; right: 22px; top: 226px; display: flex; flex-direction: column;">
<div style="position: relative; transform: rotate(-3deg);">
  <svg aria-hidden="true" width="14" height="60" viewBox="0 0 14 60" fill="none" stroke="#FFC1C6" stroke-width="2.4" stroke-linecap="round" style="position: absolute; left: -18px; top: 96px;"><path d="M11 6q-7 9 0 18M5 2q-6 13 0 26M11 34q-7 9 0 18"></path></svg>
  <svg aria-hidden="true" width="14" height="60" viewBox="0 0 14 60" fill="none" stroke="#FFC1C6" stroke-width="2.4" stroke-linecap="round" style="position: absolute; right: -18px; top: 120px;"><path d="M3 6q7 9 0 18M9 2q6 13 0 26M3 34q7 9 0 18"></path></svg>
  <span aria-hidden="true" style="position: absolute; left: -14px; top: -6px; width: 74px; height: 22px; transform: rotate(-24deg); background: repeating-linear-gradient(90deg, #FED170 0 7px, #F6C24A 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2;"></span>
  <span aria-hidden="true" style="position: absolute; left: 268px; top: -5px; width: 74px; height: 22px; transform: rotate(21deg); background: repeating-linear-gradient(90deg, #FFC1C6 0 7px, #F8AEB5 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2;"></span>
  <section role="group" aria-label="ISBN digitado: 85-08-06924-X. Esse número não confere." style="position: relative; padding: 16px 16px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; display: flex; flex-direction: column;">
    <div style="display: flex; align-items: center; justify-content: space-between; gap: 8px;">
      <span style="height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; display: flex; align-items: center; gap: 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; white-space: nowrap;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 4.5h10a3 3 0 0 1 3 3V20H8a3 3 0 0 1-3-3z"></path><path d="M5 17a3 3 0 0 1 3-3h10"></path></svg>ISBN-10 · edição antiga</span>
      <span style="font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums; white-space: nowrap;">10 <span style="font-weight: 600; color: #5B544B;">de 10</span></span>
    </div>
    <div style="margin-top: 14px; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 1; letter-spacing: 0.5px; font-variant-numeric: tabular-nums; white-space: nowrap;"><span style="color: #1A1714;">85<span style="color: #A79C8B;">-</span>08<span style="color: #A79C8B;">-</span>06924</span><span style="color: #A79C8B;">-</span><span aria-hidden="true" style="position: relative; display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 40px; margin-left: 2px; border-radius: 9px; border: 1.6px solid #1A1714; background: #FFC1C6; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; vertical-align: middle;">X</span></div>
    <p role="alert" style="margin: 10px 0 0; padding: 6px 10px; border-radius: 12px; background: #FFE9E4; border: 1.2px solid #1A1714; display: flex; gap: 8px; align-items: center; font-size: 13.5px; font-weight: 800; line-height: 1.35; color: #1A1714;"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8.5"></circle><path d="M12 7.5v5.5M12 16.5h.01"></path></svg><span style="white-space: nowrap;">Esse número não confere.</span></p>
    <div style="margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; flex-direction: column; align-items: center;">
      <svg aria-hidden="true" width="267" height="74" viewBox="0 0 267.0 74" font-family="Figtree, sans-serif" style="display: block; overflow: visible;"><defs><pattern id="hatch69b" width="5" height="5" patternUnits="userSpaceOnUse" patternTransform="rotate(45)"><rect width="5" height="5" fill="#FFE1E4"></rect><rect width="2" height="5" fill="#FFC1C6"></rect></pattern></defs><rect x="16.0" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="21.2" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="26.4" y="0" width="7.8" height="50" fill="#552CB7"></rect><rect x="36.8" y="0" width="5.2" height="50" fill="#552CB7"></rect><rect x="49.8" y="0" width="2.6" height="50" fill="#552CB7"></rect><rect x="57.6" y="0" width="2.6" height="50" fill="#552CB7"></rect><rect x="68.0" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="75.8" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="81.0" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="94.0" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="99.2" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="107.0" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="117.4" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="125.2" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="135.6" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="140.8" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="146.0" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="159.0" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="164.2" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="169.4" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="182.4" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="192.8" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="200.6" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="208.4" y="0" width="5.2" height="50" fill="#1A1714"></rect><rect x="218.8" y="0" width="2.6" height="50" fill="#1A1714"></rect><rect x="224.0" y="0" width="7.8" height="50" fill="#1A1714"></rect><rect x="255.2" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="260.4" y="0" width="2.6" height="57" fill="#1A1714"></rect><rect x="237.5" y="0" width="17.2" height="50" rx="2" fill="url(#hatch69b)" stroke="#1A1714" stroke-width="1.2" stroke-dasharray="3 2.5"></rect><text x="6" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#552CB7">9</text><text x="32.9" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#552CB7">7</text><text x="51.1" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#552CB7">8</text><text x="69.3" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">8</text><text x="87.5" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">5</text><text x="105.7" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">0</text><text x="123.9" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">8</text><text x="155.1" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">0</text><text x="173.3" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">6</text><text x="191.5" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">9</text><text x="209.7" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">2</text><text x="227.9" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#1A1714">4</text><text x="246.1" y="63" text-anchor="middle" font-size="12" font-weight="700" fill="#C2364A">!</text><path d="M2.0 67 v4 H60.2 v-4" fill="none" stroke="#552CB7" stroke-width="1.3" stroke-linecap="round"></path></svg>
    </div>
  </section>
</div>
  <div style="margin-top: 8px; display: flex; flex-direction: column; align-items: center; gap: 4px; text-align: center;">
    <p style="margin: 0; font-size: 13px; font-weight: 600; line-height: 1.4; color: #CFC6B8;">O erro mais comum: dois vizinhos trocados.</p>
    <p style="margin: 0; font-size: 13.5px; font-weight: 500; color: #CFC6B8;">Livro sem ISBN? <a href="#" style="font-weight: 800; color: #FFFAF1; text-decoration: underline; text-underline-offset: 3px;">Buscar pelo título</a></p>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `sc69b.sticker` — retângulo absoluto no canvas 390×844: **x=22, y=226, w=346, h=303.54**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc69b.sticker` | box | 0 | 0 | 346 | 303.54 | `position: absolute; left: 22px; right: 22px; top: 226px; display: flex; flex-direction: column` |  |
| 2 | `sc69b.sticker.tilt` | box | 0 | 0 | 346 | 257.12 | `position: relative; transform: rotate(-3deg)` |  |
| 3 | `sc69b.sticker.shakeLeft` | icon | -18 | 96 | 14 | 60 | `position: absolute; left: -18px; top: 96px` |  |
| 4 | `sc69b.sticker.shakeRight` | icon | 350 | 120 | 14 | 60 | `position: absolute; right: -18px; top: 120px` |  |
| 5 | `sc69b.sticker.tapeLeft` | box | -14 | -6 | 77 | 22 | `position: absolute; left: -14px; top: -6px; width: 74px; height: 22px; transform: rotate(-24deg); background: repeating-linear-gradient(90deg, #FED170 0 7px, #F6C24A 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2` |  |
| 6 | `sc69b.sticker.tapeRight` | box | 268 | -5 | 77 | 22 | `position: absolute; left: 268px; top: -5px; width: 74px; height: 22px; transform: rotate(21deg); background: repeating-linear-gradient(90deg, #FFC1C6 0 7px, #F8AEB5 7px 10px); opacity: 0.92; border-left: 1.5px dashed rgba(26,23,20,0.25); border-right: 1.5px dashed rgba(26,23,20,0.25); z-index: 2` |  |
| 7 | `sc69b.sticker.card` | box | 0 | 0 | 346 | 257.12 | `position: relative; padding: 16px 16px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 5px 5px 0 #1A1714; display: flex; flex-direction: column` |  |
| 8 | `sc69b.sticker.card.top` | box | 17.5 | 17.5 | 311 | 26 | `display: flex; align-items: center; justify-content: space-between; gap: 8px` |  |
| 9 | `sc69b.sticker.card.kind` ±1 | box+text | 17.5 | 17.5 | 169.84 | 26 | `height: 26px; padding: 0 10px 0 8px; box-sizing: border-box; display: flex; align-items: center; gap: 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800; white-space: nowrap` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 10 | `sc69b.sticker.card.kind.icon` | icon | 26.7 | 23.5 | 14 | 14 | `—` |  |
| 11 | `sc69b.sticker.card.count` ±1 | text | 274.59 | 22.7 | 53.91 | 15.6 | `font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums; white-space: nowrap` | Figtree 13/normal peso 800 ls normal #1A1714 tnum |
| 12 | `sc69b.sticker.card.count.total` ±1 | inline | 294.17 | 22.7 | 34.33 | 15.6 | `font-weight: 600; color: #5B544B` | Figtree 13/normal peso 600 ls normal #5B544B tnum |
| 13 | `sc69b.sticker.card.digits` | box | 17.5 | 57.5 | 311 | 40 | `margin-top: 14px; display: flex; align-items: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 32px; line-height: 1; letter-spacing: 0.5px; font-variant-numeric: tabular-nums; white-space: nowrap` |  |
| 14 | `sc69b.sticker.card.digits.number` ±1 | text | 17.5 | 61.5 | 205.82 | 32 | `color: #1A1714` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #1A1714 tnum |
| 15 | `sc69b.sticker.card.digits.number.dash1` ±1 | inline | 58.05 | 58.3 | 11.67 | 38.4 | `color: #A79C8B` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #A79C8B tnum |
| 16 | `sc69b.sticker.card.digits.number.dash2` ±1 | inline | 110.27 | 58.3 | 11.67 | 38.4 | `color: #A79C8B` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #A79C8B tnum |
| 17 | `sc69b.sticker.card.digits.dash3` ±1 | text | 223.32 | 61.5 | 11.67 | 32 | `color: #A79C8B` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #A79C8B tnum |
| 18 | `sc69b.sticker.card.digits.check` ±1 | box+text | 236.99 | 57.5 | 32 | 40 | `position: relative; display: inline-flex; align-items: center; justify-content: center; width: 32px; height: 40px; margin-left: 2px; border-radius: 9px; border: 1.6px solid #1A1714; background: #FFC1C6; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; vertical-align: middle` | Bricolage (opsz 32) 32/32px peso 800 ls 0.5px #1A1714 tnum |
| 19 | `sc69b.sticker.card.alert` | box | 17.5 | 107.5 | 311 | 32.62 | `margin: 10px 0 0; padding: 6px 10px; border-radius: 12px; background: #FFE9E4; border: 1.2px solid #1A1714; display: flex; gap: 8px; align-items: center; font-size: 13.5px; font-weight: 800; line-height: 1.35; color: #1A1714` |  |
| 20 | `sc69b.sticker.card.alert.icon` | icon | 28.7 | 115.31 | 17 | 17 | `—` |  |
| 21 | `sc69b.sticker.card.alert.text` ±1 | text | 53.7 | 114.7 | 161.19 | 18.23 | `white-space: nowrap` | Figtree 13.5/18.225px peso 800 ls normal #1A1714 |
| 22 | `sc69b.sticker.card.barcode` | box | 17.5 | 154.12 | 311 | 87.5 | `margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; flex-direction: column; align-items: center` |  |
| 23 | `sc69b.sticker.card.barcode.bars` | icon | 39.5 | 167.62 | 267 | 74 | `display: block; overflow: visible` |  |
| 24 | `sc69b.sticker.notes` | box | 0 | 265.12 | 346 | 38.41 | `margin-top: 8px; display: flex; flex-direction: column; align-items: center; gap: 4px; text-align: center` |  |
| 25 | `sc69b.sticker.notes.line` ±1 | text | 44.6 | 265.12 | 256.8 | 18.2 | `margin: 0; font-size: 13px; font-weight: 600; line-height: 1.4; color: #CFC6B8` | Figtree 13/18.2px peso 600 ls normal #CFC6B8 |
| 26 | `sc69b.sticker.notes.noIsbn` ±1 | text | 66.72 | 287.33 | 212.57 | 16.21 | `margin: 0; font-size: 13.5px; font-weight: 500; color: #CFC6B8` | Figtree 13.5/normal peso 500 ls normal #CFC6B8 |
| 27 | `sc69b.sticker.notes.noIsbn.link` ±1 | inline | 169.38 | 287.33 | 109.9 | 16.21 | `font-weight: 800; color: #FFFAF1; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #FFFAF1 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `sc69b.sticker.tilt`: caixa visual com `transform: rotate(-3deg)` = x -6.49, y -8.88, w 358.98, h 274.88 (relativa à seção).
- `sc69b.sticker.shakeLeft`: caixa visual deslocada pelo transform de um ancestral = x -19.44, y 105.31, w 17.12, h 60.65 (relativa à seção).
- `sc69b.sticker.shakeRight`: caixa visual deslocada pelo transform de um ancestral = x 349.31, y 110.02, w 17.12, h 60.65 (relativa à seção).
- `sc69b.sticker.tapeLeft`: caixa visual com `transform: rotate(-24deg)` = x -21.06, y -14.34, w 78.59, h 54.56 (relativa à seção).
- `sc69b.sticker.tapeRight`: caixa visual com `transform: rotate(21deg)` = x 259.89, y -23.18, w 80.03, h 44.72 (relativa à seção).
- `sc69b.sticker.card`: caixa visual deslocada pelo transform de um ancestral = x -6.49, y -8.88, w 358.98, h 274.88 (relativa à seção).
- `sc69b.sticker.card.top`: caixa visual deslocada pelo transform de um ancestral = x 11.9, y 9.51, w 311.94, h 42.24 (relativa à seção).
- `sc69b.sticker.card.kind`: caixa visual deslocada pelo transform de um ancestral = x 11.9, y 16.9, w 170.97, h 34.85 (relativa à seção).
- `sc69b.sticker.card.kind.icon`: caixa visual deslocada pelo transform de um ancestral = x 21.4, y 30.57, w 14.71, h 14.71 (relativa à seção).
- `sc69b.sticker.card.count`: caixa visual deslocada pelo transform de um ancestral = x 268.91, y 14.71, w 54.65, h 18.4 (relativa à seção).
- `sc69b.sticker.card.count.total`: caixa visual deslocada pelo transform de um ancestral = x 288.46, y 14.71, w 35.1, h 17.38 (relativa à seção).
- `sc69b.sticker.card.digits`: caixa visual deslocada pelo transform de um ancestral = x 13.99, y 49.46, w 312.67, h 56.22 (relativa à seção).
- `sc69b.sticker.card.digits.number`: caixa visual deslocada pelo transform de um ancestral = x 14.2, y 58.96, w 207.21, h 42.73 (relativa à seção).
- `sc69b.sticker.card.digits.number.dash1`: caixa visual deslocada pelo transform de um ancestral = x 54.53, y 63.8, w 13.66, h 38.96 (relativa à seção).
- `sc69b.sticker.card.digits.number.dash2`: caixa visual deslocada pelo transform de um ancestral = x 106.68, y 61.07, w 13.66, h 38.96 (relativa à seção).
- `sc69b.sticker.card.digits.dash3`: caixa visual deslocada pelo transform de um ancestral = x 219.74, y 58.35, w 13.33, h 32.57 (relativa à seção).
- `sc69b.sticker.card.digits.check`: caixa visual deslocada pelo transform de um ancestral = x 233.18, y 52.57, w 34.05, h 41.62 (relativa à seção).
- `sc69b.sticker.card.alert`: caixa visual deslocada pelo transform de um ancestral = x 16.61, y 99.39, w 312.28, h 48.86 (relativa à seção).
- `sc69b.sticker.card.alert.icon`: caixa visual deslocada pelo transform de um ancestral = x 28.2, y 121.99, w 17.87, h 17.87 (relativa à seção).
- `sc69b.sticker.card.alert.text`: caixa visual deslocada pelo transform de um ancestral = x 53.14, y 112.53, w 161.93, h 26.64 (relativa à seção).
- `sc69b.sticker.card.barcode`: caixa visual deslocada pelo transform de um ancestral = x 19.05, y 145.95, w 315.15, h 103.66 (relativa à seção).
- `sc69b.sticker.card.barcode.bars`: caixa visual deslocada pelo transform de um ancestral = x 41.73, y 160.58, w 270.51, h 87.87 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc69b.sticker.card.kind` | 1 | ISBN-10 · edição antiga | 34.7 | 46.7 | 176.14 | 129.44 |
| `sc69b.sticker.card.count` *(composto)* | 1 | 10 de 10 | 35.05 | 274.59 | 328.5 | 53.91 |
| `sc69b.sticker.card.digits.number` *(composto)* | 1 | 85-08-06924 | 88.06 | 17.5 | 223.32 | 205.82 |
| `sc69b.sticker.card.digits.dash3` | 1 | - | 88.06 | 223.32 | 234.99 | 11.67 |
| `sc69b.sticker.card.digits.check` | 1 | X | 88.06 | 241.57 | 264.41 | 22.84 |
| `sc69b.sticker.card.alert.text` | 1 | Esse número não confere. | 128.53 | 53.7 | 214.9 | 161.2 |
| `sc69b.sticker.notes.line` | 1 | O erro mais comum: dois vizinhos trocados. | 278.77 | 44.6 | 301.4 | 256.8 |
| `sc69b.sticker.notes.noIsbn` *(composto)* | 1 | Livro sem ISBN? Buscar pelo título | 300.15 | 66.72 | 279.29 | 212.57 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A mesma etiqueta da 69 girada −3° (não −1,5°), com duas marcas de tremor (SVG 14 × 60, traço rosa 2,4) dos dois lados, `left −18 · top 96` e `right −18 · top 120`.
2. "10 de 10"; o número 85-08-06924 com o X numa casa de 32 × 40 (raio 9, borda 1,6 contínua, `#FFC1C6`, sombra 2/2).
3. Aviso, 10 abaixo (`role=alert`): padding 6/10, raio 12, `#FFE9E4`, borda 1,2, ícone 17 + "Esse número não confere." 13,5/800 `nowrap`.
4. Barras: a hachura rosa (`#FFE1E4`/`#FFC1C6`) na casa final, o contorno tracejado preto e o "!" `#C2364A` no lugar do "?"; o 9 e o 2 trocados nos dígitos.
5. Na barra: o X em `#F7F0E3` a 0,4 sem sombra; "Apagar tudo" no lugar de "Colar".
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- As marcas do tremor e as fitas passam da etiqueta (0,6 acima, no catálogo): `Clip.none`.
- O aviso faz a etiqueta crescer: o texto de baixo começa 8 abaixo (não 16) — a coluna inteira muda.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_069b_scanner_isbn_nao_confere_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_069b_scanner_isbn_nao_confere_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `sc69b.sticker.tapeRight` | sai do quadro (x) | 7 | 0 | **sim** | sim |  |
| 360 | `sc69b.sticker.tapeRight` | passa do pai (x) | 29 | 0 | **sim** | sim | pai `sc69b.sticker.tilt` (vaza) |

## Diferenças em relação à prancha 69 (seções reutilizadas: backdrop, controls, heading, toolbar, keypad)

Estas seções são as mesmas widgets da 69 (fases L69_1_titulo_e_etiqueta, L69_2_teclado); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `sc69b.toolbar.x` | bg: "#FED170" → "#F7F0E3"; opacity: null → "0.4"; shadow: "#1A1714 2px 2px 0px 0px" → null |
| `sc69b.toolbar.spacer` | retângulo ['199.65', '566.75', '126.35', '0'] → ['246.14', '566.75', '79.86', '0'] |

Só na base: `toolbar.paste`, `toolbar.paste.icon`.

Só nesta prancha: `toolbar.clearAll`, `toolbar.clearAll.icon`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc69b.sticker.shakeLeft` |  |  | aria-hidden=true |
| `sc69b.sticker.shakeRight` |  |  | aria-hidden=true |
| `sc69b.sticker.tapeLeft` |  |  | aria-hidden=true |
| `sc69b.sticker.tapeRight` |  |  | aria-hidden=true |
| `sc69b.sticker.card` | group | ISBN digitado: 85-08-06924-X. Esse número não confere. |  |
| `sc69b.sticker.card.kind.icon` |  |  | aria-hidden=true |
| `sc69b.sticker.card.digits.check` |  |  | aria-hidden=true |
| `sc69b.sticker.card.alert` | alert |  |  |
| `sc69b.sticker.card.alert.icon` |  |  | aria-hidden=true |
| `sc69b.sticker.card.barcode.bars` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc69b.sticker.shakeLeft` | AppSvg(AppIllustrationsScanner.tremorEsquerda, size: 14×60) |  |
| `sc69b.sticker.shakeRight` | AppSvg(AppIllustrationsScanner.tremorDireita, size: 14×60) |  |
| `sc69b.sticker.tapeLeft` | HatchPainter (hachura 135°) dentro do contorno | Transform: rotate(-24deg) |
| `sc69b.sticker.tapeRight` | HatchPainter (hachura 135°) dentro do contorno | Transform: rotate(21deg) |
| `sc69b.sticker.card` | NeoBox |  |
| `sc69b.sticker.card.kind` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc69b.sticker.card.kind.icon` | AppSvg(AppIconsScanner.bookSimple, size: 14) |  |
| `sc69b.sticker.card.count.total` | TextSpan dentro do AppText.rich do pai |  |
| `sc69b.sticker.card.digits.number.dash1` | TextSpan dentro do AppText.rich do pai |  |
| `sc69b.sticker.card.digits.number.dash2` | TextSpan dentro do AppText.rich do pai |  |
| `sc69b.sticker.card.digits.check` | NeoBox + AppText |  |
| `sc69b.sticker.card.alert` | NeoBox |  |
| `sc69b.sticker.card.alert.icon` | AppSvg(AppIconsScanner.alert, size: 17) |  |
| `sc69b.sticker.card.barcode` | NeoBox |  |
| `sc69b.sticker.card.barcode.bars` | CustomPainter (codigo_barras_isbn_nao_confere) | o código de barras do ISBN digitado (o mesmo adesivo em rosa, com o dígito que não confere): no app, desenhado a partir dos dígitos que a pessoa digita (barras EAN-13 por CustomPainter, dígitos em AppText); o SVG é a referência do estado da prancha. desenha fora da própria caixa (0,6 px acima da caixa; o `<svg>` tem overflow: visible): no app, sem recorte (o SvgPicture com clipBehavior: Clip.none, ou o pintor sem clip) — com o recorte padrão, o que passa some. |
| `sc69b.sticker.notes.noIsbn.link` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Tremor uma vez (nenhum com "reduzir movimento"); `SemanticsService.announce("Esse número não confere")`.
- Nada é buscado e nada se apaga sozinho; corrigir qualquer dígito confere de novo.
- Apagar tudo → limpa o campo e volta para a 69.

## Dados

- A conta do dígito: ISBN-10 com pesos de 10 a 2, módulo 11, X = 10; ISBN-13 com pesos 1 e 3, módulo 10 (nota do design).

## Subfases

- **L69b.1** Etiqueta no estado "não confere" (giro, casa rosa, aviso)
- **L69b.2** Barra: X apagado e Apagar tudo
- **L69b.3** Tremor e anúncio
- **L69b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc69b.sticker'), todos os ids de `kRef69b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/069b_scanner_isbn_nao_confere_390x844@3x.png` no recorte da fase (y 194.82–537.54) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef69bw360` e `kRef69bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L69b.1 Etiqueta no estado "não confere" (giro, casa rosa, aviso)
- [ ] L69b.2 Barra: X apagado e Apagar tudo
- [ ] L69b.3 Tremor e anúncio
- [ ] L69b.4 Verificação + relatório
- [ ] Geometria 23/23 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
