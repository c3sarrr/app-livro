# FASE L28 — Busca (Explorar) — barra de busca, brilho e o título "O que vamos ler agora?"

> Tela 28 · prancha `028_busca_explorar` (28 · Busca — Explorar (antes de digitar), canvas 390×1520) · executada na **T15** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L28_1_busca_e_titulo@3x.png` · `docs/design/medicao/projeto/png/redline/L28_1_busca_e_titulo_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_028_busca_explorar.json` · `test/reference/projeto/reference_layout_028_busca_explorar.dart` (`kRef28`).
> Arquivos sugeridos: `lib/features/search/presentation/search_screen.dart`, `lib/features/search/presentation/sections/search_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Busca, antes de digitar (28): a barra de cima (voltar, o campo "Livro, autor ou ISBN" e o botão amarelo do Scanner), o brilho lavanda e o título "O que vamos ler agora?". Abre pela lupa da Início (ao lado do sino).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<div style="position: absolute; left: 16px; right: 16px; top: 54px; display: flex; align-items: center; gap: 8px; z-index: 2;">
  <a href="#" aria-label="Voltar" style="width: 48px; height: 48px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
  <label style="flex-grow: 1; min-width: 0; height: 50px; padding: 0 14px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px;"><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg><input type="search" placeholder="Livro, autor ou ISBN" aria-label="Buscar livros, autores, clubes e trechos" style="flex-grow: 1; min-width: 0; height: 100%; border: none; outline: none; background: transparent; font-size: 15.5px; font-weight: 600; color: #1A1714;"></label>
  <a href="#" aria-label="Escanear o código de barras" style="width: 48px; height: 48px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="21" height="21" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8V5.5A1.5 1.5 0 0 1 5.5 4H8M16 4h2.5A1.5 1.5 0 0 1 20 5.5V8M20 16v2.5a1.5 1.5 0 0 1-1.5 1.5H16M8 20H5.5A1.5 1.5 0 0 1 4 18.5V16"></path><path d="M8 8v8M11 8v8M14 8v8M17 8v8"></path></svg></a>
</div>

<svg aria-hidden="true" width="26" height="26" viewBox="0 0 24 24" style="position: absolute; left: 330px; top: 136px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#B6ACE4" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>

<h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 0.98; letter-spacing: -1.1px;">O que vamos<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.4px;">ler agora?</span></h1>
```

## Especificação pixel a pixel

Seção `bu28.searchBar` — retângulo absoluto no canvas 390×1520: **x=16, y=54, w=358, h=50**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `bu28.searchBar` | box | 0 | 0 | 358 | 50 | `position: absolute; left: 16px; right: 16px; top: 54px; display: flex; align-items: center; gap: 8px; z-index: 2` |  |
| 2 | `bu28.searchBar.back` | box | 0 | 1 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `bu28.searchBar.back.icon` | icon | 14 | 15 | 20 | 20 | `—` |  |
| 4 | `bu28.searchBar.field` | box | 56 | 0 | 246 | 50 | `flex-grow: 1; min-width: 0; height: 50px; padding: 0 14px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px` |  |
| 5 | `bu28.searchBar.field.icon` | icon | 71.5 | 15 | 20 | 20 | `—` |  |
| 6 | `bu28.searchBar.field.input` | box | 100.5 | 1.5 | 186 | 47 | `flex-grow: 1; min-width: 0; height: 100%; border: none; outline: none; background: transparent; font-size: 15.5px; font-weight: 600; color: #1A1714` |  |
| 7 | `bu28.searchBar.scan` | box | 310 | 1 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 8 | `bu28.searchBar.scan.icon` | icon | 323.5 | 14.5 | 21 | 21 | `—` |  |

Seção `bu28.sparkle` — retângulo absoluto no canvas 390×1520: **x=330, y=136, w=26, h=26**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 9 | `bu28.sparkle` | icon | 0 | 0 | 26 | 26 | `position: absolute; left: 330px; top: 136px` |  |

Seção `bu28.title` — retângulo absoluto no canvas 390×1520: **x=16, y=128, w=358, h=78.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 10 | `bu28.title` | text | 0 | 0 | 358 | 78.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 36) 36/35.28px peso 800 ls -1.1px #1A1714 |
| 11 | `bu28.title.serif` ±1 | inline | 0 | 28.24 | 152.95 | 57.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.4px` | Instrument Serif itálico 44/43.12px peso 400 ls -0.4px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `bu28.title` *(composto)* | 1 | O que vamos | 29.52 | 0 | 209.89 | 209.89 |
| `bu28.title` *(composto)* | 2 | ler agora? | 71.8 | 0 | 152.95 | 152.95 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Barra em `left/right 16 · top 54`, gap 8, `z-index 2`: voltar 48 (`#FFFAF1`, sombra 2/2), o campo de 50 (`flex 1`, padding 0/14, gap 9, lupa 20 `#6F665B`, texto 15,5/600) e o Scanner 48 `#FED170` com sombra 2/2 e o ícone 21.
2. Brilho lavanda 26 em `left 330 · top 136`.
3. Título: "O que vamos" Bricolage 36/800 `lh 0,98` ls −1,1, quebra, "ler agora?" Instrument Serif itálico 44 ls −0,4.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- "Livro, autor ou ISBN" é o `placeholder` (cor padrão do Chromium, não declarada): `hintText` com a cor da referência @3x.
- Na 28b o campo ganha o anel `{{brand}}` de 4 (foco) e o X de limpar, e a lupa encolhe (abaixo, na L28b_1).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_028_busca_explorar_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_028_busca_explorar_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `bu28.searchBar.back` |  | Voltar |  |
| `bu28.searchBar.back.icon` |  |  | aria-hidden=true |
| `bu28.searchBar.field.icon` |  |  | aria-hidden=true |
| `bu28.searchBar.field.input` |  | Buscar livros, autores, clubes e trechos |  |
| `bu28.searchBar.scan` |  | Escanear o código de barras |  |
| `bu28.searchBar.scan.icon` |  |  | aria-hidden=true |
| `bu28.sparkle` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `bu28.searchBar.back` | CircleIconButton / NeoBox circular |  |
| `bu28.searchBar.back.icon` | AppSvg(AppIconsLeitor.arrowLeft, size: 20) |  |
| `bu28.searchBar.field` | NeoBox |  |
| `bu28.searchBar.field.icon` | AppSvg(AppIconsLeitor.searchGray, size: 20) |  |
| `bu28.searchBar.scan` | CircleIconButton / NeoBox circular |  |
| `bu28.searchBar.scan.icon` | AppSvg(AppIconsScanner.scanBarcodeBusca, size: 21) |  |
| `bu28.sparkle` | AppSvg(AppIconsScanner.sparkleLavanda, size: 26) |  |
| `bu28.title.serif` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Voltar → a tela de onde abriu (a Início).
- Campo → resultados enquanto digita (espera ~300 ms), na 28b; o trecho buscado grifado em amarelo.
- Scanner → a tela do Scanner.

## Dados

- Nada vem do banco nesta faixa.

## Subfases

- **L28.1** A tela da Busca e a lupa da Início ligada
- **L28.2** Barra de busca
- **L28.3** Brilho e título
- **L28.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('bu28.searchBar', 'bu28.sparkle', 'bu28.title'), todos os ids de `kRef28.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/028_busca_explorar_390x1520@3x.png` no recorte da fase (y 46–221.44) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef28w360` e `kRef28w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L28.1 A tela da Busca e a lupa da Início ligada
- [ ] L28.2 Barra de busca
- [ ] L28.3 Brilho e título
- [ ] L28.4 Verificação + relatório
- [ ] Geometria 10/10 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
