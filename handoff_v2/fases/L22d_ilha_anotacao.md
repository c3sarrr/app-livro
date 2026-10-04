# FASE L22d — Modo anotação — ilha (cor, espessura, desfazer)

> Tela 22 · prancha `22_modo_anotacao` (22 · Leitor — modo anotação, canvas 390×844) · executada na **G16** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L22d_ilha_anotacao@3x.png` · `referencia/png/redline/L22d_ilha_anotacao_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/22_modo_anotacao_390x844@{1,2,3}x.png` · `referencia/layout/layout_22_modo_anotacao.json` · `test/reference/leitor/reference_layout_22_modo_anotacao.dart` (`kRef22`).
> Arquivos sugeridos: `lib/features/reader/presentation/annotation_bar.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

"Barra de anotação": rótulos das ferramentas, poço de cor, espessura, desfazer/refazer.

---

## HTML literal da seção

Props do componente: `{{paper}}` = padrão `#F8F1E4`, `{{ink}}` = padrão `#FF552E`, `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- Bottom island (thumb zone) -->
<section aria-label="Barra de anotação" style="position: absolute; left: 14px; right: 14px; bottom: 30px; height: 90px; padding: 5px 12px 0; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box;">
  <div aria-hidden="true" style="width: 312px; margin: 0 auto; display: grid; grid-template-columns: repeat(6, 52px);"><span style="display: flex; justify-content: center;"><span style="height: 19px; padding: 0 7px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 10px; font-weight: 800; color: #1A1714;">Caneta</span></span><span style="display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap;">Marcador</span><span style="display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap;">Borracha</span><span style="display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap;">Laço</span><span style="display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap;">Reta</span><span style="display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap;">Espaço</span></div>
  <div style="margin-top: 7px; padding-top: 7px; border-top: 1.5px dashed #CFC3AE; display: flex; align-items: center; gap: 10px;">
    <!-- colour well: current ink inside, ring opens the full wheel -->
    <button aria-label="Cor da caneta: coral. Toque para escolher qualquer cor" style="width: 42px; height: 42px; flex-shrink: 0; padding: 0; border-radius: 50%; background: conic-gradient(#FF552E, #F2A815, #FED170, #ABCF82, #00995E, #058CD7, #B6ACE4, #552CB7, #FFC1C6, #FF552E); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><span style="width: 27px; height: 27px; border-radius: 50%; background: {{ink}}; border: 1.5px solid #1A1714; box-shadow: 0 0 0 2.5px #FFFAF1; box-sizing: border-box;"></span></button>
    <!-- stroke size -->
    <div role="radiogroup" aria-label="Espessura do traço" style="height: 42px; padding: 0 2px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 1px;">
      <button role="radio" aria-checked="false" aria-label="Fina" style="width: 36px; height: 36px; padding: 0; border-radius: 50%; border: 1.5px solid transparent; background: transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><span style="width: 5px; height: 5px; border-radius: 50%; background: {{ink}}; box-shadow: 0 0 0 1px #1A1714;"></span></button>
      <button role="radio" aria-checked="true" aria-label="Média" style="width: 36px; height: 36px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; background: {{brand}}; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><span style="width: 9px; height: 9px; border-radius: 50%; background: {{ink}}; box-shadow: 0 0 0 1.2px #1A1714;"></span></button>
      <button role="radio" aria-checked="false" aria-label="Grossa" style="width: 36px; height: 36px; padding: 0; border-radius: 50%; border: 1.5px solid transparent; background: transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><span style="width: 14px; height: 14px; border-radius: 50%; background: {{ink}}; box-shadow: 0 0 0 1.4px #1A1714;"></span></button>
    </div>
    <span style="flex-grow: 1;"></span>
    <button aria-label="Desfazer" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 14 4 9l5-5"></path><path d="M4 9h10.5a5.5 5.5 0 0 1 0 11H11"></path></svg></button>
    <button aria-label="Refazer" aria-disabled="true" style="width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; opacity: 0.38;"><svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m15 14 5-5-5-5"></path><path d="M20 9H9.5a5.5 5.5 0 0 0 0 11H13"></path></svg></button>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `ann.island` — retângulo absoluto no canvas 390×844: **x=14, y=724, w=362, h=90**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `ann.island` | box | 0 | 0 | 362 | 90 | `position: absolute; left: 14px; right: 14px; bottom: 30px; height: 90px; padding: 5px 12px 0; border-radius: 26px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 3px 3px 0 #1A1714; box-sizing: border-box` |  |
| 2 | `ann.island.labels` | box | 25 | 6.5 | 312 | 19 | `width: 312px; margin: 0 auto; display: grid; grid-template-columns: repeat(6, 52px)` |  |
| 3 | `ann.island.labels.pen` | box | 25 | 6.5 | 52 | 19 | `display: flex; justify-content: center` |  |
| 4 | `ann.island.labels.pen.pill` ±1 | box+text | 25.79 | 6.5 | 50.42 | 19 | `height: 19px; padding: 0 7px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; font-size: 10px; font-weight: 800; color: #1A1714` | Figtree 10/normal peso 800 ls normal #1A1714 |
| 5 | `ann.island.labels.marker` | text | 77 | 6.5 | 52 | 19 | `display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap` | Figtree 10/normal peso 700 ls normal #6F665B |
| 6 | `ann.island.labels.eraser` | text | 129 | 6.5 | 52 | 19 | `display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap` | Figtree 10/normal peso 700 ls normal #6F665B |
| 7 | `ann.island.labels.lasso` | text | 181 | 6.5 | 52 | 19 | `display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap` | Figtree 10/normal peso 700 ls normal #6F665B |
| 8 | `ann.island.labels.line` | text | 233 | 6.5 | 52 | 19 | `display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap` | Figtree 10/normal peso 700 ls normal #6F665B |
| 9 | `ann.island.labels.space` | text | 285 | 6.5 | 52 | 19 | `display: flex; justify-content: center; align-items: center; height: 19px; font-size: 10px; font-weight: 700; color: #6F665B; white-space: nowrap` | Figtree 10/normal peso 700 ls normal #6F665B |
| 10 | `ann.island.row` | box | 13.5 | 32.5 | 335 | 52.5 | `margin-top: 7px; padding-top: 7px; border-top: 1.5px dashed #CFC3AE; display: flex; align-items: center; gap: 10px` |  |
| 11 | `ann.island.colorWell` | box | 13.5 | 42 | 42 | 42 | `width: 42px; height: 42px; flex-shrink: 0; padding: 0; border-radius: 50%; background: conic-gradient(#FF552E, #F2A815, #FED170, #ABCF82, #00995E, #058CD7, #B6ACE4, #552CB7, #FFC1C6, #FF552E); border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 12 | `ann.island.colorWell.ink` | box | 21 | 49.5 | 27 | 27 | `width: 27px; height: 27px; border-radius: 50%; background: {{ink}} (padrão #FF552E); border: 1.5px solid #1A1714; box-shadow: 0 0 0 2.5px #FFFAF1; box-sizing: border-box` |  |
| 13 | `ann.island.width` | box | 65.5 | 42 | 117 | 42 | `height: 42px; padding: 0 2px; border-radius: 999px; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; gap: 1px` |  |
| 14 | `ann.island.width.thin` | box | 69 | 45 | 36 | 36 | `width: 36px; height: 36px; padding: 0; border-radius: 50%; border: 1.5px solid transparent; background: transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 15 | `ann.island.width.thin.dot` | box | 84.5 | 60.5 | 5 | 5 | `width: 5px; height: 5px; border-radius: 50%; background: {{ink}} (padrão #FF552E); box-shadow: 0 0 0 1px #1A1714` |  |
| 16 | `ann.island.width.medium` | box | 106 | 45 | 36 | 36 | `width: 36px; height: 36px; padding: 0; border-radius: 50%; border: 1.5px solid #1A1714; background: {{brand}} (padrão #B6ACE4); box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 17 | `ann.island.width.medium.dot` | box | 119.5 | 58.5 | 9 | 9 | `width: 9px; height: 9px; border-radius: 50%; background: {{ink}} (padrão #FF552E); box-shadow: 0 0 0 1.2px #1A1714` |  |
| 18 | `ann.island.width.thick` | box | 143 | 45 | 36 | 36 | `width: 36px; height: 36px; padding: 0; border-radius: 50%; border: 1.5px solid transparent; background: transparent; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 19 | `ann.island.width.thick.dot` | box | 154 | 56 | 14 | 14 | `width: 14px; height: 14px; border-radius: 50%; background: {{ink}} (padrão #FF552E); box-shadow: 0 0 0 1.4px #1A1714` |  |
| 20 | `ann.island.spacer` | box | 192.5 | 63 | 48 | 0 | `flex-grow: 1` |  |
| 21 | `ann.island.undo` | box | 250.5 | 41 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 22 | `ann.island.undo.icon` | icon | 262.5 | 53 | 20 | 20 | `—` |  |
| 23 | `ann.island.redo` | box | 304.5 | 41 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; padding: 0; border-radius: 50%; background: #F7F0E3; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; opacity: 0.38` |  |
| 24 | `ann.island.redo.icon` | icon | 316.5 | 53 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `ann.island.labels.pen.pill` | 1 | Caneta | 19.5 | 34.29 | 67.71 | 33.42 |
| `ann.island.labels.marker` | 1 | Marcador | 19.5 | 80.98 | 125.01 | 44.03 |
| `ann.island.labels.eraser` | 1 | Borracha | 19.5 | 134.34 | 175.66 | 41.32 |
| `ann.island.labels.lasso` | 1 | Laço | 19.5 | 196.01 | 217.99 | 21.98 |
| `ann.island.labels.line` | 1 | Reta | 19.5 | 248.38 | 269.62 | 21.24 |
| `ann.island.labels.space` | 1 | Espaço | 19.5 | 294.42 | 327.58 | 33.16 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Ilha: `left/right 14 · bottom 30`, altura 90, padding 5/12/0, raio 26, `#FFFAF1`, borda 1,5, sombra 3/3.
2. Rótulos (grade de 6 × 52 = 312, centralizada): Figtree 10/700 `#6F665B`; o ativo vira pílula `brand` (altura 19, borda 1,5, Figtree 10/800).
3. Linha de controles (separador tracejado `#CFC3AE`): poço de cor 42 (anel cônico arco-íris, miolo 27 na cor da tinta com aro `#FFFAF1` 2,5) · espessura (`radiogroup`, cápsula `#F7F0E3` com 3 botões 36: pontos 5/9/14 na cor da tinta; Média ativa com fundo `brand`) · espaço flexível · Desfazer e Refazer 44 (`#F7F0E3`; Refazer com `aria-disabled` e opacidade 0,38).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `ann.island` |  | Barra de anotação |  |
| `ann.island.labels` |  |  | aria-hidden=true |
| `ann.island.colorWell` |  | Cor da caneta: coral. Toque para escolher qualquer cor |  |
| `ann.island.width` | radiogroup | Espessura do traço |  |
| `ann.island.width.thin` | radio | Fina | aria-checked=false |
| `ann.island.width.medium` | radio | Média | aria-checked=true |
| `ann.island.width.thick` | radio | Grossa | aria-checked=false |
| `ann.island.undo` |  | Desfazer |  |
| `ann.island.undo.icon` |  |  | aria-hidden=true |
| `ann.island.redo` |  | Refazer | aria-disabled=true |
| `ann.island.redo.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `ann.island` | NeoBox |  |
| `ann.island.labels.pen.pill` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `ann.island.row` | NeoBox |  |
| `ann.island.colorWell` | ConicRingPainter (anel arco-íris) |  |
| `ann.island.colorWell.ink` | CircleIconButton / NeoBox circular |  |
| `ann.island.width` | NeoBox |  |
| `ann.island.width.thin` | CircleIconButton / NeoBox circular |  |
| `ann.island.width.thin.dot` | CircleIconButton / NeoBox circular |  |
| `ann.island.width.medium` | CircleIconButton / NeoBox circular |  |
| `ann.island.width.medium.dot` | CircleIconButton / NeoBox circular |  |
| `ann.island.width.thick` | CircleIconButton / NeoBox circular |  |
| `ann.island.width.thick.dot` | CircleIconButton / NeoBox circular |  |
| `ann.island.undo` | CircleIconButton / NeoBox circular |  |
| `ann.island.undo.icon` | AppSvg(AppIconsLeitor.ic_undo, size: 20) |  |
| `ann.island.redo` | CircleIconButton / NeoBox circular |  |
| `ann.island.redo.icon` | AppSvg(AppIconsLeitor.ic_redo, size: 20) |  |

## Interações

- Poço de cor → painel da ferramenta (23/23b); espessura muda o preset; desfazer/refazer na pilha (`undo_stack`).

## Dados

- `pen_presets` (cor, espessura); pilha de desfazer da sessão.

## Subfases

- **L22d.1** Ilha e rótulos
- **L22d.2** Poço de cor
- **L22d.3** Espessura
- **L22d.4** Desfazer/Refazer (estado desabilitado)
- **L22d.5** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('ann.island'), todos os ids de `kRef22.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/22_modo_anotacao_390x844@3x.png` no recorte da fase (y 716–822) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L22d.1 Ilha e rótulos
- [ ] L22d.2 Poço de cor
- [ ] L22d.3 Espessura
- [ ] L22d.4 Desfazer/Refazer (estado desabilitado)
- [ ] L22d.5 Verificação + relatório
- [ ] Geometria 24/24 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
