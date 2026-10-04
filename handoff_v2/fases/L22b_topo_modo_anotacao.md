# FASE L22b — Modo anotação — pílula do modo e Concluir

> Tela 22 · prancha `22_modo_anotacao` (22 · Leitor — modo anotação, canvas 390×844) · executada na **G16** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L22b_topo_modo_anotacao@3x.png` · `referencia/png/redline/L22b_topo_modo_anotacao_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/22_modo_anotacao_390x844@{1,2,3}x.png` · `referencia/layout/layout_22_modo_anotacao.json` · `test/reference/leitor/reference_layout_22_modo_anotacao.dart` (`kRef22`).
> Arquivos sugeridos: `lib/features/reader/presentation/annotation_top_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Pílula "Modo anotação" à esquerda e botão verde "Concluir" à direita.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{ink}}` = padrão `#FF552E`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- Top: mode pill + done -->
<div style="position: absolute; left: 14px; top: 50px; height: 52px; padding: 0 16px 0 7px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px;">
  <span style="width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="19" height="19" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 20h4L19 9a2.8 2.8 0 0 0-4-4L4 16z"></path><path d="m13.5 6.5 4 4"></path></svg></span>
  <span>
    <span style="display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 15.5px; line-height: 1.1; letter-spacing: -0.2px; white-space: nowrap;">Modo anotação</span>
    <span style="display: block; margin-top: 2px; font-size: 11.5px; font-weight: 600; color: #5B544B; white-space: nowrap;">2 dedos movem a página</span>
  </span>
</div>

<button style="position: absolute; right: 14px; top: 50px; height: 52px; padding: 0 18px 0 14px; border-radius: 26px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 15px; font-weight: 800; color: #1A1714;"><svg width="19" height="19" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 12.5 4.5 4.5L19 7.5"></path></svg>Concluir</button>
```

## Especificação pixel a pixel

Seção `ann.modePill` — retângulo absoluto no canvas 390×844: **x=14, y=50, w=202.48, h=52**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `ann.modePill` ±1 | box | 0 | 0 | 202.48 | 52 | `position: absolute; left: 14px; top: 50px; height: 52px; padding: 0 16px 0 7px; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 9px` |  |
| 2 | `ann.modePill.iconCircle` | box | 8.5 | 7 | 38 | 38 | `width: 38px; height: 38px; flex-shrink: 0; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 3 | `ann.modePill.icon` | icon | 18 | 16.5 | 19 | 19 | `—` |  |
| 4 | `ann.modePill.texts` ±1 | box | 55.5 | 9.57 | 129.48 | 32.86 | `—` |  |
| 5 | `ann.modePill.title` ±1 | text | 55.5 | 9.57 | 129.48 | 17.05 | `display: block; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 15.5px; line-height: 1.1; letter-spacing: -0.2px; white-space: nowrap` | Bricolage (opsz 15.5) 15.5/17.05px peso 800 ls -0.2px #1A1714 |
| 6 | `ann.modePill.subtitle` ±1 | text | 55.5 | 28.62 | 129.48 | 13.81 | `display: block; margin-top: 2px; font-size: 11.5px; font-weight: 600; color: #5B544B; white-space: nowrap` | Figtree 11.5/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `ann.modePill.title` | 1 | Modo anotação | 23.21 | 55.5 | 171.75 | 116.25 |
| `ann.modePill.subtitle` | 1 | 2 dedos movem a página | 39.55 | 55.5 | 184.98 | 129.48 |

Seção `ann.done` — retângulo absoluto no canvas 390×844: **x=255.97, y=50, w=120.03, h=52**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 7 | `ann.done` ±1 | box+text | 0 | 0 | 120.03 | 52 | `position: absolute; right: 14px; top: 50px; height: 52px; padding: 0 18px 0 14px; border-radius: 26px; background: #ABCF82; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 7px; font-size: 15px; font-weight: 800; color: #1A1714` | Figtree 15/normal peso 800 ls normal #1A1714 |
| 8 | `ann.done.icon` ±1 | icon | 15.51 | 16.5 | 19 | 19 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `ann.done` | 1 | Concluir | 31.25 | 41.51 | 100.53 | 59.02 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Pílula: `left 14 · top 50`, altura 52, padding 0/16/0/7, raio 26, `#FFFAF1`, borda 1,5, sombra 3/3; círculo amarelo 38 com lápis 19; "Modo anotação" Bricolage 15,5/800 (lh 1,1, ls −0,2) + subtítulo Figtree 11,5/600 `#5B544B`.
2. Concluir: `right 14 · top 50`, altura 52, raio 26, `#ABCF82`, borda 1,5, sombra 3/3, ✓ 19 + Figtree 15/800.
3. O subtítulo muda com a ferramenta: "2 dedos movem a página" (caneta) · "Arraste entre as linhas" (Espaço, tela 24).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `ann.modePill.icon` |  |  | aria-hidden=true |
| `ann.done.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `ann.modePill` | NeoBox |  |
| `ann.modePill.iconCircle` | CircleIconButton / NeoBox circular |  |
| `ann.modePill.icon` | AppSvg(AppIconsLeitor.ic_pencil, size: 19) |  |
| `ann.done` | NeoBox + AppText |  |
| `ann.done.icon` | AppSvg(AppIconsLeitor.ic_check, size: 19) |  |

## Interações

- Concluir salva e volta ao leitor; Voltar do sistema = Concluir (D-42).

## Dados

- —

## Subfases

- **L22b.1** Pílula do modo
- **L22b.2** Concluir
- **L22b.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('ann.modePill', 'ann.done'), todos os ids de `kRef22.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/22_modo_anotacao_390x844@3x.png` no recorte da fase (y 42–110) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L22b.1 Pílula do modo
- [ ] L22b.2 Concluir
- [ ] L22b.3 Verificação + relatório
- [ ] Geometria 8/8 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
