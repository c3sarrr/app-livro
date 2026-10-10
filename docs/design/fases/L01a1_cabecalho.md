# FASE L01a1 — Início — cabeçalho (saudação, busca, sino) e título

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a1_cabecalho@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a1_cabecalho_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/home/presentation/sections/header_section.dart`, `lib/features/home/presentation/sections/headline_section.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

Cabeçalho da Início nova: avatar, saudação e, à direita, dois botões redondos — a lupa (nova) e o sino com o ponto coral. Abaixo, o título "Continue / sua história." (igual à v1).

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

```html
<!-- Header -->
<header style="display: flex; align-items: center; justify-content: space-between; height: 48px;">
  <div style="display: flex; align-items: center; gap: 12px;">
    <div style="width: 44px; height: 44px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px;">M</div>
    <div style="display: flex; flex-direction: column; gap: 1px;">
      <span style="font-size: 13px; font-weight: 500; color: #5B544B;">Boa noite,</span>
      <span style="font-size: 16px; font-weight: 700; letter-spacing: -0.1px;">Marina</span>
    </div>
  </div>
  <div style="display: flex; align-items: center; gap: 8px;">
  <a href="#" aria-label="Buscar livros" style="width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="7"></circle><path d="m20 20-3.5-3.5"></path></svg>
  </a>
  <button aria-label="Notificações, 2 novas" style="position: relative; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M6 8a6 6 0 1 1 12 0c0 7 3 9 3 9H3s3-2 3-9"></path><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"></path></svg>
    <span style="position: absolute; top: 9px; right: 11px; width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.5px solid #FFFAF1;"></span>
  </button>
  </div>
</header>

<!-- Editorial headline -->
<h1 style="margin: 24px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 42px; line-height: 0.98; letter-spacing: -1.4px;">Continue<br><span style="font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 50px; letter-spacing: -0.6px;">sua história.</span></h1>
```

## Especificação pixel a pixel

Seção `i01.header` — retângulo absoluto no canvas 390×2650: **x=20, y=62, w=350, h=48**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.header` | box | 0 | 0 | 350 | 48 | `display: flex; align-items: center; justify-content: space-between; height: 48px` |  |
| 2 | `i01.header.identity` ±1 | box | 0 | 2 | 114.43 | 44 | `display: flex; align-items: center; gap: 12px` |  |
| 3 | `i01.header.avatar` | box+text | 0 | 2 | 44 | 44 | `width: 44px; height: 44px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 18px` | Bricolage (opsz 18) 18/normal peso 800 ls normal #1A1714 |
| 4 | `i01.header.greetingColumn` ±1 | box | 56 | 6.1 | 58.43 | 35.8 | `display: flex; flex-direction: column; gap: 1px` |  |
| 5 | `i01.header.greeting` ±1 | text | 56 | 6.1 | 58.43 | 15.6 | `font-size: 13px; font-weight: 500; color: #5B544B` | Figtree 13/normal peso 500 ls normal #5B544B |
| 6 | `i01.header.name` ±1 | text | 56 | 22.7 | 58.43 | 19.2 | `font-size: 16px; font-weight: 700; letter-spacing: -0.1px` | Figtree 16/normal peso 700 ls -0.1px #1A1714 |
| 7 | `i01.header.actions` | box | 246 | 0 | 104 | 48 | `display: flex; align-items: center; gap: 8px` |  |
| 8 | `i01.header.search` | box | 246 | 0 | 48 | 48 | `width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 9 | `i01.header.search.icon` | icon | 259 | 13 | 22 | 22 | `—` |  |
| 10 | `i01.header.bell` | box | 302 | 0 | 48 | 48 | `position: relative; width: 48px; height: 48px; border-radius: 50%; background: #FFFAF1; border: 1.5px solid #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center; padding: 0` |  |
| 11 | `i01.header.bell.icon` | icon | 315 | 13 | 22 | 22 | `—` |  |
| 12 | `i01.header.bell.dot` | box | 325.5 | 10.5 | 12 | 12 | `position: absolute; top: 9px; right: 11px; width: 9px; height: 9px; border-radius: 50%; background: #FF552E; border: 1.5px solid #FFFAF1` |  |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.header.avatar` | 1 | M | 29.94 | 13.47 | 30.53 | 17.06 |
| `i01.header.greeting` | 1 | Boa noite, | 18.45 | 56 | 114.43 | 58.43 |
| `i01.header.name` | 1 | Marina | 37.9 | 56 | 105.51 | 49.51 |

Seção `i01.headline` — retângulo absoluto no canvas 390×2650: **x=20, y=134, w=350, h=90.16**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 13 | `i01.headline` | text | 0 | 0 | 350 | 90.16 | `margin: 24px 0 0; font-family: 'Bricolage Grotesque', sans-serif; font-weight: 800; font-size: 42px; line-height: 0.98; letter-spacing: -1.4px` | Bricolage (opsz 42) 42/41.16px peso 800 ls -1.4px #1A1714 |
| 14 | `i01.headline.serif` ±1 | inline | 0 | 33.16 | 219.65 | 65 | `font-family: 'Instrument Serif', Georgia, serif; font-style: italic; font-weight: 400; font-size: 50px; letter-spacing: -0.6px` | Instrument Serif itálico 50/49px peso 400 ls -0.6px #1A1714 |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.headline` *(composto)* | 1 | Continue | 34.44 | 0 | 170.69 | 170.69 |
| `i01.headline` *(composto)* | 2 | sua história. | 82.66 | 0 | 219.65 | 219.65 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Cabeçalho 350 × 48, `space-between`. Identidade: avatar 44 (círculo `#FED170`, borda 1,5, "M" Bricolage 18/800) + coluna (gap 1) com "Boa noite," Figtree 13/500 `#5B544B` e "Marina" Figtree 16/700 ls −0,1.
2. Ações (gap 8): **lupa** e sino, ambos círculos 48 `#FFFAF1` com borda 1,5. Ícones 22: `ic_search_home` (novo, traço 1,9) e `ic_bell` (o da v1). O ponto do sino é `content-box`: 9 + borda 1,5 `#FFFAF1` = 12 por fora, em `top 9 · right 11`, coral `#FF552E`.
3. Título: Bricolage 42/800, `line-height 0,98`, ls −1,4; "sua história." em Instrument Serif itálico 50 ls −0,6 (inline) — 2 linhas, mesma composição da v1, 24 abaixo do cabeçalho.
4. O que muda em relação à v1: só o grupo `header.actions` (antes o sino ficava sozinho).
5. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.header.search` |  | Buscar livros |  |
| `i01.header.bell` |  | Notificações, 2 novas |  |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.header.avatar` | CircleIconButton / NeoBox circular |  |
| `i01.header.search` | CircleIconButton / NeoBox circular |  |
| `i01.header.search.icon` | AppSvg(AppIconsInicio.ic_search_home, size: 22) |  |
| `i01.header.bell` | CircleIconButton / NeoBox circular |  |
| `i01.header.bell.icon` | AppSvg(AppIcons.ic_bell, size: 22) |  |
| `i01.header.bell.dot` | CircleIconButton / NeoBox circular |  |
| `i01.headline.serif` | TextSpan dentro do AppText.rich do pai |  |

## Interações

- Lupa → sem ação (D-243 b): o elemento fica idêntico à prancha, o toque não faz nada, um teste documenta e o item entra em `docs/design/estados_sem_design.md` (busca = C14, sem prancha).
- Sino e avatar → como hoje (G08/G21).

## Dados

- Saudação pela hora e nome do perfil (como na v1); ponto do sino = há notificação não lida.

## Subfases

- **L01a1.1** Cabeçalho com lupa e sino
- **L01a1.2** Título "Continue sua história."
- **L01a1.3** Lupa sem ação (D-243 b) + estados_sem_design
- **L01a1.4** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.header', 'i01.headline'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 54–240.16) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a1.1 Cabeçalho com lupa e sino
- [ ] L01a1.2 Título "Continue sua história."
- [ ] L01a1.3 Lupa sem ação (D-243 b) + estados_sem_design
- [ ] L01a1.4 Verificação + relatório
- [ ] Geometria 13/13 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
