# FASE L17 — Detalhes — Clima do livro (humor, ritmo, personagens × trama)

> Tela 17 · prancha `017_detalhes_fisico` (17 · Detalhes do livro — físico (Brás Cubas), canvas 390×1940) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L17_4_clima@3x.png` · `docs/design/medicao/projeto/png/redline/L17_4_clima_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_017_detalhes_fisico.json` · `test/reference/projeto/reference_layout_017_detalhes_fisico.dart` (`kRef17`).
> Arquivos sugeridos: `lib/features/library/presentation/details/book_mood_section.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

O clima do livro votado pelos leitores (estilo StoryGraph, nota do design): os humores mais votados em pílulas coloridas com a porcentagem, o ritmo (Lento / Médio / Rápido) e a barra personagens × trama (81 % × 19 %).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{halo}}` = padrão `#ABCF82`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- How the book feels, voted by readers -->
<section aria-label="Clima do livro" style="margin-top: 30px;">
  <div style="display: flex; align-items: baseline; justify-content: space-between; gap: 10px;"><h2 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px;">Clima do livro</h2><span style="font-size: 12.5px; font-weight: 700; color: #6F665B; white-space: nowrap;">1,2 mil leitores</span></div>
  <div style="margin-top: 12px; padding: 16px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <div style="display: flex; flex-wrap: wrap; gap: 8px;"><span style="height: 32px; padding: 0 12px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap;">irônico<span style="font-size: 12px; font-weight: 700; color: #3E3832;">72%</span></span><span style="height: 32px; padding: 0 12px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap;">reflexivo<span style="font-size: 12px; font-weight: 700; color: #3E3832;">58%</span></span><span style="height: 32px; padding: 0 12px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap;">engraçado<span style="font-size: 12px; font-weight: 700; color: #3E3832;">41%</span></span><span style="height: 32px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap;">sombrio<span style="font-size: 12px; font-weight: 700; color: #3E3832;">18%</span></span></div>
    <div style="margin-top: 16px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;">RITMO</div>
    <div style="margin-top: 6px; padding: 3px; border-radius: 999px; border: 1.5px solid #E2D7C4; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px;"><span style="height: 34px; border-radius: 999px; background: transparent; border: 1.5px solid transparent; font-weight: 600; color: #6F665B; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 13px;">Lento</span><span style="height: 34px; border-radius: 999px; background: {{brand}}; border: 1.5px solid #1A1714; font-weight: 800; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 13px;">Médio <span style="font-size: 11.5px; font-weight: 700;">64%</span></span><span style="height: 34px; border-radius: 999px; background: transparent; border: 1.5px solid transparent; font-weight: 600; color: #6F665B; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 13px;">Rápido</span></div>
    <div style="margin-top: 16px; display: flex; justify-content: space-between; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B;"><span>PERSONAGENS 81%</span><span>TRAMA 19%</span></div>
    <div style="margin-top: 6px; display: flex;"><span style="position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden;"><span style="position: absolute; left: 0; top: 0; bottom: 0; width: 81%; background: #FFC1C6;"><svg width="10" height="15" viewBox="0 0 10 15" preserveAspectRatio="none" style="position: absolute; top: 0; right: -5px; height: 100%;"><path d="M0 0H5Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15H0Z" fill="#FFC1C6"></path><path d="M5 0Q9.5 2.5 5 5Q0.5 7.5 5 10Q9.5 12.5 5 15" fill="none" stroke="#1A1714" stroke-width="1.5" vector-effect="non-scaling-stroke"></path></svg></span></span></div>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `d17.mood` — retângulo absoluto no canvas 390×1940: **x=20, y=920.44, w=350, h=272.4**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `d17.mood` | box | 0 | 0 | 350 | 272.4 | `margin-top: 30px` |  |
| 2 | `d17.mood.header` | box | 0 | 0 | 350 | 24 | `display: flex; align-items: baseline; justify-content: space-between; gap: 10px` |  |
| 3 | `d17.mood.title` ±1 | text | 0 | 0 | 127.92 | 24 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 20px; letter-spacing: -0.4px` | Bricolage (opsz 20) 20/normal peso 800 ls -0.4px #1A1714 |
| 4 | `d17.mood.voters` ±1 | text | 268.14 | 6.72 | 81.86 | 15.01 | `font-size: 12.5px; font-weight: 700; color: #6F665B; white-space: nowrap` | Figtree 12.5/normal peso 700 ls normal #6F665B |
| 5 | `d17.mood.card` | box | 0 | 36 | 350 | 236.4 | `margin-top: 12px; padding: 16px; border-radius: 22px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 6 | `d17.mood.tags` | box | 17.5 | 53.5 | 315 | 72 | `display: flex; flex-wrap: wrap; gap: 8px` |  |
| 7 | `d17.mood.tag1` ±1 | box+text | 17.5 | 53.5 | 100.05 | 32 | `height: 32px; padding: 0 12px; border-radius: 999px; background: #FFC1C6; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 8 | `d17.mood.tag1.percent` ±1 | text | 80.67 | 62.3 | 23.38 | 14.4 | `font-size: 12px; font-weight: 700; color: #3E3832` | Figtree 12/normal peso 700 ls normal #3E3832 |
| 9 | `d17.mood.tag2` ±1 | box+text | 125.55 | 53.5 | 112.87 | 32 | `height: 32px; padding: 0 12px; border-radius: 999px; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 10 | `d17.mood.tag2.percent` ±1 | text | 200.84 | 62.3 | 24.07 | 14.4 | `font-size: 12px; font-weight: 700; color: #3E3832` | Figtree 12/normal peso 700 ls normal #3E3832 |
| 11 | `d17.mood.tag3` ±1 | box+text | 17.5 | 93.5 | 122.23 | 32 | `height: 32px; padding: 0 12px; border-radius: 999px; background: #ABCF82; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 12 | `d17.mood.tag3.percent` ±1 | text | 103.81 | 102.3 | 22.42 | 14.4 | `font-size: 12px; font-weight: 700; color: #3E3832` | Figtree 12/normal peso 700 ls normal #3E3832 |
| 13 | `d17.mood.tag4` ±1 | box+text | 147.73 | 93.5 | 106.44 | 32 | `height: 32px; padding: 0 12px; border-radius: 999px; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: inline-flex; align-items: center; gap: 6px; font-size: 13.5px; font-weight: 800; white-space: nowrap` | Figtree 13.5/normal peso 800 ls normal #1A1714 |
| 14 | `d17.mood.tag4.percent` ±1 | text | 218.5 | 102.3 | 22.16 | 14.4 | `font-size: 12px; font-weight: 700; color: #3E3832` | Figtree 12/normal peso 700 ls normal #3E3832 |
| 15 | `d17.mood.paceLabel` | text | 17.5 | 141.5 | 315 | 13.2 | `margin-top: 16px; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 16 | `d17.mood.pace` | box | 17.5 | 160.7 | 315 | 43 | `margin-top: 6px; padding: 3px; border-radius: 999px; border: 1.5px solid #E2D7C4; display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 2px` |  |
| 17 | `d17.mood.pace.slow` | box+text | 22 | 165.2 | 100.67 | 34 | `height: 34px; border-radius: 999px; background: transparent; border: 1.5px solid transparent; font-weight: 600; color: #6F665B; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 13px` | Figtree 13/normal peso 600 ls normal #6F665B |
| 18 | `d17.mood.pace.medium` | box+text | 124.67 | 165.2 | 100.67 | 34 | `height: 34px; border-radius: 999px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; font-weight: 800; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 13px` | Figtree 13/normal peso 800 ls normal #1A1714 |
| 19 | `d17.mood.pace.medium.percent` ±1 | text | 184.58 | 175.29 | 23.3 | 13.81 | `font-size: 11.5px; font-weight: 700` | Figtree 11.5/normal peso 700 ls normal #1A1714 |
| 20 | `d17.mood.pace.fast` | box+text | 227.33 | 165.2 | 100.67 | 34 | `height: 34px; border-radius: 999px; background: transparent; border: 1.5px solid transparent; font-weight: 600; color: #6F665B; box-sizing: border-box; display: flex; align-items: center; justify-content: center; gap: 5px; font-size: 13px` | Figtree 13/normal peso 600 ls normal #6F665B |
| 21 | `d17.mood.splitLabels` | box | 17.5 | 219.7 | 315 | 13.2 | `margin-top: 16px; display: flex; justify-content: space-between; font-size: 11px; font-weight: 800; letter-spacing: 1.2px; color: #6F665B` |  |
| 22 | `d17.mood.splitLabels.characters` ±1 | text | 17.5 | 219.7 | 122.56 | 13.2 | `—` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 23 | `d17.mood.splitLabels.plot` ±1 | text | 259.45 | 219.7 | 73.05 | 13.2 | `—` | Figtree 11/normal peso 800 ls 1.2px #6F665B |
| 24 | `d17.mood.split` | box | 17.5 | 238.9 | 315 | 16 | `margin-top: 6px; display: flex` |  |
| 25 | `d17.mood.split.track` | box | 17.5 | 238.9 | 315 | 16 | `position: relative; display: block; flex-grow: 1; height: 16px; border-radius: 999px; border: 1.5px solid #1A1714; background: repeating-linear-gradient(135deg,#E9DFCC 0 3px,#FFFAF1 3px 7px); box-sizing: border-box; overflow: hidden` |  |
| 26 | `d17.mood.split.fill` | box | 19 | 240.4 | 252.72 | 13 | `position: absolute; left: 0; top: 0; bottom: 0; width: 81%; background: #FFC1C6` |  |
| 27 | `d17.mood.split.fill.edge` | icon | 266.72 | 240.4 | 10 | 13 | `position: absolute; top: 0; right: -5px; height: 100%` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `d17.mood.title` | 1 | Clima do livro | 18.6 | 0 | 127.92 | 127.92 |
| `d17.mood.voters` | 1 | 1,2 mil leitores | 18.6 | 268.14 | 350 | 81.86 |
| `d17.mood.tag1` | 1 | irônico | 74.22 | 31 | 74.67 | 43.67 |
| `d17.mood.tag1.percent` | 1 | 72% | 73.7 | 80.67 | 104.05 | 23.38 |
| `d17.mood.tag2` | 1 | reflexivo | 74.22 | 139.05 | 194.84 | 55.79 |
| `d17.mood.tag2.percent` | 1 | 58% | 73.7 | 200.84 | 224.92 | 24.08 |
| `d17.mood.tag3` | 1 | engraçado | 114.22 | 31 | 97.81 | 66.81 |
| `d17.mood.tag3.percent` | 1 | 41% | 113.7 | 103.81 | 126.23 | 22.42 |
| `d17.mood.tag4` | 1 | sombrio | 114.22 | 161.23 | 212.5 | 51.27 |
| `d17.mood.tag4.percent` | 1 | 18% | 113.7 | 218.5 | 240.67 | 22.17 |
| `d17.mood.paceLabel` | 1 | RITMO | 151.95 | 17.5 | 58.75 | 41.25 |
| `d17.mood.pace.slow` | 1 | Lento | 186.75 | 55.35 | 89.31 | 33.96 |
| `d17.mood.pace.medium` | 1 | Médio | 186.75 | 142.12 | 179.58 | 37.46 |
| `d17.mood.pace.medium.percent` | 1 | 64% | 186.22 | 184.58 | 207.88 | 23.3 |
| `d17.mood.pace.fast` | 1 | Rápido | 186.75 | 257.02 | 298.31 | 41.29 |
| `d17.mood.splitLabels.characters` | 1 | PERSONAGENS 81% | 230.15 | 17.5 | 140.06 | 122.56 |
| `d17.mood.splitLabels.plot` | 1 | TRAMA 19% | 230.15 | 259.45 | 332.5 | 73.05 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. "Clima do livro" Bricolage 20/800 e "1,2 mil leitores" 12,5/700 `#6F665B` na mesma linha, pela baseline (`space-between`), 30 abaixo do cartão anterior.
2. Cartão 12 abaixo: padding 16, raio 22, `#FFFAF1`, borda 1,5, sem sombra. Humores (flex-wrap, gap 8): pílulas de 32, padding 0/12, borda 1,5, 13,5/800 + a porcentagem 12/700 `#3E3832` (gap 6) — irônico `#FFC1C6`, reflexivo `#FED170`, engraçado `#ABCF82`, sombrio `#FFFAF1`.
3. "RITMO" 11/800 ls 1,2 `#6F665B`, 16 abaixo; a régua de 3 (padding 3, borda 1,5 `#E2D7C4`, gap 2): o mais votado em `{{brand}}` com borda 1,5 e "Médio 64%" (13/800 + 11,5/700); os outros sem fundo, 13/600 `#6F665B`, com borda transparente de 1,5 (a mesma altura de 34).
4. Personagens × trama, 16 abaixo: os rótulos 11/800 ls 1,2 nas pontas e, 6 abaixo, a barra de 16 (borda 1,5, hachura 135° `#E9DFCC`/`#FFFAF1` 3/7) com o rosa até 81 % e a ponta ondulada de 10 × 15.
5. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- A ponta ondulada é um SVG com `preserveAspectRatio="none"` e `vector-effect: non-scaling-stroke`: no app, a borda ondulada das barras do catálogo de SVGs, esticada na altura, com o traço sem escalar.
- A cor de cada humor é a do clima em todo o app (a nota do design: "a mesma cor de cada clima em todo o app") — uma tabela só de climas e cores, a mesma da Busca (28) e das resenhas.
- Com outros humores a fileira muda (flex-wrap): a 17b já quebra de outro jeito (misterioso, reflexivo / romântico, tenso).

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_017_detalhes_fisico_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_017_detalhes_fisico_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

- Nada desta fase sai do quadro, passa do pai, invade o vizinho, ganha reticências ou fica num fio de navalha a 360 ou a 430.

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `d17.mood` |  | Clima do livro |  |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `d17.mood.card` | NeoBox |  |
| `d17.mood.tag1` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.mood.tag2` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.mood.tag3` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.mood.tag4` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.mood.pace` | NeoBox |  |
| `d17.mood.pace.slow` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.mood.pace.medium` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.mood.pace.fast` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `d17.mood.split.track` | HatchPainter (hachura 135°) dentro do contorno |  |
| `d17.mood.split.fill` | NeoBox |  |
| `d17.mood.split.fill.edge` | CustomPainter (borda_onda_preenchimento) | preserveAspectRatio="none" + vector-effect="non-scaling-stroke" (o flutter_svg ignora o vector-effect): a borda ondulada da ponta da barra preenchida, esticada na altura da barra com traço fixo de 1,5 — CustomPainter, como a onda da barra do leitor. |

## Interações

- Nenhum toque na prancha (é leitura). Votar no clima fica nas resenhas (T20).

## Dados

- Votos dos leitores no catálogo (humor, ritmo, personagens × trama) e quantos votaram. A fonte desses votos ainda não existe no app: D-247 — com dados reais a seção some até haver a fonte, e a fixture continua nos testes (a fonte é pergunta da T14).
- Todo texto e número sai dos dados reais (banco local, catálogo, conta) e dos cálculos — nunca escrito no widget; na demonstração (D-267), da fixture da tela (D-34), que reproduz a prancha.

## Subfases

- **L17.1** Título e leitores
- **L17.2** Pílulas de humor (flex-wrap)
- **L17.3** Ritmo e personagens × trama
- **L17.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('d17.mood'), todos os ids de `kRef17.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/017_detalhes_fisico_390x1940@3x.png` no recorte da fase (y 912.44–1200.84) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef17w360` e `kRef17w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L17.1 Título e leitores
- [ ] L17.2 Pílulas de humor (flex-wrap)
- [ ] L17.3 Ritmo e personagens × trama
- [ ] L17.4 Verificação + relatório
- [ ] Geometria 27/27 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
