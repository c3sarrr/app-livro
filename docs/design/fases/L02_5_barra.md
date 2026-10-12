# FASE L02 — Biblioteca — degradê inferior e barra de navegação

> Tela 02 · prancha `002_biblioteca` (02 · Biblioteca, canvas 390×1640) · executada na **T14** (etapas 7–11 do docs/ROTEIRO.md).
> Referências: `docs/design/medicao/projeto/png/secoes/L02_5_barra@3x.png` · `docs/design/medicao/projeto/png/redline/L02_5_barra_redline@3x.png` (Nº = tabelas abaixo) · `docs/design/medicao/projeto/png/002_biblioteca_390x1640@{1,2,3}x.png` · `docs/design/medicao/projeto/layout/layout_002_biblioteca.json` · `test/reference/projeto/reference_layout_002_biblioteca.dart` (`kRef02`).
> Arquivos sugeridos: `lib/features/shell/presentation/floating_nav_bar.dart`, `lib/features/shell/presentation/bottom_fade.dart`.
> Gerado por `tools/medicao/gen_fases.py` (T13.12). Medidas = Chromium 141, zoom 100. Não edite as tabelas à mão: regenere.

O degradê de 170 que deixa a estante passar por baixo da navegação e a barra de 5 itens com a Biblioteca marcada — a navegação da Início (F11, G05), agora com a aba Biblioteca ativa.

---

## HTML literal da seção

Props do componente: `{{brand}}` = padrão `#B6ACE4`, `{{shelf}}` = padrão `#FED170`.

```html
<!-- Bottom fade so the shelf slips under the floating nav -->
<div aria-hidden="true" style="position: absolute; left: 0; right: 0; bottom: 0; height: 170px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 60%); pointer-events: none;"></div>

<!-- Bottom navigation (fixed in the app; sits above the home-indicator area) -->
<nav aria-label="Navegação principal" style="position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px;">
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10.5 12 3l9 7.5V20a1 1 0 0 1-1 1h-5v-6h-6v6H4a1 1 0 0 1-1-1z"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Início</span>
  </a>
  <a href="#" aria-current="page" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}}; border: 1.5px solid #1A1714; box-sizing: border-box;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="#FFFAF1" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3.5" y="4" width="4.5" height="16" rx="1"></rect><rect x="10" y="4" width="4.5" height="16" rx="1"></rect><path d="m16.4 5.6 3.9-1 3.2 14.6-3.9 1z"></path></svg>
    <span style="font-size: 11px; font-weight: 800; letter-spacing: -0.2px;">Biblioteca</span>
  </a>
  <a href="#" aria-label="Scanner: escanear livro ou página" style="position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px;">
    <span style="position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center;">
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3.5 8V6a2.5 2.5 0 0 1 2.5-2.5h2"></path><path d="M16 3.5h2A2.5 2.5 0 0 1 20.5 6v2"></path><path d="M20.5 16v2a2.5 2.5 0 0 1-2.5 2.5h-2"></path><path d="M8 20.5H6A2.5 2.5 0 0 1 3.5 18v-2"></path><path d="M8 8.5v7"></path><path d="M11 8.5v7"></path><path d="M13.5 8.5v7"></path><path d="M16 8.5v7"></path></svg>
    </span>
    <span style="font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px;">Scanner</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="8" r="3.5"></circle><path d="M2.5 20a6.5 6.5 0 0 1 13 0"></path><path d="M16 4.6a3.5 3.5 0 0 1 0 6.8"></path><path d="M18.5 14a6.5 6.5 0 0 1 3 6"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Clubes</span>
  </a>
  <a href="#" style="display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px;">
    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#1A1714" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="8" r="4"></circle><path d="M4 21a8 8 0 0 1 16 0"></path></svg>
    <span style="font-size: 11px; font-weight: 600; color: #5B544B;">Perfil</span>
  </a>
</nav>
```

## Especificação pixel a pixel

Seção `b02.bottomFade` — retângulo absoluto no canvas 390×1640: **x=0, y=1470, w=390, h=170**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 1 | `b02.bottomFade` | box | 0 | 0 | 390 | 170 | `position: absolute; left: 0; right: 0; bottom: 0; height: 170px; background: linear-gradient(to bottom, rgba(247,240,227,0), #F7F0E3 60%); pointer-events: none` |  |

Seção `b02.nav` — retângulo absoluto no canvas 390×1640: **x=16, y=1540, w=358, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem transform). Nº = rótulo no redline. Coordenada absoluta (teste de geometria) = seção + tabela.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva |
|---|---|---|---|---|---|---|---|---|
| 2 | `b02.nav` | box | 0 | 0 | 358 | 70 | `position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; display: grid; grid-template-columns: repeat(5, minmax(0, 1fr)); gap: 4px` |  |
| 3 | `b02.nav.home` | box | 9.5 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 4 | `b02.nav.home.icon` | icon | 30.8 | 15.9 | 22 | 22 | `—` |  |
| 5 | `b02.nav.home.label` ±1 | text | 28.21 | 40.9 | 27.18 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 6 | `b02.nav.library` | box | 78.1 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 7 | `b02.nav.library.icon` | icon | 99.4 | 15.9 | 22 | 22 | `—` |  |
| 8 | `b02.nav.library.label` ±1 | text | 85.8 | 40.9 | 49.2 | 13.2 | `font-size: 11px; font-weight: 800; letter-spacing: -0.2px` | Figtree 11/normal peso 800 ls -0.2px #1A1714 |
| 9 | `b02.nav.scanner` | box | 146.7 | 9.5 | 64.6 | 51 | `position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px` |  |
| 10 | `b02.nav.scanner.fab` | box | 149 | -20.5 | 60 | 60 | `position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: 0 4px 0 #1A1714; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 11 | `b02.nav.scanner.icon` | icon | 165 | -4.5 | 28 | 28 | `—` |  |
| 12 | `b02.nav.scanner.label` ±1 | text | 158.35 | 45.3 | 41.3 | 15.2 | `font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px` | Figtree 11/normal peso 700 ls normal #1A1714 |
| 13 | `b02.nav.clubs` | box | 215.3 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 14 | `b02.nav.clubs.icon` | icon | 236.6 | 15.9 | 22 | 22 | `—` |  |
| 15 | `b02.nav.clubs.label` ±1 | text | 230.37 | 40.9 | 34.45 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 16 | `b02.nav.profile` | box | 283.9 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 17 | `b02.nav.profile.icon` | icon | 305.2 | 15.9 | 22 | 22 | `—` |  |
| 18 | `b02.nav.profile.label` ±1 | text | 303.18 | 40.9 | 26.05 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `b02.nav.home.label` | 1 | Início | 51.35 | 28.21 | 55.39 | 27.18 |
| `b02.nav.library.label` | 1 | Biblioteca | 51.35 | 85.8 | 135 | 49.2 |
| `b02.nav.scanner.label` | 1 | Scanner | 55.75 | 158.35 | 199.65 | 41.3 |
| `b02.nav.clubs.label` | 1 | Clubes | 51.35 | 230.37 | 264.83 | 34.46 |
| `b02.nav.profile.label` | 1 | Perfil | 51.35 | 303.18 | 329.22 | 26.04 |

`±1` ao lado da Key = posição/largura horizontal depende da largura medida do texto (tolerância ±1,0 em x/w; demais ±0,5).

## Leitura de designer (detalhes críticos)

1. Degradê: 170 de altura, de `rgba(247,240,227,0)` a `#F7F0E3` em 60 % (de cima para baixo), `pointer-events: none` — não bloqueia o toque nos livros.
2. Navegação: `left/right 16 · bottom 30`, 70 de altura, padding 8, raio 28, `#FFFAF1`, borda 1,5, sombra dura 0/4; grade de 5 colunas, gap 4. Itens: ícone 22 + rótulo 11/600 `#5B544B`, gap 3, raio 20.
3. A ativa (Biblioteca): fundo `{{brand}}`, borda 1,5, o ícone das lombadas preenchido de `#FFFAF1` e o rótulo 11/800 ls −0,2. O Scanner: círculo 60 `#FED170` (borda 1,5, sombra 0/4) 30 acima do item, ícone 28, rótulo 11/700 com `padding-bottom 2`.
4. Fontes desta prancha: a Figtree vai até 800 **real** (D-246: `Figtree-ExtraBold.ttf`; o 900 renderiza 800); a Bricolage 800 usa a família do tamanho (`AppFonts.bricolageOpsz`, opsz = tamanho; 11 usa a 12) e a 700 só existe na 15 (`bricolageBold`); a Literata da interface é a estática do tamanho e do peso (`literataStatic`); a Instrument Serif é estática. Com letter-spacing ≠ 0 o app desliga liga e clig, como o Blink (D-282); o `tnum` entra onde a tabela diz.

## Armadilhas

- É o componente da Início (`FloatingNavBar`): só muda a aba ativa — a geometria é a mesma (a referência confere a 36 × 02: a mesma navegação presa ao fundo, −796).
- O degradê da 02 (170, de cima para baixo, até 60 %) não é o da 36 (130, de baixo para cima, até 55 %): `BottomFade` com os parâmetros de cada tela.

## Nas outras larguras (360 e 430 — T13.9, D-272)

Referências: `docs/design/medicao/projeto_larguras/layout/layout_002_biblioteca_w{360,430}.json` · `test/reference/projeto_larguras/reference_layout_002_biblioteca_w{360,430}.dart`. Informação para a etapa: a tela é fluida (o CSS da prancha); o que não acompanha a largura fica abaixo, com quanto passa e quanto já passava a 390.

| largura | Key | o que acontece | px | a 390 | novo | largura fixa | pai / vizinho |
|---|---|---|---|---|---|---|---|
| 360 | `b02.nav.scanner.fab` | passa do pai (x) | 0.7 | 0 | **sim** | sim | pai `b02.nav.scanner` (vaza) |

## Semântica (do arquivo)

| Key | role | rótulo | outros |
|---|---|---|---|
| `b02.bottomFade` |  |  | aria-hidden=true |
| `b02.nav` |  | Navegação principal |  |
| `b02.nav.library` |  |  | aria-current=page |
| `b02.nav.scanner` |  | Scanner: escanear livro ou página |  |
| `b02.nav.scanner.icon` |  |  | aria-hidden=true |

## Widgets e pintores sugeridos (mapa da T13.12)

Texto = `AppText`/`AppText.rich`; contêineres sem decoração = layout (Row/Column/Stack/Padding). Demais:

| Key | widget / pintor | observação |
|---|---|---|
| `b02.bottomFade` | DecoratedBox(LinearGradient) |  |
| `b02.nav` | NeoBox |  |
| `b02.nav.home.icon` | AppSvg(AppIcons.navHome, size: 22) |  |
| `b02.nav.library` | NeoBox |  |
| `b02.nav.library.icon` | AppSvg(AppIcons.navLibraryActive, size: 22) |  |
| `b02.nav.scanner.fab` | CircleIconButton / NeoBox circular |  |
| `b02.nav.scanner.icon` | AppSvg(AppIcons.navScanner, size: 28) |  |
| `b02.nav.clubs.icon` | AppSvg(AppIcons.navClubs, size: 22) |  |
| `b02.nav.profile.icon` | AppSvg(AppIcons.navProfile, size: 22) |  |

## Interações

- Navegação como hoje (G05, F11): Início, Clubes e Perfil trocam de aba; o Scanner abre em tela cheia (`/scanner`); a aba ativa segue o comportamento atual das abas.

## Dados

- A aba ativa sai da rota (`/biblioteca`); nada mais é dado.

## Subfases

- **L02.1** Degradê da Biblioteca
- **L02.2** Navegação com a Biblioteca ativa
- **L02.3** Verificação + relatório

## Testes da fase

- Geometria: para cada seção ('b02.bottomFade', 'b02.nav'), todos os ids de `kRef02.idsOfSection(seção)` (sem inline) com as tolerâncias da v1 (±0,5; ±1,0 em x/w para `textDependentX`).
- Texto: quebras e baselines de cada linha (`lines`; `linesAll` para texto composto) idênticas; linhas `hidden` não aparecem.
- Estilo: cores, bordas (1,5/1,3/1,2 exatas), raios, sombras duras (blur 0), fontes (família por tamanho, peso real), recursos (tnum).
- Visual: golden da prancha contra `docs/design/medicao/projeto/png/002_biblioteca_390x1640@3x.png` no recorte da fase (y 1462–1640) → `blur_mismatch_% ≤ 0,5` (`tools/compare_images.py`).
- Semântica: rótulos/roles da tabela acima (exceções da D-51).
- Dados: o texto exibido sai da fixture da tela (D-34) e dos cálculos (nunca escrito no widget).
- Larguras: a mesma tela a 360 e a 430 contra `kRef02w360` e `kRef02w430` (`test/reference/projeto_larguras/`), com as tolerâncias da geometria.

## Checklist de aceite

- [ ] L02.1 Degradê da Biblioteca
- [ ] L02.2 Navegação com a Biblioteca ativa
- [ ] L02.3 Verificação + relatório
- [ ] Geometria 18/18 · Texto OK · Estilo OK · Visual ≤ 0,5 % · Semântica OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório da fase com lado a lado e heatmap inspecionados
