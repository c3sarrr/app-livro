# FASE L01a3 — Início — Também lendo (livro de papel e e-book)

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a3_tambem_lendo@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a3_tambem_lendo_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/also_reading_section.dart`, `lib/features/home/presentation/covers/memorias_postumas_cover.dart`, `lib/features/home/presentation/covers/pride_prejudice_cover.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

"Também lendo 3": Brás Cubas (livro de papel, com o "play" do cronômetro e "Papel · 3h 40min") e Orgulho e Preconceito (papel, anel de 81 % e "Papel · pág. 344").

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
        <button aria-label="Iniciar leitura de Brás Cubas" style="width: 46px; height: 46px; margin-top: 12px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
          <svg width="18" height="18" sc-camel-view-box="0 0 24 24" aria-hidden="true"><path d="M8 5.5v13a1 1 0 0 0 1.5.86l10.2-6.5a1 1 0 0 0 0-1.72L9.5 4.64A1 1 0 0 0 8 5.5z" fill="#FED170"></path></svg>
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
```

## Especificação pixel a pixel

Seção `i01.alsoReading` — retângulo absoluto no canvas 390×2650: **x=20, y=562.96, w=350, h=205.81**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.alsoReading` | box | 0 | 0 | 350 | 205.81 | `margin-top: 32px; display: flex; flex-direction: column; gap: 30px` |  |
| 2 | `i01.alsoReading.header` | box | 0 | 0 | 350 | 22 | `display: flex; align-items: center; gap: 8px` |  |
| 3 | `i01.alsoReading.title` ±1 | text | 0 | 0.2 | 126.54 | 21.6 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.3px` | Bricolage (opsz 18) 18/normal peso 800 ls -0.3px #1A1714 |
| 4 | `i01.alsoReading.count` ±1 | box+text | 134.54 | 0 | 22 | 22 | `min-width: 22px; height: 22px; padding: 0 7px; box-sizing: border-box; border-radius: 999px; background: #1A1714; color: #F7F0E3; font-size: 12px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 12/normal peso 800→**800** ls normal #F7F0E3 |
| 5 | `i01.alsoReading.grid` | box | 0 | 52 | 350 | 153.81 | `display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px` |  |
| 6 | `i01.alsoReading.card1` | box | 0 | 52 | 169 | 153.81 | `display: flex; flex-direction: column; gap: 12px; padding: 0 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 7 | `i01.alsoReading.card1.top` | box | 15.5 | 53.5 | 138 | 59 | `display: flex; align-items: flex-end; justify-content: space-between` |  |
| 8 | `i01.alsoReading.card1.cover` | box | 15.5 | 31.5 | 54 | 81 | `position: relative; display: block; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box; transform: rotate(-4deg); box-shadow: 2px 2px 0 #1A1714` |  |
| 9 | `i01.alsoReading.card1.cover.spine` | box | 17 | 33 | 5 | 78 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.18)` |  |
| 10 | `i01.alsoReading.card1.cover.hat` | box | 35 | 47 | 18 | 16 | `position: absolute; left: 18px; top: 14px; width: 18px; height: 16px; border-radius: 2px 2px 0 0; background: #1A1714` |  |
| 11 | `i01.alsoReading.card1.cover.brim` | box | 30 | 62 | 28 | 5 | `position: absolute; left: 13px; top: 29px; width: 28px; height: 5px; border-radius: 50%; background: #1A1714` |  |
| 12 | `i01.alsoReading.card1.cover.title` | text | 26 | 82.1 | 39 | 20.9 | `position: absolute; left: 9px; right: 3px; bottom: 8px; font-family: 'Instrument Serif', Georgia, serif; font-size: 11px; line-height: 0.95; color: #FED170` | Instrument Serif 11/10.45px peso 400 ls normal #FED170 |
| 13 | `i01.alsoReading.card1.play` | box | 107.5 | 66.5 | 46 | 46 | `width: 46px; height: 46px; margin-top: 12px; padding: 0; border-radius: 50%; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 14 | `i01.alsoReading.card1.play.icon` | icon | 121.5 | 80.5 | 18 | 18 | `—` |  |
| 15 | `i01.alsoReading.card1.textBlock` | box | 15.5 | 124.5 | 138 | 65.81 | `display: flex; flex-direction: column; gap: 2px; min-width: 0` |  |
| 16 | `i01.alsoReading.card1.title` | text | 15.5 | 124.5 | 138 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 17 | `i01.alsoReading.card1.author` | text | 15.5 | 144.5 | 138 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 13/normal peso 500 ls normal #5B544B |
| 18 | `i01.alsoReading.card1.meta` ±1 | box+text | 15.5 | 168.1 | 119.92 | 22.21 | `margin-top: 6px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 3px 8px 3px 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #E2D7C4; white-space: nowrap` | Figtree 11.5/normal peso 700 ls normal #1A1714 |
| 19 | `i01.alsoReading.card1.meta.icon` | icon | 22.7 | 173.2 | 12 | 12 | `—` |  |
| 20 | `i01.alsoReading.card2` | box | 181 | 52 | 169 | 153.81 | `display: flex; flex-direction: column; gap: 12px; padding: 0 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 21 | `i01.alsoReading.card2.top` | box | 196.5 | 53.5 | 138 | 59 | `display: flex; align-items: flex-end; justify-content: space-between` |  |
| 22 | `i01.alsoReading.card2.cover` | box | 196.5 | 31.5 | 54 | 81 | `position: relative; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box; transform: rotate(3deg); box-shadow: 2px 2px 0 #1A1714` |  |
| 23 | `i01.alsoReading.card2.cover.spine` | box | 198 | 33 | 5 | 78 | `position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.12)` |  |
| 24 | `i01.alsoReading.card2.cover.circle` | box | 215 | 46 | 20 | 20 | `position: absolute; left: 17px; top: 13px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 25 | `i01.alsoReading.card2.cover.title` | text | 207 | 85.9 | 40 | 17.1 | `position: absolute; left: 9px; right: 2px; bottom: 8px; font-family: 'Instrument Serif', Georgia, serif; font-size: 9px; line-height: 0.95; color: #1A1714` | Instrument Serif 9/8.55px peso 400 ls normal #1A1714 |
| 26 | `i01.alsoReading.card2.ring` | box | 288.5 | 66.5 | 46 | 46 | `position: relative; width: 46px; height: 46px; margin-top: 12px` |  |
| 27 | `i01.alsoReading.card2.ring.svg` | icon | 288.5 | 66.5 | 46 | 46 | `—` |  |
| 28 | `i01.alsoReading.card2.ring.label` | text | 288.5 | 66.5 | 46 | 46 | `position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 29 | `i01.alsoReading.card2.textBlock` | box | 196.5 | 124.5 | 138 | 65.81 | `display: flex; flex-direction: column; gap: 2px; min-width: 0` |  |
| 30 | `i01.alsoReading.card2.title` | text | 196.5 | 124.5 | 138 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 31 | `i01.alsoReading.card2.author` | text | 196.5 | 144.5 | 138 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 13/normal peso 500 ls normal #5B544B |
| 32 | `i01.alsoReading.card2.meta` ±1 | box+text | 196.5 | 168.1 | 116.36 | 22.21 | `margin-top: 6px; align-self: flex-start; display: flex; align-items: center; gap: 4px; font-size: 11.5px; font-weight: 700; padding: 3px 8px 3px 6px; border-radius: 999px; background: #F7F0E3; border: 1.2px solid #E2D7C4; white-space: nowrap` | Figtree 11.5/normal peso 700 ls normal #1A1714 |
| 33 | `i01.alsoReading.card2.meta.icon` | icon | 203.7 | 173.2 | 12 | 12 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `i01.alsoReading.card1.cover`: caixa visual com `transform: rotate(-4deg)` = x 12.74, y 29.71, w 59.52, h 84.57 (relativa à seção).
- `i01.alsoReading.card1.cover.spine`: caixa visual deslocada pelo transform de um ancestral = x 14.34, y 34.53, w 10.43, h 78.16 (relativa à seção).
- `i01.alsoReading.card1.cover.hat`: caixa visual deslocada pelo transform de um ancestral = x 33.27, y 46.33, w 19.07, h 17.22 (relativa à seção).
- `i01.alsoReading.card1.cover.brim`: caixa visual deslocada pelo transform de um ancestral = x 29.33, y 60.94, w 28.28, h 6.94 (relativa à seção).
- `i01.alsoReading.card1.cover.title`: caixa visual deslocada pelo transform de um ancestral = x 26.74, y 80.51, w 40.36, h 23.57 (relativa à seção).
- `i01.alsoReading.card2.cover`: caixa visual com `transform: rotate(3deg)` = x 194.42, y 30.14, w 58.16, h 83.72 (relativa à seção).
- `i01.alsoReading.card2.cover.spine`: caixa visual deslocada pelo transform de um ancestral = x 195.99, y 31.72, w 9.07, h 78.16 (relativa à seção).
- `i01.alsoReading.card2.cover.circle`: caixa visual deslocada pelo transform de um ancestral = x 215.33, y 45.59, w 21.02, h 21.02 (relativa à seção).
- `i01.alsoReading.card2.cover.title`: caixa visual deslocada pelo transform de um ancestral = x 205.4, y 85.02, w 40.84, h 19.17 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.alsoReading.title` | 1 | Também lendo | 16.94 | 0 | 126.54 | 126.54 |
| `i01.alsoReading.count` | 1 | 3 | 15.2 | 142.21 | 148.88 | 6.67 |
| `i01.alsoReading.card1.cover.title` | 1 | Brás | 91.06 | 26 | 42.34 | 16.34 |
| `i01.alsoReading.card1.cover.title` | 2 | Cubas | 101.51 | 26 | 48.79 | 22.79 |
| `i01.alsoReading.card1.title` | 1 | Brás Cubas | 138.75 | 15.5 | 92.17 | 76.67 |
| `i01.alsoReading.card1.author` | 1 | Machado de Assis | 156.85 | 15.5 | 120.81 | 105.31 |
| `i01.alsoReading.card1.meta` | 1 | Papel · 3h 40min | 183.23 | 38.7 | 126.22 | 87.52 |
| `i01.alsoReading.card2.cover.title` | 1 | Orgulho e | 93.23 | 207 | 236.76 | 29.76 |
| `i01.alsoReading.card2.cover.title` | 2 | Preconceito | 101.78 | 207 | 242.46 | 35.46 |
| `i01.alsoReading.card2.ring.label` | 1 | 81% | 93.35 | 301.34 | 321.66 | 20.32 |
| `i01.alsoReading.card2.title` | 1 | Orgulho e Preconceito | 138.75 | 196.5 | 351.4 | 154.9 |
| `i01.alsoReading.card2.author` | 1 | Jane Austen | 156.85 | 196.5 | 269.26 | 72.76 |
| `i01.alsoReading.card2.meta` | 1 | Papel · pág. 344 | 183.23 | 219.7 | 303.66 | 83.96 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Título Bricolage 18/800 ls −0,3 + contador preto 22 ("3", Figtree 12/800 → 700); grade de 2 colunas (gap 12), 30 abaixo do título.
2. Cartão 169 × 153,81: padding 0/14/14, raio 22, `#FFFAF1`, borda 1,5, sem sombra. A capa (54 × 81, raio 3/7/7/3, borda 1,5, sombra 2/2) **sobe 22** (`margin-top −22`, sai pela borda de cima) e gira: −4° no Brás Cubas, +3° no Orgulho.
3. Capa do Brás Cubas em CSS (não é SVG): fundo `#058CD7`, lombada 5 `rgba(0,0,0,.18)`, cartola = retângulo 18 × 16 (raio 2/2/0/0) + aba 28 × 5 elíptica, ambas `#1A1714`; "Brás / Cubas" Instrument Serif 11 `lh 0,95` `#FED170`. Orgulho e Preconceito: `#FFC1C6`, círculo 20 com borda 1,5, título Instrument Serif 9 `#1A1714` (2 linhas).
4. "Play": círculo 46 preto (12 abaixo do topo da faixa) com o triângulo amarelo 18 (`ic_play`). Anel: 46 (`anel_progresso_livro`: r 18, traço 5, trilho `#EAE1CF`, 81 %) + "81%" Figtree 11/800 (→ 700) no centro.
5. Título Figtree 15/700 `nowrap` + reticências: "Orgulho e Preconceito" não cabe em 138 e aparece "Orgulho e Precon…" (a tabela traz o texto inteiro; o PNG mostra o cortado). Autor 13/500 `#5B544B`.
6. Pílula meta (6 abaixo): fundo `#F7F0E3`, borda 1,2 `#E2D7C4`, raio 999, padding 3/8/3/6, livro de papel 12 (`ic_book_paper`) + "Papel · 3h 40min" Figtree 11,5/700.
7. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Reticências do Flutter (`TextOverflow.ellipsis`) têm de cortar no mesmo ponto: "Orgulho e Precon…".
- Capas giradas saem pela borda de cima do cartão: o cartão não pode recortar (`clipBehavior: none`).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.alsoReading` |  | Também lendo |  |
| `i01.alsoReading.card1.cover` |  | Memórias Póstumas de Brás Cubas |  |
| `i01.alsoReading.card1.play` |  | Iniciar leitura de Brás Cubas |  |
| `i01.alsoReading.card1.play.icon` |  |  | aria-hidden=true |
| `i01.alsoReading.card1.meta.icon` |  |  | aria-hidden=true |
| `i01.alsoReading.card2.ring.svg` |  |  | aria-hidden=true |
| `i01.alsoReading.card2.meta.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.alsoReading.count` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.alsoReading.card1` | NeoBox |  |
| `i01.alsoReading.card1.cover` | NeoBox | Transform: rotate(-4deg) |
| `i01.alsoReading.card1.cover.spine` | NeoBox |  |
| `i01.alsoReading.card1.cover.hat` | NeoBox |  |
| `i01.alsoReading.card1.cover.brim` | CircleIconButton / NeoBox circular |  |
| `i01.alsoReading.card1.play` | CircleIconButton / NeoBox circular |  |
| `i01.alsoReading.card1.play.icon` | AppSvg(AppIconsInicio.ic_play, size: 18) |  |
| `i01.alsoReading.card1.meta` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.alsoReading.card1.meta.icon` | AppSvg(AppIconsInicio.ic_book_paper, size: 12) |  |
| `i01.alsoReading.card2` | NeoBox |  |
| `i01.alsoReading.card2.cover` | NeoBox | Transform: rotate(3deg) |
| `i01.alsoReading.card2.cover.spine` | NeoBox |  |
| `i01.alsoReading.card2.cover.circle` | CircleIconButton / NeoBox circular |  |
| `i01.alsoReading.card2.ring.svg` | CustomPainter (anel_progresso_livro) | stroke-dasharray = progresso do livro (91,6 de 113,1 = 2π·18 → 81 %) com rotate(-90): anel desenhado por CustomPainter com o valor real (o rótulo "81%" é texto da página, não do SVG). |
| `i01.alsoReading.card2.meta` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.alsoReading.card2.meta.icon` | AppSvg(AppIconsInicio.ic_book_paper, size: 12) |  |

## Interações

- "Play" → aparece na T03 sem ação (D-243 b): o elemento fica idêntico à prancha, o toque não faz nada, um teste documenta e o item entra em `docs/design/estados_sem_design.md`; ganha ação na T04 (D-247: começa a sessão do cronômetro).
- Capa do Brás Cubas (link) e cartão do Orgulho (link) → página do livro, como hoje.

## Dados

- "3" = livros em leitura além do herói (a grade mostra 2 — regra do contador no plano da T03, como a v1 fazia).
- "Papel · 3h 40min" e "Papel · pág. 344": formato papel + tempo ou página — a regra (tempo lido? restante?) fica para o plano da T03 (já listada no PLANO_FIDELIDADE_TELAS); "81%" = progresso.

## Subfases

- **L01a3.1** Título e contador
- **L01a3.2** Cartões e capas giradas (Brás Cubas com cartola, Orgulho)
- **L01a3.3** "Play" (sem ação) e anel 81 %
- **L01a3.4** Título com reticências e pílula "Papel"
- **L01a3.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.alsoReading'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 554.96–776.77) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a3.1 Título e contador
- [ ] L01a3.2 Cartões e capas giradas (Brás Cubas com cartola, Orgulho)
- [ ] L01a3.3 "Play" (sem ação) e anel 81 %
- [ ] L01a3.4 Título com reticências e pílula "Papel"
- [ ] L01a3.5 Verificação + relatório
- [ ] Geometria 33/33 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
