# FASE L20c — Leitor com controles — chip de tempo

> Tela 20 · prancha `20_leitor_controles` (20 · Leitor — com controles, canvas 390×844) · executada na **G12** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L20c_chip_tempo@3x.png` · `referencia/png/redline/L20c_chip_tempo_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/20_leitor_controles_390x844@{1,2,3}x.png` · `referencia/layout/layout_20_leitor_controles.json` · `test/reference/leitor/reference_layout_20_leitor_controles.dart` (`kRef20`).
> Arquivos sugeridos: `lib/features/reader/presentation/time_chip.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Chip amarelo "18 min hoje · contando sozinho" logo abaixo da ilha superior ("e-book time counts by itself").

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- e-book time counts by itself -->
<span style="position: absolute; left: 50%; top: 130px; transform: translateX(-50%); height: 30px; padding: 0 12px 0 9px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; white-space: nowrap;"><svg width="15" height="15" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="13.5" r="7.5"></circle><path d="M12 9.5v4l2.5 1.5"></path><path d="M10 2.5h4"></path></svg>18 min hoje · contando sozinho</span>
```

## Especificação pixel a pixel

Seção `r20.timeChip` — retângulo absoluto no canvas 390×844: **x=195, y=130, w=221.95, h=30**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `r20.timeChip` ±1 | box+text | 0 | 0 | 221.95 | 30 | `position: absolute; left: 50%; top: 130px; transform: translateX(-50%); height: 30px; padding: 0 12px 0 9px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; white-space: nowrap` | Figtree 12.5/normal peso 800 ls normal #1A1714 |
| 2 | `r20.timeChip.icon` | icon | 10.5 | 7.5 | 15 | 15 | `—` |  |

**Transforms (o retângulo da tabela é o de layout; o desenho fica na caixa visual):**
- `r20.timeChip`: caixa visual com `transform: translateX(-50%)` = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).
- `r20.timeChip.icon`: caixa visual deslocada pelo transform de um ancestral = x {fmt(v[0] - sr[0])}, y {fmt(v[1] - sr[1])}, w {fmt(v[2])}, h {fmt(v[3])} (relativa à seção).

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `r20.timeChip` | 1 | 18 min hoje · contando sozinho | 19.38 | 31.5 | 208.45 | 176.95 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Centralizado no canvas (`left 50% · translateX(-50%)`), `top 130`, altura 30, padding 0/12/0/9, raio 999, `#FED170`, borda 1,5; cronômetro 15 + texto Figtree 12,5/800 `nowrap`. Largura vem do texto (221,95) → posição horizontal depende do texto (±1,0).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `r20.timeChip.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `r20.timeChip` | Pill / CountBadge (NeoBox com raio de pílula + AppText) | Transform: translateX(-50%) |
| `r20.timeChip.icon` | AppSvg(AppIconsLeitor.ic_timer, size: 15) |  |

## Interações

- Sem toque (informativo).

## Dados

- Minutos de hoje = soma das sessões de hoje no fuso do usuário, incluindo a sessão aberta (D-27); "18 min" = mesmo número do cartão "Seu dia" da Início.

## Subfases

- **L20c.1** Chip
- **L20c.2** Texto derivado e atualização ao vivo
- **L20c.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('r20.timeChip'), todos os ids de `kRef20.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/20_leitor_controles_390x844@3x.png` no recorte da fase (y 122–168) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L20c.1 Chip
- [ ] L20c.2 Texto derivado e atualização ao vivo
- [ ] L20c.3 Verificação + relatório
- [ ] Geometria 2/2 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
