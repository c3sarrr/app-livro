# FASE L01a4 — Início — Seu dia de leitura (meta, Ler agora, semana)

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a4_seu_dia@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a4_seu_dia_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/reading_day_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Cartão amarelo "Seu dia de leitura": meta (18 de 30 min), o botão novo "Ler agora", as pílulas "2 sessões" e "2 destaques", a semana e o selo.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

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
      <a href="#" aria-label="Iniciar leitura (cronômetro)" style="align-self: flex-start; height: 40px; padding: 0 14px 0 11px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800; color: #F7F0E3;">
        <svg width="17" height="17" sc-camel-view-box="0 0 24 24" fill="none" stroke="#FED170" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path></svg>
        <span style="color: #F7F0E3;">Ler agora</span>
      </a>
      <div style="display: flex; gap: 6px; flex-wrap: wrap;">
        <span style="font-size: 12px; font-weight: 700; padding: 5px 9px; border-radius: 999px; background: rgba(255,250,241,0.7); border: 1.2px solid #1A1714;">2 sessões</span>
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

Seção `i01.today` — retângulo absoluto no canvas 390×2650: **x=20, y=804.77, w=350, h=414.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.today` | box | 0 | 0 | 350 | 414.6 | `position: relative; margin-top: 36px; background: #FED170; border: 1.5px solid #1A1714; border-radius: 28px; box-shadow: 4px 4px 0 #1A1714; padding: 18px; box-sizing: border-box; display: flex; flex-direction: column; gap: 16px; overflow: hidden` |  |
| 2 | `i01.today.decoCircleLarge` | box | 241.5 | -44.5 | 153 | 153 | `position: absolute; right: -46px; top: -46px; width: 150px; height: 150px; border-radius: 50%; border: 1.5px solid rgba(26,23,20,0.14)` |  |
| 3 | `i01.today.decoCircleSmall` | box | 267.5 | -18.5 | 101 | 101 | `position: absolute; right: -20px; top: -20px; width: 98px; height: 98px; border-radius: 50%; border: 1.5px solid rgba(26,23,20,0.14)` |  |
| 4 | `i01.today.header` | box | 19.5 | 19.5 | 311 | 32 | `position: relative; display: flex; align-items: center; justify-content: space-between` |  |
| 5 | `i01.today.title` ±1 | text | 19.5 | 20.55 | 156.76 | 29.9 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 6 | `i01.today.title.serif` ±1 | inline | 120.62 | 20.55 | 55.64 | 29.9 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 23px; letter-spacing: -0.2px` | Instrument Serif itálico 23/normal peso 400 ls -0.2px #1A1714 |
| 7 | `i01.today.streakPill` ±1 | box+text | 246.26 | 19.5 | 84.23 | 32 | `display: flex; align-items: center; gap: 5px; height: 32px; padding: 0 11px 0 8px; box-sizing: border-box; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800→**800** ls normal #1A1714 |
| 8 | `i01.today.streakPill.icon` ±1 | icon | 255.76 | 27 | 17 | 17 | `—` |  |
| 9 | `i01.today.goalRow` | box | 19.5 | 67.5 | 311 | 125.8 | `position: relative; display: flex; align-items: center; gap: 18px` |  |
| 10 | `i01.today.dial` | box | 19.5 | 74.4 | 112 | 112 | `position: relative; width: 112px; height: 112px; flex-shrink: 0` |  |
| 11 | `i01.today.dial.svg` | icon | 19.5 | 74.4 | 112 | 112 | `—` |  |
| 12 | `i01.today.dial.center` | box | 19.5 | 74.4 | 112 | 112 | `position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center` |  |
| 13 | `i01.today.dial.value` ±1 | text | 59.57 | 106.8 | 31.86 | 34 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 1; letter-spacing: -1px` | Bricolage (opsz 34) 34/34px peso 800 ls -1px #1A1714 |
| 14 | `i01.today.dial.caption` ±1 | text | 50.58 | 140.8 | 49.84 | 13.2 | `font-size: 11px; font-weight: 700; color: #4A4238` | Figtree 11/normal peso 700 ls normal #4A4238 |
| 15 | `i01.today.goalText` | box | 149.5 | 67.5 | 181 | 125.8 | `display: flex; flex-direction: column; gap: 10px; min-width: 0` |  |
| 16 | `i01.today.goalText.sentence` | text | 149.5 | 67.5 | 181 | 39 | `margin: 0; font-size: 15px; font-weight: 600; line-height: 1.3; text-wrap: pretty` | Figtree 15/19.5px peso 600 ls normal #1A1714 |
| 17 | `i01.today.goalText.sentence.strong` ±1 | inline | 199.28 | 68.25 | 44.12 | 18 | `font-weight: 800` | Figtree 15/19.5px peso 800→**800** ls normal #1A1714 |
| 18 | `i01.today.readNow` ±1 | box | 149.5 | 116.5 | 109.69 | 40 | `align-self: flex-start; height: 40px; padding: 0 14px 0 11px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800; color: #F7F0E3` |  |
| 19 | `i01.today.readNow.icon` | icon | 160.5 | 128 | 17 | 17 | `—` |  |
| 20 | `i01.today.readNow.label` ±1 | text | 184.5 | 128.1 | 60.69 | 16.8 | `color: #F7F0E3` | Figtree 14/normal peso 800→**800** ls normal #F7F0E3 |
| 21 | `i01.today.chips` | box | 149.5 | 166.5 | 181 | 26.8 | `display: flex; gap: 6px; flex-wrap: wrap` |  |
| 22 | `i01.today.chip.sessions` ±1 | box+text | 149.5 | 166.5 | 72.83 | 26.8 | `font-size: 12px; font-weight: 700; padding: 5px 9px; border-radius: 999px; background: rgba(255,250,241,0.7); border: 1.2px solid #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 23 | `i01.today.chip.highlights` ±1 | box+text | 228.33 | 166.5 | 86.86 | 26.8 | `font-size: 12px; font-weight: 700; padding: 5px 9px; border-radius: 999px; background: rgba(255,250,241,0.7); border: 1.2px solid #1A1714` | Figtree 12/normal peso 700 ls normal #1A1714 |
| 24 | `i01.today.week` | box | 19.5 | 209.3 | 311 | 153.8 | `position: relative; background: #FFFAF1; border: 1.5px solid #1A1714; border-radius: 22px; padding: 14px 14px 12px; box-sizing: border-box; display: flex; flex-direction: column; gap: 8px` |  |
| 25 | `i01.today.week.header` | box | 35 | 224.8 | 280 | 15.6 | `display: flex; justify-content: space-between; align-items: baseline` |  |
| 26 | `i01.today.week.title` ±1 | text | 35 | 224.8 | 74.69 | 15.6 | `font-size: 13px; font-weight: 800` | Figtree 13/normal peso 800→**800** ls normal #1A1714 |
| 27 | `i01.today.week.total` ±1 | text | 217.28 | 225.75 | 97.72 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B` | Figtree 12/normal peso 600 ls normal #5B544B |
| 28 | `i01.today.week.chart` | box | 35 | 248.4 | 280 | 80 | `position: relative; display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 8px; align-items: end; height: 80px` |  |
| 29 | `i01.today.week.goalLine` | box | 31 | 288.9 | 288 | 1.5 | `position: absolute; left: -4px; right: -4px; bottom: 38px; border-top: 1.5px dashed #1A1714; opacity: 0.45` |  |
| 30 | `i01.today.week.bar0` | box | 35 | 248.4 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 31 | `i01.today.week.bar0.fill` | box | 36.2 | 284.2 | 30.74 | 43 | `width: 100%; height: 43px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 32 | `i01.today.week.bar1` | box | 76.14 | 248.4 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 33 | `i01.today.week.bar1.fill` | box | 77.34 | 267.2 | 30.74 | 60 | `width: 100%; height: 60px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 34 | `i01.today.week.bar2` | box | 117.29 | 248.4 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 35 | `i01.today.week.bar2.fill` | box | 118.49 | 287.2 | 30.74 | 40 | `width: 100%; height: 40px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 36 | `i01.today.week.bar3` | box | 158.43 | 248.4 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 37 | `i01.today.week.bar3.fill` | box | 159.63 | 297.2 | 30.74 | 30 | `width: 100%; height: 30px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 38 | `i01.today.week.bar4` | box | 199.57 | 248.4 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 39 | `i01.today.week.bar4.fill` | box | 200.77 | 276.2 | 30.74 | 51 | `width: 100%; height: 51px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 40 | `i01.today.week.bar5` | box | 240.71 | 248.4 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.2px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #EFE6D4 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 41 | `i01.today.week.bar5.fill` | box | 241.91 | 254.2 | 30.74 | 73 | `width: 100%; height: 73px; background: {{weekColor}} (padrão #B6ACE4); border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 42 | `i01.today.week.bar6` | box | 281.86 | 248.4 | 33.14 | 80 | `height: 80px; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; background: repeating-linear-gradient(135deg, #FDE2B2 0 3px, #FFFAF1 3px 7px); display: flex; align-items: flex-end; overflow: hidden` |  |
| 43 | `i01.today.week.bar6.fill` | box | 283.36 | 302.9 | 30.14 | 24 | `width: 100%; height: 24px; background: #FF552E; border-top: 1.5px solid #1A1714; box-sizing: border-box; border-radius: 999px` |  |
| 44 | `i01.today.week.labels` | box | 35 | 336.4 | 280 | 13.2 | `display: grid; grid-template-columns: repeat(7, minmax(0, 1fr)); gap: 8px; text-align: center; font-size: 11px; font-weight: 700; color: #5B544B` |  |
| 45 | `i01.today.week.label0` | text | 35 | 336.4 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 46 | `i01.today.week.label1` | text | 76.14 | 336.4 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 47 | `i01.today.week.label2` | text | 117.29 | 336.4 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 48 | `i01.today.week.label3` | text | 158.43 | 336.4 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 49 | `i01.today.week.label4` | text | 199.57 | 336.4 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 50 | `i01.today.week.label5` | text | 240.71 | 336.4 | 33.14 | 13.2 | `—` | Figtree 11/normal peso 700 ls normal #5B544B |
| 51 | `i01.today.week.label6` | text | 281.86 | 336.4 | 33.14 | 13.2 | `color: #1A1714; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 52 | `i01.today.footer` | box | 19.5 | 379.1 | 311 | 16 | `position: relative; display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 600` |  |
| 53 | `i01.today.footer.icon` | icon | 19.5 | 379.1 | 16 | 16 | `—` |  |
| 54 | `i01.today.footer.text` ±1 | text | 43.5 | 379.3 | 193.65 | 15.6 | `—` | Figtree 13/normal peso 600 ls normal #1A1714 |
| 55 | `i01.today.footer.text.strong` ±1 | inline | 73.84 | 379.3 | 34.75 | 15.6 | `font-weight: 800` | Figtree 13/normal peso 800→**800** ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.today.title` *(composto)* | 1 | Seu dia de leitura | 43.32 | 19.5 | 176.26 | 156.76 |
| `i01.today.streakPill` | 1 | 12 dias | 40.05 | 277.76 | 318 | 40.24 |
| `i01.today.dial.value` | 1 | 18 | 135.02 | 59.57 | 91.43 | 31.86 |
| `i01.today.dial.caption` | 1 | de 30 min | 151.25 | 50.58 | 100.42 | 49.84 |
| `i01.today.goalText.sentence` *(composto)* | 1 | Faltam 12 min para fechar | 82.5 | 149.5 | 324.58 | 175.08 |
| `i01.today.goalText.sentence` *(composto)* | 2 | a meta de hoje. | 102 | 149.5 | 253.38 | 103.88 |
| `i01.today.readNow.label` | 1 | Ler agora | 141.4 | 184.5 | 245.19 | 60.69 |
| `i01.today.chip.sessions` | 1 | 2 sessões | 184.1 | 159.7 | 212.13 | 52.43 |
| `i01.today.chip.highlights` | 1 | 2 destaques | 184.1 | 238.53 | 304.98 | 66.45 |
| `i01.today.week.title` | 1 | Esta semana | 237.15 | 35 | 109.69 | 74.69 |
| `i01.today.week.total` | 1 | 4h 00min no total | 237.15 | 217.28 | 315 | 97.72 |
| `i01.today.week.label0` | 1 | S | 346.85 | 48.23 | 54.91 | 6.68 |
| `i01.today.week.label1` | 1 | T | 346.85 | 89.5 | 95.93 | 6.43 |
| `i01.today.week.label2` | 1 | Q | 346.85 | 129.52 | 138.2 | 8.68 |
| `i01.today.week.label3` | 1 | Q | 346.85 | 170.66 | 179.34 | 8.68 |
| `i01.today.week.label4` | 1 | S | 346.85 | 212.8 | 219.48 | 6.68 |
| `i01.today.week.label5` | 1 | S | 346.85 | 253.95 | 260.62 | 6.67 |
| `i01.today.week.label6` | 1 | Hoje | 346.85 | 286.46 | 310.4 | 23.94 |
| `i01.today.footer.text` *(composto)* | 1 | Mais 2 dias para o selo de 14 dias | 391.65 | 43.5 | 237.15 | 193.65 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cartão `#FED170`, borda 1,5, raio 28, sombra 4/4, padding 18, `overflow: hidden` (os dois círculos decorativos 150 e 98, borda 1,5 `rgba(26,23,20,.14)`, saem pelo canto superior direito e são recortados).
2. Cabeçalho: "Seu dia de" Bricolage 20/800 ls −0,4 + "leitura" Instrument Serif itálico 23; pílula "12 dias" (32 de altura, `#FFFAF1`, borda 1,5, chama 17 + Figtree 13/800 → 700).
3. Mostrador 112 (`mostrador_meta_diaria`: CustomPainter — anel r 44 traço 10 em 60 %, 30 marcas, bolinha coral) com "18" Bricolage 34/800 ls −1 e "de 30 min" Figtree 11/700 `#4A4238` no centro.
4. Coluna (gap 10): "Faltam **12 min** para fechar / a meta de hoje." Figtree 15/600 `lh 1,3` (`text-wrap: pretty`; o forte 800 → 700); **"Ler agora"** (novo): pílula preta 40, padding 0/14/0/11, cronômetro 17 amarelo (`ic_stopwatch`) + Figtree 14/800 (→ 700) `#F7F0E3`; pílulas "2 sessões" e "2 destaques" (Figtree 12/700, fundo `rgba(255,250,241,.7)`, borda 1,2).
5. Semana (igual à v1): caixa `#FFFAF1` raio 22; barras 33,14 × 80 com hachura 135° `#EFE6D4`/`#FFFAF1` (3/7) e o preenchimento lavanda; a de hoje com hachura `#FDE2B2` e preenchimento coral de 24; linha da meta tracejada a 45 %.
6. O que muda em relação à v1: "Ler agora" e "2 sessões" (no lugar da pílula de páginas); o texto da meta sobe e a linha fica 13,8 mais alta.
7. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.today` |  | Seu dia de leitura |  |
| `i01.today.decoCircleLarge` |  |  | aria-hidden=true |
| `i01.today.decoCircleSmall` |  |  | aria-hidden=true |
| `i01.today.streakPill.icon` |  |  | aria-hidden=true |
| `i01.today.dial.svg` |  |  | aria-hidden=true |
| `i01.today.readNow` |  | Iniciar leitura (cronômetro) |  |
| `i01.today.readNow.icon` |  |  | aria-hidden=true |
| `i01.today.week.chart` |  | Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, sexta 38, sábado 55, hoje 18 de 30 |  |
| `i01.today.week.goalLine` |  |  | aria-hidden=true |
| `i01.today.footer.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.today` | NeoBox |  |
| `i01.today.decoCircleLarge` | CircleIconButton / NeoBox circular |  |
| `i01.today.decoCircleSmall` | CircleIconButton / NeoBox circular |  |
| `i01.today.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `i01.today.streakPill` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.today.streakPill.icon` | AppSvg(AppIcons.ic_flame, size: 17) |  |
| `i01.today.dial.svg` | CustomPainter (mostrador_meta_diaria) | mostrador da meta: anel de progresso r 44 / traço 10 com dasharray 165,9 de 276,5 (= 18 de 30 min → 60 %), marcas r 44 com dasharray 1,5 + 7,71 = 2π·44/30 (uma por minuto da meta, opacidade 0,35) e a bolinha coral (r 6) na ponta do arco: CustomPainter com minutos/meta reais; a posição da bolinha é calculada (aqui 30,1 / 91,6). |
| `i01.today.goalText.sentence.strong` | TextSpan dentro do AppText.rich do pai |  |
| `i01.today.readNow` | NeoBox |  |
| `i01.today.readNow.icon` | AppSvg(AppIconsInicio.ic_stopwatch, size: 17) |  |
| `i01.today.chip.sessions` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.today.chip.highlights` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.today.week` | NeoBox |  |
| `i01.today.week.goalLine` | NeoBox |  |
| `i01.today.week.bar0` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.today.week.bar0.fill` | NeoBox |  |
| `i01.today.week.bar1` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.today.week.bar1.fill` | NeoBox |  |
| `i01.today.week.bar2` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.today.week.bar2.fill` | NeoBox |  |
| `i01.today.week.bar3` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.today.week.bar3.fill` | NeoBox |  |
| `i01.today.week.bar4` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.today.week.bar4.fill` | NeoBox |  |
| `i01.today.week.bar5` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.today.week.bar5.fill` | NeoBox |  |
| `i01.today.week.bar6` | HatchPainter (hachura 135°) dentro do contorno |  |
| `i01.today.week.bar6.fill` | NeoBox |  |
| `i01.today.footer.icon` | AppSvg(AppIcons.ic_sparkle_solid, size: 16) |  |
| `i01.today.footer.text.strong` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- "Ler agora" → aparece na T03 sem ação (D-243 b): o elemento fica idêntico à prancha, o toque não faz nada, um teste documenta e o item entra em `docs/design/estados_sem_design.md`; ganha ação na T04 (D-247).
- Pílulas e semana: informativas.

## Dados

- Minutos de hoje (18) e meta (30) como hoje; "N sessões" = sessões de `reading_sessions` de hoje; "2 destaques" como hoje; semana: 32, 45, 30, 22, 38, 55 e 18 (= 4h 00min, do rótulo `aria` do gráfico).

## Subfases

- **L01a4.1** Cartão e cabeçalho com a sequência
- **L01a4.2** Mostrador (CustomPainter)
- **L01a4.3** Texto da meta e "Ler agora" (sem ação)
- **L01a4.4** Pílulas "N sessões" e destaques
- **L01a4.5** Semana e selo
- **L01a4.6** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.today'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 752.27–1227.37) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a4.1 Cartão e cabeçalho com a sequência
- [ ] L01a4.2 Mostrador (CustomPainter)
- [ ] L01a4.3 Texto da meta e "Ler agora" (sem ação)
- [ ] L01a4.4 Pílulas "N sessões" e destaques
- [ ] L01a4.5 Semana e selo
- [ ] L01a4.6 Verificação + relatório
- [ ] Geometria 52/52 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
