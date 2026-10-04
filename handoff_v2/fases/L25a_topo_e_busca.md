# FASE L25a — Grifos e notas — topo, título e busca

> Tela 25 · prancha `25_grifos_notas` (25 · Grifos e notas (Dom Casmurro), canvas 390×2170) · executada na **G19** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L25a_topo_e_busca@3x.png` · `referencia/png/redline/L25a_topo_e_busca_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/25_grifos_notas_390x2170@{1,2,3}x.png` · `referencia/layout/layout_25_grifos_notas.json` · `test/reference/leitor/reference_layout_25_grifos_notas.dart` (`kRef25`).
> Arquivos sugeridos: `lib/features/highlights/presentation/highlights_screen.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Tela própria "Grifos e notas" (rola): barra do topo, título, subtítulo e busca.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- top bar -->
<div style="position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between;">
  <a href="#" aria-label="Voltar ao livro" style="width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M19 12H5"></path><path d="m11 6-6 6 6 6"></path></svg></a>
  <button aria-label="Exportar grifos e notas" style="height: 48px; padding: 0 16px 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800;"><svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 15V3M7.5 7.5 12 3l4.5 4.5"></path><path d="M5 12v7a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-7"></path></svg>Exportar</button>
</div>

<svg aria-hidden="true" width="22" height="22" sc-camel-view-box="0 0 24 24" style="position: absolute; left: 318px; top: 128px;"><path d="M12 1.5C12.4 7.2 13.6 10.9 22.5 12 13.6 13.1 12.4 16.8 12 22.5 11.6 16.8 10.4 13.1 1.5 12 10.4 10.9 11.6 7.2 12 1.5Z" fill="#FED170" stroke="#1A1714" stroke-width="1.4" stroke-linejoin="round"></path></svg>

<h1 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1px;">Grifos <span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px;">e notas</span></h1>

<p style="margin: 6px 0 0; font-size: 14px; font-weight: 600; color: #5B544B;"><strong style="font-weight: 800; color: #1A1714;">Dom Casmurro</strong> · na ordem do livro</p>

<!-- search -->
<label style="margin-top: 16px; height: 48px; padding: 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px;">
  <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#6F665B" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>
  <input type="search" placeholder="Buscar nos grifos e notas" aria-label="Buscar nos grifos e notas" style="flex-grow: 1; min-width: 0; height: 100%; border: none; outline: none; background: transparent; font-size: 15px; font-weight: 600; color: #1A1714;">
</label>
```

## Especificação pixel a pixel

Seção `hl.topBar` — retângulo absoluto no canvas 390×2170: **x=16, y=54, w=358, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `hl.topBar` | box | 0 | 0 | 358 | 48 | `position: absolute; left: 16px; right: 16px; top: 54px; display: flex; justify-content: space-between` |  |
| 2 | `hl.topBar.back` | box | 0 | 0 | 48 | 48 | `width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `hl.topBar.back.icon` | icon | 14 | 14 | 20 | 20 | `—` |  |
| 4 | `hl.topBar.export` ±1 | box+text | 243.94 | 0 | 114.06 | 48 | `height: 48px; padding: 0 16px 0 13px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 2px 2px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 14px; font-weight: 800` | Figtree 14/normal peso 800 ls normal #1A1714 |
| 5 | `hl.topBar.export.icon` ±1 | icon | 258.44 | 15 | 18 | 18 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hl.topBar.export` | 1 | Exportar | 28.9 | 283.44 | 340.5 | 57.06 |

Seção `hl.sparkle` — retângulo absoluto no canvas 390×2170: **x=318, y=128, w=22, h=22**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 6 | `hl.sparkle` | icon | 0 | 0 | 22 | 22 | `position: absolute; left: 318px; top: 128px` |  |

Seção `hl.title` — retângulo absoluto no canvas 390×2170: **x=16, y=122, w=358, h=41.16**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 7 | `hl.title` | text | 0 | 0 | 358 | 41.16 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 34px; line-height: 0.98; letter-spacing: -1px` | Bricolage (opsz 34) 34/33.32px peso 800 ls -1px #1A1714 |
| 8 | `hl.title.serif` ±1 | inline | 101.22 | -6.72 | 102.24 | 54.6 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 42px; letter-spacing: -0.4px` | Instrument Serif itálico 42/41.16px peso 400 ls -0.4px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hl.title` *(composto)* | 1 | Grifos e notas | 34.86 | 0 | 203.46 | 203.46 |

Seção `hl.subtitle` — retângulo absoluto no canvas 390×2170: **x=16, y=169.16, w=358, h=16.8**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 9 | `hl.subtitle` | text | 0 | 0 | 358 | 16.8 | `margin: 6px 0 0; font-size: 14px; font-weight: 600; color: #5B544B` | Figtree 14/normal peso 600 ls normal #5B544B |
| 10 | `hl.subtitle.strong` ±1 | inline | 0 | 0 | 97.72 | 16.8 | `font-weight: 800; color: #1A1714` | Figtree 14/normal peso 800 ls normal #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hl.subtitle` *(composto)* | 1 | Dom Casmurro · na ordem do livro | 13.3 | 0 | 218.75 | 218.75 |

Seção `hl.search` — retângulo absoluto no canvas 390×2170: **x=16, y=201.96, w=358, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 11 | `hl.search` | box | 0 | 0 | 358 | 48 | `margin-top: 16px; height: 48px; padding: 0 16px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 10px` |  |
| 12 | `hl.search.icon` | icon | 17.5 | 14 | 20 | 20 | `—` |  |
| 13 | `hl.search.input` | box | 47.5 | 1.5 | 293 | 45 | `flex-grow: 1; min-width: 0; height: 100%; border: none; outline: none; background: transparent; font-size: 15px; font-weight: 600; color: #1A1714` |  |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Canvas 390 × 2170; o conteúdo vai até 2271,58 (achado: o fim da lista passa da prancha).
2. Topo: voltar 44 (seta) + pílula "⇪ Exportar" (48 de altura, sombra 2/2, Figtree 14/800). Estrela decorativa 22 ao lado do título.
3. Título "**Grifos** *e notas*": Bricolage 34/800 (lh 0,98, ls −1) + Instrument Serif itálico 42 na mesma linha (baselines alinhadas).
4. Subtítulo "**Dom Casmurro** · na ordem do livro" (Figtree 14/600 `#5B544B`, nome em 800 tinta); busca: pílula 48 `#FFFAF1` com lupa 20 e placeholder "Buscar nos grifos e notas".

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `hl.topBar.back` |  | Voltar ao livro |  |
| `hl.topBar.back.icon` |  |  | aria-hidden=true |
| `hl.topBar.export` |  | Exportar grifos e notas |  |
| `hl.topBar.export.icon` |  |  | aria-hidden=true |
| `hl.sparkle` |  |  | aria-hidden=true |
| `hl.search.icon` |  |  | aria-hidden=true |
| `hl.search.input` |  | Buscar nos grifos e notas |  |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `hl.topBar.back` | CircleIconButton / NeoBox circular |  |
| `hl.topBar.back.icon` | AppSvg(AppIconsLeitor.ic_arrow_left, size: 20) |  |
| `hl.topBar.export` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hl.topBar.export.icon` | AppSvg(AppIconsLeitor.ic_share, size: 18) |  |
| `hl.sparkle` | AppSvg(AppIconsLeitor.ic_star_deco, size: 22) |  |
| `hl.title.serif` | TextSpan dentro do AppText.rich do pai |  |
| `hl.subtitle.strong` | TextSpan dentro do AppText.rich do pai |  |
| `hl.search` | NeoBox |  |
| `hl.search.icon` | AppSvg(AppIconsLeitor.ic_search_cinza, size: 20) |  |

## Interações

- Voltar → leitor; Exportar → regra do plano (D-24); busca FTS5 local em texto do grifo + nota.

## Dados

- Livro atual; consulta de busca.

## Subfases

- **L25a.1** Topo
- **L25a.2** Título misto
- **L25a.3** Subtítulo + busca
- **L25a.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('hl.topBar', 'hl.sparkle', 'hl.title', 'hl.subtitle', 'hl.search'), todos os ids de `kRef25.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/25_grifos_notas_390x2170@3x.png` no recorte da fase (y 46–257.96) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L25a.1 Topo
- [ ] L25a.2 Título misto
- [ ] L25a.3 Subtítulo + busca
- [ ] L25a.4 Verificação + relatório
- [ ] Geometria 11/11 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
