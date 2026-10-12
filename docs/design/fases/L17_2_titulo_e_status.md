# FASE L17 — Detalhes (livro físico) — título, autor, ano, formato e status

> Tela 17 · prancha `017_detalhes_fisico` (17 · Detalhes do livro — físico (Brás Cubas), canvas 390×1940) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17_2_titulo_e_status@3x.png` · `docs/design/medicao/projeto/png/redline/L17_2_titulo_e_status_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017_detalhes_fisico.json` · `test/reference/projeto/reference_layout_017_detalhes_fisico.dart` (`kRef17`).
> Arquivos sugeridos: `lib/features/library/presentation/details/details_title.dart`, `lib/features/library/presentation/details/status_selector.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

O título do livro em duas fontes ("Memórias Póstumas / de Brás Cubas"), a linha do autor (Machado de Assis · 1881 e a pílula "Livro físico · 208 páginas") e o seletor de status Quero ler / Lendo / Lido.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#ABCF82`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Title -->
<h1 style="margin: 2px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px;">Memórias Póstumas<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.5px;">de Brás Cubas</span></h1>

<div style="margin-top: 10px; display: flex; align-items: center; flex-wrap: wrap; gap: 8px 10px;">
  <span style="font-size: 15px; font-weight: 700;">Machado de Assis</span>
  <span style="width: 4px; height: 4px; border-radius: 50%; background: #1A1714;"></span>
  <span style="font-size: 15px; font-weight: 600; color: #5B544B;">1881</span>
  <span style="height: 28px; padding: 0 10px 0 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 700; color: #3E3832;"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#3E3832" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"></path></svg>Livro físico · 208 páginas</span>
</div>

<div role="radiogroup" aria-label="Status" style="margin-top: 18px; height: 48px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1;">
  <button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B;">Quero ler</button>
  <button role="radio" aria-checked="true" style="height: 100%; padding: 0; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800;">Lendo</button>
  <button role="radio" aria-checked="false" style="height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B;">Lido</button>
</div>
```

## Especificação pixel a pixel

Seção `d17.title` — retângulo absoluto no canvas 390×1940: **x=20, y=440, w=350, h=76.44**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17.title` | text | 0 | 0 | 350 | 76.44 | `margin: 2px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1.1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1.1px #1A1714 |
| 2 | `d17.title.serif` ±1 | inline | 0 | 26.28 | 210.55 | 57.2 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 44px; letter-spacing: -0.5px` | Instrument Serif itálico 44/43.12px peso 400 ls -0.5px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.title` *(composto)* | 1 | Memórias Póstumas | 27.88 | 0 | 319.27 | 319.27 |
| `d17.title` *(composto)* | 2 | de Brás Cubas | 69.84 | 0 | 210.55 | 210.55 |

Seção `d17.meta` — retângulo absoluto no canvas 390×1940: **x=20, y=526.44, w=350, h=54**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 3 | `d17.meta` | box | 0 | 0 | 350 | 54 | `margin-top: 10px; display: flex; align-items: center; flex-wrap: wrap; gap: 8px 10px` |  |
| 4 | `d17.meta.author` ±1 | text | 0 | 0 | 123.19 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 5 | `d17.meta.dot` ±1 | box | 133.19 | 7 | 4 | 4 | `width: 4px; height: 4px; border-radius: 50%; background: #1A1714` |  |
| 6 | `d17.meta.year` ±1 | text | 147.19 | 0 | 30.96 | 18 | `font-size: 15px; font-weight: 600; color: #5B544B` | Figtree 15/normal peso 600 ls normal #5B544B |
| 7 | `d17.meta.format` ±1 | box+text | 0 | 26 | 183.94 | 28 | `height: 28px; padding: 0 10px 0 8px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #E2D7C4; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 700; color: #3E3832` | Figtree 12.5/normal peso 700 ls normal #3E3832 |
| 8 | `d17.meta.format.icon` | icon | 9.5 | 33 | 14 | 14 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.meta.author` | 1 | Machado de Assis | 14.25 | 0 | 123.19 | 123.19 |
| `d17.meta.year` | 1 | 1881 | 14.25 | 147.19 | 178.15 | 30.96 |
| `d17.meta.format` | 1 | Livro físico · 208 páginas | 44.38 | 29.5 | 172.44 | 142.94 |

Seção `d17.status` — retângulo absoluto no canvas 390×1940: **x=20, y=598.44, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 9 | `d17.status` | box | 0 | 0 | 350 | 48 | `margin-top: 18px; height: 48px; padding: 3px; box-sizing: border-box; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px; border-radius: 999px; border: 1.5px solid #1A1714; background: #FFFAF1` |  |
| 10 | `d17.status.wantToRead` | text | 4.5 | 4.5 | 112.33 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 11 | `d17.status.reading` | box+text | 118.83 | 4.5 | 112.33 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 12 | `d17.status.read` | text | 233.17 | 4.5 | 112.33 | 39 | `height: 100%; padding: 0; border-radius: 999px; background: transparent; border: none; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.status.wantToRead` | 1 | Quero ler | 28.9 | 31.02 | 90.31 | 59.29 |
| `d17.status.reading` | 1 | Lendo | 28.9 | 154.98 | 195.02 | 40.04 |
| `d17.status.read` | 1 | Lido | 28.9 | 275.67 | 303 | 27.33 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Título 2 abaixo da área da capa: Bricolage 34/800 `lh 0,98` ls −1,1, quebra, e Instrument Serif itálico 44 ls −0,5 — 2 linhas, 350 de largura, 76,44 de altura.
2. Linha do autor (flex-wrap, gap 8/10, 10 abaixo): "Machado de Assis" 15/700, o ponto 4 × 4 `#1A1714`, "1881" 15/600 `#5B544B` e a pílula de 28 (borda 1,5 `#E2D7C4`, padding 0/10/0/8, ícone 14 `#3E3832` + 12,5/700 `#3E3832`).
3. Status 18 abaixo: pílula de 48 (padding 3, borda 1,5, `#FFFAF1`), 3 colunas iguais, gap 2; a marcada em `{{brand}}` com borda 1,5 e 14/800, as outras sem fundo, 14/600 `#5B544B`.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- Os Detalhes mostram o título completo ("Memórias Póstumas de Brás Cubas"); o curto ("Brás Cubas") é o das listas e da Início — o campo do título curto chega nesta etapa (D-270), editável e preenchido pelo catálogo.
- O status "Abandonado" existe na Biblioteca (aba) mas não no seletor de 3: como marcar e desmarcar o abandonado é pergunta da T14.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017_detalhes_fisico_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017_detalhes_fisico_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- A 360: fio de navalha em `d17.title` linha 1 «Memórias Póstumas»: sobra 0.73 px · sem palavra seguinte (D-275: a linha única quebra se crescer).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17.meta.format.icon` |  |  | aria-hidden=true |
| `d17.status` | radiogroup | Status |  |
| `d17.status.wantToRead` | radio |  | aria-checked=false |
| `d17.status.reading` | radio |  | aria-checked=true |
| `d17.status.read` | radio |  | aria-checked=false |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `d17.meta.dot` | CircleIconButton / NeoBox circular |  |
| `d17.meta.format` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.meta.format.icon` | AppSvg(AppIconsBiblioteca.bookClosed, size: 14) |  |
| `d17.status` | NeoBox |  |
| `d17.status.reading` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |

## Interações

- Status → muda na hora (Quero ler, Lendo, Lido) e salva no banco local; "Lido" marca o fim da leitura. O que mais muda com o "Lido" (resenha, conquistas) é das etapas delas.
- Autor e ano: sem toque (a prancha não os marca como link).

## Dados

- Título, autor, ano e páginas do catálogo (ou do cadastro à mão, 28d); formato e status do `user_book`.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17.1** Título em duas fontes
- **L17.2** Autor, ano e formato (flex-wrap)
- **L17.3** Seletor de status ligado ao banco
- **L17.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17.title', 'd17.meta', 'd17.status'), todos os ids de `kRef17.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@3x.png` no recorte da fase (y 432–654.44) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17w360` e `kRef17w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17.1 Título em duas fontes
- [ ] L17.2 Autor, ano e formato (flex-wrap)
- [ ] L17.3 Seletor de status ligado ao banco
- [ ] L17.4 Verificação + relatório
- [ ] Geometria 11/11 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
