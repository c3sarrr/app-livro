# FASE L02 — Biblioteca — título, adicionar, busca e filtros

> Tela 02 · prancha `002_biblioteca` (02 · Biblioteca, canvas 390×1640) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L02_1_cabecalho@3x.png` · `docs/design/medicao/projeto/png/redline/L02_1_cabecalho_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/002_biblioteca_390x1640@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_002_biblioteca.json` · `test/reference/projeto/reference_layout_002_biblioteca.dart` (`kRef02`).
> Arquivos sugeridos: `lib/features/library/presentation/library_screen.dart`, `lib/features/library/presentation/sections/library_header.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Topo da Biblioteca (02): o título "Sua biblioteca." numa linha só, o botão redondo de adicionar e, embaixo, a busca em pílula com o botão dos filtros. A tela entra no lugar do placeholder da aba (`/biblioteca`), que hoje só tem o bloco de importar da G09 (D-87).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Large title -->
<header style="display: flex; align-items: center; justify-content: space-between; gap: 12px; min-height: 52px;">
  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 1; letter-spacing: -1.2px; white-space: nowrap;">Sua <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.6px;">biblioteca.</span></h1>
  <button aria-label="Adicionar livros" style="width: 48px; height: 48px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"><path d="M12 5v14M5 12h14"></path></svg>
  </button>
</header>

<!-- Search + filters -->
<div style="margin-top: 20px; display: flex; gap: 10px;">
  <label style="flex-grow: 1; min-width: 0; height: 52px; display: flex; align-items: center; gap: 10px; padding: 0 18px 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>
    <input type="search" aria-label="Buscar na biblioteca" placeholder="Título, autor ou nota" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 15px; font-weight: 500; color: #1A1714;">
  </label>
  <button aria-label="Filtros" style="width: 52px; height: 52px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round"><path d="M4 7h9M18 7h2M4 17h3M12 17h8"></path><circle cx="15.5" cy="7" r="2.3"></circle><circle cx="9.5" cy="17" r="2.3"></circle></svg>
  </button>
</div>
```

## Especificação pixel a pixel

Seção `b02.header` — retângulo absoluto no canvas 390×1640: **x=20, y=62, w=350, h=52**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `b02.header` | box | 0 | 0 | 350 | 52 | `display: flex; align-items: center; justify-content: space-between; gap: 12px; min-height: 52px` |  |
| 2 | `b02.header.title` ±1 | text | 0 | 3 | 234.9 | 46 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 36px; line-height: 1; letter-spacing: -1.2px; white-space: nowrap` | Bricolage (opsz 36) 36/36px peso 800 ls -1.2px #1A1714 |
| 3 | `b02.header.title.serif` ±1 | inline | 69 | -3.9 | 165.9 | 59.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.6px` | Instrument Serif itálico 46/46px peso 400 ls -0.6px #1A1714 |
| 4 | `b02.header.add` | box | 302 | 2 | 48 | 48 | `width: 48px; height: 48px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 5 | `b02.header.add.icon` | icon | 315 | 15 | 22 | 22 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b02.header.title` *(composto)* | 1 | Sua biblioteca. | 41.64 | 0 | 234.9 | 234.9 |

Seção `b02.search` — retângulo absoluto no canvas 390×1640: **x=20, y=134, w=350, h=52**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `b02.search` | box | 0 | 0 | 350 | 52 | `margin-top: 20px; display: flex; gap: 10px` |  |
| 7 | `b02.search.field` | box | 0 | 0 | 288 | 52 | `flex-grow: 1; min-width: 0; height: 52px; display: flex; align-items: center; gap: 10px; padding: 0 18px 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 8 | `b02.search.field.icon` | icon | 17.5 | 16 | 20 | 20 | `—` |  |
| 9 | `b02.search.field.input` | box | 47.5 | 1.5 | 221 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-size: 15px; font-weight: 500; color: #1A1714` |  |
| 10 | `b02.search.filters` | box | 298 | 0 | 52 | 52 | `width: 52px; height: 52px; flex-shrink: 0; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 11 | `b02.search.filters.icon` | icon | 313 | 15 | 22 | 22 | `—` |  |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cabeçalho 350 × 52 (`min-height`), `space-between`, gap 12: "Sua" Bricolage 36/800 `lh 1` ls −1,2 e "biblioteca." Instrument Serif itálico 46 ls −0,6 (inline), `white-space: nowrap` — uma linha de 234,9, baseline 41,64.
2. Adicionar: círculo 48 `#FFFAF1`, borda 1,5, sem sombra, com o "+" de 22 (traço 2): `AppIconsBiblioteca.plusCabecalho`.
3. Busca 20 abaixo: pílula de 52 (`flex 1` → 288 de largura), padding 0/18/0/16, gap 10, com a lupa 20 (`AppIconsLeitor.search`) e o campo em Figtree 15/500; à direita, o botão dos filtros, círculo 52 com o ícone de 22 (traço 1,9).
4. Nenhuma sombra nesta faixa: título, adicionar, busca e filtros são planos (só a borda de 1,5).
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- "Título, autor ou nota" é o `placeholder` do `<input>` (não é texto medido): a cor é a padrão do Chromium e não está declarada na prancha. No app, `hintText` em 15/500 com a cor tirada da referência @3x e a posição do campo (x 47,5 na seção, altura 49).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_002_biblioteca_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_002_biblioteca_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `b02.header.add` |  | Adicionar livros |  |
| `b02.search.field.icon` |  |  | aria-hidden=true |
| `b02.search.field.input` |  | Buscar na biblioteca |  |
| `b02.search.filters` |  | Filtros |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `b02.header.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `b02.header.add` | CircleIconButton / NeoBox circular |  |
| `b02.header.add.icon` | AppSvg(AppIconsBiblioteca.plusCabecalho, size: 22) |  |
| `b02.search.field` | NeoBox |  |
| `b02.search.field.icon` | AppSvg(AppIconsLeitor.search, size: 20) |  |
| `b02.search.filters` | CircleIconButton / NeoBox circular |  |
| `b02.search.filters.icon` | AppSvg(AppIconsBiblioteca.filters, size: 22) |  |

## Interações

- Adicionar (+) → as formas de pôr um livro na estante (as mesmas da 36: Escanear, Buscar, E-book ou PDF). A prancha não desenha esse menu: abrir o importar que já existe (D-87) ou seguir a D-243 b (idêntico, sem ação, teste, `estados_sem_design.md`) é pergunta da T14 (ROTEIRO §2b).
- Busca → filtra a estante na hora por título, autor ou nota, no aparelho (sem servidor), dentro da aba de status escolhida; teclado com "Buscar" e o X de limpar do sistema.
- Filtros → sem prancha: D-243 b (idêntico à prancha, sem ação, teste que documenta, item em `docs/design/estados_sem_design.md`) — confirmar na pergunta da T14 (ROTEIRO §2b).

## Dados

- Nada desta fase vem do banco: título, rótulos e o texto de exemplo são textos do app. A busca lê os livros da estante (título, autor e notas das anotações).

## Subfases

- **L02.1** A tela da Biblioteca no lugar do placeholder (rota `/biblioteca`)
- **L02.2** Cabeçalho: título e Adicionar
- **L02.3** Busca local e o botão dos filtros
- **L02.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('b02.header', 'b02.search'), todos os ids de `kRef02.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/002_biblioteca_390x1640@3x.png` no recorte da fase (y 50.1–194) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef02w360` e `kRef02w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L02.1 A tela da Biblioteca no lugar do placeholder (rota `/biblioteca`)
- [ ] L02.2 Cabeçalho: título e Adicionar
- [ ] L02.3 Busca local e o botão dos filtros
- [ ] L02.4 Verificação + relatório
- [ ] Geometria 10/10 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
