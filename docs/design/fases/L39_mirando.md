# FASE L39 — Scanner (mirando) — a linha que varre a moldura e a folha de dicas

> Tela 39 · prancha `039_scanner_mirando` (39 · Scanner — mirando, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L39_mirando@3x.png` · `docs/design/medicao/projeto/png/redline/L39_mirando_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/039_scanner_mirando_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_039_scanner_mirando.json` · `test/reference/projeto/reference_layout_039_scanner_mirando.dart` (`kRef39`).
> Arquivos sugeridos: `lib/features/scanner/presentation/scan_line.dart`, `lib/features/scanner/presentation/sheets/aiming_sheet.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Scanner mirando (39): a câmera viva, a linha coral que varre a moldura, o chip "Procurando o código…" e a folha baixa que ensina com um desenho — "Vire o livro de costas." —, as duas dicas e "Código apagado? Digitar o ISBN".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- moving scan line (sweeps up and down) -->
<div aria-hidden="true" style="position: absolute; left: 70px; right: 70px; top: 246px; height: 3px; border-radius: 2px; background: #FF552E; box-shadow: 0 0 0 1.5px #1A1714, 0 0 18px 4px rgba(255,85,46,0.45);"></div>

<!-- Hint tray -->
<section role="dialog" aria-label="Dica para escanear" style="position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">
  <span aria-hidden="true" style="align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD;"></span>
  <div style="margin-top: 12px; display: flex; gap: 14px; align-items: center;">
    <svg aria-hidden="true" width="86" height="104" viewBox="0 0 86 104" style="flex-shrink: 0;">
      <rect x="6" y="6" width="72" height="94" rx="5" fill="#1A1714"></rect>
      <rect x="3" y="3" width="72" height="94" rx="5" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.5"></rect>
      <path d="M14 18h40M14 25h48M14 32h34" stroke="#1A1714" stroke-width="2" stroke-linecap="round" opacity="0.35"></path>
      <rect x="16" y="58" width="46" height="28" rx="3" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.3"></rect>
      <path d="M21 62v18M24 62v18M28 62v18M31 62v18M35 62v18M39 62v18M42 62v18M46 62v18M50 62v18M53 62v18M57 62v18" stroke="#1A1714" stroke-width="1.5"></path>
      <rect x="11" y="53" width="56" height="38" rx="6" fill="none" stroke="#FF552E" stroke-width="2.4" stroke-dasharray="5 4"></rect>
      <path d="M62 28l14-12" stroke="#1A1714" stroke-width="1.6" stroke-linecap="round"></path>
    </svg>
    <span style="min-width: 0; flex-grow: 1;">
      <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; line-height: 1.05; letter-spacing: -0.4px;">Vire o livro<span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 23px;"> de costas.</span></span>
      <span style="display: block; margin-top: 6px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B;">O código de barras fica no verso, quase sempre perto do preço. Encaixe ele na moldura.</span>
    </span>
  </div>
  <div style="margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; gap: 8px; flex-wrap: wrap;">
    <span style="height: 30px; padding: 0 11px; border-radius: 999px; background: #F7F0E3; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 12.5px; font-weight: 700;">Pouca luz? Ligue a lanterna</span>
    <span style="height: 30px; padding: 0 11px; border-radius: 999px; background: #F7F0E3; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 12.5px; font-weight: 700;">Afaste um palmo</span>
  </div>
  <p style="margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B;">Código apagado? <a href="#" style="font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px;">Digitar o ISBN</a></p>
</section>
```

## Especificação pixel a pixel

Seção `sc39.scanLine` — retângulo absoluto no canvas 390×844: **x=70, y=246, w=250, h=3**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc39.scanLine` | box | 0 | 0 | 250 | 3 | `position: absolute; left: 70px; right: 70px; top: 246px; height: 3px; border-radius: 2px; background: #FF552E; box-shadow: 0 0 0 1.5px #1A1714, 0 0 18px 4px rgba(255,85,46,0.45)` |  |

Seção `sc39.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=590.29, w=370, h=243.71**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `sc39.sheet` | box | 0 | 0 | 370 | 243.71 | `position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 3 | `sc39.sheet.handle` | box | 165 | 11.5 | 40 | 5 | `align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD` |  |
| 4 | `sc39.sheet.lead` | box | 19.5 | 28.5 | 331 | 104 | `margin-top: 12px; display: flex; gap: 14px; align-items: center` |  |
| 5 | `sc39.sheet.lead.art` | icon | 19.5 | 28.5 | 86 | 104 | `flex-shrink: 0` |  |
| 6 | `sc39.sheet.lead.textBlock` | box | 119.5 | 37.08 | 231 | 86.85 | `min-width: 0; flex-grow: 1` |  |
| 7 | `sc39.sheet.lead.title` | text | 119.5 | 37.08 | 231 | 24.15 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; line-height: 1.05; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/21px peso 800 ls -0.4px #1A1714 |
| 8 | `sc39.sheet.lead.title.serif` ±1 | inline | 219.27 | 34.2 | 76.01 | 29.9 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 23px` | Instrument Serif itálico 23/24.15px peso 400 ls -0.4px #1A1714 |
| 9 | `sc39.sheet.lead.body` | text | 119.5 | 67.23 | 231 | 56.7 | `display: block; margin-top: 6px; font-size: 13.5px; font-weight: 600; line-height: 1.4; color: #5B544B` | Figtree 13.5/18.9px peso 600 ls normal #5B544B |
| 10 | `sc39.sheet.tips` | box | 19.5 | 146.5 | 331 | 43.5 | `margin-top: 14px; padding-top: 12px; border-top: 1.5px dashed #CFC3AE; display: flex; gap: 8px; flex-wrap: wrap` |  |
| 11 | `sc39.sheet.tips.light` ±1 | box+text | 19.5 | 160 | 179.68 | 30 | `height: 30px; padding: 0 11px; border-radius: 999px; background: #F7F0E3; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 12.5px; font-weight: 700` | Figtree 12.5/normal peso 700 ls normal #1A1714 |
| 12 | `sc39.sheet.tips.distance` ±1 | box+text | 207.18 | 160 | 121.97 | 30 | `height: 30px; padding: 0 11px; border-radius: 999px; background: #F7F0E3; border: 1.3px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 12.5px; font-weight: 700` | Figtree 12.5/normal peso 700 ls normal #1A1714 |
| 13 | `sc39.sheet.footer` | text | 19.5 | 204 | 331 | 16.21 | `margin: 14px 0 0; text-align: center; font-size: 13.5px; font-weight: 500; color: #5B544B` | Figtree 13.5/normal peso 500 ls normal #5B544B |
| 14 | `sc39.sheet.footer.link` ±1 | inline | 196.17 | 204 | 88.3 | 16.21 | `font-weight: 800; color: #1A1714; text-decoration: underline; text-underline-offset: 3px` | Figtree 13.5/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc39.sheet.lead.title` *(composto)* | 1 | Vire o livro de costas. | 56.96 | 119.5 | 295.28 | 175.78 |
| `sc39.sheet.lead.body` | 1 | O código de barras fica no verso, | 81.39 | 119.5 | 321.01 | 201.51 |
| `sc39.sheet.lead.body` | 2 | quase sempre perto do preço. | 100.3 | 119.5 | 302.63 | 183.13 |
| `sc39.sheet.lead.body` | 3 | Encaixe ele na moldura. | 119.2 | 119.5 | 262.95 | 143.45 |
| `sc39.sheet.tips.light` | 1 | Pouca luz? Ligue a lanterna | 179.37 | 31.8 | 186.88 | 155.08 |
| `sc39.sheet.tips.distance` | 1 | Afaste um palmo | 179.37 | 219.47 | 316.85 | 97.38 |
| `sc39.sheet.footer` *(composto)* | 1 | Código apagado? Digitar o ISBN | 216.83 | 85.53 | 284.48 | 198.95 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Linha: `left/right 70 · top 246`, 3 de altura, raio 2, `#FF552E`, com o filete preto de 1,5 e o brilho `0 0 18 4 rgba(255,85,46,.45)` (duas sombras).
2. A folha (a mesma nas 03, 39, 40, 41 e 42): `left/right/bottom 10`, padding 10/18/22, raio 30/30/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4; a alça 40 × 5 `#D9CFBD` (raio 3) centrada no topo. É um `Align` no fundo da tela (não um `showModalBottomSheet`), para a câmera continuar visível atrás (nota do design).
3. Desenho 86 × 104 (`livroCodigoBarras`): o livro lavanda de costas com a sombra dura, as linhas de texto a 35 %, a etiqueta com as barras e o retângulo tracejado coral em volta do código; ao lado (gap 14), "Vire o livro" Bricolage 20/800 `lh 1,05` + " de costas." Instrument Serif itálico 23 e o texto 13,5/600 `lh 1,4` `#5B544B`, 6 abaixo.
4. Dicas, 14 abaixo, depois da linha tracejada (borda de cima 1,5 `dashed #CFC3AE`, padding-top 12): pílulas de 30 `#F7F0E3`, borda 1,3, padding 0/11, 12,5/700 (flex-wrap, gap 8). Embaixo, "Código apagado? Digitar o ISBN".
5. O que muda da 03 (tabela "Diferenças"): a etiqueta da câmera desfocada (`blur 1.4`) e o chip "Procurando o código…" em `#FFFAF1` (200,7 de largura, ícone 14).
6. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O tracejado coral do desenho tem `stroke-dasharray`: o registro de tracejados (`svgDashes`, D-285) lê o arquivo sem esse traço e o pinta por cima como o Chromium (ver o mapa de widgets).
- As dicas da prancha aparecem as duas juntas (o estado depois de 8 s); antes de 4 s a folha não tem a faixa das dicas — a altura da folha muda; o estado sem dicas não tem prancha (a folha encolhe; confirmar na T15).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_039_scanner_mirando_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_039_scanner_mirando_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `sc39.sheet.lead.body` linha 1 «O código de barras fica no»: sobra 39.65 px · estouro com a próxima palavra 0.51 px.

## Diferenças em relação à prancha 03 (seções reutilizadas: camera, dim, corners, status, controls)

Estas seções são as mesmas widgets da 03 (fases L03_1_camera, L03_2_controles, L03_3_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `sc39.camera.label` | filter: null → "blur(1.4px)" |
| `sc39.status.chip` | retângulo ['130.22', '126', '129.55', '36'] → ['94.65', '126', '200.7', '36']; bg: "#FED170" → "#FFFAF1"; texto «Código lido» → «Procurando o código…» |
| `sc39.status.chip.badge` | retângulo ['137.72', '132', '24', '24'] → ['102.15', '132', '24', '24'] |
| `sc39.status.chip.badge.icon` | retângulo ['143.22', '137.5', '13', '13'] → ['107.15', '137', '14', '14'] |

Só na base: `camera.book.ring`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc39.scanLine` |  |  | aria-hidden=true |
| `sc39.sheet` | dialog | Dica para escanear |  |
| `sc39.sheet.handle` |  |  | aria-hidden=true |
| `sc39.sheet.lead.art` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc39.scanLine` | NeoBox |  |
| `sc39.sheet` | NeoBox |  |
| `sc39.sheet.handle` | NeoBox |  |
| `sc39.sheet.lead.art` | AppSvg(AppIllustrationsScanner.livroCodigoBarras, size: 86×104) | tem stroke-dasharray (o `<rect>` de cantos 6, 5/4, 2,4, coral): o flutter_svg traceja com outra fase → no app, o registro de tracejados (svgDashes, T01 e D-285) lê o arquivo sem esse traço (só o do id="tracejado": os outros `<rect>` têm traço) e o pinta por cima como o Chromium: o padrão começa em (x + rx, y), no sentido horário, e o comprimento das curvas é medido na escala da pintura (D-286). |
| `sc39.sheet.lead.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `sc39.sheet.tips` | NeoBox |  |
| `sc39.sheet.tips.light` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc39.sheet.tips.distance` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc39.sheet.footer.link` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Linha: `AnimationController.repeat(reverse: true)`, 1,6 s ida e volta de cima a baixo da moldura, sem piscar; parada no meio com `disableAnimations` (nota do design).
- Dicas: aparecem só depois de alguns segundos sem leitura (4 s "Pouca luz? Ligue a lanterna", 8 s "Afaste um palmo"); tocar na primeira liga a lanterna; os timers são cancelados a cada leitura e no dispose.
- Digitar o ISBN → a aba Digitar (69).

## Dados

- Nada vem do banco; as dicas dependem do tempo sem leitura.

## Subfases

- **L39.1** Linha que varre (com o modo sem animação)
- **L39.2** Folha de dicas com o desenho
- **L39.3** Dicas por tempo e o atalho Digitar
- **L39.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc39.scanLine', 'sc39.sheet'), todos os ids de `kRef39.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/039_scanner_mirando_390x844@3x.png` no recorte da fase (y 238–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef39w360` e `kRef39w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L39.1 Linha que varre (com o modo sem animação)
- [ ] L39.2 Folha de dicas com o desenho
- [ ] L39.3 Dicas por tempo e o atalho Digitar
- [ ] L39.4 Verificação + relatório
- [ ] Geometria 12/12 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
