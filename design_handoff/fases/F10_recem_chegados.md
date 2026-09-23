# FASE 10 — Seção 8: "Recém-chegados" (lista com mini-capas e flex-shrink do CSS)

> Pré-requisito: FASE 9 aprovada.
> Referências: `secoes/F10_recem_chegados@3x.png` · `redline/F10_recem_chegados_redline@3x.png`.
> Arquivos: `sections/recently_added_section.dart`, `covers/frankenstein_mini_cover.dart`, `covers/o_alienista_mini_cover.dart`, `covers/senhora_mini_cover.dart`, `application/css_flex.dart`.

---

## HTML literal da seção

```html
    <!-- Recently added -->
    <section aria-label="Adicionados recentemente" style="margin-top: 40px; display: flex; flex-direction: column; gap: 10px;">
      <div style="display: flex; align-items: center; justify-content: space-between;">
        <h3 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px;">Recém-chegados</h3>
        <a href="#" style="height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700;">Biblioteca
          <svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
        </a>
      </div>

      <div style="background: #FFFAF1; border-radius: 24px; padding: 4px 8px 4px 14px; display: flex; flex-direction: column;">
        <div style="display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid #E9E1D2;">
          <div style="position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #1A1714; overflow: hidden; box-sizing: border-box;">
            <div style="position: absolute; left: 10px; top: 10px; width: 22px; height: 22px; border-radius: 50%; background: #B6ACE4;"></div>
            <div style="position: absolute; left: 8px; right: 6px; bottom: 7px; height: 3px; border-radius: 3px; background: #B6ACE4;"></div>
          </div>
          <a href="#" style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
            <span style="font-size: 15px; font-weight: 700;">Frankenstein</span>
            <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Mary Shelley · EPUB</span>
          </a>
          <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #ECE7FA; color: #3B2D86;">Quero ler</span>
          <button aria-label="Mais opções para Frankenstein" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
            <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="#1A1714"><circle cx="5" cy="12" r="1.8"></circle><circle cx="12" cy="12" r="1.8"></circle><circle cx="19" cy="12" r="1.8"></circle></svg>
          </button>
        </div>
        <div style="display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid #E9E1D2;">
          <div style="position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box;">
            <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.12);"></div>
            <div style="position: absolute; left: 12px; top: 12px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></div>
            <div style="position: absolute; left: 18px; top: 18px; width: 8px; height: 8px; border-radius: 50%; background: #1A1714;"></div>
          </div>
          <a href="#" style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
            <span style="font-size: 15px; font-weight: 700;">O Alienista</span>
            <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Machado de Assis · PDF</span>
          </a>
          <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #ECE7FA; color: #3B2D86;">Quero ler</span>
          <button aria-label="Mais opções para O Alienista" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
            <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="#1A1714"><circle cx="5" cy="12" r="1.8"></circle><circle cx="12" cy="12" r="1.8"></circle><circle cx="19" cy="12" r="1.8"></circle></svg>
          </button>
        </div>
        <div style="display: flex; align-items: center; gap: 14px; padding: 12px 0;">
          <div style="position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #F2A815; overflow: hidden; box-sizing: border-box;">
            <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.12);"></div>
            <div style="position: absolute; left: 10px; right: 8px; top: 12px; height: 26px; border-radius: 13px 13px 0 0; border: 1.5px solid #1A1714; border-bottom: none; box-sizing: border-box;"></div>
          </div>
          <a href="#" style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
            <span style="font-size: 15px; font-weight: 700;">Senhora</span>
            <span style="font-size: 13px; font-weight: 500; color: #5B544B;">José de Alencar · EPUB</span>
          </a>
          <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #EFE7D7; color: #4A4238;">Novo</span>
          <button aria-label="Mais opções para Senhora" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
            <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="#1A1714"><circle cx="5" cy="12" r="1.8"></circle><circle cx="12" cy="12" r="1.8"></circle><circle cx="19" cy="12" r="1.8"></circle></svg>
          </button>
        </div>
      </div>
    </section>
```

## Especificação pixel a pixel

Seção `recent` — retângulo absoluto no canvas 390×2390: **x=20, y=1881.16, w=350, h=334**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `recent` | box | 0 | 0 | 350 | 334 | `margin-top: 40px; display: flex; flex-direction: column; gap: 10px` |  |
| 2 | `recent.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `recent.title` | text | 0 | 7.6 | 195.47 | 28.8 | `margin: 0px; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px` | Bricolage (opsz 24) 24/normal peso 800 ls -0.6px #1A1714 |
| 4 | `recent.libraryLink` | text | 263.81 | 0 | 86.19 | 44 | `height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 5 | `recent.libraryLink.icon` | icon | 332 | 13 | 18 | 18 | `—` |  |
| 6 | `recent.list` | box | 0 | 54 | 350 | 280 | `background: #FFFAF1; border-radius: 24px; padding: 4px 8px 4px 14px; display: flex; flex-direction: column` |  |
| 7 | `recent.row0` | box | 14 | 58 | 328 | 91 | `display: flex; align-items: center; gap: 14px; padding: 12px 0px; border-bottom: 1px solid #E9E1D2` |  |
| 8 | `recent.row0.cover` | box | 14 | 70 | 44 | 66 | `position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #1A1714; overflow: hidden; box-sizing: border-box` |  |
| 9 | `recent.row0.cover.moon` | box | 25.2 | 81.2 | 22 | 22 | `position: absolute; left: 10px; top: 10px; width: 22px; height: 22px; border-radius: 50%; background: #B6ACE4` |  |
| 10 | `recent.row0.cover.bar` | box | 23.2 | 124.8 | 27.6 | 3 | `position: absolute; left: 8px; right: 6px; bottom: 7px; height: 3px; border-radius: 3px; background: #B6ACE4` |  |
| 11 | `recent.row0.textBlock` | box | 72 | 84.7 | 126.54 | 36.6 | `flex-grow: 1; min-width: 0px; display: flex; flex-direction: column; gap: 3px` |  |
| 12 | `recent.row0.title` | text | 72 | 84.7 | 126.54 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 13 | `recent.row0.subtitle` | text | 72 | 105.7 | 126.54 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 14 | `recent.row0.tag` | box+text | 212.54 | 90.8 | 71.46 | 24.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #ECE7FA; color: #3B2D86` | Figtree 12/normal peso 700 ls normal #3B2D86 |
| 15 | `recent.row0.more` | box | 298 | 81 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0px` |  |
| 16 | `recent.row0.more.icon` | icon | 310 | 93 | 20 | 20 | `—` |  |
| 17 | `recent.row1` | box | 14 | 149 | 328 | 91 | `display: flex; align-items: center; gap: 14px; padding: 12px 0px; border-bottom: 1px solid #E9E1D2` |  |
| 18 | `recent.row1.cover` | box | 14 | 161 | 44 | 66 | `position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box` |  |
| 19 | `recent.row1.cover.spine` | box | 15.2 | 162.2 | 4 | 63.6 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 4px; background: rgba(0,0,0,0.12)` |  |
| 20 | `recent.row1.cover.ring` | box | 27.2 | 174.2 | 20 | 20 | `position: absolute; left: 12px; top: 12px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 21 | `recent.row1.cover.dot` | box | 33.2 | 180.2 | 8 | 8 | `position: absolute; left: 18px; top: 18px; width: 8px; height: 8px; border-radius: 50%; background: #1A1714` |  |
| 22 | `recent.row1.textBlock` | box | 72 | 167.9 | 129.83 | 52.2 | `flex-grow: 1; min-width: 0px; display: flex; flex-direction: column; gap: 3px` |  |
| 23 | `recent.row1.title` | text | 72 | 167.9 | 129.83 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 24 | `recent.row1.subtitle` | text | 72 | 188.9 | 129.83 | 31.2 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 25 | `recent.row1.tag` | box+text | 215.83 | 174.6 | 68.17 | 38.8 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #ECE7FA; color: #3B2D86` | Figtree 12/normal peso 700 ls normal #3B2D86 |
| 26 | `recent.row1.more` | box | 298 | 172 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0px` |  |
| 27 | `recent.row1.more.icon` | icon | 310 | 184 | 20 | 20 | `—` |  |
| 28 | `recent.row2` | box | 14 | 240 | 328 | 90 | `display: flex; align-items: center; gap: 14px; padding: 12px 0px` |  |
| 29 | `recent.row2.cover` | box | 14 | 252 | 44 | 66 | `position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #F2A815; overflow: hidden; box-sizing: border-box` |  |
| 30 | `recent.row2.cover.spine` | box | 15.2 | 253.2 | 4 | 63.6 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 4px; background: rgba(0,0,0,0.12)` |  |
| 31 | `recent.row2.cover.arch` | box | 25.2 | 265.2 | 23.6 | 26 | `position: absolute; left: 10px; right: 8px; top: 12px; height: 26px; border-radius: 13px 13px 0px 0px; border-top: 1.5px solid #1A1714; border-right: 1.5px solid #1A1714; border-left: 1.5px solid #1A1714; border-image: initial; border-bottom: none; box-sizing: border-box` |  |
| 32 | `recent.row2.textBlock` | box | 72 | 266.7 | 148.56 | 36.6 | `flex-grow: 1; min-width: 0px; display: flex; flex-direction: column; gap: 3px` |  |
| 33 | `recent.row2.title` | text | 72 | 266.7 | 148.56 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 34 | `recent.row2.subtitle` | text | 72 | 287.7 | 148.56 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 35 | `recent.row2.tag` | box+text | 234.56 | 272.8 | 49.44 | 24.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #EFE7D7; color: #4A4238` | Figtree 12/normal peso 700 ls normal #4A4238 |
| 36 | `recent.row2.more` | box | 298 | 263 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0px` |  |
| 37 | `recent.row2.more.icon` | icon | 310 | 275 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `recent.title` | 1 | Recém-chegados | 29.92 | 0 | 195.47 | 195.47 |
| `recent.libraryLink` | 1 | Biblioteca | 26.9 | 263.81 | 328 | 64.19 |
| `recent.row0.title` | 1 | Frankenstein | 98.95 | 72 | 160.51 | 88.51 |
| `recent.row0.subtitle` | 1 | Mary Shelley · EPUB | 118.05 | 72 | 188.78 | 116.78 |
| `recent.row0.tag` | 1 | Quero ler | 107.2 | 222.54 | 274 | 51.46 |
| `recent.row1.title` | 1 | O Alienista | 182.15 | 72 | 147.34 | 75.34 |
| `recent.row1.subtitle` | 1 | Machado de Assis · | 201.25 | 72 | 183.81 | 111.81 |
| `recent.row1.subtitle` | 2 | PDF | 216.85 | 72 | 95.7 | 23.7 |
| `recent.row1.tag` | 1 | Quero | 191 | 225.83 | 260.28 | 34.45 |
| `recent.row1.tag` | 2 | ler | 205.4 | 225.83 | 239.98 | 14.15 |
| `recent.row2.title` | 1 | Senhora | 280.95 | 72 | 128.88 | 56.88 |
| `recent.row2.subtitle` | 1 | José de Alencar · EPUB | 300.05 | 72 | 207.37 | 135.37 |
| `recent.row2.tag` | 1 | Novo | 289.2 | 244.56 | 274 | 29.44 |

## Leitura de designer (detalhes críticos)

1. Seção em coluna, **gap 10**. Cabeçalho igual ao de "Para você" (44 de altura): "Recém-chegados" Bricolage 24 ls −0,6 + link "Biblioteca" 14/700 + seta 18.
2. Lista: fundo `#FFFAF1`, raio **24**, padding **4 8 4 14** (assimétrico!), **sem borda e sem sombra**. Altura 280.
3. Linhas: `align-items: center`, gap **14**, padding **12 0**, divisor **1 px `#E9E1D2`** embaixo das linhas 1 e 2 (a última não tem) → alturas 91, 91, 90. O divisor ocupa a largura da linha (328), de x = 34 a 362.
4. Mini-capas 44×66, borda **1,2**, raio **3 7 7 3**, recorte, sem sombra:
   - Frankenstein: fundo **tinta**; lua 22×22 `#B6ACE4` em `left 10 / top 10`; barra `#B6ACE4` altura 3 raio 3 em `left 8 / right 6 / bottom 7` (largura 27,6). Sem lombada.
   - O Alienista: fundo `#B6ACE4`; lombada **4 px** `.12`; anel 20×20 (border-box) borda 1,5 tinta em `left 12 / top 12`; ponto 8×8 tinta em `left 18 / top 18`.
   - Senhora: fundo `#F2A815`; lombada 4 px `.12`; arco vazado: `left 10 / right 8 / top 12`, altura 26, raio **13 13 0 0**, borda 1,5 tinta **sem a borda de baixo** (largura 23,6).
5. Texto (link, flexível, `min-width: 0`, gap 3): título 15/700 (**line-height normal = 18**), subtítulo "Autor · FORMATO" 13/500 `#5B544B`.
6. Selo: 12/700, padding 5 10, raio 999, **sem borda**: "Quero ler" `#ECE7FA`/`#3B2D86`; "Novo" `#EFE7D7`/`#4A4238`.
7. Botão "mais opções" 44×44 transparente, ícone 20 (três pontos r1,8).
8. ⚠ **Flex-shrink do CSS (D-12)**: sobram **198 px** para texto + selo (328 − 44 − 44 − 3 × 14). Na linha "O Alienista" o texto quer 138,68 (subtítulo) e o selo 71,46 → estouro de ≈ 12,13 px (138,676 + 71,456 − 198, com as larguras sem arredondar). O CSS encolhe os dois **proporcionalmente à base INTERNA** (texto 138,68; selo 51,46 = sem o padding): texto → **129,83** (subtítulo quebra em "Machado de Assis ·" / "PDF") e selo → **68,17** (texto quebra em "Quero" / "ler", selo com 38,8 de altura). Nas linhas 1 e 3 não há estouro: o texto cresce (126,54 e 148,56) e o selo mantém a largura natural. **`Expanded`/`Flexible` do Flutter NÃO reproduzem isso — implemente o algoritmo.**

## Construção obrigatória

`application/css_flex.dart`:
```dart
/// Resolve larguras de [texto (flex-grow 1, flex-shrink 1, min-width 0)] + [selo (flex-shrink 1, min-width = min-content)]
/// exatamente como o CSS Flexbox (§9.7 "Resolving Flexible Lengths").
({double text, double tag}) resolveTextAndTag({
  required double available,        // 198 no canvas 390
  required double textMaxContent,    // max(título, subtítulo) em largura intrínseca
  required double tagTextMaxContent, // largura do texto do selo
  required double tagTextMinContent, // maior palavra do selo
  double tagHorizontalPadding = 20,  // 10 + 10
}) {
  final tagBase = tagTextMaxContent + tagHorizontalPadding;
  if (textMaxContent + tagBase <= available) return (text: available - tagBase, tag: tagBase); // texto cresce
  final overflow = textMaxContent + tagBase - available;
  final scaledTotal = textMaxContent + tagTextMaxContent;   // fator = flex-shrink × base INTERNA
  var text = textMaxContent - overflow * textMaxContent / scaledTotal;
  var tag = tagBase - overflow * tagTextMaxContent / scaledTotal;
  final tagMin = tagTextMinContent + tagHorizontalPadding;
  if (tag < tagMin) { tag = tagMin; text = available - tag; }  // selo não encolhe abaixo do min-content
  return (text: text, tag: tag);
}
```
Medidas intrínsecas com `ui.Paragraph` (mesmos estilos do `AppText`: `title15`, `body13Muted`, `tagLavender`/`tagSand`). Testes unitários obrigatórios (valores do arquivo):

| Linha | textMax | tagTextMax | tagTextMin | Resultado esperado (±0,05) |
|---|---|---|---|---|
| Frankenstein | 116,78 | 51,46 | 34,45 | texto **126,54**, selo **71,46** |
| O Alienista | 138,68 | 51,46 | 34,45 | texto **129,83**, selo **68,17** |
| Senhora | 135,37 | 29,44 | 29,44 | texto **148,56**, selo **49,44** |

Linha (use `LayoutBuilder` para obter a largura da linha e calcular `available`; a lista **não** está sob `IntrinsicHeight`):
```dart
LayoutBuilder(builder: (context, c) {
  final w = resolveTextAndTag(
    available: c.maxWidth - 44 - 44 - 3 * 14,                  // 328 − 130 = 198
    textMaxContent: math.max(measure(book.title, AppTextStyles.title15), measure(subtitle, AppTextStyles.body13Muted)),
    tagTextMaxContent: measure(tagLabel, tagStyle), tagTextMinContent: longestWord(tagLabel, tagStyle));
  return Container(                                              // Container SOMA a borda ao tamanho (DecoratedBox não soma)
    key: ValueKey('recent.row$i'),
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: i < 2
        ? const BoxDecoration(border: Border(bottom: BorderSide(width: 1, color: AppColors.divider)))
        : null,                                                  // → alturas 66 + 24 + 1 = 91, 91 e 66 + 24 = 90
    child: Row(crossAxisAlignment: CrossAxisAlignment.center, spacing: 14, children: [
      MiniCover(key: ValueKey('recent.row$i.cover'), …),                               // 44×66
      SizedBox(width: w.text, child: Pressable(isLink: true, onTap: …,        // sem rótulo: nome = título + subtítulo (<a>)
        child: Column(key: ValueKey('recent.row$i.textBlock'), mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 3, children: [title, subtitle]))),
      SizedBox(width: w.tag, child: Pill(key: ValueKey('recent.row$i.tag'), padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          color: tagBackground, child: AppText(tagLabel, style: tagStyle))),                 // quebra dentro dessa largura
      CircleIconButton(key: ValueKey('recent.row$i.more'), size: 44,                  // sem fundo e sem borda
          icon: AppSvg(AppIcons.moreHorizontal, size: 20, key: ValueKey('recent.row$i.more.icon')),
          onTap: () => onMore(book), semanticsLabel: 'Mais opções para ${book.title}'),
    ]),
  );
})
```
- `measure`/`longestWord` = larguras intrínsecas de `ui.Paragraph` com os mesmos estilos do `AppText` (máxima e mínima), sem arredondar.
- O divisor pertence à linha (largura 328, de x = 34 a 362) e fica **dentro** do retângulo `recent.rowN` (0 e 1).
- Lista: `NeoBox(key: 'recent.list', color: surface, radius: BorderRadius.circular(24), padding: EdgeInsets.fromLTRB(14, 4, 8, 4))`.
- Semântica: seção `Semantics(container: true, explicitChildNodes: true, label: 'Adicionados recentemente')`; título `<h3>` "Recém-chegados" com `Semantics(container: true, header: true, …)`; bloco de texto é link (`/livro/:bookId`); botão `label: 'Mais opções para <título>'`.

## Subfases

- **10.1** Cabeçalho + link "Biblioteca".
- **10.2** Contêiner da lista (padding 4/8/4/14, raio 24, sem borda) + divisores 1 px.
- **10.3** Mini-capas (3 artes, borda 1,2).
- **10.4** Algoritmo `resolveTextAndTag` + testes unitários da tabela.
- **10.5** Linhas com textos e selos (inclui as quebras "Machado de Assis ·"/"PDF" e "Quero"/"ler").
- **10.6** Botões "mais opções".
- **10.7** Verificação completa + relatório.

## Testes da fase

- `expectGeometry(tester, idsOfSection('recent'))` → 37/37.
- `expectTextLines` para todos os textos (em especial `recent.row1.subtitle` e `recent.row1.tag` com 2 linhas).
- Estilo: lista sem borda/sombra; divisores 1 px `#E9E1D2` só nas linhas 0 e 1; mini-capas borda 1,2; selos sem borda com as cores certas; arco da Senhora sem borda inferior.
- Visual: `--rect 16,1873,358,351` → `blur_mismatch_% ≤ 0,5`.
- Não-regressão F03–F09.

## Checklist de aceite da FASE 10

- [ ] 10.1 Cabeçalho 44 com "Recém-chegados" 24 ls −0,6 e link "Biblioteca" + seta
- [ ] 10.2 Lista `#FFFAF1` raio 24 padding 4/8/4/14, sem borda/sombra; alturas de linha 91/91/90; divisores 1 px `#E9E1D2`
- [ ] 10.3 Frankenstein (tinta, lua 22, barra 27,6×3), O Alienista (lavanda, lombada 4, anel 20, ponto 8), Senhora (âmbar, lombada 4, arco 23,6×26 sem base)
- [ ] 10.4 `resolveTextAndTag` + 3 testes da tabela verdes
- [ ] 10.5 Linha 2 reproduz o arquivo: subtítulo em 2 linhas e selo "Quero"/"ler" 68,17×38,8 centralizado
- [ ] 10.5 Selos: "Quero ler" `#ECE7FA`/`#3B2D86`, "Novo" `#EFE7D7`/`#4A4238`
- [ ] 10.6 Botões 44×44 transparentes com ícone 20 e semântica
- [ ] Geometria 37/37 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado e heatmap inspecionados

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 10 concluída — aguardando sua aprovação para iniciar a FASE 11.`
