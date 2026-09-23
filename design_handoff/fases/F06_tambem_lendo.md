# FASE 6 — Seção 4: "Também lendo" (2 cards com capas que "saltam" e anéis de progresso)

> Pré-requisito: FASE 5 aprovada.
> Referências: `secoes/F06_tambem_lendo@3x.png` · `redline/F06_tambem_lendo_redline@3x.png`.
> Arquivos: `sections/also_reading_section.dart`, `covers/mrs_dalloway_cover.dart`, `covers/pride_prejudice_cover.dart`.

---

## HTML literal da seção

```html
    <!-- Also reading -->
    <section aria-label="Também lendo" style="margin-top: 32px; display: flex; flex-direction: column; gap: 30px;">
      <div style="display: flex; align-items: center; gap: 8px;">
        <h3 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.3px;">Também lendo</h3>
        <span style="min-width: 22px; height: 22px; padding: 0 7px; box-sizing: border-box; border-radius: 999px; background: #1A1714; color: #F7F0E3; font-size: 12px; font-weight: 800; display: flex; align-items: center; justify-content: center;">2</span>
      </div>
      <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 12px;">
        <a href="#" style="display: flex; flex-direction: column; gap: 12px; padding: 0 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
          <div style="display: flex; align-items: flex-end; justify-content: space-between;">
            <div style="position: relative; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #ABCF82; overflow: hidden; box-sizing: border-box; transform: rotate(-4deg); box-shadow: 2px 2px 0 #1A1714;">
              <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 5px; background: rgba(0,0,0,0.15);"></div>
              <div style="position: absolute; left: 12px; right: 7px; top: 12px; height: 20px; border-radius: 20px 20px 0 0; background: #1A1714;"></div>
              <div style="position: absolute; left: 10px; right: 5px; bottom: 8px; font-family: 'Instrument Serif', Georgia, serif; font-size: 11px; line-height: 0.95; color: #1A1714;">Mrs.<br>Dalloway</div>
            </div>
            <div style="position: relative; width: 46px; height: 46px; margin-top: 12px;">
              <svg width="46" height="46" sc-camel-view-box="0 0 46 46" aria-hidden="true"><circle cx="23" cy="23" r="18" fill="none" stroke="#EAE1CF" stroke-width="5"></circle><circle cx="23" cy="23" r="18" fill="none" stroke="#1A1714" stroke-width="5" stroke-linecap="round" stroke-dasharray="38.5 113.1" transform="rotate(-90 23 23)"></circle></svg>
              <span style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800;">34%</span>
            </div>
          </div>
          <div style="display: flex; flex-direction: column; gap: 2px; min-width: 0;">
            <span style="font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Mrs. Dalloway</span>
            <span style="font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Virginia Woolf</span>
          </div>
        </a>
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
          </div>
        </a>
      </div>
    </section>
```

## Especificação pixel a pixel

Seção `alsoReading` — retângulo absoluto no canvas 390×2390: **x=20, y=555.16, w=350, h=175.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `alsoReading` | box | 0 | 0 | 350 | 175.6 | `margin-top: 32px; display: flex; flex-direction: column; gap: 30px` |  |
| 2 | `alsoReading.header` | box | 0 | 0 | 350 | 22 | `display: flex; align-items: center; gap: 8px` |  |
| 3 | `alsoReading.title` | text | 0 | 0.2 | 126.54 | 21.6 | `margin: 0px; font-family: "Bricolage Grotesque", sans-serif; font-weight: 800; font-size: 18px; letter-spacing: -0.3px` | Bricolage (opsz 18) 18/normal peso 800 ls -0.3px #1A1714 |
| 4 | `alsoReading.count` | box+text | 134.54 | 0 | 22 | 22 | `min-width: 22px; height: 22px; padding: 0px 7px; box-sizing: border-box; border-radius: 999px; background: #1A1714; color: #F7F0E3; font-size: 12px; font-weight: 800; display: flex; align-items: center; justify-content: center` | Figtree 12/normal peso 800→**700** ls normal #F7F0E3 |
| 5 | `alsoReading.grid` | box | 0 | 52 | 350 | 123.6 | `display: grid; grid-template-columns: repeat(2, minmax(0px, 1fr)); gap: 12px` |  |
| 6 | `alsoReading.card1` | box | 0 | 52 | 169 | 123.6 | `display: flex; flex-direction: column; gap: 12px; padding: 0px 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 7 | `alsoReading.card1.top` | box | 15.5 | 53.5 | 138 | 59 | `display: flex; align-items: flex-end; justify-content: space-between` |  |
| 8 | `alsoReading.card1.cover` | box | 15.5 | 31.5 | 54 | 81 | `position: relative; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #ABCF82; overflow: hidden; box-sizing: border-box; transform: rotate(-4deg); box-shadow: #1A1714 2px 2px 0px` |  |
| 9 | `alsoReading.card1.cover.spine` | box | 17 | 33 | 5 | 78 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 5px; background: rgba(0,0,0,0.15)` |  |
| 10 | `alsoReading.card1.cover.arch` | box | 29 | 45 | 32 | 20 | `position: absolute; left: 12px; right: 7px; top: 12px; height: 20px; border-radius: 20px 20px 0px 0px; background: #1A1714` |  |
| 11 | `alsoReading.card1.cover.title` | text | 27 | 82.1 | 36 | 20.9 | `position: absolute; left: 10px; right: 5px; bottom: 8px; font-family: "Instrument Serif", Georgia, serif; font-size: 11px; line-height: 0.95; color: #1A1714` | Instrument Serif 11/10.45px peso 400 ls normal #1A1714 |
| 12 | `alsoReading.card1.ring` | box | 107.5 | 66.5 | 46 | 46 | `position: relative; width: 46px; height: 46px; margin-top: 12px` |  |
| 13 | `alsoReading.card1.ring.svg` | icon | 107.5 | 66.5 | 46 | 46 | `—` |  |
| 14 | `alsoReading.card1.ring.label` | text | 107.5 | 66.5 | 46 | 46 | `position: absolute; inset: 0px; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 15 | `alsoReading.card1.textBlock` | box | 15.5 | 124.5 | 138 | 35.6 | `display: flex; flex-direction: column; gap: 2px; min-width: 0px` |  |
| 16 | `alsoReading.card1.title` | text | 15.5 | 124.5 | 138 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 17 | `alsoReading.card1.author` | text | 15.5 | 144.5 | 138 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 13/normal peso 500 ls normal #5B544B |
| 18 | `alsoReading.card2` | box | 181 | 52 | 169 | 123.6 | `display: flex; flex-direction: column; gap: 12px; padding: 0px 14px 14px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 19 | `alsoReading.card2.top` | box | 196.5 | 53.5 | 138 | 59 | `display: flex; align-items: flex-end; justify-content: space-between` |  |
| 20 | `alsoReading.card2.cover` | box | 196.5 | 31.5 | 54 | 81 | `position: relative; width: 54px; height: 81px; margin-top: -22px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.5px solid #1A1714; background: #FFC1C6; overflow: hidden; box-sizing: border-box; transform: rotate(3deg); box-shadow: #1A1714 2px 2px 0px` |  |
| 21 | `alsoReading.card2.cover.spine` | box | 198 | 33 | 5 | 78 | `position: absolute; left: 0px; top: 0px; bottom: 0px; width: 5px; background: rgba(0,0,0,0.12)` |  |
| 22 | `alsoReading.card2.cover.circle` | box | 215 | 46 | 20 | 20 | `position: absolute; left: 17px; top: 13px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 23 | `alsoReading.card2.cover.title` | text | 207 | 85.9 | 40 | 17.1 | `position: absolute; left: 9px; right: 2px; bottom: 8px; font-family: "Instrument Serif", Georgia, serif; font-size: 9px; line-height: 0.95; color: #1A1714` | Instrument Serif 9/8.55px peso 400 ls normal #1A1714 |
| 24 | `alsoReading.card2.ring` | box | 288.5 | 66.5 | 46 | 46 | `position: relative; width: 46px; height: 46px; margin-top: 12px` |  |
| 25 | `alsoReading.card2.ring.svg` | icon | 288.5 | 66.5 | 46 | 46 | `—` |  |
| 26 | `alsoReading.card2.ring.label` | text | 288.5 | 66.5 | 46 | 46 | `position: absolute; inset: 0px; display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 27 | `alsoReading.card2.textBlock` | box | 196.5 | 124.5 | 138 | 35.6 | `display: flex; flex-direction: column; gap: 2px; min-width: 0px` |  |
| 28 | `alsoReading.card2.title` | text | 196.5 | 124.5 | 138 | 18 | `font-size: 15px; font-weight: 700; line-height: 1.2; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 15/18px peso 700 ls normal #1A1714 |
| 29 | `alsoReading.card2.author` | text | 196.5 | 144.5 | 138 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B; white-space: nowrap; overflow: hidden; text-overflow: ellipsis` | Figtree 13/normal peso 500 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `alsoReading.title` | 1 | Também lendo | 16.94 | 0 | 126.54 | 126.54 |
| `alsoReading.count` | 1 | 2 | 15.2 | 142.07 | 149.02 | 6.95 |
| `alsoReading.card1.cover.title` | 1 | Mrs. | 91.06 | 27 | 43.54 | 16.54 |
| `alsoReading.card1.cover.title` | 2 | Dalloway | 101.51 | 27 | 61.52 | 34.52 |
| `alsoReading.card1.ring.label` | 1 | 34% | 93.35 | 119.49 | 141.51 | 22.02 |
| `alsoReading.card1.title` | 1 | Mrs. Dalloway | 138.75 | 15.5 | 111.29 | 95.79 |
| `alsoReading.card1.author` | 1 | Virginia Woolf | 156.85 | 15.5 | 98.32 | 82.82 |
| `alsoReading.card2.cover.title` | 1 | Orgulho e | 93.23 | 207 | 236.76 | 29.76 |
| `alsoReading.card2.cover.title` | 2 | Preconceito | 101.78 | 207 | 242.46 | 35.46 |
| `alsoReading.card2.ring.label` | 1 | 81% | 93.35 | 301.34 | 321.66 | 20.32 |
| `alsoReading.card2.title` | 1 | Orgulho e Precon… *(reticências)* | 138.75 | 196.5 | 327.02 | 130.52 |
| `alsoReading.card2.author` | 1 | Jane Austen | 156.85 | 196.5 | 269.26 | 72.76 |

## Leitura de designer (detalhes críticos)

1. Seção em coluna com **gap 30** (grande, porque as capas sobem 22 px para dentro desse espaço).
2. Cabeçalho (gap 8, centralizado): "Também lendo" Bricolage 18 ls −0,3 + contador "2": pílula **mín. 22 × 22**, padding 0 7, fundo tinta, texto `#F7F0E3` 12/800→**700**. O título tem 21,6 de altura e fica centrado na linha de 22 → y+0,2.
3. Grade de 2 colunas iguais, gap 12 → cards de **169** de largura. Card: fundo `#FFFAF1`, borda 1,5, raio **22**, padding **0 14 14** (sem padding no topo!), **sem sombra**, sem recorte.
4. Linha superior do card: `align-items: flex-end` + `space-between`. A capa (54×81) tem `margin-top: −22` → a linha mede **59** (81 − 22) e a capa **vaza 22 px para cima**, passando por cima da borda do card. O anel (46×46) tem `margin-top: 12` → ocupa 58, alinhado embaixo → começa 13 px abaixo do topo da linha.
5. Capas com **sombra dura 2/2**, borda 1,5, raio **3 7 7 3**, recorte, e **rotação**: Mrs. Dalloway **−4°**, Orgulho e Preconceito **+3°**.
   - Mrs. Dalloway: fundo `#ABCF82`; lombada 5 px `rgba(0,0,0,.15)`; arco tinta em `left 12 / right 7 / top 12`, altura 20, raio **20 20 0 0** (largura resultante 32); título "Mrs.⏎Dalloway" Instrument Serif **11**, line-height 0,95, em `left 10 / right 5 / bottom 8`.
   - Orgulho e Preconceito: fundo `#FFC1C6`; lombada 5 px `rgba(0,0,0,.12)`; círculo vazado 20×20 (border-box) borda 1,5 tinta em `left 17 / top 13`; título "Orgulho e⏎Preconceito" Instrument Serif **9**, line-height 0,95, em `left 9 / right 2 / bottom 8`.
6. Anel: trilho `#EAE1CF` e arco tinta, traço 5, raio 18, cap redondo, começa no topo, sentido horário (34% e 81%); rótulo central 11/800→700.
7. Bloco de texto (gap 2): título 15/700 **line-height 1,2**, autor 13/500 `#5B544B`; ambos `nowrap + ellipsis`. "Orgulho e Preconceito" **trunca** → exatamente **"Orgulho e Precon…"** (a próxima letra estouraria 138 por 0,70 px).
8. Altura do card = 1,5 + 59 + 12 + 35,6 + 14 + 1,5 = **123,6**.

## Construção obrigatória

```dart
Column(key: const ValueKey('alsoReading'), crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 30, children: [
  Row(key: const ValueKey('alsoReading.header'), spacing: 8, children: [
    AppText('Também lendo', key: const ValueKey('alsoReading.title'), style: AppTextStyles.sectionTitleS),
    CountBadge(key: const ValueKey('alsoReading.count'), label: '2', style: AppTextStyles.count12OnInk,
        minWidth: 22, height: 22, horizontalPadding: 7, background: AppColors.ink),
  ]),
  Row(key: const ValueKey('alsoReading.grid'), crossAxisAlignment: CrossAxisAlignment.start, spacing: 12,
      children: [Expanded(child: card1), Expanded(child: card2)]),
])
```
Card (repita para `card2` com os dados/arte dele):
```dart
NeoBox(key: const ValueKey('alsoReading.card1'), color: AppColors.surface, border: const BorderSide(width: 1.5, color: AppColors.ink),
  radius: BorderRadius.circular(22), padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [
    SizedBox(key: const ValueKey('alsoReading.card1.top'), height: 59, child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
        SizedBox(width: 54, height: 59, child: OverflowBox(minHeight: 81, maxHeight: 81, alignment: Alignment.bottomCenter,
          child: SizedBox(key: const ValueKey('alsoReading.card1.cover'), width: 54, height: 81,
            child: Transform.rotate(angle: -4 * math.pi / 180,
              child: const KeyedSubtree(key: ValueKey('alsoReading.card1.cover#rot'), child: MrsDallowayCover()))))),
        Padding(padding: const EdgeInsets.only(top: 12), child: /* anel 46×46: Keys ring, ring.svg, ring.label */),
      ])),
    Column(key: const ValueKey('alsoReading.card1.textBlock'), crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 2, children: [
      AppText(title, key: const ValueKey('alsoReading.card1.title'), style: AppTextStyles.title15, maxLines: 1, ellipsis: true),
      AppText(author, key: const ValueKey('alsoReading.card1.author'), style: AppTextStyles.body13Muted, maxLines: 1, ellipsis: true),
    ]),
  ]),
)
```
- Anel: `SizedBox(key: ring, width: 46, height: 46, child: Stack(children: [Positioned.fill(child: ExcludeSemantics(child: CustomPaint(key: ring.svg, painter: RingProgressPainter(progress: …)))), Positioned.fill(child: Center(key: ring.label, child: AppText('34%', style: AppTextStyles.micro11Bold)))]))`. O `CustomPaint` **precisa** do `Positioned.fill` (ou `size: Size.square(46)`): como filho não posicionado de um `Stack` ele recebe restrição frouxa e, sem filho, mede **0×0** — o anel seria pintado centrado em (0, 0).
- Nenhum recorte no card nem na grade (a capa precisa vazar para cima).
- Card inteiro: `Pressable(isLink: true, onTap: …)` **sem** `semanticsLabel` → o nome do link é o texto do card, como no `<a>` do HTML; destino `/livro/:bookId` na F12. Seção: `Semantics(container: true, explicitChildNodes: true, label: 'Também lendo')`. Título `<h3>`: `Semantics(container: true, header: true, child: AppText('Também lendo', …))`.

## Subfases

- **6.1** Cabeçalho (título + contador 22×22).
- **6.2** Grade e card base (169 × 123,6, padding 0/14/14, raio 22, sem sombra).
- **6.3** Capa Mrs. Dalloway (arte, −4°, sombra 2/2, vazamento de 22 px).
- **6.4** Capa Orgulho e Preconceito (arte, +3°).
- **6.5** Anéis 34% / 81% e rótulos.
- **6.6** Textos com reticências ("Orgulho e Precon…").
- **6.7** Verificação completa + relatório.

## Testes da fase

- `expectGeometry(tester, idsOfSection('alsoReading'))` → 29/29 (filhos das capas via `layoutRect`).
- `expectTextLines` para títulos, autores, rótulos dos anéis, título da seção e contador (capas: só quebras "Mrs."/"Dalloway" e "Orgulho e"/"Preconceito"; `alsoReading.card2.title` = reticências).
- Estilo: rotações (−4°, +3°), sombras (2,2), raios 3/7/7/3, cores das capas, card sem sombra, contador (tinta, texto `#F7F0E3`).
- Visual: `--rect 16,547,358,192` → `blur_mismatch_% ≤ 0,5`. Inspecione: capas passando por cima da borda do card; sombra 2/2 girada; arco preto 20/20/0/0; "Precon…".
- Não-regressão F03–F05.

## Checklist de aceite da FASE 6

- [ ] 6.1 Título Bricolage18 ls −0,3 + contador 22×22 (mín.) tinta/`#F7F0E3`, gap 8
- [ ] 6.2 Gap de seção 30; grade 2×169 com gap 12; card `#FFFAF1`, borda 1,5, raio 22, padding 0/14/14, sem sombra, altura 123,6
- [ ] 6.3 Mrs. Dalloway: `#ABCF82`, lombada .15, arco 32×20 raio 20/20/0/0, título 11/0,95 em 10/5/8, −4°, sombra 2/2, vazando 22 px
- [ ] 6.4 Orgulho e Preconceito: `#FFC1C6`, lombada .12, círculo 20 borda 1,5 em 17/13, título 9/0,95 em 9/2/8, +3°, sombra 2/2
- [ ] 6.5 Anéis 46×46 (r18, traço 5, cap redondo, topo, horário) 34% e 81%; rótulos 11/700 centralizados
- [ ] 6.6 Título 15/700/1,2 e autor 13/500 `#5B544B` com `maxLines: 1` + "…"; "Orgulho e Precon…"
- [ ] Geometria 29/29 · Texto OK · Estilo OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado e heatmap inspecionados

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 6 concluída — aguardando sua aprovação para iniciar a FASE 7.`
