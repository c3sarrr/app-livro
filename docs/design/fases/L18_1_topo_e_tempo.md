# FASE L18 — Cronômetro — a barra de cima (minimizar, a sessão e o som ambiente), o livro e o relógio (o anel, o estado, o tempo e o de hoje)

> Tela 18 · prancha `018_cronometro` (18 · Cronômetro de leitura (livro físico), canvas 390×844) · executada na **T18** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L18_1_topo_e_tempo@3x.png` · `docs/design/medicao/projeto/png/redline/L18_1_topo_e_tempo_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/018_cronometro_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_018_cronometro.json` · `test/reference/projeto/reference_layout_018_cronometro.dart` (`kRef18`).
> Arquivos sugeridos: `lib/features/reading_session/presentation/timer/timer_screen.dart`, `lib/features/reading_session/presentation/timer/timer_top_bar.dart`, `lib/features/reading_session/presentation/timer/timer_dial.dart`, `lib/core/design_system/painters/timer_ring_painter.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Cronômetro (18), em cima: a barra (minimizar com o tempo andando, "SESSÃO 7", o som ambiente "Chuva"), o livro de papel (a capa girada, o título e "Machado de Assis · livro físico") e o relógio — o mostrador com os 60 traços, o anel da meta de hoje, "LENDO", o tempo 08:42 e "Hoje: 26 de 30 min". Substitui a folha mínima da T04.

---

## HTML literal da seção

Props do componente: `{{arc}}` = padrão `#FED170`.

```html
<!-- Top bar: minimize keeps the timer running -->
<header style="align-self: stretch; height: 48px; display: flex; align-items: center; justify-content: space-between;">
  <button aria-label="Minimizar (o tempo continua)" style="width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m6 9 6 6 6-6"></path></svg></button>
  <span style="font-size: 12px; font-weight: 800; letter-spacing: 1.6px; color: #B9AE9C;">SESSÃO 7</span>
  <button aria-label="Som ambiente: chuva" style="height: 40px; padding: 0 14px 0 11px; border-radius: 999px; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 13px; font-weight: 800; color: #F7F0E3;"><svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 16.2A4.5 4.5 0 0 0 17.5 8h-1.8A7 7 0 1 0 4 14.9"></path><path d="M16 14v6M8 14v6M12 16v6"></path></svg>Chuva</button>
</header>

<!-- What you're reading (paper book) -->
<div style="align-self: stretch; margin-top: 18px; display: flex; align-items: center; gap: 14px;">
  <div aria-hidden="true" style="width: 46px; height: 69px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #F7F0E3; background: #058CD7; overflow: hidden; box-sizing: border-box; transform: rotate(-5deg); box-shadow: 3px 3px 0 #000;"><svg width="100%" height="100%" viewBox="0 0 96 144" preserveAspectRatio="xMidYMid slice" style="display: block;">
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
</svg></div>
  <div style="min-width: 0;">
    <div style="font-size: 15.5px; font-weight: 800; line-height: 1.25;">Memórias Póstumas de Brás Cubas</div>
    <div style="margin-top: 3px; font-size: 13px; font-weight: 600; color: #B9AE9C;">Machado de Assis · livro físico</div>
  </div>
</div>

<!-- Dial: minute ticks + today's goal arc -->
<div role="timer" aria-label="8 minutos e 42 segundos nesta sessão; 26 de 30 minutos hoje" style="position: relative; margin-top: 18px; width: 300px; height: 300px;">
  <svg width="300" height="300" viewBox="0 0 300 300" aria-hidden="true" style="position: absolute; inset: 0;">
    <circle cx="150" cy="150" r="146" fill="#221E1A" stroke="rgba(247,240,227,0.85)" stroke-width="1.5"></circle>
    <line x1="150.0" y1="26.0" x2="150.0" y2="14.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="163.6" y1="20.7" x2="164.2" y2="14.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="177.0" y1="22.8" x2="178.3" y2="17.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="190.2" y1="26.4" x2="192.0" y2="20.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="202.9" y1="31.2" x2="205.3" y2="25.8" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="212.0" y1="42.6" x2="218.0" y2="32.2" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="226.4" y1="44.8" x2="229.9" y2="40.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="237.0" y1="53.4" x2="241.0" y2="48.9" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="246.6" y1="63.0" x2="251.1" y2="59.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="255.2" y1="73.6" x2="260.0" y2="70.1" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="257.4" y1="88.0" x2="267.8" y2="82.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="268.8" y1="97.1" x2="274.2" y2="94.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="273.6" y1="109.8" x2="279.3" y2="108.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="277.2" y1="123.0" x2="283.0" y2="121.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="279.3" y1="136.4" x2="285.3" y2="135.8" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="274.0" y1="150.0" x2="286.0" y2="150.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="279.3" y1="163.6" x2="285.3" y2="164.2" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="277.2" y1="177.0" x2="283.0" y2="178.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="273.6" y1="190.2" x2="279.3" y2="192.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="268.8" y1="202.9" x2="274.2" y2="205.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="257.4" y1="212.0" x2="267.8" y2="218.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="255.2" y1="226.4" x2="260.0" y2="229.9" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="246.6" y1="237.0" x2="251.1" y2="241.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="237.0" y1="246.6" x2="241.0" y2="251.1" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="226.4" y1="255.2" x2="229.9" y2="260.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="212.0" y1="257.4" x2="218.0" y2="267.8" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="202.9" y1="268.8" x2="205.3" y2="274.2" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="190.2" y1="273.6" x2="192.0" y2="279.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="177.0" y1="277.2" x2="178.3" y2="283.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="163.6" y1="279.3" x2="164.2" y2="285.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="150.0" y1="274.0" x2="150.0" y2="286.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="136.4" y1="279.3" x2="135.8" y2="285.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="123.0" y1="277.2" x2="121.7" y2="283.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="109.8" y1="273.6" x2="108.0" y2="279.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="97.1" y1="268.8" x2="94.7" y2="274.2" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="88.0" y1="257.4" x2="82.0" y2="267.8" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="73.6" y1="255.2" x2="70.1" y2="260.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="63.0" y1="246.6" x2="59.0" y2="251.1" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="53.4" y1="237.0" x2="48.9" y2="241.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="44.8" y1="226.4" x2="40.0" y2="229.9" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="42.6" y1="212.0" x2="32.2" y2="218.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="31.2" y1="202.9" x2="25.8" y2="205.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="26.4" y1="190.2" x2="20.7" y2="192.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="22.8" y1="177.0" x2="17.0" y2="178.3" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="20.7" y1="163.6" x2="14.7" y2="164.2" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="26.0" y1="150.0" x2="14.0" y2="150.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="20.7" y1="136.4" x2="14.7" y2="135.8" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="22.8" y1="123.0" x2="17.0" y2="121.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="26.4" y1="109.8" x2="20.7" y2="108.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="31.2" y1="97.1" x2="25.8" y2="94.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="42.6" y1="88.0" x2="32.2" y2="82.0" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="44.8" y1="73.6" x2="40.0" y2="70.1" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="53.4" y1="63.0" x2="48.9" y2="59.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="63.0" y1="53.4" x2="59.0" y2="48.9" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="73.6" y1="44.8" x2="70.1" y2="40.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="88.0" y1="42.6" x2="82.0" y2="32.2" stroke="#F7F0E3" stroke-opacity="0.9" stroke-width="2" stroke-linecap="round"></line><line x1="97.1" y1="31.2" x2="94.7" y2="25.8" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="109.8" y1="26.4" x2="108.0" y2="20.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="123.0" y1="22.8" x2="121.7" y2="17.0" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line><line x1="136.4" y1="20.7" x2="135.8" y2="14.7" stroke="#F7F0E3" stroke-opacity="0.35" stroke-width="1.2" stroke-linecap="round"></line>
    <circle cx="150" cy="150" r="112" fill="none" stroke="#3A332C" stroke-width="10"></circle><circle cx="150" cy="150" r="112" fill="none" stroke="{{arc}}" stroke-width="10" stroke-linecap="round" stroke-dasharray="626.3 703.7" transform="rotate(-90 150 150)"></circle>
    <circle cx="78.6" cy="63.7" r="9" fill="#F7F0E3" stroke="#1A1714" stroke-width="2.5"></circle>
  </svg>
  <div style="position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center;">
    <span style="display: flex; align-items: center; gap: 7px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.8px; color: #B9AE9C;"><span style="width: 8px; height: 8px; border-radius: 50%; background: #FF552E;"></span>LENDO</span>
    <span style="margin-top: 6px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 74px; line-height: 1; letter-spacing: -2px; font-variant-numeric: tabular-nums;">08:42</span>
    <span style="margin-top: 8px; font-size: 14px; font-weight: 600; color: #B9AE9C;">Hoje: <strong style="color: #F7F0E3; font-weight: 800;">26</strong> de 30 min</span>
  </div>
</div>
```

## Especificação pixel a pixel

Seção `cr18.top` — retângulo absoluto no canvas 390×844: **x=20, y=58, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `cr18.top` | box | 0 | 0 | 350 | 48 | `align-self: stretch; height: 48px; display: flex; align-items: center; justify-content: space-between` |  |
| 2 | `cr18.top.minimize` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; padding: 0; border-radius: 50%; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `cr18.top.minimize.icon` | icon | 13 | 13 | 22 | 22 | `—` |  |
| 4 | `cr18.top.session` ±1 | text | 118.99 | 16.8 | 69.42 | 14.4 | `font-size: 12px; font-weight: 800; letter-spacing: 1.6px; color: #B9AE9C` | Figtree 12/normal peso 800 ls 1.6px #B9AE9C |
| 5 | `cr18.top.sound` ±1 | box+text | 259.39 | 4 | 90.61 | 40 | `height: 40px; padding: 0 14px 0 11px; border-radius: 999px; background: #2B2621; border: 1.5px solid rgba(247,240,227,0.85); box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 13px; font-weight: 800; color: #F7F0E3` | Figtree 13/normal peso 800 ls normal #F7F0E3 |
| 6 | `cr18.top.sound.icon` ±1 | icon | 271.89 | 15.5 | 17 | 17 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18.top.session` | 1 | SESSÃO 7 | 28.2 | 118.99 | 188.4 | 69.41 |
| `cr18.top.sound` | 1 | Chuva | 28.55 | 295.89 | 334.5 | 38.61 |

Seção `cr18.book` — retângulo absoluto no canvas 390×844: **x=20, y=124, w=350, h=69**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 7 | `cr18.book` | box | 0 | 0 | 350 | 69 | `align-self: stretch; margin-top: 18px; display: flex; align-items: center; gap: 14px` |  |
| 8 | `cr18.book.cover` | box | 0 | 0 | 46 | 69 | `width: 46px; height: 69px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #F7F0E3; background: #058CD7; overflow: hidden; box-sizing: border-box; transform: rotate(-5deg); box-shadow: 3px 3px 0 #000` |  |
| 9 | `cr18.book.cover.art` | icon | 1.5 | 1.5 | 43 | 66 | `display: block` |  |
| 10 | `cr18.book.textBlock` ±1 | box | 60 | 15.51 | 250.68 | 37.98 | `min-width: 0` |  |
| 11 | `cr18.book.title` ±1 | text | 60 | 15.51 | 250.68 | 19.38 | `font-size: 15.5px; font-weight: 800; line-height: 1.25` | Figtree 15.5/19.375px peso 800 ls normal #F7F0E3 |
| 12 | `cr18.book.author` ±1 | text | 60 | 37.89 | 250.68 | 15.6 | `margin-top: 3px; font-size: 13px; font-weight: 600; color: #B9AE9C` | Figtree 13/normal peso 600 ls normal #B9AE9C |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `cr18.book.cover`: caixa visual com `transform: rotate(-5deg)` = x -2.92, y -1.87, w 51.84, h 72.75 (relativa à seção).
- `cr18.book.cover.art`: caixa visual deslocada pelo transform de um ancestral = x -1.29, y -0.25, w 48.59, h 69.5 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18.book.title` | 1 | Memórias Póstumas de Brás Cubas | 30.62 | 60 | 310.68 | 250.68 |
| `cr18.book.author` | 1 | Machado de Assis · livro físico | 50.24 | 60 | 236.54 | 176.54 |

Seção `cr18.timer` — retângulo absoluto no canvas 390×844: **x=45, y=211, w=300, h=300**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 13 | `cr18.timer` | box | 0 | 0 | 300 | 300 | `position: relative; margin-top: 18px; width: 300px; height: 300px` |  |
| 14 | `cr18.timer.ring` | icon | 0 | 0 | 300 | 300 | `position: absolute; inset: 0` |  |
| 15 | `cr18.timer.center` | box | 0 | 0 | 300 | 300 | `position: absolute; inset: 0; display: flex; flex-direction: column; align-items: center; justify-content: center` |  |
| 16 | `cr18.timer.status` ±1 | text | 118.44 | 90.69 | 63.12 | 13.81 | `display: flex; align-items: center; gap: 7px; font-size: 11.5px; font-weight: 800; letter-spacing: 1.8px; color: #B9AE9C` | Figtree 11.5/normal peso 800 ls 1.8px #B9AE9C |
| 17 | `cr18.timer.status.dot` ±1 | box | 118.44 | 93.6 | 8 | 8 | `width: 8px; height: 8px; border-radius: 50%; background: #FF552E` |  |
| 18 | `cr18.timer.time` ±1 | text | 57.88 | 110.5 | 184.25 | 74 | `margin-top: 6px; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 74px; line-height: 1; letter-spacing: -2px; font-variant-numeric: tabular-nums` | Bricolage (opsz 74) 74/74px peso 800 ls -2px #F7F0E3 tnum |
| 19 | `cr18.timer.today` ±1 | text | 89.8 | 192.5 | 120.4 | 16.8 | `margin-top: 8px; font-size: 14px; font-weight: 600; color: #B9AE9C` | Figtree 14/normal peso 600 ls normal #B9AE9C |
| 20 | `cr18.timer.today.minutes` ±1 | inline | 127.42 | 192.5 | 16.44 | 16.8 | `color: #F7F0E3; font-weight: 800` | Figtree 14/normal peso 800 ls normal #F7F0E3 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `cr18.timer.status` | 1 | LENDO | 101.62 | 133.44 | 181.56 | 48.12 |
| `cr18.timer.time` | 1 | 08:42 | 171.93 | 57.88 | 242.12 | 184.24 |
| `cr18.timer.today` *(composto)* | 1 | Hoje: 26 de 30 min | 205.81 | 89.8 | 210.2 | 120.4 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A coluna é centrada em x = 195, com 18 entre o topo, o livro, o relógio e as etiquetas.
2. Topo de 48 (`align-self: stretch`, `space-between`): minimizar (48, a seta para baixo 22 traço 2,2), "SESSÃO 7" 12/800 ls 1,6 `#B9AE9C` e o som (pílula de 40, padding 0/14/0/11, gap 7, a nuvem de chuva 17 e "Chuva" 13/800).
3. Livro 18 abaixo (gap 14): a capa 46 × 69 (raio 3/7/7/3, borda 1,5 creme, sombra 3/3 preta) girada −5°, com o desenho da capa (SVG `slice`); "Memórias Póstumas de Brás Cubas" 15,5/800 `lh 1,25` e o autor com o formato 13/600 `#B9AE9C`, 3 abaixo.
4. Relógio 18 abaixo, 300 × 300 (`role="timer"`): o círculo de raio 146 `#221E1A` com a borda 1,5 creme a 0,85; os 60 traços (12 grossos de 2 a 0,9 e 48 finos de 1,2 a 0,35, pontas redondas); o trilho de raio 112 (10 `#3A332C`) e o arco `{{arc}}` de 10 com a ponta redonda, começando no alto.
5. No meio: "LENDO" 11,5/800 ls 1,8 `#B9AE9C` com a bolinha coral 8; o tempo Bricolage 74/800 `lh 1` ls −2 `tnum`, 6 abaixo; "Hoje: 26 de 30 min" 14/600 `#B9AE9C` com o "26" 800 creme, 8 abaixo.
6. A tela é escura (o fundo da prancha, para não brilhar ao lado do livro de papel — a nota do design): os botões `#2B2621` com a borda 1,5 creme a 0,85, os textos `#F7F0E3` e os secundários `#B9AE9C`.
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O arco da prancha tem 626,3 de 703,7 (89%), mas 26 de 30 dá 86,7%: o desenho não bate com o número. No app o arco é o progresso real; a fixture que reproduz a prancha e a regra (fração exata ou o arco da prancha) é pergunta da T18.
- O tempo usa algarismos tabulares (`font-variant-numeric: tabular-nums`; no app, `withTabularFigures()`, D-282): 08:42 e 12:31 têm a mesma largura (184,25). O número do "Hoje" não: o "30" é 0,54 mais largo que o "26" e a linha continua centrada.
- A capa girada desenha fora da própria caixa (a referência guarda a caixa sem o giro e a visível, `vis`).
- O arco é `stroke-dasharray` girado −90°: `CustomPainter` com o valor real (o mapa de widgets), não o SVG.
- As três cores com nome da prancha (`meta.props`): `arc` #FED170 (o arco do anel e a etiqueta da meta), `goal` #ABCF82 (o selo e o cartão de hoje) e `brand` #B6ACE4 (o anel de 4 em volta do campo da página) — no app vêm dos tokens.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_018_cronometro_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_018_cronometro_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `cr18.top.minimize` |  | Minimizar (o tempo continua) |  |
| `cr18.top.minimize.icon` |  |  | aria-hidden=true |
| `cr18.top.sound` |  | Som ambiente: chuva |  |
| `cr18.top.sound.icon` |  |  | aria-hidden=true |
| `cr18.book.cover` |  |  | aria-hidden=true |
| `cr18.timer` | timer | 8 minutos e 42 segundos nesta sessão; 26 de 30 minutos hoje |  |
| `cr18.timer.ring` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `cr18.top.minimize` | CircleIconButton / NeoBox circular |  |
| `cr18.top.minimize.icon` | AppSvg(AppIconsCronometro.chevronDownPapel, size: 22) |  |
| `cr18.top.sound` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `cr18.top.sound.icon` | AppSvg(AppIconsCronometro.rainPapel, size: 17) |  |
| `cr18.book.cover` | NeoBox | Transform: rotate(-5deg) |
| `cr18.book.cover.art` | AppSvg(AppIllustrationsInicio.coverBrasCubasWings, size: 43×66) | capa da Início com `<text>` ("MEMÓRIAS PÓSTUMAS DE" Figtree 800 4,6 ls 0,8; "Brás Cubas" Instrument Serif 17,5; "MACHADO DE ASSIS" Figtree 700 5,2 ls 0,9) e preserveAspectRatio="xMidYMid slice", width/height 100% da caixa 43×66 (escala max(43/96, 66/144) = 0,4583): AppSvg sem os textos em BoxFit.cover e os textos em AppText por cima, nas posições × escala (como o herói da Início). |
| `cr18.timer.ring` | CustomPainter (anel_cronometro) | cores dinâmicas: #FED170 = arc · stroke-dasharray = progresso (dasharray 626,3 de 703,7 = 2π·112 → 89 %, rotate(-90)): anel desenhado por CustomPainter com o valor real; o SVG é a referência do estado da prancha. A cor do arco é a prop "arc". |
| `cr18.timer.status.dot` | CircleIconButton / NeoBox circular |  |
| `cr18.timer.today.minutes` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Minimizar → fecha a tela e o tempo continua: volta para onde estava, com a mini-barra da T04 (D-256); tocar na mini-barra reabre o cronômetro.
- Som ambiente → escolher e tocar chuva, café ou lareira (a nota do design) — a escolha e o tocador não têm prancha nem pacote no app: sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T18 (ROTEIRO §2b); o áudio é pergunta da T18.
- O relógio anda a cada segundo (o `second_ticker.dart` da T04), também com a tela bloqueada ou o app minimizado (a nota do design pede a notificação fixa no Android e a Live Activity no iPhone — pergunta da T18).

## Dados

- A sessão aberta (`OpenPaperSession`) e o livro de papel (`paper_book_source.dart`): o tempo desta sessão, o número da sessão do livro ("SESSÃO 7" = as sessões já gravadas + 1), o título, o autor e o formato.
- "Hoje" = os minutos do dia (todas as sessões, papel e e-book) contra a meta diária (`ReadingGoals`); o arco é essa fração.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L18.1** Tela escura e a coluna centrada
- **L18.2** Topo: minimizar, sessão e som
- **L18.3** Livro com a capa girada
- **L18.4** Relógio: mostrador, traços e arco
- **L18.5** Estado, tempo e hoje
- **L18.6** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('cr18.top', 'cr18.book', 'cr18.timer'), todos os ids de `kRef18.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/018_cronometro_390x844@3x.png` no recorte da fase (y 50–519) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef18w360` e `kRef18w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L18.1 Tela escura e a coluna centrada
- [ ] L18.2 Topo: minimizar, sessão e som
- [ ] L18.3 Livro com a capa girada
- [ ] L18.4 Relógio: mostrador, traços e arco
- [ ] L18.5 Estado, tempo e hoje
- [ ] L18.6 Verificação + relatório
- [ ] Geometria 19/19 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
