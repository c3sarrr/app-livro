# FASE L14 — Onboarding 3/4 — o título, a busca e o scanner

> Tela 14 · prancha `014_onboarding_primeiros_livros` (14 · Onboarding 3/4 — Primeiros livros, canvas 390×844) · executada na **T16** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L14_1_busca@3x.png` · `docs/design/medicao/projeto/png/redline/L14_1_busca_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/014_onboarding_primeiros_livros_390x844@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_014_onboarding_primeiros_livros.json` · `test/reference/projeto/reference_layout_014_onboarding_primeiros_livros.dart` (`kRef14`).
> Arquivos sugeridos: `lib/features/account/presentation/onboarding/first_books_step.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Onboarding 3/4 — Primeiros livros (14), em cima: "Comece sua estante.", o texto, a busca por título, autor ou ISBN e o botão amarelo do Scanner.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{progress}}` = padrão `#FF552E`.

```html
<div style="position: relative; margin-top: 36px;">
  <h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px;">Comece sua<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px;">estante.</span></h1>
  <svg aria-hidden="true" width="24" height="24" viewBox="0 0 24 24" style="position: absolute; right: 14px; top: 30px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#ABCF82" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>
</div>

<p style="margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B;">Adicione os livros que você já tem ou quer ler.</p>

<!-- Search + scanner -->
<div style="margin-top: 16px; display: flex; align-items: center; gap: 10px;">
  <label style="flex-grow: 1; min-width: 0; height: 52px; display: flex; align-items: center; gap: 10px; padding: 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>
    <input type="search" aria-label="Buscar livros" placeholder="Título, autor ou ISBN" style="flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-family: inherit; font-size: 15px; font-weight: 500; color: #1A1714;">
  </label>
  <button aria-label="Escanear código de barras" style="width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 7V5a2 2 0 0 1 2-2h2M17 3h2a2 2 0 0 1 2 2v2M21 17v2a2 2 0 0 1-2 2h-2M7 21H5a2 2 0 0 1-2-2v-2M8 7v10M12 7v10M16 7v10"></path></svg>
  </button>
</div>
```

## Especificação pixel a pixel

Seção `e14.heading` — retângulo absoluto no canvas 390×844: **x=20, y=142, w=350, h=78.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `e14.heading` | box | 0 | 0 | 350 | 78.4 | `position: relative; margin-top: 36px` |  |
| 2 | `e14.heading.title` | text | 0 | 0 | 350 | 78.4 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1.1px #1A1714 |
| 3 | `e14.heading.title.serif` ±1 | inline | 0 | 25.96 | 122.5 | 59.8 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 46px; letter-spacing: -0.5px` | Instrument Serif itálico 46/45.08px peso 400 ls -0.5px #1A1714 |
| 4 | `e14.heading.sparkle` | icon | 312 | 30 | 24 | 24 | `position: absolute; right: 14px; top: 30px` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e14.heading.title` *(composto)* | 1 | Comece sua | 27.88 | 0 | 189.15 | 189.15 |
| `e14.heading.title` *(composto)* | 2 | estante. | 71.5 | 0 | 122.5 | 122.5 |

Seção `e14.lead` — retângulo absoluto no canvas 390×844: **x=20, y=230.4, w=350, h=21.02**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 5 | `e14.lead` | text | 0 | 0 | 350 | 21.02 | `margin: 10px 0 0; font-size: 14.5px; font-weight: 500; line-height: 1.45; color: #5B544B` | Figtree 14.5/21.025px peso 500 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `e14.lead` | 1 | Adicione os livros que você já tem ou quer ler. | 15.58 | 0 | 298.52 | 298.52 |

Seção `e14.search` — retângulo absoluto no canvas 390×844: **x=20, y=267.43, w=350, h=52**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `e14.search` | box | 0 | 0 | 350 | 52 | `margin-top: 16px; display: flex; align-items: center; gap: 10px` |  |
| 7 | `e14.search.field` | box | 0 | 0 | 288 | 52 | `flex-grow: 1; min-width: 0; height: 52px; display: flex; align-items: center; gap: 10px; padding: 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 8 | `e14.search.field.icon` | icon | 17.5 | 16 | 20 | 20 | `—` |  |
| 9 | `e14.search.field.input` | box | 47.5 | 1.5 | 223 | 49 | `flex-grow: 1; min-width: 0; height: 100%; border: none; background: transparent; outline: none; padding: 0; font-family: inherit; font-size: 15px; font-weight: 500; color: #1A1714` |  |
| 10 | `e14.search.scan` | box | 298 | 0 | 52 | 52 | `width: 52px; height: 52px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 11 | `e14.search.scan.icon` | icon | 312 | 14 | 24 | 24 | `—` |  |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. O topo com "3 de 4" e a barra em 75 %; título Bricolage 34/800 + "estante." Instrument Serif 46, o brilho verde 24; o texto 14,5/500.
2. Busca, 16 abaixo (gap 10): a pílula de 52 (`flex 1`, padding 0/16, gap 10, lupa 20, texto 15/500) e o Scanner, círculo 52 `#FED170` com sombra 2/2 e o ícone 24.
3. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- "Título, autor ou ISBN" é o `placeholder` (cor padrão do Chromium): `hintText` com a cor da referência @3x.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_014_onboarding_primeiros_livros_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_014_onboarding_primeiros_livros_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Diferenças em relação à prancha 13 (seções reutilizadas: waves, top)

Estas seções são as mesmas widgets da 13 (fases L13_generos); abaixo, só o que muda nesta prancha. Ids sem linha aqui = idênticos (geometria, estilo e texto).

| Key | o que muda |
|---|---|
| `e14.top.step` | texto «2 de 4» → «3 de 4» |
| `e14.top.progress.fill` | retângulo ['146.2', '75.5', '75.57', '13'] → ['146.2', '75.5', '113.36', '13']; position: {"top": "0px", "right": "75.5716px", "bottom": "0px", "left": "0px"} → {"top": "0px", "right": "37.7858px", "bottom": "0px", "left": "0px"} |
| `e14.top.progress.fill.edge` | retângulo ['216.77', '75.5', '10', '13'] → ['254.56', '75.5', '10', '13']; position: {"top": "0px", "right": "-5px", "bottom": "0px", "left": "70.5714px"} → {"top": "0px", "right": "-5px", "bottom": "0px", "left": "108.357px"} |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `e14.heading.sparkle` |  |  | aria-hidden=true |
| `e14.search.field.icon` |  |  | aria-hidden=true |
| `e14.search.field.input` |  | Buscar livros |  |
| `e14.search.scan` |  | Escanear código de barras |  |
| `e14.search.scan.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `e14.heading.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `e14.heading.sparkle` | AppSvg(AppIconsEntrada.sparkleVerde, size: 24) |  |
| `e14.search.field` | NeoBox |  |
| `e14.search.field.icon` | AppSvg(AppIconsLeitor.search, size: 20) |  |
| `e14.search.scan` | CircleIconButton / NeoBox circular |  |
| `e14.search.scan.icon` | AppSvg(AppIconsEntrada.scanBarcodeGrande, size: 24) |  |

## Interações

- Busca → por título, autor ou ISBN (a busca do catálogo da T15); onde o resultado aparece aqui não tem prancha — pergunta da T16.
- Scanner → o Scanner; volta para o passo 3 com o livro adicionado.

## Dados

- O catálogo (T15) para a busca.

## Subfases

- **L14.1** Título e texto
- **L14.2** Busca e Scanner
- **L14.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('e14.heading', 'e14.lead', 'e14.search'), todos os ids de `kRef14.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/014_onboarding_primeiros_livros_390x844@3x.png` no recorte da fase (y 134–327.43) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef14w360` e `kRef14w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L14.1 Título e texto
- [ ] L14.2 Busca e Scanner
- [ ] L14.3 Verificação + relatório
- [ ] Geometria 10/10 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
