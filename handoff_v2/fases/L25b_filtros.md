# FASE L25b — Grifos e notas — filtros de tipo e cor

> Tela 25 · prancha `25_grifos_notas` (25 · Grifos e notas (Dom Casmurro), canvas 390×2170) · executada na **G19** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L25b_filtros@3x.png` · `referencia/png/redline/L25b_filtros_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/25_grifos_notas_390x2170@{1,2,3}x.png` · `referencia/layout/layout_25_grifos_notas.json` · `test/reference/leitor/reference_layout_25_grifos_notas.dart` (`kRef25`).
> Arquivos sugeridos: `lib/features/highlights/presentation/highlight_filters.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Filtros de tipo (exclusivos, rolam na horizontal) e de cor (múltiplos) + "Só do clube".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- type -->
<div role="radiogroup" aria-label="Tipo" style="margin: 12px -16px 0; padding: 0 16px 4px; display: flex; gap: 8px; overflow: hidden; -webkit-mask-image: linear-gradient(90deg, #000 85%, transparent); mask-image: linear-gradient(90deg, #000 85%, transparent);"><button role="radio" aria-checked="true" style="height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: {{brand}}; box-shadow: 2px 2px 0 #1A1714;">Tudo <span style="font-weight: 700; color: #1A1714;">12</span></button><button role="radio" aria-checked="false" style="height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1;">Grifos <span style="font-weight: 700; color: #8A8073;">6</span></button><button role="radio" aria-checked="false" style="height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1;">Notas <span style="font-weight: 700; color: #8A8073;">2</span></button><button role="radio" aria-checked="false" style="height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1;">À mão <span style="font-weight: 700; color: #8A8073;">1</span></button><button role="radio" aria-checked="false" style="height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1;">Desenhos <span style="font-weight: 700; color: #8A8073;">3</span></button></div>

<!-- colour + club -->
<div style="margin-top: 10px; display: flex; align-items: center; gap: 8px;">
  <div role="group" aria-label="Filtrar por cor" style="height: 44px; padding: 0 7px 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px;">
    <span style="margin-right: 2px; font-size: 11px; font-weight: 800; letter-spacing: 1px; color: #6F665B;">COR</span><button role="checkbox" aria-checked="false" aria-label="Amarelo" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FED170;"></button><button role="checkbox" aria-checked="false" aria-label="Rosa" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FFC1C6;"></button><button role="checkbox" aria-checked="false" aria-label="Verde" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #ABCF82;"></button><button role="checkbox" aria-checked="false" aria-label="Lavanda" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #B6ACE4;"></button><button role="checkbox" aria-checked="false" aria-label="Tinta coral" style="width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FF552E;"></button>
  </div>
  <button role="switch" aria-checked="false" style="height: 44px; padding: 0 12px 0 9px; flex-grow: 1; min-width: 0; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800; white-space: nowrap;"><span style="width: 26px; height: 26px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="15" height="15" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="8" r="3.2"></circle><path d="M3.5 19c.6-3.4 2.8-5.2 5.5-5.2s4.9 1.8 5.5 5.2"></path><circle cx="16.5" cy="9" r="2.6"></circle><path d="M15.5 13.9c2.6-.3 4.5 1.4 5 4.6"></path></svg></span>Só do clube</button>
</div>
```

## Especificação pixel a pixel

Seção `hl.types` — retângulo absoluto no canvas 390×2170: **x=0, y=261.96, w=390, h=44**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `hl.types` | box | 0 | 0 | 390 | 44 | `margin: 12px -16px 0; padding: 0 16px 4px; display: flex; gap: 8px; overflow: hidden; -webkit-mask-image: linear-gradient(90deg, #000 85%, transparent); mask-image: linear-gradient(90deg, #000 85%, transparent)` |  |
| 2 | `hl.types.all` ±1 | box+text | 16 | 0 | 81.83 | 40 | `height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: {{brand}} (padrão #B6ACE4); box-shadow: 2px 2px 0 #1A1714` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 3 | `hl.types.all.count` ±1 | text | 68.82 | 11.9 | 13.51 | 16.21 | `font-weight: 700; color: #1A1714` | Figtree 13.5/normal peso 700 ls normal #1A1714 |
| 4 | `hl.types.highlights` ±1 | box+text | 105.83 | 0 | 83.41 | 40 | `height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 5 | `hl.types.highlights.count` ±1 | text | 165.92 | 11.9 | 7.83 | 16.21 | `font-weight: 700; color: #8A8073` | Figtree 13.5/normal peso 700 ls normal #8A8073 |
| 6 | `hl.types.notes` ±1 | box+text | 197.25 | 0 | 82.29 | 40 | `height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 7 | `hl.types.notes.count` ±1 | text | 256.22 | 11.9 | 7.82 | 16.21 | `font-weight: 700; color: #8A8073` | Figtree 13.5/normal peso 700 ls normal #8A8073 |
| 8 | `hl.types.handwritten` ±1 | box+text | 287.54 | 0 | 82.74 | 40 | `height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 9 | `hl.types.handwritten.count` ±1 | text | 349.08 | 11.9 | 5.7 | 16.21 | `font-weight: 700; color: #8A8073` | Figtree 13.5/normal peso 700 ls normal #8A8073 |
| 10 | `hl.types.drawings` ±1 | box+text | 378.28 | 0 | 105.43 | 40 | `height: 40px; padding: 0 14px; flex-shrink: 0; border-radius: 999px; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap; background: #FFFAF1` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 11 | `hl.types.drawings.count` ±1 | text | 460.7 | 11.9 | 7.51 | 16.21 | `font-weight: 700; color: #8A8073` | Figtree 13.5/normal peso 700 ls normal #8A8073 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hl.types.all` | 1 | Tudo | 24.73 | 31.5 | 62.82 | 31.32 |
| `hl.types.all.count` | 1 | 12 | 24.73 | 68.82 | 82.33 | 13.51 |
| `hl.types.highlights` | 1 | Grifos | 24.73 | 121.33 | 159.92 | 38.59 |
| `hl.types.highlights.count` | 1 | 6 | 24.73 | 165.92 | 173.75 | 7.83 |
| `hl.types.notes` | 1 | Notas | 24.73 | 212.75 | 250.22 | 37.47 |
| `hl.types.notes.count` | 1 | 2 | 24.73 | 256.22 | 264.04 | 7.82 |
| `hl.types.handwritten` | 1 | À mão | 24.73 | 303.04 | 343.08 | 40.04 |
| `hl.types.handwritten.count` | 1 | 1 | 24.73 | 349.08 | 354.78 | 5.7 |
| `hl.types.drawings` | 1 | Desenhos *(oculta: recortada)* | 24.73 | 393.78 | 454.7 | 60.92 |
| `hl.types.drawings.count` | 1 | 3 *(oculta: recortada)* | 24.73 | 460.7 | 468.21 | 7.51 |

Seção `hl.filters` — retângulo absoluto no canvas 390×2170: **x=16, y=315.96, w=358, h=44**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 12 | `hl.filters` | box | 0 | 0 | 358 | 44 | `margin-top: 10px; display: flex; align-items: center; gap: 8px` |  |
| 13 | `hl.filters.colors` ±1 | box | 0 | 0 | 215.9 | 44 | `height: 44px; padding: 0 7px 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 5px` |  |
| 14 | `hl.filters.colors.label` ±1 | text | 13.5 | 15.4 | 26.9 | 13.2 | `margin-right: 2px; font-size: 11px; font-weight: 800; letter-spacing: 1px; color: #6F665B` | Figtree 11/normal peso 800 ls 1px #6F665B |
| 15 | `hl.filters.colors.yellow` ±1 | box | 47.4 | 8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FED170` |  |
| 16 | `hl.filters.colors.pink` ±1 | box | 80.4 | 8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FFC1C6` |  |
| 17 | `hl.filters.colors.green` ±1 | box | 113.4 | 8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #ABCF82` |  |
| 18 | `hl.filters.colors.lavender` ±1 | box | 146.4 | 8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #B6ACE4` |  |
| 19 | `hl.filters.colors.coral` ±1 | box | 179.4 | 8 | 28 | 28 | `width: 28px; height: 28px; flex-shrink: 0; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box; background: #FF552E` |  |
| 20 | `hl.filters.clubOnly` ±1 | box+text | 223.9 | 0 | 134.1 | 44 | `height: 44px; padding: 0 12px 0 9px; flex-grow: 1; min-width: 0; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 6px; font-size: 13px; font-weight: 800; white-space: nowrap` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 21 | `hl.filters.clubOnly.circle` ±1 | box | 238.52 | 9 | 26 | 26 | `width: 26px; height: 26px; flex-shrink: 0; border-radius: 50%; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 22 | `hl.filters.clubOnly.icon` ±1 | icon | 244.02 | 14.5 | 15 | 15 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hl.filters.colors.label` | 1 | COR | 25.85 | 13.5 | 40.4 | 26.9 |
| `hl.filters.clubOnly` | 1 | Só do clube | 26.55 | 270.52 | 340.38 | 69.86 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Tipo (`radiogroup`): faixa `overflow: hidden` com **máscara** horizontal (preto até 85 % → transparente) → `ShaderMask`; o 5º chip ("Desenhos 3") fica cortado na borda.
2. Chips 40 de altura, raio 999, borda 1,5; ativo "Tudo 12" com fundo `brand`; contadores em Figtree 700 `#8A8073`.
3. Cor: "COR" + 5 caixas de seleção redondas (amarelo, rosa, verde, lavanda, tinta coral) + interruptor "Só do clube" (ícone de pessoas).

## Armadilhas

- `hl.types` tem máscara `linear-gradient(90deg, #000000 85%, #000000@0)` → `ShaderMask`.
- Linhas recortadas por `overflow` (existem no layout, não aparecem): `hl.types.drawings`, `hl.types.drawings.count`.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `hl.types` | radiogroup | Tipo |  |
| `hl.types.all` | radio |  | aria-checked=true |
| `hl.types.highlights` | radio |  | aria-checked=false |
| `hl.types.notes` | radio |  | aria-checked=false |
| `hl.types.handwritten` | radio |  | aria-checked=false |
| `hl.types.drawings` | radio |  | aria-checked=false |
| `hl.filters.colors` | group | Filtrar por cor |  |
| `hl.filters.colors.yellow` | checkbox | Amarelo | aria-checked=false |
| `hl.filters.colors.pink` | checkbox | Rosa | aria-checked=false |
| `hl.filters.colors.green` | checkbox | Verde | aria-checked=false |
| `hl.filters.colors.lavender` | checkbox | Lavanda | aria-checked=false |
| `hl.filters.colors.coral` | checkbox | Tinta coral | aria-checked=false |
| `hl.filters.clubOnly` | switch |  | aria-checked=false |
| `hl.filters.clubOnly.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `hl.types.all` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hl.types.highlights` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hl.types.notes` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hl.types.handwritten` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hl.types.drawings` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hl.filters.colors` | NeoBox |  |
| `hl.filters.colors.yellow` | CircleIconButton / NeoBox circular |  |
| `hl.filters.colors.pink` | CircleIconButton / NeoBox circular |  |
| `hl.filters.colors.green` | CircleIconButton / NeoBox circular |  |
| `hl.filters.colors.lavender` | CircleIconButton / NeoBox circular |  |
| `hl.filters.colors.coral` | CircleIconButton / NeoBox circular |  |
| `hl.filters.clubOnly` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `hl.filters.clubOnly.circle` | CircleIconButton / NeoBox circular |  |
| `hl.filters.clubOnly.icon` | AppSvg(AppIconsLeitor.ic_people, size: 15) |  |

## Interações

- Tipo exclusivo; cores combináveis; "Só do clube" = itens com `shared_club_post_id`.

## Dados

- Contagens por tipo somam o total (6 + 2 + 1 + 3 = 12 = contador da tela 20).

## Subfases

- **L25b.1** Faixa de tipos com máscara
- **L25b.2** Cores
- **L25b.3** Só do clube
- **L25b.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('hl.types', 'hl.filters'), todos os ids de `kRef25.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/25_grifos_notas_390x2170@3x.png` no recorte da fase (y 253.96–367.96) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L25b.1 Faixa de tipos com máscara
- [ ] L25b.2 Cores
- [ ] L25b.3 Só do clube
- [ ] L25b.4 Verificação + relatório
- [ ] Geometria 22/22 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
