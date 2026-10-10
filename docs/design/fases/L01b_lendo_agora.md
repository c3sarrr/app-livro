# FASE L01b — Início lendo agora — livro de papel em sessão e mini-barra do cronômetro

> Tela 01b · prancha `001b_inicio_lendo_agora` (01b · Início — lendo agora (cronômetro ativo), canvas 390×844) · executada na **T04** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01b_lendo_agora@3x.png` · `docs/design/medicao/inicio2/png/redline/L01b_lendo_agora_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001b_inicio_lendo_agora_390x844@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001b_inicio_lendo_agora.json` · `test/reference/inicio2/reference_layout_001b_inicio_lendo_agora.dart` (`kRef01b`).
> Arquivos sugeridos: `lib/features/reading_session/presentation/session_mini_bar.dart`, `lib/features/home/presentation/sections/also_reading_section.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A Início com uma sessão de leitura do livro de papel em andamento: o cartão do Brás Cubas em "pausar" com o anel coral e a mini-barra do cronômetro acima da barra de navegação. Sem o cartão da revisão.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

```html
<!-- Also reading -->
<section aria-label="Também lendo" style="margin-top: 32px; display: flex; flex-direction: column; gap: 30px;">
  <div style="display: flex; align-items: center; gap: 8px;">
    <h3 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.3px;">Também lendo</h3>
    <span style="min-width: 22px; height: 22px; padding: 0 7px; box-sizing: border-box; border-radius: 999px; background: #1A1714; color: #F7F0E3; font-size: 12px; font-weight: 800; display: flex; align-items: center; justify-content: center;">3</span>
  </div>
  <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px;">
    <div style="display: flex; flex-direction: column; gap: 12px; padding: 0 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
      <div style="display: flex; align-items: flex-end; justify-content: space-between;">
        <a href="#" aria-label="Memórias Póstumas de Brás Cubas" style="position: relative; display: block; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box; transform: rotate(-4deg); box-shadow: 2px 2px 0 #1A1714;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.18);"></div>
          <div style="position: absolute; left: 18px; top: 14px; width: 18px; height: 16px; border-radius: 2px 2px 0 0; background: #1A1714;"></div>
          <div style="position: absolute; left: 13px; top: 29px; width: 28px; height: 5px; border-radius: 50%; background: #1A1714;"></div>
          <div style="position: absolute; left: 9px; right: 3px; bottom: 8px; font-family: 'Instrument Serif', Georgia, serif; font-size: 11px; line-height: 0.95; color: #FED170;">Brás<br>Cubas</div>
        </a>
        <!-- paper book: quick-start the reading timer -->
        <button aria-label="Pausar leitura de Brás Cubas" style="width: 46px; height: 46px; margin-top: 12px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-shadow: 0 0 0 3px #FF552E; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
          <svg width="16" height="16" sc-camel-view-box="0 0 24 24" aria-hidden="true"><rect x="5.5" y="4" width="4.5" height="16" rx="1.5" fill="#FED170"></rect><rect x="14" y="4" width="4.5" height="16" rx="1.5" fill="#FED170"></rect></svg>
        </button>
      </div>
      <div style="display: flex; flex-direction: column; gap: 2px; min-width: 0;">
        <span style="font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Brás Cubas</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Machado de Assis</span>
        <span style="margin-top: 6px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 3px 8px 3px 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #E2D7C4; white-space: nowrap;"><svg width="12" height="12" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"></path></svg>Papel · 3h 40min</span>
      </div>
    </div>
    <a href="#" style="display: flex; flex-direction: column; gap: 12px; padding: 0 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
      <div style="display: flex; align-items: flex-end; justify-content: space-between;">
        <div style="position: relative; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box; transform: rotate(3deg); box-shadow: 2px 2px 0 #1A1714;">
          <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.12);"></div>
          <div style="position: absolute; left: 17px; top: 13px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></div>
          <div style="position: absolute; left: 9px; right: 2px; bottom: 8px; font-family: 'Instrument Serif', Georgia, serif; font-size: 9px; line-height: 0.95; color: #1A1714;">Orgulho e<br>Preconceito</div>
        </div>
        <div style="position: relative; width: 46px; height: 46px; margin-top: 12px;">
          <svg width="46" height="46" sc-camel-view-box="0 0 46 46" aria-hidden="true"><circle cx="23" cy="23" r="18" fill="none" stroke="#EAE1CF" stroke-width="5"></circle><circle cx="23" cy="23" r="18" fill="none" stroke="#1A1714" stroke-width="5" stroke-linecap="round" stroke-dasharray="91.6 113.1" transform="rotate(-90 23 23)"></circle></svg>
          <span style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">81%</span>
        </div>
      </div>
      <div style="display: flex; flex-direction: column; gap: 2px; min-width: 0;">
        <span style="font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Orgulho e Preconceito</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Jane Austen</span>
        <span style="margin-top: 6px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 3px 8px 3px 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #E2D7C4; white-space: nowrap;"><svg width="12" height="12" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"></path></svg>Papel · pág. 344</span>
      </div>
    </a>
  </div>
</section>

<!-- Now reading: mini bar while a timer session runs (tap opens the timer) -->
<a href="#" aria-label="Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro" style="position: absolute; left: 16px; right: 16px; bottom: 130px; height: 66px; padding: 0 10px 0 12px; border-radius: 22px; background: #1A1714; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 rgba(26,23,20,0.35); box-sizing: border-box; display: flex; align-items: center; gap: 12px; overflow: hidden; color: #F7F0E3;">
  <span aria-hidden="true" style="position: absolute; left: 0; top: 0; height: 4px; width: 89%; background: {{brand}}; border-radius: 0 4px 4px 0;"></span>
  <span aria-hidden="true" style="width: 32px; height: 48px; flex-shrink: 0; border-radius: 2px 5px 5px 2px; border: 1.2px solid #F7F0E3; background: #058CD7; overflow: hidden; box-sizing: border-box; transform: rotate(-5deg);"><svg width="100%" height="100%" sc-camel-view-box="0 0 96 144" sc-camel-preserve-aspect-ratio="xMidYMid slice" style="display: block;">
    <rect width="96" height="144" fill="#058CD7"></rect>
    <!-- a top hat with little wings: memoirs written from the other side -->
    <path d="M12 9c.2 1.4.6 1.9 1.9 2.1-1.3.2-1.7.7-1.9 2.1-.2-1.4-.6-1.9-1.9-2.1 1.3-.2 1.7-.7 1.9-2.1z" fill="#FED170"></path>
    <path d="M83 90c.3 2.2.9 3 3 3.3-2.1.3-2.7 1.1-3 3.3-.3-2.2-.9-3-3-3.3 2.1-.3 2.7-1.1 3-3.3z" fill="#FFFAF1"></path>
    <path d="M20 58c.2 1.4.6 1.9 1.9 2.1-1.3.2-1.7.7-1.9 2.1-.2-1.4-.6-1.9-1.9-2.1 1.3-.2 1.7-.7 1.9-2.1z" fill="#FFFAF1"></path>
    <text x="12" y="20" font-family="Figtree, sans-serif" font-size="4.6" font-weight="800" letter-spacing="0.8" fill="#F7F0E3">MEMÓRIAS PÓSTUMAS DE</text>
    <text x="11" y="38" font-family="'Instrument Serif', Georgia, serif" font-size="17.5" fill="#FED170">Brás Cubas</text>
    <!-- wings -->
    <path d="M33 66c-8-1-15-6-18-13 5 2 9 2 12 1-3-1-6-4-7-7 5 3 10 4 14 4z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.2" stroke-linejoin="round"></path>
    <path d="M63 66c8-1 15-6 18-13-5 2-9 2-12 1 3-1 6-4 7-7-5 3-10 4-14 4z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.2" stroke-linejoin="round"></path>
    <!-- hat -->
    <path d="M36 46h24l-2 30H38z" fill="#1A1714"></path>
    <rect x="37.2" y="68" width="21.6" height="5" fill="#FF552E"></rect>
    <ellipse cx="48" cy="77" rx="18" ry="4.2" fill="#1A1714"></ellipse>
    <path d="M40 50.5c3-1 13-1 16 0" stroke="#FFFAF1" stroke-width="1" stroke-linecap="round" opacity="0.5"></path>
    <!-- clouds -->
    <path d="M-4 120c4-8 14-8 18-3 3-6 13-7 17 0 4-5 13-4 15 3 4-6 14-5 17 1 3-5 12-5 15 1 4-3 10-2 12 2V146H-4z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path>
    <path d="M-4 134c5-5 12-5 16-1 4-4 11-4 15 0 4-4 12-4 16 0 4-4 11-4 15 0 4-4 11-4 15 0 4-3 9-3 13 0V146H-4z" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.3" stroke-linejoin="round"></path>
    <text x="12.5" y="104" font-family="Figtree, sans-serif" font-size="5.2" font-weight="700" letter-spacing="0.9" fill="#F7F0E3">MACHADO DE ASSIS</text>
  </svg></span>
  <span style="min-width: 0; flex-grow: 1;">
    <span style="display: flex; align-items: center; gap: 6px; font-size: 10.5px; font-weight: 800; letter-spacing: 1.4px; color: #B9AE9C;"><span style="width: 7px; height: 7px; border-radius: 50%; background: #FF552E;"></span>LENDO · PAPEL</span>
    <span style="display: block; margin-top: 2px; font-size: 15px; font-weight: 800; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #F7F0E3;">Brás Cubas</span>
  </span>
  <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px; font-variant-numeric: tabular-nums; color: #F7F0E3;">08:42</span>
  <button aria-label="Pausar" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: none; display: flex; align-items: center; justify-content: center;">
    <svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><rect x="5.5" y="4" width="4.5" height="16" rx="1.5" fill="#1A1714"></rect><rect x="14" y="4" width="4.5" height="16" rx="1.5" fill="#1A1714"></rect></svg>
  </button>
</a>

<!-- Bottom fade so content slips under the floating nav -->
<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 240px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 48%); pointer-events: none;"></div>

<!-- Bottom navigation (fixed in the app; sits above the home-indicator area) -->
<nav aria-label="Navegação principal" style="position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px;">
  <a href="#" aria-current="page" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"></path></svg>
    <span style="font-size: 11px; font-weight: 800;">Início</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4" width="4.5" height="16" rx="1"></rect><rect x="10" y="4" width="4.5" height="16" rx="1"></rect><path d="m16.4 5.6 3.9-1 3.2 14.6-3.9 1z"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Biblioteca</span>
  </a>
  <a href="#" aria-label="Scanner: escanear livro ou página" style="position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px;">
    <span style="position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="28" height="28" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 8V6a2.5 2.5 0 0 1 2.5-2.5h2"></path><path d="M16 3.5h2A2.5 2.5 0 0 1 20.5 6v2"></path><path d="M20.5 16v2a2.5 2.5 0 0 1-2.5 2.5h-2"></path><path d="M8 20.5H6A2.5 2.5 0 0 1 3.5 18v-2"></path><path d="M8 8.5v7"></path><path d="M11 8.5v7"></path><path d="M13.5 8.5v7"></path><path d="M16 8.5v7"></path></svg>
    </span>
    <span style="font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px;">Scanner</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Clubes</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"></circle><path d="M4 21a8 8 0 0 1 16 0"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Perfil</span>
  </a>
</nav>
```

## Especificação pixel a pixel

Seção `i01b.alsoReading` — retângulo absoluto no canvas 390×844: **x=20, y=562.96, w=350, h=205.81**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01b.alsoReading` | box | 0 | 0 | 350 | 205.81 | `margin-top: 32px; display: flex; flex-direction: column; gap: 30px` |  |
| 2 | `i01b.alsoReading.header` | box | 0 | 0 | 350 | 22 | `display: flex; align-items: center; gap: 8px` |  |
| 3 | `i01b.alsoReading.title` ±1 | text | 0 | 0.2 | 126.54 | 21.6 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.3px` | Bricolage (opsz 18) 18/normal peso 800 ls -0.3px #1A1714 |
| 4 | `i01b.alsoReading.count` ±1 | box+text | 134.54 | 0 | 22 | 22 | `min-width: 22px; height: 22px; padding: 0 7px; box-sizing: border-box; border-radius: 999px; background: #1A1714; color: #F7F0E3; font-size: 12px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 12/normal peso 800→**800** ls normal #F7F0E3 |
| 5 | `i01b.alsoReading.grid` | box | 0 | 52 | 350 | 153.81 | `display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px` |  |
| 6 | `i01b.alsoReading.card1` | box | 0 | 52 | 169 | 153.81 | `display: flex; flex-direction: column; gap: 12px; padding: 0 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 7 | `i01b.alsoReading.card1.top` | box | 15.5 | 53.5 | 138 | 59 | `display: flex; align-items: flex-end; justify-content: space-between` |  |
| 8 | `i01b.alsoReading.card1.cover` | box | 15.5 | 31.5 | 54 | 81 | `position: relative; display: block; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box; transform: rotate(-4deg); box-shadow: 2px 2px 0 #1A1714` |  |
| 9 | `i01b.alsoReading.card1.cover.spine` | box | 17 | 33 | 5 | 78 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.18)` |  |
| 10 | `i01b.alsoReading.card1.cover.hat` | box | 35 | 47 | 18 | 16 | `position: absolute; left: 18px; top: 14px; width: 18px; height: 16px; border-radius: 2px 2px 0 0; background: #1A1714` |  |
| 11 | `i01b.alsoReading.card1.cover.brim` | box | 30 | 62 | 28 | 5 | `position: absolute; left: 13px; top: 29px; width: 28px; height: 5px; border-radius: 50%; background: #1A1714` |  |
| 12 | `i01b.alsoReading.card1.cover.title` | text | 26 | 82.1 | 39 | 20.9 | `position: absolute; left: 9px; right: 3px; bottom: 8px; font-family: 'Instrument Serif', Georgia, serif; font-size: 11px; line-height: 0.95; color: #FED170` | Instrument Serif 11/10.45px peso 400 ls normal #FED170 |
| 13 | `i01b.alsoReading.card1.play` | box | 107.5 | 66.5 | 46 | 46 | `width: 46px; height: 46px; margin-top: 12px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-shadow: 0 0 0 3px #FF552E; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 14 | `i01b.alsoReading.card1.play.icon` | icon | 122.5 | 81.5 | 16 | 16 | `—` |  |
| 15 | `i01b.alsoReading.card1.textBlock` | box | 15.5 | 124.5 | 138 | 65.81 | `display: flex; flex-direction: column; gap: 2px; min-width: 0` |  |
| 16 | `i01b.alsoReading.card1.title` | text | 15.5 | 124.5 | 138 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 17 | `i01b.alsoReading.card1.author` | text | 15.5 | 144.5 | 138 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 13/normal peso 500 ls normal #5B544B |
| 18 | `i01b.alsoReading.card1.meta` ±1 | box+text | 15.5 | 168.1 | 119.92 | 22.21 | `margin-top: 6px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 3px 8px 3px 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #E2D7C4; white-space: nowrap` | Figtree 11.5/normal peso 700 ls normal #1A1714 |
| 19 | `i01b.alsoReading.card1.meta.icon` | icon | 22.7 | 173.2 | 12 | 12 | `—` |  |
| 20 | `i01b.alsoReading.card2` | box | 181 | 52 | 169 | 153.81 | `display: flex; flex-direction: column; gap: 12px; padding: 0 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 21 | `i01b.alsoReading.card2.top` | box | 196.5 | 53.5 | 138 | 59 | `display: flex; align-items: flex-end; justify-content: space-between` |  |
| 22 | `i01b.alsoReading.card2.cover` | box | 196.5 | 31.5 | 54 | 81 | `position: relative; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box; transform: rotate(3deg); box-shadow: 2px 2px 0 #1A1714` |  |
| 23 | `i01b.alsoReading.card2.cover.spine` | box | 198 | 33 | 5 | 78 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.12)` |  |
| 24 | `i01b.alsoReading.card2.cover.circle` | box | 215 | 46 | 20 | 20 | `position: absolute; left: 17px; top: 13px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 25 | `i01b.alsoReading.card2.cover.title` | text | 207 | 85.9 | 40 | 17.1 | `position: absolute; left: 9px; right: 2px; bottom: 8px; font-family: 'Instrument Serif', Georgia, serif; font-size: 9px; line-height: 0.95; color: #1A1714` | Instrument Serif 9/8.55px peso 400 ls normal #1A1714 |
| 26 | `i01b.alsoReading.card2.ring` | box | 288.5 | 66.5 | 46 | 46 | `position: relative; width: 46px; height: 46px; margin-top: 12px` |  |
| 27 | `i01b.alsoReading.card2.ring.svg` | icon | 288.5 | 66.5 | 46 | 46 | `—` |  |
| 28 | `i01b.alsoReading.card2.ring.label` | text | 288.5 | 66.5 | 46 | 46 | `position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 29 | `i01b.alsoReading.card2.textBlock` | box | 196.5 | 124.5 | 138 | 65.81 | `display: flex; flex-direction: column; gap: 2px; min-width: 0` |  |
| 30 | `i01b.alsoReading.card2.title` | text | 196.5 | 124.5 | 138 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 31 | `i01b.alsoReading.card2.author` | text | 196.5 | 144.5 | 138 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 13/normal peso 500 ls normal #5B544B |
| 32 | `i01b.alsoReading.card2.meta` ±1 | box+text | 196.5 | 168.1 | 116.36 | 22.21 | `margin-top: 6px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 3px 8px 3px 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #E2D7C4; white-space: nowrap` | Figtree 11.5/normal peso 700 ls normal #1A1714 |
| 33 | `i01b.alsoReading.card2.meta.icon` | icon | 203.7 | 173.2 | 12 | 12 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `i01b.alsoReading.card1.cover`: caixa visual com `transform: rotate(-4deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card1.cover.spine`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card1.cover.hat`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card1.cover.brim`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card1.cover.title`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card2.cover`: caixa visual com `transform: rotate(3deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card2.cover.spine`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card2.cover.circle`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.alsoReading.card2.cover.title`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01b.alsoReading.title` | 1 | Também lendo | 16.94 | 0 | 126.54 | 126.54 |
| `i01b.alsoReading.count` | 1 | 3 | 15.2 | 142.21 | 148.88 | 6.67 |
| `i01b.alsoReading.card1.cover.title` | 1 | Brás | 91.06 | 26 | 42.34 | 16.34 |
| `i01b.alsoReading.card1.cover.title` | 2 | Cubas | 101.51 | 26 | 48.79 | 22.79 |
| `i01b.alsoReading.card1.title` | 1 | Brás Cubas | 138.75 | 15.5 | 92.17 | 76.67 |
| `i01b.alsoReading.card1.author` | 1 | Machado de Assis | 156.85 | 15.5 | 120.81 | 105.31 |
| `i01b.alsoReading.card1.meta` | 1 | Papel · 3h 40min | 183.23 | 38.7 | 126.22 | 87.52 |
| `i01b.alsoReading.card2.cover.title` | 1 | Orgulho e | 93.23 | 207 | 236.76 | 29.76 |
| `i01b.alsoReading.card2.cover.title` | 2 | Preconceito | 101.78 | 207 | 242.46 | 35.46 |
| `i01b.alsoReading.card2.ring.label` | 1 | 81% | 93.35 | 301.34 | 321.66 | 20.32 |
| `i01b.alsoReading.card2.title` | 1 | Orgulho e Preconceito | 138.75 | 196.5 | 351.4 | 154.9 |
| `i01b.alsoReading.card2.author` | 1 | Jane Austen | 156.85 | 196.5 | 269.26 | 72.76 |
| `i01b.alsoReading.card2.meta` | 1 | Papel · pág. 344 | 183.23 | 219.7 | 303.66 | 83.96 |

Seção `i01b.miniBar` — retângulo absoluto no canvas 390×844: **x=16, y=648, w=358, h=66**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 35 | `i01b.miniBar` | box | 0 | 0 | 358 | 66 | `position: absolute; left: 16px; right: 16px; bottom: 130px; height: 66px; padding: 0 10px 0 12px; border-radius: 22px; background: #1A1714; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 rgba(26,23,20,0.35); box-sizing: border-box; display: flex; align-items: center; gap: 12px; overflow: hidden; color: #F7F0E3` |  |
| 36 | `i01b.miniBar.progress` | box | 1.5 | 1.5 | 315.95 | 4 | `position: absolute; left: 0; top: 0; height: 4px; width: 89%; background: {{brand}} (padrão #B6ACE4); border-radius: 0 4px 4px 0` |  |
| 37 | `i01b.miniBar.cover` | box | 13.5 | 9 | 32 | 48 | `width: 32px; height: 48px; flex-shrink: 0; border-radius: 2px 5px 5px 2px; border: 1.2px solid #F7F0E3; background: #058CD7; overflow: hidden; box-sizing: border-box; transform: rotate(-5deg)` |  |
| 38 | `i01b.miniBar.cover.art` | icon | 14.7 | 10.2 | 29.6 | 45.6 | `display: block` |  |
| 39 | `i01b.miniBar.texts` ±1 | box | 57.5 | 16.7 | 157.95 | 32.61 | `min-width: 0; flex-grow: 1` |  |
| 40 | `i01b.miniBar.kicker` ±1 | text | 57.5 | 16.7 | 157.95 | 12.61 | `display: flex; align-items: center; gap: 6px; font-size: 10.5px; font-weight: 800; letter-spacing: 1.4px; color: #B9AE9C` | Figtree 10.5/normal peso 800→**800** ls 1.4px #B9AE9C |
| 41 | `i01b.miniBar.kicker.dot` | box | 57.5 | 19.5 | 7 | 7 | `width: 7px; height: 7px; border-radius: 50%; background: #FF552E` |  |
| 42 | `i01b.miniBar.title` ±1 | text | 57.5 | 31.3 | 157.95 | 18 | `display: block; margin-top: 2px; font-size: 15px; font-weight: 800; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; color: #F7F0E3` | Figtree 15/18px peso 800→**800** ls normal #F7F0E3 |
| 43 | `i01b.miniBar.time` ±1 | text | 227.45 | 18.6 | 63.05 | 28.8 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px; font-variant-numeric: tabular-nums; color: #F7F0E3` | Bricolage (opsz 24) 24/normal peso 800 ls -0.6px #F7F0E3 tnum |
| 44 | `i01b.miniBar.pause` | box | 302.5 | 11 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: none; display: flex; align-items: center; justify-content: center` |  |
| 45 | `i01b.miniBar.pause.icon` | icon | 315.5 | 24 | 18 | 18 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `i01b.miniBar.cover`: caixa visual com `transform: rotate(-5deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01b.miniBar.cover.art`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01b.miniBar.kicker` | 1 | LENDO · PAPEL | 26.67 | 70.5 | 163.96 | 93.46 |
| `i01b.miniBar.title` | 1 | Brás Cubas | 45.55 | 57.5 | 134.16 | 76.66 |
| `i01b.miniBar.time` | 1 | 08:42 | 40.92 | 227.45 | 290.5 | 63.05 |

Seção `i01b.bottomFade` — retângulo absoluto no canvas 390×844: **x=0, y=604, w=390, h=240**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 34 | `i01b.bottomFade` | box | 0 | 0 | 390 | 240 | `position: absolute; left: 0; right: 0; bottom: 0; height: 240px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 48%); pointer-events: none` |  |

Seção `i01b.nav` — retângulo absoluto no canvas 390×844: **x=16, y=744, w=358, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 46 | `i01b.nav` | box | 0 | 0 | 358 | 70 | `position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px` |  |
| 47 | `i01b.nav.home` | box | 9.5 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 48 | `i01b.nav.home.icon` | icon | 30.8 | 15.9 | 22 | 22 | `—` |  |
| 49 | `i01b.nav.home.label` ±1 | text | 28.01 | 40.9 | 27.59 | 13.2 | `font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 50 | `i01b.nav.library` | box | 78.1 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 51 | `i01b.nav.library.icon` | icon | 99.4 | 15.9 | 22 | 22 | `—` |  |
| 52 | `i01b.nav.library.label` ±1 | text | 85.5 | 40.9 | 49.79 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 53 | `i01b.nav.scanner` | box | 146.7 | 9.5 | 64.6 | 51 | `position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px` |  |
| 54 | `i01b.nav.scanner.fab` | box | 149 | -20.5 | 60 | 60 | `position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 55 | `i01b.nav.scanner.icon` | icon | 165 | -4.5 | 28 | 28 | `—` |  |
| 56 | `i01b.nav.scanner.label` ±1 | text | 158.35 | 45.3 | 41.3 | 15.2 | `font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px` | Figtree 11/normal peso 700 ls normal #1A1714 |
| 57 | `i01b.nav.clubs` | box | 215.3 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 58 | `i01b.nav.clubs.icon` | icon | 236.6 | 15.9 | 22 | 22 | `—` |  |
| 59 | `i01b.nav.clubs.label` ±1 | text | 230.37 | 40.9 | 34.45 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 60 | `i01b.nav.profile` | box | 283.9 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 61 | `i01b.nav.profile.icon` | icon | 305.2 | 15.9 | 22 | 22 | `—` |  |
| 62 | `i01b.nav.profile.label` ±1 | text | 303.18 | 40.9 | 26.05 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01b.nav.home.label` | 1 | Início | 51.35 | 28.01 | 55.59 | 27.58 |
| `i01b.nav.library.label` | 1 | Biblioteca | 51.35 | 85.5 | 135.3 | 49.8 |
| `i01b.nav.scanner.label` | 1 | Scanner | 55.75 | 158.35 | 199.65 | 41.3 |
| `i01b.nav.clubs.label` | 1 | Clubes | 51.35 | 230.37 | 264.83 | 34.46 |
| `i01b.nav.profile.label` | 1 | Perfil | 51.35 | 303.18 | 329.22 | 26.04 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Prancha de 844 (a mesma página da 01, cortada na tela): o que passa de 844 existe no layout mas não aparece no PNG (ex.: Quincas Borba e O Cortiço no "Para você", que só aqui trocam Memorial de Aires e Casa de Pensão).
2. Cartão do Brás Cubas: o botão do "play" (mesmo id `alsoReading.card1.play`) mostra **pausar** — `ic_pause` amarelo 16 (o play era 18) e um **aro coral de 3** (`box-shadow 0 0 0 3 #FF552E` → `BoxShadow(spreadRadius: 3)`); rótulo "Pausar leitura de Brás Cubas".
3. Mini-barra: `left/right 16 · bottom 130` (30 acima da barra), 358 × 66, padding 0/10/0/12, raio 22, `#1A1714`, borda 1,5 `#1A1714`, sombra 0/4 `rgba(26,23,20,.35)`, `overflow: hidden`. No topo, progresso de 4 `{{brand}}` em **89 %** (raio 0/4/4/0, dentro da borda).
4. Capa 32 × 48 girada −5° (borda 1,2 `#F7F0E3`, raio 2/5/5/2): `il_capa_bras_cubas_asas.svg` (Brás Cubas com asas, `slice` 0,3167). Textos: "● LENDO · PAPEL" Figtree 10,5/800 (→ 700) ls 1,4 `#B9AE9C` com o ponto coral 7; "Brás Cubas" Figtree 15/800 (→ 700) `#F7F0E3` com reticências.
5. Tempo "08:42" Bricolage 24/800 ls −0,6 **tabular** `#F7F0E3`; pausar: círculo 44 `#F7F0E3` com `ic_pause_tinta` 18.
6. Degradê inferior maior: 240 de altura, opaco em 48 % (na 01: 150 e 55 %) — no app, `features/shell/presentation/bottom_fade.dart` com a altura do estado.
7. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- A capa da mini-barra é SVG com `<text>` (Figtree 800 4,6 e 700 5,2; Instrument Serif 17,5) em escala 0,3167: textos em `AppText` por cima ou o desenho sem textos (catálogo de SVGs).
- O tempo atualiza a cada segundo com números tabulares: largura fixa, sem "pular".

## Diferenças em relação à prancha 01 (seções reutilizadas: header, headline, hero, alsoReading, today, forYou, club, recent)

Estas seções são as mesmas widgets da 01 (fases L01a1_cabecalho, L01a2_heroi, L01a3_tambem_lendo, L01a4_seu_dia, L01a5_revisao, L01a6_para_voce, L01a7_clube, L01a8_recem_chegados, L01a9_barra); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `i01b.alsoReading.card1.play` | shadow: null → "#FF552E 0px 0px 0px 3px" |
| `i01b.alsoReading.card1.play.icon` | retângulo ['141.5', '643.46', '18', '18'] → ['142.5', '644.46', '16', '16'] |
| `i01b.forYou` (seção inteira) | muda de lugar: x 0, y -205.15 (abaixo, os ids dela já descontado esse deslocamento) |
| `i01b.forYou.item2.cover.title` | texto «Memorial / de Aires» → «Quincas / Borba» |
| `i01b.forYou.item2.title` | texto «Memorial de Aires» → «Quincas Borba» |
| `i01b.forYou.item3.cover.textBlock` | retângulo ['297.5', '1673.01', '87', '60.61'] → ['297.5', '1491.26', '87', '37.21']; position: {"top": "98.39px", "right": "10px", "bottom": "12px", "left": "16px"} → {"top": "121.79px", "right": "10px", "bottom": "12px", "left": "16px"} |
| `i01b.forYou.item3.cover.title` | retângulo ['297.5', '1673.01', '87', '46.8'] → ['297.5', '1491.26', '87', '23.4']; texto «Casa de / Pensão» → «O Cortiço» |
| `i01b.forYou.item3.title` | texto «Casa de Pensão» → «O Cortiço» |
| `i01b.club` (seção inteira) | muda de lugar: x 0, y -205.15 (abaixo, os ids dela já descontado esse deslocamento) |
| `i01b.recent` (seção inteira) | muda de lugar: x 0, y -205.15 (abaixo, os ids dela já descontado esse deslocamento) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01b.alsoReading` |  | Também lendo |  |
| `i01b.alsoReading.card1.cover` |  | Memórias Póstumas de Brás Cubas |  |
| `i01b.alsoReading.card1.play` |  | Pausar leitura de Brás Cubas |  |
| `i01b.alsoReading.card1.play.icon` |  |  | aria-hidden=true |
| `i01b.alsoReading.card1.meta.icon` |  |  | aria-hidden=true |
| `i01b.alsoReading.card2.ring.svg` |  |  | aria-hidden=true |
| `i01b.alsoReading.card2.meta.icon` |  |  | aria-hidden=true |
| `i01b.bottomFade` |  |  | aria-hidden=true |
| `i01b.miniBar` |  | Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro |  |
| `i01b.miniBar.progress` |  |  | aria-hidden=true |
| `i01b.miniBar.cover` |  |  | aria-hidden=true |
| `i01b.miniBar.pause` |  | Pausar |  |
| `i01b.miniBar.pause.icon` |  |  | aria-hidden=true |
| `i01b.nav` |  | Navegação principal |  |
| `i01b.nav.home` |  |  | aria-current=page |
| `i01b.nav.scanner` |  | Scanner: escanear livro ou página |  |
| `i01b.nav.scanner.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01b.alsoReading.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01b.alsoReading.card1` | NeoBox |  |
| `i01b.alsoReading.card1.cover` | NeoBox | Transform: rotate(-4deg) |
| `i01b.alsoReading.card1.cover.spine` | NeoBox |  |
| `i01b.alsoReading.card1.cover.hat` | NeoBox |  |
| `i01b.alsoReading.card1.cover.brim` | CircleIconButton / NeoBox circular |  |
| `i01b.alsoReading.card1.play` | CircleIconButton / NeoBox circular |  |
| `i01b.alsoReading.card1.play.icon` | AppSvg(AppIconsInicio.ic_pause, size: 16) | o "pausar": no Brás Cubas da 01b tem o id do "play" da 01 (alsoReading.card1.play: um botão com dois estados, cronômetro parado/rodando — não dois widgets), amarelo 16; a mini-barra usa o mesmo desenho em tinta 18 (ic_pause_tinta). |
| `i01b.alsoReading.card1.meta` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01b.alsoReading.card1.meta.icon` | AppSvg(AppIconsInicio.ic_book_paper, size: 12) |  |
| `i01b.alsoReading.card2` | NeoBox |  |
| `i01b.alsoReading.card2.cover` | NeoBox | Transform: rotate(3deg) |
| `i01b.alsoReading.card2.cover.spine` | NeoBox |  |
| `i01b.alsoReading.card2.cover.circle` | CircleIconButton / NeoBox circular |  |
| `i01b.alsoReading.card2.ring.svg` | CustomPainter (anel_progresso_livro) | stroke-dasharray = progresso do livro (91,6 de 113,1 = 2π·18 → 81 %) com rotate(-90): anel desenhado por CustomPainter com o valor real (o rótulo "81%" é texto da página, não do SVG). |
| `i01b.alsoReading.card2.meta` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01b.alsoReading.card2.meta.icon` | AppSvg(AppIconsInicio.ic_book_paper, size: 12) |  |
| `i01b.bottomFade` | DecoratedBox(LinearGradient) |  |
| `i01b.miniBar` | NeoBox |  |
| `i01b.miniBar.progress` | NeoBox |  |
| `i01b.miniBar.cover` | NeoBox | Transform: rotate(-5deg) |
| `i01b.miniBar.cover.art` | AppSvg(AppIllustrationsInicio.il_capa_bras_cubas_asas, size: 29.6×45.6) | tem <text> (Instrument Serif 19 no título; Figtree 700 5,2 no autor; Figtree 800 4,6 em "MEMÓRIAS PÓSTUMAS DE", em unidades do viewBox 96×144) e preserveAspectRatio="xMidYMid slice" (escala max(29,6/96, 45,6/144) = 0,3167): o flutter_svg desenha <text> com a fonte do sistema e não faz "slice" → no app, o desenho sem os textos (BoxFit.cover) e os textos com AppText por cima, nas mesmas posições × escala; a capa fica dentro de uma caixa girada (rotate(-5deg)) — o tamanho do catálogo é o do layout, sem o giro. |
| `i01b.miniBar.kicker.dot` | CircleIconButton / NeoBox circular |  |
| `i01b.miniBar.pause` | CircleIconButton / NeoBox circular |  |
| `i01b.miniBar.pause.icon` | AppSvg(AppIconsInicio.ic_pause_tinta, size: 18) | o "pausar": no Brás Cubas da 01b tem o id do "play" da 01 (alsoReading.card1.play: um botão com dois estados, cronômetro parado/rodando — não dois widgets), amarelo 16; a mini-barra usa o mesmo desenho em tinta 18 (ic_pause_tinta). |
| `i01b.nav` | NeoBox |  |
| `i01b.nav.home` | NeoBox |  |
| `i01b.nav.home.icon` | AppSvg(AppIcons.ic_nav_home_active, size: 22) |  |
| `i01b.nav.library.icon` | AppSvg(AppIcons.ic_nav_library, size: 22) |  |
| `i01b.nav.scanner.fab` | CircleIconButton / NeoBox circular |  |
| `i01b.nav.scanner.icon` | AppSvg(AppIcons.ic_nav_scanner, size: 28) |  |
| `i01b.nav.clubs.icon` | AppSvg(AppIcons.ic_nav_clubs, size: 22) |  |
| `i01b.nav.profile.icon` | AppSvg(AppIcons.ic_nav_profile, size: 22) |  |

## Interações

- Pausar (cartão ou mini-barra) → pausa a sessão; o mesmo botão retoma (T04).
- Toque na mini-barra → sem ação (D-243 b): o elemento fica idêntico à prancha, o toque não faz nada, um teste documenta e o item entra em `docs/design/estados_sem_design.md` até a tela do cronômetro (C15).
- Fim da sessão com a página do papel: D-243 a (mínimo da D-23).

## Dados

- "08:42" = tempo da sessão aberta (sobrevive ao app fechado); 89 % = meta do dia contando a sessão ((18 + 8,7) ÷ 30); "LENDO · PAPEL" = formato do livro; rótulo da mini-barra "Sessão em andamento: Brás Cubas, 8 minutos e 42 segundos. Abrir cronômetro".
- Sem o cartão da revisão: a 01b mostra a Início sem a seção (D-247), por isso tudo abaixo sobe 205,15.

## Subfases

- **L01b.1** Estado "pausar" do cartão (ícone + aro coral)
- **L01b.2** Mini-barra (fundo, progresso 89 %, capa girada)
- **L01b.3** Textos e tempo tabular
- **L01b.4** Degradê de 240
- **L01b.5** Toques (pausar; mini-barra D-243 b)
- **L01b.6** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01b.alsoReading', 'i01b.miniBar', 'i01b.bottomFade', 'i01b.nav'), todos os ids de `kRef01b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001b_inicio_lendo_agora_390x844@3x.png` no recorte da fase (y 554.96–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01b.1 Estado "pausar" do cartão (ícone + aro coral)
- [ ] L01b.2 Mini-barra (fundo, progresso 89 %, capa girada)
- [ ] L01b.3 Textos e tempo tabular
- [ ] L01b.4 Degradê de 240
- [ ] L01b.5 Toques (pausar; mini-barra D-243 b)
- [ ] L01b.6 Verificação + relatório
- [ ] Geometria 62/62 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
