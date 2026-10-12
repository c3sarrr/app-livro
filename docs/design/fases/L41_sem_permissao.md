# FASE L41 — Scanner (sem permissão de câmera) — o fundo listrado e a folha que pede a câmera

> Tela 41 · prancha `041_scanner_sem_permissao` (41 · Scanner — sem permissão de câmera, canvas 390×844) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L41_sem_permissao@3x.png` · `docs/design/medicao/projeto/png/redline/L41_sem_permissao_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/041_scanner_sem_permissao_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_041_scanner_sem_permissao.json` · `test/reference/projeto/reference_layout_041_scanner_sem_permissao.dart` (`kRef41`).
> Arquivos sugeridos: `lib/features/scanner/presentation/sheets/permission_sheet.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Sem permissão de câmera (41): o fundo escuro listrado no lugar da câmera, os cantos e a lanterna apagados (0,35) e a folha que explica sem culpa — "A câmera está desligada para nós." —, o caminho nos ajustes num chip tracejado, "Abrir os ajustes do celular" e "Digitar o ISBN".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{reticle}}` = padrão `#FED170`.

```html
<!-- no camera: dark, hatched placeholder where the preview would be -->
<div aria-hidden="true" style="position: absolute; inset: 0; background: repeating-linear-gradient(135deg, #221D19 0 10px, #1E1A17 10px 20px);"></div>

<section role="dialog" aria-label="Permitir câmera" style="position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column;">
  <span aria-hidden="true" style="align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD;"></span>
  <div style="margin-top: 16px;"><svg aria-hidden="true" width="150" height="120" viewBox="0 0 150 120" style="display: block; margin: 0 auto; overflow: visible;">
      <rect x="27" y="31" width="100" height="72" rx="14" fill="#1A1714"></rect>
      <rect x="23" y="27" width="100" height="72" rx="14" fill="#FED170" stroke="#1A1714" stroke-width="1.6"></rect>
      <path d="M50 27l8-12h30l8 12" fill="#FED170" stroke="#1A1714" stroke-width="1.6" stroke-linejoin="round"></path>
      <circle cx="73" cy="63" r="22" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.6"></circle>
      <circle cx="73" cy="63" r="12" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.5"></circle>
      <g transform="translate(98 66)">
        <rect x="3" y="12" width="36" height="30" rx="7" fill="#1A1714"></rect>
        <rect x="0" y="9" width="36" height="30" rx="7" fill="#FFC1C6" stroke="#1A1714" stroke-width="1.6"></rect>
        <path d="M8 9V3a10 10 0 0 1 20 0v6" fill="none" stroke="#1A1714" stroke-width="2.4"></path>
        <circle cx="18" cy="22" r="3.5" fill="#1A1714"></circle><path d="M18 24v6" stroke="#1A1714" stroke-width="2.4" stroke-linecap="round"></path>
      </g>
      <g transform="translate(4 6) scale(.9)"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></g>
    </svg></div>
  <h2 style="margin: 14px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 25px; line-height: 1.02; letter-spacing: -0.6px;">A câmera está<span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 29px;"> desligada para nós.</span></h2>
  <p style="margin: 8px 6px 0; text-align: center; font-size: 14px; font-weight: 600; line-height: 1.45; color: #5B544B;">Ela só serve para ler o código de barras — nenhuma foto é guardada ou enviada.</p>
  <div style="margin-top: 14px; padding: 10px 12px; border-radius: 16px; background: #F7F0E3; border: 1.3px dashed #1A1714; display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 700;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="3"></circle><path d="M12 2.5v3M12 18.5v3M4.2 6.5l2.6 1.5M17.2 16l2.6 1.5M2.5 12h3M18.5 12h3M4.2 17.5 6.8 16M17.2 8l2.6-1.5"></path></svg><span>Ajustes do celular › BookNest › <strong style="font-weight: 800;">Câmera</strong></span></div>
  <a href="#" style="margin-top: 14px; height: 54px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 16px; font-weight: 800;">Abrir os ajustes do celular</a>
  <a href="#" style="margin-top: 10px; height: 50px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 800;"><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2.5" y="6" width="19" height="12" rx="2.5"></rect><path d="M6.5 10h.01M10 10h.01M14 10h.01M17.5 10h.01M7.5 14h9"></path></svg>Digitar o ISBN</a>
</section>
```

## Especificação pixel a pixel

Seção `sc41.backdrop` — retângulo absoluto no canvas 390×844: **x=0, y=0, w=390, h=844**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `sc41.backdrop` | box | 0 | 0 | 390 | 844 | `position: absolute; inset: 0; background: repeating-linear-gradient(135deg, #221D19 0 10px, #1E1A17 10px 20px)` |  |

Seção `sc41.sheet` — retângulo absoluto no canvas 390×844: **x=10, y=353.64, w=370, h=480.36**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `sc41.sheet` | box | 0 | 0 | 370 | 480.36 | `position: absolute; left: 10px; right: 10px; bottom: 10px; box-sizing: border-box; padding: 10px 18px 22px; border-radius: 30px 30px 44px 44px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: flex; flex-direction: column` |  |
| 3 | `sc41.sheet.handle` | box | 165 | 11.5 | 40 | 5 | `align-self: center; width: 40px; height: 5px; border-radius: 3px; background: #D9CFBD` |  |
| 4 | `sc41.sheet.art` | box | 19.5 | 32.5 | 331 | 120 | `margin-top: 16px` |  |
| 5 | `sc41.sheet.art.image` | icon | 110 | 32.5 | 150 | 120 | `display: block; margin: 0 auto; overflow: visible` |  |
| 6 | `sc41.sheet.title` | text | 19.5 | 166.5 | 331 | 59.16 | `margin: 14px 0 0; text-align: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 25px; line-height: 1.02; letter-spacing: -0.6px` | Bricolage (opsz 25) 25/25.5px peso 800 ls -0.6px #1A1714 |
| 7 | `sc41.sheet.title.serif` ±1 | inline | 165.09 | 162.44 | 178.89 | 67.28 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 29px` | Instrument Serif itálico 29/29.58px peso 400 ls -0.6px #1A1714 |
| 8 | `sc41.sheet.body` | text | 25.5 | 233.66 | 319 | 40.6 | `margin: 8px 6px 0; text-align: center; font-size: 14px; font-weight: 600; line-height: 1.45; color: #5B544B` | Figtree 14/20.3px peso 600 ls normal #5B544B |
| 9 | `sc41.sheet.path` | box | 19.5 | 288.26 | 331 | 40.6 | `margin-top: 14px; padding: 10px 12px; border-radius: 16px; background: #F7F0E3; border: 1.3px dashed #1A1714; display: flex; align-items: center; gap: 8px; font-size: 13px; font-weight: 700` |  |
| 10 | `sc41.sheet.path.icon` | icon | 32.8 | 299.56 | 18 | 18 | `—` |  |
| 11 | `sc41.sheet.path.text` ±1 | text | 58.8 | 300.76 | 235.01 | 15.6 | `—` | Figtree 13/normal peso 700 ls normal #1A1714 |
| 12 | `sc41.sheet.path.text.strong` ±1 | inline | 246.45 | 300.76 | 47.36 | 15.6 | `font-weight: 800` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 13 | `sc41.sheet.openSettings` | box+text | 19.5 | 342.86 | 331 | 54 | `margin-top: 14px; height: 54px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 9px; font-size: 16px; font-weight: 800` | Figtree 16/normal peso 800 ls normal #1A1714 |
| 14 | `sc41.sheet.typeIsbn` | box+text | 19.5 | 406.86 | 331 | 50 | `margin-top: 10px; height: 50px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15px; font-weight: 800` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 15 | `sc41.sheet.typeIsbn.icon` ±1 | icon | 122.94 | 422.86 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `sc41.sheet.title` *(composto)* | 1 | A câmera está desligada para | 191.15 | 26.02 | 343.98 | 317.96 |
| `sc41.sheet.title` *(composto)* | 2 | nós. | 220.73 | 165.09 | 204.91 | 39.82 |
| `sc41.sheet.body` | 1 | Ela só serve para ler o código de barras — | 248.71 | 52.13 | 317.87 | 265.74 |
| `sc41.sheet.body` | 2 | nenhuma foto é guardada ou enviada. | 269.01 | 65.53 | 304.46 | 238.93 |
| `sc41.sheet.path.text` *(composto)* | 1 | Ajustes do celular › BookNest › Câmera | 313.11 | 58.8 | 293.81 | 235.01 |
| `sc41.sheet.openSettings` | 1 | Abrir os ajustes do celular | 375.46 | 88.58 | 281.42 | 192.84 |
| `sc41.sheet.typeIsbn` | 1 | Digitar o ISBN | 437.11 | 148.94 | 247.06 | 98.12 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Fundo: `repeating-linear-gradient(135deg, #221D19 0 10px, #1E1A17 10px 20px)` na tela inteira (listras de 10); os cantos e a lanterna da 03 com opacidade 0,35.
2. A folha (a mesma nas 03, 39, 40, 41 e 42): `left/right/bottom 10`, padding 10/18/22, raio 30/30/44/44, `#FFFAF1`, borda 1,5, sombra dura 0/4; a alça 40 × 5 `#D9CFBD` (raio 3) centrada no topo. É um `Align` no fundo da tela (não um `showModalBottomSheet`), para a câmera continuar visível atrás (nota do design).
3. Desenho 150 × 120 centrado, 16 abaixo da alça: a câmera amarela com a lente lavanda e o cadeado rosa (sombras duras deslocadas 3–4), e a estrela creme.
4. Título centrado 14 abaixo: "A câmera está" Bricolage 25/800 `lh 1,02` ls −0,6 + " desligada para nós." Instrument Serif itálico 29; o texto 14/600 `lh 1,45`, margem 8/6.
5. O caminho, 14 abaixo: padding 10/12, raio 16, `#F7F0E3`, borda 1,3 `dashed`, a engrenagem 18 + "Ajustes do celular › BookNest › **Câmera**" 13/700 (800 no último).
6. Botões: "Abrir os ajustes do celular" 54, `#FED170`, sombra 3/3, 16/800, sem ícone; "Digitar o ISBN" 50, `#FFFAF1`, sem sombra, teclado 18 + 15/800, 10 abaixo.
7. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- O chip do caminho tem borda tracejada (`dashed` 1,3) e o "›" vem da Figtree: conferir o glifo e o espaçamento na referência @3x.
- A 430 o texto fica num fio de navalha (sobra 0,84, abaixo).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_041_scanner_sem_permissao_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_041_scanner_sem_permissao_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 430: fio de navalha em `sc41.sheet.body` linha 1 «Ela só serve para ler o código de barras — nenhuma foto»: sobra 0.84 px · estouro com a próxima palavra 10.27 px.

## Diferenças em relação à prancha 03 (seções reutilizadas: corners, controls)

Estas seções são as mesmas widgets da 03 (fases L03_1_camera, L03_2_controles, L03_3_folha); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `sc41.corners` | opacity: null → "0.35" |
| `sc41.controls.torch` | opacity: null → "0.35" |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `sc41.backdrop` |  |  | aria-hidden=true |
| `sc41.sheet` | dialog | Permitir câmera |  |
| `sc41.sheet.handle` |  |  | aria-hidden=true |
| `sc41.sheet.art.image` |  |  | aria-hidden=true |
| `sc41.sheet.path.icon` |  |  | aria-hidden=true |
| `sc41.sheet.typeIsbn.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `sc41.backdrop` | HatchPainter (hachura 135°) dentro do contorno |  |
| `sc41.sheet` | NeoBox |  |
| `sc41.sheet.handle` | NeoBox |  |
| `sc41.sheet.art.image` | AppSvg(AppIllustrationsScanner.cameraCadeado, size: 150×120) |  |
| `sc41.sheet.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `sc41.sheet.path` | NeoBox |  |
| `sc41.sheet.path.icon` | AppSvg(AppIconsScanner.settingsSmall, size: 18) |  |
| `sc41.sheet.path.text.strong` | TextSpan dentro do AppText.rich do pai |  |
| `sc41.sheet.openSettings` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc41.sheet.typeIsbn` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `sc41.sheet.typeIsbn.icon` | AppSvg(AppIconsScanner.keyboard, size: 18) |  |

## Interações

- Abrir os ajustes do celular → os ajustes do app no sistema; ao voltar (`resumed`), checar de novo e religar a câmera sozinho (nota do design).
- Digitar o ISBN → a aba Digitar (69), que não depende da câmera.
- A permissão é pedida na primeira abertura, com a explicação antes do pedido do sistema; negada → esta tela; negada de vez → o botão abre os ajustes.

## Dados

- O caminho mostrado depende do sistema (Android e iPhone dizem diferente): o texto por plataforma é pergunta da T15; a prancha mostra o do iPhone.

## Subfases

- **L41.1** Fundo listrado e controles apagados
- **L41.2** Folha da permissão
- **L41.3** Ajustes do sistema e a volta
- **L41.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('sc41.backdrop', 'sc41.sheet'), todos os ids de `kRef41.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/041_scanner_sem_permissao_390x844@3x.png` no recorte da fase (y 345.64–842) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef41w360` e `kRef41w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L41.1 Fundo listrado e controles apagados
- [ ] L41.2 Folha da permissão
- [ ] L41.3 Ajustes do sistema e a volta
- [ ] L41.4 Verificação + relatório
- [ ] Geometria 13/13 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
