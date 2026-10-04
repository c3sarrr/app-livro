# FASE L21b — Seleção de texto — barra de ações

> Tela 21 · prancha `21_selecao_texto` (21 · Leitor — seleção de texto, canvas 390×844) · executada na **G13** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L21b_barra_de_acoes@3x.png` · `referencia/png/redline/L21b_barra_de_acoes_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/21_selecao_texto_390x844@{1,2,3}x.png` · `referencia/layout/layout_21_selecao_texto.json` · `test/reference/leitor/reference_layout_21_selecao_texto.dart` (`kRef21`).
> Arquivos sugeridos: `lib/features/reader/presentation/selection_toolbar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Barra flutuante "Ações para o trecho selecionado" acima da seleção (caso "acima" do arquivo).

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`.

```html
<p style="margin: 0; font-family: 'Literata', Georgia, serif; font-size: 20.5px; font-weight: 400; line-height: 1.72; color: #2A2520; text-align: left; text-indent: 1.3em;">Retórica dos namorados, dá-me uma comparação exata e poética para dizer o que foram <mark style="background: linear-gradient(transparent 12%, rgba(254,209,112,0.85) 12%, rgba(254,209,112,0.85) 92%, transparent 92%); color: inherit; border-radius: 3px; -webkit-box-decoration-break: clone; box-decoration-break: clone;">aqueles olhos de Capitu</mark>. Não me acode imagem capaz de dizer, sem quebra da dignidade do estilo, o que eles foram e me fizeram. <span aria-label="Trecho selecionado" style="background: transparent;">Olhos de ressaca? Vá, de ressaca.</span> É o que me dá ideia daquela feição nova. Traziam não sei que fluido misterioso e enérgico, uma força que arrastava para dentro, <span style="position: static;"><span role="toolbar" aria-label="Ações para o trecho selecionado" style="position: absolute; left: -6px; right: -6px; margin-top: -162px; z-index: 5; display: block; padding: 10px 10px 6px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; font-family: 'Figtree', sans-serif; text-indent: 0; line-height: 1;">
    <span style="display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 0 2px 8px; border-bottom: 1.5px dashed #CFC3AE;">
      <span style="font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">GRIFAR</span>
      <span style="display: flex; gap: 7px;">
        <button aria-label="Grifar em amarelo" style="width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #FED170;"></button>
        <button aria-label="Grifar em rosa" style="width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #FFC1C6;"></button>
        <button aria-label="Grifar em verde" style="width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #ABCF82;"></button>
        <button aria-label="Grifar em lavanda" style="width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #B6ACE4;"></button>
        <button aria-label="Escolher outra cor" style="width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: conic-gradient(#FF552E, #F2A815, #FED170, #ABCF82, #00995E, #058CD7, #B6ACE4, #552CB7, #FFC1C6, #FF552E); display: flex; align-items: center; justify-content: center;"><span style="width: 14px; height: 14px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="8" height="8" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="4" stroke-linecap="round" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg></span></button>
        <button aria-label="Sublinhar" style="width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #FFFAF1; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" aria-hidden="true"><text x="12" y="14.5" text-anchor="middle" font-family="Literata, Georgia, serif" font-size="13" fill="#1A1714">a</text><path d="M4 19q2-2 4 0t4 0 4 0 4 0" fill="none" stroke="#FF552E" stroke-width="2" stroke-linecap="round"></path></svg></button>
      </span>
    </span>
    <span style="display: flex; margin-top: 4px;">
      <button style="flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 4h16v12H8l-4 4z"></path><path d="M8 9h8M8 12h5"></path></svg>Nota</button>
      <button style="flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="8" y="8" width="12" height="12" rx="2.5"></rect><path d="M16 8V5.5A1.5 1.5 0 0 0 14.5 4h-9A1.5 1.5 0 0 0 4 5.5v9A1.5 1.5 0 0 0 5.5 16H8"></path></svg>Copiar</button>
      <button style="flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 15V3M7.5 7.5 12 3l4.5 4.5"></path><path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7"></path></svg>Compartilhar</button>
      <button style="flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>Buscar</button>
    </span>
  </span>
```

## Especificação pixel a pixel

Seção `r21.toolbar` — retângulo absoluto no canvas 390×844: **x=22, y=353.12, w=346, h=116.5**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `r21.toolbar` | box | 0 | 0 | 346 | 116.5 | `position: absolute; left: -6px; right: -6px; margin-top: -162px; z-index: 5; display: block; padding: 10px 10px 6px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; font-family: 'Figtree', sans-serif; text-indent: 0; line-height: 1` |  |
| 2 | `r21.toolbar.colors` | box | 11.5 | 11.5 | 323 | 43.5 | `display: flex; align-items: center; justify-content: space-between; gap: 8px; padding: 0 2px 8px; border-bottom: 1.5px dashed #CFC3AE` |  |
| 3 | `r21.toolbar.colors.label` ±1 | text | 13.5 | 23 | 47.14 | 11 | `font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/11px peso 800 ls 1.2px #6F665B |
| 4 | `r21.toolbar.colors.swatches` | box | 93.5 | 11.5 | 239 | 34 | `display: flex; gap: 7px` |  |
| 5 | `r21.toolbar.colors.yellow` | box | 93.5 | 11.5 | 34 | 34 | `width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #FED170` |  |
| 6 | `r21.toolbar.colors.pink` | box | 134.5 | 11.5 | 34 | 34 | `width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #FFC1C6` |  |
| 7 | `r21.toolbar.colors.green` | box | 175.5 | 11.5 | 34 | 34 | `width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #ABCF82` |  |
| 8 | `r21.toolbar.colors.lavender` | box | 216.5 | 11.5 | 34 | 34 | `width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #B6ACE4` |  |
| 9 | `r21.toolbar.colors.other` | box | 257.5 | 11.5 | 34 | 34 | `width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: conic-gradient(#FF552E, #F2A815, #FED170, #ABCF82, #00995E, #058CD7, #B6ACE4, #552CB7, #FFC1C6, #FF552E); display: flex; align-items: center; justify-content: center` |  |
| 10 | `r21.toolbar.colors.other.center` | box | 267.5 | 21.5 | 14 | 14 | `width: 14px; height: 14px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 11 | `r21.toolbar.colors.other.icon` | icon | 270.5 | 24.5 | 8 | 8 | `—` |  |
| 12 | `r21.toolbar.colors.underline` | box | 298.5 | 11.5 | 34 | 34 | `width: 34px; height: 34px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; padding: 0; flex-shrink: 0; background: #FFFAF1; display: flex; align-items: center; justify-content: center` |  |
| 13 | `r21.toolbar.colors.underline.icon` | icon | 305.5 | 18.5 | 20 | 20 | `—` |  |
| 14 | `r21.toolbar.actions` | box | 11.5 | 59 | 323 | 50 | `display: flex; margin-top: 4px` |  |
| 15 | `r21.toolbar.actions.note` | text | 11.5 | 59 | 80.75 | 50 | `flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 16 | `r21.toolbar.actions.note.icon` | icon | 41.88 | 65.09 | 20 | 20 | `—` |  |
| 17 | `r21.toolbar.actions.copy` | text | 92.25 | 59 | 80.75 | 50 | `flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 18 | `r21.toolbar.actions.copy.icon` | icon | 122.62 | 65.09 | 20 | 20 | `—` |  |
| 19 | `r21.toolbar.actions.share` | text | 173 | 59 | 80.75 | 50 | `flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 20 | `r21.toolbar.actions.share.icon` | icon | 203.38 | 65.09 | 20 | 20 | `—` |  |
| 21 | `r21.toolbar.actions.search` | text | 253.75 | 59 | 80.75 | 50 | `flex: 1 1 0; height: 50px; padding: 0; border: none; background: transparent; border-radius: 14px; display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 4px; font-size: 11.5px; font-weight: 800; color: #1A1714` | Figtree 11.5/normal peso 800 ls normal #1A1714 |
| 22 | `r21.toolbar.actions.search.icon` | icon | 284.12 | 65.09 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r21.toolbar.colors.label` | 1 | GRIFAR | 32.35 | 13.5 | 60.64 | 47.14 |
| `r21.toolbar.actions.note` | 1 | Nota | 100.02 | 38.67 | 65.08 | 26.41 |
| `r21.toolbar.actions.copy` | 1 | Copiar | 100.02 | 114.64 | 150.61 | 35.97 |
| `r21.toolbar.actions.share` | 1 | Compartilhar | 100.02 | 177.76 | 248.99 | 71.23 |
| `r21.toolbar.actions.search` | 1 | Buscar | 100.02 | 276.01 | 312.24 | 36.23 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Caixa: `left/right −6` em relação à página (346 de largura), `margin-top −162` a partir da linha da seleção, padding 10/10/6, raio 22, `#FFFAF1`, borda 1,5, sombra 3/3. Opaca: esconde o texto de baixo.
2. Linha 1: "GRIFAR" (Figtree 11/800, ls 1,2, `#6F665B`) + 4 círculos 34 (amarelo, rosa, verde, lavanda; borda 1,5) + "outra cor" (anel cônico arco-íris com miolo 14 `#FFFAF1` e "+" 8) + "Sublinhar" ("a" em Literata 13 sobre ondulado coral). Separador tracejado `#CFC3AE` 1,5.
3. Linha 2: 4 botões flexíveis de 50 de altura (ícone 20 + rótulo Figtree 11,5/800): Nota · Copiar · Compartilhar · Buscar.

## Armadilhas

- O "a" do ícone Sublinhar é `<text>` em Literata dentro do SVG: o flutter_svg não usa a fonte do app → desenhe o "a" com AppText por cima do ondulado (catálogo de SVGs).
- Posição acima/abaixo conforme o espaço disponível; o arquivo só mostra "acima".

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `r21.toolbar` | toolbar | Ações para o trecho selecionado |  |
| `r21.toolbar.colors.yellow` |  | Grifar em amarelo |  |
| `r21.toolbar.colors.pink` |  | Grifar em rosa |  |
| `r21.toolbar.colors.green` |  | Grifar em verde |  |
| `r21.toolbar.colors.lavender` |  | Grifar em lavanda |  |
| `r21.toolbar.colors.other` |  | Escolher outra cor |  |
| `r21.toolbar.colors.other.icon` |  |  | aria-hidden=true |
| `r21.toolbar.colors.underline` |  | Sublinhar |  |
| `r21.toolbar.colors.underline.icon` |  |  | aria-hidden=true |
| `r21.toolbar.actions.note.icon` |  |  | aria-hidden=true |
| `r21.toolbar.actions.copy.icon` |  |  | aria-hidden=true |
| `r21.toolbar.actions.share.icon` |  |  | aria-hidden=true |
| `r21.toolbar.actions.search.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `r21.toolbar` | NeoBox |  |
| `r21.toolbar.colors` | NeoBox |  |
| `r21.toolbar.colors.yellow` | CircleIconButton / NeoBox circular |  |
| `r21.toolbar.colors.pink` | CircleIconButton / NeoBox circular |  |
| `r21.toolbar.colors.green` | CircleIconButton / NeoBox circular |  |
| `r21.toolbar.colors.lavender` | CircleIconButton / NeoBox circular |  |
| `r21.toolbar.colors.other` | ConicRingPainter (anel arco-íris) |  |
| `r21.toolbar.colors.other.center` | CircleIconButton / NeoBox circular |  |
| `r21.toolbar.colors.other.icon` | AppSvg(AppIconsLeitor.ic_plus_tiny, size: 8) |  |
| `r21.toolbar.colors.underline` | CircleIconButton / NeoBox circular |  |
| `r21.toolbar.colors.underline.icon` | AppSvg(AppIconsLeitor.ic_underline, size: 20) | tem <text> ("a" em Literata 13): o flutter_svg desenha texto com a fonte do sistema → desenhar o "a" com AppText (Literata13 não existe: usar a variável com opsz 13) por cima do traço ondulado. |
| `r21.toolbar.actions.note.icon` | AppSvg(AppIconsLeitor.ic_note, size: 20) |  |
| `r21.toolbar.actions.copy.icon` | AppSvg(AppIconsLeitor.ic_copy, size: 20) |  |
| `r21.toolbar.actions.share.icon` | AppSvg(AppIconsLeitor.ic_share, size: 20) |  |
| `r21.toolbar.actions.search.icon` | AppSvg(AppIconsLeitor.ic_search, size: 20) |  |

## Interações

- Cor → cria grifo `fill` e fecha · Sublinhar → grifo `underline` · Outra cor → seletor da tela 23 (D-38) · Nota → grifo + nota (editor mínimo D-23) · Copiar/Compartilhar → texto + "— Machado de Assis, *Dom Casmurro* (pág. 159)" (D-39) · Buscar → busca no livro (D-23).

## Dados

- Cores = as 4 da paleta (iguais às opções de `brand`).

## Subfases

- **L21b.1** Caixa e posicionamento
- **L21b.2** Linha de cores
- **L21b.3** Linha de ações
- **L21b.4** Ações reais
- **L21b.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('r21.toolbar'), todos os ids de `kRef21.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/21_selecao_texto_390x844@3x.png` no recorte da fase (y 345.12–477.62) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L21b.1 Caixa e posicionamento
- [ ] L21b.2 Linha de cores
- [ ] L21b.3 Linha de ações
- [ ] L21b.4 Ações reais
- [ ] L21b.5 Verificação + relatório
- [ ] Geometria 22/22 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
