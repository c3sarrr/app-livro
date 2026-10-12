# FASE L40 — Scanner (livro não encontrado) — a folha: fora da nossa base, Salvar como e Adicionar à mão

> Tela 40 · prancha `040_scanner_nao_encontrado` (40 · Scanner — livro não encontrado, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L40_nao_encontrado@3x.png` · `docs/design/medicao/projeto/png/redline/L40_nao_encontrado_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/040_scanner_nao_encontrado_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_040_scanner_nao_encontrado.json` · `test/reference/projeto/reference_layout_040_scanner_nao_encontrado.dart` (`kRef40`).
> Arquivos sugeridos: `lib/features/scanner/presentation/sheets/not_found_sheet.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Livro não encontrado (40): o código foi lido, mas o ISBN não está na base. A folha não trata como erro: o chip rosa "Fora da nossa base" com o ISBN, a capa em branco com o "?", "Esse ainda não está aqui.", "Salvar como" (Lendo) e "Adicionar à mão".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<section role="dialog" aria-label="Livro não encontrado" style="position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">
  <span aria-hidden="true" style="align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD;"></span>
  <div style="margin-top: 12px; display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 6px 8px;">
    <span style="display: flex; align-items: center; gap: 5px; height: 26px; white-space: nowrap; padding: 0 10px 0 8px; box-sizing: border-box; border-radius: 999px; background: #FFE9E4; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800;"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="8"></circle><path d="M12 8v5M12 16h.01"></path></svg>Fora da nossa base</span>
    <span style="font-size: 12px; font-weight: 600; color: #5B544B; white-space: nowrap; font-variant-numeric: tabular-nums;">ISBN 978-65-01-23418-6</span>
  </div>
  <div style="margin-top: 14px; display: flex; gap: 14px; align-items: center;">
    <svg aria-hidden="true" width="84" height="110" viewBox="0 0 84 110" style="flex-shrink: 0; overflow: visible;">
      <rect x="7" y="7" width="70" height="98" rx="5" fill="#1A1714"></rect>
      <rect x="3" y="3" width="70" height="98" rx="5" fill="#ABCF82" stroke="#1A1714" stroke-width="1.5"></rect>
      <path d="M10 3v98" stroke="#1A1714" stroke-width="1.3" opacity="0.4"></path>
      <rect x="18" y="16" width="44" height="34" rx="4" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3" stroke-dasharray="4 3"></rect>
      <text x="40" y="41" text-anchor="middle" font-family="'Instrument Serif', Georgia, serif" font-style="italic" font-size="26" fill="#1A1714">?</text>
      <g transform="translate(56 64) scale(.9)"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></g>
    </svg>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1.05; letter-spacing: -0.5px;">Esse ainda não<span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 24px;"> está aqui.</span></span>
      <span style="display: block; margin-top: 6px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">Edição independente, antiga ou muito nova? Adicione à mão — o ISBN já vai preenchido.</span>
    </span>
  </div>
  <span style="margin-top: 16px; font-size: 12px; font-weight: 700; color: #5B544B;">Salvar como</span>
  <div role="radiogroup" aria-label="Salvar como" style="margin-top: 8px; height: 48px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1;">
    <button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B;">Quero ler</button>
    <button role="radio" aria-checked="true" style="height: 100%; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800;">Lendo</button>
    <button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B;">Lido</button>
  </div>
  <div style="margin-top: 16px; display: flex; gap: 10px;">
    <a href="#" style="flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#F7F0E3" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg><span style="color: #F7F0E3;">Adicionar à mão</span></a>
    <button aria-label="Escanear de novo" style="width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 12a8 8 0 1 1-2.35-5.65"></path><path d="M20 4v5h-5"></path></svg></button>
  </div>
  <p style="margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B;">Leu o código errado? <a href="#" style="font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Buscar pelo título</a></p>
</section>
```

## Especificação pixel a pixel

Seção `sc40.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=445.39, w=370, h=388.61**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc40.sheet` | box | 0 | 0 | 370 | 388.61 | `position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 2 | `sc40.sheet.handle` | box | 165 | 11.5 | 40 | 5 | `align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD` |  |
| 3 | `sc40.sheet.top` | box | 19.5 | 28.5 | 331 | 26 | `margin-top: 12px; display: flex; flex-wrap: wrap; align-items: center; justify-content: space-between; gap: 6px 8px` |  |
| 4 | `sc40.sheet.chip` ±1 | box+text | 19.5 | 28.5 | 143.31 | 26 | `display: flex; align-items: center; gap: 5px; height: 26px; white-space: nowrap; padding: 0 10px 0 8px; box-sizing: border-box; border-radius: 999px; background: #FFE9E4; border: 1.2px solid #1A1714; font-size: 12px; font-weight: 800` | Figtree 12/normal peso 800 ls normal #1A1714 |
| 5 | `sc40.sheet.chip.icon` | icon | 28.7 | 35 | 13 | 13 | `—` |  |
| 6 | `sc40.sheet.isbn` ±1 | text | 202.42 | 34.3 | 148.08 | 14.4 | `font-size: 12px; font-weight: 600; color: #5B544B; white-space: nowrap; font-variant-numeric: tabular-nums` | Figtree 12/normal peso 600 ls normal #5B544B tnum |
| 7 | `sc40.sheet.lead` | box | 19.5 | 68.5 | 331 | 110 | `margin-top: 14px; display: flex; gap: 14px; align-items: center` |  |
| 8 | `sc40.sheet.lead.art` | icon | 19.5 | 68.5 | 84 | 110 | `flex-shrink: 0; overflow: visible` |  |
| 9 | `sc40.sheet.lead.textBlock` | box | 117.5 | 79.55 | 233 | 87.9 | `min-width: 0; flex-grow: 1` |  |
| 10 | `sc40.sheet.lead.title` | text | 117.5 | 79.55 | 233 | 25.2 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 21px; line-height: 1.05; letter-spacing: -0.5px` | Bricolage (opsz 21) 21/22.05px peso 800 ls -0.5px #1A1714 |
| 11 | `sc40.sheet.lead.title.serif` ±1 | inline | 264.38 | 76.55 | 82.1 | 31.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 24px` | Instrument Serif itálico 24/25.2px peso 400 ls -0.5px #1A1714 |
| 12 | `sc40.sheet.lead.body` | text | 117.5 | 110.75 | 233 | 56.7 | `display: block; margin-top: 6px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 13 | `sc40.sheet.saveAs.label` | text | 19.5 | 194.5 | 331 | 14.4 | `margin-top: 16px; font-size: 12px; font-weight: 700; color: #5B544B` | Figtree 12/normal peso 700 ls normal #5B544B |
| 14 | `sc40.sheet.saveAs.options` | box | 19.5 | 216.9 | 331 | 48 | `margin-top: 8px; height: 48px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1` |  |
| 15 | `sc40.sheet.saveAs.options.wantToRead` | text | 24 | 221.4 | 106 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 16 | `sc40.sheet.saveAs.options.reading` | box+text | 132 | 221.4 | 106 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 17 | `sc40.sheet.saveAs.options.read` | text | 240 | 221.4 | 106 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 18 | `sc40.sheet.actions` | box | 19.5 | 280.9 | 331 | 54 | `margin-top: 16px; display: flex; gap: 10px` |  |
| 19 | `sc40.sheet.actions.primary` | box | 19.5 | 280.9 | 267 | 54 | `flex-grow: 1; height: 54px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; justify-content: center; gap: 10px; font-size: 16px; font-weight: 700` |  |
| 20 | `sc40.sheet.actions.primary.icon` ±1 | icon | 78.69 | 297.9 | 20 | 20 | `—` |  |
| 21 | `sc40.sheet.actions.primary.label` ±1 | text | 108.69 | 298.3 | 118.62 | 19.2 | `color: #F7F0E3` | Figtree 16/normal peso 700 ls normal #F7F0E3 |
| 22 | `sc40.sheet.actions.scanAgain` | box | 296.5 | 280.9 | 54 | 54 | `width: 54px; height: 54px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 23 | `sc40.sheet.actions.scanAgain.icon` | icon | 312.5 | 296.9 | 22 | 22 | `—` |  |
| 24 | `sc40.sheet.footer` | text | 19.5 | 348.9 | 331 | 16.21 | `margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B` | Figtree 13.5/normal peso 500 ls normal #5B544B |
| 25 | `sc40.sheet.footer.link` ±1 | inline | 195.83 | 348.9 | 109.9 | 16.21 | `font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc40.sheet.chip` | 1 | Fora da nossa base | 45.7 | 46.7 | 151.61 | 104.91 |
| `sc40.sheet.isbn` | 1 | ISBN 978-65-01-23418-6 | 45.7 | 202.42 | 350.5 | 148.08 |
| `sc40.sheet.lead.title` *(composto)* | 1 | Esse ainda não está aqui. | 100.31 | 117.5 | 346.48 | 228.98 |
| `sc40.sheet.lead.body` | 1 | Edição independente, antiga ou muito | 124.92 | 117.5 | 350.21 | 232.71 |
| `sc40.sheet.lead.body` | 2 | nova? Adicione à mão — o ISBN já vai | 143.82 | 117.5 | 349.48 | 231.98 |
| `sc40.sheet.lead.body` | 3 | preenchido. | 162.72 | 117.5 | 190.25 | 72.75 |
| `sc40.sheet.saveAs.label` | 1 | Salvar como | 205.9 | 19.5 | 87.37 | 67.87 |
| `sc40.sheet.saveAs.options.wantToRead` | 1 | Quero ler | 245.8 | 47.35 | 106.64 | 59.29 |
| `sc40.sheet.saveAs.options.reading` | 1 | Lendo | 245.8 | 164.98 | 205.02 | 40.04 |
| `sc40.sheet.saveAs.options.read` | 1 | Lido | 245.8 | 279.34 | 306.66 | 27.32 |
| `sc40.sheet.actions.primary.label` | 1 | Adicionar à mão | 313.5 | 108.69 | 227.31 | 118.62 |
| `sc40.sheet.footer` *(composto)* | 1 | Leu o código errado? Buscar pelo título | 361.73 | 64.26 | 305.74 | 241.48 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. A folha (a mesma nas 03, 39, 40, 41 e 42): `left/right/bottom 10`, padding 10/18/22, raio 30/30/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4; a alça 40 × 5 `#D9CFBD` (raio 3) centrada no topo. É um `Align` no fundo da tela (não um `showModalBottomSheet`), para a câmera continuar visível atrás (nota do design).
2. Topo (flex-wrap, gap 6/8): o chip de 26 `#FFE9E4` **com borda** 1,2 (o "Livro encontrado" da 03 não tem), o ícone de alerta 13 (traço 2,6) e "Fora da nossa base" 12/800 `nowrap`; o ISBN 12/600 `tnum`.
3. Desenho 84 × 110 (`livroInterrogacao`, `overflow: visible`): o livro verde com sombra dura, o quadro tracejado com o "?" em Instrument Serif itálico 26 e a estrela 0,9; ao lado, "Esse ainda não" Bricolage 21/800 ls −0,5 + " está aqui." Instrument Serif itálico 24 e o texto 13,5/600 `lh 1,4`.
4. "Salvar como" 12/700 `#5B544B` e, 8 abaixo, a régua de 48 (padding 3, borda 1,5, 3 colunas, gap 2): o marcado em `{{brand}}` com borda 1,5 e 14/800; os outros sem fundo, 14/600 `#5B544B`. Aqui "Lendo" vem marcado (a nota do design), 16 abaixo do desenho.
5. Ações 16 abaixo (gap 10): o botão preto de 54 (`flex 1`, ícone 20 `#F7F0E3` + 16/700) e o círculo 54 de escanear de novo (a seta circular 22); por último, 14 abaixo, a linha centrada 13,5/500 `#5B544B` com o link 800 sublinhado (offset 3). O botão diz "Adicionar à mão" e é um link (a prancha usa `<a>`).
6. O que muda da 03 na câmera: o verso verde (outro livro), a citação com uma linha a menos e o autor "EDIÇÃO INDEPENDENTE".
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O chip tem borda e o da 03 não: o ícone anda 1,2 (a borda de 1,2) — não é o mesmo widget com outra cor.
- O desenho tem `<text>` (o "?") e um tracejado: `AppSvg` sem o texto, o "?" em `AppText` e o tracejado pelo registro `svgDashes` (o mapa de widgets).
- Fio de navalha em `sc40.sheet.lead.body` linha 1 «Edição independente, antiga ou muito»: sobra 0.29 px · estouro com a próxima palavra 39.24 px.
- Fio de navalha em `sc40.sheet.lead.body` linha 2 «nova? Adicione à mão — o ISBN já vai»: sobra 1.02 px · estouro com a próxima palavra 74.98 px.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_040_scanner_nao_encontrado_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_040_scanner_nao_encontrado_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `sc40.sheet.lead.body` linha 2 «muito nova? Adicione à mão — o»: sobra 0.97 px · estouro com a próxima palavra 33.04 px.
- A 430: fio de navalha em `sc40.sheet.lead.body` linha 1 «Edição independente, antiga ou muito nova?»: sobra 0.76 px · estouro com a próxima palavra 56.78 px.

## Diferenças em relação à prancha 03 (seções reutilizadas: camera, dim, detected, corners, status, controls)

Estas seções são as mesmas widgets da 03 (fases L03_1_camera, L03_2_controles, L03_3_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `sc40.camera.book` | bgImage: "linear-gradient(160deg, #FF6C47 0%, #FF552E 48%, #DB431F 100%)" → "linear-gradient(160deg, #B9DA94 0%, #ABCF82 48%, #8DB565 100%)" |
| `sc40.camera.book.quote` | retângulo ['32', '82', '250', '94.08'] → ['32', '82', '250', '70.56']; position: {"top": "56px", "right": "84px", "bottom": "409.92px", "left": "96px"} → {"top": "56px", "right": "84px", "bottom": "433.44px", "left": "96px"}; texto «“Ao verme que primeiro roeu as / frias carnes do meu cadáver» → «“Contos escritos à mão, em / cadernos de escola, e reunidos » |
| `sc40.camera.book.author` | retângulo ['32', '222', '114.75', '10.8'] → ['32', '222', '135.73', '10.8']; position: {"top": "196px", "right": "219.25px", "bottom": "353.2px", "left": "96px"} → {"top": "196px", "right": "198.271px", "bottom": "353.2px", "left": "96px"}; texto «MACHADO DE ASSIS» → «EDIÇÃO INDEPENDENTE» |
| `sc40.camera.label.isbn` | retângulo ['140.6', '218', '108.81', '10.21'] → ['140.46', '218', '109.07', '10.21']; texto «ISBN 978-65-5921-104-3» → «ISBN 978-65-01-23418-6» |

Só na base: `camera.book.ring`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc40.sheet` | dialog | Livro não encontrado |  |
| `sc40.sheet.handle` |  |  | aria-hidden=true |
| `sc40.sheet.chip.icon` |  |  | aria-hidden=true |
| `sc40.sheet.lead.art` |  |  | aria-hidden=true |
| `sc40.sheet.saveAs.options` | radiogroup | Salvar como |  |
| `sc40.sheet.saveAs.options.wantToRead` | radio |  | aria-checked=false |
| `sc40.sheet.saveAs.options.reading` | radio |  | aria-checked=true |
| `sc40.sheet.saveAs.options.read` | radio |  | aria-checked=false |
| `sc40.sheet.actions.primary.icon` |  |  | aria-hidden=true |
| `sc40.sheet.actions.scanAgain` |  | Escanear de novo |  |
| `sc40.sheet.actions.scanAgain.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc40.sheet` | NeoBox |  |
| `sc40.sheet.handle` | NeoBox |  |
| `sc40.sheet.chip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc40.sheet.chip.icon` | AppSvg(AppIconsScanner.alertSmall, size: 13) |  |
| `sc40.sheet.lead.art` | AppSvg(AppIllustrationsScanner.livroInterrogacao, size: 84×110) | tem `<text>` (o "?" em Instrument Serif 26): o flutter_svg desenharia o texto com a fonte do sistema → no app o AppSvg lê o desenho sem os textos e eles voltam em AppText nas mesmas posições (como as capas da Início, T03.7). tem stroke-dasharray (o `<rect>` de cantos 4, 4/3, 1,3, tinta, sobre o fundo creme dele): o flutter_svg traceja com outra fase → no app, o registro de tracejados (svgDashes, T01 e D-285) lê o arquivo sem esse traço (só o do id="tracejado": os outros `<rect>` têm traço) e o pinta por cima como o Chromium: o padrão começa em (x + rx, y), no sentido horário, e o comprimento das curvas é medido na escala da pintura (D-286). |
| `sc40.sheet.lead.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `sc40.sheet.saveAs.options` | NeoBox |  |
| `sc40.sheet.saveAs.options.reading` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc40.sheet.actions.primary` | NeoBox |  |
| `sc40.sheet.actions.primary.icon` | AppSvg(AppIconsScanner.plusPapel, size: 20) |  |
| `sc40.sheet.actions.scanAgain` | CircleIconButton / NeoBox circular |  |
| `sc40.sheet.actions.scanAgain.icon` | AppSvg(AppIconsScanner.refresh, size: 22) |  |
| `sc40.sheet.footer.link` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Adicionar à mão → a tela 28d com o ISBN e o status preenchidos (a capa pode ser fotografada lá).
- Escanear de novo → a mira (39).
- Buscar pelo título → a Busca (28), para o caso de ter lido o código errado (o de uma etiqueta de preço).
- `SemanticsService.announce("Livro não encontrado")` ao mostrar a folha.

## Dados

- O ISBN lido; o resto é texto do app.
- O app de hoje, sem o livro, oferece digitar os dados e enviar à comunidade (`ScanNotFound` com as sugestões); o design diz que o livro à mão fica privado e que o app oferece juntar quando o ISBN aparecer na base — qual regra vale é pergunta da T15.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L40.1** Folha "fora da nossa base" (chip com borda, desenho)
- **L40.2** Salvar como em Lendo
- **L40.3** Adicionar à mão com o ISBN preenchido
- **L40.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc40.sheet'), todos os ids de `kRef40.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/040_scanner_nao_encontrado_390x844@3x.png` no recorte da fase (y 437.39–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef40w360` e `kRef40w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L40.1 Folha "fora da nossa base" (chip com borda, desenho)
- [ ] L40.2 Salvar como em Lendo
- [ ] L40.3 Adicionar à mão com o ISBN preenchido
- [ ] L40.4 Verificação + relatório
- [ ] Geometria 23/23 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
