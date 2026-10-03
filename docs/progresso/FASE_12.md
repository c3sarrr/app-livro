# FASE 12 — Integração: toques, rotas, semântica, tema e desempenho

Checklist da fase (`design_handoff/fases/F12_integracao_interacoes.md`), item por item. Um item só é marcado com evidência.
Saídas literais dos comandos: `F12_verificacao.txt` · autorrevisão: `F12_comparacao.md`.

- [x] 12.1 Todos os toques da tabela navegam para as rotas certas; voltar preserva o scroll
  - `HomeScreen` (agora `ConsumerWidget` que só lê o id no toque) liga os 10 callbacks das seções às rotas-placeholder da F02: sino → `/notificacoes`; CTA → `/leitor/dom-casmurro`;
    destaques → `/livro/dom-casmurro/destaques`; cards → `/livro/<id>`; "Ver tudo" → `/para-voce`; itens → `/livro/<id>`; CTA do clube → `/clube/leitoras-de-capitu/discussao`;
    textos das linhas → `/livro/<id>` (todos por `push`); "Biblioteca" → `go('/biblioteca')` (troca de aba).
  - `touch_home_test.dart` (23 testes): para cada uma das 13 linhas de `push`, a Início rolada no aparelho 390×844 → `tester.tap` → rota certa + placeholder certo + shell fora de cena → voltar do sistema →
    Início **na mesma rolagem** (e o carrossel horizontal também); `recent.libraryLink` troca de aba e a Início volta na mesma rolagem; alvos 48×48 / 243×54 / 54×54 / 221×46 / altura 44
    respondem nos 4 lados e no centro e **não** respondem 4 px fora; ponto do sino, ícone, rótulos e badge (camadas sobrepostas) não bloqueiam o toque; sem `InkWell`/`InkResponse`, feedback = escala 0,97.
- [x] 12.1 "Mais opções" sem UI inventada (callback + TODO de produto)
  - `HomeScreen.onMoreOptions(Book)` é um no-op com `// TODO(produto)`; o teste prova que o botão tem ação de toque e rótulo, e que tocar não muda a rota, não monta rota/diálogo/folha/menu nem barreira modal.
- [x] 12.2 Todos os rótulos semânticos do arquivo presentes; cabeçalhos marcados; decorativos fora da árvore
  - `semantics_home_test.dart`: os 28 pares (rótulo, papel) da lista da F12 em nós próprios (as 4 exceções com exatamente 2 nós), nenhum nó funde 2 rótulos, 7 cabeçalhos nos níveis h1/h2/h3,
    32 decorativos fora da árvore, "18" e "de 30 min" legíveis, `selected` só no Início, 5 botões + 17 links com a ação `tap`.
- [x] 12.2 Diretrizes de alvo de toque e contraste executadas e registradas
  - iOS 44×44: **passou** · rótulos: **passou** · contraste (tema padrão + as 7 outras opções): **passou** · **Android 48×48: reprova exatamente os 3 botões "Mais opções" (44×44 no arquivo)** — visual não alterado.
- [x] 12.3 `brand` e `weekColor` com as 4 opções cada; goldens por opção sem efeitos colaterais
  - Seletor na rota `/_ds` (só `kDebugMode`): `DesignSystemScreen` = `HomeThemeSelector` + galeria; `theme_selector_test.dart` (3) + golden `ds_tema_seletor@3x.png`.
  - `golden_theme_test.dart`: 8 opções comparadas pixel a pixel com o golden padrão: **0 pixels fora das regiões esperadas** em todas; a padrão = 0 diferenças; 12 PNGs `inicio_brand_*` / `inicio_weekcolor_*`.
- [x] 12.4 Otimizações aplicadas sem mudança de pixel (golden canvas idêntico ao aprovado na F11)
  - `flutter test test/home/golden_canvas_test.dart test/home/golden_viewport_test.dart` **sem** `--update-goldens`: passa; `sha256` dos dois PNGs inalterados desde a F11.
  - Aplicado: `RepaintBoundary` no **dial** e no **carrossel** (0 pixels de diferença, provado); pré-cache dos 18 SVGs no `main()`; `select` por seção provado (brand → só hero + barra; weekColor → só o cartão do dia; rolar → nada);
    sem `Opacity`/`saveLayer` (varredura de `lib/` + árvore em execução); `shouldRepaint` dos 6 pintores compara todos os campos (teste).
  - **Não aplicado, medido:** `RepaintBoundary` nas capas e no gráfico semanal mudam o anti-aliasing de curvas (3–89 px, Δ ≤ 12/255; 178 px com tudo ligado) e **quebram o golden idêntico** → decisão do usuário (relatório).
- [x] 12.4 Perfil de rolagem registrado (0 frames > 16 ms em aparelho médio ou justificativa) — ou pendência registrada se não houver alvo (profile não roda em simulador iOS)
  - **Pendência de ambiente registrada** (sem aparelho, sem AVD e sem JDK 17 — `flutter doctor` marca o Android toolchain com `!`); comando exato no relatório.
- [x] 12.5 Comportamento de sistema (edge-to-edge, status bar, toque na status bar via `Scaffold`) testado; prints de emulador/simulador anexados **ou** pendência registrada
  - `platform_test.dart` (9): estilo **enviado** ao sistema (status bar transparente com ícones escuros / conteúdo escuro no iOS; barra de navegação transparente, ícones escuros, `contrastEnforced: false` = sem scrim)
    e o mesmo em todas as rotas (região na raiz do `App`); fade até a borda real da tela; toque na status bar do iOS (`handleScrollToTop` → `Scaffold` → rolagem 0, no 390×844 com safe 47/34, plataforma iOS antes do `pumpWidget`);
    física: Android clamping + stretch, iOS bounce, repouso igual.
  - Caminho do SDK 3.47.2: o iOS envia `handleScrollToTop` em `SystemChannels.statusBar` e o `ScaffoldState.handleStatusBarTap` reage (no Android a mesma mensagem dispara um assert do framework: a faixa só existe no iOS).
  - **Prints de emulador/simulador: pendência de ambiente registrada** (comandos no relatório); a prova automática é o golden do viewport (F11), que continua idêntico.
- [x] `dart format` / `flutter analyze` (0) / `flutter test` verdes
  - `Formatted 132 files (0 changed)`, exit 0 · `No issues found!`, exit 0 · `+528: All tests passed!` (465 anteriores + 63 novos da F12), 3 execuções completas.
- [x] Relatório no modelo do prompt mestre
  - `RELATORIO_FASE_12.md`.
