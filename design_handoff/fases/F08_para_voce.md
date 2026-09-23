# FASE 8 — Seção 6: "Para você" (motivo + carrossel de capas)

> Pré-requisito: FASE 7 aprovada.
> Referências: `secoes/F08_para_voce@3x.png` · `redline/F08_para_voce_redline@3x.png`.
> Arquivos: `sections/for_you_section.dart`, `covers/memorias_postumas_cover.dart`, `covers/quincas_borba_cover.dart`, `covers/o_cortico_cover.dart`.

---

## HTML literal da seção

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
            <div style="position: absolute; left: 16px; right: 10px; top: 16px; font-family: 'Instrument Serif', Georgia, serif; font-size: 19px; line-height: 0.95; color: #1A1714;">Memórias Póstumas de Brás Cubas</div>
            <div style="position: absolute; left: 16px; bottom: 12px; font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E;">MACHADO DE ASSIS</div>
          </div>
          <div style="display: flex; flex-direction: column; gap: 2px;">
            <span style="font-size: 14px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Memórias Póstumas</span>
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
              <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1;">Quincas<br>Borba</div>
              <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">MACHADO DE ASSIS</div>
            </div>
          </div>
          <div style="display: flex; flex-direction: column; gap: 2px;">
            <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">Quincas Borba</span>
            <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Machado de Assis</span>
          </div>
        </a>
        <a href="#" style="width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px;">
          <div style="position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box;">
            <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 7px; background: rgba(0,0,0,0.18);"></div>
            <div style="position: absolute; left: 24px; top: 22px; width: 68px; height: 80px; border-radius: 34px 34px 0 0; background: #FED170;"></div>
            <div style="position: absolute; left: 44px; top: 56px; width: 28px; height: 46px; border-radius: 14px 14px 0 0; background: #00995E;"></div>
            <div style="position: absolute; left: 16px; right: 10px; bottom: 12px; display: flex; flex-direction: column; gap: 6px;">
              <div style="font-family: 'Instrument Serif', Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1;">O Cortiço</div>
              <div style="font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1;">ALUÍSIO AZEVEDO</div>
            </div>
          </div>
          <div style="display: flex; flex-direction: column; gap: 2px;">
            <span style="font-size: 14px; font-weight: 700; line-height: 1.2;">O Cortiço</span>
            <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Aluísio Azevedo</span>
          </div>
        </a>
      </div>
    </section>
```

## Especificação pixel a pixel

Seção `forYou` — retângulo absoluto no canvas 390×2390: **x=20, y=1207.56, w=350, h=327**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `forYou` | box | 0 | 0 | 350 | 327 | `margin-top: 40px; display: flex; flex-direction: column; gap: 14px` |  |
| 2 | `forYou.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `forYou.title` | text | 0 | 7.6 | 109.35 | 28.8 | `margin: 0px; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px` | Bricolage (opsz 24) 24/normal peso 800 ls -0.6px #1A1714 |
| 4 | `forYou.seeAll` | text | 272.01 | 0 | 77.99 | 44 | `height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 5 | `forYou.seeAll.icon` | icon | 332 | 13 | 18 | 18 | `—` |  |
| 6 | `forYou.reasonChip` | box+text | 0 | 58 | 241.28 | 32.6 | `align-self: flex-start; display: flex; align-items: center; gap: 6px; font-size: 13px; font-weight: 600; padding: 7px 12px 7px 10px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1` | Figtree 13/normal peso 600 ls normal #1A1714 |
| 7 | `forYou.reasonChip.icon` | icon | 11.5 | 67.3 | 14 | 14 | `—` |  |
| 8 | `forYou.carousel` | box | -20 | 108.6 | 390 | 218.4 | `margin: 4px -20px 0px; padding: 0px 20px; display: flex; gap: 14px; overflow: hidden` |  |
| 9 | `forYou.item1` | box | 0 | 108.6 | 116 | 218.4 | `width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px` |  |
| 10 | `forYou.item1.cover` | box | 0 | 108.6 | 116 | 174 | `position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #FF552E; overflow: hidden; box-sizing: border-box` |  |
| 11 | `forYou.item1.cover.spine` | box | 1.5 | 110.1 | 7 | 171 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 7px; background: rgba(0,0,0,0.15)` |  |
| 12 | `forYou.item1.cover.blob` | box | 21.5 | 223.1 | 123 | 116 | `position: absolute; left: 20px; right: -30px; bottom: -58px; height: 116px; border-radius: 50%; background: #1A1714` |  |
| 13 | `forYou.item1.cover.title` | text | 17.5 | 126.1 | 87 | 54.15 | `position: absolute; left: 16px; right: 10px; top: 16px; font-family: "Instrument Serif", Georgia, serif; font-size: 19px; line-height: 0.95; color: #1A1714` | Instrument Serif 19/18.05px peso 400 ls normal #1A1714 |
| 14 | `forYou.item1.cover.author` | text | 17.5 | 261.29 | 78.33 | 7.81 | `position: absolute; left: 16px; bottom: 12px; font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FF552E` | Figtree 6.5/normal peso 700 ls 0.91px #FF552E |
| 15 | `forYou.item1.textBlock` | box | 0 | 292.6 | 116 | 34.4 | `display: flex; flex-direction: column; gap: 2px` |  |
| 16 | `forYou.item1.title` | text | 0 | 292.6 | 116 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 17 | `forYou.item1.author` | text | 0 | 311.4 | 116 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 18 | `forYou.item2` | box | 130 | 108.6 | 116 | 218.4 | `width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px` |  |
| 19 | `forYou.item2.cover` | box | 130 | 108.6 | 116 | 174 | `position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #058CD7; overflow: hidden; box-sizing: border-box` |  |
| 20 | `forYou.item2.cover.spine` | box | 131.5 | 110.1 | 7 | 171 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 21 | `forYou.item2.cover.lines` | box | 147.5 | 128.1 | 81 | 30 | `position: absolute; left: 16px; right: 16px; top: 18px; display: flex; flex-direction: column; gap: 6px` |  |
| 22 | `forYou.item2.cover.line1` | box | 147.5 | 128.1 | 81 | 6 | `height: 6px; border-radius: 6px; background: #F7F0E3` |  |
| 23 | `forYou.item2.cover.line2` | box | 147.5 | 140.1 | 56.7 | 6 | `height: 6px; width: 70%; border-radius: 6px; background: #F7F0E3` |  |
| 24 | `forYou.item2.cover.line3` | box | 147.5 | 152.1 | 32.4 | 6 | `height: 6px; width: 40%; border-radius: 6px; background: #F7F0E3` |  |
| 25 | `forYou.item2.cover.textBlock` | box | 147.5 | 208.49 | 87 | 60.61 | `position: absolute; left: 16px; right: 10px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 26 | `forYou.item2.cover.title` | text | 147.5 | 208.49 | 87 | 46.8 | `font-family: "Instrument Serif", Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 26/23.4px peso 400 ls normal #FFFAF1 |
| 27 | `forYou.item2.cover.author` | text | 147.5 | 261.29 | 87 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 6.5/normal peso 700 ls 0.91px #FFFAF1 |
| 28 | `forYou.item2.textBlock` | box | 130 | 292.6 | 116 | 34.4 | `display: flex; flex-direction: column; gap: 2px` |  |
| 29 | `forYou.item2.title` | text | 130 | 292.6 | 116 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 30 | `forYou.item2.author` | text | 130 | 311.4 | 116 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 31 | `forYou.item3` | box | 260 | 108.6 | 116 | 218.4 | `width: 116px; flex-shrink: 0; display: flex; flex-direction: column; gap: 10px` |  |
| 32 | `forYou.item3.cover` | box | 260 | 108.6 | 116 | 174 | `position: relative; width: 116px; height: 174px; border-radius: 4px 10px 10px 4px; border: 1.5px solid #1A1714; background: #00995E; overflow: hidden; box-sizing: border-box` |  |
| 33 | `forYou.item3.cover.spine` | box | 261.5 | 110.1 | 7 | 171 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 7px; background: rgba(0,0,0,0.18)` |  |
| 34 | `forYou.item3.cover.archOuter` | box | 285.5 | 132.1 | 68 | 80 | `position: absolute; left: 24px; top: 22px; width: 68px; height: 80px; border-radius: 34px 34px 0px 0px; background: #FED170` |  |
| 35 | `forYou.item3.cover.archInner` | box | 305.5 | 166.1 | 28 | 46 | `position: absolute; left: 44px; top: 56px; width: 28px; height: 46px; border-radius: 14px 14px 0px 0px; background: #00995E` |  |
| 36 | `forYou.item3.cover.textBlock` | box | 277.5 | 231.89 | 87 | 37.21 | `position: absolute; left: 16px; right: 10px; bottom: 12px; display: flex; flex-direction: column; gap: 6px` |  |
| 37 | `forYou.item3.cover.title` | text | 277.5 | 231.89 | 87 | 23.4 | `font-family: "Instrument Serif", Georgia, serif; font-size: 26px; line-height: 0.9; color: #FFFAF1` | Instrument Serif 26/23.4px peso 400 ls normal #FFFAF1 |
| 38 | `forYou.item3.cover.author` | text | 277.5 | 261.29 | 87 | 7.81 | `font-size: 6.5px; letter-spacing: 0.14em; font-weight: 700; color: #FFFAF1` | Figtree 6.5/normal peso 700 ls 0.91px #FFFAF1 |
| 39 | `forYou.item3.textBlock` | box | 260 | 292.6 | 116 | 34.4 | `display: flex; flex-direction: column; gap: 2px` |  |
| 40 | `forYou.item3.title` | text | 260 | 292.6 | 116 | 16.8 | `font-size: 14px; font-weight: 700; line-height: 1.2` | Figtree 14/16.8px peso 700 ls normal #1A1714 |
| 41 | `forYou.item3.author` | text | 260 | 311.4 | 116 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `forYou.title` | 1 | Para você | 29.92 | 0 | 109.35 | 109.35 |
| `forYou.seeAll` | 1 | Ver tudo | 26.9 | 272.01 | 328 | 55.99 |
| `forYou.reasonChip` | 1 | Porque você lê Machado de Assis | 78.85 | 31.5 | 227.78 | 196.28 |
| `forYou.item1.cover.title` | 1 | Memórias | 141.58 | 17.5 | 81.53 | 64.03 |
| `forYou.item1.cover.title` | 2 | Póstumas de | 159.63 | 17.5 | 98.48 | 80.98 |
| `forYou.item1.cover.title` | 3 | Brás Cubas | 177.68 | 17.5 | 88.31 | 70.81 |
| `forYou.item1.cover.author` | 1 | MACHADO DE ASSIS | 267.46 | 17.5 | 95.83 | 78.33 |
| `forYou.item1.title` | 1 | Memórias Póstu… *(reticências)* | 305.9 | 0 | 112.88 | 112.88 |
| `forYou.item1.author` | 1 | Machado de Assis | 323.75 | 0 | 105.31 | 105.31 |
| `forYou.item2.cover.title` | 1 | Quincas | 229.03 | 147.5 | 218.35 | 70.85 |
| `forYou.item2.cover.title` | 2 | Borba | 252.43 | 147.5 | 200.9 | 53.4 |
| `forYou.item2.cover.author` | 1 | MACHADO DE ASSIS | 267.46 | 147.5 | 225.82 | 78.32 |
| `forYou.item2.title` | 1 | Quincas Borba | 305.9 | 130 | 223.39 | 93.39 |
| `forYou.item2.author` | 1 | Machado de Assis | 323.75 | 130 | 235.31 | 105.31 |
| `forYou.item3.cover.title` | 1 | O Cortiço | 252.43 | 277.5 | 359.27 | 81.77 |
| `forYou.item3.cover.author` | 1 | ALUÍSIO AZEVEDO | 267.46 | 277.5 | 348.99 | 71.49 |
| `forYou.item3.title` | 1 | O Cortiço | 305.9 | 260 | 323.01 | 63.01 |
| `forYou.item3.author` | 1 | Aluísio Azevedo | 323.75 | 260 | 353.41 | 93.41 |

## Leitura de designer (detalhes críticos)

1. Seção em coluna, **gap 14**. O retângulo da seção é 20→370, mas o carrossel usa `margin: 4px -20px 0; padding: 0 20px` → ocupa **0→390** (sangra até as bordas) e começa **18 px** abaixo do chip (14 de gap + 4 de margem).
2. Cabeçalho (44 de altura, `space-between`, centralizado): "Para você" Bricolage 24 ls −0,6 (28,8 → y+7,6); link "Ver tudo" 14/700 + seta 18 (traço **2**), gap 4, altura de toque 44.
3. Chip de motivo (alinhado à esquerda): padding **7 12 7 10**, borda 1,5, fundo `#FFFAF1`, raio 999, gap 6: brilho sólido 14 + "Porque você lê Machado de Assis" 13/600 → **241,28 × 32,6**.
4. Itens de 116 de largura, gap 14, coluna gap 10: capa 116×174 + textos (gap 2): título 14/700 **line-height 1,2**, autor 13/500 `#5B544B`. Só o **primeiro** título tem `nowrap + ellipsis` → **"Memórias Póstu…"**. Os títulos 2 e 3 quebrariam normalmente (cabem em 1 linha).
5. O 3º item vai de 280 a 396 → **cortado 6 px na borda direita** (o contêiner é `overflow: hidden`). Com D-03 o carrossel rola; em repouso fica idêntico.
6. Capas (116×174): borda 1,5, raio **4 10 10 4**, recorte, **sem sombra e sem rotação**, lombada 7 px.
   - **Memórias Póstumas**: fundo `#FF552E`, lombada `.15`; **elipse** tinta em `left 20 / right −30 / bottom −58`, altura 116 → largura 123 (**border-radius 50% numa caixa 123×116 = elipse 61,5 × 58, não círculo**); título "Memórias Póstumas de Brás Cubas" Instrument Serif 19 / 0,95 **tinta** em `left 16 / right 10 / top 16` quebrando em **"Memórias" / "Póstumas de" / "Brás Cubas"**; autor em `left 16 / bottom 12` (largura do texto, 78,33) com cor **`#FF552E` = cor do fundo** → só aparece sobre a elipse preta (o "M" inicial fica invisível sobre o laranja — é assim no arquivo).
   - **Quincas Borba**: fundo `#058CD7`, lombada `.18`; três barras `#F7F0E3` altura 6 raio 6 em coluna gap 6 (`left 16 / right 16 / top 18`), larguras **100% (81), 70% (56,7), 40% (32,4)**; bloco inferior (`left 16 / right 10 / bottom 12`, gap 6): "Quincas⏎Borba" Instrument Serif 26 / **0,9** `#FFFAF1` + "MACHADO DE ASSIS" 6,5/700 ls 0,91 `#FFFAF1`.
   - **O Cortiço**: fundo `#00995E`, lombada `.18`; arco externo `#FED170` 68×80 raio **34 34 0 0** em `left 24 / top 22`; arco interno **da cor do fundo** `#00995E` 28×46 raio **14 14 0 0** em `left 44 / top 56` (forma a "porta"); bloco inferior: "O Cortiço" 26/0,9 `#FFFAF1` + "ALUÍSIO AZEVEDO".

## Construção obrigatória

```dart
Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [       // envolvido por _fullBleed('forYou', …) da F02
  Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: SizedBox(key: const ValueKey('forYou.header'), height: 44,
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [/* título; link Ver tudo (Key forYou.seeAll, altura 44) */]))),
  const SizedBox(height: 14),
  Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Align(alignment: Alignment.centerLeft, child: /* Pill Key forYou.reasonChip */)),
  const SizedBox(height: 14 + 4),
  SingleChildScrollView(key: const ValueKey('forYou.carousel'), scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 20), clipBehavior: Clip.hardEdge,
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: 14, children: [/* 3 itens de 116 */])),
])
```
- Elipse: `DecoratedBox(decoration: const ShapeDecoration(shape: OvalBorder(), color: AppColors.ink))` num `Positioned(left: 20, right: -30, bottom: -58, height: 116)` — **nunca** `BoxShape.circle`.
- Barras do Quincas: `Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 6)` com `FractionallySizedBox(widthFactor: 1 | .7 | .4, alignment: Alignment.centerLeft)` — o `stretch` é obrigatório: com o alinhamento padrão da `Column` (`center`) o `FractionallySizedBox` recebe restrição frouxa, mede só a fração e é **centralizado** pela coluna (as barras de 70% e 40% sairiam do lugar). Com o `stretch`, o `FractionallySizedBox` mede a largura toda (81) → as Keys `forYou.item2.cover.line1..3` ficam na **caixa filha** (`SizedBox(height: 6)` + `DecoratedBox` raio 6 `#F7F0E3`: 81 / 56,7 / 32,4 × 6), não no `FractionallySizedBox`.
- Ordem de pintura dentro de cada capa = ordem da tabela (lombada → formas → textos).
- Semântica: seção `Semantics(container: true, explicitChildNodes: true, label: 'Para você')`; título `<h3>` com `Semantics(container: true, header: true, …)`; itens = `Pressable(isLink: true)` sem rótulo próprio (nome = textos do item, como no `<a>`; destino `/livro/:bookId` na F12); "Ver tudo" = `Pressable(isLink: true)` → `/para-voce`.

## Subfases

- **8.1** Cabeçalho + link "Ver tudo" (44 de altura de toque).
- **8.2** Chip de motivo 241,28 × 32,6.
- **8.3** Carrossel sangrado (0→390, padding 20, gap 14, corte do 3º item; rolagem D-03).
- **8.4** Capa Memórias Póstumas (elipse, título em 3 linhas, autor na cor do fundo).
- **8.5** Capa Quincas Borba (barras 81/56,7/32,4; título 26/0,9).
- **8.6** Capa O Cortiço (arcos sobrepostos).
- **8.7** Legendas (reticências só no 1º título).
- **8.8** Verificação completa + relatório.

## Testes da fase

- `expectGeometry(tester, idsOfSection('forYou'))` → 41/41 (a Key `forYou` é o retângulo 20→370 da F02).
- `expectTextLines` para todos os textos (título da Memórias em 3 linhas; "Memórias Póstu…").
- Estilo: raio 4/10/10/4 nas 3 capas, sem sombra, sem rotação; elipse 123×116; arcos 34/34/0/0 e 14/14/0/0; cores.
- Rolagem (D-03): a extensão máxima é **26 px** (conteúdo 20 + 3 × 116 + 2 × 14 + 20 = 416 − 390). `tester.drag(carrossel, Offset(-100, 0))` + `pumpAndSettle` → `position.pixels == 26` e `maxScrollExtent == 26` (depois de soltar ele **fica** em 26 — só o excesso do bounce/stretch volta); `tester.drag(carrossel, Offset(100, 0))` + `pumpAndSettle` → `pixels == 0` e o golden do repouso volta a ser idêntico.
- Visual: `--rect 0,1199,390,344` → `blur_mismatch_% ≤ 0,5`. Inspecione: "ACHADO DE ASSIS" visível só sobre a elipse; corte do 3º item em x = 390.
- Não-regressão F03–F07.

## Checklist de aceite da FASE 8

- [ ] 8.1 Cabeçalho 44 (título 24 ls −0,6; "Ver tudo" 14/700 + seta 18 traço 2, gap 4)
- [ ] 8.2 Chip 7/12/7/10, borda 1,5, brilho 14 + texto 13/600, gap 6 → 241,28×32,6
- [ ] 8.3 Carrossel 0→390, padding 20, gap 14, 18 px abaixo do chip, 3º item cortado em 390; rolagem D-03
- [ ] 8.4 Memórias: `#FF552E`, lombada .15, elipse 123×116 (OvalBorder), título 19/0,95 em 3 linhas, autor `#FF552E` só visível sobre a elipse
- [ ] 8.5 Quincas: `#058CD7`, lombada .18, barras 6 px (81/56,7/32,4, gap 6), "Quincas⏎Borba" 26/0,9, autor
- [ ] 8.6 O Cortiço: `#00995E`, lombada .18, arco `#FED170` 68×80 (34/34/0/0) + arco `#00995E` 28×46 (14/14/0/0), título e autor
- [ ] 8.7 Legendas 14/700/1,2 e 13/500; "Memórias Póstu…" (só o 1º com reticências)
- [ ] Geometria 41/41 · Texto OK · Estilo OK · Rolagem OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado e heatmap inspecionados

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 8 concluída — aguardando sua aprovação para iniciar a FASE 9.`
