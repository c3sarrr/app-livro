# FASE 11 — Navegação inferior flutuante, FAB "Scanner" e fade inferior

> Pré-requisito: FASE 10 aprovada.
> Referências: `secoes/F11_nav_fade@3x.png` · `redline/F11_nav_fade_redline@3x.png` · `inicio_viewport_390x844_DERIVADA@3x.png`.
> Arquivos: `shell/presentation/floating_nav_bar.dart`, `scanner_fab.dart`, `bottom_fade.dart`, `main_shell.dart`.

---

## HTML literal

`{{brand}}` = `homeThemeProvider.brand`.

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

## Especificação pixel a pixel — fade

Seção `bottomFade` — retângulo absoluto no canvas 390×2390: **x=0, y=2240, w=390, h=150**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 1 | `bottomFade` | box | 0 | 0 | 390 | 150 | `position: absolute; left: 0px; right: 0px; bottom: 0px; height: 150px; background: linear-gradient(rgba(247,240,227,0), #F7F0E3 55%); pointer-events: none` |  |

## Especificação pixel a pixel — navegação

Seção `nav` — retângulo absoluto no canvas 390×2390: **x=16, y=2290, w=358, h=70**. Coordenadas da tabela = **relativas ao canto superior esquerdo da seção** (retângulo de layout, sem rotação). Nº = rótulo na imagem de redline. Para obter a coordenada absoluta (usada pelo teste de geometria), some x/y da seção.

| Nº | Key (id) | tipo | x | y | w | h | CSS declarado no arquivo (literal) | tipografia efetiva (herdada+declarada) |
|---|---|---|---|---|---|---|---|---|
| 2 | `nav` | box | 0 | 0 | 358 | 70 | `position: absolute; left: 16px; right: 16px; bottom: 30px; height: 70px; padding: 8px; box-sizing: border-box; border-radius: 28px; background: #FFFAF1; border: 1.5px solid #1A1714; box-shadow: #1A1714 0px 4px 0px; display: grid; grid-template-columns: repeat(5, minmax(0px, 1fr)); gap: 4px` |  |
| 3 | `nav.home` | box | 9.5 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px; background: {{brand}} (padrão #B6ACE4); border: 1.5px solid #1A1714; box-sizing: border-box` |  |
| 4 | `nav.home.icon` | icon | 30.8 | 15.9 | 22 | 22 | `—` |  |
| 5 | `nav.home.label` | text | 28.01 | 40.9 | 27.59 | 13.2 | `font-size: 11px; font-weight: 800` | Figtree 11/normal peso 800→**700** ls normal #1A1714 |
| 6 | `nav.library` | box | 78.1 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 7 | `nav.library.icon` | icon | 99.4 | 15.9 | 22 | 22 | `—` |  |
| 8 | `nav.library.label` | text | 85.5 | 40.9 | 49.79 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 9 | `nav.scanner` | box | 146.7 | 9.5 | 64.6 | 51 | `position: relative; display: flex; flex-direction: column; align-items: center; justify-content: flex-end; gap: 3px; border-radius: 20px` |  |
| 10 | `nav.scanner.fab` | box | 149 | -20.5 | 60 | 60 | `position: absolute; top: -30px; left: 50%; margin-left: -30px; width: 60px; height: 60px; border-radius: 50%; background: #FED170; border: 1.5px solid #1A1714; box-shadow: #1A1714 0px 4px 0px; box-sizing: border-box; display: flex; align-items: center; justify-content: center` |  |
| 11 | `nav.scanner.icon` | icon | 165 | -4.5 | 28 | 28 | `—` |  |
| 12 | `nav.scanner.label` | text | 158.35 | 45.3 | 41.3 | 15.2 | `font-size: 11px; font-weight: 700; color: #1A1714; padding-bottom: 2px` | Figtree 11/normal peso 700 ls normal #1A1714 |
| 13 | `nav.clubs` | box | 215.3 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 14 | `nav.clubs.icon` | icon | 236.6 | 15.9 | 22 | 22 | `—` |  |
| 15 | `nav.clubs.label` | text | 230.37 | 40.9 | 34.45 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |
| 16 | `nav.profile` | box | 283.9 | 9.5 | 64.6 | 51 | `display: flex; flex-direction: column; align-items: center; justify-content: center; gap: 3px; border-radius: 20px` |  |
| 17 | `nav.profile.icon` | icon | 305.2 | 15.9 | 22 | 22 | `—` |  |
| 18 | `nav.profile.label` | text | 303.18 | 40.9 | 26.05 | 13.2 | `font-size: 11px; font-weight: 600; color: #5B544B` | Figtree 11/normal peso 600 ls normal #5B544B |

**Linhas de texto — quebras OBRIGATÓRIAS, baseline e extensão horizontal (relativas à seção; a largura inclui o letter-spacing após o último caractere, como no navegador):**

| Key | linha | texto exato da linha | baseline y | x início | x fim | largura |
|---|---|---|---|---|---|---|
| `nav.home.label` | 1 | Início | 51.35 | 28.01 | 55.59 | 27.58 |
| `nav.library.label` | 1 | Biblioteca | 51.35 | 85.5 | 135.3 | 49.8 |
| `nav.scanner.label` | 1 | Scanner | 55.75 | 158.35 | 199.65 | 41.3 |
| `nav.clubs.label` | 1 | Clubes | 51.35 | 230.37 | 264.83 | 34.46 |
| `nav.profile.label` | 1 | Perfil | 51.35 | 303.18 | 329.22 | 26.04 |

## Leitura de designer (detalhes críticos)

1. **Fade**: 150 px na base da tela, `linear-gradient(to bottom, rgba(247,240,227,0) 0%, #F7F0E3 55%)` → transparente no topo, opaco a partir de **82,5 px** (55%) até o fim. Não recebe toques. Pinta **antes** da navegação.
2. **Barra**: `left/right 16`, `bottom 30` (D-02), altura **70**, padding **8**, fundo `#FFFAF1`, borda 1,5, raio **28**, **sombra dura (0, 4)** (só para baixo). Grade de 5 colunas iguais com gap 4 → itens de **64,6 × 51**.
3. **Item ativo (Início)**: fundo `brand`, borda 1,5, raio **20**; ícone casa **com preenchimento `#FFFAF1`** (traço 1,8); rótulo "Início" 11/800→**700** tinta. Conteúdo centralizado, gap 3 (ícone 22 + rótulo 13,2 = 38,2 → começa 6,4 px abaixo do topo do item).
4. **Itens inativos**: sem fundo/borda; ícone só traço tinta 1,8; rótulo 11/**600** `#5B544B`.
5. **Scanner**: o item alinha o conteúdo **embaixo** (`justify-content: flex-end`): só o rótulo "Scanner" 11/**700** tinta com `padding-bottom 2`. O **FAB** é `position:absolute` a partir do item: `top −30`, centralizado → círculo **60×60** `#FED170`, borda 1,5, **sombra dura (0, 4)**, ícone de código de barras **28** (traço 1,9). O FAB sobe **20,5 px acima** da borda superior da barra e pinta por cima dela.
6. Toque no FAB precisa funcionar em **toda** a área do círculo (inclusive a parte fora da barra) → o FAB é posicionado no `MainShell` (irmão da barra, depois dela), não dentro da barra.

## Construção obrigatória

No `MainShell` (substitui os placeholders da F02):
```dart
final w = MediaQuery.sizeOf(context).width;
final navBottom = math.max(30.0, MediaQuery.viewPaddingOf(context).bottom - 4);   // D-02
Stack(children: [
  Positioned.fill(child: shell),
  const Positioned(left: 0, right: 0, bottom: 0, height: 150, child: IgnorePointer(child: BottomFade(key: ValueKey('bottomFade')))),
  Positioned(left: 16, right: 16, bottom: navBottom, height: 70, child: FloatingNavBar(key: const ValueKey('nav'), …)),
  // FAB: centro horizontal da tela (o item do meio é simétrico) e topo = topo do item − 30
  Positioned(left: (w - 60) / 2, bottom: navBottom + 70 - (1.5 + 8 - 30) - 60, width: 60, height: 60,   // = navBottom + 30,5
      child: const ScannerFab(key: ValueKey('nav.scanner.fab'))),
])
```
- `BottomFade` = `DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [AppColors.paperTransparent, AppColors.paper], stops: [0, 0.55])))`.
- `FloatingNavBar` = `NeoBox(color: surface, border: 1,5, radius: 28, shadow: AppShadows.drop4, padding: EdgeInsets.all(8), child: Row(spacing: 4, children: 5 × Expanded(item)))`.
- Item: `Pressable` + `Column(mainAxisAlignment: center (scanner: end), spacing: 3)`; ativo com `NeoBox(color: brand, border 1,5, radius 20)`. Keys: `nav.home`, `nav.home.icon`, `nav.home.label`, … `nav.scanner`, `nav.scanner.label`, `nav.clubs…`, `nav.profile…`; `nav.scanner.icon` dentro do FAB.
- Estado ativo vem do `StatefulNavigationShell.currentIndex` (Início = 0). Abas não-Início ativas usam os SVGs `_extrapolado_*` (D-07). Scanner: `context.push('/scanner')` (D-08).
- Semântica: `Semantics(container: true, explicitChildNodes: true, label: 'Navegação principal')`; itens = `Pressable(isLink: true)` (nome = rótulo visível); item ativo com `Semantics(selected: true)` **dentro** do `Pressable` (sem `container`, o flag se funde no nó do link — por fora criaria um nó a mais) (`aria-current="page"`); fade `ExcludeSemantics` (`aria-hidden`); scanner = `Pressable(isLink: true, semanticsLabel: 'Scanner: escanear livro ou página')` no item; o FAB (irmão no `MainShell`) leva `ExcludeSemantics` e chama o mesmo `onTap` → um único nó, sem leitura duplicada.

## Subfases

- **11.1** Fade inferior (gradiente 0→55%, IgnorePointer).
- **11.2** Barra flutuante (70, padding 8, raio 28, sombra 0/4) + grade 5 × 64,6.
- **11.3** Itens inativos (ícone + rótulo 600 `#5B544B`) e ativo (brand, borda 1,5, raio 20, ícone preenchido, rótulo 700 tinta).
- **11.4** FAB 60 no shell (posição derivada, sombra 0/4, ícone 28) + rótulo "Scanner" embaixo com padding 2.
- **11.5** Integração com go_router (troca de aba, estado ativo, push do scanner) e com o tema (brand).
- **11.6** Verificação completa + relatório.

## Testes da fase

- `expectGeometry(tester, [...idsOfSection('nav'), 'bottomFade'])` → 18/18 (canvas 390×2390).
- Viewport 390×844 (`safeTop 47, safeBottom 34`): nav em y **744**, FAB em y **723,5**; após rolar até o fim, nav e FAB no mesmo lugar.
- Golden do viewport: `inicio_viewport@3x.png` (390×844, safe 47/34) comparado com `inicio_viewport_390x844_DERIVADA@3x.png` → `blur_mismatch_% ≤ 0,5`.
- Toques: tocar a parte do FAB **acima** da barra (ex.: y = 2275) abre `/scanner`; tocar "Biblioteca" troca a aba e o item ativo.
- Tema: `brand` muda o item ativo junto com o hero.
- Visual (canvas): `--rect 0,2230,390,160` → `blur_mismatch_% ≤ 0,5`.
- Não-regressão F03–F10.

## Checklist de aceite da FASE 11

- [ ] 11.1 Fade 390×150 transparente→`#F7F0E3` em 55%, sem toque, abaixo da barra na ordem de pintura
- [ ] 11.2 Barra 358×70 em bottom 30, `#FFFAF1`, borda 1,5, raio 28, sombra (0,4,0), padding 8, 5 colunas de 64,6 com gap 4
- [ ] 11.3 Ativo: brand + borda 1,5 + raio 20, casa preenchida `#FFFAF1`, "Início" 700 tinta; inativos: 600 `#5B544B`
- [ ] 11.4 FAB 60×60 `#FED170` borda 1,5 sombra (0,4) com ícone 28, topo 20,5 acima da barra, 100% tocável; rótulo "Scanner" 700 tinta embaixo (padding 2)
- [ ] 11.5 go_router: troca de aba, ativo correto, `/scanner` por push; tema brand aplicado
- [ ] 11.5 Semântica da navegação (container, selecionado, rótulo do scanner sem duplicar)
- [ ] Geometria 18/18 · Viewport OK · Golden do viewport ≤ 0,5% · Toques OK · Visual ≤ 0,5% · Não-regressão OK
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório com lado-a-lado (canvas e viewport) inspecionados

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 11 concluída — aguardando sua aprovação para iniciar a FASE 12.`
