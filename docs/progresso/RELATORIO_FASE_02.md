## Relatório — FASE 2: Dados, estado, rotas e esqueleto da tela Início

### Entregue
- Domínio: `lib/features/home/domain/models.dart` (11 tipos imutáveis + `CoverArt`, `RecentStatus` e o enum cru `BookFormat`).
- Dados: `lib/features/home/data/home_repository.dart` (`HomeRepository` + `HomeMockRepository`, `referenceNow` = dom 20/09/2026 20:00).
- Aplicação: `lib/features/home/application/formatters.dart` (`HomeFormatters`, sem `intl`) e `home_providers.dart` (`clockProvider`, `homeRepositoryProvider`, `homeSnapshotProvider`, `HomeTheme`/`HomeThemeController`/`homeThemeProvider`).
- App: `lib/app/app.dart` (`App` / `App.forTests()`), `lib/app/router.dart` (`AppRoutes` + `createRouter`); `lib/main.dart` alterado (licença OFL mantida + `configureSystemUi()` + `ProviderScope(App)`).
- Telas: `lib/features/shell/presentation/main_shell.dart`, `lib/features/home/presentation/home_screen.dart` (esqueleto com os 8 placeholders), `lib/features/placeholder/presentation/placeholder_screen.dart`.
- Testes (80 novos): `test/home/formatters_test.dart` (27), `home_repository_test.dart` (16), `home_providers_test.dart` (10), `app_test.dart` (6), `router_test.dart` (5), `geometry_shell_test.dart` (15), `golden_canvas_test.dart` (1); helper `test/support/pump_app.dart` (`pumpApp`, `homeScrollPosition`).
- Golden: `test/golden/goldens/inicio_canvas@3x.png` (1170 × 7170, só o fundo `#F7F0E3`).
- Documentação: `docs/progresso/FASE_02.md` (checklist com evidências), `F02_verificacao.txt` (saídas literais da §7), `F02_comparacao.md` (autorrevisão visual e conferência da tabela da fase), este relatório.
- Removidos os 7 `.gitkeep` vazios das pastas que deixaram de estar vazias (`lib/app`, `lib/features/home/{application,data,domain}`, `lib/features/{placeholder,shell}/presentation`, `test/home`); `covers/` e `sections/` seguem vazias com o seu.
- Sem dependências novas (`pubspec.yaml`/`pubspec.lock` intocados). Nenhum arquivo da F00/F01 alterado. Sem commit (ver Informativo).

### Checklist (100%)
- [x] 2.1 Modelos imutáveis (sem strings formatadas) — evidência: 11 classes `@immutable` com construtor `const` e 54 campos `final` (verificação acusa mutação); únicos `String` = nomes/títulos/ids/iniciais; formato como `enum BookFormat`
- [x] 2.2 Mock com 100% dos dados; `referenceNow = 2026-09-20 20:00` — evidência: 12 testes campo a campo; alturas das barras e cores A/J/L conferidas contra o próprio HTML original
- [x] 2.3 Formatadores idênticos à tabela — evidência: 20/20 linhas da tabela + 34 saídas encontradas literalmente no HTML original (9 `aria-label`, 22 textos, 2 frases com negrito, rótulos da semana)
- [x] 2.4 Providers + `HomeThemeController` — evidência: 10 testes; 4 + 4 opções aceitas; opções da outra prop, flame, tinta e `#B6ACE5` → `AssertionError` sem mudar o estado
- [x] 2.5 `App` (escala travada, "even", NoSplash, sem banner) + `main.dart` (edge-to-edge, retrato) — evidência: 6 testes, inclusive `main()` de ponta a ponta com o canal de plataforma simulado
- [x] 2.6 Rotas do shell + `/scanner` + destinos + `/_ds` — evidência: 5 testes (abas; scanner `fullscreenDialog` no navigator raiz sem trocar a aba; 6 destinos com parâmetros; galeria em debug; `PlaceholderScreen` centrado na área segura)
- [x] 2.7 `MainShell` (ordem do HTML, `navBottom`) — evidência: 3 camadas na ordem, fade `IgnorePointer` sem receber toque, D-13, `navBottom` 0 → 30, 34 → 30, 48 → 44
- [x] 2.7 `HomeScreen` (Scaffold papel + `primary: true`, inset, gutters, gaps, 140) — evidência: estrutura, inset 62/62/74, gaps `[24, 24, 32, 36, 40, 40, 40]`, conteúdo 2355,16, toque na status bar do iOS rola ao topo
- [x] 2.8 Geometria 10/10 no canvas — evidência: `expectGeometry` verde; todos os Δ = 0 (maior ≈ 2·10⁻¹³ px)
- [x] 2.8 Viewport 390×844: header em 62, nav em 744 — evidência: `header` (20, 62, 350, 48), `nav` (16, 744, 358, 70)
- [x] 2.8 Rolagem até 2355,16 com nav fixa — evidência: extensão 2355,16; fim em 1511,16; `recent.bottom` 704; `nav` em 744 durante e no fim
- [x] 2.8 Abas/placeholders e preservação do scroll — evidência: rolagem 600,0 antes e 600,0 ao voltar à Início
- [x] 2.8 (teste 6) Golden do canvas + `--rect 0,0,390,56` — evidência: `blur_mismatch_%` 0,0 e `raw_mismatch_%` 0,0 (`max_diff` 0), PASSOU
- [x] `dart format` / `flutter analyze` / `flutter test` — evidência: 0 mudanças · No issues found! · +200: All tests passed!
- [x] Relatório no modelo — este documento

### Verificação
- Geometria: 10/10 elementos dentro da tolerância (maior desvio: `recent.y` ≈ −2·10⁻¹³ px, ruído de ponto flutuante; todos os outros Δ = 0,0000). Aparelho 390 × 844 (47/34): `header.y` = 62, `nav.y` = 744. Rolagem: extensão total 2355,16.
- Estilo (exatos, sem tolerância): tema (M3, `scaffoldBackgroundColor` `#F7F0E3`, `NoSplash`, realce e hover transparentes); `DefaultTextStyle` Figtree 16/400, height 1,2, tinta, "even"; `DefaultTextHeightBehavior` "even"; `TextScaler.noScaling`; `SystemUiOverlayStyle` da D-13 (6 campos); `Scaffold` papel sem nenhum slot além do corpo; camadas do shell (posições 0/0/0/150 e 16/16/30/70); `PlaceholderScreen` (`ColoredBox` papel, `sectionTitleL`).
- Visual:

  | Região | blur_mismatch_% | raw_mismatch_% | mean_abs | max | Resultado |
  |---|---:|---:|---:|---:|---|
  | inset superior (0, 0, 390, 56) | 0,0 | 0,0 | 0,0 | 0 | PASSOU |

  Lado a lado e heatmap inspecionados: idênticos (`build/visual_diff/F02/F02_inset_superior_{lado_a_lado,heatmap,onion}.png`). O modo `--layout` foi rodado como linha de base: as 10 regiões falham por definição (nenhuma seção construída; a §7 exige só as concluídas) — tabela em `F02_comparacao.md`.
- Texto: 20/20 saídas da tabela 2.3 idênticas; 34/34 saídas encontradas literalmente no HTML original.
- flutter analyze: 0 problemas · dart format: ok (61 arquivos, 0 mudanças) · flutter test: 200 passaram (120 da F00/F01 + 80 da F02) · `design_handoff/` intacto (131/131).

### Decisões fora do arquivo usadas nesta fase
- D-01 (navegação e fade fixos, conteúdo rola por baixo), D-02 (inset e `navBottom`), D-05 (escala travada), D-06 (retrato), D-07 (placeholders das abas), D-08 (Scanner full screen por push), D-09 (agora de referência, mock síncrono, sem loading/erro/vazio), D-10 (alturas do arquivo no mock), D-11 (`brand`/`weekColor` só com as opções do arquivo), D-13 (status bar/edge-to-edge).
- Notas técnicas (não criam D-xx; peço sua confirmação junto com a aprovação):
  1. **go_router 18 × `MaterialApp` do SDK:** o go_router 18 detecta o `MaterialApp` do pacote `material_ui`, não o do SDK (`package:flutter/material.dart`, que a fase pede). Com `builder:`, as rotas virariam `NoTransitionPage`. Todas as rotas (inclusive o shell) usam `pageBuilder` com o `MaterialPage` do SDK e os mesmos parâmetros que o go_router usaria — o comportamento que a fase pressupõe.
  2. Títulos dos placeholders fora das abas (não existem no arquivo): "Scanner", "Notificações", "Leitor", "Livro", "Destaques e notas", "Para você", "Discussão"; título com semântica de cabeçalho (§5.1). Destinos = rotas de topo no navigator raiz, abertas por push, sem `fullscreenDialog`.
  3. `App.forTests()` = `App()` + `overridePlatformDefaultLocation: true` (sempre começa em `/inicio`, ignorando um deep link da plataforma).
  4. Auxiliares da 2.3 para as setas da tabela: `weekTotalLabel` ("4h 00min no total"), `participantsAria` ("11 participantes"), `formatLabel` ("EPUB"/"PDF"). Para entradas que não existem no arquivo os formatadores mantêm o padrão do arquivo (45 min → "0h 45min"; 20:30 → "20h30"; singular só para 1; "faltam" nunca negativo).
  5. Neste SDK o toque na status bar do iOS chega como a mensagem `handleScrollToTop` (`SystemChannels.statusBar`), não mais como toque em (0, 0); o `Scaffold` continua sendo quem a trata — o motivo da fase para usar `Scaffold` foi confirmado por teste com essa mensagem.

### Riscos/pendências
- Nenhuma.
- Informativo — git: o repositório só tem o commit da F00 (`70ae231`); a F01 aprovada e esta F02 estão sem commit. Não fiz commits (você não pediu). Os arquivos das duas fases estão em caminhos separados, então dá para fazer um commit por fase quando você quiser.
- Informativo para as próximas fases: Keys de layout precisam ser `ValueKey<String>`; um `ValueKey(campoAnulável)` vira `ValueKey<String?>` e não casa na busca (o teste de geometria pegou isso aqui e foi corrigido).

✅ FASE 2 concluída — aguardando sua aprovação para iniciar a FASE 3.
