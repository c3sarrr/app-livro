# FASE 12 — Integração: toques, rotas, semântica, tema e desempenho

> Pré-requisito: FASE 11 aprovada (todas as seções visuais prontas).
> Resultado: a tela deixa de ser "estática" — todos os alvos de toque navegam, a acessibilidade reproduz o arquivo, o tema funciona e o desempenho é de produção — **sem mudar 1 pixel do estado de repouso**.

---

## Subfase 12.1 — Mapa de toques (todos com `Pressable`, sem ripple)

| Elemento (Key) | Destino / ação | Observação |
|---|---|---|
| `header.bell` | `context.push('/notificacoes')` | alvo 48×48 |
| `hero.cta` | `context.push('/leitor/dom-casmurro')` | alvo 243×54 |
| `hero.notesButton` | `context.push('/livro/dom-casmurro/destaques')` | alvo 54×54 (badge não bloqueia) |
| `alsoReading.card1` / `card2` | `context.push('/livro/<id>')` | card inteiro |
| `forYou.seeAll` | `context.push('/para-voce')` | altura 44 |
| `forYou.item1..3` | `context.push('/livro/<id>')` | item inteiro (capa + textos) |
| `club.cta` | `context.push('/clube/leitoras-de-capitu/discussao')` | 221×46 |
| `recent.libraryLink` | `context.go('/biblioteca')` (troca de aba) | altura 44 |
| `recent.rowN.textBlock` | `context.push('/livro/<id>')` | só o bloco de texto é link (como no HTML) |
| `recent.rowN.more` | abre nada visual (callback `onMore(book)` vazio + `// TODO(produto)`) | o arquivo não define o menu — **não invente** |
| `nav.*` / `nav.scanner.fab` | abas / `/scanner` | F11 |

- Todos os destinos são as rotas-placeholder da F02.
- `Pressable.feedbackEnabled = true` em produção; nos goldens não há toque (repouso idêntico).
- Teste: para cada linha da tabela, `tester.tap(find.byKey(...))` + `pumpAndSettle` → rota esperada ativa; voltar (`pop`) → Início **no mesmo scroll**.

## Subfase 12.2 — Acessibilidade (espelho dos `aria-*` do arquivo)

Convenção (prompt mestre §5.1): seção = `Semantics(container: true, explicitChildNodes: true, label)`; cabeçalho = `Semantics(container: true, header: true)`; rótulo/valor próprio = `Semantics(container: true, label, value?, excludeSemantics: true)`; toque = `Pressable` (sempre nó próprio); decorativo = `ExcludeSemantics`.
Monte um teste de semântica (`tester.ensureSemantics()`) que encontra **exatamente** estes rótulos, cada um num nó próprio e sem rótulos concatenados. Exceções esperadas (2 nós com o mesmo rótulo, como no HTML): "Continuar lendo" (seção + link do CTA); "Também lendo", "Seu dia de leitura" e "Para você" (seção + cabeçalho `<h3>`).
- Seções: "Continuar lendo", "Também lendo", "Seu dia de leitura", "Para você", "Seu clube do livro", "Adicionados recentemente", "Navegação principal".
- "Notificações, 2 novas" · "Destaques e notas deste livro (14)" · "Progresso do livro" (valor 62%) · "Minutos lidos por dia: segunda 32, terça 45, quarta 30, quinta 22, sexta 38, sábado 55, hoje 18 de 30" · "11 participantes" · "Progresso do grupo" (54%) · "Você" · "3 mensagens novas" · "Próximo encontro: quinta, 24 de setembro, às 20h" · "Mais opções para Frankenstein" / "O Alienista" / "Senhora" · "Scanner: escanear livro ou página".
- Cabeçalhos (`header: true`): h1 "Continue sua história.", h2 "Dom Casmurro", h3 "Também lendo", "Seu dia de leitura", "Para você", "Leitoras de Capitu", "Recém-chegados". Os títulos de duas linhas (F04, F09) já usam `label` sem quebra + `excludeSemantics`.
- Elementos `aria-hidden` (brilhos, círculos decorativos, **desenho** do dial — o "18" e "de 30 min" ficam legíveis —, linha da meta, entalhes, fade) **fora** da árvore.
- Item ativo da navegação com `selected: true`.
- Rode `meetsGuideline(androidTapTargetGuideline)` e `meetsGuideline(iOSTapTargetGuideline)` — os alvos do arquivo já têm ≥ 44 px; registre qualquer falha (não altere o visual para corrigir: reporte).
- `meetsGuideline(textContrastGuideline)`: registre o resultado (informativo — as cores são do arquivo).

## Subfase 12.3 — Tema (props do arquivo)

- `brand`: hero + item ativo da navegação. `weekColor`: preenchimentos 0–5 do gráfico.
- Em `kDebugMode`, a galeria `/_ds` ganha um seletor com as 4 opções de cada (D-11). Produção usa o padrão `#B6ACE4`.
- Golden extra por opção de `brand` (4) e de `weekColor` (4) — só a região afetada muda (compare com o golden padrão: diferença fora das regiões esperadas = 0).

## Subfase 12.4 — Desempenho de produção

- `const` em tudo que for constante; `select` do Riverpod por seção (rebuild mínimo).
- `RepaintBoundary` em volta de: dial, gráfico semanal, cada capa, carrossel.
- Pintores com `shouldRepaint` corretos (comparação de campos).
- Sem `Opacity` widget, sem `saveLayer` desnecessário (as translucências são cores com alpha).
- Pré-cache dos SVGs no `main()` (`AppIcons.all`) para não "piscar" na primeira abertura.
- Perfil (`flutter run --profile`): rolar a tela do topo ao fim e registrar o tempo médio de build/raster (meta: 0 frames acima de 16 ms em aparelho médio). Rode **no que estiver disponível**: Android (aparelho real ou emulador) e/ou iPhone **real** — o modo profile **não roda no simulador iOS**. Se nenhum alvo existir no ambiente, registre como **pendência para o usuário** (com o comando exato) e siga. Se houver jank, otimize **sem alterar pixels** e prove com o golden.

## Subfase 12.5 — Plataforma

- Android: edge-to-edge, barra de navegação do sistema transparente com ícones escuros, sem "scrim".
- iOS: status bar escura; toque na status bar rola para o topo — quem implementa isso é o **`Scaffold`** da `HomeScreen` (F02), que anima o `PrimaryScrollController`; por isso o scroll usa `primary: true`. Teste no **viewport 390 × 844** (`setCanvasView(tester, logical: const Size(390, 844), safeTop: 47, safeBottom: 34)` — no canvas 390×2390 não há o que rolar, e a faixa da status bar precisa de altura > 0). Plataforma iOS **antes** do `pumpWidget` (o `Theme` lê a plataforma no build; sem iOS o `Scaffold` nem cria a faixa da status bar): `testWidgets(..., variant: TargetPlatformVariant.only(TargetPlatform.iOS))` ou `debugDefaultTargetPlatformOverride = TargetPlatform.iOS` no início (e `null` no fim). Role 800 px e dispare o toque na status bar **pelo mecanismo do seu SDK**:
  - Flutter atual: o iOS envia `handleScrollToTop` no canal `SystemChannels.statusBar` e o `ScaffoldState` (um `WidgetsBindingObserver`) reage em `handleStatusBarTap()`. No teste:
    ```dart
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      SystemChannels.statusBar.name,
      SystemChannels.statusBar.codec.encodeMethodCall(const MethodCall('handleScrollToTop')),
      (_) {},
    );
    ```
  - SDKs antigos (o `Scaffold` ainda punha um `GestureDetector` na faixa da status bar): `await tester.tapAt(const Offset(195, 10));`.
  → após `pumpAndSettle`, o offset do scroll volta a 0. Confira no código do `Scaffold` da sua versão qual caminho vale e registre no relatório.
- Rolagem: física padrão de cada plataforma (bounce no iOS, stretch no Android), sem mudar o repouso.
- Se houver emulador Android (perfil de hardware personalizado **390 × 844 dp**) e/ou simulador iPhone 13/14 (390 × 844 pt) no ambiente: prints comparados lado a lado com `inicio_viewport_390x844_DERIVADA@3x.png` e anexados. Se não houver, a prova automática é o golden do viewport (F11) e os prints viram **pendência para o usuário** (liste os comandos).

---

## Checklist de aceite da FASE 12

- [ ] 12.1 Todos os toques da tabela navegam para as rotas certas; voltar preserva o scroll
- [ ] 12.1 "Mais opções" sem UI inventada (callback + TODO de produto)
- [ ] 12.2 Todos os rótulos semânticos do arquivo presentes; cabeçalhos marcados; decorativos fora da árvore
- [ ] 12.2 Diretrizes de alvo de toque e contraste executadas e registradas
- [ ] 12.3 `brand` e `weekColor` com as 4 opções cada; goldens por opção sem efeitos colaterais
- [ ] 12.4 Otimizações aplicadas sem mudança de pixel (golden canvas idêntico ao aprovado na F11)
- [ ] 12.4 Perfil de rolagem registrado (0 frames > 16 ms em aparelho médio ou justificativa) — ou pendência registrada se não houver alvo (profile não roda em simulador iOS)
- [ ] 12.5 Comportamento de sistema (edge-to-edge, status bar, toque na status bar via `Scaffold`) testado; prints de emulador/simulador anexados **ou** pendência registrada
- [ ] `dart format` / `flutter analyze` (0) / `flutter test` verdes
- [ ] Relatório no modelo do prompt mestre

**Ao concluir: entregue o relatório e PARE.**
`✅ FASE 12 concluída — aguardando sua aprovação para iniciar a FASE 13.`
