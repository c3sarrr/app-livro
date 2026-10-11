# F11 — Autorrevisão visual (prompt mestre §8, passo 4)

Imagens em `build/visual_diff/F11/` (local, não versionadas). Comparei o recorte `secoes/F11_nav_fade@3x.png`, o `redline` e o golden do
Flutter lado a lado (`F11_nav_fade_secao_golden_redline.png`), percorrendo a tabela da fase linha por linha, e o viewport 390×844 contra a derivada.

## Canvas — faixa `0,2230,390,160` (`F11_nav_fade`)

| Região (logica) | px @3x | ≠ 0 | > 8 | > 64 | max |
|---|---:|---:|---:|---:|---:|
| faixa inteira (0, 2230, 390, 160) | 561.600 | 11.167 | 5.982 | 76 | 99 |
| fade sem nada por cima (0, 2230, 390, 39,5) | 138.060 | **0** | 0 | 0 | 0 |
| fade nas laterais da barra (0…16) | 23.040 | **0** | 0 | 0 | 0 |
| fade abaixo da barra (y 2364…2390) | 91.260 | **0** | 0 | 0 | 0 |
| barra (16, 2290, 358, 74) | 238.428 | 10.562 | 5.648 | 76 | 99 |
| FAB (165, 2269,5, 60, 64) | 34.560 | 1.969 | 1.065 | 1 | 66 |
| item ativo (25,5, 2299,5, 64,6, 51) | 29.682 | 1.925 | 1.267 | 37 | 99 |
| rótulos (y 2330…2351) | 51.030 | 2.784 | 2.065 | 33 | 99 |

O fade é **idêntico** à referência (0 pixels diferentes), inclusive dentro da rampa: papel com alpha sobre papel dá exatamente `[247 240 227]`.
Só 76 dos 561.600 pixels da faixa (0,014 %) passam de 64, todos em arestas de glifo e de arco.

### Tabela da fase, linha por linha (lado a lado + redline + recortes ampliados)
1. `bottomFade` — gradiente invisível sobre o papel, como na referência; nada a ver no recorte além do papel contínuo (confirmado por 0 pixels).
2. `nav` — contorno, borda 1,5, raio 28 e sombra (0,4) só para baixo: coincidem; o canto esquerdo (`zoom_canto_esq.png`) sem diferença de forma.
3. `nav.home` — pílula lavanda, borda 1,5, raio 20: forma e cor iguais (`zoom_home_item.png`).
4. `nav.home.icon` — casa com miolo `#FFFAF1` e traço 1,8: igual.
5. `nav.home.label` — "Início" 700: mesma posição e peso; só o contorno do glifo difere (hinting).
6–8. `nav.library` (+ ícone dos três livros, rótulo "Biblioteca" 600 `#5B544B`): iguais.
9–12. `nav.scanner`: item sem fundo; FAB `#FED170` com borda e sombra; ícone de código de barras; rótulo "Scanner" 700 mais baixo (alinhado ao fundo, `padding-bottom 2`):
   iguais (`zoom_fab.png`: dois anéis finos de 1 px na borda e a meia-lua da sombra = suavização; formas e cores idênticas).
13–18. `nav.clubs` e `nav.profile` (ícone e rótulo): iguais.
Ordem de pintura: o FAB cobre a borda superior da barra e o rótulo "Scanner" fica abaixo do círculo, como no arquivo.

### O que sobra é rasterização
O heatmap e os recortes mostram só contornos de 1 px: bordas e arcos (suavização do Skia × Chromium) e as arestas dos glifos Figtree 11/12 (o mesmo −1 px físico
de hinting documentado desde "Para você"). Nenhuma diferença de forma, posição, cor, espessura, ordem de pintura ou recorte.

## Viewport 390×844 (safe 47/34) × `inicio_viewport_390x844_DERIVADA@3x.png`
- Inteiro (`0,0,390,844`): `blur_mismatch_%` 0,0 · raw 0,5499 · mean_abs 0,648 · max 221 → PASSOU. Faixa inferior (`0,694,390,150`): 0,0 · raw 0,1502 → PASSOU.
- Lado a lado: cabeçalho em y 62, hero, "Também lendo" e a barra com o FAB sobrepondo os cards, na mesma posição da derivada; os 47 px superiores só papel.
- Heatmap: o mesmo resíduo uniforme de borda em toda a tela; a barra e o FAB não são mais claros que o resto.

## Não-regressão
- `--layout` com as 10 seções: F03–F10 repetem os números da F10 (`header` 0,4113 · `headline` 1,3126 · `hero` 0,6195 · `alsoReading` 0,8922 ·
  `today` 1,3001 · `forYou` 2,1986 · `club` 2,2549 · `recent` 0,8938); `bottomFade` 0,1288 e `nav` 0,2545 passam (`blur` 0,0 em todas).
- Golden da F11 × golden aprovado da F10: **0 pixels diferentes acima de y 2240**; as 240.446 diferenças ficam em y 2269,3…2364 / x 16…374 (barra + FAB + sombra).

## Achados da autorrevisão
- **Teste da F05 ajustado:** `style_hero_test` ("Tema: cada opção de brand …") assertava que o `brand` só muda o cartão. A F11 exige que o item ativo da barra siga o `brand`
  junto com o hero, então 21.511 pixels da pílula passaram a mudar. O teste agora admite mudança só no cartão **e** no retângulo `nav.home` (0 pixels fora dos dois) e prova
  que o preenchimento da pílula acompanha o hero.
- **Teste da F02 ajustado:** `geometry_shell_test` ("camadas na ordem do HTML") assertava os 3 placeholders (`SizedBox`); passou a assertar as 4 camadas reais
  (conteúdo → `BottomFade` em `IgnorePointer` → `FloatingNavBar` → `ScannerFab`), as posições `Positioned` e as Keys. A F11 diz que substitui os placeholders.
- **Toque no centro do item "Scanner":** o centro do item cai sob o FAB (que pinta por cima); o toque ali é do FAB e o do rótulo é do item — mesma ação, uma única chamada.
- **Cantos do FAB fora do círculo:** o retângulo 60×60 do `Pressable` é opaco, então os quatro cantos fora da curva também tocam o scanner (no navegador a área fora do raio não recebe
  o toque). É o mesmo tema da capa da F06 e do CTA da F09; fica para a F12, não alterado aqui.
