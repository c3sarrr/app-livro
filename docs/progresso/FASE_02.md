# FASE 2 — Dados, estado, rotas e esqueleto da tela Início

Checklist da fase (`design_handoff/fases/F02_shell_e_dados.md`), item por item. Um item só é marcado com evidência.
Linha de base antes de qualquer alteração (prova de que F00/F01 estão íntegras): `flutter analyze` → "No issues found!" (exit 0) · `flutter test` → "+120: All tests passed!" (exit 0).
Saídas literais dos comandos: `F02_verificacao.txt` · autorrevisão visual: `F02_comparacao.md`.

- [x] 2.1 Modelos imutáveis criados (sem strings formatadas)
  — `lib/features/home/domain/models.dart`: os 11 tipos da 2.1 + `enum CoverArt` (9 capas) e `enum RecentStatus`, todos `@immutable`, campos `final` (54) e construtores `const`. O formato do livro é o `enum BookFormat { epub, pdf }` (dado cru; "EPUB"/"PDF" só no formatador). `test/home/home_repository_test.dart` (grupo 2.1, 4 testes): tipos e valores dos enums; toda classe `@immutable` + `const` e nenhum campo sem `final` (a verificação acusa uma mutação de teste `int streakDays;`); os únicos `String` são `id`, `title`, `shortTitle`, `author`, `firstName`, `initial`, `reasonAuthor`, `namePrefix`, `nameHighlight`, `userInitial`; instâncias em expressões `const`.
- [x] 2.2 Mock com 100% dos dados da tabela; `referenceNow = 2026-09-20 20:00`
  — `lib/features/home/data/home_repository.dart`: `HomeRepository` (interface) + `HomeMockRepository` (síncrono, `referenceNow = DateTime(2026, 9, 20, 20)`, domingo). Grupo 2.2 do mesmo teste (12 testes): cada linha da tabela campo a campo (usuário; continuar lendo; também lendo; dia de leitura; semana seg 14/09 → dom 20/09 com minutos `[32, 45, 30, 22, 38, 55, 18]`, alturas `[43, 60, 40, 30, 51, 73, 24]` e hoje = domingo; para você com título curto; clube com A/J/L = `#B6ACE4`/`#ABCF82`/`#FFC1C6` e encontro quinta 24/09 20:00; recém-chegados), 9 ids/capas distintos, listas imutáveis e — contra o HTML original — as 7 alturas das barras e as 3 cores dos avatares extraídas do próprio arquivo.
- [x] 2.3 Formatadores + testes unitários: todas as saídas idênticas à tabela
  — `lib/features/home/application/formatters.dart` (`HomeFormatters`, sem `intl`; abreviações e nomes próprios). `test/home/formatters_test.dart` (27 testes): as 20 linhas da tabela 2.3 com a entrada do mock e a saída exata (inclusive faixas da saudação hora a hora, "4h 00min no total" pela soma da semana = 240, trechos com negrito, U+00B7 com espaços); abreviações completas (SEG…DOM, JAN…DEZ); e **conferência literal no HTML original** de 34 saídas: 9 `aria-label`, 22 nós de texto (incluindo "12 dias"), as 2 frases com `<strong>` e os rótulos da semana (`S T Q Q S S` + "Hoje" em destaque).
- [x] 2.4 Providers (`clock`, `homeRepository`, `homeSnapshot`, `homeTheme`) + testes do `HomeThemeController` (só aceita as opções do arquivo)
  — `lib/features/home/application/home_providers.dart` (código da fase). `test/home/home_providers_test.dart` (10 testes): padrões (relógio = `referenceNow`, repositório = mock, snapshot = mock); relógio injetado → "Bom dia,"; repositório injetado vira a fonte; `select` do recorte; tema padrão `#B6ACE4`/`#B6ACE4`; as 4 opções de brand e as 4 de weekColor aceitas (preservando a outra prop); fora das opções (inclusive as opções da OUTRA prop e `#B6ACE5`) → `AssertionError` sem mudar o estado; ouvintes notificados.
- [x] 2.5 `App` com trava de escala de texto, `DefaultTextHeightBehavior` even, `NoSplash`, sem banner de debug; `main.dart` com edge-to-edge e retrato
  — `lib/app/app.dart` e `lib/main.dart`. `test/home/app_test.dart` (6 testes): `debugShowCheckedModeBanner: false` e nenhum `CheckedModeBanner`; tema M3, fundo `#F7F0E3`, `NoSplash.splashFactory`, realce/hover transparentes; com o sistema pedindo 2× (controle: `scale(10) = 20` fora do builder), dentro do app `TextScaler.noScaling`; `DefaultTextHeightBehavior` "even" e `DefaultTextStyle` Figtree 16/400, height 1,2, tinta; `App.forTests()` em `/inicio`; `configureSystemUi()` chama `setEnabledSystemUIMode(edgeToEdge)` e `setPreferredOrientations([portraitUp])`; `main()` de ponta a ponta: licença OFL, as 2 chamadas de sistema, `ProviderScope` acima do `App`, Início aberta.
- [x] 2.6 Rotas do shell + `/scanner` + destinos placeholder + `/_ds` (debug)
  — `lib/app/router.dart` (`AppRoutes` + `createRouter`) e `lib/features/placeholder/presentation/placeholder_screen.dart`. `test/home/router_test.dart` (5 testes): abas `/inicio` `/biblioteca` `/clubes` `/perfil` (`StatefulShellRoute.indexedStack`, também por `goBranch`); `/scanner` por push no navigator raiz, `fullscreenDialog: true`, cobre o shell e a aba ativa (Clubes) não muda, nem ao voltar; os 6 destinos (`/notificacoes`, `/leitor/:bookId`, `/livro/:bookId`, `/livro/:bookId/destaques`, `/para-voce`, `/clube/:clubId/discussao`) por push no navigator raiz com os parâmetros certos; `/_ds` (em `kDebugMode`) abre a galeria da F01; `PlaceholderScreen`: `ColoredBox` papel 390 × 844, `SafeArea`, 1 único `AppText` em `sectionTitleL` centrado na área segura (195; 428,5), semântica de cabeçalho.
- [x] 2.7 `MainShell` com as camadas na ordem do HTML e `navBottom` = max(30, viewPadding.bottom − 4)
  — `lib/features/shell/presentation/main_shell.dart`. `test/home/geometry_shell_test.dart` (grupo MainShell, 5 testes): `Stack` com exatamente 3 camadas na ordem conteúdo (`StatefulNavigationShell`, fill) → fade (0/0/0, h 150, `IgnorePointer`, Key `bottomFade`, não recebe toque) → navegação (16/16/30, h 70, Key `nav`); sem `Scaffold` no shell (o único do app é o da Início); `AnnotatedRegion` com o estilo da D-13 (6 campos); `navBottom`: bottom 0 → 30, 34 → 30, 48 → 44.
- [x] 2.7 `HomeScreen` = `Scaffold(backgroundColor: paper)` + `SingleChildScrollView(primary: true)` com inset `max(62, viewPadding.top + 15)`, gutters, gaps 24/24/32/36/40/40/40 e padding inferior 140
  — `lib/features/home/presentation/home_screen.dart`. Mesmo arquivo de teste (grupo HomeScreen, 5 testes + 3 do canvas): `Scaffold` papel sem appBar/drawer/endDrawer/FAB/bottomNavigationBar/bottomSheet; `primary: true`, vertical, `padding` (62 | 140); coluna `stretch`; inset top 0 → 62, 47 → 62, 59 → 74; gaps medidos `[24, 24, 32, 36, 40, 40, 40]`; conteúdo 2355,16 com 140 depois de `recent`; gutters x 20 / w 350 nos 8 blocos; "Para você" num contêiner 0 → 390; no iOS a mensagem `handleScrollToTop` do sistema rola a Início ao topo (o motivo do `Scaffold`).
- [x] 2.8 Geometria dos 10 blocos no canvas: 10/10 dentro da tolerância
  — `expectGeometry` com os 10 ids no canvas 390 × 2390 (DPR 3): 10/10; todos os Δ = 0,0000 px (maior: `recent.y` ≈ −2·10⁻¹³ px, ruído de ponto flutuante). Saída por id em `F02_verificacao.txt`.
- [x] 2.8 Viewport 390×844: header em 62 e nav em 744
  — safe 47/34: `header` = (20, 62, 350, 48); `nav` = (16, 744, 358, 70); `bottomFade` = (0, 694, 390, 150). Saída: `[aparelho] header.y = 62.0 | nav.y = 744.0`.
- [x] 2.8 Rolagem até 2355,16 com nav fixa
  — `maxScrollExtent + viewportDimension` = 2355,16 (ε 10⁻⁹); com arrastos até o fim, `pixels` = 1511,16 = 2355,16 − 844, `recent.bottom` = 704 (= 844 − 140) e a `nav` em 744 durante e ao fim da rolagem. Saída: `[rolagem] extensão total 2355.16 | fim em 1511.1599999999999 | recent.bottom 704.0 | nav.y 744.0`.
- [x] 2.8 Navegação entre abas/placeholders e preservação do scroll
  — Início rolada a 600,0 → Biblioteca → Clubes → Perfil (placeholders na tela, Início montada fora da tela, camadas fixas por cima) → `goBranch(1)` → `/inicio`: rolagem 600,0 (`[rotas] rolagem da Início ao voltar: 600.0`). Scanner e destinos: ver 2.6.
- [x] 2.8 (teste 6, sem linha própria no checklist; exigido também pela §7) Golden do canvas gerado; `--rect 0,0,390,56` com `blur_mismatch_%` = 0,0 e `raw_mismatch_%` = 0,0
  — `test/home/golden_canvas_test.dart` (modelo da F00 com `captureAt` @3x) → `test/golden/goldens/inicio_canvas@3x.png` 1170 × 7170, uma única cor (247, 240, 227) = `#F7F0E3`; regenerado com os mesmos bytes (sha256 igual). `compare_images.py --rect 0,0,390,56`: `blur_mismatch_%` 0,0 · `raw_mismatch_%` 0,0 · `max_diff` 0 → PASSOU; lado a lado e heatmap inspecionados (idênticos, sem vermelho).
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  — `Formatted 61 files (0 changed)` exit 0 · `No issues found!` exit 0 · `+200: All tests passed!` exit 0 (120 da F00/F01 + 80 da F02) · `design_handoff/` 131/131 OK.
- [x] Relatório no modelo do prompt mestre
  — `RELATORIO_FASE_02.md` (e na conversa).

## Subfase 2.8-correção (aprovada pelo usuário durante a F04, 23/09/2026)

Motivo: na F04 o placeholder `headline` (um `SizedBox` de 90,16 exatos) virou texto real. A altura de cada linha de texto vem
das métricas de fonte que o SkParagraph calcula em float32 (`SkScalar`): título = 41,16000175 + 49 = 90,16000175 px (Δ 1,75·10⁻⁶).
Quatro asserções deste arquivo exigiam ε 10⁻⁹ / igualdade exata de `Rect` sobre alturas acumuladas e passaram a falhar (o gate de
geometria de ±0,5 px passa, com maior desvio 0,000002). Decisão do usuário: tolerância de ruído float32 de ±10⁻³ px (500× abaixo do
gate; a referência medida tem 2 casas decimais) nessas 4 asserções. Nenhum código de produção mudou.

- [x] Constante `_float32Noise = 1e-3` com o motivo documentado
  — `test/home/geometry_shell_test.dart`, logo após `_blocks`.
- [x] "ritmo vertical": altura total do conteúdo 2355,16 (±10⁻³)
  — obtido `[ritmo] ... conteúdo 2355.1600017547607`.
- [x] "gutters 20; Para você": contêiner com x = 0 e largura 390 exatos; topo 1207,56 e altura 327 (±10⁻³) — antes: igualdade exata de `Rect`
  — topo obtido 1207,5600017547607.
- [x] "aparelho 390×844 — rolagem até o fim": extensão total 2355,16 e fim da rolagem 1511,16 (±10⁻³)
  — `[rolagem] extensão total 2355.1600017547607 | fim em 1511.1600017547607 | recent.bottom 704.0 | nav.y 744.0`.
- [x] Continuam exatos, sem mudança: gaps `[24, 24, 32, 36, 40, 40, 40]` (6 casas), padding inferior 140 (ε 10⁻⁹), `recent.bottom` 704 no fim da rolagem (ε 10⁻⁹), inset 62, nav em 744
  — mesmas saídas acima (`[ritmo] gaps [24.0, 24.0, 32.0, 36.0, 40.0, 40.0, 40.0]`).
- [x] `geometry_shell_test.dart` 15/15 verdes; suíte completa verde
  — `F04_verificacao.txt`: `+224: All tests passed!`.
