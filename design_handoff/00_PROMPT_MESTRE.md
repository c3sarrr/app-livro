# PROMPT MESTRE — Tela "Início" do App de Leitura em Flutter (réplica pixel a pixel)

> Versão 1.1 · 23/09/2026 (revisada por auditoria independente contra o código-fonte do Flutter/Skia) · Idioma de trabalho: português do Brasil
> Fonte de design: `referencia/original/Redesign mobile — App de leitura.html` (bundle do Claude Design, 1 tela: **Início**, canvas 390 × 2390)

---

## 0. Como usar (para o humano)

1. Copie a pasta inteira `prompt_flutter_inicio/` para a raiz do repositório Flutter com o nome **`design_handoff/`** (não renomeie nada dentro dela).
2. Cole **este arquivo inteiro** no agente de código (Claude Code, Cursor, etc.) como primeira mensagem.
3. O agente executa **uma fase por vez**. Ao final de cada fase ele entrega um relatório com o checklist 100% marcado e **para**. Você revisa e responde **"OK, próxima fase"** (ou pede correções).
4. Nunca peça "faz tudo de uma vez". A qualidade depende das travas de fase.

---

## 1. Papel e missão (para o agente)

Você atua simultaneamente como:

- **Engenheiro de software nível PhD** em Flutter/Dart, motores de renderização (Skia/Impeller), tipografia digital e layout (CSS ↔ Flutter).
- **Designer de produto sênior**, com olho para detalhe de 0,5 px, que nunca aceita "parecido".

**Missão:** reproduzir em Flutter a tela **Início** do arquivo de design de forma **idêntica** — mesma geometria (±0,5 px), mesmas cores (hex exatos), mesmas fontes (os mesmos binários, com o mesmo *optical size* e o mesmo peso efetivamente renderizado), mesmas quebras de linha, mesma ordem de pintura (z-order), mesmos recortes, sombras duras, hachuras, tracejados, rotações e ícones. **Nada pode ser simplificado, aproximado, omitido ou "melhorado".**

A tela é longa (rolagem vertical). Ela será construída **seção por seção**, cada seção como uma fase com subfases e checklist de aceite.

---

## 2. Hierarquia da verdade (em caso de conflito, vence o item de cima)

1. **HTML original** — `design_handoff/referencia/original/Redesign mobile — App de leitura.html`. É um bundle: o HTML real da tela está embutido. O trecho literal de cada seção já foi extraído e colado em cada arquivo de fase. Nesses trechos, `sc-camel-view-box` é a codificação do bundler para o atributo SVG `viewBox`, e `{{brand}}`/`{{weekColor}}` são as props do componente (padrão `#B6ACE4`).
2. **Geometria medida** — `design_handoff/referencia/layout/layout_inicio.json` e o gerado `reference_layout.dart` (retângulos de layout de 248 elementos, linhas de texto com baseline, estilos computados). Medido no Chromium com zoom 100 (bordas exatas de 1,5/1,2 px, métricas sem arredondamento).
3. **PNGs de referência** — `design_handoff/referencia/png/`:
   - `inicio_canvas_390x2390@1x|@2x|@3x.png` — canvas completo (supersample 10× → reduzido; é o alvo visual).
   - `inicio_viewport_390x844_DERIVADA@2x|@3x.png` — **derivada**: primeira dobra num aparelho 390×844 com a navegação fixa (composição que o comentário do arquivo descreve; não existe como tela separada no arquivo).
   - `secoes/Fxx_*.png` — recorte @3x de cada seção. `redline/Fxx_*_redline@3x.png` — mesmo recorte com os retângulos numerados (Nº das tabelas das fases).
   - `inicio_w360x2390@2x.png` e `inicio_w430x2390@2x.png` + `layout/layout_w360.json`/`_w430.json` + `layout/reference_layout_w360.dart`/`_w430.dart` — comportamento fluido em outras larguras (validação secundária, fase 13).
4. **Este prompt e os arquivos de fase.**

Se encontrar qualquer divergência entre fontes, **pare e reporte** (não escolha sozinho).

---

## 3. Regras absolutas (inegociáveis)

### 3.1 Ritmo de trabalho
1. **Uma fase por vez.** Leia apenas `00_PROMPT_MESTRE.md` + o arquivo da fase atual. Não implemente nada de fases futuras.
2. **Checklist obrigatório.** Ao iniciar a fase, crie a lista de tarefas com TODOS os itens do checklist da fase (use a ferramenta de tarefas do seu ambiente — TodoWrite/TaskCreate — ou, se não houver, o arquivo `docs/progresso/FASE_XX.md` com `- [ ]`). Marque um item **somente com evidência** (teste passando, print, número medido).
3. **Gate de saída.** Só declare a fase concluída com **100% dos itens marcados** e todos os testes verdes. Então entregue o relatório (modelo na seção 9) e **PARE**, terminando com a frase exata:
   `✅ FASE N concluída — aguardando sua aprovação para iniciar a FASE N+1.`
4. Se algo bloquear (ferramenta, dependência, ambiguidade), **pare e pergunte**. Não contorne. Única exceção: as **pendências de ambiente previstas no próprio arquivo da fase** (build nativo sem Android SDK/Xcode na F00; perfil em aparelho e prints de emulador/simulador na F12) — registre-as com o comando exato e siga.
5. Não reescreva fases já aprovadas sem pedir. Correções pedidas pelo usuário viram uma subfase "N.x-correção" com checklist próprio.

### 3.2 Proibições (anti-simplificação) — violar qualquer uma reprova a fase
- ❌ Trocar ícones SVG do arquivo por `Icons.*`/Cupertino/qualquer outro pacote. Use **exatamente** `design_handoff/assets/icons/*.svg`.
- ❌ Usar `google_fonts` ou fontes do sistema. Use **exatamente** `design_handoff/assets/fonts/*.ttf` (gerados a partir dos binários do próprio arquivo).
- ❌ Arredondar medidas: 1,5 px **não** vira 1 ou 2; 1,2 px **não** vira 1; 6,5 px de fonte **não** vira 6 ou 7; 0,91 px de espaçamento **não** vira 1.
- ❌ Aproximar cores ou usar cores do tema Material. Só os hex do arquivo (tabela em F01).
- ❌ Remover/"limpar" decorações: brilhos (sparkles), círculos decorativos, lombadas das capas, hachuras diagonais, linha de meta tracejada, entalhes do ticket, perfuração tracejada, sombras duras, rotações das capas.
- ❌ Trocar sombra dura (`x y 0 cor`) por `elevation`, `Material`, `Card`, `PhysicalModel` ou sombra com blur.
- ❌ Usar widgets Material com estilo padrão (Card, Chip, ElevatedButton, FilledButton, ListTile, BottomNavigationBar, NavigationBar, AppBar, FloatingActionButton, Badge, LinearProgressIndicator, CircularProgressIndicator, Divider com altura padrão). Tudo é construído com primitivos do design system (F01).
- ❌ Ripple/splash/highlight do Material sobre qualquer elemento (quebra o visual). Feedback de toque apenas pelo padrão definido em D-04.
- ❌ Escalar a interface (ScreenUtil, `MediaQuery.size.width / 390`, FittedBox na tela, etc.). **1 px CSS = 1 dp lógico.** O layout é fluido exatamente como o CSS (fase 13 valida 360 e 430).
- ❌ Alterar textos (acentos, maiúsculas, "·", "~", "…"), alterar quebras de linha, usar `\n` onde o arquivo não quebra (exceto nas artes de capa, que já têm `<br>` ou são ilustrações — ver cada fase).
- ❌ Inventar estados/telas/elementos que não existem no arquivo. Qualquer necessidade fora do arquivo entra em "Decisões fora do arquivo" (seção 10) — mínima e registrada.
- ❌ Usar `Text`/`RichText` do Flutter diretamente na tela. Todo texto usa o primitivo `AppText` (F01) — motivo técnico na seção 6.4.
- ❌ Desligar/afrouxar testes, tolerâncias ou goldens para "passar". Se não passa, corrige-se a implementação.

### 3.3 Obrigações
- ✅ Cada elemento não-inline das tabelas das fases vira um widget com `Key` igual ao id (`ValueKey<String>('hero.cover')`), posicionado no **retângulo de layout** do elemento (para elementos rotacionados, a Key vai no widget de layout **antes** do `Transform`).
- ✅ Todo número do código vem das tabelas das fases / tokens da F01. Nada "no olho".
- ✅ Código limpo: `flutter analyze` sem avisos, `dart format` aplicado, widgets `const` sempre que possível, nada de lógica de negócio na UI.
- ✅ Acessibilidade: os `aria-label` do arquivo viram `Semantics(label: ...)` com o texto idêntico, seguindo a convenção da seção 5.1; elementos `aria-hidden` ficam fora da árvore semântica.

---

## 4. Stack, dependências e arquitetura

- **Flutter**: canal stable mais recente (mínimo 3.27 — usamos `spacing:` em `Row`/`Column` e `Color.withValues`). Dart 3 (records, `sealed`, `abstract final class`).
- **Dependências de produção** (somente estas): `flutter_riverpod`, `go_router`, `flutter_svg`.
- **Dependências de dev**: `flutter_test` (SDK), `flutter_lints` (ou `very_good_analysis`, se já existir no projeto).
- **Proibidas**: `google_fonts`, `flutter_screenutil`, pacotes de UI prontos, pacotes de ícones.

### 4.1 Estrutura de pastas (feature-first)
```
lib/
  main.dart
  app/
    app.dart                  # MaterialApp.router, tema mínimo, trava de escala de texto, DefaultTextHeightBehavior
    router.dart               # go_router: StatefulShellRoute (Início, Biblioteca, Clubes, Perfil) + /scanner (full screen)
  core/design_system/
    tokens/  app_colors.dart app_typography.dart app_radii.dart app_strokes.dart app_shadows.dart app_spacing.dart app_icons.dart
    text/    app_text.dart (RenderBox de parágrafo com métricas exatas)
    painters/ hatch_painter.dart chromium_dash.dart ring_progress_painter.dart goal_dial_painter.dart top_border_crescent_painter.dart
    widgets/ neo_box.dart pill.dart count_badge.dart circle_icon_button.dart app_svg.dart pressable.dart stadium_progress_bar.dart
  features/
    home/
      domain/models.dart
      data/home_repository.dart            # mock com os dados EXATOS do arquivo
      application/home_providers.dart      # Riverpod
      application/formatters.dart          # "4h 00min", "~2h 10min", "QUI", "SET", plurais
      presentation/home_screen.dart
      presentation/sections/  header_section.dart headline_section.dart continue_reading_hero.dart also_reading_section.dart
                              reading_day_card.dart for_you_section.dart book_club_ticket.dart recently_added_section.dart
      presentation/covers/    (uma arte por capa: dom_casmurro_cover.dart, mrs_dalloway_cover.dart, ...)
    shell/presentation/  main_shell.dart floating_nav_bar.dart scanner_fab.dart bottom_fade.dart
    placeholder/presentation/placeholder_screen.dart
test/
  support/  load_fonts.dart precache_svgs.dart canvas.dart geometry.dart   # F00
            text_lines.dart                                            # F01 (expectTextLines)
  reference/reference_layout.dart          # cópias de design_handoff/referencia/layout/ (NUNCA editar valores)
            reference_layout_w360.dart reference_layout_w430.dart      # só F13
  design_system/ …                         # testes dos primitivos
  home/ geometry_*_test.dart  golden_*_test.dart  text_*_test.dart  style_*_test.dart
  golden/goldens/                          # PNGs gerados pelo Flutter (comparados com a referência via ferramenta)
tools/compare_images.py                    # cópia de design_handoff/ferramentas/compare_images.py
design_handoff/                            # este pacote (somente leitura)
```

### 4.2 Estado e dados (Riverpod)
- `homeRepositoryProvider` → `HomeMockRepository` (síncrono) devolvendo um `HomeSnapshot` com **todos** os dados do arquivo (nomes, números, datas, cores das capas).
- `homeSnapshotProvider` → lê o repositório. **Sem** loading/erro/vazio visuais (não existem no arquivo — D-09).
- `homeThemeProvider` (`Notifier`) → `brand` e `weekColor` (props do arquivo; padrão `#B6ACE4`; opções na F01).
- Formatação 100% derivada de dados (ex.: 240 min → `4h 00min`; faltam `30 − 18 = 12 min`; `+8 = 11 participantes − 3 avatares`). O resultado precisa ser **idêntico** ao texto do arquivo — coberto por testes unitários.

### 4.3 Navegação (go_router)
- `StatefulShellRoute.indexedStack` com 4 ramos: `/inicio` (esta tela), `/biblioteca`, `/clubes`, `/perfil` (placeholders — D-07).
- `/scanner`: rota full-screen fora do shell (D-08).
- O `MainShell` pinta: corpo da aba → `BottomFade` → `FloatingNavBar` → `ScannerFab` (nesta ordem de pintura — ver F11).

---

## 5. Tradução CSS → Flutter (regras de fidelidade — leia com atenção)

| CSS do arquivo | Flutter obrigatório | Armadilha que você deve evitar |
|---|---|---|
| 1 px | 1.0 dp lógico | Nunca multiplicar por fator de tela |
| `box-sizing: border-box` + `width/height` | `Container(width, height)` com `BoxDecoration(border)` — o Flutter desenha a borda **dentro** e o `Container` já recua o filho pela largura da borda | Não somar a borda de novo no padding |
| **content-box** com borda (sem `box-sizing`) e tamanho explícito | tamanho externo = conteúdo + 2×borda (ex.: ponto do sino 9+3 = **12×12**; anel da capa 18+3 = **21×21**; círculos decorativos 150+3 = **153**, 98+3 = **101**) | As tabelas das fases marcam esses casos com ⚠ |
| `overflow: hidden` + `border-radius` | recortar os **filhos** no retângulo interno (padding box) com raio interno = raio − borda (`NeoBox(clip: true)`) | `Container(clipBehavior:)` recorta na borda EXTERNA e deixa filhos pintarem por cima da borda — proibido para estes casos |
| `border-radius: 999px` | pílula: raio = metade do menor lado (`BorderRadius.circular(999)` é normalizado igual ao CSS pelo Skia) | Não usar raio menor "parecido" |
| `border-radius: 4px 10px 10px 4px` | `BorderRadius.only(topLeft: 4, topRight: 10, bottomRight: 10, bottomLeft: 4)` (ordem CSS: TL, TR, BR, BL) | Ordem trocada |
| `box-shadow: X Y 0 #1A1714` | `BoxShadow(offset: Offset(X, Y), blurRadius: 0, spreadRadius: 0, color: ink)` no mesmo `BoxDecoration` da caixa | Recortar a caixa com `ClipRRect` por fora (corta a sombra) |
| `position: absolute` (top/right/bottom/left) | `Stack` + `Positioned`, medidas relativas à **padding box** (dentro da borda) | Medir a partir da borda externa |
| `position: absolute` pinta **acima** do conteúdo estático (ordem de pintura CSS) | No `Stack`, os filhos posicionados vêm **depois** do conteúdo de fluxo | Ex.: brilho pequeno do hero pinta por cima do título "Dom Casmurro"; linha tracejada da meta pinta por cima das barras |
| `transform: rotate(θ)` | `Transform.rotate(angle: θ·π/180)` (origem no centro, não afeta layout; sombra e borda giram juntas) | Rotacionar com a Key no widget girado (Key vai no slot de layout) |
| `margin-top` negativo / conteúdo que "vaza" | `OverflowBox`/`Stack(clipBehavior: Clip.none)` mantendo o tamanho de layout do CSS | Deixar o vazamento alterar a altura da linha |
| `display:flex; gap:N` | `Row/Column(spacing: N)` | `SizedBox` esquecido/duplicado |
| `justify-content: space-between` | `MainAxisAlignment.spaceBetween` | — |
| `align-items: baseline` | `CrossAxisAlignment.baseline` + `TextBaseline.alphabetic` | — |
| `align-items: stretch` (padrão do flex CSS) | `CrossAxisAlignment.stretch` | O padrão do Flutter é `center` |
| `align-self: flex-start` dentro de coluna esticada | `Align(alignment: Alignment.centerLeft, child: ...)` | — |
| `grid-template-columns: repeat(n, minmax(0,1fr))` + gap | `Row(spacing: gap)` com `Expanded` em cada coluna | Colunas por conteúdo |
| `flex-grow:1; min-width:0` + irmão que encolhe (`flex-shrink:1`) | algoritmo de flex-shrink do CSS implementado explicitamente (F10) | `Expanded` + `Flexible` NÃO reproduzem o CSS |
| `white-space: nowrap; text-overflow: ellipsis` | `AppText(maxLines: 1, ellipsis: true)` com largura do contêiner | — |
| `line-height: normal` | altura = métricas da fonte: **1,2** (Figtree, Bricolage) e **1,3** (Instrument Serif) — declarar explicitamente | Deixar `height: null` |
| `line-height: N` (sem unidade) | `height: N` com `TextLeadingDistribution.even` | Distribuição proporcional (padrão Flutter) desloca a baseline |
| `letter-spacing: X em` | `letterSpacing: X × fontSize` (0,14em a 6,5 px = **0,91**; 0,1em a 10 px = **1,0**; 0,08em a 12 px = **0,96**) | — |
| `font-weight: 800` em **Figtree** | **w700** (o `@font-face` do arquivo só declara até 700: o navegador renderiza 700 — verificado) | Usar 800 deixa o texto mais pesado que o arquivo |
| Bricolage Grotesque (fonte variável, eixo `opsz`) | família estática do **tamanho exato** (`Bricolage18`, `Bricolage24`, …) — o navegador aplica `opsz = font-size` | Usar um único arquivo da Bricolage para todos os tamanhos |
| `repeating-linear-gradient(135deg, A 0 3px, B 3px 7px)` | `HatchPainter` (F01): `t = (x + y)/√2` a partir do canto superior esquerdo da padding box; A se `t mod 7 < 3` | Listras na direção errada (são "/"), fase errada, suavização |
| `border-*: 1.5px dashed` | `ChromiumDash` (F01): traço 3 px, vão ideal 1,5 px ajustado para terminar com traço (algoritmo do Chromium) | `dash 4 / gap 4` genérico |
| `border-top` só no topo + `border-radius: 999px` | `TopBorderCrescentPainter` (F01): meia-lua que afina até 0 nas laterais | `Border(top:)` com raio (o Flutter não suporta e/ou desenha errado) |
| `opacity: .45` / `.35` num traço de cor única | cor com alpha (`0x73`/`0x59`) no `Paint` | `Opacity` widget (camada extra) |
| `letter-spacing` numa linha alinhada à esquerda | `AppText` já corrige: o SkParagraph desloca a linha em **metade do letter-spacing** do 1º caractere (`TextLine.cpp`, "fix for flutter"); o `RenderAppText` pinta com `dx = −lineMetrics.left` | Um parágrafo com linhas de letter-spacing diferentes (`<br>` entre fontes) → **uma coluna de `AppText`**, um por linha (F04, F09) |
| `aria-label` / `role` com valor | `Semantics(container: true, label:, value:?, excludeSemantics: true)` idêntico (seção 5.1) | Sem `container`, o rótulo se funde no nó do pai |
| `aria-hidden="true"` | `ExcludeSemantics` | — |

### 5.1 Convenção de semântica (vale para todas as fases)
| HTML | Flutter |
|---|---|
| `<section aria-label>` / `<nav aria-label>` | `Semantics(container: true, explicitChildNodes: true, label: …)` — nó próprio que **não** absorve os filhos |
| `<h1>`–`<h3>` | `Semantics(container: true, header: true, child: AppText(...))`; título de 2 linhas: `label` sem quebra + `excludeSemantics: true` |
| `<a>` / `<button>` | `Pressable` (F01): sempre nó próprio; com `aria-label` → `semanticsLabel`; sem → o texto dos filhos vira o nome (como no navegador) |
| elemento com `aria-label`/`role="progressbar"` | `Semantics(container: true, label:, value:?, excludeSemantics: true)` |
| `aria-current="page"` | `Semantics(selected: true)` **dentro** do `Pressable` do item |
| `aria-hidden="true"` | `ExcludeSemantics` |

O `AppText` não é fronteira semântica (igual ao `RenderParagraph`): dentro de um nó **sem** `explicitChildNodes` (link, cabeçalho, rótulo) o texto dele se funde nesse nó; dentro de uma seção (`explicitChildNodes: true`, que atravessa os widgets sem semântica) cada `AppText` solto vira um nó de texto próprio — igual ao `Text` do Flutter.

---

## 6. Tipografia (crítico)

### 6.1 Arquivos
`design_handoff/assets/fonts/` contém fontes **estáticas** geradas pelo script `ferramentas/build_fonts.py` a partir dos **mesmos woff2** embutidos no HTML (validado: largura de texto com desvio ≤ 0,05 px e rasterização idêntica ao navegador). Declare-as com `ferramentas/pubspec_fonts.yaml` (copie o bloco para o `pubspec.yaml`).

- **Bricolage Grotesque** (títulos/numerais): peso 800, **uma família por tamanho** (optical size): `Bricolage12` (usado nos 11 px — o eixo começa em 12), `Bricolage18`, `Bricolage20`, `Bricolage22`, `Bricolage24`, `Bricolage26`, `Bricolage34`, `Bricolage42`. Fallbacks: `Bricolage{N}Ext`, `Bricolage{N}Vi`.
- **Figtree** (texto de interface): pesos 400/500/600/700. Fallback `FigtreeExt`. **Não existe 800** (e não deve existir — ver 5).
- **Instrument Serif** (serifadas editoriais e títulos de capa): Regular + Italic. Fallback `InstrumentSerifExt`.
- Os subsets "Ext"/"Vi" existem porque o arquivo usa `unicode-range` (latin / latin-ext / vietnamese). Mesclar os subsets num único TTF quebra o kerning — por isso ficam separados como `fontFamilyFallback`.
- Licença: SIL OFL 1.1 (`assets/fonts/LICENCAS_FONTES_OFL.txt`) — manter o arquivo junto das fontes no app.

### 6.2 Regras
1. `TextLeadingDistribution.even` em **todos** os estilos (e `DefaultTextHeightBehavior` na raiz).
2. `height` **sempre explícito** (ver tabela da F01): `normal` = 1,2 (Figtree/Bricolage) ou 1,3 (Instrument Serif).
3. Escala de texto do sistema travada em 1,0 (D-05).
4. Cores de texto exatas por elemento (há 8 cores de texto diferentes).
5. Kerning e ligaduras padrão (iguais ao navegador) — não desligar.

### 6.3 Pesos e tamanhos que existem no arquivo
São **46 estilos de texto** (tokens); todos estão catalogados na F01 com nome semântico. Nenhum texto da tela pode usar estilo fora do catálogo.

### 6.4 Por que `AppText` e não `Text`
O `TextPainter`/`RenderParagraph` do Flutter historicamente **arredonda para cima** largura e altura do parágrafo para pixels inteiros ("floating point hack"). Ex.: uma linha Figtree 13 px mede 15,6 px no arquivo e viraria 16 px — somando dezenas de textos, a tela desce vários px e as pílulas ficam até 1 px mais largas. O primitivo `AppText` (F01) faz layout de um `ui.Paragraph` e usa as **medidas exatas** (sem arredondar), baseline exata, `maxLines`/reticências e semântica. A F01 inclui um teste que **prova** a diferença no seu SDK; mesmo que a sua versão do Flutter não arredonde mais, `AppText` continua obrigatório (determinismo).

Segundo motivo: o SkParagraph desloca cada linha alinhada à esquerda em **metade do letter-spacing** do primeiro caractere (ex.: "Continue", ls −1,4, sairia 0,7 px à esquerda — o suficiente para reprovar o gate visual da F04). O navegador não faz isso. O `AppText` desfaz o deslocamento por parágrafo (teste (f) da F01).

---

## 7. Protocolo de verificação (4 camadas — todas obrigatórias por fase)

1. **Geometria (gate principal, automático).** Teste de widget renderizando o app num viewport lógico **390 × 2390** (DPR 3) e comparando `tester.getRect(find.byKey(ValueKey(id)))` com `kRefLayout[id].rect`:
   - vertical (y, h): **±0,5 px** para todos;
   - horizontal (x, w): **±0,5 px**, exceto ids em `kTextDependentX` (**±1,0 px**);
   - texto (`expectTextLines`, F01): linhas iguais (mesma quantidade e mesmo conteúdo), baseline ±0,5 px, início/fim da linha ±0,5 px.
2. **Estilo (automático).** Para cada caixa-chave, o teste lê a decoração/pintor e confere cor, largura de borda, raio, sombra e alpha **exatos** (sem tolerância).
3. **Visual (semiautomático).** Golden do Flutter @3x do mesmo retângulo → `python3 tools/compare_images.py` contra o PNG de referência. Gate: `blur_mismatch_% ≤ 0,5` por seção (calibrado: deslocamento de 0,33 px passa; ≥ 0,67 px falha). Anexar heatmap e lado-a-lado ao relatório e **olhar as imagens** (você mesmo deve abrir e inspecionar).
4. **Texto (automático).** Strings idênticas ao arquivo, quebras de linha idênticas (tabelas "Linhas de texto"), reticências onde existem.

Comandos padrão ao fim de cada fase — **nesta ordem** (o golden precisa existir antes do `flutter test`). Os passos 1–2 começam na **F02**, quando o teste de golden do canvas é criado; em F00/F01 rode só os passos 3–4.
```bash
# 0) SÓ na F12 e na F13 (nenhuma seção nova): o golden aprovado na F11 precisa continuar idêntico
flutter test test/home/golden_canvas_test.dart          # SEM --update-goldens; falhou = regressão → corrija
# 1) gera/atualiza o PNG do Flutter (canvas inteiro 390×2390 @3x)
flutter test --update-goldens test/home/golden_canvas_test.dart
git diff --stat -- test/golden/goldens                  # registre no relatório o que mudou (se houver git)
# 2) camada visual: seção da fase + todas as seções já concluídas (não-regressão)
python3 tools/compare_images.py --flutter test/golden/goldens/inicio_canvas@3x.png \
  --ref design_handoff/referencia/png/inicio_canvas_390x2390@3x.png --scale 3 \
  --rect <x,y,w,h da seção> --out build/visual_diff/<fase> --name <fase>
python3 tools/compare_images.py --flutter test/golden/goldens/inicio_canvas@3x.png \
  --ref design_handoff/referencia/png/inicio_canvas_390x2390@3x.png --scale 3 \
  --layout design_handoff/referencia/layout/layout_inicio.json --out build/visual_diff/<fase>/todas
#    (no modo --layout, seções ainda não construídas FALHAM por definição — só as concluídas precisam PASSAR)
# 3) qualidade
dart format --set-exit-if-changed lib test
flutter analyze            # 0 problemas (inclui "info")
# 4) suíte completa (geometria, estilo, texto, goldens já aprovados)
flutter test
```
> Observação: o golden do Flutter é **gerado** (`--update-goldens`) e a aprovação vem da comparação com a referência do HTML (camada 3) + geometria (camada 1). Como o PNG do canvas muda a cada fase de seção (entra uma seção nova), a proteção contra regressão **entre fases** é o passo 2 com `--layout` (todas as seções concluídas contra a referência do HTML) + geometria/estilo/texto do passo 4. Da F12 em diante nenhuma seção nova entra: aí vale o passo 0 (golden aprovado intocado).

**Quando só o gate visual falha.** O gate foi calibrado com cópias deslocadas da própria referência, nunca com um render real do Flutter. Se geometria, estilo e texto estão 100% verdes e mesmo assim `blur_mismatch_% > 0,5`: (1) abra heatmap/lado-a-lado/onion e localize as diferenças; (2) se houver **qualquer** diferença de forma, posição, cor, espessura, ordem de pintura ou recorte → é bug, corrija; (3) se a diferença for **exclusivamente** de rasterização (suavização de borda, hinting de glifo, arredondamento de sub-pixel do motor) → **não** mexa no gate nem "empurre" pixels: **pare**, entregue a evidência (recortes ampliados + números) e peça a decisão do usuário. Nunca marque a fase como concluída com o gate vermelho sem essa aprovação explícita.

---

## 8. Execução de cada fase (roteiro que você segue sempre)

1. Ler o arquivo da fase inteiro (tabelas, HTML literal, armadilhas).
2. Criar a lista de tarefas = checklist da fase (item por item, sem agrupar).
3. Para cada subfase: implementar → rodar testes da subfase → marcar itens com evidência.
4. **Auto-revisão pixel a pixel:** abrir `secoes/Fxx_*@3x.png`, o `redline` e o seu golden lado a lado; percorrer a tabela da fase linha por linha conferindo número por número.
5. Rodar os comandos da seção 7; guardar saídas.
6. Relatório (seção 9) → **PARAR**.

---

## 9. Modelo do relatório de fase (obrigatório)

```
## Relatório — FASE N: <título>
### Entregue
- arquivos criados/alterados (caminhos)
### Checklist (100%)
- [x] item … — evidência: <teste/print/medida>
### Verificação
- Geometria: X/Y elementos dentro da tolerância (maior desvio: id, valor)
- Estilo: X/Y asserts
- Visual: tabela do compare_images.py (+ caminhos dos PNGs de evidência)
- Texto: X/Y strings e quebras
- flutter analyze: 0 problemas · dart format: ok · flutter test: N passaram
### Decisões fora do arquivo usadas nesta fase
- D-xx …
### Riscos/pendências
- (deve estar vazio para concluir a fase — exceto as pendências de ambiente previstas na fase: F00 0.3, F12 12.4/12.5, cada uma com o comando exato para o usuário rodar)

✅ FASE N concluída — aguardando sua aprovação para iniciar a FASE N+1.
```

---

## 10. Decisões fora do arquivo (registradas — não crie outras sem perguntar)

| ID | Decisão | Motivo |
|---|---|---|
| D-01 | Navegação inferior e fade inferior **fixos** no viewport; conteúdo rola por baixo | Comentário literal do arquivo: "fixed in the app" / "content slips under the floating nav" |
| D-02 | Inset superior do conteúdo = `max(62, viewPadding.top + 15)`; `bottom` da navegação = `max(30, viewPadding.bottom − 4)` | No canvas/golden (viewPadding 0) resulta exatamente 62 e 30; num iPhone 390×844 (47/34) também 62 e 30 |
| D-03 | Carrossel "Para você" rola na horizontal (física da plataforma), estado de repouso idêntico ao arquivo | O 3º card cortado na borda é a affordance de rolagem |
| D-04 | Toque: sem ripple/splash; feedback = escala 0,97 por 90 ms (entrada) / 120 ms (saída), `Curves.easeOut`, via `Pressable`; desligável por flag | O arquivo não define estados de toque; repouso permanece idêntico |
| D-05 | Escala de fonte do sistema travada em 1,0 | O layout tem alturas fixas (48, 54, 70, 32 px…); revisar com design antes de liberar |
| D-06 | Somente retrato | Tela desenhada só em retrato |
| D-07 | Abas Biblioteca/Clubes/Perfil = placeholders (fundo `#F7F0E3` + título em Bricolage 24); estado ativo dessas abas segue a regra da aba Início (pílula brand + ícone com preenchimento `#FFFAF1` + rótulo 700 tinta) usando os SVGs `_extrapolado_*` | Arquivo só mostra a Início ativa |
| D-08 | Scanner = rota full-screen placeholder aberta por push; a aba ativa não muda | Botão central de ação |
| D-09 | Repositório mock síncrono com os dados exatos; "agora" de referência fixo em **domingo 20/09/2026 20:00** (saudação "Boa noite,", semana S T Q Q S S + Hoje, encontro quinta 24/09); sem estados de loading/erro/vazio | Não existem no arquivo; coerência interna dos dados |
| D-10 | Barras da semana: no mock, alturas do arquivo `[43, 60, 40, 30, 51, 73, 24]` px; para dados reais, `minutos × 4/3` px (escala inferida), limitado à altura interna do trilho: **77,6** (borda 1,2) e **77,0** na barra de hoje (borda 1,5) | Arquivo usa px fixos; a regra linear diverge ≤ 0,67 px |
| D-11 | `brand` e `weekColor` configuráveis (props do arquivo), padrão `#B6ACE4` | Props do componente no arquivo |
| D-12 | Linha "O Alienista" reproduz o arquivo: autor quebra em 2 linhas e o selo "Quero ler" quebra em "Quero / ler" (flex-shrink do CSS) | Fidelidade; **não corrigir** sem pedido do usuário |
| D-13 | Status bar transparente com ícones escuros; Android edge-to-edge | Fundo claro, conteúdo sob a status bar |
| D-14 | Textos Figtree com `font-weight: 800` renderizam **700** | Comportamento real do arquivo (verificado) |
| D-15 | Rótulos semânticos = `aria-label` do arquivo | Acessibilidade sem alterar visual |

---

## 11. Mapa das fases

| Fase | Arquivo | Entrega |
|---|---|---|
| F00 | `fases/F00_preparacao.md` | Projeto, dependências, assets, fontes, harness de testes (geometria, golden, comparação) |
| F01 | `fases/F01_design_system.md` | Tokens (cores, tipografia, raios, traços, sombras), `AppText`, pintores e primitivos |
| F02 | `fases/F02_shell_e_dados.md` | Modelos, mock, providers, formatadores, rotas, `MainShell` e esqueleto da Início |
| F03 | `fases/F03_header.md` | Cabeçalho (avatar, saudação, sino) |
| F04 | `fases/F04_headline.md` | Título editorial "Continue / sua história." |
| F05 | `fases/F05_hero_continuar_lendo.md` | Cartão "Continuar lendo" (capa Dom Casmurro, progresso, ações) |
| F06 | `fases/F06_tambem_lendo.md` | "Também lendo" (2 cards, capas, anéis) |
| F07 | `fases/F07_seu_dia_de_leitura.md` | "Seu dia de leitura" (dial, chips, gráfico semanal, selo) |
| F08 | `fases/F08_para_voce.md` | "Para você" (motivo, carrossel, 3 capas) |
| F09 | `fases/F09_clube_do_livro.md` | Ticket do clube (corpo, canhoto, perfuração, entalhes) |
| F10 | `fases/F10_recem_chegados.md` | "Recém-chegados" (lista, mini-capas, flex-shrink) |
| F11 | `fases/F11_navegacao_inferior.md` | Navegação flutuante, FAB Scanner, fade |
| F12 | `fases/F12_integracao_interacoes.md` | Interações, semântica, rotas, tema, desempenho |
| F13 | `fases/F13_qa_final.md` | QA final pixel a pixel (canvas, viewport, 360/430), auditoria anti-simplificação |

---

## 12. Definição de pronto (tela inteira)

- Todas as fases aprovadas pelo usuário.
- Geometria: 100% dos ids dentro da tolerância no canvas 390×2390.
- Visual: todas as seções com `blur_mismatch_% ≤ 0,5` contra `inicio_canvas_390x2390@3x.png`; viewport 390×844 idem contra a referência derivada.
- Texto: 100% das strings e quebras idênticas.
- Zero itens da lista de proibições (3.2) — auditoria da F13 assinada.
- `flutter analyze` limpo, `flutter test` verde, app rodando em Android e iOS.

**Comece agora pela FASE 0 (`design_handoff/fases/F00_preparacao.md`). Não leia outras fases.**
