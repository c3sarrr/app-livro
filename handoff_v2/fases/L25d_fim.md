# FASE L25d — Grifos e notas — fim da lista

> Tela 25 · prancha `25_grifos_notas` (25 · Grifos e notas (Dom Casmurro), canvas 390×2170) · executada na **G19** (trilha B do prompt v2).
> Referências: `referencia/png/secoes/L25d_fim@3x.png` · `referencia/png/redline/L25d_fim_redline@3x.png` (Nº = tabelas abaixo) · `referencia/png/25_grifos_notas_390x2170@{1,2,3}x.png` · `referencia/layout/layout_25_grifos_notas.json` · `test/reference/leitor/reference_layout_25_grifos_notas.dart` (`kRef25`).
> Arquivos sugeridos: `lib/features/highlights/presentation/highlights_end.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Cartão tracejado de fim: "Daqui para frente, / as margens ainda estão em branco." + botão "Continuar lendo · pág. 159".

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`.

```html
<!-- end of what was read -->
<div style="margin-top: 26px; padding: 18px 16px 16px; border-radius: 22px; border: 1.5px dashed #1A1714; text-align: center;">
  <p style="margin: 0; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 22px; line-height: 1.15;">Daqui para frente,<br>as margens ainda estão em branco.</p>
  <a href="#" style="margin-top: 14px; height: 52px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15.5px; font-weight: 800; color: #F7F0E3;"><span style="color: #F7F0E3;">Continuar lendo · pág. 159</span></a>
</div>
```

## Especificação pixel a pixel

Seção `hl.end` — retângulo absoluto no canvas 390×2170: **x=16, y=2117.98, w=358, h=153.6**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `hl.end` | box | 0 | 0 | 358 | 153.6 | `margin-top: 26px; padding: 18px 16px 16px; border-radius: 22px; border: 1.5px dashed #1A1714; text-align: center` |  |
| 2 | `hl.end.text` | text | 17.5 | 19.5 | 323 | 50.6 | `margin: 0; font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-size: 22px; line-height: 1.15` | Instrument Serif itálico 22/25.3px peso 400 ls normal #1A1714 |
| 3 | `hl.end.cta` | box | 17.5 | 84.1 | 323 | 52 | `margin-top: 14px; height: 52px; border-radius: 999px; background: #1A1714; display: flex; align-items: center; justify-content: center; gap: 8px; font-size: 15.5px; font-weight: 800; color: #F7F0E3` |  |
| 4 | `hl.end.cta.label` ±1 | text | 85.68 | 100.8 | 186.63 | 18.61 | `color: #F7F0E3` | Figtree 15.5/normal peso 800 ls normal #F7F0E3 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `hl.end.text` | 1 | Daqui para frente, | 39.63 | 106.05 | 251.95 | 145.9 |
| `hl.end.text` | 2 | as margens ainda estão em branco. | 64.93 | 40.19 | 317.81 | 277.62 |
| `hl.end.cta.label` | 1 | Continuar lendo · pág. 159 *(oculta: recortada)* | 115.53 | 85.68 | 272.32 | 186.64 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cartão tracejado 1,5 raio 22, centralizado; frase em Instrument Serif itálico 22 com quebra forçada (`<br>`); botão preto 52 de altura com ícone e rótulo `#F7F0E3`.
2. ⚠ Na prancha (2170) o cartão aparece só até 2170 e o botão (y 2202–2254) fica **fora** — as medidas existem, mas não há referência visual do botão.

## Armadilhas

- Linhas recortadas por `overflow` (existem no layout, não aparecem): `hl.end.cta.label`.

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `hl.end` | NeoBox |  |
| `hl.end.cta` | NeoBox |  |

## Interações

- Continuar lendo → leitor na posição atual.

## Dados

- Página atual (159).

## Subfases

- **L25d.1** Cartão final
- **L25d.2** Botão
- **L25d.3** Verificação + relatório (visual só até 2170)

## Testes da fase

- Geometria: para cada seção ('hl.end'), todos os ids de `kRef25.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `referencia/png/25_grifos_notas_390x2170@3x.png` no recorte da fase (y 2109.98–2170) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L25d.1 Cartão final
- [ ] L25d.2 Botão
- [ ] L25d.3 Verificação + relatório (visual só até 2170)
- [ ] Geometria 4/4 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
