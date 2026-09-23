# FASE 7 — Seção 5: "Seu dia de leitura" (dial da meta, chips, gráfico semanal, selo)

> Pré-requisito: FASE 6 aprovada.
> Referências: `secoes/F07_seu_dia@3x.png` · `redline/F07_seu_dia_redline@3x.png`.
> Arquivo: `sections/reading_day_card.dart` (pode dividir em `goal_dial.dart`, `week_chart.dart`).

A seção mais densa da tela. Siga as subfases em ordem e **não** junte etapas.

---

## HTML literal da seção

`{{weekColor}}` = `homeThemeProvider.weekColor` (padrão `#B6ACE4`). A barra "Hoje" usa `#FF552E` fixo.

```html
    <!-- Today: goal + streak + week -->
    <section aria-label="Seu dia de leitura" style="position: relative; margin-top: 36px; background: #FED170; border: 1.5px solid #1A1714; border-radius: 28px; box-shadow: 4px 4px 0 #1A1714; padding: 18px; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px; overflow: hidden;">
      <div aria-hidden="true" style="position: absolute; right: -46px; top: -46px; width: 150px; height: 150px; border-radius: 50%; border: 1.5px solid rgba(26,23,20,0.14);"></div>
      <div aria-hidden="true" style="position: absolute; right: -20px; top: -20px; width: 98px; height: 98px; border-radius: 50%; border: 1.5px solid rgba(26,23,20,0.14);"></div>

      <div style="position: relative; display: flex; align-items: center; justify-content: space-between;">
        <h3 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Seu dia de <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 23px; letter-spacing: -0.2px;">leitura</span></h3>
        <span style="display: flex; align-items: center; gap: 5px; height: 32px; padding: 0 11px 0 8px; box-sizing: border-box; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; font-size: 13px; font-weight: 800;">
          <svg width="17" height="17" sc-camel-view-box="0 0 24 24" fill="#FF552E" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round" aria-hidden="true"><path d="M8.5 14.5A2.5 2.5 0 0 0 11 12c0-1.38-.5-2-1-3-1.07-2.14-.22-4.05 2-6 .5 2.5 2 4.9 4 6.5 2 1.6 3 3.5 3 5.5a7 7 0 1 1-14 0c0-1.15.43-2.29 1-3a2.5 2.5 0 0 0 2.5 2.5z"></path></svg>
          12 dias
        </span>
      </div>

      <div style="position: relative; display: flex; align-items: center; gap: 18px;">
        <!-- Goal dial -->
        <div style="position: relative; width: 112px; height: 112px; flex-shrink: 0;">
          <svg width="112" height="112" sc-camel-view-box="0 0 112 112" aria-hidden="true">
            <circle cx="56" cy="56" r="54" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.5"></circle>
            <circle cx="56" cy="56" r="44" fill="none" stroke="#1A1714" stroke-width="2" stroke-dasharray="1.5 7.71" opacity="0.35"></circle>
            <circle cx="56" cy="56" r="44" fill="none" stroke="#1A1714" stroke-width="10" stroke-linecap="round" stroke-dasharray="165.9 276.5" transform="rotate(-90 56 56)"></circle>
            <circle cx="30.1" cy="91.6" r="6" fill="#FF552E" stroke="#1A1714" stroke-width="1.5"></circle>
          </svg>
          <div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center;">
            <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 1; letter-spacing: -1px;">18</span>
            <span style="font-size: 11px; font-weight: 700; color: #4A4238;">de 30 min</span>
          </div>
        </div>
        <div style="display: flex; flex-direction: column; gap: 10px; min-width: 0;">
          <p style="margin: 0; font-size: 15px; font-weight: 600; line-height: 1.3; text-wrap: pretty;">Faltam <strong style="font-weight: 800;">12 min</strong> para fechar a meta de hoje.</p>
          <div style="display: flex; gap: 6px; flex-wrap: wrap;">
            <span style="font-size: 12px; font-weight: 700; padding: 5px 9px; border-radius: 999px; background: rgba(255,250,241,0.7); border: 1.2px solid #1A1714;">24 páginas</span>
            <span style="font-size: 12px; font-weight: 700; padding: 5px 9px; border-radius: 999px; background: rgba(255,250,241,0.7); border: 1.2px solid #1A1714;">2 destaques</span>
          </div>
        </div>
      </div>

      <!-- Week chart -->
      <div style="position: relative; background: #FFFAF1; border: 1.5px solid #1A1714; border-radius: 22px; padding: 14px 14px 12px; box-sizing: border-box; display: flex; flex-direction: column; gap: 8px;">
        <div style="display: flex; justify-content: space-between; align-items: baseline;">
          <span style="font-size: 13px; font-weight: 800;">Esta semana</span>
          <span style="font-size: 12px; font-weight: 600; color: #5B544B;">4h 00min no total</span>
        </div>
        <div aria-label="Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, sexta 38, sábado 55, hoje 18 de 30" style="position: relative; display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 8px; align-items: end; height: 80px;">
          <div aria-hidden="true" style="position: absolute; left: -4px; right: -4px; bottom: 38px; border-top: 1.5px dashed #1A1714; opacity: 0.45;"></div>
          <div style="height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden;"><div style="width: 100%; height: 43px; background: {{weekColor}}; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px;"></div></div>
          <div style="height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden;"><div style="width: 100%; height: 60px; background: {{weekColor}}; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px;"></div></div>
          <div style="height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden;"><div style="width: 100%; height: 40px; background: {{weekColor}}; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px;"></div></div>
          <div style="height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden;"><div style="width: 100%; height: 30px; background: {{weekColor}}; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px;"></div></div>
          <div style="height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden;"><div style="width: 100%; height: 51px; background: {{weekColor}}; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px;"></div></div>
          <div style="height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden;"><div style="width: 100%; height: 73px; background: {{weekColor}}; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px;"></div></div>
          <div style="height: 80px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #FDE2B2 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden;"><div style="width: 100%; height: 24px; background: #FF552E; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px;"></div></div>
        </div>
        <div style="display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 8px; text-align: center; font-size: 11px; font-weight: 700; color: #5B544B;">
          <span>S</span><span>T</span><span>Q</span><span>Q</span><span>S</span><span>S</span><span style="color: #1A1714; font-weight: 800;">Hoje</span>
        </div>
      </div>

      <div style="position: relative; display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600;">
        <svg width="16" height="16" sc-camel-view-box="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>
        <span>Mais <strong style="font-weight: 800;">2 dias</strong> para o selo de 14 dias</span>
      </div>
    </section>
```

## Especificação pixel a pixel

Seção `today` — retângulo absoluto no canvas 390×2390: **x=20, y=766.76, w=350, h=400.8**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `today` | box | 0 | 0 | 350 | 400.8 | `position: relative; margin-top: 36px; background: #FED170; border: 1.5px solid #1A1714; border-radius: 28px; box-shadow: #1A1714 4px 4px 0px; padding: 18px; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px; overflow: hidden` |  |
| 2 | `today.decoCircleLarge` | box | 241.5 | -44.5 | 153 | 153 | `position: absolute; right: -46px; top: -46px; width: 150px; height: 150px; border-radius: 50%; border: 1.5px solid rgba(26,23,20,0.14)` |  |
| 3 | `today.decoCircleSmall` | box | 267.5 | -18.5 | 101 | 101 | `position: absolute; right: -20px; top: -20px; width: 98px; height: 98px; border-radius: 50%; border: 1.5px solid rgba(26,23,20,0.14)` |  |
| 4 | `today.header` | box | 19.5 | 19.5 | 311 | 32 | `position: relative; display: flex; align-items: center; justify-content: space-between` |  |
| 5 | `today.title` | text | 19.5 | 20.55 | 156.76 | 29.9 | `margin: 0px; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| — | `today.title.serif` | inline | 120.62 | 20.55 | 55.64 | 29.9 | `font-family: "Instrument Serif", Georgia, serif; font-style: italic; font-weight: 400; font-size: 23px; letter-spacing: -0.2px` | Instrument Serif itálico 23/normal peso 400 ls -0.2px #1A1714 |
| 6 | `today.streakPill` | box+text | 246.26 | 19.5 | 84.23 | 32 | `display: flex; align-items: center; gap: 5px; height: 32px; padding: 0px 11px 0px 8px; box-sizing: border-box; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800→**700** ls normal #1A1714 |
| 7 | `today.streakPill.icon` | icon | 255.76 | 27 | 17 | 17 | `—` |  |
| 8 | `today.goalRow` | box | 19.5 | 67.5 | 311 | 112 | `position: relative; display: flex; align-items: center; gap: 18px` |  |
| 9 | `today.dial` | box | 19.5 | 67.5 | 112 | 112 | `position: relative; width: 112px; height: 112px; flex-shrink: 0` |  |
| 10 | `today.dial.svg` | icon | 19.5 | 67.5 | 112 | 112 | `—` |  |
| 11 | `today.dial.center` | box | 19.5 | 67.5 | 112 | 112 | `position: absolute; inset: 0px; display: flex; flex-direction: column; align-items: center; justify-content: center` |  |
| 12 | `today.dial.value` | text | 59.57 | 99.9 | 31.86 | 34 | `font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 34px; line-height: 1; letter-spacing: -1px` | Bricolage (opsz 34) 34/34px peso 800 ls -1px #1A1714 |
| 13 | `today.dial.caption` | text | 50.58 | 133.9 | 49.84 | 13.2 | `font-size: 11px; font-weight: 700; color: #4A4238` | Figtree 11/normal peso 700 ls normal #4A4238 |
| 14 | `today.goalText` | box | 149.5 | 85.6 | 181 | 75.8 | `display: flex; flex-direction: column; gap: 10px; min-width: 0px` |  |
| 15 | `today.goalText.sentence` | text | 149.5 | 85.6 | 181 | 39 | `margin: 0px; font-size: 15px; font-weight: 600; line-height: 1.3; text-wrap: pretty` | Figtree 15/19.5px peso 600 ls normal #1A1714 |
| — | `today.goalText.sentence.strong` | inline | 199.28 | 86.35 | 44.12 | 18 | `font-weight: 800` | Figtree 15/19.5px peso 800→**700** ls normal #1A1714 |
| 16 | `today.chips` | box | 149.5 | 134.6 | 181 | 26.8 | `display: flex; gap: 6px; flex-wrap: wrap` |  |
| 17 | `today.chip.pages` | box+text | 149.5 | 134.6 | 80.51 | 26.8 | `font-size: 12px; font-weight: 700; padding: 5px 9px; border-radius: 999px; background: rgba(255,250,241,0.7); border: 1.2px solid #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 18 | `today.chip.highlights` | box+text | 236.01 | 134.6 | 86.86 | 26.8 | `font-size: 12px; font-weight: 700; padding: 5px 9px; border-radius: 999px; background: rgba(255,250,241,0.7); border: 1.2px solid #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 19 | `today.week` | box | 19.5 | 195.5 | 311 | 153.8 | `position: relative; background: #FFFAF1; border: 1.5px solid #1A1714; border-radius: 22px; padding: 14px 14px 12px; box-sizing: border-box; display: flex; flex-direction: column; gap: 8px` |  |
| 20 | `today.week.header` | box | 35 | 211 | 280 | 15.6 | `display: flex; justify-content: space-between; align-items: baseline` |  |
| 21 | `today.week.title` | text | 35 | 211 | 74.69 | 15.6 | `font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800→**700** ls normal #1A1714 |
| 22 | `today.week.total` | text | 217.28 | 211.95 | 97.72 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B` | Figtree 12/normal peso 600 ls normal #5B544B |
| 23 | `today.week.chart` | box | 35 | 234.6 | 280 | 80 | `position: relative; display: grid; grid-template-columns: repeat(7, minmax(0px, 1fr)); gap: 8px; align-items: end; height: 80px` |  |
| 24 | `today.week.goalLine` | box | 31 | 275.1 | 288 | 1.5 | `position: absolute; left: -4px; right: -4px; bottom: 38px; border-top: 1.5px dashed #1A1714; opacity: 0.45` |  |
| 25 | `today.week.bar0` | box | 35 | 234.6 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0px, #EFE6D4 3px, #FFFAF1 3px, #FFFAF1 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 26 | `today.week.bar0.fill` | box | 36.2 | 270.4 | 30.74 | 43 | `width: 100%; height: 43px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 27 | `today.week.bar1` | box | 76.14 | 234.6 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0px, #EFE6D4 3px, #FFFAF1 3px, #FFFAF1 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 28 | `today.week.bar1.fill` | box | 77.34 | 253.4 | 30.74 | 60 | `width: 100%; height: 60px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 29 | `today.week.bar2` | box | 117.29 | 234.6 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0px, #EFE6D4 3px, #FFFAF1 3px, #FFFAF1 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 30 | `today.week.bar2.fill` | box | 118.49 | 273.4 | 30.74 | 40 | `width: 100%; height: 40px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 31 | `today.week.bar3` | box | 158.43 | 234.6 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0px, #EFE6D4 3px, #FFFAF1 3px, #FFFAF1 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 32 | `today.week.bar3.fill` | box | 159.63 | 283.4 | 30.74 | 30 | `width: 100%; height: 30px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 33 | `today.week.bar4` | box | 199.57 | 234.6 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0px, #EFE6D4 3px, #FFFAF1 3px, #FFFAF1 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 34 | `today.week.bar4.fill` | box | 200.77 | 262.4 | 30.74 | 51 | `width: 100%; height: 51px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 35 | `today.week.bar5` | box | 240.71 | 234.6 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0px, #EFE6D4 3px, #FFFAF1 3px, #FFFAF1 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 36 | `today.week.bar5.fill` | box | 241.91 | 240.4 | 30.74 | 73 | `width: 100%; height: 73px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 37 | `today.week.bar6` | box | 281.86 | 234.6 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #FDE2B2 0px, #FDE2B2 3px, #FFFAF1 3px, #FFFAF1 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 38 | `today.week.bar6.fill` | box | 283.36 | 289.1 | 30.14 | 24 | `width: 100%; height: 24px; background: #FF552E; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 39 | `today.week.labels` | box | 35 | 322.6 | 280 | 13.2 | `display: grid; grid-template-columns: repeat(7, minmax(0px, 1fr)); gap: 8px; text-align: center; font-size: 11px; font-weight: 700; color: #5B544B` |  |
| 40 | `today.week.label0` | text | 35 | 322.6 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 41 | `today.week.label1` | text | 76.14 | 322.6 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 42 | `today.week.label2` | text | 117.29 | 322.6 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 43 | `today.week.label3` | text | 158.43 | 322.6 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 44 | `today.week.label4` | text | 199.57 | 322.6 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 45 | `today.week.label5` | text | 240.71 | 322.6 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 46 | `today.week.label6` | text | 281.86 | 322.6 | 33.14 | 13.2 | `color: #1A1714; font-weight: 800` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 47 | `today.footer` | box | 19.5 | 365.3 | 311 | 16 | `position: relative; display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600` |  |
| 48 | `today.footer.icon` | icon | 19.5 | 365.3 | 16 | 16 | `—` |  |
| 49 | `today.footer.text` | text | 43.5 | 365.5 | 193.65 | 15.6 | `—` | Figtree 13/normal peso 600 ls normal #1A1714 |
| — | `today.footer.text.strong` | inline | 73.84 | 365.5 | 34.75 | 15.6 | `font-weight: 800` | Figtree 13/normal peso 800→**700** ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `today.title` | 1 | Seu dia de leitura | 43.32 | 19.5 | 176.26 | 156.76 |
| `today.title.serif` | 1 | leitura | 43.32 | 120.62 | 176.26 | 55.64 |
| `today.streakPill` | 1 | 12 dias | 40.05 | 277.76 | 318 | 40.24 |
| `today.dial.value` | 1 | 18 | 128.12 | 59.57 | 91.43 | 31.86 |
| `today.dial.caption` | 1 | de 30 min | 144.35 | 50.58 | 100.42 | 49.84 |
| `today.goalText.sentence` | 1 | Faltam 12 min para fechar | 100.6 | 149.5 | 324.58 | 175.08 |
| `today.goalText.sentence` | 2 | a meta de hoje. | 120.1 | 149.5 | 253.38 | 103.88 |
| `today.goalText.sentence.strong` | 1 | 12 min | 100.6 | 199.28 | 243.39 | 44.11 |
| `today.chip.pages` | 1 | 24 páginas | 152.2 | 159.7 | 219.81 | 60.11 |
| `today.chip.highlights` | 1 | 2 destaques | 152.2 | 246.21 | 312.66 | 66.45 |
| `today.week.title` | 1 | Esta semana | 223.35 | 35 | 109.69 | 74.69 |
| `today.week.total` | 1 | 4h 00min no total | 223.35 | 217.28 | 315 | 97.72 |
| `today.week.label0` | 1 | S | 333.05 | 48.23 | 54.91 | 6.68 |
| `today.week.label1` | 1 | T | 333.05 | 89.5 | 95.93 | 6.43 |
| `today.week.label2` | 1 | Q | 333.05 | 129.52 | 138.2 | 8.68 |
| `today.week.label3` | 1 | Q | 333.05 | 170.66 | 179.34 | 8.68 |
| `today.week.label4` | 1 | S | 333.05 | 212.8 | 219.48 | 6.68 |
| `today.week.label5` | 1 | S | 333.05 | 253.95 | 260.62 | 6.67 |
| `today.week.label6` | 1 | Hoje | 333.05 | 286.46 | 310.4 | 23.94 |
| `today.footer.text` | 1 | Mais 2 dias para o selo de 14 dias | 377.85 | 43.5 | 237.15 | 193.65 |
| `today.footer.text.strong` | 1 | 2 dias | 377.85 | 73.84 | 108.59 | 34.75 |

## Leitura de designer (detalhes críticos)

**Cartão**
1. 350 × **400,8**, fundo `#FED170`, borda 1,5, raio 28, sombra dura 4/4, padding **18**, coluna gap **16**, `overflow: hidden` (recorte interno 26,5).
2. Dois círculos decorativos (`position:absolute`, primeiros no DOM → pintam **atrás** do conteúdo, porque os demais filhos são `position: relative`): grande **153** (150 + borda) em `right −46 / top −46`; pequeno **101** (98 + borda) em `right −20 / top −20`; borda 1,5 `rgba(26,23,20,.14)`, sem preenchimento; recortados pelo canto arredondado.

**Cabeçalho (32 de altura, `space-between`, centralizado)**
3. "Seu dia de " Bricolage 20 ls −0,4 + "leitura" Instrument Serif **itálico 23** ls −0,2 — **mesmo parágrafo**, mesma baseline; a linha mede **29,9** (a serifada define ascendente/descendente) e fica centrada em 32 (y+1,05).
4. Pílula de sequência: altura **32**, padding **0 11 0 8**, borda 1,5, fundo `#FFFAF1`, gap 5: chama 17 (preenchimento `#FF552E`, traço tinta 1,6) + "12 dias" 13/800→**700** → largura **84,23**.

**Linha da meta (112 de altura, gap 18, centralizada)**
5. Dial 112×112 — `SizedBox(key: 'today.dial', 112×112, child: Stack([Positioned.fill(child: ExcludeSemantics(child: CustomPaint(key: 'today.dial.svg', painter: GoalDialPainter(progress: 18 / 30)))), Positioned.fill(child: Column(key: 'today.dial.center', mainAxisAlignment: center, children: [valor, legenda]))]))` (o `Positioned.fill` é obrigatório: um `CustomPaint` sem filho e com restrição frouxa mede 0×0): face r54 `#FFFAF1` com traço 1,5; marcações r44 (traço 2, dash 1,5/7,71, opacidade .35); arco r44 traço 10 cap redondo de 12h no sentido horário cobrindo 60%; pino r6 `#FF552E` com traço 1,5 no fim do arco (30,1; 91,6). Centro: "18" Bricolage 34 **line-height 1** ls −1 e "de 30 min" 11/700 `#4A4238`, coluna centralizada (bloco de 47,2 → y+32,4).
6. Coluna de texto (181 de largura, gap 10), centrada verticalmente (75,8 → y+18,1): frase 15/600 **line-height 1,3** com "12 min" em 800→**700**, quebrando exatamente em **"Faltam 12 min para fechar" / "a meta de hoje."** (o CSS usa `text-wrap: pretty`; aqui o resultado é igual ao quebrador guloso — a palavra "a" estouraria 181 por 5,55 px); chips (gap 6, quebram linha com gap 6): padding **5 9**, borda **1,2**, fundo `rgba(255,250,241,.7)`, 12/700 → 80,51 e 86,86 × 26,8.

**Cartão da semana (311 × 153,8)**
7. Fundo `#FFFAF1`, borda 1,5, raio **22**, padding **14 14 12**, coluna gap 8. Cabeçalho `space-between` alinhado **pela baseline**: "Esta semana" 13/800→700 e "4h 00min no total" 12/600 `#5B544B` (o segundo fica 0,95 px mais baixo no topo por ter ascendente menor).
8. Gráfico: grade de 7 colunas iguais (**33,143**), gap 8, altura 80, alinhadas embaixo.
   - Trilhos 0–5: altura 80, raio 999 (→ 16,571), **borda 1,2**, fundo hachurado `#EFE6D4`/`#FFFAF1` (listra 3, período 7, 135°, origem no canto interno superior esquerdo), recorte.
   - Trilho 6 ("Hoje"): **borda 1,5** e hachura `#FDE2B2`/`#FFFAF1`.
   - Preenchimentos: largura 100% da área interna (30,742; na barra 6: **30,142**), alturas **43, 60, 40, 30, 51, 73, 24**, cor `weekColor` (barra 6: `#FF552E`), raio 999, **borda superior 1,5 tinta em forma de meia-lua** (`TopBorderCrescentPainter`). A base do preenchimento é recortada pela curva interna do trilho.
   - Linha da meta: `left −4 / right −4 / bottom 38`, borda superior **1,5 tracejada** tinta com **opacidade .45** (traço 3, vão ajustado: 64 traços em 288 px) — é `position:absolute` e por isso pinta **por cima** das barras.
9. Rótulos: grade igual (7 × 33,143, gap 8), centralizados, 11 px: "S T Q Q S S" 700 `#5B544B`; "Hoje" 800→700 **tinta**.

**Rodapé (16 de altura, gap 8, centralizado)**
10. Brilho sólido 16 + "Mais **2 dias** para o selo de 14 dias" 13/600 com "2 dias" 800→700 (linha 15,6 centrada → y+0,2).

## Construção obrigatória

```dart
NeoBox(key: const ValueKey('today'), color: AppColors.sun, border: const BorderSide(width: 1.5, color: AppColors.ink),
  radius: BorderRadius.circular(28), shadow: AppShadows.hard4, clip: true,
  child: Stack(children: [
    const Positioned(right: -46, top: -46, child: /* círculo 153, Key today.decoCircleLarge */),
    const Positioned(right: -20, top: -20, child: /* círculo 101, Key today.decoCircleSmall */),
    Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 16, children: [
      /* today.header (32), today.goalRow (112), today.week (153,8), today.footer (16) */
    ])),
  ]),
)
```
Gráfico (núcleo):
```dart
SizedBox(key: const ValueKey('today.week.chart'), height: 80, child: Stack(clipBehavior: Clip.none, children: [
  Row(crossAxisAlignment: CrossAxisAlignment.end, spacing: 8, children: [
    for (var i = 0; i < 7; i++) Expanded(child: _Bar(index: i, stat: week[i], color: i == 6 ? AppColors.flame : theme.weekColor)),
  ]),
  const Positioned(left: -4, right: -4, bottom: 38, height: 1.5,
    child: CustomPaint(key: ValueKey('today.week.goalLine'),
      painter: ChromiumDashPainter(axis: Axis.horizontal, thickness: 1.5, color: AppColors.goalLine))),
]))
```
`_Bar`: `NeoBox(key: today.week.barN, height: 80, border: BorderSide(width: isToday ? 1.5 : 1.2, color: ink), radius: BorderRadius.circular(999), clip: true, child: Stack(children: [Positioned.fill(child: CustomPaint(painter: HatchPainter(stripe: isToday ? hatchToday : hatch))), Align(alignment: Alignment.bottomCenter, child: SizedBox(key: today.week.barN.fill, height: barHeightPx, width: double.infinity, child: CustomPaint(painter: TopBorderCrescentPainter(fill: color))))]))`.

Semântica: seção `Semantics(container: true, explicitChildNodes: true, label: 'Seu dia de leitura')`; gráfico `Semantics(container: true, label: weekAria(...), excludeSemantics: true)`; linha tracejada e **só o desenho** do dial fora da árvore (`ExcludeSemantics` no `CustomPaint`; no HTML só o `<svg>` é `aria-hidden` — "18" e "de 30 min" continuam legíveis); título `Semantics(container: true, header: true, child: AppText.rich(...))` — o `AppText` não é fronteira semântica, então o texto vira o rótulo **desse** nó de cabeçalho (sem nó duplicado).

## Subfases

- **7.1** Cartão + círculos decorativos atrás do conteúdo (recortados).
- **7.2** Cabeçalho: título misto (Bricolage 20 + Instrument itálico 23) + pílula de sequência 84,23 × 32.
- **7.3** Dial 112 (face, 31 marcações, arco 60%, pino) + números centrais.
- **7.4** Frase da meta (quebra "Faltam 12 min para fechar" / "a meta de hoje.") + chips 1,2.
- **7.5** Cartão da semana: moldura + cabeçalho por baseline.
- **7.6** Barras: trilhos (bordas 1,2 / 1,5), hachuras, preenchimentos com meia-lua, alturas do arquivo.
- **7.7** Linha da meta tracejada por cima (64 traços, .45) + rótulos (Hoje em tinta).
- **7.8** Rodapé do selo.
- **7.9** Verificação completa + relatório.

## Testes da fase

- `expectGeometry(tester, idsOfSection('today'))` → 49/49.
- `expectTextLines` para todos os textos (inclui `today.title` com os dois trechos numa linha, baseline 43,32 relativa à seção; `today.goalText.sentence` com as 2 linhas).
- Prova dos tokens mistos: `cardTitleM`, `cardSerifM`, `goalSentence`, `goalSentenceStrong` conferidos pelas linhas acima.
- Estilo: bordas 1,2 (barras 0–5) × 1,5 (barra 6), cores de hachura, alturas `[43, 60, 40, 30, 51, 73, 24]`, `weekColor` aplicado só às barras 0–5, linha da meta com 64 traços e alpha `0x73`.
- Tema: cada opção de `weekColorOptions` muda só os preenchimentos 0–5.
- Visual: `--rect 16,758,358,418` → `blur_mismatch_% ≤ 0,5`. Inspecione ampliado: direção "/" da hachura, meia-lua do topo dos preenchimentos, tracejado sobre as barras, círculos atrás do título.
- Não-regressão F03–F06.

## Checklist de aceite da FASE 7

- [ ] 7.1 Cartão 350×400,8 `#FED170`, borda 1,5, raio 28, sombra 4/4, padding 18, gap 16, recorte
- [ ] 7.1 Círculos 153 e 101 (content-box), borda 1,5 `rgba(26,23,20,.14)`, em −46/−46 e −20/−20, atrás do conteúdo
- [ ] 7.2 Título misto numa linha (29,9) centrado em 32; pílula 84,23×32 (padding 0/11/0/8, gap 5, chama 17)
- [ ] 7.3 Dial: face r54 + traço 1,5; 31 marcações; arco 60% traço 10; pino (30,1; 91,6); "18" 34/1 ls −1 + "de 30 min" `#4A4238`
- [ ] 7.4 Frase 15/600/1,3 com "12 min" 700, 2 linhas exatas; chips 5/9, borda 1,2, fundo .7, gap 6 (com quebra de linha)
- [ ] 7.5 Cartão semana 311×153,8, padding 14/14/12, gap 8, cabeçalho por baseline
- [ ] 7.6 7 colunas de 33,143 (gap 8); trilhos 80 com borda 1,2 / 1,5; hachuras corretas (listra 3/período 7, "/", origem interna)
- [ ] 7.6 Preenchimentos com meia-lua 1,5 e alturas do arquivo; recorte pela curva do trilho
- [ ] 7.7 Linha tracejada 288×1,5 em bottom 38, 64 traços, alpha .45, por cima das barras
- [ ] 7.7 Rótulos 11 px centralizados; "Hoje" 700 tinta
- [ ] 7.8 Rodapé: brilho 16 + frase com "2 dias" 700, gap 8
- [ ] Geometria 49/49 · Texto OK · Estilo OK · Tema OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado, heatmap e recorte ampliado das barras inspecionados

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 7 concluída — aguardando sua aprovação para iniciar a FASE 8.`
