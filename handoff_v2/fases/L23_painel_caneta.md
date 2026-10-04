# FASE L23 — Ajustes da caneta

> Tela 23 · prancha `23_ajustes_caneta` (23 · Leitor — ajustes da caneta, canvas 390×844) · executada na **G17** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L23_painel_caneta@3x.png` · `referencia/png/redline/L23_painel_caneta_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/23_ajustes_caneta_390x844@{1,2,3}x.png` · `referencia/layout/layout_23_ajustes_caneta.json` · `test/reference/leitor/reference_layout_23_ajustes_caneta.dart` (`kRef23`).
> Arquivos sugeridos: `lib/features/reader/presentation/pen_panel.dart`, `lib/core/design_system/painters/color_wheel_painter.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Painel "Ajustes da caneta" (`role=dialog`) que sai da caneta; a página esmaece. O resto da tela = 22 (ver tabela de diferenças).

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- page fades while the pen settings are open -->
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(248,241,228,0.66);"></div>

<!-- Pen settings: pops from the pen (tap the active tool again) -->
<section role="dialog" aria-label="Ajustes da caneta" style="position: absolute; left: 14px; right: 14px; bottom: 190px; padding: 14px 16px 18px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box;">
  <span aria-hidden="true" style="position: absolute; left: 42px; bottom: -9.5px; width: 16px; height: 16px; background: #FFFAF1; border-right: 1.5px solid #1A1714; border-bottom: 1.5px solid #1A1714; transform: rotate(45deg);"></span>

  <div style="display: flex; align-items: center; justify-content: space-between;">
    <span>
      <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.4px;">Caneta</span>
      <span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #5B544B;">Esferográfica · 1,2 mm · coral</span>
    </span>
    <button aria-label="Fechar ajustes" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"></path></svg></button>
  </div>

  <!-- live preview on a ruled strip -->
  <div aria-label="Prévia do traço" role="img" style="margin-top: 12px; height: 58px; border-radius: 16px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(to bottom, #F7F0E3 0 18px, #E6DBC6 18px 19.5px); background-position: 0 9px; box-sizing: border-box; overflow: hidden;">
    <svg width="100%" height="56" sc-camel-view-box="0 0 300 56" sc-camel-preserve-aspect-ratio="xMidYMid meet" aria-hidden="true"><path d="M14 38C30 14 44 14 50 28S62 46 78 30 96 10 108 22 116 44 132 36 150 14 166 20 172 40 190 38 210 18 226 22 236 40 252 36 268 22 290 26" fill="none" stroke="#FF552E" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"></path></svg>
  </div>

  <!-- tip -->
  <div style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">PONTA</div>
  <div role="radiogroup" aria-label="Tipo de ponta" style="margin-top: 7px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px;">
    <button role="radio" aria-checked="true" style="height: 70px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 12px; font-weight: 800; color: #1A1714;"><svg width="80" height="26" sc-camel-view-box="0 0 80 26" aria-hidden="true"><path d="M6 17C18 4 30 23 43 12S66 6 75 13" fill="none" stroke="#FF552E" stroke-width="2.4" stroke-linecap="round"></path></svg>Esferográfica</button><button role="radio" aria-checked="false" style="height: 70px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 12px; font-weight: 800; color: #1A1714;"><svg width="80" height="26" sc-camel-view-box="0 0 80 26" aria-hidden="true"><path d="M6 19C17 3 29 7 33.5 14 38 21 46 22.5 56 10.5 62 4 70 5.5 76 12L74.6 13.3C69 8.2 63.5 7.4 57.5 12.6 47 25.5 36.5 23.5 31.5 16 27.5 10.5 18.5 6.5 7.6 20.2Z" fill="#FF552E"></path></svg>Tinteiro</button><button role="radio" aria-checked="false" style="height: 70px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 12px; font-weight: 800; color: #1A1714;"><svg width="80" height="26" sc-camel-view-box="0 0 80 26" aria-hidden="true"><path d="M5 18C19 5 35 3.5 50 9.5 60 13.5 68 12.5 77 8 70 16.5 60 19.5 48.5 16 35.5 12 21.5 12.5 5 18Z" fill="#FF552E"></path><path d="M12 15.5C25 9 38 8.5 50 12.5M20 14C32 10.5 44 11.5 56 14.5" fill="none" stroke="#FFFAF1" stroke-width="0.9" stroke-linecap="round" opacity="0.8"></path></svg>Pincel</button>
  </div>

  <!-- size -->
  <div style="margin-top: 15px; display: flex; justify-content: space-between; align-items: baseline;"><span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">ESPESSURA</span><span style="font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums;">1,2 mm</span></div>
  <div style="margin-top: 6px; height: 32px; display: flex; align-items: center; gap: 12px;">
    <span aria-hidden="true" style="width: 5px; height: 5px; flex-shrink: 0; border-radius: 50%; background: #1A1714;"></span>
    <span role="slider" aria-label="Espessura" aria-valuemin="0.3" aria-valuemax="4" aria-valuenow="1.2" aria-valuetext="1,2 milímetro" style="position: relative; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box;">
      <span style="position: absolute; left: 0; top: 0; bottom: 0; width: 32%; border-radius: 999px 0 0 999px; background: {{brand}};"></span>
      <span aria-hidden="true" style="position: absolute; left: 32%; top: 50%; width: 28px; height: 28px; margin: -14px 0 0 -14px; border-radius: 50%; background: #FFFAF1; border: 2px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box;"></span>
    </span>
    <span aria-hidden="true" style="width: 14px; height: 14px; flex-shrink: 0; border-radius: 50%; background: #1A1714;"></span>
  </div>

  <!-- colour -->
  <div style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">COR</div>
  <div role="radiogroup" aria-label="Cores favoritas" style="margin-top: 8px; padding: 0 4px; display: flex; justify-content: space-between;"><button role="radio" aria-checked="true" aria-label="Coral" style="width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FF552E; box-shadow: 0 0 0 2.5px #FFFAF1, 0 0 0 4px #1A1714;"></button><button role="radio" aria-checked="false" aria-label="Roxo" style="width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #552CB7;"></button><button role="radio" aria-checked="false" aria-label="Azul" style="width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #058CD7;"></button><button role="radio" aria-checked="false" aria-label="Verde" style="width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #00995E;"></button><button role="radio" aria-checked="false" aria-label="Dourado" style="width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #F2A815;"></button><button role="radio" aria-checked="false" aria-label="Tinta preta" style="width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #1A1714;"></button><button aria-label="Salvar a cor atual nas favoritas" style="width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; border-style: dashed; background: transparent; display: flex; align-items: center; justify-content: center;"><svg width="14" height="14" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg></button></div>
  <div style="margin-top: 14px; display: flex; gap: 16px; align-items: center;">
    <span role="slider" aria-label="Roda de cores: tom e intensidade" aria-valuetext="coral" style="position: relative; width: 124px; height: 124px; flex-shrink: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: radial-gradient(circle closest-side, #FFFFFF, rgba(255,255,255,0)), conic-gradient(#FF0000, #FFFF00, #00FF00, #00FFFF, #0000FF, #FF00FF, #FF0000);">
      <span aria-hidden="true" style="position: absolute; left: 58.0px; top: -0.2px; width: 24px; height: 24px; border-radius: 50%; background: #FF552E; border: 3px solid #FFFAF1; box-shadow: 0 0 0 1.5px #1A1714, 2px 2px 0 1.5px #1A1714; box-sizing: border-box;"></span>
    </span>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">BRILHO</span>
      <span role="slider" aria-label="Brilho" aria-valuemin="0" aria-valuemax="100" aria-valuenow="100" style="position: relative; display: block; margin-top: 9px; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: linear-gradient(90deg, #1A1714, #FF552E); box-sizing: border-box;">
        <span aria-hidden="true" style="position: absolute; right: -3px; top: 50%; width: 26px; height: 26px; margin-top: -13px; border-radius: 50%; background: #FF552E; border: 3px solid #FFFAF1; box-shadow: 0 0 0 1.5px #1A1714; box-sizing: border-box;"></span>
      </span>
      <span style="margin-top: 16px; height: 42px; padding: 0 12px; border-radius: 14px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px;">
        <span aria-hidden="true" style="width: 18px; height: 18px; flex-shrink: 0; border-radius: 6px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box;"></span>
        <span style="font-size: 15px; font-weight: 800; letter-spacing: 0.6px; font-variant-numeric: tabular-nums;">#FF552E</span>
      </span>
    </span>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `pen.fade` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `pen.fade` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background: rgba(248,241,228,0.66)` |  |

Seção `pen.penPanel` — retângulo absoluto no canvas 390×844: **x=14, y=125, w=362, h=529**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `pen.penPanel` | box | 0 | 0 | 362 | 529 | `position: absolute; left: 14px; right: 14px; bottom: 190px; padding: 14px 16px 18px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box` |  |
| 3 | `pen.penPanel.arrow` | box | 43.5 | 519.5 | 17.5 | 17.5 | `position: absolute; left: 42px; bottom: -9.5px; width: 16px; height: 16px; background: #FFFAF1; border-right: 1.5px solid #1A1714; border-bottom: 1.5px solid #1A1714; transform: rotate(45deg)` |  |
| 4 | `pen.penPanel.header` | box | 17.5 | 15.5 | 327 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 5 | `pen.penPanel.header.texts` ±1 | box | 17.5 | 17.44 | 162.99 | 40.11 | `—` |  |
| 6 | `pen.penPanel.title` ±1 | text | 17.5 | 17.44 | 162.99 | 23.1 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.4px` | Bricolage (opsz 22) 22/23.1px peso 800 ls -0.4px #1A1714 |
| 7 | `pen.penPanel.subtitle` ±1 | text | 17.5 | 42.54 | 162.99 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 8 | `pen.penPanel.close` | box | 300.5 | 15.5 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `pen.penPanel.close.icon` | icon | 313.5 | 28.5 | 18 | 18 | `—` |  |
| 10 | `pen.penPanel.preview` | box | 17.5 | 71.5 | 327 | 58 | `margin-top: 12px; height: 58px; border-radius: 16px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(to bottom, #F7F0E3 0 18px, #E6DBC6 18px 19.5px); background-position: 0 9px; box-sizing: border-box; overflow: hidden` |  |
| 11 | `pen.penPanel.preview.art` | icon | 19 | 73 | 324 | 56 | `—` |  |
| 12 | `pen.penPanel.tipLabel` | text | 17.5 | 143.5 | 327 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 13 | `pen.penPanel.tips` | box | 17.5 | 163.7 | 327 | 70 | `margin-top: 7px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px` |  |
| 14 | `pen.penPanel.tips.ballpoint` | box+text | 17.5 | 163.7 | 103.67 | 70 | `height: 70px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 12px; font-weight: 800; color: #1A1714` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 15 | `pen.penPanel.tips.ballpoint.sample` | icon | 29.33 | 176.5 | 80 | 26 | `—` |  |
| 16 | `pen.penPanel.tips.fountain` | box+text | 129.17 | 163.7 | 103.67 | 70 | `height: 70px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 12px; font-weight: 800; color: #1A1714` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 17 | `pen.penPanel.tips.fountain.sample` | icon | 141 | 176.5 | 80 | 26 | `—` |  |
| 18 | `pen.penPanel.tips.brush` | box+text | 240.83 | 163.7 | 103.67 | 70 | `height: 70px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 12px; font-weight: 800; color: #1A1714` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 19 | `pen.penPanel.tips.brush.sample` | icon | 252.67 | 176.5 | 80 | 26 | `—` |  |
| 20 | `pen.penPanel.sizeHeader` | box | 17.5 | 248.7 | 327 | 15.6 | `margin-top: 15px; display: flex; justify-content: space-between; align-items: baseline` |  |
| 21 | `pen.penPanel.sizeHeader.label` ±1 | text | 17.5 | 250.6 | 73.42 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 22 | `pen.penPanel.sizeHeader.value` ±1 | text | 298.48 | 248.7 | 46.02 | 15.6 | `font-size: 13px; font-weight: 800; font-variant-numeric: tabular-nums` | Figtree 13/normal peso 800 ls normal #1A1714 tnum |
| 23 | `pen.penPanel.size` | box | 17.5 | 270.3 | 327 | 32 | `margin-top: 6px; height: 32px; display: flex; align-items: center; gap: 12px` |  |
| 24 | `pen.penPanel.size.minDot` | box | 17.5 | 283.8 | 5 | 5 | `width: 5px; height: 5px; flex-shrink: 0; border-radius: 50%; background: #1A1714` |  |
| 25 | `pen.penPanel.size.slider` | box | 34.5 | 278.3 | 284 | 16 | `position: relative; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box` |  |
| 26 | `pen.penPanel.size.slider.fill` | box | 36 | 279.8 | 89.92 | 13 | `position: absolute; left: 0; top: 0; bottom: 0; width: 32%; border-radius: 999px 0 0 999px; background: {{brand}} (padrão #B6ACE4)` |  |
| 27 | `pen.penPanel.size.slider.knob` | box | 111.92 | 272.3 | 28 | 28 | `position: absolute; left: 32%; top: 50%; width: 28px; height: 28px; margin: -14px 0 0 -14px; border-radius: 50%; background: #FFFAF1; border: 2px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box` |  |
| 28 | `pen.penPanel.size.maxDot` | box | 330.5 | 279.3 | 14 | 14 | `width: 14px; height: 14px; flex-shrink: 0; border-radius: 50%; background: #1A1714` |  |
| 29 | `pen.penPanel.colorLabel` | text | 17.5 | 316.3 | 327 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 30 | `pen.penPanel.favorites` | box | 17.5 | 337.5 | 327 | 34 | `margin-top: 8px; padding: 0 4px; display: flex; justify-content: space-between` |  |
| 31 | `pen.penPanel.favorites.coral` | box | 21.5 | 337.5 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FF552E; box-shadow: 0 0 0 2.5px #FFFAF1, 0 0 0 4px #1A1714` |  |
| 32 | `pen.penPanel.favorites.purple` | box | 69 | 337.5 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #552CB7` |  |
| 33 | `pen.penPanel.favorites.blue` | box | 116.5 | 337.5 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #058CD7` |  |
| 34 | `pen.penPanel.favorites.green` | box | 164 | 337.5 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #00995E` |  |
| 35 | `pen.penPanel.favorites.gold` | box | 211.5 | 337.5 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #F2A815` |  |
| 36 | `pen.penPanel.favorites.black` | box | 259 | 337.5 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #1A1714` |  |
| 37 | `pen.penPanel.favorites.add` | box | 306.5 | 337.5 | 34 | 34 | `width: 34px; height: 34px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; border-style: dashed; background: transparent; display: flex; align-items: center; justify-content: center` |  |
| 38 | `pen.penPanel.favorites.add.icon` | icon | 316.5 | 347.5 | 14 | 14 | `—` |  |
| 39 | `pen.penPanel.picker` | box | 17.5 | 385.5 | 327 | 124 | `margin-top: 14px; display: flex; gap: 16px; align-items: center` |  |
| 40 | `pen.penPanel.picker.wheel` | box | 17.5 | 385.5 | 124 | 124 | `position: relative; width: 124px; height: 124px; flex-shrink: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: radial-gradient(circle closest-side, #FFFFFF, rgba(255,255,255,0)), conic-gradient(#FF0000, #FFFF00, #00FF00, #00FFFF, #0000FF, #FF00FF, #FF0000)` |  |
| 41 | `pen.penPanel.picker.wheel.cursor` | box | 77 | 386.8 | 24 | 24 | `position: absolute; left: 58.0px; top: -0.2px; width: 24px; height: 24px; border-radius: 50%; background: #FF552E; border: 3px solid #FFFAF1; box-shadow: 0 0 0 1.5px #1A1714, 2px 2px 0 1.5px #1A1714; box-sizing: border-box` |  |
| 42 | `pen.penPanel.picker.side` | box | 157.5 | 399.4 | 187 | 96.2 | `min-width: 0; flex-grow: 1` |  |
| 43 | `pen.penPanel.picker.brightnessLabel` | text | 157.5 | 399.4 | 187 | 13.2 | `display: block; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 44 | `pen.penPanel.picker.brightness` | box | 157.5 | 421.6 | 187 | 16 | `position: relative; display: block; margin-top: 9px; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: linear-gradient(90deg, #1A1714, #FF552E); box-sizing: border-box` |  |
| 45 | `pen.penPanel.picker.brightness.knob` | box | 320 | 416.6 | 26 | 26 | `position: absolute; right: -3px; top: 50%; width: 26px; height: 26px; margin-top: -13px; border-radius: 50%; background: #FF552E; border: 3px solid #FFFAF1; box-shadow: 0 0 0 1.5px #1A1714; box-sizing: border-box` |  |
| 46 | `pen.penPanel.picker.hex` | box | 157.5 | 453.6 | 187 | 42 | `margin-top: 16px; height: 42px; padding: 0 12px; border-radius: 14px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px` |  |
| 47 | `pen.penPanel.picker.hex.swatch` | box | 171 | 465.6 | 18 | 18 | `width: 18px; height: 18px; flex-shrink: 0; border-radius: 6px; background: #FF552E; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 48 | `pen.penPanel.picker.hex.value` ±1 | text | 198 | 465.6 | 67.88 | 18 | `font-size: 15px; font-weight: 800; letter-spacing: 0.6px; font-variant-numeric: tabular-nums` | Figtree 15/normal peso 800 ls 0.6px #1A1714 tnum |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `pen.penPanel.arrow`: caixa visual com `transform: rotate(45deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `pen.penPanel.title` | 1 | Caneta | 36.25 | 17.5 | 91.61 | 74.11 |
| `pen.penPanel.subtitle` | 1 | Esferográfica · 1,2 mm · coral | 54.43 | 17.5 | 180.49 | 162.99 |
| `pen.penPanel.tipLabel` | 1 | PONTA | 153.95 | 17.5 | 61.43 | 43.93 |
| `pen.penPanel.tips.ballpoint` | 1 | Esferográfica | 217.9 | 31.5 | 107.16 | 75.66 |
| `pen.penPanel.tips.fountain` | 1 | Tinteiro | 217.9 | 159 | 203 | 44 |
| `pen.penPanel.tips.brush` | 1 | Pincel | 217.9 | 275.69 | 309.64 | 33.95 |
| `pen.penPanel.sizeHeader.label` | 1 | ESPESSURA | 261.05 | 17.5 | 90.92 | 73.42 |
| `pen.penPanel.sizeHeader.value` | 1 | 1,2 mm | 261.05 | 298.48 | 344.5 | 46.02 |
| `pen.penPanel.colorLabel` | 1 | COR | 326.75 | 17.5 | 45 | 27.5 |
| `pen.penPanel.picker.brightnessLabel` | 1 | BRILHO | 409.85 | 157.5 | 204.85 | 47.35 |
| `pen.penPanel.picker.hex.value` | 1 | #FF552E | 479.85 | 198 | 265.88 | 67.88 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Véu `#F8F1E4@0.66` sobre a página. Painel: `left/right 14 · bottom 190`, raio 26, sombra 4/4, seta apontando para a caneta.
2. Cabeçalho "Caneta" (Bricolage 22) + subtítulo derivado "Esferográfica · 1,2 mm · coral" + fechar 18.
3. Prévia do traço numa faixa pautada (`role=img`); PONTA (3 cartões com amostra; ativo com fundo `brand`); ESPESSURA "1,2 mm" com slider hachurado (preenchimento `brand` a 32 %, D-50) e pontos 5/14 nas pontas;
4. COR (`radiogroup` "Cores favoritas", 6 círculos 34 + "+" tracejado; ativo com aro duplo 2,5 `#FFFAF1` + 4 tinta);
5. Roda de cores 124 (cônico HSV + radial branco, cursor 24 com aro 3) + BRILHO (slider 16 com degradê tinta→cor, botão 26) + campo hex 42 "#FF552E" (Figtree 15/800 ls 0,6, amostra 18 raio 6).

## Armadilhas

- Roda de cores e degradês por CustomPainter (recortes em `png/elementos/`), não pacote de color picker.
- Subtítulo derivado: tipo · mm com vírgula · nome da cor (ou hex).

## Diferenças em relação à prancha 22 (seções reutilizadas: page, deskEdge, modePill, done, toolShelf, island)

Estas seções são as mesmas widgets da 22 (fases L22a_pagina_anotada, L22b_topo_modo_anotacao, L22c_prateleira_ferramentas, L22d_ilha_anotacao); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Só na base: `page.text.wavy.touchRing`, `page.text.wavy.touchDot`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `pen.fade` |  |  | aria-hidden=true |
| `pen.penPanel` | dialog | Ajustes da caneta |  |
| `pen.penPanel.arrow` |  |  | aria-hidden=true |
| `pen.penPanel.close` |  | Fechar ajustes |  |
| `pen.penPanel.close.icon` |  |  | aria-hidden=true |
| `pen.penPanel.preview` | img | Prévia do traço |  |
| `pen.penPanel.preview.art` |  |  | aria-hidden=true |
| `pen.penPanel.tips` | radiogroup | Tipo de ponta |  |
| `pen.penPanel.tips.ballpoint` | radio |  | aria-checked=true |
| `pen.penPanel.tips.ballpoint.sample` |  |  | aria-hidden=true |
| `pen.penPanel.tips.fountain` | radio |  | aria-checked=false |
| `pen.penPanel.tips.fountain.sample` |  |  | aria-hidden=true |
| `pen.penPanel.tips.brush` | radio |  | aria-checked=false |
| `pen.penPanel.tips.brush.sample` |  |  | aria-hidden=true |
| `pen.penPanel.size.minDot` |  |  | aria-hidden=true |
| `pen.penPanel.size.slider` | slider | Espessura | aria-valuemin=0.3, aria-valuemax=4, aria-valuenow=1.2, aria-valuetext=1,2 milímetro |
| `pen.penPanel.size.slider.knob` |  |  | aria-hidden=true |
| `pen.penPanel.size.maxDot` |  |  | aria-hidden=true |
| `pen.penPanel.favorites` | radiogroup | Cores favoritas |  |
| `pen.penPanel.favorites.coral` | radio | Coral | aria-checked=true |
| `pen.penPanel.favorites.purple` | radio | Roxo | aria-checked=false |
| `pen.penPanel.favorites.blue` | radio | Azul | aria-checked=false |
| `pen.penPanel.favorites.green` | radio | Verde | aria-checked=false |
| `pen.penPanel.favorites.gold` | radio | Dourado | aria-checked=false |
| `pen.penPanel.favorites.black` | radio | Tinta preta | aria-checked=false |
| `pen.penPanel.favorites.add` |  | Salvar a cor atual nas favoritas |  |
| `pen.penPanel.favorites.add.icon` |  |  | aria-hidden=true |
| `pen.penPanel.picker.wheel` | slider | Roda de cores: tom e intensidade | aria-valuetext=coral |
| `pen.penPanel.picker.wheel.cursor` |  |  | aria-hidden=true |
| `pen.penPanel.picker.brightness` | slider | Brilho | aria-valuemin=0, aria-valuemax=100, aria-valuenow=100 |
| `pen.penPanel.picker.brightness.knob` |  |  | aria-hidden=true |
| `pen.penPanel.picker.hex.swatch` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `pen.fade` | NeoBox |  |
| `pen.penPanel` | NeoBox |  |
| `pen.penPanel.arrow` | NeoBox | Transform: rotate(45deg) |
| `pen.penPanel.close` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.close.icon` | AppSvg(AppIconsLeitor.ic_close, size: 18) |  |
| `pen.penPanel.preview` | HatchPainter (hachura 135°) dentro do contorno |  |
| `pen.penPanel.preview.art` | AppSvg(AppIllustrationsLeitor.il_previa_traco_caneta, size: 326×56) | width="100%": a prévia ocupa a largura da faixa pautada; no app é desenhada com a ponta/espessura/cor atuais. |
| `pen.penPanel.tips.ballpoint` | NeoBox + AppText |  |
| `pen.penPanel.tips.ballpoint.sample` | AppSvg(AppIllustrationsLeitor.il_ponta_esferografica, size: 80×26) |  |
| `pen.penPanel.tips.fountain` | NeoBox + AppText |  |
| `pen.penPanel.tips.fountain.sample` | AppSvg(AppIllustrationsLeitor.il_ponta_tinteiro, size: 80×26) |  |
| `pen.penPanel.tips.brush` | NeoBox + AppText |  |
| `pen.penPanel.tips.brush.sample` | AppSvg(AppIllustrationsLeitor.il_ponta_pincel, size: 80×26) |  |
| `pen.penPanel.size.minDot` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.size.slider` | HatchPainter (hachura 135°) dentro do contorno |  |
| `pen.penPanel.size.slider.fill` | NeoBox |  |
| `pen.penPanel.size.slider.knob` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.size.maxDot` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.coral` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.purple` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.blue` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.green` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.gold` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.black` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.add` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.favorites.add.icon` | AppSvg(AppIconsLeitor.ic_plus, size: 14) |  |
| `pen.penPanel.picker.wheel` | ColorWheelPainter (cônico HSV + radial branco) |  |
| `pen.penPanel.picker.wheel.cursor` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.picker.brightness` | DecoratedBox(LinearGradient) |  |
| `pen.penPanel.picker.brightness.knob` | CircleIconButton / NeoBox circular |  |
| `pen.penPanel.picker.hex` | NeoBox |  |
| `pen.penPanel.picker.hex.swatch` | NeoBox |  |

## Interações

- Fechar/tocar fora fecha; cada controle altera o preset na hora; "+" salva a cor atual (máx. 12 favoritas).

## Dados

- `pen_presets.pen_tip`, `pen_width_mm` (D-28/D-50), `pen_color`, `favorite_colors`.

## Subfases

- **L23.1** Véu + painel + seta
- **L23.2** Cabeçalho e prévia
- **L23.3** Ponta
- **L23.4** Espessura
- **L23.5** Cores favoritas
- **L23.6** Roda + brilho + hex
- **L23.7** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('pen.fade', 'pen.penPanel'), todos os ids de `kRef23.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/23_ajustes_caneta_390x844@3x.png` no recorte da fase (y 117–673.63) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L23.1 Véu + painel + seta
- [ ] L23.2 Cabeçalho e prévia
- [ ] L23.3 Ponta
- [ ] L23.4 Espessura
- [ ] L23.5 Cores favoritas
- [ ] L23.6 Roda + brilho + hex
- [ ] L23.7 Verificação + relatório
- [ ] Geometria 48/48 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
