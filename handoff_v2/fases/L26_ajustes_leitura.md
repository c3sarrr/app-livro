# FASE L26 — Ajustes de leitura (Aa)

> Tela 26 · prancha `26_ajustes_leitura` (26 · Leitor — ajustes de leitura (Aa), canvas 390×844) · executada na **G14** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L26_ajustes_leitura@3x.png` · `referencia/png/redline/L26_ajustes_leitura_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/26_ajustes_leitura_390x844@{1,2,3}x.png` · `referencia/layout/layout_26_ajustes_leitura.json` · `test/reference/leitor/reference_layout_26_ajustes_leitura.dart` (`kRef26`).
> Arquivos sugeridos: `lib/features/reader/presentation/reader_settings_sheet.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Folha de ajustes com a página viva em cima ("every change shows here at once") e a pílula "● prévia ao vivo".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- The page stays live above the sheet: every change shows here at once -->
<article aria-label="Prévia da página" style="position: absolute; left: 28px; right: 28px; top: 92px; height: 210px; overflow: hidden;">
  <p style="margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em;">Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram aqueles olhos de Capitu. Não me acode imagem capaz de dizer, sem quebra da dignidade do estilo, o que eles foram e me fizeram. Olhos de ressaca? Vá, de ressaca. É o que me dá ideia daquela feição nova. Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, como a vaga que se retira da praia, nos dias de ressaca.</p>
</article>

<span aria-hidden="true" style="position: absolute; left: 50%; top: 54px; transform: translateX(-50%); height: 26px; padding: 0 11px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 11.5px; font-weight: 800; white-space: nowrap;"><span style="width: 7px; height: 7px; border-radius: 50%; background: #FF552E;"></span>prévia ao vivo</span>

<!-- Bottom sheet -->
<section role="dialog" aria-label="Ajustes de leitura" style="position: absolute; left: 10px; right: 10px; bottom: 10px; padding: 10px 18px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box;">
  <span aria-hidden="true" style="display: block; width: 40px; height: 5px; margin: 0 auto; border-radius: 3px; background: #CFC3AE;"></span>

  <div style="margin-top: 8px; display: flex; align-items: center; justify-content: space-between;">
    <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 23px; letter-spacing: -0.5px;">Ajustes <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 28px; letter-spacing: -0.2px;">de leitura</span></h1>
    <button aria-label="Fechar" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 6l12 12M18 6 6 18"></path></svg></button>
  </div>

  <!-- size -->
  <div style="margin-top: 12px; display: flex; align-items: center; gap: 10px;">
    <button aria-label="Diminuir a letra" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 15px; font-weight: 500;">A</button>
    <span role="slider" aria-label="Tamanho da letra" aria-valuemin="1" aria-valuemax="7" aria-valuenow="4" style="flex-grow: 1; height: 48px; border-radius: 999px; border: 1.5px dashed #CFC3AE; box-sizing: border-box; display: flex; align-items: center; justify-content: space-evenly;"><span style="width: 7px; height: 7px; border-radius: 50%; background: #1A1714;  box-sizing: border-box;"></span><span style="width: 7px; height: 7px; border-radius: 50%; background: #1A1714;  box-sizing: border-box;"></span><span style="width: 7px; height: 7px; border-radius: 50%; background: #1A1714;  box-sizing: border-box;"></span><span style="width: 14px; height: 14px; border-radius: 50%; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;"></span><span style="width: 7px; height: 7px; border-radius: 50%; background: #CFC3AE;  box-sizing: border-box;"></span><span style="width: 7px; height: 7px; border-radius: 50%; background: #CFC3AE;  box-sizing: border-box;"></span><span style="width: 7px; height: 7px; border-radius: 50%; background: #CFC3AE;  box-sizing: border-box;"></span></span>
    <button aria-label="Aumentar a letra" style="width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 25px; font-weight: 500;">A</button>
  </div>

  <!-- font -->
  <div style="margin-top: 16px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">FONTE</div>
  <div role="radiogroup" aria-label="Fonte" style="margin-top: 7px; display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 8px;"><button role="radio" aria-checked="true" aria-label="Literata, tela" style="height: 82px; padding: 0; border-radius: 16px; background: {{brand}}; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px;"><span style="font-family: 'Literata', Georgia, serif; font-size: 26px; line-height: 1.1; color: #1A1714;">Aa</span><span style="font-size: 12px; font-weight: 800;">Literata</span><span style="font-size: 10.5px; font-weight: 600; color: #3B3466; margin-top: -1px;">tela</span></button><button role="radio" aria-checked="false" aria-label="Lora, clássica" style="height: 82px; padding: 0; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px;"><span style="font-family: 'Lora', Georgia, serif; font-size: 26px; line-height: 1.1; color: #1A1714;">Aa</span><span style="font-size: 12px; font-weight: 800;">Lora</span><span style="font-size: 10.5px; font-weight: 600; color: #8A8073; margin-top: -1px;">clássica</span></button><button role="radio" aria-checked="false" aria-label="Figtree, sem serifa" style="height: 82px; padding: 0; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px;"><span style="font-family: 'Figtree', sans-serif; font-size: 26px; line-height: 1.1; color: #1A1714;">Aa</span><span style="font-size: 12px; font-weight: 800;">Figtree</span><span style="font-size: 10.5px; font-weight: 600; color: #8A8073; margin-top: -1px;">sem serifa</span></button><button role="radio" aria-checked="false" aria-label="Atkinson, dislexia" style="height: 82px; padding: 0; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px;"><span style="font-family: 'Atkinson Hyperlegible', sans-serif; font-size: 26px; line-height: 1.1; color: #1A1714;">Aa</span><span style="font-size: 12px; font-weight: 800;">Atkinson</span><span style="font-size: 10.5px; font-weight: 600; color: #8A8073; margin-top: -1px;">dislexia</span></button></div>

  <!-- theme -->
  <div style="margin-top: 16px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">PAPEL</div>
  <div role="radiogroup" aria-label="Tema do papel" style="margin-top: 9px; display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px;"><button role="radio" aria-checked="true" aria-label="Tema Creme" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; width: 100%; height: 62px; border-radius: 14px; background: #F8F1E4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px;"><span style="font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #2A2520;">Aa</span><span style="margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #D9CCB4;"></span><span style="margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #D9CCB4;"></span><span style="position: absolute; right: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="12" height="12" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg></span></span><span style="font-size: 12px; font-weight: 800; color: #1A1714;">Creme</span></button><button role="radio" aria-checked="false" aria-label="Tema Branco" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; width: 100%; height: 62px; border-radius: 14px; background: #FFFDF8; border: 1.5px solid #1A1714;  box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px;"><span style="font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #1A1714;">Aa</span><span style="margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #E3DCCD;"></span><span style="margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #E3DCCD;"></span></span><span style="font-size: 12px; font-weight: 700; color: #1A1714;">Branco</span></button><button role="radio" aria-checked="false" aria-label="Tema Sépia" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; width: 100%; height: 62px; border-radius: 14px; background: #EEDDBF; border: 1.5px solid #1A1714;  box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px;"><span style="font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #4A3622;">Aa</span><span style="margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #CDB48C;"></span><span style="margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #CDB48C;"></span></span><span style="font-size: 12px; font-weight: 700; color: #1A1714;">Sépia</span></button><button role="radio" aria-checked="false" aria-label="Tema Noite" style="padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px;"><span style="position: relative; width: 100%; height: 62px; border-radius: 14px; background: #1F1B17; border: 1.5px solid #1A1714;  box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px;"><span style="font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #EDE3D1;">Aa</span><span style="margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #4A433A;"></span><span style="margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #4A433A;"></span></span><span style="font-size: 12px; font-weight: 700; color: #1A1714;">Noite</span></button></div>

  <!-- spacing -->
  <div style="margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">ENTRELINHA</div>
  <div role="radiogroup" aria-label="Entrelinha" style="margin-top: 7px; height: 46px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 3px;"><button role="radio" aria-checked="false" style="padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><path d="M4 8.5H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path><path d="M4 12H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path><path d="M4 15.5H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path></svg>Justo</button><button role="radio" aria-checked="true" style="padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 800;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><path d="M4 6.8H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path><path d="M4 12H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path><path d="M4 17.2H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path></svg>Médio</button><button role="radio" aria-checked="false" style="padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><path d="M4 5H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path><path d="M4 12H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path><path d="M4 19H20" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round"></path></svg>Solto</button></div>
  <div style="margin-top: 12px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">MARGENS</div>
  <div role="radiogroup" aria-label="Margens" style="margin-top: 7px; height: 46px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 3px;"><button role="radio" aria-checked="false" style="padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="3" fill="none" stroke="#1A1714" stroke-width="1.8"></rect><path d="M5 8.5H19" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path><path d="M5 12H19" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path><path d="M5 15.5H19" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path></svg>Estreita</button><button role="radio" aria-checked="true" style="padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 800;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="3" fill="none" stroke="#1A1714" stroke-width="1.8"></rect><path d="M7 8.5H17" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path><path d="M7 12H17" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path><path d="M7 15.5H17" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path></svg>Média</button><button role="radio" aria-checked="false" style="padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="3" fill="none" stroke="#1A1714" stroke-width="1.8"></rect><path d="M8.8 8.5H15.2" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path><path d="M8.8 12H15.2" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path><path d="M8.8 15.5H15.2" stroke="#1A1714" stroke-width="2" stroke-linecap="round"></path></svg>Larga</button></div>
</section>
```

## Especificação pixel a pixel

Seção `rs.page` — retângulo absoluto no canvas 390×844: **x=28, y=92, w=334, h=210**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `rs.page` | box | 0 | 0 | 334 | 210 | `position: absolute; left: 28px; right: 28px; top: 92px; height: 210px; overflow: hidden` |  |
| 2 | `rs.page.text` | text | 0 | 0 | 334 | 493.64 | `margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em` | Literata (opsz 20.5) 20.5/35.26px peso 400 ls normal #2A2520 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `rs.page.text` | 1 | Retórica dos namorados, dá-me | 26.54 | 26.65 | 332 | 305.35 |
| `rs.page.text` | 2 | uma comparação exata e poética | 61.8 | 0 | 312.39 | 312.39 |
| `rs.page.text` | 3 | para dizer o que foram aqueles | 97.06 | 0 | 294.1 | 294.1 |
| `rs.page.text` | 4 | olhos de Capitu. Não me acode | 132.32 | 0 | 293.2 | 293.2 |
| `rs.page.text` | 5 | imagem capaz de dizer, sem | 167.58 | 0 | 267.46 | 267.46 |
| `rs.page.text` | 6 | quebra da dignidade do estilo, o | 202.84 | 0 | 305.61 | 305.61 |
| `rs.page.text` | 7 | que eles foram e me fizeram. *(oculta: recortada)* | 238.1 | 0 | 274.05 | 274.05 |
| `rs.page.text` | 8 | Olhos de ressaca? Vá, de ressaca. É *(oculta: recortada)* | 273.36 | 0 | 329.5 | 329.5 |
| `rs.page.text` | 9 | o que me dá ideia daquela feição *(oculta: recortada)* | 308.62 | 0 | 308.62 | 308.62 |
| `rs.page.text` | 10 | nova. Traziam não sei que fluido *(oculta: recortada)* | 343.88 | 0 | 313.75 | 313.75 |
| `rs.page.text` | 11 | misterioso e enérgico, uma força *(oculta: recortada)* | 379.14 | 0 | 315.35 | 315.35 |
| `rs.page.text` | 12 | que arrastava para dentro, como a *(oculta: recortada)* | 414.4 | 0 | 327.57 | 327.57 |
| `rs.page.text` | 13 | vaga que se retira da praia, nos *(oculta: recortada)* | 449.66 | 0 | 296.32 | 296.32 |
| `rs.page.text` | 14 | dias de ressaca. *(oculta: recortada)* | 484.92 | 0 | 147.93 | 147.93 |

Seção `rs.livePill` — retângulo absoluto no canvas 390×844: **x=195, y=54, w=112.78, h=26**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `rs.livePill` ±1 | box+text | 0 | 0 | 112.78 | 26 | `position: absolute; left: 50%; top: 54px; transform: translateX(-50%); height: 26px; padding: 0 11px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 11.5px; font-weight: 800; white-space: nowrap` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 4 | `rs.livePill.dot` | box | 12.5 | 9.5 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #FF552E` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `rs.livePill`: caixa visual com `transform: translateX(-50%)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `rs.livePill.dot`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `rs.livePill` | 1 | prévia ao vivo | 17.03 | 25.5 | 100.28 | 74.78 |

Seção `rs.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=286.8, w=370, h=547.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `rs.sheet` | box | 0 | 0 | 370 | 547.2 | `position: absolute; left: 10px; right: 10px; bottom: 10px; padding: 10px 18px 20px; border-radius: 32px 32px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box` |  |
| 6 | `rs.sheet.grabber` | box | 165 | 11.5 | 40 | 5 | `display: block; width: 40px; height: 5px; margin: 0 auto; border-radius: 3px; background: #CFC3AE` |  |
| 7 | `rs.sheet.header` | box | 19.5 | 24.5 | 331 | 44 | `margin-top: 8px; display: flex; align-items: center; justify-content: space-between` |  |
| 8 | `rs.sheet.title` ±1 | text | 19.5 | 28.3 | 181.16 | 36.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 23px; letter-spacing: -0.5px` | Bricolage (opsz 23) 23/normal peso 800 ls -0.5px #1A1714 |
| 9 | `rs.sheet.title.serif` ±1 | inline | 105.44 | 28.3 | 95.22 | 36.4 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 28px; letter-spacing: -0.2px` | Instrument Serif itálico 28/normal peso 400 ls -0.2px #1A1714 |
| 10 | `rs.sheet.close` | box | 306.5 | 24.5 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 11 | `rs.sheet.close.icon` | icon | 319.5 | 37.5 | 18 | 18 | `—` |  |
| 12 | `rs.sheet.size` | box | 19.5 | 80.5 | 331 | 48 | `margin-top: 12px; display: flex; align-items: center; gap: 10px` |  |
| 13 | `rs.sheet.size.smaller` | box+text | 19.5 | 80.5 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 15px; font-weight: 500` | Literata (opsz 15) 15/normal peso 500 ls normal #1A1714 |
| 14 | `rs.sheet.size.steps` | box | 77.5 | 80.5 | 215 | 48 | `flex-grow: 1; height: 48px; border-radius: 999px; border: 1.5px dashed #CFC3AE; box-sizing: border-box; display: flex; align-items: center; justify-content: space-evenly` |  |
| 15 | `rs.sheet.size.step1` | box | 98.5 | 101 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #1A1714; box-sizing: border-box` |  |
| 16 | `rs.sheet.size.step2` | box | 125 | 101 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #1A1714; box-sizing: border-box` |  |
| 17 | `rs.sheet.size.step3` | box | 151.5 | 101 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #1A1714; box-sizing: border-box` |  |
| 18 | `rs.sheet.size.step4` | box | 178 | 97.5 | 14 | 14 | `width: 14px; height: 14px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 19 | `rs.sheet.size.step5` | box | 211.5 | 101 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #CFC3AE; box-sizing: border-box` |  |
| 20 | `rs.sheet.size.step6` | box | 238 | 101 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #CFC3AE; box-sizing: border-box` |  |
| 21 | `rs.sheet.size.step7` | box | 264.5 | 101 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #CFC3AE; box-sizing: border-box` |  |
| 22 | `rs.sheet.size.larger` | box+text | 302.5 | 80.5 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Literata', Georgia, serif; font-size: 25px; font-weight: 500` | Literata (opsz 25) 25/normal peso 500 ls normal #1A1714 |
| 23 | `rs.sheet.fontLabel` | text | 19.5 | 144.5 | 331 | 13.2 | `margin-top: 16px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 24 | `rs.sheet.fonts` | box | 19.5 | 164.7 | 331 | 82 | `margin-top: 7px; display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 8px` |  |
| 25 | `rs.sheet.fonts.literata` | box | 19.5 | 164.7 | 76.75 | 82 | `height: 82px; padding: 0; border-radius: 16px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px` |  |
| 26 | `rs.sheet.fonts.literata.sample` ±1 | text | 41.52 | 176.39 | 32.71 | 28.6 | `font-family: 'Literata', Georgia, serif; font-size: 26px; line-height: 1.1; color: #1A1714` | Literata (opsz 26) 26/28.6px peso 400 ls normal #1A1714 |
| 27 | `rs.sheet.fonts.literata.name` ±1 | text | 35.9 | 207 | 43.96 | 14.4 | `font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 28 | `rs.sheet.fonts.literata.caption` ±1 | text | 48.96 | 222.39 | 17.82 | 12.61 | `font-size: 10.5px; font-weight: 600; color: #3B3466; margin-top: -1px` | Figtree 10.5/normal peso 600 ls normal #3B3466 |
| 29 | `rs.sheet.fonts.lora` | box | 104.25 | 164.7 | 76.75 | 82 | `height: 82px; padding: 0; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px` |  |
| 30 | `rs.sheet.fonts.lora.sample` ±1 | text | 127.43 | 176.39 | 30.39 | 28.6 | `font-family: 'Lora', Georgia, serif; font-size: 26px; line-height: 1.1; color: #1A1714` | Lora 26/28.6px peso 400 ls normal #1A1714 |
| 31 | `rs.sheet.fonts.lora.name` ±1 | text | 130.24 | 207 | 24.78 | 14.4 | `font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 32 | `rs.sheet.fonts.lora.caption` ±1 | text | 123.99 | 222.39 | 37.27 | 12.61 | `font-size: 10.5px; font-weight: 600; color: #8A8073; margin-top: -1px` | Figtree 10.5/normal peso 600 ls normal #8A8073 |
| 33 | `rs.sheet.fonts.figtree` | box | 189 | 164.7 | 76.75 | 82 | `height: 82px; padding: 0; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px` |  |
| 34 | `rs.sheet.fonts.figtree.sample` ±1 | text | 212.03 | 176.39 | 30.69 | 28.6 | `font-family: 'Figtree', sans-serif; font-size: 26px; line-height: 1.1; color: #1A1714` | Figtree 26/28.6px peso 400 ls normal #1A1714 |
| 35 | `rs.sheet.fonts.figtree.name` ±1 | text | 207.12 | 207 | 40.5 | 14.4 | `font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 36 | `rs.sheet.fonts.figtree.caption` ±1 | text | 202.96 | 222.39 | 48.84 | 12.61 | `font-size: 10.5px; font-weight: 600; color: #8A8073; margin-top: -1px` | Figtree 10.5/normal peso 600 ls normal #8A8073 |
| 37 | `rs.sheet.fonts.atkinson` | box | 273.75 | 164.7 | 76.75 | 82 | `height: 82px; padding: 0; border-radius: 16px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 2px` |  |
| 38 | `rs.sheet.fonts.atkinson.sample` ±1 | text | 297.15 | 176.39 | 29.95 | 28.6 | `font-family: 'Atkinson Hyperlegible', sans-serif; font-size: 26px; line-height: 1.1; color: #1A1714` | Atkinson Hyperlegible 26/28.6px peso 400 ls normal #1A1714 |
| 39 | `rs.sheet.fonts.atkinson.name` ±1 | text | 286.98 | 207 | 50.29 | 14.4 | `font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 40 | `rs.sheet.fonts.atkinson.caption` ±1 | text | 294.45 | 222.39 | 35.35 | 12.61 | `font-size: 10.5px; font-weight: 600; color: #8A8073; margin-top: -1px` | Figtree 10.5/normal peso 600 ls normal #8A8073 |
| 41 | `rs.sheet.paperLabel` | text | 19.5 | 262.7 | 331 | 13.2 | `margin-top: 16px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 42 | `rs.sheet.papers` | box | 19.5 | 284.9 | 331 | 82.4 | `margin-top: 9px; display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px` |  |
| 43 | `rs.sheet.papers.cream` | box | 19.5 | 284.9 | 75.25 | 82.4 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 44 | `rs.sheet.papers.cream.card` | box | 19.5 | 284.9 | 75.25 | 62 | `position: relative; width: 100%; height: 62px; border-radius: 14px; background: #F8F1E4; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px` |  |
| 45 | `rs.sheet.papers.cream.sample` | text | 33 | 298.4 | 48.25 | 18 | `font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #2A2520` | Literata (opsz 18) 18/18px peso 400 ls normal #2A2520 |
| 46 | `rs.sheet.papers.cream.line1` | box | 33 | 323.4 | 48.25 | 3 | `margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #D9CCB4` |  |
| 47 | `rs.sheet.papers.cream.line2` | box | 33 | 330.4 | 33.77 | 3 | `margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #D9CCB4` |  |
| 48 | `rs.sheet.papers.cream.check` | box | 78.25 | 279.4 | 22 | 22 | `position: absolute; right: -7px; top: -7px; width: 22px; height: 22px; border-radius: 50%; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 49 | `rs.sheet.papers.cream.check.icon` | icon | 83.25 | 284.4 | 12 | 12 | `—` |  |
| 50 | `rs.sheet.papers.cream.name` ±1 | text | 38.37 | 352.9 | 37.51 | 14.4 | `font-size: 12px; font-weight: 800; color: #1A1714` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 51 | `rs.sheet.papers.white` | box | 104.75 | 284.9 | 75.25 | 82.4 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 52 | `rs.sheet.papers.white.card` | box | 104.75 | 284.9 | 75.25 | 62 | `position: relative; width: 100%; height: 62px; border-radius: 14px; background: #FFFDF8; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px` |  |
| 53 | `rs.sheet.papers.white.sample` | text | 118.25 | 298.4 | 48.25 | 18 | `font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #1A1714` | Literata (opsz 18) 18/18px peso 400 ls normal #1A1714 |
| 54 | `rs.sheet.papers.white.line1` | box | 118.25 | 323.4 | 48.25 | 3 | `margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #E3DCCD` |  |
| 55 | `rs.sheet.papers.white.line2` | box | 118.25 | 330.4 | 33.77 | 3 | `margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #E3DCCD` |  |
| 56 | `rs.sheet.papers.white.name` ±1 | text | 123.06 | 352.9 | 38.63 | 14.4 | `font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 57 | `rs.sheet.papers.sepia` | box | 190 | 284.9 | 75.25 | 82.4 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 58 | `rs.sheet.papers.sepia.card` | box | 190 | 284.9 | 75.25 | 62 | `position: relative; width: 100%; height: 62px; border-radius: 14px; background: #EEDDBF; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px` |  |
| 59 | `rs.sheet.papers.sepia.sample` | text | 203.5 | 298.4 | 48.25 | 18 | `font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #4A3622` | Literata (opsz 18) 18/18px peso 400 ls normal #4A3622 |
| 60 | `rs.sheet.papers.sepia.line1` | box | 203.5 | 323.4 | 48.25 | 3 | `margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #CDB48C` |  |
| 61 | `rs.sheet.papers.sepia.line2` | box | 203.5 | 330.4 | 33.77 | 3 | `margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #CDB48C` |  |
| 62 | `rs.sheet.papers.sepia.name` ±1 | text | 212.26 | 352.9 | 30.72 | 14.4 | `font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 63 | `rs.sheet.papers.night` | box | 275.25 | 284.9 | 75.25 | 82.4 | `padding: 0; border: none; background: transparent; display: flex; flex-direction: column; align-items: center; gap: 6px` |  |
| 64 | `rs.sheet.papers.night.card` | box | 275.25 | 284.9 | 75.25 | 62 | `position: relative; width: 100%; height: 62px; border-radius: 14px; background: #1F1B17; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; flex-direction: column; justify-content: center; padding: 0 12px` |  |
| 65 | `rs.sheet.papers.night.sample` | text | 288.75 | 298.4 | 48.25 | 18 | `font-family: 'Literata', Georgia, serif; font-size: 18px; line-height: 1; color: #EDE3D1` | Literata (opsz 18) 18/18px peso 400 ls normal #EDE3D1 |
| 66 | `rs.sheet.papers.night.line1` | box | 288.75 | 323.4 | 48.25 | 3 | `margin-top: 7px; height: 3px; width: 100%; border-radius: 2px; background: #4A433A` |  |
| 67 | `rs.sheet.papers.night.line2` | box | 288.75 | 330.4 | 33.77 | 3 | `margin-top: 4px; height: 3px; width: 70%; border-radius: 2px; background: #4A433A` |  |
| 68 | `rs.sheet.papers.night.name` ±1 | text | 297.5 | 352.9 | 30.76 | 14.4 | `font-size: 12px; font-weight: 700; color: #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 69 | `rs.sheet.spacingLabel` | text | 19.5 | 381.3 | 331 | 13.2 | `margin-top: 14px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 70 | `rs.sheet.spacing` | box | 19.5 | 401.5 | 331 | 46 | `margin-top: 7px; height: 46px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 3px` |  |
| 71 | `rs.sheet.spacing.tight` | box+text | 24 | 406 | 105.33 | 37 | `padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 72 | `rs.sheet.spacing.tight.icon` ±1 | icon | 47.53 | 415.5 | 18 | 18 | `—` |  |
| 73 | `rs.sheet.spacing.medium` | box+text | 132.33 | 406 | 105.33 | 37 | `padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 74 | `rs.sheet.spacing.medium.icon` ±1 | icon | 153.77 | 415.5 | 18 | 18 | `—` |  |
| 75 | `rs.sheet.spacing.loose` | box+text | 240.67 | 406 | 105.33 | 37 | `padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 76 | `rs.sheet.spacing.loose.icon` ±1 | icon | 265.18 | 415.5 | 18 | 18 | `—` |  |
| 77 | `rs.sheet.marginsLabel` | text | 19.5 | 459.5 | 331 | 13.2 | `margin-top: 12px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 78 | `rs.sheet.margins` | box | 19.5 | 479.7 | 331 | 46 | `margin-top: 7px; height: 46px; padding: 3px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 3px` |  |
| 79 | `rs.sheet.margins.narrow` | box+text | 24 | 484.2 | 105.33 | 37 | `padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 80 | `rs.sheet.margins.narrow.icon` ±1 | icon | 40.91 | 493.7 | 18 | 18 | `—` |  |
| 81 | `rs.sheet.margins.medium` | box+text | 132.33 | 484.2 | 105.33 | 37 | `padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 82 | `rs.sheet.margins.medium.icon` ±1 | icon | 154.04 | 493.7 | 18 | 18 | `—` |  |
| 83 | `rs.sheet.margins.wide` | box+text | 240.67 | 484.2 | 105.33 | 37 | `padding: 0; border-radius: 999px; background: transparent; border: 1.5px solid transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 7px; font-size: 13px; font-weight: 700` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 84 | `rs.sheet.margins.wide.icon` ±1 | icon | 264.04 | 493.7 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `rs.sheet.title` *(composto)* | 1 | Ajustes de leitura | 56.02 | 19.5 | 200.66 | 181.16 |
| `rs.sheet.size.smaller` | 1 | A | 111.02 | 37.96 | 49.04 | 11.08 |
| `rs.sheet.size.larger` | 1 | A | 115.37 | 317.38 | 335.62 | 18.24 |
| `rs.sheet.fontLabel` | 1 | FONTE | 154.95 | 19.5 | 61.91 | 42.41 |
| `rs.sheet.fonts.literata.sample` | 1 | Aa | 201.99 | 41.52 | 74.23 | 32.71 |
| `rs.sheet.fonts.literata.name` | 1 | Literata | 218.39 | 35.9 | 79.85 | 43.95 |
| `rs.sheet.fonts.literata.caption` | 1 | tela | 232.37 | 48.96 | 66.79 | 17.83 |
| `rs.sheet.fonts.lora.sample` | 1 | Aa | 200.21 | 127.43 | 157.82 | 30.39 |
| `rs.sheet.fonts.lora.name` | 1 | Lora | 218.39 | 130.24 | 155.01 | 24.77 |
| `rs.sheet.fonts.lora.caption` | 1 | clássica | 232.37 | 123.99 | 161.26 | 37.27 |
| `rs.sheet.fonts.figtree.sample` | 1 | Aa | 199.8 | 212.03 | 242.72 | 30.69 |
| `rs.sheet.fonts.figtree.name` | 1 | Figtree | 218.39 | 207.12 | 247.62 | 40.5 |
| `rs.sheet.fonts.figtree.caption` | 1 | sem serifa | 232.37 | 202.96 | 251.8 | 48.84 |
| `rs.sheet.fonts.atkinson.sample` | 1 | Aa | 199.27 | 297.15 | 327.1 | 29.95 |
| `rs.sheet.fonts.atkinson.name` | 1 | Atkinson | 218.39 | 286.98 | 337.27 | 50.29 |
| `rs.sheet.fonts.atkinson.caption` | 1 | dislexia | 232.37 | 294.45 | 329.8 | 35.35 |
| `rs.sheet.paperLabel` | 1 | PAPEL | 273.15 | 19.5 | 59.51 | 40.01 |
| `rs.sheet.papers.cream.sample` | 1 | Aa | 315.22 | 45.72 | 68.53 | 22.81 |
| `rs.sheet.papers.cream.name` | 1 | Creme | 364.3 | 38.37 | 75.88 | 37.51 |
| `rs.sheet.papers.white.sample` | 1 | Aa | 315.22 | 130.97 | 153.78 | 22.81 |
| `rs.sheet.papers.white.name` | 1 | Branco | 364.3 | 123.06 | 161.69 | 38.63 |
| `rs.sheet.papers.sepia.sample` | 1 | Aa | 315.22 | 216.22 | 239.03 | 22.81 |
| `rs.sheet.papers.sepia.name` | 1 | Sépia | 364.3 | 212.26 | 242.99 | 30.73 |
| `rs.sheet.papers.night.sample` | 1 | Aa | 315.22 | 301.47 | 324.28 | 22.81 |
| `rs.sheet.papers.night.name` | 1 | Noite | 364.3 | 297.5 | 328.25 | 30.75 |
| `rs.sheet.spacingLabel` | 1 | ENTRELINHA | 391.75 | 19.5 | 100.76 | 81.26 |
| `rs.sheet.spacing.tight` | 1 | Justo | 429.05 | 72.53 | 105.81 | 33.28 |
| `rs.sheet.spacing.medium` | 1 | Médio | 429.05 | 178.77 | 216.23 | 37.46 |
| `rs.sheet.spacing.loose` | 1 | Solto | 429.05 | 290.18 | 321.49 | 31.31 |
| `rs.sheet.marginsLabel` | 1 | MARGENS | 469.95 | 19.5 | 82.32 | 62.82 |
| `rs.sheet.margins.narrow` | 1 | Estreita | 507.25 | 65.91 | 112.42 | 46.51 |
| `rs.sheet.margins.medium` | 1 | Média | 507.25 | 179.04 | 215.96 | 36.92 |
| `rs.sheet.margins.wide` | 1 | Larga | 507.25 | 289.04 | 322.62 | 33.58 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Página de prévia (mesmo motor do leitor) com 7 linhas visíveis acima da folha; pílula "prévia ao vivo" com ponto.
2. Folha: `left/right 10 · bottom 10`, raio 32/32/44/44, sombra 0/4, alça no topo; título "**Ajustes** *de leitura*" (Bricolage 23 + Instrument Serif itálico 28) + fechar.
3. Tamanho: "A" pequeno/grande + 7 pontos (`slider`, valor 4 ativo lavanda). FONTE: 4 cartões com "Aa" na própria fonte (Literata 26, Lora 26, Figtree 26, Atkinson 26) + nome + legenda.
4. PAPEL: 4 cartões (Creme ✓ com selo `brand`, Branco, Sépia `#EEDDBF`, Noite `#1F1B17`) com "Aa" e 2 linhas; ENTRELINHA e MARGENS: segmentados de 3 com ícones.

## Armadilhas

- A prévia é o mesmo motor (não um `Text` à parte).
- Lora: fonte variável sem modificação (Reserved Font Name).
- Fio de navalha em `rs.page.text` linha 7 «que eles foram e me fizeram.»: sobra 59.95 px · estouro com a próxima palavra 0.71 px.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `rs.page.text`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `rs.page` |  | Prévia da página |  |
| `rs.livePill` |  |  | aria-hidden=true |
| `rs.sheet` | dialog | Ajustes de leitura |  |
| `rs.sheet.grabber` |  |  | aria-hidden=true |
| `rs.sheet.close` |  | Fechar |  |
| `rs.sheet.close.icon` |  |  | aria-hidden=true |
| `rs.sheet.size.smaller` |  | Diminuir a letra |  |
| `rs.sheet.size.steps` | slider | Tamanho da letra | aria-valuemin=1, aria-valuemax=7, aria-valuenow=4 |
| `rs.sheet.size.larger` |  | Aumentar a letra |  |
| `rs.sheet.fonts` | radiogroup | Fonte |  |
| `rs.sheet.fonts.literata` | radio | Literata, tela | aria-checked=true |
| `rs.sheet.fonts.lora` | radio | Lora, clássica | aria-checked=false |
| `rs.sheet.fonts.figtree` | radio | Figtree, sem serifa | aria-checked=false |
| `rs.sheet.fonts.atkinson` | radio | Atkinson, dislexia | aria-checked=false |
| `rs.sheet.papers` | radiogroup | Tema do papel |  |
| `rs.sheet.papers.cream` | radio | Tema Creme | aria-checked=true |
| `rs.sheet.papers.cream.check.icon` |  |  | aria-hidden=true |
| `rs.sheet.papers.white` | radio | Tema Branco | aria-checked=false |
| `rs.sheet.papers.sepia` | radio | Tema Sépia | aria-checked=false |
| `rs.sheet.papers.night` | radio | Tema Noite | aria-checked=false |
| `rs.sheet.spacing` | radiogroup | Entrelinha |  |
| `rs.sheet.spacing.tight` | radio |  | aria-checked=false |
| `rs.sheet.spacing.tight.icon` |  |  | aria-hidden=true |
| `rs.sheet.spacing.medium` | radio |  | aria-checked=true |
| `rs.sheet.spacing.medium.icon` |  |  | aria-hidden=true |
| `rs.sheet.spacing.loose` | radio |  | aria-checked=false |
| `rs.sheet.spacing.loose.icon` |  |  | aria-hidden=true |
| `rs.sheet.margins` | radiogroup | Margens |  |
| `rs.sheet.margins.narrow` | radio |  | aria-checked=false |
| `rs.sheet.margins.narrow.icon` |  |  | aria-hidden=true |
| `rs.sheet.margins.medium` | radio |  | aria-checked=true |
| `rs.sheet.margins.medium.icon` |  |  | aria-hidden=true |
| `rs.sheet.margins.wide` | radio |  | aria-checked=false |
| `rs.sheet.margins.wide.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `rs.livePill` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: translateX(-50%) |
| `rs.livePill.dot` | CircleIconButton / NeoBox circular |  |
| `rs.sheet` | NeoBox |  |
| `rs.sheet.grabber` | NeoBox |  |
| `rs.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `rs.sheet.close` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.close.icon` | AppSvg(AppIconsLeitor.ic_close_round, size: 18) |  |
| `rs.sheet.size.smaller` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.steps` | NeoBox |  |
| `rs.sheet.size.step1` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.step2` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.step3` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.step4` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.step5` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.step6` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.step7` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.size.larger` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.fonts.literata` | NeoBox |  |
| `rs.sheet.fonts.lora` | NeoBox |  |
| `rs.sheet.fonts.figtree` | NeoBox |  |
| `rs.sheet.fonts.atkinson` | NeoBox |  |
| `rs.sheet.papers.cream.card` | NeoBox |  |
| `rs.sheet.papers.cream.line1` | NeoBox |  |
| `rs.sheet.papers.cream.line2` | NeoBox |  |
| `rs.sheet.papers.cream.check` | CircleIconButton / NeoBox circular |  |
| `rs.sheet.papers.cream.check.icon` | AppSvg(AppIconsLeitor.ic_check_small, size: 12) |  |
| `rs.sheet.papers.white.card` | NeoBox |  |
| `rs.sheet.papers.white.line1` | NeoBox |  |
| `rs.sheet.papers.white.line2` | NeoBox |  |
| `rs.sheet.papers.sepia.card` | NeoBox |  |
| `rs.sheet.papers.sepia.line1` | NeoBox |  |
| `rs.sheet.papers.sepia.line2` | NeoBox |  |
| `rs.sheet.papers.night.card` | NeoBox |  |
| `rs.sheet.papers.night.line1` | NeoBox |  |
| `rs.sheet.papers.night.line2` | NeoBox |  |
| `rs.sheet.spacing` | NeoBox |  |
| `rs.sheet.spacing.tight` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rs.sheet.spacing.tight.icon` | AppSvg(AppIconsLeitor.ic_spacing_tight, size: 18) |  |
| `rs.sheet.spacing.medium` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rs.sheet.spacing.medium.icon` | AppSvg(AppIconsLeitor.ic_spacing_medium, size: 18) |  |
| `rs.sheet.spacing.loose` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rs.sheet.spacing.loose.icon` | AppSvg(AppIconsLeitor.ic_spacing_loose, size: 18) |  |
| `rs.sheet.margins` | NeoBox |  |
| `rs.sheet.margins.narrow` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rs.sheet.margins.narrow.icon` | AppSvg(AppIconsLeitor.ic_margins_narrow, size: 18) |  |
| `rs.sheet.margins.medium` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rs.sheet.margins.medium.icon` | AppSvg(AppIconsLeitor.ic_margins_medium, size: 18) |  |
| `rs.sheet.margins.wide` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `rs.sheet.margins.wide.icon` | AppSvg(AppIconsLeitor.ic_margins_wide, size: 18) |  |

## Interações

- Cada mudança refaz a paginação mantendo o localizador; valores D-20.

## Dados

- `reader_settings` (global por usuário).

## Subfases

- **L26.1** Página viva + pílula
- **L26.2** Folha e título
- **L26.3** Tamanho
- **L26.4** Fonte
- **L26.5** Papel
- **L26.6** Entrelinha e margens
- **L26.7** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('rs.page', 'rs.livePill', 'rs.sheet'), todos os ids de `kRef26.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/26_ajustes_leitura_390x844@3x.png` no recorte da fase (y 46–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L26.1 Página viva + pílula
- [ ] L26.2 Folha e título
- [ ] L26.3 Tamanho
- [ ] L26.4 Fonte
- [ ] L26.5 Papel
- [ ] L26.6 Entrelinha e margens
- [ ] L26.7 Verificação + relatório
- [ ] Geometria 83/83 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
