# FASE L01a9 — Início — degradê inferior e barra de navegação

> Tela 01 · prancha `001_inicio` (01 · Início (Home), canvas 390×2650) · executada na **T03** (trilha T do PLANO_FIDELIDADE_TELAS.md).
> Referências: `docs/design/medicao/inicio2/png/secoes/L01a9_barra@3x.png` · `docs/design/medicao/inicio2/png/redline/L01a9_barra_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/inicio2/png/001_inicio_390x2650@{1,2,3}x.png` · `docs/design/medicao/inicio2/layout/layout_001_inicio.json` · `test/reference/inicio2/reference_layout_001_inicio.dart` (`kRef01`).
> Arquivos sugeridos: `lib/features/shell/presentation/floating_nav_bar.dart`, `lib/features/shell/presentation/bottom_fade.dart`, `lib/features/shell/presentation/scanner_fab.dart`.
> Gerado por `tools/medicao/gen_fases.py` (G01.9). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

O degradê do fim da página e a barra de navegação (Início ativo) — iguais à v1.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{weekColor}}` = padrão `#B6ACE4`.

```html
<!-- Bottom fade so content slips under the floating nav -->
<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 150px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none;"></div>

<!-- Bottom navigation (fixed in the app; sits above the home-indicator area) -->
<nav aria-label="Navegação principal" style="position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px;">
  <a href="#" aria-current="page" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"></path></svg>
    <span style="font-size: 11px; font-weight: 800;">Início</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4" width="4.5" height="16" rx="1"></rect><rect x="10" y="4" width="4.5" height="16" rx="1"></rect><path d="m16.4 5.6 3.9-1 3.2 14.6-3.9 1z"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Biblioteca</span>
  </a>
  <a href="#" aria-label="Scanner: escanear livro ou página" style="position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px;">
    <span style="position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="28" height="28" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 8V6a2.5 2.5 0 0 1 2.5-2.5h2"></path><path d="M16 3.5h2A2.5 2.5 0 0 1 20.5 6v2"></path><path d="M20.5 16v2a2.5 2.5 0 0 1-2.5 2.5h-2"></path><path d="M8 20.5H6A2.5 2.5 0 0 1 3.5 18v-2"></path><path d="M8 8.5v7"></path><path d="M11 8.5v7"></path><path d="M13.5 8.5v7"></path><path d="M16 8.5v7"></path></svg>
    </span>
    <span style="font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px;">Scanner</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Clubes</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" sc-camel-view-box="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"></circle><path d="M4 21a8 8 0 0 1 16 0"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Perfil</span>
  </a>
</nav>
```

## Especificação pixel a pixel

Seção `i01.bottomFade` — retângulo absoluto no canvas 390×2650: **x=0, y=2500, w=390, h=150**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `i01.bottomFade` | box | 0 | 0 | 390 | 150 | `position: absolute; left: 0; right: 0; bottom: 0; height: 150px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none` |  |

Seção `i01.nav` — retângulo absoluto no canvas 390×2650: **x=16, y=2550, w=358, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `i01.nav` | box | 0 | 0 | 358 | 70 | `position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px` |  |
| 3 | `i01.nav.home` | box | 9.5 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 4 | `i01.nav.home.icon` | icon | 30.8 | 15.9 | 22 | 22 | `—` |  |
| 5 | `i01.nav.home.label` ±1 | text | 28.01 | 40.9 | 27.59 | 13.2 | `font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**800** ls normal #1A1714 |
| 6 | `i01.nav.library` | box | 78.1 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 7 | `i01.nav.library.icon` | icon | 99.4 | 15.9 | 22 | 22 | `—` |  |
| 8 | `i01.nav.library.label` ±1 | text | 85.5 | 40.9 | 49.79 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 9 | `i01.nav.scanner` | box | 146.7 | 9.5 | 64.6 | 51 | `position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px` |  |
| 10 | `i01.nav.scanner.fab` | box | 149 | -20.5 | 60 | 60 | `position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 11 | `i01.nav.scanner.icon` | icon | 165 | -4.5 | 28 | 28 | `—` |  |
| 12 | `i01.nav.scanner.label` ±1 | text | 158.35 | 45.3 | 41.3 | 15.2 | `font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px` | Figtree 11/normal peso 700 ls normal #1A1714 |
| 13 | `i01.nav.clubs` | box | 215.3 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 14 | `i01.nav.clubs.icon` | icon | 236.6 | 15.9 | 22 | 22 | `—` |  |
| 15 | `i01.nav.clubs.label` ±1 | text | 230.37 | 40.9 | 34.45 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 16 | `i01.nav.profile` | box | 283.9 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 17 | `i01.nav.profile.icon` | icon | 305.2 | 15.9 | 22 | 22 | `—` |  |
| 18 | `i01.nav.profile.label` ±1 | text | 303.18 | 40.9 | 26.05 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `i01.nav.home.label` | 1 | Início | 51.35 | 28.01 | 55.59 | 27.58 |
| `i01.nav.library.label` | 1 | Biblioteca | 51.35 | 85.5 | 135.3 | 49.8 |
| `i01.nav.scanner.label` | 1 | Scanner | 55.75 | 158.35 | 199.65 | 41.3 |
| `i01.nav.clubs.label` | 1 | Clubes | 51.35 | 230.37 | 264.83 | 34.46 |
| `i01.nav.profile.label` | 1 | Perfil | 51.35 | 303.18 | 329.22 | 26.04 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Degradê: 150 de altura presos ao fundo, `#F7F0E3` de 0 % a opaco em 55 %, sem toque (`pointer-events: none`).
2. Barra: `left/right 16 · bottom 30`, 358 × 70, padding 8, raio 28, `#FFFAF1`, borda 1,5, sombra 0/4; 5 colunas (gap 4); Início ativo com fundo `{{brand}}`, borda 1,5 e raio 20; o FAB do scanner (60, `#FED170`, sombra 0/4) sobe 30 acima da barra. Rótulos Figtree 11 (ativo 800 → 700; os outros 600 `#5B544B`; Scanner 700).
3. A barra e o degradê ficam presos ao fundo da tela (o `<main>` rola por baixo).
4. Fontes desta prancha: o arquivo declara a Figtree só até 700 — todo `font-weight: 800/900` da Figtree renderiza **700** (D-14, D-246: no app, `AppFonts.figtree(..., FontWeight.w700)`); a Bricolage é sempre 800 com a família do tamanho (opsz = tamanho; 11 px usa a 12).

## Armadilhas

- Nenhuma além das regras gerais de fidelidade (§4.2 do prompt v2).

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `i01.bottomFade` |  |  | aria-hidden=true |
| `i01.nav` |  | Navegação principal |  |
| `i01.nav.home` |  |  | aria-current=page |
| `i01.nav.scanner` |  | Scanner: escanear livro ou página |  |
| `i01.nav.scanner.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da G01.10)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `i01.bottomFade` | DecoratedBox(LinearGradient) |  |
| `i01.nav` | NeoBox |  |
| `i01.nav.home` | NeoBox |  |
| `i01.nav.home.icon` | AppSvg(AppIcons.ic_nav_home_active, size: 22) |  |
| `i01.nav.library.icon` | AppSvg(AppIcons.ic_nav_library, size: 22) |  |
| `i01.nav.scanner.fab` | CircleIconButton / NeoBox circular |  |
| `i01.nav.scanner.icon` | AppSvg(AppIcons.ic_nav_scanner, size: 28) |  |
| `i01.nav.clubs.icon` | AppSvg(AppIcons.ic_nav_clubs, size: 22) |  |
| `i01.nav.profile.icon` | AppSvg(AppIcons.ic_nav_profile, size: 22) |  |

## Interações

- Como hoje (shell da G08).

## Dados

- —

## Subfases

- **L01a9.1** Degradê e barra (sem mudança visual)
- **L01a9.2** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('i01.bottomFade', 'i01.nav'), todos os ids de `kRef01.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/inicio2/png/001_inicio_390x2650@3x.png` no recorte da fase (y 2492–2650) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).

## Checklist de aceite

- [ ] L01a9.1 Degradê e barra (sem mudança visual)
- [ ] L01a9.2 Verificação + relatório
- [ ] Geometria 18/18 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
