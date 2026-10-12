# FASE L03 — Scanner — a câmera congelada no verso do livro, a moldura, o código lido e o chip "Código lido"

> Tela 03 · prancha `003_scanner_encontrado` (03 · Scanner — livro encontrado, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L03_1_camera@3x.png` · `docs/design/medicao/projeto/png/redline/L03_1_camera_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/003_scanner_encontrado_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_003_scanner_encontrado.json` · `test/reference/projeto/reference_layout_003_scanner_encontrado.dart` (`kRef03`).
> Arquivos sugeridos: `lib/features/scanner/presentation/scanner_screen.dart`, `lib/features/scanner/presentation/scanner_camera.dart`, `lib/features/scanner/presentation/scanner_frame.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Scanner com o livro encontrado (03): a câmera parada no quadro em que o código foi lido (o verso coral do Brás Cubas com a etiqueta do ISBN), o escuro fora da moldura, o contorno amarelo no código lido com o selo de visto, os cantos da mira e o chip "Código lido".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- Camera preview (frozen on the frame where the code was read) -->
<div aria-hidden="true" style="position: absolute; inset: 0; overflow: hidden; background: radial-gradient(120% 75% at 50% 32%, #4A413A 0%, #2B2521 55%, #191512 100%);">
  <!-- Back cover of the physical book -->
  <div style="position: absolute; left: -64px; top: 26px; width: 430px; height: 560px; transform: rotate(-5deg); border-radius: 6px; background: linear-gradient(160deg, #FF6C47 0%, #FF552E 48%, #DB431F 100%); box-shadow: 0 30px 60px rgba(0,0,0,0.45); overflow: hidden;">
    <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 22px; background: rgba(0,0,0,0.18);"></div>
    <div style="position: absolute; left: 96px; top: 56px; width: 250px; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 21px; line-height: 1.12; color: #1A1714; opacity: 0.55; filter: blur(1.6px);">“Ao verme que primeiro roeu as frias carnes do meu cadáver dedico como saudosa lembrança estas memórias póstumas.”</div>
    <div style="position: absolute; left: 96px; top: 196px; font-size: 9px; font-weight: 800; letter-spacing: 0.18em; color: #1A1714; opacity: 0.5; filter: blur(1.2px);">MACHADO DE ASSIS</div>
    <div style="position: absolute; left: 96px; top: 470px; width: 44px; height: 44px; border-radius: 50%; border: 2px solid #1A1714; opacity: 0.5; filter: blur(1.2px);"></div>
  </div>
  <!-- Barcode label on the back cover -->
  <div style="position: absolute; left: 97px; top: 210px; width: 196px; height: 104px; box-sizing: border-box; padding: 8px 8px 0; border-radius: 4px; background: #FFFDF8; transform: rotate(-5deg); display: flex; flex-direction: column; align-items: center; gap: 3px;">
    <span style="font-size: 8.5px; font-weight: 700; letter-spacing: 0.06em; color: #1A1714;">ISBN 978-65-5921-104-3</span>
    <svg width="180" height="70" viewBox="0 0 179.5 70" fill="#1A1714" font-family="Figtree, sans-serif" aria-hidden="true"><rect x="12.0" y="0" width="1.7" height="63"></rect><rect x="15.4" y="0" width="1.7" height="63"></rect><rect x="18.8" y="0" width="5.1" height="56"></rect><rect x="25.6" y="0" width="3.4" height="56"></rect><rect x="34.1" y="0" width="1.7" height="56"></rect><rect x="39.2" y="0" width="1.7" height="56"></rect><rect x="47.7" y="0" width="1.7" height="56"></rect><rect x="51.1" y="0" width="1.7" height="56"></rect><rect x="54.5" y="0" width="3.4" height="56"></rect><rect x="63.0" y="0" width="1.7" height="56"></rect><rect x="66.4" y="0" width="5.1" height="56"></rect><rect x="74.9" y="0" width="1.7" height="56"></rect><rect x="81.7" y="0" width="1.7" height="56"></rect><rect x="85.1" y="0" width="3.4" height="56"></rect><rect x="90.2" y="0" width="1.7" height="63"></rect><rect x="93.6" y="0" width="1.7" height="63"></rect><rect x="97.0" y="0" width="3.4" height="56"></rect><rect x="102.1" y="0" width="3.4" height="56"></rect><rect x="108.9" y="0" width="3.4" height="56"></rect><rect x="115.7" y="0" width="3.4" height="56"></rect><rect x="120.8" y="0" width="3.4" height="56"></rect><rect x="127.6" y="0" width="3.4" height="56"></rect><rect x="132.7" y="0" width="5.1" height="56"></rect><rect x="141.2" y="0" width="1.7" height="56"></rect><rect x="144.6" y="0" width="1.7" height="56"></rect><rect x="148.0" y="0" width="5.1" height="56"></rect><rect x="156.5" y="0" width="1.7" height="56"></rect><rect x="165.0" y="0" width="1.7" height="56"></rect><rect x="168.4" y="0" width="1.7" height="63"></rect><rect x="171.8" y="0" width="1.7" height="63"></rect><text x="4" y="67" font-size="11" font-weight="600">9</text><text x="52.8" y="67" font-size="11" font-weight="600" text-anchor="middle" letter-spacing="1.2">786559</text><text x="132.7" y="67" font-size="11" font-weight="600" text-anchor="middle" letter-spacing="1.2">211043</text></svg>
  </div>
</div>

<!-- Dim everything outside the viewfinder -->
<div aria-hidden="true" style="position: absolute; left: 55px; top: 181px; width: 280px; height: 160px; border-radius: 22px; box-shadow: 0 0 0 1200px rgba(20,17,15,0.58);"></div>

<!-- Detected code highlight (follows the barcode) -->
<div aria-hidden="true" style="position: absolute; left: 92px; top: 205px; width: 206px; height: 114px; box-sizing: border-box; border-radius: 10px; border: 3px solid {{reticle}}; box-shadow: 0 0 0 1.5px #1A1714, inset 0 0 0 1.5px #1A1714; transform: rotate(-5deg);">
  <span style="position: absolute; top: -14px; right: -14px; width: 28px; height: 28px; border-radius: 50%; background: {{reticle}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
  </span>
</div>

<!-- Viewfinder corners -->
<svg aria-hidden="true" width="290" height="170" viewBox="0 0 290 170" fill="none" stroke-linecap="round" style="position: absolute; left: 50px; top: 176px;">
  <path d="M5 45V27A22 22 0 0 1 27 5H45M245 5H263A22 22 0 0 1 285 27V45M285 125V143A22 22 0 0 1 263 165H245M45 165H27A22 22 0 0 1 5 143V125" stroke="#1A1714" stroke-width="10"></path>
  <path d="M5 45V27A22 22 0 0 1 27 5H45M245 5H263A22 22 0 0 1 285 27V45M285 125V143A22 22 0 0 1 263 165H245M45 165H27A22 22 0 0 1 5 143V125" stroke="{{reticle}}" stroke-width="5.5"></path>
</svg>

<!-- Feedback chip (label + icon, never colour alone) -->
<div role="status" style="position: absolute; left: 0; right: 0; top: 126px; display: flex; justify-content: center;">
  <span style="height: 36px; padding: 0 14px 0 6px; box-sizing: border-box; display: flex; align-items: center; gap: 8px; border-radius: 999px; background: {{reticle}}; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; font-size: 14px; font-weight: 800;">
    <span style="width: 24px; height: 24px; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center;">
      <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#FED170" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>
    </span>
    Código lido
  </span>
</div>
```

## Especificação pixel a pixel

Seção `sc03.camera` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc03.camera` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; overflow: hidden; background: radial-gradient(120% 75% at 50% 32%, #4A413A 0%, #2B2521 55%, #191512 100%)` |  |
| 2 | `sc03.camera.book` | box | -64 | 26 | 430 | 560 | `position: absolute; left: -64px; top: 26px; width: 430px; height: 560px; transform: rotate(-5deg); border-radius: 6px; background: linear-gradient(160deg, #FF6C47 0%, #FF552E 48%, #DB431F 100%); box-shadow: 0 30px 60px rgba(0,0,0,0.45); overflow: hidden` |  |
| 3 | `sc03.camera.book.spine` | box | -64 | 26 | 22 | 560 | `position: absolute; left: 0; top: 0; bottom: 0; width: 22px; background: rgba(0,0,0,0.18)` |  |
| 4 | `sc03.camera.book.quote` | text | 32 | 82 | 250 | 94.08 | `position: absolute; left: 96px; top: 56px; width: 250px; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 21px; line-height: 1.12; color: #1A1714; opacity: 0.55; filter: blur(1.6px)` | Instrument Serif itálico 21/23.52px peso 400 ls normal #1A1714 |
| 5 | `sc03.camera.book.author` ±1 | text | 32 | 222 | 114.75 | 10.8 | `position: absolute; left: 96px; top: 196px; font-size: 9px; font-weight: 800; letter-spacing: 0.18em; color: #1A1714; opacity: 0.5; filter: blur(1.2px)` | Figtree 9/normal peso 800 ls 1.62px #1A1714 |
| 6 | `sc03.camera.book.ring` | box | 32 | 496 | 48 | 48 | `position: absolute; left: 96px; top: 470px; width: 44px; height: 44px; border-radius: 50%; border: 2px solid #1A1714; opacity: 0.5; filter: blur(1.2px)` |  |
| 7 | `sc03.camera.label` | box | 97 | 210 | 196 | 104 | `position: absolute; left: 97px; top: 210px; width: 196px; height: 104px; box-sizing: border-box; padding: 8px 8px 0; border-radius: 4px; background: #FFFDF8; transform: rotate(-5deg); display: flex; flex-direction: column; align-items: center; gap: 3px` |  |
| 8 | `sc03.camera.label.isbn` ±1 | text | 140.6 | 218 | 108.81 | 10.21 | `font-size: 8.5px; font-weight: 700; letter-spacing: 0.06em; color: #1A1714` | Figtree 8.5/normal peso 700 ls 0.51px #1A1714 |
| 9 | `sc03.camera.label.barcode` | icon | 105 | 231.21 | 180 | 70 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `sc03.camera.book`: caixa visual com `transform: rotate(-5deg)` = x -87.58, y 8.33, w 477.17, h 595.35 (relativa à seção).
- `sc03.camera.book.spine`: caixa visual deslocada pelo transform de um ancestral = x -87.58, y 43.89, w 70.72, h 559.79 (relativa à seção).
- `sc03.camera.book.quote`: caixa visual deslocada pelo transform de um ancestral = x 12.93, y 71.44, w 257.25, h 115.51 (relativa à seção).
- `sc03.camera.book.author`: caixa visual deslocada pelo transform de um ancestral = x 25.13, y 222.69, w 115.25, h 20.76 (relativa à seção).
- `sc03.camera.book.ring`: caixa visual deslocada pelo transform de um ancestral = x 49.01, y 501.46, w 52, h 52 (relativa à seção).
- `sc03.camera.label`: caixa visual com `transform: rotate(-5deg)` = x 92.84, y 201.66, w 204.32, h 120.69 (relativa à seção).
- `sc03.camera.label.isbn`: caixa visual deslocada pelo transform de um ancestral = x 136.97, y 213.43, w 109.28, h 19.65 (relativa à seção).
- `sc03.camera.label.barcode`: caixa visual deslocada pelo transform de um ancestral = x 102.66, y 223.48, w 185.42, h 85.42 (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc03.camera.book.quote` | 1 | “Ao verme que primeiro roeu as | 100.9 | 32 | 264.64 | 232.64 |
| `sc03.camera.book.quote` | 2 | frias carnes do meu cadáver | 124.42 | 32 | 244.67 | 212.67 |
| `sc03.camera.book.quote` | 3 | dedico como saudosa lembrança | 147.94 | 32 | 276.96 | 244.96 |
| `sc03.camera.book.quote` | 4 | estas memórias póstumas.” | 171.46 | 32 | 234.73 | 202.73 |
| `sc03.camera.book.author` | 1 | MACHADO DE ASSIS | 230.55 | 32 | 146.75 | 114.75 |
| `sc03.camera.label.isbn` | 1 | ISBN 978-65-5921-104-3 | 226.08 | 140.6 | 249.4 | 108.8 |

Seção `sc03.dim` — retângulo absoluto no canvas 390×844: **x=55, y=181, w=280, h=160**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 10 | `sc03.dim` | box | 0 | 0 | 280 | 160 | `position: absolute; left: 55px; top: 181px; width: 280px; height: 160px; border-radius: 22px; box-shadow: 0 0 0 1200px rgba(20,17,15,0.58)` |  |

Seção `sc03.detected` — retângulo absoluto no canvas 390×844: **x=92, y=205, w=206, h=114**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 11 | `sc03.detected` | box | 0 | 0 | 206 | 114 | `position: absolute; left: 92px; top: 205px; width: 206px; height: 114px; box-sizing: border-box; border-radius: 10px; border: 3px solid {{reticle}} (padrão #FED170); box-shadow: 0 0 0 1.5px #1A1714, inset 0 0 0 1.5px #1A1714; transform: rotate(-5deg)` |  |
| 12 | `sc03.detected.badge` | box | 189 | -11 | 28 | 28 | `position: absolute; top: -14px; right: -14px; width: 28px; height: 28px; border-radius: 50%; background: {{reticle}} (padrão #FED170); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 13 | `sc03.detected.badge.icon` | icon | 195.5 | -4.5 | 15 | 15 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `sc03.detected`: caixa visual com `transform: rotate(-5deg)` = x -4.58, y -8.76, w 215.15, h 131.52 (relativa à seção).
- `sc03.detected.badge`: caixa visual deslocada pelo transform de um ancestral = x 182.75, y -20.68, w 30.33, h 30.33 (relativa à seção).
- `sc03.detected.badge.icon`: caixa visual deslocada pelo transform de um ancestral = x 189.79, y -13.63, w 16.25, h 16.25 (relativa à seção).

Seção `sc03.corners` — retângulo absoluto no canvas 390×844: **x=50, y=176, w=290, h=170**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 14 | `sc03.corners` | icon | 0 | 0 | 290 | 170 | `position: absolute; left: 50px; top: 176px` |  |

Seção `sc03.status` — retângulo absoluto no canvas 390×844: **x=0, y=126, w=390, h=36**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 15 | `sc03.status` | box | 0 | 0 | 390 | 36 | `position: absolute; left: 0; right: 0; top: 126px; display: flex; justify-content: center` |  |
| 16 | `sc03.status.chip` ±1 | box+text | 130.22 | 0 | 129.55 | 36 | `height: 36px; padding: 0 14px 0 6px; box-sizing: border-box; display: flex; align-items: center; gap: 8px; border-radius: 999px; background: {{reticle}} (padrão #FED170); border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 17 | `sc03.status.chip.badge` ±1 | box | 137.72 | 6 | 24 | 24 | `width: 24px; height: 24px; border-radius: 50%; background: #1A1714; display: flex; align-items: center; justify-content: center` |  |
| 18 | `sc03.status.chip.badge.icon` ±1 | icon | 143.22 | 11.5 | 13 | 13 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc03.status.chip` | 1 | Código lido | 22.9 | 169.72 | 244.28 | 74.56 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A câmera da prancha é cena: fundo `radial-gradient(120% 75% at 50% 32%, #4A413A, #2B2521 55%, #191512)`, o verso do livro 430 × 560 girado −5° com degradê coral e sombra `0 30 60 rgba(0,0,0,.45)`, o texto desfocado (`filter: blur`) e a etiqueta do ISBN 196 × 104. No app tudo isso é a imagem da câmera ao vivo (o mapa de widgets: fica só como referência da fixture).
2. Escuro fora da moldura: a caixa 280 × 160 em `left 55 · top 181`, raio 22, com `box-shadow: 0 0 0 1200px rgba(20,17,15,.58)` — no app, `ClipPath` invertido (a moldura arredondada fora) com a camada a 58 % (a nota do design fala em 45 % e desfoque de 6 fora da moldura: a prancha não desfoca — pergunta da T15).
3. Código lido: o contorno 206 × 114 em `left 92 · top 205`, raio 10, borda 3 `{{reticle}}` com o filete preto de 1,5 por fora e por dentro (duas sombras), girado −5° como o código; o selo 28 `{{reticle}}` com o visto 15 (traço 3,2) em `top/right −14`.
4. Cantos: SVG 290 × 170 em `left 50 · top 176` (`miraScanner`): os 4 cantos de raio 22, traço preto 10 e, por cima, traço `{{reticle}}` 5,5, pontas redondas.
5. Chip "Código lido" centrado em top 126: 36 de altura, padding 0/14/0/6, gap 8, `{{reticle}}`, borda 1,5, sombra 2/2, 14/800, com o círculo preto 24 e o visto 13 `#FED170` (`role=status`: texto e ícone, nunca só a cor).
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O contorno e o selo giram −5° (como o código na cena): no app o contorno segue o retângulo do código detectado pelo leitor (a posição e o ângulo reais), não um giro fixo.
- `{{reticle}}` é cor de estado: amarelo (lido) nas 03, 40 e 42; outra cor na mira (39). Os cantos usam a troca de cor do `AppSvg` (cores dinâmicas no mapa).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_003_scanner_encontrado_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_003_scanner_encontrado_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc03.camera` |  |  | aria-hidden=true |
| `sc03.camera.label.barcode` |  |  | aria-hidden=true |
| `sc03.dim` |  |  | aria-hidden=true |
| `sc03.detected` |  |  | aria-hidden=true |
| `sc03.corners` |  |  | aria-hidden=true |
| `sc03.status` | status |  |  |
| `sc03.status.chip.badge.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc03.camera.book` | DecoratedBox(LinearGradient) | Transform: rotate(-5deg) |
| `sc03.camera.book.spine` | NeoBox |  |
| `sc03.camera.book.ring` | CircleIconButton / NeoBox circular |  |
| `sc03.camera.label` | NeoBox | Transform: rotate(-5deg) |
| `sc03.camera.label.barcode` | CustomPainter (codigo_barras_camera) | é a cena do protótipo sob a câmera (o código de barras do livro, com os dígitos em `<text>` Figtree 600 11): no app é a imagem da câmera ao vivo — fica só como referência (como a tinta da fixture, D-34). |
| `sc03.dim` | NeoBox |  |
| `sc03.detected` | NeoBox | Transform: rotate(-5deg) |
| `sc03.detected.badge` | CircleIconButton / NeoBox circular |  |
| `sc03.detected.badge.icon` | AppSvg(AppIconsLeitor.checkSmall, size: 15) |  |
| `sc03.corners` | AppSvg(AppIllustrationsScanner.miraScanner, size: 290×170) | cores dinâmicas: #FED170 = reticle |
| `sc03.status.chip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc03.status.chip.badge` | CircleIconButton / NeoBox circular |  |
| `sc03.status.chip.badge.icon` | AppSvg(AppIconsScanner.checkReadAmarelo, size: 13) |  |

## Interações

- Ao aceitar o código (2 quadros seguidos com o mesmo EAN-13 978/979): pausar a câmera, vibração leve, cantos e contorno amarelos, o chip e a folha sobem; `SemanticsService.announce("Código lido")` (regras da nota do design).
- Outros códigos (preço, código interno) são ignorados; repetidos por 3 s mostram a dica "Esse parece ser o código de preço" (nota do design; a dica não tem prancha — o texto segue a nota).

## Dados

- O ISBN lido e o livro do catálogo (`isbn_resolver.dart`, as camadas da G07); a cena da câmera é só da fixture.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L03.1** Câmera ao vivo e o escuro fora da moldura
- **L03.2** Cantos da mira (cores por estado)
- **L03.3** Contorno do código lido e o selo
- **L03.4** Chip de estado anunciado
- **L03.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc03.camera', 'sc03.dim', 'sc03.detected', 'sc03.corners', 'sc03.status'), todos os ids de `kRef03.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/003_scanner_encontrado_390x844@3x.png` no recorte da fase (y 118–354) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef03w360` e `kRef03w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L03.1 Câmera ao vivo e o escuro fora da moldura
- [ ] L03.2 Cantos da mira (cores por estado)
- [ ] L03.3 Contorno do código lido e o selo
- [ ] L03.4 Chip de estado anunciado
- [ ] L03.5 Verificação + relatório
- [ ] Geometria 18/18 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
