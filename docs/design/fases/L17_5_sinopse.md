# FASE L17 — Detalhes — Sinopse e ficha (páginas, ano, formato, ISBN)

> Tela 17 · prancha `017_detalhes_fisico` (17 · Detalhes do livro — físico (Brás Cubas), canvas 390×1940) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17_5_sinopse@3x.png` · `docs/design/medicao/projeto/png/redline/L17_5_sinopse_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017_detalhes_fisico.json` · `test/reference/projeto/reference_layout_017_detalhes_fisico.dart` (`kRef17`).
> Arquivos sugeridos: `lib/features/library/presentation/details/synopsis_section.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

A sinopse em Literata com "Ler mais" no fim do parágrafo e a ficha em 4 casas (páginas, publicado, formato, ISBN) entre duas linhas pretas, com divisórias tracejadas.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#ABCF82`, `{{shelf}}` = padrão `#FED170`.

```html
<section aria-label="Sinopse" style="margin-top: 30px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Sinopse</h2></div>
  <p style="margin: 10px 0 0; font-family: 'Literata', Georgia, serif; font-size: 15.5px; font-weight: 400; line-height: 1.6; color: #2B2621;">Depois de morto, Brás Cubas resolve contar a própria vida, com franqueza, ironia e muitas digressões. Um “defunto autor” revisita amores, vaidades e fracassos da elite carioca do século XIX. <a href="#" style="font-family: 'Figtree', sans-serif; font-size: 14px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px;">Ler mais</a></p>
  <div style="margin-top: 14px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 0; border-top: 1.5px solid #1A1714; border-bottom: 1.5px solid #1A1714;"><div style="padding: 10px 0;  "><div style="font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B;">PÁGINAS</div><div style="margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums;">208</div></div><div style="padding: 10px 0; border-left: 1.5px dashed #CFC3AE; padding-left: 14px; "><div style="font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B;">PUBLICADO</div><div style="margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums;">1881</div></div><div style="padding: 10px 0;  border-top: 1.5px dashed #CFC3AE;"><div style="font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B;">FORMATO</div><div style="margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums;">Brochura</div></div><div style="padding: 10px 0; border-left: 1.5px dashed #CFC3AE; padding-left: 14px; border-top: 1.5px dashed #CFC3AE;"><div style="font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B;">ISBN</div><div style="margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums;">978-65-5921-104-3</div></div></div>
</section>
```

## Especificação pixel a pixel

Seção `d17.synopsis` — retângulo absoluto no canvas 390×1940: **x=20, y=1222.84, w=350, h=283.17**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17.synopsis` | box | 0 | 0 | 350 | 283.17 | `margin-top: 30px` |  |
| 2 | `d17.synopsis.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 3 | `d17.synopsis.title` ±1 | text | 0 | 0 | 76.55 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 4 | `d17.synopsis.text` | text | 0 | 34 | 350 | 124.63 | `margin: 10px 0 0; font-family: 'Literata', Georgia, serif; font-size: 15.5px; font-weight: 400; line-height: 1.6; color: #2B2621` | Literata (opsz 15.5) 15.5/24.8px peso 400 ls normal #2B2621 |
| 5 | `d17.synopsis.text.more` ±1 | inline | 86.27 | 139.03 | 54.78 | 16.8 | `font-family: 'Figtree', sans-serif; font-size: 14px; font-weight: 800; text-decoration: underline; text-underline-offset: 3px` | Figtree 14/22.4px peso 800 ls normal #1A1714 |
| 6 | `d17.synopsis.facts` | box | 0 | 172.63 | 350 | 110.54 | `margin-top: 14px; display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); column-gap: 0; border-top: 1.5px solid #1A1714; border-bottom: 1.5px solid #1A1714` |  |
| 7 | `d17.synopsis.fact1` | box | 0 | 174.13 | 175 | 53.02 | `padding: 10px 0` |  |
| 8 | `d17.synopsis.fact1.label` | text | 0 | 184.13 | 175 | 12.61 | `font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B` | Figtree 10.5/normal peso 800 ls 1.1px #6F665B |
| 9 | `d17.synopsis.fact1.value` | text | 0 | 199.74 | 175 | 17.41 | `margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums` | Figtree 14.5/normal peso 800 ls normal #1A1714 tnum |
| 10 | `d17.synopsis.fact2` | box | 175 | 174.13 | 175 | 53.02 | `padding: 10px 0; border-left: 1.5px dashed #CFC3AE; padding-left: 14px` |  |
| 11 | `d17.synopsis.fact2.label` | text | 190.5 | 184.13 | 159.5 | 12.61 | `font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B` | Figtree 10.5/normal peso 800 ls 1.1px #6F665B |
| 12 | `d17.synopsis.fact2.value` | text | 190.5 | 199.74 | 159.5 | 17.41 | `margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums` | Figtree 14.5/normal peso 800 ls normal #1A1714 tnum |
| 13 | `d17.synopsis.fact3` | box | 0 | 227.15 | 175 | 54.52 | `padding: 10px 0; border-top: 1.5px dashed #CFC3AE` |  |
| 14 | `d17.synopsis.fact3.label` | text | 0 | 238.65 | 175 | 12.61 | `font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B` | Figtree 10.5/normal peso 800 ls 1.1px #6F665B |
| 15 | `d17.synopsis.fact3.value` | text | 0 | 254.26 | 175 | 17.41 | `margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums` | Figtree 14.5/normal peso 800 ls normal #1A1714 tnum |
| 16 | `d17.synopsis.fact4` | box | 175 | 227.15 | 175 | 54.52 | `padding: 10px 0; border-left: 1.5px dashed #CFC3AE; padding-left: 14px; border-top: 1.5px dashed #CFC3AE` |  |
| 17 | `d17.synopsis.fact4.label` | text | 190.5 | 238.65 | 159.5 | 12.61 | `font-size: 10.5px; font-weight: 800; letter-spacing: 1.1px; color: #6F665B` | Figtree 10.5/normal peso 800 ls 1.1px #6F665B |
| 18 | `d17.synopsis.fact4.value` | text | 190.5 | 254.26 | 159.5 | 17.41 | `margin-top: 3px; font-size: 14.5px; font-weight: 800; white-space: nowrap; font-variant-numeric: tabular-nums` | Figtree 14.5/normal peso 800 ls normal #1A1714 tnum |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.synopsis.title` | 1 | Sinopse | 18.6 | 0 | 76.55 | 76.55 |
| `d17.synopsis.text` *(composto)* | 1 | Depois de morto, Brás Cubas resolve contar a | 53.13 | 0 | 327.17 | 327.17 |
| `d17.synopsis.text` *(composto)* | 2 | própria vida, com franqueza, ironia e muitas | 77.93 | 0 | 326.26 | 326.26 |
| `d17.synopsis.text` *(composto)* | 3 | digressões. Um “defunto autor” revisita | 102.73 | 0 | 289.93 | 289.93 |
| `d17.synopsis.text` *(composto)* | 4 | amores, vaidades e fracassos da elite carioca do | 127.53 | 0 | 342.36 | 342.36 |
| `d17.synopsis.text` *(composto)* | 5 | século XIX. Ler mais | 152.33 | 0 | 141.05 | 141.05 |
| `d17.synopsis.fact1.label` | 1 | PÁGINAS | 194.11 | 0 | 54.76 | 54.76 |
| `d17.synopsis.fact1.value` | 1 | 208 | 213.52 | 0 | 27.67 | 27.67 |
| `d17.synopsis.fact2.label` | 1 | PUBLICADO | 194.11 | 190.5 | 260.53 | 70.03 |
| `d17.synopsis.fact2.value` | 1 | 1881 | 213.52 | 190.5 | 227.39 | 36.89 |
| `d17.synopsis.fact3.label` | 1 | FORMATO | 248.63 | 0 | 59.43 | 59.43 |
| `d17.synopsis.fact3.value` | 1 | Brochura | 268.04 | 0 | 61.29 | 61.29 |
| `d17.synopsis.fact4.label` | 1 | ISBN | 248.63 | 190.5 | 218.9 | 28.4 |
| `d17.synopsis.fact4.value` | 1 | 978-65-5921-104-3 | 268.04 | 190.5 | 333.82 | 143.32 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Sinopse" Bricolage 20/800 ls −0,4, 30 abaixo do clima; o texto 10 abaixo em Literata 15,5/400 `lh 1,6` `#2B2621`, com "Ler mais" no fim, inline, em Figtree 14/800 sublinhado (offset 3).
2. Ficha 14 abaixo: grade de 2 colunas, borda de cima e de baixo 1,5 preta; casas com padding 10/0; a da direita com a borda esquerda 1,5 `dashed #CFC3AE` e recuo 14; a 2ª fileira com a borda de cima tracejada. Rótulo 10,5/800 ls 1,1 `#6F665B` e valor 14,5/800 `tnum`, 3 abaixo, `nowrap`.
3. Valores: 208 · 1881 · Brochura · 978-65-5921-104-3 (na 17b: 256 · 1899 · E-book · DIREITOS Domínio público).
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- "Ler mais" é um link dentro do parágrafo (outra família e peso no meio da Literata): `AppText.rich` com o `TextSpan` em Figtree e o toque num recognizer; a quebra das linhas depende das duas fontes juntas.
- O sublinhado tem `text-underline-offset: 3px`, que o `TextDecoration` do Flutter não tem: desenhar a linha à parte e conferir posição e espessura na referência @3x.
- As divisórias tracejadas encontram as bordas pretas nos cantos: pintor de tracejado, não `Border` do Flutter.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017_detalhes_fisico_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017_detalhes_fisico_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17.synopsis` |  | Sinopse |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17.synopsis.text.more` | TextSpan dentro do AppText.rich do pai |  |
| `d17.synopsis.facts` | NeoBox |  |
| `d17.synopsis.fact2` | NeoBox |  |
| `d17.synopsis.fact3` | NeoBox |  |
| `d17.synopsis.fact4` | NeoBox |  |

## Interações

- Ler mais → o texto inteiro no lugar. O estado aberto não tem prancha (o parágrafo cresce e o "Ler mais" some, ou vira "Ler menos") — confirmar na T14.
- Ficha: sem toque.

## Dados

- Sinopse, páginas, ano, formato da edição e ISBN do catálogo (ou do cadastro à mão); no e-book de domínio público, a 4ª casa diz DIREITOS · Domínio público.
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17.1** Sinopse com Ler mais
- **L17.2** Ficha de 4 casas
- **L17.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17.synopsis'), todos os ids de `kRef17.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@3x.png` no recorte da fase (y 1214.84–1514.01) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17w360` e `kRef17w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17.1 Sinopse com Ler mais
- [ ] L17.2 Ficha de 4 casas
- [ ] L17.3 Verificação + relatório
- [ ] Geometria 17/17 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
