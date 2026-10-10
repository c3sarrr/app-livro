# FASE L01a6 — Início — Para você

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a6_para_voce@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a6_para_voce_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/for_you_section.dart`, `lib/features/home/presentation/covers/`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

"Para você" com a pílula do motivo e três capas novas: Esaú e Jacó, Memorial de Aires e Casa de Pensão (na v1: Memórias Póstumas, Quincas Borba, O Cortiço).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

```html
<!-- For you -->
<section aria-label="Para você" style="margin-top: 40px; display: flex; flex-direction: column; gap: 14px;">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <h3 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px;">Para você</h3>
    <a href="#" style="height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700;">Ver tudo
      <svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </a>
  </div>
  <span style="align-self: flex-start; display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600; padding: 7px 12px 7px 10px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1;">
    <svg width="14" height="14" sc-camel-view-box="0 0 24 24" aria-hidden="true"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#1A1714"></path></svg>
    Porque você lê Machado de Assis
  </span>

  <div style="margin: 4px -20px 0; padding: 0 20px; display: flex; gap: 14px; overflow: hidden;">
    <a href="#" style="width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px;">
      <div style="position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box;">
        <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.15);"></div>
        <div style="position: absolute; left: 20px; right: -30px; bottom: -58px; height: 116px; border-radius: 50%; background: #1A1714;"></div>
        <div style="position: absolute; left: 16px; right: 10px; top: 16px; font-family: 'Instrument Serif', Georgia, serif; font-size: 22px; line-height: 0.95; color: #1A1714;">Esaú<br>e Jacó</div>
        <div style="position: absolute; left: 16px; bottom: 12px; font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E;">MACHADO DE ASSIS</div>
      </div>
      <div style="display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 14px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Esaú e Jacó</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Machado de Assis</span>
      </div>
    </a>
    <a href="#" style="width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px;">
      <div style="position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box;">
        <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></div>
        <div style="position: absolute; left: 16px; right: 16px; top: 18px; display: flex; flex-direction: column; gap: 6px;">
          <div style="height: 6px; border-radius: 6px; background: #F7F0E3;"></div>
          <div style="height: 6px; width: 70%; border-radius: 6px; background: #F7F0E3;"></div>
          <div style="height: 6px; width: 40%; border-radius: 6px; background: #F7F0E3;"></div>
        </div>
        <div style="position: absolute; left: 16px; right: 10px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
          <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1;">Memorial<br>de Aires</div>
          <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">MACHADO DE ASSIS</div>
        </div>
      </div>
      <div style="display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Memorial de Aires</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Machado de Assis</span>
      </div>
    </a>
    <a href="#" style="width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px;">
      <div style="position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box;">
        <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></div>
        <div style="position: absolute; left: 24px; top: 22px; width: 68px; height: 80px; border-radius: 34px 34px 0 0; background: #FED170;"></div>
        <div style="position: absolute; left: 44px; top: 56px; width: 28px; height: 46px; border-radius: 14px 14px 0 0; background: #00995E;"></div>
        <div style="position: absolute; left: 16px; right: 10px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
          <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1;">Casa de<br>Pensão</div>
          <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">ALUÍSIO AZEVEDO</div>
        </div>
      </div>
      <div style="display: flex; flex-direction: column; gap: 2px;">
        <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Casa de Pensão</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Aluísio Azevedo</span>
      </div>
    </a>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `i01.forYou` — retângulo absoluto no canvas 390×2650: **x=20, y=1464.52, w=350, h=327**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.forYou` | box | 0 | 0 | 350 | 327 | `margin-top: 40px; display: flex; flex-direction: column; gap: 14px` |  |
| 2 | `i01.forYou.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `i01.forYou.title` ±1 | text | 0 | 7.6 | 109.35 | 28.8 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px` | Bricolage (opsz 24) 24/normal peso 800 ls -0.6px #1A1714 |
| 4 | `i01.forYou.seeAll` ±1 | text | 272.01 | 0 | 77.99 | 44 | `height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 5 | `i01.forYou.seeAll.icon` | icon | 332 | 13 | 18 | 18 | `—` |  |
| 6 | `i01.forYou.reasonChip` ±1 | box+text | 0 | 58 | 241.28 | 32.6 | `align-self: flex-start; display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600; padding: 7px 12px 7px 10px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1` | Figtree 13/normal peso 600 ls normal #1A1714 |
| 7 | `i01.forYou.reasonChip.icon` | icon | 11.5 | 67.3 | 14 | 14 | `—` |  |
| 8 | `i01.forYou.carousel` | box | -20 | 108.6 | 390 | 218.4 | `margin: 4px -20px 0; padding: 0 20px; display: flex; gap: 14px; overflow: hidden` |  |
| 9 | `i01.forYou.item1` | box | 0 | 108.6 | 116 | 218.4 | `width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px` |  |
| 10 | `i01.forYou.item1.cover` | box | 0 | 108.6 | 116 | 174 | `position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box` |  |
| 11 | `i01.forYou.item1.cover.spine` | box | 1.5 | 110.1 | 7 | 171 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.15)` |  |
| 12 | `i01.forYou.item1.cover.blob` | box | 21.5 | 223.1 | 123 | 116 | `position: absolute; left: 20px; right: -30px; bottom: -58px; height: 116px; border-radius: 50%; background: #1A1714` |  |
| 13 | `i01.forYou.item1.cover.title` | text | 17.5 | 126.1 | 87 | 41.8 | `position: absolute; left: 16px; right: 10px; top: 16px; font-family: 'Instrument Serif', Georgia, serif; font-size: 22px; line-height: 0.95; color: #1A1714` | Instrument Serif 22/20.9px peso 400 ls normal #1A1714 |
| 14 | `i01.forYou.item1.cover.author` ±1 | text | 17.5 | 261.29 | 78.33 | 7.81 | `position: absolute; left: 16px; bottom: 12px; font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E` | Figtree 6.5/normal peso 700 ls 0.91px #FF552E |
| 15 | `i01.forYou.item1.textBlock` | box | 0 | 292.6 | 116 | 34.4 | `display: flex; flex-direction: column; gap: 2px` |  |
| 16 | `i01.forYou.item1.title` | text | 0 | 292.6 | 116 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 17 | `i01.forYou.item1.author` | text | 0 | 311.4 | 116 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 18 | `i01.forYou.item2` | box | 130 | 108.6 | 116 | 218.4 | `width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px` |  |
| 19 | `i01.forYou.item2.cover` | box | 130 | 108.6 | 116 | 174 | `position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box` |  |
| 20 | `i01.forYou.item2.cover.spine` | box | 131.5 | 110.1 | 7 | 171 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 21 | `i01.forYou.item2.cover.lines` | box | 147.5 | 128.1 | 81 | 30 | `position: absolute; left: 16px; right: 16px; top: 18px; display: flex; flex-direction: column; gap: 6px` |  |
| 22 | `i01.forYou.item2.cover.line1` | box | 147.5 | 128.1 | 81 | 6 | `height: 6px; border-radius: 6px; background: #F7F0E3` |  |
| 23 | `i01.forYou.item2.cover.line2` | box | 147.5 | 140.1 | 56.7 | 6 | `height: 6px; width: 70%; border-radius: 6px; background: #F7F0E3` |  |
| 24 | `i01.forYou.item2.cover.line3` | box | 147.5 | 152.1 | 32.4 | 6 | `height: 6px; width: 40%; border-radius: 6px; background: #F7F0E3` |  |
| 25 | `i01.forYou.item2.cover.textBlock` | box | 147.5 | 208.49 | 87 | 60.61 | `position: absolute; left: 16px; right: 10px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 26 | `i01.forYou.item2.cover.title` | text | 147.5 | 208.49 | 87 | 46.8 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 26/23.4px peso 400 ls normal #FFFAF1 |
| 27 | `i01.forYou.item2.cover.author` | text | 147.5 | 261.29 | 87 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 6.5/normal peso 700 ls 0.91px #FFFAF1 |
| 28 | `i01.forYou.item2.textBlock` | box | 130 | 292.6 | 116 | 34.4 | `display: flex; flex-direction: column; gap: 2px` |  |
| 29 | `i01.forYou.item2.title` | text | 130 | 292.6 | 116 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 30 | `i01.forYou.item2.author` | text | 130 | 311.4 | 116 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 31 | `i01.forYou.item3` | box | 260 | 108.6 | 116 | 218.4 | `width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px` |  |
| 32 | `i01.forYou.item3.cover` | box | 260 | 108.6 | 116 | 174 | `position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box` |  |
| 33 | `i01.forYou.item3.cover.spine` | box | 261.5 | 110.1 | 7 | 171 | `position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 34 | `i01.forYou.item3.cover.archOuter` | box | 285.5 | 132.1 | 68 | 80 | `position: absolute; left: 24px; top: 22px; width: 68px; height: 80px; border-radius: 34px 34px 0 0; background: #FED170` |  |
| 35 | `i01.forYou.item3.cover.archInner` | box | 305.5 | 166.1 | 28 | 46 | `position: absolute; left: 44px; top: 56px; width: 28px; height: 46px; border-radius: 14px 14px 0 0; background: #00995E` |  |
| 36 | `i01.forYou.item3.cover.textBlock` | box | 277.5 | 208.49 | 87 | 60.61 | `position: absolute; left: 16px; right: 10px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 37 | `i01.forYou.item3.cover.title` | text | 277.5 | 208.49 | 87 | 46.8 | `font-family: 'Instrument Serif', Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 26/23.4px peso 400 ls normal #FFFAF1 |
| 38 | `i01.forYou.item3.cover.author` | text | 277.5 | 261.29 | 87 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 6.5/normal peso 700 ls 0.91px #FFFAF1 |
| 39 | `i01.forYou.item3.textBlock` | box | 260 | 292.6 | 116 | 34.4 | `display: flex; flex-direction: column; gap: 2px` |  |
| 40 | `i01.forYou.item3.title` | text | 260 | 292.6 | 116 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 41 | `i01.forYou.item3.author` | text | 260 | 311.4 | 116 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.forYou.title` | 1 | Para você | 29.92 | 0 | 109.35 | 109.35 |
| `i01.forYou.seeAll` | 1 | Ver tudo | 26.9 | 272.01 | 328 | 55.99 |
| `i01.forYou.reasonChip` | 1 | Porque você lê Machado de Assis | 78.85 | 31.5 | 227.78 | 196.28 |
| `i01.forYou.item1.cover.title` | 1 | Esaú | 144.03 | 17.5 | 53.01 | 35.51 |
| `i01.forYou.item1.cover.title` | 2 | e Jacó | 164.93 | 17.5 | 59.34 | 41.84 |
| `i01.forYou.item1.cover.author` | 1 | MACHADO DE ASSIS | 267.47 | 17.5 | 95.83 | 78.33 |
| `i01.forYou.item1.title` | 1 | Esaú e Jacó | 305.9 | 0 | 75.57 | 75.57 |
| `i01.forYou.item1.author` | 1 | Machado de Assis | 323.75 | 0 | 105.31 | 105.31 |
| `i01.forYou.item2.cover.title` | 1 | Memorial | 229.03 | 147.5 | 232.83 | 85.33 |
| `i01.forYou.item2.cover.title` | 2 | de Aires | 252.43 | 147.5 | 216.22 | 68.72 |
| `i01.forYou.item2.cover.author` | 1 | MACHADO DE ASSIS | 267.47 | 147.5 | 225.82 | 78.32 |
| `i01.forYou.item2.title` | 1 | Memorial de Aires | 305.9 | 130 | 245.98 | 115.98 |
| `i01.forYou.item2.author` | 1 | Machado de Assis | 323.75 | 130 | 235.31 | 105.31 |
| `i01.forYou.item3.cover.title` | 1 | Casa de | 229.03 | 277.5 | 344.27 | 66.77 |
| `i01.forYou.item3.cover.title` | 2 | Pensão | 252.43 | 277.5 | 339.59 | 62.09 |
| `i01.forYou.item3.cover.author` | 1 | ALUÍSIO AZEVEDO | 267.47 | 277.5 | 348.99 | 71.49 |
| `i01.forYou.item3.title` | 1 | Casa de Pensão | 305.9 | 260 | 360.41 | 100.41 |
| `i01.forYou.item3.author` | 1 | Aluísio Azevedo | 323.75 | 260 | 353.41 | 93.41 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cabeçalho 44: "Para você" Bricolage 24/800 ls −0,6 × "Ver tudo" Figtree 14/700 + seta 18; pílula "Porque você lê Machado de Assis" (Figtree 13/600, borda 1,5, brilho 14) 14 abaixo.
2. Carrossel com `margin 4 −20 0` e `padding 0 20`, `overflow: hidden`: itens de 116 (gap 14); o 3º passa da borda (até x 396) e é recortado em 390.
3. Capas em CSS (116 × 174, raio 4/10/10/4, borda 1,5, lombada 7): **Esaú e Jacó** — fundo coral `#FF552E`, mancha preta elíptica 123 × 116 (`left 20 · right −30 · bottom −58`), "Esaú / e Jacó" Instrument Serif 22 `lh 0,95` `#1A1714`, autor Figtree 6,5/700 ls 0,14 em **coral** (o "M" fica coral sobre coral, fora da mancha: no PNG lê-se "ACHADO DE ASSIS" — fiel ao arquivo). **Memorial de Aires** — `#058CD7`, três traços creme de 6 (100/70/40 %), título 26 `lh 0,9` `#FFFAF1`. **Casa de Pensão** — `#00995E`, arco amarelo 68 × 80 (raio 34/34/0/0) com o vão verde 28 × 46 (raio 14/14/0/0), título 26 creme.
4. Título do livro Figtree 14/700 (reticências no 1º) e autor 13/500 `#5B544B`.
5. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.forYou` |  | Para você |  |
| `i01.forYou.reasonChip.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.forYou.seeAll.icon` | AppSvg(AppIcons.ic_arrow_right, size: 18) |  |
| `i01.forYou.reasonChip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.forYou.reasonChip.icon` | AppSvg(AppIcons.ic_sparkle_solid, size: 14) |  |
| `i01.forYou.item1.cover` | NeoBox |  |
| `i01.forYou.item1.cover.spine` | NeoBox |  |
| `i01.forYou.item1.cover.blob` | CircleIconButton / NeoBox circular |  |
| `i01.forYou.item2.cover` | NeoBox |  |
| `i01.forYou.item2.cover.spine` | NeoBox |  |
| `i01.forYou.item2.cover.line1` | NeoBox |  |
| `i01.forYou.item2.cover.line2` | NeoBox |  |
| `i01.forYou.item2.cover.line3` | NeoBox |  |
| `i01.forYou.item3.cover` | NeoBox |  |
| `i01.forYou.item3.cover.spine` | NeoBox |  |
| `i01.forYou.item3.cover.archOuter` | NeoBox |  |
| `i01.forYou.item3.cover.archInner` | NeoBox |  |

## Interações

- Capa/item → página do livro; "Ver tudo" → como hoje.

## Dados

- Recomendações como hoje (G21); as capas desenhadas só na fixture (D-79).

## Subfases

- **L01a6.1** Cabeçalho e motivo
- **L01a6.2** Carrossel (recorte do 3º item)
- **L01a6.3** Capas novas (Esaú e Jacó, Memorial de Aires, Casa de Pensão)
- **L01a6.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.forYou'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 1456.52–1811.62) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a6.1 Cabeçalho e motivo
- [ ] L01a6.2 Carrossel (recorte do 3º item)
- [ ] L01a6.3 Capas novas (Esaú e Jacó, Memorial de Aires, Casa de Pensão)
- [ ] L01a6.4 Verificação + relatório
- [ ] Geometria 41/41 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
