# FASE L01a8 — Início — Recém-chegados

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a8_recem_chegados@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a8_recem_chegados_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/recently_added_section.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

"Recém-chegados": Frankenstein ("Quero ler"), O Alienista (agora **"Lido"**, pílula verde nova) e Senhora (agora em **papel**).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

```html
<!-- Recently added -->
<section aria-label="Adicionados recentemente" style="margin-top: 40px; display: flex; flex-direction: column; gap: 10px;">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <h3 style="margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px;">Recém-chegados</h3>
    <a href="#" style="height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700;">Biblioteca
      <svg width="18" height="18" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path></svg>
    </a>
  </div>

  <div style="background: #FFFAF1; border-radius: 24px; padding: 4px 8px 4px 14px; display: flex; flex-direction: column;">
    <div style="display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid #E9E1D2;">
      <div style="position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #1A1714; overflow: hidden; box-sizing: border-box;">
        <div style="position: absolute; left: 10px; top: 10px; width: 22px; height: 22px; border-radius: 50%; background: #B6ACE4;"></div>
        <div style="position: absolute; left: 8px; right: 6px; bottom: 7px; height: 3px; border-radius: 3px; background: #B6ACE4;"></div>
      </div>
      <a href="#" style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
        <span style="font-size: 15px; font-weight: 700;">Frankenstein</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Mary Shelley · EPUB</span>
      </a>
      <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #ECE7FA; color: #3B2D86;">Quero ler</span>
      <button aria-label="Mais opções para Frankenstein" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="#1A1714"><circle cx="5" cy="12" r="1.8"></circle><circle cx="12" cy="12" r="1.8"></circle><circle cx="19" cy="12" r="1.8"></circle></svg>
      </button>
    </div>
    <div style="display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid #E9E1D2;">
      <div style="position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box;">
        <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.12);"></div>
        <div style="position: absolute; left: 12px; top: 12px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box;"></div>
        <div style="position: absolute; left: 18px; top: 18px; width: 8px; height: 8px; border-radius: 50%; background: #1A1714;"></div>
      </div>
      <a href="#" style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
        <span style="font-size: 15px; font-weight: 700;">O Alienista</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Machado de Assis · PDF</span>
      </a>
      <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #E1EDD0; color: #2E5314; white-space: nowrap;">Lido</span>
      <button aria-label="Mais opções para O Alienista" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="#1A1714"><circle cx="5" cy="12" r="1.8"></circle><circle cx="12" cy="12" r="1.8"></circle><circle cx="19" cy="12" r="1.8"></circle></svg>
      </button>
    </div>
    <div style="display: flex; align-items: center; gap: 14px; padding: 12px 0;">
      <div style="position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #F2A815; overflow: hidden; box-sizing: border-box;">
        <div style="position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.12);"></div>
        <div style="position: absolute; left: 10px; right: 8px; top: 12px; height: 26px; border-radius: 13px 13px 0 0; border: 1.5px solid #1A1714; border-bottom: none; box-sizing: border-box;"></div>
      </div>
      <a href="#" style="flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px;">
        <span style="font-size: 15px; font-weight: 700;">Senhora</span>
        <span style="font-size: 13px; font-weight: 500; color: #5B544B;">José de Alencar · Papel</span>
      </a>
      <span style="font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #EFE7D7; color: #4A4238;">Novo</span>
      <button aria-label="Mais opções para Senhora" style="width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0;">
        <svg width="20" height="20" sc-camel-view-box="0 0 24 24" fill="#1A1714"><circle cx="5" cy="12" r="1.8"></circle><circle cx="12" cy="12" r="1.8"></circle><circle cx="19" cy="12" r="1.8"></circle></svg>
      </button>
    </div>
  </div>
</section>
```

## Especificação pixel a pixel

Seção `i01.recent` — retângulo absoluto no canvas 390×2650: **x=20, y=2138.12, w=350, h=334**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.recent` | box | 0 | 0 | 350 | 334 | `margin-top: 40px; display: flex; flex-direction: column; gap: 10px` |  |
| 2 | `i01.recent.header` | box | 0 | 0 | 350 | 44 | `display: flex; align-items: center; justify-content: space-between` |  |
| 3 | `i01.recent.title` ±1 | text | 0 | 7.6 | 195.47 | 28.8 | `margin: 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 24px; letter-spacing: -0.6px` | Bricolage (opsz 24) 24/normal peso 800 ls -0.6px #1A1714 |
| 4 | `i01.recent.libraryLink` ±1 | text | 263.81 | 0 | 86.19 | 44 | `height: 44px; display: flex; align-items: center; gap: 4px; font-size: 14px; font-weight: 700` | Figtree 14/normal peso 700 ls normal #1A1714 |
| 5 | `i01.recent.libraryLink.icon` | icon | 332 | 13 | 18 | 18 | `—` |  |
| 6 | `i01.recent.list` | box | 0 | 54 | 350 | 280 | `background: #FFFAF1; border-radius: 24px; padding: 4px 8px 4px 14px; display: flex; flex-direction: column` |  |
| 7 | `i01.recent.row0` | box | 14 | 58 | 328 | 91 | `display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid #E9E1D2` |  |
| 8 | `i01.recent.row0.cover` | box | 14 | 70 | 44 | 66 | `position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #1A1714; overflow: hidden; box-sizing: border-box` |  |
| 9 | `i01.recent.row0.cover.moon` | box | 25.2 | 81.2 | 22 | 22 | `position: absolute; left: 10px; top: 10px; width: 22px; height: 22px; border-radius: 50%; background: #B6ACE4` |  |
| 10 | `i01.recent.row0.cover.bar` | box | 23.2 | 124.8 | 27.6 | 3 | `position: absolute; left: 8px; right: 6px; bottom: 7px; height: 3px; border-radius: 3px; background: #B6ACE4` |  |
| 11 | `i01.recent.row0.textBlock` ±1 | box | 72 | 84.7 | 126.54 | 36.6 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 12 | `i01.recent.row0.title` ±1 | text | 72 | 84.7 | 126.54 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 13 | `i01.recent.row0.subtitle` ±1 | text | 72 | 105.7 | 126.54 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 14 | `i01.recent.row0.tag` ±1 | box+text | 212.54 | 90.8 | 71.46 | 24.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #ECE7FA; color: #3B2D86` | Figtree 12/normal peso 700 ls normal #3B2D86 |
| 15 | `i01.recent.row0.more` | box | 298 | 81 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 16 | `i01.recent.row0.more.icon` | icon | 310 | 93 | 20 | 20 | `—` |  |
| 17 | `i01.recent.row1` | box | 14 | 149 | 328 | 91 | `display: flex; align-items: center; gap: 14px; padding: 12px 0; border-bottom: 1px solid #E9E1D2` |  |
| 18 | `i01.recent.row1.cover` | box | 14 | 161 | 44 | 66 | `position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #B6ACE4; overflow: hidden; box-sizing: border-box` |  |
| 19 | `i01.recent.row1.cover.spine` | box | 15.2 | 162.2 | 4 | 63.6 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.12)` |  |
| 20 | `i01.recent.row1.cover.ring` | box | 27.2 | 174.2 | 20 | 20 | `position: absolute; left: 12px; top: 12px; width: 20px; height: 20px; border-radius: 50%; border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 21 | `i01.recent.row1.cover.dot` | box | 33.2 | 180.2 | 8 | 8 | `position: absolute; left: 18px; top: 18px; width: 8px; height: 8px; border-radius: 50%; background: #1A1714` |  |
| 22 | `i01.recent.row1.textBlock` ±1 | box | 72 | 175.7 | 154.3 | 36.6 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 23 | `i01.recent.row1.title` ±1 | text | 72 | 175.7 | 154.3 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 24 | `i01.recent.row1.subtitle` ±1 | text | 72 | 196.7 | 154.3 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 25 | `i01.recent.row1.tag` ±1 | box+text | 240.3 | 181.8 | 43.7 | 24.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #E1EDD0; color: #2E5314; white-space: nowrap` | Figtree 12/normal peso 700 ls normal #2E5314 |
| 26 | `i01.recent.row1.more` | box | 298 | 172 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 27 | `i01.recent.row1.more.icon` | icon | 310 | 184 | 20 | 20 | `—` |  |
| 28 | `i01.recent.row2` | box | 14 | 240 | 328 | 90 | `display: flex; align-items: center; gap: 14px; padding: 12px 0` |  |
| 29 | `i01.recent.row2.cover` | box | 14 | 252 | 44 | 66 | `position: relative; width: 44px; height: 66px; flex-shrink: 0; border-radius: 3px 7px 7px 3px; border: 1.2px solid #1A1714; background: #F2A815; overflow: hidden; box-sizing: border-box` |  |
| 30 | `i01.recent.row2.cover.spine` | box | 15.2 | 253.2 | 4 | 63.6 | `position: absolute; left: 0; top: 0; bottom: 0; width: 4px; background: rgba(0,0,0,0.12)` |  |
| 31 | `i01.recent.row2.cover.arch` | box | 25.2 | 265.2 | 23.6 | 26 | `position: absolute; left: 10px; right: 8px; top: 12px; height: 26px; border-radius: 13px 13px 0 0; border: 1.5px solid #1A1714; border-bottom: none; box-sizing: border-box` |  |
| 32 | `i01.recent.row2.textBlock` ±1 | box | 72 | 266.7 | 148.56 | 36.6 | `flex-grow: 1; min-width: 0; display: flex; flex-direction: column; gap: 3px` |  |
| 33 | `i01.recent.row2.title` ±1 | text | 72 | 266.7 | 148.56 | 18 | `font-size: 15px; font-weight: 700` | Figtree 15/normal peso 700 ls normal #1A1714 |
| 34 | `i01.recent.row2.subtitle` ±1 | text | 72 | 287.7 | 148.56 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 35 | `i01.recent.row2.tag` ±1 | box+text | 234.56 | 272.8 | 49.44 | 24.4 | `font-size: 12px; font-weight: 700; padding: 5px 10px; border-radius: 999px; background: #EFE7D7; color: #4A4238` | Figtree 12/normal peso 700 ls normal #4A4238 |
| 36 | `i01.recent.row2.more` | box | 298 | 263 | 44 | 44 | `width: 44px; height: 44px; flex-shrink: 0; border: none; background: transparent; border-radius: 50%; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 37 | `i01.recent.row2.more.icon` | icon | 310 | 275 | 20 | 20 | `—` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.recent.title` | 1 | Recém-chegados | 29.92 | 0 | 195.47 | 195.47 |
| `i01.recent.libraryLink` | 1 | Biblioteca | 26.9 | 263.81 | 328 | 64.19 |
| `i01.recent.row0.title` | 1 | Frankenstein | 98.95 | 72 | 160.51 | 88.51 |
| `i01.recent.row0.subtitle` | 1 | Mary Shelley · EPUB | 118.05 | 72 | 188.78 | 116.78 |
| `i01.recent.row0.tag` | 1 | Quero ler | 107.2 | 222.54 | 274 | 51.46 |
| `i01.recent.row1.title` | 1 | O Alienista | 189.95 | 72 | 147.34 | 75.34 |
| `i01.recent.row1.subtitle` | 1 | Machado de Assis · PDF | 209.05 | 72 | 210.68 | 138.68 |
| `i01.recent.row1.tag` | 1 | Lido | 198.2 | 250.3 | 274 | 23.7 |
| `i01.recent.row2.title` | 1 | Senhora | 280.95 | 72 | 128.88 | 56.88 |
| `i01.recent.row2.subtitle` | 1 | José de Alencar · Papel | 300.05 | 72 | 206.94 | 134.94 |
| `i01.recent.row2.tag` | 1 | Novo | 289.2 | 244.56 | 274 | 29.44 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Lista `#FFFAF1` raio 24, padding 4/8/4/14; linhas de 91 com divisória 1 `#E9E1D2`; capas 44 × 66 (raio 3/7/7/3, borda 1,2) iguais às da v1.
2. Pílula **"Lido"**: fundo `#E1EDD0`, texto `#2E5314` (cores novas), Figtree 12/700, padding 5/10, `nowrap` — na v1 era "Quero / ler" em 2 linhas; agora o bloco de texto ganha largura (154,3) e o subtítulo cabe em 1 linha.
3. "José de Alencar · Papel" (era EPUB). Botão ⋯ 44 com `ic_more_horizontal` 20.
4. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.recent` |  | Adicionados recentemente |  |
| `i01.recent.row0.more` |  | Mais opções para Frankenstein |  |
| `i01.recent.row1.more` |  | Mais opções para O Alienista |  |
| `i01.recent.row2.more` |  | Mais opções para Senhora |  |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.recent.libraryLink.icon` | AppSvg(AppIcons.ic_arrow_right, size: 18) |  |
| `i01.recent.list` | NeoBox |  |
| `i01.recent.row0` | NeoBox |  |
| `i01.recent.row0.cover` | NeoBox |  |
| `i01.recent.row0.cover.moon` | CircleIconButton / NeoBox circular |  |
| `i01.recent.row0.cover.bar` | NeoBox |  |
| `i01.recent.row0.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.recent.row0.more.icon` | AppSvg(AppIcons.ic_more_horizontal, size: 20) |  |
| `i01.recent.row1` | NeoBox |  |
| `i01.recent.row1.cover` | NeoBox |  |
| `i01.recent.row1.cover.spine` | NeoBox |  |
| `i01.recent.row1.cover.ring` | CircleIconButton / NeoBox circular |  |
| `i01.recent.row1.cover.dot` | CircleIconButton / NeoBox circular |  |
| `i01.recent.row1.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.recent.row1.more.icon` | AppSvg(AppIcons.ic_more_horizontal, size: 20) |  |
| `i01.recent.row2.cover` | NeoBox |  |
| `i01.recent.row2.cover.spine` | NeoBox |  |
| `i01.recent.row2.cover.arch` | NeoBox |  |
| `i01.recent.row2.tag` | Pill / CountBadge (NeoBox com raio de pílula + AppText) |  |
| `i01.recent.row2.more.icon` | AppSvg(AppIcons.ic_more_horizontal, size: 20) |  |

## Interações

- ⋯ → sem ação (D-243 b): o elemento fica idêntico à prancha, o toque não faz nada, um teste documenta e o item entra em `docs/design/estados_sem_design.md` (como na D-243: menus ⋯).
- Linha → página do livro, como hoje.

## Dados

- Estado do livro → pílula: "Quero ler" (lavanda), "Lido" (verde), "Novo" (bege); formato no subtítulo, incluindo "Papel".

## Subfases

- **L01a8.1** Pílula "Lido" e formato "Papel"
- **L01a8.2** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.recent'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 2130.12–2480.12) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a8.1 Pílula "Lido" e formato "Papel"
- [ ] L01a8.2 Verificação + relatório
- [ ] Geometria 37/37 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
