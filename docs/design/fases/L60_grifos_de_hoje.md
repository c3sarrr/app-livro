# FASE L60 — Início rolada até o cartão "Seus grifos de hoje"

> Tela 60 · prancha `060_inicio_grifos_de_hoje` (60 · Início — grifos de hoje (revisão), canvas 390×844) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L60_grifos_de_hoje@3x.png` · `docs/design/medicao/inicio2/png/redline/L60_grifos_de_hoje_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/060_inicio_grifos_de_hoje_390x844@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_060_inicio_grifos_de_hoje.json` · `test/reference/inicio2/reference_layout_060_inicio_grifos_de_hoje.dart` (`kRef60`).
> Arquivos sugeridos: `lib/features/home/presentation/home_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A Início rolada até o cartão "Seus grifos de hoje": o fim do "Seu dia", o cartão da revisão e o começo do "Para você". É um caso de teste de viewport (rolagem 930), não uma tela nova.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

```html
<!-- Daily highlight review (5 a day) -->
<section aria-label="Seus grifos de hoje" style="margin-top: 40px; padding: 16px; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; display: flex; align-items: center; gap: 14px;">
  <span aria-hidden="true" style="position: relative; width: 104px; height: 112px; flex-shrink: 0;"><span style="position: absolute; left: 2px; top: 18px; width: 62px; height: 82px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(-12deg); display: flex; flex-direction: column; gap: 5px;"><span style="height: 5px; width: 90%; border-radius: 3px; background: #ABCF82;"></span><span style="height: 5px; width: 70%; border-radius: 3px; background: #ABCF82;"></span><span style="height: 5px; width: 82%; border-radius: 3px; background: #E4DACA;"></span><span style="height: 5px; width: 55%; border-radius: 3px; background: #E4DACA;"></span></span><span style="position: absolute; left: 36px; top: 14px; width: 62px; height: 82px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(8deg); display: flex; flex-direction: column; gap: 5px;"><span style="height: 5px; width: 90%; border-radius: 3px; background: #FFC1C6;"></span><span style="height: 5px; width: 70%; border-radius: 3px; background: #FFC1C6;"></span><span style="height: 5px; width: 82%; border-radius: 3px; background: #E4DACA;"></span><span style="height: 5px; width: 55%; border-radius: 3px; background: #E4DACA;"></span></span><span style="position: absolute; left: 18px; top: 6px; width: 66px; height: 90px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(-2deg); display: flex; flex-direction: column; gap: 5px;"><span style="height: 5px; width: 90%; border-radius: 3px; background: #B6ACE4;"></span><span style="height: 5px; width: 70%; border-radius: 3px; background: #B6ACE4;"></span><span style="height: 5px; width: 82%; border-radius: 3px; background: #E4DACA;"></span><span style="height: 5px; width: 55%; border-radius: 3px; background: #E4DACA;"></span></span>
    <svg width="26" height="26" sc-camel-view-box="0 0 24 24" style="position: absolute; right: -2px; top: -4px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>
  </span>
  <span style="min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 4px;">
    <span style="font-size: 11px; font-weight: 800; letter-spacing: 1px; color: #6F665B;">REVISÃO · 5 GRIFOS · 2 MIN</span>
    <span style="font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; line-height: 1.05; letter-spacing: -0.5px;">Seus grifos <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 24px;">de hoje</span></span>
    <span style="font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #5B544B;">De Dom Casmurro, Quincas Borba e Iracema.</span>
    <a href="#" style="margin-top: 6px; align-self: flex-start; height: 40px; padding: 0 16px 0 12px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800;"><svg width="15" height="15" sc-camel-view-box="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170"></path></svg><span style="color: #F7F0E3;">Revisar</span></a>
  </span>
</section>

<!-- Bottom fade so content slips under the floating nav -->
<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 150px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none;"></div>

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

Seção `i60.review` — retângulo absoluto no canvas 390×844: **x=20, y=1259.37, w=350, h=165.15**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i60.review` | box | 0 | 0 | 350 | 165.15 | `margin-top: 40px; padding: 16px; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; display: flex; align-items: center; gap: 14px` |  |
| 2 | `i60.review.art` | box | 17.5 | 26.58 | 104 | 112 | `position: relative; width: 104px; height: 112px; flex-shrink: 0` |  |
| 3 | `i60.review.art.card1` | box | 19.5 | 44.58 | 62 | 82 | `position: absolute; left: 2px; top: 18px; width: 62px; height: 82px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(-12deg); display: flex; flex-direction: column; gap: 5px` |  |
| 4 | `i60.review.art.card1.line0` | box | 29 | 56.08 | 38.7 | 5 | `height: 5px; width: 90%; border-radius: 3px; background: #ABCF82` |  |
| 5 | `i60.review.art.card1.line1` | box | 29 | 66.08 | 30.1 | 5 | `height: 5px; width: 70%; border-radius: 3px; background: #ABCF82` |  |
| 6 | `i60.review.art.card1.line2` | box | 29 | 76.08 | 35.26 | 5 | `height: 5px; width: 82%; border-radius: 3px; background: #E4DACA` |  |
| 7 | `i60.review.art.card1.line3` | box | 29 | 86.08 | 23.65 | 5 | `height: 5px; width: 55%; border-radius: 3px; background: #E4DACA` |  |
| 8 | `i60.review.art.card2` | box | 53.5 | 40.58 | 62 | 82 | `position: absolute; left: 36px; top: 14px; width: 62px; height: 82px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(8deg); display: flex; flex-direction: column; gap: 5px` |  |
| 9 | `i60.review.art.card2.line0` | box | 63 | 52.08 | 38.7 | 5 | `height: 5px; width: 90%; border-radius: 3px; background: #FFC1C6` |  |
| 10 | `i60.review.art.card2.line1` | box | 63 | 62.08 | 30.1 | 5 | `height: 5px; width: 70%; border-radius: 3px; background: #FFC1C6` |  |
| 11 | `i60.review.art.card2.line2` | box | 63 | 72.08 | 35.26 | 5 | `height: 5px; width: 82%; border-radius: 3px; background: #E4DACA` |  |
| 12 | `i60.review.art.card2.line3` | box | 63 | 82.08 | 23.65 | 5 | `height: 5px; width: 55%; border-radius: 3px; background: #E4DACA` |  |
| 13 | `i60.review.art.card3` | box | 35.5 | 32.58 | 66 | 90 | `position: absolute; left: 18px; top: 6px; width: 66px; height: 90px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(-2deg); display: flex; flex-direction: column; gap: 5px` |  |
| 14 | `i60.review.art.card3.line0` | box | 45 | 44.08 | 42.3 | 5 | `height: 5px; width: 90%; border-radius: 3px; background: #B6ACE4` |  |
| 15 | `i60.review.art.card3.line1` | box | 45 | 54.08 | 32.9 | 5 | `height: 5px; width: 70%; border-radius: 3px; background: #B6ACE4` |  |
| 16 | `i60.review.art.card3.line2` | box | 45 | 64.08 | 38.54 | 5 | `height: 5px; width: 82%; border-radius: 3px; background: #E4DACA` |  |
| 17 | `i60.review.art.card3.line3` | box | 45 | 74.08 | 25.85 | 5 | `height: 5px; width: 55%; border-radius: 3px; background: #E4DACA` |  |
| 18 | `i60.review.art.sparkle` | icon | 97.5 | 22.58 | 26 | 26 | `position: absolute; right: -2px; top: -4px` |  |
| 19 | `i60.review.textBlock` | box | 135.5 | 17.5 | 197 | 130.15 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 4px` |  |
| 20 | `i60.review.kicker` | text | 135.5 | 17.5 | 197 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1px; color: #6F665B` | Figtree 11/normal peso 800→**800** ls 1px #6F665B |
| 21 | `i60.review.title` | text | 135.5 | 34.7 | 197 | 25.2 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; line-height: 1.05; letter-spacing: -0.5px` | Bricolage (opsz 20) 20/21px peso 800 ls -0.5px #1A1714 |
| 22 | `i60.review.title.serif` ±1 | inline | 244.59 | 31.7 | 55.97 | 31.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 24px` | Instrument Serif itálico 24/25.2px peso 400 ls -0.5px #1A1714 |
| 23 | `i60.review.subtitle` | text | 135.5 | 63.9 | 197 | 33.75 | `font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #5B544B` | Figtree 12.5/16.875px peso 600 ls normal #5B544B |
| 24 | `i60.review.cta` ±1 | box | 135.5 | 107.65 | 97.22 | 40 | `margin-top: 6px; align-self: flex-start; height: 40px; padding: 0 16px 0 12px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800` |  |
| 25 | `i60.review.cta.icon` | icon | 147.5 | 120.15 | 15 | 15 | `—` |  |
| 26 | `i60.review.cta.label` ±1 | text | 169.5 | 119.25 | 47.22 | 16.8 | `color: #F7F0E3` | Figtree 14/normal peso 800→**800** ls normal #F7F0E3 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `i60.review`: caixa visual deslocada pelo transform de um ancestral = x 0, y -930, w 350, h 165.15 (relativa à seção).
- `i60.review.art`: caixa visual deslocada pelo transform de um ancestral = x 17.5, y -903.43, w 104, h 112 (relativa à seção).
- `i60.review.art.card1`: caixa visual com `transform: rotate(-12deg)` = x 11.65, y -890.97, w 77.69, h 93.1 (relativa à seção).
- `i60.review.art.card1.line0`: caixa visual deslocada pelo transform de um ancestral = x 23.34, y -876.86, w 38.89, h 12.94 (relativa à seção).
- `i60.review.art.card1.line1`: caixa visual deslocada pelo transform de um ancestral = x 25.42, y -865.29, w 30.48, h 11.15 (relativa à seção).
- `i60.review.art.card1.line2`: caixa visual deslocada pelo transform de um ancestral = x 27.49, y -856.58, w 35.53, h 12.22 (relativa à seção).
- `i60.review.art.card1.line3`: caixa visual deslocada pelo transform de um ancestral = x 29.57, y -844.38, w 24.17, h 9.81 (relativa à seção).
- `i60.review.art.card2`: caixa visual com `transform: rotate(8deg)` = x 48.1, y -893.34, w 72.81, h 89.83 (relativa à seção).
- `i60.review.art.card2.line0`: caixa visual deslocada pelo transform de um ancestral = x 66.62, y -880.63, w 39.02, h 10.34 (relativa à seção).
- `i60.review.art.card2.line1`: caixa visual deslocada pelo transform de um ancestral = x 65.23, y -870.73, w 30.5, h 9.14 (relativa à seção).
- `i60.review.art.card2.line2`: caixa visual deslocada pelo transform de um ancestral = x 63.84, y -860.82, w 35.61, h 9.86 (relativa à seção).
- `i60.review.art.card2.line3`: caixa visual deslocada pelo transform de um ancestral = x 62.44, y -850.92, w 24.12, h 8.24 (relativa à seção).
- `i60.review.art.card3`: caixa visual com `transform: rotate(-2deg)` = x 33.95, y -898.55, w 69.1, h 92.25 (relativa à seção).
- `i60.review.art.card3.line0`: caixa visual deslocada pelo transform de um ancestral = x 43.84, y -886.56, w 42.45, h 6.47 (relativa à seção).
- `i60.review.art.card3.line1`: caixa visual deslocada pelo transform de um ancestral = x 44.19, y -876.24, w 33.05, h 6.14 (relativa à seção).
- `i60.review.art.card3.line2`: caixa visual deslocada pelo transform de um ancestral = x 44.54, y -866.44, w 38.69, h 6.34 (relativa à seção).
- `i60.review.art.card3.line3`: caixa visual deslocada pelo transform de um ancestral = x 44.89, y -856, w 26.01, h 5.9 (relativa à seção).
- `i60.review.art.sparkle`: caixa visual deslocada pelo transform de um ancestral = x 97.5, y -907.43, w 26, h 26 (relativa à seção).
- `i60.review.textBlock`: caixa visual deslocada pelo transform de um ancestral = x 135.5, y -912.5, w 197, h 130.15 (relativa à seção).
- `i60.review.kicker`: caixa visual deslocada pelo transform de um ancestral = x 135.5, y -912.5, w 197, h 13.2 (relativa à seção).
- `i60.review.title`: caixa visual deslocada pelo transform de um ancestral = x 135.5, y -895.3, w 197, h 25.2 (relativa à seção).
- `i60.review.title.serif`: caixa visual deslocada pelo transform de um ancestral = x 244.59, y -898.3, w 55.97, h 31.2 (relativa à seção).
- `i60.review.subtitle`: caixa visual deslocada pelo transform de um ancestral = x 135.5, y -866.1, w 197, h 33.75 (relativa à seção).
- `i60.review.cta`: caixa visual deslocada pelo transform de um ancestral = x 135.5, y -822.35, w 97.22, h 40 (relativa à seção).
- `i60.review.cta.icon`: caixa visual deslocada pelo transform de um ancestral = x 147.5, y -809.85, w 15, h 15 (relativa à seção).
- `i60.review.cta.label`: caixa visual deslocada pelo transform de um ancestral = x 169.5, y -810.75, w 47.22, h 16.8 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i60.review.kicker` | 1 | REVISÃO · 5 GRIFOS · 2 MIN *(oculta: recortada)* | 27.95 | 135.5 | 304.56 | 169.06 |
| `i60.review.title` *(composto)* | 1 | Seus grifos de hoje *(oculta: recortada)* | 55.46 | 135.5 | 300.56 | 165.06 |
| `i60.review.subtitle` | 1 | De Dom Casmurro, Quincas Borba *(oculta: recortada)* | 76.71 | 135.5 | 328.15 | 192.65 |
| `i60.review.subtitle` | 2 | e Iracema. *(oculta: recortada)* | 93.58 | 135.5 | 193.95 | 58.45 |
| `i60.review.cta.label` | 1 | Revisar *(oculta: recortada)* | 132.55 | 169.5 | 216.72 | 47.22 |

Seção `i60.bottomFade` — retângulo absoluto no canvas 390×844: **x=0, y=694, w=390, h=150**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 27 | `i60.bottomFade` | box | 0 | 0 | 390 | 150 | `position: absolute; left: 0; right: 0; bottom: 0; height: 150px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none` |  |

Seção `i60.nav` — retângulo absoluto no canvas 390×844: **x=16, y=744, w=358, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 28 | `i60.nav` | box | 0 | 0 | 358 | 70 | `position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px` |  |
| 29 | `i60.nav.home` | box | 9.5 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 30 | `i60.nav.home.icon` | icon | 30.8 | 15.9 | 22 | 22 | `—` |  |
| 31 | `i60.nav.home.label` ±1 | text | 28.01 | 40.9 | 27.59 | 13.2 | `font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 32 | `i60.nav.library` | box | 78.1 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 33 | `i60.nav.library.icon` | icon | 99.4 | 15.9 | 22 | 22 | `—` |  |
| 34 | `i60.nav.library.label` ±1 | text | 85.5 | 40.9 | 49.79 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 35 | `i60.nav.scanner` | box | 146.7 | 9.5 | 64.6 | 51 | `position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px` |  |
| 36 | `i60.nav.scanner.fab` | box | 149 | -20.5 | 60 | 60 | `position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 37 | `i60.nav.scanner.icon` | icon | 165 | -4.5 | 28 | 28 | `—` |  |
| 38 | `i60.nav.scanner.label` ±1 | text | 158.35 | 45.3 | 41.3 | 15.2 | `font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px` | Figtree 11/normal peso 700 ls normal #1A1714 |
| 39 | `i60.nav.clubs` | box | 215.3 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 40 | `i60.nav.clubs.icon` | icon | 236.6 | 15.9 | 22 | 22 | `—` |  |
| 41 | `i60.nav.clubs.label` ±1 | text | 230.37 | 40.9 | 34.45 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 42 | `i60.nav.profile` | box | 283.9 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 43 | `i60.nav.profile.icon` | icon | 305.2 | 15.9 | 22 | 22 | `—` |  |
| 44 | `i60.nav.profile.label` ±1 | text | 303.18 | 40.9 | 26.05 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i60.nav.home.label` | 1 | Início | 51.35 | 28.01 | 55.59 | 27.58 |
| `i60.nav.library.label` | 1 | Biblioteca | 51.35 | 85.5 | 135.3 | 49.8 |
| `i60.nav.scanner.label` | 1 | Scanner | 55.75 | 158.35 | 199.65 | 41.3 |
| `i60.nav.clubs.label` | 1 | Clubes | 51.35 | 230.37 | 264.83 | 34.46 |
| `i60.nav.profile.label` | 1 | Perfil | 51.35 | 303.18 | 329.22 | 26.04 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A prancha é a 01 com `transform: translateY(-930px)` no `<main>`: os 296 elementos são os mesmos e o retângulo de **layout** (medido sem transform) é igual ao da 01; o que muda é a caixa visual (930 acima). No app: a mesma Início com `ScrollController` em 930 (as tabelas trazem as caixas visuais, deslocadas pelo transform).
2. A barra de navegação e o degradê ficam presos ao fundo da tela de 844 (na 01, ao fundo da página de 2650): no app, fora da área que rola.
3. Nada muda de desenho em relação às fases L01a4–L01a6 (diferenças abaixo: nenhuma).
4. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Linhas recortadas por `overflow` (existem no layout, não aparecem): `i60.review.kicker`, `i60.review.title`, `i60.review.title.serif`, `i60.review.subtitle`, `i60.review.cta.label`.

## Diferenças em relação à prancha 01 (seções reutilizadas: header, headline, hero, alsoReading, today, forYou, club, recent)

Estas seções são as mesmas widgets da 01 (fases L01a1_cabecalho, L01a2_heroi, L01a3_tambem_lendo, L01a4_seu_dia, L01a5_revisao, L01a6_para_voce, L01a7_clube, L01a8_recem_chegados, L01a9_barra); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 01.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i60.review` |  | Seus grifos de hoje |  |
| `i60.review.art` |  |  | aria-hidden=true |
| `i60.review.cta.icon` |  |  | aria-hidden=true |
| `i60.bottomFade` |  |  | aria-hidden=true |
| `i60.nav` |  | Navegação principal |  |
| `i60.nav.home` |  |  | aria-current=page |
| `i60.nav.scanner` |  | Scanner: escanear livro ou página |  |
| `i60.nav.scanner.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i60.review` | NeoBox |  |
| `i60.review.art.card1` | NeoBox | Transform: rotate(-12deg) |
| `i60.review.art.card1.line0` | NeoBox |  |
| `i60.review.art.card1.line1` | NeoBox |  |
| `i60.review.art.card1.line2` | NeoBox |  |
| `i60.review.art.card1.line3` | NeoBox |  |
| `i60.review.art.card2` | NeoBox | Transform: rotate(8deg) |
| `i60.review.art.card2.line0` | NeoBox |  |
| `i60.review.art.card2.line1` | NeoBox |  |
| `i60.review.art.card2.line2` | NeoBox |  |
| `i60.review.art.card2.line3` | NeoBox |  |
| `i60.review.art.card3` | NeoBox | Transform: rotate(-2deg) |
| `i60.review.art.card3.line0` | NeoBox |  |
| `i60.review.art.card3.line1` | NeoBox |  |
| `i60.review.art.card3.line2` | NeoBox |  |
| `i60.review.art.card3.line3` | NeoBox |  |
| `i60.review.art.sparkle` | AppSvg(AppIconsInicio.ic_sparkle_amarelo, size: 26) |  |
| `i60.review.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `i60.review.cta` | NeoBox |  |
| `i60.review.cta.icon` | AppSvg(AppIconsInicio.ic_sparkle_solid_amarelo, size: 15) |  |
| `i60.bottomFade` | DecoratedBox(LinearGradient) |  |
| `i60.nav` | NeoBox |  |
| `i60.nav.home` | NeoBox |  |
| `i60.nav.home.icon` | AppSvg(AppIcons.ic_nav_home_active, size: 22) |  |
| `i60.nav.library.icon` | AppSvg(AppIcons.ic_nav_library, size: 22) |  |
| `i60.nav.scanner.fab` | CircleIconButton / NeoBox circular |  |
| `i60.nav.scanner.icon` | AppSvg(AppIcons.ic_nav_scanner, size: 28) |  |
| `i60.nav.clubs.icon` | AppSvg(AppIcons.ic_nav_clubs, size: 22) |  |
| `i60.nav.profile.icon` | AppSvg(AppIcons.ic_nav_profile, size: 22) |  |

## Interações

- Rolagem da Início; os toques são os das fases L01a.

## Dados

- Os mesmos da 01 (fixture `t60` = `t01`, D-241).

## Subfases

- **L60.1** Golden da Início rolada 930 (viewport 390 × 844)
- **L60.2** Barra e degradê fixos durante a rolagem
- **L60.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i60.review', 'i60.bottomFade', 'i60.nav'), todos os ids de `kRef60.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/060_inicio_grifos_de_hoje_390x844@3x.png` no recorte da fase (y 321.37–844) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L60.1 Golden da Início rolada 930 (viewport 390 × 844)
- [ ] L60.2 Barra e degradê fixos durante a rolagem
- [ ] L60.3 Verificação + relatório
- [ ] Geometria 43/43 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
