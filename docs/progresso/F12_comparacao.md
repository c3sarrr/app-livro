# F12 — Autorrevisão (prompt mestre §8, passo 4)

A F12 não acrescenta nenhuma seção nem muda o estado de repouso: a "comparação" é (1) provar que o repouso continua pixel-idêntico ao aprovado na F11 e
(2) inspecionar o que é novo (seletor de tema, variantes de tema) e a árvore semântica. Imagens locais em `build/visual_diff/F12/` e nos goldens de `test/golden/goldens/`.

## 1. Repouso idêntico ao golden aprovado na F11 (passo 0 do §7)
- `flutter test test/home/golden_canvas_test.dart test/home/golden_viewport_test.dart` **sem** `--update-goldens`: passou.
- `sha256` dos dois PNGs, antes e depois da fase, idênticos:
  `inicio_canvas@3x.png` fdf4a823…c31743 · `inicio_viewport@3x.png` 35ba1eb8…5948a3 (os PNGs nem foram regravados).
- `compare_images.py --layout` (10 regiões) e as faixas do canvas/viewport: **os mesmos números da F11** (header 0,4113 · headline 1,3126 · hero 0,6195 · alsoReading 0,8922 ·
  today 1,3001 · forYou 2,1986 · club 2,2549 · recent 0,8938 · bottomFade 0,1288 · nav 0,2545 · viewport 0,5499; `blur_mismatch_%` 0,0 em todas) — `F12_verificacao.txt`.

## 2. As `RepaintBoundary`: medi uma a uma e só mantive as que não mexem em pixel
O arquivo da fase pede boundaries em "dial, gráfico semanal, cada capa, carrossel" **e** o golden idêntico. As duas exigências conflitam: com todas ligadas o golden do canvas
**falha** (178 pixels de 8,4 M, diferença máxima 12/255). Para saber quem é o culpado liguei cada boundary sozinha (interruptor temporário por `--dart-define`) e comparei o canvas
com o golden aprovado:

| Só esta boundary ligada | pixels ≠ golden | Δ máx. (de 255) | Onde |
|---|---:|---:|---|
| nenhuma | **0** | 0 | — |
| **dial** (`today.dial`) | **0** | 0 | — |
| **carrossel** (`forYou.carousel`) | **0** | 0 | — |
| capa do hero (rotacionada −3°) | 3 | 2 | contorno da capa |
| 2 capas de "Também lendo" (rotacionadas) | 34 | 12 | contorno das capas |
| 3 capas de "Para você" (sem rotação) | 12 | 4 | elipse/arco da arte |
| 3 mini-capas de "Recém-chegados" | 89 | 6 | arcos/anéis das artes |
| gráfico semanal (`today.week.chart`) | 40 | 6 | topo arredondado das barras |
| todas juntas | 178 | 12 | soma das linhas acima |

Os pixels diferentes estão só em **bordas curvas** (elipses, arcos, cantos), com Δ de 1 a 12 em 255: é ruído de arredondamento de ponto flutuante do Skia ao rasterizar a figura numa
camada própria numa posição vertical fracionária (ex.: capas em y 1316,2). Não é mudança de forma, cor ou posição, e some na prática — mas o critério da fase é "idêntico", então
**mantive só dial e carrossel** (provadas neutras) e não afrouxei golden nem tolerância. As outras seis ficam como decisão sua (relatório, "Decisões para você").

## 3. O que é novo e foi inspecionado
- **Seletor de tema da galeria `/_ds`** (`ds_tema_seletor@3x.png`): "Tema (D-11)", linha `brand` e linha `weekColor`, 4 amostras cada com o hex embaixo; a opção ativa tem borda 3 (as
  duas padrão `#B6ACE4` no estado inicial). Legível, sem corte, sem estourar a largura de 390.
- **Variantes de tema** (12 recortes `inicio_brand_*` e `inicio_weekcolor_*`): olhei `brand #ABCF82` (hero verde; capa, brilhos, barra de progresso e botões intactos), `brand #FFC1C6`
  (a pílula do Início rosa; ícone, rótulo e o resto da barra intactos) e `weekColor #F2A815` (barras 0–5 em âmbar; a de "Hoje" continua `#FF552E`; hachura, linha da meta e rótulos iguais).
  Em todas as 8 opções: **0 pixels diferentes do golden padrão fora das regiões esperadas**; a opção padrão reproduz o golden com 0 diferenças.
  - brand: 498.726–498.744 px no hero + 21.511–21.515 px na pílula mudam (520.237–520.259 no total); weekColor: 10.014–10.023 / 14.764–14.771 / 9.171–9.179 / 6.442–6.461 /
    12.241–12.247 / 18.392–18.398 px nas barras 0–5 (≈ 71.0 mil no total) e 0 na barra de hoje.

## 4. Árvore semântica da tela inteira
Dump da árvore real (canvas) conferido contra a lista da F12: as 7 seções, os 7 cabeçalhos (h1/h2/h3 com os níveis do HTML), os 18 rótulos próprios, o `selected` só no Início e
**nada** decorativo (brilhos, círculos, desenho do dial, linha da meta, entalhes, perfuração, fade, FAB, ícones). O "18" e o "de 30 min" do dial continuam legíveis.
Diretrizes: iOS 44×44 e rótulos passam; contraste passa (tema padrão e as 7 outras opções); **Android 48×48 reprova só os 3 botões "Mais opções"** (44×44 no arquivo).

## 5. Achados da autorrevisão
- **`main()` agora espera o pré-cache dos SVGs** (E/S real): o teste de `main()` da F02 (`app_test.dart`) passou a rodar `main` dentro de `tester.runAsync` e a provar que os 18 SVGs ficam em cache.
- **`HomeScreen` virou `ConsumerWidget`** (só para ler o id do snapshot no momento do toque, sem assistir nada): a rota `/_ds` agora monta `DesignSystemScreen` (seletor + galeria) —
  o teste `router_test` continua achando `DesignSystemGallery` dentro dela.
- **Travessia do leitor de tela × ordem do HTML:** 14 posições diferentes entre as 77 rotuladas (hero, "Seu dia", clube — o que já estava registrado desde a F09). Não alterado (decisão sua).
- **Toque nas partes que vazam / cantos fora da curva:** a capa de "Também lendo" acima do card não é tocável; os cantos fora do círculo do FAB e das pílulas do CTA são. Não alterado (decisão sua).
