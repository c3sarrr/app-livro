# FASE L13b — Onboarding 3/4 (dica) — o foco no scanner, a seta, "é aqui!" e o cartão

> Tela 13b · prancha `013b_onboarding_dica_scanner` (13b · Onboarding — dica do scanner, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L13b_dica_scanner@3x.png` · `docs/design/medicao/projeto/png/redline/L13b_dica_scanner_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/013b_onboarding_dica_scanner_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_013b_onboarding_dica_scanner.json` · `test/reference/projeto/reference_layout_013b_onboarding_dica_scanner.dart` (`kRef13b`).
> Arquivos sugeridos: `lib/features/account/presentation/onboarding/scanner_tip_overlay.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A dica do scanner (13b), por cima do passo 3: o escuro com o círculo de luz no botão amarelo, o anel tracejado, a seta desenhada, "é aqui!" e o bilhete com a fita — "Tem o livro na mão?", Entendi e Testar agora.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{progress}}` = padrão `#FF552E`.

```html
<!-- Coach mark (shown once, on arrival at step 3): scrim with a spotlight on the scanner -->
<span aria-hidden="true" style="position: absolute; left: 286px; top: -12px; width: 76px; height: 76px; border-radius: 50%; box-shadow: 0 0 0 1400px rgba(26,23,20,0.82); z-index: 5; pointer-events: none;"></span>

<span aria-hidden="true" style="position: absolute; left: 279px; top: -19px; width: 90px; height: 90px; border-radius: 50%; border: 2px dashed #FFFAF1; box-sizing: border-box; z-index: 6; pointer-events: none;"></span>

<svg aria-hidden="true" width="350" height="140" viewBox="0 0 350 140" style="position: absolute; left: 0; top: 0; z-index: 6; overflow: visible; pointer-events: none;">
  <path d="M214 130C222 96 244 66 296 60" fill="none" stroke="#FFFAF1" stroke-width="2.6" stroke-linecap="round"></path>
  <path d="M283.9 55.3L296 60L285.3 67.4" fill="none" stroke="#FFFAF1" stroke-width="2.8" stroke-linecap="round" stroke-linejoin="round"></path>
</svg>

<span aria-hidden="true" style="position: absolute; left: 92px; top: 62px; z-index: 6; padding: 3px 14px 7px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 25px; line-height: 1; color: #1A1714; transform: rotate(-6deg); white-space: nowrap;">é aqui!</span>

<section role="dialog" aria-modal="true" aria-labelledby="tip-title" aria-describedby="tip-body" style="position: absolute; left: 0; right: 0; top: 146px; z-index: 6; padding: 22px 18px 18px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; transform: rotate(-1.5deg); box-sizing: border-box;">
  <span aria-hidden="true" style="position: absolute; left: 50%; top: -13px; width: 78px; height: 24px; margin-left: -39px; background: {{brand}}; opacity: 0.85; border: 1.5px solid rgba(26,23,20,0.35); box-sizing: border-box; transform: rotate(3deg);"></span>
  <div style="display: flex; align-items: flex-start; gap: 14px;">
    <!-- back of a book with its barcode -->
    <svg aria-hidden="true" width="46" height="60" viewBox="0 0 46 60" style="flex-shrink: 0; transform: rotate(-6deg); overflow: visible;">
      <rect x="4" y="4" width="40" height="54" rx="4" fill="#1A1714"></rect>
      <rect x="1" y="1" width="40" height="54" rx="4" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.5"></rect>
      <rect x="7" y="30" width="28" height="19" rx="2" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.2"></rect>
      <path d="M10 33v10M12.5 33v10M14 33v10M17 33v10M19.5 33v10M21 33v10M24 33v10M26 33v10M28.5 33v10M31.5 33v10" stroke="#1A1714" stroke-width="1.2"></path>
      <path d="M7 10h22M7 15h16M7 20h20" stroke="#FFFAF1" stroke-width="2.4" stroke-linecap="round"></path>
    </svg>
    <div style="min-width: 0;">
      <h2 id="tip-title" style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.5px;">Tem o livro <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 26px; letter-spacing: -0.2px;">na mão?</span></h2>
      <p id="tip-body" style="margin: 6px 0 0; font-size: 14px; font-weight: 500; line-height: 1.45; color: #5B544B;">Aponte a câmera para o código de barras e ele entra na sua estante na hora.</p>
    </div>
  </div>
  <div style="margin-top: 16px; display: flex; gap: 10px;">
    <button style="flex: 1 1 0; height: 48px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 15px; font-weight: 800; color: #1A1714;">Entendi</button>
    <button style="flex: 1.35 1 0; height: 48px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 800; color: #F7F0E3;">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#FED170" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2M8 7v10M12 7v10M16 7v10"></path></svg>
      <span style="color: #F7F0E3;">Testar agora</span>
    </button>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `e13b.coach` — retângulo absoluto no canvas 390×844: **x=20, y=248.43, w=369, h=366.2**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e13b.coach.spotlight` | box | 286 | 7 | 76 | 76 | `position: absolute; left: 286px; top: -12px; width: 76px; height: 76px; border-radius: 50%; box-shadow: 0 0 0 1400px rgba(26,23,20,0.82); z-index: 5; pointer-events: none` |  |
| 2 | `e13b.coach.ring` | box | 279 | 0 | 90 | 90 | `position: absolute; left: 279px; top: -19px; width: 90px; height: 90px; border-radius: 50%; border: 2px dashed #FFFAF1; box-sizing: border-box; z-index: 6; pointer-events: none` |  |
| 3 | `e13b.coach.arrow` | icon | 0 | 19 | 350 | 140 | `position: absolute; left: 0; top: 0; z-index: 6; overflow: visible; pointer-events: none` |  |
| 4 | `e13b.coach.tag` ±1 | box+text | 92 | 81 | 93.2 | 38 | `position: absolute; left: 92px; top: 62px; z-index: 6; padding: 3px 14px 7px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 25px; line-height: 1; color: #1A1714; transform: rotate(-6deg); white-space: nowrap` | Instrument Serif itálico 25/25px peso 400 ls normal #1A1714 |
| 5 | `e13b.coach.card` | box | 0 | 165 | 350 | 201.2 | `position: absolute; left: 0; right: 0; top: 146px; z-index: 6; padding: 22px 18px 18px; border-radius: 24px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; transform: rotate(-1.5deg); box-sizing: border-box` |  |
| 6 | `e13b.coach.card.tape` | box | 136 | 153.5 | 78 | 24 | `position: absolute; left: 50%; top: -13px; width: 78px; height: 24px; margin-left: -39px; background: {{brand}} (padrão #B6ACE4); opacity: 0.85; border: 1.5px solid rgba(26,23,20,0.35); box-sizing: border-box; transform: rotate(3deg)` |  |
| 7 | `e13b.coach.card.row` | box | 19.5 | 188.5 | 311 | 94.2 | `display: flex; align-items: flex-start; gap: 14px` |  |
| 8 | `e13b.coach.card.art` | icon | 19.5 | 188.5 | 46 | 60 | `flex-shrink: 0; transform: rotate(-6deg); overflow: visible` |  |
| 9 | `e13b.coach.card.textBlock` | box | 79.5 | 188.5 | 251 | 94.2 | `min-width: 0` |  |
| 10 | `e13b.coach.card.title` | text | 79.5 | 188.5 | 251 | 27.3 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 22px; line-height: 1.05; letter-spacing: -0.5px` | Bricolage (opsz 22) 22/23.1px peso 800 ls -0.5px #1A1714 |
| 11 | `e13b.coach.card.title.serif` ±1 | inline | 194.41 | 185.25 | 80.66 | 33.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 26px; letter-spacing: -0.2px` | Instrument Serif itálico 26/27.3px peso 400 ls -0.2px #1A1714 |
| 12 | `e13b.coach.card.body` | text | 79.5 | 221.8 | 251 | 60.9 | `margin: 6px 0 0; font-size: 14px; font-weight: 500; line-height: 1.45; color: #5B544B` | Figtree 14/20.3px peso 500 ls normal #5B544B |
| 13 | `e13b.coach.card.actions` | box | 19.5 | 298.69 | 311 | 48 | `margin-top: 16px; display: flex; gap: 10px` |  |
| 14 | `e13b.coach.card.actions.dismiss` | box+text | 19.5 | 298.69 | 130.32 | 48 | `flex: 1 1 0; height: 48px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 15px; font-weight: 800; color: #1A1714` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 15 | `e13b.coach.card.actions.try` | box | 159.82 | 298.69 | 170.68 | 48 | `flex: 1.35 1 0; height: 48px; border-radius: 999px; background: #1A1714; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 800; color: #F7F0E3` |  |
| 16 | `e13b.coach.card.actions.try.icon` ±1 | icon | 188.57 | 313.69 | 18 | 18 | `—` |  |
| 17 | `e13b.coach.card.actions.try.label` ±1 | text | 214.57 | 313.69 | 87.18 | 18 | `color: #F7F0E3` | Figtree 15/normal peso 800 ls normal #F7F0E3 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `e13b.coach.tag`: caixa visual com `transform: rotate(-6deg)` = x 90.27, y 76.23, w 96.66, h 47.53 (relativa à seção).
- `e13b.coach.card`: caixa visual com `transform: rotate(-1.5deg)` = x -2.57, y 160.45, w 355.15, h 210.29 (relativa à seção).
- `e13b.coach.card.tape`: caixa visual com `transform: rotate(3deg)` = x 133.08, y 152.51, w 78.6, h 26.03 (relativa à seção).
- `e13b.coach.card.row`: caixa visual deslocada pelo transform de um ancestral = x 17.53, y 184.45, w 313.36, h 102.31 (relativa à seção).
- `e13b.coach.card.art`: caixa visual com `transform: rotate(-6deg)` = x 14.59, y 189.23, w 53.44, h 65.49 (relativa à seção).
- `e13b.coach.card.textBlock`: caixa visual deslocada pelo transform de um ancestral = x 77.51, y 184.45, w 253.38, h 100.74 (relativa à seção).
- `e13b.coach.card.title`: caixa visual deslocada pelo transform de um ancestral = x 77.51, y 184.45, w 251.63, h 33.86 (relativa à seção).
- `e13b.coach.card.title.serif`: caixa visual deslocada pelo transform de um ancestral = x 192.3, y 182.65, w 81.51, h 35.9 (relativa à seção).
- `e13b.coach.card.body`: caixa visual deslocada pelo transform de um ancestral = x 78.39, y 217.74, w 252.51, h 67.45 (relativa à seção).
- `e13b.coach.card.actions`: caixa visual deslocada pelo transform de um ancestral = x 20.42, y 294.61, w 312.15, h 56.12 (relativa à seção).
- `e13b.coach.card.actions.dismiss`: caixa visual deslocada pelo transform de um ancestral = x 20.42, y 299.34, w 131.53, h 51.4 (relativa à seção).
- `e13b.coach.card.actions.try`: caixa visual deslocada pelo transform de um ancestral = x 160.69, y 294.61, w 171.88, h 52.45 (relativa à seção).
- `e13b.coach.card.actions.try.icon`: caixa visual deslocada pelo transform de um ancestral = x 189.82, y 312.85, w 18.46, h 18.46 (relativa à seção).
- `e13b.coach.card.actions.try.label`: caixa visual deslocada pelo transform de um ancestral = x 215.81, y 310.36, w 87.62, h 20.28 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e13b.coach.tag` | 1 | é aqui! | 106.5 | 107.5 | 169.7 | 62.2 |
| `e13b.coach.card.title` *(composto)* | 1 | Tem o livro na mão? | 210.99 | 79.5 | 275.06 | 195.56 |
| `e13b.coach.card.body` | 1 | Aponte a câmera para o código de | 236.84 | 79.5 | 296.05 | 216.55 |
| `e13b.coach.card.body` | 2 | barras e ele entra na sua estante na | 257.14 | 79.5 | 300.94 | 221.44 |
| `e13b.coach.card.body` | 3 | hora. | 277.45 | 79.5 | 110.65 | 31.15 |
| `e13b.coach.card.actions.dismiss` | 1 | Entendi | 327.95 | 57.88 | 111.44 | 53.56 |
| `e13b.coach.card.actions.try.label` | 1 | Testar agora | 327.95 | 214.57 | 301.75 | 87.18 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Escuro: o círculo 76 em `left 286 · top −12` (relativo à busca) com `box-shadow: 0 0 0 1400px rgba(26,23,20,.82)`; o anel tracejado 90 (borda 2 `dashed #FFFAF1`) em volta.
2. Seta: SVG 350 × 140 com a curva e a ponta em creme (traço 2,6 e 2,8).
3. "é aqui!" em `left 92 · top 62`: pílula `#FED170`, padding 3/14/7, sombra 2/2, Instrument Serif itálico 25, girada −6°.
4. Bilhete em top 146: padding 22/18/18, raio 24, `#FFFAF1`, borda 1,5, sombra 4/4, girado −1,5°; a fita 78 × 24 `{{brand}}` a 0,85 em cima (girada 3°); o livro de costas 46 × 60 girado −6°, "Tem o livro" Bricolage 22/800 + "na mão?" Instrument Serif 26 e o texto 14/500; os botões de 48 (gap 10): Entendi (`flex 1`) e Testar agora (`flex 1,35`, preto, o ícone 18 amarelo).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O círculo de luz é um `CustomPainter` com recorte (nota do design), no lugar exato do botão do Scanner da 14: calcular pela posição real do botão (não fixa).
- A 360 o círculo, o anel e a seta passam do quadro (abaixo): a posição segue o botão.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_013b_onboarding_dica_scanner_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_013b_onboarding_dica_scanner_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `e13b.coach.spotlight` | sai do quadro (x) | 22 | 0 | **sim** | sim |  |
| 360 | `e13b.coach.spotlight` | passa do pai (x) | 42 | 12 | não | sim | pai `e13b.search` (vaza) |
| 360 | `e13b.coach.ring` | sai do quadro (x) | 29 | 0 | **sim** | sim |  |
| 360 | `e13b.coach.ring` | passa do pai (x) | 49 | 19 | não | sim | pai `e13b.search` (vaza) |
| 360 | `e13b.coach.arrow` | sai do quadro (x) | 10 | 0 | **sim** | sim |  |
| 360 | `e13b.coach.arrow` | passa do pai (x) | 30 | 0 | **sim** | sim | pai `e13b.search` (vaza) |

- A 360: fio de navalha em `e13b.coach.card.body` linha 2 «barras e ele entra na sua estante»: sobra 18.05 px · estouro com a próxima palavra 0.44 px.
- A 430: fio de navalha em `e13b.coach.card.body` linha 1 «Aponte a câmera para o código de barras e»: sobra 20.96 px · estouro com a próxima palavra 0.98 px.

## Diferenças em relação à prancha 14 (seções reutilizadas: waves, top, heading, lead, search, suggestions, continue)

Estas seções são as mesmas widgets da 14 (fases L14_1_busca, L14_2_sugestoes); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

Nenhuma diferença: todos os ids das seções reutilizadas são idênticos aos da 14.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e13b.coach.spotlight` |  |  | aria-hidden=true |
| `e13b.coach.ring` |  |  | aria-hidden=true |
| `e13b.coach.arrow` |  |  | aria-hidden=true |
| `e13b.coach.tag` |  |  | aria-hidden=true |
| `e13b.coach.card` | dialog |  | aria-modal=true, aria-labelledby=tip-title, aria-describedby=tip-body |
| `e13b.coach.card.tape` |  |  | aria-hidden=true |
| `e13b.coach.card.art` |  |  | aria-hidden=true |
| `e13b.coach.card.actions.try.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e13b.coach.spotlight` | NeoBox |  |
| `e13b.coach.ring` | CircleIconButton / NeoBox circular |  |
| `e13b.coach.arrow` | AppSvg(AppIllustrationsEntrada.setaCurvaDica, size: 350×140) |  |
| `e13b.coach.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: rotate(-6deg) |
| `e13b.coach.card` | NeoBox | Transform: rotate(-1.5deg) |
| `e13b.coach.card.tape` | NeoBox | Transform: rotate(3deg) |
| `e13b.coach.card.art` | AppSvg(AppIllustrationsEntrada.livroCodigoBarrasDica, size: 46×60) |  |
| `e13b.coach.card.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e13b.coach.card.actions.dismiss` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `e13b.coach.card.actions.try` | NeoBox |  |
| `e13b.coach.card.actions.try.icon` | AppSvg(AppIconsEntrada.scanBarcodeDica, size: 18) |  |

## Interações

- Aparece uma vez só, ao chegar no passo 3 (a flag fica salva no aparelho).
- Testar agora → o Scanner; Entendi → fecha e não mostra de novo; tocar fora do bilhete também fecha.
- `role=dialog` modal com título e texto ligados.

## Dados

- A flag "dica vista" no aparelho.

## Subfases

- **L13b.1** Escuro com o recorte no botão
- **L13b.2** Seta, "é aqui!" e o bilhete
- **L13b.3** Uma vez só (flag) e os toques
- **L13b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e13b.coach'), todos os ids de `kRef13b.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/013b_onboarding_dica_scanner_390x844@3x.png` no recorte da fase (y 240.43–627.17) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef13bw360` e `kRef13bw430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L13b.1 Escuro com o recorte no botão
- [ ] L13b.2 Seta, "é aqui!" e o bilhete
- [ ] L13b.3 Uma vez só (flag) e os toques
- [ ] L13b.4 Verificação + relatório
- [ ] Geometria 16/16 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
