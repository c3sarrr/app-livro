# FASE L23b — Ajustes do marca-texto

> Tela 23b · prancha `23b_ajustes_marcatexto` (23b · Leitor — ajustes do marca-texto, canvas 390×844) · executada na **G17** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L23b_painel_marcatexto@3x.png` · `referencia/png/redline/L23b_painel_marcatexto_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/23b_ajustes_marcatexto_390x844@{1,2,3}x.png` · `referencia/layout/layout_23b_ajustes_marcatexto.json` · `test/reference/leitor/reference_layout_23b_ajustes_marcatexto.dart` (`kRef23b`).
> Arquivos sugeridos: `lib/features/reader/presentation/marker_panel.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Painel "Ajustes do marca-texto"; o resto da tela = 22 com o marca-texto ativo (ver diferenças).

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- page fades while the highlighter settings are open -->
<div aria-hidden="true" style="position: absolute; inset: 0; background: rgba(248,241,228,0.66);"></div>

<!-- Highlighter settings: pops from the highlighter (tap the active tool again) -->
<section role="dialog" aria-label="Ajustes do marca-texto" style="position: absolute; left: 14px; right: 14px; bottom: 190px; padding: 14px 16px 16px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box;">
  <span aria-hidden="true" style="position: absolute; left: 95px; bottom: -9.5px; width: 16px; height: 16px; background: #FFFAF1; border-right: 1.5px solid #1A1714; border-bottom: 1.5px solid #1A1714; transform: rotate(45deg);"></span>

  <div style="display: flex; align-items: center; justify-content: space-between;">
    <span>
      <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.4px;">Marca-texto</span>
      <span style="display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #5B544B;">Fundo · amarelo “lindo” · média</span>
    </span>
    <button aria-label="Fechar ajustes" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"></path></svg></button>
  </div>

  <!-- live preview: a real line of the page -->
  <div aria-label="Prévia: Olhos de ressaca, com fundo amarelo na palavra ressaca" role="img" style="margin-top: 12px; padding: 10px 14px; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; font-family: 'Literata', Georgia, serif; font-size: 17px; line-height: 1.5; color: #2A2520; white-space: nowrap; overflow: hidden; text-align: center;">Olhos de <span style="background: linear-gradient(transparent 14%, rgba(254,209,112,0.95) 14%, rgba(254,209,112,0.95) 92%, transparent 92%); border-radius: 3px;">ressaca</span>? Vá, de ressaca.</div>

  <div style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">ESTILO</div>
  <div role="radiogroup" aria-label="Estilo do marca-texto" style="margin-top: 7px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px;"><button role="radio" aria-checked="true" style="height: 66px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 7px; font-size: 12px; font-weight: 800; color: #1A1714;"><span style="font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 400; line-height: 1.2; padding-bottom: 3px; color: #2A2520;"><span style="background: linear-gradient(transparent 14%, rgba(254,209,112,0.95) 14%, rgba(254,209,112,0.95) 92%, transparent 92%); border-radius: 3px;">ressaca</span></span>Fundo</button><button role="radio" aria-checked="false" style="height: 66px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 7px; font-size: 12px; font-weight: 800; color: #1A1714;"><span style="font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 400; line-height: 1.2; padding-bottom: 3px; color: #2A2520;"><span style="text-decoration: underline; text-decoration-color: rgba(254,209,112,1); text-decoration-thickness: 4px; text-underline-offset: 3px; text-decoration-skip-ink: none;">ressaca</span></span>Sublinhado</button><button role="radio" aria-checked="false" style="height: 66px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 7px; font-size: 12px; font-weight: 800; color: #1A1714;"><span style="font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 400; line-height: 1.2; padding-bottom: 3px; color: #2A2520;"><span style="text-decoration: underline wavy; text-decoration-color: rgba(254,209,112,1); text-decoration-thickness: 2.5px; text-underline-offset: 2px; text-decoration-skip-ink: none;">ressaca</span></span>Ondulado</button></div>

  <div style="margin-top: 14px; display: flex; justify-content: space-between; align-items: baseline;"><span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">CORES E RÓTULOS</span><a href="#" style="font-size: 12.5px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px;">Editar rótulos</a></div>
  <div role="radiogroup" aria-label="Cor do marca-texto" style="margin-top: 7px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px;"><button role="radio" aria-checked="true" aria-label="amarelo, rótulo lindo, 5 grifos" style="height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left;"><span aria-hidden="true" style="width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 0 0 2.5px #FFFAF1, 0 0 0 4px #1A1714;"></span><span style="min-width: 0; display: flex; flex-direction: column;"><span style="font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap;">lindo</span><span style="font-size: 11px; font-weight: 600; color: #8A8073;">5 grifos</span></span></button><button role="radio" aria-checked="false" aria-label="rosa, rótulo personagem, 3 grifos" style="height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left;"><span aria-hidden="true" style="width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box;"></span><span style="min-width: 0; display: flex; flex-direction: column;"><span style="font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap;">personagem</span><span style="font-size: 11px; font-weight: 600; color: #8A8073;">3 grifos</span></span></button><button role="radio" aria-checked="false" aria-label="verde, rótulo ideia, 2 grifos" style="height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left;"><span aria-hidden="true" style="width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box;"></span><span style="min-width: 0; display: flex; flex-direction: column;"><span style="font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap;">ideia</span><span style="font-size: 11px; font-weight: 600; color: #8A8073;">2 grifos</span></span></button><button role="radio" aria-checked="false" aria-label="lavanda, rótulo pro clube, 2 grifos" style="height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left;"><span aria-hidden="true" style="width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box;"></span><span style="min-width: 0; display: flex; flex-direction: column;"><span style="font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap;">pro clube</span><span style="font-size: 11px; font-weight: 600; color: #8A8073;">2 grifos</span></span></button></div>

  <div style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">ALTURA</div>
  <div role="radiogroup" aria-label="Altura do fundo" style="margin-top: 7px; height: 44px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #F7F0E3;"><button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; color: #5B544B; box-sizing: border-box; font-size: 13px; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 6px;"><span aria-hidden="true" style="width: 16px; height: 6px; border-radius: 2px; background: #FED170; border: 1.2px solid #1A1714; box-sizing: border-box;"></span>Baixa</button><button role="radio" aria-checked="true" style="height: 100%; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13px; font-weight: 800; display: flex; align-items: center; justify-content: center; gap: 6px;"><span aria-hidden="true" style="width: 16px; height: 11px; border-radius: 2px; background: #FED170; border: 1.2px solid #1A1714; box-sizing: border-box;"></span>Média</button><button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; color: #5B544B; box-sizing: border-box; font-size: 13px; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 6px;"><span aria-hidden="true" style="width: 16px; height: 16px; border-radius: 2px; background: #FED170; border: 1.2px solid #1A1714; box-sizing: border-box;"></span>Alta</button></div>

  <div style="margin-top: 12px; padding: 10px 12px; border-radius: 16px; border: 1.3px dashed #8A7F63; display: flex; align-items: center; gap: 10px;">
    <svg width="34" height="22" sc-camel-view-box="0 0 34 22" aria-hidden="true" style="flex-shrink: 0;"><rect x="1" y="5" width="32" height="12" rx="3" fill="#FED170" stroke="#1A1714" stroke-width="1.3"></rect><path d="M3 18C9 13 14 19 20 14S29 12 32 9" fill="none" stroke="#FF552E" stroke-width="1.6" stroke-linecap="round" stroke-dasharray="2.5 2.5"></path></svg>
    <span style="font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #3D3830;"><strong style="color: #1A1714;">Gruda nas palavras.</strong> Mesmo torto, o traço encaixa na linha e acompanha se a fonte mudar.</span>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `mk.fade` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `mk.fade` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background: rgba(248,241,228,0.66)` |  |

Seção `mk.markerPanel` — retângulo absoluto no canvas 390×844: **x=14, y=108.86, w=362, h=545.13**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `mk.markerPanel` | box | 0 | 0 | 362 | 545.13 | `position: absolute; left: 14px; right: 14px; bottom: 190px; padding: 14px 16px 16px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; box-sizing: border-box` |  |
| 3 | `mk.markerPanel.arrow` | box | 96.5 | 535.64 | 17.5 | 17.5 | `position: absolute; left: 95px; bottom: -9.5px; width: 16px; height: 16px; background: #FFFAF1; border-right: 1.5px solid #1A1714; border-bottom: 1.5px solid #1A1714; transform: rotate(45deg)` |  |
| 4 | `mk.markerPanel.header` | box | 17.5 | 15.5 | 327 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 5 | `mk.markerPanel.header.texts` ±1 | box | 17.5 | 17.45 | 174.62 | 40.11 | `—` |  |
| 6 | `mk.markerPanel.title` ±1 | text | 17.5 | 17.45 | 174.62 | 23.1 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.4px` | Bricolage (opsz 22) 22/23.1px peso 800 ls -0.4px #1A1714 |
| 7 | `mk.markerPanel.subtitle` ±1 | text | 17.5 | 42.55 | 174.62 | 15.01 | `display: block; margin-top: 2px; font-size: 12.5px; font-weight: 600; color: #5B544B` | Figtree 12.5/normal peso 600 ls normal #5B544B |
| 8 | `mk.markerPanel.close` | box | 300.5 | 15.5 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `mk.markerPanel.close.icon` | icon | 313.5 | 28.51 | 18 | 18 | `—` |  |
| 10 | `mk.markerPanel.preview` | box+text | 17.5 | 71.51 | 327 | 48.5 | `margin-top: 12px; padding: 10px 14px; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; font-family: 'Literata', Georgia, serif; font-size: 17px; line-height: 1.5; color: #2A2520; white-space: nowrap; overflow: hidden; text-align: center` | Literata (opsz 17) 17/25.5px peso 400 ls normal #2A2520 |
| 11 | `mk.markerPanel.preview.highlight` ±1 | inline | 124.17 | 83.13 | 57.94 | 25.25 | `background: linear-gradient(transparent 14%, rgba(254,209,112,0.95) 14%, rgba(254,209,112,0.95) 92%, transparent 92%); border-radius: 3px` | Literata (opsz 17) 17/25.5px peso 400 ls normal #2A2520 |
| 12 | `mk.markerPanel.styleLabel` | text | 17.5 | 134 | 327 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 13 | `mk.markerPanel.styles` | box | 17.5 | 154.2 | 327 | 66 | `margin-top: 7px; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 8px` |  |
| 14 | `mk.markerPanel.styles.fill` | box+text | 17.5 | 154.2 | 103.67 | 66 | `height: 66px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 7px; font-size: 12px; font-weight: 800; color: #1A1714` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 15 | `mk.markerPanel.styles.fill.sample` ±1 | box | 41.81 | 165.4 | 55.04 | 22.2 | `font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 400; line-height: 1.2; padding-bottom: 3px; color: #2A2520` | Literata (opsz 16) 16/19.2px peso 400 ls normal #2A2520 |
| 16 | `mk.markerPanel.styles.fill.sample.word` ±1 | inline | 41.81 | 163.12 | 55.04 | 23.76 | `background: linear-gradient(transparent 14%, rgba(254,209,112,0.95) 14%, rgba(254,209,112,0.95) 92%, transparent 92%); border-radius: 3px` | Literata (opsz 16) 16/19.2px peso 400 ls normal #2A2520 |
| 17 | `mk.markerPanel.styles.underline` | box+text | 129.17 | 154.2 | 103.67 | 66 | `height: 66px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 7px; font-size: 12px; font-weight: 800; color: #1A1714` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 18 | `mk.markerPanel.styles.underline.sample` ±1 | box | 153.48 | 165.4 | 55.04 | 22.2 | `font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 400; line-height: 1.2; padding-bottom: 3px; color: #2A2520` | Literata (opsz 16) 16/19.2px peso 400 ls normal #2A2520 |
| 19 | `mk.markerPanel.styles.underline.sample.word` ±1 | inline | 153.48 | 163.12 | 55.04 | 23.76 | `text-decoration: underline; text-decoration-color: rgba(254,209,112,1); text-decoration-thickness: 4px; text-underline-offset: 3px; text-decoration-skip-ink: none` | Literata (opsz 16) 16/19.2px peso 400 ls normal #2A2520 |
| 20 | `mk.markerPanel.styles.wavy` | box+text | 240.83 | 154.2 | 103.67 | 66 | `height: 66px; padding: 0; border-radius: 16px; border: 1.5px solid #1A1714; background: #F7F0E3; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 7px; font-size: 12px; font-weight: 800; color: #1A1714` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 21 | `mk.markerPanel.styles.wavy.sample` ±1 | box | 265.15 | 165.4 | 55.04 | 22.2 | `font-family: 'Literata', Georgia, serif; font-size: 16px; font-weight: 400; line-height: 1.2; padding-bottom: 3px; color: #2A2520` | Literata (opsz 16) 16/19.2px peso 400 ls normal #2A2520 |
| 22 | `mk.markerPanel.styles.wavy.sample.word` ±1 | inline | 265.15 | 163.12 | 55.04 | 23.76 | `text-decoration: underline wavy; text-decoration-color: rgba(254,209,112,1); text-decoration-thickness: 2.5px; text-underline-offset: 2px; text-decoration-skip-ink: none` | Literata (opsz 16) 16/19.2px peso 400 ls normal #2A2520 |
| 23 | `mk.markerPanel.colorsHeader` | box | 17.5 | 234.2 | 327 | 15.01 | `margin-top: 14px; display: flex; justify-content: space-between; align-items: baseline` |  |
| 24 | `mk.markerPanel.colorsHeader.label` ±1 | text | 17.5 | 235.63 | 117.75 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 25 | `mk.markerPanel.colorsHeader.editLabels` ±1 | text | 265.46 | 234.2 | 79.04 | 15.01 | `font-size: 12.5px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 26 | `mk.markerPanel.colors` | box | 17.5 | 256.21 | 327 | 108 | `margin-top: 7px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 8px` |  |
| 27 | `mk.markerPanel.colors.yellow` | box | 17.5 | 256.21 | 159.5 | 50 | `height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left` |  |
| 28 | `mk.markerPanel.colors.yellow.swatch` | box | 29 | 269.21 | 24 | 24 | `width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; box-shadow: 0 0 0 2.5px #FFFAF1, 0 0 0 4px #1A1714` |  |
| 29 | `mk.markerPanel.colors.yellow.texts` ±1 | box | 62 | 266.85 | 37.95 | 28.73 | `min-width: 0; display: flex; flex-direction: column` |  |
| 30 | `mk.markerPanel.colors.yellow.label` ±1 | text | 62 | 266.85 | 37.95 | 15.53 | `font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap` | Figtree 13.5/15.525px peso 800 ls normal #1A1714 |
| 31 | `mk.markerPanel.colors.yellow.count` ±1 | text | 62 | 282.38 | 37.95 | 13.2 | `font-size: 11px; font-weight: 600; color: #8A8073` | Figtree 11/normal peso 600 ls normal #8A8073 |
| 32 | `mk.markerPanel.colors.pink` | box | 185 | 256.21 | 159.5 | 50 | `height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left` |  |
| 33 | `mk.markerPanel.colors.pink.swatch` | box | 196.5 | 269.21 | 24 | 24 | `width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 34 | `mk.markerPanel.colors.pink.texts` ±1 | box | 229.5 | 266.85 | 78.11 | 28.73 | `min-width: 0; display: flex; flex-direction: column` |  |
| 35 | `mk.markerPanel.colors.pink.label` ±1 | text | 229.5 | 266.85 | 78.11 | 15.53 | `font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap` | Figtree 13.5/15.525px peso 800 ls normal #1A1714 |
| 36 | `mk.markerPanel.colors.pink.count` ±1 | text | 229.5 | 282.38 | 78.11 | 13.2 | `font-size: 11px; font-weight: 600; color: #8A8073` | Figtree 11/normal peso 600 ls normal #8A8073 |
| 37 | `mk.markerPanel.colors.green` | box | 17.5 | 314.21 | 159.5 | 50 | `height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left` |  |
| 38 | `mk.markerPanel.colors.green.swatch` | box | 29 | 327.21 | 24 | 24 | `width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 39 | `mk.markerPanel.colors.green.texts` ±1 | box | 62 | 324.85 | 37.88 | 28.73 | `min-width: 0; display: flex; flex-direction: column` |  |
| 40 | `mk.markerPanel.colors.green.label` ±1 | text | 62 | 324.85 | 37.88 | 15.53 | `font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap` | Figtree 13.5/15.525px peso 800 ls normal #1A1714 |
| 41 | `mk.markerPanel.colors.green.count` ±1 | text | 62 | 340.38 | 37.88 | 13.2 | `font-size: 11px; font-weight: 600; color: #8A8073` | Figtree 11/normal peso 600 ls normal #8A8073 |
| 42 | `mk.markerPanel.colors.lavender` | box | 185 | 314.21 | 159.5 | 50 | `height: 50px; padding: 0 10px; border-radius: 16px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: flex; align-items: center; gap: 9px; text-align: left` |  |
| 43 | `mk.markerPanel.colors.lavender.swatch` | box | 196.5 | 327.21 | 24 | 24 | `width: 24px; height: 24px; flex-shrink: 0; border-radius: 50%; background: #B6ACE4; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 44 | `mk.markerPanel.colors.lavender.texts` ±1 | box | 229.5 | 324.85 | 58.83 | 28.73 | `min-width: 0; display: flex; flex-direction: column` |  |
| 45 | `mk.markerPanel.colors.lavender.label` ±1 | text | 229.5 | 324.85 | 58.83 | 15.53 | `font-size: 13.5px; font-weight: 800; line-height: 1.15; white-space: nowrap` | Figtree 13.5/15.525px peso 800 ls normal #1A1714 |
| 46 | `mk.markerPanel.colors.lavender.count` ±1 | text | 229.5 | 340.38 | 58.83 | 13.2 | `font-size: 11px; font-weight: 600; color: #8A8073` | Figtree 11/normal peso 600 ls normal #8A8073 |
| 47 | `mk.markerPanel.heightLabel` | text | 17.5 | 378.21 | 327 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 48 | `mk.markerPanel.heights` | box | 17.5 | 398.41 | 327 | 44 | `margin-top: 7px; height: 44px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #F7F0E3` |  |
| 49 | `mk.markerPanel.heights.low` | text | 22 | 402.91 | 104.67 | 35 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; color: #5B544B; box-sizing: border-box; font-size: 13px; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 6px` | Figtree 13/normal peso 600 ls normal #5B544B |
| 50 | `mk.markerPanel.heights.low.sample` ±1 | box | 47.67 | 417.41 | 16 | 6 | `width: 16px; height: 6px; border-radius: 2px; background: #FED170; border: 1.2px solid #1A1714; box-sizing: border-box` |  |
| 51 | `mk.markerPanel.heights.medium` | box+text | 128.67 | 402.91 | 104.67 | 35 | `height: 100%; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 13px; font-weight: 800; display: flex; align-items: center; justify-content: center; gap: 6px` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 52 | `mk.markerPanel.heights.medium.sample` ±1 | box | 151.54 | 414.91 | 16 | 11 | `width: 16px; height: 11px; border-radius: 2px; background: #FED170; border: 1.2px solid #1A1714; box-sizing: border-box` |  |
| 53 | `mk.markerPanel.heights.high` | text | 235.33 | 402.91 | 104.67 | 35 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; color: #5B544B; box-sizing: border-box; font-size: 13px; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 6px` | Figtree 13/normal peso 600 ls normal #5B544B |
| 54 | `mk.markerPanel.heights.high.sample` ±1 | box | 264.67 | 412.41 | 16 | 16 | `width: 16px; height: 16px; border-radius: 2px; background: #FED170; border: 1.2px solid #1A1714; box-sizing: border-box` |  |
| 55 | `mk.markerPanel.tip` | box | 17.5 | 454.41 | 327 | 73.22 | `margin-top: 12px; padding: 10px 12px; border-radius: 16px; border: 1.3px dashed #8A7F63; display: flex; align-items: center; gap: 10px` |  |
| 56 | `mk.markerPanel.tip.icon` | icon | 30.8 | 480.03 | 34 | 22 | `flex-shrink: 0` |  |
| 57 | `mk.markerPanel.tip.text` | text | 74.8 | 465.72 | 256.4 | 50.62 | `font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #3D3830` | Figtree 12.5/16.875px peso 600 ls normal #3D3830 |
| 58 | `mk.markerPanel.tip.text.strong` ±1 | inline | 74.8 | 466.64 | 113.61 | 15.01 | `color: #1A1714` | Figtree 12.5/16.875px peso 900→**800** ls normal #1A1714 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `mk.markerPanel.arrow`: caixa visual com `transform: rotate(45deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `mk.markerPanel.title` | 1 | Marca-texto | 36.26 | 17.5 | 146.06 | 128.56 |
| `mk.markerPanel.subtitle` | 1 | Fundo · amarelo “lindo” · média | 54.43 | 17.5 | 192.12 | 174.62 |
| `mk.markerPanel.preview` *(composto)* | 1 | Olhos de ressaca? Vá, de ressaca. | 103.14 | 51.36 | 310.64 | 259.28 |
| `mk.markerPanel.styleLabel` | 1 | ESTILO | 144.45 | 17.5 | 62.22 | 44.72 |
| `mk.markerPanel.styles.fill` | 1 | Fundo | 206.01 | 52.07 | 86.59 | 34.52 |
| `mk.markerPanel.styles.fill.sample` *(composto)* | 1 | ressaca | 181.95 | 41.81 | 96.85 | 55.04 |
| `mk.markerPanel.styles.underline` | 1 | Sublinhado | 206.01 | 149.92 | 212.08 | 62.16 |
| `mk.markerPanel.styles.underline.sample` *(composto)* | 1 | ressaca | 181.95 | 153.48 | 208.52 | 55.04 |
| `mk.markerPanel.styles.wavy` | 1 | Ondulado | 206.01 | 265.56 | 319.77 | 54.21 |
| `mk.markerPanel.styles.wavy.sample` *(composto)* | 1 | ressaca | 181.95 | 265.15 | 320.19 | 55.04 |
| `mk.markerPanel.colorsHeader.label` | 1 | CORES E RÓTULOS | 246.08 | 17.5 | 135.25 | 117.75 |
| `mk.markerPanel.colorsHeader.editLabels` | 1 | Editar rótulos | 246.08 | 265.46 | 344.5 | 79.04 |
| `mk.markerPanel.colors.yellow.label` | 1 | lindo | 279.33 | 62 | 92.9 | 30.9 |
| `mk.markerPanel.colors.yellow.count` | 1 | 5 grifos | 292.83 | 62 | 99.95 | 37.95 |
| `mk.markerPanel.colors.pink.label` | 1 | personagem | 279.33 | 229.5 | 307.61 | 78.11 |
| `mk.markerPanel.colors.pink.count` | 1 | 3 grifos | 292.83 | 229.5 | 267.16 | 37.66 |
| `mk.markerPanel.colors.green.label` | 1 | ideia | 337.33 | 62 | 92.4 | 30.4 |
| `mk.markerPanel.colors.green.count` | 1 | 2 grifos | 350.83 | 62 | 99.88 | 37.88 |
| `mk.markerPanel.colors.lavender.label` | 1 | pro clube | 337.33 | 229.5 | 288.33 | 58.83 |
| `mk.markerPanel.colors.lavender.count` | 1 | 2 grifos | 350.83 | 229.5 | 267.38 | 37.88 |
| `mk.markerPanel.heightLabel` | 1 | ALTURA | 388.66 | 17.5 | 67.36 | 49.86 |
| `mk.markerPanel.heights.low` | 1 | Baixa | 424.97 | 69.67 | 100.99 | 31.32 |
| `mk.markerPanel.heights.medium` | 1 | Média | 424.97 | 173.54 | 210.46 | 36.92 |
| `mk.markerPanel.heights.high` | 1 | Alta | 424.97 | 286.67 | 310.66 | 23.99 |
| `mk.markerPanel.tip.text` *(composto)* | 1 | Gruda nas palavras. Mesmo torto, o traço | 478.52 | 74.8 | 311.01 | 236.21 |
| `mk.markerPanel.tip.text` *(composto)* | 2 | encaixa na linha e acompanha se a fonte | 495.4 | 74.8 | 302.39 | 227.59 |
| `mk.markerPanel.tip.text` *(composto)* | 3 | mudar. | 512.27 | 74.8 | 114.03 | 39.23 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Mesmo painel da 23 (posição, raio, sombra, seta apontando para o marca-texto).
2. Prévia com uma linha real da página: "Olhos de **ressaca**? Vá, de ressaca." (Literata 17) com fundo amarelo `#FED170@.95` em "ressaca".
3. ESTILO (Fundo ativo · Sublinhado · Ondulado, cada um com "ressaca" no estilo; o Ondulado usa Figtree 900 → renderiza 800);
4. CORES E RÓTULOS + link "Editar rótulos": 4 linhas com amostra, rótulo e "N grifos" (5/3/2/2);
5. ALTURA (Baixa · **Média** · Alta) e a dica "**Gruda nas palavras.** Mesmo torto, o traço encaixa na linha…" com ilustração.

## Armadilhas

- Comportamento "gruda nas palavras": traço livre vira grifo ancorado (Anexo 03 §9.4, D-29).
- Prateleira: ver achado da 23b (caneta pintada como ativa).
- ⚠ **Achado da G01:** na 23b a tinta que já estava na página (elipse e risco em "Olhos de ressaca?", ondulado, sublinhado duplo) aparece **amarela**; na 22/23/24/24b e nas miniaturas da 25 ela é **coral** (`ink`). O poço de cor e os pontos de espessura amarelos fazem sentido (ferramenta ativa = marca-texto); a tinta antiga mudar de cor não. Decisão no relatório da G01 (proposta: a tinta existente mantém a cor com que foi feita).

## Diferenças em relação à prancha 22 (seções reutilizadas: page, deskEdge, modePill, done, toolShelf, island)

Estas seções são as mesmas widgets da 22 (fases L22a_pagina_anotada, L22b_topo_modo_anotacao, L22c_prateleira_ferramentas, L22d_ilha_anotacao); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `mk.page.text.doubleUnderline.line1` | bg: "#FF552E" → "#FED170" |
| `mk.page.text.doubleUnderline.line2` | bg: "#FF552E" → "#FED170" |
| `mk.toolShelf.pen` | transform: "translateY(-12px)" → null; transformMatrix: "matrix(1, 0, 0, 1, 0, -12)" → null |
| `mk.toolShelf.marker` | transform: null → "translateY(-12px)"; transformMatrix: null → "matrix(1, 0, 0, 1, 0, -12)" |
| `mk.island.labels.pen` | font: null → {"family": "Figtree", "size": 10.0, "weightCss": 700, "weightRendered": 700, "style": "normal", "lineHeight": "normal", "letterSpacing": "normal", "color": "#6F665B", "whiteSpace": "nowrap"}; texto «» → «Caneta» |
| `mk.island.labels.marker` | font: {"family": "Figtree", "size": 10.0, "weightCss": 700, "weightRendered": 700, "style": "normal", "lineHeight": "normal", "letterSpacing": "normal", "color": "#6F665B", "whiteSpace": "nowrap"} → null; texto «Marcador» → «» |
| `mk.island.colorWell.ink` | bg: "#FF552E" → "#FED170" |
| `mk.island.width.thin.dot` | bg: "#FF552E" → "#FED170" |
| `mk.island.width.medium.dot` | bg: "#FF552E" → "#FED170" |
| `mk.island.width.thick.dot` | bg: "#FF552E" → "#FED170" |

Só na base: `page.text.wavy.touchRing`, `page.text.wavy.touchDot`, `island.labels.pen.pill`.

Só nesta prancha: `island.labels.marker.pill`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `mk.fade` |  |  | aria-hidden=true |
| `mk.markerPanel` | dialog | Ajustes do marca-texto |  |
| `mk.markerPanel.arrow` |  |  | aria-hidden=true |
| `mk.markerPanel.close` |  | Fechar ajustes |  |
| `mk.markerPanel.close.icon` |  |  | aria-hidden=true |
| `mk.markerPanel.preview` | img | Prévia: Olhos de ressaca, com fundo amarelo na palavra ressaca |  |
| `mk.markerPanel.styles` | radiogroup | Estilo do marca-texto |  |
| `mk.markerPanel.styles.fill` | radio |  | aria-checked=true |
| `mk.markerPanel.styles.underline` | radio |  | aria-checked=false |
| `mk.markerPanel.styles.wavy` | radio |  | aria-checked=false |
| `mk.markerPanel.colors` | radiogroup | Cor do marca-texto |  |
| `mk.markerPanel.colors.yellow` | radio | amarelo, rótulo lindo, 5 grifos | aria-checked=true |
| `mk.markerPanel.colors.yellow.swatch` |  |  | aria-hidden=true |
| `mk.markerPanel.colors.pink` | radio | rosa, rótulo personagem, 3 grifos | aria-checked=false |
| `mk.markerPanel.colors.pink.swatch` |  |  | aria-hidden=true |
| `mk.markerPanel.colors.green` | radio | verde, rótulo ideia, 2 grifos | aria-checked=false |
| `mk.markerPanel.colors.green.swatch` |  |  | aria-hidden=true |
| `mk.markerPanel.colors.lavender` | radio | lavanda, rótulo pro clube, 2 grifos | aria-checked=false |
| `mk.markerPanel.colors.lavender.swatch` |  |  | aria-hidden=true |
| `mk.markerPanel.heights` | radiogroup | Altura do fundo |  |
| `mk.markerPanel.heights.low` | radio |  | aria-checked=false |
| `mk.markerPanel.heights.low.sample` |  |  | aria-hidden=true |
| `mk.markerPanel.heights.medium` | radio |  | aria-checked=true |
| `mk.markerPanel.heights.medium.sample` |  |  | aria-hidden=true |
| `mk.markerPanel.heights.high` | radio |  | aria-checked=false |
| `mk.markerPanel.heights.high.sample` |  |  | aria-hidden=true |
| `mk.markerPanel.tip.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `mk.fade` | NeoBox |  |
| `mk.markerPanel` | NeoBox |  |
| `mk.markerPanel.arrow` | NeoBox | Transform: rotate(45deg) |
| `mk.markerPanel.close` | CircleIconButton / NeoBox circular |  |
| `mk.markerPanel.close.icon` | AppSvg(AppIconsLeitor.ic_close, size: 18) |  |
| `mk.markerPanel.preview` | NeoBox + AppText |  |
| `mk.markerPanel.preview.highlight` | TextSpan dentro do AppText.rich do pai |  |
| `mk.markerPanel.styles.fill` | NeoBox + AppText |  |
| `mk.markerPanel.styles.fill.sample.word` | TextSpan dentro do AppText.rich do pai |  |
| `mk.markerPanel.styles.underline` | NeoBox + AppText |  |
| `mk.markerPanel.styles.underline.sample.word` | TextSpan dentro do AppText.rich do pai |  |
| `mk.markerPanel.styles.wavy` | NeoBox + AppText |  |
| `mk.markerPanel.styles.wavy.sample.word` | TextSpan dentro do AppText.rich do pai |  |
| `mk.markerPanel.colors.yellow` | NeoBox |  |
| `mk.markerPanel.colors.yellow.swatch` | CircleIconButton / NeoBox circular |  |
| `mk.markerPanel.colors.pink` | NeoBox |  |
| `mk.markerPanel.colors.pink.swatch` | CircleIconButton / NeoBox circular |  |
| `mk.markerPanel.colors.green` | NeoBox |  |
| `mk.markerPanel.colors.green.swatch` | CircleIconButton / NeoBox circular |  |
| `mk.markerPanel.colors.lavender` | NeoBox |  |
| `mk.markerPanel.colors.lavender.swatch` | CircleIconButton / NeoBox circular |  |
| `mk.markerPanel.heights` | NeoBox |  |
| `mk.markerPanel.heights.low.sample` | NeoBox |  |
| `mk.markerPanel.heights.medium` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `mk.markerPanel.heights.medium.sample` | NeoBox |  |
| `mk.markerPanel.heights.high.sample` | NeoBox |  |
| `mk.markerPanel.tip` | NeoBox |  |
| `mk.markerPanel.tip.icon` | AppSvg(AppIllustrationsLeitor.il_dica_gruda_nas_palavras, size: 34×22) |  |
| `mk.markerPanel.tip.text.strong` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Escolher estilo/cor/altura muda o preset; "Editar rótulos" → edição dos rótulos (não desenhada, D-23).

## Dados

- `pen_presets.highlighter_*`; `highlight_labels` globais do usuário; contagens = grifos da cor em **todos** os livros (D-40).

## Subfases

- **L23b.1** Painel e prévia
- **L23b.2** Estilo
- **L23b.3** Cores e rótulos
- **L23b.4** Altura
- **L23b.5** Dica
- **L23b.6** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('mk.fade', 'mk.markerPanel'), todos os ids de `kRef23b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/23b_ajustes_marcatexto_390x844@3x.png` no recorte da fase (y 100.86–673.63) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L23b.1 Painel e prévia
- [ ] L23b.2 Estilo
- [ ] L23b.3 Cores e rótulos
- [ ] L23b.4 Altura
- [ ] L23b.5 Dica
- [ ] L23b.6 Verificação + relatório
- [ ] Geometria 53/53 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
