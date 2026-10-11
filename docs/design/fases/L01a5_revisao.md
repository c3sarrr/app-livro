# FASE L01a5 — Início — cartão "Seus grifos de hoje" (revisão)

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a5_revisao@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a5_revisao_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/review_card.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Seção nova: cartão "Seus grifos de hoje" com a arte dos três cartões de grifo e o botão "Revisar". Aparece com a fixture e some com dados reais até a T05 (D-247).

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
```

## Especificação pixel a pixel

Seção `i01.review` — retângulo absoluto no canvas 390×2650: **x=20, y=1259.37, w=350, h=165.15**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.review` | box | 0 | 0 | 350 | 165.15 | `margin-top: 40px; padding: 16px; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 4px 4px 0 #1A1714; display: flex; align-items: center; gap: 14px` |  |
| 2 | `i01.review.art` | box | 17.5 | 26.58 | 104 | 112 | `position: relative; width: 104px; height: 112px; flex-shrink: 0` |  |
| 3 | `i01.review.art.card1` | box | 19.5 | 44.58 | 62 | 82 | `position: absolute; left: 2px; top: 18px; width: 62px; height: 82px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(-12deg); display: flex; flex-direction: column; gap: 5px` |  |
| 4 | `i01.review.art.card1.line0` | box | 29 | 56.08 | 38.7 | 5 | `height: 5px; width: 90%; border-radius: 3px; background: #ABCF82` |  |
| 5 | `i01.review.art.card1.line1` | box | 29 | 66.08 | 30.1 | 5 | `height: 5px; width: 70%; border-radius: 3px; background: #ABCF82` |  |
| 6 | `i01.review.art.card1.line2` | box | 29 | 76.08 | 35.26 | 5 | `height: 5px; width: 82%; border-radius: 3px; background: #E4DACA` |  |
| 7 | `i01.review.art.card1.line3` | box | 29 | 86.08 | 23.65 | 5 | `height: 5px; width: 55%; border-radius: 3px; background: #E4DACA` |  |
| 8 | `i01.review.art.card2` | box | 53.5 | 40.58 | 62 | 82 | `position: absolute; left: 36px; top: 14px; width: 62px; height: 82px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(8deg); display: flex; flex-direction: column; gap: 5px` |  |
| 9 | `i01.review.art.card2.line0` | box | 63 | 52.08 | 38.7 | 5 | `height: 5px; width: 90%; border-radius: 3px; background: #FFC1C6` |  |
| 10 | `i01.review.art.card2.line1` | box | 63 | 62.08 | 30.1 | 5 | `height: 5px; width: 70%; border-radius: 3px; background: #FFC1C6` |  |
| 11 | `i01.review.art.card2.line2` | box | 63 | 72.08 | 35.26 | 5 | `height: 5px; width: 82%; border-radius: 3px; background: #E4DACA` |  |
| 12 | `i01.review.art.card2.line3` | box | 63 | 82.08 | 23.65 | 5 | `height: 5px; width: 55%; border-radius: 3px; background: #E4DACA` |  |
| 13 | `i01.review.art.card3` | box | 35.5 | 32.58 | 66 | 90 | `position: absolute; left: 18px; top: 6px; width: 66px; height: 90px; padding: 10px 8px; border-radius: 10px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; transform: rotate(-2deg); display: flex; flex-direction: column; gap: 5px` |  |
| 14 | `i01.review.art.card3.line0` | box | 45 | 44.08 | 42.3 | 5 | `height: 5px; width: 90%; border-radius: 3px; background: #B6ACE4` |  |
| 15 | `i01.review.art.card3.line1` | box | 45 | 54.08 | 32.9 | 5 | `height: 5px; width: 70%; border-radius: 3px; background: #B6ACE4` |  |
| 16 | `i01.review.art.card3.line2` | box | 45 | 64.08 | 38.54 | 5 | `height: 5px; width: 82%; border-radius: 3px; background: #E4DACA` |  |
| 17 | `i01.review.art.card3.line3` | box | 45 | 74.08 | 25.85 | 5 | `height: 5px; width: 55%; border-radius: 3px; background: #E4DACA` |  |
| 18 | `i01.review.art.sparkle` | icon | 97.5 | 22.58 | 26 | 26 | `position: absolute; right: -2px; top: -4px` |  |
| 19 | `i01.review.textBlock` | box | 135.5 | 17.5 | 197 | 130.15 | `min-width: 0; flex-grow: 1; display: flex; flex-direction: column; gap: 4px` |  |
| 20 | `i01.review.kicker` | text | 135.5 | 17.5 | 197 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: 1px; color: #6F665B` | Figtree 11/normal peso 800→**800** ls 1px #6F665B |
| 21 | `i01.review.title` | text | 135.5 | 34.7 | 197 | 25.2 | `font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; line-height: 1.05; letter-spacing: -0.5px` | Bricolage (opsz 20) 20/21px peso 800 ls -0.5px #1A1714 |
| 22 | `i01.review.title.serif` ±1 | inline | 244.59 | 31.7 | 55.97 | 31.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 24px` | Instrument Serif itálico 24/25.2px peso 400 ls -0.5px #1A1714 |
| 23 | `i01.review.subtitle` | text | 135.5 | 63.9 | 197 | 33.75 | `font-size: 12.5px; font-weight: 600; line-height: 1.35; color: #5B544B` | Figtree 12.5/16.875px peso 600 ls normal #5B544B |
| 24 | `i01.review.cta` ±1 | box | 135.5 | 107.65 | 97.22 | 40 | `margin-top: 6px; align-self: flex-start; height: 40px; padding: 0 16px 0 12px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800` |  |
| 25 | `i01.review.cta.icon` | icon | 147.5 | 120.15 | 15 | 15 | `—` |  |
| 26 | `i01.review.cta.label` ±1 | text | 169.5 | 119.25 | 47.22 | 16.8 | `color: #F7F0E3` | Figtree 14/normal peso 800→**800** ls normal #F7F0E3 |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `i01.review.art.card1`: caixa visual com `transform: rotate(-12deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card1.line0`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card1.line1`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card1.line2`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card1.line3`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card2`: caixa visual com `transform: rotate(8deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card2.line0`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card2.line1`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card2.line2`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card2.line3`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card3`: caixa visual com `transform: rotate(-2deg)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card3.line0`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card3.line1`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card3.line2`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `i01.review.art.card3.line3`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.review.kicker` | 1 | REVISÃO · 5 GRIFOS · 2 MIN | 27.95 | 135.5 | 304.56 | 169.06 |
| `i01.review.title` *(composto)* | 1 | Seus grifos de hoje | 55.46 | 135.5 | 300.56 | 165.06 |
| `i01.review.subtitle` | 1 | De Dom Casmurro, Quincas Borba | 76.71 | 135.5 | 328.15 | 192.65 |
| `i01.review.subtitle` | 2 | e Iracema. | 93.58 | 135.5 | 193.95 | 58.45 |
| `i01.review.cta.label` | 1 | Revisar | 132.55 | 169.5 | 216.72 | 47.22 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cartão `#FFFAF1`, borda 1,5, raio 28, sombra 4/4, padding 16, linha (gap 14) alinhada ao centro → 350 × 165,15.
2. Arte 104 × 112: três cartõezinhos (62 × 82, 62 × 82 e 66 × 90; raio 10, borda 1,5, sombra 2/2, padding 10/8, gap 5) girados −12°, +8° e −2° (ordem de pintura: verde, rosa, lavanda por cima); em cada um, 4 traços de 5 (raio 3) em 90/70/82/55 % — os dois primeiros na cor do grifo (`#ABCF82`, `#FFC1C6`, `#B6ACE4`), os outros `#E4DACA` (cor nova). Brilho amarelo 26 (`ic_sparkle_amarelo`) em `right −2 · top −4`.
3. Texto (gap 4): "REVISÃO · 5 GRIFOS · 2 MIN" Figtree 11/800 (→ 700) ls 1 `#6F665B`; "Seus grifos" Bricolage 20/800 `lh 1,05` ls −0,5 + "de hoje" Instrument Serif itálico 24; "De Dom Casmurro, Quincas Borba / e Iracema." Figtree 12,5/600 `lh 1,35` `#5B544B` (2 linhas).
4. "Revisar": pílula preta 40 (6 acima), padding 0/16/0/12, brilho amarelo 15 (`ic_sparkle_solid_amarelo`) + Figtree 14/800 (→ 700) `#F7F0E3`.
5. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.review` |  | Seus grifos de hoje |  |
| `i01.review.art` |  |  | aria-hidden=true |
| `i01.review.cta.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.review` | NeoBox |  |
| `i01.review.art.card1` | NeoBox | Transform: rotate(-12deg) |
| `i01.review.art.card1.line0` | NeoBox |  |
| `i01.review.art.card1.line1` | NeoBox |  |
| `i01.review.art.card1.line2` | NeoBox |  |
| `i01.review.art.card1.line3` | NeoBox |  |
| `i01.review.art.card2` | NeoBox | Transform: rotate(8deg) |
| `i01.review.art.card2.line0` | NeoBox |  |
| `i01.review.art.card2.line1` | NeoBox |  |
| `i01.review.art.card2.line2` | NeoBox |  |
| `i01.review.art.card2.line3` | NeoBox |  |
| `i01.review.art.card3` | NeoBox | Transform: rotate(-2deg) |
| `i01.review.art.card3.line0` | NeoBox |  |
| `i01.review.art.card3.line1` | NeoBox |  |
| `i01.review.art.card3.line2` | NeoBox |  |
| `i01.review.art.card3.line3` | NeoBox |  |
| `i01.review.art.sparkle` | AppSvg(AppIconsInicio.ic_sparkle_amarelo, size: 26) |  |
| `i01.review.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `i01.review.cta` | NeoBox |  |
| `i01.review.cta.icon` | AppSvg(AppIconsInicio.ic_sparkle_solid_amarelo, size: 15) |  |

## Interações

- "Revisar" e o cartão → sem ação (D-243 b): o elemento fica idêntico à prancha, o toque não faz nada, um teste documenta e o item entra em `docs/design/estados_sem_design.md` até a T05 (rota `/revisao`).

## Dados

- D-247: com a fixture `t01` (testes de fidelidade) o cartão aparece; com dados reais some até a T05. "5 grifos · 2 min" e os livros do subtítulo vêm do baralho do dia (T05).

## Subfases

- **L01a5.1** Cartão e arte dos três cartões (giros)
- **L01a5.2** Textos e "Revisar"
- **L01a5.3** Regra D-247 (fixture × dados reais)
- **L01a5.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.review'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 1251.37–1432.52) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a5.1 Cartão e arte dos três cartões (giros)
- [ ] L01a5.2 Textos e "Revisar"
- [ ] L01a5.3 Regra D-247 (fixture × dados reais)
- [ ] L01a5.4 Verificação + relatório
- [ ] Geometria 25/25 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
